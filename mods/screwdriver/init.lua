
local mode_text = {
	{"Change rotation, Don't change axisdir."},
	{"Keep choosen face in front then rotate it."},
	{"Change axis dir, Reset rotation."},
	{"Bring top in front then rotate it."},
}

local opposite_faces = {
	[0] = 5,
	[1] = 2,
	[2] = 1,
	[3] = 4,
	[4] = 3,
	[5] = 0,
}

local function screwdriver_setmode(user,itemstack)
	local player_name = user:get_player_name()
	local item = itemstack:to_table()
	local mode = tonumber(itemstack:get_metadata())
	if not mode then
		minetest.chat_send_player(player_name, "Hold shift and use to change screwdriwer modes.")
		mode = 0
	end
	mode = mode + 1
	if mode == 5 then
		mode = 1
	end
	minetest.chat_send_player(player_name, "Screwdriver mode : "..mode.." - "..mode_text[mode][1] )
	itemstack:set_name("screwdriver:screwdriver"..mode)
	itemstack:set_metadata(mode)
	return itemstack
end

local function get_node_face(pointed_thing)
	local ax, ay, az = pointed_thing.above.x, pointed_thing.above.y, pointed_thing.above.z
	local ux, uy, uz = pointed_thing.under.x, pointed_thing.under.y, pointed_thing.under.z
	if     ay > uy then return 0 -- Top
	elseif az > uz then return 1 -- Z+ side
	elseif az < uz then return 2 -- Z- side
	elseif ax > ux then return 3 -- X+ side
	elseif ax < ux then return 4 -- X- side
	elseif ay < uy then return 5 -- Bottom
	else
		error("pointed_thing.above and under are the same!")
	end
end

local function nextrange(x, max)
	x = x + 1
	if x > max then
		x = 0
	end
	return x
end

local function screwdriver_handler(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then
		return
	end
	local pos = pointed_thing.under
	if minetest.is_protected(pos, user:get_player_name()) then
		minetest.record_protection_violation(pos, user:get_player_name())
		return
	end
	local keys = user:get_player_control()
	local player_name = user:get_player_name()
	local mode = tonumber(itemstack:get_metadata())
	if not mode or keys["sneak"] == true then
		return screwdriver_setmode(user, itemstack)
	end
	local node = minetest.get_node(pos)
	local node_name = node.name
	local ndef = minetest.registered_nodes[node.name]
	if ndef.paramtype2 == "facedir" then
		if ndef.drawtype == "nodebox" and ndef.node_box.type ~= "fixed" then
			return
		end
		if node.param2 == nil then
			return
		end
		-- Get ready to set the param2
		local n = node.param2
		local axisdir = math.floor(n / 4)
		local rotation = n - axisdir * 4
		if mode == 1 then
			n = axisdir * 4 + nextrange(rotation, 3)
		elseif mode == 2 then
			-- If you are pointing at the axisdir face or the
			-- opposite one then you can just rotate the node.
			-- Otherwise change the axisdir, avoiding the facing
			-- and opposite axes.
			local face = get_node_face(pointed_thing)
			if axisdir == face or axisdir == opposite_faces[face] then
				n = axisdir * 4 + nextrange(rotation, 3)
			else
				axisdir = nextrange(axisdir, 5)
				-- This is repeated because switching from the face
				-- can move to to the opposite and vice-versa
				if axisdir == face or axisdir == opposite_faces[face] then
					axisdir = nextrange(axisdir, 5)
				end
				if axisdir == face or axisdir == opposite_faces[face] then
					axisdir = nextrange(axisdir, 5)
				end
				n = axisdir * 4
			end
		elseif mode == 3 then
			n = nextrange(axisdir, 5) * 4
		elseif mode == 4 then
			local face = get_node_face(pointed_thing)
			if axisdir == face then
				n = axisdir * 4 + nextrange(rotation, 3)
			else
				n = face * 4
			end
		end
		--print (dump(axisdir..", "..rotation))
		node.param2 = n
		minetest.swap_node(pos, node)
		local item_wear = tonumber(itemstack:get_wear())
		item_wear = item_wear + 327
		if item_wear > 65535 then
			itemstack:clear()
			return itemstack
		end
		itemstack:set_wear(item_wear)
		return itemstack
	end
end

minetest.register_craft({
	output = "screwdriver:screwdriver",
	recipe = {
		{"default:steel_ingot"},
		{"group:stick"}
	}
})

minetest.register_tool("screwdriver:screwdriver", {
	description = "Screwdriver",
	inventory_image = "screwdriver.png",
	on_use = function(itemstack, user, pointed_thing)
		screwdriver_handler(itemstack, user, pointed_thing)
		return itemstack
	end,
})

for i = 1, 4 do
	minetest.register_tool("screwdriver:screwdriver"..i, {
		description = "Screwdriver in Mode "..i,
		inventory_image = "screwdriver.png^tool_mode"..i..".png",
		wield_image = "screwdriver.png",
		groups = {not_in_creative_inventory=1},
		on_use = function(itemstack, user, pointed_thing)
			screwdriver_handler(itemstack, user, pointed_thing)
			return itemstack
		end,
	})
end

