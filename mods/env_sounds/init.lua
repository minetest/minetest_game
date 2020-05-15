-- Parameters

-- Node search radius around player
local radius = 8

local allsounds = {
	["env_sounds_water"] = {
		trigger = {"default:water_flowing", "default:river_water_flowing"},
		base_volume = 0.04,
		max_volume = 0.4,
		per_node = 0.004,
	},
	["env_sounds_lava"] = {
		trigger = {"default:lava_source", "default:lava_flowing"},
		base_volume = 0,
		max_volume = 0.6,
		per_node = {
			["default:lava_source"] = 0.008,
			["default:lava_flowing"] = 0.002,
		},
	},
}

if minetest.settings:get_bool("river_source_sounds") then
	table.insert(allsounds["env_sounds_water"].trigger,
		"default:river_water_source")
end


-- Update sound for player

local function update_sound(player)
	local player_name = player:get_player_name()
	local ppos = player:get_pos()
	ppos = vector.add(ppos, player:get_properties().eye_height)
	local areamin = vector.subtract(ppos, radius)
	local areamax = vector.add(ppos, radius)

	for sound, def in pairs(allsounds) do
		local pos, counts = minetest.find_nodes_in_area(areamin, areamax,
			def.trigger)
		if #pos > 0 then
			-- Find average position
			local posav = vector.new()
			for _, p in ipairs(pos) do
				posav.x = posav.x + p.x
				posav.y = posav.y + p.y
				posav.z = posav.z + p.z
			end
			posav = vector.divide(posav, #pos)

			-- Calculate gain
			local gain = def.base_volume
			if type(def.per_node) == 'table' then
				for nodename, n in pairs(counts) do
					gain = gain + n * def.per_node[nodename]
				end
			else
				gain = gain + #pos * def.per_node
			end
			gain = math.min(gain, def.max_volume)
			minetest.sound_play(sound, {
				pos = posav,
				to_player = player_name,
				gain = gain,
			}, true)
		end
	end
end


-- Update sound when player joins

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
