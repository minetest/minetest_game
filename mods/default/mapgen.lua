-- minetest/default/mapgen.lua

local function generate_ore(name, wherein, minp, maxp, seed, chunks_per_volume, ore_per_chunk, height_min, height_max)
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed)
	local num_chunks = math.floor(chunks_per_volume * volume)
	local inverse_chance = math.floor(27 / ore_per_chunk)
	--print("generate_ore num_chunks: "..dump(num_chunks))
	for i=1,num_chunks do
		local y0 = pr:next(y_min, y_max)
		if y0 >= height_min and y0 <= height_max then
			local x0 = pr:next(minp.x, maxp.x)
			local z0 = pr:next(minp.z, maxp.z)
			local p0 = {x=x0, y=y0, z=z0}
			for x1=-1,1 do
			for y1=-1,1 do
			for z1=-1,1 do
				if pr:next(1,inverse_chance) == 1 then
					local x2 = x0+x1
					local y2 = y0+y1
					local z2 = z0+z1
					local p2 = {x=x2, y=y2, z=z2}
					if minetest.env:get_node(p2).name == wherein then
						minetest.env:set_node(p2, {name=name})
					end
				end
			end
			end
			end
		end
	end
	--print("generate_ore done")
end

minetest.register_on_generated(function(minp, maxp, seed)
	generate_ore("default:stone_with_coal", "default:stone", minp, maxp, seed,   1/8/8/8, 5, -64, 64)
	generate_ore("default:stone_with_iron", "default:stone", minp, maxp, seed+1, 1/16/16/16, 5, 3, 7)
	generate_ore("default:stone_with_iron", "default:stone", minp, maxp, seed+2, 1/12/12/12, 5, -16, 2)
	generate_ore("default:stone_with_iron", "default:stone", minp, maxp, seed+3, 1/9/9/9, 5, -64, -17)
	-- Generate clay
	if maxp.y >= 2 and minp.y <= 0 then
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=1,divs do
		for divz=1,divs do
			local cx = minp.x + math.floor((divx+0.5)*divlen)
			local cz = minp.z + math.floor((divz+0.5)*divlen)
			local is_shallow = true
			if minetest.env:get_node({x=cx-divlen*2,y=1,z=cz+0}).name == "default:water_source" or
					minetest.env:get_node({x=cx+divlen*2,y=1,z=cz+0}).name == "default:water_source" or
					minetest.env:get_node({x=cx,y=1,z=cz-divlen*2}).name == "default:water_source" or
					minetest.env:get_node({x=cx,y=1,z=cz+divlen*2}).name == "default:water_source" then
				is_shallow = false
			end	
			if is_shallow and
					minetest.env:get_node({x=cx,y=1,z=cz}).name == "default:water_source" and
					minetest.env:get_node({x=cx,y=0,z=cz}).name == "default:sand" then
				for x1=-divlen,divlen do
				for z1=-divlen,divlen do
					if minetest.env:get_node({x=cx+x1,y=0,z=cz+z1}).name == "default:sand" then
						minetest.env:set_node({x=cx+x1,y=0,z=cz+z1}, {name="default:clay"})
					end
				end
				end
			end
		end
		end
	end
end)

