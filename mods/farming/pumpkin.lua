minetest.register_craftitem("farming:pumpkin_seed", {
	description = "Pumpkin Seed",
	inventory_image = "farming_pumpkin_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.env:get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "farming:pumpkin_1"
			minetest.env:set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("farming:pumpkin_1", {
	paramtype = "light",
	drawtype = "nodebox",
	drop = "",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
		},
	},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("farming:pumpkin_2", {
	paramtype = "light",
	drawtype = "nodebox",
	drop = "",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png"},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.35, -0.5, -0.35, 0.35, 0.2, 0.35}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.35, -0.5, -0.35, 0.35, 0.2, 0.35}
		},
	},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2, not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("farming:pumpkin", {
	description = "Pumpkin",
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	
	on_punch = function(pos, node, puncher)
		local tool = puncher:get_wielded_item():get_name()
		if tool and tool == "default:sword_wood" or tool == "default:sword_stone" or tool == "default:sword_steel" then
			node.name = "farming:pumpkin_face"
			minetest.env:set_node(pos, node)
			puncher:get_inventory():add_item("main", ItemStack("farming:pumpkin_seed"))
			if math.random(1, 5) == 1 then
				puncher:get_inventory():add_item("main", ItemStack("farming:pumpkin_seed"))
			end
		end
	end
})

farming:add_plant("farming:pumpkin", {"farming:pumpkin_1", "farming:pumpkin_2"}, 80, 20)

minetest.register_node("farming:pumpkin_face", {
	description = "Pumpkin",
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("farming:pumpkin_face_light", {
	description = "Pumpkin",
	paramtype2 = "facedir",
	light_source = LIGHT_MAX-2,
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face_light.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:pumpkin_face_light",
	recipe = {"farming:pumpkin_face", "default:torch"}
})

-- ========= BIG PUMPKIN =========
minetest.register_node("farming:big_pumpkin", {
	description = "Big Pumpkin",
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_big_side.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1, -0.5, -1, 1, 1.5, 1}
		}
	},
	groups = {choppy=1, oddly_breakable_by_hand=1, flammable=2},
	sounds = default.node_sound_wood_defaults(),
	
	after_place_node = function(pos, placer)
		for dx=-1,1 do
			for dy=0,1 do
				for dz=-1,1 do
					pos.x = pos.x+dx
					pos.y = pos.y+dy
					pos.z = pos.z+dz
					if dx ~= 0 or dy ~= 0 or dz ~= 0 then
						if minetest.env:get_node(pos).name ~= "air" then
							pos.x = pos.x-dx
							pos.y = pos.y-dy
							pos.z = pos.z-dz
							minetest.env:remove_node(pos)
							minetest.after(0.1, function(placer)
								local inv = placer:get_inventory()
								local index = placer:get_wield_index()
								inv:set_stack("main", index, ItemStack("farming:big_pumpkin"))
							end, placer)
							return
						end
					end
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end
		for dy=0,1 do
			pos.y = pos.y+dy
			pos.z = pos.z+1
			minetest.env:set_node(pos, {name="farming:big_pumpkin_side", param2=2})
			pos.x = pos.x-1
			minetest.env:set_node(pos, {name="farming:big_pumpkin_corner", param2=2})
			pos.x = pos.x+1
			pos.z = pos.z-2
			minetest.env:set_node(pos, {name="farming:big_pumpkin_side", param2=4})
			pos.x = pos.x+1
			minetest.env:set_node(pos, {name="farming:big_pumpkin_corner", param2=4})
			pos.z = pos.z+1
			minetest.env:set_node(pos, {name="farming:big_pumpkin_side", param2=3})
			pos.z = pos.z+1
			minetest.env:set_node(pos, {name="farming:big_pumpkin_corner", param2=3})
			pos.z = pos.z-1
			pos.x = pos.x-2
			minetest.env:set_node(pos, {name="farming:big_pumpkin_side", param2=1})
			pos.z = pos.z-1
			minetest.env:set_node(pos, {name="farming:big_pumpkin_corner", param2=1})
			pos.z = pos.z+1
			pos.x = pos.x+1
			pos.y = pos.y-dy
		end
		pos.y = pos.y+1
		minetest.env:set_node(pos, {name="farming:big_pumpkin_top"})
	end,
	
	after_destruct = function(pos, oldnode)
		for dx=-1,1 do
			for dy=0,1 do
				for dz=-1,1 do
					pos.x = pos.x+dx
					pos.y = pos.y+dy
					pos.z = pos.z+dz
					local name = minetest.env:get_node(pos).name
					if string.find(name, "farming:big_pumpkin") then
						minetest.env:remove_node(pos)
					end
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end
	end
})

minetest.register_node("farming:big_pumpkin_side", {
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_big_top_side.png", "farming_pumpkin_big_side.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0, 0, 0}
		}
	},
	groups = {not_in_creative_inventory=1},
})
minetest.register_node("farming:big_pumpkin_corner", {
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_big_top_corner.png", "farming_pumpkin_big_side.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0, 0.5, 0.5}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0, 0, 0}
		}
	},
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("farming:big_pumpkin_top", {
	paramtype = "light",
	tiles = {"farming_pumpkin_big_top.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0, 0, 0}
		}
	},
	groups = {not_in_creative_inventory=1},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:big_pumpkin",
	recipe = {"bucket:bucket_water", "farming:pumpkin"},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"}
	}
})

-- ========= SCARECROW =========
local box1 = {
	{-1, -8, -1, 1, 8, 1},
}

local box2 = {
	{-1, -8, -1, 1, 8, 1},
	{-12, -8, -1, 12, -7, 1},
	{-5, -2, -5, 5, 8, 5}
}

for j,list in ipairs(box1) do
	for i,int in ipairs(list) do
		list[i] = int/16
	end
	box1[j] = list
end

for j,list in ipairs(box2) do
	for i,int in ipairs(list) do
		list[i] = int/16
	end
	box2[j] = list
end

minetest.register_node("farming:scarecrow", {
	description = "Scarecrow",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"farming_scarecrow_top.png", "farming_scarecrow_top.png", "farming_scarecrow_side.png", "farming_scarecrow_side.png", "farming_scarecrow_side.png", "farming_scarecrow_front.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = box2
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-12/16, -1.5, -0.5, 12/16, 0.5, 0.5}
		}
	},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2},
	
	after_place_node = function(pos, placer)
		local node = minetest.env:get_node(pos)
		local param2 = node.param2
		pos.y = pos.y+1
		if minetest.env:get_node(pos).name ~= "air" then
			pos.y = pos.y-1
			minetest.env:remove_node(pos)
			minetest.after(0.1, function(placer)
				local inv = placer:get_inventory()
				local index = placer:get_wield_index()
				inv:set_stack("main", index, ItemStack("farming:scarecrow"))
			end, placer)
			return
		end
		minetest.env:set_node(pos, node)
		pos.y = pos.y-1
		node.name = "farming:scarecrow_bottom"
		minetest.env:set_node(pos, node)
	end,
	
	after_destruct = function(pos, oldnode)
		pos.y = pos.y-1
		if minetest.env:get_node(pos).name == "farming:scarecrow_bottom" then
			minetest.env:remove_node(pos)
		end
	end
})

minetest.register_node("farming:scarecrow_bottom", {
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = box1
	},
	groups = {not_in_creative_inventory=1},
	selection_box = {
		type = "fixed",
		fixed = {
			{0, 0, 0, 0, 0, 0}
		}
	}
})

minetest.register_craft({
	output = "farming:scarecrow",
	recipe = {
		{"", "farming:pumpkin_face", "",},
		{"default:stick", "default:stick", "default:stick",},
		{"", "default:stick", "",}
	}
})

minetest.register_node("farming:scarecrow_light", {
	description = "Scarecrow",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = LIGHT_MAX-2,
	tiles = {"farming_scarecrow_top.png", "farming_scarecrow_top.png", "farming_scarecrow_side.png", "farming_scarecrow_side.png", "farming_scarecrow_side.png", "farming_scarecrow_front_light.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = box2
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-12/16, -1.5, -0.5, 12/16, 0.5, 0.5}
		}
	},
	groups = {choppy=2, oddly_breakable_by_hand=2, flammable=2},
	
	after_place_node = function(pos, placer)
		local node = minetest.env:get_node(pos)
		local param2 = node.param2
		pos.y = pos.y+1
		if minetest.env:get_node(pos).name ~= "air" then
			pos.y = pos.y-1
			minetest.env:remove_node(pos)
			minetest.after(0.1, function(placer)
				local inv = placer:get_inventory()
				local index = placer:get_wield_index()
				inv:set_stack("main", index, ItemStack("farming:scarecrow_light"))
			end, placer)
			return
		end
		minetest.env:set_node(pos, node)
		pos.y = pos.y-1
		node.name = "farming:scarecrow_bottom"
		minetest.env:set_node(pos, node)
	end,
	
	after_destruct = function(pos, oldnode)
		pos.y = pos.y-1
		if minetest.env:get_node(pos).name == "farming:scarecrow_bottom" then
			minetest.env:remove_node(pos)
		end
	end
})

minetest.register_craft({
	output = "farming:scarecrow_light",
	recipe = {
		{"", "farming:pumpkin_face_light", "",},
		{"default:stick", "default:stick", "default:stick",},
		{"", "default:stick", "",}
	}
})

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming:pumpkin_seed",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:pumpkin",
	burntime = 5
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:pumpkin_face",
	burntime = 5
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:pumpkin_face_light",
	burntime = 7
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:big_pumpkin",
	burntime = 10
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:scarecrow",
	burntime = 5
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:scarecrow_light",
	burntime = 5
})
