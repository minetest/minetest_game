dye = {}

-- Make dye names and descriptions available globally.
-- Other mods can use these for looping through available colors.
dye.dyes = {
	white		= { name = "White", html = "#FFFFFF" },
	grey		= { name = "Grey", html = "#7F7F7F" },
	dark_grey	= { name = "Dark Grey", html = "#3F3F3F" },
	black		= { name = "Black", html = "#000000" },
	violet		= { name = "Violet", html = "#8000FF" },
	blue		= { name = "Blue", html = "#0000FF" },
	cyan		= { name = "Cyan", html = "#00FFFF" },
	dark_green	= { name = "Dark Green", html = "#007F00" },
	green		= { name = "Green", html = "#00FF00" },
	yellow		= { name = "Yellow", html = "#FFFF00" },
	brown		= { name = "Brown", html = "#854C30" },
	orange		= { name = "Orange", html = "#FF7F00" },
	red			= { name = "Red", html = "#FF0000" },
	magenta		= { name = "Magenta", html = "#FF00FF" },
	pink		= { name = "Pink", html = "#FF7FFF" },
}

-- Define items

for key, value in pairs(dye.dyes) do
	local itemName = "dye:"..key

	minetest.register_craftitem(itemName, {
		inventory_image = "dye_"..key..".png",
		description = value.name,
		groups = "color_"..key
	})
	minetest.register_craft({
		type = "shapeless",
		output = itemName .. " 4",
		recipe = {"group:flower,color_"..key},
	})
end

-- Manually add coal->black dye.
-- TODO: Is this still desirable?

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
