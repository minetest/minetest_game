-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.

stairs = {}

-- Node will be called stairs:stair_<subname>
function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node("stairs:stair_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tile_images = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = minetest.rotate_node
	})

	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{recipeitem, "", ""},
			{recipeitem, recipeitem, ""},
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Node will be called stairs:slab_<subname>
function stairs.register_slab(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node("stairs:slab_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tile_images = images,
		paramtype = "light",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = minetest.rotate_node
	})

	minetest.register_craft({
		output = 'stairs:slab_' .. subname .. ' 3',
		recipe = {
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Nodes will be called stairs:{stair,slab}_<subname>
function stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds)
end

stairs.register_stair_and_slab("wood", "default:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_wood.png"},
		"Wooden Stair",
		"Wooden Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("stone", "default:stone",
		{cracky=3},
		{"default_stone.png"},
		"Stone Stair",
		"Stone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("cobble", "default:cobble",
		{cracky=3},
		{"default_cobble.png"},
		"Cobblestone Stair",
		"Cobblestone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("desert_stone", "default:desert_stone",
		{cracky=3},
		{"default_desert_stone.png"},
		"Desertstone Stair",
		"Desertstone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("desert_cobble", "default:desert_cobble",
		{cracky=3},
		{"default_desert_cobble.png"},
		"Desert Cobblestone Stair",
		"Desert Cobblestone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("desert_stonebrick", "default:desert_stonebrick",
		{cracky=3},
		{"default_desert_stone_brick.png"},
		"Desert Stone Brick Stair",
		"Desert Stone Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("brick", "default:brick",
		{cracky=3},
		{"default_brick.png"},
		"Brick Stair",
		"Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("sandstone", "default:sandstone",
		{crumbly=2,cracky=2},
		{"default_sandstone.png"},
		"Sandstone Stair",
		"Sandstone Slab",
		default.node_sound_stone_defaults())
		
stairs.register_stair_and_slab("sandstonebrick", "default:sandstonebrick",
		{crumbly=2,cracky=2},
		{"default_sandstone_brick.png"},
		"Sandstone Brick Stair",
		"Sandstone Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("junglewood", "default:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_junglewood.png"},
		"Junglewood Stair",
		"Junglewood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("stonebrick", "default:stonebrick",
		{cracky=3},
		{"default_stone_brick.png"},
		"Stone Brick Stair",
		"Stone Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("pinewood", "default:pinewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_pinewood.png"},
		"Pinewood Stair",
		"Pinewood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("obsidian", "default:obsidian",
		{cracky=1,level=2},
		{"default_obsidian.png"},
		"Obsidian Stair",
		"Obsidian Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("obsidianbrick", "default:obsidianbrick",
		{cracky=1,level=2},
		{"default_obsidian_brick.png"},
		"Obsidian Brick Stair",
		"Obsidian Brick Slab",
		default.node_sound_stone_defaults())
