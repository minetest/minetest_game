-- Mapgen

dofile(minetest.get_modpath("mapgen").."/ores.lua")

-- Set mapgen mode to v7
minetest.register_on_mapgen_init(function(params)
	minetest.set_mapgen_params({
		mgname = "v7",
		seed = params.seed,
		water_level = -10,
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