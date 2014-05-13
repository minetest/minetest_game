-- WALL BUTTON
-- A button that when pressed emits power for 1 second
-- and then turns off again

mesecon.button_turnoff = function (pos)
	local node = minetest.get_node(pos)
	if node.name=="mesecons_button:button_on" then --has not been dug
		minetest.swap_node(pos, {name = "mesecons_button:button_off", param2=node.param2})
		minetest.sound_play("mesecons_button_pop", {pos=pos})
		local rules = mesecon.rules.buttonlike_get(node)
		mesecon:receptor_off(pos, rules)
	end
end

minetest.register_node("mesecons_button:button_off", {
	drawtype = "nodebox",
	tiles = {
	"jeija_wall_button_sides.png",	
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_sides.png",
	"jeija_wall_button_off.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
	type = "fixed",
		fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
	},
	node_box = {
		type = "fixed",	
		fixed = {
		{ -6/16, -6/16, 6/16, 6/16, 6/16, 8/16 },	-- the thin plate behind the button
		{ -4/16, -2/16, 4/16, 4/16, 2/16, 6/16 }	-- the button itself
	}
	},
	groups = {dig_immediate=2, mesecon_needs_receiver = 1},
	description = "Button",
	on_punch = function (pos, node)
		minetest.swap_node(pos, {name = "mesecons_button:button_on", param2=node.param2})
		mesecon:receptor_on(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_button_push", {pos=pos})
		minetest.after(1, mesecon.button_turnoff, pos)
	end,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.buttonlike_get
	}}
})

minetest.register_node("mesecons_button:button_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_sides.png",
		"jeija_wall_button_on.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	light_source = LIGHT_MAX-7,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
	},
	node_box = {
	type = "fixed",
	fixed = {
		{ -6/16, -6/16,  6/16, 6/16, 6/16, 8/16 },
		{ -4/16, -2/16, 11/32, 4/16, 2/16, 6/16 }
	}
    },
	groups = {dig_immediate=2, not_in_creative_inventory=1, mesecon_needs_receiver = 1},
	drop = 'mesecons_button:button_off',
	description = "Button",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.buttonlike_get
	}}
})

minetest.register_craft({
	output = "mesecons_button:button_off 2",
	recipe = {
		{"group:mesecon_conductor_craftable","default:stone"},
	}
})
