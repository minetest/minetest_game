walls = {}

walls.register = function(wall_name, wall_desc, wall_texture_table, wall_mat, wall_sounds)
	--make wall_texture_table paramenter backwards compatible for mods passing single texture
	if type(wall_texture_table) ~= "table" then
		wall_texture_table = { wall_texture_table }
	end
	-- inventory node, and pole-type wall start item
	minetest.register_node(wall_name, {
		description = wall_desc,
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{-1/4, -1/2, -1/4, 1/4, 1/2, 1/4}},
			-- connect_bottom =
			connect_front = {{-3/16, -1/2, -1/2,  3/16, 3/8, -1/4}},
			connect_left = {{-1/2, -1/2, -3/16, -1/4, 3/8,  3/16}},
			connect_back = {{-3/16, -1/2,  1/4,  3/16, 3/8,  1/2}},
			connect_right = {{ 1/4, -1/2, -3/16,  1/2, 3/8,  3/16}},
		},
		connects_to = { "group:wall", "group:stone", "group:fence" },
		paramtype = "light",
		is_ground_content = false,
		tiles = wall_texture_table,
		walkable = true,
		groups = { cracky = 3, wall = 1, stone = 2 },
		sounds = wall_sounds,
				after_place_node = function(pos, placer, itemstack, pointed_thing)
			local pos_under = {x = pos.x, y = pos.y - 1, z = pos.z}
			local pos_above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local node_under = string.gsub(minetest.get_node(pos_under).name, "_full$", "")
			local node_above = string.gsub(minetest.get_node(pos_above).name, "_full$", "")

			if minetest.get_item_group(node_under, "wall") == 1 then
				minetest.set_node(pos_under, {name = node_under .. "_full"})
			end
			if minetest.get_item_group(node_above, "wall") == 1 then
				minetest.set_node(pos, {name = wall_name .. "_full"})
			end
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			local pos_under = {x = pos.x, y = pos.y - 1, z = pos.z}
			local node_under = string.gsub(minetest.get_node(pos_under).name, "_full$", "")
			if minetest.get_item_group(node_under, "wall") == 1 and
					digger and digger:is_player() then
				minetest.set_node(pos_under, {name = node_under})
			end
		end,
	})

	minetest.register_node(wall_name .. "_full", {
		description = wall_desc,
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{-1/4, -1/2, -1/4, 1/4, 1/2, 1/4}},
			connect_front = {{-3/16, -1/2, -1/2,  3/16, 1/2, -1/4}},
			connect_left = {{-1/2, -1/2, -3/16, -1/4, 1/2,  3/16}},
			connect_back = {{-3/16, -1/2,  1/4,  3/16, 1/2,  1/2}},
			connect_right = {{ 1/4, -1/2, -3/16,  1/2, 1/2,  3/16}},
		},
		connects_to = {"group:wall", "group:stone", "group:fence"},
		paramtype = "light",
		is_ground_content = false,
		tiles = wall_texture_table,
		groups = {cracky = 3, wall = 1, stone = 2, not_in_creative_inventory = 1},
		sounds = wall_sounds,
		drop = wall_name,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			local pos_under = {x = pos.x, y = pos.y - 1, z = pos.z}
			local node_under = string.gsub(minetest.get_node(pos_under).name, "_full$", "")
			if minetest.get_item_group(node_under, "wall") == 1 and
					digger and digger:is_player() then
				minetest.set_node(pos_under, {name = node_under})
			end
		end,
	})

	-- crafting recipe
	minetest.register_craft({
		output = wall_name .. " 6",
		recipe = {
			{ '', '', '' },
			{ wall_mat, wall_mat, wall_mat},
			{ wall_mat, wall_mat, wall_mat},
		}
	})

end

walls.register("walls:cobble", "Cobblestone Wall", {"default_cobble.png"},
		"default:cobble", default.node_sound_stone_defaults())

walls.register("walls:mossycobble", "Mossy Cobblestone Wall", {"default_mossycobble.png"},
		"default:mossycobble", default.node_sound_stone_defaults())

walls.register("walls:desertcobble", "Desert Cobblestone Wall", {"default_desert_cobble.png"},
		"default:desert_cobble", default.node_sound_stone_defaults())

