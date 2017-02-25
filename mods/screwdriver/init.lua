screwdriver = {}

screwdriver.ROTATE_FACE = 1
screwdriver.ROTATE_AXIS = 2
screwdriver.disallow = function(pos, node, user, mode, new_param2)
	return false
end
screwdriver.rotate_simple = function(pos, node, user, mode, new_param2)
	if mode ~= screwdriver.ROTATE_FACE then
		return false
	end
end

screwdriver.rotate = {}

local facedir_tbl = {
	[screwdriver.ROTATE_FACE] = {
		[0] = 1, [1] = 2, [2] = 3, [3] = 0,
		[4] = 5, [5] = 6, [6] = 7, [7] = 4,
		[8] = 9, [9] = 10, [10] = 11, [11] = 8,
		[12] = 13, [13] = 14, [14] = 15, [15] = 12,
		[16] = 17, [17] = 18, [18] = 19, [19] = 16,
		[20] = 21, [21] = 22, [22] = 23, [23] = 20,
	},
	[screwdriver.ROTATE_AXIS] = {
		[0] = 4, [1] = 4, [2] = 4, [3] = 4,
		[4] = 8, [5] = 8, [6] = 8, [7] = 8,
		[8] = 12, [9] = 12, [10] = 12, [11] = 12,
		[12] = 16, [13] = 16, [14] = 16, [15] = 16,
		[16] = 20, [17] = 20, [18] = 20, [19] = 20,
		[20] = 0, [21] = 0, [22] = 0, [23] = 0,
	},
}

screwdriver.rotate.facedir = function(node, mode)
	return facedir_tbl[mode][node.param2]
end

local wallmounted_tbl = {
	[screwdriver.ROTATE_FACE] = {[2] = 5, [3] = 4, [4] = 2, [5] = 3, [1] = 0, [0] = 1},
	[screwdriver.ROTATE_AXIS] = {[2] = 5, [3] = 4, [4] = 2, [5] = 1, [1] = 0, [0] = 3}
}
screwdriver.rotate.wallmounted = function(node, mode)
	return wallmounted_tbl[mode][node.param2]
end

-- Handles rotation
screwdriver.handler = function(itemstack, user, pointed_thing, mode, uses)
	if pointed_thing.type ~= "node" then
		return
	end

	local pos = pointed_thing.under

	if minetest.is_protected(pos, user:get_player_name()) then
		minetest.record_protection_violation(pos, user:get_player_name())
		return
	end

	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	-- can we rotate this paramtype2?
	local fn = screwdriver.rotate[ndef.paramtype2]
	if not fn then
		return
	end

	local should_rotate = true
	local new_param2 = fn(node, mode)

	-- Node provides a handler, so let the handler decide instead if the node can be rotated
	if ndef and ndef.on_rotate then
		-- Copy pos and node because callback can modify it
		local result = ndef.on_rotate(vector.new(pos),
				{name = node.name, param1 = node.param1, param2 = node.param2},
				user, mode, new_param2)
		if result == false then -- Disallow rotation
			return
		elseif result == true then
			should_rotate = false
		end
	else
		if not ndef or not ndef.paramtype2 == "facedir" or
				ndef.on_rotate == false or
				(ndef.drawtype == "nodebox" and
				(ndef.node_box and ndef.node_box.type ~= "fixed")) or
				node.param2 == nil then
			return
		end

		if ndef.can_dig and not ndef.can_dig(pos, user) then
			return
		end
	end

	if should_rotate then
		node.param2 = new_param2
		minetest.swap_node(pos, node)
	end

	if not minetest.setting_getbool("creative_mode") then
		itemstack:add_wear(65535 / ((uses or 200) - 1))
	end

	return itemstack
end

-- Screwdriver
minetest.register_tool("screwdriver:screwdriver", {
	description = "Screwdriver (left-click rotates face, right-click rotates axis)",
	inventory_image = "screwdriver.png",
	on_use = function(itemstack, user, pointed_thing)
		screwdriver.handler(itemstack, user, pointed_thing, screwdriver.ROTATE_FACE, 200)
		return itemstack
	end,
	on_place = function(itemstack, user, pointed_thing)
		screwdriver.handler(itemstack, user, pointed_thing, screwdriver.ROTATE_AXIS, 200)
		return itemstack
	end,
})


minetest.register_craft({
	output = "screwdriver:screwdriver",
	recipe = {
		{"default:steel_ingot"},
		{"group:stick"}
	}
})

minetest.register_alias("screwdriver:screwdriver1", "screwdriver:screwdriver")
minetest.register_alias("screwdriver:screwdriver2", "screwdriver:screwdriver")
minetest.register_alias("screwdriver:screwdriver3", "screwdriver:screwdriver")
minetest.register_alias("screwdriver:screwdriver4", "screwdriver:screwdriver")
