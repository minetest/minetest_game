carts:register_rail("carts:rail", {
	description = "Rail",
	tiles = {
		"carts_rail_straight.png", "carts_rail_curved.png",
		"carts_rail_t_junction.png", "carts_rail_crossing.png"
	},
	inventory_image = "carts_rail_straight.png",
	wield_image = "carts_rail_straight.png",
	groups = carts:get_rail_groups(),
}, {})

minetest.register_craft({
	output = "carts:rail 16",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	}
})

minetest.register_alias("default:rail", "carts:rail")

carts:register_rail("carts:powerrail", {
	description = "Powered rail",
	tiles = {
		"carts_rail_straight_pwr.png", "carts_rail_curved_pwr.png",
		"carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"
	},
	groups = carts:get_rail_groups(),
}, {acceleration = 4})

minetest.register_craft({
	output = "carts:powerrail 8",
	recipe = {
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"},
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"},
	}
})

carts:register_rail("carts:brakerail", {
	description = "Brake rail",
	tiles = {
		"carts_rail_straight_brk.png", "carts_rail_curved_brk.png",
		"carts_rail_t_junction_brk.png", "carts_rail_crossing_brk.png"
	},
	groups = carts:get_rail_groups(),
}, {acceleration = -3})


minetest.register_craft({
	output = "carts:brakerail 8",
	recipe = {
		{"default:steel_ingot", "default:coal_lump", "default:steel_ingot"},
		{"default:steel_ingot", "group:stick", "default:steel_ingot"},
		{"default:steel_ingot", "default:coal_lump", "default:steel_ingot"},
	}
})
