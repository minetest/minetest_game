mesecon.on_placenode = function (pos, node)
	if mesecon:is_receptor_on(node.name) then
		mesecon:receptor_on(pos, mesecon:receptor_get_rules(node))
	elseif mesecon:is_powered(pos) then
		if mesecon:is_conductor(node.name) then
			mesecon:turnon (pos)
			--mesecon:receptor_on (pos, mesecon:conductor_get_rules(node))
		else
			mesecon:changesignal(pos, node, mesecon:effector_get_rules(node), "on", 1)
			mesecon:activate(pos, node, nil, 1)
		end
	elseif mesecon:is_conductor_on(node) then
		minetest.swap_node(pos, {name = mesecon:get_conductor_off(node)})
	elseif mesecon:is_effector_on (node.name) then
		mesecon:deactivate(pos, node, nil, 1)
	end
end

mesecon.on_dignode = function (pos, node)
	if mesecon:is_conductor_on(node) then
		mesecon:receptor_off(pos, mesecon:conductor_get_rules(node))
	elseif mesecon:is_receptor_on(node.name) then
		mesecon:receptor_off(pos, mesecon:receptor_get_rules(node))
	end
end

minetest.register_abm({
	nodenames = {"group:overheat"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		meta:set_int("heat",0)
	end,
})

minetest.register_on_placenode(mesecon.on_placenode)
minetest.register_on_dignode(mesecon.on_dignode)
