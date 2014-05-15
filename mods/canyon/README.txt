canyon 0.3.1 by paramat.
For latest stable Minetest and back to 0.4.3.
Depends default.
License WTFPL.

* Perlin generated canyon river systems with perlin generated river depth.
* Water level is dynamic across and along rivers, being a squashed copy of the stone surface the canyon replaced, rough terrain creates rapids.
* Compatible with snow biomes mod.
* Canyon generation is fairly fast, a few seconds per chunk on a medium speed computer.

Version 0.2.0
-------------
* Scale of canyon pattern reduced from 1024 to 384 nodes.
* Parameters for controlling river depth maximum and minimum, water rise in highlands.
* Vertical canyon walls replaced with steep slopes to the river bed.
* Waterfalls and rivers rising steeply in mountain areas.
* Water rise in highlands is set as a proportion of the stone surface level replaced by the canyon.
* More efficient code, faster generation, bug fixes, smoother lake surfaces, no place_node and fewer dig_node messages printed to terminal.

Version 0.3.0
-------------
* Canyon, chasm and landup mods are now compatible and all have their version numbers raised to 0.3.0 to signify this.
* Various minor improvements.

Version 0.3.1
-------------
* Depth of river surface below land surface is now varied by a large scale perlin noise. This creates large areas where rivers are at sea level and in deep canyons, and other large areas where the river surface rises in altitude and remains just below land surface area
* Code tidied up.

