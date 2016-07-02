home = {} -- Global namespace
local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
    local input = io.open(homes_file, "r")
    if input then
		repeat
            local x = input:read("*n")
            if x == nil then
            	break
            end
            local y = input:read("*n")
            local z = input:read("*n")
            local name = input:read("*l")
            homepos[name:sub(2)] = {x = x, y = y, z = z}
        until input:read(0) == nil
        io.close(input)
    else
        homepos = {}
    end
end

loadhomes()

minetest.register_privilege("home", "Can use /sethome and /home")

function home.go(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		-- just a check to prevent the server crashing
		return false, "Player " .. name .. " not found"
	end
	if homepos[name] then
		player:setpos(homepos[name])
		return true, "Teleported to home!"
	else
		return false, "Set a home using /sethome"
	end
end

minetest.register_chatcommand("home", {
	description = "Teleport you to your home point",
	privs = {home=true},
	func = function(name)
		return home.go(name)
	end,
})

function home.set(name, pos)
	if type(pos) ~= "table" then
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "No position given and player is offline"
		end
		pos = player:getpos()
	end

	homepos[name] = pos

	local output, err = io.open(homes_file, "w")
	if output then
		for i, v in pairs(homepos) do
			output:write(v.x.." "..v.y.." "..v.z.." "..i.."\n")
		end
		output:close()
	else
		minetest.log("warning", "Couldn't open sethome's home file for saving positions : " .. err)
	end
	return true, "Home set!"
end

minetest.register_chatcommand("sethome", {
	description = "Set your home point",
	privs = {home=true},
	func = function(name)
		return home.set(name)
	end,
})

function home.get(name)
	return homepos[name]
end
