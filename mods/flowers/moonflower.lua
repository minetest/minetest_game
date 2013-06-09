-- Moon Flower mod by MirceaKitsune

local SPAWN_ATTEMPTS = 5 -- How many times to attempt spawning per chunk
local SPAWN_PROBABILITY = 0.1 -- Probability of each spawn attempt
local OPEN_TIME_START = 0.2 -- Day time at which moon flowers open up
local OPEN_TIME_END = 0.8 -- Day time at which moon flowers close up
local OPEN_CHECK = 10 -- Interval at which to check if lighting changed

minetest.register_node("flowers:moonflower_closed", {
	description = "Moon flower",
	drawtype = "plantlike",
	tiles = { "moonflower_closed.png" },
	inventory_image = "moonflower_closed.png",
	wield_image = "moonflower_closed.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = { snappy = 3, flammable=2, flower=1 },
	drop = 'flowers:moonflower_closed',
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

minetest.register_node("flowers:moonflower_open", {
	description = "Moon flower",
	drawtype = "plantlike",
	tiles = { "moonflower_open.png" },
	inventory_image = "moonflower_open.png",
	wield_image = "moonflower_open.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	light_source = LIGHT_MAX / 2,
	groups = { not_in_creative_inventory = 1, snappy = 3, flammable=2, flower=1 },
	drop = 'flowers:moonflower_closed',
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 },
	},
})

set_moonflower = function (pos)
	-- choose the appropriate form of the moon flower
	if (minetest.env:get_node_light(pos, 0.5) == 15)
	and ((minetest.env:get_timeofday() < OPEN_TIME_START) or (minetest.env:get_timeofday() > OPEN_TIME_END)) then
		minetest.env:add_node(pos, { name = "flowers:moonflower_open" })
	else
		minetest.env:add_node(pos, { name = "flowers:moonflower_closed" })
	end
end

minetest.register_abm({
	nodenames = { "flowers:moonflower_closed", "flowers:moonflower_open" },
	interval = OPEN_CHECK,
	chance = 1,

	action = function(pos, node, active_object_count, active_object_count_wider)
		set_moonflower(pos)
	end
})

minetest.register_on_generated(function(minp, maxp, seed)
for attempts = 0, SPAWN_ATTEMPTS do
	-- choose a random location on the X and Z axes
	local coords_x = math.random(minp.x, maxp.x)
	local coords_z = math.random(minp.z, maxp.z)

	-- now scan upward until we find a suitable spot on the Y axis, if none is found this attempt is failed
	for coords_y = minp.y, maxp.y do
		local pos_here = { x = coords_x, y = coords_y, z = coords_z }
		local node_here = minetest.env:get_node(pos_here)
		local pos_top = { x = coords_x, y = coords_y + 1, z = coords_z }
		local node_top = minetest.env:get_node(pos_top)

		if (node_here.name == "default:dirt_with_grass") and (node_top.name == "air") then
			if (math.random() <= SPAWN_PROBABILITY) then
				set_moonflower(pos_top)
			end
			break
		end
	end
end
end)
