-- Parameters

local radius = 8 -- Water node search radius around player

-- End of parameters


local handles = {}
local river_source_sounds = minetest.settings:get_bool("river_source_sounds")


-- Update sound for player

local function update_sound(player)
	local player_name = player:get_player_name()
	-- Search for water nodes in radius around player
	local ppos = player:getpos()
	local areamin = vector.subtract(ppos, radius)
	local areamax = vector.add(ppos, radius)
	local wpos, num
	if river_source_sounds then
		wpos, num = minetest.find_nodes_in_area(
			areamin,
			areamax,
			{
				"default:water_flowing",
				"default:river_water_source",
				"default:river_water_flowing"
			}
		)
	else
		wpos, num = minetest.find_nodes_in_area(
			areamin,
			areamax,
			{
				"default:water_flowing",
				"default:river_water_flowing"
			}
		)
	end
	-- Total number of waters in radius
	local waters = (num["default:water_flowing"] or 0) +
		(num["default:river_water_source"] or 0) +
		(num["default:river_water_flowing"] or 0)
	-- If waters
	if waters > 0 then
		-- Find centre of water positions
		local wposmid = wpos[1]
		-- If more than 1 water
		if #wpos > 1 then
			local wposmin = areamax
			local wposmax = areamin
			for i = 1, #wpos do
				local wposi = wpos[i]
				if wposi.x > wposmax.x then
					wposmax.x = wposi.x
				end
				if wposi.y > wposmax.y then
					wposmax.y = wposi.y
				end
				if wposi.z > wposmax.z then
					wposmax.z = wposi.z
				end
				if wposi.x < wposmin.x then
					wposmin.x = wposi.x
				end
				if wposi.y < wposmin.y then
					wposmin.y = wposi.y
				end
				if wposi.z < wposmin.z then
					wposmin.z = wposi.z
				end
			end
			wposmid = vector.divide(vector.add(wposmin, wposmax), 2)
		end
		-- Play sound
		local handle = minetest.sound_play(
			"env_sounds_water",
			{
				pos = wposmid,
				to_player = player_name,
				gain = math.min(0.04 + waters * 0.004, 0.4),
				max_hear_distance = 32,
			}
		)
		-- Store sound handle for this player
		if handle then
			handles[player_name] = handle
		end
	end
end


-- Update sound 'on joinplayer'

minetest.register_on_joinplayer(function(player)
	update_sound(player)
end)


-- Cyclic sound update

local function cyclic_update()
	for _, player in pairs(minetest.get_connected_players()) do
		update_sound(player)
	end
	minetest.after(3.5, cyclic_update)
end

minetest.after(0, cyclic_update)


-- Stop sound and clear handle on player leave

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	if handles[player_name] then
		minetest.sound_stop(handles[player_name])
		handles[player_name] = nil
	end
end)
