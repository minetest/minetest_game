-- Mapgen

-- Set mapgen mode to v7
minetest.register_on_mapgen_init(function(params)
	minetest.set_mapgen_params({
		mgname = "v7",
		seed = params.seed,
		water_level = 0,
		flags = "caves",
	})
end)

-- Dust Biome
minetest.register_biome({
	name = "plains",
	node_top = "moontest:dust",
	node_bottom = "moontest:stone",
	depth_top = 2,
	node_dust = "air",
	height_min = -10,
	height_max = 160,
})

-- Obsidian Biome
minetest.register_biome({
	name = "plains",
	node_top = "default:obsidian",
	node_bottom = "moontest:stone",
	depth_top = 8,
	node_dust = "air",
	height_min = -30,
	height_max = 20,
})

-- Aliases

minetest.register_alias("mapgen_water_source", "moontest:vacuum")
minetest.register_alias("mapgen_lava_source", "default:lava_source")
minetest.register_alias("mapgen_stone", "moontest:stone")
minetest.register_alias("mapgen_dirt", "moontest:dust")
