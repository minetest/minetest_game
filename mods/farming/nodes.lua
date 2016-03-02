minetest.override_item("default:dirt", {
	groups = {crumbly=3,soil=1},
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.override_item("default:dirt_with_grass", {
	groups = {crumbly=3,soil=1},
	soil = {
		base = "default:dirt_with_grass",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node("farming:soil", {
	description = "Soil",
	tiles = {"default_dirt.png^farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	groups = {
		crumbly = 3,
		not_in_creative_inventory = 1,
		soil = 2,
		grassland = 1,
		field = 1
	},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node("farming:soil_wet", {
	description = "Wet Soil",
	tiles = {
		"default_dirt.png^farming_soil_wet.png",
		"default_dirt.png^farming_soil_wet_side.png"
	},
	drop = "default:dirt",
	groups = {
		crumbly = 3,
		not_in_creative_inventory = 1,
		soil = 3,
		wet = 1,
		grassland = 1,
		field = 1
	},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.override_item("default:desert_sand", {
	groups = {crumbly=3, falling_node=1, sand=1, soil = 1},
	soil = {
		base = "default:desert_sand",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})
minetest.register_node("farming:desert_sand_soil", {
	description = "Desert Sand Soil",
	drop = "default:desert_sand",
	tiles = {"farming_desert_sand_soil.png", "default_desert_sand.png"},
	groups = {
		crumbly = 3,
		not_in_creative_inventory = 1,
		falling_node = 1,
		sand = 1,
		soil = 2,
		desert = 1,
		field = 1
	},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "default:desert_sand",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})

minetest.register_node("farming:desert_sand_soil_wet", {
	description = "Wet Desert Sand Soil",
	drop = "default:desert_sand",
	tiles = {
		"farming_desert_sand_soil_wet.png",
		"farming_desert_sand_soil_wet_side.png"
	},
	groups = {
		crumbly = 3,
		falling_node = 1,
		sand = 1,
		not_in_creative_inventory = 1,
		soil = 3,
		wet = 1,
		desert = 1,
		field = 1
	},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "default:desert_sand",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})

minetest.register_node("farming:straw", {
	description = "Straw",
	tiles = {"farming_straw.png"},
	is_ground_content = false,
	groups = {snappy=3, flammable=4},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_abm({
	nodenames = {"group:field"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		pos.y = pos.y + 1
		local nn = minetest.get_node_or_nil(pos)
		if not nn then
			return
		end
		local nn_def = minetest.registered_nodes[nn.name]
		pos.y = pos.y - 1

		local soil = minetest.registered_nodes[node.name].soil
		assert(soil, "[farming] field "..node.name.." doesn't have soil")
		local wet = soil.wet
		local base = soil.base
		local dry = soil.dry
		assert(wet and base and dry, "[farming] field "..node.name..
				"'s soil must have wet, base and dry")

		if nn_def and nn_def.walkable and
				minetest.get_item_group(nn.name, "plant") == 0 then
			node.name = base
			minetest.set_node(pos, node)
			return
		end

		-- only turn back if there are no unloaded blocks (and therefore
		-- possible water sources) nearby
		if minetest.find_node_near(pos, 3, {"ignore"}) then
			return
		end

		-- check if there is water nearby
		local wet_lvl = minetest.get_item_group(node.name, "wet")
		if minetest.find_node_near(pos, 3, {"group:water"}) then
			-- if it is dry soil and not base node, turn it into wet soil
			if wet_lvl == 0 then
				node.name = wet
				minetest.set_node(pos, node)
			end
			return
		end

		-- turn it back into base if it is already dry
		if wet_lvl == 0 then
			-- only turn it back if there is no plant/seed on top of it
			if minetest.get_item_group(nn.name, "plant") == 0 and
					minetest.get_item_group(nn.name, "seed") == 0 then
				node.name = base
				minetest.set_node(pos, node)
			end

		-- if its wet turn it back into dry soil
		elseif wet_lvl == 1 then
			node.name = dry
			minetest.set_node(pos, node)
		end
	end,
})


local defchange = {drop = {
	max_items = 1,
	items = {
		{items = {'farming:seed_wheat'},rarity = 5},
		{items = {'default:grass_1'}},
	}
}}
for i = 1, 5 do
	minetest.override_item("default:grass_"..i, defchange)
end

minetest.override_item("default:junglegrass", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:seed_cotton'},rarity = 8},
		{items = {'default:junglegrass'}},
	}
}})
