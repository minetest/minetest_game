function beds.register_bed(name, def)
	minetest.register_node(name .. "_bottom", {
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		drawtype = "nodebox",
		tiles = def.tiles.bottom,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		stack_max = 1,
		groups = {snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, bed = 1},
		sounds = default.node_sound_wood_defaults(),
		node_box = {
			type = "fixed",
			fixed = def.nodebox.bottom,
		},
		selection_box = {
			type = "fixed",
			fixed = def.selectionbox,

		},
		after_place_node = function(pos, placer, itemstack)
			local n = minetest.get_node_or_nil(pos)
			if not n or not n.param2 then
				minetest.remove_node(pos)
				return true
			end
			local dir = minetest.facedir_to_dir(n.param2)
			local p = vector.add(pos, dir)
			local n2 = minetest.get_node_or_nil(p)
			local def = n2 and minetest.registered_items[n2.name]
			if not def or not def.buildable_to then
				minetest.remove_node(pos)
				return true
			end
			minetest.set_node(p, {name = n.name:gsub("%_bottom", "_top"), param2 = n.param2})
			return false
		end,
		on_destruct = function(pos)
			local n = minetest.get_node_or_nil(pos)
			if not n then return end
			local dir = minetest.facedir_to_dir(n.param2)
			local p = vector.add(pos, dir)
			local n2 = minetest.get_node(p)
			if minetest.get_item_group(n2.name, "bed") == 2 and n.param2 == n2.param2 then
				minetest.remove_node(p)
			end
		end,
		on_rightclick = function(pos, node, clicker)
			beds.on_rightclick(pos, clicker)
		end,
		on_rotate = function(pos, node, user, mode, new_param2)
			local dir = minetest.facedir_to_dir(node.param2)
			local p = vector.add(pos, dir)
			local node2 = minetest.get_node_or_nil(p)
			if not node2 or not minetest.get_item_group(node2.name, "bed") == 2 or
					not node.param2 == node2.param2 then
				return false
			end
			if minetest.is_protected(p, user:get_player_name()) then
				minetest.record_protection_violation(p, user:get_player_name())
				return false
			end
			if mode ~= screwdriver.ROTATE_FACE then
				return false
			end
			local newp = vector.add(pos, minetest.facedir_to_dir(new_param2))
			local node3 = minetest.get_node_or_nil(newp)
			local def = node3 and minetest.registered_nodes[node3.name]
			if not def or not def.buildable_to then
				return false
			end
			if minetest.is_protected(newp, user:get_player_name()) then
				minetest.record_protection_violation(newp, user:get_player_name())
				return false
			end
			node.param2 = new_param2
			minetest.swap_node(pos, node)
			minetest.remove_node(p)
			minetest.set_node(newp, {name = node.name:gsub("%_bottom", "_top"), param2 = new_param2})
			return true
		end,
	})

	minetest.register_node(name .. "_top", {
		drawtype = "nodebox",
		tiles = def.tiles.top,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, bed = 2},
		sounds = default.node_sound_wood_defaults(),
		node_box = {
			type = "fixed",
			fixed = def.nodebox.top,
		},
		selection_box = {
			type = "fixed",
			fixed = {0, 0, 0, 0, 0, 0},
		},
	})

	minetest.register_alias(name, name .. "_bottom")

	-- register recipe
	minetest.register_craft({
		output = name,
		recipe = def.recipe
	})
end
