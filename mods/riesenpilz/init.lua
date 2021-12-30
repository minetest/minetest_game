local load_time_start = os.clock()
local MAX_SIZE = 3

riesenpilz = {}
local modpath = minetest.get_modpath("riesenpilz").."/"
dofile(modpath.."settings.lua")
dofile(modpath.."functions.lua")


-- Growing Functions

local function r_area(manip, width, height, pos)
	local emerged_pos1, emerged_pos2 = manip:read_from_map(
		{x=pos.x-width, y=pos.y, z=pos.z-width},
		{x=pos.x+width, y=pos.y+height, z=pos.z+width}
	)
	return VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
end

-- contents become added later
local c

-- cache buildable_to ids
local re_al_cache = {[minetest.get_content_id("ignore")] = true}
local function replacing_allowed(id)
	if re_al_cache[id] ~= nil then
		return re_al_cache[id]
	end
	local def = minetest.registered_nodes[minetest.get_name_from_content_id(id)]
	if not def
	or def.buildable_to then
		re_al_cache[id] = true
		return true
	end
	re_al_cache[id] = false
	return false
end

local set_vm_nodes
if riesenpilz.giant_restrict_area then
	function set_vm_nodes(manip, pznodes)
		local nodes = manip:get_data()
		for vi,id in pairs(pznodes) do
			if not replacing_allowed(nodes[vi]) then
				return false
			end
			nodes[vi] = id
		end
		manip:set_data(nodes)
		return true
	end
else
	function set_vm_nodes(manip, pznodes)
		local nodes = manip:get_data()
		for vi,id in pairs(pznodes) do
			if replacing_allowed(nodes[vi]) then
				nodes[vi] = id
			end
		end
		manip:set_data(nodes)
		return true
	end
end

local function set_vm_data(manip, pznodes, pos, t1, name)
	if not set_vm_nodes(manip, pznodes) then
		return
	end
	manip:write_to_map()
	riesenpilz.inform("a giant " .. name .. " mushroom grew at " ..
		minetest.pos_to_string(pos), 3, t1)
	local t2 = os.clock()
	manip:update_map()
	riesenpilz.inform("map updated", 3, t2)
end


function riesenpilz.red(pos, nodes, area, w)
	w = w or math.random(MAX_SIZE)
	local h = w + 2

	for i = 0, h do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.stem
	end

	local br = w+1
	for k = -1, 1, 2 do
		for l = -br+1, br do
			nodes[area:index(pos.x+br*k, pos.y+h, pos.z-l*k)] = c.head_red
			nodes[area:index(pos.x+l*k, pos.y+h, pos.z+br*k)] = c.head_red
		end
	end

	for k = -w, w do
		for l = -w, w do
			nodes[area:index(pos.x+l, pos.y+h+1, pos.z+k)] = c.head_red
			nodes[area:index(pos.x+l, pos.y+h, pos.z+k)] = c.lamellas
		end
	end
end

local function riesenpilz_hybridpilz(pos)
	local t1 = os.clock()

	local w = math.random(MAX_SIZE)

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, w+1, w+3, pos)

	local pznodes = {}
	riesenpilz.red(pos, pznodes, area, w)

	set_vm_data(manip, pznodes, pos, t1, "red")
end


function riesenpilz.brown(pos, nodes, area, br)
	br = br or math.random(MAX_SIZE-1)+1
	local h = br + 2

	for i in area:iterp(pos, {x=pos.x, y=pos.y+h, z=pos.z}) do
		nodes[i] = c.stem
	end

	local w = br+1
	for l = -br, br do
		for k = -w, w, w*2 do
			nodes[area:index(pos.x+k, pos.y+h+1, pos.z+l)] = c.head_brown
			nodes[area:index(pos.x+l, pos.y+h+1, pos.z+k)] = c.head_brown
		end
		for k = -br, br do
			nodes[area:index(pos.x+l, pos.y+h+1, pos.z+k)] = c.head_brown
		end
	end
end

local function riesenpilz_brauner_minecraftpilz(pos)
	local t1 = os.clock()

	local br = math.random(MAX_SIZE-1)+1

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, br+1, br+3, pos)

	local pznodes = {}
	riesenpilz.brown(pos, pznodes, area, br)

	set_vm_data(manip, pznodes, pos, t1, "brown")
end


function riesenpilz.fly_agaric(pos, nodes, area, param2s)
	local h = 3

	for i = 0, h do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.stem
	end

	for j = -1, 1 do
		for k = -1, 1 do
			nodes[area:index(pos.x+j, pos.y+h+1, pos.z+k)] = c.head_red
		end
		for l = 1, h do
			local y = pos.y+l
			for _,p in pairs({
				{area:index(pos.x+j, y, pos.z+2), 0},
				{area:index(pos.x+j, y, pos.z-2), 2},
				{area:index(pos.x+2, y, pos.z+j), 1},
				{area:index(pos.x-2, y, pos.z+j), 3},
			}) do
				local tmp = p[1]
				nodes[tmp] = c.head_red_side
				param2s[tmp] = p[2]
			end
		end
	end
end

local function riesenpilz_minecraft_fliegenpilz(pos)
	local t1 = os.clock()

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 2, 4, pos)
	local param2s = manip:get_param2_data()

	local pznodes = {}
	riesenpilz.fly_agaric(pos, pznodes, area, param2s)

	if not set_vm_nodes(manip, pznodes) then
		return
	end
	manip:set_param2_data(param2s)
	manip:write_to_map()
	manip:update_map()
	riesenpilz.inform("a fly agaric grew at " .. minetest.pos_to_string(pos),
		3, t1)
end


local function ran_node(a, b, ran)
	if math.random(ran) == 1 then
		return a
	end
	return b
end

function riesenpilz.lavashroom(pos, nodes, area, h)
	h = h or 3 + math.random(MAX_SIZE - 2)

	-- remove the mushroom
	nodes[area:indexp(pos)] = c.air

	for i = -1, 1, 2 do
		-- set the stem
		for n = 0, h do
			nodes[area:index(pos.x+i, pos.y+n, pos.z)] = c.stem_brown
			nodes[area:index(pos.x, pos.y+n, pos.z+i)] = c.stem_brown
		end

		local o = 2*i
		for l = -1, 1 do
			for k = 2, 3 do
				nodes[area:index(pos.x+k*i, pos.y+h+2, pos.z+l)] = c.head_brown_full
				nodes[area:index(pos.x+l, pos.y+h+2, pos.z+k*i)] = c.head_brown_full
			end
			nodes[area:index(pos.x+l, pos.y+h+1, pos.z+o)] = c.head_brown_full
			nodes[area:index(pos.x+o, pos.y+h+1, pos.z+l)] = c.head_brown_full
		end

		for m = -1, 1, 2 do
			for k = 2, 3 do
				for j = 2, 3 do
					nodes[area:index(pos.x+j*i, pos.y+h+2, pos.z+k*m)] = ran_node(c.head_yellow, c.head_orange, 7)
				end
			end
			nodes[area:index(pos.x+i, pos.y+h+1, pos.z+m)] = c.head_brown_full
			nodes[area:index(pos.x+m*2, pos.y+h+1, pos.z+o)] = c.head_brown_full
		end

		for l = -3+1, 3 do
			nodes[area:index(pos.x+3*i, pos.y+h+5, pos.z-l*i)] = ran_node(c.head_yellow, c.head_orange, 5)
			nodes[area:index(pos.x+l*i, pos.y+h+5, pos.z+3*i)] = ran_node(c.head_yellow, c.head_orange, 5)
		end

		for j = 0, 1 do
			for l = -3, 3 do
				nodes[area:index(pos.x+i*4, pos.y+h+3+j, pos.z+l)] = ran_node(c.head_yellow, c.head_orange, 6)
				nodes[area:index(pos.x+l, pos.y+h+3+j, pos.z+i*4)] = ran_node(c.head_yellow, c.head_orange, 6)
			end
		end

	end

	for k = -2, 2 do
		for l = -2, 2 do
			nodes[area:index(pos.x+k, pos.y+h+6, pos.z+l)] = ran_node(c.head_yellow, c.head_orange, 4)
		end
	end
end

local function riesenpilz_lavashroom(pos)
	local t1 = os.clock()

	local h = 3+math.random(MAX_SIZE-2)

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 4, h+6, pos)

	local pznodes = {}
	riesenpilz.lavashroom(pos, pznodes, area, h)

	set_vm_data(manip, pznodes, pos, t1, "lavashroom")
end


function riesenpilz.glowshroom(pos, nodes, area, h)
	h = h or 2 + math.random(MAX_SIZE)

	for i = 0, h do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.stem_blue
	end

	local br = 2
	for i = -1, 1, 2 do

		for k = -br, br, 2*br do
			for l = 2, h do
				nodes[area:index(pos.x+i*br, pos.y+l, pos.z+k)] = c.head_blue
			end
			nodes[area:index(pos.x+i*br, pos.y+1, pos.z+k)] = c.head_blue_bright
		end

		for l = -br+1, br do
			nodes[area:index(pos.x+i*br, pos.y+h, pos.z-l*i)] = c.head_blue
			nodes[area:index(pos.x+l*i, pos.y+h, pos.z+br*i)] = c.head_blue
		end

	end

	for l = 0, br do
		for i = -br+l, br-l do
			for k = -br+l, br-l do
				nodes[area:index(pos.x+i, pos.y+h+1+l, pos.z+k)] = c.head_blue
			end
		end
	end

end

local function riesenpilz_glowshroom(pos)
	local t1 = os.clock()

	local h = 2+math.random(MAX_SIZE)

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 2, h+3, pos)

	local pznodes = {}
	riesenpilz.glowshroom(pos, pznodes, area, h)

	set_vm_data(manip, pznodes, pos, t1, "glowshroom")
end


function riesenpilz.parasol(pos, nodes, area, w, h)
	h = h or 6 + math.random(MAX_SIZE)

	--stem
	for i in area:iterp(pos, {x=pos.x, y=pos.y+h-2, z=pos.z}) do
		nodes[i] = c.stem
	end

	w = w or MAX_SIZE + math.random(2)
	local bhead1 = w-1
	local bhead2 = math.random(1,w-2)

	for _,j in pairs({
		{bhead2, 0, c.head_brown_bright},
		{bhead1, -1, c.head_beige}
	}) do
		for i in area:iter(pos.x-j[1], pos.y+h+j[2], pos.z-j[1], pos.x+j[1], pos.y+h+j[2], pos.z+j[1]) do
			nodes[i] = j[3]
		end
	end

	local rh = math.random(2,3)
	for k = -1, 1, 2 do
		for l = 0, 1 do
			nodes[area:index(pos.x+k, pos.y+rh, pos.z-l*k)] = c.head_white
			nodes[area:index(pos.x+l*k, pos.y+rh, pos.z+k)] = c.head_white
		end
		for l = -w+1, w do
			nodes[area:index(pos.x+w*k, pos.y+h-2, pos.z-l*k)] = c.head_beige
			nodes[area:index(pos.x+l*k, pos.y+h-2, pos.z+w*k)] = c.head_beige
		end
		for l = -bhead1+1, bhead1 do
			nodes[area:index(pos.x+bhead1*k, pos.y+h-2, pos.z-l*k)] = c.head_white
			nodes[area:index(pos.x+l*k, pos.y+h-2, pos.z+bhead1*k)] = c.head_white
		end
	end
end

local function riesenpilz_parasol(pos)
	local t1 = os.clock()

	local w = MAX_SIZE+math.random(2)
	local h = 6+math.random(MAX_SIZE)

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, w, h, pos)

	local pznodes = {}
	riesenpilz.parasol(pos, pznodes, area, w, h)

	set_vm_data(manip, pznodes, pos, t1, "parasol")
end


function riesenpilz.red45(pos, nodes, area, h1, h2)
	local walkspace = h1 or math.random(2,MAX_SIZE)
	local toph = h2 or math.random(MAX_SIZE)
	local h = walkspace+toph+4

	-- stem
	for i in area:iterp(pos, {x=pos.x, y=pos.y+h, z=pos.z}) do
		nodes[i] = c.stem_red
	end

	for i = -1,1,2 do
		for l = 0, 1 do
			if math.random(2) == 1 then
				nodes[area:index(pos.x+i, pos.y, pos.z-l*i)] = c.stem_red
				if math.random(2) == 1 then
					nodes[area:index(pos.x+i, pos.y+1, pos.z-l*i)] = c.stem_red
				end
			end
			if math.random(2) == 1 then
				nodes[area:index(pos.x+l*i, pos.y, pos.z+i)] = c.stem_red
				if math.random(2) == 1 then
					nodes[area:index(pos.x+l*i, pos.y+1, pos.z+i)] = c.stem_red
				end
			end
			nodes[area:index(pos.x+i, pos.y+walkspace+2, pos.z-l*i)] = c.head_red
			nodes[area:index(pos.x+l*i, pos.y+walkspace+2, pos.z+i)] = c.head_red
		end
		nodes[area:index(pos.x, pos.y+walkspace+3, pos.z+i)] = c.head_red
		nodes[area:index(pos.x+i, pos.y+walkspace+3, pos.z)] = c.head_red
		for j = -1,1,2 do
			nodes[area:index(pos.x+j, pos.y+walkspace+1, pos.z+i)] = c.head_red
			nodes[area:index(pos.x+j*3, pos.y+walkspace+1, pos.z+i*3)] = c.head_red
			for z = 1,2 do
				for x = 1,2 do
					for y = h-toph, h-1 do
						nodes[area:index(pos.x+x*j, pos.y+y, pos.z+z*i)] = c.head_red
					end
					if z ~= 2
					or x ~= 2
					or math.random(4) ~= 2 then
						nodes[area:index(pos.x+x*j, pos.y+h, pos.z+z*i)] = c.head_red
					end
					local zo = z+1
					local xo = x+1
					nodes[area:index(pos.x + xo * j, pos.y + walkspace + 2,
						pos.z + zo * i)] = c.head_red
					if zo ~= 3
					or xo ~= 3
					or math.random(2) == 1 then
						nodes[area:index(pos.x + xo * j, pos.y + walkspace + 3,
							pos.z + zo * i)] = c.head_red
					end
				end
			end
		end
	end

	-- top
	for z = -1,1 do
		for x = -1,1 do
			nodes[area:index(pos.x+x, pos.y+h+1, pos.z+z)] = c.head_red
		end
	end
end

local function riesenpilz_red45(pos)
	local t1 = os.clock()

	local h1 = math.random(2,MAX_SIZE)
	local h2 = math.random(MAX_SIZE)
	local h = h1+h2+5

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 3, h, pos)

	local pznodes = {}
	riesenpilz.red45(pos, pznodes, area, h1, h2)

	set_vm_data(manip, pznodes, pos, t1, "red45")
end


function riesenpilz.apple(pos, nodes, area)
	local size = 5
	local a = size*2
	local b = size-1

	for l = -b, b do
		for j = 1, a-1 do
			for k = -size, size, a do
				nodes[area:index(pos.x+k, pos.y+j, pos.z+l)] = c.red
				nodes[area:index(pos.x+l, pos.y+j, pos.z+k)] = c.red
			end
		end
		for i = -b, b do
			nodes[area:index(pos.x+i, pos.y, pos.z+l)] = c.red
			nodes[area:index(pos.x+i, pos.y+a, pos.z+l)] = c.red
		end
	end

	for i = a+1, a+b do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.tree
	end

	local d = pos.y+1
	for i = -3,1,1 do
		nodes[area:index(pos.x+i, d, pos.z+1)] = c.brown
	end
	for i = 0,1,1 do
		nodes[area:index(pos.x+i+1, d, pos.z-1-i)] = c.brown
		nodes[area:index(pos.x+i+2, d, pos.z-1-i)] = c.brown
	end
	nodes[area:index(pos.x+1, d, pos.z)] = c.brown
	nodes[area:index(pos.x-3, d+1, pos.z+1)] = c.brown
end

local function riesenpilz_apple(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 5, 14, pos)

	local pznodes = {}
	riesenpilz.apple(pos, pznodes, area)

	if not set_vm_nodes(manip, pznodes) then
		return
	end
	manip:write_to_map()
	riesenpilz.inform("an apple grew at " .. minetest.pos_to_string(pos), 3, t1)
	manip:update_map()
end



-- 3D apple [3apple]


if riesenpilz.change_apple then
	minetest.override_item("default:apple", {
		drawtype = "nodebox",
		tiles = {"3apple_apple_top.png", "3apple_apple_bottom.png", "3apple_apple.png"},
		node_box = {
			type = "fixed",
			fixed = {
				{-3/16,	-7/16,	-3/16,	3/16,	1/16,	3/16},
				{-4/16,	-6/16,	-3/16,	4/16,	0,		3/16},
				{-3/16,	-6/16,	-4/16,	3/16,	0,		4/16},
				{-1/32,	1/16,	-1/32,	1/32,	4/16,	1/32},
				{-1/16,	1.6/16,	0,		1/16,	1.8/16,	1/16},
				{-2/16,	1.4/16,	1/16,	1/16,	1.6/16,	2/16},
				{-2/16,	1.2/16,	2/16,	0,		1.4/16,	3/16},
				{-1.5/16,	1/16,	.5/16,	0.5/16,		1.2/16,	2.5/16},
			}
		},
	})
end



-- Mushroom Nodes


local abm_allowed = true
local disallowed_ps = {}

for name, ndata in pairs({
	brown = {
		description = "brown mushroom",
		box = {
			{-0.15, -0.2, -0.15, 0.15, -0.1, 0.15},
			{-0.2, -0.3, -0.2, 0.2, -0.2, 0.2},
			{-0.05, -0.5, -0.05, 0.05, -0.3, 0.05}
		},
		growing = {
			r = {min=3, max=4},
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:tree"},
			light = {min=1, max=7},
			interval = 100,
			chance = 18,
		},
		hp = 2,
	},
	red = {
		description = "red mushroom",
		box = {
			{-1/16, -8/16, -1/16, 1/16, -6/16, 1/16},
			{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16},
			{-4/16, -5/16, -4/16, 4/16, -4/16, 4/16},
			{-3/16, -4/16, -3/16, 3/16, -3/16, 3/16},
			{-2/16, -3/16, -2/16, 2/16, -2/16, 2/16}
		},
		growing = {
			r = {min=4, max=5},
			grounds = {soil=2},
			neighbours = {"default:water_flowing"},
			light = {min=4, max=13},
			interval = 50,
			chance = 30,
		},
		hp = -2,
	},
	fly_agaric = {
		description = "fly agaric",
		box = {
			{-0.05, -0.5, -0.05, 0.05, 1/20, 0.05},
			{-3/20, -6/20, -3/20, 3/20, 0, 3/20},
			{-4/20, -2/20, -4/20, 4/20, -4/20, 4/20}
		},
		growing = {
			r = 4,
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:pinetree"},
			light = {min=2, max=10},
			interval = 101,
			chance = 30,
		},
		hp = -6,
	},
	lavashroom = {
		description = "Lavashroom",
		box = {
			{-1/16, -8/16, -1/16, 1/16, -6/16, 1/16},
			{-2/16, -6/16, -2/16, 2/16,     0, 2/16},
			{-3/16, -5/16, -3/16, 3/16, -1/16, 3/16},
			{-4/16, -4/16, -4/16, 4/16, -2/16, 4/16}
		},
		growing = {
			r = {min=5, max=6},
			grounds = {cracky=3},
			neighbours = {"default:lava_source"},
			light = {min=10, max=12},
			interval = 1010,
			chance = 60,
		},
		hp = -1,
	},
	glowshroom = {
		description = "Glowshroom",
		box = {
			{-1/16, -8/16, -1/16,  1/16, -1/16, 1/16},
			{-2/16, -3/16, -2/16,  2/16, -2/16, 2/16},
			{-3/16, -5/16, -3/16,  3/16, -3/16, 3/16},
			{-3/16, -7/16, -3/16, -2/16, -5/16, -2/16},
			{3/16,  -7/16, -3/16,  2/16, -5/16, -2/16},
			{-3/16, -7/16,  3/16, -2/16, -5/16, 2/16},
			{3/16,  -7/16,  3/16,  2/16, -5/16, 2/16}
		},
		growing = {
			r = 3,
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:stone"},
			light = 0,
			interval = 710,
			chance = 320,
		},
		hp = -2,
	},
	nether_shroom = {
		description = "Nether mushroom",
		box = {
			{-1/16, -8/16, -1/16, 1/16, -2/16, 1/16},
			{-2/16, -6/16, -2/16, 2/16, -5/16, 2/16},
			{-3/16, -2/16, -3/16, 3/16,     0, 3/16},
			{-4/16, -1/16, -4/16, 4/16,  1/16,-2/16},
			{-4/16, -1/16,  2/16, 4/16,  1/16, 4/16},
			{-4/16, -1/16, -2/16,-2/16,  1/16, 2/16},
			{ 2/16, -1/16, -2/16, 4/16,  1/16, 2/16}
		},
		burntime = 6,
		hp = -3,
	},
	parasol = {
		description = "white parasol mushroom",
		box = {
			{-1/16, -8/16, -1/16, 1/16,  0, 1/16},
			{-2/16, -6/16, -2/16, 2/16, -5/16, 2/16},
			{-5/16, -4/16, -5/16, 5/16, -3/16, 5/16},
			{-4/16, -3/16, -4/16, 4/16, -2/16, 4/16},
			{-3/16, -2/16, -3/16, 3/16, -1/16, 3/16}
		},
		growing = {
			r = {min=3, max=5},
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:pinetree"},
			light = {min=1, max=11},
			interval = 51,
			chance = 36,
		},
		hp = 3,
	},
	red45 = {
		description = "45 red mushroom",
		box = {
			{-1/16, -0.5, -1/16,  1/16, 1/8, 1/16},
			{-3/16,  1/8, -3/16,  3/16, 1/4, 3/16},
			{-5/16, -1/4, -5/16, -1/16, 1/8, -1/16},
			{1/16,  -1/4, -5/16,  5/16, 1/8, -1/16},
			{-5/16, -1/4,  1/16, -1/16, 1/8, 5/16},
			{1/16,  -1/4,  1/16,  5/16, 1/8, 5/16}
		},
		growing = {
			r = {min=3, max=4},
			grounds = {soil=2},
			neighbours = {"default:water_source"},
			light = {min=2, max=7},
			interval = 1000,
			chance = 180,
		},
		hp = 1,
	},
	brown45 = {
		description = "45 brown mushroom",
		box = {
			{-1/16, -0.5, -1/16, 1/16, 1/16, 1/16},
			{-3/8,   1/8, -7/16,  3/8,  1/4, 7/16},
			{-7/16,  1/8,  -3/8, 7/16,  1/4, 3/8},
			{-3/8,   1/4,  -3/8,  3/8, 5/16, 3/8},
			{-3/8,  1/16,  -3/8,  3/8,  1/8, 3/8}
		},
		growing = {
			r = {min=2, max=3},
			grounds = {tree=1},
			neighbours = {"default:water_flowing"},
			light = {min=7, max=11},
			interval = 100,
			chance = 20,
		},
		hp = 1,
	},
}) do
	local burntime = ndata.burntime or 1
	local box = {
		type = "fixed",
		fixed = ndata.box
	}
	local nd = "riesenpilz:" .. name
	minetest.register_node(nd, {
		description = ndata.description,
		tiles = {
			--~ {name = "riesenpilz_"..name.."_top.png", tileable_vertical = false},
			--~ {name = "riesenpilz_"..name.."_bottom.png", tileable_vertical = false},
			--~ {name = "riesenpilz_"..name.."_side.png", tileable_vertical = false},
			"riesenpilz_" .. name .. "_top.png",
			"riesenpilz_" .. name .. "_bottom.png",
			"riesenpilz_" .. name .. "_side.png",
		},
		use_texture_alpha = "opaque",
		inventory_image = "riesenpilz_"..name.."_side.png",
		walkable = false,
		buildable_to = true,
		drawtype = "nodebox",
		paramtype = "light",
		groups = {snappy=3,flammable=2,attached_node=1},
		sounds =  default.node_sound_leaves_defaults(),
		node_box = box,
		selection_box = box,
		furnace_burntime = burntime,
		on_secondary_use = minetest.item_eat(ndata.hp),
	})

	local g = ndata.growing

	if g then
		local grounds = g.grounds
		local nds = {}
		for n in pairs(grounds) do
			table.insert(nds, "group:"..n)
		end

		local nbs = table.copy(g.neighbours)
		table.insert(nbs, "air")

		local rmin, rmax, lmin, lmax

		local r = g.r
		if type(r) == "table" then
			rmin = r.min
			rmax = r.max
		else
			rmin = r or 3
			rmax = rmin
		end

		local l = g.light
		if type(l) == "table" then
			lmin = l.min
			lmax = l.max
		else
			lmin = l or 3
			lmax = lmin
		end

		minetest.register_abm({
			nodenames = nds,
			neighbors = g.neighbours,
			interval = g.interval,
			chance = g.chance,
			catch_up = false,
			action = function(pos, node)
				if not abm_allowed then
					return
				end

			-- don't try to spawn them on the same positions again
				for _,p in pairs(disallowed_ps) do
					if vector.equals(p, pos) then
						return
					end
				end

			-- don't spawn mushroom circles next to other ones
				if minetest.find_node_near(pos, rmax, nd) then
					return
				end

			-- spawn them around the right nodes
				local data = minetest.registered_nodes[node.name]
				if not data
				or not data.groups then
					return
				end
				local groups = data.groups
				for groupname, groupvalue in pairs(grounds) do
					if groups[groupname] ~= groupvalue then
						return
					end
				end

			-- find their neighbours
				for _,n in pairs(nbs) do
					if not minetest.find_node_near(pos, rmin, n) then
						return
					end
				end

			-- should disallow lag
				abm_allowed = false
				minetest.after(2, function() abm_allowed = true end)
				disallowed_ps[#disallowed_ps+1] = pos

			-- witch circles
				local ps = {}
				for _,p in pairs(riesenpilz.circle(math.random(rmin, rmax))) do
					p = vector.add(pos, p)

				-- currently 3 is used here, approved by its use in the mapgen
					if math.random(3) == 1 then

					-- don't only use the current y for them
						for y = 1,-1,-1 do
							local pos_above = {x=p.x, y=p.y+y, z=p.z}
							if minetest.get_node(pos_above).name ~= "air" then
								break
							end
							local f = minetest.get_node({x=p.x, y=p.y+y-1, z=p.z}).name
							if f ~= "air" then

							-- they grown on specific nodes
								local data_ground = minetest.registered_nodes[f]
								if data_ground
								and data_ground.walkable
								and data_ground.groups
								and (not data_ground.drawtype
									or data_ground.drawtype == "normal"
								) then
									local ground_disallowed
									for n,i in pairs(grounds) do
										if data_ground.groups[n] ~= i then
											ground_disallowed = true
											break
										end
									end
									if not ground_disallowed then

									-- they also need specific light strengths
										local light = minetest.get_node_light(
											pos_above, 0.5)
										if light >= lmin
										and light <= lmax then
											ps[#ps+1] = pos_above
										end
									end
								end
								break
							end
						end
					end
				end
				if not ps[1] then
					return
				end

			-- place them
				for _,p in pairs(ps) do
					minetest.set_node(p, {name=nd})
				end
				minetest.log("info", "[riesenpilz] "..nd.." mushrooms grew at "..minetest.pos_to_string(pos))
			end
		})
	end
end

-- disallow abms when the server is lagging
minetest.register_globalstep(function(dtime)
	if dtime > 0.5
	and abm_allowed then
		abm_allowed = false
		minetest.after(2, function() abm_allowed = true end)
		--minetest.chat_send_all(dtime)
	end
end)



-- Big Mushroom Nodes


local head_sounds = default.node_sound_wood_defaults({
	footstep = {name="riesenpilz_head", gain=0.1},
	place = {name="default_place_node", gain=0.5},
	dig = {name="riesenpilz_head", gain=0.2},
	dug = {name="riesenpilz_stem", gain=0.1}
})
local add_fence = minetest.register_fence
local node_groups = {oddly_breakable_by_hand=3, fall_damage_add_percent=-80, bouncy=10}

for _, ndata in ipairs({
	{
		typ = "stem",
		description = "white",
		textures = {"stem_top.png", "stem_top.png", "stem_white.png"},
	},
	{
		typ = "stem",
		name = "brown",
		textures = {"stem_top.png", "stem_top.png", "stem_brown.png"},
		fence = false,
	},
	{
		typ = "stem",
		name = "blue",
		textures = {"stem_top.png","stem_top.png","stem_blue.png"},
		fence = false,
	},
	{
		typ = "stem",
		name = "red",
		textures = {"stem_red45_top.png","stem_red45_top.png","stem_red45.png"},
	},
	{
		name = "lamellas",
		description = "giant mushroom lamella",
		textures = "lamellas.png",
		sapling = "lamellas"
	},
	{
		typ = "head",
		name = "red",
		textures = {"head.png", "lamellas.png", "head.png"},
		sapling = "red"
	},
	{
		typ = "head",
		name = "orange",
		textures = "head_orange.png",
		sapling = "lavashroom"
	},
	{
		typ = "head",
		name = "yellow",
		textures = "head_yellow.png",
		sapling = "lavashroom"
	},
	{
		typ = "head",
		name = "brown",
		textures = {"brown_top.png", "lamellas.png", "brown_top.png"},
		sapling = "brown",
	},
	{
		typ = "head",
		name = "brown_full",
		description = "full brown",
		textures = "brown_top.png",
		sapling = "brown",
		fence = false,
	},
	{
		typ = "head",
		name = "blue_bright",
		description = "blue bright",
		textures = "head_blue_bright.png",
		sapling = "glowshroom"
	},
	{
		typ = "head",
		name = "blue",
		textures = "head_blue.png",
		sapling = "glowshroom"
	},
	{
		typ = "head",
		name = "white",
		textures = "head_white.png",
		sapling = "parasol"
	},
	{
		typ = "head",
		name = "beige",
		textures = {"head_beige.png", "head_white.png", "head_beige.png"},
		sapling = "parasol"
	},
	{
		typ = "head",
		name = "brown_bright",
		description = "brown bright",
		textures = {"head_brown_bright.png", "head_white.png", "head_brown_bright.png"},
		sapling = "parasol"
	},
}) do
	-- fill missing stuff
	local textures = ndata.textures
	ndata.description = ndata.description or ndata.name
	if type(textures) == "string" then
		textures = {textures}
	end
	for i = 1,#textures do
		textures[i] = "riesenpilz_"..textures[i]
	end
	local nodename = "riesenpilz:"
	local desctiption,sounds = "giant mushroom "
	if ndata.typ == "stem" then
		desctiption = desctiption .. "stem " .. ndata.description
		nodename = nodename .. "stem" ..
			((ndata.name and "_" .. ndata.name) or "")
		sounds = default.node_sound_wood_defaults({
			footstep = {name="riesenpilz_stem", gain=0.2},
			place = {name="default_place_node", gain=0.5},
			dig = {name="riesenpilz_stem", gain=0.4},
			dug = {name="default_wood_footstep", gain=0.3}
		})
	elseif ndata.typ == "head" then
		desctiption = desctiption .. "head " .. ndata.description
		nodename = nodename .. "head_" .. ndata.name
		sounds = head_sounds
	else
		nodename = nodename .. ndata.name
		desctiption = desctiption .. ndata.description
	end
	local drop = ndata.sapling and {max_items = 1, items = {
		{items = {"riesenpilz:" .. ndata.sapling}, rarity = 20},
		{items = {nodename}, rarity = 1}
	}}
	minetest.register_node(nodename, {
		description = desctiption,
		tiles = textures,
		groups = node_groups,
		drop = drop,
		sounds = sounds,
	})

	if add_fence
	and ndata.fence ~= false then
		add_fence({fence_of = nodename})
	end
end

minetest.register_node("riesenpilz:head_red_side", {
	description = "giant mushroom head red side",
	tiles = {"riesenpilz_head.png",	"riesenpilz_lamellas.png",	"riesenpilz_head.png",
					"riesenpilz_head.png",	"riesenpilz_head.png",	"riesenpilz_lamellas.png"},
	paramtype2 = "facedir",
	groups = node_groups,
	drop = {max_items = 1,
		items = {{items = {"riesenpilz:fly_agaric"},rarity = 20,},
		{items = {"riesenpilz:head_red"},rarity = 1,}}},
	sounds = head_sounds
})



minetest.register_node("riesenpilz:ground", {
	description = "dirt with rotten grass",
	tiles = {"riesenpilz_ground_top.png","default_dirt.png",
		{name="default_dirt.png^riesenpilz_ground_side.png", tileable_vertical = false}
	},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
	drop = 'default:dirt'
})


c = {
	air = minetest.get_content_id("air"),

	stem = minetest.get_content_id("riesenpilz:stem"),
	head_red = minetest.get_content_id("riesenpilz:head_red"),
	lamellas = minetest.get_content_id("riesenpilz:lamellas"),

	head_brown = minetest.get_content_id("riesenpilz:head_brown"),

	head_red_side = minetest.get_content_id("riesenpilz:head_red_side"),

	stem_brown = minetest.get_content_id("riesenpilz:stem_brown"),
	head_brown_full = minetest.get_content_id("riesenpilz:head_brown_full"),
	head_orange = minetest.get_content_id("riesenpilz:head_orange"),
	head_yellow = minetest.get_content_id("riesenpilz:head_yellow"),

	stem_blue = minetest.get_content_id("riesenpilz:stem_blue"),
	head_blue = minetest.get_content_id("riesenpilz:head_blue"),
	head_blue_bright = minetest.get_content_id("riesenpilz:head_blue_bright"),

	head_white = minetest.get_content_id("riesenpilz:head_white"),
	head_beige = minetest.get_content_id("riesenpilz:head_beige"),
	head_brown_bright = minetest.get_content_id("riesenpilz:head_brown_bright"),

	stem_red = minetest.get_content_id("riesenpilz:stem_red"),

	red = minetest.get_content_id("default:copperblock"),
	brown = minetest.get_content_id("default:desert_stone"),
	tree = minetest.get_content_id("default:tree"),
}



-- Growing


minetest.register_tool("riesenpilz:growingtool", {
	description = "growingtool",
	inventory_image = "riesenpilz_growingtool.png",
})

local grow_functions = {
	["riesenpilz:red"] = riesenpilz_hybridpilz,
	["riesenpilz:fly_agaric"] = riesenpilz_minecraft_fliegenpilz,
	["riesenpilz:brown"] = riesenpilz_brauner_minecraftpilz,
	["riesenpilz:lavashroom"] = riesenpilz_lavashroom,
	["riesenpilz:glowshroom"] = riesenpilz_glowshroom,
	["riesenpilz:parasol"] = riesenpilz_parasol,
	["riesenpilz:red45"] = riesenpilz_red45,
	["default:apple"] = riesenpilz_apple
}
local function get_grow(name)
	if grow_functions[name] then
		return grow_functions[name]
	end

	local is = {}
	for i = 1,#minetest.registered_abms do
		local ad = minetest.registered_abms[i]
		if type(ad.nodenames) ~= "table" then
			minetest.log("warning", "ABM nodenames is not a table: " ..
				dump(ad))
			return
		end
		if ad.chance > 1
		and table.indexof(ad.nodenames, name) ~= -1 then
			is[#is+1] = ad.action
		end
	end

	local func
	if is[1] then
		function func(pos, node)
			for i = 1,#is do
				is[i](pos, node)
			end
		end
	else
		local def = minetest.registered_nodes[name]
		if def then
			if def.on_timer then
				func = def.on_timer
			else
				func = function(pos, _, player)
					if def.on_place then
						def.on_place(ItemStack(name), player, {
							type = "node",
							under = vector.new(pos),--{x=pos.x, y=pos.y-1, z=pos.z},
							above = vector.new(pos)
						})
					end
					if def.after_place_node then
						def.after_place_node(pos)
					end
				end
			end
		else
			func = function() end
		end
	end

	grow_functions[name] = func
	return func
end

minetest.register_on_punchnode(function(pos, node, player)
	if player:get_wielded_item():get_name() ~= "riesenpilz:growingtool"
	or minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local func = get_grow(node.name)
	if func then
		func(pos, node, player)
	end
end)



-- Uses


-- mush45's meal
minetest.register_craftitem("riesenpilz:mush45_meal", {
	description = "Mushroom Meal",
	inventory_image = "riesenpilz_mush45_meal.png",
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	output = "riesenpilz:mush45_meal 4",
	recipe = {
		{"riesenpilz:brown45", "riesenpilz:red45"},
		{"riesenpilz:red45", "riesenpilz:brown45"},
	}
})


--[[ unfinished
if minetest.global_exists(technic) then
	if minetest.global_exists(digilines) then
		-- digiline light value detector
		minetest.register_node("riesenpilz:light_detector" {
			tiles = {"riesenpilz_light_detector.png"},
			paramtype = "light",
			digiline = {
				receive = function(pos)
					local light = minetest.get_node_light(pos)
					send("light_detector", light)
				end,
			},
			--sounds = ,
		})

		--technic.comp({"riesenpilz:glowshroom 10", "coal"}, "riesenpilz:light_detector")
	end


	--[ [
	if minetest.global_exists(3darmor) then add to depends
		--lavashroom skin armor, swimming in lava possible

		minetest.register_craftitem("riesenpilz:lavashroom_flesh", {
			description = "lavashroom's flesh",
			inventory_image = "riesenpilz_lavashroom_flesh.png",
			on_use = minetest.item_eat(3),
		})

		minetest.register_craftitem("riesenpilz:lavashroom_skin", {
			description = "lavashroom's skin",
			inventory_image = "riesenpilz_lavashroom_skin.png",
		})

		minetest.register_craftitem("riesenpilz:antilava_plate", {
			description = "lava protecting plate",
			inventory_image = "riesenpilz_antilava_plate.png",
		})

		technic.centri("riesenpilz:lavashroom", {"riesenpilz:lavashroom_flesh", "riesenpilz:lavashroom_skin"})
		technic.comp("riesenpilz:lavashroom_skin 5", "riesenpilz:antilava_plate")

		armor_register(plate blah)
	end--] ]
})
end--]]


if riesenpilz.enable_mapgen then
	dofile(modpath.."mapgen.lua")
end



-- Legacy


minetest.register_alias("riesenpilz:head_binge", "riesenpilz:head_beige")


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[riesenpilz] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
