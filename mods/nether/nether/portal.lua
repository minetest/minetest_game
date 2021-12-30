--code copied from Pilzadam's nether mod and edited

-- kills the player if he uses PilzAdam portal
local portal_target = nether.buildings+1
local nether_prisons = minetest.settings:get_bool("enable_damage")
local obsidian_portal_kills = nether_prisons and true
local mclike_portal = false

local abm_allowed
minetest.after(5, function()
	abm_allowed = true
end)

local save_path = minetest.get_worldpath() .. "/nether_players"
local players_in_nether = {}
-- only get info from file if nether prisons
if nether_prisons then
	local file = io.open(save_path, "r")
	if not file then
		return
	end
	local contents = file:read"*all"
	io.close(file)
	if not contents then
		return
	end
	local playernames = string.split(contents, " ")
	for i = 1,#playernames do
		players_in_nether[playernames[i]] = true
	end
end

local function save_nether_players()
	local playernames,n = {},1
	for name in pairs(players_in_nether) do
		playernames[n] = name
		n = n+1
	end
	local f = io.open(save_path, "w")
	assert(f, "Could not open nether_players file for writing.")
	f:write(table.concat(playernames, " "))
	io.close(f)
end

local update_background
if nether_prisons then
	function update_background(player, down)
		if down then
			player:set_sky({r=15, g=0, b=0}, "plain")
		else
			player:set_sky(nil, "regular")
		end
	end
else
	function update_background()end
end

-- returns nodename if area is generated, else calls generation function
local function generated_or_generate(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		return node.name
	end
	minetest.get_voxel_manip():read_from_map(pos, pos)
	node = minetest.get_node_or_nil(pos)
	if not node then
		minetest.emerge_area(vector.subtract(pos, 80), vector.add(pos, 80))
		return false
	end
	return node.name
end

-- where the player appears after dying
local function get_player_died_target(player)
	local target = vector.add(player:get_pos(),
		{x=math.random(-100,100), y=0, z=math.random(-100,100)})
	target.y = portal_target + math.random(4)
	return target
end

-- used for obsidian portal
local function obsidian_teleport(player, pname, target)
	minetest.chat_send_player(pname, "For any reason you arrived here. Type " ..
		"/nether_help to find out things like craft recipes.")
	players_in_nether[pname] = true
	save_nether_players()
	update_background(player, true)
	if target then
		player:set_pos(target)
	else
		player:set_hp(0)
	end
end

-- teleports players to nether or helps it
local function player_to_nether(player, pos)
	local pname = player:get_player_name()
	if players_in_nether[pname] then
		return
	end
	players_in_nether[pname] = true
	save_nether_players()
	update_background(player, true)
	if pos then
		player:set_pos(pos)
		return
	end
	minetest.chat_send_player(pname, "For any reason you arrived here. " ..
		"Type /nether_help to find out things like craft recipes.")
	player:set_hp(0)
	if not nether_prisons then
		player:set_pos(get_player_died_target(player))
	end
end

local function player_from_nether(player, pos)
	local pname = player:get_player_name()
	if players_in_nether[pname] then
		players_in_nether[pname] = nil
		save_nether_players()
	end
	update_background(player)
	player:set_pos(pos)
end


local function player_exists(name)
	local players = minetest.get_connected_players()
	for i = 1,#players do
		if players[i]:get_player_name() == name then
			return true
		end
	end
	return false
end

-- Chatcommands (edited) written by sss
minetest.register_chatcommand("to_hell", {
	params = "[<player_name>]",
	description = "Send someone to hell",
	func = function(name, pname)
		if not minetest.check_player_privs(name, {nether=true}) then
			return false,
				"You need the nether privilege to execute this chatcommand."
		end
		if not player_exists(pname) then
			pname = name
		end
		local player = minetest.get_player_by_name(pname)
		if not player then
			return false, "Something went wrong."
		end
		minetest.chat_send_player(pname, "Go to hell !!!")
		player_to_nether(player)
		return true, pname.." is now in the nether."
	end
})

minetest.register_chatcommand("from_hell", {
	params = "[<player_name>]",
	description = "Extract from hell",
	func = function(name, pname)
		if not minetest.check_player_privs(name, {nether=true}) then
			return false,
				"You need the nether priv to execute this chatcommand."
		end
		if not player_exists(pname) then
			pname = name
		end
		local player = minetest.get_player_by_name(pname)
		if not player then
			return false, "Something went wrong."
		end
		minetest.chat_send_player(pname, "You are free now")
		local pos = player:get_pos()
		player_from_nether(player, {x=pos.x, y=100, z=pos.z})
		return true, pname.." is now out of the nether."
	end
})


if nether_prisons then
	-- randomly set player position when he/she dies in nether
	minetest.register_on_respawnplayer(function(player)
		local pname = player:get_player_name()
		if not players_in_nether[pname] then
			return
		end
		local target = get_player_died_target(player)
		player:set_pos(target)
		minetest.after(0, function(pname, target)
			-- fixes respawn bug
			local player = minetest.get_player_by_name(pname)
			if player then
				player:moveto(target)
			end
		end, pname, target)
		return true
	end)

	-- override set_pos etc. to disallow player teleportion by e.g. travelnet
	local function can_teleport(player, pos)
		if not player:is_player() then
			-- the same metatable is used for entities
			return true
		end
		local pname = player:get_player_name()
		local in_nether = players_in_nether[pname] == true

		-- test if the target is valid
		if pos.y < nether.start then
			if in_nether then
				return true
			end
		elseif not in_nether then
			return true
		end

		-- test if the current position is valid
		local current_pos = player:get_pos()
		local now_in_nether = current_pos.y < nether.start
		if now_in_nether ~= in_nether then
			if in_nether then
				minetest.log("action", "Player \"" .. pname ..
					"\" has to be in the nether, teleporting it!")
				update_background(player, true)
				current_pos.y = portal_target
				player:set_pos(current_pos)
			else
				minetest.log("action", "Player \"" .. pname ..
					"\" must not be in the nether, teleporting it!")
				update_background(player)
				current_pos.y = 20
				player:set_pos(current_pos)
			end
			return false
		end

		minetest.chat_send_player(pname,
			"You can not simply teleport to or from the nether!")
		minetest.log("action", "Player \"" .. pname ..
			"\" attempted to teleport from or to the nether, ignoring.")
		return false
	end
	local methods = {"set_pos", "move_to", "setpos", "moveto"}
	local metatable_overridden
	minetest.register_on_joinplayer(function(player)
		-- set the background when the player joins
		if player:get_pos().y < nether.start then
			update_background(player, true)
		end

		-- overide set_pos etc. if not yet done
		if metatable_overridden then
			return
		end
		metatable_overridden = true
		local mt = getmetatable(player)
		for i = 1,#methods do
			local methodname = methods[i]
			local origfunc = mt[methodname]
			mt[methodname] = function(...)
				if can_teleport(...) then
					origfunc(...)
				end
			end
		end
	end)
else
	-- test if player is in nether when he/she joins
	minetest.register_on_joinplayer(function(player)
		players_in_nether[player:get_player_name()] =
			player:get_pos().y < nether.start or nil
	end)
end

-- removes the violet stuff from the obsidian portal
local function remove_portal_essence(pos)
	for z = -1,1 do
		for y = -2,2 do
			for x = -1,1 do
				local p = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
				if minetest.get_node(p).name == "nether:portal" then
					minetest.remove_node(p)
				end
			end
		end
	end
end

-- change parts of the particledefinition instead of recreating it every time
local particledef = {
	amount = 32,
	time = 4,
	minvel = {x=0, y=1, z=0},
	maxvel = {x=0, y=2, z=0},
	minacc = {x=-0.5,y=-3,z=-0.3},
	maxacc = {x=0.5,y=-0.4,z=0.3},
	minexptime = 1,
	maxexptime = 1,
	minsize = 0.4,
	maxsize = 3,
	collisiondetection = true,
}

-- teleports player to neter (obsidian portal)
local function obsi_teleport_player(player, pos, target)
	local pname = player:get_player_name()
	if players_in_nether[pname] then
		return
	end

	local objpos = player:get_pos()
	objpos.y = objpos.y+0.1 -- Fix some glitches at -8000
	if minetest.get_node(vector.round(objpos)).name ~= "nether:portal" then
		return
	end

	local has_teleported
	if obsidian_portal_kills then
		obsidian_teleport(player, pname)
		has_teleported = true
	elseif not mclike_portal then
		local target = vector.round(get_player_died_target(player))
		if generated_or_generate(target) then
			obsidian_teleport(player, pname, target)
			has_teleported = true
		end
	end

	if not has_teleported then
		-- e.g. ungenerated area
		return
	end

	remove_portal_essence(pos)

	minetest.sound_play("nether_portal_usual", {to_player=pname, gain=1})
end

-- abm for particles of the obsidian portal essence and for teleporting
minetest.register_abm({
	nodenames = {"nether:portal"},
	interval = 1,
	chance = 2,
	catch_up = false,
	action = function(pos, node)
		if not abm_allowed then
			return
		end
		particledef.minpos = {x=pos.x-0.25, y=pos.y-0.5, z=pos.z-0.25}
		particledef.maxpos = {x=pos.x+0.25, y=pos.y+0.34, z=pos.z+0.25}
		particledef.texture = "nether_portal_particle.png^[transform" ..
			math.random(0, 7)
		minetest.add_particlespawner(particledef)
		for _,obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if obj:is_player() then
				local meta = minetest.get_meta(pos)
				local target = minetest.string_to_pos(meta:get_string("target"))
				if target then
					minetest.after(3, obsi_teleport_player, obj, pos, target)
				end
			end
		end
	end,
})

local function move_check(p1, max, dir)
	local p = {x=p1.x, y=p1.y, z=p1.z}
	local d = math.abs(max-p1[dir]) / (max-p1[dir])
	while p[dir] ~= max do
		p[dir] = p[dir] + d
		if minetest.get_node(p).name ~= "default:obsidian" then
			return false
		end
	end
	return true
end

local function check_portal(p1, p2)
	if p1.x ~= p2.x then
		if not move_check(p1, p2.x, "x") then
			return false
		end
		if not move_check(p2, p1.x, "x") then
			return false
		end
	elseif p1.z ~= p2.z then
		if not move_check(p1, p2.z, "z") then
			return false
		end
		if not move_check(p2, p1.z, "z") then
			return false
		end
	else
		return false
	end

	if not move_check(p1, p2.y, "y") then
		return false
	end
	if not move_check(p2, p1.y, "y") then
		return false
	end

	return true
end

-- tests if it's an obsidian portal
local function is_portal(pos)
	for d=-3,3 do
		for y=-4,4 do
			local px = {x=pos.x+d, y=pos.y+y, z=pos.z}
			local pz = {x=pos.x, y=pos.y+y, z=pos.z+d}
			if check_portal(px, {x=px.x+3, y=px.y+4, z=px.z}) then
				return px, {x=px.x+3, y=px.y+4, z=px.z}
			end
			if check_portal(pz, {x=pz.x, y=pz.y+4, z=pz.z+3}) then
				return pz, {x=pz.x, y=pz.y+4, z=pz.z+3}
			end
		end
	end
end

-- put here the function for creating a second portal
local create_second_portal
if mclike_portal then
	function create_second_portal(target)
		-- change target here
	end
end

-- adds the violet portal essence
local function make_portal(pos)
	local p1, p2 = is_portal(pos)
	if not p1
	or not p2 then
		print("[nether] something failed.")
		return false
	end

	local in_nether = p1.y < nether.start

	if in_nether
	and not mclike_portal then
		print("[nether] aborted, obsidian portals can't be used to get out")
		return
	end

	for d=1,2 do
	for y=p1.y+1,p2.y-1 do
		local p
		if p1.z == p2.z then
			p = {x=p1.x+d, y=y, z=p1.z}
		else
			p = {x=p1.x, y=y, z=p1.z+d}
		end
		if minetest.get_node(p).name ~= "air" then
			return false
		end
	end
	end

	local param2
	if p1.z == p2.z then
		param2 = 0
	else
		param2 = 1
	end

	local target = {x=p1.x, y=p1.y, z=p1.z}
	target.x = target.x + 1
	if in_nether then
		target.y = 0
		create_second_portal(target)
	else
		target.y = portal_target + math.random(4)
	end

	if not generated_or_generate(target)
	and mclike_portal then
		return false
	end

	for d=0,3 do
	for y=p1.y,p2.y do
		local p
		if param2 == 0 then
			p = {x=p1.x+d, y=y, z=p1.z}
		else
			p = {x=p1.x, y=y, z=p1.z+d}
		end
		if minetest.get_node(p).name == "air" then
			minetest.set_node(p, {name="nether:portal", param2=param2})
		end
		local meta = minetest.get_meta(p)
		meta:set_string("p1", minetest.pos_to_string(p1))
		meta:set_string("p2", minetest.pos_to_string(p2))
		meta:set_string("target", minetest.pos_to_string(target))
	end
	end
	print("[nether] construction accepted.")
	return true
end

-- destroy the portal when destroying obsidian
minetest.override_item("default:obsidian", {
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local p1 = minetest.string_to_pos(meta:get_string("p1"))
		local p2 = minetest.string_to_pos(meta:get_string("p2"))
		local target = minetest.string_to_pos(meta:get_string("target"))
		if not p1 or not p2 then
			return
		end
		for x=p1.x,p2.x do
		for y=p1.y,p2.y do
		for z=p1.z,p2.z do
			local nn = minetest.get_node({x=x,y=y,z=z}).name
			if nn == "default:obsidian" or nn == "nether:portal" then
				if nn == "nether:portal" then
					minetest.remove_node({x=x,y=y,z=z})
				end
				local m = minetest.get_meta({x=x,y=y,z=z})
				m:set_string("p1", "")
				m:set_string("p2", "")
				m:set_string("target", "")
			end
		end
		end
		end
		meta = minetest.get_meta(target)
		if not meta then
			return
		end
		p1 = minetest.string_to_pos(meta:get_string("p1"))
		p2 = minetest.string_to_pos(meta:get_string("p2"))
		if not p1 or not p2 then
			return
		end
		for x=p1.x,p2.x do
		for y=p1.y,p2.y do
		for z=p1.z,p2.z do
			local nn = minetest.get_node({x=x,y=y,z=z}).name
			if nn == "default:obsidian" or nn == "nether:portal" then
				if nn == "nether:portal" then
					minetest.remove_node({x=x,y=y,z=z})
				end
				local m = minetest.get_meta({x=x,y=y,z=z})
				m:set_string("p1", "")
				m:set_string("p2", "")
				m:set_string("target", "")
			end
		end
		end
		end
	end
})

-- override mese crystal fragment for making an obsidian portal
minetest.after(0.1, function()
	minetest.override_item("default:mese_crystal_fragment", {
		on_place = function(stack, player, pt)
			if pt.under
			and minetest.get_node(pt.under).name == "default:obsidian" then
				local done = make_portal(pt.under)
				if done then
					minetest.chat_send_player(player:get_player_name(),
						"Warning: If you are in the nether you may not be " ..
						"able to find the way out!")
					if not minetest.settings:get_bool("creative_mode") then
						stack:take_item()
					end
				end
			end
			return stack
		end
	})
end)


-- a not filled square
local function vector_square(r)
	local tab, n = {}, 1
	for i = -r+1, r do
		for j = -1, 1, 2 do
			local a, b = r*j, i*j
			tab[n] = {a, b}
			tab[n+1] = {b, a}
			n=n+2
		end
	end
	return tab
end

local function is_netherportal(pos)
	local x, y, z = pos.x, pos.y, pos.z
	for _,i in pairs({-1, 3}) do
		if minetest.get_node({x=x, y=y+i, z=z}).name ~= "nether:white" then
			return
		end
	end
	for _,sn in pairs(vector_square(1)) do
		if minetest.get_node({x=x+sn[1], y=y-1, z=z+sn[2]}).name ~= "nether:netherrack"
		or minetest.get_node({x=x+sn[1], y=y+3, z=z+sn[2]}).name ~= "nether:blood_cooked" then
			return
		end
	end
	for _,sn in pairs(vector_square(2)) do
		if minetest.get_node({x=x+sn[1], y=y-1, z=z+sn[2]}).name ~= "nether:netherrack_black"
		or minetest.get_node({x=x+sn[1], y=y+3, z=z+sn[2]}).name ~= "nether:wood_empty" then
			return
		end
	end
	for i = -1,1,2 do
		for j = -1,1,2 do
			if minetest.get_node({x=x+i, y=y+2, z=z+j}).name ~= "nether:apple" then
				return
			end
		end
	end
	for i = -2,2,4 do
		for j = 0,2 do
			for k = -2,2,4 do
				if minetest.get_node({x=x+i, y=y+j, z=z+k}).name ~= "nether:netherrack_brick_blue" then
					return
				end
			end
		end
	end
	for i = -1,1 do
		for j = -1,1 do
			if minetest.get_node({x=x+i, y=y+4, z=z+j}).name ~= "nether:wood_empty" then
				return
			end
		end
	end
	return true
end

-- cache known portals
local known_portals_d = {}
local known_portals_u = {}
local function get_portal(t, z,x)
	return t[z] and t[z][x]
end
local function set_portal(t, z,x, y)
	t[z] = t[z] or {}
	t[z][x] = y
end

-- used when a player eats that fruit in a portal
function nether.teleport_player(player)
	if not player then
		minetest.log("error", "[nether] Missing player.")
		return
	end
	local pos = vector.round(player:get_pos())
	if not is_netherportal(pos) then
		return
	end
	minetest.sound_play("nether_teleporter", {pos=pos})
	local meta = minetest.get_meta({x=pos.x, y=pos.y-1, z=pos.z})
	if pos.y < nether.start then
		set_portal(known_portals_d, pos.z,pos.x, pos.y)

		local my = tonumber(meta:get_string("y"))
		local y = get_portal(known_portals_u, pos.z,pos.x)
		if y then
			if y ~= my then
				meta:set_string("y", y)
			end
		else
			y = my or 100
		end
		pos.y = y - 0.3

		player_from_nether(player, pos)
	else
		set_portal(known_portals_u, pos.z,pos.x, pos.y)

		local my = tonumber(meta:get_string("y"))
		local y = get_portal(known_portals_d, pos.z,pos.x)
		if y then
			if y ~= my then
				meta:set_string("y", y)
			end
		else
			y = my or portal_target+math.random(4)
		end
		pos.y = y - 0.3

		player_to_nether(player, pos)
	end
	minetest.sound_play("nether_teleporter", {pos=pos})
	return true
end
