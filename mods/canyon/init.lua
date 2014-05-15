-- canyon 0.3.1 by paramat.
-- For latest stable Minetest and back to 0.4.3.
-- Depends default.
-- License WTFPL.

-- Parameters

local ONGEN = true -- (true / false) Enable / disable canyon.
local WAFAV = 0.4 -- 0.4 -- Water factor average.
local WAFAMP = 0.7 -- 0.7 -- Water factor amplitude.
--Water factor is proportion of water surface level to removed stone surface level.
local MINDEP = 11 -- 11 -- (0-30) Minimum river depth.
local MAXDEP = 30 -- 30 -- (0-30) Maximum river depth.
local PROG = true

local SEEDDIFF1 = 5192098 -- Perlin1 for river pattern.
local OCTAVES1 = 5 -- 5
local PERSISTENCE1 = 0.6 -- 0.6
local SCALE1 = 384 -- 384
local NOISEL = -0.06 -- -0.06 -- NOISEL and NOISEH control canyon width.
local NOISEH = 0.06 -- 0.06

local SEEDDIFF2 = 924 -- Perlin2 for depth variation.
local OCTAVES2 = 4 -- 4
local PERSISTENCE2 = 0.5 -- 0.5
local SCALE2 = 192 -- 192

local SEEDDIFF3 = 13050 -- Perlin3 for water factor variation.
local OCTAVES3 = 2 -- 2
local PERSISTENCE3 = 0.4 -- 0.4
local SCALE3 = 512 -- 512

-- Stuff

canyon = {}

local depran = MAXDEP - MINDEP
local noiran = NOISEH - NOISEL

-- On generated function

if ONGEN then
	minetest.register_on_generated(function(minp, maxp, seed)
		if minp.y == -32 then
			local env = minetest.env
			local perlin1 = env:get_perlin(SEEDDIFF1, OCTAVES1, PERSISTENCE1, SCALE1)
			local perlin2 = env:get_perlin(SEEDDIFF2, OCTAVES2, PERSISTENCE2, SCALE2)
			local perlin3 = env:get_perlin(SEEDDIFF3, OCTAVES3, PERSISTENCE3, SCALE3)
			local x1 = maxp.x
			local z1 = maxp.z
			local x0 = minp.x
			local z0 = minp.z
			for x = x0, x1 do
				if PROG then
					print ("[canyon] "..(x - x0 + 1).." ("..minp.x.." "..minp.y.." "..minp.z..")")
				end
				for z = z0, z1 do -- For each column do
					local noise1 = perlin1:get2d({x=x,y=z})
					if noise1 > NOISEL and noise1 < NOISEH then -- If column is in canyon then
						local noise2 = perlin2:get2d({x=x,y=z})
						local norm1 = (noise1 - NOISEL) * (NOISEH - noise1) / noiran ^ 2 * 4
						local norm2 = (noise2 + 1.875) / 3.75
						-- Find surface y
						local surfacey = 1
						for y = 47, 2, -1 do
							local nodename = env:get_node({x=x,y=y,z=z}).name
							if nodename ~= "moontest:vacuum" then
								surfacey = y
								break
							end
						end
						-- Find stone y
						local stoney = 1
						for y = 47, 2, -1 do
							local nodename = env:get_node({x=x,y=y,z=z}).name
							if nodename == "moontest:stone"
							or nodename == "moontest:basalt"
							or nodename == "moontest:dust" then
								stoney = y
								break
							end
						end
						-- Calculate water surface rise and riverbed sand bottom y
						local noise3 = perlin3:get2d({x=x,y=z})
						local watfac = WAFAV + noise3 * WAFAMP
						if watfac < 0 then
							watfac = 0
						end
						if watfac > 0.9 then
							watfac = 0.9
						end
						local watris = math.floor((stoney - 1) * watfac)
						local exboty = surfacey - math.floor(norm1 * (surfacey - watris + 2 + MINDEP + norm2 * depran))
						-- Find seabed y or airgap y
						local seabedy = 47
						for y = exboty, 47 do
							local nodename = env:get_node({x=x,y=y,z=z}).name
								if nodename == "moontest:hlsource"
								or nodename == "moontest:hlflowing"
								or nodename == "moontest:vacuum" then
								seabedy = y - 1
								break
							end
						end
						-- Excavate canyon, add sand if below seabed or airgap, add water up to varying height, dig surface
						for y = exboty, surfacey do
							if y <= exboty + 2 and y <= seabedy and y <= watris + 2 then
								env:add_node({x=x,y=y,z=z}, {name="moontest:dust"})
							elseif y < watris + 1 then
								env:add_node({x=x,y=y,z=z}, {name="moontest:hlsource"})
							elseif y == watris + 1 then
								env:add_node({x=x,y=y,z=z}, {name="moontest:hlsource"})
								env:dig_node({x=x,y=y+1,z=z})
							elseif y == surfacey then
								env:dig_node({x=x,y=y,z=z})
							else
								env:remove_node({x=x,y=y,z=z})
							end
						end
						-- Remove moss created by digging snow
						local nodename = env:get_node({x=x,y=surfacey,z=z}).name
						if nodename == "snow:moss" then
							env:dig_node({x=x,y=surfacey,z=z})
						end
					end
				end
			end
		end
	end)
end

