-- minetest/creative/init.lua

creative = {}
local player_inventory = {}

-- Create detached creative inventory after loading all mods
creative.init_creative_inventory = function(player)
	local player_name = player:get_player_name()

	player_inventory[player_name] = {}
	player_inventory[player_name].size = 0
	player_inventory[player_name].filter = nil
	player_inventory[player_name].start_i = 1

	local inv = minetest.create_detached_inventory("creative_" .. player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if minetest.setting_getbool("creative_mode") then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if minetest.setting_getbool("creative_mode") then
				return -1
			else
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		end,
		on_put = function(inv, listname, index, stack, player)
		end,
		on_take = function(inv, listname, index, stack, player)
			--print(player:get_player_name().." takes item from creative inventory; listname="..dump(listname)..", index="..dump(index)..", stack="..dump(stack))
			if stack then
				minetest.log("action", player:get_player_name().." takes "..dump(stack:get_name()).." from creative inventory")
				--print("stack:get_name()="..dump(stack:get_name())..", stack:get_count()="..dump(stack:get_count()))
			end
		end,
	})

	creative.update_creative_inventory(player_name, nil, 2)
	--print("creative inventory size: "..dump(player_inventory[player_name].size))
end

local function tab_category(tab_id)
	local id_category = {
		nil, -- Reserved for crafting tab.
		minetest.registered_items,
		minetest.registered_nodes,
		minetest.registered_tools,
		minetest.registered_craftitems
	}

	-- If index out of range, show default ("All") page.
	return id_category[tab_id] or id_category[2]
end

function creative.update_creative_inventory(player_name, filter, tab_id)
	local creative_list = {}
	local inv = minetest.get_inventory({type = "detached", name = "creative_" .. player_name})

	for name, def in pairs(tab_category(tab_id)) do
		if not (def.groups.not_in_creative_inventory == 1) and
				def.description and def.description ~= "" and
				(not filter or def.name:find(filter, 1, true) or
					def.description:lower():find(filter, 1, true)) then
			creative_list[#creative_list+1] = name
		end
	end

	table.sort(creative_list)
	inv:set_size("main", #creative_list)
	inv:set_list("main", creative_list)
	player_inventory[player_name].size = #creative_list
end

-- Create the trash field
local trash = minetest.create_detached_inventory("creative_trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the creative inventory to restore the stack
	allow_put = function(inv, listname, index, stack, player)
		if minetest.setting_getbool("creative_mode") then
			return stack:get_count()
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		inv:set_stack(listname, index, "")
	end,
})
trash:set_size("main", 1)

creative.set_creative_formspec = function(player, start_i, pagenum, tab_id)
	local player_name = player:get_player_name()
	local filter = player_inventory[player_name].filter or ""
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((player_inventory[player_name].size - 1) / (3*8) + 1)
	tab_id = tab_id or 2

	player:set_inventory_formspec([[
		size[8,8.6]
		image[4.06,3.4;0.8,0.8;creative_trash_icon.png]
		list[current_player;main;0,4.7;8,1;]
		list[current_player;main;0,5.85;8,3;8]
		list[detached:creative_trash;main;4,3.3;1,1;]
		tablecolumns[color;text;color;text]
		tableoptions[background=#00000000;highlight=#00000000;border=false]
		button[5.4,3.2;0.8,0.9;creative_prev;<]
		button[7.25,3.2;0.8,0.9;creative_next;>]
		button[2.1,3.4;0.8,0.5;search;?]
		button[2.75,3.4;0.8,0.5;clear;X]
		tooltip[search;Search]
		tooltip[clear;Reset]
		listring[current_player;main]
		]] ..
		"field[0.3,3.5;2.2,1;filter;;".. filter .."]"..
		"listring[detached:creative_".. player_name ..";main]"..
		"tabheader[0,0;tabs;Crafting,All,Nodes,Tools,Items;".. tostring(tab_id) ..";true;false]"..
		"list[detached:creative_".. player_name ..";main;0,0;8,3;".. tostring(start_i) .."]"..
		"table[6.05,3.35;1.15,0.5;pagenum;#FFFF00,".. tostring(pagenum) ..",#FFFFFF,/ ".. tostring(pagemax) .."]"..
		default.get_hotbar_bg(0,4.7)..
		default.gui_bg .. default.gui_bg_img .. default.gui_slots
	)
end

creative.set_crafting_formspec = function(player)
	player:set_inventory_formspec([[
		size[8,8.6]
		list[current_player;craft;2,0.75;3,3;]
		list[current_player;craftpreview;6,1.75;1,1;]
		list[current_player;main;0,4.7;8,1;]
		list[current_player;main;0,5.85;8,3;8]
		list[detached:creative_trash;main;0,2.75;1,1;]
		image[0.06,2.85;0.8,0.8;creative_trash_icon.png]
		image[5,1.75;1,1;gui_furnace_arrow_bg.png^[transformR270]
		tabheader[0,0;tabs;Crafting,All,Nodes,Tools,Items;1;true;false]
		listring[current_player;main]
		listring[current_player;craft]
		]] ..
		default.get_hotbar_bg(0,4.7)..
		default.gui_bg .. default.gui_bg_img .. default.gui_slots
	)
end

minetest.register_on_joinplayer(function(player)
	-- If in creative mode, modify player's inventory forms
	if not minetest.setting_getbool("creative_mode") then
		return
	end
	creative.init_creative_inventory(player)
	creative.set_creative_formspec(player, 0, 1, 2)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not minetest.setting_getbool("creative_mode") then
		return
	end
	-- Figure out current page from formspec
	local player_name = player:get_player_name()
	local formspec = player:get_inventory_formspec()
	local filter = formspec:match("filter;;([%w_:]+)") or ""
	local start_i = formspec:match("list%[detached:creative_".. player_name ..";.*;(%d+)%]")
	local tab_id = tonumber(formspec:match("tabheader%[.*;(%d+)%;.*%]"))
	local inv_size = player_inventory[player_name].size
	start_i = tonumber(start_i) or 0

	if fields.quit then
		if tab_id == 1 then
			creative.set_crafting_formspec(player)
		end
	elseif fields.tabs then
		if tonumber(fields.tabs) == 1 then
			creative.set_crafting_formspec(player)
		else
			creative.update_creative_inventory(player_name, filter, tonumber(fields.tabs))
			creative.set_creative_formspec(player, 0, 1, tonumber(fields.tabs))
		end
	elseif fields.clear then
		player_inventory[player_name].filter = ""
		creative.update_creative_inventory(player_name, nil, tab_id)
		creative.set_creative_formspec(player, 0, 1, tab_id)
	elseif fields.search then
		player_inventory[player_name].filter = fields.filter:lower()
		creative.update_creative_inventory(player_name, fields.filter:lower(), tab_id)
		creative.set_creative_formspec(player, 0, 1, tab_id)
	else
		if fields.creative_prev then
			start_i = start_i - 3*8
			if start_i < 0 then
				start_i = inv_size - (inv_size % (3*8))
				if inv_size == start_i then
					start_i = math.max(0, inv_size - (3*8))
				end
			end
		elseif fields.creative_next then
			start_i = start_i + 3*8
			if start_i >= inv_size then
				start_i = 0
			end
		end

		creative.set_creative_formspec(player, start_i, start_i / (3*8) + 1, tab_id)
	end
end)

if minetest.setting_getbool("creative_mode") then
	local digtime = 0.5
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x=1, y=1, z=2.5},
		range = 10,
		tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level = 3,
			groupcaps = {
				crumbly = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				cracky = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				snappy = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				choppy = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
				oddly_breakable_by_hand = {times={[1]=digtime, [2]=digtime, [3]=digtime}, uses=0, maxlevel=3},
			},
			damage_groups = {fleshy = 10},
		}
	})

	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
		return true
	end)

	function minetest.handle_node_drops(pos, drops, digger)
		if not digger or not digger:is_player() then
			return
		end
		local inv = digger:get_inventory()
		if inv then
			for _, item in ipairs(drops) do
				item = ItemStack(item):get_name()
				if not inv:contains_item("main", item) then
					inv:add_item("main", item)
				end
			end
		end
	end
end
