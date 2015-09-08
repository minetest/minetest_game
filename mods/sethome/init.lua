local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}

local function loadhomes()
	local input = io.open(homes_file, "r")
	if input then
		repeat
			local x = input:read("*n")
			if not x then
				break
			end
			local y = input:read("*n")
			local z = input:read("*n")
			local name = input:read("*l")
			homepos[name:sub(2)] = vector.new(x, y, z)
		until not input:read(0)
		io.close(input)
	end
end

loadhomes()

minetest.register_on_shutdown(function()
	local output = io.open(homes_file, "w")
	for i, v in pairs(homepos) do
		output:write(v.x.." "..v.y.." "..v.z.." "..i.."\n")
	end
	io.close(output)
end)

minetest.register_privilege("home", "Can use /sethome and /home")

minetest.register_chatcommand("home", {
	description = "Teleport you to your home point",
	privs = {home=true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end
		if homepos[name] then
			player:setpos(homepos[name])
			return "Teleported to home!"
		else
			return "Set a home using /sethome"
		end
	end
})

minetest.register_chatcommand("sethome", {
	description = "Set your home point",
	privs = {home=true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end
		homepos[name] = player:getpos()
		return "Home set!"
	end
})
