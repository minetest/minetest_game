local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_tree = minetest.get_content_id("default:tree")
local c_leaves = minetest.get_content_id("default:leaves")
local c_apple = minetest.get_content_id("default:apple")

function default.grow_tree(data, a, pos, is_apple_tree, seed)
        --[[
                NOTE: Tree-placing code is currently duplicated in the engine
                and in games that have saplings; both are deprecated but not
                replaced yet
        ]]--
    local hight = math.random(4, 5)
    for x_area = -2, 2 do
    for y_area = -1, 2 do
    for z_area = -2, 2 do
        if math.random(1,30) < 23 then  --randomize leaves
            local area_l = a:index(pos.x+x_area, pos.y+hight+y_area-1, pos.z+z_area)  --sets area for leaves
            if data[area_l] == c_air or data[area_l] == c_ignore then    --sets if not air or ignore
                if is_apple_tree == true and math.random(1, 100) <=  10 then  --randomize apples
                    data[area_l] = c_apple  --add apples now
                else 
                    data[area_l] = c_leaves    --add leaves now
                end
            end
         end       
    end
    end
    end
    for tree_h = 0, hight-1 do  -- add the trunk
        local area_t = a:index(pos.x, pos.y+tree_h, pos.z)  --set area for tree
        if data[area_t] == c_air or data[area_t] == c_leaves or data[area_t] == c_apple then    --sets if air
            data[area_t] = c_tree    --add tree now
        end
	end
end

local c_jungletree = minetest.get_content_id("default:jungletree")
local c_jungleleaves = minetest.get_content_id("default:jungleleaves")

function default.grow_jungletree(data, a, pos, seed)
        --[[
                NOTE: Tree-placing code is currently duplicated in the engine
                and in games that have saplings; both are deprecated but not
                replaced yet
        ]]--
    local hight = math.random(8, 12)
    for x_area = -3, 3 do
    for y_area = -2, 2 do
    for z_area = -3, 3 do
        if math.random(1,30) < 23 then  --randomize leaves
            local area_l = a:index(pos.x+x_area, pos.y+hight+y_area-1, pos.z+z_area)  --sets area for leaves
            if data[area_l] == c_air or data[area_l] == c_ignore then    --sets if not air or ignore
                data[area_l] = c_jungleleaves    --add leaves now
            end
         end       
    end
    end
    end
    for tree_h = 0, hight-1 do  -- add the trunk
        local area_t = a:index(pos.x, pos.y+tree_h, pos.z)  --set area for tree
        if data[area_t] == c_air or data[area_t] == c_jungleleaves then    --sets if air
            data[area_t] = c_jungletree    --add tree now
        end
    end
    for roots_x = -1, 1 do
    for roots_z = -1, 1 do
        if math.random(1, 3) >= 2 then  --randomize roots
            if a:contains(pos.x+roots_x, pos.y-1, pos.z+roots_z) and data[a:index(pos.x+roots_x, pos.y-1, pos.z+roots_z)] == c_air then
                data[a:index(pos.x+roots_x, pos.y-1, pos.z+roots_z)] = c_jungletree
            elseif a:contains(pos.x+roots_x, pos.y, pos.z+roots_z) and data[a:index(pos.x+roots_x, pos.y, pos.z+roots_z)] == c_air then
                data[a:index(pos.x+roots_x, pos.y, pos.z+roots_z)] = c_jungletree
            end
        end
    end
    end
end