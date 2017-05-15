
config = {}

config.settings = {}
config.setting_definitions = {}

local storage = Settings(minetest.get_worldpath() .. "/world.conf")
assert(storage)
local needs_restart = false

function config.register_setting(name, data)
	if data.type ~= "bool" and data.type ~= "text" then
		error("Setting type must be \"bool\", \"text\" or \"number\"")
	end
	data = table.copy(data)
	data.name = name
	config.settings[#config.settings+1] = data
	config.setting_definitions[name] = data
	if storage:get(name) == nil then
		config.setting_set(name, data.default_value)
	end
end

function config.setting_get(name)
	local setting = config.setting_definitions[name]
	if not setting then
		return
	end
	if setting.type == "bool" then
		return storage:get_bool(name)
	elseif setting.type == "text" then
		return storage:get(name)
	elseif setting.type == "number" then
		return tonumber(storage:get(name)) or setting.default_value
	end
end

function config.setting_set(name, value)
	local setting = config.setting_definitions[name]
	if not setting then
		return
	end
	if setting.type == "bool" then
		if value then
			storage:set(name, "true")
		else
			storage:set(name, "false")
		end
	elseif setting.type == "text" then
		storage:set(name, value)
	elseif setting.type == "number" then
		storage:set(name, tostring(value))
	end
	storage:write()
end

local pages_cache = nil
local num_pages = nil
local setting_max_y = 7.6
local function get_setting_page(i)
	if pages_cache ~= nil then
		return pages_cache[i]
	end
	pages_cache = {{}}
	local page = 1
	local y = 0
	local index = 1
	for j, setting in ipairs(config.settings) do
		local height = 1.2
		if setting.type == "bool" then
			height = 0.5
		end
		if height + y > setting_max_y then
			page = page + 1
			y = 0
			index = 1
			pages_cache[page] = {}
		end
		y = y + height
		pages_cache[page][index] = j
		index = index + 1
	end
	num_pages = #pages_cache
	return pages_cache[i]
end

local function get_num_pages()
	if pages_cache == nil then
		get_setting_page(1)
	end
	return num_pages
end

sfinv.register_page("config:config", {
	title = "Configuration",
	is_in_nav = function(self, player, context)
		return minetest.check_player_privs(player, "server") and
			not minetest.is_singleplayer() and
			config.settings[1] ~= nil -- Don't show if there is nothing to configure
	end,
	get = function(self, player, context)
		local page_id = context.page_num or 1
		local form =
			"label[6.2,8.35;" .. minetest.colorize("#FFFF00", tostring(page_id)) ..
			" / " .. tostring(get_num_pages()) .. "]"
		-- This needs to be before the buttons or it might overlap with them
		if needs_restart then
			form = form .. "label[0.1,7.9;" ..
				minetest.colorize("orange",
				                  "Warning: some changes you made")
				.. "]"
			form = form .. "label[0.1,8.3;" ..
				minetest.colorize("orange",
				                  "might require a server restart.")
				.. "]"
		end
		form = form ..
			[[
				button[5.4,8.2;0.8,0.9;config_prev;<]
				button[7.25,8.2;0.8,0.9;config_next;>]
			]]
		local y = 0
		for _, i in ipairs(get_setting_page(page_id)) do
			local setting = config.settings[i]
			local current_value = config.setting_get(setting.name)
			if setting.type == "bool" then
				form = form .. "checkbox[0," .. y .. ";" ..
					tostring(i) .. ";" .. setting.description .. ";" ..
					tostring(current_value) .. "]"
				y = y + 0.5
			elseif setting.type == "text" then
				form = form .. "field[0.3," .. (y + 0.8) .. ";5,1;" ..
					tostring(i) .. ";" .. setting.description .. ";" ..
					minetest.formspec_escape(current_value) .. "]" ..
					"field_close_on_enter[" .. tostring(i) .. ";false]"
				y = y + 1.2
			elseif setting.type == "number" then
				form = form .. "field[0.3," .. (y + 0.8) .. ";5,1;" ..
					tostring(i) .. ";" .. setting.description .. ";" ..
					tostring(current_value) .. "]" ..
					"field_close_on_enter[" .. tostring(i) .. ";false]"
				y = y + 1.2
			end
		end
		if default then
			form = form .. default.gui_bg .. default.gui_bg_img
		end
		return sfinv.make_formspec(player, context, form, false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if not minetest.check_player_privs(player, "server") then
			return
		end

		local update = false

		if fields.config_next then
			context.page_num = (context.page_num or 1) + 1
			if context.page_num > get_num_pages() then
				context.page_num = 1
			end
			update = true
		end

		if fields.config_prev then
			context.page_num = (context.page_num or 1) - 1
			if context.page_num < 1 then
				context.page_num = get_num_pages()
			end
			update = true
		end

		for index, value in pairs(fields) do
			local i = tonumber(index)
			if i ~= nil then
				local setting = config.settings[i]
				if setting.type == "bool" then
					value = (value == "true")
				elseif setting.type == "number" then
					value = tonumber(value)
				end
				if value ~= nil then
					config.setting_set(setting.name, value)
					if not setting.on_change and not needs_restart then
						needs_restart = true
						-- Redisplay the page
						update = true
					end
					if setting.on_change then
						setting.on_change(value)
					end
				end
			end
		end

		if update then
			sfinv.set_page(player, "config:config")
		end
	end,
})
