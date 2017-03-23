local S, NS = dofile(minetest.get_modpath(minetest.get_current_modname()).."/intllib.lua")

-- mods/default/craftitems.lua

minetest.register_craftitem("default:stick", {
	description = S("Stick"),
	inventory_image = "default_stick.png",
	groups = {stick = 1, flammable = 2},
})

minetest.register_craftitem("default:paper", {
	description = S("Paper"),
	inventory_image = "default_paper.png",
	groups = {flammable = 3},
})

local lpp = 14 -- Lines per book's page
local function book_on_use(itemstack, user)
	local player_name = user:get_player_name()
	local meta = itemstack:get_meta()
	local title, text, owner = "", "", player_name
	local page, page_max, lines, string = 1, 1, {}, ""

	-- Backwards compatibility
	local old_data = minetest.deserialize(itemstack:get_metadata())
	if old_data then
		meta:from_table({ fields = old_data })
	end

	local data = meta:to_table().fields

	if data.owner then
		title = data.title
		text = data.text
		owner = data.owner

		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			lines[#lines+1] = str
		end

		if data.page then
			page = data.page
			page_max = data.page_max

			for i = ((lpp * page) - lpp) + 1, lpp * page do
				if not lines[i] then break end
				string = string .. lines[i] .. "\n"
			end
		end
	end

	local formspec
	if owner == player_name then
		formspec = "size[8,8]" .. default.gui_bg ..
			default.gui_bg_img ..
			"field[0.5,1;7.5,0;title;Title:;" ..
				minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;text;Contents:;" ..
				minetest.formspec_escape(text) .. "]" ..
			"button_exit[2.5,7.5;3,1;save;Save]"
	else
		formspec = "size[8,8]" .. default.gui_bg ..
			default.gui_bg_img ..
			"label[0.5,0.5;by " .. owner .. "]" ..
			"tablecolumns[color;text]" ..
			"tableoptions[background=#00000000;highlight=#00000000;border=false]" ..
			"table[0.4,0;7,0.5;title;#FFFF00," .. minetest.formspec_escape(title) .. "]" ..
			"textarea[0.5,1.5;7.5,7;;" ..
				minetest.formspec_escape(string ~= "" and string or text) .. ";]" ..
			"button[2.4,7.6;0.8,0.8;book_prev;<]" ..
			"label[3.2,7.7;Page " .. page .. " of " .. page_max .. "]" ..
			"button[4.9,7.6;0.8,0.8;book_next;>]"
	end

	minetest.show_formspec(player_name, "default:book", formspec)
	return itemstack
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "default:book" then return end
	local inv = player:get_inventory()
	local stack = player:get_wielded_item()

	if fields.save and fields.title ~= "" and fields.text ~= "" then
		local new_stack, data
		if stack:get_name() ~= "default:book_written" then
			local count = stack:get_count()
			if count == 1 then
				stack:set_name("default:book_written")
			else
				stack:set_count(count - 1)
				new_stack = ItemStack("default:book_written")
			end
		else
			data = stack:get_meta():to_table().fields
		end

		if not data then data = {} end
		data.title = fields.title
		data.owner = player:get_player_name()
		data.description = "\""..fields.title.."\" by "..data.owner
		data.text = fields.text
		data.text_len = #data.text
		data.page = 1
		data.page_max = math.ceil((#data.text:gsub("[^\n]", "") + 1) / lpp)

		if new_stack then
			new_stack:get_meta():from_table({ fields = data })
			if inv:room_for_item("main", new_stack) then
				inv:add_item("main", new_stack)
			else
				minetest.add_item(player:getpos(), new_stack)
			end
		else
			stack:get_meta():from_table({ fields = data })
		end

	elseif fields.book_next or fields.book_prev then
		local data = stack:get_meta():to_table().fields
		if not data or not data.page then
			return
		end

		data.page = tonumber(data.page)
		data.page_max = tonumber(data.page_max)

		if fields.book_next then
			data.page = data.page + 1
			if data.page > data.page_max then
				data.page = 1
			end
		else
			data.page = data.page - 1
			if data.page == 0 then
				data.page = data.page_max
			end
		end

		stack:get_meta():from_table(data)
		stack = book_on_use(stack, player)
	end

	-- Update stack
	player:set_wielded_item(stack)
end)

minetest.register_craftitem("default:book", {
	description = S("Book"),
	inventory_image = "default_book.png",
	groups = {book = 1, flammable = 3},
	on_use = book_on_use,
})

minetest.register_craftitem("default:book_written", {
	description = S("Book With Text"),
	inventory_image = "default_book_written.png",
	groups = {book = 1, not_in_creative_inventory = 1, flammable = 3},
	stack_max = 1,
	on_use = book_on_use,
})

minetest.register_craft({
	type = "shapeless",
	output = "default:book_written",
	recipe = {"default:book", "default:book_written"}
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "default:book_written" then
		return
	end

	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		if old_craft_grid[i]:get_name() == "default:book_written" then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end
	local copymeta = original:get_meta():to_table()
	-- copy of the book held by player's mouse cursor
	itemstack:get_meta():from_table(copymeta)
	-- put the book with metadata back in the craft grid
	craft_inv:set_stack("craft", index, original)
end)

minetest.register_craftitem("default:coal_lump", {
	description = S("Coal Lump"),
	inventory_image = "default_coal_lump.png",
	groups = {coal = 1, flammable = 1}
})

minetest.register_craftitem("default:iron_lump", {
	description = S("Iron Lump"),
	inventory_image = "default_iron_lump.png",
})

minetest.register_craftitem("default:copper_lump", {
	description = S("Copper Lump"),
	inventory_image = "default_copper_lump.png",
})

minetest.register_craftitem("default:mese_crystal", {
	description = S("Mese Crystal"),
	inventory_image = "default_mese_crystal.png",
})

minetest.register_craftitem("default:gold_lump", {
	description = S("Gold Lump"),
	inventory_image = "default_gold_lump.png",
})

minetest.register_craftitem("default:diamond", {
	description = S("Diamond"),
	inventory_image = "default_diamond.png",
})

minetest.register_craftitem("default:clay_lump", {
	description = S("Clay Lump"),
	inventory_image = "default_clay_lump.png",
})

minetest.register_craftitem("default:steel_ingot", {
	description = S("Steel Ingot"),
	inventory_image = "default_steel_ingot.png",
})

minetest.register_craftitem("default:copper_ingot", {
	description = S("Copper Ingot"),
	inventory_image = "default_copper_ingot.png",
})

minetest.register_craftitem("default:bronze_ingot", {
	description = S("Bronze Ingot"),
	inventory_image = "default_bronze_ingot.png",
})

minetest.register_craftitem("default:gold_ingot", {
	description = S("Gold Ingot"),
	inventory_image = "default_gold_ingot.png"
})

minetest.register_craftitem("default:mese_crystal_fragment", {
	description = S("Mese Crystal Fragment"),
	inventory_image = "default_mese_crystal_fragment.png",
})

minetest.register_craftitem("default:clay_brick", {
	description = S("Clay Brick"),
	inventory_image = "default_clay_brick.png",
})

minetest.register_craftitem("default:obsidian_shard", {
	description = S("Obsidian Shard"),
	inventory_image = "default_obsidian_shard.png",
})

minetest.register_craftitem("default:flint", {
	description = S("Flint"),
	inventory_image = "default_flint.png"
})
