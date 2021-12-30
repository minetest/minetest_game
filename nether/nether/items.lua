local nether_sound = default.node_sound_stone_defaults({
	dig = {name="nether_dig", gain=0.7},
	dug = {name="nether_dug", gain=1},
	footstep = {name="nether_footstep", gain=0.4}
})

local add_fence = minetest.register_fence
local function add_more_nodes(name)
	local nd = "nether:"..name
	if not string.find(name, "nether") then
		name = "nether_"..name
	end
	local data = minetest.registered_nodes[nd]
	stairs.register_stair_and_slab(name, nd,
		data.groups,
		data.tiles,
		data.description.." Stair",
		data.description.." Slab",
		data.sounds
	)
	if add_fence then
		add_fence({fence_of = nd})
	end
end

--[[
local function add_fence(name)
	local def = minetest.registered_nodes[name]
	local fencedef = {}
	for _,i in pairs({"walkable", "sunlike_propagates"}) do
		if def[i] ~= nil then
			fencedef[i] = def[i]
		end
	end
end
--]]

local creative_installed = minetest.global_exists("creative")

local function digging_allowed(player, v)
	if not player then
		return false
	end
	if creative_installed
	and creative.is_enabled_for(player:get_player_name()) then
		return true
	end
	local tool = player:get_wielded_item():get_name()
	tool = minetest.registered_tools[tool] or tool == ""
		and minetest.registered_items[tool]
	if not tool
	or not tool.tool_capabilities then
		return false
	end
	local groups = tool.tool_capabilities.groupcaps
	if not groups then
		return false
	end
	if groups.nether
	and groups.nether.times[v] then
		return true
	end
	return false
end

-- Netherrack
minetest.register_node("nether:netherrack", {
	description = "Netherrack",
	tiles = {"nether_netherrack.png"},
	groups = {nether=2},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 2)
	end,
})
add_more_nodes("netherrack")

minetest.register_node("nether:netherrack_tiled", {
	description = "Tiled Netherrack",
	tiles = {"nether_netherrack_tiled.png"},
	groups = {nether=2},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 2)
	end,
})
add_more_nodes("netherrack_tiled")

minetest.register_node("nether:netherrack_soil", {
	description = "Dirty Netherrack",
	tiles = {"nether_netherrack.png^nether_netherrack_soil.png"},
	groups = {nether=2},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 2)
	end,
})

minetest.register_node("nether:netherrack_black", {
	description = "Black Netherrack",
	tiles = {"nether_netherrack_black.png"},
	groups = {nether=2},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 2)
	end,
})
add_more_nodes("netherrack_black")

minetest.register_node("nether:netherrack_blue", {
	description = "Blue Netherrack",
	tiles = {"nether_netherrack_blue.png"},
	groups = {nether=1},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 1)
	end,
})
add_more_nodes("netherrack_blue")

-- Netherbrick
minetest.register_node("nether:netherrack_brick", {
	description = "Netherrack Brick",
	tiles = {"nether_netherrack_brick.png"},
	groups = {nether=3},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("netherrack_brick")

minetest.register_node("nether:netherrack_brick_blue", {
	description = "Blue Netherrack Brick",
	tiles = {"nether_netherrack_brick_blue.png"},
	groups = {nether=3},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("netherrack_brick_blue")

minetest.register_node("nether:netherrack_brick_black", {
	description = "Black Netherrack Brick",
	tiles = {"nether_netherrack_brick_black.png"},
	groups = {nether=3},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("netherrack_brick_black")

minetest.register_node("nether:white", {
	description = "Siwtonic block",
	tiles = {"nether_white.png"},
	groups = {nether=1},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 1)
	end,
})
add_more_nodes("white")


-- Nether blood
minetest.register_node("nether:sapling", {
	description = "Nether Blood Child",
	drawtype = "plantlike",
	tiles = {"nether_sapling.png"},
	inventory_image = "nether_sapling.png",
	wield_image = "nether_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2, oddly_breakable_by_hand=2, attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("nether:blood", {
	description = "Nether Blood",
	tiles = {"nether_blood.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("blood")

minetest.register_node("nether:blood_cooked", {
	description = "Cooked Nether Blood",
	tiles = {"nether_blood_cooked.png"},
	groups = {nether=3},
	sounds = nether_sound,
	furnace_burntime = 10,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("blood_cooked")

minetest.register_node("nether:blood_empty", {
	description = "Nether Blood Extracted",
	tiles = {"nether_blood_empty.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("blood_empty")


minetest.register_node("nether:blood_top", {
	description = "Nether Blood Head",
	tiles = {"nether_blood_top.png", "nether_blood.png",
		"nether_blood.png^nether_blood_side.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("blood_top")

minetest.register_node("nether:blood_top_cooked", {
	description = "Cooked Nether Blood Head",
	tiles = {"nether_blood_top_cooked.png", "nether_blood_cooked.png",
		"nether_blood_cooked.png^nether_blood_side_cooked.png"},
	groups = {nether=3},
	sounds = nether_sound,
	furnace_burntime = 10,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("blood_top_cooked")

minetest.register_node("nether:blood_top_empty", {
	description = "Nether Blood Head Extracted",
	tiles = {"nether_blood_top_empty.png", "nether_blood_empty.png",
		"nether_blood_empty.png^nether_blood_side_empty.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("blood_top_empty")


minetest.register_node("nether:blood_stem", {
	description = "Nether Blood Stem",
	tiles = {"nether_blood_stem_top.png", "nether_blood_stem_top.png",
		"nether_blood_stem.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("blood_stem")

minetest.register_node("nether:blood_stem_cooked", {
	description = "Cooked Nether Blood Stem",
	tiles = {"nether_blood_stem_top_cooked.png",
		"nether_blood_stem_top_cooked.png", "nether_blood_stem_cooked.png"},
	groups = {nether=3},
	sounds = nether_sound,
	furnace_burntime = 30,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("blood_stem_cooked")

minetest.register_node("nether:blood_stem_empty", {
	description = "Nether Blood Stem Extracted",
	tiles = {"nether_blood_stem_top_empty.png",
		"nether_blood_stem_top_empty.png", "nether_blood_stem_empty.png"},
	groups = {tree=1, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("blood_stem_empty")


minetest.register_node("nether:wood", {
	description = "Nether Blood Wood",
	tiles = {"nether_wood.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("wood")

minetest.register_node("nether:wood_cooked", {
	description = "Cooked Nether Blood Wood",
	tiles = {"nether_wood_cooked.png"},
	groups = {nether=3},
	sounds = nether_sound,
	furnace_burntime = 8,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})
add_more_nodes("wood_cooked")

minetest.register_node("nether:wood_empty", {
	description = "Nether Wood",
	tiles = {"nether_wood_empty.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2, wood=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("wood_empty")

minetest.register_node("nether:extractor", {
	description = "Nether Blood Extractor",
	tiles = {"nether_blood_extractor.png"},
	groups = {nether=3},
	sounds = nether_sound,
	can_dig = function(_, player)
		return digging_allowed(player, 3)
	end,
})

-- Nether fruit
minetest.register_node("nether:fruit_leaves", {
	description = "Nether Fruit Leaves",
	tiles = {"nether_fruit_leaves.png"},
	groups = {fleshy=3, dig_immediate=2},
	sounds = default.node_sound_defaults(),
	furnace_burntime = 18,
})
add_more_nodes("fruit_leaves")

local function room_for_items(inv)
	local free_slots = 0
	for _,i in ipairs(inv:get_list("main")) do
		if i:get_count() == 0 then
			free_slots = free_slots+1
		end
	end
	if free_slots < 2 then
		return false
	end
	return true
end

local drop_mushroom = minetest.registered_nodes["riesenpilz:nether_shroom"].on_drop
minetest.override_item("riesenpilz:nether_shroom", {
	on_drop = function(itemstack, dropper, pos)
		if dropper:get_player_control().aux1 then
			return drop_mushroom(itemstack, dropper, pos)
		end
		local inv = dropper:get_inventory()
		if not inv then
			return
		end
		if not room_for_items(inv) then
			return
		end
		minetest.sound_play("nether_remove_leaf", {pos = pos,  gain = 0.25})
		itemstack:take_item()
		inv:add_item("main", "nether:shroom_head")
		inv:add_item("main", "nether:shroom_stem")
		return itemstack
	end,
})

minetest.register_node("nether:apple", {
	description = "Nether Fruit",
	drawtype = "nodebox",
	tiles = {"nether_fruit_top.png", "nether_fruit_bottom.png",
		"nether_fruit.png", "nether_fruit.png^[transformFX",
		"nether_fruit.png^[transformFX", "nether_fruit.png"},
	use_texture_alpha = "opaque",
	node_box = {
		type = "fixed",
		fixed = {
			{-1/6, -1/4, -1/6, 1/6, -1/6, 1/6},

			{-1/6, -1/6, -1/4, 1/6, 1/6, 1/4},
			{-1/4, -1/6, -1/6, 1/4, 1/6, 1/6},

			{-1/4, 1/6, -1/12, 1/4, 1/4, 1/12},
			{-1/12, 1/6, -1/4, 1/12, 1/4, 1/4},

			{-1/6, 1/6, -1/6, 1/6, 1/3, 1/6},

			{-1/12, 1/3, -1/12, 0, 5/12, 0},

			{-1/12, 5/12, -1/6, 0, 0.5, 1/12},
			{-1/6, 5/12, -1/12, 1/12, 0.5, 0},
		}
	},
	paramtype = "light",
	groups = {fleshy=3, dig_immediate=3},
	on_use = function(itemstack, user)
		local inv = user:get_inventory()
		if not inv then
			return
		end
		itemstack:take_item()
		if nether.teleport_player(user) then
			return itemstack
		end
		local amount = math.random(4, 6)
		inv:add_item("main", {name="nether:blood_extracted", count=math.floor(amount/3)})
		user:set_hp(user:get_hp()-amount)
		return itemstack
	end,
	sounds = default.node_sound_defaults(),
	furnace_burntime = 6,
})

local drop_fruit = minetest.registered_nodes["nether:apple"].on_drop
minetest.override_item("nether:apple", {
	on_drop = function(itemstack, dropper, pos)
		if dropper:get_player_control().aux1 then
			return drop_fruit(itemstack, dropper, pos)
		end
		local inv = dropper:get_inventory()
		if not inv then
			return
		end
		if not room_for_items(inv) then
			return
		end
		minetest.sound_play("nether_remove_leaf", {pos = pos,  gain = 0.25})
		itemstack:take_item()
		inv:add_item("main", "nether:fruit_leaf")
		inv:add_item("main", "nether:fruit_no_leaf")
		return itemstack
	end,
})

-- Nether vine
minetest.register_node("nether:vine", {
	description = "Nether vine",
	walkable = false,
	drop = "nether:sapling",
	sunlight_propagates = true,
	paramtype = "light",
	tiles = { "nether_vine.png" },
	drawtype = "plantlike",
	inventory_image = "nether_vine.png",
	groups = { snappy = 3,flammable=2 },
	sounds = default.node_sound_leaves_defaults(),
	after_dig_node = function(pos, _, _, digger)
		if digger then
			local p = {x=pos.x, y=pos.y-1, z=pos.z}
			local nn = minetest.get_node(p)
			if nn.name == "nether:vine" then
				minetest.node_dig(p, nn, digger)
			end
		end
	end
})


-- forest stuff

for n,i in pairs({"small", "middle", "big"}) do
	minetest.register_node("nether:grass_"..i, {
		description = "Nether Grass",
		drawtype = "plantlike",
		waving = 1,
		tiles = {"nether_grass_"..i..".png"},
		inventory_image = "nether_grass_"..i..".png",
		wield_image = "nether_grass_"..i..".png",
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		drop = "nether:grass "..n,
		groups = {snappy=3,flora=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})
end

minetest.register_node("nether:glowflower", {
	description = "Glowing Flower",
	drawtype = "plantlike",
	tiles = {"nether_glowflower.png"},
	inventory_image = "nether_glowflower.png",
	wield_image = "nether_glowflower.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	light_source = 10,
	groups = {snappy=3,flammable=2,flower=1,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

minetest.register_node("nether:tree_sapling", {
	description = "Nether Tree Sapling",
	drawtype = "plantlike",
	tiles = {"nether_tree_sapling.png"},
	inventory_image = "nether_tree_sapling.png",
	wield_image = "nether_tree_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2, oddly_breakable_by_hand=2, attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("nether:tree", {
	description = "Nether Trunk",
	tiles = {"nether_tree_top.png", "nether_tree_top.png", "nether_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("nether:tree_corner", {
	description = "Nether Trunk Corner",
	tiles = {"nether_tree.png^[transformR180", "nether_tree_top.png",
		"nether_tree_corner.png^[transformFY",
		"nether_tree_corner.png^[transformR180", "nether_tree.png",
		"nether_tree_top.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,not_in_creative_inventory=1},
	drop = "nether:tree",
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("nether:forest_wood", {
	description = "Nether Wood Block",
	tiles = {"nether_forest_wood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,wood=1},
	sounds = default.node_sound_wood_defaults(),
})
add_more_nodes("forest_wood")

minetest.register_node("nether:leaves", {
	description = "Nether Leaves",
	drawtype = "plantlike",
	waving = 1,
	visual_scale = math.sqrt(2) + 0.01,
	tiles = {"nether_leaves.png"},
	inventory_image = "nether_leaves.png",
	wield_image = "nether_leaves.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=3, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {"nether:tree_sapling"},
				rarity = 30,
			},
			{
				items = {"nether:leaves"},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("nether:dirt", {
	description = "Nether Dirt",
	tiles = {"nether_dirt.png"},
	groups = {crumbly=3,soil=1,nether_dirt=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("nether:dirt_top", {
	description = "Nether Dirt Top",
	tiles = {"nether_dirt_top.png", "nether_dirt.png",
		{name="nether_dirt.png^nether_dirt_top_side.png", tileable_vertical = false}
	},
	groups = {crumbly=3,soil=1,nether_dirt=1},
	drop = "nether:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

minetest.register_node("nether:dirt_bottom", {
	description = "Netherrack Dirt Transition",
	tiles = {"nether_dirt.png", "nether_netherrack.png",
		{name="nether_netherrack.png^nether_dirt_transition.png", tileable_vertical = false}
	},
	groups = {nether=2},
	drop = "nether:netherrack",
	sounds = default.node_sound_dirt_defaults({
		dig = {name="nether_dig", gain=0.7},
		dug = {name="nether_dug", gain=1},
	}),
	can_dig = function(_, player)
		return digging_allowed(player, 2)
	end,
})


-- Nether torch
minetest.register_node("nether:torch", {
	description = "Nether Torch",
	drawtype = "torchlike",
	tiles = {"nether_torch_on_floor.png", "nether_torch_on_ceiling.png",
		{
			name = "nether_torch.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	inventory_image = "nether_torch_on_floor.png",
	wield_image = "nether_torch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2, dig_immediate=3, attached_node=1, hot=3, igniter=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})

local invisible = "nether_transparent.png"
minetest.register_node("nether:portal", {
	description = "Nether Portal Essence",
	tiles = {invisible, invisible, invisible, invisible, "nether_portal_stuff.png"},
	inventory_image = "nether_portal_stuff.png",
	wield_image = "nether_portal_stuff.png",
	light_source = 12,
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "blend",
	walkable = false,
	pointable = false,
	buildable_to = false,
	drop = "",
	diggable = false,
	groups = {not_in_creative_inventory=1},
	post_effect_color = {a=200, r=50, g=0, b=60},--{a=180, r=128, g=0, b=128}
	drawtype = "nodebox",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
})


minetest.register_craftitem("nether:grass", {
	description = "Nether Grass",
	inventory_image = "nether_grass.png",
})

minetest.register_craftitem("nether:grass_dried", {
	description = "Dried Nether Grass",
	inventory_image = "nether_grass_dried.png",
	furnace_burntime = 1,
})

minetest.register_craftitem("nether:forest_planks", {
	description = "Nether Wooden Planks",
	inventory_image = "nether_forest_planks.png",
	stack_max = 990,
})

minetest.register_craftitem("nether:bark", {
	description = "Nether Trunk Bark",
	inventory_image = "nether_bark.png",
	furnace_burntime = 5,
})

-- Nether Pearl
minetest.register_craftitem("nether:pearl", {
	description = "Nether Pearl",
	inventory_image = "nether_pearl.png",
})

minetest.register_craftitem("nether:stick", {
	description = "Nether Stick",
	inventory_image = "nether_stick.png",
	groups = {stick=1},
})

local tmp = {}
minetest.register_craftitem("nether:shroom_head", {
	description = "Nether Mushroom Head",
	inventory_image = "nether_shroom_top.png",
	furnace_burntime = 3,
	on_place = function(itemstack, _, pointed_thing)
		if not pointed_thing then
			return
		end

		if pointed_thing.type ~= "node" then
			return
		end

		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node = minetest.get_node(pos)
		local pstr = pos.x.." "..pos.y.." "..pos.z

		if node.name == "nether:netherrack_soil"
		and not tmp[pstr] then
			minetest.sound_play("default_grass_footstep", {pos=pos})
			minetest.set_node(pos, {name="nether:netherrack_soil", param2=math.max(node.param2, math.random(3, 10))})
			tmp[pstr] = true
			minetest.after(3, function() tmp[pos.x.." "..pos.y.." "..pos.z] = nil end)
		end
	end
})

minetest.register_craftitem("nether:shroom_stem", {
	description = "Nether Mushroom Stem",
	inventory_image = "nether_shroom_stem.png",
	furnace_burntime = 3,
})

minetest.register_craftitem("nether:fruit_leaf", {
	description = "Nether Fruit Leaf",
	inventory_image = "nether_fruit_leaf.png",
	furnace_burntime = 2,
})

minetest.register_craftitem("nether:fruit_no_leaf", {
	description = "Nether Fruit Without Leaf",
	inventory_image = "nether_fruit_no_leaf.png",
	furnace_burntime = 4,
})

minetest.register_craftitem("nether:fim", {
	description = "Nether FIM",	--fruit in mushroom
	inventory_image = "nether_fim.png",
	furnace_burntime = 10,
})

local blood_exno = {}
for _,i in ipairs({"nether:blood", "nether:blood_top", "nether:blood_stem"}) do
	blood_exno[i] = i.."_empty"
end

minetest.register_craftitem("nether:blood_extracted", {
	description = "Blood",
	inventory_image = "nether_blood_extracted.png",
	on_place = function(itemstack, _, pointed_thing)
		if not pointed_thing then
			return
		end

		if pointed_thing.type ~= "node" then
			return
		end

		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node = minetest.get_node_or_nil(pos)

		if not node then
			return
		end

		if node.name == "nether:vine" then
			pos = {x=pos.x, y=pos.y-1, z=pos.z}
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name = "nether:vine"})
			end
			itemstack:take_item()
			return itemstack
		end

		if node.name ~= "nether:extractor" then
			return
		end
		itemstack:take_item()
		minetest.after(1, function(pos)
			for i = -1,1,2 do
				for _,p in ipairs({
					{x=pos.x+i, y=pos.y, z=pos.z},
					{x=pos.x, y=pos.y, z=pos.z+i},
				}) do
					local nodename = blood_exno[minetest.get_node(p).name]
					if nodename then
						minetest.set_node(p, {name=nodename})
						p = vector.add(p, {x=math.random()-0.5, y=math.random()+0.5, z=math.random()-0.5})
						minetest.sound_play("nether_extract_blood", {pos = p,  gain = 1})
						minetest.add_item(p, "nether:blood_extracted")
					end
				end
			end
		end, pos)

		return itemstack
	end
})

minetest.register_craftitem("nether:hotbed", {
	description = "Cooked Blood",
	inventory_image = "nether_hotbed.png",
	on_place = function(itemstack, _, pointed_thing)
		if not pointed_thing then
			return
		end
		if pointed_thing.type ~= "node" then
			return
		end
		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node = minetest.get_node(pos)

		if node.name ~= "nether:netherrack" then
			return
		end

		minetest.sound_play("default_place_node", {pos=pos})
		minetest.set_node(pos, {name = "nether:netherrack_soil"})

		itemstack:take_item()
		return itemstack
	end
})


minetest.register_tool("nether:pick_mushroom", {
	description = "Nether Mushroom Pickaxe",
	inventory_image = "nether_pick_mushroom.png",
	tool_capabilities = {
		max_drop_level=0,
		groupcaps={
			cracky = {times={[3]=3}, uses=1, maxlevel=1},
			nether = {times={[3]=3}, uses=1, maxlevel=1},
		},
	},
})

minetest.register_tool("nether:pick_wood", {
	description = "Nether Wood Pickaxe",
	inventory_image = "nether_pick_wood.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[3]=1.6}, uses=10, maxlevel=1},
			nether = {times={[2]=6, [3]=1.6}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
})

minetest.register_tool("nether:pick_netherrack", {
	description = "Netherrack Pickaxe",
	inventory_image = "nether_pick_netherrack.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=2.0, [3]=1.20}, uses=20, maxlevel=1},
			nether = {times={[1]=16, [2]=2, [3]=1.20}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
})

minetest.register_tool("nether:pick_netherrack_blue", {
	description = "Blue Netherrack Pickaxe",
	inventory_image = "nether_pick_netherrack_blue.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=30, maxlevel=2},
			nether = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
})

minetest.register_tool("nether:pick_white", {
	description = "Siwtonic Pickaxe",
	inventory_image = "nether_pick_white.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=1, [2]=0.8, [3]=0.3}, uses=180, maxlevel=3},
			nether = {times={[1]=1, [2]=0.5, [3]=0.3}, uses=180, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("nether:axe_netherrack", {
	description = "Netherrack Axe",
	inventory_image = "nether_axe_netherrack.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			choppy={times={[1]=2.9, [2]=1.9, [3]=1.4}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
})

minetest.register_tool("nether:axe_netherrack_blue", {
	description = "Blue Netherrack Axe",
	inventory_image = "nether_axe_netherrack_blue.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.5, [2]=1.5, [3]=1}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=6},
	},
})

minetest.register_tool("nether:axe_white", {
	description = "Siwtonic Axe",
	inventory_image = "nether_axe_white.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=1.2, [2]=0.5, [3]=0.3}, uses=180, maxlevel=2},
		},
		damage_groups = {fleshy=8},
	},
})

minetest.register_tool("nether:shovel_netherrack", {
	description = "Netherrack Shovel",
	inventory_image = "nether_shovel_netherrack.png",
	wield_image = "nether_shovel_netherrack.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=1.7, [2]=1.1, [3]=0.45}, uses=22, maxlevel=2},
		},
		damage_groups = {fleshy=2},
	},
})

minetest.register_tool("nether:shovel_netherrack_blue", {
	description = "Blue Netherrack Shovel",
	inventory_image = "nether_shovel_netherrack_blue.png",
	wield_image = "nether_shovel_netherrack_blue.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.4, [2]=0.8, [3]=0.35}, uses=50, maxlevel=2},
		},
		damage_groups = {fleshy=3},
	},
})

minetest.register_tool("nether:shovel_white", {
	description = "Siwtonic Shovel",
	inventory_image = "nether_shovel_white.png",
	wield_image = "nether_shovel_white.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=0.95, [2]=0.45, [3]=0.1}, uses=151, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
})

minetest.register_tool("nether:sword_netherrack", {
	description = "Netherrack Sword",
	inventory_image = "nether_sword_netherrack.png",
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.3, [3]=0.38}, uses=40, maxlevel=1},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("nether:sword_netherrack_blue", {
	description = "Blue Netherrack Sword",
	inventory_image = "nether_sword_netherrack_blue.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=2.5, [2]=1.1, [3]=0.33}, uses=40, maxlevel=2},
		},
		damage_groups = {fleshy=7},
	},
})

minetest.register_tool("nether:sword_white", {
	description = "Siwtonic Sword",
	inventory_image = "nether_sword_white.png",
	wield_image = "nether_sword_white.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.7, [2]=0.8, [3]=0.2}, uses=100, maxlevel=3},
		},
		damage_groups = {fleshy=11},
	},
})


-- override creative hand
if minetest.settings:get_bool("creative_mode") then
	local capas = minetest.registered_items[""].tool_capabilities
	capas.groupcaps.nether = capas.groupcaps.cracky
	minetest.override_item("", {tool_capabilities = capas})
end
