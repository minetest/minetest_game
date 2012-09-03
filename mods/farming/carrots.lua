minetest.register_craftitem("farming:carrot_seed", {
	description = "Carrot Seeds",
	inventory_image = "farming_carrot_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.env:get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "farming:carrot_1"
			minetest.env:set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("farming:carrot_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_carrot_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+3/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:carrot_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_carrot_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+5/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:carrot_3", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_carrot_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+12/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:carrot", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_carrot_4.png"},
	drop = {
		max_items = 6,
		items = {
			{ items = {'farming:carrot_seed'} },
			{ items = {'farming:carrot_seed'}, rarity = 2},
			{ items = {'farming:carrot_seed'}, rarity = 5},
			{ items = {'farming:carrot_item'} },
			{ items = {'farming:carrot_item'}, rarity = 2 },
			{ items = {'farming:carrot_item'}, rarity = 5 }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craftitem("farming:carrot_item", {
	description = "Carrot",
	inventory_image = "farming_carrot.png",
	on_use = minetest.item_eat(3),
})

farming:add_plant("farming:carrot", {"farming:carrot_1", "farming:carrot_2", "farming:carrot_3"}, 50, 20)
