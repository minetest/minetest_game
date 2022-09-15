--Made by Stvk

--get translate
local S = minetest.get_translator("barrier")

--the barrier

minetest.register_node("stvk:barrier", {
	description = S("Barrier"),
	inventory_image = "ignore.png^air.png",
	wield_image = "ignore.png^air.png",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = true,
	pointable = false,
	diggable = false
	buildable_to = true,
	floodable: false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
})
