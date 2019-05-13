-- wool/init.lua

-- Load support for MT game translation.
local S = minetest.get_translator()
 

local dyes = {
	{"white",      S("White")},
	{"grey",       S("Grey")},
	{"black",      S("Black")},
	{"red",        S("Red")},
	{"yellow",     S("Yellow")},
	{"green",      S("Green")},
	{"cyan",       S("Cyan")},
	{"blue",       S("Blue")},
	{"magenta",    S("Magenta")},
	{"orange",     S("Orange")},
	{"violet",     S("Violet")},
	{"brown",      S("Brown")},
	{"pink",       S("Pink")},
	{"dark_grey",  S("Dark Grey")},
	{"dark_green", S("Dark Green")},
}

for i = 1, #dyes do
	local name, desc = unpack(dyes[i])

	minetest.register_node("wool:" .. name, {
		description = S("@1 Wool", desc),
		tiles = {"wool_" .. name .. ".png"},
		is_ground_content = false,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
				flammable = 3, wool = 1},
		sounds = default.node_sound_defaults(),
	})

	minetest.register_craft{
		type = "shapeless",
		output = "wool:" .. name,
		recipe = {"group:dye,color_" .. name, "group:wool"},
	}
end

-- Legacy
-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("wool:dark_blue", "wool:blue")
minetest.register_alias("wool:gold", "wool:yellow")
