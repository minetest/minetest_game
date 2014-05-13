-- moontest 0.6.5 by paramat
-- Licenses: code WTFPL, textures CC BY-SA

moontest = {}

local player_pos = {}
local player_pos_previous = {}

dofile(minetest.get_modpath("moontest").."/nodes.lua")
dofile(minetest.get_modpath("moontest").."/crafting.lua")

-- Globalstep function
minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		if FOOT and math.random() < 0.3 and player_pos_previous[player:get_player_name()] ~= nil then -- eternal footprints
			local pos = player:getpos()
			player_pos[player:get_player_name()] = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.2),z=math.floor(pos.z+0.5)}
			local p_ground = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.4),z=math.floor(pos.z+0.5)}
			local n_ground  = minetest.get_node(p_ground).name
			local p_groundpl = {x=math.floor(pos.x+0.5),y=math.floor(pos.y-0.5),z=math.floor(pos.z+0.5)}
			if player_pos[player:get_player_name()].x ~= player_pos_previous[player:get_player_name()].x
			or player_pos[player:get_player_name()].y < player_pos_previous[player:get_player_name()].y
			or player_pos[player:get_player_name()].z ~= player_pos_previous[player:get_player_name()].z then
				if n_ground == "moontest:dust" then
					if math.random() < 0.5 then
						minetest.add_node(p_groundpl,{name="moontest:dustprint1"})
					else
						minetest.add_node(p_groundpl,{name="moontest:dustprint2"})
					end
				end
			end
			player_pos_previous[player:get_player_name()] = {
				x=player_pos[player:get_player_name()].x,
				y=player_pos[player:get_player_name()].y,
				z=player_pos[player:get_player_name()].z
			}
		end
		if math.random() < 0.1 then
			if player:get_inventory():contains_item("main", "moontest:spacesuit")
			and player:get_breath() < 11 then
				player:set_breath(11)
			end
		end
		if math.random() > 0.99 then
			local pos = player:getpos()
		end
	end
end)

-- Space apple tree

function moontest_appletree(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	for j = -2, -1 do
		local nodename = minetest.get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moontest:soil" then
			return
		end
	end
	for j = 1, 5 do
		local nodename = minetest.get_node({x=x,y=y+j,z=z}).name
		if nodename ~= "moontest:air" then
			return
		end
	end
	for j = -2, 4 do
		if j >= 1 then
			for i = -2, 2 do
			for k = -2, 2 do
				local nodename = minetest.get_node({x=x+i,y=y+j+1,z=z+k}).name
				if math.random() > (math.abs(i) + math.abs(k)) / 16 then
					if math.random(13) == 2 then
						minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="default:apple"})
					else
						minetest.add_node({x=pos.x+i,y=pos.y+j+1,z=pos.z+k},{name="moontest:leaves"})
					end
				else
					minetest.add_node({x=x+i,y=y+j+1,z=z+k},{name="moontest:air"})
					minetest.get_meta({x=x+i,y=y+j+1,z=z+k}):set_int("spread", 16)
				end
			end
			end
		end
		minetest.add_node({x=pos.x,y=pos.y+j,z=pos.z},{name="default:tree"})
	end
	print ("[moontest] Appletree sapling grows")
end

-- Vacuum or air flows into a dug hole

minetest.register_on_dignode(function(pos, oldnode, digger)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	for i = -1,1 do
	for j = -1,1 do
	for k = -1,1 do
		if not (i == 0 and j == 0 and k == 0) then
			local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
			if nodename == "moontest:air" then	
				local spread = minetest.get_meta({x=x+i,y=y+j,z=z+k}):get_int("spread")
				if spread > 0 then
					minetest.add_node({x=x,y=y,z=z},{name="moontest:air"})
					minetest.get_meta(pos):set_int("spread", (spread - 1))
					print ("[moontest] MR air flows into hole "..(spread - 1))
					return
				end
			elseif nodename == "moontest:vacuum" then
				minetest.add_node({x=x,y=y,z=z},{name="moontest:vacuum"})
				print ("[moontest] Vacuum flows into hole")
				return
			end
		end
	end
	end
	end
end)

-- Air spreads

minetest.register_abm({
	nodenames = {"moontest:air"},
	neighbors = {"moontest:vacuum", "air"},
	interval = 11,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local spread = minetest.get_meta(pos):get_int("spread")
		if spread <= 0 then
			return
		end
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -1,1 do
		for j = -1,1 do
		for k = -1,1 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moontest:vacuum"
				or nodename == "air" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moontest:air"})
					minetest.get_meta({x=x+i,y=y+j,z=z+k}):set_int("spread", (spread - 1))
					print ("[moontest] MR air spreads "..(spread - 1))
				end
			end
		end
		end
		end
	end
})

-- Hydroponic saturation

minetest.register_abm({
	nodenames = {"moontest:hlsource", "moontest:hlflowing"},
	neighbors = {"moontest:dust", "moontest:dustprint1", "moontest:dustprint2"},
	interval = 29,
	chance = 9,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -2,2 do
		for j = -4,0 do -- saturates out and downwards to pos.y - 4, a 5x5 cube.
		for k = -2,2 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moontest:dust"
				or nodename == "moontest:dustprint1"
				or nodename == "moontest:dustprint2" then
					minetest.add_node({x=x+i,y=y+j,z=z+k},{name="moontest:soil"})
					print ("[moontest] Hydroponic liquid saturates")
				end
			end
		end
		end
		end
	end
})

-- Soil drying

minetest.register_abm({
	nodenames = {"moontest:soil"},
	interval = 31,
	chance = 27,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		for i = -2, 2 do
		for j = 0, 4 do -- search above for liquid
		for k = -2, 2 do
			if not (i == 0 and j == 0 and k == 0) then
				local nodename = minetest.get_node({x=x+i,y=y+j,z=z+k}).name
				if nodename == "moontest:hlsource" or nodename == "moontest:hlflowing" then
					return
				end
			end
		end
		end
		end
		minetest.add_node(pos,{name="moontest:dust"})
		print ("[moontest] Moon soil dries")
	end,
})

-- Space appletree from sapling

minetest.register_abm({
	nodenames = {"moontest:sapling"},
	interval = 57,
	chance = 3,
	action = function(pos, node, active_object_count, active_object_count_wider)
		moontest_appletree(pos)
	end,
})
