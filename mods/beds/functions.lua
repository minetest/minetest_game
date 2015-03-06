local player_in_bed = 0
local is_sp = minetest.is_singleplayer()
local enable_respawn = minetest.setting_getbool("enable_bed_respawn") or true


-- helper functions

local function get_look_yaw(pos)
	local n = minetest.get_node(pos)
	if n.param2 == 1 then
		return 7.9, n.param2
	elseif n.param2 == 3 then
		return 4.75, n.param2
	elseif n.param2 == 0 then
		return 3.15, n.param2
	else
		return 6.28, n.param2
	end
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

	return true
end

local function lay_down(player, pos, bed_pos, state, skip)
	local name = player:get_player_name()
	local hud_flags = player:hud_get_flags()

	if not player or not name then
		return
	end

	-- stand up
	if state ~= nil and not state then
		local p = beds.pos[name] or nil
		if beds.player[name] ~= nil then
			beds.player[name] = nil
			player_in_bed = player_in_bed - 1
		end
		-- skip here to prevent sending player specific changes (used for leaving players)
		if skip then
			return
		end
		if p then 
			player:setpos(p)
		end

		-- physics, eye_offset, etc
		player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
		player:set_look_yaw(math.random(1, 180)/100)
		default.player_attached[name] = false
		player:set_physics_override(1, 1, 1)
		hud_flags.wielditem = true
		default.player_set_animation(player, "stand" , 30)

	-- lay down
	else
		beds.player[name] = 1
		beds.pos[name] = pos
		player_in_bed = player_in_bed + 1

		-- physics, eye_offset, etc
		player:set_eye_offset({x=0,y=-13,z=0}, {x=0,y=0,z=0})
		local yaw, param2 = get_look_yaw(bed_pos)
		player:set_look_yaw(yaw)
		local dir = minetest.facedir_to_dir(param2)
		local p = {x=bed_pos.x+dir.x/2,y=bed_pos.y,z=bed_pos.z+dir.z/2}
		player:set_physics_override(0, 0, 0)
		player:setpos(p)
		default.player_attached[name] = true
		hud_flags.wielditem = false
		default.player_set_animation(player, "lay" , 0)
	end

	player:hud_set_flags(hud_flags)
end

local function update_formspecs(finished)
	local ges = #minetest.get_connected_players()
	local form_n = ""
	local is_majority = (ges/2) < player_in_bed

	if finished then
		form_n = beds.formspec ..
			"label[2.7,11; Good morning.]"
	else
		form_n = beds.formspec ..
			"label[2.2,11;"..tostring(player_in_bed).." of "..tostring(ges).." players are in bed]"	
		if is_majority then
			form_n = form_n ..
				"button_exit[2,8;4,0.75;force;Force night skip]"
		end
	end

	for name,_ in pairs(beds.player) do
		minetest.show_formspec(name, "beds_form", form_n)
	end
end


-- public functions

function beds.kick_players()
	for name,_ in pairs(beds.player) do
		local player = minetest.get_player_by_name(name)
		lay_down(player, nil, nil, false)
	end
end

function beds.skip_night()
	minetest.set_timeofday(0.23)
	beds.set_spawns()
end

function beds.on_rightclick(pos, player)
	local name = player:get_player_name()
	local ppos = player:getpos()
	local tod = minetest.get_timeofday()

	if tod > 0.2 and tod < 0.805 then
		if beds.player[name] then
			lay_down(player, nil, nil, false)
		end
		minetest.chat_send_player(name, "You can only sleep at night.")
		return
	end

	-- move to bed
	if not beds.player[name] then
		lay_down(player, ppos, pos)
	else
		lay_down(player, nil, nil, false)
	end

	if not is_sp then
		update_formspecs(false)
	end

	-- skip the night and let all players stand up
	if check_in_beds() then
		minetest.after(2, function()
			beds.skip_night()
			if not is_sp then
				update_formspecs(true)
			end
			beds.kick_players()
		end)
	end
end


-- callbacks

minetest.register_on_joinplayer(function(player)
	beds.read_spawns()
end)

-- respawn player at bed if enabled and valid position is found
minetest.register_on_respawnplayer(function(player)
	if not enable_respawn then
		return false
	end
	local name = player:get_player_name()
	local pos = beds.spawn[name] or nil
	if pos then
		player:setpos(pos)
		return true
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	lay_down(player, nil, nil, false, true)
	beds.player[name] = nil
	if check_in_beds() then
		minetest.after(2, function()
			beds.skip_night()
			update_formspecs(true)
			beds.kick_players()
		end)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "beds_form" then
		return
	end
	if fields.quit or fields.leave then
		lay_down(player, nil, nil, false)
		update_formspecs(false)
	end

	if fields.force then
		beds.skip_night()
		update_formspecs(true)
		beds.kick_players()
	end
end)
