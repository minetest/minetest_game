Minetest Game mod: beds
=======================
See license.txt for license information.

Authors of source code
----------------------
Originally by BlockMen (MIT)
Various Minetest developers and contributors (MIT)

Authors of media (textures)
---------------------------
BlockMen (CC BY-SA 3.0):
  beds_bed.png
  beds_bed_fancy.png
  beds_bed_foot.png
  beds_bed_head.png
  beds_bed_side1.png
  beds_bed_side2.png
  beds_bed_side_bottom.png
  beds_bed_side_bottom_r.png
  beds_bed_side_top.png
  beds_bed_side_top_r.png
  beds_bed_top1.png
  beds_bed_top2.png
  beds_bed_top_bottom.png
  beds_bed_top_top.png
  beds_transparent.png

hkzorman (CC BY-SA 3.0):
  beds_bed_fancy_white.png
  beds_bed_foot_white.png
  beds_bed_side1_white.png
  beds_bed_side2_white.png
  beds_bed_side_bottom_r_white.png
  beds_bed_side_bottom_white.png
  beds_bed_side_top_r_white.png
  beds_bed_top1_white.png
  beds_bed_top2_white.png
  beds_bed_top_bottom_white.png
  beds_bed_top_top_white.png
  beds_bed_white.png

Functionality
-------------
This mod adds a bed to Minetest which allows to skip the night.
To sleep, rightclick the bed. If playing in singleplayer mode the night gets skipped
immediately. If playing multiplayer you get shown how many other players are in bed too,
if all players are sleeping the night gets skipped. The night skip can be forced if more
than 50% of the players are lying in bed and use this option.

Another feature is a controlled respawning. If you have slept in bed (not just lying in
it) your respawn point is set to the beds location and you will respawn there after
death.
You can disable the respawn at beds by setting "enable_bed_respawn = false" in
minetest.conf.
You can disable the night skip feature by setting "enable_bed_night_skip = false" in
minetest.conf or by using the /set command in-game.
