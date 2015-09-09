
sethome = {}

local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
	local input, err = io.open(homes_file, "r")
	if not input then
		return minetest.log("info", "Could not load player homes file: " .. err)
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
		return false
	end

	local data = {}
	local output = io.open(homes_file, "w")
	if output then
		homepos[name] = pos
		for i, v in pairs(homepos) do
			table.insert(data, string.format("%.1f %.1f %.1f %s\n", v.x, v.y, v.z, i))
		end
		output:write(table.concat(data))
		io.close(output)
		return true
	end
	minetest.log("action", "[sethome] unable to write to homes file")
	return false
end

sethome.get = function(name)
	return homepos[name]
end

sethome.go = function(name)
	local player = minetest.get_player_by_name(name)
	if player and homepos[name] then
		player:setpos(homepos[name])
		return true
	end
	return false
end

minetest.register_privilege("home", "Can use /sethome and /home")

minetest.register_chatcommand("home", {
	description = "Teleport you to your home point",
	privs = {home = true},
	func = function(name)
		if sethome.go(name) then
			return true, "Teleported to home!"
		end
		return false, "Set a home using /sethome"
	end,
})

minetest.register_chatcommand("sethome", {
	description = "Set your home point",
	privs = {home = true},
	func = function(name)
		name = name or "" -- fallback to empty player name if nil
		local player = minetest.get_player_by_name(name)
		if player and sethome.set(name, player:getpos()) then
			return true, "Home set!"
		end
		return false, "Player not found!"
	end,
})
