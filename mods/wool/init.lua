-- wool/init.lua

-- Load support for MT game translation.
local S = minetest.get_translator("wool")

local dyes = dye.dyes

for i = 1, #dyes do
	local name, desc = unpack(dyes[i])

	minetest.register_node("wool:" .. name, {
		description = S(desc .. " Fabric"),
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

-- Dummy calls to S() to allow translation scripts to detect the strings.
-- To update this run:
-- for _,e in ipairs(dye.dyes) do print(("S(%q)"):format(e[2].." Fabric")) end

--[[
S("White Fabric")
S("Grey Fabric")
S("Dark Grey Fabric")
S("Black Fabric")
S("Violet Fabric")
S("Blue Fabric")
S("Cyan Fabric")
S("Dark Green Fabric")
S("Green Fabric")
S("Yellow Fabric")
S("Brown Fabric")
S("Orange Fabric")
S("Red Fabric")
S("Magenta Fabric")
S("Pink Fabric")
--]]
