Compatible with Minetest 0.4.3 and later
Depends default
License WTFPL

* Warning, this mod can seriously damage maps, it is not 'on generated', instead impact is triggered by abm on dirt, grass, desert sand and sand. Unless testing in a new world you should edit the impact area and safe area in the init.lua.

* This first version is the fastest and simplest, also being compatible back to 0.4.3. Perhaps i will develop a more complex version for 0.4.6 including the new stuff like mese crystals, obsidian etc.

* Default parameters are for one impact every few minutes for your instant gratification, for normal use you might want to increase the abm interval and chance parameters. Personally i just add 1 or 2 zeros on the end of MSRCHA.

* The primary excavated nodes (stone, desert stone, dirt, grass, desert sand, sand, trees) are counted, the proportions calculated, then randomly layered around the crater in the same proportions and with the same total number of nodes, thickest at the crater rim and thinning inwards and outwards.

* Most stone is broken into gravel. Grass becomes dirt. Water, snow, plants are assumed to be vapourized and are not counted. As the ejected material is added it strips surrounding trees of their leaves.

* Damage is inflicted to nearby players depending on distance from impact point, by default a rare direct hit is fatal.

* There is a sound file for using your own choice of sound, the default sound is simply the pop of a dug node, it seems a good cute / abstract impact sound.


Version 0.2.0

* Impacts can now be created on generated chunk as well as by abm, both are optional. By default only on generated impacts are enabled.

* By default on generated impacts are fairly common, you might want to increase parameter ONGCHA.

* On generated craters are limited to 16m radius, craters by abm can be up to 31m radius.

* On generated impacts are too distant to damage players.

* Compatible with default jungles, jungletree trunks are now counted and scattered.

* Meseor path is now excavated, single-node holes are punched in jungle canopies and in the ice above icecaves.

* Compatible with snow biomes mod, bugs fixed (nodes floating above snow, floating moss).

* Impact area and safe area apply to both on-gen and abm impacts.
