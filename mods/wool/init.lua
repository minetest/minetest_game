-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("wool:dark_blue", "wool:blue")
minetest.register_alias("wool:gold", "wool:yellow")

local wool = {}
wool.dyes = {
	{"white",      "White"},
	{"grey",       "Grey"},
	{"dark_grey",  "Dark Grey"},
	{"black",      "Black"},
	{"violet",     "Violet"},
	{"blue",       "Blue"},
	{"cyan",       "Cyan"},
	{"dark_green", "Dark Green"},
	{"green",      "Green"},
	{"yellow",     "Yellow"},
	{"brown",      "Brown"},
	{"orange",     "Orange"},
	{"red",        "Red"},
	{"magenta",    "Magenta"},
	{"pink",       "Pink"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local desc = row[2]
	-- Node Definition
	minetest.register_node("wool:"..name, {
		description = desc.." Wool",
		tile_images = {"wool_"..name..".png"},
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,flammable=3},
	})
	if name ~= "white" then
		-- Crafting from dye and white wool
		minetest.register_craft({
			type = "shapeless",
			output = 'wool:'..name..' 16',
			recipe = {'dye:'..name, 'wool:white'},
		})
	end
end

