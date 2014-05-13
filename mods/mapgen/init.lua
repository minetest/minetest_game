minetest.register_on_mapgen_init(function(params)
	minetest.set_mapgen_params({
		mgname = "v7",
		seed = params.seed,
		water_level = 0,
		flags = "caves",
	})
end)

dofile(minetest.get_modpath("mapgen").."/mapgen.lua")

minetest.register_alias("mapgen_water_source", "mapgen:vacuum")
minetest.register_alias("mapgen_lava_source", "default:lava_source")
minetest.register_alias("mapgen_stone", "mapgen:stone")
minetest.register_alias("mapgen_dirt", "mapgen:compressed_dust")
minetest.register_alias("mapgen_dirt_with_grass", "air")

