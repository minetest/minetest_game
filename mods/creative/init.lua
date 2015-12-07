-- minetest/creative/init.lua

creative_inventory = {}

-- Create detached creative inventory after loading all mods
creative_inventory.init_creative_inventory = function(player)
	local player_name = player:get_player_name()
	creative_inventory[player_name] = {}
	creative_inventory[player_name].size = 0
	creative_inventory[player_name].filter = nil
	creative_inventory[player_name].start_i = 1

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

	creative_inventory.update(player_name, nil)
	--print("creative inventory size: "..dump(creative_inventory.creative_inventory_size))
end

function creative_inventory.update(player_name, filter)
	local creative_list = {}
	local inv = minetest.get_inventory({type = "detached", name = "creative_" .. player_name})

	for name, def in pairs(minetest.registered_items) do
		if not (def.groups.not_in_creative_inventory == 1) and
				def.description and def.description ~= "" then
			if (filter and def.name:find(filter, 1, true)) or not filter then
				creative_list[#creative_list+1] = name
			end
		end
	end

	table.sort(creative_list)
	inv:set_size("main", #creative_list)
	inv:set_list("main", creative_list)
	creative_inventory[player_name].size = #creative_list
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

creative_inventory.set_creative_formspec = function(player, start_i, pagenum)
	local player_name = player:get_player_name()
	local filter = creative_inventory[player_name].filter or ""
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((creative_inventory[player_name].size - 1) / (6*4) + 1)

	player:set_inventory_formspec(
			"size[13,7.5]"..
			--"image[6,0.6;1,2;player.png]"..
			default.gui_bg..
			default.gui_bg_img..
			default.gui_slots..
			"list[current_player;main;5,3.5;8,1;]"..
			"list[current_player;main;5,4.75;8,3;8]"..
			"list[current_player;craft;8,0;3,3;]"..
			"list[current_player;craftpreview;12,1;1,1;]"..
			"image[11,1;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"list[detached:creative_" .. player_name .. ";main;0.05,1;4,6;" .. tostring(start_i) .. "]"..
			"tablecolumns[color;text;color;text]"..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]"..
			"table[1.4,7.2;1.1,0.5;pagenum;#FFFF00," .. tostring(pagenum) .. ",#FFFFFF,/ " .. tostring(pagemax) .. "]"..
			"button[0,7;1,1;creative_prev;<<]"..
			"button[3.08,7;1,1;creative_next;>>]"..
			"button[2.55,0.2;0.8,0.5;search;?]"..
			"button[3.3,0.2;0.8,0.5;clear;X]"..
			"tooltip[search;Search]"..
			"tooltip[clear;Reset]"..
			"listring[current_player;main]"..
			"listring[current_player;craft]"..
			"listring[current_player;main]"..
			"listring[detached:creative_" .. player_name .. ";main]"..
			"label[5,1.5;Trash:]"..
			"list[detached:creative_trash;main;5,2;1,1;]"..
			"field[0.3,0.3;2.6,1;filter;;" .. filter .. "]"..
			default.get_hotbar_bg(5,3.5)
	)
end

minetest.register_on_joinplayer(function(player)
	-- If in creative mode, modify player's inventory forms
	if not minetest.setting_getbool("creative_mode") then
		return
	end
	creative_inventory.init_creative_inventory(player)
	creative_inventory.set_creative_formspec(player, 0, 1)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not minetest.setting_getbool("creative_mode") then
		return
	end
	-- Figure out current page from formspec
	local current_page = 0
	local player_name = player:get_player_name()
	local formspec = player:get_inventory_formspec()
	local start_i = formspec:match("list%[detached:creative_" .. player_name .. ";main;[%d.]+,[%d.]+;[%d.]+,[%d.]+;(%d+)%]")
	start_i = tonumber(start_i) or 0

	if fields.creative_prev or start_i >= creative_inventory[player_name].size then
		start_i = start_i - 4*6
	elseif fields.creative_next or start_i < 0 then
		start_i = start_i + 4*6
	end

	if fields.search or fields.clear then
		if fields.clear then
			creative_inventory[player_name].filter = ""
			creative_inventory.update(player_name, nil)
		else
			creative_inventory[player_name].filter = fields.filter:lower()
			creative_inventory.update(player_name, fields.filter:lower())
		end
		minetest.after(0, function()
			creative_inventory.set_creative_formspec(player, 0, 1)
		end)
	end
	
	if start_i < 0 or start_i >= creative_inventory[player_name].size then
		start_i = 0
	end

	creative_inventory.set_creative_formspec(player, start_i, start_i / (6*4) + 1)
end)

if minetest.setting_getbool("creative_mode") then
	local digtime = 0.5
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x=1,y=1,z=2.5},
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
