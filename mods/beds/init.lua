beds = {}
beds.player = {}
beds.pos = {}
beds.spawn = {}

-- Intllib
ibeds = {}
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end
ibeds.intllib = S

beds.formspec = "size[8,15;true]"..
		"bgcolor[#080808BB; true]"..
		"button_exit[2,12;4,0.75;leave;" .. S("Leave Bed") .. "]"

local modpath = minetest.get_modpath("beds")

-- load files
dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/beds.lua")
dofile(modpath.."/spawns.lua")
