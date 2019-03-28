
carts = {}
carts.modpath = minetest.get_modpath("carts")
carts.railparams = {}

-- Maximal speed of the cart in m/s (min = -1)
carts.speed_max = 7
-- Set to -1 to disable punching the cart from inside (min = -1)
carts.punch_speed_max = 5
-- Maximal distance for the path correction (for dtime peaks)
carts.path_distance_max = 3


dofile(carts.modpath.."/functions.lua")
dofile(carts.modpath.."/rails.lua")
dofile(carts.modpath.."/cart_entity.lua")

-- register cart as dungeon loot
if dungeon_loot and dungeon_loot.register then
	local loot_list = {
		{name = "carts:rail", chance = 0.35, count = {1, 6}},
	}
	for _,loot in pairs(loot_list) do
		dungeon_loot.register(loot)
    end
end