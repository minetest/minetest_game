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
		buildable_to = true,
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
	{
		"rose",
		"Red Rose",
		{-2 / 16, -0.5, -2 / 16, 2 / 16, 5 / 16, 2 / 16},
		{color_red = 1, flammable = 1}
	},
	{
		"tulip",
		"Orange Tulip",
		{-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
		{color_orange = 1, flammable = 1}
	},
	{
		"dandelion_yellow",
		"Yellow Dandelion",
		{-4 / 16, -0.5, -4 / 16, 4 / 16, -2 / 16, 4 / 16},
		{color_yellow = 1, flammable = 1}
	},
	{
		"chrysanthemum_green",
		"Green Chrysanthemum",
		{-4 / 16, -0.5, -4 / 16, 4 / 16, -1 / 16, 4 / 16},
		{color_green = 1, flammable = 1}
	},
	{
		"geranium",
		"Blue Geranium",
		{-2 / 16, -0.5, -2 / 16, 2 / 16, 2 / 16, 2 / 16},
		{color_blue = 1, flammable = 1}
	},
	{
		"viola",
		"Viola",
		{-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16},
		{color_violet = 1, flammable = 1}
	},
	{
		"dandelion_white",
		"White Dandelion",
		{-5 / 16, -0.5, -5 / 16, 5 / 16, -2 / 16, 5 / 16},
		{color_white = 1, flammable = 1}
	},
	{
		"tulip_black",
		"Black Tulip",
		{-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
		{color_black = 1, flammable = 1}
	},
}

for _,item in pairs(flowers.datas) do
	add_simple_flower(unpack(item))
end


-- Flower spread
-- Public function to enable override by mods

function flowers.flower_spread(pos, node)
	pos.y = pos.y - 1
	local under = minetest.get_node(pos)
	pos.y = pos.y + 1
	-- Replace flora with dry shrub in desert sand and silver sand,
	-- as this is the only way to generate them.
	-- However, preserve grasses in sand dune biomes.
	if minetest.get_item_group(under.name, "sand") == 1 and
			under.name ~= "default:sand" then
		minetest.set_node(pos, {name = "default:dry_shrub"})
		return
	end

	if minetest.get_item_group(under.name, "soil") == 0 then
		return
	end

	local light = minetest.get_node_light(pos)
	if not light or light < 13 then
		return
	end

	local pos0 = vector.subtract(pos, 4)
	local pos1 = vector.add(pos, 4)
	if #minetest.find_nodes_in_area(pos0, pos1, "group:flora") > 3 then
		return
	end

	local soils = minetest.find_nodes_in_area_under_air(
		pos0, pos1, "group:soil")
	if #soils > 0 then
		local seedling = soils[math.random(#soils)]
		local seedling_above =
			{x = seedling.x, y = seedling.y + 1, z = seedling.z}
		light = minetest.get_node_light(seedling_above)
		if not light or light < 13 or
				-- Desert sand is in the soil group
				minetest.get_node(seedling).name == "default:desert_sand" then
			return
		end

		minetest.set_node(seedling_above, {name = node.name})
	end
end

minetest.register_abm({
	label = "Flower spread",
	nodenames = {"group:flora"},
	interval = 13,
	chance = 96,
	action = function(...)
		flowers.flower_spread(...)
	end,
})


--
-- Mushrooms
--

minetest.register_node("flowers:mushroom_red", {
	description = "Red Mushroom",
	tiles = {"flowers_mushroom_red.png"},
	inventory_image = "flowers_mushroom_red.png",
	wield_image = "flowers_mushroom_red.png",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	on_use = minetest.item_eat(-5),
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, -1 / 16, 4 / 16},
	}
})

minetest.register_node("flowers:mushroom_brown", {
	description = "Brown Mushroom",
	tiles = {"flowers_mushroom_brown.png"},
	inventory_image = "flowers_mushroom_brown.png",
	wield_image = "flowers_mushroom_brown.png",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	on_use = minetest.item_eat(1),
	selection_box = {
		type = "fixed",
		fixed = {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16},
	}
})


-- Mushroom spread and death

function flowers.mushroom_spread(pos, node)
	if minetest.get_node_light(pos, nil) == 15 then
		minetest.remove_node(pos)
		return
	end
	local positions = minetest.find_nodes_in_area_under_air(
		{x = pos.x - 1, y = pos.y - 2, z = pos.z - 1},
		{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
		{"group:soil", "group:tree"})
	if #positions == 0 then
		return
	end
	local pos2 = positions[math.random(#positions)]
	pos2.y = pos2.y + 1
	if minetest.get_node_light(pos, 0.5) <= 3 and
			minetest.get_node_light(pos2, 0.5) <= 3 then
		minetest.set_node(pos2, {name = node.name})
	end
end

minetest.register_abm({
	label = "Mushroom spread",
	nodenames = {"flowers:mushroom_brown", "flowers:mushroom_red"},
	interval = 11,
	chance = 150,
	action = function(...)
		flowers.mushroom_spread(...)
	end,
})


-- These old mushroom related nodes can be simplified now

minetest.register_alias("flowers:mushroom_spores_brown", "flowers:mushroom_brown")
minetest.register_alias("flowers:mushroom_spores_red", "flowers:mushroom_red")
minetest.register_alias("flowers:mushroom_fertile_brown", "flowers:mushroom_brown")
minetest.register_alias("flowers:mushroom_fertile_red", "flowers:mushroom_red")
minetest.register_alias("mushroom:brown_natural", "flowers:mushroom_brown")
minetest.register_alias("mushroom:red_natural", "flowers:mushroom_red")


--
-- Waterlily
--

minetest.register_node("flowers:waterlily", {
	description = "Waterlily",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"flowers_waterlily.png", "flowers_waterlily_bottom.png"},
	inventory_image = "flowers_waterlily.png",
	wield_image = "flowers_waterlily.png",
	liquids_pointable = true,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	floodable = true,
	groups = {snappy = 3, flower = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31 / 64, -0.5, 0.5, -15 / 32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local def = minetest.registered_nodes[node.name]
		local player_name = placer and placer:get_player_name() or ""

		if def and def.on_rightclick then
			return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
					pointed_thing)
		end

		if def and def.liquidtype == "source" and
				minetest.get_item_group(node.name, "water") > 0 then
			if not minetest.is_protected(pos, player_name) then
				minetest.set_node(pos, {name = "flowers:waterlily",
					param2 = math.random(0, 3)})
				if not (creative and creative.is_enabled_for
						and creative.is_enabled_for(player_name)) then
					itemstack:take_item()
				end
			else
				minetest.chat_send_player(player_name, "Node is protected")
				minetest.record_protection_violation(pos, player_name)
			end
		end

		return itemstack
	end
})
