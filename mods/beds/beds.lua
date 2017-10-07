-- Fancy shaped bed

beds.register_bed("beds:fancy_bed", {
	description = "Fancy Bed",
	inventory_image = "beds_bed_fancy.png^beds_bed_fancy_o.png",
	wield_image = "beds_bed_fancy.png^beds_bed_fancy_o.png",
	tiles = {
		bottom = {
			"beds_wool.png^[transformR90",
			{name = "default_wood.png", color = "white"},
			"beds_wool.png",
			"beds_wool.png^[transformFX",
			{name = "default_wood.png", color = "white"},
			"beds_wool.png^[transformR90",
		},
		top = {
			"beds_wool.png^[transformR270",
			{name = "default_wood.png", color = "white"},
			"beds_wool.png",
			"beds_wool.png^[transformFX",
			{name = "beds_bed_head.png", color = "white"},
			{name = "default_wood.png", color = "white"},
		}
	},
	overlay_tiles = {
		bottom = {
			{name = "beds_bed_top.png", color = "white"},
			"",
			{name = "beds_bed_side1.png", color = "white"},
			{name = "beds_bed_side1.png^[transformFX", color = "white"},
			"",
			{name = "beds_bed_foot.png", color = "white"},
		},
		top = {
			{name = "beds_bed_top_top.png^[transformR270^beds_bed_top.png^[transformR180", color = "white"},
			"",
			{name = "beds_bed_side2.png", color = "white"},
			{name = "beds_bed_side2.png^[transformFX", color = "white"},
			"",
			"",
		}
	},
	color = "#A90000", -- First color on palette.
	palette = "beds_palette.png",
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
})

-- Simple shaped bed

beds.register_bed("beds:bed", {
	description = "Simple Bed",
	inventory_image = "beds_bed.png^beds_bed_o.png",
	wield_image = "beds_bed.png^beds_bed_o.png",
	tiles = {
		bottom = {
			"beds_wool.png^[transformR90",
			{name = "default_wood.png", color = "white"},
			"beds_wool.png",
			"beds_wool.png^[transformFX",
			"blank.png",
			"beds_wool.png^[transformR90"
		},
		top = {
			"beds_wool.png^[transformR270",
			{name = "default_wood.png", color = "white"},
			"beds_wool.png",
			"beds_wool.png^[transformFX",
			{name = "beds_bed_side_top.png^[transformFX", color = "white"},
			"blank.png",
		}
	},
	overlay_tiles = {
		bottom = {
			"",
			"",
			{name = "beds_bed_side_bottom_r.png", color = "white"},
			{name = "beds_bed_side_bottom_r.png^[transformFX", color = "white"},
			"",
			{name = "beds_bed_side_bottom.png", color = "white"}
		},
		top = {
			{name = "beds_bed_top_top.png^[transformR90", color = "white"},
			"",
			{name = "beds_bed_side_top_r.png", color = "white"},
			{name = "beds_bed_side_top_r.png^[transformFX", color = "white"},
			"",
			"",
		}
	},
	color = "#A90000", -- First color on palette.
	palette = "beds_palette.png",
	nodebox = {
		bottom = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
		top = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
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

local colors = {
	red = 0,
	blue = 1, cyan = 1,
	green = 2, dark_green = 2,
	yellow = 3,
	magenta = 4, violet = 4, pink = 4,
	white = 5,
	orange = 6, brown = 6,
	black = 7, dark_grey = 7, grey = 7
}

for color, palette_index in pairs(colors) do
	palette_index = palette_index*2^5
	local out = ItemStack("beds:fancy_bed")
	out:get_meta():set_int("palette_index", palette_index)
	minetest.register_craft({
		output = out:to_string(),
		recipe = {
			{"",             "",             "group:stick"},
			{"wool:"..color, "wool:"..color, "wool:white"},
			{"group:wood",   "group:wood",   "group:wood"}
		},
	})
end

for color, palette_index in pairs(colors) do
	palette_index = palette_index*2^5
	local out = ItemStack("beds:bed")
	out:get_meta():set_int("palette_index", palette_index)
	minetest.register_craft({
		output = out:to_string(),
		recipe = {
			{"wool:"..color, "wool:"..color, "wool:white"},
			{"group:wood",   "group:wood",   "group:wood"}
		},
	})
end
