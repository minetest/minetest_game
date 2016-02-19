-- mods/default/crafting.lua

for _,woodsort in pairs({"", "jungle", "pine_", "acacia_", "aspen_"}) do
	minetest.register_craft({
		output = "default:"..woodsort.."wood 4",
		recipe = {
			{"default:"..woodsort.."tree"},
		}
	})
end

minetest.register_craft({
	output = "default:stick 4",
	recipe = {
		{"group:wood"},
	}
})

minetest.register_craft({
	output = "default:sign_wall",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "default:torch 4",
	recipe = {
		{"default:coal_lump"},
		{"group:stick"},
	}
})

for _,t in pairs({
	{"group:wood", "wood"},
	{"group:stone", "stone"},
	{"default:steel_ingot", "steel"},
	{"default:bronze_ingot", "bronze"},
	{"default:mese_crystal", "mese"},
	{"default:diamond", "diamond"},
}) do
	local material, type = unpack(t)

	minetest.register_craft({
		output = "default:pick_"..type,
		recipe = {
			{material, material, material},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		}
	})

	minetest.register_craft({
		output = "default:shovel_"..type,
		recipe = {
			{material},
			{"group:stick"},
			{"group:stick"},
		}
	})

	minetest.register_craft({
		output = "default:axe_"..type,
		recipe = {
			{material, material},
			{material, "group:stick"},
			{"", "group:stick"},
		}
	})

	minetest.register_craft({
		output = "default:axe_"..type,
		recipe = {
			{material, material},
			{"group:stick", material},
			{"group:stick",""},
		}
	})

	minetest.register_craft({
		output = "default:sword_"..type,
		recipe = {
			{material},
			{material},
			{"group:stick"},
		}
	})
end

minetest.register_craft({
	output = "default:rail 24",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "default:chest",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

minetest.register_craft({
	output = "default:chest_locked",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "default:steel_ingot", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

minetest.register_craft({
	output = "default:furnace",
	recipe = {
		{"group:stone", "group:stone", "group:stone"},
		{"group:stone", "", "group:stone"},
		{"group:stone", "group:stone", "group:stone"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "default:bronze_ingot",
	recipe = {"default:steel_ingot", "default:copper_ingot"},
})

for _,t in pairs({
	{"coal_lump", "coalblock"},
	{"steel_ingot", "steelblock"},
	{"copper_ingot", "copperblock"},
	{"bronze_ingot", "bronzeblock"},
	{"gold_ingot", "goldblock"},
	{"diamond", "diamondblock"},
	{"mese_crystal", "mese"},
	{"obsidian_shard", "obsidian"},
	{"snow", "snowblock"},
}) do
	local material = "default:"..t[1]
	local block = "default:"..t[2]

	minetest.register_craft({
		output = block,
		recipe = {
			{material, material, material},
			{material, material, material},
			{material, material, material},
		}
	})

	minetest.register_craft({
		output = material.." 9",
		recipe = {
			{block},
		}
	})
end

for _,t in pairs({
	{"sandstone", "sandstonebrick"},
	{"obsidian", "obsidianbrick"},
	{"stone", "stonebrick"},
	{"desert_stone", "desert_stonebrick"},
}) do
	local material = "default:"..t[1]
	local brick = "default:"..t[2]

	minetest.register_craft({
		output = brick.." 4",
		recipe = {
			{material, material},
			{material, material},
		}
	})
end

minetest.register_craft({
	output = "default:sandstone",
	recipe = {
		{"group:sand", "group:sand"},
		{"group:sand", "group:sand"},
	}
})

minetest.register_craft({
	output = "default:sand 4",
	recipe = {
		{"default:sandstone"},
	}
})

minetest.register_craft({
	output = "default:clay",
	recipe = {
		{"default:clay_lump", "default:clay_lump"},
		{"default:clay_lump", "default:clay_lump"},
	}
})

minetest.register_craft({
	output = "default:brick",
	recipe = {
		{"default:clay_brick", "default:clay_brick"},
		{"default:clay_brick", "default:clay_brick"},
	}
})

minetest.register_craft({
	output = "default:clay_brick 4",
	recipe = {
		{"default:brick"},
	}
})

minetest.register_craft({
	output = "default:paper",
	recipe = {
		{"default:papyrus", "default:papyrus", "default:papyrus"},
	}
})

minetest.register_craft({
	output = "default:book",
	recipe = {
		{"default:paper"},
		{"default:paper"},
		{"default:paper"},
	}
})

minetest.register_craft({
	output = "default:bookshelf",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"default:book", "default:book", "default:book"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

minetest.register_craft({
	output = "default:ladder",
	recipe = {
		{"group:stick", "", "group:stick"},
		{"group:stick", "group:stick", "group:stick"},
		{"group:stick", "", "group:stick"},
	}
})

minetest.register_craft({
	output = "default:mese_crystal_fragment 9",
	recipe = {
		{"default:mese_crystal"},
	}
})

minetest.register_craft({
	output = "default:meselamp 1",
	recipe = {
		{"", "default:mese_crystal",""},
		{"default:mese_crystal", "default:glass", "default:mese_crystal"},
	}
})


--
-- Crafting (tool repair)
--

minetest.register_craft({
	type = "toolrepair",
	additional_wear = -0.02,
})


--
-- Cooking recipes
--

for _,t in pairs({
	{"group:sand", "glass"},
	{"default:obsidian_shard", "obsidian_glass"},
	{"default:cobble", "stone"},
	{"default:mossycobble", "stone"},
	{"default:desert_cobble", "desert_stone"},
	{"default:iron_lump", "steel_ingot"},
	{"default:copper_lump", "copper_ingot"},
	{"default:gold_lump", "gold_ingot"},
	{"default:clay_lump", "clay_brick"},
}) do
	minetest.register_craft({
		type = "cooking",
		output = "default:"..t[2],
		recipe = t[1],
	})
end


--
-- Fuels
--

for _,t in pairs({
	{"group:tree", 30},
	{"group:leaves", 1},
	{"group:wood", 7},
	{"group:sapling", 10},
	{"default:junglegrass", 2},
	{"default:cactus", 15},
	{"default:papyrus", 1},
	{"default:bookshelf", 30},
	{"default:fence_wood", 15},
	{"default:ladder", 5},
	{"default:lava_source", 60},
	{"default:torch", 4},
	{"default:sign_wall", 10},
	{"default:chest", 30},
	{"default:chest_locked", 30},
	{"default:nyancat", 1},
	{"default:nyancat_rainbow", 1},
	{"default:apple", 3},
	{"default:coal_lump", 40},
	{"default:coalblock", 370},
	{"default:grass_1", 2},
	{"default:dry_grass_1", 2},
}) do
	minetest.register_craft({
		type = "fuel",
		recipe = t[1],
		burntime = t[2],
	})
end
