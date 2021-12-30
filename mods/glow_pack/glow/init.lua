-- glow/init.lua
-- mod by john and Zeg9

local light = 14

minetest.register_node("glow:stone", {
	description = "Glowing stone",
	tiles = {"glow_stone.png"},
	light_source = light,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("glow:lamp", {
	description = "Lamp",
	tiles = {"glow_stone.png^glow_lamp_frame.png"},
	light_source = light,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})


minetest.register_craft( {
	output = '"glow:stone" 2',
	recipe = {
		{'default:stone','default:coal_lump','default:stone'}
	},
})

minetest.register_craft( {
	output = '"glow:lamp" 6',
	recipe = {
		{'default:stick', 'default:glass', 'default:stick'},
		{'default:glass', 'glow:stone',    'default:glass'},
		{'default:stick', 'default:glass', 'default:stick'},
	},
})

minetest.register_alias("glow:lantern", "glow:lamp")
