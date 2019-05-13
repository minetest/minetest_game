-- binoculars/init.lua

-- Mod global namespace

binoculars = {}

-- Load support for MT game translation.
local S = minetest.get_translator()


-- Detect creative mod
local creative_mod = minetest.get_modpath("creative")
-- Cache creative mode setting as fallback if creative mod not present
local creative_mode_cache = minetest.settings:get_bool("creative_mode")


-- Update player property
-- Global to allow overriding

function binoculars.update_player_property(player)
	local creative_enabled =
		(creative_mod and creative.is_enabled_for(player:get_player_name())) or
		creative_mode_cache
	local new_zoom_fov = 0

	if player:get_inventory():contains_item(
			"main", "binoculars:binoculars") then
		new_zoom_fov = 10
	elseif creative_enabled then
		new_zoom_fov = 15
	end

	-- Only set property if necessary to avoid player mesh reload
	if player:get_properties().zoom_fov ~= new_zoom_fov then
		player:set_properties({zoom_fov = new_zoom_fov})
	end
end


-- Set player property 'on joinplayer'

minetest.register_on_joinplayer(function(player)
	binoculars.update_player_property(player)
end)


-- Cyclic update of player property

local function cyclic_update()
	for _, player in ipairs(minetest.get_connected_players()) do
		binoculars.update_player_property(player)
	end
	minetest.after(4.7, cyclic_update)
end

minetest.after(4.7, cyclic_update)


-- Binoculars item

minetest.register_craftitem("binoculars:binoculars", {
	description = S("Binoculars\nUse with 'Zoom' key"),
	inventory_image = "binoculars_binoculars.png",
	stack_max = 1,

	on_use = function(itemstack, user, pointed_thing)
		binoculars.update_player_property(user)
	end,
})


-- Crafting

minetest.register_craft({
	output = "binoculars:binoculars",
	recipe = {
		{"default:obsidian_glass", "", "default:obsidian_glass"},
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
		{"default:obsidian_glass", "", "default:obsidian_glass"},
	}
})
