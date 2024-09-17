minetest.set_gen_notify({dungeon = true, temple = true})

local function noise3d_integer(noise, pos)
	return math.abs(math.floor(noise:get_3d(pos) * 0x7fffffff))
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

local function populate_chest(pos, rand, dungeontype)
	--minetest.chat_send_all("chest placed at " .. minetest.pos_to_string(pos) .. " [" .. dungeontype .. "]")
	--minetest.add_node(vector.add(pos, {x=0, y=1, z=0}), {name="default:torch", param2=1})

	local item_list = dungeon_loot._internal_get_loot(pos.y, dungeontype)
	-- take random (partial) sample of all possible items
	local sample_n = math.min(#item_list, dungeon_loot.STACKS_PER_CHEST_MAX)
	item_list = random_sample(rand, item_list, sample_n)

	-- apply chances / randomized amounts and collect resulting items
	local items = {}
	for _, loot in ipairs(item_list) do
		if rand:next(0, 1000) / 1000 <= loot.chance then
			local itemdef = minetest.registered_items[loot.name]
			local amount = 1
			if loot.count ~= nil then
				amount = rand:next(loot.count[1], loot.count[2])
			end

			if not itemdef then
				minetest.log("warning", "Registered loot item " .. loot.name .. " does not exist")
			elseif itemdef.tool_capabilities then
				for n = 1, amount do
					local wear = rand:next(0.20 * 65535, 0.75 * 65535) -- 20% to 75% wear
					table.insert(items, ItemStack({name = loot.name, wear = wear}))
				end
			elseif itemdef.stack_max == 1 then
				-- not stackable, add separately
				for n = 1, amount do
					table.insert(items, loot.name)
				end
			else
				table.insert(items, ItemStack({name = loot.name, count = amount}))
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

local function place_chests(candidates, blockseed)
	if #candidates == 0 then
		return
	end

	local noise = minetest.get_perlin(10115, 4, 0.5, 1)
	local rand = PcgRandom(blockseed)

	local num_chests = rand:next(dungeon_loot.CHESTS_MIN, dungeon_loot.CHESTS_MAX)
	num_chests = math.min(#candidates, num_chests)
	local rooms = random_sample(rand, candidates, num_chests)

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

		if minetest.get_node(chestpos).name == "air" then
			-- make it face inwards to the room
			local facedir = minetest.dir_to_facedir(vector.multiply(wall.facing, -1))
			minetest.add_node(chestpos, {name = "default:chest", param2 = facedir})
			populate_chest(chestpos, PcgRandom(noise3d_integer(noise, chestpos)), room.type)
		end
	end
end

if minetest.register_mapgen_script then
	-- dungeon rooms are scanned in mapgen thread
	minetest.set_gen_notify({custom=true}, nil, {"dungeon_loot:candidates"})
	minetest.register_mapgen_script(minetest.get_modpath("dungeon_loot") .. "/scan.lua")
	minetest.register_on_generated(function(minp, maxp, blockseed)
		local gennotify = minetest.get_mapgen_object("gennotify")
		local candidates = gennotify.custom["dungeon_loot:candidates"]
		assert(type(candidates) == "table", "candidates must exist")
		place_chests(candidates, blockseed)
	end)
else
	-- dungeon rooms are scanned in callback here
	dofile(minetest.get_modpath("dungeon_loot") .. "/scan.lua")
	minetest.register_on_generated(function(minp, maxp, blockseed)
		-- process at most 8 rooms to keep runtime of this predictable
		local candidates = dungeon_loot._internal_find_rooms(8)
		place_chests(candidates, blockseed)
	end)
end
