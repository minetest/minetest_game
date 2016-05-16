-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("wool:dark_blue", "wool:blue")
minetest.register_alias("wool:gold", "wool:yellow")

local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	{"white",      "bianca",      "basecolor_white"},
	{"grey",       "grigia",       "basecolor_grey"},
	{"black",      "nera",      "basecolor_black"},
	{"red",        "rossa",        "basecolor_red"},
	{"yellow",     "gialla",     "basecolor_yellow"},
	{"green",      "verde",      "basecolor_green"},
	{"cyan",       "ciano",       "basecolor_cyan"},
	{"blue",       "blu",       "basecolor_blue"},
	{"magenta",    "magenta",    "basecolor_magenta"},
	{"orange",     "arancione",     "excolor_orange"},
	{"violet",     "viola",     "excolor_violet"},
	{"brown",      "marrone",      "unicolor_dark_orange"},
	{"pink",       "rosa",       "unicolor_light_red"},
	{"dark_grey",  "girigia scura",  "unicolor_darkgrey"},
	{"dark_green", "verde scura", "unicolor_dark_green"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local desc = row[2]
	local craft_color_group = row[3]
	-- Node Definition
	minetest.register_node("wool:"..name, {
		description = "Lana " .. desc,
		tiles = {"wool_"..name..".png"},
		is_ground_content = false,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,flammable=3,wool=1},
		sounds = default.node_sound_defaults(),
	})
	if craft_color_group then
		-- Crafting from dye and white wool
		minetest.register_craft({
			type = "shapeless",
			output = 'wool:'..name,
			recipe = {'group:dye,'..craft_color_group, 'group:wool'},
		})
	end
end

