Minetest Game mod: map
======================
See license.txt for license information.

Authors of source code
----------------------
paramat (MIT)

Authors of media (textures)
---------------------------
TumeniNodes (CC BY-SA 3.0):
  map_mapping_kit.png (map)

paramat (CC BY-SA 3.0):
  map_mapping_kit.png (compass and pen)

Crafting
--------
map:mapping_kit

default:glass G
default:paper P
default:stick S
default:steel_ingot I
default:wood W
dye:black D

GPS
IPI
WPD

Usage
-----
In survival mode, use of the minimap requires the mapping kit item in your
inventory.
Once crafted, to instantly enable, 'use' (left click) the item, otherwise the
minimap will be automatically enabled a few seconds later.
Minimap radar mode is always disabled in survival mode.

Minimap and minimap radar mode will be automatically enabled in creative mode
and for any player with the 'creative' privilege.

The 'map.update_hud_flags()' function is global so can be redefined by a mod for
alternative behaviour.
