-- Disable by mapgen or setting

local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name == "v6" or mg_name == "singlenode" or
		minetest.settings:get_bool("enable_weather") == false then
	return
end


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

local function update_clouds()
	-- Time in seconds.
	-- Add random time offset to avoid identical behaviour each server session.
	local time = os.difftime(os.time(), os_time_0) - t_offset

	nobj_density = nobj_density or minetest.get_perlin(np_density)
	nobj_thickness = nobj_thickness or minetest.get_perlin(np_thickness)
	nobj_speedx = nobj_speedx or minetest.get_perlin(np_speedx)
	nobj_speedz = nobj_speedz or minetest.get_perlin(np_speedz)

	local n_density = nobj_density:get_2d({x = time, y = 0})
	local n_thickness = nobj_thickness:get_2d({x = time, y = 0})
	local n_speedx = nobj_speedx:get_2d({x = time, y = 0})
	local n_speedz = nobj_speedz:get_2d({x = time, y = 0})

	for _, player in ipairs(minetest.get_connected_players()) do
		local humid = minetest.get_humidity(player:get_pos())
		player:set_clouds({
			density = rangelim(humid / 100, 0.25, 1.0) * n_density,
			thickness = math.max(math.floor(
				rangelim(32 * humid / 100, 8, 32) * n_thickness
				), 1),
			speed = {x = n_speedx * 4, z = n_speedz * 4},
		})
	end
end


local function cyclic_update()
	update_clouds()
	minetest.after(CYCLE, cyclic_update)
end


minetest.after(0, cyclic_update)


-- Update on player join to instantly alter clouds from the default

minetest.register_on_joinplayer(function(player)
	update_clouds()
end)
