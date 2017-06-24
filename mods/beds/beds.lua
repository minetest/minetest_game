-- Fancy shaped bed

beds.register_bed("beds:fancy_bed", {
	description = "Fancy Bed",
	inventory_image = "beds_bed_fancy.png",
	wield_image = "beds_bed_fancy.png",
	tiles = {
		bottom = {
			"beds_bed_top1.png",
			"default_wood.png",
			"beds_bed_side1.png",
			"beds_bed_side1.png^[transformFX",
			"default_wood.png",
			"beds_bed_foot.png",
		},
		top = {
			"beds_bed_top2.png",
			"default_wood.png",
			"beds_bed_side2.png",
			"beds_bed_side2.png^[transformFX",
			"beds_bed_head.png",
			"default_wood.png",
		}
	},
	nodebox = {
		bottom = {
			{-0.5, -0.5, -0.5, -0.375, -0.065, -0.4375},
			{0.375, -0.5, -0.5, 0.5, -0.065, -0.4375},
			{-0.5, -0.375, -0.5, 0.5, -0.125, -0.4375},
			{-0.5, -0.375, -0.5, -0.4375, -0.125, 0.5},
			{0.4375, -0.375, -0.5, 0.5, -0.125, 0.5},
			{-0.4375, -0.3125, -0.4375, 0.4375, -0.0625, 0.5},
		},
		top = {
			{-0.5, -0.5, 0.4375, -0.375, 0.1875, 0.5},
			{0.375, -0.5, 0.4375, 0.5, 0.1875, 0.5},
			{-0.5, 0, 0.4375, 0.5, 0.125, 0.5},
			{-0.5, -0.375, 0.4375, 0.5, -0.125, 0.5},
			{-0.5, -0.375, -0.5, -0.4375, -0.125, 0.5},
			{0.4375, -0.375, -0.5, 0.5, -0.125, 0.5},
			{-0.4375, -0.3125, -0.5, 0.4375, -0.0625, 0.4375},
		}
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
	recipe = {
		{"", "", "group:stick"},
		{"wool:red", "wool:red", "wool:white"},
		{"group:wood", "group:wood", "group:wood"},
	},
})

-- Simple shaped bed

beds.register_bed("beds:bed", {
	description = "Simple Bed",
	inventory_image = "beds_bed.png",
	wield_image = "beds_bed.png",
	tiles = {
		bottom = {
			"beds_bed_top_bottom.png^[transformR90",
			{name = "default_wood.png", color = "white"},
			{name = "beds_bed_side_bottom_r.png", color = "white"},
			{name = "beds_bed_side_bottom_r.png^[transformfx", color = "white"},
			"beds_transparent.png",
			{name = "beds_bed_side_bottom.png", color = "white"}
		},
		top = {
			{name = "beds_bed_top_top.png^[transformR90", color = "white"},
			{name = "default_wood.png", color = "white"},
			{name = "beds_bed_side_top_r.png", color = "white"},
			{name = "beds_bed_side_top_r.png^[transformfx", color = "white"},
			{name = "beds_bed_side_top.png", color = "white"},
			"beds_transparent.png",
		}
	},
	overlay_tiles = {
		bottom = {
			"",
			"",
			"beds_bed_side_bottom_o.png",
			"beds_bed_side_bottom_o.png^[transformfx",
			"",
			"beds_bed_side_bottom_o.png"
		},
		top = {
			"beds_bed_top_top_o.png^[transformR90",
			"",
			"beds_bed_side_top_r_o.png",
			"beds_bed_side_top_r_o.png^[transformfx",
			"",
			"",
		}
	},
	palette = "beds_palette.png",
	nodebox = {
		bottom = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
		top = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
	recipe = {
		{"group:wool", "group:wool", "wool:white"},
		{"group:wood", "group:wood", "group:wood"}
	},
})

-- Aliases for PilzAdam's beds mod

minetest.register_alias("beds:bed_bottom_red", "beds:bed_bottom")
minetest.register_alias("beds:bed_top_red", "beds:bed_top")

-- Fuel

minetest.register_craft({
	type = "fuel",
	recipe = "beds:fancy_bed_bottom",
	burntime = 13,
})

minetest.register_craft({
	type = "fuel",
	recipe = "beds:bed_bottom",
	burntime = 12,
})

-- colored Crafting

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name():sub(1, 5) ~= "beds:" then
		return
	end
	local colors = {red = 0, blue = 1, green = 2, yellow = 3, magenta = 4,
		cyan = 5, orange = 6, black = 7, brown = 7}
	local loc = old_craft_grid[3]:get_name() == "" and 3 or 0
	local color = colors[old_craft_grid[1+loc]:get_name():sub(6)]
	if color == nil or colors[old_craft_grid[2+loc]:get_name():sub(6)] ~= color then
		color = 7
	end
	itemstack:get_meta():set_string("palette_index", 2^5*color)
	return itemstack
end)
