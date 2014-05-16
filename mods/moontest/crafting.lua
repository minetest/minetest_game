-- Crafting

minetest.register_craft({
    output = "moontest:airlock",
    recipe = {
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"default:steel_ingot", "default:mese", "default:steel_ingot"},
        {"default:steel_ingot", "", "default:steel_ingot"},
    },
})

minetest.register_craft({
    output = "moontest:light",
    recipe = {
        {"moontest:light_crystal", "moontest:stone", "moontest:light_crystal"},
        {"moontest:light_crystal", "default:mese_crystal", "moontest:light_crystal"},
        {"moontest:light_crystal", "moontest:stone", "moontest:light_crystal"},
    },
})

minetest.register_craft({
    output = "moontest:light_stick",
    recipe = {
        {"moontest:light_crystal"},
        {"default:stick"},
        {"default:stick"},
    },
})

minetest.register_craft({
    output = "moontest:airgen",
    recipe = {
        {"default:steel_ingot", "moontest:waterice", "default:steel_ingot"},
        {"moontest:waterice", "default:mese", "moontest:waterice"},
        {"default:steel_ingot", "moontest:waterice", "default:steel_ingot"},
    },
})

minetest.register_craft({
	output = "default:wood",
	recipe = {
		{"moontest:tree"},
	},
})

minetest.register_craft({
	output = "default:water_source",
	recipe = {
		{"moontest:waterice"},
	},
})

minetest.register_craft({
    output = "moontest:hlsource",
    recipe = {
        {"moontest:leaves", "moontest:leaves", "moontest:leaves"},
        {"moontest:leaves", "moontest:waterice", "moontest:leaves"},
        {"moontest:leaves", "moontest:leaves", "moontest:leaves"},
    },
})

minetest.register_craft({
	output = "moontest:stonebrick 4",
	recipe = {
		{"moontest:stone", "moontest:stone"},
		{"moontest:stone", "moontest:stone"},
	}
})

minetest.register_craft({
    output = "default:furnace",
    recipe = {
        {"moontest:stone", "moontest:stone", "moontest:stone"},
        {"moontest:stone", "", "moontest:stone"},
        {"moontest:stone", "moontest:stone", "moontest:stone"},
    },
})

minetest.register_craft({
	output = "moontest:stoneslab 4",
	recipe = {
		{"moontest:stone", "moontest:stone"},
	}
})

minetest.register_craft({
	output = "moontest:stonestair 4",
	recipe = {
		{"moontest:stone", ""},
		{"moontest:stone", "moontest:stone"},
	}
})

minetest.register_craft({
	output = "moontest:helmet",
	recipe = {
		{"default:mese_crystal"},
		{"default:glass"},
		{"default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "moontest:lifesupport",
	recipe = {
		{"default:steel_ingot","default:steel_ingot" , "default:steel_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "moontest:spacesuit",
	recipe = {
		{"wool:white", "moontest:helmet", "wool:white"},
		{"", "moontest:lifesupport", ""},
		{"wool:white", "", "wool:white"},
	}
})

minetest.register_craft({
    output = "moontest:light 8",
    recipe = {
        {"moontest:glass", "moontest:glass", "moontest:glass"},
        {"moontest:glass", "default:mese", "moontest:glass"},
        {"moontest:glass", "moontest:glass", "moontest:glass"},
    },
})

minetest.register_craft({
	output = "moontest:sapling",
	recipe = {
		{"default:mese_crystal"},
		{"default:sapling"},
	}
})

-- Cooking

minetest.register_craft({
	type = "cooking",
	output = "moontest:glass",
	recipe = "moontest:dust",
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:mese_crystal",
	burntime = 50,
})
