-- minetest/creative/init.lua

creative = {}
local player_inventory = {}
local creative_mode = minetest.setting_getbool("creative_mode")

-- Create detached creative inventory after loading all mods
creative.init_creative_inventory = function(owner)
	local owner_name = owner:get_player_name()
	player_inventory[owner_name] = {
		size = 0,
		filter = "",
		start_i = 1,
		tab_id = 2,
	}

	minetest.create_detached_inventory("creative_" .. owner_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if creative_mode and not to_list == "main" then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if creative_mode then
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
			local player_name, stack_name = player:get_player_name(), stack:get_name()
			--print(player_name .. " takes item from creative inventory; listname = " .. listname .. ", index = " .. index .. ", stack = " .. dump(stack:to_table()))
			if stack then
				minetest.log("action", player_name .. " takes " .. stack_name .. " from creative inventory")
				--print("Stack name: " .. stack_name .. ", Stack count: " .. stack:get_count())
			end
		end,
	})

	creative.update_creative_inventory(owner_name)
	--print("creative inventory size: " .. player_inventory[player_name].size)
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

function creative.update_creative_inventory(player_name)
	local creative_list = {}
	local player_inv = minetest.get_inventory({type = "detached", name = "creative_" .. player_name})
	local inv = player_inventory[player_name]

	for name, def in pairs(tab_category(inv.tab_id)) do
		if not (def.groups.not_in_creative_inventory == 1) and
				def.description and def.description ~= "" and
				(def.name:find(inv.filter, 1, true) or
					def.description:lower():find(inv.filter, 1, true)) then
			creative_list[#creative_list+1] = name
		end
	end

	table.sort(creative_list)
	player_inv:set_size("main", #creative_list)
	player_inv:set_list("main", creative_list)
	inv.size = #creative_list
end

-- Create the trash field
local trash = minetest.create_detached_inventory("creative_trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the creative inventory to restore the stack
	allow_put = function(inv, listname, index, stack, player)
		if creative_mode then
			return stack:get_count()
		else
			return 0
		end
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)

creative.formspec_add = ""

creative.set_creative_formspec = function(player, start_i)
	local player_name = player:get_player_name()
	local inv = player_inventory[player_name]
	local pagenum = math.floor(start_i / (3*8) + 1)
	local pagemax = math.ceil(inv.size / (3*8))

	player:set_inventory_formspec([[
		size[8,8.6]
		image[4.06,3.4;0.8,0.8;creative_trash_icon.png]
		list[current_player;main;0,4.7;8,1;]
		list[current_player;main;0,5.85;8,3;8]
		list[detached:creative_trash;main;4,3.3;1,1;]
		listring[]
		tablecolumns[color;text;color;text]
		tableoptions[background=#00000000;highlight=#00000000;border=false]
		button[5.4,3.2;0.8,0.9;creative_prev;<]
		button[7.25,3.2;0.8,0.9;creative_next;>]
		button[2.1,3.4;0.8,0.5;creative_search;?]
		button[2.75,3.4;0.8,0.5;creative_clear;X]
		tooltip[creative_search;Search]
		tooltip[creative_clear;Reset]
		listring[current_player;main]
		]] ..
		"field[0.3,3.5;2.2,1;creative_filter;;" .. minetest.formspec_escape(inv.filter) .. "]" ..
		"listring[detached:creative_" .. player_name .. ";main]" ..
		"tabheader[0,0;creative_tabs;Crafting,All,Nodes,Tools,Items;" .. tostring(inv.tab_id) .. ";true;false]" ..
		"list[detached:creative_" .. player_name .. ";main;0,0;8,3;" .. tostring(start_i) .. "]" ..
		"table[6.05,3.35;1.15,0.5;pagenum;#FFFF00," .. tostring(pagenum) .. ",#FFFFFF,/ " .. tostring(pagemax) .. "]" ..
		default.get_hotbar_bg(0,4.7) ..
		default.gui_bg .. default.gui_bg_img .. default.gui_slots
		.. creative.formspec_add
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
		tabheader[0,0;creative_tabs;Crafting,All,Nodes,Tools,Items;1;true;false]
		listring[current_player;main]
		listring[current_player;craft]
		]] ..
		default.get_hotbar_bg(0,4.7) ..
		default.gui_bg .. default.gui_bg_img .. default.gui_slots
	)
end

minetest.register_on_joinplayer(function(player)
	-- If in creative mode, modify player's inventory forms
	if not creative_mode then
		return
	end
	creative.init_creative_inventory(player)
	creative.set_creative_formspec(player, 0)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" or not creative_mode then
		return
	end

	local player_name = player:get_player_name()
	local inv = player_inventory[player_name]

	if fields.quit then
		if inv.tab_id == 1 then
			creative.set_crafting_formspec(player)
		end
	elseif fields.creative_tabs then
		local tab = tonumber(fields.creative_tabs)
		inv.tab_id = tab
		player_inventory[player_name].start_i = 1

		if tab == 1 then
			creative.set_crafting_formspec(player)
		else
			creative.update_creative_inventory(player_name)
			creative.set_creative_formspec(player, 0)
		end
	elseif fields.creative_clear then
		player_inventory[player_name].start_i = 1
		inv.filter = ""
		creative.update_creative_inventory(player_name)
		creative.set_creative_formspec(player, 0)
	elseif fields.creative_search then
		player_inventory[player_name].start_i = 1
		inv.filter = fields.creative_filter:lower()
		creative.update_creative_inventory(player_name)
		creative.set_creative_formspec(player, 0)
	else
		local start_i = player_inventory[player_name].start_i or 0

		if fields.creative_prev then
			start_i = start_i - 3*8
			if start_i < 0 then
				start_i = inv.size - (inv.size % (3*8))
				if inv.size == start_i then
					start_i = math.max(0, inv.size - (3*8))
				end
			end
		elseif fields.creative_next then
			start_i = start_i + 3*8
			if start_i >= inv.size then
				start_i = 0
			end
		end

		player_inventory[player_name].start_i = start_i
		creative.set_creative_formspec(player, start_i)
	end
end)

if creative_mode then
	local digtime = 42
	local caps = {times = {digtime, digtime, digtime}, uses = 0, maxlevel = 256}

	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x = 1, y = 1, z = 2.5},
		range = 10,
		tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level = 3,
			groupcaps = {
				crumbly = caps,
				cracky  = caps,
				snappy  = caps,
				choppy  = caps,
				oddly_breakable_by_hand = caps,
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
