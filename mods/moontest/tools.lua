--picks

minetest.register_tool("moontest:pick_lunarium", {
	description = "Lunarium Pickaxe",
	inventory_image = "moontest_tool_lunariumpick.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=1.75, [2]=0.85, [3]=0.35}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=6},
	},
})

minetest.register_tool("moontest:pick_titanium", {
	description = "Titanium Pickaxe",
	inventory_image = "moontest_tool_titaniumpick.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=2,
		groupcaps={
			cracky = {times={[1]=3.50, [2]=1.70, [3]=0.70}, uses=50, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
})

--shovels

minetest.register_tool("moontest:shovel_lunarium", {
	description = "Lunarium Shovel",
	inventory_image = "moontest_tool_lunariumshovel.png",
	wield_image = "moontest_tool_lunariumshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=0.85, [2]=0.35, [3]=0.15}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("moontest:shovel_titanium", {
	description = "Titanium Shovel",
	inventory_image = "moontest_tool_titaniumshovel.png",
	wield_image = "moontest_tool_titaniumshovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.7, [2]=0.7, [3]=0.3}, uses=50, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
})

--axes

minetest.register_tool("moontest:axe_lunarium", {
	description = "Lunarium Axe",
	inventory_image = "moontest_tool_lunariumaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=1.85, [2]=0.75, [3]=0.35}, uses=40, maxlevel=2},
		},
		damage_groups = {fleshy=9},
	},
})

minetest.register_tool("moontest:axe_titanium", {
	description = "Titanium Axe",
	inventory_image = "moontest_tool_titaniumaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.7, [2]=1.5, [3]=0.7}, uses=50, maxlevel=2},
		},
		damage_groups = {fleshy=8},
	},
})

--swords :D

minetest.register_tool("moontest:sword_lunarium", {
	description = "Lunarium Sword",
	inventory_image = "moontest_tool_lunariumsword.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.65, [2]=0.75, [3]=0.15}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=10},
	}
})

minetest.register_tool("moontest:sword_titanium", {
	description = "Titanium Sword",
	inventory_image = "moontest_tool_titaniumsword.png",
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=3.3, [2]=1.5, [3]=0.3}, uses=50, maxlevel=3},
		},
		damage_groups = {fleshy=9},
	}
})