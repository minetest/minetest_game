-- Global namespace

spawn = {}

-- Load files

local modpath = minetest.get_modpath("spawn")

dofile(modpath .. "/api.lua")
dofile(modpath .. "/search.lua")
