Minetest mod "Beds"
===================
by BlockMen (c) 2014-2015

Version: 1.1.1

About
~~~~~
This mod adds a bed to Minetest which allows to skip the night. To sleep rightclick the bed, if playing 
in singleplayer mode the night gets skipped imideatly. If playing on server you get shown how many other
players are in bed too. If all players are sleeping the night gets skipped aswell. Also the night skip can be forced
if more than 50% of the players are lying in bed and use this option.

Another feature is a controled respawning. If you have slept in bed (not just lying in it) your respawn point
is set to the beds location and you will respawn there after death.
You can disable the respawn at beds by setting "enable_bed_respawn = false" in minetest.conf
You can also disable the night skip feature by setting "enable_bed_night_skip = false" in minetest.conf or by using
the /set command ingame.


License of source code, textures: WTFPL
---------------------------------------
(c) Copyright BlockMen (2014-2015)


This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.
