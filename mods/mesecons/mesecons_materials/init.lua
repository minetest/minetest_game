--GLUE
minetest.register_craftitem("mesecons_materials:glue", {
	image = "jeija_glue.png",
	on_place_on_ground = minetest.craftitem_place_item,
    	description="Glue",
})

minetest.register_craftitem("mesecons_materials:fiber", {
	image = "jeija_fiber.png",
	on_place_on_ground = minetest.craftitem_place_item,
    	description="Fiber",
})

minetest.register_craft({
	output = "mesecons_materials:glue 2",
	type = "cooking",
	recipe = "default:sapling",
	cooktime = 2
})

minetest.register_craft({
	output = "mesecons_materials:fiber 6",
	type = "cooking",
	recipe = "mesecons_materials:glue",
	cooktime = 4
})

-- Silicon
minetest.register_craftitem("mesecons_materials:silicon", {
	image = "jeija_silicon.png",
	on_place_on_ground = minetest.craftitem_place_item,
    	description="Silicon",
})

minetest.register_craft({
	output = "mesecons_materials:silicon 4",
	recipe = {
		{"default:sand", "default:sand"},
		{"default:sand", "default:steel_ingot"},
	}
})
