function beds.register_bed(name, def)
	minetest.register_node(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		drawtype = "mesh",
		mesh = def.mesh,
		tiles = def.tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		stack_max = 1,
		groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, bed=1},
		sounds = default.node_sound_wood_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 1.5},
		},
		collision_box = {
			type = "fixed",
			fixed = def.collisionbox,
		},
		after_place_node = function(pos, placer, itemstack)
			local n = minetest.get_node_or_nil(pos)
			if not n or not n.param2 then
				minetest.remove_node(pos)
				return true
			end
			local dir = minetest.facedir_to_dir(n.param2)
			local p = {x=pos.x+dir.x,y=pos.y,z=pos.z+dir.z}
			local n2 = minetest.get_node_or_nil(p)
			local def = minetest.registered_items[n2.name] or nil
			if not n2 or not def or not def.buildable_to then
				minetest.remove_node(pos)
				minetest.chat_send_player(placer:get_player_name(), "No room to place the bed!")
				return true
			end
			minetest.set_node(p, {name = n.name, param2 = n.param2})
			return false
		end,
		on_rightclick = function(pos, node, clicker)
			beds.on_rightclick(pos, clicker)
		end,
	})

	minetest.register_alias(name .. "_bottom", name)
	minetest.register_alias(name .. "_top", "air")

	-- register recipe
	minetest.register_craft({
		output = name,
		recipe = def.recipe
	})
end
