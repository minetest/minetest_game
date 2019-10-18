-- sethome/init.lua

sethome = {}

-- Load support for MT game translation.
local S = minetest.get_translator("sethome")


local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local formspec =
        "size[8,4]" ..
        "real_coordinates[true]" ..
        "label[3,0.5;" .. S("Are you sure?") .. "]" ..
        "label[0.65,1;" .. S("(This will override your previous home coordinates!)") .. "]" ..
        "button_exit[0.2,2.75;2,1;yes;Yes]" ..
        "button_exit[5.6,2.75;2,1;no;No]"

local function loadhomes()
	local input = io.open(homes_file, "r")
	if not input then
		return -- no longer an error
	end

	-- Iterate over all stored positions in the format "x y z player" for each line
	for pos, name in input:read("*a"):gmatch("(%S+ %S+ %S+)%s([%w_-]+)[\r\n]") do
		homepos[name] = minetest.string_to_pos(pos)
	end
	input:close()
end

loadhomes()

sethome.set = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player or not pos then
		minetest.chat_send_player(player:get_player_name(), "Player not found!")
	end
	player:set_attribute("sethome:home", minetest.pos_to_string(pos))

	-- remove `name` from the old storage file
	local data = {}
	local output = io.open(homes_file, "w")
	if output then
		homepos[name] = nil
		for i, v in pairs(homepos) do
			table.insert(data, string.format("%.1f %.1f %.1f %s\n", v.x, v.y, v.z, i))
		end
		output:write(table.concat(data))
		io.close(output)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "sethome:sethomedialog" then
		if fields.yes then
			sethome.set(player:get_player_name(), player:get_pos())
			minetest.chat_send_player(player:get_player_name(), "Home set!")
		end
	end
end)

sethome.get = function(name)
	local player = minetest.get_player_by_name(name)
	local pos = minetest.string_to_pos(player:get_attribute("sethome:home"))
	if pos then
		return pos
	end

	-- fetch old entry from storage table
	pos = homepos[name]
	if pos then
		return vector.new(pos)
	else
		return nil
	end
end

sethome.go = function(name)
	local pos = sethome.get(name)
	local player = minetest.get_player_by_name(name)
	if player and pos then
		player:set_pos(pos)
		return true
	end
	return false
end

minetest.register_privilege("home", {
	description = S("Can use /sethome and /home"),
	give_to_singleplayer = false
})

minetest.register_chatcommand("home", {
	description = S("Teleport you to your home point"),
	privs = {home = true},
	func = function(name)
		if sethome.go(name) then
			return true, S("Teleported to home!")
		end
		return false, S("Set a home using /sethome")
	end,
})

minetest.register_chatcommand("sethome", {
	description = S("Set your home point"),
	privs = {home = true},
	func = function(name)
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		minetest.show_formspec(player:get_player_name(), "sethome:sethomedialog", formspec)
	end,
})
