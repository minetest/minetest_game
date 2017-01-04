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

--
-- Crafting
--

minetest.register_craft({
	type = "shapeless",
	output = "dye:black 4",
	recipe = {"default:coal_lump"},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:brown 2",
	recipe = {'dye:blue', 'dye:red', 'dye:yellow'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:cyan 2",
	recipe = {'dye:blue', 'dye:white'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:dark_green 2",
	recipe = {'dye:blue', 'dye:yellow', "dye:black"},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:dark_grey 2",
	recipe = {'dye:black', 'dye:grey'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:green 2",
	recipe = {'dye:blue', 'dye:yellow'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:grey 2",
	recipe = {'dye:black', 'dye:white'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:grey 2",
	recipe = {'dye:dark_grey', 'dye:white'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:magenta 2",
	recipe = {'dye:red', 'dye:pink'},
})

minetest.register_craft({
	type = "shapeless",
	output = "dye:pink 2",
	recipe = {'dye:red', 'dye:white'},
})
