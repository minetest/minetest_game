default.config = Settings(minetest.get_worldpath().."/default.conf")

local conf_table = default.config:to_table()

local defaults = {
}

for k, v in pairs(defaults) do
	if conf_table[k] == nil then
		if minetest.setting_get(k) ~= nil then
			default.config:set(k, minetest.setting_get(k))
		else
			default.config:set(k, v)
		end
	end
end
