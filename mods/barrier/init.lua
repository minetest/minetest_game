--Made by Stvk

--get translate
local S = minetest.get_translator("barrier")

--the barrier

minetest.register_node("barrier:barrier", {
	description = S("Barrier"),
	inventory_image = "barrier.png",
	wield_image = "barrier.png",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = true,
	pointable = false,
	diggable = false
	buildable_to = true,
	floodable = false,
	drop = "",
	sounds = default.node_sound_defaults(),
	groups = {not_in_creative_inventory = 1},
})
