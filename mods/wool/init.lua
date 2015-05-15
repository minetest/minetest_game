-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("wool:dark_blue", "wool:blue")
minetest.register_alias("wool:gold", "wool:yellow")

local wool = {}

-- Intllib
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end
wool.intllib = S

-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	{"white",      S("White"),      nil},
	{"grey",       S("Grey"),       "basecolor_grey"},
	{"black",      S("Black"),      "basecolor_black"},
	{"red",        S("Red"),        "basecolor_red"},
	{"yellow",     S("Yellow"),     "basecolor_yellow"},
	{"green",      S("Green"),      "basecolor_green"},
	{"cyan",       S("Cyan"),       "basecolor_cyan"},
	{"blue",       S("Blue"),       "basecolor_blue"},
	{"magenta",    S("Magenta"),    "basecolor_magenta"},
	{"orange",     S("Orange"),     "excolor_orange"},
	{"violet",     S("Violet"),     "excolor_violet"},
	{"brown",      S("Brown"),      "unicolor_dark_orange"},
	{"pink",       S("Pink"),       "unicolor_light_red"},
	{"dark_grey",  S("Dark Grey"),  "unicolor_darkgrey"},
	{"dark_green", S("Dark Green"), "unicolor_dark_green"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local desc = row[2]
	local craft_color_group = row[3]
	-- Node Definition
	minetest.register_node("wool:"..name, {
		description = S("@1 Wool", desc), --desc..S(" Wool"),
		tiles = {"wool_"..name..".png"},
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

