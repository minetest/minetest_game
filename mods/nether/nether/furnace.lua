-- minetest time speed
local time_speed = tonumber(minetest.settings:get("time_speed"))
if not time_speed then
	time_speed = 1
else
	time_speed = time_speed/72
end

local function get_date()
	return os.date("%y %d %H %M %S")
end

-- returns the time difference in seconds
local function get_timediff(d1, d2)
	local d = string.split(d1, " ")
	for n,i in pairs(string.split(d2, " ")) do
		d[n] = i-d[n]
	end
	local secs = 0
	local y,d,h,m,s = unpack(d)
	if s ~= 0 then
		secs = secs+s
	end
	if m ~= 0 then
		secs = secs+m*60
	end
	if h ~= 0 then
		secs = secs+h*3600	-- 60*60
	end
	if d ~= 0 then
		secs = secs+d*86400	-- 60*60*24
	end
	if y ~= 0 then
		secs = secs+y*31557600	-- 60*60*24*365.25
	end
	--secs = math.floor(secs+0.5)
	if secs < 0 then
		minetest.log("action", "play warzone2100?")
	end
	return secs*time_speed
end

-- copied from older default furnace code and edited a bit

function nether.get_furnace_active_formspec(pos, percent)
	local formspec =
		"size[8,9]"..
		"image[2,2;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(100-percent)..":default_furnace_fire_fg.png]"..
		"list[current_name;fuel;2,3;1,1;]"..
		"list[current_name;src;2,1;1,1;]"..
		"list[current_name;dst;5,1;2,2;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end

nether.furnace_inactive_formspec =
	"size[8,9]"..
	"image[2,2;1,1;default_furnace_fire_bg.png]"..
	"list[current_name;fuel;2,3;1,1;]"..
	"list[current_name;src;2,1;1,1;]"..
	"list[current_name;dst;5,1;2,2;]"..
	"list[current_player;main;0,5;8,4;]"

minetest.register_node("nether:furnace", {
	description = "Furnace",
	tiles = {"default_furnace_top.png", "default_furnace_bottom.png", "default_furnace_side.png",
		"default_furnace_side.png", "default_furnace_side.png", "default_furnace_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", nether.furnace_inactive_formspec)
		meta:set_string("infotext", "Furnace")
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		elseif not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("last_active", get_date())
		local inv = meta:get_inventory()
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext","Furnace is empty")
				end
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("last_active", get_date())
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext","Furnace is empty")
				end
				return count
			else
				return 0
			end
		elseif to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end,
})

minetest.register_node("nether:furnace_active", {
	description = "Furnace",
	tiles = {
		"default_furnace_top.png",
		"default_furnace_bottom.png",
		"default_furnace_side.png",
		"default_furnace_side.png",
		"default_furnace_side.png",
		{
			image = "default_furnace_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "nether:furnace",
	groups = {cracky=2, not_in_creative_inventory=1,hot=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", nether.furnace_inactive_formspec)
		meta:set_string("infotext", "Furnace");
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		elseif not inv:is_empty("dst") then
			return false
		elseif not inv:is_empty("src") then
			return false
		end
		return true
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("last_active", get_date())
		local inv = meta:get_inventory()
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext","Furnace is empty")
				end
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("last_active", get_date())
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext","Furnace is empty")
				end
				return count
			else
				return 0
			end
		elseif to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end,
})

local function swap_node(pos,name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos,node)
end

minetest.register_abm({
	nodenames = {"nether:furnace","nether:furnace_active"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_string("timedif") == "" then
			meta:set_float("timedif", 0.0)
		end

		-- lag shouldn't control the furnace speed
		local current_time = get_date()
		local last_time = meta:get_string("last_active")
		if last_time == "" then
			meta:set_string("last_active", current_time)
			return
		end
		if last_time == current_time then
			return
		end

		local timediff = get_timediff(last_time, current_time)+meta:get_string("timedif")
		local times = math.floor(timediff)
		meta:set_string("last_active", current_time)
		meta:set_float("timedif", timediff-times)


		for _ = 1,times do
			for _,name in pairs({
					"fuel_totaltime",
					"fuel_time",
					"src_totaltime",
					"src_time",
			}) do
				if meta:get_string(name) == "" then
					meta:set_float(name, 0.0)
				end
			end
			local inv = meta:get_inventory()
			local srclist = inv:get_list("src")
			local cooked = nil
			local aftercooked

			if srclist then
				cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
			end

			local was_active = false

			if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
				was_active = true
				meta:set_float("fuel_time", meta:get_float("fuel_time") + 1)
				meta:set_float("src_time", meta:get_float("src_time") + 1)
				if cooked
				and cooked.item
				and meta:get_float("src_time") >= cooked.time then
					-- check if there's room for output in "dst" list
					if inv:room_for_item("dst",cooked.item) then
						-- Put result in "dst" list
						inv:add_item("dst", cooked.item)
						-- take stuff from "src" list
						inv:set_stack("src", 1, aftercooked.items[1])
					--~ else
						--print("Could not insert '"..cooked.item:to_string().."'")
					end
					meta:set_string("src_time", 0)
				end
			end

			if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
				local percent = math.floor(meta:get_float("fuel_time") /
						meta:get_float("fuel_totaltime") * 100)
				meta:set_string("infotext","Furnace active: "..percent.."%")
				swap_node(pos,"nether:furnace_active")
				meta:set_string("formspec",nether.get_furnace_active_formspec(pos, percent))
				return
			end

			local fuel = nil
			local afterfuel
			local cooked = nil
			local fuellist = inv:get_list("fuel")
			local srclist = inv:get_list("src")

			if srclist then
				cooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
			end
			if fuellist then
				fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
			end

			if not fuel or fuel.time <= 0 then
				meta:set_string("infotext","Furnace out of fuel")
				swap_node(pos,"nether:furnace")
				meta:set_string("formspec", nether.furnace_inactive_formspec)
				return
			end

			if cooked.item:is_empty() then
				if was_active then
					meta:set_string("infotext","Furnace is empty")
					swap_node(pos,"nether:furnace")
					meta:set_string("formspec", nether.furnace_inactive_formspec)
				end
				return
			end

			meta:set_string("fuel_totaltime", fuel.time)
			meta:set_string("fuel_time", 0)

			inv:set_stack("fuel", 1, afterfuel.items[1])
		end
	end,
})
