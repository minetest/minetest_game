
--
-- Formspec
--

local function get_workbench_formspec(pos, error)
	local msg = "Rename Item"
	local text = minetest.get_meta(pos):get_string("text")

	if error then
		msg = minetest.colorize("red", error)
	end

	return
		"size[8,7]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"field[0.5,0.5;6.2,1;text;"..msg..";"..minetest.formspec_escape(text).."]" ..
		"button[6.5,0.2;1.5,1;rename;Rename]" ..
		"list[context;input;1.5,1.4;1,1;]" ..
		"image[2.5,1.4;1,1;gui_workbench_plus.png]" ..
		"image[3.5,1.4;1,1;default_nametag_slot.png]" ..
		"list[context;nametag;3.5,1.4;1,1;]" ..
		"image[4.5,1.4;1,1;gui_furnace_arrow_bg.png^[transformR270]" ..
		"list[context;output;5.5,1.4;1,1]" ..
		"list[current_player;main;0,2.85;8,1;]" ..
		"list[current_player;main;0,4.08;8,3;8]" ..
		"field_close_on_enter[text;false]" ..
		default.get_hotbar_bg(0,2.85)
end

local function get_item_desc(stack)
	if not stack:is_known() then
		return
	end

	local desc = stack:get_meta():get_string("description")
	if desc == "" then
		return minetest.registered_items[stack:get_name()].description
	end

	return desc
end

local function workbench_update_text(pos, stack)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", get_item_desc(stack))
	meta:set_string("formspec", get_workbench_formspec(pos))
end

local function workbench_update_help(pos, type, string)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", get_workbench_formspec(pos, string))
	meta:set_string("error", type)
end

--
-- Node definition
--

minetest.register_node("default:workbench", {
	description = "Workbench",
	tiles = {"default_workbench_top.png", "default_wood.png", "default_workbench_sides.png",
		"default_workbench_sides.png", "default_workbench_sides.png", "default_workbench_sides.png"},
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 3/16, -0.5, 0.5, 0.5, 0.5},
			{-7/16, -0.5, 1/4, -1/4, 0.5, 7/16},
			{-7/16, -0.5, -7/16, -1/4, 0.5, -1/4},
			{1/4, -0.5, 1/4, 7/16, 0.5, 7/16},
			{1/4, -0.5, -7/16, 7/16, 0.5, -1/4},
		}
	},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_workbench_formspec(pos))
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("nametag", 1)
		inv:set_size("output", 1)
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()

		if inv:is_empty("input") and inv:is_empty("nametag") and
				inv:is_empty("output") then
			return true
		else
			return false
		end
	end,
	on_blast = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()

		local drops = {
			inv:get_list("input")[1],
			inv:get_list("nametag")[1],
			inv:get_list("output")[1],
			"default:workbench",
		}
		minetest.remove_node(pos)
		return drops
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack)
		if not stack:is_known() then
			return 0
		end

		if listname == "nametag" then
			if stack:get_name() ~= "default:nametag" then
				return 0
			else
				return stack:get_count()
			end
		elseif listname == "output" then
			return 0
		elseif listname == "input" then
			if minetest.registered_items[stack:get_name()].groups.renameable == 0 then
				return 0
			end
		end

		return 1
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local stack = inv:get_stack(from_list, from_index)

		if to_list == "nametag" then
			if stack:get_name() ~= "default:nametag" then
				return 0
			end
		elseif to_list == "input" then
			if minetest.registered_items[stack:get_name()].groups.renameable == 0 then
				return 0
			end
		elseif to_list == "output" then
			return 0
		end

		return count
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local error = meta:get_string("error")

		if error == "input" and not inv:is_empty("input") then
			meta:set_string("formspec", get_workbench_formspec(pos))
		elseif error == "nametag" and not inv:is_empty("nametag") then
			meta:set_string("formspec", get_workbench_formspec(pos))
		end

		if listname == "input" then
			workbench_update_text(pos, stack)
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(to_list, to_index)

		if to_list == "input" then
			workbench_update_text(pos, stack)
		end
	end,
	on_metadata_inventory_take = function(pos, listname)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local error = meta:get_string("error")

		if error == "output" and inv:is_empty("output") then
			meta:set_string("formspec", get_workbench_formspec(pos))
		end

		if listname == "input" then
			meta:set_string("text", "")
			meta:set_string("formspec", get_workbench_formspec(pos))
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if fields.rename or fields.key_enter_field == "text" then
			meta:set_string("text", fields.text)

			if inv:is_empty("input") then
				workbench_update_help(pos, "input", "Missing input item!")
			elseif inv:is_empty("nametag") then
				workbench_update_help(pos, "nametag", "Missing nametag!")
			elseif not inv:is_empty("output") then
				workbench_update_help(pos, "output", "No room in output!")
			else
				local new_stack  = inv:get_stack("input", 1)

				if not new_stack:is_known() then
					workbench_update_help(pos, nil, "Cannot rename unknown item!")
					return
				end

				local item       = minetest.registered_items[new_stack:get_name()]
				local renameable = item.groups.renameable ~= 0

				if not renameable then
					workbench_update_help(pos, nil, "Item cannot be renamed!")
					return
				elseif fields.text == "" then
					workbench_update_help(pos, nil, "Description cannot be blank!")
					return
				elseif fields.text:len() > 500 then
					workbench_update_help(pos, nil, "Description too long (max 500 characters)!")
					return
				elseif fields.text == get_item_desc(inv:get_stack("input", 1)) then
					workbench_update_help(pos, nil, "Description not changed!")
				end

				new_stack:get_meta():set_string("description", fields.text)

				minetest.log("action", sender:get_player_name().." renames "
					..inv:get_stack("input", 1):get_name().." to "..fields.text)

				inv:remove_item("input", inv:get_stack("input", 1))
				inv:remove_item("nametag", inv:get_stack("nametag", 1):take_item(1))
				inv:set_stack("output", 1, new_stack)

				meta:set_string("text", "")
				workbench_update_help(pos)
			end
		end
	end,
})
