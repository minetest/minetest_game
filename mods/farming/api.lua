-- Wear out hoes, place soil
-- TODO Ignore group:flower

local creative = minetest.setting_getbool("creative_mode")
function farming.hoe_on_use(itemstack, user, pt, max_uses)
	-- check if pointing at a node's top
	if not pt or pt.type ~= "node" or pt.above.y ~= pt.under.y+1 then
		return
	end

	local above = minetest.get_node(pt.above)
	if above.name ~= "air" or not minetest.registered_nodes[above.name] then
		return
	end

	local under = minetest.get_node(pt.under)
	if not minetest.registered_nodes[under.name] or
			minetest.get_item_group(under.name, "soil") ~= 1 then
		return
	end

	-- check if (wet) soil defined
	local soil = minetest.registered_nodes[under.name].soil
	if not soil or not soil.wet or not soil.dry then
		return
	end

	if minetest.is_protected(pt.under, user:get_player_name()) then
		minetest.record_protection_violation(pt.under, user:get_player_name())
		return
	end
	if minetest.is_protected(pt.above, user:get_player_name()) then
		minetest.record_protection_violation(pt.above, user:get_player_name())
		return
	end

	-- turn the node into soil, wear out item and play sound
	minetest.set_node(pt.under, {name = soil.dry})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})

	if creative then
		return
	end

	itemstack:add_wear(65535/(max_uses-1))
	return itemstack
end

-- Register new hoes
function farming.register_hoe(name, def)
	-- Check for : prefix (register new hoes in your mod's namespace)
	if name:sub(1,1) ~= ":" then
		name = ":" .. name
	end
	-- Check def table
	assert(def.description, "[farming] missing field description (hoe "..name..")")
	assert(def.inventory_image, "[farming] missing field inventory_image (hoe "..name..")")

	local uses = tonumber(def.max_uses)
	assert(uses and uses > 1, "[farming] max uses are invalid (hoe "..name..")")

	-- Register the tool
	minetest.register_tool(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			return farming.hoe_on_use(itemstack, user, pointed_thing, uses)
		end
	})

	-- Register its recipe
	if not def.material then
		if def.recipe then
			minetest.register_craft({
				output = name:sub(2),
				recipe = def.recipe
			})
		end
		return
	end

	minetest.register_craft({
		output = name:sub(2),
		recipe = {
			{def.material, def.material, ""},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
		}
	})

	-- Reverse Recipe
	minetest.register_craft({
		output = name:sub(2),
		recipe = {
			{"", def.material, def.material},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
		}
	})
end

-- Seed placement
function farming.place_seed(itemstack, placer, pt, plantname)
	-- check if pointing at a node's top
	if not pt or pt.type ~= "node" or pt.above.y ~= pt.under.y+1 then
		return
	end

	local playername = placer:get_player_name()
	if minetest.is_protected(pt.under, playername) then
		minetest.record_protection_violation(pt.under, playername)
		return
	end
	if minetest.is_protected(pt.above, playername) then
		minetest.record_protection_violation(pt.above, playername)
		return
	end

	-- check if you can replace the node above the pointed node
	local above = minetest.get_node(pt.above)
	if not (minetest.registered_nodes[above.name] and
			minetest.registered_nodes[above.name].buildable_to) then
		return
	end

	-- check if pointing at soil
	local under = minetest.get_node(pt.under)
	if not minetest.registered_nodes[under.name] or
			minetest.get_item_group(under.name, "soil") < 2 then
		return
	end

	-- add the node and remove 1 item from the itemstack
	minetest.add_node(pt.above, {name = plantname, param2 = 1})

	if creative then
		return
	end

	itemstack:take_item()
	return itemstack
end

-- Register plants
function farming.register_plant(name, def)
	-- Check def table
	assert(def.steps, "[farming] missing field steps (plant "..name..")")
	assert(def.inventory_image, "[farming] missing field inventory_image (plant "..name..")")
	assert(def.description, "[farming] missing field description (plant "..name..")")
	def.fertility = def.fertility or {}

	-- Register seed
	local g = {seed = 1, snappy = 3, attached_node = 1}
	for k, v in pairs(def.fertility) do
		g[v] = 1
	end

	local mname, pname = unpack(name:split(":"))

	minetest.register_node(":" .. mname .. ":seed_" .. pname, {
		description = def.description,
		tiles = {def.inventory_image},
		inventory_image = def.inventory_image,
		wield_image = def.inventory_image,
		drawtype = "signlike",
		groups = g,
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = false,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		fertility = def.fertility,
		on_place = function(itemstack, placer, pointed_thing)
			return farming.place_seed(itemstack, placer, pointed_thing,
					mname .. ":seed_" .. pname)
		end
	})

	-- Register harvest
	minetest.register_craftitem(":" .. mname .. ":" .. pname, {
		description = pname:gsub("^%l", string.upper),
		inventory_image = mname .. "_" .. pname .. ".png",
	})

	-- Register growing steps
	for i = 1, def.steps do
		local nodegroups = {
			snappy = 3,
			flammable = 2,
			plant = 1,
			not_in_creative_inventory = 1,
			attached_node = 1
		}
		nodegroups[pname] = i

		minetest.register_node(mname .. ":" .. pname .. "_" .. i, {
			drawtype = "plantlike",
			waving = 1,
			tiles = {mname .. "_" .. pname .. "_" .. i .. ".png"},
			paramtype = "light",
			walkable = false,
			buildable_to = true,
			drop = {
				items = {
					{items = {mname .. ":" .. pname}, rarity = 9 - i},
					{items = {mname .. ":" .. pname}, rarity= 18 - i * 2},
					{items = {mname .. ":seed_" .. pname}, rarity = 9 - i},
					{items = {mname .. ":seed_" .. pname}, rarity = 18 - i * 2},
				}
			},
			selection_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
			},
			groups = nodegroups,
			sounds = default.node_sound_leaves_defaults(),
		})
	end

	def.minlight = def.minlight or 1
	def.maxlight = def.maxlight or 14

	-- Growing ABM
	minetest.register_abm({
		nodenames = {"group:" .. pname, "group:seed"},
		neighbors = {"group:soil"},
		interval = 9,
		chance = 20,
		action = function(pos, node)
			-- return if already full grown
			if minetest.get_item_group(node.name, pname) == def.steps then
				return
			end

			pos.y = pos.y-1
			local soil_node = minetest.get_node_or_nil(pos)
			if not soil_node then
				return
			end
			pos.y = pos.y+1

			local fertility = minetest.registered_items[node.name].fertility

			-- grow seed
			if fertility and minetest.get_item_group(node.name, "seed") then
				for _, v in pairs(fertility) do
					if minetest.get_item_group(soil_node.name, v) ~= 0 then
						node.name = node.name:gsub("seed_", "") .. "_1"
						minetest.set_node(pos, node)
						return
					end
				end
				return
			end

			-- check if on wet soil
			if minetest.get_item_group(soil_node.name, "soil") < 3 then
				return
			end

			-- check light
			local ll = minetest.get_node_light(pos)

			if not ll or ll < def.minlight or ll > def.maxlight then
				return
			end

			-- grow
			node.name = mname .. ":" .. pname .. "_" .. plant_height + 1
			minetest.set_node(pos, node)
		end
	})

	-- Return
	return {
		seed = mname .. ":seed_" .. pname,
		harvest = mname .. ":" .. pname
	}
end
