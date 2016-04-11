xpanes = {}

local function rshift(x, by)
	return math.floor(x / 2 ^ by)
end

local directions = {
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = -1},
}

local function update_pane(pos, name)
	if not minetest.get_node(pos).name:find("^xpanes:"..name) then
		return
	end
	local sum = 0
	for i, dir in pairs(directions) do
		local node = minetest.get_node(vector.add(pos, dir))
		local def = minetest.registered_nodes[node.name]
		local pane_num = def and def.groups.pane or 0
		if pane_num > 0 or not def or (def.walkable ~= false and
				def.drawtype ~= "nodebox") then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.set_node(pos, {name = "xpanes:"..name.."_"..sum})
end

local function update_nearby(pos, node)
	node = node or minetest.get_node(pos)
	local name = node.name
	if not name or node.name:sub(1, 7) ~= "xpanes:" then
		return
	end
	local underscore_pos = string.find(name, "_[^_]*$") or 0
	local len = name:len()
	local num = tonumber(name:sub(underscore_pos+1, len))
	if not num or num < 1 or num > 15 then
		name = name:sub(8)
	else
		name = name:sub(8, underscore_pos - 1)
	end
	for i, dir in pairs(directions) do
		update_pane(vector.add(pos, dir), name)
	end
end

minetest.register_on_placenode(update_nearby)
minetest.register_on_dignode(update_nearby)

local half_boxes = {
	{0,     -0.5, -1/32, 0.5,  0.5, 1/32},
	{-1/32, -0.5, 0,     1/32, 0.5, 0.5},
	{-0.5,  -0.5, -1/32, 0,    0.5, 1/32},
	{-1/32, -0.5, -0.5,  1/32, 0.5, 0}
}

local full_boxes = {
	{-0.5,  -0.5, -1/32, 0.5,  0.5, 1/32},
	{-1/32, -0.5, -0.5,  1/32, 0.5, 0.5}
}

local sb_half_boxes = {
	{0,     -0.5, -0.06, 0.5,  0.5, 0.06},
	{-0.06, -0.5, 0,     0.06, 0.5, 0.5},
	{-0.5,  -0.5, -0.06, 0,    0.5, 0.06},
	{-0.06, -0.5, -0.5,  0.06, 0.5, 0}
}

local sb_full_boxes = {
	{-0.5,  -0.5, -0.06, 0.5,  0.5, 0.06},
	{-0.06, -0.5, -0.5,  0.06, 0.5, 0.5}
}

local pane_def_fields = {
	drawtype = "airlike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	air_equivalent = true,
}

function xpanes.register_pane(name, def)
	for i = 1, 15 do
		local need = {}
		local cnt = 0
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				need[j] = true
				cnt = cnt + 1
			end
		end
		local take = {}
		local take2 = {}
		if need[1] == true and need[3] == true then
			need[1] = nil
			need[3] = nil
			table.insert(take, full_boxes[1])
			table.insert(take2, sb_full_boxes[1])
		end
		if need[2] == true and need[4] == true then
			need[2] = nil
			need[4] = nil
			table.insert(take, full_boxes[2])
			table.insert(take2, sb_full_boxes[2])
		end
		for k in pairs(need) do
			table.insert(take, half_boxes[k])
			table.insert(take2, sb_half_boxes[k])
		end
		local texture = def.textures[1]
		if cnt == 1 then
			texture = def.textures[1].."^"..def.textures[2]
		end
		minetest.register_node(":xpanes:"..name.."_"..i, {
			drawtype = "nodebox",
			tiles = {def.textures[3], def.textures[3], texture},
			paramtype = "light",
			groups = def.groups,
			drop = "xpanes:"..name,
			sounds = def.sounds,
			node_box = {
				type = "fixed",
				fixed = take
			},
			selection_box = {
				type = "fixed",
				fixed = take2
			}
		})
	end

	for k, v in pairs(pane_def_fields) do
		def[k] = def[k] or v
	end

	def.on_construct = function(pos)
		update_pane(pos, name)
	end

	minetest.register_node(":xpanes:"..name, def)

	minetest.register_craft({
		output = "xpanes:"..name.." 16",
		recipe = def.recipe
	})
end

xpanes.register_pane("pane", {
	description = "Glass Pane",
	textures = {"default_glass.png","xpanes_pane_half.png","xpanes_white.png"},
	inventory_image = "default_glass.png",
	wield_image = "default_glass.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3, pane=1},
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "default:glass", "default:glass"}
	}
})

xpanes.register_pane("bar", {
	description = "Iron bar",
	textures = {"xpanes_bar.png","xpanes_bar.png","xpanes_space.png"},
	inventory_image = "xpanes_bar.png",
	wield_image = "xpanes_bar.png",
	groups = {cracky=2, pane=1},
	sounds = default.node_sound_stone_defaults(),
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

