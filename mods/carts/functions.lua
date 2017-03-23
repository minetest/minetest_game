local S, NS = dofile(minetest.get_modpath(minetest.get_current_modname()).."/intllib.lua")

function carts:get_sign(z)
	if z == 0 then
		return 0
	else
		return z / math.abs(z)
	end
end

function carts:manage_attachment(player, obj)
	if not player then
		return
	end
	local status = obj ~= nil
	local player_name = player:get_player_name()
	if default.player_attached[player_name] == status then
		return
	end
	default.player_attached[player_name] = status

	if status then
		player:set_attach(obj, "", {x=0, y=6, z=0}, {x=0, y=0, z=0})
		player:set_eye_offset({x=0, y=-4, z=0},{x=0, y=-4, z=0})
	else
		player:set_detach()
		player:set_eye_offset({x=0, y=0, z=0},{x=0, y=0, z=0})
	end
end

function carts:velocity_to_dir(v)
	if math.abs(v.x) > math.abs(v.z) then
		return {x=carts:get_sign(v.x), y=carts:get_sign(v.y), z=0}
	else
		return {x=0, y=carts:get_sign(v.y), z=carts:get_sign(v.z)}
	end
end

function carts:is_rail(pos, railtype)
	local node = minetest.get_node(pos).name
	if node == "ignore" then
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(pos, pos)
		local area = VoxelArea:new{
			MinEdge = emin,
			MaxEdge = emax,
		}
		local data = vm:get_data()
		local vi = area:indexp(pos)
		node = minetest.get_name_from_content_id(data[vi])
	end
	if minetest.get_item_group(node, "rail") == 0 then
		return false
	end
	if not railtype then
		return true
	end
	return minetest.get_item_group(node, "connect_to_raillike") == railtype
end

function carts:check_front_up_down(pos, dir_, check_up, railtype)
	local dir = vector.new(dir_)
	local cur

	-- Front
	dir.y = 0
	cur = vector.add(pos, dir)
	if carts:is_rail(cur, railtype) then
		return dir
	end
	-- Up
	if check_up then
		dir.y = 1
		cur = vector.add(pos, dir)
		if carts:is_rail(cur, railtype) then
			return dir
		end
	end
	-- Down
	dir.y = -1
	cur = vector.add(pos, dir)
	if carts:is_rail(cur, railtype) then
		return dir
	end
	return nil
end

function carts:get_rail_direction(pos_, dir, ctrl, old_switch, railtype)
	local pos = vector.round(pos_)
	local cur
	local left_check, right_check = true, true

	-- Check left and right
	local left = {x=0, y=0, z=0}
	local right = {x=0, y=0, z=0}
	if dir.z ~= 0 and dir.x == 0 then
		left.x = -dir.z
		right.x = dir.z
	elseif dir.x ~= 0 and dir.z == 0 then
		left.z = dir.x
		right.z = -dir.x
	end

	if ctrl then
		if old_switch == 1 then
			left_check = false
		elseif old_switch == 2 then
			right_check = false
		end
		if ctrl.left and left_check then
			cur = carts:check_front_up_down(pos, left, false, railtype)
			if cur then
				return cur, 1
			end
			left_check = false
		end
		if ctrl.right and right_check then
			cur = carts:check_front_up_down(pos, right, false, railtype)
			if cur then
				return cur, 2
			end
			right_check = true
		end
	end

	-- Normal
	cur = carts:check_front_up_down(pos, dir, true, railtype)
	if cur then
		return cur
	end

	-- Left, if not already checked
	if left_check then
		cur = carts:check_front_up_down(pos, left, false, railtype)
		if cur then
			return cur
		end
	end

	-- Right, if not already checked
	if right_check then
		cur = carts:check_front_up_down(pos, right, false, railtype)
		if cur then
			return cur
		end
	end

	-- Backwards
	if not old_switch then
		cur = carts:check_front_up_down(pos, {
				x = -dir.x,
				y = dir.y,
				z = -dir.z
			}, true, railtype)
		if cur then
			return cur
		end
	end

	return {x=0, y=0, z=0}
end

function carts:pathfinder(pos_, old_pos, old_dir, ctrl, pf_switch, railtype)
	local pos = vector.round(pos_)
	local pf_pos = vector.round(old_pos)
	local pf_dir = vector.new(old_dir)

	for i = 1, 3 do
		if vector.equals(pf_pos, pos) then
			-- Success! Cart moved on correctly
			return true
		end

		pf_dir, pf_switch = carts:get_rail_direction(pf_pos, pf_dir, ctrl, pf_switch, railtype)
		if vector.equals(pf_dir, {x=0, y=0, z=0}) then
			-- No way forwards
			return false
		end

		pf_pos = vector.add(pf_pos, pf_dir)
	end
	-- Cart not found
	return false
end

function carts:register_rail(name, def_overwrite, railparams)
	local def = {
		drawtype = "raillike",
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		sounds = default.node_sound_metal_defaults()
	}
	for k, v in pairs(def_overwrite) do
		def[k] = v
	end
	if not def.inventory_image then
		def.wield_image = def.tiles[1]
		def.inventory_image = def.tiles[1]
	end

	if railparams then
		carts.railparams[name] = table.copy(railparams)
	end

	minetest.register_node(name, def)
end

function carts:get_rail_groups(additional_groups)
	-- Get the default rail groups and add more when a table is given
	local groups = {dig_immediate = 2, attached_node = 1, rail = 1, connect_to_raillike = 1}
	if type(additional_groups) == "table" then
		for k, v in pairs(additional_groups) do
			groups[k] = v
		end
	end
	return groups
end
