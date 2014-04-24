
local mode_text = {
	{"Change rotation, Don't change axisdir."},
	{"Keep choosen face in front then rotate it."},
	{"Change axis dir, Reset rotation."},
	{"Bring top in front then rotate it."},
}

-- Use Lua-friendly tables to avoid hash-lookups:
local opposite_faces = {
--	0  1  2  3  4  5
	5, 2, 1, 4, 3, 0
}

-- Rotational order for a given rotation axis as primary index:
-- Negative values indicate X rotation adjustments (rotate to opposite side),
-- 00 is just a visual indicator for invalid/unused axisdir indices.
-- Rotation order is always clockwise.
-- Layout: Row is selected by the face pointed at (the rotation axis),
--         current axisdir selects column, value is next axisdir:
local axis_rotations = {
--	  0   1   2   3   4   5  
	{00,  3,  4,  2,  1, 00},	-- Y+
	{ 4, 00, 00,  0,  5,  3},	-- Z+
	{ 3, 00, 00,  5,  0,  4},	-- Z-
	{ 1, -5,  0, 00, 00, -2},	-- X+
	{ 2,  0, -5, 00, 00, -1},	-- X-
	{00,  4,  3,  1,  2, 00},	-- Y-
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

local function screwdriver_handler(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then
		return
	end
	local pos = pointed_thing.under
	local keys = user:get_player_control()
	local player_name = user:get_player_name()
	local mode = tonumber(itemstack:get_metadata())
	if not mode or keys["sneak"] == true then
		return screwdriver_setmode(user, itemstack)
	end
	if minetest.is_protected(pos, user:get_player_name()) then
		minetest.record_protection_violation(pos, user:get_player_name())
		return
	end
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or not ndef.paramtype2 == "facedir" or
			(ndef.drawtype == "nodebox" and
			not ndef.node_box.type == "fixed") or
			node.param2 == nil then
		return
	end

	-- Split current param2 facedir value into axisdir and rotation:
	local rotation = node.param2 % 4
	local axisdir = math.floor(node.param2 / 4) % 6

	if mode == 1 then
		rotation = rotation + 1
	elseif mode == 2 then
		-- rotates the pointed face clockwise:
		local face = get_node_face(pointed_thing)
		-- when rotating the top/bottom faces, only change rotation:
		if axisdir == face then
			rotation = rotation + 1
		elseif axisdir == opposite_faces[face+1] then
			rotation = rotation - 1
		else
			-- rotate side faces: get next axisdir from table:
			axisdir = axis_rotations[face+1][axisdir+1]

			-- handle rotation adjustment (to keep face in front):
			if face == 0 then			-- Y+ (top) axis rotation fix
				rotation = rotation + 1
			elseif face == 5 then		-- Y- (bottom)
				rotation = rotation - 1
			elseif axisdir < 0 then		-- X axis rotation fix
				axisdir = -axisdir
				rotation = rotation + 2
			end
		end
	elseif mode == 3 then
		axisdir = axisdir + 1
		rotation = 0
	elseif mode == 4 then
		local face = get_node_face(pointed_thing)
		if axisdir == face then
			rotation = rotation + 1
		else
			axisdir = face
			rotation = 0
		end
	end

	-- recombine axisdir and rotation to facedir value:
	node.param2 = (axisdir%6) * 4 + (rotation%4)
	minetest.swap_node(pos, node)

	if not minetest.setting_getbool("creative_mode") then
		local item_wear = tonumber(itemstack:get_wear())
		item_wear = item_wear + 327
		if item_wear > 65535 then
			itemstack:clear()
			return itemstack
		end
		itemstack:set_wear(item_wear)
	end
	return itemstack
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

