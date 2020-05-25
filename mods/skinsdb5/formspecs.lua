local S = minetest.get_translator("skinsdb")

function skinsdb5.get_formspec_context(player)
	if player then
		local playername = player:get_player_name()
		skinsdb5.ui_context[playername] = skinsdb5.ui_context[playername] or {}
		return skinsdb5.ui_context[playername]
	else
		return {}
	end
end

-- Show skin info
function skinsdb5.get_skin_info_formspec(skin_name)
	local skin = player_api.registered_skins[skin_name]
	if not skin then
		return ""
	end
	local texture = skin.texture or (skin.textures and skin.textures[1])
	if not skin.preview and texture then
		skin.preview = skinsdb5.get_preview(texture, skin.format)
	end
	local formspec = ""
	if skin.preview then
		formspec = formspec.."image[0,.75;1,2;"..skin.preview.."]"
	end
	if texture then
		local raw_size = skin.format == "1.8" and "2,2" or "2,1"
		formspec = formspec.."label[6,.5;"..S("Raw texture")..":]image[6,1;"..raw_size..";"..texture.."]"
	end
	formspec = formspec.."label[2,.5;"..S("Name")..": "..minetest.formspec_escape(skin.description or skin.name).."]"
	if skin.author then
		formspec = formspec.."label[2,1;"..S("Author")..": "..minetest.formspec_escape(skin.author).."]"
	end
	if skin.license then
		formspec = formspec.."label[2,1.5;"..S("License")..": "..minetest.formspec_escape(skin.license).."]"
	end
	return formspec
end

function skinsdb5.get_skin_selection_formspec(player, context, y_delta)
	local skins_list = skinsdb5.get_skinlist_for_player(player:get_player_name())
	local current_skin = player_api.registered_skins[player_api.get_skin(player)]
	context.skins_list = {}
	context.total_pages = 1
	context.dropdown_values = nil

	for i, skin in ipairs(skins_list) do
		local page = math.floor((i-1) / 16)+1
		local page_index = (i-1)%16+1
		context.total_pages = page
		context.skins_list[i] = {
			name = skin.name,
			page = page,
			page_index = page_index
		}

		if not context.skins_page and skin.name == current_skin then
			context.skins_page = page
		end
	end

	context.skins_page = context.skins_page or 1
	local current_page = context.skins_page
	local formspec = ""
	for i = (current_page-1)*16+1, current_page*16 do
		local skin = skins_list[i]
		if not skin then
			break
		end

		if not skin.preview then
			local texture = skin.texture or (skin.textures and skin.textures[1])
			if texture then
				skin.preview = skinsdb5.get_preview(texture, skin.format)
			end
		end

		local index_p = context.skins_list[i].page_index
		local x = (index_p-1) % 8
		local y
		if index_p > 8 then
			y = y_delta + 1.9
		else
			y = y_delta
		end
		formspec = formspec.."image_button["..x..","..y..";1,2;"..
			(skin.preview or "")..";skins_set$"..i..";]"..
			"tooltip[skins_set$"..i..";"..minetest.formspec_escape(skin.description or skin.name).."]"
	end

	if context.total_pages > 1 then
		local page_prev = current_page - 1
		local page_next = current_page + 1
		if page_prev < 1 then
			page_prev = context.total_pages
		end
		if page_next > context.total_pages then
			page_next = 1
		end
		local page_list = ""
		context.dropdown_values = {}
		for pg=1, context.total_pages do
			local pagename = S("Page").." "..pg.."/"..context.total_pages
			context.dropdown_values[pagename] = pg
			if pg > 1 then page_list = page_list.."," end
			page_list = page_list..pagename
		end
		formspec = formspec
			.."button[0,"..(y_delta+4.0)..";1,.5;skins_page$"..page_prev..";<<]"
			.."dropdown[0.9,"..(y_delta+3.88)..";6.5,.5;skins_selpg;"..page_list..";"..context.skins_page.."]"
			.."button[7,"..(y_delta+4.0)..";1,.5;skins_page$"..page_next..";>>]"
	end
	return formspec
end

function skinsdb5.on_skin_selection_receive_fields(player, context, fields)
	for field, _ in pairs(fields) do
		local current = string.split(field, "$", 2)
		if current[1] == "skins_set" then
			player_api.set_skin(player, context.skins_list[tonumber(current[2])].name)
			return 'set'
		elseif current[1] == "skins_page" then
			context.skins_page = tonumber(current[2])
			return 'page'
		end
	end
	if fields.skins_selpg then
		context.skins_page = tonumber(context.dropdown_values[fields.skins_selpg])
		return 'page'
	end
end
