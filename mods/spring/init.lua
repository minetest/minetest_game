minetest.register_node("default:water_spring",{
    description = "Water Spring",
    tiles = {"default_water.png"},
})

minetest.register_node("default:lava_spring",{
    description = "Lava Spring",
    tiles = {"default_lava.png"},
})

-- if minetest.setting_getbool("liquid_finite") then
minetest.register_abm({
    nodenames = {"default:water_spring"},
    interval = 1,
    chance = 1,
    action = function(pos,node)
        minetest.env:set_node(pos,{name = "default:water_source", param2=128})
    end
})

minetest.register_abm({
    nodenames = {"default:lava_spring"},
    interval = 1,
    chance = 1,
    action = function(pos,node)
        minetest.env:set_node(pos,{name = "default:lava_source", param2=128})
    end
})
-- end
