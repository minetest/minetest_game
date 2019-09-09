-- Parameters

local radius = 8 -- Water node search radius around player

-- End of parameters


local handles = {}
local river_source_sounds = minetest.settings:get_bool("river_source_sounds")


-- Update sound for player

local function update_sound(player)
	local player_name = player:get_player_name()
	-- Search for water nodes in radius around player
	local ppos = player:get_pos()
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
	local waters = #wpos
	if waters == 0 then
		return
	end

	-- Find average position of water positions
	local wposav = vector.new()
	for i, pos in ipairs(wpos) do
		wposav = vector.add(wposav, pos)
	end
	wposav = vector.divide(wposav, waters)
	-- Play sound
	local handle = minetest.sound_play(
		"env_sounds_water",
		{
			pos = wposav,
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
