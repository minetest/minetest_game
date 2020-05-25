local S = minetest.get_translator("skinsdb")

unified_inventory.register_page("skins", {
	get_formspec = function(player)
		local skin = player_api.get_skin(player)
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"..skinsdb5.get_skin_info_formspec(skin)..
				"button[.75,3;6.5,.5;skins_page;"..S("Change").."]"
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("skins", {
	type = "image",
	image = "skins_button.png",
	tooltip = S("Skins"),
})

local function get_formspec(player)
	local context = skinsdb5.get_formspec_context(player)
	local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"..
			skinsdb5.get_skin_selection_formspec(player, context, -0.2)
	return formspec
end

unified_inventory.register_page("skins_page", {
	get_formspec = function(player)
		return {formspec=get_formspec(player)}
	end
})

-- click button handlers
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.skins then
		unified_inventory.set_inventory_formspec(player, "craft")
		return
	end

	if formname ~= "" then
		return
	end

	local context = skinsdb5.get_formspec_context(player)
	local action = skinsdb5.on_skin_selection_receive_fields(player, context, fields)
	if action == "set" then
		unified_inventory.set_inventory_formspec(player, "skins")
	elseif action == "page" then
		unified_inventory.set_inventory_formspec(player, "skins_page")
	end
end)

player_api.register_on_skin_change(function(player, model_name, skin_name)
	local player_name = player:get_player_name()
	-- refresh skins page if selected
	if unified_inventory.current_page[player_name] == "skins" then
		unified_inventory.set_inventory_formspec(player, "skins")
	end
end)
