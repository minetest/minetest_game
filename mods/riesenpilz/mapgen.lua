local minetest = minetest	--Should make things a bit faster.

local c
local function define_contents()
	c = {
		ignore = minetest.get_content_id("ignore"),
		air = minetest.get_content_id("air"),

		water = minetest.get_content_id("default:water_source"),
		stone = minetest.get_content_id("default:stone"),
		dirt = minetest.get_content_id("default:dirt"),
		desert_sand = minetest.get_content_id("default:desert_sand"),

		dry_shrub = minetest.get_content_id("default:dry_shrub"),

		ground = minetest.get_content_id("riesenpilz:ground"),
		riesenpilz_brown = minetest.get_content_id("riesenpilz:brown"),
		riesenpilz_red = minetest.get_content_id("riesenpilz:red"),
		riesenpilz_fly_agaric = minetest.get_content_id("riesenpilz:fly_agaric"),
		riesenpilz_lavashroom = minetest.get_content_id("riesenpilz:lavashroom"),
		riesenpilz_glowshroom = minetest.get_content_id("riesenpilz:glowshroom"),
		riesenpilz_parasol = minetest.get_content_id("riesenpilz:parasol"),

		TREE_STUFF = {
			minetest.get_content_id("default:tree"),
			minetest.get_content_id("default:leaves"),
			minetest.get_content_id("default:apple"),
			minetest.get_content_id("default:jungletree"),
			minetest.get_content_id("default:jungleleaves"),
			minetest.get_content_id("default:junglegrass"),
		},
	}
end


local grounds = {}
local function is_ground(id)
	local is = grounds[id]
	if is ~= nil then
		return is
	end
	local data = minetest.registered_nodes[minetest.get_name_from_content_id(id)]
	if not data
	or data.paramtype == "light" then
		grounds[id] = false
		return false
	end
	local groups = data.groups
	if groups
	and (groups.crumbly == 3 or groups.soil == 1) then
		grounds[id] = true
		return true
	end
	grounds[id] = false
	return false
end

local toremoves = {}
local function is_toremove(id)
	local is = toremoves[id]
	if is ~= nil then
		return is
	end
	local data = minetest.registered_nodes[minetest.get_name_from_content_id(id)]
	if not data then
		toremoves[id] = false
		return false
	end
	local groups = data.groups
	if groups
	and groups.flammable then
		toremoves[id] = true
		return true
	end
	toremoves[id] = false
	return false
end


local data = {}
local area, pr
local function make_circle(nam, pos, radius, chance)
	local circle = riesenpilz.circle(radius)
	for i = 1, #circle do
		if pr:next(1, chance) == 1 then
			local vi = area:indexp(vector.add(pos, circle[i]))
			if data[vi] == c.air
			and is_ground(data[vi - area.ystride]) then
				data[vi] = nam
			end
		end
	end
end


local nosmooth_rarity = 0.5
local smooth_rarity_max = 0.6
local smooth_rarity_min = 0.4
local smooth_rarity_dif = smooth_rarity_max - smooth_rarity_min
local perlin_scale = 500

local contents_defined
minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y <= 0
	or minp.y >= 150 then --avoid generation in the sky
		return
	end

	local x0,z0,x1,z1 = minp.x,minp.z,maxp.x,maxp.z	-- Assume X and Z lengths are equal
	local perlin1 = minetest.get_perlin(51,3, 0.5, perlin_scale)	--Get map specific perlin

	if not riesenpilz.always_generate then
		local biome_allowed
		for x = x0, x1, 16 do
			for z = z0, z1, 16 do
				if perlin1:get2d({x=x, y=z}) > nosmooth_rarity then
					biome_allowed = true
					break
				end
			end
			if biome_allowed then
				break
			end
		end
		if not biome_allowed then
			return
		end
	end

	local t1 = os.clock()
	riesenpilz.inform(("tries to generate a giant mushroom biome at: " ..
		"x=[%d; %d]; y=[%d; %d]; z=[%d; %d]"):format(minp.x, maxp.x, minp.y,
		maxp.y, minp.z, maxp.z), 2)

	if not contents_defined then
		define_contents()
		contents_defined = true
	end

	local divs = (maxp.x-minp.x);
	local num = 1
	local tab = {}
	pr = PseudoRandom(seed+68)

	local heightmap = minetest.get_mapgen_object("heightmap")
	local hmi = 1
	local hm_zstride = divs+1

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for p_pos in area:iterp(minp, maxp) do	--remove tree stuff
		local d_p_pos = data[p_pos]
		for _,nam in ipairs(c.TREE_STUFF) do
			if d_p_pos == nam then
				data[p_pos] = c.air
				break
			end
		end
	end

	for j=0,divs do
		for i=0,divs do
			local x,z = x0+i,z0+j

			--Check if we are in a "riesenpilz biome"
			local in_biome = false
			local test = perlin1:get2d({x=x, y=z})
			--smooth mapgen
			if riesenpilz.always_generate then
				in_biome = true
			elseif riesenpilz.smooth then
				if test >= smooth_rarity_max
				or (
					test > smooth_rarity_min
					and pr:next(1, 1000) <= ((test-smooth_rarity_min)/smooth_rarity_dif)*1000
				) then
					in_biome = true
				end
			elseif test > nosmooth_rarity then
				in_biome = true
			end

			if in_biome then

				local ymin = math.max(heightmap[hmi]-5, minp.y)
				local ymax = math.min(heightmap[hmi]+20, maxp.y)

				-- skip the air part
				local ground
				local vi = area:index(x, ymax, z)
				for y = ymax, ymin, -1 do
					if data[vi] ~= c.air then
						ground = y
						break
					end
					vi = vi - area.ystride
				end

				local ground_y
				if ground then
					for y = ground, ymin, -1 do
						local d_p_pos = data[vi]
						if is_toremove(d_p_pos) then
							-- remove trees etc.
							data[vi] = c.air
						else
							if is_ground(d_p_pos) then
								ground_y = y
								heightmap[hmi] = y
							end
							break
						end
						vi = vi - area.ystride
					end
				end

				if ground_y then
					-- add ground and dirt below if needed
					data[vi] = c.ground
					for off = -1,-5,-1 do
						local p_pos = vi + off * area.ystride
						if not is_ground(data[p_pos])
						or data[p_pos] == c.dirt then
							break
						end
						data[p_pos] = c.dirt
					end

					local bigtype
					local boden = {x=x,y=ground_y+1,z=z}
					if pr:next(1,15) == 1 then
						data[vi + area.ystride] = c.dry_shrub
					elseif pr:next(1,80) == 1 then
						make_circle(c.riesenpilz_brown, boden, pr:next(3,4), 3)
					elseif pr:next(1,85) == 1 then
						make_circle(c.riesenpilz_parasol, boden, pr:next(3,5), 3)
					elseif pr:next(1,90) == 1 then
						make_circle(c.riesenpilz_red, boden, pr:next(4,5), 3)
					elseif pr:next(1,100) == 1 then
						make_circle(c.riesenpilz_fly_agaric, boden, 4, 3)
					elseif pr:next(1,340) == 10 then
						bigtype = 2
					elseif pr:next(1,380) == 1 then
						bigtype = 1
					elseif pr:next(1,390) == 20 then
						bigtype = 3
					elseif pr:next(1,800) == 7 then
						bigtype = 5
					elseif pr:next(1,4000) == 1 then
						make_circle(c.riesenpilz_lavashroom, boden, pr:next(5,6), 3)
					elseif pr:next(1,5000) == 1 then
						make_circle(c.riesenpilz_glowshroom, boden, 3, 3)
					elseif pr:next(1,6000) == 2 then
						if pr:next(1,200) == 15 then
							bigtype = 4
						elseif pr:next(1,2000) == 54 then
							bigtype = 6
						end
					end
					if bigtype then
						tab[num] = {bigtype, boden}
						num = num+1
					end
				end
			end
			hmi = hmi+1
		end
	end
	riesenpilz.inform("ground finished", 2, t1)

	local param2s
	if num ~= 1 then
		local t2 = os.clock()
		for _,v in pairs(tab) do
			local p = v[2]

			-- simple test for the distance to the biome border
			local found_border = false
			local dist = 5
			local xmin = math.max(minp.x, p.x - dist)
			local xmax = math.min(maxp.x, p.x + dist)
			local hm_vi = (p.z - minp.z) * hm_zstride + xmin - minp.x + 1
			for _ = xmin, xmax do
				if not heightmap[hm_vi] then
					found_border = true
					break
				end
				hm_vi = hm_vi+1
			end
			if not found_border then
				local zmin = math.max(minp.z, p.z - dist)
				local zmax = math.min(maxp.z, p.z + dist)
				hm_vi = (zmin - minp.z) * hm_zstride + p.x - minp.x + 1
				for _ = zmin, zmax do
					if not heightmap[hm_vi] then
						found_border = true
						break
					end
					hm_vi = hm_vi + hm_zstride
				end
			end

			if not found_border then
				local m = v[1]
				if m == 1 then
					riesenpilz.red(p, data, area)
				elseif m == 2 then
					riesenpilz.brown(p, data, area)
				elseif m == 3 then
					if not param2s then
						param2s = vm:get_param2_data()
					end
					riesenpilz.fly_agaric(p, data, area, param2s)
				elseif m == 4 then
					riesenpilz.lavashroom(p, data, area)
				elseif m == 5 then
					riesenpilz.parasol(p, data, area)
				elseif m == 6 then
					riesenpilz.red45(p, data, area)
				end
			end
		end
		riesenpilz.inform("giant shrooms generated", 2, t2)
	end

	local t2 = os.clock()
	vm:set_data(data)
	if param2s then
		vm:set_param2_data(param2s)
	end
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map()
	area = nil
	riesenpilz.inform("data set", 2, t2)

	riesenpilz.inform("done", 1, t1)
end)
