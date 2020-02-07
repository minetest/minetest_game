Minetest Game mod: tnt
======================
See license.txt for license information.

Authors of source code
----------------------
PilzAdam (MIT)<br>
ShadowNinja (MIT)<br>
sofar (sofar@foo-projects.org) (MIT)<br>
Various Minetest developers and contributors (MIT)

Authors of media
----------------
BlockMen (CC BY-SA 3.0):<br>
All textures not mentioned below.

ShadowNinja (CC BY-SA 3.0):
- tnt_smoke.png

Wuzzy (CC BY-SA 3.0):
- All gunpowder textures except tnt_gunpowder_inventory.png.

sofar (sofar@foo-projects.org) (CC BY-SA 3.0):
- tnt_blast.png

paramat (CC BY-SA 3.0)
- tnt_tnt_stick.png - Derived from a texture by benrob0329.

TumeniNodes (CC0 1.0)
- tnt_explode.ogg<br>
renamed, edited, and converted to .ogg from Explosion2.wav<br>
by steveygos93 (CC0 1.0)<br>
<https://freesound.org/s/80401/>

- tnt_ignite.ogg<br>
renamed, edited, and converted to .ogg from sparkler_fuse_nm.wav<br>
by theneedle.tv (CC0 1.0)<br>
<https://freesound.org/s/316682/>

- tnt_gunpowder_burning.ogg<br>
renamed, edited, and converted to .ogg from road flare ignite burns.wav<br>
by frankelmedico (CC0 1.0)<br>
<https://freesound.org/s/348767/>


Introduction
------------
This mod adds TNT to Minetest. TNT is a tool to help the player<br>
in mining.

How to use the mod:

Craft gunpowder by placing coal and gravel in the crafting area.<br>
The gunpowder can be used to craft TNT sticks or as a fuse trail for TNT.

To craft 2 TNT sticks:
```
G_G
GPG
G_G
```
G = gunpowder<br>
P = paper<br>
The sticks are not usable as an explosive.

Craft TNT from 9 TNT sticks.

There are different ways to ignite TNT:
  1. Hit it with a torch.
  2. Hit a gunpowder fuse trail that leads to TNT with a torch or<br>
     flint-and-steel.
  3. Activate it with mesecons (fastest way).

For 1 TNT:
Node destruction radius is 3 nodes.<br>
Player and object damage radius is 6 nodes.
