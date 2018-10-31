-- Global spawn search function

-- Searches a square area along an outward spiral starting at the centre.
-- Returns a spawn position, or 'false' on search failure.

-- 'pos'
-- Starting position for search, for example '{x = 0, y = 8, z = 0}'.
-- This sets the y co-ordinate for all positions checked, so any specified
-- biomes must be active at this y.

-- 'radius'
-- Radius of search area. Defaults to 4096.

-- 'spacing'
-- Spacing of checked positions, in nodes. Defaults to 64.

-- 'biome_ids'
-- Table of biome ids. Returned spawn position will be in one of these biomes.
-- If missing or nil, returned spawn position will be in any biome.

function spawn.search(pos, radius, spacing, biome_ids)
	radius = radius or 4096
	spacing = spacing or 64

	local checks = math.pow(math.floor(radius / spacing) * 2, 2)
	local edge_len = 1
	local edge_dist = 0
	local dir_step = 0
	local dir_ind = 1
	local dirs = {
		{x = 0, y = 0, z = 1},
		{x = -1, y = 0, z = 0},
		{x = 0, y = 0, z = -1},
		{x = 1, y = 0, z = 0},
	}

	for iter = 1, checks do
		if biome_ids then
			local biome_data = minetest.get_biome_data(pos)
			-- Sometimes biome_data is nil
			local biome = biome_data and biome_data.biome

			for id_ind = 1, #biome_ids do
				local biome_id = biome_ids[id_ind]
				if biome == biome_id then
					local spawn_y = minetest.get_spawn_level(pos.x, pos.z)
					if spawn_y then
						-- Successful search
						local spawn_pos = {x = pos.x, y = spawn_y, z = pos.z}
						return spawn_pos
					end
				end
			end
		else
			-- 'biome_ids' is nil, spawn in any biome
			local spawn_y = minetest.get_spawn_level(pos.x, pos.z)
			if spawn_y then
				-- Successful search
				local spawn_pos = {x = pos.x, y = spawn_y, z = pos.z}
				return spawn_pos
			end
		end

		-- Get next position on search spiral
		if edge_dist == edge_len then
			edge_dist = 0
			dir_ind = dir_ind + 1
			if dir_ind == 5 then
				dir_ind = 1
			end
			dir_step = dir_step + 1
			edge_len = math.floor(dir_step / 2) + 1
		end

		local dir = dirs[dir_ind]
		local move = vector.multiply(dir, spacing)
		edge_dist = edge_dist + 1
		pos = vector.add(pos, move)
	end

	-- Search failed
	return false
end
