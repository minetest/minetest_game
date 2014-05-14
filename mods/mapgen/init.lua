-- Mapgen

dofile(minetest.get_modpath("mapgen").."/ores.lua")

-- Set mapgen mode to v7
minetest.register_on_mapgen_init(function(params)
	minetest.set_mapgen_params({
		mgname = "v7",
		seed = params.seed,
		water_level = -10,
		flags = "caves",
	})
end)

-- Dust Biome
minetest.register_biome({
	name = "plains",
	node_top = "moontest:dust",
	depth_top = 2,
	node_bottom = "moontest:stone",
	node_dust = "air",
	height_min = 3,
	height_max = 30,
})

-- Basalt Biome
minetest.register_biome({
	name = "basalt",
	node_top = "moontest:basalt",
	depth_top = 2,
	node_filler = "moontest:dust",
	depth_filler = 1,
	node_dust = "air",
	height_min = -50,
	height_max = 5,
})

-- Lunar Ice Cap Biome
minetest.register_biome({
	name = "plains",
	node_top = "moontest:waterice",
	depth_top = 4,
	node_filler = "moontest:dust",
	depth_filler = 2,
	node_dust = "air",
	height_min = 25,
	height_max = 100,
})

-- Aliases

minetest.register_alias("mapgen_lava_source", "moontest:hlsource")
minetest.register_alias("mapgen_water_source", "moontest:hlsource")
minetest.register_alias("mapgen_stone", "moontest:stone")
