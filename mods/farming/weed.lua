minetest.register_node("farming:weed", {
	description = "Weed",
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_weed.png"},
	inventory_image = "farming_weed.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+4/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_abm({
	nodenames = {"farming:soil_wet", "farming:soil"},
	interval = 50,
	chance = 10,
	action = function(pos, node)
		if minetest.env:find_node_near(pos, 4, {"farming:scarecrow", "farming:scarecrow_light"}) ~= nil then
			return
		end
		pos.y = pos.y+1
		if minetest.env:get_node(pos).name == "air" then
			node.name = "farming:weed"
			minetest.env:set_node(pos, node)
		end
	end
})

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming:weed",
	burntime = 1
})