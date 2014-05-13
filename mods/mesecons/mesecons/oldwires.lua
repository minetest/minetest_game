minetest.register_node("mesecons:mesecon_off", {
	drawtype = "raillike",
	tiles = {"jeija_mesecon_off.png", "jeija_mesecon_curved_off.png", "jeija_mesecon_t_junction_off.png", "jeija_mesecon_crossing_off.png"},
	inventory_image = "jeija_mesecon_off.png",
	wield_image = "jeija_mesecon_off.png",
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
	},
	groups = {dig_immediate=3, mesecon=1, mesecon_conductor_craftable=1},
    	description="Mesecons",
	mesecons = {conductor={
		state = mesecon.state.off,
		onstate = "mesecons:mesecon_on"
	}}
})

minetest.register_node("mesecons:mesecon_on", {
	drawtype = "raillike",
	tiles = {"jeija_mesecon_on.png", "jeija_mesecon_curved_on.png", "jeija_mesecon_t_junction_on.png", "jeija_mesecon_crossing_on.png"},
	paramtype = "light",
	is_ground_content = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
	},
	groups = {dig_immediate=3, not_in_creaive_inventory=1, mesecon=1},
	drop = "mesecons:mesecon_off 1",
	light_source = LIGHT_MAX-11,
	mesecons = {conductor={
		state = mesecon.state.on,
		offstate = "mesecons:mesecon_off"
	}}
})
