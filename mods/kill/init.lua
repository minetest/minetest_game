kill = {}

function kill.kill(player)
	if player then
		if minetest.setting_getbool("enable_damage") then
			player:set_hp(0)
			return true
		else
			for _, callback in pairs(core.registered_on_respawnplayers) do
				if callback(player) then
					return true
				end
			end

			-- There doesn't seem to be a way to get a default spawn pos from the lua API
			return false, "No static_spawnpoint defined"
		end
	else
		-- Show error message if used when not logged in, eg: from IRC mod
		return false, "You need to be online to be killed!"
	end
end

local function aliases(name, from)
	if minetest.chatcommands[from] then
		minetest.register_chatcommand(name, minetest.chatcommands[from])
	end
end

minetest.register_chatcommand("suicide", {
	description = "Kill yourself to respawn",
	func = function(name)
		return kill.kill(minetest.get_player_by_name(name))
	end
})

minetest.register_privilege("kill", {description = "Can kill the players", give_to_singleplayer = false})
minetest.register_chatcommand("kill", {
	params = "<name>",
	description = "Kill a player",
	privs = {kill = true},
	func = function(name, param)
		return kill.kill(minetest.get_player_by_name(param))
	end
})

aliases("killme", "suicide")
