-- Mapgen

dofile(minetest.get_modpath("mapgen").."/ores.lua")

-- Set mapgen mode to v7
minetest.register_on_mapgen_init(function(params)
	minetest.set_mapgen_params({
		mgname = "v7",
		seed = params.seed,
		water_level = 1,
		flags = "caves",
	})
end)

-- Dust Biome
minetest.register_biome({
	name = "plains",
	node_top = "moontest:dust",
	depth_top = 2,
	node_bottom = "moontest:stone",
	node_dust = "air",
	height_min = 3,
	height_max = 30,
})

-- Basalt Biome
minetest.register_biome({
	name = "basalt",
	node_top = "moontest:basalt",
	depth_top = 2,
	node_filler = "moontest:dust",
	depth_filler = 1,
	node_dust = "air",
	height_min = -50,
	height_max = 5,
})

-- Lunar Ice Cap Biome
minetest.register_biome({
	name = "plains",
	node_top = "moontest:waterice",
	depth_top = 4,
	node_filler = "moontest:dust",
	depth_filler = 2,
	node_dust = "air",
	height_min = 25,
	height_max = 100,
})

-- Aliases

minetest.register_alias("mapgen_lava_source", "moontest:hlsource")
minetest.register_alias("mapgen_water_source", "moontest:hlsource")
minetest.register_alias("mapgen_stone", "moontest:stone")
minetest.register_alias("mapgen_dirt", "moontest:dust")

--treegen function
local function moontest_tree(x, y, z, area, data)

	local c_tree = minetest.get_content_id("moontest:tree")
	local c_leaves = minetest.get_content_id("moontest:leaves")
	for j = -2, 4 do
		if j >= 1 then
			for i = -2, 2 do
			for k = -2, 2 do
				local vi = area:index(x + i, y + j + 1, z + k)
				if math.random(3) ~= 2 then
					data[vi] = c_leaves
				end
			end
			end
		end
		local vi = area:index(x, y + j, z)
		data[vi] = c_tree
	end
end

--Set everything to vacuum on generate
minetest.register_on_generated(function(minp, maxp, seed)
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	--fire up the voxel manipulator
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	--get the content ID #'s of air and vacuum
	local c_air = minetest.get_content_id("air")
	local c_vac = minetest.get_content_id("moontest:vacuum")
	local c_dust = minetest.get_content_id("moontest:dust")
	--loop through every node of the chunk
	for z = z0, z1 do
		for x = x0, x1 do
			for y = y0, y1 do
			    --grab the location of the node in question
				local vi = area:index(x, y, z)
				--if it's air, it won't be now!
				if data[vi] == c_air then
					data[vi] = c_vac
				end
			end
			--gen trees
			--find surface
			local yasurf = false -- y of above surface node
			for y = y1, 2, -1 do --decrement, not increment
				local vi = area:index(x, y, z)
				local c_node = data[vi]
				if y == y1 and c_node ~= c_vac then -- if top node solid
					break
				elseif c_node == c_dust then --if first surface node
					yasurf = y + 1 --set the position of the surface
					break
				end
			end
			if yasurf then --if surface was found
				if math.random() <= 0.0001337 then --much LEET
					moontest_tree(x, yasurf+1, z, area, data)--place a tree
				end
			end
		end
	end
	--write the voxel manipulator data back to world
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
end)

--make lava delete vacuum nodes nearby so as to allow flowing
minetest.register_abm({
	nodenames = {"group:lava"},
	neighbors = {"moontest:vacuum"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for x = -1,1 do
			for y = -1,1 do
				for z = -1,1 do
					n_pos = {x=x + pos.x,y=y+pos.y,z=z+pos.z}
					n_name = minetest.get_node(n_pos).name
					if n_name == "moontest:vacuum" then
						minetest.remove_node(n_pos)
					end
				end
			end
		end
	end,
})