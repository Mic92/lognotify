#lognotify...
... is log watcher for awesome wm.

It will show a naughty popup each time something
changes in one of the predefined log files.

#REQUIREMENTS
 [awesome](http://awesome.naquadah.org/) for sure :)

 [linotify](https://github.com/hoelzro/linotify)

    $ luarocks install inotify

 [luasocket](http://luasocket.luaforge.net/)

    $ luarocks install luasocket
    
 [bitop](http://bitop.luajit.org/)

    $ luarocks install luabitop

One-Liner for archlinux:

    $ yaourt -S lua-socket lua-bitop linotify-git

#SETUP
* Make and install luainotify.
* Clone lognotify into your configuration directory. (~/.config/awesome):

  `cd $XDG_CONFIG_HOME/awesome && git clone git://github.com/Mic92/lognotify.git`

  or rename init.lua to lognotify.lua and put into awesome's loadpath:

  `wget --no-check-certificate https://github.com/Mic92/lognotify/blob/master/init.lua -O $XDG_CONFIG_HOME/awesome/lognotify.lua`

#USAGE
* Require the module in your rc.lua

`local lognotify = require("lognotify")`

* Initialize and configure it. Here an example:

``` lua
ilog = lognotify{
   logs = { mpd = { file = "/home/bob/.mpd/log", },
   	aptitude = { file = "/var/log/aptitude", },
   	-- Check, whether you have the permissions to read your log files!
   	-- You can fix this by configure syslog deamon in many case.
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
}
```

* run it:

`
ilog:start()
`

* if you tired of it, you can stop it and start later at any time again

`
ilog:stop()
`

#THANKS

* [koniu](https://github.com/koniu) - original author of code
* [dodo](https://github.com/dodo) - port to luarocks's inotify and fixes related to logrotate
