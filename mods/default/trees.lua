--
-- Grow trees
--

local random = math.random

local function can_grow(pos)
	local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	if not node_under then
		return false
	end
	local name_under = node_under.name
	local is_soil = minetest.get_item_group(name_under, "soil")
	if is_soil == 0 then
		return false
	end
	return true
end

minetest.register_abm({
	nodenames = {"default:sapling"},
	interval = 10,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A sapling grows into a tree at "..minetest.pos_to_string(pos))
		default.grow_tree(pos, random(1, 4) == 1)
	end
})

minetest.register_abm({
	nodenames = {"default:junglesapling"},
	interval = 10,
	chance = 50,
	action = function(pos, node)
		if not can_grow(pos) then
			return
		end

		minetest.log("action", "A jungle sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		default.grow_jungletree(pos)
	end
})


local c_air = minetest.get_content_id("air")
local c_apple = minetest.get_content_id("default:apple")

local function add_trunk_and_leaves(data, a, pos, tree_cid, leaves_cid,
		height, size, iters, is_apple_tree)
	local x, y, z = pos.x, pos.y, pos.z

	-- Trunk
	for y_dist = 0, height - 1 do
		local vi = a:index(x, y + y_dist, z)
		if y_dist == 0 or data[vi] == c_air then
			data[vi] = tree_cid
		end
	end

	-- Force leaves near the trunk
	for x_dist = -1, 1 do
	for y_dist = -size, 1 do
	for z_dist = -1, 1 do
		local vi = a:index(x + x_dist, y + height + y_dist, z + z_dist)
		if data[vi] == c_air then
			if is_apple_tree and random(1, 8) == 1 then
				data[vi] = c_apple
			else
				data[vi] = leaves_cid
			end
		end
	end
	end
	end

	-- Randomly add leaves in 2x2x2 clusters.
	for i = 1, iters do
		local clust_x = x + random(-size, size - 1)
		local clust_y = y + height + random(-size, 0)
		local clust_z = z + random(-size, size - 1)

		for xi = 0, 1 do
		for yi = 0, 1 do
		for zi = 0, 1 do
			local vi = a:index(clust_x + xi, clust_y + yi, clust_z + zi)
			if data[vi] == c_air then
				if is_apple_tree and random(1, 8) == 1 then
					data[vi] = c_apple
				else
					data[vi] = leaves_cid
				end
			end
		end
		end
		end
	end
end


local c_tree = minetest.get_content_id("default:tree")
local c_leaves = minetest.get_content_id("default:leaves")

function default.grow_tree(pos, is_apple_tree, bad)
	--[[
		NOTE: Tree-placing code is currently duplicated in the engine
		and in games that have saplings; both are deprecated but not
		replaced yet
	--]]
	if bad then
		error("Deprecated use of default.grow_tree")
	end

	local x, y, z = pos.x, pos.y, pos.z
	local height = random(4, 5)

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
			{x = pos.x - 2, y = pos.y, z = pos.z - 2},
			{x = pos.x + 2, y = pos.y + height + 1, z = pos.z + 2}
	)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	add_trunk_and_leaves(data, a, pos, c_tree, c_leaves, height, 2, 8, is_apple_tree)

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

local c_jungletree = minetest.get_content_id("default:jungletree")
local c_jungleleaves = minetest.get_content_id("default:jungleleaves")

function default.grow_jungletree(pos, bad)
	--[[
		NOTE: Tree-placing code is currently duplicated in the engine
		and in games that have saplings; both are deprecated but not
		replaced yet
	--]]
	if bad then
		error("Deprecated use of default.grow_jungletree")
	end

	local x, y, z = pos.x, pos.y, pos.z
	local height = random(8, 12)

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
			{x = pos.x - 3, y = pos.y - 1,  z = pos.z - 3},
			{x = pos.x + 3, y = pos.y + height + 1, z = pos.z + 3})
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	add_trunk_and_leaves(data, a, pos, c_jungletree, c_jungleleaves, height, 3, 30, false)

	-- Roots
	for x_dist = -1, 1 do
	for z_dist = -1, 1 do
		if random(1, 3) >= 2 then
			local vi_1 = a:index(x + x_dist, y - 1, z + z_dist)
			local vi_2 = a:index(x + x_dist, y,     z + z_dist)
			if data[vi_1] == c_air then
				data[vi_1] = c_jungletree
			elseif data[vi_2] == c_air then
				data[vi_2] = c_jungletree
			end
		end
	end
	end

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

