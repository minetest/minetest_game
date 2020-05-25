local S = minetest.get_translator("skinsdb")

local function show_selection_formspec(player)
	local context = skinsdb5.get_formspec_context(player)
	local name = player:get_player_name()
	local skin = player_api.get_skin(player)
	local formspec = "size[8,8]"..skinsdb5.get_skin_info_formspec(skin)
	formspec = formspec..skinsdb5.get_skin_selection_formspec(player, context, 3.5)
	minetest.show_formspec(name, 'skinsdb_show_ui', formspec)
end


minetest.register_chatcommand("skinsdb", {
	params = "[set] <skin key> | show [<skin key>] | list | list private | list public | [ui]",
	description = S("Show, list or set player's skin"),
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("Player not found")
		end

		-- parse command line
		local command, parameter
		local words = param:split(" ")
		local word = words[1]
		if word == 'set' or word == 'list' or word == 'show' or word == 'ui' then
			command = word
			parameter = words[2]
		elseif player_api.registered_skins[word] then
			command = 'set'
			parameter = word
		elseif not word then
			command = 'ui'
		else
			return false, S("unknown command").." "..word..", "..S("see /help skinsdb for supported parameters")
		end

		if command == "set" then
			if parameter then
				if player_api.registered_skins[parameter] then
					player_api.set_skin(player, parameter)
					return true, S("skin set to").." "..parameter
				else
					return false, S("invalid skin").." "..parameter
				end
			else
				return false, S("requires skin key")
			end
		elseif command == "list" then
			local list
			if parameter == "private" then
				list = skinsdb5.get_skinlist_with_meta("playername", name)
			elseif parameter == "public" then
				list = skinsdb5.get_skinlist_for_player()
			elseif not parameter then
				list = skinsdb5.get_skinlist_for_player(name)
			else
				return false, S("unknown parameter"), parameter
			end

			local current_skin_key = player_api.get_skin(player)
			for _, skin in ipairs(list) do
				local info = skin.name.." - "
						..S("Name").."="..(skin.description or skin.name or "").." "
						..S("Author").."="..(skin.author or "").." "
						..S("License").."="..(skin.license or "")
				if skin.name == current_skin_key then
					info = minetest.colorize("#00FFFF", info)
				end
				minetest.chat_send_player(name, info)
			end
		elseif command == "show" then
			local skin
			if parameter then
				skin = parameter
			else
				skin = player_api.get_skin(player)
			end
			if not skin then
				return false, S("invalid skin")
			end
			local formspec = "size[8,3]"..skinsdb5.get_skin_info_formspec(skin)
			minetest.show_formspec(name, 'skinsdb_show_skin', formspec)
		elseif command == "ui" then
			show_selection_formspec(player)
		end
	end,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "skinsdb_show_ui" then
		return
	end

	local context = skinsdb5.get_formspec_context(player)

	local action = skinsdb5.on_skin_selection_receive_fields(player, context, fields)
	if action == 'set' then
		minetest.close_formspec(player:get_player_name(), formname)
	elseif action == 'page' then
		show_selection_formspec(player)
	end
end)
