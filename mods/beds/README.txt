Minetest Game mod: beds
=======================
See license.txt for license information.

Authors of source code
----------------------
BlockMen (MIT)

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
