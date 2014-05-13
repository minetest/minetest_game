local mesewire_rules =
{
	{x = 1, y = 0, z = 0},
	{x =-1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y =-1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z =-1},
}

minetest.register_node(":default:mese", {
	description = "Mese Block",
	tiles = {minetest.registered_nodes["default:mese"].tiles[1]},
	is_ground_content = true,
	groups = {cracky=1},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:mese_powered",
		rules = mesewire_rules
	}}
})

minetest.register_node("mesecons_extrawires:mese_powered", {
	tiles = {minetest.registered_nodes["default:mese"].tiles[1].."^[brighten"},
	is_ground_content = true,
	groups = {cracky=1, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "default:mese",
		rules = mesewire_rules
	}},
	drop = "default:mese"
})
