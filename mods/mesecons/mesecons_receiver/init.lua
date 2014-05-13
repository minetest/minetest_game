rcvboxes = {
	{ -3/16, -3/16   , -8/16       , 3/16,     3/16, -13/32       }, -- the smaller bump	
	{ -1/32, -1/32   , -3/2        , 1/32,     1/32, -1/2         }, -- the wire through the block
	{ -2/32, -.5-1/32, -.5         , 2/32,    0    , -.5002+3/32  }, -- the vertical wire bit
	{ -2/32, -17/32  , -7/16+0.002 , 2/32,   -14/32,  16/32+0.001 }  -- the horizontal wire
}

local receiver_get_rules = function (node)
	local rules = {	{x =  1, y = 0, z = 0},
			{x = -2, y = 0, z = 0}}
	if node.param2 == 2 then
		rules = mesecon:rotate_rules_left(rules)
	elseif node.param2 == 3 then
		rules = mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	elseif node.param2 == 0 then
		rules = mesecon:rotate_rules_right(rules)
	end
	return rules
end

minetest.register_node("mesecons_receiver:receiver_on", {
	drawtype = "nodebox",
	tiles = {
		"receiver_top_on.png",
		"receiver_bottom_on.png",
		"receiver_lr_on.png",
		"receiver_lr_on.png",
		"receiver_fb_on.png",
		"receiver_fb_on.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
             	type = "fixed",
		fixed = { -3/16, -8/16, -8/16, 3/16, 3/16, 8/16 }
	},
	node_box = {
		type = "fixed",
		fixed = rcvboxes
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons:wire_00000000_off",
	mesecons = {conductor = {
		state = mesecon.state.on,
		rules = receiver_get_rules,
		offstate = "mesecons_receiver:receiver_off"
	}}
})

minetest.register_node("mesecons_receiver:receiver_off", {
	drawtype = "nodebox",
	description = "You hacker you",
	tiles = {
		"receiver_top_off.png",
		"receiver_bottom_off.png",
		"receiver_lr_off.png",
		"receiver_lr_off.png",
		"receiver_fb_off.png",
		"receiver_fb_off.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
             	type = "fixed",
		fixed = { -3/16, -8/16, -8/16, 3/16, 3/16, 8/16 }
	},
	node_box = {
		type = "fixed",
		fixed = rcvboxes
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "mesecons:wire_00000000_off",
	mesecons = {conductor = {
		state = mesecon.state.off,
		rules = receiver_get_rules,
		onstate = "mesecons_receiver:receiver_on"
	}}
})

mesecon:add_rules("receiver_pos", {{x = 2,  y = 0, z = 0}})

mesecon:add_rules("receiver_pos_all", {
{x = 2,  y = 0, z = 0},
{x =-2,  y = 0, z = 0},
{x = 0,  y = 0, z = 2},
{x = 0,  y = 0, z =-2}})

function mesecon:receiver_get_pos_from_rcpt(pos, param2)
	local rules = mesecon:get_rules("receiver_pos")
	if param2 == nil then param2 = minetest.get_node(pos).param2 end
	if param2 == 2 then
		rules = mesecon:rotate_rules_left(rules)
	elseif param2 == 3 then
		rules = mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	elseif param2 == 0 then
		rules = mesecon:rotate_rules_right(rules)
	end
	np = {
	x = pos.x + rules[1].x,
	y = pos.y + rules[1].y,
	z = pos.z + rules[1].z}
	return np
end

function mesecon:receiver_place(rcpt_pos)
	local node = minetest.get_node(rcpt_pos)
	local pos = mesecon:receiver_get_pos_from_rcpt(rcpt_pos, node.param2)
	local nn = minetest.get_node(pos)

	if string.find(nn.name, "mesecons:wire_") ~= nil then
		minetest.dig_node(pos)
		if mesecon:is_power_on(rcpt_pos) then
			minetest.add_node(pos, {name = "mesecons_receiver:receiver_on", param2 = node.param2})
			mesecon:receptor_on(pos, receiver_get_rules(node))
		else
			minetest.add_node(pos, {name = "mesecons_receiver:receiver_off", param2 = node.param2})
		end
		mesecon:update_autoconnect(pos)
	end
end

function mesecon:receiver_remove(rcpt_pos, dugnode)
	local pos = mesecon:receiver_get_pos_from_rcpt(rcpt_pos, dugnode.param2)
	local nn = minetest.get_node(pos)
	if string.find(nn.name, "mesecons_receiver:receiver_") ~=nil then
		minetest.dig_node(pos)
		local node = {name = "mesecons:wire_00000000_off"}
		minetest.add_node(pos, node)
		mesecon:update_autoconnect(pos)
		mesecon.on_placenode(pos, node)
	end
end

minetest.register_on_placenode(function (pos, node)
	if minetest.get_item_group(node.name, "mesecon_needs_receiver") == 1 then
		mesecon:receiver_place(pos)
	end
end)

minetest.register_on_dignode(function(pos, node)
	if minetest.get_item_group(node.name, "mesecon_needs_receiver") == 1 then
		mesecon:receiver_remove(pos, node)
	end
end)

minetest.register_on_placenode(function (pos, node)
	if string.find(node.name, "mesecons:wire_") ~=nil then
		rules = mesecon:get_rules("receiver_pos_all")
		local i = 1
		while rules[i] ~= nil do
			np = {
			x = pos.x + rules[i].x,
			y = pos.y + rules[i].y,
			z = pos.z + rules[i].z}
			if minetest.get_item_group(minetest.get_node(np).name, "mesecon_needs_receiver") == 1 then
				mesecon:receiver_place(np)
			end
			i = i + 1
		end
	end
end)
