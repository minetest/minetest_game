-- Vessels Mod by Vanessa Ezekowitz  ~~  2012-07-26
--
-- License: LGPL
--

--========================================
-- Crafts
--
-- Glass bottle (yields 10)
--
--       G - G
--       G - G
--       - G -
--
-- Drinking Glass (yields 14)
--
--       G - G
--       G - G
--       G G G
--
-- Heavy Steel Bottle (yields 5)
--
--       S - S
--       S - S
--       - S -


minetest.register_craftitem("vessels:glass_bottle", {
        description = "Glass Bottle (empty)",
        inventory_image = "vessels_glass_bottle_inv.png",
	wield_image = "vessels_glass_bottle.png"
})

minetest.register_craft( {
	output = "vessels:glass_bottle 10",
	recipe = {
		{ "default:glass", "", "default:glass" },
		{ "default:glass", "", "default:glass" },
		{ "", "default:glass", "" }
	}
})

minetest.register_craftitem("vessels:drinking_glass", {
        description = "Drinking Glass (empty)",
        inventory_image = "vessels_drinking_glass_inv.png",
	wield_image = "vessels_drinking_glass.png"
})

minetest.register_craft( {
	output = "vessels:drinking_glass 14",
	recipe = {
		{ "default:glass", "", "default:glass" },
		{ "default:glass", "", "default:glass" },
		{ "default:glass", "default:glass", "default:glass" }
	}
})

minetest.register_craftitem("vessels:steel_bottle", {
        description = "Heavy Steel Bottle (empty)",
        inventory_image = "vessels_steel_bottle_inv.png",
	wield_image = "vessels_steel_bottle.png"
})

minetest.register_craft( {
	output = "vessels:steel_bottle 5",
	recipe = {
		{ "default:steel_ingot", "", "default:steel_ingot" },
		{ "default:steel_ingot", "", "default:steel_ingot" },
		{ "", "default:steel_ingot", "" }
	}
})


-- Make sure we can recycle them

minetest.register_craftitem("vessels:glass_fragments", {
        description = "Pile of Glass Fragments",
        inventory_image = "vessels_glass_fragments.png",
})

minetest.register_craft( {
	type = "shapeless",
	output = "vessels:glass_fragments",
	recipe = {
		"vessels:glass_bottle",
		"vessels:glass_bottle",
	},
})

minetest.register_craft( {
	type = "shapeless",
	output = "vessels:glass_fragments",
	recipe = {
		"vessels:drinking_glass",
		"vessels:drinking_glass",
	},
})

minetest.register_craft({
	type = "cooking",
	output = "default:glass",
	recipe = "vessels:glass_fragments",
})

minetest.register_craft( {
	type = "cooking",
	output = "default:steel_ingot",
	recipe = "vessels:steel_bottle",
})

print("[Vessels] Loaded!")
