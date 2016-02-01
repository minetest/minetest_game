
-- Default to enabled in singleplayer and disabled in multiplayer
local singleplayer = minetest.is_singleplayer()
local setting = minetest.setting_getbool("enable_tnt")
if (not singleplayer and setting ~= true) or
		(singleplayer and setting == false) then
	return
end

-- loss probabilities array (one in X will be lost)
local loss_prob = {}

loss_prob["default:cobble"] = 3
loss_prob["default:dirt"] = 4

local radius = tonumber(minetest.setting_get("tnt_radius") or 3)

-- Fill a list with data for content IDs, after all nodes are registered
local cid_data = {}
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			drops = def.drops,
			flammable = def.groups.flammable,
			on_blast = def.on_blast,
		}
	end
end)

local function rand_pos(center, pos, radius)
	local def
	local reg_nodes = minetest.registered_nodes
	local i = 0
	repeat
		-- Give up and use the center if this takes too long
		if i > 4 then
			pos.x, pos.z = center.x, center.z
			break
		end
		pos.x = center.x + math.random(-radius, radius)
		pos.z = center.z + math.random(-radius, radius)
		def = reg_nodes[minetest.get_node(pos).name]
		i = i + 1
	until def and not def.walkable
end

local function eject_drops(drops, pos, radius)
	local drop_pos = vector.new(pos)
	for _, item in pairs(drops) do
		local count = item:get_count()
		local max = item:get_stack_max()
		if count > max then
			item:set_count(max)
		end
		while count > 0 do
			if count < max then
				item:set_count(count)
			end
			rand_pos(pos, drop_pos, radius)
			local obj = minetest.add_item(drop_pos, item)
			if obj then
				obj:get_luaentity().collect = true
				obj:setacceleration({x=0, y=-10, z=0})
				obj:setvelocity({x=math.random(-3, 3), y=10,
						z=math.random(-3, 3)})
			end
			count = count - max
		end
	end
end

local function add_drop(drops, item)
	item = ItemStack(item)
	local name = item:get_name()
	if loss_prob[name] ~= nil and math.random(1, loss_prob[name]) == 1 then
		return
	end

	local drop = drops[name]
	if drop == nil then
		drops[name] = item
	else
		drop:set_count(drop:get_count() + item:get_count())
	end
end

local fire_node = {name="fire:basic_flame"}

local function destroy(drops, pos, cid)
	if minetest.is_protected(pos, "") then
		return
	end
	local def = cid_data[cid]
	if def and def.on_blast then
		def.on_blast(vector.new(pos), 1)
		return
	end
	if def and def.flammable then
		minetest.set_node(pos, fire_node)
	else
		minetest.remove_node(pos)
		if def then
			local node_drops = minetest.get_node_drops(def.name, "")
			for _, item in ipairs(node_drops) do
				add_drop(drops, item)
			end
		end
	end
end


local function calc_velocity(pos1, pos2, old_vel, power)
	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)

	-- Divide by distance
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)

	-- Add old velocity
	vel = vector.add(vel, old_vel)
	return vel
end

local function entity_physics(pos, radius)
	-- Make the damage radius larger than the destruction radius
	radius = radius * 2
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local obj_vel = obj:getvelocity()
		local dist = math.max(1, vector.distance(pos, obj_pos))

		if obj_vel ~= nil then
			obj:setvelocity(calc_velocity(pos, obj_pos,
					obj_vel, radius * 10))
		end

		local damage = (4 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end

local function add_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 128,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-20, y=-20, z=-20},
		maxvel = {x=20,  y=20,  z=20},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 8,
		maxsize = 16,
		texture = "tnt_smoke.png",
	})
end

local function burn(pos)
	local name = minetest.get_node(pos).name
	if name == "tnt:tnt" then
		minetest.sound_play("tnt_ignite", {pos=pos})
		minetest.set_node(pos, {name="tnt:tnt_burning"})
		minetest.get_node_timer(pos):start(1)
	elseif name == "tnt:gunpowder" then
		minetest.sound_play("tnt_gunpowder_burning", {pos=pos, gain=2})
		minetest.set_node(pos, {name="tnt:gunpowder_burning"})
		minetest.get_node_timer(pos):start(1)
	end
end

local function explode(pos, radius)
	local pos = vector.round(pos)
	local vm = VoxelManip()
	local pr = PseudoRandom(os.time())
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	local drops = {}
	local p = {}

	local c_air = minetest.get_content_id("air")

	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do
		if (x * x) + (y * y) + (z * z) <=
				(radius * radius) + pr:next(-radius, radius) then
			local cid = data[vi]
			p.x = pos.x + x
			p.y = pos.y + y
			p.z = pos.z + z
			if cid ~= c_air then
				destroy(drops, p, cid)
			end
		end
		vi = vi + 1
	end
	end
	end

	return drops
end


local function boom(pos)
	minetest.sound_play("tnt_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
	minetest.set_node(pos, {name="tnt:boom"})
	minetest.get_node_timer(pos):start(0.5)

	local drops = explode(pos, radius)
	entity_physics(pos, radius)
	eject_drops(drops, pos, radius)
	add_effects(pos, radius)
end

minetest.register_node("tnt:tnt", {
	description = "TNT",
	tiles = {"tnt_top.png", "tnt_bottom.png", "tnt_side.png"},
	is_ground_content = false,
	groups = {dig_immediate=2, mesecon=2},
	sounds = default.node_sound_wood_defaults(),
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.sound_play("tnt_ignite", {pos=pos})
			minetest.set_node(pos, {name="tnt:tnt_burning"})
			minetest.get_node_timer(pos):start(4)
		end
	end,
	on_blast = function(pos, intensity)
		burn(pos)
	end,
	mesecons = {effector = {action_on = boom}},
})

minetest.register_node("tnt:tnt_burning", {
	tiles = {
		{
			name = "tnt_top_burning_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1,
			}
		},
		"tnt_bottom.png", "tnt_side.png"},
	light_source = 5,
	drop = "",
	sounds = default.node_sound_wood_defaults(),
	on_timer = boom,
	-- unaffected by explosions
	on_blast = function() end,
})

minetest.register_node("tnt:boom", {
	drawtype = "plantlike",
	tiles = {"tnt_boom.png"},
	light_source = default.LIGHT_MAX,
	walkable = false,
	drop = "",
	groups = {dig_immediate=3},
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end,
	-- unaffected by explosions
	on_blast = function() end,
})

minetest.register_node("tnt:gunpowder", {
	description = "Gun Powder",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	tiles = {"tnt_gunpowder_straight.png", "tnt_gunpowder_curved.png", "tnt_gunpowder_t_junction.png", "tnt_gunpowder_crossing.png"},
	inventory_image = "tnt_gunpowder_inventory.png",
	wield_image = "tnt_gunpowder_inventory.png",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {dig_immediate=2,attached_node=1,connect_to_raillike=minetest.raillike_group("gunpowder")},
	sounds = default.node_sound_leaves_defaults(),
	
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			burn(pos)
		end
	end,
	on_blast = function(pos, intensity)
		burn(pos)
	end,
})

minetest.register_node("tnt:gunpowder_burning", {
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	tiles = {{
		name = "tnt_gunpowder_burning_straight_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	},
	{
		name = "tnt_gunpowder_burning_curved_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	},
	{
		name = "tnt_gunpowder_burning_t_junction_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	},
	{
		name = "tnt_gunpowder_burning_crossing_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	}},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	drop = "",
	groups = {dig_immediate=2,attached_node=1,connect_to_raillike=minetest.raillike_group("gunpowder")},
	sounds = default.node_sound_leaves_defaults(),
	on_timer = function(pos, elapsed)
		for dx = -1, 1 do
		for dz = -1, 1 do
		for dy = -1, 1 do
			if not (dx == 0 and dz == 0) then
				burn({
					x = pos.x + dx,
					y = pos.y + dy,
					z = pos.z + dz,
				})
			end
		end
		end
		end
		minetest.remove_node(pos)
	end,
	-- unaffected by explosions
	on_blast = function() end,
})

minetest.register_abm({
	nodenames = {"tnt:tnt", "tnt:gunpowder"},
	neighbors = {"fire:basic_flame", "default:lava_source", "default:lava_flowing"},
	interval = 4,
	chance = 1,
	action = burn,
})

minetest.register_craft({
	output = "tnt:gunpowder",
	type = "shapeless",
	recipe = {"default:coal_lump", "default:gravel"}
})

minetest.register_craft({
	output = "tnt:tnt",
	recipe = {
		{"",           "group:wood",    ""},
		{"group:wood", "tnt:gunpowder", "group:wood"},
		{"",           "group:wood",    ""}
	}
})
