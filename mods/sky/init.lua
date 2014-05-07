
-- Set time to midnight.
minetest.register_on_joinplayer(function(player)
    minetest.set_timeofday(0)
    minetest.setting_set("time_speed", 0)
end)

-- Disable clouds.
minetest.register_on_joinplayer(function(player)
    minetest.setting_set("enable_clouds", 0)
end)
