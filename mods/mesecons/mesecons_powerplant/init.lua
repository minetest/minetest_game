-- The POWER_PLANT
-- Just emits power. always.

minetest.register_node("mesecons_powerplant:power_plant", {
	drawtype = "plantlike",
	visual_scale = 1,
	tiles = {"jeija_power_plant.png"},
	inventory_image = "jeija_power_plant.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3, mesecon = 2},
	light_source = LIGHT_MAX-9,
    	description="Power Plant",
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	sounds = default.node_sound_leaves_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on
	}}
})

minetest.register_craft({
	output = "mesecons_powerplant:power_plant 1",
	recipe = {
		{"group:mesecon_conductor_craftable"},
		{"group:mesecon_conductor_craftable"},
		{"default:sapling"},
	}
})
