-- Skin selection page

local skins_formspec_main = function(name, context)
	local formspec = "label[0.0,1.5;" .. "Select Player Skin:" .. "]"
		.. "textlist[0.0,2.0;5.8,6.7;skins_set;"

	local skins_list = {}
	context.skins_list = skins_list
	for _, skin in pairs(player_api.registered_skins) do
		if skin.in_inventory_list ~= false and
				(not skin.playername or (name and skin.playername:lower() == name:lower())) then
			table.insert(skins_list, skin)
		end
	end
	table.sort(skins_list, function(a,b) return tostring(a.sort_id or a.description or a.name or "") <
			tostring(b.sort_id or b.description or b.name or "") end)

	local current_skin_name = player_api.get_skin(minetest.get_player_by_name(name))
	local selected_skin = player_api.registered_skins[current_skin_name]
	local selected = 1
	for i = 1, #skins_list do
		local skin = skins_list[i]
		formspec = formspec .. (skin.description or skin.name)
		if i < #skins_list then
			formspec = formspec .. ","
		end
		if skin.name == current_skin_name then
			selected = i
		end
	end
	formspec = formspec .. ";" .. selected .. ";false]"
	if selected_skin then
		if selected_skin.description then
			formspec = formspec .. "label[0.0,0.0;" .. "Current skin: " .. selected_skin.description .. "]"
		end
		if selected_skin.author then
			formspec = formspec .. "label[0.0,0.5;" .. "Author: " .. selected_skin.author .. "]"
		end
		if selected_skin.license then
			formspec = formspec .. "label[0.0,1;" .. "License: " .. selected_skin.license .. "]"
		end
	end
	return formspec
end


-- Register sfinv tab
local formspec_size_and_pos = table.concat({
	"size[6.0,8.6]",
	"position[0.05,0.5]",
	"anchor[0.0,0.5]",
	"bgcolor[#00000000;false]",
	"background[5,5;1,1;gui_formbg.png;true]"
},"")

sfinv.register_page("skins:skins", {
	title = "Skins",
	get = function(self, player, context)
		local name = player:get_player_name()
		return sfinv.make_formspec(player, context, skins_formspec_main(name, context),
			false, formspec_size_and_pos)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		local event = minetest.explode_textlist_event(fields["skins_set"])
		if event.type == "CHG" then
			local selected_skin = context.skins_list[event.index]
			if selected_skin then
				player_api.set_skin(player, selected_skin.name)
			end
		end
	end,
})

player_api.register_on_skin_change(function(player, model_name, skin_name)
	if sfinv.enabled then
		sfinv.set_player_inventory_formspec(player)
	end
end)


player_api.read_textures_and_meta()
