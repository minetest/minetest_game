local S = minetest.get_translator("mod_me")

-- Don't show the dialog if previously confirmed
if minetest.settings:get_bool("minetest_game.mod_me_dismissed", false) then
	return
end

local game_path = minetest.get_game_info().path

-- Exit if extra mods are installed
for _, name in ipairs(minetest.get_modnames()) do
	local mod_path = minetest.get_modpath(name)
	if mod_path:sub(1, #game_path) ~= game_path then
		return
	end
end

minetest.register_on_joinplayer(function(player)
	if not minetest.is_singleplayer() and player:get_player_name() ~= minetest.settings:get("name") then
		return
	end

	local markup = table.concat({
		"<big>", S("Minetest Game is meant to be modded"), "</big>\n",
		S("You've started a world with Minetest Game but you don't have any mods installed."), " ",
		S("Minetest Game is intentionally left bare so that you can mod it how you like."),
		"\n",
		S("We recommend going back to the Content tab in the main menu and finding some mods."), " ",
		S("If you don't want to have to choose mods, you can download another game from the same menu."),
		"\n"
	}, "")

	local fs = {
		"formspec_version[6]",
		"size[10.666,6]",
		"hypertext[0.375,0.375;9.916,4.14;ht;", minetest.formspec_escape(markup), "]",
		"button_exit[0.375,4.765;4,0.86;back;", S("Exit to Menu"), "]",
		"button_exit[6.291,4.765;4,0.86;okay;", S("Continue"), "]",
	}

	minetest.show_formspec(player:get_player_name(), "mod_me:alert", table.concat(fs, ""))
end)


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mod_me:alert" then
		return false
	end

	if fields.back then
		minetest.request_shutdown("Exiting to main menu")
		return true
	end

	if fields.okay then
		minetest.settings:set_bool("minetest_game.mod_me_dismissed", true)
		return true
	end
end)
