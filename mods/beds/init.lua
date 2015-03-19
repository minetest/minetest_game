beds = {}
beds.player = {}
beds.pos = {}
beds.spawn = {}

beds.formspec = "size[8,15;true]"..
		"bgcolor[#080808BB; true]"..
		"button_exit[2,12;4,0.75;leave;Leave Bed]"

local modpath = minetest.get_modpath("beds")

i18n.load_mo_file(modpath, "beds")

-- load files
dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/beds.lua")
dofile(modpath.."/spawns.lua")
