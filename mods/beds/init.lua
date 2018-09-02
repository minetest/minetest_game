beds = {}
beds.player = {}
beds.bed_position = {}
beds.pos = {}
beds.spawn = {}

beds.formspec = "size[8,15;true]" ..
	"bgcolor[#080808BB; true]" ..
	"button_exit[2,12;4,0.75;leave;Leave Bed]"

local modpath = minetest.get_modpath("beds")

-- Load files

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/beds.lua")
dofile(modpath .. "/spawns.lua")


-- Modifications
-- Saturation: 150
-- Lightness: -25
-- Contrast: -100
-- Brightness: -85