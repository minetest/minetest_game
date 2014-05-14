minetest.register_node("moontest:lightore", {
	description = "Lightore",
	tiles = {"moontest_stone.png^moontest_light_ore.png"},
	light_source = 7,
	groups = {cracky = 3, stone = 1},
	drop = "moontest:light_crystal",
})


