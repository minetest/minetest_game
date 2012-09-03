local function create_soil(pos, inv, p)
	if pos == nil then
		return false
	end
	local node = minetest.env:get_node(pos)
	local name = node.name
	local above = minetest.env:get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if name == "default:dirt" or name == "default:dirt_with_grass" then
		if above.name == "air" then
			node.name = "farming:soil"
			minetest.env:set_node(pos, node)
			if inv and p and name == "default:dirt_with_grass" then
				for name,rarity in pairs(farming.seeds) do
					if math.random(1, rarity-p) == 1 then
						inv:add_item("main", ItemStack(name))
					end
				end
			end
			return true
		end
	end
	return false
end

minetest.register_tool("farming:hoe_wood", {
	description = "Wood Hoe",
	inventory_image = "farming_hoe_wood.png",
	on_use = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory(), 0) then
			itemstack:add_wear(65535/30)
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_wood",
	recipe = {
		{"default:wood", "default:wood"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})

minetest.register_tool("farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_hoe_stone.png",
	on_use = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory(), 5) then
			itemstack:add_wear(65535/50)
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_stone",
	recipe = {
		{"default:cobble", "default:cobble"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})

minetest.register_tool("farming:hoe_steel", {
	description = "Steel Hoe",
	inventory_image = "farming_hoe_steel.png",
	on_use = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory(), 10) then
			itemstack:add_wear(65535/80)
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})
