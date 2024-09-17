if minetest.save_gen_notify then
	dungeon_loot = {}
end

local function find_walls(cpos, is_temple)
	local is_wall = function(node)
		return node.name ~= "air" and node.name ~= "ignore"
	end

	local dirs = {{x=1, z=0}, {x=-1, z=0}, {x=0, z=1}, {x=0, z=-1}}
	local get_node = minetest.get_node

	local ret = {}
	local mindist = {x=0, z=0}
	local min = function(a, b) return a ~= 0 and math.min(a, b) or b end
	for _, dir in ipairs(dirs) do
		for i = 1, 9 do -- 9 = max room size / 2
			local pos = vector.add(cpos, {x=dir.x*i, y=0, z=dir.z*i})

			-- continue in that direction until we find a wall-like node
			local node = get_node(pos)
			if is_wall(node) then
				local front_below = vector.subtract(pos, {x=dir.x, y=1, z=dir.z})
				local above = vector.add(pos, {x=0, y=1, z=0})

				-- check that it:
				--- is at least 2 nodes high (not a staircase)
				--- has a floor
				if is_wall(get_node(front_below)) and is_wall(get_node(above)) then
					table.insert(ret, {pos = pos, facing = {x=-dir.x, y=0, z=-dir.z}})
					if dir.z == 0 then
						mindist.x = min(mindist.x, i-1)
					else
						mindist.z = min(mindist.z, i-1)
					end
				end
				-- abort even if it wasn't a wall cause something is in the way
				break
			end
		end
	end

	local biome = minetest.get_biome_data(cpos)
	biome = biome and minetest.get_biome_name(biome.biome) or ""
	local type = "normal"
	if is_temple or biome:find("desert") == 1 then
		type = "desert"
	elseif biome:find("sandstone_desert") == 1 then
		type = "sandstone"
	elseif biome:find("icesheet") == 1 then
		type = "ice"
	end

	return {
		walls = ret,
		size = {x=mindist.x*2, z=mindist.z*2},
		type = type,
	}
end

function dungeon_loot._internal_find_rooms(max_rooms)
	local gennotify = minetest.get_mapgen_object("gennotify")
	local poslist = gennotify["dungeon"] or {}
	local n_dungeons = #poslist
	-- Add MGv6 desert temples to the list too
	for _, entry in ipairs(gennotify["temple"] or {}) do
		table.insert(poslist, entry)
	end
	if #poslist == 0 then
		return {}
	end

	local candidates = {}
	local num_process = math.min(#poslist, max_rooms)
	for i = 1, num_process do
		local room = find_walls(poslist[i], i > n_dungeons)
		-- skip small rooms and everything that doesn't at least have 3 walls
		if math.min(room.size.x, room.size.z) >= 4 and #room.walls >= 3 then
			table.insert(candidates, room)
		end
	end

	return candidates
end

-- if loaded inside mapgen env, do our job there and export the result
if minetest.save_gen_notify then
	minetest.register_on_generated(function(vmanip, minp, maxp, blockseed)
		local candidates = dungeon_loot._internal_find_rooms(9999)
		minetest.save_gen_notify("dungeon_loot:candidates", candidates)
	end)
end
