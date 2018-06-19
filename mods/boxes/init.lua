minetest.register_node("boxes:box_wood", {
	description = "Woodbox",
	groups = {cracky=3},
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_stone", {
	description = "Stonebox",
	groups = {cracky=3},
	tiles = {
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_dirt", {
	description = "Dirtbox",
	groups = {cracky=3},
	tiles = {
		"default_dirt.png",
		"default_dirt.png",
		"default_dirt.png",
		"default_dirt.png",
		"default_dirt.png",
		"default_dirt.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_sand", {
	description = "Sandbox",
	groups = {cracky=3},
	tiles = {
		"default_sand.png",
		"default_sand.png",
		"default_sand.png",
		"default_sand.png",
		"default_sand.png",
		"default_sand.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_water", {
	description = "Waterbox",
	groups = {cracky=3},
	tiles = {
		"default_water_source_animated.png",
		"default_water_source_animated.png",
		"default_water_source_animated.png",
		"default_water_source_animated.png",
		"default_water_source_animated.png",
		"default_water_source_animated.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_lava", {
	description = "Lavabox",
	groups = {cracky=3},
	tiles = {
		"default_lava_source_animated.png",
		"default_lava_source_animated.png",
		"default_lava_source_animated.png",
		"default_lava_source_animated.png",
		"default_lava_source_animated.png",
		"default_lava_source_animated.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_cobble", {
	description = "Cobblebox",
	groups = {cracky=3},
	tiles = {
		"default_cobble.png",
		"default_cobble.png",
		"default_cobble.png",
		"default_cobble.png",
		"default_cobble.png",
		"default_cobble.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})

minetest.register_node("boxes:box_obsidian", {
	description = "Obsidianbox",
	groups = {cracky=3},
	tiles = {
		"default_obsidian.png",
		"default_obsidian.png",
		"default_obsidian.png",
		"default_obsidian.png",
		"default_obsidian.png",
		"default_obsidian.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5}, -- NodeBox3
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5}, -- NodeBox4
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5}, -- NodeBox6
			{-0.5, 0, -0.5, 0.5, 0, 0.5}, -- NodeBox7
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5}, -- NodeBox8
		}
	}
})
