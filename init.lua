--  _                         _   _  __
-- | |                       | | (_)/ _|
-- | | ___   __ _ _ __   ___ | |_ _| |_ _   _
-- | |/ _ \ / _` | '_ \ / _ \| __| |  _| | | |
-- | | (_) | (_| | | | | (_) | |_| | | | |_| |
-- |_|\___/ \__, |_| |_|\___/ \__|_|_|  \__, |
--           __/ |                       __/ |
--          |___/                       |___/
--
-- log watcher for awesome wm
-- show a naughty popup each time something
-- changes in one of the predefined log files.
--
-- based on work of koniu <gkusnierz <at> gmail.com>
-- (see https://awesome.naquadah.org/wiki/Naughty_log_watcher)
--
-- Copyright (c) 2011-2012, Jörg Thalheim <jthalheim@gmail.com>
--
-- This program is free software. It comes without any warranty, to
-- the extent permitted by applicable law. You can redistribute it
-- and/or modify it under the terms of the Do What The Fuck You Want
-- To Public License, Version 2, as published by Sam Hocevar. See
-- http://sam.zoy.org/wtfpl/COPYING for more details.

-- {{{ Grab enviroment
-- standart library
local io = io and { open = io.open } or require("io")
local bit = bit or require('bit')
local ipairs = ipairs
local pairs = pairs
local print = print
local setmetatable = setmetatable
local timer = (type(timer) == 'table' and timer or require("gears.timer"))
local type = type
-- external
local socket = require("socket")
local inotify = require("inotify")
local escape = awful and awful.util.escape or require("awful.util").escape
local naughty = naughty or require("naughty")
-- }}}

local lognotify = {}

LOGNOTIFY = {}
LOGNOTIFY_mt = { __index = LOGNOTIFY }

function lognotify.new(settings)
    local watcher = {}
    if type(settings) ~= "table" then settings = {} end

    watcher.logs = settings.logs or {}
    watcher.naughty_timeout = settings.naughty_timeout or 0
    watcher.timer = timer({ timeout = settings.interval or 1})

    setmetatable(watcher, LOGNOTIFY_mt)

    return watcher
end

function LOGNOTIFY:start()
    local errno, errstr
    self.inotify, errno, errstr = inotify.init()
    self.sd = { getfd = function () return self.inotify:fileno() end }
    for logname, log in pairs(self.logs) do
        self:read_log(logname)
        self:watch_log(logname)
    end
    if self.timer.connect_signal then
        self.timer:connect_signal("timeout", function() self:watch() end)
    else
        self.timer:add_signal("timeout", function() self:watch() end)
    end
    self.timer:start()
end

function LOGNOTIFY:stop()
    self.timer:stop()
    self.inotify:close()
end

function LOGNOTIFY:watch()
    if #socket.select({self.sd}, nil, 0) > 0 then
        local events, nread, errno, errstr = self.inotify:read()
        if events then
            for i, event in ipairs(events) do
                for logname, log in pairs(self.logs) do
                    if event.wd == log.wd then
                        if bit.band(event.mask, inotify.IN_MOVE_SELF) ~= 0 then
                            self:watch_log(logname)
                        end
                        local diff = self:read_log(logname)
                        if diff then
                            self:notify(logname, log.file, diff)
                        end
                    end
                end
            end
        end
    end
end

function LOGNOTIFY:watch_log(logname)
    local log = self.logs[logname]
    if log.wd then
        self.inotify:rmwatch(log.wd)
    end
    log.wd, errno, errstr = self.inotify:addwatch(log.file,
                                                  inotify.IN_MODIFY,
                                                  inotify.IN_MOVE_SELF)
    log.len = nil
    self:read_log(logname)
end

function LOGNOTIFY:read_log(logname)
    local log = self.logs[logname]

    -- read log file
    local f, errno = io.open(log.file)
    if not f then
        print("[lognotify] Can't read: "..errno)
        return
    end

    -- log was visited earlier
    if not log.len then
        log.len = f:seek("end")
        f:close()
        return
    end
    f:seek("set", log.len)
    -- remove trailing newline
    local diff =  f:read("*a"):gsub("\n$", "")

    -- set last length
    log.len = f:seek("end")
    f:close()

    -- check if ignored
    local ignored = false
    for i, phr in ipairs(log.ignore or {}) do
        if diff:find(phr) then ignored = true; break end
    end

    if not ignored then
        return diff
    end
end

function LOGNOTIFY:notify(name,file,diff)
    naughty.notify{
        title = name..": "..file,
        text = escape(diff),
        hover_timeout = 0.2, timeout = self.naughty_timeout
    }
end


return setmetatable(lognotify, { __call = function(self, ...) return self.new(...) end })
-- vim:filetype=lua:tabstop=8:shiftwidth=4:expandtab:
