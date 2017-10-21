minetest.set_gen_notify({dungeon=true})

local function noise3d_integer(noise, pos)
	return math.abs(math.floor(noise:get3d(pos) * 2147483647))
end

local function find_walls(cpos)
	local wall = ItemStack("mapgen_cobble"):get_name()
	local wall_alt = ItemStack("mapgen_mossycobble"):get_name()
	local is_wall = function(node) return node.name == wall or node.name == wall_alt end

	local dirs = { {x=1, z=0}, {x=-1, z=0}, {x=0, z=1}, {x=0, z=-1} }
	local get_node = minetest.get_node

	local ret = {}
	local mindist = {x=0, z=0}
	local min = function(a, b) return a ~= 0 and math.min(a, b) or b end
	for _, dir in ipairs(dirs) do
		for i = 1, 8 do -- 8 = max room size / 2
			local pos = vector.add(cpos, {x=dir.x*i, y=0, z=dir.z*i})

			-- continue in that direction until we find a wall-like node
			if is_wall(get_node(pos)) then
				local front_below = vector.subtract(pos, {x=dir.x, y=1, z=dir.z})
				local above = vector.add(pos, {x=0, y=1, z=0})

				-- check that it:
				--- is at least 2 nodes high (not a staircase)
				--- has a floor
				if is_wall(get_node(front_below)) and is_wall(get_node(above)) then
					table.insert(ret, {pos=pos, facing={x=-dir.x, y=0, z=-dir.z}})
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

	return {
		walls = ret,
		size = {x=mindist.x*2, z=mindist.z*2},
	}
end

local function populate_chest(pos, rand)
	local item_list = {
		-- {"item:name", chance, min, max},
		{"bucket:bucket_empty", 0.65, 1, 1},
		{"bucket:bucket_lava", 0.55, 1, 1},

		{"default:flint", 0.6, 1, 3},
		{"default:stick", 0.6, 3, 6},
		{"farming:string", 0.5, 1, 8},
		{"farming:wheat", 0.5, 1, 4},
		{"vessels:glass_fragments", 0.4, 2, 5},
		{"fire:flint_and_steel", 0.4, 1, 1},

		{"default:coal_lump", 0.9, 1, 12},
		{"default:gold_ingot", 0.5, 1, 1},
		{"default:steel_ingot", 0.4, 1, 6},
		{"default:mese_crystal", 0.1, 2, 3},

		{"default:sword_wood", 0.6, 1, 1},
		{"default:pick_stone", 0.3, 1, 1},
		{"default:axe_diamond", 0.05, 1, 1},
	}
	if pos.y > -64 then
		table.insert(item_list, {"default:dirt", 0.8, 4, 32})
		table.insert(item_list, {"default:sand", 0.6, 2, 16})
	end
	if pos.y <= -512 then
		table.insert(item_list, {"default:obsidian", 0.25, 1, 3})
		table.insert(item_list, {"default:mese", 0.15, 1, 1})
	end

	-------------------- COMMENT THESE OUT BEFORE MERGING --------------------
	minetest.chat_send_all("chest placed at "  .. minetest.pos_to_string(pos))
	minetest.add_node(vector.add(pos, {x=0, y=1, z=0}), {name="default:torch", param2=1})
	-------------------- COMMENT THESE OUT BEFORE MERGING --------------------

	-- random sample of all items (half)
	local item_list2 = {}
	for n = 1, math.floor(#item_list / 2) do
		local idx = rand:next(1, #item_list)
		table.insert(item_list2, item_list[idx])
		table.remove(item_list, idx)
	end
	item_list = item_list2

	-- apply chances / randomized amounts and collect resulting items
	local items = {}
	for _, spec in ipairs(item_list) do
		if rand:next(0, 1000) / 1000 <= spec[2] then
			local itemdef = minetest.registered_items[spec[1]]
			local amount = rand:next(spec[3], spec[4])

			if itemdef.tool_capabilities then
				for n = 1, amount do
					local wear = rand:next(0.20 * 65535, 0.75 * 65535) -- 20% to 75% wear
					table.insert(items, ItemStack({name=spec[1], wear=wear}))
				end
			elseif itemdef.stack_max == 1 then
				-- not stackable -> add separately
				for n = 1, amount do
					table.insert(items, spec[1])
				end
			else
				table.insert(items, ItemStack({name=spec[1], count=amount}))
			end
		end
	end

	-- place items at random places in chest
	local inv = minetest.get_meta(pos):get_inventory()
	local listsz = inv:get_size("main")
	assert(listsz >= #items)
	for _, item in ipairs(items) do
		local index = rand:next(1, listsz)
		if inv:get_stack("main", index):is_empty() then
			inv:set_stack("main", index, item)
		else
			inv:add_item("main", item) -- space occupied, just put it anywhere
		end
	end
end

--[[local function room_debug(cpos, room)
	minetest.chat_send_all("dungeon room at " .. minetest.pos_to_string(cpos))

	minetest.add_node(cpos, {name="default:sign_wall_wood", param2=1})
	local meta = minetest.get_meta(cpos)
	meta:set_string("text", string.format("roomsize = (%d, %d)", room.size.x, room.size.z))
	meta:set_string("infotext", '"' .. meta:get_string("text") .. '"')

	for _, w in ipairs(room.walls) do
		local p = minetest.dir_to_wallmounted(vector.multiply(w.facing, -1))
		minetest.add_node(vector.add(w.pos, w.facing), {name="default:torch", param2=p})
	end
end--]]


minetest.register_on_generated(function(minp, maxp, blockseed)
	local poslist = minetest.get_mapgen_object("gennotify")["dungeon"]
	if poslist == nil then return end

	local noise = minetest.get_perlin(10115, 4, 0.5, 1)
	local rand = PcgRandom(noise3d_integer(noise, poslist[1]))

	local candidates = {}
	for _, cpos in ipairs(poslist) do
		local room = find_walls(cpos)
		-- skip small rooms and everything that doesn't at least have 3 walls
		if math.min(room.size.x, room.size.z) >= 4 and #room.walls >= 3 then
			--room_debug(cpos, room)
			table.insert(candidates, room)
		end
	end

	local no_chests = rand:next(0, 2) -- not necessarily in a single dungeon
	no_chests = math.min(#candidates, no_chests)
	local rooms = {} -- rooms with chests
	for n = 1, no_chests do
		local idx = rand:next(1, #candidates)
		table.insert(rooms, candidates[idx])
		table.remove(candidates, idx)
	end
	candidates = nil

	for _, room in ipairs(rooms) do
		-- choose place somewhere in front of any of the walls
		local wall = room.walls[rand:next(1, #room.walls)]
		local v, vi -- vector / axis that runs alongside the wall
		if wall.facing.x ~= 0 then
			v, vi = {x=0, y=0, z=1}, "z"
		else
			v, vi = {x=1, y=0, z=0}, "x"
		end
		local chestpos = vector.add(wall.pos, {x=wall.facing.x, y=0, z=wall.facing.z})
		local off = rand:next(-room.size[vi]/2 + 1, room.size[vi]/2 - 1)
		chestpos = vector.add(chestpos, vector.multiply(v, off))

		-- make it face inwards to the room
		local facedir = minetest.dir_to_facedir({x=-wall.facing.x, y=0, z=-wall.facing.z})
		minetest.add_node(chestpos, {name="default:chest", param2=facedir})
		populate_chest(chestpos, PcgRandom(noise3d_integer(noise, chestpos)))
	end
end)
