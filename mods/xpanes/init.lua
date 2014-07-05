xpanes = {}

local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end

local directions = {
    {x = 1, y = 0, z = 0},
    {x = 0, y = 0, z = 1},
    {x = -1, y = 0, z = 0},
    {x = 0, y = 0, z = -1},
}

local function update_pane(pos,name)
    if minetest.get_node(pos).name:find("xpanes:"..name) == nil then
        return
    end
    local sum = 0
    for i = 1, 4 do
        local node = minetest.get_node({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
	local pane_num = minetest.registered_nodes[node.name].groups.pane or 0
        if (minetest.registered_nodes[node.name].walkable ~= false and minetest.registered_nodes[node.name].drawtype ~= "nodebox") or pane_num > 0 then
            sum = sum + 2 ^ (i - 1)
        end
    end
    if sum == 0 then
        sum = 15
    end
    minetest.set_node(pos, {name = "xpanes:"..name.."_"..sum})
end

local function update_nearby(pos,n)
    if n == nil then n = minetest.get_node(pos) end
    if not n or not n.name then return end
    local name = string.sub(n.name,8,10)
    if name ~=  "bar" then name = "pane" end
    for i = 1,4 do
        update_pane({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z}, name)
    end
end

local half_blocks = {
    {0, -0.5, -1/32, 0.5, 0.5, 1/32},
    {-1/32, -0.5, 0, 1/32, 0.5, 0.5},
    {-0.5, -0.5, -1/32, 0, 0.5, 1/32},
    {-1/32, -0.5, -0.5, 1/32, 0.5, 0}
}

local full_blocks = {
    {-0.5, -0.5, -1/32, 0.5, 0.5, 1/32},
    {-1/32, -0.5, -0.5, 1/32, 0.5, 0.5}
}

local sb_half_blocks = {
    {0, -0.5, -0.06, 0.5, 0.5, 0.06},
    {-0.06, -0.5, 0, 0.06, 0.5, 0.5},
    {-0.5, -0.5, -0.06, 0, 0.5, 0.06},
    {-0.06, -0.5, -0.5, 0.06, 0.5, 0}
}

local sb_full_blocks = {
    {-0.5, -0.5, -0.06, 0.5, 0.5, 0.06},
    {-0.06, -0.5, -0.5, 0.06, 0.5, 0.5}
}
--register panes and bars
function xpanes.register_pane(name, def)
for i = 1, 15 do
    local need = {}
    local cnt = 0
    for j = 1, 4 do
        if rshift(i, j - 1) % 2 == 1 then
            need[j] = true
            cnt = cnt + 1
        end
    end
    local take = {}
    local take2 = {}
    if need[1] == true and need[3] == true then
        need[1] = nil
        need[3] = nil
        table.insert(take, full_blocks[1])
        table.insert(take2, sb_full_blocks[1])
    end
    if need[2] == true and need[4] == true then
        need[2] = nil
        need[4] = nil
        table.insert(take, full_blocks[2])
        table.insert(take2, sb_full_blocks[2])
    end
    for k in pairs(need) do
        table.insert(take, half_blocks[k])
        table.insert(take2, sb_half_blocks[k])
    end
    local texture = def.textures[1]
    if cnt == 1 then
        texture = def.textures[1].."^"..def.textures[2]
    end
    minetest.register_node("xpanes:"..name.."_"..i, {
        drawtype = "nodebox",
        tiles = {def.textures[3], def.textures[3], texture},
        paramtype = "light",
        groups = def.groups,
        drop = "xpanes:"..name,
	sounds = def.sounds,
        node_box = {
            type = "fixed",
            fixed = take
        },
        selection_box = {
            type = "fixed",
            fixed = take2
        }
    })
end

minetest.register_node("xpanes:"..name, def)

minetest.register_craft({
	output = "xpanes:"..name.." 16",
	recipe = def.recipe
})
end

minetest.register_on_placenode(update_nearby)
minetest.register_on_dignode(update_nearby)

xpanes.register_pane("pane", {
    description = "Glass Pane",
    tiles = {"xpanes_space.png"},
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    air_equivalent = true,
    textures = {"default_glass.png","xpanes_pane_half.png","xpanes_white.png"},
    inventory_image = "default_glass.png",
    wield_image = "default_glass.png",
    sounds = default.node_sound_glass_defaults(),
    groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,pane=1},
    on_construct = function(pos)
	update_pane(pos, "pane")
    end,
    recipe = {
		{'default:glass', 'default:glass', 'default:glass'},
        {'default:glass', 'default:glass', 'default:glass'}
	}
})

xpanes.register_pane("bar", {
    description = "Iron bar",
    tiles = {"xpanes_space.png"},
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    air_equivalent = true,
    textures = {"xpanes_bar.png","xpanes_bar.png","xpanes_space.png"},
    inventory_image = "xpanes_bar.png",
    wield_image = "xpanes_bar.png",
    groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,pane=1},
    sounds = default.node_sound_stone_defaults(),
    on_construct = function(pos)
	update_pane(pos, "bar")
    end,
    recipe = {
		{'default:steel_ingot', 'default:glass', 'default:glass'},
        {'default:glass', 'default:glass', 'default:glass'}
	}
})
