-- Check whether mod should be active
local mg_name = minetest.get_mapgen_setting("mg_name")
local settings_enabled = minetest.settings:get_bool("enable_weather", true)
local randomize_clouds = mg_name ~= "v6" and mg_name ~= "singlenode"

-- global variable for API (see end of file)
weather = {}

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

-- set a default shadow intensity for mgv6 and singlenode
local function set_default_lighting(players)
	for _, player in ipairs(players) do
		local lighting = {
			shadows = { intensity = 0.33 }
		}
		local overrides = weather.on_update(player, { lighting })
		if overrides.lighting ~= nil then
			player:set_lighting(overrides.lighting)
		end
	end
end

local function update_weather(players)
	-- skip cloud randomization if worldgen not supported
	if not randomize_clouds then
		set_default_lighting(players)
		return
	end
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
		local clouds = {
			-- Range limit density_max to always have occasional
			-- small scattered clouds at extreme low humidity.
			density = density,
			thickness = math.max(math.floor(
				rangelim(32 * humid / 100, 8, 32) * n_thickness
				), 2),
			speed = {x = n_speedx * 4, z = n_speedz * 4},
		}
		-- now adjust the shadow intensity
		local lighting = {
			shadows = { intensity = 0.7 * (1 - density) }
		}
		-- check for API overrides and then apply
		local overrides = weather.on_update(player, { clouds, lighting })
		if overrides ~= nil and overrides.clouds ~= nil then
			player:set_clouds(overrides.clouds)
		end
		if overrides ~= nil and overrides.lighting ~= nil then
			player:set_lighting(overrides.lighting)
		end
	end
end

-- Update clouds periodically for all players

local timer = nil
local function cyclic_update()
	local players = minetest.get_connected_players()
	update_weather(players)
	timer = minetest.after(CYCLE, cyclic_update)
end
timer = minetest.after(0, cyclic_update)


local function purge_effects()
	-- stop timer for active cycle
	if timer ~= nil then
		timer:cancel()
		timer = nil
	end
	-- reset changed player tables to default values
    for _, player in ipairs(minetest.get_connected_players()) do
        if randomize_clouds then
            player:set_clouds({})
        end
        -- NOTE: set_lighting doesn't allow empty table to reset
        player:set_lighting({
            shadows = {
                intensity = 0
            }
        })
    end
end


-- Update on player join to instantly alter clouds from the default

minetest.register_on_joinplayer(function(player)
	if weather.is_enabled() then
		update_weather({ player })
	end
end)

-- Define API functions

local is_enabled = true
weather.is_enabled = function()
    return settings_enabled and is_enabled
end

weather.set_enabled = function(enable)
    if enable and not is_enabled then
		-- restart stopped update cycle
        cyclic_update()
	elseif not enable and is_enabled then
		-- stop update cycle and remove effects
		purge_effects()
	end
    is_enabled = enable
end

weather.on_update = function(player, overrides)
    return overrides
end

-- End API definition
