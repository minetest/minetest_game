-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png", },
	inventory_image = "jeija_solar_panel.png",
	wield_image = "jeija_solar_panel.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "wallmounted",
		wall_bottom = { -7/16, -8/16, -7/16,  7/16, -7/16, 7/16 },
		wall_top    = { -7/16,  7/16, -7/16,  7/16,  8/16, 7/16 },
		wall_side   = { -8/16, -7/16, -7/16, -7/16,  7/16, 7/16 },
	},
	selection_box = {
		type = "wallmounted",
		wall_bottom = { -7/16, -8/16, -7/16,  7/16, -7/16, 7/16 },
		wall_top    = { -7/16,  7/16, -7/16,  7/16,  8/16, 7/16 },
		wall_side   = { -8/16, -7/16, -7/16, -7/16,  7/16, 7/16 },
	},
	drop = "mesecons_solarpanel:solar_panel_off",
	groups = {dig_immediate=3, not_in_creative_inventory = 1},
	sounds = default.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on
	}}
})

-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png", },
	inventory_image = "jeija_solar_panel.png",
	wield_image = "jeija_solar_panel.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "wallmounted",
		wall_bottom = { -7/16, -8/16, -7/16,  7/16, -7/16, 7/16 },
		wall_top    = { -7/16,  7/16, -7/16,  7/16,  8/16, 7/16 },
		wall_side   = { -8/16, -7/16, -7/16, -7/16,  7/16, 7/16 },
	},
	selection_box = {
		type = "wallmounted",
		wall_bottom = { -7/16, -8/16, -7/16,  7/16, -7/16, 7/16 },
		wall_top    = { -7/16,  7/16, -7/16,  7/16,  8/16, 7/16 },
		wall_side   = { -8/16, -7/16, -7/16, -7/16,  7/16, 7/16 },
	},
	groups = {dig_immediate=3},
    	description="Solar Panel",
	sounds = default.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off
	}}
})

minetest.register_craft({
	output = "mesecons_solarpanel:solar_panel_off 1",
	recipe = {
		{"mesecons_materials:silicon", "mesecons_materials:silicon"},
		{"mesecons_materials:silicon", "mesecons_materials:silicon"},
	}
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light >= 12 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_on", param2=node.param2})
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light < 12 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_off", param2=node.param2})
			mesecon:receptor_off(pos)
		end
	end,
})
