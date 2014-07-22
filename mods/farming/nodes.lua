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
	tiles = {"farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative_inventory=1, soil=2, grassland = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node("farming:soil_wet", {
	description = "Wet Soil",
	tiles = {"farming_soil_wet.png", "farming_soil_wet_side.png"},
	drop = "default:dirt",
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative_inventory=1, soil=3, wet = 1, grassland = 1},
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
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative_inventory = 1, falling_node=1, sand=1, soil = 2, desert = 1},
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
	tiles = {"farming_desert_sand_soil_wet.png", "farming_desert_sand_soil_wet_side.png"},
	is_ground_content = true,
	groups = {crumbly=3, falling_node=1, sand=1, not_in_creative_inventory=1, soil=3, wet = 1, desert = 1},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "default:desert_sand",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})

minetest.register_abm({
	nodenames = {"group:soil", "group:wet"},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		node = minetest.registered_nodes[node.name]
		pos.y = pos.y-1
		
		if node.soil == nil or node.soil.wet == nil or node.soil.base == nil or node.soil.dry == nil then
			return
		end
		
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable and minetest.get_item_group(nn, "plant") == 0 and node.name ~= node.soil.base then
			minetest.set_node(pos, {name = node.soil.base})
		end
		-- check if there is water nearby
		if minetest.find_node_near(pos, 3, {"group:water"}) then
			-- if it is dry soil and not base node, turn it into wet soil
			if node.name ~= node.soil.base and minetest.get_item_group(node.name, "wet") == 0 then
				minetest.set_node(pos, {name = node.soil.wet})
			end
		else
			-- turn it back into base if it is already dry
			if minetest.get_item_group(node.name, "wet") == 0 then
				-- only turn it back if there is no plant/seed on top of it
				if minetest.get_item_group(nn, "plant") == 0 and minetest.get_item_group(nn, "seed") == 0 then
					minetest.set_node(pos, {name = node.soil.base})
				end
				
			-- if its wet turn it back into dry soil
			elseif minetest.get_item_group(node.name, "wet") == 1 then
				minetest.set_node(pos, {name = node.soil.dry})
			end
		end
	end,
})


for i = 1, 5 do		
	minetest.override_item("default:grass_"..i, {drop = {
		max_items = 1,
		items = {
			{items = {'farming:seed_wheat'},rarity = 5},
			{items = {'default:grass_1'}},
		}
	}})
end
	
minetest.override_item("default:junglegrass", {drop = {
	max_items = 1,
	items = {
		{items = {'farming:seed_cotton'},rarity = 8},
		{items = {'default:junglegrass'}},
	}
}})
