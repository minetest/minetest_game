--register stoppers for movestones/pistons

mesecon.mvps_stoppers = {}
mesecon.mvps_unmov = {}
mesecon.on_mvps_move = {}

function mesecon:is_mvps_stopper(node, pushdir, stack, stackid)
	local get_stopper = mesecon.mvps_stoppers[node.name]
	if type (get_stopper) == "function" then
		get_stopper = get_stopper(node, pushdir, stack, stackid)
	end
	return get_stopper
end

function mesecon:register_mvps_stopper(nodename, get_stopper)
	if get_stopper == nil then
			get_stopper = true
	end
	mesecon.mvps_stoppers[nodename] = get_stopper
end

-- Objects that cannot be moved (e.g. movestones)
function mesecon:register_mvps_unmov(objectname)
	mesecon.mvps_unmov[objectname] = true;
end

function mesecon:is_mvps_unmov(objectname)
	return mesecon.mvps_unmov[objectname]
end

-- Functions to be called on mvps movement
function mesecon:register_on_mvps_move(callback)
	mesecon.on_mvps_move[#mesecon.on_mvps_move+1] = callback
end

local function on_mvps_move(moved_nodes)
	for _, callback in ipairs(mesecon.on_mvps_move) do
		callback(moved_nodes)
	end
end

function mesecon:mvps_process_stack(stack)
	-- update mesecons for placed nodes ( has to be done after all nodes have been added )
	for _, n in ipairs(stack) do
		nodeupdate(n.pos)
		mesecon.on_placenode(n.pos, minetest.get_node(n.pos))
		mesecon:update_autoconnect(n.pos)
	end
end

function mesecon:mvps_get_stack(pos, dir, maximum)
	-- determine the number of nodes to be pushed
	local np = {x = pos.x, y = pos.y, z = pos.z}
	local nodes = {}
	while true do
		local nn = minetest.get_node_or_nil(np)
		if not nn or #nodes > maximum then
			-- don't push at all, something is in the way (unloaded map or too many nodes)
			return nil
		end

		if nn.name == "air"
		or (minetest.registered_nodes[nn.name]
		and minetest.registered_nodes[nn.name].liquidtype ~= "none") then --is liquid
			break
		end

		table.insert (nodes, {node = nn, pos = np})

		np = mesecon:addPosRule(np, dir)
	end
	return nodes
end

function mesecon:mvps_push(pos, dir, maximum) -- pos: pos of mvps; dir: direction of push; maximum: maximum nodes to be pushed
	local nodes = mesecon:mvps_get_stack(pos, dir, maximum)

	if not nodes then return end
	-- determine if one of the nodes blocks the push
	for id, n in ipairs(nodes) do
		if mesecon:is_mvps_stopper(n.node, dir, nodes, id) then
			return
		end
	end

	-- remove all nodes
	for _, n in ipairs(nodes) do
		n.meta = minetest.get_meta(n.pos):to_table()
		minetest.remove_node(n.pos)
	end

	-- update mesecons for removed nodes ( has to be done after all nodes have been removed )
	for _, n in ipairs(nodes) do
		mesecon.on_dignode(n.pos, n.node)
		mesecon:update_autoconnect(n.pos)
	end

	-- add nodes
	for _, n in ipairs(nodes) do
		np = mesecon:addPosRule(n.pos, dir)
		minetest.add_node(np, n.node)
		minetest.get_meta(np):from_table(n.meta)
	end
	
	local moved_nodes = {}
	local oldstack = mesecon:tablecopy(nodes)
	for i in ipairs(nodes) do
		moved_nodes[i] = {}
		moved_nodes[i].oldpos = nodes[i].pos
		nodes[i].pos = mesecon:addPosRule(nodes[i].pos, dir)
		moved_nodes[i].pos = nodes[i].pos
		moved_nodes[i].node = nodes[i].node
		moved_nodes[i].meta = nodes[i].meta
	end
	
	on_mvps_move(moved_nodes)

	return true, nodes, oldstack
end

mesecon:register_on_mvps_move(function(moved_nodes)
	for _, n in ipairs(moved_nodes) do
		mesecon.on_placenode(n.pos, n.node)
		mesecon:update_autoconnect(n.pos)
	end
end)

function mesecon:mvps_pull_single(pos, dir) -- pos: pos of mvps; direction: direction of pull (matches push direction for sticky pistons)
	np = mesecon:addPosRule(pos, dir)
	nn = minetest.get_node(np)

	if ((not minetest.registered_nodes[nn.name]) --unregistered node
	or minetest.registered_nodes[nn.name].liquidtype == "none") --non-liquid node
	and not mesecon:is_mvps_stopper(nn, {x = -dir.x, y = -dir.y, z = -dir.z}, {{pos = np, node = nn}}, 1) then --non-stopper node
		local meta = minetest.get_meta(np):to_table()
		minetest.remove_node(np)
		minetest.add_node(pos, nn)
		minetest.get_meta(pos):from_table(meta)

		nodeupdate(np)
		nodeupdate(pos)
		mesecon.on_dignode(np, nn)
		mesecon:update_autoconnect(np)
		on_mvps_move({{pos = pos, oldpos = np, node = nn, meta = meta}})
	end
	return {{pos = np, node = {param2 = 0, name = "air"}}, {pos = pos, node = nn}}
end

function mesecon:mvps_pull_all(pos, direction) -- pos: pos of mvps; direction: direction of pull
	local lpos = {x=pos.x-direction.x, y=pos.y-direction.y, z=pos.z-direction.z} -- 1 away
	local lnode = minetest.get_node(lpos)
	local lpos2 = {x=pos.x-direction.x*2, y=pos.y-direction.y*2, z=pos.z-direction.z*2} -- 2 away
	local lnode2 = minetest.get_node(lpos2)

	--avoid pulling solid nodes
	if lnode.name ~= "ignore"
	and lnode.name ~= "air"
	and ((not minetest.registered_nodes[lnode.name])
	or minetest.registered_nodes[lnode.name].liquidtype == "none") then
		return
	end

	--avoid pulling empty or liquid nodes
	if lnode2.name == "ignore"
	or lnode2.name == "air"
	or (minetest.registered_nodes[lnode2.name]
	and minetest.registered_nodes[lnode2.name].liquidtype ~= "none") then
		return
	end

	local moved_nodes = {}
	local oldpos = {x=lpos2.x + direction.x, y=lpos2.y + direction.y, z=lpos2.z + direction.z}
	repeat
		lnode2 = minetest.get_node(lpos2)
		local meta = minetest.get_meta(lnode2):to_table()
		minetest.add_node(oldpos, lnode2)
		minetest.get_meta(oldpos):from_table(meta)
		moved_nodes[#moved_nodes+1] = {pos = oldpos, oldpos = lnode2, node = lnode2, meta = meta}
		nodeupdate(oldpos)
		oldpos = {x=lpos2.x, y=lpos2.y, z=lpos2.z}
		lpos2.x = lpos2.x-direction.x
		lpos2.y = lpos2.y-direction.y
		lpos2.z = lpos2.z-direction.z
		lnode = minetest.get_node(lpos2)
	until lnode.name == "air"
	or lnode.name == "ignore"
	or (minetest.registered_nodes[lnode.name]
	and minetest.registered_nodes[lnode.name].liquidtype ~= "none")
	minetest.remove_node(oldpos)
	mesecon.on_dignode(oldpos, lnode2)
	mesecon:update_autoconnect(oldpos)
	on_mvps_move(moved_nodes)
end

function mesecon:mvps_move_objects(pos, dir, nodestack)
	local objects_to_move = {}

	-- Move object at tip of stack
	local pushpos = mesecon:addPosRule(pos, -- get pos at tip of stack
		{x = dir.x * #nodestack,
		 y = dir.y * #nodestack,
		 z = dir.z * #nodestack})


	local objects = minetest.get_objects_inside_radius(pushpos, 1)
	for _, obj in ipairs(objects) do
		table.insert(objects_to_move, obj)
	end

	-- Move objects lying/standing on the stack (before it was pushed - oldstack)
	if tonumber(minetest.setting_get("movement_gravity")) > 0 and dir.y == 0 then
		-- If gravity positive and dir horizontal, push players standing on the stack
		for _, n in ipairs(nodestack) do
			local p_above = mesecon:addPosRule(n.pos, {x=0, y=1, z=0})
			local objects = minetest.get_objects_inside_radius(p_above, 1)
			for _, obj in ipairs(objects) do
				table.insert(objects_to_move, obj)
			end
		end
	end

	for _, obj in ipairs(objects_to_move) do
		local entity = obj:get_luaentity()
		if not entity or not mesecon:is_mvps_unmov(entity.name) then
			local np = mesecon:addPosRule(obj:getpos(), dir)

			--move only if destination is not solid
			local nn = minetest.get_node(np)
			if not ((not minetest.registered_nodes[nn.name])
			or minetest.registered_nodes[nn.name].walkable) then
				obj:setpos(np)
			end
		end
	end
end

mesecon:register_mvps_stopper("default:chest_locked")
mesecon:register_mvps_stopper("default:furnace")
