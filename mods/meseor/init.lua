-- meseor 0.2.0 by paramat.
-- License WTFPL, see license.txt.

-- Parameters.

local ONGEN = true -- (true / false) Enable / disable impacts on generated chunk.
local ONGCHA = 9 -- 9 -- Ongen 1/x chance of impact per generated chunk.

local ABM = false -- Enable / disable impacts by abm on surface material.
local ABMINT = 181 -- 181 -- Abm interval.
local ABMCHA = 100000 -- 100000 -- Abm 1/x chance per node.
local DAMAGE = true -- Enable / disable player damage loop.
local DAMMAX = 20 -- 20 -- Maximum damage. 20 = direct hit is fatal.

local RADMIN = 3 -- 3 -- Minimum crater radius.
local RADMAX = 16 -- 31 -- Maximum crater radius, on-gen craters are limited to 16.
local STOCHA = 5 -- 5 -- 1/x chance of stone boulders instead of gravel.

local XMIN = -32000 -- Impact area dimensions. Impacts only inside this area.
local XMAX = 32000
local ZMIN = -32000
local ZMAX = 32000

local SAXMIN = 0 -- Safe area dimensions. No impacts inside this area.
local SAXMAX = 0 -- When overlapping impact area, the safe area overrides.
local SAZMIN = 0
local SAZMAX = 0

local DEBUG = true

-- Stuff.

meseor = {}

-- On generated.

if ONGEN then
	minetest.register_on_generated(function(minp, maxp, seed)
		if math.random(ONGCHA) == 2 then
			local env = minetest.env
			local maxrad = RADMAX
			if maxrad > 16 then maxrad = 16 end
			local conrad = math.random(RADMIN, maxrad)
			local rimrad = math.ceil(conrad * 2.4)
			local x = math.random(minp.x + rimrad, maxp.x - rimrad)
			local z = math.random(minp.z + rimrad, maxp.z - rimrad)
			-- Find surface with air above, abort if water found, ignore trees and ice.
			local surfy = false
			local aa = false
			for y = maxp.y, minp.y, -1 do
				local nodename = env:get_node({x=x,y=y,z=z}).name
				if nodename == "default:water_source" or nodename == "default:water_flowing" then
					return
				elseif nodename == "air" then
					aa = true
				elseif aa and nodename ~= "air" and nodename ~= "ignore" and nodename ~= "snow:ice"
				and nodename ~= "default:leaves" and nodename ~= "default:jungleleaves"
				and nodename ~= "default:tree" and nodename ~= "default:jungletree" then
					surfy = y
					break
				end
			end
			if not surfy then
				return
			end
			DAMAGE = false
			crater({x=x,y=surfy,z=z},conrad)
		end
	end)
end

-- Abm.

if ABM then
	minetest.register_abm({
		nodenames = {
			"default:obsidian",
			"moontest:dust",
		},    
		interval = ABMINT,	
		chance = ABMCHA,
		action = function(pos, node, _, _)
			local env = minetest.env
			local x = pos.x
			local y = pos.y
			local z = pos.z
			-- Find close surface above, abort if underwater or no close surface found.
			local surfy = false
			for j = 1, 4 do
				local nodename = env:get_node({x=x,y=y+j,z=z}).name
				if nodename == "default:water_source" or nodename == "default:water_flowing" then
					return
				elseif nodename == "air" then
					surfy = y+j-1
					break
				end
			end
			if not surfy then
				return
			end
			local conrad = math.random(RADMIN, RADMAX)
			crater({x=x,y=surfy,z=z},conrad)
		end,
	})
end

-- Functions.

function crater(pos, conrad)
			local env = minetest.env
			local x = pos.x
			local y = pos.y
			local z = pos.z
			local rimrad = math.ceil(conrad * 2.4)
			-- If in safe zone or not in impact zone then abort.
			if (x > SAXMIN - rimrad and x < SAXMAX + rimrad and z > SAZMIN - rimrad and z < SAZMAX + rimrad)
			or not (x > XMIN and x < XMAX and z > ZMIN and z < ZMAX) then
				return
			end
			-- Check enough depth.
			for j = -conrad - 1, -1 do
				local nodename = env:get_node({x=x,y=y+j,z=z}).name
				if nodename == "air" or nodename == "ignore" then
					return
				end
			end
			-- Check pos open to sky.
			for j = 1, 160 do
				local nodename = env:get_node({x=x,y=y+j,z=z}).name
				if nodename ~= "air" and nodename ~= "ignore"
				and nodename ~= "default:leaves" and nodename ~= "default:jungleleaves"
				and nodename ~= "snow:ice" and nodename ~= "snow:needles" then
					return
				end
			end
			-- Excavate path.
			for j = 1, 160 do
				local nodename = env:get_node({x=x,y=y+j,z=z}).name
				if nodename ~= "air" and nodename ~= "ignore" then
					env:remove_node({x=x,y=y+j,z=z})
				end
			end
			-- Add meseorite.
			env:add_node({x=x,y=y-conrad-1,z=z},{name="default:mese"})
			-- Excavate cone and count excavated nodes.
			local exsto = 0
			local exdsto = 0
			local exdirt = 0
			local exdsan = 0
			local exsan = 0
			local extree = 0
			local exjtree = 0
			for j = 0, conrad * 2 do
				for i = -j, j do
				for k = -j, j do
					if i ^ 2 + k ^ 2 <= j ^ 2 then
						local exsno = false
						local nodename = env:get_node({x=x+i,y=y-conrad+j,z=z+k}).name
						if nodename == "default:stone" then
							exsto = exsto + 1
						elseif nodename == "default:desert_stone" then
							exdsto = exdsto + 1
						elseif nodename == "default:dirt" or nodename == "default:dirt_with_grass" then
							exdirt = exdirt + 1
						elseif nodename == "default:desert_sand" then
							exdsan = exdsan + 1
						elseif nodename == "default:sand" then
							exsan = exsan + 1
						elseif nodename == "default:tree" then
							extree = extree + 1
						elseif nodename == "default:jungletree" then
							exjtree = exjtree + 1
						elseif nodename == "snow:snow" then
							exsno = true
						end
						if nodename ~= "air" then
							env:remove_node({x=x+i,y=y-conrad+j,z=z+k})
						end
						if exsno then
							env:remove_node({x=x+i,y=y-conrad+j,z=z+k})
						end
					end
				end
				end
			end
			-- Calculate proportions of ejecta.
			local extot = exsto + exdsto + exdirt + exdsan + exsan + extree + exjtree
			local pexsto = exsto / extot
			local pexdsto = exdsto / extot
			local pexdirt = exdirt / extot
			local pexdsan = exdsan / extot
			local pexsan = exsan / extot
			local pextree = extree / extot
			local pexjtree = exjtree / extot
			-- Print to terminal.
			if DEBUG then
				print ("[meseor] Cone radius "..conrad.." node ("..x.." "..y.." "..z..")")
				print ("[meseor] exsto "..exsto.." exdsto "..exdsto.." exdirt "..exdirt.." exdsan "..exdsan)
				print ("[meseor] exsan "..exsan.." extree "..extree.." exjtree "..exjtree)
				print ("[meseor] extot "..extot)
			end
			-- Add ejecta.
			local addtot = 0
			for rep = 1, 128 do
				for i = -rimrad, rimrad do
				for k = -rimrad, rimrad do
					local rad = (i ^ 2 + k ^ 2) ^ 0.5
					if rad <= rimrad and math.random() > math.abs(rad - conrad * 1.2) / (conrad * 1.2)
					and addtot < extot and math.random(3) == 2 then
						-- Find ground.
						local groundy = false
						for j = conrad - 1, -160, -1 do
							local nodename = env:get_node({x=x+i,y=y+j,z=z+k}).name
							if nodename == "default:leaves" or nodename == "default:jungleleaves"
							or nodename == "default:papyrus" or nodename == "default:dry_shrub"
							or nodename == "default:grass_1" or nodename == "default:grass_2"
							or nodename == "default:grass_3" or nodename == "default:grass_4"
							or nodename == "default:grass_5" or nodename == "default:apple"
							or nodename == "default:junglegrass" or nodename == "snow:needles" then
								env:remove_node({x=x+i,y=y+j,z=z+k})
							elseif nodename ~= "air" and nodename ~= "ignore" and nodename ~= "snow:snow"
							and nodename ~= "default:water_source" and nodename ~= "default:water_flowing" then
								groundy = y+j
								break
							end
						end
						if groundy then
							local x = x + i
							local y = groundy + 1
							local z = z + k
							if math.random() < pexjtree then
								env:add_node({x=x,y=y,z=z},{name="default:jungletree"})
							elseif math.random() < pextree then
								env:add_node({x=x,y=y,z=z},{name="default:tree"})
							elseif math.random() < pexsan then
								env:add_node({x=x,y=y,z=z},{name="default:sand"})
							elseif math.random() < pexdsan then
								env:add_node({x=x,y=y,z=z},{name="default:desert_sand"})
							elseif math.random() < pexdirt then
								env:add_node({x=x,y=y,z=z},{name="default:dirt"})
							elseif math.random() < pexdsto then
								env:add_node({x=x,y=y,z=z},{name="default:desert_stone"})
							elseif math.random() < pexsto then
								if math.random(STOCHA) == 2 then
									env:add_node({x=x,y=y,z=z},{name="default:stone"})
								else
									env:add_node({x=x,y=y,z=z},{name="default:gravel"})
								end
							end
							addtot = addtot + 1
						end
					end
				end
				end
				if addtot == extot then break end
			end
			-- Play sound.
			minetest.sound_play("meseor", {gain = 1})
			-- Damage player if inside rimrad.
			if DAMAGE then
				for _,player in ipairs(minetest.get_connected_players()) do
					local plapos = player:getpos()
					local pladis = ((plapos.x - x) ^ 2 + (plapos.y - y) ^ 2 + (plapos.z - z) ^ 2) ^ 0.5
					local pladam = math.ceil((1 - pladis / rimrad) * DAMMAX)
					if pladam > 0 then
						player:set_hp(player:get_hp() - pladam)
					end
				end
			end
end
