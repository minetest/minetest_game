local S = minetest.get_translator("skinsdb")

-- generate the current formspec
local function get_formspec(player, context)
	local skin = player_api.get_skin(player)
	local formspec = skinsdb5.get_skin_info_formspec(skin)
	formspec = formspec..skinsdb5.get_skin_selection_formspec(player, context, 4)
	return formspec
end

sfinv.register_page("skinsdb5:overview", {
	title = S("Skins"),
	get = function(self, player, context)
		-- collect skins data
		return sfinv.make_formspec(player, context, get_formspec(player, context))
	end,
	on_player_receive_fields = function(self, player, context, fields)
		local action = skinsdb5.on_skin_selection_receive_fields(player, context, fields)
		if action == "page" then
			sfinv.set_player_inventory_formspec(player)
		end
	end
})

player_api.register_on_skin_change(function(player, model_name, skin_name)
	if sfinv.enabled then
		sfinv.set_player_inventory_formspec(player)
	end
end)
