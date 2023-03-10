-- Check whether mod should be active
local mg_name = minetest.get_mapgen_setting("mg_name")
local mod_enabled = minetest.settings:get_bool("enable_weather", true)
local randomize_clouds = mod_enabled and mg_name ~= "v6" and mg_name ~= "singlenode"

weather = {}
local playerlist = {}

-- Parameters
local TSCALE = 600 -- Time scale of noise variation in seconds
local CYCLE = 8 -- Time period of cyclic clouds update in seconds

local np_density = {
	offset = 0.5,
	scale = 0.5,
	spread = {x = TSCALE, y = TSCALE, z = TSCALE},
	seed = 813,
	octaves = 1,
	persist = 0,
	lacunarity = 2,
}

local np_thickness = {
	offset = 0.5,
	scale = 0.5,
	spread = {x = TSCALE, y = TSCALE, z = TSCALE},
	seed = 96,
	octaves = 1,
	persist = 0,
	lacunarity = 2,
}

local np_speedx = {
	offset = 0,
	scale = 1,
	spread = {x = TSCALE, y = TSCALE, z = TSCALE},
	seed = 911923,
	octaves = 1,
	persist = 0,
	lacunarity = 2,
}

local np_speedz = {
	offset = 0,
	scale = 1,
	spread = {x = TSCALE, y = TSCALE, z = TSCALE},
	seed = 5728,
	octaves = 1,
	persist = 0,
	lacunarity = 2,
}

-- End parameters

-- Initialise noise objects to nil

local nobj_density = nil
local nobj_thickness = nil
local nobj_speedx = nil
local nobj_speedz = nil

-- Update clouds function

local function rangelim(value, lower, upper)
	return math.min(math.max(value, lower), upper)
end

local os_time_0 = os.time()
local t_offset = math.random(0, 300000)

local function update_clouds(players)
	-- Time in seconds.
	-- Add random time offset to avoid identical behaviour each server session.
	local time = os.difftime(os.time(), os_time_0) - t_offset

	nobj_density = nobj_density or minetest.get_perlin(np_density)
	nobj_thickness = nobj_thickness or minetest.get_perlin(np_thickness)
	nobj_speedx = nobj_speedx or minetest.get_perlin(np_speedx)
	nobj_speedz = nobj_speedz or minetest.get_perlin(np_speedz)

	local n_density = nobj_density:get_2d({x = time, y = 0}) -- 0 to 1
	local n_thickness = nobj_thickness:get_2d({x = time, y = 0}) -- 0 to 1
	local n_speedx = nobj_speedx:get_2d({x = time, y = 0}) -- -1 to 1
	local n_speedz = nobj_speedz:get_2d({x = time, y = 0}) -- -1 to 1

	for _, player in ipairs(players) do
		-- Fallback to mid-value 50 for very old worlds
		local humid = minetest.get_humidity(player:get_pos()) or 50
		-- Default and classic density value is 0.4, make this happen
		-- at humidity midvalue 50 when n_density is at midvalue 0.5.
		-- density_max = 0.25 at humid = 0.
		-- density_max = 0.8 at humid = 50.
		-- density_max = 1.35 at humid = 100.
		local density_max = 0.8 + ((humid - 50) / 50) * 0.55
		local density = rangelim(density_max, 0.2, 1.0) * n_density
		player:set_clouds({
			-- Range limit density_max to always have occasional
			-- small scattered clouds at extreme low humidity.
			density = density,
			thickness = math.max(math.floor(
				rangelim(32 * humid / 100, 8, 32) * n_thickness
				), 2),
			speed = {x = n_speedx * 4, z = n_speedz * 4},
		})
		-- now adjust the shadow intensity
		player:set_lighting({
			shadows = { intensity = 0.7 * (1 - density) }
		})
	end
end

local function purge_effects(player)
	-- reset potentially touched values to their defaults
	if randomize_clouds then
		player:set_clouds({
			density = 0.4,
			thickness = 16,
			speed = { x = 0, z = -2 }
		})
	end
	player:set_lighting({
		shadows = { intensity = 0 }
	})
end

-- Define API hooks

-- override to set state for newly joined players
weather.enable_on_join = true

-- returns bool for whether weather is active
-- returns nil if player is offline or weather is disabled
weather.get_enabled = function(player)
	return playerlist[player]
end

-- override weather generation for individual player
weather.set_enabled = function(player, enable)
	if enable == playerlist[player] then
		return
	end
	playerlist[player] = enable
	if enable then
		if randomize_clouds then
			update_clouds({player})
		end
	else
		purge_effects(player)
	end
end

-- End API hooks

-- skip event registration if mod is disabled
if not mod_enabled then
	return
end

if update_clouds then
	local function cyclic_update()
		local players = {}
		for player, state in pairs(playerlist) do
			if state then
				table.insert(players, player)
			end
		end
		update_clouds(players)
		minetest.after(CYCLE, cyclic_update)
	end
	minetest.after(0, cyclic_update)
end

-- Update on player join to instantly alter clouds from the default

minetest.register_on_joinplayer(function(player)
	if weather.enable_on_join then
		playerlist[player] = true
		if randomize_clouds then
			update_clouds({player})
		else
			-- set a default shadow intensity for mgv6 and singlenode
			player:set_lighting({
				shadows = {
					intensity = 0.33
				}
			})
		end
	else
		playerlist[player] = false
	end
end)

minetest.register_on_leaveplayer(function(player)
	table.remove(player)
end)
