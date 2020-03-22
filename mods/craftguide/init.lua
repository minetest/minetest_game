local player_data = {}
local init_items = {}
local recipes_cache = {}
local usages_cache = {}

local group_stereotypes = {
	dye = "dye:white",
	wool = "wool:white",
	coal = "default:coal_lump",
	vessel = "vessels:glass_bottle",
	flower = "flowers:dandelion_yellow"
}

local function table_replace(t, val, new)
	for k, v in pairs(t) do
		if v == val then
			t[k] = new
		end
	end
end

local function item_in_recipe(item, recipe)
	for _, recipe_item in pairs(recipe.items) do
		if recipe_item == item then
			return true
		end
	end
	return false
end

local function extract_groups(str)
	if str:sub(1, 6) == "group:" then
		return str:sub(7):split()
	end
end

local function item_has_groups(item_groups, groups)
	for _, group in ipairs(groups) do
		if not item_groups[group] then
			return false
		end
	end
	return true
end

-- If item can be used in recipe because recipe takes a `group:` item that item
-- matches, return a copy of recipe with the `group:` item replaced with item.
local function groups_item_in_recipe(item, recipe)
	local item_groups = minetest.registered_items[item].groups

	for _, recipe_item in pairs(recipe.items) do
		local groups = extract_groups(recipe_item)
		if groups and item_has_groups(item_groups, groups) then
			local usage = table.copy(recipe)
			table_replace(usage.items, recipe_item, item)
			return usage
		end
	end
end

local function get_usages(item)
	local usages = {}

	for _, recipes in pairs(recipes_cache) do
		for _, recipe in ipairs(recipes) do
			if item_in_recipe(item, recipe) then
				table.insert(usages, recipe)
			else
				recipe = groups_item_in_recipe(item, recipe)
				if recipe then
					table.insert(usages, recipe)
				end
			end
		end
	end

	return #usages > 0 and usages
end

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_items) do
		if def.groups.not_in_craft_guide ~= 1 and def.description ~= "" then
			recipes_cache[name] = minetest.get_all_craft_recipes(name)
		end
	end
	for name, def in pairs(minetest.registered_items) do
		if def.groups.not_in_craft_guide ~= 1 and def.description ~= "" then
			usages_cache[name] = get_usages(name)
			if recipes_cache[name] or usages_cache[name] then
				table.insert(init_items, name)
			end
		end
	end
	table.sort(init_items)
end)

local function groups_to_item(groups)
	if #groups == 1 then
		local group = groups[1]
		if group_stereotypes[group] then
			return group_stereotypes[group]
		elseif minetest.registered_items["default:"..group] then
			return "default:"..group
		end
	end

	for name, def in pairs(minetest.registered_items) do
		if item_has_groups(def.groups, groups) then
			return name
		end
	end

	return ":unknown"
end

local function is_fuel(item)
	return minetest.get_craft_result({
		method = "fuel",
		width = 1,
		items = {item}
	}).time > 0
end

local function item_button_fs(fs, x, y, item, element_name, groups)
	table.insert(fs, ("item_image_button[%s,%s;1.05,1.05;%s;%s;%s]")
		:format(x, y, item, element_name, groups and "\nG" or ""))

	local tooltip
	if groups then
		local groupstr = {}
		for _, group in ipairs(groups) do
			table.insert(groupstr, minetest.colorize("yellow", group))
		end
		groupstr = table.concat(groupstr, ", ")
		tooltip = "Any item belonging to the group(s): "..groupstr
	elseif is_fuel(item) then
		local itemdef = minetest.registered_items[item]
		local desc = itemdef and itemdef.description or "Unknown Item"
		tooltip = desc.."\n"..minetest.colorize("orange", "Fuel")
	end
	if tooltip then
		table.insert(fs, ("tooltip[%s;%s]"):format(element_name, tooltip))
	end
end

local function recipe_fs(fs, data)
	local recipe = data.recipes[data.rnum]
	local width = recipe.width
	local cooktime, shapeless

	if recipe.method == "cooking" then
		cooktime, width = width, 1
	elseif width == 0 then
		shapeless = true
		width = #recipe.items <= 4 and 2 or math.min(3, #recipe.items)
	end

	table.insert(fs, ("label[5.5,6.6;%s %d of %d]")
		:format(data.show_usages and "Usage" or "Recipe", data.rnum, #data.recipes))

	if #data.recipes > 1 then
		table.insert(fs,
			"image_button[5.5,7.2;0.8,0.8;craftguide_prev_icon.png;recipe_prev;]"..
			"image_button[6.2,7.2;0.8,0.8;craftguide_next_icon.png;recipe_next;]"..
			"tooltip[recipe_prev;Previous recipe]"..
			"tooltip[recipe_next;Next recipe]")
	end

	local rows = math.ceil(table.maxn(recipe.items) / width)
	if width > 3 or rows > 3 then
		table.insert(fs, "label[0,6.6;Recipe is too big to be displayed.]")
		return
	end

	for i, item in pairs(recipe.items) do
		local x = (i - 1) % width + 3 - width
		local y = math.ceil(i / width + 6 - math.min(2, rows)) + 0.6

		local groups = extract_groups(item)
		if groups then
			item = groups_to_item(groups)
		end
		item_button_fs(fs, x, y, item, item, groups)
	end

	if shapeless or recipe.method == "cooking" then
		table.insert(fs, ("image[3.2,6.1;0.5,0.5;craftguide_%s.png]")
			:format(shapeless and "shapeless" or "furnace"))
		local tooltip = shapeless and "Shapeless" or
			"Cooking time: "..minetest.colorize("yellow", cooktime)
		table.insert(fs, "tooltip[3.2,6.1;0.5,0.5;"..tooltip.."]")
	end
	table.insert(fs, "image[3,6.6;1,1;sfinv_crafting_arrow.png]")

	item_button_fs(fs, 4, 6.6, recipe.output, recipe.output:match("%S*"))
end

local function get_formspec(player)
	local name = player:get_player_name()
	local data = player_data[name]
	data.pagemax = math.max(1, math.ceil(#data.items / 32))

	local fs = {}
	table.insert(fs, ("field[0.3,4.2;2.8,1.2;filter;;%s]")
		:format(minetest.formspec_escape(data.filter)))
	table.insert(fs, ("label[5.8,4.15;%s / %d]")
		:format(minetest.colorize("yellow", data.pagenum), data.pagemax))
	table.insert(fs,
		"image_button[2.63,4.05;0.8,0.8;craftguide_search_icon.png;search;]"..
		"image_button[3.25,4.05;0.8,0.8;craftguide_clear_icon.png;clear;]"..
		"image_button[5,4.05;0.8,0.8;craftguide_prev_icon.png;prev;]"..
		"image_button[7.25,4.05;0.8,0.8;craftguide_next_icon.png;next;]"..
		"tooltip[search;Search]"..
		"tooltip[clear;Reset]"..
		"tooltip[prev;Previous page]"..
		"tooltip[next;Next page]"..
		"field_close_on_enter[filter;false]")

	if #data.items == 0 then
		table.insert(fs, "label[3,2;No items to show.]")
	else
		local first_item = (data.pagenum - 1) * 32
		for i = first_item, first_item + 31 do
			local item = data.items[i + 1]
			if not item then
				break
			end
			local x = i % 8
			local y = (i % 32 - x) / 8
			item_button_fs(fs, x, y, item, item.."_inv")
		end
	end

	if data.recipes then
		if #data.recipes > 0 then
			recipe_fs(fs, data)
		elseif data.show_usages then
			table.insert(fs, "label[2,6.6;No usages.\nClick again to show recipes.]")
		else
			table.insert(fs, "label[2,6.6;No recipes.\nClick again to show usages.]")
		end
	end

	return table.concat(fs)
end

local function execute_search(data)
	local filter = data.filter
	if filter == "" then
		data.items = init_items
		return
	end
	data.items = {}

	for _, item in ipairs(init_items) do
		local itemdef = minetest.registered_items[item]
		local desc = itemdef and itemdef.description:lower() or ""

		if item:find(filter, 1, true) or desc:find(filter, 1, true) then
			table.insert(data.items, item)
		end
	end
end

local function reset_data(data)
	data.filter = ""
	data.pagenum = 1
	data.prev_item = nil
	data.recipes = nil
	data.items = init_items
end

local function on_receive_fields(player, fields)
	local name = player:get_player_name()
	local data = player_data[name]

	if fields.clear then
		reset_data(data)
		return true

	elseif fields.key_enter_field == "filter" or fields.search then
		local new = fields.filter:lower()
		if new ~= "" and data.filter == new then
			return
		end
		data.filter = new
		data.pagenum = 1
		execute_search(data)
		return true

	elseif fields.prev or fields.next then
		if data.pagemax == 1 then
			return
		end
		data.pagenum = data.pagenum + (fields.next and 1 or -1)
		if data.pagenum > data.pagemax then
			data.pagenum = 1
		elseif data.pagenum == 0 then
			data.pagenum = data.pagemax
		end
		return true

	elseif fields.recipe_next or fields.recipe_prev then
		data.rnum = data.rnum + (fields.recipe_next and 1 or -1)
		if data.rnum > #data.recipes then
			data.rnum = 1
		elseif data.rnum == 0 then
			data.rnum = #data.recipes
		end
		return true

	else
		local item
		for field in pairs(fields) do
			if field:find(":") then
				item = field
				break
			end
		end
		if not item then
			return
		end
		if item:sub(-4) == "_inv" then
			item = item:sub(1, -5)
		end

		if item == data.prev_item then
			data.show_usages = not data.show_usages
		else
			data.show_usages = nil
		end
		if data.show_usages then
			data.recipes = usages_cache[item] or {}
		else
			data.recipes = recipes_cache[item] or {}
		end
		data.prev_item = item
		data.rnum = 1
		return true
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_data[name] = {
		filter = "",
		pagenum = 1,
		items = init_items
	}
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_data[name] = nil
end)

sfinv.register_page("craftguide:craftguide", {
	title = "Craft Guide",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, get_formspec(player))
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if on_receive_fields(player, fields) then
			sfinv.set_player_inventory_formspec(player)
		end
	end
})
