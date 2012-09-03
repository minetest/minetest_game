minetest.register_craftitem("farming:strawberry_seed", {
	description = "Strawberry Seeds",
	inventory_image = "farming_strawberry_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.env:get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "farming:strawberry_1"
			minetest.env:set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("farming:strawberry_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_strawberry_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+9/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:strawberry_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_strawberry_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+12/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:strawberry_3", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_strawberry_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+14/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:strawberry", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_strawberry_4.png"},
	drop = {
		max_items = 6,
		items = {
			{ items = {'farming:strawberry_seed'} },
			{ items = {'farming:strawberry_seed'}, rarity = 2},
			{ items = {'farming:strawberry_seed'}, rarity = 5},
			{ items = {'farming:strawberry_item'} },
			{ items = {'farming:strawberry_item'}, rarity = 2 },
			{ items = {'farming:strawberry_item'}, rarity = 5 }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craftitem("farming:strawberry_item", {
	description = "Strawberry",
	inventory_image = "farming_strawberry.png",
	on_use = minetest.item_eat(2),
})

farming:add_plant("farming:strawberry", {"farming:strawberry_1", "farming:strawberry_2", "farming:strawberry_3"}, 50, 20)
