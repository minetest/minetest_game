function crossover_get_rules(node)
	return {
		{--first wire
			{x=-1,y=0,z=0},
			{x=1,y=0,z=0},
		},
		{--second wire
			{x=0,y=0,z=-1},
			{x=0,y=0,z=1},
		},
	}
end

local crossover_states = {
	"mesecons_extrawires:crossover_off",
	"mesecons_extrawires:crossover_01",
	"mesecons_extrawires:crossover_10",
	"mesecons_extrawires:crossover_on",
}

minetest.register_node("mesecons_extrawires:crossover_off", {
	description = "Insulated Crossover",
	drawtype = "nodebox",
	tiles = {
		"jeija_insulated_wire_crossing_tb_off.png",
		"jeija_insulated_wire_crossing_tb_off.png",
		"jeija_insulated_wire_ends_off.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
			{ -3/32, -17/32, -16/32-0.001, 3/32, -13/32, -6/32 },
			{ -3/32, -13/32, -9/32, 3/32, -6/32, -6/32 },
			{ -3/32, -9/32, -9/32, 3/32, -6/32, 9/32 },
			{ -3/32, -13/32, 6/32, 3/32, -6/32, 9/32 },
			{ -3/32, -17/32, 6/32, 3/32, -13/32, 16/32+0.001 },
		},
	},
	groups = {dig_immediate=3, mesecon=3, mesecon_conductor_craftable=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
})

minetest.register_node("mesecons_extrawires:crossover_01", {
	description = "You hacker you!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "nodebox",
	tiles = {
		"jeija_insulated_wire_crossing_tb_01.png",
		"jeija_insulated_wire_crossing_tb_01.png",
		"jeija_insulated_wire_ends_01x.png",
		"jeija_insulated_wire_ends_01x.png",
		"jeija_insulated_wire_ends_01z.png",
		"jeija_insulated_wire_ends_01z.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
			{ -3/32, -17/32, -16/32-0.001, 3/32, -13/32, -6/32 },
			{ -3/32, -13/32, -9/32, 3/32, -6/32, -6/32 },
			{ -3/32, -9/32, -9/32, 3/32, -6/32, 9/32 },
			{ -3/32, -13/32, 6/32, 3/32, -6/32, 9/32 },
			{ -3/32, -17/32, 6/32, 3/32, -13/32, 16/32+0.001 },
		},
	},
	groups = {dig_immediate=3, mesecon=3, mesecon_conductor_craftable=1, not_in_creative_inventory=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
})

minetest.register_node("mesecons_extrawires:crossover_10", {
	description = "You hacker you!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "nodebox",
	tiles = {
		"jeija_insulated_wire_crossing_tb_10.png",
		"jeija_insulated_wire_crossing_tb_10.png",
		"jeija_insulated_wire_ends_10x.png",
		"jeija_insulated_wire_ends_10x.png",
		"jeija_insulated_wire_ends_10z.png",
		"jeija_insulated_wire_ends_10z.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
			{ -3/32, -17/32, -16/32-0.001, 3/32, -13/32, -6/32 },
			{ -3/32, -13/32, -9/32, 3/32, -6/32, -6/32 },
			{ -3/32, -9/32, -9/32, 3/32, -6/32, 9/32 },
			{ -3/32, -13/32, 6/32, 3/32, -6/32, 9/32 },
			{ -3/32, -17/32, 6/32, 3/32, -13/32, 16/32+0.001 },
		},
	},
	groups = {dig_immediate=3, mesecon=3, mesecon_conductor_craftable=1, not_in_creative_inventory=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
})

minetest.register_node("mesecons_extrawires:crossover_on", {
	description = "You hacker you!",
	drop = "mesecons_extrawires:crossover_off",
	drawtype = "nodebox",
	tiles = {
		"jeija_insulated_wire_crossing_tb_on.png",
		"jeija_insulated_wire_crossing_tb_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png",
		"jeija_insulated_wire_ends_on.png"
	},
	paramtype = "light",
	walkable = false,
	stack_max = 99,
	selection_box = {type="fixed", fixed={-16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001}},
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
			{ -3/32, -17/32, -16/32-0.001, 3/32, -13/32, -6/32 },
			{ -3/32, -13/32, -9/32, 3/32, -6/32, -6/32 },
			{ -3/32, -9/32, -9/32, 3/32, -6/32, 9/32 },
			{ -3/32, -13/32, 6/32, 3/32, -6/32, 9/32 },
			{ -3/32, -17/32, 6/32, 3/32, -13/32, 16/32+0.001 },
		},
	},
	groups = {dig_immediate=3, mesecon=3, mesecon_conductor_craftable=1, not_in_creative_inventory=1},
	mesecons = {
		conductor = {
			states = crossover_states,
			rules = crossover_get_rules(),
		}
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:crossover_off",
	recipe = {
		"mesecons_insulated:insulated_off",
		"mesecons_insulated:insulated_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_insulated:insulated_off 2",
	recipe = {
		"mesecons_extrawires:crossover_off",
	},
})
