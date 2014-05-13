local vertical_box = {
	type = "fixed",
	fixed = {-1/16, -8/16, -1/16, 1/16, 8/16, 1/16}
}

local top_box = {
	type = "fixed",
	fixed = {{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}}
}

local bottom_box = {
	type = "fixed",
	fixed = {
		{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		{-1/16, -7/16, -1/16, 1/16, 8/16, 1/16},
	}
}

local vertical_rules = {
	{x=0, y=1, z=0},
	{x=0, y=-1, z=0},
}

local top_rules = {
	{x=1,y=0, z=0},
	{x=-1,y=0, z=0},
	{x=0,y=0, z=1},
	{x=0,y=0, z=-1},
	{x=0,y=-1, z=0},
}

local bottom_rules = {
	{x=1, y=0, z=0},
	{x=-1, y=0, z=0},
	{x=0, y=0, z=1},
	{x=0, y=0, z=-1},
	{x=0, y=1, z=0},
}

local vertical_updatepos = function (pos)
	local node = minetest.get_node(pos)
	if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].is_vertical_conductor then
		local node_above = minetest.get_node(mesecon:addPosRule(pos, vertical_rules[1]))
		local node_below = minetest.get_node(mesecon:addPosRule(pos, vertical_rules[2]))
		local namestate = minetest.registered_nodes[node.name].vertical_conductor_state

		local above = minetest.registered_nodes[node_above.name] and minetest.registered_nodes[node_above.name].is_vertical_conductor
		local below = minetest.registered_nodes[node_below.name] and minetest.registered_nodes[node_below.name].is_vertical_conductor

		if above and below then -- above and below: vertical mesecon
			minetest.add_node(pos, {name = "mesecons_extrawires:vertical_" .. namestate})
		elseif above and not below then -- above only: bottom
			minetest.add_node(pos, {name = "mesecons_extrawires:vertical_bottom_" .. namestate})
		elseif not above and below then -- below only: top
			minetest.add_node(pos, {name = "mesecons_extrawires:vertical_top_" .. namestate})
		else -- no vertical wire above, no vertical wire below: use default wire
			minetest.add_node(pos, {name = "mesecons_extrawires:vertical_" .. namestate})
		end
	end
end

local vertical_update = function (pos, node)
	vertical_updatepos(pos) -- this one
	vertical_updatepos(mesecon:addPosRule(pos, vertical_rules[1])) -- above
	vertical_updatepos(mesecon:addPosRule(pos, vertical_rules[2])) -- below
end

-- Vertical wire
minetest.register_node("mesecons_extrawires:vertical_on", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_vertical_on.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	selection_box = vertical_box,
	node_box = vertical_box,
	is_vertical_conductor = true,
	vertical_conductor_state = "on",
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:vertical_off",
		rules = vertical_rules,
	}},
	drop = "mesecons_extrawires:vertical_off",
	after_place_node = vertical_update,
	after_dig_node = vertical_update,
})

minetest.register_node("mesecons_extrawires:vertical_off", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_vertical_off.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate=3},
	selection_box = vertical_box,
	node_box = vertical_box,
	is_vertical_conductor = true,
	vertical_conductor_state = "off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:vertical_on",
		rules = vertical_rules,
	}},
	after_place_node = vertical_update,
	after_dig_node = vertical_update,
})

-- Vertical wire top
minetest.register_node("mesecons_extrawires:vertical_top_on", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_on.png","wires_full_on.png","wires_vertical_on.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	selection_box = top_box,
	node_box = top_box,
	is_vertical_conductor = true,
	vertical_conductor_state = "on",
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:vertical_top_off",
		rules = top_rules,
	}},
	drop = "mesecons_extrawires:vertical_off",
	after_place_node = vertical_update,
	after_dig_node = vertical_update,
})

minetest.register_node("mesecons_extrawires:vertical_top_off", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_off.png","wires_full_off.png","wires_vertical_off.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	selection_box = top_box,
	node_box = top_box,
	is_vertical_conductor = true,
	vertical_conductor_state = "off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:vertical_top_on",
		rules = top_rules,
	}},
	drop = "mesecons_extrawires:vertical_off",
	after_place_node = vertical_update,
	after_dig_node = vertical_update,
})

-- Vertical wire bottom
minetest.register_node("mesecons_extrawires:vertical_bottom_on", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_on.png","wires_full_on.png","wires_vertical_on.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	vertical_conductor_state = "on",
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = bottom_box,
	node_box = bottom_box,
	mesecons = {conductor = {
		state = mesecon.state.on,
		offstate = "mesecons_extrawires:vertical_bottom_off",
		rules = bottom_rules,
	}},
	drop = "mesecons_extrawires:vertical_off",
	after_place_node = vertical_update,
	after_dig_node = vertical_update,
})

minetest.register_node("mesecons_extrawires:vertical_bottom_off", {
	description = "Vertical mesecon",
	drawtype = "nodebox",
	tiles = {"wires_full_off.png","wires_full_off.png","wires_vertical_off.png"},
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	selection_box = bottom_box,
	node_box = bottom_box,
	is_vertical_conductor = true,
	vertical_conductor_state = "off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		onstate = "mesecons_extrawires:vertical_bottom_on",
		rules = bottom_rules,
	}},
	drop = "mesecons_extrawires:vertical_off",
	after_place_node = vertical_update,
	after_dig_node = vertical_update,
})

minetest.register_craft({
	output = "mesecons_extrawires:vertical_off 3",
	recipe = {
		{"mesecons:wire_00000000_off"},
		{"mesecons:wire_00000000_off"},
		{"mesecons:wire_00000000_off"}
	}
})

minetest.register_craft({
	output = "mesecons:wire_00000000_off",
	recipe = {{"mesecons_extrawires:vertical_off"}}
})
