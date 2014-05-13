local lightstone_rules = {
	{x=0,  y=0,  z=-1},
	{x=1,  y=0,  z=0},
	{x=-1, y=0,  z=0},
	{x=0,  y=0,  z=1},
	{x=1,  y=1,  z=0},
	{x=1,  y=-1, z=0},
	{x=-1, y=1,  z=0},
	{x=-1, y=-1, z=0},
	{x=0,  y=1,  z=1},
	{x=0,  y=-1, z=1},
	{x=0,  y=1,  z=-1},
	{x=0,  y=-1, z=-1},
	{x=0,  y=-1, z=0},
}

function mesecon:lightstone_add(name, base_item, texture_off, texture_on)
	minetest.register_node("mesecons_lightstone:lightstone_" .. name .. "_off", {
		tiles = {texture_off},
		groups = {cracky=2, mesecon_effector_off = 1, mesecon = 2},
		description=name.." Lightstone",
		sounds = default.node_sound_stone_defaults(),
		mesecons = {effector = {
			rules = lightstone_rules,
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "mesecons_lightstone:lightstone_" .. name .. "_on", param2 = node.param2})
			end,
		}}
	})
	minetest.register_node("mesecons_lightstone:lightstone_" .. name .. "_on", {
	tiles = {texture_on},
	groups = {cracky=2,not_in_creative_inventory=1, mesecon = 2},
	drop = "mesecons_lightstone:lightstone_" .. name .. "_off",
	light_source = LIGHT_MAX-2,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		rules = lightstone_rules,
		action_off = function (pos, node)
			minetest.swap_node(pos, {name = "mesecons_lightstone:lightstone_" .. name .. "_off", param2 = node.param2})
		end,
	}}
	})

	minetest.register_craft({
		output = "mesecons_lightstone:lightstone_" .. name .. "_off",
		recipe = {
			{"",base_item,""},
			{base_item,"default:torch",base_item},
			{"","group:mesecon_conductor_craftable",""}
		}
	})
end


mesecon:lightstone_add("red", "default:clay_brick", "jeija_lightstone_red_off.png", "jeija_lightstone_red_on.png")
mesecon:lightstone_add("green", "default:cactus", "jeija_lightstone_green_off.png", "jeija_lightstone_green_on.png")
mesecon:lightstone_add("blue", "mesecons_materials:fiber", "jeija_lightstone_blue_off.png", "jeija_lightstone_blue_on.png")
mesecon:lightstone_add("gray", "default:cobble", "jeija_lightstone_gray_off.png", "jeija_lightstone_gray_on.png")
mesecon:lightstone_add("darkgray", "default:gravel", "jeija_lightstone_darkgray_off.png", "jeija_lightstone_darkgray_on.png")
mesecon:lightstone_add("yellow", "default:mese_crystal_fragment", "jeija_lightstone_yellow_off.png", "jeija_lightstone_yellow_on.png")
