dofile(minetest.get_modpath("mapgen").."/mapgen.lua")

minetest.register_alias("mapgen_water_source", "mapgen:vacuum")
minetest.register_alias("mapgen_lava_source", "default:lava_source")
minetest.register_alias("mapgen_stone", "mapgen:stone")
minetest.register_alias("mapgen_dirt", "mapgen:compressed_dust")
minetest.register_alias("mapgen_dirt_with_grass", "air")

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:coalore",
	wherein        = "mapgen:stone",
	clust_scarcity = 8*8*8,
	clust_num_ores = 8,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = 64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:coalore",
	wherein        = "mapgen:stone",
	clust_scarcity = 24*24*24,
	clust_num_ores = 27,
	clust_size     = 6,
	height_min     = -31000,
	height_max     = 0,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:ironore",
	wherein        = "mapgen:stone",
	clust_scarcity = 12*12*12,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -15,
	height_max     = 2,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:ironore",
	wherein        = "mapgen:stone",
	clust_scarcity = 9*9*9,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -63,
	height_max     = -16,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:ironore",
	wherein        = "mapgen:stone",
	clust_scarcity = 7*7*7,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:ironore",
	wherein        = "mapgen:stone",
	clust_scarcity = 24*24*24,
	clust_num_ores = 27,
	clust_size     = 6,
	height_min     = -31000,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:meseore",
	wherein        = "mapgen:stone",
	clust_scarcity = 18*18*18,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -255,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:meseore",
	wherein        = "mapgen:stone",
	clust_scarcity = 14*14*14,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -256,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:mese",
	wherein        = "mapgen:stone",
	clust_scarcity = 36*36*36,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = -1024,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:goldore",
	wherein        = "mapgen:stone",
	clust_scarcity = 15*15*15,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -255,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:goldore",
	wherein        = "mapgen:stone",
	clust_scarcity = 13*13*13,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -256,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:diamondore",
	wherein        = "mapgen:stone",
	clust_scarcity = 17*17*17,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -255,
	height_max     = -128,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:diamondore",
	wherein        = "mapgen:stone",
	clust_scarcity = 15*15*15,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -256,
	flags          = "absheight",
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:copperore",
	wherein        = "mapgen:stone",
	clust_scarcity = 12*12*12,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -63,
	height_max     = -16,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mapgen:copperore",
	wherein        = "mapgen:stone",
	clust_scarcity = 9*9*9,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -31000,
	height_max     = -64,
	flags          = "absheight",
})

minetest.register_node("mapgen:stone", {
	description = "Moon Stone",
	tiles = {"mapgen_stone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:ironore", {
	description = "MR Iron Ore",
	tiles = {"mapgen_stone.png^default_mineral_iron.png"},
	groups = {cracky=2},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:copperore", {
	description = "MR Copper Ore",
	tiles = {"mapgen_stone.png^default_mineral_copper.png"},
	groups = {cracky=2},
	drop = "default:copper_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:goldore", {
	description = "MR Gold Ore",
	tiles = {"mapgen_stone.png^default_mineral_gold.png"},
	groups = {cracky=2},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:diamondore", {
	description = "MR Diamond Ore",
	tiles = {"mapgen_stone.png^default_mineral_diamond.png"},
	groups = {cracky=1},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("mapgen:meseore", {
	description = "MR Mese Ore",
	tiles = {"mapgen_stone.png^default_mineral_mese.png"},
	groups = {cracky=1},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:dust", {
	description = "Moon Dust",
	tiles = {"mapgen_dust.png"},
	groups = {crumbly=3, falling_node=1},
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.1},
	}),
})

minetest.register_node("mapgen:compressed_dust", {
	description = "Compressed Moon Dust",
	tiles = {"mapgen_compressed_dust.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.1},
	}),
})

minetest.register_node("mapgen:vacuum", {
	description = "Vacuum",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drowning = 1,
})

minetest.register_node("mapgen:air", {
	description = "Life Support Air",
	drawtype = "glasslike",
	tiles = {"mapgen_air.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
})

minetest.register_node("mapgen:airgen", {
	description = "Air Generator",
	tiles = {"mapgen_airgen.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "mapgen:vacuum" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="mapgen:air"})
					minetest.get_meta({x=x+i,y=y+j,z=z+k}):set_int("spread", 16)
					print ("[mapgen] Added MR air node")
				end
			end
		end
		end
		end
		
	end
})

minetest.register_node("mapgen:waterice", {
	description = "Water Ice",
	tiles = {"mapgen_waterice.png"},
	light_source = 1,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,melts=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("mapgen:hlflowing", {
	description = "Flowing Hydroponics",
	inventory_image = minetest.inventorycube("mapgen_hl.png"),
	drawtype = "flowingliquid",
	tiles = {"mapgen_hl.png"},
	special_tiles = {
		{
			image="mapgen_hlflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="mapgen_hlflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = 224,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mapgen:hlflowing",
	liquid_alternative_source = "mapgen:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("mapgen:hlsource", {
	description = "Hydroponic Source",
	inventory_image = minetest.inventorycube("mapgen_hl.png"),
	drawtype = "liquid",
	tiles = {"mapgen_hl.png"},
	alpha = 224,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "mapgen:hlflowing",
	liquid_alternative_source = "mapgen:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("mapgen:soil", {
	description = "Moonsoil",
	tiles = {"mapgen_soil.png"},
	groups = {crumbly=3, falling_node=1, soil=3},
	drop = "mapgen:dust",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("mapgen:airlock", {
	description = "Airlock",
	tiles = {"mapgen_airlock.png"},
	light_source = 14,
	walkable = false,
	post_effect_color = {a=255, r=0, g=0, b=0},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:glass", {
	description = "MR Glass",
	drawtype = "glasslike",
	tiles = {"default_obsidian_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("mapgen:sapling", {
	description = "MR Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("mapgen:leaves", {
	description = "MR Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"mapgen:sapling"},rarity = 20,},
			{items = {"mapgen:leaves"},}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("mapgen:light", {
	description = "Light",
	tiles = {"mapgen_light.png"},
	light_source = 14,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("mapgen:stonebrick", {
	description = "Moon Stone Brick",
	tiles = {"mapgen_stonebricktop.png", "mapgen_stonebrickbot.png", "mapgen_stonebrick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:stoneslab", {
	description = "Moon Stone Slab",
	tiles = {"mapgen_stonebricktop.png", "mapgen_stonebrickbot.png", "mapgen_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mapgen:stonestair", {
	description = "Moon Stone Stair",
	tiles = {"mapgen_stonebricktop.png", "mapgen_stonebrickbot.png", "mapgen_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

-- Items

minetest.register_craftitem("mapgen:spacesuit", {
	description = "MR Spacesuit",
	inventory_image = "mapgen_spacesuit.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_craftitem("mapgen:helmet", {
	description = "MR Mesetint Helmet",
	inventory_image = "mapgen_helmet.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_craftitem("mapgen:lifesupport", {
	description = "MR Life Support",
	inventory_image = "mapgen_lifesupport.png",
	groups = {not_in_creative_inventory=1},
})

-- Crafting

minetest.register_craft({
    output = "mapgen:airlock",
    recipe = {
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"default:steel_ingot", "default:mese", "default:steel_ingot"},
        {"default:steel_ingot", "", "default:steel_ingot"},
    },
})

minetest.register_craft({
    output = "mapgen:airgen",
    recipe = {
        {"default:steel_ingot", "mapgen:waterice", "default:steel_ingot"},
        {"mapgen:waterice", "default:mese", "mapgen:waterice"},
        {"default:steel_ingot", "mapgen:waterice", "default:steel_ingot"},
    },
})

minetest.register_craft({
	output = "default:water_source",
	recipe = {
		{"mapgen:waterice"},
	},
})

minetest.register_craft({
    output = "mapgen:hlsource",
    recipe = {
        {"mapgen:leaves", "mapgen:leaves", "mapgen:leaves"},
        {"mapgen:leaves", "mapgen:waterice", "mapgen:leaves"},
        {"mapgen:leaves", "mapgen:leaves", "mapgen:leaves"},
    },
})

minetest.register_craft({
	output = "mapgen:stonebrick 4",
	recipe = {
		{"mapgen:stone", "mapgen:stone"},
		{"mapgen:stone", "mapgen:stone"},
	}
})

minetest.register_craft({
    output = "default:furnace",
    recipe = {
        {"mapgen:stone", "mapgen:stone", "mapgen:stone"},
        {"mapgen:stone", "", "mapgen:stone"},
        {"mapgen:stone", "mapgen:stone", "mapgen:stone"},
    },
})

minetest.register_craft({
	output = "mapgen:stoneslab 4",
	recipe = {
		{"mapgen:stone", "mapgen:stone"},
	}
})

minetest.register_craft({
	output = "mapgen:stonestair 4",
	recipe = {
		{"mapgen:stone", ""},
		{"mapgen:stone", "mapgen:stone"},
	}
})

minetest.register_craft({
	output = "mapgen:helmet",
	recipe = {
		{"default:mese_crystal"},
		{"default:glass"},
		{"default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "mapgen:lifesupport",
	recipe = {
		{"default:steel_ingot","default:steel_ingot" , "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "mapgen:spacesuit",
	recipe = {
		{"wool:white", "mapgen:helmet", "wool:white"},
		{"", "mapgen:lifesupport", ""},
		{"wool:white", "", "wool:white"},
	}
})

minetest.register_craft({
    output = "mapgen:light 8",
    recipe = {
        {"mapgen:glass", "mapgen:glass", "mapgen:glass"},
        {"mapgen:glass", "default:mese", "mapgen:glass"},
        {"mapgen:glass", "mapgen:glass", "mapgen:glass"},
    },
})

minetest.register_craft({
	output = "mapgen:sapling",
	recipe = {
		{"default:mese_crystal"},
		{"default:sapling"},
	}
})

-- Cooking

minetest.register_craft({
	type = "cooking",
	output = "mapgen:glass",
	recipe = "mapgen:dust",
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:mese_crystal",
	burntime = 50,
})
