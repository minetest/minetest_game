-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.


-- Namespace for functions

flowers = {}


-- Map Generation

dofile(minetest.get_modpath("flowers") .. "/mapgen.lua")


--
-- Flowers
--

-- Aliases for original flowers mod

minetest.register_alias("flowers:flower_rose", "flowers:rose")
minetest.register_alias("flowers:flower_tulip", "flowers:tulip")
minetest.register_alias("flowers:flower_dandelion_yellow", "flowers:dandelion_yellow")
minetest.register_alias("flowers:flower_geranium", "flowers:geranium")
minetest.register_alias("flowers:flower_viola", "flowers:viola")
minetest.register_alias("flowers:flower_dandelion_white", "flowers:dandelion_white")


-- Flower registration

local function add_simple_flower(name, desc, box, f_groups)
	-- Common flowers' groups
	f_groups.snappy = 3
	f_groups.flammable = 2
	f_groups.flower = 1
	f_groups.flora = 1
	f_groups.attached_node = 1

	minetest.register_node("flowers:" .. name, {
		description = desc,
		drawtype = "plantlike",
		waving = 1,
		tiles = {"flowers_" .. name .. ".png"},
		inventory_image = "flowers_" .. name .. ".png",
		wield_image = "flowers_" .. name .. ".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		stack_max = 99,
		groups = f_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = box
		}
	})
end

flowers.datas = {
	{"rose", "Rose", {-0.15, -0.5, -0.15, 0.15, 0.3, 0.15}, {color_red = 1}},
	{"tulip", "Orange Tulip", {-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_orange = 1}},
	{"dandelion_yellow", "Yellow Dandelion", {-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_yellow = 1}},
	{"geranium", "Blue Geranium", {-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}, {color_blue = 1}},
	{"viola", "Viola", {-0.5, -0.5, -0.5, 0.5, -0.2, 0.5}, {color_violet = 1}},
	{"dandelion_white", "White dandelion", {-0.5, -0.5, -0.5, 0.5, -0.2, 0.5}, {color_white = 1}}
}

for _,item in pairs(flowers.datas) do
	add_simple_flower(unpack(item))
end


-- Flower spread

minetest.register_abm({
	nodenames = {"group:flora"},
	neighbors = {"default:dirt_with_grass", "default:desert_sand"},
	interval = 50,
	chance = 25,
	action = function(pos, node)
		pos.y = pos.y - 1
		local under = minetest.get_node(pos)
		pos.y = pos.y + 1
		if under.name == "default:desert_sand" then
			minetest.set_node(pos, {name = "default:dry_shrub"})
		elseif under.name ~= "default:dirt_with_grass" then
			return
		end

		local light = minetest.get_node_light(pos)
		if not light or light < 13 then
			return
		end

		local pos0 = {x = pos.x - 4, y = pos.y - 4, z = pos.z - 4}
		local pos1 = {x = pos.x + 4, y = pos.y + 4, z = pos.z + 4}
		if #minetest.find_nodes_in_area(pos0, pos1, "group:flora_block") > 0 then
			return
		end

		local flowers = minetest.find_nodes_in_area(pos0, pos1, "group:flora")
		if #flowers > 3 then
			return
		end

		local seedling = minetest.find_nodes_in_area(pos0, pos1, "default:dirt_with_grass")
		if #seedling > 0 then
			seedling = seedling[math.random(#seedling)]
			seedling.y = seedling.y + 1
			light = minetest.get_node_light(seedling)
			if not light or light < 13 then
				return
			end
			if minetest.get_node(seedling).name == "air" then
				minetest.set_node(seedling, {name = node.name})
			end
		end
	end,
})


--
-- Mushrooms
--

local mushrooms_datas = {
	{"brown", 2},
	{"red", -6}
}

for _, m in pairs(mushrooms_datas) do
	local name, nut = m[1], m[2]

	-- Register fertile mushrooms

	-- These are placed by mapgen and the growing ABM.
	-- These drop an infertile mushroom, and 0 to 3 spore
	-- nodes with an average of 1.25 per mushroom, for
	-- a slow multiplication of mushrooms when farming.

	minetest.register_node("flowers:mushroom_fertile_" .. name, {
		description = string.sub(string.upper(name), 0, 1) ..
			string.sub(name, 2) .. " Fertile Mushroom",
		tiles = {"flowers_mushroom_" .. name .. ".png"},
		inventory_image = "flowers_mushroom_" .. name .. ".png",
		wield_image = "flowers_mushroom_" .. name .. ".png",
		drawtype = "plantlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, flammable = 3, attached_node = 1,
			not_in_creative_inventory = 1},
		drop = {
			items = {
				{items = {"flowers:mushroom_" .. name}},
				{items = {"flowers:mushroom_spores_" .. name}, rarity = 4},
				{items = {"flowers:mushroom_spores_" .. name}, rarity = 2},
				{items = {"flowers:mushroom_spores_" .. name}, rarity = 2}
			}
		},
		sounds = default.node_sound_leaves_defaults(),
		on_use = minetest.item_eat(nut),
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
		}
	})

	-- Register infertile mushrooms

	-- These do not drop spores, to avoid the use of repeated digging
	-- and placing of a single mushroom to generate unlimited spores.

	minetest.register_node("flowers:mushroom_" .. name, {
		description = string.sub(string.upper(name), 0, 1) ..
			string.sub(name, 2) .. " Mushroom",
		tiles = {"flowers_mushroom_" .. name .. ".png"},
		inventory_image = "flowers_mushroom_" .. name .. ".png",
		wield_image = "flowers_mushroom_" .. name .. ".png",
		drawtype = "plantlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, flammable = 3, attached_node = 1},
		sounds = default.node_sound_leaves_defaults(),
		on_use = minetest.item_eat(nut),
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
		}
	})

	-- Register mushroom spores

	minetest.register_node("flowers:mushroom_spores_" .. name, {
		description = string.sub(string.upper(name), 0, 1) ..
			string.sub(name, 2) .. " Mushroom Spores",
		drawtype = "signlike",
		tiles = {"flowers_mushroom_spores_" .. name .. ".png"},
		inventory_image = "flowers_mushroom_spores_" .. name .. ".png",
		wield_image = "flowers_mushroom_spores_" .. name .. ".png",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		selection_box = {
			type = "wallmounted",
		},
		groups = {dig_immediate = 3, attached_node = 1},
	})
end


-- Register growing ABM

minetest.register_abm({
	nodenames = {"flowers:mushroom_spores_brown", "flowers:mushroom_spores_red"},
	interval = 11,
	chance = 50,
	action = function(pos, node)
		local node_under = minetest.get_node_or_nil({x = pos.x,
			y = pos.y - 1, z = pos.z})
		if not node_under then
			return
		end
		if minetest.get_item_group(node_under.name, "soil") ~= 0 and
				minetest.get_node_light(pos, nil) <= 13 then
			if node.name == "flowers:mushroom_spores_brown" then
				minetest.set_node(pos, {name = "flowers:mushroom_fertile_brown"})
			elseif node.name == "flowers:mushroom_spores_red" then
				minetest.set_node(pos, {name = "flowers:mushroom_fertile_red"})
			end
		end
	end
})


--
-- Waterlily
--

minetest.register_node("flowers:waterlily", {
	description = "Waterlily",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"flowers_waterlily.png"},
	inventory_image = "flowers_waterlily.png",
	wield_image = "flowers_waterlily.png",
	liquids_pointable = true,
	walkable = false,
	groups = {snappy = 3, flower = 1},
	sounds = default.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.46875, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}
	},

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local find_water = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y, z = pos.z - 1},
			{x = pos.x + 1, y = pos.y, z = pos.z + 1}, "default:water_source")
		if #find_water ~= 0 then
			minetest.set_node(pos, {name = "default:water_source"})
			pos.y = pos.y + 1
		end
		minetest.set_node(pos, {name = "flowers:waterlily", param2 = math.random(0, 3)})
	end
})
