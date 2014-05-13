function gate_rotate_rules(node)
	for rotations = 0, node.param2 - 1 do
		rules = mesecon:rotate_rules_left(rules)
	end
	return rules
end

function gate_get_output_rules(node)
	rules = {{x=1, y=0, z=0}}
	return gate_rotate_rules(node)
end

function gate_get_input_rules_oneinput(node)
	rules = {{x=-1, y=0, z=0}, {x=1, y=0, z=0}}
	return gate_rotate_rules(node)
end

function gate_get_input_rules_twoinputs(node)
	rules = {
	{x=0, y=0, z=1},
	{x=0, y=0, z=-1},
	{x=1, y=0, z=0}}
	return gate_rotate_rules(node)
end

function update_gate(pos, node, rulename, newstate)
	yc_update_real_portstates(pos, node, rulename, newstate)
	gate = get_gate(pos)
	L = rotate_ports(
		yc_get_real_portstates(pos),
		minetest.get_node(pos).param2
	)
	if gate == "diode" then
		set_gate(pos, L.a)
	elseif gate == "not" then
		set_gate(pos, not L.a)
	elseif gate == "nand" then
		set_gate(pos, not(L.b and L.d))
	elseif gate == "and" then
		set_gate(pos, L.b and L.d)
	elseif gate == "xor" then
		set_gate(pos, (L.b and not L.d) or (not L.b and L.d))
	end
end

function set_gate(pos, on)
	gate = get_gate(pos)
	local meta = minetest.get_meta(pos)
	if on ~= gate_state(pos) then
		yc_heat(meta)
		--minetest.after(0.5, yc_cool, meta)
		if yc_overheat(meta) then
			pop_gate(pos)
		else
			local node = minetest.get_node(pos)
			if on then
				minetest.swap_node(pos, {name = "mesecons_gates:"..gate.."_on", param2=node.param2})
				mesecon:receptor_on(pos,
				gate_get_output_rules(node))
			else
				minetest.swap_node(pos, {name = "mesecons_gates:"..gate.."_off", param2=node.param2})
				mesecon:receptor_off(pos,
				gate_get_output_rules(node))
			end
		end
	end
end

function get_gate(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name].mesecons_gate
end

function gate_state(pos)
	name = minetest.get_node(pos).name
	return string.find(name, "_on") ~= nil
end

function pop_gate(pos)
	gate = get_gate(pos)
	minetest.remove_node(pos)
	minetest.after(0.2, yc_overheat_off, pos)
	minetest.add_item(pos, "mesecons_gates:"..gate.."_off")
end

function rotate_ports(L, param2)
	for rotations=0, param2-1 do
		port = L.a
		L.a = L.b
		L.b = L.c
		L.c = L.d
		L.d = port
	end
	return L
end

gates = {
{name = "diode", inputnumber = 1}, 
{name = "not"  , inputnumber = 1}, 
{name = "nand" , inputnumber = 2},
{name = "and"  , inputnumber = 2},
{name = "xor"  , inputnumber = 2}}

local onoff, drop, nodename, description, groups
for _, gate in ipairs(gates) do
	if gate.inputnumber == 1 then
		get_rules = gate_get_input_rules_oneinput
	elseif gate.inputnumber == 2 then
		get_rules = gate_get_input_rules_twoinputs
	end
	for on = 0, 1 do
		nodename = "mesecons_gates:"..gate.name
		if on == 1 then
			onoff = "on"
			drop = nodename.."_off"
			nodename = nodename.."_"..onoff
			description = "You hacker you!"
			groups = {dig_immediate=2, not_in_creative_inventory=1, overheat = 1}
		else
			onoff = "off"
			drop = nil
			nodename = nodename.."_"..onoff
			description = gate.name.." Gate"
			groups = {dig_immediate=2, overheat = 1}
		end

		tiles = "jeija_microcontroller_bottom.png^"..
			"jeija_gate_"..onoff..".png^"..
			"jeija_gate_"..gate.name..".png"

		node_box = {
			type = "fixed",
			fixed = {
				{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
			},
		}

		local mesecon_state
		if on == 1 then
			mesecon_state = mesecon.state.on
		else
			mesecon_state = mesecon.state.off
		end

		minetest.register_node(nodename, {
			description = description,
			paramtype = "light",
			paramtype2 = "facedir",
			drawtype = "nodebox",
			tiles = {tiles},
			inventory_image = tiles,
			selection_box = node_box,
			node_box = node_box,
			walkable = true,
			on_construct = function(pos)
				local meta = minetest.get_meta(pos)
				meta:set_int("heat", 0)
				update_gate(pos)
			end,
			groups = groups,
			drop = drop,
			sounds = default.node_sound_stone_defaults(),
			mesecons_gate = gate.name,
			mesecons =
			{
				receptor =
				{
					state = mesecon_state,
					rules = gate_get_output_rules
				},
				effector =
				{
					rules = get_rules,
					action_change = update_gate
				}
			}
		})
	end
end

minetest.register_craft({
	output = 'mesecons_gates:diode_off',
	recipe = {
		{'', '', ''},
		{'mesecons:mesecon', 'mesecons_torch:mesecon_torch_on', 'mesecons_torch:mesecon_torch_on'},
		{'', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:not_off',
	recipe = {
		{'', '', ''},
		{'mesecons:mesecon', 'mesecons_torch:mesecon_torch_on', 'mesecons:mesecon'},
		{'', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:and_off',
	recipe = {
		{'mesecons:mesecon', '', ''},
		{'', 'mesecons_materials:silicon', 'mesecons:mesecon'},
		{'mesecons:mesecon', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:nand_off',
	recipe = {
		{'mesecons:mesecon', '', ''},
		{'', 'mesecons_materials:silicon', 'mesecons_torch:mesecon_torch_on'},
		{'mesecons:mesecon', '', ''},
	},
})

minetest.register_craft({
	output = 'mesecons_gates:xor_off',
	recipe = {
		{'mesecons:mesecon', '', ''},
		{'', 'mesecons_materials:silicon', 'mesecons_materials:silicon'},
		{'mesecons:mesecon', '', ''},
	},
})

