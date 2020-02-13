Minetest Game mod: map
======================
See license.txt for license information.

Authors of source code
----------------------
paramat (MIT)

Authors of media (textures)
---------------------------
TumeniNodes (CC BY-SA 3.0):
- `map_mapping_kit.png (map)`

paramat (CC BY-SA 3.0):
- `map_mapping_kit.png (compass and pen)`

Crafting
--------
map:mapping_kit

`default:glass G`<br>
`default:paper P`<br>
`group:stick S`<br>
`default:steel_ingot I`<br>
`group:wood W`<br>
`dye:black D`<br>

```
GPS
IPI
WPD
```

Usage
-----
In survival mode, use of the minimap requires the mapping kit item in your<br>
inventory. It can take up to 5 seconds for adding to or removal from inventory<br>
to have an effect, however to instantly allow the use of the minimap 'use'<br>
(leftclick) the item.<br>
Minimap radar mode is always disallowed in survival mode.

Minimap and minimap radar mode are automatically allowed in creative mode and<br>
for any player with the 'creative' privilege.

The `map.update_hud_flags()` function is global so can be redefined by a mod for<br>
alternative behaviour.
