-- bones/init.lua

-- Minetest 0.4 mod: bones
-- See README.txt for licensing and other information.

-- Load support for MT game translation.
local S = minetest.get_translator("bones")

local theoretical_max_slots = minetest.settings:get("bones_max_slots") or ( 15 * 10 )
local dead_player_callbacks={}

bones = {}

local function is_owner(pos, name)
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name or minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	return false
end

local function get_bones_formspec_wh(cols,rows)
	return
		"size[" .. cols .. "," .. ( rows + 5 ) .. "]" ..
		"list[current_name;main;0,0.3;" .. cols .. "," .. rows .. ";]" ..
		"list[current_player;main;" .. ( ( cols - 8 ) / 2 ) .. "," .. rows .. ".85;8,1;]" ..
		"list[current_player;main;".. ( ( cols - 8 ) / 2 ) .. "," .. ( rows + 2 ) .. ".08;8,3;8]" ..
		"listring[current_name;main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85)
end

local function get_bones_formspec_for_size(numitems)
	--the absolute minimum is 4*8
	if numitems <= 4 * 8 then
		return get_bones_formspec_wh(8, 4)
	end
	--if we're over 4*8, but below 4*15 we make it 4 rows and adjust the column count to make everything fit
	if numitems <= 4 * 15 then
		return get_bones_formspec_wh( math.floor ( ( numitems + 3 ) / 4 ), 4)
	end
	--if we're over 4*15 we'll make 15 columns and adjust the row count to make everything fit
	return get_bones_formspec_wh(15, math.floor ( ( numitems + 14 ) / 15 ) )
end

local share_bones_time = tonumber(minetest.settings:get("share_bones_time")) or 1200
local share_bones_time_early = tonumber(minetest.settings:get("share_bones_time_early")) or share_bones_time / 4

local bones_def = {
	description = S("Bones"),
	tiles = {
		"bones_top.png^[transform2",
		"bones_bottom.png",
		"bones_side.png",
		"bones_side.png",
		"bones_rear.png",
		"bones_front.png"
	},
	paramtype2 = "facedir",
	groups = {dig_immediate = 2},
	sounds = default.node_sound_gravel_defaults(),

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if meta:get_inventory():is_empty("main") then
			local inv = player:get_inventory()
			if inv:room_for_item("main", {name = "bones:bones"}) then
				inv:add_item("main", {name = "bones:bones"})
			else
				minetest.add_item(pos, "bones:bones")
			end
			minetest.remove_node(pos)
		end
	end,

	on_punch = function(pos, node, player)
		if not is_owner(pos, player:get_player_name()) then
			return
		end

		if minetest.get_meta(pos):get_string("infotext") == "" then
			return
		end

		local inv = minetest.get_meta(pos):get_inventory()
		local player_inv = player:get_inventory()
		local has_space = true

		for i = 1, inv:get_size("main") do
			local stk = inv:get_stack("main", i)
			if player_inv:room_for_item("main", stk) then
				inv:set_stack("main", i, nil)
				player_inv:add_item("main", stk)
			else
				has_space = false
				break
			end
		end

		-- remove bones if player emptied them
		if has_space then
			if player_inv:room_for_item("main", {name = "bones:bones"}) then
				player_inv:add_item("main", {name = "bones:bones"})
			else
				minetest.add_item(pos,"bones:bones")
			end
			minetest.remove_node(pos)
		end
	end,

	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local time = meta:get_int("time") + elapsed
		if time >= share_bones_time then
			meta:set_string("infotext", S("@1's old bones", meta:get_string("owner")))
			meta:set_string("owner", "")
		else
			meta:set_int("time", time)
			return true
		end
	end,
	on_blast = function(pos)
	end,
}

default.set_inventory_action_loggers(bones_def, "bones")

minetest.register_node("bones:bones", bones_def)

local function may_replace(pos, player)
	local node_name = minetest.get_node(pos).name
	local node_definition = minetest.registered_nodes[node_name]

	-- if the node is unknown, we return false
	if not node_definition then
		return false
	end

	-- allow replacing air
	if node_name == "air" then
		return true
	end

	-- don't replace nodes inside protections
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end

	-- allow replacing liquids
	if node_definition.liquidtype ~= "none" then
		return true
	end

	-- don't replace filled chests and other nodes that don't allow it
	local can_dig_func = node_definition.can_dig
	if can_dig_func and not can_dig_func(pos, player) then
		return false
	end

	-- default to each nodes buildable_to; if a placed block would replace it, why shouldn't bones?
	-- flowers being squished by bones are more realistical than a squished stone, too
	return node_definition.buildable_to
end

local drop = function(pos, itemstack)
	local obj = minetest.add_item(pos, itemstack:take_item(itemstack:get_count()))
	if obj then
		obj:set_velocity({
			x = math.random(-10, 10) / 9,
			y = 5,
			z = math.random(-10, 10) / 9,
		})
	end
end

local player_inventory_lists = { "main", "craft" }
bones.player_inventory_lists = player_inventory_lists

--functions registered this way won't becalled if bones_mode is keep
function bones.register_dead_player_inv_management(func)
	table.insert(dead_player_callbacks, func)
end

local function transfer_stack_to_bones(stk,current_dead_player)
	-- check if it's possible to place bones, if not find space near player
	if ( current_dead_player.bones_mode == "bones" ) and
			( current_dead_player.bones_pos == nil ) then
		current_dead_player.bones_pos = current_dead_player.player_pos
		local air
		if may_replace(current_dead_player.bones_pos, current_dead_player.player) then
			air = current_dead_player.bones_pos
		else
			air = minetest.find_node_near(current_dead_player.bones_pos, 1, {"air"})
		end

		if air and not minetest.is_protected(air, current_dead_player.player_name) then
			current_dead_player.bones_pos = air
			local param2 = minetest.dir_to_facedir(current_dead_player.player:get_look_dir())
			minetest.set_node(current_dead_player.bones_pos, {name = "bones:bones", param2 = param2})
			local meta = minetest.get_meta(current_dead_player.bones_pos)
			current_dead_player.bones_inv = meta:get_inventory()
			--make it so big that anything reasonable will for sure fit inside
			current_dead_player.bones_inv:set_size("main", theoretical_max_slots)
		else
			current_dead_player.bones_mode = "drop"
			current_dead_player.bones_pos = nil
		end
	end

	if ( current_dead_player.bones_mode == "bones" ) and
			( current_dead_player.bones_inv:room_for_item("main", stk) ) then
		current_dead_player.bones_inv:add_item("main", stk)
	else
		drop(current_dead_player.player_pos, stk)
		current_dead_player.dropped=true
	end
end

local function player_dies_transfer_inventory(player,transfer_stack)
	local player_inv = player:get_inventory()
	for _, list_name in ipairs(player_inventory_lists) do
		for i = 1, player_inv:get_size(list_name) do
			local stack = player_inv:get_stack(list_name, i)
			transfer_stack(stack)
		end
		player_inv:set_list(list_name, {})
	end
end

bones.register_dead_player_inv_management(player_dies_transfer_inventory)

minetest.register_on_dieplayer(function(player)
	local pos = vector.round(player:get_pos())
	local bones_mode = minetest.settings:get("bones_mode") or "bones"
	if bones_mode ~= "bones" and bones_mode ~= "drop" and bones_mode ~= "keep" then
		bones_mode = "bones"
	end
	local player_name = player:get_player_name()
	local current_dead_player={player=player, player_name=player_name, bones_inv=nil, bones_pos=nil,
		bones_mode=bones_mode, player_pos=pos, dropped=false}

	local bones_position_message = minetest.settings:get_bool("bones_position_message") == true
	local pos_string = minetest.pos_to_string(pos)

	-- return if keep inventory set or in creative mode
	if bones_mode == "keep" or minetest.is_creative_enabled(player_name) then
		minetest.log("action", player_name .. " dies at " .. pos_string ..
			". No bones placed")
		if bones_position_message then
			minetest.chat_send_player(player_name, S("@1 died at @2.", player_name, pos_string))
		end
		return
	end

	local callback=function(stk)
		transfer_stack_to_bones(stk,current_dead_player)
	end

	for i=1,#dead_player_callbacks do
		local fun=dead_player_callbacks[i]
		fun(player,callback)
	end

	local bones_conclusion

	if not ( current_dead_player.bones_pos ) then
		drop(current_dead_player.player_pos, ItemStack("bones:bones"))
		if not ( current_dead_player.dropped ) then
			bones_conclusion="No bones placed"
			if bones_position_message then
				minetest.chat_send_player(player_name, S("@1 died at @2.", player_name, pos_string))
			end
		else
			bones_conclusion="Inventory dropped"
			if bones_position_message then
				minetest.chat_send_player(player_name, S("@1 died at @2, and dropped their inventory.", player_name, pos_string, public_conclusion))
			end
		end
	else
		if not ( current_dead_player.dropped ) then
			bones_conclusion="Bones placed"
			if bones_position_message then
				minetest.chat_send_player(player_name, S("@1 died at @2, and bones were placed.", player_name, pos_string, public_conclusion))
			end
		else
			bones_conclusion="Inventory partially dropped"
			if bones_position_message then
				minetest.chat_send_player(player_name, S("@1 died at @2, and partially dropped their inventory.", player_name, pos_string, public_conclusion))
			end
		end
	end

	minetest.log("action", player_name .. " dies at " .. pos_string ..
		". " .. bones_conclusion)

	local inv = current_dead_player.bones_inv
	local inv_size = theoretical_max_slots
	if inv then
		for i = 1, theoretical_max_slots do
			local stack = inv:get_stack("main", i)
			if stack:get_count() == 0 then
				inv_size = i - 1
				break
			end
		end
		local meta = minetest.get_meta(current_dead_player.bones_pos)
		meta:set_string("formspec", get_bones_formspec_for_size(inv_size))
		meta:set_string("owner", player_name)

		if share_bones_time ~= 0 then
			meta:set_string("infotext", S("@1's fresh bones", player_name))

			if share_bones_time_early == 0 or not minetest.is_protected(pos, player_name) then
				meta:set_int("time", 0)
			else
				meta:set_int("time", (share_bones_time - share_bones_time_early))
			end

			minetest.get_node_timer(pos):start(10)
		else
			meta:set_string("infotext", S("@1's bones", player_name))
		end
	end
end)
