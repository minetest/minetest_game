-- mods/default/tools.lua

-- support for MT game translation.
local S = default.get_translator

-- The hand
-- Override the hand item registered in the engine in builtin/game/register.lua
minetest.override_item("", {
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {fleshy=1},
	}
})

-- Default-type tool registration function

function default.register_tool_of_type(name, desc, img, wimg, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat, typename, typedesc, typebreak, typetool, typeshape)
	extra_groups[typetool] = 1
	local mygroupcaps = {}
	mygroupcaps[typebreak] = {times={[1]=gc1, [2]=gc2, [3]=gc3}, uses=use_count, maxlevel=maxlvl}
	minetest.register_tool("default:"..typename.."_"..name, {
		description = S(desc.." "..typedesc),
		inventory_image = img,
		wield_image = wimg,
		tool_capabilities = {
			full_punch_interval = punch_interval,
			max_drop_level=max_drop_lvl,
			groupcaps=mygroupcaps,
			damage_groups = {fleshy=dmg},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = extra_groups
	})
	minetest.register_craft({
		output = "default:"..typename.."_"..name,
		recipe = typeshape
	})
end

--
-- Picks
--

function default.register_pick(name, desc, img, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat)
	default.register_tool_of_type(name, desc, img, nil, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat, "pick", "Pickaxe", "cracky", "pickaxe", {
		{mat, mat, mat},
		{"", "group:stick", ""},
		{"", "group:stick", ""}
	})
end

default.register_pick("wood", "Wooden", "default_tool_woodpick.png", 1.2, 0, nil, nil, 1.60, 10, 1, 2, {flammable = 2}, "group:wood")

default.register_pick("stone", "Stone", "default_tool_stonepick.png", 1.3, 0, nil, 2.0, 1.00, 20, 1, 3, {}, "group:stone")

default.register_pick("bronze", "Bronze", "default_tool_bronzepick.png", 1.0, 1, 4.50, 1.80, 0.90, 20, 2, 4, {}, "default:bronze_ingot")

default.register_pick("steel", "Steel", "default_tool_steelpick.png", 1.0, 1, 4.00, 1.60, 0.80, 20, 2, 4, {}, "default:steel_ingot")

default.register_pick("mese", "Mese", "default_tool_mesepick.png", 0.9, 3, 2.4, 1.2, 0.60, 20, 3, 5, {}, "default:mese_crystal")

default.register_pick("diamond", "Diamond", "default_tool_diamondpick.png", 0.9, 3, 2.0, 1.0, 0.50, 30, 3, 5, {}, "default:diamond")

--
-- Shovels
--

function default.register_shovel(name, desc, img, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat)
	default.register_tool_of_type(name, desc, img, img.."^[transformR90", punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat, "shovel", "Shovel", "crumbly", "shovel", {
		{mat},
		{"group:stick"},
		{"group:stick"}
	})
end

default.register_shovel("wood", "Wooden", "default_tool_woodshovel.png", 1.2, 0, 3.00, 1.60, 0.60, 10, 1, 2, {flammable = 2}, "group:wood")

default.register_shovel("stone", "Stone", "default_tool_stoneshovel.png", 1.4, 0, 1.80, 1.20, 0.50, 20, 1, 2, {}, "group:stone")

default.register_shovel("bronze", "Bronze", "default_tool_bronzeshovel.png", 1.1, 1, 1.65, 1.05, 0.45, 25, 2, 3, {}, "default:bronze_ingot")

default.register_shovel("steel", "Steel", "default_tool_steelshovel.png", 1.1, 1, 1.50, 0.90, 0.40, 30, 2, 3, {}, "default:steel_ingot")

default.register_shovel("mese", "Mese", "default_tool_meseshovel.png", 1.0, 3, 1.20, 0.60, 0.30, 20, 3, 4, {}, "default:mese_crystal")

default.register_shovel("diamond", "Diamond", "default_tool_diamondshovel.png", 1.0, 1, 1.10, 0.50, 0.30, 30, 3, 4, {}, "default:diamond")

--
-- Axes
--

function default.register_axe(name, desc, img, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat)
	default.register_tool_of_type(name, desc, img, nil, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat, "axe", "Axe", "choppy", "axe", {
		{mat, mat},
		{mat, "group:stick"},
		{"", "group:stick"}
	})
end

default.register_axe("wood", "Wooden", "default_tool_woodaxe.png", 1.0, 0, nil, 3.00, 1.60, 10, 1, 2, {flammable = 2}, "group:wood")

default.register_axe("stone", "Stone", "default_tool_stoneaxe.png", 1.2, 0, 3.00, 2.00, 1.30, 20, 1, 3, {}, "group:stone")

default.register_axe("bronze", "Bronze", "default_tool_bronzeaxe.png", 1.0, 1, 2.75, 1.70, 1.15, 20, 2, 4, {}, "default:bronze_ingot")

default.register_axe("steel", "Steel", "default_tool_steelaxe.png", 1.0, 1, 2.50, 1.40, 1.00, 20, 2, 4, {}, "default:steel_ingot")

default.register_axe("mese", "Mese", "default_tool_meseaxe.png", 0.9, 1, 2.20, 1.00, 0.60, 20, 3, 6, {}, "default:mese_crystal")

default.register_axe("diamond", "Diamond", "default_tool_diamondaxe.png", 0.9, 1, 2.10, 0.90, 0.50, 30, 3, 7, {}, "default:diamond")

--
-- Swords
--

function default.register_sword(name, desc, img, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat)
	default.register_tool_of_type(name, desc, img, nil, punch_interval, max_drop_lvl, gc1, gc2, gc3, use_count, maxlvl, dmg, extra_groups, mat, "sword", "Sword", "snappy", "sword", {
		{mat},
		{mat},
		{"group:stick"}
	})
end

default.register_sword("wood", "Wooden", "default_tool_woodsword.png", 1, 0, nil, 1.6, 0.40, 10, 1, 2, {flammable = 2}, "group:wood")

default.register_sword("stone", "Stone", "default_tool_stonesword.png", 1.2, 0, nil, 1.4, 0.40, 20, 1, 4, {}, "group:stone")

default.register_sword("bronze", "Bronze", "default_tool_bronzesword.png", 0.8, 1, 2.75, 1.30, 0.375, 25, 2, 6, {}, "default:bronze_ingot")

default.register_sword("steel", "Steel", "default_tool_steelsword.png", 0.8, 1, 2.5, 1.20, 0.35, 30, 2, 6, {}, "default:steel_ingot")

default.register_sword("mese", "Mese", "default_tool_mesesword.png", 0.7, 1, 2.0, 1.00, 0.35, 30, 3, 7, {}, "default:mese_crystal")

default.register_sword("diamond", "Diamond", "default_tool_diamondsword.png", 0.7, 1, 1.90, 0.90, 0.30, 40, 3, 8, {}, "default:diamond")

-- Fuel recipes for wooden tools

minetest.register_craft({
	type = "fuel",
	recipe = "default:pick_wood",
	burntime = 6,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:shovel_wood",
	burntime = 4,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:axe_wood",
	burntime = 6,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:sword_wood",
	burntime = 5,
})
