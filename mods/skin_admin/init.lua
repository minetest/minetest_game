minetest.register_chatcommand("skinadm", {
	params = "list | set <playername> <skin key>",
	description = "Set skin for a player on server",
	privs = {server = true},
	func = function(name, param)
		-- parse command line
		local words = param:split(" ")
		local command = words[1]
		if command == "list" then
			local list_sorted = {}
			for _, skin in pairs(player_api.registered_skins) do
				table.insert(list_sorted, skin)
			end
			table.sort(list_sorted, function(a,b) return tostring(a.sort_id or a.name or "") <
					tostring(b.sort_id or b.name or "") end)
			for _, skin in ipairs(list_sorted) do
				minetest.chat_send_player(name, skin.name..'\t'..(skin.description or "")..
						(skin.in_inventory_list and " (hidden)" or "")..
						(skin.playername and " (private by "..skin.playername..")" or ""))
			end
		elseif command == "set" then
			local playername = words[2]
			local selected_skin = words[3]
			if not playername or not selected_skin then
				return false, "skin set requires player and skin key"
			end
			local player = minetest.get_player_by_name(playername)
			if not player then
				return false, "player "..playername.." unknown or offline"
			end
			if not player_api.registered_skins[selected_skin] then
				return false, "invalid skin "..selected_skin..". try /skinadm list"
			end
			player_api.set_skin(player, selected_skin)
		else
			return false, "parameter required. see /help skinadm"
		end
	end
})
