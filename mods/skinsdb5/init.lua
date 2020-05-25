-- Rework 2018-2020 by bell07
-- License: GPLv3

skinsdb5 = {}
local modpath = minetest.get_modpath(minetest.get_current_modname())
skinsdb5.modpath = modpath

dofile(modpath.."/api.lua")
dofile(modpath.."/preview.lua")
dofile(modpath.."/formspecs.lua")
dofile(modpath.."/chatcommands.lua")

-- Unified inventory page/integration
if minetest.get_modpath("unified_inventory") then
	dofile(modpath.."/unified_inventory_page.lua")
end

if minetest.get_modpath("sfinv") then
	dofile(modpath.."/sfinv_page.lua")
end

-- Update skin on join
skinsdb5.ui_context = {}
minetest.register_on_leaveplayer(function(player)
	skinsdb5.ui_context[player:get_player_name()] = nil
end)

-- Read current mod textures- and meta- folder
player_api.read_textures_and_meta()
