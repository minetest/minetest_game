local pi = math.pi
local is_sp = minetest.is_singleplayer()
local enable_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_respawn == nil then
	enable_respawn = true
end

local enable_bed_in_the_daytime = minetest.settings:get_bool("enable_bed_in_the_daytime")

-- support for MT game translation.
local S = beds.get_translator

-- Helper functions

local function get_look_yaw(pos)
	local rotation = minetest.get_node(pos).param2
	if rotation > 3 then
		rotation = rotation % 4 -- Mask colorfacedir values
	end
	if rotation == 1 then
		return pi / 2, rotation
	elseif rotation == 3 then
		return -pi / 2, rotation
	elseif rotation == 0 then
		return pi, rotation
	else
		return 0, rotation
	end
end

local function is_night_skip_enabled()
	local enable_night_skip = minetest.settings:get_bool("enable_bed_night_skip")
	if enable_night_skip == nil then
		enable_night_skip = true
	end
	return enable_night_skip
end

local function is_night()
	local tod = minetest.get_timeofday()
	return not (tod > 0.2 and tod < 0.805)
end

local function check_in_beds(players)
	local in_bed = beds.player
	if not players then
		players = minetest.get_connected_players()
	end

	for n, player in ipairs(players) do
		local name = player:get_player_name()
		if not in_bed[name] then
			return false
		end
	end

	return #players > 0
end

local function lay_down(player, pos, bed_pos, state, skip)
	local name = player:get_player_name()
	local hud_flags = player:hud_get_flags()

	if not player or not name then
		return
	end

	-- stand up
	if state ~= nil and not state then
		if not beds.player[name] then
			-- player not in bed, do nothing
			return false
		end
		beds.bed_position[name] = nil
		-- skip here to prevent sending player specific changes (used for leaving players)
		if skip then
			return
		end
		player:set_pos(beds.pos[name])

		-- physics, eye_offset, etc
		local physics_override = beds.player[name].physics_override
		beds.player[name] = nil
		player:set_physics_override({
			speed = physics_override.speed,
			jump = physics_override.jump,
			gravity = physics_override.gravity
		})
		player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		player:set_look_horizontal(math.random(1, 180) / 100)
		player_api.player_attached[name] = false
		hud_flags.wielditem = true
		player_api.set_animation(player, "stand" , 30)

	-- lay down
	else

		-- Check if bed is occupied
		for _, other_pos in pairs(beds.bed_position) do
			if vector.distance(bed_pos, other_pos) < 0.1 then
				minetest.chat_send_player(name, S("This bed is already occupied!"))
				return false
			end
		end

		-- Check if player is moving
		if vector.length(player:get_velocity()) > 0.001 then
			minetest.chat_send_player(name, S("You have to stop moving before going to bed!"))
			return false
		end

		-- Check if player is attached to an object
		if player:get_attach() then
			return false
		end

		if beds.player[name] then
			-- player already in bed, do nothing
			return false
		end

		beds.pos[name] = pos
		beds.bed_position[name] = bed_pos
		beds.player[name] = {physics_override = player:get_physics_override()}

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = -13, z = 0}, {x = 0, y = 0, z = 0})
		local yaw, param2 = get_look_yaw(bed_pos)
		player:set_look_horizontal(yaw)
		local dir = minetest.facedir_to_dir(param2)
		-- p.y is just above the nodebox height of the 'Simple Bed' (the highest bed),
		-- to avoid sinking down through the bed.
		local p = {
			x = bed_pos.x + dir.x / 2,
			y = bed_pos.y + 0.07,
			z = bed_pos.z + dir.z / 2
		}
		player:set_physics_override({speed = 0, jump = 0, gravity = 0})
		player:set_pos(p)
		player_api.player_attached[name] = true
		hud_flags.wielditem = false
		player_api.set_animation(player, "lay" , 0)
	end

	player:hud_set_flags(hud_flags)
end

local function get_player_in_bed_count()
	local c = 0
	for _, _ in pairs(beds.player) do
		c = c + 1
	end
	return c
end

local function is_above_percent(player_in_bed)
	-- default: 50, range: 0..99
	local above_percent = math.min(tonumber(minetest.settings:get("bed_night_skip_above_percent")) or 50, 99);

	return (#minetest.get_connected_players() * above_percent / 100) < player_in_bed
end

local update_formspecs_loops = 0

local function update_formspecs(force_morning)
	local ges = #minetest.get_connected_players()
	local player_in_bed = get_player_in_bed_count()
	local tod = minetest.get_timeofday()

	local form_n = beds.formspec
	local esc = minetest.formspec_escape
	if force_morning or (tod >= 0.23 and tod <= 0.375) then -- <= ~9:00
		form_n = form_n .. "label[2.7,9;" .. esc(S("Good morning.")) .. "]"
	elseif not is_night() then
		if (tod < 0.749) then -- < ~18:00
			form_n = form_n .. "label[2.7,9;" .. esc(S("Wake up!")) .. "]"
		end
	elseif not is_sp then
		form_n = form_n .. "label[2.2,9;" ..
			esc(S("@1 of @2 players are in bed", player_in_bed, ges)) .. "]"

		if is_above_percent(player_in_bed) and is_night_skip_enabled() then
			form_n = form_n .. "button_exit[2,6;4,0.75;force;" ..
				esc(S("Force night skip")) .. "]"
		end
	end

	-- debug code disabled
	--form_n = form_n .. " " .. "label[2.2,8;" .. esc(tod*24) ..
	--	" loop:" .. update_formspecs_loops ..
	--	"]";

	for name,_ in pairs(beds.player) do
		minetest.show_formspec(name, "beds_form", form_n)
	end
end

local function check_night_skip()
	if is_night() and check_in_beds() then
		minetest.after(2, function()
			if not is_sp or enable_bed_in_the_daytime then
				update_formspecs(is_night_skip_enabled())
			end
			if is_night_skip_enabled() then
				beds.skip_night()
				beds.kick_players()
			end
		end)
		return true
	end
	return false
end

local function update_formspecs_loop()
	if not check_night_skip() then
		update_formspecs(false)
	end
	if get_player_in_bed_count() > 0 then
		update_formspecs_loops = update_formspecs_loops + 1
		minetest.after(2, update_formspecs_loop)
	else
		update_formspecs_loops = 0
	end
end

-- Public functions

function beds.kick_players()
	if enable_bed_in_the_daytime then
		return
	end
	for name, _ in pairs(beds.player) do
		local player = minetest.get_player_by_name(name)
		lay_down(player, nil, nil, false)
	end
end

function beds.skip_night()
	minetest.set_timeofday(0.23)
end

function beds.on_rightclick(pos, player)
	local name = player:get_player_name()
	local ppos = player:get_pos()

	if not is_night() and not enable_bed_in_the_daytime then
		if beds.player[name] then
			lay_down(player, nil, nil, false)
		end
		minetest.chat_send_player(name, S("You can only sleep at night."))
		return
	end

	-- move to bed
	if not beds.player[name] then
		lay_down(player, ppos, pos)
		beds.set_spawns() -- save respawn positions when entering bed
	else
		lay_down(player, nil, nil, false)
	end

	if not is_sp then
		update_formspecs(false)
	end

	-- skip the night and let all players stand up
	check_night_skip()

	if enable_bed_in_the_daytime and update_formspecs_loops == 0 then
		update_formspecs_loops = 1
		-- update formspecs for day sleepers
		minetest.after(2, update_formspecs_loop)
	end

end

function beds.can_dig(bed_pos)
	-- Check all players in bed which one is at the expected position
	for _, player_bed_pos in pairs(beds.bed_position) do
		if vector.equals(bed_pos, player_bed_pos) then
			return false
		end
	end
	return true
end

-- Callbacks
-- Only register respawn callback if respawn enabled
if enable_respawn then
	-- respawn player at bed if enabled and valid position is found
	minetest.register_on_respawnplayer(function(player)
		local name = player:get_player_name()
		local pos = beds.spawn[name]
		if pos then
			player:set_pos(pos)
			return true
		end
	end)
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	lay_down(player, nil, nil, false, true)
	beds.player[name] = nil
	check_night_skip()
end)

minetest.register_on_dieplayer(function(player)
	local name = player:get_player_name()
	local in_bed = beds.player
	local pos = player:get_pos()
	local yaw = get_look_yaw(pos)

	if in_bed[name] then
		lay_down(player, nil, pos, false)
		player:set_look_horizontal(yaw)
		player:set_pos(pos)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "beds_form" then
		return
	end

	-- Because "Force night skip" button is a button_exit, it will set fields.quit
	-- and lay_down call will change value of player_in_bed, so it must be taken
	-- earlier.
	local last_player_in_bed = get_player_in_bed_count()

	if fields.quit or fields.leave then
		lay_down(player, nil, nil, false)
		update_formspecs(false)
	end

	if fields.force then
		if is_above_percent(last_player_in_bed) and is_night_skip_enabled() then
			update_formspecs(true)
			beds.skip_night()
			beds.kick_players()
		else
			update_formspecs(false)
		end
	end
end)
