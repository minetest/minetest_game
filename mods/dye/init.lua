-- List of palette handlers

palette_handlers = {}

-- Default handler for default_r6g6b6.png

palette_handlers["default_r6g6b6.png"] = {
	index_to_rgb = function(p)
		if p > 215 then
			p = 215
		end
		local r = math.floor(p / 36) / 5 * 255
		local g = math.floor(p / 6) % 6 / 5 * 255
		local b = p % 6 / 5 * 255
		return r, g, b
	end,

	rgb_to_index = function(r, g, b)
		local ri = math.floor(r / 255 * 5 + 0.5)
		local gi = math.floor(g / 255 * 5 + 0.5)
		local bi = math.floor(b / 255 * 5 + 0.5)
		return ri * 36 + gi * 6 + bi
	end
}

-- Other mods can use these for looping through available colors

dye = {}
dye.basecolors = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
dye.excolors = {"white", "lightgrey", "grey", "darkgrey", "black", "red", "orange", "yellow",
	"lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta", "red_violet"}

-- Make dye names and descriptions available globally

dye.dyes = {
	{"white",      "White"},
	{"grey",       "Grey"},
	{"dark_grey",  "Dark grey"},
	{"black",      "Black"},
	{"violet",     "Violet"},
	{"blue",       "Blue"},
	{"cyan",       "Cyan"},
	{"dark_green", "Dark green"},
	{"green",      "Green"},
	{"yellow",     "Yellow"},
	{"brown",      "Brown"},
	{"orange",     "Orange"},
	{"red",        "Red"},
	{"magenta",    "Magenta"},
	{"pink",       "Pink"},
}

-- Paint with a dye

dye.use = function(itemstack, user, pointed_thing, red, green, blue)
	if pointed_thing.type ~= "node" then
		return itemstack
	end

	local pos = pointed_thing.under

	if minetest.is_protected(pos, user:get_player_name()) then
		minetest.record_protection_violation(pos, user:get_player_name())
		return itemstack
	end

	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or (ndef.can_dig and not ndef.can_dig(pos, user)) then
		return itemstack
	end

	if not ndef.palette then
		return itemstack
	end
	local palettehandler = palette_handlers[ndef.palette]
	if not (palettehandler and palettehandler.index_to_rgb and
			palettehandler.rgb_to_index) then
		return itemstack
	end

	local node_r, node_g, node_b = palettehandler.index_to_rgb(node.param2)
	node.param2 = palettehandler.rgb_to_index(
		node_r * 0.49 + red * 0.51,
		node_g * 0.49 + green * 0.51,
		node_b * 0.49 + blue * 0.51,
		node.param2)

	minetest.swap_node(pos, node)

	if minetest.setting_getbool("creative_mode") then
		return itemstack
	end

	itemstack:take_item()
	return itemstack
end

-- This collection of colors is partly a historic thing, partly something else

local dyes = {
	{"white",      "White dye",      {dye=1, basecolor_white=1,   excolor_white=1,      unicolor_white=1},       {r=255, g=255, b=255}},
	{"grey",       "Grey dye",       {dye=1, basecolor_grey=1,    excolor_grey=1,       unicolor_grey=1},        {r=153, g=153, b=153}},
	{"dark_grey",  "Dark grey dye",  {dye=1, basecolor_grey=1,    excolor_darkgrey=1,   unicolor_darkgrey=1},    {r=51 , g=51 , b=51}},
	{"black",      "Black dye",      {dye=1, basecolor_black=1,   excolor_black=1,      unicolor_black=1},       {r=0  , g=0  , b=0}},
	{"violet",     "Violet dye",     {dye=1, basecolor_magenta=1, excolor_violet=1,     unicolor_violet=1},      {r=102, g=0  , b=255}},
	{"blue",       "Blue dye",       {dye=1, basecolor_blue=1,    excolor_blue=1,       unicolor_blue=1},        {r=0  , g=0  , b=255}},
	{"cyan",       "Cyan dye",       {dye=1, basecolor_cyan=1,    excolor_cyan=1,       unicolor_cyan=1},        {r=0  , g=255, b=255}},
	{"dark_green", "Dark green dye", {dye=1, basecolor_green=1,   excolor_green=1,      unicolor_dark_green=1},  {r=0  , g=102, b=0}},
	{"green",      "Green dye",      {dye=1, basecolor_green=1,   excolor_green=1,      unicolor_green=1},       {r=0  , g=255, b=0}},
	{"yellow",     "Yellow dye",     {dye=1, basecolor_yellow=1,  excolor_yellow=1,     unicolor_yellow=1},      {r=255, g=255, b=0}},
	{"brown",      "Brown dye",      {dye=1, basecolor_brown=1,   excolor_orange=1,     unicolor_dark_orange=1}, {r=102, g=51 , b=0}},
	{"orange",     "Orange dye",     {dye=1, basecolor_orange=1,  excolor_orange=1,     unicolor_orange=1},      {r=255, g=153, b=0}},
	{"red",        "Red dye",        {dye=1, basecolor_red=1,     excolor_red=1,        unicolor_red=1},         {r=255, g=0  , b=0}},
	{"magenta",    "Magenta dye",    {dye=1, basecolor_magenta=1, excolor_red_violet=1, unicolor_red_violet=1},  {r=255, g=0  , b=255}},
	{"pink",       "Pink dye",       {dye=1, basecolor_red=1,     excolor_red=1,        unicolor_light_red=1},   {r=255, g=153, b=153}},
}

-- Define items

for _, row in ipairs(dyes) do
	local name = row[1]
	local description = row[2]
	local groups = row[3]
	local r = row[4].r
	local g = row[4].g
	local b = row[4].b
	local item_name = "dye:" .. name
	local item_image = "dye_" .. name .. ".png"
	minetest.register_craftitem(item_name, {
		inventory_image = item_image,
		description = description,
		groups = groups,
		on_place = function(itemstack, user, pointed_thing)
			return dye.use(itemstack, user, pointed_thing, r, g, b)
		end,
	})
	minetest.register_craft({
		type = "shapeless",
		output = item_name .. " 4",
		recipe = {"group:flower,color_" .. name},
	})
end

-- Manually add coal->black dye

minetest.register_craft({
	type = "shapeless",
	output = "dye:black 4",
	recipe = {"group:coal"},
})

-- Mix recipes
local dye_recipes = {
	-- src1, src2, dst
	-- RYB mixes
	{"red", "blue", "violet"}, -- "purple"
	{"yellow", "red", "orange"},
	{"yellow", "blue", "green"},
	-- RYB complementary mixes
	{"yellow", "violet", "dark_grey"},
	{"blue", "orange", "dark_grey"},
	-- CMY mixes - approximation
	{"cyan", "yellow", "green"},
	{"cyan", "magenta", "blue"},
	{"yellow", "magenta", "red"},
	-- other mixes that result in a color we have
	{"red", "green", "brown"},
	{"magenta", "blue", "violet"},
	{"green", "blue", "cyan"},
	{"pink", "violet", "magenta"},
	-- mixes with black
	{"white", "black", "grey"},
	{"grey", "black", "dark_grey"},
	{"green", "black", "dark_green"},
	{"orange", "black", "brown"},
	-- mixes with white
	{"white", "red", "pink"},
	{"white", "dark_grey", "grey"},
	{"white", "dark_green", "green"},
}

for _, mix in pairs(dye_recipes) do
	minetest.register_craft({
		type = "shapeless",
		output = 'dye:' .. mix[3] .. ' 2',
		recipe = {'dye:' .. mix[1], 'dye:' .. mix[2]},
	})
end
