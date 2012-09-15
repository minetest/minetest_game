-- Wool crafting, for Minetest 0.4.2-rc1 and 0.4.3
-- By Jordach, Jordan Snelling.

-- Original Wool / Colour_Blocks crafts.

minetest.register_craft({
	output = 'wool:red 16',
	recipe = {
		{'default:apple', 'wool:white'},
	}
})

minetest.register_craft({
	output = 'wool:yellow 16',
	recipe = {
		{'default:sand', 'wool:white'},
	}
})

minetest.register_craft({
	output = 'wool:white 16',
	recipe = {
		{'default:coal_lump', 'default:sand'},
	}
})


minetest.register_craft({
	output = 'wool:black 16',
	recipe = {
		{'default:coal_lump', 'wool:dark_grey'},
	}
})

minetest.register_craft({
	output = 'wool:grey 16',
	recipe = {
		{'default:coal_lump', 'wool:white'},
	}
})

minetest.register_craft({
	output = 'wool:green 16',
	recipe = {
		{'default:leaves', 'wool:white'},
	}
})


minetest.register_craft({
	output = 'wool:brown 16',
	recipe = {
		{'default:dirt', 'wool:white'},
	}
})

minetest.register_craft({
	output = 'wool:blue 16',
	recipe = {
		{'wool:cyan', 'wool:violet'},
	}
})

minetest.register_craft({
	output = 'wool:blue 16',
	recipe = {
		{'wool:white', 'default:mese'},
	}
})

minetest.register_craft({
	output = 'wool:orange 16',
	recipe = {
		{'wool:yellow', 'wool:red'},
	}
})

-- 16 colour wool addition crafts

minetest.register_craft({
	output = 'wool:dark_grey 16',
	recipe = {
		{'wool:grey', 'default:coal_lump'},
	}
})

minetest.register_craft({
	output = 'wool:dark_green 16',
	recipe = {
		{'wool:green', 'default:coal_lump'},
	}
})

minetest.register_craft({
	output = 'wool:pink 16',
	recipe = {
		{'wool:red', 'wool:white'},
	}
})

-- New craft methods

minetest.register_craft({
	output = 'wool:orange 16',
	recipe = {
		{'default:desert_sand', 'wool:white'},
	}
})

minetest.register_craft({
	output = 'wool:dark_green 16',
	recipe = {
		{'wool:white', 'default:cactus'},
	}
})

minetest.register_craft({
	output = 'wool:cyan 16',
	recipe = {
		{'default:tree', 'wool:white'},
	}
})

minetest.register_craft({
	output = 'wool:magenta 16',
	recipe = {
		{'wool:blue', 'wool:violet'},
	}
})

minetest.register_craft({
	output = 'wool:violet 16',
	recipe = {
		{'wool:cyan', 'wool:red'},
	}
})