-- MESECON_SWITCH

minetest.register_node("mesecons_switch:mesecon_switch_off", {
	tiles = {"jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_off.png"},
	paramtype2="facedir",
	groups = {dig_immediate=2},
	description="Switch",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_punch = function(pos, node)
		minetest.swap_node(pos, {name = "mesecons_switch:mesecon_switch_on", param2 = node.param2})
		mesecon:receptor_on(pos)
		minetest.sound_play("mesecons_switch", {pos=pos})
	end
})

minetest.register_node("mesecons_switch:mesecon_switch_on", {
	tiles = {"jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_side.png", "jeija_mesecon_switch_on.png"},
	paramtype2="facedir",
	groups = {dig_immediate=2,not_in_creative_inventory=1},
	drop="mesecons_switch:mesecon_switch_off 1",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_punch = function(pos, node)
		minetest.swap_node(pos, {name = "mesecons_switch:mesecon_switch_off", param2 = node.param2})
		mesecon:receptor_off(pos)
		minetest.sound_play("mesecons_switch", {pos=pos})
	end
})

minetest.register_craft({
	output = "mesecons_switch:mesecon_switch_off 2",
	recipe = {
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		{"group:mesecon_conductor_craftable","", "group:mesecon_conductor_craftable"},
	}
})
