S, NS = dofile(minetest.get_modpath(minetest.get_current_modname()).."/intllib.lua")

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

-- This collection of colors is partly a historic thing, partly something else

local dyes = {
	{"white",      "White dye",      {dye=1, basecolor_white=1,   excolor_white=1,      unicolor_white=1}},
	{"grey",       "Grey dye",       {dye=1, basecolor_grey=1,    excolor_grey=1,       unicolor_grey=1}},
	{"dark_grey",  "Dark grey dye",  {dye=1, basecolor_grey=1,    excolor_darkgrey=1,   unicolor_darkgrey=1}},
	{"black",      "Black dye",      {dye=1, basecolor_black=1,   excolor_black=1,      unicolor_black=1}},
	{"violet",     "Violet dye",     {dye=1, basecolor_magenta=1, excolor_violet=1,     unicolor_violet=1}},
	{"blue",       "Blue dye",       {dye=1, basecolor_blue=1,    excolor_blue=1,       unicolor_blue=1}},
	{"cyan",       "Cyan dye",       {dye=1, basecolor_cyan=1,    excolor_cyan=1,       unicolor_cyan=1}},
	{"dark_green", "Dark green dye", {dye=1, basecolor_green=1,   excolor_green=1,      unicolor_dark_green=1}},
	{"green",      "Green dye",      {dye=1, basecolor_green=1,   excolor_green=1,      unicolor_green=1}},
	{"yellow",     "Yellow dye",     {dye=1, basecolor_yellow=1,  excolor_yellow=1,     unicolor_yellow=1}},
	{"brown",      "Brown dye",      {dye=1, basecolor_brown=1,   excolor_orange=1,     unicolor_dark_orange=1}},
	{"orange",     "Orange dye",     {dye=1, basecolor_orange=1,  excolor_orange=1,     unicolor_orange=1}},
	{"red",        "Red dye",        {dye=1, basecolor_red=1,     excolor_red=1,        unicolor_red=1}},
	{"magenta",    "Magenta dye",    {dye=1, basecolor_magenta=1, excolor_red_violet=1, unicolor_red_violet=1}},
	{"pink",       "Pink dye",       {dye=1, basecolor_red=1,     excolor_red=1,        unicolor_light_red=1}},
}

-- Define items

for _, row in ipairs(dyes) do
	local name = row[1]
	local description = row[2]
	local groups = row[3]
	local item_name = "dye:" .. name
	local item_image = "dye_" .. name .. ".png"
	minetest.register_craftitem(item_name, {
		inventory_image = item_image,
		description = description,
		groups = groups
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
	{"red", "green", "dark_grey"},
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
