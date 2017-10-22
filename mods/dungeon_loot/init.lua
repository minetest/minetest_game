minetest.set_gen_notify({dungeon=true})

local function noise3d_integer(noise, pos)
	return math.abs(math.floor(noise:get3d(pos) * 2147483647))
end

local function random_sample(rand, list, count)
	local ret = {}
	for n = 1, count do
		local idx = rand:next(1, #list)
		table.insert(ret, list[idx])
		table.remove(list, idx)
	end
	return ret
end

local function find_walls(cpos)
	local wall = ItemStack("mapgen_cobble"):get_name()
	local wall_alt = ItemStack("mapgen_mossycobble"):get_name()
	local wall_sand = ItemStack("mapgen_sandstonebrick"):get_name()
	local is_wall = function(node)
		return table.indexof({wall, wall_alt, wall_sand}, node.name) ~= -1
	end

	local dirs = { {x=1, z=0}, {x=-1, z=0}, {x=0, z=1}, {x=0, z=-1} }
	local get_node = minetest.get_node

	local ret = {}
	local mindist = {x=0, z=0}
	local min = function(a, b) return a ~= 0 and math.min(a, b) or b end
	local wallnode
	for _, dir in ipairs(dirs) do
		for i = 1, 8 do -- 8 = max room size / 2
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
					table.insert(ret, {pos=pos, facing={x=-dir.x, y=0, z=-dir.z}})
					if dir.z == 0 then
						mindist.x = min(mindist.x, i-1)
					else
						mindist.z = min(mindist.z, i-1)
					end
					wallnode = node.name
				end
				-- abort even if it wasn't a wall cause something is in the way
				break
			end
		end
	end

	return {
		walls = ret,
		size = {x=mindist.x*2, z=mindist.z*2},
		type = wallnode == wall_sand and "desert" or "normal"
	}
end

-- {
--   name = "item:name",
--   chance = 0.5,
--   count = {min, max},
--   y = {min, max},
--   types = {"normal", ...},
-- }
-- only name and chance are required
local default_loot = {
	-- buckets
	{name="bucket:bucket_empty", chance=0.65},
	-- water in deserts or above ground, lava otherwise
	{name="bucket:bucket_water", chance=0.55, types={"desert"}},
	{name="bucket:bucket_water", chance=0.55, y={0, 32768}, types={"normal"}},
	{name="bucket:bucket_lava", chance=0.55, y={-32768, -1}, types={"normal"}},

	-- various items
	{name="default:flint", chance=0.6, count={1, 3}},
	{name="default:stick", chance=0.6, count={3, 6}},
	{name="farming:string", chance=0.5, count={1, 8}},
	{name="farming:wheat", chance=0.5, count={1, 4}},
	{name="vessels:glass_fragments", chance=0.4, count={2, 5}},
	{name="fire:flint_and_steel", chance=0.4},

	-- minerals
	{name="default:coal_lump", chance=0.9, count={1, 12}},
	{name="default:gold_ingot", chance=0.5},
	{name="default:steel_ingot", chance=0.4, count={1, 6}},
	{name="default:mese_crystal", chance=0.1, count={2, 3}},

	-- tools
	{name="default:sword_wood", chance=0.6},
	{name="default:pick_stone", chance=0.3},
	{name="default:axe_diamond", chance=0.05},

	-- natural materials
	{name="default:desert_sand", chance=0.8, count={4, 32}, y={-64, 32768}, types={"desert"}},
	{name="default:sand", chance=0.8, count={4, 32}, y={-64, 32768}, types={"normal"}},
	{name="default:sand", chance=0.6, count={2, 16}, y={-64, 32768}},
	{name="default:obsidian", chance=0.25, count={1, 3}, y={-32768, -512}},
	{name="default:mese", chance=0.15, y={-32768, -512}},
}

local function get_loot(pos_y, dungeontype)
	-- filter default loot by y and type
	local ret = {}
	for _, l in ipairs(default_loot) do
		if l.y == nil or (pos_y >= l.y[1] and pos_y <= l.y[2]) then
			if l.types == nil or table.indexof(l.types, dungeontype) ~= -1 then
				table.insert(ret, l)
			end
		end
	end
	return ret
end

local function populate_chest(pos, rand, dungeontype)
	-------------------- COMMENT THESE OUT BEFORE MERGING --------------------
	minetest.chat_send_all("chest placed at " .. minetest.pos_to_string(pos) .. " [" .. dungeontype .. "]")
	minetest.add_node(vector.add(pos, {x=0, y=1, z=0}), {name="default:torch", param2=1})
	-------------------- COMMENT THESE OUT BEFORE MERGING --------------------

	local item_list = get_loot(pos.y, dungeontype)
	-- take random (partial) sample of all possible items
	-- 8 is the absolute maximum number of itemstacks per chest
	assert(#item_list >= 8)
	item_list = random_sample(rand, item_list, 8)

	-- apply chances / randomized amounts and collect resulting items
	local items = {}
	for _, loot in ipairs(item_list) do
		if rand:next(0, 1000) / 1000 <= loot.chance then
			local itemdef = minetest.registered_items[loot.name]
			local amount = 1
			if loot.count ~= nil then
				amount = rand:next(loot.count[1], loot.count[2])
			end

			if itemdef.tool_capabilities then
				for n = 1, amount do
					local wear = rand:next(0.20 * 65535, 0.75 * 65535) -- 20% to 75% wear
					table.insert(items, ItemStack({name=loot.name, wear=wear}))
				end
			elseif itemdef.stack_max == 1 then
				-- not stackable, add separately
				for n = 1, amount do
					table.insert(items, loot.name)
				end
			else
				table.insert(items, ItemStack({name=loot.name, count=amount}))
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
	local rooms = random_sample(rand, candidates, no_chests)

	for _, room in ipairs(rooms) do
		-- choose place somewhere in front of any of the walls
		local wall = room.walls[rand:next(1, #room.walls)]
		local v, vi -- vector / axis that runs alongside the wall
		if wall.facing.x ~= 0 then
			v, vi = {x=0, y=0, z=1}, "z"
		else
			v, vi = {x=1, y=0, z=0}, "x"
		end
		local chestpos = vector.add(wall.pos, wall.facing)
		local off = rand:next(-room.size[vi]/2 + 1, room.size[vi]/2 - 1)
		chestpos = vector.add(chestpos, vector.multiply(v, off))

		-- make it face inwards to the room
		local facedir = minetest.dir_to_facedir(vector.multiply(wall.facing, -1))
		minetest.add_node(chestpos, {name="default:chest", param2=facedir})
		populate_chest(chestpos, PcgRandom(noise3d_integer(noise, chestpos)), room.type)
	end
end)
