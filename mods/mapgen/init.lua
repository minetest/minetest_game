minetest.register_on_mapgen_init(function(params)
	minetest.set_mapgen_params({
		mgname = "v7",
		seed = params.seed,
		water_level = 0,
		flags = "caves",
	})
end)

dofile(minetest.get_modpath("mapgen").."/mapgen.lua")

minetest.register_alias("mapgen_water_source", "moontest:vacuum")
minetest.register_alias("mapgen_lava_source", "default:lava_source")
minetest.register_alias("mapgen_stone", "moontest:stone")
minetest.register_alias("mapgen_dirt", "moontest:compressed_dust")
minetest.register_alias("mapgen_dirt_with_grass", "air")

