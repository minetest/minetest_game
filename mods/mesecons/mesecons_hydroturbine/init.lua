-- HYDRO_TURBINE
-- Water turbine:
-- Active if flowing >water< above it
-- (does not work with other liquids)

minetest.register_node("mesecons_hydroturbine:hydro_turbine_off", {
	drawtype = "nodebox",
	tiles = {"jeija_hydro_turbine_off.png"},
	groups = {dig_immediate=2},
    	description="Water Turbine",
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.45, 1.15, -0.1, 0.45, 1.45, 0.1},
			{-0.1, 1.15, -0.45, 0.1, 1.45, 0.45}},
	},
	node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.45, 1.15, -0.1, 0.45, 1.45, 0.1},
			{-0.1, 1.15, -0.45, 0.1, 1.45, 0.45}},
	},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off
	}}
})

minetest.register_node("mesecons_hydroturbine:hydro_turbine_on", {
	drawtype = "nodebox",
	tiles = {"jeija_hydro_turbine_on.png"},
	drop = "mesecons_hydroturbine:hydro_turbine_off 1",
	groups = {dig_immediate=2,not_in_creative_inventory=1},
	description="Water Turbine",
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.5, 1.15, -0.1, 0.5, 1.45, 0.1},
			{-0.1, 1.15, -0.5, 0.1, 1.45, 0.5}},
	},
	node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.15, 0.5, -0.15, 0.15, 1.45, 0.15},
			{-0.5, 1.15, -0.1, 0.5, 1.45, 0.1},
			{-0.1, 1.15, -0.5, 0.1, 1.45, 0.5}},
	},
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on
	}}
})


minetest.register_abm({
nodenames = {"mesecons_hydroturbine:hydro_turbine_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local waterpos={x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.get_node(waterpos).name=="default:water_flowing" then
			minetest.add_node(pos, {name="mesecons_hydroturbine:hydro_turbine_on"})
			nodeupdate(pos)
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm({
nodenames = {"mesecons_hydroturbine:hydro_turbine_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local waterpos={x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.get_node(waterpos).name~="default:water_flowing" then
			minetest.add_node(pos, {name="mesecons_hydroturbine:hydro_turbine_off"})
			nodeupdate(pos)
			mesecon:receptor_off(pos)
		end
	end,
})

minetest.register_craft({
	output = "mesecons_hydroturbine:hydro_turbine_off 2",
	recipe = {
	{"","default:stick", ""},
	{"default:stick", "default:steel_ingot", "default:stick"},
	{"","default:stick", ""},
	}
})

