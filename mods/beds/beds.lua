-- Bed colors lookup
beds.node_registration_data = {
	{
		color = "black",
		desc_prefix = "Black "
	},
	{
		color = "blue",
		desc_prefix = "Blue "
	},
	{
		color = "brown",
		desc_prefix = "Brown "
	},
	{
		color = "cyan",
		desc_prefix = "Cyan "
	},
	{
		color = "dark_green",
		desc_prefix = "Dark Green "
	},
	{
		color = "dark_grey",
		desc_prefix = "Dark Grey "
	},
	{
		color = "green",
		desc_prefix = "Green "
	},
	{
		color = "grey",
		desc_prefix = "Grey "
	},
	{
		color = "magenta",
		desc_prefix = "Magenta "
	},
	{
		color = "orange",
		desc_prefix = "Orange "
	},
	{
		color = "pink",
		desc_prefix = "Pink "
	},
	{
		color = "red",
		desc_prefix = "Red "
	},
	{
		color = "violet",
		desc_prefix = "Violet "
	},
	{
		color = "white",
		desc_prefix = "White "
	},
	{
		color = "yellow",
		desc_prefix = "Yellow "
	}
}

-- Fancy shaped bed
for _,item in pairs(beds.node_registration_data) do
	beds.register_bed("beds:fancy_bed_"..item.color, {
		description = item.desc_prefix.."Fancy Bed",
		inventory_image = "beds_bed_fancy_"..item.color..".png",
		wield_image = "beds_bed_fancy_"..item.color..".png",
		tiles = {
			bottom = {
				"beds_bed_top1_"..item.color..".png",
				"default_wood.png",
				"beds_bed_side1_"..item.color..".png",
				"beds_bed_side1_"..item.color..".png^[transformFX",
				"default_wood.png",
				"beds_bed_foot_"..item.color..".png",
			},
			top = {
				"beds_bed_top2_"..item.color..".png",
				"default_wood.png",
				"beds_bed_side2_"..item.color..".png",
				"beds_bed_side2_"..item.color..".png^[transformFX",
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
			{"wool:"..item.color, "wool:"..item.color, "wool:white"},
			{"group:wood", "group:wood", "group:wood"},
		},
	})

	-- Fuel
	minetest.register_craft({
		type = "fuel",
		recipe = "beds:fancy_bed_"..item.color.."_bottom",
		burntime = 13,
	})


	-- Simple shaped bed
	beds.register_bed("beds:bed_"..item.color, {
		description = item.desc_prefix.."Simple Bed",
		inventory_image = "beds_bed_"..item.color..".png",
		wield_image = "beds_bed_"..item.color..".png",
		tiles = {
			bottom = {
				"beds_bed_top_bottom_"..item.color..".png^[transformR90",
				"default_wood.png",
				"beds_bed_side_bottom_r_"..item.color..".png",
				"beds_bed_side_bottom_r_"..item.color..".png^[transformfx",
				"beds_transparent.png",
				"beds_bed_side_bottom_"..item.color..".png"
			},
			top = {
				"beds_bed_top_top_"..item.color..".png^[transformR90",
				"default_wood.png",
				"beds_bed_side_top_r_"..item.color..".png",
				"beds_bed_side_top_r_"..item.color..".png^[transformfx",
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
			{"wool:"..item.color, "wool:"..item.color, "wool:white"},
			{"group:wood", "group:wood", "group:wood"}
		},
	})

	-- Fuel
	minetest.register_craft({
		type = "fuel",
		recipe = "beds:bed_"..item.color.."_bottom",
		burntime = 12,
	})
end

-- Aliases for PilzAdam's beds mod
minetest.register_alias("beds:bed_bottom_red", "beds:bed_bottom")
minetest.register_alias("beds:bed_top_red", "beds:bed_top")

-- Aliases for old beds to new red bed
minetest.register_alias("beds:bed_bottom", "beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "beds:bed_red_top")
minetest.register_alias("beds:fancy_bed_bottom", "beds:fancy_bed_red_bottom")
minetest.register_alias("beds:fancy_bed_top", "beds:fancy_bed_red_top")