function beds.register_bed(name, def)
	minetest.register_node(name .. "_bottom", {
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		drawtype = "nodebox",
		tiles = def.tiles.bottom,
		paramtype = "light",
		paramtype2 = "facedir",
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
		on_construct = function(pos)
			local n = minetest.get_node(pos)
			local p = vector.add(pos, minetest.facedir_to_dir(n.param2))
			local n2 = minetest.get_node_or_nil(p)
			local def = minetest.registered_nodes[n2.name]
			if n2
			and def
			and def.buildable_to then
				minetest.set_node(p, {name = name.."_top", param2 = n.param2})
			end
		end,
		after_place_node = function(pos, placer, itemstack)
			local n = minetest.get_node_or_nil(pos)
			if not n or not n.param2 then
				minetest.remove_node(pos)
				return true
			end
			local n2 = minetest.get_node_or_nil(vector.add(pos, minetest.facedir_to_dir(n.param2)))
			if n2
			and n2.param2 == n.param2
			and n2.name == name.."_top" then
				return false
			end
			minetest.remove_node(pos)
			return true
		end,
		on_destruct = function(pos)
			local n = minetest.get_node_or_nil(pos)
			if not n then
				return
			end
			local dir = minetest.facedir_to_dir(n.param2)
			local p = vector.add(pos, dir)
			local n2 = minetest.get_node(p)
			if minetest.get_item_group(n2.name, "bed") == 2
			and n.param2 == n2.param2 then
				minetest.remove_node(p)
			end
		end,
		on_rightclick = function(pos, node, clicker)
			beds.on_rightclick(pos, clicker)
		end,
	})

	minetest.register_node(name .. "_top", {
		drawtype = "nodebox",
		tiles = def.tiles.top,
		paramtype = "light",
		paramtype2 = "facedir",
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
