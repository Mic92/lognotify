#lognotify...
... is log watcher for awesome wm.
It will show a naughty popup each time something 
changes in one of the predefined log files.

#REQUIREMENTS
 awesome for sure :) (http://awesome.naquadah.org/) 
 luainotify (http://www3.telus.net/taj_khattra/luainotify.html)

#SETUP
* Make and install luanotify.
* Download lognotify.lua and put in to your config directory. (~/.config/awesome)
  or in awesome's loadpath (/usr/share/awesome/lib)

#USAGE
* Require the module in your rc.lua
require("lognotify")
* Initialize and configure it. Here an example:
``ilog = lognotify{ 
	logs = { mpd = { file = "/home/bob/.mpd/log", },
		aptitude = { file = "/var/log/aptitude", },
		syslog    = { file = "/var/log/syslog", ignore = { "Changing fan level" },
		},
		awesome  = { file = "/home/bob/log/awesome",
			ignore = {
				"/var/lib/dpkg", -- aptwidget failure when aptitude running
				"wicd", "wired profiles found", -- wicd junk
				"seek to:", "Close unzip stream", -- gmpc junk
				"^nolog"},
			},
	-- Delay between checking in seconds. Default: 1
	interval = 1,
	-- Time in seconds after which popup expires. Set 0 for no timeout. Default: 0
	naughty_timeout = 15
}``
* run it:
`ilog:start()`
* if you tired of it, you can stop it and start later at any time again
`ilog:stop()`
