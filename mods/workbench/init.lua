-- Workbench mod by MirceaKitsune

-- Inventory crafting grid size. Use nil to leave the default formspec untouched, recommended if other mods change the inventory window.
local INVENTORY_CRAFT = 2

--
-- Internal workbench functions:
--

local function move_items(s_inv, s_listname, d_inv, d_listname)
	local s_size = s_inv:get_size(s_listname)
	for i = 1, s_size do
		local stack = s_inv:get_stack(s_listname, i)
		if stack and not stack:is_empty() then
			d_inv:add_item(d_listname, stack)
		end
	end
	s_inv:set_list(s_listname, {})
end

local inventory_persistence = {}

local function inventory_set_size(player, size)
	size = math.min(6, math.max(1, size))
	local inv = player:get_inventory()
	if inv:get_size("craft") ~= size*size then
		move_items(inv, "craft", inv, "main")
		inv:set_size("craft", size*size)
		inv:set_width("craft", size)
	end
end

local function inventory_set_formspec(player, size)
	size = math.min(6, math.max(1, size))
	local inv = player:get_inventory()
	local msize_x = math.min(inv:get_size("main"), 8)
	local msize_y = math.min(math.ceil(inv:get_size("main") / 8), 4)
	local fsize_x = math.max(msize_x, size + 2)
	local fsize_y = msize_y + size + 1.25

	local formspec = "size["..fsize_x..","..fsize_y.."]"
	..default.gui_bg
	..default.gui_bg_img
	..default.gui_slots
	.."list[current_player;main;"..(fsize_x-msize_x)..","..(fsize_y-msize_y)..";"..msize_x..",1;]"
	.."list[current_player;main;"..(fsize_x-msize_x)..","..(fsize_y-msize_y+1.25)..";"..msize_x..","..(msize_y - 1)..";"..msize_x.."]"
	.."list[current_player;craft;"..(fsize_x-size-2)..",0;"..size..","..size..";]"
	.."list[current_player;craftpreview;"..(fsize_x-1)..","..(size/2-0.5)..";1,1;]"
	for i = 0, msize_x - 1, 1 do
		formspec = formspec.."image["..(fsize_x-msize_x + i)..","..(fsize_y-msize_y)..";1,1;gui_hb_bg.png]"
	end
	player:set_inventory_formspec(formspec)
end

local function inventory_set(player, size)
	local name = player:get_player_name()
	local inv = player:get_inventory()

	-- When size is a number, we want to presist inventory settings and activate the workbench settings
	-- When size is nil, we want to re-activate the persisted inventory settings
	if not size then
		inv:set_size("craft", inventory_persistence[name].craft_size)
		inv:set_width("craft", inventory_persistence[name].craft_width)
		player:set_inventory_formspec(inventory_persistence[name].formspec)
		inventory_persistence[name] = nil
	else
		inventory_persistence[name] = {}
		inventory_persistence[name].craft_size = inv:get_size("craft")
		inventory_persistence[name].craft_width = inv:get_width("craft")
		inventory_persistence[name].formspec = player:get_inventory_formspec()

		inventory_set_size(player, size)
		inventory_set_formspec(player, size)
	end
end

minetest.register_on_joinplayer(function(player)
	if minetest.setting_getbool("creative_mode") then
		inventory_set_size(player, 3)
	elseif INVENTORY_CRAFT then
		minetest.after(0, function()
			inventory_set_size(player, INVENTORY_CRAFT)
			inventory_set_formspec(player, INVENTORY_CRAFT)
		end)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "workbench:workbench" and fields.quit then
		inventory_set(player, _)
	end
end)

--
-- Item definitions:
--

minetest.register_node("workbench:3x3", {
	description = "WorkBench",
	tiles = {"workbench_3x3_top.png", "workbench_3x3_bottom.png", "workbench_3x3_side.png",
		"workbench_3x3_side.png", "workbench_3x3_side.png", "workbench_3x3_front.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Workbench")
	end,
	on_rightclick = function(pos, node, clicker)
		inventory_set(clicker, 3)
		minetest.show_formspec(clicker:get_player_name(), "workbench:workbench", clicker:get_inventory_formspec())
	end,
})

minetest.register_craft({
	output = 'workbench:3x3',
	recipe = {
		{'group:wood', 'group:wood', ''},
		{'group:wood', 'group:wood', ''},
		{'', '', ''},
	}
})
