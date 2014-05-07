
-- Set time to midnight.
minetest.register_on_joinplayer(function(player)
    minetest.set_timeofday(0)
    minetest.setting_set("time_speed", 0)
end)

-- Disable clouds.
minetest.register_on_joinplayer(function(player)
    minetest.setting_set("enable_clouds", 0)
end)

-- Sky textures
minetest.register_on_joinplayer(function(player)
	minetest.after(0, function()
		textures ={
		"pink_planet_pos_y.png",
		"pink_planet_neg_y.png",
		"pink_planet_pos_z.png",
		"pink_planet_neg_z.png",	
		"pink_planet_neg_x.png",
		"pink_planet_pos_x.png",
		}
		
		player:set_sky({r=0, g=0, b=0, a=0},"skybox", textures)
	end)
end)
