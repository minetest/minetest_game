-- WALL LEVER
-- Basically a switch that can be attached to a wall
-- Powers the block 2 nodes behind (using a receiver)
minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_bottom.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_off.png",
	},
	inventory_image = "jeija_wall_lever_off.png",
	wield_image = "jeija_wall_lever_off.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, 3/16, 8/16, 8/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {{ -6/16, -6/16, 6/16, 6/16,  6/16, 8/16 },	-- the base "slab"
			 { -5/16, -3/16, 5/16, 5/16,  3/16, 6/16 },	-- the lighted ring area
			 { -4/16, -2/16, 4/16, 4/16,  2/16, 5/16 },	-- the raised bit that the lever "sits" on
			 { -2/16, -1/16, 3/16, 2/16,  1/16, 4/16 },	-- the lever "hinge"
			 { -1/16, -8/16, 4/16, 1/16,  0,    6/16 }}	-- the lever itself.
	},
	groups = {dig_immediate=2, mesecon_needs_receiver = 1},
	description="Lever",
	on_punch = function (pos, node)
		minetest.swap_node(pos, {name = "mesecons_walllever:wall_lever_on", param2 = node.param2})
		mesecon:receptor_on(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_lever", {pos=pos})
	end,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.off
	}}
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_top.png",
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_on.png",
	},
	inventory_image = "jeija_wall_lever_on.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	light_source = LIGHT_MAX-7,
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, 3/16, 8/16, 8/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {{ -6/16, -6/16,  6/16, 6/16, 6/16,  8/16 },	-- the base "slab"
			 { -5/16, -3/16,  5/16, 5/16, 3/16,  6/16 },	-- the lighted ring area
			 { -4/16, -2/16,  4/16, 4/16, 2/16,  5/16 },	-- the raised bit that the lever "sits" on
			 { -2/16, -1/16,  3/16, 2/16, 1/16,  4/16 },	-- the lever "hinge"
			 { -1/16,  0,     4/16, 1/16, 8/16,  6/16 }}	-- the lever itself.
	},
	groups = {dig_immediate = 2, not_in_creative_inventory = 1, mesecon_needs_receiver = 1},
	drop = "mesecons_walllever:wall_lever_off 1",
	description="Lever",
	on_punch = function (pos, node)
		minetest.swap_node(pos, {name = "mesecons_walllever:wall_lever_off", param2 = node.param2})
		mesecon:receptor_off(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_lever", {pos=pos})
	end,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.on
	}}
})

minetest.register_craft({
	output = "mesecons_walllever:wall_lever_off 2",
	recipe = {
	    {"group:mesecon_conductor_craftable"},
		{"default:stone"},
		{"default:stick"},
	}
})
