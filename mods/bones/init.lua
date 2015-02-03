-- Minetest 0.4 mod: bones
-- See README.txt for licensing and other information. 

bones = {}

local function is_owner(pos, name)
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name then
		return true
	end
	return false
end

bones.bones_formspec =
	"size[8,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[current_name;main;0,0.3;8,4;]"..
	"list[current_player;main;0,4.85;8,1;]"..
	"list[current_player;main;0,6.08;8,3;8]"..
	default.get_hotbar_bg(0,4.85)

local share_bones_time = tonumber(minetest.setting_get("share_bones_time") or 1200)
local share_bones_time_early = tonumber(minetest.setting_get("share_bones_time_early") or (share_bones_time/4))

minetest.register_node("bones:bones", {
	description = "Bones",
	tiles = {
		"bones_top.png",
		"bones_bottom.png",
		"bones_side.png",
		"bones_side.png",
		"bones_rear.png",
		"bones_front.png"
	},
	paramtype2 = "facedir",
	groups = {dig_immediate=2},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.5},
		dug = {name="default_gravel_footstep", gain=1.0},
	}),
	
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return is_owner(pos, player:get_player_name()) and inv:is_empty("main")
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
			minetest.remove_node(pos)
		end
	end,
	
	on_punch = function(pos, node, player)
		if(not is_owner(pos, player:get_player_name())) then
			return
		end
		
		if(minetest.get_meta(pos):get_string("infotext") == "") then
			return
		end
		
		local inv = minetest.get_meta(pos):get_inventory()
		local player_inv = player:get_inventory()
		local has_space = true
		
		for i=1,inv:get_size("main") do
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
			meta:set_string("infotext", meta:get_string("owner").."'s old bones")
			meta:set_string("owner", "")
		else
			meta:set_int("time", time)
			return true
		end
	end,
})

local function may_replace(pos, player)
	local node_name = minetest.get_node(pos).name
	local node_definition = minetest.registered_nodes[node_name]

	-- if the node is unknown, we let the protection mod decide
	-- this is consistent with when a player could dig or not dig it
	-- unknown decoration would often be removed
	-- while unknown building materials in use would usually be left
	if not node_definition then
		-- only replace nodes that are not protected
		return not minetest.is_protected(pos, player:get_player_name())
	end

	-- allow replacing air and liquids
	if node_name == "air" or node_definition.liquidtype ~= "none" then
		return true
	end

	-- don't replace filled chests and other nodes that don't allow it
	local can_dig_func = node_definition.can_dig
	if can_dig_func and not can_dig_func(pos, player) then
		return false
	end

	-- default to each nodes buildable_to; if a placed block would replace it, why shouldn't bones?
	-- flowers being squished by bones are more realistical than a squished stone, too
	-- exception are of course any protected buildable_to
	return node_definition.buildable_to and not minetest.is_protected(pos, player:get_player_name())
end

minetest.register_on_dieplayer(function(player)
	if minetest.setting_getbool("creative_mode") then
		return
	end
	
	local player_inv = player:get_inventory()
	if player_inv:is_empty("main") and
		player_inv:is_empty("craft") then
		return
	end

	local pos = player:getpos()
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)
	local param2 = minetest.dir_to_facedir(player:get_look_dir())
	local player_name = player:get_player_name()
	local player_inv = player:get_inventory()

	if (not may_replace(pos, player)) then
		if (may_replace({x=pos.x, y=pos.y+1, z=pos.z}, player)) then
			-- drop one node above if there's space
			-- this should solve most cases of protection related deaths in which players dig straight down
			-- yet keeps the bones reachable
			pos.y = pos.y+1
		else
			-- drop items instead of delete
			for i=1,player_inv:get_size("main") do
				minetest.add_item(pos, player_inv:get_stack("main", i))
			end
			for i=1,player_inv:get_size("craft") do
				minetest.add_item(pos, player_inv:get_stack("craft", i))
			end
			-- empty lists main and craft
			player_inv:set_list("main", {})
			player_inv:set_list("craft", {})
			return
		end
	end
	
	minetest.set_node(pos, {name="bones:bones", param2=param2})
	
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("main", 8*4)
	inv:set_list("main", player_inv:get_list("main"))
	
	for i=1,player_inv:get_size("craft") do
		local stack = player_inv:get_stack("craft", i)
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
		else
			--drop if no space left
			minetest.add_item(pos, stack)
		end
	end
	
	player_inv:set_list("main", {})
	player_inv:set_list("craft", {})
	
	meta:set_string("formspec", bones.bones_formspec)
	meta:set_string("owner", player_name)
	
	if share_bones_time ~= 0 then
		meta:set_string("infotext", player_name.."'s fresh bones")

		if share_bones_time_early == 0 or not minetest.is_protected(pos, player_name) then
			meta:set_int("time", 0)
		else
			meta:set_int("time", (share_bones_time - share_bones_time_early))
		end

		minetest.get_node_timer(pos):start(10)
	else
		meta:set_string("infotext", player_name.."'s bones")
	end
end)
