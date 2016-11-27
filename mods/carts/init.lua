
carts = {}
carts.modpath = minetest.get_modpath("carts")
carts.railparams = {}

-- Maximal speed of the cart in m/s (min = -1) - corrected for slope
carts.speed_max_downhill = 5.70
carts.speed_max = 7
carts.speed_max_uphill = 4.25

-- Set to -1 to disable punching the cart from inside (min = -1)
carts.punch_speed_max = 5


dofile(carts.modpath.."/functions.lua")
dofile(carts.modpath.."/rails.lua")

-- Support for non-default games
if not default.player_attached then
	default.player_attached = {}
end

dofile(carts.modpath.."/cart_entity.lua")
