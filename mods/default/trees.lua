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
        local pr = PseudoRandom(seed)
        local th = pr:next(4, 5)
        local x, y, z = pos.x, pos.y, pos.z
        for yy = y, y+th-1 do
                local vi = a:index(x, yy, z)
                if a:contains(x, yy, z) and (data[vi] == c_air or yy == y) then
                        data[vi] = c_tree
                end
        end
        y = y+th-1 -- (x, y, z) is now last piece of trunk
        local leaves_a = VoxelArea:new{MinEdge={x=-2, y=-1, z=-2}, MaxEdge={x=2, y=2, z=2}}
        local leaves_buffer = {}
        
        -- Force leaves near the trunk
        local d = 1
        for xi = -d, d do
        for yi = -d, d do
        for zi = -d, d do
                leaves_buffer[leaves_a:index(xi, yi, zi)] = true
        end
        end
        end
        
        -- Add leaves randomly
        for iii = 1, 8 do
                local d = 1
                local xx = pr:next(leaves_a.MinEdge.x, leaves_a.MaxEdge.x - d)
                local yy = pr:next(leaves_a.MinEdge.y, leaves_a.MaxEdge.y - d)
                local zz = pr:next(leaves_a.MinEdge.z, leaves_a.MaxEdge.z - d)
                
                for xi = 0, d do
                for yi = 0, d do
                for zi = 0, d do
                        leaves_buffer[leaves_a:index(xx+xi, yy+yi, zz+zi)] = true
                end
                end
                end
        end
        
        -- Add the leaves
        for xi = leaves_a.MinEdge.x, leaves_a.MaxEdge.x do
        for yi = leaves_a.MinEdge.y, leaves_a.MaxEdge.y do
        for zi = leaves_a.MinEdge.z, leaves_a.MaxEdge.z do
                if a:contains(x+xi, y+yi, z+zi) then
                        local vi = a:index(x+xi, y+yi, z+zi)
                        if data[vi] == c_air or data[vi] == c_ignore then
                                if leaves_buffer[leaves_a:index(xi, yi, zi)] then
                                        if is_apple_tree and pr:next(1, 100) <=  10 then
                                                data[vi] = c_apple
                                        else
                                                data[vi] = c_leaves
                                        end
                                end
                        end
                end
        end
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
        local pr = PseudoRandom(seed)
        local x, y, z = pos.x, pos.y, pos.z
        for xi = -1, 1 do
        for zi = -1, 1 do
                if pr:next(1, 3) >= 2 then
                        local vi1 = a:index(x+xi, y, z+zi)
                        local vi2 = a:index(x+xi, y-1, z+zi)
                        if a:contains(x+xi, y-1, z+zi) and data[vi2] == c_air then
                                data[vi2] = c_jungletree
                        elseif a:contains(x+xi, y, z+zi) and data[vi1] == c_air then
                                data[vi1] = c_jungletree
                        end
                end
        end
        end
        
        local th = pr:next(8, 12)
        for yy = y, y+th-1 do
                local vi = a:index(x, yy, z)
                if a:contains(x, yy, z) and (data[vi] == c_air or yy == y) then
                        data[vi] = c_jungletree
                end
        end
        y = y+th-1 -- (x, y, z) is now last piece of trunk
        local leaves_a = VoxelArea:new{MinEdge={x=-3, y=-2, z=-3}, MaxEdge={x=3, y=2, z=3}}
        local leaves_buffer = {}
        
        -- Force leaves near the trunk
        local d = 1
        for xi = -d, d do
        for yi = -d, d do
        for zi = -d, d do
                leaves_buffer[leaves_a:index(xi, yi, zi)] = true
        end
        end
        end
        
        -- Add leaves randomly
        for iii = 1, 30 do
                local d = 1
                local xx = pr:next(leaves_a.MinEdge.x, leaves_a.MaxEdge.x - d)
                local yy = pr:next(leaves_a.MinEdge.y, leaves_a.MaxEdge.y - d)
                local zz = pr:next(leaves_a.MinEdge.z, leaves_a.MaxEdge.z - d)
                
                for xi = 0, d do
                for yi = 0, d do
                for zi = 0, d do
                        leaves_buffer[leaves_a:index(xx+xi, yy+yi, zz+zi)] = true
                end
                end
                end
        end
        
        -- Add the leaves
        for xi = leaves_a.MinEdge.x, leaves_a.MaxEdge.x do
        for yi = leaves_a.MinEdge.y, leaves_a.MaxEdge.y do
        for zi = leaves_a.MinEdge.z, leaves_a.MaxEdge.z do
                if a:contains(x+xi, y+yi, z+zi) then
                        local vi = a:index(x+xi, y+yi, z+zi)
                        if data[vi] == c_air or data[vi] == c_ignore then
                                if leaves_buffer[leaves_a:index(xi, yi, zi)] then
                                        data[vi] = c_jungleleaves
                                end
                        end
                end
        end
        end
        end
end
