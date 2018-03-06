local skins_skins = {}
local skins_modpath = minetest.get_modpath("skins")
local skins_list = {}


-- Local custom make_formspec function

local function make_formspec(player, context, content, show_inv, size)
	local tmp = {
		size,
		"bgcolor[#00000000;false]" .. "background[5,5;1,1;gui_formbg.png;true]",
		sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
		content
	}
	return table.concat(tmp, "")
end


-- Load player-selectable skin list
-- Non-player-selectable skins only settable by admin should be separated by 100

local id = 1
local gap = 0
local num = 0

while true do
	local f = io.open(skins_modpath .. "/textures/character_" .. id .. ".png")
	if not f then
		gap = gap + 1
		if gap > 100 then
			break
		end
	else
		gap = 0
	end

	if f then
		f:close()
		table.insert(skins_list, "character_" .. id)
		num = num + 1
	end
	id = id + 1
end


-- Load Metadata

local skins_meta = {}

for _, skin in pairs(skins_list) do
	skins_meta[skin] = {}
	local f = io.open(skins_modpath .. "/meta/" .. skin .. ".txt")
	local data = nil
	if f then
		data = minetest.deserialize("return {" .. f:read('*all') .. "}")
		f:close()
	end
	data = data or {}
	skins_meta[skin].name = data.name or skin
	skins_meta[skin].author = data.author or ""
end


-- Skin selection page

local skins_formspec_main = function(name)
	local formspec = "label[0.0,1.5;" .. "Select Player Skin:" .. "]"
		.. "textlist[0.0,2.0;5.8,6.7;skins_set;"
	local meta
	local selected = 1
	for i = 1, #skins_list do
		formspec = formspec .. skins_meta[skins_list[i]].name
		if i < #skins_list then
			formspec = formspec .. ","
		end
		if skins_skins[name] == skins_list[i] then
			selected = i
			meta = skins_meta[skins_skins[name]]
		end
	end
	formspec = formspec .. ";" .. selected .. ";false]"
	if meta then
		if meta.name then
			formspec = formspec .. "label[0.0,0.0;" .. "Name: " .. meta.name .. "]"
		end
		if meta.author then
			formspec = formspec .. "label[0.0,0.5;" .. "Author: " .. meta.author .. "]"
		end
	end
	return formspec
end


-- Update player skin

local skins_update_player_skin = function(player)
	if not player then
		return
	end

	local name = player:get_player_name()
	player:set_properties({
		textures = {skins_skins[name] .. ".png"},
	})
	player:set_attribute("skins:skin", skins_skins[name])
end


-- Register sfinv tab

sfinv.register_page("skins:skins", {
	title = "Skins",
	get = function(self, player, context)
		local name = player:get_player_name()
		return make_formspec(player, context, skins_formspec_main(name),
			false, "size[6.0,8.6]position[0.05,0.5]anchor[0.0,0.5]")
	end,
	on_player_receive_fields = function(self, player, context, fields)
		local event = minetest.explode_textlist_event(fields["skins_set"])

		if event.type == "CHG" then
			local index = event.index
			if index > num then
				index = num
			end
			local name = player:get_player_name()
			skins_skins[name] = skins_list[index]
			skins_update_player_skin(player)

			sfinv.override_page("skins:skins", {
				get = function(...)
					return make_formspec(player, context,
						skins_formspec_main(name), false,
						"size[6.0,8.6]position[0.05,0.5]anchor[0.0,0.5]")
				end,
			})

			sfinv.set_player_inventory_formspec(player)
		end
	end,
})


-- Load player skin on player join

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	-- Do we already have a skin in player attributes?
	local skin = player:get_attribute("skins:skin")
	if skin then
		skins_skins[name] = skin
	end
	-- If no skin found use default
	if not skins_skins[name] then
		skins_skins[name] = "character_1"
	end
	skins_update_player_skin(player)
end)


-- Admin command to set player skin (usually for custom skins)
-- Example:
-- /setskin paramat 3

minetest.register_chatcommand("setskin", {
	params = "<player name> <skin number>",
	description = "Admin command to set player skin",
	privs = {server = true},
	func = function(name, param)
		if not param or param == "" then
			return
		end

		local playername, skinnum = string.match(param, "([^ ]+) (-?%d+)")
		if not playername or not skinnum then
			return
		end

		local player = minetest.get_player_by_name(playername)
		if player then
			skins_skins[playername] = "character_" .. tonumber(skinnum)
			player:set_attribute("skins:skin", skins_skins[playername])
			player:set_properties({
				textures = {skins_skins[playername] .. ".png"},
			})
			-- To admin
			minetest.chat_send_player(name,
				playername .. "'s skin set to character_" .. skinnum)
			-- To player
			minetest.chat_send_player(playername,
				"Your skin has been set to character_" .. skinnum)
		else
			-- To admin
			minetest.chat_send_player(name, playername .. " not on server")
		end
	end,
})
