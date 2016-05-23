-- farming/api.lua

-- Wear out hoes, place soil
-- TODO Ignore group:flower
farming.registered_plants = {}

function farming.hoe_on_use(itemstack, user, pt, uses)
	if not pt or pt.type ~= "node" or pt.above.y ~= pt.under.y + 1 then
		-- Only nodes pointed on the top can be hoed
		return
	end

	if minetest.get_node(pt.above).name ~= "air" then
		-- The hoe is obstructed from moving if there is no free space
		return
	end

	local node_under = minetest.get_node(pt.under)
	local node_under_def = minetest.registered_nodes[node_under.name]
	if not node_under_def or
			minetest.get_item_group(node_under.name, "soil") ~= 1 then
		-- Not a soil node
		return
	end

	-- Test if soil properties are defined
	local soil = node_under_def.soil
	if not soil or not soil.wet or not soil.dry then
		return
	end

	local playername = user and user:get_player_name() or ""
	if minetest.is_protected(pt.under, playername) then
		minetest.record_protection_violation(pt.under, playername)
		return
	end

	-- Put the node which should appear after applying the hoe
	node_under.name = node_under_def.soil.dry
	minetest.swap_node(pt.under, node_under)
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	}, true)

	if minetest.global_exists("creative")
			and creative.is_enabled_for(playername) then
		return
	end

	-- wear tool
	itemstack:add_wear(65535 / (uses - 1))
	if itemstack:is_empty() then
		local wdef = itemstack:get_definition()
		if wdef.sound and wdef.sound.breaks then
			minetest.sound_play(wdef.sound.breaks, {pos = pt.above,
				gain = 0.5}, true)
		end
	end
	return itemstack
end

-- Register new hoes
function farming.register_hoe(name, def)
	-- Check for : prefix (register new hoes in your mod's namespace)
	if name:sub(1,1) ~= ":" then
		name = ":" .. name
	end
	-- Check def table
	assert(def.description, "Missing hoe description for " .. name)
	assert(def.inventory_image, "Missing inventory image for " .. name)
	assert(def.max_uses and def.max_uses > 1,
		"max_uses are invalid (hoe " .. name .. ")")

	-- Register the tool
	minetest.register_tool(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			return farming.hoe_on_use(itemstack, user, pointed_thing,
				def.max_uses)
		end,
		groups = def.groups,
		sound = {breaks = "default_tool_breaks"},
	})

	-- Register its recipe
	if def.recipe then
		minetest.register_craft({
			output = name:sub(2),
			recipe = def.recipe
		})
	elseif def.material then
		minetest.register_craft({
			output = name:sub(2),
			recipe = {
				{def.material, def.material},
				{"", "group:stick"},
				{"", "group:stick"}
			}
		})
	end
end

-- how often node timers for plants will tick, +/- some random value
local function tick(pos)
	minetest.get_node_timer(pos):start(math.random(166, 286))
end
-- how often a growth failure tick is retried (e.g. too dark)
local function tick_again(pos)
	minetest.get_node_timer(pos):start(math.random(40, 80))
end

-- Seed placement
function farming.place_seed(itemstack, placer, pt, plantname)
	if not pt or pt.type ~= "node" or pt.above.y ~= pt.under.y + 1 then
		-- Seeds can only be placed on top of a node
		return
	end

	local playername = placer and placer:get_player_name() or ""
	if minetest.is_protected(pt.above, playername) then
		minetest.record_protection_violation(pt.above, playername)
		return
	end

	local node_above_def = minetest.registered_nodes[
		minetest.get_node(pt.above).name]
	if not node_above_def or not node_above_def.buildable_to then
		-- We cannot put the seed here
		return
	end

	-- The seed must be placed onto a soil node
	local node_under = minetest.get_node(pt.under)
	if minetest.get_item_group(node_under.name, "soil") < 2 then
		return
	end

	-- Put the seed node
	minetest.log("action", playername .. " places node " .. plantname ..
		" at " .. minetest.pos_to_string(pt.above))
	minetest.add_node(pt.above, {name = plantname, param2 = 1})
	tick(pt.above)

	if minetest.global_exists("creative")
			and creative.is_enabled_for(playername) then
		return
	end

	itemstack:take_item()
	return itemstack
end

farming.grow_plant = function(pos, elapsed)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]

	if not def.next_plant then
		-- disable timer for fully grown plant
		return
	end

	-- grow seed
	if minetest.get_item_group(node.name, "seed") and def.fertility then
		local soil_node = minetest.get_node_or_nil(
			{x = pos.x, y = pos.y - 1, z = pos.z})
		if not soil_node then
			tick_again(pos)
			return
		end
		-- omitted is a check for light, we assume seeds can germinate in the dark.
		for _, groupname in ipairs(def.fertility) do
			if minetest.get_item_group(soil_node.name, groupname) ~= 0 then
				local placenode = {name = def.next_plant}
				if def.place_param2 then
					placenode.param2 = def.place_param2
				end
				minetest.swap_node(pos, placenode)
				if minetest.registered_nodes[def.next_plant].next_plant then
					tick(pos)
					return
				end
			end
		end

		return
	end

	-- check if on wet soil
	local below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	if minetest.get_item_group(below.name, "soil") < 3 then
		tick_again(pos)
		return
	end

	-- check light
	local light = minetest.get_node_light(pos)
	if not light or light < def.minlight or light > def.maxlight then
		tick_again(pos)
		return
	end

	-- grow
	local placenode = {name = def.next_plant}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end
	minetest.swap_node(pos, placenode)

	-- new timer needed?
	if minetest.registered_nodes[def.next_plant].next_plant then
		tick(pos)
	end
	return
end

-- Register plants
function farming.register_plant(name, def)
	local mname, pname = unpack(name:split(":"))

	-- Check def table
	if not def.harvest_description then
		def.harvest_description = pname:gsub("^%l", string.upper)
	end
	assert(def.description, "Missing description for " .. name)
	assert(def.inventory_image, "Missing inventory_image for " .. name)
	assert(def.steps, "Missing number of steps for " .. name)
	assert(def.fertility and def.fertility[1], "Missing fertility for " .. name)
	def.minlight = def.minlight or 1
	def.maxlight = def.maxlight or default.LIGHT_MAX

	farming.registered_plants[pname] = def

	-- Register seed
	local lbm_nodes = {mname .. ":seed_" .. pname}
	local seed_groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 2}
	for _, groupname in ipairs(def.fertility) do
		seed_groups[groupname] = 1
	end

	minetest.register_node(":" .. mname .. ":seed_" .. pname, {
		description = def.description,
		tiles = {def.inventory_image},
		inventory_image = def.inventory_image,
		wield_image = def.inventory_image,
		drawtype = "signlike",
		groups = seed_groups,
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = def.place_param2 or nil, -- this isn't actually used for placement
		walkable = false,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		fertility = def.fertility,
		sounds = default.node_sound_dirt_defaults({
			dig = {name = "", gain = 0},
			dug = {name = "default_grass_footstep", gain = 0.2},
			place = {name = "default_place_node", gain = 0.25},
		}),

		on_place = function(itemstack, placer, pointed_thing)
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local udef = minetest.registered_nodes[node.name]
			if udef and udef.on_rightclick and
					not (placer and placer:is_player() and
					placer:get_player_control().sneak) then
				return udef.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end

			return farming.place_seed(itemstack, placer, pointed_thing,
				mname .. ":seed_" .. pname) or itemstack
		end,
		next_plant = mname .. ":" .. pname .. "_1",
		on_timer = farming.grow_plant,
		minlight = def.minlight,
		maxlight = def.maxlight,
	})

	-- Register harvest
	minetest.register_craftitem(":" .. mname .. ":" .. pname, {
		description = def.harvest_description,
		inventory_image = mname .. "_" .. pname .. ".png",
		groups = def.groups or {flammable = 2},
	})

	-- Register growing steps
	for i = 1, def.steps do
		local base_rarity = 1
		if def.steps ~= 1 then
			base_rarity =  8 - (i - 1) * 7 / (def.steps - 1)
		end
		local drop = {
			items = {
				{items = {mname .. ":" .. pname}, rarity = base_rarity},
				{items = {mname .. ":" .. pname}, rarity = base_rarity * 2},
				{items = {mname .. ":seed_" .. pname}, rarity = base_rarity},
				{items = {mname .. ":seed_" .. pname}, rarity = base_rarity * 2},
			}
		}

		local next_plant = nil

		if i < def.steps then
			next_plant = mname .. ":" .. pname .. "_" .. (i + 1)
			lbm_nodes[#lbm_nodes + 1] = mname .. ":" .. pname .. "_" .. i
		end

		minetest.register_node(":" .. mname .. ":" .. pname .. "_" .. i, {
			drawtype = "plantlike",
			waving = 1,
			tiles = {mname .. "_" .. pname .. "_" .. i .. ".png"},
			paramtype = "light",
			paramtype2 = def.paramtype2 or nil,
			place_param2 = def.place_param2 or nil,
			walkable = false,
			buildable_to = true,
			drop = drop,
			selection_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
			},
			groups = {snappy = 3, flammable = 2, plant = 1,
				not_in_creative_inventory = 1, attached_node = 1, [pname] = i},
			sounds = default.node_sound_leaves_defaults(),
			next_plant = next_plant,
			on_timer = farming.grow_plant,
			minlight = def.minlight,
			maxlight = def.maxlight,
		})
	end

	-- replacement LBM for pre-nodetimer plants
	minetest.register_lbm({
		name = ":" .. mname .. ":start_nodetimer_" .. pname,
		nodenames = lbm_nodes,
		action = tick_again,
	})

	-- Return
	return {
		seed = mname .. ":seed_" .. pname,
		harvest = mname .. ":" .. pname
	}
end
