minetest.register_craftitem("farming:cotton_seed", {
	description = "Cotton Seeds",
	inventory_image = "farming_cotton_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.env:get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "farming:cotton_1"
			minetest.env:set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("farming:cotton_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_cotton_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+6/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:cotton_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"farming_cotton_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+12/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:cotton", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_cotton.png"},
	drop = {
		max_items = 6,
		items = {
			{ items = {'farming:cotton_seed'} },
			{ items = {'farming:cotton_seed'}, rarity = 2},
			{ items = {'farming:cotton_seed'}, rarity = 5},
			{ items = {'farming:string'} },
			{ items = {'farming:string'}, rarity = 2 },
			{ items = {'farming:string'}, rarity = 5 }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
})

farming:add_plant("farming:cotton", {"farming:cotton_1", "farming:cotton_2"}, 50, 20)

minetest.register_craftitem("farming:string", {
	description = "String",
	inventory_image = "farming_string.png",
})

minetest.register_craft({
	output = "wool:white",
	recipe = {{"farming:string"}}
})

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming:cotton_seed",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:string",
	burntime = 1
})
