-- Mod global namespace

binoculars = {}


-- Cache creative mode setting

local creative_mode_cache = minetest.settings:get_bool("creative_mode")


-- Update player property
-- Global to allow overriding

function binoculars.update_player_property(player)
	local creative_enabled =
		(creative and creative.is_enabled_for(player:get_player_name())) or
		creative_mode_cache

	if creative_enabled or
			player:get_inventory():contains_item("main", "binoculars:binoculars") then
		player:set_properties({can_zoom = true})
	else
		player:set_properties({can_zoom = false})
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
	description = "Binoculars\nUse with 'Zoom' key",
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
