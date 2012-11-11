-- Minetest 0.4 mod: farming
-- See README.txt for licensing and other information.

-- Groups defined in this mod:
--   plant: 1 = full grown; higher numbers = less grown
--   soil: 1 = wet; 2 = dry

-- store all the functions in a global table
farming = {}

-- contains all the registered plants ordered by the name
farming.registered_plants = {}

-- contains all the seeds that can be dropped by plowing grass
--  this table is extended automatically by register_plant()
local seeds = {}

-- defines all items and nodes that are needed to farm the plant
-- def should define these fields:
--
--   plant_textures: a list with the textures for the plants
--
--   seed_description: the tooltip of the seed
--                     not needed if plant_harvested is true
--   seed_texture: the texture of the seed
--                 not needed if plant_harvested is true
--   seed_rarity: a list with the inverted chance to get one more seed
--                not needed if plant_harvested is true
--
--   plant_harvested: if true there are no seeds and you plant the plant by
--                    placing the harvested item on soil
--   plowing_rarity: inverted chance to get the seed when plowing grass
--
--   item_description: the tooltip of the harvested item
--   item_texture: the texture of the harvested item
--   item_rarity: a list with the inverted chance to get one more item
--
--   growing_intervals: number of 60 sec intervals to the next growing step
--                     note: there are cases where single intervals are skipped
--   growing_light: the light value the plant needs to grow
function farming:register_plant(name, def)
	
	-- add it to the registered_plants table
	farming.registered_plants[name] = def
	
	-- places the seed if the player points at soil
	local function place_seed(itemstack, placer, pointed_thing)
		local pt = pointed_thing
		-- check if pointing at a node
		if not pt then
			return
		end
		if pt.type ~= "node" then
			return
		end
		
		local under = minetest.env:get_node(pt.under)
		local above = minetest.env:get_node(pt.above)
		
		-- return if any of the nodes is not registered
		if not minetest.registered_nodes[under.name] then
			return
		end
		if not minetest.registered_nodes[above.name] then
			return
		end
		
		-- check if pointing at the top of the node
		if pt.above.y ~= pt.under.y+1 then
			return
		end
		
		-- check if you can replace the node above the pointed node
		if not minetest.registered_nodes[above.name].buildable_to then
			return
		end
		
		-- check if pointing at soil
		if minetest.get_item_group(under.name, "soil") == 0 then
			return
		end
		
		-- add the node and remove 1 item from the itemstack
		minetest.env:add_node(pt.above, {name=name.."_1"})
		itemstack:take_item()
		return itemstack
	end
	
	if def.plant_harvested then
		-- add the harvested item to the seeds table if its not 0
		if def.plowing_rarity ~= 0 then
			table.insert(seeds, {name=name, rarity=def.plowing_rarity})
		end
		
		-- register the harvested item
		minetest.register_craftitem(name, {
			description = def.item_description,
			inventory_image = def.item_texture,
			on_place = place_seed,
		})
	else
		-- register the seed
		minetest.register_craftitem(name.."_seed", {
			description = def.seed_description,
			inventory_image = def.seed_texture,
			on_place = place_seed,
		})
		
		-- add the seed to the seeds table if its not 0
		if def.plowing_rarity ~= 0 then
			table.insert(seeds, {name=name.."_seed", rarity=def.plowing_rarity})
		end
		
		-- register the harvested item
		minetest.register_craftitem(name, {
			description = def.item_description,
			inventory_image = def.item_texture,
		})
	end
	
	-- register the growing states
	local i
	local growing_states = {} -- contains the names of the nodes
	for i=1, #def.plant_textures-1 do
		local plant_state = #def.plant_textures-i+1
		local drop = ""
		-- if its the last growing state drop seeds with a rarity of 30%
		if plant_state == 2 then
			if def.plant_harvested then
				drop = {
					items = {
						{items ={name}, rarity = 3}
					}
				}
			else
				drop = {
					items = {
						{items ={name.."_seed"}, rarity = 3}
					}
				}
			end
		end
		
		minetest.register_node(name.."_"..i, {
			drawtype = "plantlike",
			tiles = {def.plant_textures[i]},
			paramtype = "light",
			walkable = false,
			drop = drop,
			selection_box = {
				type = "fixed",
				fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
			},
			groups = {snappy=3, flammable=2, not_in_creative_inventory=1, plant=plant_state},
			sounds = default.node_sound_leaves_defaults(),
		})
		table.insert(growing_states, name.."_"..i)
	end
	
	-- add the drops from the definition table to the drop table for the node
	local drop = { items = {} }
	for _,rarity in ipairs(def.item_rarity) do
		if rarity ~= 0 then
			table.insert(drop.items, {items={name}, rarity=rarity})
		end
	end
	if not def.plant_harvested then
		for _,rarity in ipairs(def.seed_rarity) do
			if rarity ~= 0 then
				table.insert(drop.items, {items={name.."_seed"}, rarity=rarity})
			end
		end
	end
	
	-- register the full grown state
	i = #def.plant_textures
	
	minetest.register_node(name.."_"..i, {
		drawtype = "plantlike",
		tiles = {def.plant_textures[i]},
		paramtype = "light",
		walkable = false,
		drop = drop,
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		groups = {snappy=3, flammable=2, not_in_creative_inventory=1, plant=1},
		sounds = default.node_sound_leaves_defaults(),
	})
	
	-- register the growing abm
	minetest.register_abm({
		nodenames = growing_states,
		neighbors = {"group:soil"},
		interval = 60,
		chance = 1,
		action = function(pos, node)
			-- return with a probability of 15%
			if math.random(1, 100) <= 15 then
				return
			end
			
			-- check if on wet soil
			pos.y = pos.y-1
			local n = minetest.env:get_node(pos)
			if minetest.get_item_group(n.name, "soil") ~= 1 then
				return
			end
			pos.y = pos.y+1
			
			-- check light
			if not minetest.env:get_node_light(pos) then
				return
			end
			if minetest.env:get_node_light(pos) < def.growing_light then
				return
			end
			
			-- get the number of 60 sec intervals the node has passed
			local meta = minetest.env:get_meta(pos)
			local intervals = meta:get_int("farming_grow_intervals")
			
			-- increase it and look if its the wanted value
			intervals = intervals+1
			meta:set_int("farming_grow_intervals", intervals)
			if intervals < def.growing_intervals then
				return
			end
			
			-- grow
			farming:grow_plant(pos)
		end
	})
	
end

-- let a plant grow; this does not check light or something like that so
-- it can be used for fertilizer
-- returns: the number of states until full grown (after this function)
function farming:grow_plant(pos)
	local node = minetest.env:get_node(pos)
	local name = string.sub(node.name, 1, #node.name-2)
	
	-- if this node is not registered
	if not farming.registered_plants[name] then
		return 0
	end
	
	-- get the current grow state
	local state = minetest.get_item_group(node.name, "plant")
	
	-- if the node is not a plant
	if not state or state == 0 then
		return 0
	end
	
	-- return if the node is full grown
	if state == 1 then
		return 0
	end
	
	-- get the nodenumber from the growing state
	local i = -state+#farming.registered_plants[name].plant_textures+1
	
	-- replace the node with the next growing state
	minetest.env:set_node(pos, {name=name.."_"..i+1})
	return state-2
end

--
-- Hoes
--

-- turns dirt and grass into soil; drop seeds if plowing grass
local function hoe_on_use(itemstack, user, pointed_thing, uses)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end
	
	local under = minetest.env:get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.env:get_node(p)
	
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end
	
	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end
	
	-- check if pointing at dirt
	if under.name ~= "default:dirt" and under.name ~= "default:dirt_with_grass" then
		return
	end
	
	-- if pointing at grass drop seeds
	if under.name == "default:dirt_with_grass" then
		for _,drop in ipairs(seeds) do
			if math.random(1, drop.rarity) == 1 then
				user:get_inventory():add_item("main", drop.name)
			end
		end
	end
	
	-- turn the node into soil, wear out item and play sound
	minetest.env:set_node(pt.under, {name="farming:soil"})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})
	itemstack:add_wear(65535/(uses-1))
	return itemstack
end

minetest.register_tool("farming:hoe_wood", {
	description = "Wooden Hoe",
	inventory_image = "farming_tool_woodhoe.png",
	
	on_use = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 30)
	end,
})

minetest.register_tool("farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_tool_stonehoe.png",
	
	on_use = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 90)
	end,
})

minetest.register_tool("farming:hoe_steel", {
	description = "Steel Hoe",
	inventory_image = "farming_tool_steelhoe.png",
	
	on_use = function(itemstack, user, pointed_thing)
		return hoe_on_use(itemstack, user, pointed_thing, 200)
	end,
})

minetest.register_craft({
	output = "farming:hoe_wood",
	recipe = {
		{"default:wood", "default:wood"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

minetest.register_craft({
	output = "farming:hoe_stone",
	recipe = {
		{"default:cobble", "default:cobble"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

minetest.register_craft({
	output = "farming:hoe_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"", "default:stick"},
		{"", "default:stick"},
	}
})

--
-- Soil
--

minetest.register_node("farming:soil", {
	description = "Soil",
	tiles = {"farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("farming:soil_wet", {
	description = "Wet Soil",
	tiles = {"farming_soil_wet.png", "farming_soil_wet_side.png"},
	drop = "default:dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_abm({
	nodenames = {"group:soil"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		-- check if there is water nearby
		if minetest.env:find_node_near(pos, 4, {"group:water"}) then
			-- if it is dry soil turn it into wet soil
			if minetest.get_item_group(node.name, "soil") == 2 then
				minetest.env:set_node(pos, {name="farming:soil_wet"})
			end
		else
			-- turn it back into dirt if it is already dry
			if minetest.get_item_group(node.name, "soil") == 2 then
				-- only turn it back if there is no plant on top of it
				pos.y = pos.y+1
				local nn = minetest.env:get_node(pos).name
				pos.y = pos.y-1
				if minetest.get_item_group(nn, "plant") == 0 then
					minetest.env:set_node(pos, {name="default:dirt"})
				end
				
			-- if its wet turn it back into dry soil
			elseif minetest.get_item_group(node.name, "soil") == 1 then
				minetest.env:set_node(pos, {name="farming:soil"})
			end
		end
	end,
})

--
-- Wheat
--

farming:register_plant("farming:wheat", {
	plant_textures = {
		"farming_wheat_1.png",
		"farming_wheat_2.png",
		"farming_wheat_3.png",
		"farming_wheat_4.png",
		"farming_wheat_5.png",
		"farming_wheat_6.png",
		"farming_wheat_7.png",
		"farming_wheat_8.png"
	},
	
	item_description = "Wheat",
	item_texture = "farming_wheat.png",
	item_rarity = {1, 1, 4, 10},
	
	plant_harvested = true,
	plowing_rarity = 10,
	
	growing_intervals = 3,
	growing_light = 10,
})

minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
})

minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {"farming:wheat"}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:bread",
	recipe = "farming:flour"
})
