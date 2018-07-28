
dye = {}

-- Make dye names and descriptions available globally

dye.dyes = {
	{"white",      "White",      {unicolor_white = 1}},
	{"grey",       "Grey",       {unicolor_grey = 1}},
	{"dark_grey",  "Dark grey",  {unicolor_darkgrey = 1}},
	{"black",      "Black",      {unicolor_black = 1}},
	{"violet",     "Violet",     {unicolor_violet = 1}},
	{"blue",       "Blue",       {unicolor_blue = 1}},
	{"cyan",       "Cyan",       {unicolor_cyan = 1}},
	{"dark_green", "Dark green", {unicolor_dark_green = 1}},
	{"green",      "Green",      {unicolor_green = 1}},
	{"yellow",     "Yellow",     {unicolor_yellow = 1}},
	{"brown",      "Brown",      {unicolor_dark_orange = 1}},
	{"orange",     "Orange",     {unicolor_orange = 1}},
	{"red",        "Red",        {unicolor_red = 1}},
	{"magenta",    "Magenta",    {unicolor_red_violet = 1}},
	{"pink",       "Pink",       {unicolor_light_red = 1}},
}

-- Define items

for _, row in ipairs(dye.dyes) do
	local name = row[1]
	local description = row[2]
	local groups = row[3]

	-- Add groups
	groups.dye = 1
	groups.flammable = 2
	groups["color_" .. name] = 1

	minetest.register_craftitem("dye:" .. name, {
		inventory_image = "dye_" .. name .. ".png",
		description = description,
		groups = groups
	})

	minetest.register_craft({
		type = "shapeless",
		output = "dye:" .. name .. " 4",
		recipe = {"group:flower,color_" .. name},
	})
end

-- Manually add coal -> black dye

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
