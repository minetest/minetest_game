spacetime = {}

-- On joinplayer

minetest.register_on_joinplayer(function(player)
    minetest.set_timeofday(0)
    minetest.setting_set("time_speed", 0)
end)
