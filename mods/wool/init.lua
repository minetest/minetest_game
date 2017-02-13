-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.

for key, value in pairs(dye.dyes) do
	local color = key
	local colorDisplayName = value.name
	local htmlColor = value.html --.."A0"
	local craft_color_group = "color_"..color

	minetest.register_node("wool:"..color, {
		description = colorDisplayName.." Wool",
		tiles = {"(wool.png^[colorize:"..htmlColor..")^wool_overlay.png"},
		is_ground_content = false,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, flammable = 3, wool = 1},
		sounds = default.node_sound_defaults(),
	})

	minetest.register_craft({
		type = "shapeless",
		output = "wool:"..color,
		recipe = {"group:dye,"..craft_color_group, "group:wool"},
	})
end

--local dyes = {
--	{"white",      "White"},
--	{"grey",       "Grey"},
--	{"black",      "Black"},
--	{"red",        "Red"},
--	{"yellow",     "Yellow"},
--	{"green",      "Green"},
--	{"cyan",       "Cyan"},
--	{"blue",       "Blue"},
--	{"magenta",    "Magenta"},
--	{"orange",     "Orange"},
--	{"violet",     "Violet"},
--	{"brown",      "Brown"},
--	{"pink",       "Pink"},
--	{"dark_grey",  "Dark Grey"},
--	{"dark_green", "Dark Green"},
--}

--for i = 1, #dyes do
--	local name, desc = unpack(dyes[i])
--	local craft_color_group = "color_"..name

--	minetest.register_node("wool:" .. name, {
--		description = desc .. " Wool",
--		tiles = {"wool_" .. name .. ".png"},
--		is_ground_content = false,
--		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
--				flammable = 3, wool = 1},
--		sounds = default.node_sound_defaults(),
--	})

--	minetest.register_craft{
--		type = "shapeless",
--		output = "wool:" .. name,
--		recipe = {"group:dye," .. craft_color_group, "group:wool"},
--	}
--end


-- legacy

-- Backwards compatibility with jordach's 16-color wool mod
--minetest.register_alias("wool:dark_blue", "wool:blue")
--minetest.register_alias("wool:gold", "wool:yellow")
