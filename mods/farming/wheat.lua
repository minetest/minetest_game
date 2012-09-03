minetest.register_craftitem("farming:wheat_seed", {
	description = "Wheat Seeds",
	inventory_image = "farming_wheat_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.env:get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "farming:wheat_1"
			minetest.env:set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("farming:wheat_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_wheat_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+4/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:wheat_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_wheat_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+7/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:wheat_3", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_wheat_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+13/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:wheat", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_wheat.png"},
	drop = {
		max_items = 4,
		items = {
			{ items = {'farming:wheat_seed'} },
			{ items = {'farming:wheat_seed'}, rarity = 2},
			{ items = {'farming:wheat_seed'}, rarity = 5},
			{ items = {'farming:wheat_harvested'} }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

farming:add_plant("farming:wheat", {"farming:wheat_1", "farming:wheat_2", "farming:wheat_3"}, 50, 20)

minetest.register_craftitem("farming:wheat_harvested", {
	description = "Harvested Wheat",
	inventory_image = "farming_wheat_harvested.png",
})

minetest.register_craft({
	output = "farming:flour",
	recipe = {
		{"farming:wheat_harvested", }
	}
})

minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
})

minetest.register_craft({
	output = "farming:cake_mix",
	type = "shapeless",
	recipe = {"farming:flour", "farming:flour", "farming:flour", "farming:flour", "bucket:bucket_water"},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
})

minetest.register_craftitem("farming:cake_mix", {
	description = "Cake Mix",
	inventory_image = "farming_cake_mix.png",
})

minetest.register_craft({
	type = "cooking",
	output = "farming:bread",
	recipe = "farming:cake_mix",
	cooktime = 10
})

minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	stack_max = 1,
	on_use = minetest.item_eat(10)
})

minetest.register_craftitem("farming:pumpkin_bread", {
	description = "Pumpkin Bread",
	inventory_image = "farming_bread_pumpkin.png",
	stack_max = 1,
	on_use = minetest.item_eat(20)
})

minetest.register_craftitem("farming:pumpkin_cake_mix", {
	description = "Pumpkin Cake Mix",
	inventory_image = "farming_cake_mix_pumpkin.png",
})

minetest.register_craft({
	output = "farming:pumpkin_cake_mix",
	type = "shapeless",
	recipe = {"farming:cake_mix", "farming:pumpkin"}
})

minetest.register_craft({
	type = "cooking",
	output = "farming:pumpkin_bread",
	recipe = "farming:pumpkin_cake_mix",
	cooktime = 10
})

minetest.register_alias("farming:corn_seed", "farming:wheat_seed")
minetest.register_alias("farming:corn_1", "farming:wheat_1")
minetest.register_alias("farming:corn_2", "farming:wheat_2")
minetest.register_alias("farming:corn_3", "farming:wheat_3")
minetest.register_alias("farming:corn", "farming:wheat")
minetest.register_alias("farming:corn_harvested", "farming:wheat_harvested")

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming:wheat_seed",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:wheat_harvested",
	burntime = 2
})
