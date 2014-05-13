-- Internal.lua - The core of mesecons
--
-- For more practical developer resources see mesecons.tk
--
-- Function overview
-- mesecon:get_effector(nodename)     --> Returns the mesecons.effector -specifictation in the nodedef by the nodename
-- mesecon:get_receptor(nodename)     --> Returns the mesecons.receptor -specifictation in the nodedef by the nodename
-- mesecon:get_conductor(nodename)    --> Returns the mesecons.conductor-specifictation in the nodedef by the nodename
-- mesecon:get_any_inputrules (node)  --> Returns the rules of a node if it is a conductor or an effector
-- mesecon:get_any_outputrules (node) --> Returns the rules of a node if it is a conductor or a receptor

-- RECEPTORS
-- mesecon:is_receptor(nodename)     --> Returns true if nodename is a receptor
-- mesecon:is_receptor_on(nodename)  --> Returns true if nodename is an receptor with state = mesecon.state.on
-- mesecon:is_receptor_off(nodename) --> Returns true if nodename is an receptor with state = mesecon.state.off
-- mesecon:receptor_get_rules(node)  --> Returns the rules of the receptor (mesecon.rules.default if none specified)

-- EFFECTORS
-- mesecon:is_effector(nodename)     --> Returns true if nodename is an effector
-- mesecon:is_effector_on(nodename)  --> Returns true if nodename is an effector with nodedef.mesecons.effector.action_off
-- mesecon:is_effector_off(nodename) --> Returns true if nodename is an effector with nodedef.mesecons.effector.action_on
-- mesecon:effector_get_rules(node)  --> Returns the input rules of the effector (mesecon.rules.default if none specified)

-- SIGNALS
-- mesecon:activate(pos, node, recdepth)		--> Activates   the effector node at the specific pos (calls nodedef.mesecons.effector.action_on), higher recdepths are executed later
-- mesecon:deactivate(pos, node, recdepth)		--> Deactivates the effector node at the specific pos (calls nodedef.mesecons.effector.action_off), "
-- mesecon:changesignal(pos, node, rulename, newstate)	--> Changes     the effector node at the specific pos (calls nodedef.mesecons.effector.action_change), "

-- RULES
-- mesecon:add_rules(name, rules) | deprecated? --> Saves rules table by name
-- mesecon:get_rules(name, rules) | deprecated? --> Loads rules table with name

-- CONDUCTORS
-- mesecon:is_conductor(nodename)     --> Returns true if nodename is a conductor
-- mesecon:is_conductor_on(node)  --> Returns true if node is a conductor with state = mesecon.state.on
-- mesecon:is_conductor_off(node) --> Returns true if node is a conductor with state = mesecon.state.off
-- mesecon:get_conductor_on(node_off) --> Returns the onstate  nodename of the conductor
-- mesecon:get_conductor_off(node_on) --> Returns the offstate nodename of the conductor
-- mesecon:conductor_get_rules(node)  --> Returns the input+output rules of a conductor (mesecon.rules.default if none specified)

-- HIGH-LEVEL Internals
-- mesecon:is_power_on(pos)             --> Returns true if pos emits power in any way
-- mesecon:is_power_off(pos)            --> Returns true if pos does not emit power in any way
-- mesecon:turnon(pos, rulename)        --> Returns true  whatever there is at pos. Calls itself for connected nodes (if pos is a conductor) --> recursive, the rulename is the name of the input rule that caused calling turnon; Uses third parameter recdepth internally to determine how far away the current node is from the initial pos as it uses recursion
-- mesecon:turnoff(pos, rulename)       --> Turns off whatever there is at pos. Calls itself for connected nodes (if pos is a conductor) --> recursive, the rulename is the name of the input rule that caused calling turnoff; Uses third parameter recdepth internally to determine how far away the current node is from the initial pos as it uses recursion
-- mesecon:connected_to_receptor(pos)   --> Returns true if pos is connected to a receptor directly or via conductors; calls itself if pos is a conductor --> recursive
-- mesecon:rules_link(output, input, dug_outputrules) --> Returns true if outputposition + outputrules = inputposition and inputposition + inputrules = outputposition (if the two positions connect)
-- mesecon:rules_link_anydir(outp., inp., d_outpr.)   --> Same as rules mesecon:rules_link but also returns true if output and input are swapped
-- mesecon:is_powered(pos)              --> Returns true if pos is powered by a receptor or a conductor

-- RULES ROTATION helpsers
-- mesecon:rotate_rules_right(rules)
-- mesecon:rotate_rules_left(rules)
-- mesecon:rotate_rules_up(rules)
-- mesecon:rotate_rules_down(rules)
-- These functions return rules that have been rotated in the specific direction

-- General
function mesecon:get_effector(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.effector then
		return minetest.registered_nodes[nodename].mesecons.effector
	end
end

function mesecon:get_receptor(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.receptor then
		return minetest.registered_nodes[nodename].mesecons.receptor
	end
end

function mesecon:get_conductor(nodename)
	if  minetest.registered_nodes[nodename]
	and minetest.registered_nodes[nodename].mesecons
	and minetest.registered_nodes[nodename].mesecons.conductor then
		return minetest.registered_nodes[nodename].mesecons.conductor
	end
end

function mesecon:get_any_outputrules (node)
	if mesecon:is_conductor(node.name) then
		return mesecon:conductor_get_rules(node)
	elseif mesecon:is_receptor(node.name) then
		return mesecon:receptor_get_rules(node)
	end
	return false
end

function mesecon:get_any_inputrules (node)
	if mesecon:is_conductor(node.name) then
		return mesecon:conductor_get_rules(node)
	elseif mesecon:is_effector(node.name) then
		return mesecon:effector_get_rules(node)
	end
	return false
end

-- Receptors
-- Nodes that can power mesecons
function mesecon:is_receptor_on(nodename)
	local receptor = mesecon:get_receptor(nodename)
	if receptor and receptor.state == mesecon.state.on then
		return true
	end
	return false
end

function mesecon:is_receptor_off(nodename)
	local receptor = mesecon:get_receptor(nodename)
	if receptor and receptor.state == mesecon.state.off then
		return true
	end
	return false
end

function mesecon:is_receptor(nodename)
	local receptor = mesecon:get_receptor(nodename)
	if receptor then
		return true
	end
	return false
end

function mesecon:receptor_get_rules(node)
	local receptor = mesecon:get_receptor(node.name)
	if receptor then
		local rules = receptor.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end

	return mesecon.rules.default
end

-- Effectors
-- Nodes that can be powered by mesecons
function mesecon:is_effector_on(nodename)
	local effector = mesecon:get_effector(nodename)
	if effector and effector.action_off then
		return true
	end
	return false
end

function mesecon:is_effector_off(nodename)
	local effector = mesecon:get_effector(nodename)
	if effector and effector.action_on then
		return true
	end
	return false
end

function mesecon:is_effector(nodename)
	local effector = mesecon:get_effector(nodename)
	if effector then
		return true
	end
	return false
end

function mesecon:effector_get_rules(node)
	local effector = mesecon:get_effector(node.name)
	if effector then
		local rules = effector.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	return mesecon.rules.default
end

-- #######################
-- # Signals (effectors) #
-- #######################

-- Activation:
mesecon.queue:add_function("activate", function (pos, rulename)
	node = minetest.get_node(pos)
	effector = mesecon:get_effector(node.name)

	if effector and effector.action_on then
		effector.action_on(pos, node, rulename)
	end
end)

function mesecon:activate(pos, node, rulename, recdepth)
	if rulename == nil then
		for _,rule in ipairs(mesecon:effector_get_rules(node)) do
			mesecon:activate(pos, node, rule, recdepth + 1)
		end
		return
	end
	mesecon.queue:add_action(pos, "activate", {rulename}, nil, rulename, 1 / recdepth)
end


-- Deactivation
mesecon.queue:add_function("deactivate", function (pos, rulename)
	node = minetest.get_node(pos)
	effector = mesecon:get_effector(node.name)

	if effector and effector.action_off then
		effector.action_off(pos, node, rulename)
	end
end)

function mesecon:deactivate(pos, node, rulename, recdepth)
	if rulename == nil then
		for _,rule in ipairs(mesecon:effector_get_rules(node)) do
			mesecon:deactivate(pos, node, rule, recdepth + 1)
		end
		return
	end
	mesecon.queue:add_action(pos, "deactivate", {rulename}, nil, rulename, 1 / recdepth)
end


-- Change
mesecon.queue:add_function("change", function (pos, rulename, changetype)
	node = minetest.get_node(pos)
	effector = mesecon:get_effector(node.name)

	if effector and effector.action_change then
		effector.action_change(pos, node, rulename, changetype)
	end
end)

function mesecon:changesignal(pos, node, rulename, newstate, recdepth)
	if rulename == nil then
		for _,rule in ipairs(mesecon:effector_get_rules(node)) do
			mesecon:changesignal(pos, node, rule, newstate, recdepth + 1)
		end
		return
	end

	mesecon.queue:add_action(pos, "change", {rulename, newstate}, nil, rulename, 1 / recdepth)
end

-- #########
-- # Rules # "Database" for rulenames
-- #########

function mesecon:add_rules(name, rules)
	mesecon.rules[name] = rules
end

function mesecon:get_rules(name)
	return mesecon.rules[name]
end

-- Conductors

function mesecon:is_conductor_on(node, rulename)
	local conductor = mesecon:get_conductor(node.name)
	if conductor then
		if conductor.state then
			return conductor.state == mesecon.state.on
		end
		if conductor.states then
			if not rulename then
				return mesecon:getstate(node.name, conductor.states) ~= 1
			end
			local bit = mesecon:rule2bit(rulename, mesecon:conductor_get_rules(node))
			local binstate = mesecon:getbinstate(node.name, conductor.states)
			return mesecon:get_bit(binstate, bit)
		end
	end
	return false
end

function mesecon:is_conductor_off(node, rulename)
	local conductor = mesecon:get_conductor(node.name)
	if conductor then
		if conductor.state then
			return conductor.state == mesecon.state.off
		end
		if conductor.states then
			if not rulename then
				return mesecon:getstate(node.name, conductor.states) == 1
			end
			local bit = mesecon:rule2bit(rulename, mesecon:conductor_get_rules(node))
			local binstate = mesecon:getbinstate(node.name, conductor.states)
			return not mesecon:get_bit(binstate, bit)
		end
	end
	return false
end

function mesecon:is_conductor(nodename)
	local conductor = mesecon:get_conductor(nodename)
	if conductor then
		return true
	end
	return false
end

function mesecon:get_conductor_on(node_off, rulename)
	local conductor = mesecon:get_conductor(node_off.name)
	if conductor then
		if conductor.onstate then
			return conductor.onstate
		end
		if conductor.states then
			local bit = mesecon:rule2bit(rulename, mesecon:conductor_get_rules(node_off))
			local binstate = mesecon:getbinstate(node_off.name, conductor.states)
			binstate = mesecon:set_bit(binstate, bit, "1")
			return conductor.states[tonumber(binstate,2)+1]
		end
	end
	return offstate
end

function mesecon:get_conductor_off(node_on, rulename)
	local conductor = mesecon:get_conductor(node_on.name)
	if conductor then
		if conductor.offstate then
			return conductor.offstate
		end
		if conductor.states then
			local bit = mesecon:rule2bit(rulename, mesecon:conductor_get_rules(node_on))
			local binstate = mesecon:getbinstate(node_on.name, conductor.states)
			binstate = mesecon:set_bit(binstate, bit, "0")
			return conductor.states[tonumber(binstate,2)+1]
		end
	end
	return onstate
end

function mesecon:conductor_get_rules(node)
	local conductor = mesecon:get_conductor(node.name)
	if conductor then
		local rules = conductor.rules
		if type(rules) == 'function' then
			return rules(node)
		elseif rules then
			return rules
		end
	end
	return mesecon.rules.default
end

-- some more general high-level stuff

function mesecon:is_power_on(pos, rulename)
	local node = minetest.get_node(pos)
	if mesecon:is_conductor_on(node, rulename) or mesecon:is_receptor_on(node.name) then
		return true
	end
	return false
end

function mesecon:is_power_off(pos, rulename)
	local node = minetest.get_node(pos)
	if mesecon:is_conductor_off(node, rulename) or mesecon:is_receptor_off(node.name) then
		return true
	end
	return false
end

function mesecon:turnon(pos, rulename, recdepth)
	recdepth = recdepth or 2
	local node = minetest.get_node(pos)

	if(node.name == "ignore") then
		-- try turning on later again
		mesecon.queue:add_action(
			pos, "turnon", {rulename, recdepth + 1}, nil, true)
	end
	
	if mesecon:is_conductor_off(node, rulename) then
		local rules = mesecon:conductor_get_rules(node)

		if not rulename then
			for _, rule in ipairs(mesecon:flattenrules(rules)) do
				if mesecon:connected_to_receptor(pos, rule) then
					mesecon:turnon(pos, rule, recdepth + 1)
				end
			end
			return
		end

		minetest.swap_node(pos, {name = mesecon:get_conductor_on(node, rulename), param2 = node.param2})

		for _, rule in ipairs(mesecon:rule2meta(rulename, rules)) do
			local np = mesecon:addPosRule(pos, rule)
			if(minetest.get_node(np).name == "ignore") then
				-- try turning on later again
				mesecon.queue:add_action(
					np, "turnon", {rulename, recdepth + 1}, nil, true)
			else
				local rulenames = mesecon:rules_link_rule_all(pos, rule)

				for _, rulename in ipairs(rulenames) do
					mesecon:turnon(np, rulename, recdepth + 1)
				end
			end
		end
	elseif mesecon:is_effector(node.name) then
		mesecon:changesignal(pos, node, rulename, mesecon.state.on, recdepth)
		if mesecon:is_effector_off(node.name) then
			mesecon:activate(pos, node, rulename, recdepth)
		end
	end
end

mesecon.queue:add_function("turnon", function (pos, rulename, recdepth)
	if (MESECONS_GLOBALSTEP) then -- do not resume if we don't use globalstep - that would cause an endless loop
		mesecon:turnon(pos, rulename, recdepth)
	end
end)

function mesecon:turnoff(pos, rulename, recdepth)
	recdepth = recdepth or 2
	local node = minetest.get_node(pos)

	if(node.name == "ignore") then
		-- try turning on later again
		mesecon.queue:add_action(
			pos, "turnoff", {rulename, recdepth + 1}, nil, true)
	end

	if mesecon:is_conductor_on(node, rulename) then
		local rules = mesecon:conductor_get_rules(node)
		minetest.swap_node(pos, {name = mesecon:get_conductor_off(node, rulename), param2 = node.param2})

		for _, rule in ipairs(mesecon:rule2meta(rulename, rules)) do
			local np = mesecon:addPosRule(pos, rule)
			if(minetest.get_node(np).name == "ignore") then
				-- try turning on later again
				mesecon.queue:add_action(
					np, "turnoff", {rulename, recdepth + 1}, nil, true)
			else
				local rulenames = mesecon:rules_link_rule_all(pos, rule)

				for _, rulename in ipairs(rulenames) do
					mesecon:turnoff(np, rulename, recdepth + 1)
				end
			end
		end
	elseif mesecon:is_effector(node.name) then
		mesecon:changesignal(pos, node, rulename, mesecon.state.off, recdepth)
		if mesecon:is_effector_on(node.name)
		and not mesecon:is_powered(pos) then
			mesecon:deactivate(pos, node, rulename, recdepth + 1)
		end
	end
end

mesecon.queue:add_function("turnoff", function (pos, rulename, recdepth)
	if (MESECONS_GLOBALSTEP) then -- do not resume if we don't use globalstep - that would cause an endless loop
		mesecon:turnoff(pos, rulename, recdepth)
	end
end)


function mesecon:connected_to_receptor(pos, rulename)
	local node = minetest.get_node(pos)

	-- Check if conductors around are connected
	local rules = mesecon:get_any_inputrules(node)
	if not rules then return false end

	for _, rule in ipairs(mesecon:rule2meta(rulename, rules)) do
		local np = mesecon:addPosRule(pos, rule)
		if mesecon:rules_link(np, pos) then
			if mesecon:find_receptor_on(np, {}, mesecon:invertRule(rule)) then
				return true
			end
		end
	end

	return false
end

function mesecon:find_receptor_on(pos, checked, rulename)
	local node = minetest.get_node(pos)

	if mesecon:is_receptor_on(node.name) then
		-- add current position to checked
		table.insert(checked, {x=pos.x, y=pos.y, z=pos.z})
		return true
	end

	if mesecon:is_conductor(node.name) then
		local rules = mesecon:conductor_get_rules(node)
		local metaindex = mesecon:rule2metaindex(rulename, rules)
		-- find out if node has already been checked (to prevent from endless loop)
		for _, cp in ipairs(checked) do
			if mesecon:cmpPos(cp, pos) and cp.metaindex == metaindex then
				return false, checked
			end
		end
		-- add current position to checked
		table.insert(checked, {x=pos.x, y=pos.y, z=pos.z, metaindex = metaindex})
		for _, rule in ipairs(mesecon:rule2meta(rulename, rules)) do
			local np = mesecon:addPosRule(pos, rule)
			if mesecon:rules_link(np, pos) then
				if mesecon:find_receptor_on(np, checked, mesecon:invertRule(rule)) then
					return true
				end
			end
		end
	else
		-- find out if node has already been checked (to prevent from endless loop)
		for _, cp in ipairs(checked) do
			if mesecon:cmpPos(cp, pos) then
				return false, checked
			end
		end
		table.insert(checked, {x=pos.x, y=pos.y, z=pos.z})
	end

	return false
end

function mesecon:rules_link(output, input, dug_outputrules) --output/input are positions (outputrules optional, used if node has been dug), second return value: the name of the affected input rule
	local outputnode = minetest.get_node(output)
	local inputnode = minetest.get_node(input)
	local outputrules = dug_outputrules or mesecon:get_any_outputrules (outputnode)
	local inputrules = mesecon:get_any_inputrules (inputnode)
	if not outputrules or not inputrules then
		return
	end

	for _, outputrule in ipairs(mesecon:flattenrules(outputrules)) do
		-- Check if output sends to input
		if mesecon:cmpPos(mesecon:addPosRule(output, outputrule), input) then
			for _, inputrule in ipairs(mesecon:flattenrules(inputrules)) do
				-- Check if input accepts from output
				if  mesecon:cmpPos(mesecon:addPosRule(input, inputrule), output) then
					if inputrule.sx == nil or outputrule.sx == nil or mesecon:cmpSpecial(inputrule, outputrule) then
						return true, inputrule
					end
				end
			end
		end
	end
	return false
end

function mesecon:rules_link_rule_all(output, rule) --output/input are positions (outputrules optional, used if node has been dug), second return value: affected input rules
	local input = mesecon:addPosRule(output, rule)
	local inputnode = minetest.get_node(input)
	local inputrules = mesecon:get_any_inputrules (inputnode)
	if not inputrules then
		return {}
	end
	local rules = {}
	
	for _, inputrule in ipairs(mesecon:flattenrules(inputrules)) do
		-- Check if input accepts from output
		if  mesecon:cmpPos(mesecon:addPosRule(input, inputrule), output) then
			if inputrule.sx == nil or rule.sx == nil or mesecon:cmpSpecial(inputrule, rule) then
				rules[#rules+1] = inputrule
			end
		end
	end
	return rules
end

function mesecon:rules_link_anydir(pos1, pos2)
	return mesecon:rules_link(pos1, pos2) or mesecon:rules_link(pos2, pos1)
end

function mesecon:is_powered(pos, rule)
	local node = minetest.get_node(pos)
	local rules = mesecon:get_any_inputrules(node)
	if not rules then return false end

	if not rule then
		for _, rule in ipairs(mesecon:flattenrules(rules)) do
			local np = mesecon:addPosRule(pos, rule)
			local nn = minetest.get_node(np)
	
			if (mesecon:is_conductor_on (nn, mesecon:invertRule(rule)) or mesecon:is_receptor_on (nn.name))
			and mesecon:rules_link(np, pos) then
				return true
			end
		end
	else
		local np = mesecon:addPosRule(pos, rule)
		local nn = minetest.get_node(np)

		if (mesecon:is_conductor_on (nn, mesecon:invertRule(rule)) or mesecon:is_receptor_on (nn.name))
		and mesecon:rules_link(np, pos) then
			return true
		end
	end
	
	return false
end

--Rules rotation Functions:
function mesecon:rotate_rules_right(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		if rule.sx then
			table.insert(nr, {
				x = -rule.z, 
				y =  rule.y, 
				z =  rule.x,
				sx = -rule.sz, 
				sy =  rule.sy, 
				sz =  rule.sx})
		else
			table.insert(nr, {
				x = -rule.z, 
				y =  rule.y, 
				z =  rule.x})
		end
	end
	return nr
end

function mesecon:rotate_rules_left(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		if rule.sx then
			table.insert(nr, {
				x =  rule.z, 
				y =  rule.y, 
				z = -rule.x,
				sx =  rule.sz, 
				sy =  rule.sy, 
				sz = -rule.sx})
		else
			table.insert(nr, {
				x =  rule.z, 
				y =  rule.y, 
				z = -rule.x})
		end
	end
	return nr
end

function mesecon:rotate_rules_down(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		if rule.sx then
			table.insert(nr, {
				x = -rule.y, 
				y =  rule.x, 
				z =  rule.z,
				sx = -rule.sy, 
				sy =  rule.sx, 
				sz =  rule.sz})
		else
			table.insert(nr, {
				x = -rule.y, 
				y =  rule.x, 
				z =  rule.z})
		end
	end
	return nr
end

function mesecon:rotate_rules_up(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		if rule.sx then
			table.insert(nr, {
				x =  rule.y, 
				y = -rule.x, 
				z =  rule.z,
				sx =  rule.sy, 
				sy = -rule.sx, 
				sz =  rule.sz})
		else
			table.insert(nr, {
				x =  rule.y, 
				y = -rule.x, 
				z =  rule.z})
		end
	end
	return nr
end
