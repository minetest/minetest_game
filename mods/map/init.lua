-- Mod global namespace

map = {}


-- Cache creative mode setting

local creative_mode_cache = minetest.settings:get_bool("creative_mode")


-- Update HUD flags
-- Global to allow overriding

function map.update_hud_flags(player)
	local creative_enabled =
		(creative and creative.is_enabled_for(player:get_player_name())) or
		creative_mode_cache

	local minimap_enabled = creative_enabled or
		player:get_inventory():contains_item("main", "map:mapping_kit")
	local radar_enabled = creative_enabled

	player:hud_set_flags({
		minimap = minimap_enabled,
		minimap_radar = radar_enabled
	})
end


-- Set HUD flags 'on joinplayer'

minetest.register_on_joinplayer(function(player)
	map.update_hud_flags(player)
end)


-- Cyclic update of HUD flags

local function cyclic_update()
	for _, player in ipairs(minetest.get_connected_players()) do
		map.update_hud_flags(player)
	end
	minetest.after(5.3, cyclic_update)
end

minetest.after(5.3, cyclic_update)


-- Mapping kit item

minetest.register_craftitem("map:mapping_kit", {
	description = "Mapping Kit\nUse with 'Minimap' key",
	inventory_image = "map_mapping_kit.png",
	stack_max = 1,
	groups = {flammable = 3},

	on_use = function(itemstack, user, pointed_thing)
		map.update_hud_flags(user)
	end,
})


-- Crafting

minetest.register_craft({
	output = "map:mapping_kit",
	recipe = {
		{"default:glass", "default:paper", "default:stick"},
		{"default:steel_ingot", "default:paper", "default:steel_ingot"},
		{"group:wood", "default:paper", "dye:black"},
	}
})


-- Fuel

minetest.register_craft({
	type = "fuel",
	recipe = "map:mapping_kit",
	burntime = 5,
})
