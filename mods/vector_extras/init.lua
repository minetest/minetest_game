local path = minetest.get_modpath"vector_extras"

local funcs = {}

function funcs.pos_to_string(pos)
	return "("..pos.x.."|"..pos.y.."|"..pos.z..")"
end

local r_corr = 0.25 --remove a bit more nodes (if shooting diagonal) to let it
-- look like a hole (sth like antialiasing)

-- this doesn't need to be calculated every time
local f_1 = 0.5-r_corr
local f_2 = 0.5+r_corr

--returns information about the direction
local function get_used_dir(dir)
	local abs_dir = {x=math.abs(dir.x), y=math.abs(dir.y), z=math.abs(dir.z)}
	local dir_max = math.max(abs_dir.x, abs_dir.y, abs_dir.z)
	if dir_max == abs_dir.x then
		local tab = {"x", {x=1, y=dir.y/dir.x, z=dir.z/dir.x}}
		if dir.x >= 0 then
			tab[3] = "+"
		end
		return tab
	end
	if dir_max == abs_dir.y then
		local tab = {"y", {x=dir.x/dir.y, y=1, z=dir.z/dir.y}}
		if dir.y >= 0 then
			tab[3] = "+"
		end
		return tab
	end
	local tab = {"z", {x=dir.x/dir.z, y=dir.y/dir.z, z=1}}
	if dir.z >= 0 then
		tab[3] = "+"
	end
	return tab
end

local function node_tab(z, d)
	local n1 = math.floor(z*d+f_1)
	local n2 = math.floor(z*d+f_2)
	if n1 == n2 then
		return {n1}
	end
	return {n1, n2}
end

local function return_line(pos, dir, range) --range ~= length
	local tab = {}
	local num = 1
	local t_dir = get_used_dir(dir)
	local dir_typ = t_dir[1]
	local f_tab
	if t_dir[3] == "+" then
		f_tab = {0, range, 1}
	else
		f_tab = {0, -range, -1}
	end
	local d_ch = t_dir[2]
	if dir_typ == "x" then
		for d = f_tab[1],f_tab[2],f_tab[3] do
			local x = d
			local ytab = node_tab(d_ch.y, d)
			local ztab = node_tab(d_ch.z, d)
			for _,y in ipairs(ytab) do
				for _,z in ipairs(ztab) do
					tab[num] = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
					num = num+1
				end
			end
		end
	elseif dir_typ == "y" then
		for d = f_tab[1],f_tab[2],f_tab[3] do
			local xtab = node_tab(d_ch.x, d)
			local y = d
			local ztab = node_tab(d_ch.z, d)
			for _,x in ipairs(xtab) do
				for _,z in ipairs(ztab) do
					tab[num] = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
					num = num+1
				end
			end
		end
	else
		for d = f_tab[1],f_tab[2],f_tab[3] do
			local xtab = node_tab(d_ch.x, d)
			local ytab = node_tab(d_ch.y, d)
			local z = d
			for _,x in ipairs(xtab) do
				for _,y in ipairs(ytab) do
					tab[num] = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
					num = num+1
				end
			end
		end
	end
	return tab
end

function funcs.rayIter(pos, dir)
	-- make a table of possible movements
	local step = {}
	for i in pairs(pos) do
		local v = math.sign(dir[i])
		if v ~= 0 then
			step[i] = v
		end
	end

	local p
	return function()
		if not p then
			-- avoid skipping the first position
			p = vector.round(pos)
			return vector.new(p)
		end

		-- find the position which has the smallest distance to the line
		local choose = {}
		local choosefit = vector.new()
		for i in pairs(step) do
			choose[i] = vector.new(p)
			choose[i][i] = choose[i][i] + step[i]
			choosefit[i] = vector.dot(vector.normalize(vector.subtract(choose[i], pos)), dir)
		end
		p = choose[vector.get_max_coord(choosefit)]

		return vector.new(p)
	end
end

function funcs.fine_line(pos, dir, range)
	if not range then --dir = pos2
		dir, range = vector.direction(pos, dir), vector.distance(pos, dir)
	end
	local result,n = {},1
	for p in vector.rayIter(pos, dir) do
		if vector.distance(p, pos) > range then
			break
		end
		result[n] = p
		n = n+1
	end
	return result
end

function funcs.line(pos, dir, range, alt)
	--assert_vector(pos)
	if alt then
		if not range then --dir = pos2
			dir, range = vector.direction(pos, dir), vector.distance(pos, dir)
		end
		return return_line(pos, dir, range)
	end
	if range then
		dir = vector.round(vector.multiply(dir, range))
	else --dir = pos2
		dir = vector.subtract(dir, pos)
	end
	local line,n = {},1
	for _,i in ipairs(vector.threeline(dir.x, dir.y, dir.z)) do
		line[n] = {x=pos.x+i[1], y=pos.y+i[2], z=pos.z+i[3]}
		n = n+1
	end
	return line
end

local twolines = {}
function funcs.twoline(x, y)
	local pstr = x.." "..y
	local line = twolines[pstr]
	if line then
		return line
	end
	line = {}
	local n = 1
	local dirx = 1
	if x < 0 then
		dirx = -dirx
	end
	local ymin, ymax = 0, y
	if y < 0 then
		ymin, ymax = ymax, ymin
	end
	local m = y/x --y/0 works too
	local dir = 1
	if m < 0 then
		dir = -dir
	end
	for i = 0,x,dirx do
		local p1 = math.max(math.min(math.floor((i-0.5)*m+0.5), ymax), ymin)
		local p2 = math.max(math.min(math.floor((i+0.5)*m+0.5), ymax), ymin)
		for j = p1,p2,dir do
			line[n] = {i, j}
			n = n+1
		end
	end
	twolines[pstr] = line
	return line
end

local threelines = {}
function funcs.threeline(x, y, z)
	local pstr = x.." "..y.." "..z
	local line = threelines[pstr]
	if line then
		return line
	end
	if x ~= math.floor(x) then
		minetest.log("error", "[vector_extras] INFO: The position used for " ..
			"vector.threeline isn't round.")
	end
	local two_line = vector.twoline(x, y)
	line = {}
	local n = 1
	local zmin, zmax = 0, z
	if z < 0 then
		zmin, zmax = zmax, zmin
	end
	local m = z/math.hypot(x, y)
	local dir = 1
	if m < 0 then
		dir = -dir
	end
	for _,i in ipairs(two_line) do
		local px, py = unpack(i)
		local ph = math.hypot(px, py)
		local z1 = math.max(math.min(math.floor((ph-0.5)*m+0.5), zmax), zmin)
		local z2 = math.max(math.min(math.floor((ph+0.5)*m+0.5), zmax), zmin)
		for pz = z1,z2,dir do
			line[n] = {px, py, pz}
			n = n+1
		end
	end
	threelines[pstr] = line
	return line
end

function funcs.sort_positions(ps, preferred_coords)
	preferred_coords = preferred_coords or {"z", "y", "x"}
	local a,b,c = unpack(preferred_coords)
	local function ps_sorting(p1, p2)
		if p1[a] == p2[a] then
			if p1[b] == p2[a] then
				if p1[c] < p2[c] then
					return true
				end
			elseif p1[b] < p2[b] then
				return true
			end
		elseif p1[a] < p2[a] then
			return true
		end
	end
	table.sort(ps, ps_sorting)
end

-- Tschebyschew norm
function funcs.maxnorm(v)
	return math.max(math.max(math.abs(v.x), math.abs(v.y)), math.abs(v.z))
end

function funcs.sumnorm(v)
	return math.abs(v.x) + math.abs(v.y) + math.abs(v.z)
end

function funcs.pnorm(v, p)
	return (math.abs(v.x)^p + math.abs(v.y)^p + math.abs(v.z)^p)^(1 / p)
end

--not optimized
--local areas = {}
function funcs.plane(ps)
	-- sort positions and imagine the first one (A) as vector.zero
	vector.sort_positions(ps)
	local pos = ps[1]
	local B = vector.subtract(ps[2], pos)
	local C = vector.subtract(ps[3], pos)

	-- get the positions for the fors
	local cube_p1 = {x=0, y=0, z=0}
	local cube_p2 = {x=0, y=0, z=0}
	for i in pairs(cube_p1) do
		cube_p1[i] = math.min(B[i], C[i], 0)
		cube_p2[i] = math.max(B[i], C[i], 0)
	end
	cube_p1 = vector.apply(cube_p1, math.floor)
	cube_p2 = vector.apply(cube_p2, math.ceil)

	local vn = vector.normalize(vector.cross(B, C))

	local nAB = vector.normalize(B)
	local nAC = vector.normalize(C)
	local angle_BAC = math.acos(vector.dot(nAB, nAC))

	local nBA = vector.multiply(nAB, -1)
	local nBC = vector.normalize(vector.subtract(C, B))
	local angle_ABC = math.acos(vector.dot(nBA, nBC))

	for z = cube_p1.z, cube_p2.z do
		for y = cube_p1.y, cube_p2.y do
			for x = cube_p1.x, cube_p2.x do
				local p = {x=x, y=y, z=z}
				local n = -vector.dot(p, vn)/vector.dot(vn, vn)
				if math.abs(n) <= 0.5 then
					local ep = vector.add(p, vector.multiply(vn, n))
					local nep = vector.normalize(ep)
					local angle_BAep = math.acos(vector.dot(nAB, nep))
					local angle_CAep = math.acos(vector.dot(nAC, nep))
					local angldif = angle_BAC - (angle_BAep+angle_CAep)
					if math.abs(angldif) < 0.001 then
						ep = vector.subtract(ep, B)
						nep = vector.normalize(ep)
						local angle_ABep = math.acos(vector.dot(nBA, nep))
						local angle_CBep = math.acos(vector.dot(nBC, nep))
						angldif = angle_ABC - (angle_ABep+angle_CBep)
						if math.abs(angldif) < 0.001 then
							table.insert(ps, vector.add(pos, p))
						end
					end
				end
			end
		end
	end
	return ps
end

function funcs.straightdelay(s, v, a)
	if not a then
		return s/v
	end
	return (math.sqrt(v*v+2*a*s)-v)/a
end

-- override vector.zero
-- builtin used not to have the vector.zero function. to keep compatibility,
-- vector.zero has to be a 0-vector and vector.zero() has to return a 0-vector
-- => we make a callable 0-vector table
if not vector.zero then
	vector.zero = {x = 0, y = 0, z = 0}
else
	local old_zero = vector.zero
	vector.zero = setmetatable({x = 0, y = 0, z = 0}, {__call = old_zero})
end

function funcs.sun_dir(time)
	if not time then
		time = minetest.get_timeofday()
	end
	local t = (time-0.5)*5/6+0.5 --the sun rises at 5 o'clock, not at 6
	if t < 0.25
	or t > 0.75 then
		return
	end
	local tmp = math.cos(math.pi*(2*t-0.5))
	return {x=tmp, y=math.sqrt(1-tmp*tmp), z=0}
end

function funcs.inside(pos, minp, maxp)
	for _,i in pairs({"x", "y", "z"}) do
		if pos[i] < minp[i]
		or pos[i] > maxp[i] then
			return false
		end
	end
	return true
end

function funcs.minmax(pos1, pos2)
	local p1 = vector.new(pos1)
	local p2 = vector.new(pos2)
	for _,i in ipairs({"x", "y", "z"}) do
		if p1[i] > p2[i] then
			p1[i], p2[i] = p2[i], p1[i]
		end
	end
	return p1, p2
end

function funcs.move(p1, p2, s)
	return vector.round(
		vector.add(
			vector.multiply(
				vector.direction(
					p1,
					p2
				),
				s
			),
			p1
		)
	)
end

function funcs.from_number(i)
	return {x=i, y=i, z=i}
end

local adammil_fill = dofile(path .. "/adammil_flood_fill.lua")
function funcs.search_2d(go_test, x0, y0, allow_revisit, give_map)
	local marked_places = adammil_fill(go_test, x0, y0, allow_revisit)
	if give_map then
		return marked_places
	end
	local l = {}
	for vi in pairs(marked_places) do
		local x = (vi % 65536) - 32768
		local y = (math.floor(x / 65536) % 65536) - 32768
		l[#l+1] = {x, y}
	end
	return l
end

local fallings_search = dofile(path .. "/fill_3d.lua")
local moves_touch = {
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 0},  -- FIXME should this be here?
	{x = 1, y = 0, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 0, z = 1},
}
local moves_near = {}
for z = -1,1 do
	for y = -1,1 do
		for x = -1,1 do
			moves_near[#moves_near+1] = {x = x, y = y, z = z}
		end
	end
end

function funcs.search_3d(can_go, startpos, apply_move, moves)
	local visited = {}
	local found = {}
	local function on_visit(pos)
		local vi = minetest.hash_node_position(pos)
		if visited[vi] then
			return false
		end
		visited[vi] = true
		local valid_pos = can_go(pos)
		if valid_pos then
			found[#found+1] = pos
		end
		return valid_pos
	end
	if apply_move == "touch" then
		apply_move = vector.add
		moves = moves_touch
	elseif apply_move == "near" then
		apply_move = vector.add
		moves = moves_near
	end
	fallings_search(on_visit, startpos, apply_move, moves)
end


local explosion_tables = {}
function funcs.explosion_table(r)
	local table = explosion_tables[r]
	if table then
		return table
	end

	--~ local t1 = os.clock()
	local tab, n = {}, 1

	local tmp = r*r + r
	for x=-r,r do
		for y=-r,r do
			for z=-r,r do
				local rc = x*x+y*y+z*z
				if rc <= tmp then
					local np={x=x, y=y, z=z}
					if math.floor(math.sqrt(rc) +0.5) > r-1 then
						tab[n] = {np, true}
					else
						tab[n] = {np}
					end
					n = n+1
				end
			end
		end
	end
	explosion_tables[r] = tab
	--~ minetest.log("info", string.format("[vector_extras] table created after ca. %.2fs", os.clock() - t1))
	return tab
end

local default_nparams = {
   offset = 0,
   scale = 1,
   seed = 1337,
   octaves = 6,
   persist = 0.6
}
function funcs.explosion_perlin(rmin, rmax, nparams)
	local t1 = os.clock()

	local r = math.ceil(rmax)
	nparams = nparams or {}
	for i,v in pairs(default_nparams) do
		nparams[i] = nparams[i] or v
	end
	nparams.spread = nparams.spread or vector.from_number(r*5)

	local pos = {x=math.random(-30000, 30000), y=math.random(-30000, 30000), z=math.random(-30000, 30000)}
	local map = minetest.get_perlin_map(nparams, vector.from_number(r+r+1)
		):get3dMap_flat(pos)

	local id = 1

	local bare_maxdist = rmax*rmax
	local bare_mindist = rmin*rmin

	local mindist = math.sqrt(bare_mindist)
	local dist_diff = math.sqrt(bare_maxdist)-mindist
	mindist = mindist/dist_diff

	local pval_min, pval_max

	local tab, n = {}, 1
	for z=-r,r do
		local bare_dist_z = z*z
		for y=-r,r do
			local bare_dist_yz = bare_dist_z + y*y
			for x=-r,r do
				local bare_dist = bare_dist_yz + x*x
				local add = bare_dist < bare_mindist
				local pval, distdiv
				if not add
				and bare_dist <= bare_maxdist then
					distdiv = math.sqrt(bare_dist)/dist_diff-mindist
					pval = math.abs(map[id]) -- strange perlin values…
					if not pval_min then
						pval_min = pval
						pval_max = pval
					else
						pval_min = math.min(pval, pval_min)
						pval_max = math.max(pval, pval_max)
					end
					add = true--distdiv < 1-math.abs(map[id])
				end

				if add then
					tab[n] = {{x=x, y=y, z=z}, pval, distdiv}
					n = n+1
				end
				id = id+1
			end
		end
	end

	-- change strange values
	local pval_diff = pval_max - pval_min
	pval_min = pval_min/pval_diff

	for k,i in pairs(tab) do
		if i[2] then
			local new_pval = math.abs(i[2]/pval_diff - pval_min)
			if i[3]+0.33 < new_pval then
				tab[k] = {i[1]}
			elseif i[3] < new_pval then
				tab[k] = {i[1], true}
			else
				tab[k] = nil
			end
		end
	end

	minetest.log("info", string.format("[vector_extras] table created after ca. %.2fs", os.clock() - t1))
	return tab
end

local circle_tables = {}
function funcs.circle(r)
	local table = circle_tables[r]
	if table then
		return table
	end

	local t1 = os.clock()
	local tab, n = {}, 1

	for i = -r, r do
		for j = -r, r do
			if math.floor(math.sqrt(i*i+j*j)+0.5) == r then
				tab[n] = {x=i, y=0, z=j}
				n = n+1
			end
		end
	end
	circle_tables[r] = tab
	minetest.log("info", string.format("[vector_extras] table created after ca. %.2fs", os.clock() - t1))
	return tab
end

local ring_tables = {}
function funcs.ring(r)
	local table = ring_tables[r]
	if table then
		return table
	end

	local t1 = os.clock()
	local tab, n = {}, 1

	local tmp = r*r
	local p = {x=math.floor(r+0.5), z=0}
	while p.x > 0 do
		tab[n] = p
		n = n+1
		local p1, p2 = {x=p.x-1, z=p.z}, {x=p.x, z=p.z+1}
		local dif1 = math.abs(tmp-p1.x*p1.x-p1.z*p1.z)
		local dif2 = math.abs(tmp-p2.x*p2.x-p2.z*p2.z)
		if dif1 <= dif2 then
			p = p1
		else
			p = p2
		end
	end

	local tab2 = {}
	n = 1
	for _,i in ipairs(tab) do
		for _,j in ipairs({
			{i.x, i.z},
			{-i.z, i.x},
			{-i.x, -i.z},
			{i.z, -i.x},
		}) do
			tab2[n] = {x=j[1], y=0, z=j[2]}
			n = n+1
		end
	end
	ring_tables[r] = tab2
	minetest.log("info", string.format("[vector_extras] table created after ca. %.2fs", os.clock() - t1))
	return tab2
end

local function get_parabola_points(pos, vel, gravity, waypoints, max_pointcount,
		time)
	local pointcount = 0

	-- the height of the 45° angle point
	local yswitch = -0.5 * (vel.x^2 + vel.z^2 - vel.y^2)
		/ gravity + pos.y

	-- the times of the 45° angle point
	local vel_len = math.sqrt(vel.x^2 + vel.z^2)
	local t_raise_end = (-vel_len + vel.y) / gravity
	local t_fall_start = (vel_len + vel.y) / gravity
	if t_fall_start > 0 then
		-- the right 45° angle point wasn't passed yet
		if t_raise_end > 0 then
			-- put points from before the 45° angle
			for y = math.ceil(pos.y), math.floor(yswitch +.5) do
				local t = (vel.y -
					math.sqrt(vel.y^2 + 2 * gravity * (pos.y - y))) / gravity
				if t > time then
					return
				end
				local p = {
					x = math.floor(vel.x * t + pos.x +.5),
					y = y,
					z = math.floor(vel.z * t + pos.z +.5),
				}
				pointcount = pointcount+1
				waypoints[pointcount] = {p, t}
				if pointcount == max_pointcount then
					return
				end
			end
		end
		-- smaller and bigger horizonzal pivot
		local shp, bhp
		if math.abs(vel.x) > math.abs(vel.z) then
			shp = "z"
			bhp = "x"
		else
			shp = "x"
			bhp = "z"
		end
		-- put points between the 45° angles
		local cstart, cdir
		local cend = math.floor(vel[bhp] * t_fall_start + pos[bhp] +.5)
		if vel[bhp] > 0 then
			cstart = math.floor(math.max(pos[bhp],
				vel[bhp] * t_raise_end + pos[bhp]) +.5)
			cdir = 1
		else
			cstart = math.floor(math.min(pos[bhp],
				vel[bhp] * t_raise_end + pos[bhp]) +.5)
			cdir = -1
		end
		for i = cstart, cend, cdir do
			local t = (i - pos[bhp]) / vel[bhp]
			if t > time then
				return
			end
			local p = {
				[bhp] = i,
				y = math.floor(-0.5 * gravity * t * t + vel.y * t + pos.y +.5),
				[shp] = math.floor(vel[shp] * t + pos[shp] +.5),
			}
			pointcount = pointcount+1
			waypoints[pointcount] = {p, t}
			if pointcount == max_pointcount then
				return
			end
		end
	end
	-- put points from after the 45° angle
	local y = yswitch
	if vel.y < 0
	and pos.y < yswitch then
		y = pos.y
	end
	y = math.floor(y +.5)
	while pointcount < max_pointcount do
		local t = (vel.y +
			math.sqrt(vel.y^2 + 2 * gravity * (pos.y - y))) / gravity
		if t > time then
			return
		end
		local p = {
			x = math.floor(vel.x * t + pos.x +.5),
			y = y,
			z = math.floor(vel.z * t + pos.z +.5),
		}
		pointcount = pointcount+1
		waypoints[pointcount] = {p, t}
		y = y-1
	end
end
--[[
minetest.override_item("default:axe_wood", {
	on_use = function(_, player)
		local dir = player:get_look_dir()
		local pos = player:getpos()
		local grav = 0.03
		local ps = vector.throw_parabola(pos, dir, grav, 80)
		for i = 1,#ps do
			minetest.set_node(ps[i], {name="default:stone"})
		end
		--~ for t = 0,50,3 do
			--~ local p = {
				--~ x = dir.x * t + pos.x,
				--~ y = -0.5*grav*t*t + dir.y*t + pos.y,
				--~ z = dir.z * t + pos.z
			--~ }
			--~ minetest.set_node(p, {name="default:sandstone"})
		--~ end
	end,
})--]]

function funcs.throw_parabola(pos, vel, gravity, point_count, time)
	local waypoints = {}
	get_parabola_points(pos, vel, gravity, waypoints, point_count,
			time or math.huge)
	local ps = {}
	local ptscnt = #waypoints
	local i = 1
	while i < ptscnt do
		local p,t = unpack(waypoints[i])
		i = i+1
		local p2,t2 = unpack(waypoints[i])
		ps[#ps+1] = p
		local dist = vector.distance(p, p2)
		if dist < 1.1 then
			if dist < 0.9 then
				-- same position
				i = i+1
			end
			-- touching
		elseif dist < 1.7 then
			-- common edge
			-- get a list of possible positions between
			local diff = vector.subtract(p2, p)
			local possible_positions = {}
			for c,v in pairs(diff) do
				if v ~= 0 then
					local pos_moved = vector.new(p)
					pos_moved[c] = pos_moved[c] + v
					possible_positions[#possible_positions+1] = pos_moved
				end
			end
			-- test which one fits best
			t = 0.5 * (t + t2)
			local near_p = {
				x = vel.x * t + pos.x,
				y = -0.5 * gravity * t * t + vel.y * t + pos.y,
				z = vel.z * t + pos.z,
			}
			local d = math.huge
			for k = 1,2 do
				local pos_moved = possible_positions[k]
				local dist_current = vector.distance(pos_moved, near_p)
				if dist_current < d then
					p = pos_moved
					d = dist_current
				end
			end
			-- add it
			ps[#ps+1] = p
		elseif dist < 1.8 then
			-- common vertex
			for k = 1,2 do
				-- get a list of possible positions between
				local diff = vector.subtract(p2, p)
				local possible_positions = {}
				for c,v in pairs(diff) do
					if v ~= 0 then
						local pos_moved = vector.new(p)
						pos_moved[c] = pos_moved[c] + v
						possible_positions[#possible_positions+1] = pos_moved
					end
				end
				-- test which one fits best
				t = k / 3 * (t + t2)
				local near_p = {
					x = vel.x * t + pos.x,
					y = -0.5 * gravity * t * t + vel.y * t + pos.y,
					z = vel.z * t + pos.z,
				}
				local d = math.huge
				assert(#possible_positions == 4-k, "how, number positions?")
				for j = 1,4-k do
					local pos_moved = possible_positions[j]
					local dist_current = vector.distance(pos_moved, near_p)
					if dist_current < d then
						p = pos_moved
						d = dist_current
					end
				end
				-- add it
				ps[#ps+1] = p
			end
		else
			minetest.log("warning", "[vector_extras] A gap: " .. dist)
			--~ error("A gap, it's a gap!: " .. dist)
		end
	end
	if i == ptscnt then
		ps[#ps+1] = waypoints[i]
	end
	return ps
end

function funcs.chunkcorner(pos)
	return {x=pos.x-pos.x%16, y=pos.y-pos.y%16, z=pos.z-pos.z%16}
end

function funcs.point_distance_minmax(pos1, pos2)
	local p1 = vector.new(pos1)
	local p2 = vector.new(pos2)
	local min, max, vmin, vmax, num
	for _,i in ipairs({"x", "y", "z"}) do
		num = math.abs(p1[i] - p2[i])
		if not vmin or num < vmin then
			vmin = num
			min = i
		end
		if not vmax or num > vmax then
			vmax = num
			max = i
		end
	end
	return min, max
end

function funcs.collision(p1, p2)
	local clear, node_pos = minetest.line_of_sight(p1, p2)
	if clear then
		return false
	end
	local collision_pos = {}
	local _, max = funcs.point_distance_minmax(node_pos, p2)
	if node_pos[max] > p2[max] then
		collision_pos[max] = node_pos[max] - 0.5
	else
		collision_pos[max] = node_pos[max] + 0.5
	end
	local dmax = p2[max] - node_pos[max]
	local dcmax = p2[max] - collision_pos[max]
	local pt = dcmax / dmax

	for _,i in ipairs({"x", "y", "z"}) do
		collision_pos[i] = p2[i] - (p2[i] - node_pos[i]) * pt
	end
	return true, collision_pos, node_pos
end

function funcs.update_minp_maxp(minp, maxp, pos)
	for _,i in pairs({"z", "y", "x"}) do
		minp[i] = math.min(minp[i], pos[i])
		maxp[i] = math.max(maxp[i], pos[i])
	end
end

function funcs.quickadd(pos, z,y,x)
	if z then
		pos.z = pos.z+z
	end
	if y then
		pos.y = pos.y+y
	end
	if x then
		pos.x = pos.x+x
	end
end

function funcs.unpack(pos)
	return pos.z, pos.y, pos.x
end

function funcs.get_max_coord(vec)
	if vec.x < vec.y then
		if vec.y < vec.z then
			return "z"
		end
		return "y"
	end
	if vec.x < vec.z then
		return "z"
	end
	return "x"
end

function funcs.get_max_coords(pos)
	if pos.x < pos.y then
		if pos.y < pos.z then
			return "z", "y", "x"
		end
		if pos.x < pos.z then
			return "y", "z", "x"
		end
		return "y", "x", "z"
	end
	if pos.x < pos.z then
		return "z", "x", "y"
	end
	if pos.y < pos.z then
		return "x", "z", "y"
	end
	return "x", "y", "z"
end

function funcs.serialize(vec)
	return "{x=" .. vec.x .. ",y=" .. vec.y .. ",z=" .. vec.z .. "}"
end

function funcs.triangle(pos1, pos2, pos3)
	local normal = vector.cross(vector.subtract(pos2, pos1),
		vector.subtract(pos3, pos1))
	-- Find the biggest absolute component of the normal vector
	local dir = vector.get_max_coord({
		x = math.abs(normal.x),
		y = math.abs(normal.y),
		z = math.abs(normal.z),
	})
	-- Find the other directions for the for loops
	local all_other_dirs = {
		x = {"z", "y"},
		y = {"z", "x"},
		z = {"y", "x"},
	}
	local other_dirs = all_other_dirs[dir]
	local odir1, odir2 = other_dirs[1], other_dirs[2]

	local pos1_2d = {pos1[odir1], pos1[odir2]}
	local pos2_2d = {pos2[odir1], pos2[odir2]}
	local pos3_2d = {pos3[odir1], pos3[odir2]}
	-- The boundaries of the 2D AABB along other_dirs
	local p1 = {}
	local p2 = {}
	for i = 1,2 do
		p1[i] = math.floor(math.min(pos1_2d[i], pos2_2d[i], pos3_2d[i]))
		p2[i] = math.ceil(math.max(pos1_2d[i], pos2_2d[i], pos3_2d[i]))
	end

	-- https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage
	local function edgefunc(vert1, vert2, pos)
		return (pos[1] - vert1[1]) * (vert2[2] - vert1[2])
			- (pos[2] - vert1[2]) * (vert2[1] - vert1[1])
	end
	-- eps is used to prevend holes in neighbouring triangles
	-- It should be smaller than the smallest possible barycentric value
	-- FIXME: I'm not sure if it really does what it should.
	local eps = 0.5 / math.max(p2[1] - p1[1], p2[2] - p1[2])
	local a_all_inv = 1.0 / edgefunc(pos1_2d, pos2_2d, pos3_2d)
	local step_k3 = - (pos2_2d[1] - pos1_2d[1]) * a_all_inv
	local step_k1 = - (pos3_2d[1] - pos2_2d[1]) * a_all_inv
	-- Calculate the triangle points
	local points = {}
	local barycentric_coords = {}
	local n = 0
	-- It is possible to further optimize this
	for v1 = p1[1], p2[1] do
		local p = {v1, p1[2]}
		local k3 = edgefunc(pos1_2d, pos2_2d, p) * a_all_inv
		local k1 = edgefunc(pos2_2d, pos3_2d, p) * a_all_inv
		for _ = p1[2], p2[2] do
			local k2 = 1 - k1 - k3
			if k1 >= -eps and k2 >= -eps and k3 >= -eps then
				-- On triangle
				local h = math.floor(k1 * pos1[dir] + k2 * pos2[dir] +
					k3 * pos3[dir] + 0.5)
				n = n+1
				points[n] = {[odir1] = v1, [odir2] = p[2], [dir] = h}
				barycentric_coords[n] = {k1, k2, k3}
			end
			p[2] = p[2]+1
			k3 = k3 + step_k3
			k1 = k1 + step_k1
		end
	end
	return points, n, barycentric_coords
end


vector_extras_functions = funcs

dofile(path .. "/legacy.lua")
--dofile(minetest.get_modpath("vector_extras").."/vector_meta.lua")

vector_extras_functions = nil


for name,func in pairs(funcs) do
	if vector[name] then
		minetest.log("error", "[vector_extras] vector."..name..
			" already exists.")
	else
		vector[name] = func
	end
end
