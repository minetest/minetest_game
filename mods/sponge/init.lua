
minetest.register_node("sponge:sponge", {
	description = "Sponge",
	drawtype = "normal",
	tiles = {"sponge.png"},
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	groups = {snappy=2, flammable=1},
})

minetest.register_node("sponge:iron_sponge", {
	description = "Iron Sponge",
	drawtype = "normal",
	tiles = {"iron_sponge.png"},
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	groups = {cracky=2},
})


--[[
minetest.register_node("sponge:fake_air", {
	description = "Fake Air",
	drawtype = "airlike",
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1},
})

local replacewith = "sponge:fake_air"
if minetest.setting_get("liquid_finite") and minetest.setting_get("liquid_relax") > "0" then
    replacewith = "air"
end
]]

if minetest.setting_get("liquid_finite") then

local replacewith = "air"

minetest.register_abm({
    nodenames = {"default:water_source", "default:water_flowing"},
    neighbors = {"sponge:sponge", "sponge:iron_sponge"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
            minetest.env:add_node(pos, {name=replacewith})
    end
})

minetest.register_abm(
{nodenames = {"sponge:sponge"},
interval = 1.0,
chance = 1,
action = function(pos, node, active_object_count, active_object_count_wider)
    for i=-1,1 do
        for j=-1,1 do
            for k=-1,1 do
                p = {x=pos.x+i, y=pos.y+j, z=pos.z+k}
                n = minetest.env:get_node(p)
                if (n.name=="default:water_flowing") 
                or (n.name == "default:water_source") then
                    minetest.env:add_node(p, {name=replacewith})
                end
            end
        end
    end
end
})

minetest.register_abm(
{nodenames = {"sponge:iron_sponge"},
interval = 1.0,
chance = 1,
action = function(pos, node, active_object_count, active_object_count_wider)
    for i=-2,2 do
        for j=-2,2 do
            for k=-2,2 do
                p = {x=pos.x+i, y=pos.y+j, z=pos.z+k}
                n = minetest.env:get_node(p)
                if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].liquidtype ~= "none" then
                    minetest.env:add_node(p, {name=replacewith})
                end
            end
        end
    end
end
})

--[[
minetest.register_abm(
{nodenames = {"sponge:fake_air"},
interval = 1.0,
chance = 1,
action = function(pos, node, active_object_count, active_object_count_wider)
    spongecount=0
    for i=-2,2 do
        for j=-2,2 do
            for k=-2,2 do
                p = {x=pos.x+i, y=pos.y+j, z=pos.z+k}
                n = minetest.env:get_node(p)
                if (n.name=="sponge:iron_sponge") or (n.name == "sponge:sponge") then
                spongecount=spongecount+1
                end
            end
        end
    end
    if (spongecount==0) then
        minetest.env:add_node(pos, {name="air"})
    end
end
})
]]

minetest.register_craft({
	output = "sponge:sponge",
	recipe = {
		{'default:leaves', 'default:leaves', 'default:leaves'},
		{'default:leaves', 'default:mese', 'default:leaves'},
		{'default:leaves', 'default:leaves', 'default:leaves'},
	}
})

minetest.register_craft({
	output = "sponge:iron_sponge",
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'sponge:sponge', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

end
