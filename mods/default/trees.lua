--
-- Grow trees
--

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
		default.grow_tree(pos, math.random(1, 4) == 1)
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

		minetest.log("action", "A jungle sapling grows into a tree at "..minetest.pos_to_string(pos))
		default.grow_jungletree(pos)
	end
})

local c_air = minetest.get_content_id("air")
local c_tree = minetest.get_content_id("default:tree")
local c_leaves = minetest.get_content_id("default:leaves")
local c_apple = minetest.get_content_id("default:apple")

function default.grow_tree(pos, is_apple_tree, bad)
	--[[
		NOTE: Tree-placing code is currently duplicated in the engine
		and in games that have saplings; both are deprecated but not
		replaced yet
	--]]
	if bad then
		error("Deprecated use of default.grow_tree")
	end
	local seed = math.random(1, 100000)

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
			{x = pos.x - 2, y = pos.y, z = pos.z - 2},
			{x = pos.x + 2, y = pos.y + 6, z = pos.z + 2}
	)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	local pr = PseudoRandom(seed)
	local th = pr:next(4, 5)
	local x, y, z = pos.x, pos.y, pos.z
	for yy = y, y + th - 1 do
		local vi = a:index(x, yy, z)
		if a:contains(x, yy, z) and (data[vi] == c_air or yy == y) then
			data[vi] = c_tree
		end
	end
	y = y + th - 1 -- (x, y, z) is now last piece of trunk
	local leaves_a = VoxelArea:new({
		MinEdge = {x = -2, y = -1, z = -2},
		MaxEdge = {x = 2,  y = 2,  z = 2},
	})
	local leaves_buffer = {}

	-- Force leaves near the trunk
	local d = 1
	for xi = -d, d do
	for yi = -d, d do
	for zi = -d, d do
		leaves_buffer[leaves_a:index(xi, yi, zi)] = true
	end
	end
	end

	-- Add leaves randomly
	for iii = 1, 8 do
		local d = 1
		local xx = pr:next(leaves_a.MinEdge.x, leaves_a.MaxEdge.x - d)
		local yy = pr:next(leaves_a.MinEdge.y, leaves_a.MaxEdge.y - d)
		local zz = pr:next(leaves_a.MinEdge.z, leaves_a.MaxEdge.z - d)

		for xi = 0, d do
		for yi = 0, d do
		for zi = 0, d do
			leaves_buffer[leaves_a:index(xx+xi, yy+yi, zz+zi)] = true
		end
		end
		end
	end

	-- Add the leaves
	for xi = -2, 2 do
	for yi = -1, 2 do
	for zi = -2, 2 do
		local vi = a:index(x + xi, y + yi, z + zi)
		if data[vi] == c_air and leaves_buffer[leaves_a:index(xi, yi, zi)] then
			if is_apple_tree and pr:next(1, 100) <=  10 then
				data[vi] = c_apple
			else
				data[vi] = c_leaves
			end
		end
	end
	end
	end
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
	local seed = math.random(1, 100000)
	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
			{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
			{x = pos.x + 2, y = pos.y + 12, z = pos.z + 2})
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	local pr = PseudoRandom(seed)
	local x, y, z = pos.x, pos.y, pos.z

	-- Add the roots
	for xi = -1, 1 do
	for zi = -1, 1 do
		if pr:next(1, 3) >= 2 then
			local vi1 = a:index(x + xi, y,     z + zi)
			local vi2 = a:index(x + xi, y - 1, z + zi)
			if data[vi2] == c_air then
				data[vi2] = c_jungletree
			elseif data[vi1] == c_air then
				data[vi1] = c_jungletree
			end
		end
	end
	end

	-- Add the trunk
	local th = pr:next(8, 12)
	for yy = y, y + th - 1 do
		local vi = a:index(x, yy, z)
		if data[vi] == c_air or yy == y then
			data[vi] = c_jungletree
		end
	end
	y = y + th - 1 -- (x, y, z) is now last piece of trunk
	local leaves_a = VoxelArea:new({
		MinEdge = {x = -3, y = -2, z = -3},
		MaxEdge = {x = 3,  y = 2,  z = 3}
	})
	local leaves_buffer = {}

	-- Force leaves near the trunk
	local d = 1
	for xi = -d, d do
	for yi = -d, d do
	for zi = -d, d do
		leaves_buffer[leaves_a:index(xi, yi, zi)] = true
	end
	end
	end

	-- Add leaves randomly
	for iii = 1, 30 do
		local d = 1
		local xx = pr:next(leaves_a.MinEdge.x, leaves_a.MaxEdge.x - d)
		local yy = pr:next(leaves_a.MinEdge.y, leaves_a.MaxEdge.y - d)
		local zz = pr:next(leaves_a.MinEdge.z, leaves_a.MaxEdge.z - d)

		for xi = 0, d do
		for yi = 0, d do
		for zi = 0, d do
			leaves_buffer[leaves_a:index(xx + xi, yy + yi, zz + zi)] = true
		end
		end
		end
	end

	-- Add the leaves
	for xi = -3, 3 do
	for yi = -2, 2 do
	for zi = -3, 3 do
		local vi = a:index(x + xi, y + yi, z + zi)
		if data[vi] == c_air then
			if leaves_buffer[leaves_a:index(xi, yi, zi)] then
				data[vi] = c_jungleleaves
			end
		end
	end
	end
	end
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end

