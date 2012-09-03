minetest.register_craftitem("farming:orange_seed", {
	description = "Orange Seeds",
	inventory_image = "farming_orange_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.env:get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "farming:orange_1"
			minetest.env:set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("farming:orange_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_orange_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+3/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:orange_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_orange_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+8/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:orange_3", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_orange_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+14/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:orange", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_orange_4.png"},
	drop = {
		max_items = 6,
		items = {
			{ items = {'farming:orange_seed'} },
			{ items = {'farming:orange_seed'}, rarity = 2},
			{ items = {'farming:orange_seed'}, rarity = 5},
			{ items = {'farming:orange_item'} },
			{ items = {'farming:orange_item'}, rarity = 2 },
			{ items = {'farming:orange_item'}, rarity = 5 }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craftitem("farming:orange_item", {
	description = "Orange",
	inventory_image = "farming_orange.png",
	on_use = minetest.item_eat(4),
})

farming:add_plant("farming:orange", {"farming:orange_1", "farming:orange_2", "farming:orange_3"}, 50, 20)
