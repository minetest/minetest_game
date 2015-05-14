screwdriver = {}

local function nextrange(x, max)
	x = x + 1
	if x > max then
		x = 0
	end
	return x
end

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
local USES = 200

-- Handles rotation
local function screwdriver_handler(itemstack, user, pointed_thing, mode)
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
	-- Compute param2
	local rotationPart = node.param2 % 32 -- get first 4 bits
	local preservePart = node.param2 - rotationPart
	local axisdir = math.floor(rotationPart / 4)
	local rotation = rotationPart - axisdir * 4
	if mode == screwdriver.ROTATE_FACE then
		rotationPart = axisdir * 4 + nextrange(rotation, 3)
	elseif mode == screwdriver.ROTATE_AXIS then
		rotationPart = nextrange(axisdir, 5) * 4
	end

	local new_param2 = preservePart + rotationPart
	local should_rotate = true

	if ndef and ndef.on_rotate then -- Node provides a handler, so let the handler decide instead if the node can be rotated
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
				(ndef.drawtype == "nodebox" and
				not ndef.node_box.type == "fixed") or
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
		itemstack:add_wear(65535 / (USES - 1))
	end

	return itemstack
end

-- Screwdriver
minetest.register_tool("screwdriver:screwdriver", {
	description = "Screwdriver (left-click rotates face, right-click rotates axis)",
	inventory_image = "screwdriver.png",
	on_use = function(itemstack, user, pointed_thing)
		screwdriver_handler(itemstack, user, pointed_thing, screwdriver.ROTATE_FACE)
		return itemstack
	end,
	on_place = function(itemstack, user, pointed_thing)
		screwdriver_handler(itemstack, user, pointed_thing, screwdriver.ROTATE_AXIS)
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
