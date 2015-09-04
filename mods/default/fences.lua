--
-- Fences
--
--[[

   default:fence_wood
   default:fence_acacia_wood
   default:fence_junglewood
   default:fence_pine_wood

]]

function default.register_fence(name, desc, groups, sounds)
	if groups then
		groups.fence = 1
	end
	local texture_name = minetest.registered_items["default:" .. name].tiles[1]
	local fence_texture =
		"default_fence_overlay.png^" .. texture_name .. "^default_fence_overlay.png" ..
		"^[makealpha:255,126,126"
	minetest.register_node("default:fence_" .. name, {
		description = desc,
		drawtype = "fencelike",
		tiles = {"default_" .. name .. ".png"},
		inventory_image = fence_texture,
		wield_image = fence_texture,
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
		},
		groups = groups,
		sounds = sounds,
	})

	minetest.register_craft({
		output = "default:fence_" .. name .. " 2",
		recipe = {
			{"default:" .. name, "default:stick", "default:" .. name},
			{"default:" .. name, "default:stick", "default:" .. name},
		}
	})
end

default.register_fence("wood", "Wooden Fence",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	default.node_sound_wood_defaults())

default.register_fence("acacia_wood", "Acacia Wood Fence",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	default.node_sound_wood_defaults())

default.register_fence("junglewood", "Jungle Wood Fence",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	default.node_sound_wood_defaults())

default.register_fence("pine_wood", "Pine Wood Fence",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	default.node_sound_wood_defaults())

