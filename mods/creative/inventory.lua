local player_inventory = {}

function creative.init_creative_inventory(player)
	local player_name = player:get_player_name()
	player_inventory[player_name] = {
		size = 0,
		filter = "",
		start_i = 0
	}

	return player_inventory[player_name]
end

function creative.update_creative_inventory(player_name, tab_content)
	local creative_list = {}
	local inv = player_inventory[player_name] or
		creative.init_creative_inventory(minetest.get_player_by_name(player_name))

	for name, def in pairs(tab_content) do
		if not (def.groups.not_in_creative_inventory == 1) and
		   def.description and def.description ~= ""	   and
		  (def.name:find(inv.filter, 1, true)		   or
		   def.description:lower():find(inv.filter, 1, true)) then
			creative_list[#creative_list+1] = name
		end
	end

	inv.size = #creative_list
	table.sort(creative_list)
	return creative_list
end

-- Create the trash field
local trash = minetest.create_detached_inventory("creative_trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the creative inventory to restore the stack
	allow_put = function(_, _, _, stack)
		return stack:get_count()
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)

creative.formspec_add = ""

function creative.register_tab(name, title, items)
	sfinv.register_page("creative:" .. name, {
		title = title,
		is_in_nav = function(self, player, context)
			return creative.is_enabled_for(player:get_player_name())
		end,

		get = function(self, player, context)
			local player_name = player:get_player_name()
			local inv = player_inventory[player_name] or
				creative.init_creative_inventory(
					minetest.get_player_by_name(player_name))

			local ipp = inv.expand and 3*8 or 6*8
			local start_i = inv.start_i or 0
			local pagenum = math.floor(start_i / ipp + 1)
			local inv_items = creative.update_creative_inventory(player_name, items)
			local pagemax = math.ceil(inv.size / ipp)
			local offset = inv.expand and 3 or 6

			local formspec =
				"label[6.2," .. offset .. ".35;" .. minetest.colorize("#FFFF00",
					tostring(pagenum)) .. " / " .. tostring(pagemax) .. "]" ..
				"image[4.06," .. offset .. ".4;0.8,0.8;creative_trash_icon.png]" ..
				"listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]" ..
				"list[current_player;main;0," .. (offset + 1) .. ".5;8,1;]" ..
				"list[detached:creative_trash;main;4," .. offset .. ".3;1,1;]" ..
				"listring[]" ..
				"button[5.4,"  .. offset .. ".2;0.8,0.9;creative_prev;<]" ..
				"button[7.25," .. offset .. ".2;0.8,0.9;creative_next;>]" ..
				"button[2.1,"  .. offset .. ".4;0.8,0.5;creative_search;?]" ..
				"button[2.75," .. offset .. ".4;0.8,0.5;creative_clear;X]" ..
				"image_button[3.78,8.55;0.45,0.4;creative_" ..
					(inv.expand and "less" or "more") ..
					".png;creative_" ..
					(inv.expand and "less" or "more") ..
					";;true;false;]" ..
				"tooltip[creative_search;Search]" ..
				"tooltip[creative_clear;Reset]" ..
				"listring[current_player;main]" ..
				"field_close_on_enter[creative_filter;false]" ..
				"field[0.25," .. offset .. ".5;2.25,1;creative_filter;;" ..
					minetest.formspec_escape(inv.filter) .. "]" ..
				default.get_hotbar_bg(0, (inv.expand and 4.5 or 7.5)) ..
				default.gui_bg .. default.gui_bg_img .. default.gui_slots ..
				creative.formspec_add

			if inv.expand then
				formspec = formspec ..
					"list[current_player;main;0,5.55;8,3;8]"
			end

			local first_item = (pagenum - 1) * ipp
			for i = first_item, first_item + ipp - 1 do
				local item_name = inv_items[i + 1]
				if not item_name then break end
				local X = i % 8
				local Y = (i % ipp - X) / 8 + 1

				formspec = formspec ..
					"item_image_button[" .. (X - 0.05) .. "," .. (Y - 1) ..
						";1.1,1.1;" .. item_name .. ";" .. item_name .. "_inv;]"
			end

			return sfinv.make_formspec(player, context, formspec, false)
		end,

		on_enter = function(self, player, context)
			local player_name = player:get_player_name()
			local inv = player_inventory[player_name]
			if inv then
				inv.start_i = 0
			end
		end,

		on_player_receive_fields = function(self, player, context, fields)
			local player_name = player:get_player_name()
			local inv = player_inventory[player_name]
			assert(inv)

			if fields.creative_clear then
				inv.start_i = 0
				inv.filter = ""
				creative.update_creative_inventory(player_name, items)
				sfinv.set_player_inventory_formspec(player, context)

			elseif fields.creative_search or
					fields.key_enter_field == "creative_filter" then
				inv.start_i = 0
				inv.filter = fields.creative_filter:lower()
				creative.update_creative_inventory(player_name, items)
				sfinv.set_player_inventory_formspec(player, context)

			elseif fields.creative_more or fields.creative_less then
				inv.expand = fields.creative_more and true or false
				sfinv.set_player_inventory_formspec(player, context)

			elseif fields.creative_prev or fields.creative_next then
				local start_i = inv.start_i or 0
				local ipp = inv.expand and 3*8 or 6*8

				if fields.creative_prev then
					start_i = start_i - ipp
					if start_i < 0 then
						start_i = inv.size - (inv.size % ipp)
						if inv.size == start_i then
							start_i = math.max(0, inv.size - ipp)
						end
					end
				elseif fields.creative_next then
					start_i = start_i + ipp
					if start_i >= inv.size then
						start_i = 0
					end
				end

				inv.start_i = start_i
				sfinv.set_player_inventory_formspec(player, context)

			else for item in pairs(fields) do
				  if item:find(":") then
					local can_add = false
					local player_inv = player:get_inventory()

					for i = 1, 8 do
						if player_inv:get_stack("main", i):is_empty() then
							can_add = true
							break
						end
					end

					if can_add or inv.expand then
						if item:sub(-4) == "_inv" then
							item = item:sub(1,-5)
						end

						local stack = ItemStack(item)
						player_inv:add_item("main",
							item .. " " .. stack:get_stack_max())
					end
				  end
			     end
			end
		end
	})
end

minetest.register_on_joinplayer(function(player)
	creative.update_creative_inventory(
		player:get_player_name(), minetest.registered_items)
end)

creative.register_tab("all", "All", minetest.registered_items)
creative.register_tab("nodes", "Nodes", minetest.registered_nodes)
creative.register_tab("tools", "Tools", minetest.registered_tools)
creative.register_tab("craftitems", "Items", minetest.registered_craftitems)

local old_homepage_name = sfinv.get_homepage_name
function sfinv.get_homepage_name(player)
	if creative.is_enabled_for(player:get_player_name()) then
		return "creative:all"
	else
		return old_homepage_name(player)
	end
end
