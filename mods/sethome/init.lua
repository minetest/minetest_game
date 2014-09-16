local homes_file = minetest.get_worldpath() .. "/homes.txt"
local oldhomes_file = minetest.get_worldpath() .. "/homes"

local input, err = io.open(homes_file, "r")
if err then
	minetest.log("error", "[sethome] Failed to open homes file: " .. err)
else
	homepos = minetest.deserialize(input:read("*a"))
	if type(homepos) ~= "table" then
		homepos = {}
	end
	io.close(input)
end

minetest.register_privilege("home", "Can use /sethome and /home")

minetest.register_chatcommand("home", {
	description = "Teleport you to your home point",
	privs = {home=true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player == nil then
			return false
		end
		if homepos[name] then
			player:setpos(homepos[name])
			minetest.chat_send_player(name, "Teleported to home!")
		else
			minetest.chat_send_player(name, "Set a home using /sethome")
		end
	end
})

minetest.register_chatcommand("sethome", {
	description = "Set your home point",
	privs = {home=true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = vector.round(player:getpos())
		homepos[name] = pos
		local homedata = minetest.serialize(homepos)
		if not homedata then
			minetest.log("error", "[sethome] Failed to serialize home data!")
			minetest.chat_send_player(name, "Something failed while serializing the home data.")
			return false
		end
		local output, err = io.open(homes_file, "w")
		if err then
			minetest.log("error", "[sethome] Failed to open homes file: " .. err)
			minetest.chat_send_player(name, "Could not save your new home position.")
			return false
		end
		output:write(homedata)
		io.close(output)
		minetest.chat_send_player(name, "Home set at " .. minetest.pos_to_string(pos))
	end
})

minetest.register_chatcommand("migrate_homes", {
	description = "Migrate to new homes file format",
	privs = {rollback=true}
	func = function(name)
		local input, err = io.open(oldhomes_file, "r")
		if err then
			minetest.log("error", "[sethome] Failed to open old homes file: " .. err)
			return false
		else
			repeat
				local x = input:read("*n")
				if x == nil then
					break
				end
				local y = input:read("*n")
				local z = input:read("*n")
				local name = input:read("*l")
				homepos[name:sub(2)] = vector.new(x, y, z)
			until input:read(0) == nil
			io.close(input)
			local homedata = minetest.serialize(homepos)
			if not homedata then
				minetest.log("error", "[sethome] Failed to serialize old home data!")
				minetest.chat_send_player(name, "Something failed while serializing the old home data.")
				return false
			end
			local output, err = io.open(homes_file, "w")
			if err then
				minetest.log("error", "[sethome] Failed to open homes file: " .. err)
				minetest.chat_send_player(name, "Could not save to new homes files.")
				return false
			end
			output:write()
			io.close(output)
		end
	end
})
