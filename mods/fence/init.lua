-- Minetest 0.4 mod: fence
-- See README.txt for licensing and other information.

fence = {}
function fence.register_fence(name, texture, desc, craftitem, craftoutput, groups, sounds)
	local fence_texture = texture .. "^fence_overlay.png^[makealpha:255,126,126"
	minetest.register_node(":fence:" .. name, {
		description = desc,
		drawtype = "fencelike",
		tiles = {texture},
		inventory_image = fence_texture,
		wield_image = fence_texture,
		paramtype = "light",
		is_ground_content = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
		},
		groups = groups,
		sounds = sounds,
	})
	minetest.register_craft({
		output = 'fence:' .. name .. ' ' .. craftoutput,
		recipe = {
			{craftitem, craftitem, craftitem},
			{craftitem, craftitem, craftitem},
		}
	})
end


fence.register_fence("wood", "default_wood.png", "Wooden Fence", "group:stick", 2,
		{choppy=2, oddly_breakable_by_hand=2, flammable=2}, default.node_sound_wood_defaults())
fence.register_fence("cobble", "default_cobble.png", "Cobblestone Fence", "default:cobble", 4,
		{cracky=3, stone=2}, default.node_sound_stone_defaults())
fence.register_fence("desert_cobble", "default_desert_cobble.png", "Desert Cobblestone Fence", "default:desert_cobble", 4,
		{cracky=3, stone=2}, default.node_sound_stone_defaults())
fence.register_fence("sandstone", "default_sandstone.png", "Sandstone Fence", "default:sandstone", 4,
		{crumbly=2, cracky=3}, default.node_sound_stone_defaults())
fence.register_fence("stonebrick", "default_stone_brick.png", "Stone Brick Fence", "default:stonebrick", 4,
		{cracky=2, stone=1}, default.node_sound_stone_defaults())
fence.register_fence("sandstonebrick", "default_sandstone_brick.png", "Sandstone Brick Fence", "default:sandstonebrick", 4,
		{cracky=2}, default.node_sound_stone_defaults())
fence.register_fence("desert_stonebrick", "default_desert_stone_brick.png", "Desert Stone Brick Fence", "default:desert_stonebrick", 4,
		{cracky=2, stone=1}, default.node_sound_stone_defaults())


minetest.register_craft({
	type = "fuel",
	recipe = "fence:wood",
	burntime = 15,
})

minetest.register_alias("default:fence_wood", "fence:wood")

