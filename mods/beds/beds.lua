-- Fancy shaped bed

for key, value in pairs(dye.dyes) do
	local color = key
	local colorDisplayName = value.name
	local htmlColor = value.html.."80"

	beds.register_bed("beds:fancy_bed"..color, {
		description = colorDisplayName.." Fancy Bed",
		inventory_image = "beds_bed_fancy.png^(beds_bed_fancy_overlay.png^[colorize:"..htmlColor..")",
		wield_image = "beds_bed_fancy.png^(beds_bed_fancy_overlay.png^[colorize:"..htmlColor..")",
		tiles = {
			bottom = {
				"beds_bed_top1.png^(beds_bed_top1_overlay.png^[colorize:"..htmlColor..")",
				"default_wood.png",
				"beds_bed_side1.png^(beds_bed_side1_overlay.png^[colorize:"..htmlColor..")",
				"(beds_bed_side1.png^[transformFX)^((beds_bed_side1_overlay.png^[transformFX)^[colorize:"..htmlColor..")",
				"default_wood.png",
				"beds_bed_foot.png^(beds_bed_foot_overlay.png^[colorize:"..htmlColor..")",
			},
			top = {
				"beds_bed_top2.png^(beds_bed_top2_overlay.png^[colorize:"..htmlColor..")",
				"default_wood.png",
				"beds_bed_side2.png^(beds_bed_side2_overlay.png^[colorize:"..htmlColor..")",
				"(beds_bed_side2.png^[transformFX)^((beds_bed_side2_overlay.png^[transformFX)^[colorize:"..htmlColor..")",
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

	-- Make the bed function as fuel.
	minetest.register_craft({
		type = "fuel",
		recipe = "beds:fancy_bed_bottom",
		burntime = 13,
	})

	-- Simple shaped bed.
	-- These bed names should directly swappable from PilzAdam's beds.

	beds.register_bed("beds:bed"..color, {
		description = colorDisplayName.." Bed",
		inventory_image = "beds_bed.png^(beds_bed_overlay.png^[colorize:"..htmlColor..")",
		wield_image = "beds_bed.png^(beds_bed_overlay.png^[colorize:"..htmlColor..")",
		tiles = {
			bottom = {
				"(beds_bed_top_bottom.png^[transformR90)^((beds_bed_top_bottom_overlay.png^[transformR90)^[colorize:"..htmlColor..")",
				"default_wood.png",
				"(beds_bed_side_bottom_r.png)^(beds_bed_side_bottom_r_overlay.png^[colorize:"..htmlColor..")",
				"(beds_bed_side_bottom_r.png^[transformfx)^((beds_bed_side_bottom_r_overlay.png^[transformfx)^[colorize:"..htmlColor..")",
				"beds_transparent.png",
				"(beds_bed_side_bottom.png)^(beds_bed_side_bottom_overlay.png^[colorize:"..htmlColor..")"
			},
			top = {
				"(beds_bed_top_top.png^[transformR90)^((beds_bed_top_top_overlay.png^[transformR90)^[colorize:"..htmlColor..")",
				"default_wood.png",
				"(beds_bed_side_top_r.png)^(beds_bed_side_top_r_overlay.png^[colorize:"..htmlColor..")",
				"(beds_bed_side_top_r.png^[transformfx)^((beds_bed_side_top_r_overlay.png^[transformfx)^[colorize:"..htmlColor..")",
				"beds_bed_side_top.png",
				"beds_transparent.png",
			}
		},
		nodebox = {
			bottom = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
			top = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
		},
		selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
		recipe = {
			{"wool:"..color, "wool:"..color, "wool:"..color},
			{"group:wood", "group:wood", "group:wood"}
		},
	})

	-- Make the bed function as fuel.
	minetest.register_craft({
		type = "fuel",
		recipe = "beds:bed_bottom"..color,
		burntime = 12,
	})
end
