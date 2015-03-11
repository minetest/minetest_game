-- mods/default/nodes.lua

--[[ Index:

Stone
-----
(1. Material 2. Cobble variant 3. Brick variant [4. Modified forms])

default:stone
default:cobble
default:stonebrick
default:mossycobble

default:desert_stone
default:desert_cobble
default:desert_stonebrick

default:sandstone
default:sandstonebrick

default:obsidian
default:obsidianbrick

Soft / Non-Stone
----------------
(1. Material [2. Modified forms])

default:dirt
default:dirt_with_grass
default:dirt_with_grass_footsteps
default:dirt_with_snow

default:sand
default:desert_sand

default:gravel

default:clay

default:snow
default:snowblock

default:ice

Trees
-----
(1. Trunk 2. Fabricated trunk 3. Leaves 4. Sapling [5. Fruits])

default:tree
default:wood
default:leaves
default:sapling
default:apple

default:jungletree
default:junglewood
default:jungleleaves
default:junglesapling

default:pinetree
default:pinewood
default:pine_needles
default:pine_sapling

Ores
----
(1. In stone 2. Block)

default:stone_with_coal
default:coalblock

default:stone_with_iron
default:steelblock

default:stone_with_copper
default:copperblock
default:bronzeblock

default:stone_with_gold
default:goldblock

default:stone_with_mese
default:mese

default:stone_with_diamond
default:diamondblock

Plantlife (non-cubic)
---------------------
default:cactus
default:papyrus
default:dry_shrub
default:junglegrass
default:grass_1
default:grass_2
default:grass_3
default:grass_4
default:grass_5

Liquids
-------
(1. Source 2. Flowing)

default:water_source
default:water_flowing

default:lava_source
default:lava_flowing

Tools / "Advanced" crafting / Non-"natural"
-------------------------------------------
default:torch

default:chest
default:chest_locked

default:bookshelf

default:sign_wall
default:ladder
default:fence_wood

default:glass
default:obsidian_glass

default:rail

default:brick

Misc
----
default:cloud
default:nyancat
default:nyancat_rainbow

--]]

--
-- Stone
--

minetest.register_node("default:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:cobble", {
	description = "Cobblestone",
	tiles = {"default_cobble.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:stonebrick", {
	description = "Stone Brick",
	tiles = {"default_stone_brick.png"},
	groups = {cracky=2, stone=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:mossycobble", {
	description = "Mossy Cobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:desert_stone", {
	description = "Desert Stone",
	tiles = {"default_desert_stone.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:desert_cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:desert_cobble", {
	description = "Desert Cobblestone",
	tiles = {"default_desert_cobble.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:desert_stonebrick", {
	description = "Desert Stone Brick",
	tiles = {"default_desert_stone_brick.png"},
	groups = {cracky=2, stone=1},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:sandstone", {
	description = "Sandstone",
	tiles = {"default_sandstone.png"},
	is_ground_content = true,
	groups = {crumbly=2,cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:sandstonebrick", {
	description = "Sandstone Brick",
	tiles = {"default_sandstone_brick.png"},
	is_ground_content = true,
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:obsidian", {
	description = "Obsidian",
	tiles = {"default_obsidian.png"},
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=1,level=2},
})

minetest.register_node("default:obsidianbrick", {
	description = "Obsidian Brick",
	tiles = {"default_obsidian_brick.png"},
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=1,level=2},
})

--
-- Soft / Non-Stone
--

minetest.register_node("default:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt_with_grass", {
	description = "Dirt with Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

minetest.register_node("default:dirt_with_grass_footsteps", {
	description = "Dirt with Grass and Footsteps",
	tiles = {"default_grass_footsteps.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1,not_in_creative_inventory=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

minetest.register_node("default:dirt_with_snow", {
	description = "Dirt with Snow",
	tiles = {"default_snow.png", "default_dirt.png", "default_dirt.png^default_snow_side.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
	}),
})



minetest.register_node("default:sand", {
	description = "Sand",
	tiles = {"default_sand.png"},
	is_ground_content = true,
	groups = {crumbly=3, falling_node=1, sand=1},
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("default:desert_sand", {
	description = "Desert Sand",
	tiles = {"default_desert_sand.png"},
	is_ground_content = true,
	groups = {crumbly=3, falling_node=1, sand=1},
	sounds = default.node_sound_sand_defaults(),
})



minetest.register_node("default:gravel", {
	description = "Gravel",
	tiles = {"default_gravel.png"},
	is_ground_content = true,
	groups = {crumbly=2, falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.5},
		dug = {name="default_gravel_footstep", gain=1.0},
	}),
})



minetest.register_node("default:clay", {
	description = "Clay",
	tiles = {"default_clay.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	drop = 'default:clay_lump 4',
	sounds = default.node_sound_dirt_defaults(),
})



minetest.register_node("default:snow", {
	description = "Snow",
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	is_ground_content = true,
	paramtype = "light",
	buildable_to = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
		},
	},
	groups = {crumbly=3,falling_node=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
		dug = {name="default_snow_footstep", gain=0.75},
	}),

	on_construct = function(pos)
		pos.y = pos.y - 1
		if minetest.get_node(pos).name == "default:dirt_with_grass" then
			minetest.set_node(pos, {name="default:dirt_with_snow"})
		end
	end,
})


minetest.register_node("default:snowblock", {
	description = "Snow Block",
	tiles = {"default_snow.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
		dug = {name="default_snow_footstep", gain=0.75},
	}),
})



minetest.register_node("default:ice", {
	description = "Ice",
	tiles = {"default_ice.png"},
	is_ground_content = true,
	paramtype = "light",
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

--
-- Trees
--

minetest.register_node("default:tree", {
	description = "Tree",
	tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

minetest.register_node("default:wood", {
	description = "Wooden Planks",
	tiles = {"default_wood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("default:sapling", {
	description = "Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1,sapling=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("default:leaves", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'default:sapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'default:leaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("default:apple", {
	description = "Apple",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_apple.png"},
	inventory_image = "default_apple.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {fleshy=3,dig_immediate=3,flammable=2,leafdecay=3,leafdecay_drop=1},
	on_use = minetest.item_eat(1),
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = function(pos, placer, itemstack)
		if placer:is_player() then
			minetest.set_node(pos, {name="default:apple", param2=1})
		end
	end,
})



minetest.register_node("default:jungletree", {
	description = "Jungle Tree",
	tiles = {"default_jungletree_top.png", "default_jungletree_top.png", "default_jungletree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

minetest.register_node("default:junglewood", {
	description = "Junglewood Planks",
	tiles = {"default_junglewood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("default:jungleleaves", {
	description = "Jungle Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_jungleleaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'default:junglesapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'default:jungleleaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("default:junglesapling", {
	description = "Jungle Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_junglesapling.png"},
	inventory_image = "default_junglesapling.png",
	wield_image = "default_junglesapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1,sapling=1},
	sounds = default.node_sound_leaves_defaults(),
})



minetest.register_node("default:pinetree", {
	description = "Pine Tree",
	tiles = {"default_pinetree_top.png", "default_pinetree_top.png", "default_pinetree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

minetest.register_node("default:pinewood", {
	description = "Pinewood Planks",
	tiles = {"default_pinewood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("default:pine_needles",{
	description = "Pine Needles",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_pine_needles.png"},
	waving = 1,
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {"default:pine_sapling"},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {"default:pine_needles"},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("default:pine_sapling", {
	description = "Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_pine_sapling.png"},
	inventory_image = "default_pine_sapling.png",
	wield_image = "default_pine_sapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1,sapling=1},
	sounds = default.node_sound_leaves_defaults(),
})

--
-- Ores
--

minetest.register_node("default:stone_with_coal", {
	description = "Coal Ore",
	tiles = {"default_stone.png^default_mineral_coal.png"},
	is_ground_content = true,
	groups = {cracky=3},
	drop = 'default:coal_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:coalblock", {
	description = "Coal Block",
	tiles = {"default_coal_block.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:stone_with_iron", {
	description = "Iron Ore",
	tiles = {"default_stone.png^default_mineral_iron.png"},
	is_ground_content = true,
	groups = {cracky=2},
	drop = 'default:iron_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:steelblock", {
	description = "Steel Block",
	tiles = {"default_steel_block.png"},
	is_ground_content = true,
	groups = {cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:stone_with_copper", {
	description = "Copper Ore",
	tiles = {"default_stone.png^default_mineral_copper.png"},
	is_ground_content = true,
	groups = {cracky=2},
	drop = 'default:copper_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:copperblock", {
	description = "Copper Block",
	tiles = {"default_copper_block.png"},
	is_ground_content = true,
	groups = {cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:bronzeblock", {
	description = "Bronze Block",
	tiles = {"default_bronze_block.png"},
	is_ground_content = true,
	groups = {cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:stone_with_mese", {
	description = "Mese Ore",
	tiles = {"default_stone.png^default_mineral_mese.png"},
	is_ground_content = true,
	groups = {cracky=1},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:mese", {
	description = "Mese Block",
	tiles = {"default_mese_block.png"},
	is_ground_content = true,
	groups = {cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})




minetest.register_node("default:stone_with_gold", {
	description = "Gold Ore",
	tiles = {"default_stone.png^default_mineral_gold.png"},
	is_ground_content = true,
	groups = {cracky=2},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:goldblock", {
	description = "Gold Block",
	tiles = {"default_gold_block.png"},
	is_ground_content = true,
	groups = {cracky=1},
	sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("default:stone_with_diamond", {
	description = "Diamond Ore",
	tiles = {"default_stone.png^default_mineral_diamond.png"},
	is_ground_content = true,
	groups = {cracky=1},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:diamondblock", {
	description = "Diamond Block",
	tiles = {"default_diamond_block.png"},
	is_ground_content = true,
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})

--
-- Plantlife (non-cubic)
--

minetest.register_node("default:cactus", {
	description = "Cactus",
	tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_side.png"},
	paramtype2 = "facedir",
	is_ground_content = true,
	groups = {snappy=1,choppy=3,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node,

	after_dig_node = function(pos, node, metadata, digger)
		default.dig_up(pos, node, digger)
	end,
})

minetest.register_node("default:papyrus", {
	description = "Papyrus",
	drawtype = "plantlike",
	tiles = {"default_papyrus.png"},
	inventory_image = "default_papyrus.png",
	wield_image = "default_papyrus.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}
	},
	groups = {snappy=3,flammable=2},
	sounds = default.node_sound_leaves_defaults(),

	after_dig_node = function(pos, node, metadata, digger)
		default.dig_up(pos, node, digger)
	end,
})

minetest.register_node("default:dry_shrub", {
	description = "Dry Shrub",
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.0,
	tiles = {"default_dry_shrub.png"},
	inventory_image = "default_dry_shrub.png",
	wield_image = "default_dry_shrub.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	buildable_to = true,
	groups = {snappy=3,flammable=3,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("default:junglegrass", {
	description = "Jungle Grass",
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_junglegrass.png"},
	inventory_image = "default_junglegrass.png",
	wield_image = "default_junglegrass.png",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = true,
	groups = {snappy=3,flammable=2,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("default:grass_1", {
	description = "Grass",
	drawtype = "plantlike",
	waving = 1,
	tiles = {"default_grass_1.png"},
	-- Use texture of a taller grass stage in inventory
	inventory_image = "default_grass_3.png",
	wield_image = "default_grass_3.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	buildable_to = true,
	groups = {snappy=3,flammable=3,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},

	on_place = function(itemstack, placer, pointed_thing)
		-- place a random grass node
		local stack = ItemStack("default:grass_"..math.random(1,5))
		local ret = minetest.item_place(stack, placer, pointed_thing)
		return ItemStack("default:grass_1 "..itemstack:get_count()-(1-ret:get_count()))
	end,
})

for i=2,5 do
	minetest.register_node("default:grass_"..i, {
		description = "Grass",
		drawtype = "plantlike",
		waving = 1,
		tiles = {"default_grass_"..i..".png"},
		inventory_image = "default_grass_"..i..".png",
		wield_image = "default_grass_"..i..".png",
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		is_ground_content = true,
		drop = "default:grass_1",
		groups = {snappy=3,flammable=3,flora=1,attached_node=1,not_in_creative_inventory=1},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})
end

--
-- Liquids
--

minetest.register_node("default:water_source", {
	description = "Water Source",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name = "default_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	alpha = 160,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a=64, r=100, g=100, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("default:water_flowing", {
	description = "Flowing Water",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "flowingliquid",
	tiles = {"default_water.png"},
	special_tiles = {
		{
			name = "default_water_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
		{
			name = "default_water_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
	},
	alpha = 160,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a=64, r=100, g=100, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})



minetest.register_node("default:lava_source", {
	description = "Lava Source",
	inventory_image = minetest.inventorycube("default_lava.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_lava_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	special_tiles = {
		-- New-style lava source material (mostly unused)
		{
			name = "default_lava_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
			backface_culling = false,
		},
	},
	paramtype = "light",
	light_source = default.LIGHT_MAX - 1,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:lava_flowing",
	liquid_alternative_source = "default:lava_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=255, g=64, b=0},
	groups = {lava=3, liquid=2, hot=3, igniter=1},
})

minetest.register_node("default:lava_flowing", {
	description = "Flowing Lava",
	inventory_image = minetest.inventorycube("default_lava.png"),
	drawtype = "flowingliquid",
	tiles = {"default_lava.png"},
	special_tiles = {
		{
			name = "default_lava_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
		{
			name = "default_lava_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = default.LIGHT_MAX - 1,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:lava_flowing",
	liquid_alternative_source = "default:lava_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=255, g=64, b=0},
	groups = {lava=3, liquid=2, hot=3, igniter=1, not_in_creative_inventory=1},
})

--
-- Tools / "Advanced" crafting / Non-"natural"
--

minetest.register_node("default:torch", {
	description = "Torch",
	drawtype = "torchlike",
	tiles = {
		{
			name = "default_torch_on_floor_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0
			},
		},
		{
			name="default_torch_on_ceiling_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0
			},
		},
		{
			name="default_torch_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0
			},
		},
	},
	inventory_image = "default_torch_on_floor.png",
	wield_image = "default_torch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = default.LIGHT_MAX - 1,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,flammable=1,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})



local chest_formspec =
	"size[8,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[current_name;main;0,0.3;8,4;]"..
	"list[current_player;main;0,4.85;8,1;]"..
	"list[current_player;main;0,6.08;8,3;8]"..
	default.get_hotbar_bg(0,4.85)

local function get_locked_chest_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[nodemeta:".. spos .. ";main;0,0.3;8,4;]"..
		"list[current_player;main;0,4.85;8,1;]"..
		"list[current_player;main;0,6.08;8,3;8]"..
		default.get_hotbar_bg(0,4.85)
 return formspec
end

local function has_locked_chest_privilege(meta, player)
	if player:get_player_name() ~= meta:get_string("owner") then
		return false
	end
	return true
end

minetest.register_node("default:chest", {
	description = "Chest",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_front.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", chest_formspec)
		meta:set_string("infotext", "Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
})



minetest.register_node("default:chest_locked", {
	description = "Locked Chest",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_lock.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", "Locked Chest (owned by "..
				meta:get_string("owner")..")")
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Locked Chest")
		meta:set_string("owner", "")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main") and has_locked_chest_privilege(meta, player)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if not has_locked_chest_privilege(meta, player) then
			return 0
		end
		return count
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if not has_locked_chest_privilege(meta, player) then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if not has_locked_chest_privilege(meta, player) then
			return 0
		end
		return stack:get_count()
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to locked chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from locked chest at "..minetest.pos_to_string(pos))
	end,
	on_rightclick = function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		if has_locked_chest_privilege(meta, clicker) then
			minetest.show_formspec(
				clicker:get_player_name(),
				"default:chest_locked",
				get_locked_chest_formspec(pos)
			)
		else
			minetest.sound_play("default_chest_locked", {pos = pos})
		end
	end,
})



local bookshelf_formspec =
	"size[8,7;]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;books;0,0.3;8,2;]"..
	"list[current_player;main;0,2.85;8,1;]"..
	"list[current_player;main;0,4.08;8,3;8]"..
	default.get_hotbar_bg(0,2.85)

minetest.register_node("default:bookshelf", {
	description = "Bookshelf",
	tiles = {"default_wood.png", "default_wood.png", "default_bookshelf.png"},
	is_ground_content = false,
	groups = {choppy=3,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", bookshelf_formspec)
		local inv = meta:get_inventory()
		inv:set_size("books", 8*2)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("books")
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local to_stack = inv:get_stack(listname, index)
		if listname == "books" then
			if minetest.get_item_group(stack:get_name(), "book") ~= 0
					and to_stack:is_empty() then
				return 1
			else
				return 0
			end
		end
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		local to_stack = inv:get_stack(to_list, to_index)
		if to_list == "books" then
			if stack:get_name() == "default:book" and to_stack:is_empty() then
				return 1
			else
				return 0
			end
		end
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
			   " moves stuff in bookshelf at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
			   " moves stuff to bookshelf at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
			   " takes stuff from bookshelf at "..minetest.pos_to_string(pos))
	end,
})



minetest.register_node("default:sign_wall", {
	description = "Sign",
	drawtype = "nodebox",
	tiles = {"default_sign.png"},
	inventory_image = "default_sign_wall.png",
	wield_image = "default_sign_wall.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	node_box = {
		type = "wallmounted",
		wall_top    = {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125},
		wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
		wall_side   = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375},
	},
	groups = {choppy=2,dig_immediate=2,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),

	on_construct = function(pos)
		--local n = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
		meta:set_string("infotext", "\"\"")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		--print("Sign at "..minetest.pos_to_string(pos).." got "..dump(fields))
		if minetest.is_protected(pos, sender:get_player_name()) then
			minetest.record_protection_violation(pos, sender:get_player_name())
			return
		end
		local meta = minetest.get_meta(pos)
		if not fields.text then return end
		minetest.log("action", (sender:get_player_name() or "").." wrote \""..fields.text..
				"\" to sign at "..minetest.pos_to_string(pos))
		meta:set_string("text", fields.text)
		meta:set_string("infotext", '"'..fields.text..'"')
	end,
})

minetest.register_node("default:ladder", {
	description = "Ladder",
	drawtype = "signlike",
	tiles = {"default_ladder.png"},
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	groups = {choppy=2,oddly_breakable_by_hand=3,flammable=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_wood_defaults(),
})

local fence_texture = "default_fence_overlay.png^default_wood.png^default_fence_overlay.png^[makealpha:255,126,126"
minetest.register_node("default:fence_wood", {
	description = "Wooden Fence",
	drawtype = "fencelike",
	tiles = {"default_wood.png"},
	inventory_image = fence_texture,
	wield_image = fence_texture,
	paramtype = "light",
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
	},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})



minetest.register_node("default:glass", {
	description = "Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"default_glass.png", "default_glass_detail.png"},
	inventory_image = minetest.inventorycube("default_glass.png"),
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("default:obsidian_glass", {
	description = "Obsidian Glass",
	drawtype = "glasslike",
	tiles = {"default_obsidian_glass.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky=3,oddly_breakable_by_hand=3},
})



minetest.register_node("default:rail", {
	description = "Rail",
	drawtype = "raillike",
	tiles = {"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"},
	inventory_image = "default_rail.png",
	wield_image = "default_rail.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		-- but how to specify the dimensions for curved and sideways rails?
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {bendy=2,dig_immediate=2,attached_node=1},
})



minetest.register_node("default:brick", {
	description = "Brick Block",
	tiles = {"default_brick.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

--
-- Misc
--

minetest.register_node("default:cloud", {
	description = "Cloud",
	tiles = {"default_cloud.png"},
	sounds = default.node_sound_defaults(),
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("default:nyancat", {
	description = "Nyan Cat",
	tiles = {"default_nc_side.png", "default_nc_side.png", "default_nc_side.png",
		"default_nc_side.png", "default_nc_back.png", "default_nc_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=2},
	is_ground_content = false,
	legacy_facedir_simple = true,
	sounds = default.node_sound_defaults(),
})

minetest.register_node("default:nyancat_rainbow", {
	description = "Nyan Cat Rainbow",
	tiles = {
		"default_nc_rb.png^[transformR90", "default_nc_rb.png^[transformR90",
		"default_nc_rb.png", "default_nc_rb.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	is_ground_content = false,
	sounds = default.node_sound_defaults(),
})
