-- Global farming namespace

farming = {}
farming.path = minetest.get_modpath("farming")


-- Load files

dofile(farming.path .. "/api.lua")
dofile(farming.path .. "/nodes.lua")
dofile(farming.path .. "/hoes.lua")


-- Wheat

farming.register_plant("farming:wheat", {
	description = "Wheat seed",
	inventory_image = "farming_wheat_seed.png",
	steps = 8,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"}
})

minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
})

minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	on_use = minetest.item_eat(5),
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {"farming:wheat", "farming:wheat", "farming:wheat", "farming:wheat"}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:bread",
	recipe = "farming:flour"
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wheat",
	burntime = 2,
})


-- Cotton

farming.register_plant("farming:cotton", {
	description = "Cotton seed",
	inventory_image = "farming_cotton_seed.png",
	steps = 8,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland", "desert"}
})

minetest.register_alias("farming:string", "farming:cotton")

minetest.register_craft({
	output = "wool:white",
	recipe = {
		{"farming:cotton", "farming:cotton"},
		{"farming:cotton", "farming:cotton"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:cotton",
	burntime = 2,
})


-- Straw

minetest.register_craft({
	output = "farming:straw",
	recipe = {
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
	}
})

minetest.register_craft({
	output = "farming:straw",
	recipe = {
		{"default:dry_grass_1", "default:dry_grass_1", "default:dry_grass_1"},
		{"default:dry_grass_1", "default:dry_grass_1", "default:dry_grass_1"},
		{"default:dry_grass_1", "default:dry_grass_1", "default:dry_grass_1"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:straw",
	burntime = 18,
})
