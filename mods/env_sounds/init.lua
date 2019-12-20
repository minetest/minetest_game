-- Parameters

local radius = 8 -- Water node search radius around player

-- End of parameters


local river_source_sounds = minetest.settings:get_bool("river_source_sounds")


-- Update sound for player

local function update_sound(player)
	local player_name = player:get_player_name()
	local ppos = player:get_pos()
	local areamin = vector.subtract(ppos, radius)
	local areamax = vector.add(ppos, radius)
	local water_nodes = {"default:water_flowing", "default:river_water_flowing"}
	if river_source_sounds then
		table.insert(water_nodes, "default:river_water_source")
	end
	local wpos, _ = minetest.find_nodes_in_area(areamin, areamax, water_nodes)
	local waters = #wpos
	if waters == 0 then
		return
	end

	-- Find average position of water positions
	local wposav = vector.new()
	for _, pos in ipairs(wpos) do
		wposav.x = wposav.x + pos.x
		wposav.y = wposav.y + pos.y
		wposav.z = wposav.z + pos.z
	end
	wposav = vector.divide(wposav, waters)

	minetest.sound_play(
		"env_sounds_water",
		{
			pos = wposav,
			to_player = player_name,
			gain = math.min(0.04 + waters * 0.004, 0.4),
		}
	)
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
