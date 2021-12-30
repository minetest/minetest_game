--V2
local function get_random(a, b, seed)
	return PseudoRandom(math.abs(a+b*5)+seed)
end

local r_chs = {}

local function nether_weird_noise(minp, fct, s, seed, range, scale)
	if not r_chs[s] then
		r_chs[s] = math.floor(s/3+0.5)
	end
	scale = scale or 15
	local r_ch = r_chs[s]
	local maxp = vector.add(minp, scale)

	local tab,n = {},1
	local sm = range or (s+r_ch)*2
	for z = -sm, scale+sm do
		local pz = z+minp.z
		if pz%s == 0 then
			for x = -sm, scale+sm do
				local px = x+minp.x
				if px%s == 0 then
					local pr = get_random(px, pz, seed)
					tab[n] = {x=px+pr:next(-r_ch, r_ch), y=0, z=pz+pr:next(-r_ch, r_ch)}
					n = n+1
				end
			end
		end
	end

	local tab2,n = {},1
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local h = sm
			for _,i in ipairs(tab) do
				h = math.min(h, fct(x, i.x, z, i.z))
			end
			tab2[n] = {x=x, y=maxp.y-h, z=z}
			n = n+1
		end
	end
	return tab2
end

--[[
local function dif(z1, z2)
	return math.abs(z1-z2)
end

local function pymg(x1, x2, z1, z2)
	return math.max(dif(x1, x2), dif(z1, z2))
end

local function romg(x1, x2, z1, z2)
	return math.hypot(dif(x1, x2), dif(z1, z2))
end

local function py2mg(x1, x2, z1, z2)
	return dif(x1, x2) + dif(z1, z2)
end

minetest.register_node("ac:wmg", {
	description = "wmg",
	tiles = {"ac_block.png"},
	groups = {snappy=1,bendy=2,cracky=1},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local minp = vector.chunkcorner(pos)
		for _,p in ipairs(weird_noise(minp, pymg, 20, 8, 4)) do
			local p2 = {x=p.x, y=p.y+1, z=p.z}
			if p.y <= minp.y+7 then
				local p2 = {x=p.x, y=minp.y+6, z=p.z}
				local p3 = {x=p.x, y=p2.y+1, z=p.z}
				if minetest.get_node(p2).name ~= "default:desert_stone" then
					minetest.set_node(p2, {name="default:desert_stone"})
				end
				if minetest.get_node(p3).name ~= "default:desert_sand" then
					minetest.set_node(p3, {name="default:desert_sand"})
				end
			else
				if minetest.get_node(p).name ~= "default:desert_stone" then
					minetest.set_node(p, {name="default:desert_stone"})
				end
			end
		end
	end,
})]]

return nether_weird_noise
