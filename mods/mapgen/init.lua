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

-- Basalt Biome
minetest.register_biome({
	name = "basalt",
	node_top = "moontest:basalt",
	depth_top = 2,
	node_filler = "moontest:stone",
	depth_filler = 3,
	node_dust = "air",
	height_min = -50,
	height_max = 2,
	heat_point = 54,
	humidity_point = 51,
})

-- Aliases

minetest.register_alias("mapgen_lava_source", "moontest:hlsource")
minetest.register_alias("mapgen_water_source", "moontest:hlsource")
minetest.register_alias("mapgen_stone", "moontest:stone")
