
----------------
-- Lookup tables
----------------

-- Contains which mortar you get when you put a rapeseed into a mortar
local put_seed_into_mortar = {
	["farming:mortar"] = "farming:mortar_with_1_rapeseed",
	["farming:mortar_with_1_rapeseed"] = "farming:mortar_with_2_rapeseed",
	["farming:mortar_with_2_rapeseed"] = "farming:mortar_with_3_rapeseed",
}
-- Contains which mortar you get when you take oil from a mortar with a bottle
local take_oil_from_mortar = {
	["farming:mortar_with_1_rapeseed_oil"] = "farming:mortar",
	["farming:mortar_with_2_rapeseed_oil"] = "farming:mortar_with_1_rapeseed_oil",
	["farming:mortar_with_3_rapeseed_oil"] = "farming:mortar_with_2_rapeseed_oil",
}

-- Conatins what will be in the mortar after the player used the pestle often enough
-- How often the pestle has to be used is calculated in get_num_poundings
local pound_with_pestle = {
	["farming:mortar_with_1_rapeseed"] = {
		after = "farming:mortar_with_1_rapeseed_oil",
		base_min = 1,
		base_max = 2,
		prob = 0.5,
	},
	["farming:mortar_with_2_rapeseed"] = {
		after = "farming:mortar_with_2_rapeseed_oil",
		base_min = 2,
		base_max = 3,
		prob = 0.3,
	},
	["farming:mortar_with_3_rapeseed"] = {
		after = "farming:mortar_with_3_rapeseed_oil",
		base_min = 3,
		base_max = 4,
		prob = 0.2,
	},
}

-- Returns for an entry in pound_with_pestle, how often the player has to use the
-- pestle
local function get_num_poundings(entry)
	local ret = math.random(entry.base_min, entry.base_max)
	-- todo: make this more efficient
	while math.random() > entry.prob do
		ret = ret + 1
	end
	return ret
end


----------------------------------
-- Tables that are used at runtime
----------------------------------

-- Contains for hashed node positions how many step pounding uses are still needed
local pending_poundings = {}


---------------------------------
-- Basic helpers for registration
---------------------------------

local function get_mortar_nodebox(fill_num)
	-- the mortar's sides are 2/16 high
	-- we do not want the mortar to be filled completely => 1.8 / 16
	-- there can be up to 3 seeds or layers oil in the mortar => / 3
	local fill_offset = fill_num * (1.8 / 16 / 3)
	return {
		type = "fixed",
		fixed = {
			{-3/16, -0.5, -3/16, 3/16, -7/16 + fill_offset, 3/16},  -- ground plate + filling
			{-1/4, -7/16, -3/16, -3/16, -5/16, 3/16}, -- 4 sides
			{-3/16, -7/16, -1/4, 3/16, -5/16, -3/16},
			{3/16, -7/16, -3/16, 1/4, -5/16, 3/16},
			{-3/16, -7/16, 3/16, 3/16, -5/16, 1/4}
		},
	}
end

local mortar_box_simple = {
	type = "fixed",
	fixed = {-1/4, -0.5, -1/4, 1/4, -5/16, 1/4},
}

local function mortar_on_flood(pos)
	-- drop the mortar as item
	pos = vector.new(pos)
	pos.y = pos.y - 0.3
	minetest.add_item(pos, "farming:mortar")
end

local function poundable_mortar_on_destruct(pos)
	-- remove the entry in pending_poundings
	local pos_hash = minetest.hash_node_position(pos)
	pending_poundings[pos_hash] = nil
end


----------------------------------------------
-- Function for using the pestle on the mortar
----------------------------------------------

local function pestle_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then
		return
	end

	local pos = pointed_thing.under
	local node = minetest.get_node(pos)
	-- find out if the node is a mortar and get its pounding target
	local target = pound_with_pestle[node.name]
	if not target then
		return
	end

	-- check for protection
	local user_name = user and minetest.is_player(user) and
			user:get_player_name() or ""
	if minetest.is_protected(pos, user_name) then
		return
	end

	-- get how often the player still has to use the pestle
	local pos_hash = minetest.hash_node_position(pos)
	local remaining_hits = pending_poundings[pos_hash]
	-- if not found, generate new amount from specs
	remaining_hits = remaining_hits or get_num_poundings(target)
	remaining_hits = remaining_hits - 1
	if remaining_hits == 0 then
		-- replace with target node
		node.name = target.after
		minetest.swap_node(pos, node)
		-- clean up
		pending_poundings[pos_hash] = nil
	else
		-- write back
		pending_poundings[pos_hash] = remaining_hits
	end

	minetest.sound_play({name = "default_hard_footstep", gain = 1.0},
			{pos = pos}, true)
	-- add tool wear
	if not minetest.global_exists("creative") or
			not creative.is_enabled_for(user_name) then
		itemstack:add_wear(1024)
		if itemstack:is_empty() then
			-- item broke
			minetest.sound_play("default_tool_breaks", {pos = pos, gain = 0.5},
					true)
		end
	end
	return itemstack
end


--------------------------
-- Mortar and Pestle Items
--------------------------

-- the empty mortar
minetest.register_node("farming:mortar", {
	description = "Mortar",
	groups = {cracky = 3},
	stack_max = 16,
	drawtype = "nodebox",
	tiles = {"default_clay.png"},
	paramtype = "light",
	paramtype2 = "none",
	is_ground_content = false,
	floodable = true,
	node_box = get_mortar_nodebox(0),
	selection_box = mortar_box_simple,
	collision_box = mortar_box_simple,
	sounds = default.node_sound_stone_defaults(),
	on_flood = mortar_on_flood,
})

-- filled mortars
for _, item in ipairs({"rapeseed", "rapeseed_oil"}) do
	local top_tile, on_destruct

	if item == "rapeseed" then
		top_tile = "farming_rapeseed_in_mortar.png"
		on_destruct = poundable_mortar_on_destruct
	else
		top_tile = "(farming_rapeseed_oil.png^[mask:farming_mortar_mask.png)"
	end
	top_tile = "default_clay.png^" .. top_tile

	for fillstate = 1, 3 do
		minetest.register_node(string.format("farming:mortar_with_%i_%s", fillstate,
				item), {
			groups = {cracky = 3, not_in_creative_inventory = 1},
			drawtype = "nodebox",
			tiles = {top_tile, "default_clay.png"},
			paramtype = "light",
			paramtype2 = "none",
			is_ground_content = false,
			floodable = true,
			node_box = get_mortar_nodebox(fillstate),
			selection_box = mortar_box_simple,
			collision_box = mortar_box_simple,
			sounds = default.node_sound_stone_defaults(),
			drop = "farming:mortar",
			on_flood = mortar_on_flood,
			on_destruct = on_destruct,
		})
	end
end

minetest.register_tool("farming:pestle", {
	description = "Pestle",
	groups = {},
	inventory_image = "farming_pestle.png",
	wield_image = "farming_pestle.png^[transformR270",
	stack_max = 1,
	range = 2.0,
	sound = {breaks = "default_tool_breaks"},
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {},
		damage_groups = {},
	},
	on_use = pestle_on_use,
})


------------------------------------------
-- Overrides for seed and glass bottle
-- (for putting into / taking from mortar)
------------------------------------------

-- implement putting seeds into the mortar
local old_rapeseed_on_place = minetest.registered_items["farming:rapeseed"].on_place
minetest.override_item("farming:rapeseed", {
	node_placement_prediction = "", -- deactivate prediction (it looks bad)

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return old_rapeseed_on_place(itemstack, placer, pointed_thing)
		end

		-- do protection checks and check if mortar is clicked
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		local new_node_name = put_seed_into_mortar[node.name]

		local placer_name = placer and minetest.is_player(placer) and
				placer:get_player_name() or ""

		if minetest.is_protected(pos, placer_name) or not new_node_name then
			return old_rapeseed_on_place(itemstack, placer, pointed_thing)
		end

		-- replace the node
		node.name = new_node_name
		minetest.swap_node(pos, node)

		-- clear pending_poundings (the player has to start over)
		pending_poundings[minetest.hash_node_position(pos)] = nil

		-- remove the seed from inventory
		if not minetest.global_exists("creative") or
				not creative.is_enabled_for(placer_name) then
			itemstack:take_item()
		end
		return itemstack
	end,
})

-- implement taking oil from the mortar with glass bottle
local old_glass_bottle_on_use = minetest.registered_items["vessels:glass_bottle"].on_use
		or function(itemstack, user, pointed_thing)
			-- default behaviour when leftclicking with item
			if pointed_thing.type == "object" then
				pointed_thing.ref:punch(user, 1.0, {full_punch_interval = 1.0}, nil)
				return user:get_wielded_item()
			elseif pointed_thing.type == "node" then
				local node = minetest.get_node(pointed_thing.under)
				local node_def = minetest.registered_nodes[node.name]
				if node_def then
					node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
				end
				return user:get_wielded_item()
			end
		end
minetest.override_item("vessels:glass_bottle", {
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return old_glass_bottle_on_use(itemstack, user, pointed_thing)
		end

		-- do protection checks and check if mortar is clicked
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		local new_node_name = take_oil_from_mortar[node.name]

		local user_is_player = user and minetest.is_player(user)
		local user_name = user_is_player and user:get_player_name() or ""

		if minetest.is_protected(pos, user_name) or not new_node_name then
			return old_glass_bottle_on_use(itemstack, user, pointed_thing)
		end

		-- replace the node
		node.name = new_node_name
		minetest.swap_node(pos, node)

		-- fill the bottle
		local creative_enabled = minetest.global_exists("creative") and
				creative.is_enabled_for(user_name)
		local item_count = itemstack:get_count()
		-- try to replace
		if item_count == 1 and not creative_enabled then
			itemstack:set_name("farming:glass_bottle_with_rapeseed_oil")
			return itemstack
		end
		-- do not take in creative
		if not creative_enabled then
			itemstack:take_item()
		end
		-- add full bottle to inventory or drop it
		local full_bottle = ItemStack("farming:glass_bottle_with_rapeseed_oil")
		if user_is_player then
			local inv = user:get_inventory()
			if inv then
				full_bottle = inv:add_item("main", full_bottle)
			end
		end
		if not full_bottle:is_empty() then
			-- no space => drop full bottle
			minetest.add_item(pos, full_bottle)
		end
		return itemstack
	end,
})


-------------
-- Craftitems
-------------

minetest.register_craftitem("farming:raw_mortar", {
	description = "Raw Mortar",
	groups = {},
	inventory_image = "farming_raw_mortar.png",
	stack_max = 16,
})

minetest.register_craftitem("farming:raw_pestle", {
	description = "Raw Pestle",
	groups = {},
	inventory_image = "farming_raw_pestle.png",
	stack_max = 1,
})

minetest.register_craftitem("farming:glass_bottle_with_rapeseed_oil", {
	description = "Bottle with Rapeseed Oil",
	groups = {},
	inventory_image = "farming_rapeseed_oil.png^[mask:vessels_glass_bottle_liquidmask.png"
			.. "^vessels_glass_bottle.png",
	on_use = minetest.item_eat(3, "vessels:glass_bottle"),
})


-----------
-- Crafting
-----------

minetest.register_craft({
	output = "farming:raw_mortar",
	recipe = {
		{"default:clay_lump", "",                  "default:clay_lump"},
		{"",                  "default:clay_lump", ""},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "farming:mortar",
	recipe = "farming:raw_mortar",
	cooktime = 3,
})

minetest.register_craft({
	output = "farming:raw_pestle",
	recipe = {
		{"default:clay_lump"},
		{"default:clay_lump"},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "farming:pestle",
	recipe = "farming:raw_pestle",
	cooktime = 3,
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:glass_bottle_with_rapeseed_oil",
	burntime = 13,
	replacements = {{"farming:glass_bottle_with_rapeseed_oil", "vessels:glass_bottle"}},
})

minetest.register_craft({
	output = "default:torch 4",
	recipe = {
		{"farming:glass_bottle_with_rapeseed_oil"},
		{"farming:cotton"},
		{"group:stick"},
	},
	replacements = {{"farming:glass_bottle_with_rapeseed_oil", "vessels:glass_bottle"}},
})
