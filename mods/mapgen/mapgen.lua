minetest.register_biome({
	name = "plains",
	node_top = "mapgen:dust",
	node_bottom = "mapgen:stone",
	depth_top = 2,
	node_dust = "air",
	height_min = -10,
	height_max = 160,
})
minetest.register_biome({
	name = "plains",
	node_top = "default:obsidian",
	node_bottom = "mapgen:stone",
	depth_top = 8,
	node_dust = "air",
	height_min = -30,
	height_max = 20,
})

