local S, NS = dofile(minetest.get_modpath(minetest.get_current_modname()).."/intllib.lua")

local cart_entity = {
	physical = false, -- otherwise going uphill breaks
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	visual = "mesh",
	mesh = "carts_cart.b3d",
	visual_size = {x=1, y=1},
	textures = {"carts_cart.png"},

	driver = nil,
	punched = false, -- used to re-send velocity and position
	velocity = {x=0, y=0, z=0}, -- only used on punch
	old_dir = {x=1, y=0, z=0}, -- random value to start the cart on punch
	old_pos = nil,
	old_switch = 0,
	railtype = nil,
	attached_items = {}
}

function cart_entity:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	if self.driver and player_name == self.driver then
		self.driver = nil
		carts:manage_attachment(clicker, nil)
	elseif not self.driver then
		self.driver = player_name
		carts:manage_attachment(clicker, self.object)
	end
end

function cart_entity:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if string.sub(staticdata, 1, string.len("return")) ~= "return" then
		return
	end
	local data = minetest.deserialize(staticdata)
	if not data or type(data) ~= "table" then
		return
	end
	self.railtype = data.railtype
	if data.old_dir then
		self.old_dir = data.old_dir
	end
	if data.old_vel then
		self.old_vel = data.old_vel
	end
end

function cart_entity:get_staticdata()
	return minetest.serialize({
		railtype = self.railtype,
		old_dir = self.old_dir,
		old_vel = self.old_vel
	})
end

function cart_entity:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	local pos = self.object:getpos()
	if not self.railtype then
		local node = minetest.get_node(pos).name
		self.railtype = minetest.get_item_group(node, "connect_to_raillike")
	end
	-- Punched by non-player
	if not puncher or not puncher:is_player() then
		local cart_dir = carts:get_rail_direction(pos, self.old_dir, nil, nil, self.railtype)
		if vector.equals(cart_dir, {x=0, y=0, z=0}) then
			return
		end
		self.velocity = vector.multiply(cart_dir, 2)
		self.punched = true
		return
	end
	-- Player digs cart by sneak-punch
	if puncher:get_player_control().sneak then
		if self.sound_handle then
			minetest.sound_stop(self.sound_handle)
		end
		-- Detach driver and items
		if self.driver then
			if self.old_pos then
				self.object:setpos(self.old_pos)
			end
			local player = minetest.get_player_by_name(self.driver)
			carts:manage_attachment(player, nil)
		end
		for _,obj_ in ipairs(self.attached_items) do
			if obj_ then
				obj_:set_detach()
			end
		end
		-- Pick up cart
		local inv = puncher:get_inventory()
		if not minetest.setting_getbool("creative_mode")
				or not inv:contains_item("main", "carts:cart") then
			local leftover = inv:add_item("main", "carts:cart")
			-- If no room in inventory add a replacement cart to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:getpos(), leftover)
			end
		end
		self.object:remove()
		return
	end
	-- Player punches cart to alter velocity
	local vel = self.object:getvelocity()
	if puncher:get_player_name() == self.driver then
		if math.abs(vel.x + vel.z) > carts.punch_speed_max then
			return
		end
	end

	local punch_dir = carts:velocity_to_dir(puncher:get_look_dir())
	punch_dir.y = 0
	local cart_dir = carts:get_rail_direction(pos, punch_dir, nil, nil, self.railtype)
	if vector.equals(cart_dir, {x=0, y=0, z=0}) then
		return
	end

	local punch_interval = 1
	if tool_capabilities and tool_capabilities.full_punch_interval then
		punch_interval = tool_capabilities.full_punch_interval
	end
	time_from_last_punch = math.min(time_from_last_punch or punch_interval, punch_interval)
	local f = 2 * (time_from_last_punch / punch_interval)

	self.velocity = vector.multiply(cart_dir, f)
	self.old_dir = cart_dir
	self.punched = true
end

local function rail_on_step_event(handler, obj, dtime)
	if handler then
		handler(obj, dtime)
	end
end

-- sound refresh interval = 1.0sec
local function rail_sound(self, dtime)
	if not self.sound_ttl then
		self.sound_ttl = 1.0
		return
	elseif self.sound_ttl > 0 then
		self.sound_ttl = self.sound_ttl - dtime
		return
	end
	self.sound_ttl = 1.0
	if self.sound_handle then
		local handle = self.sound_handle
		self.sound_handle = nil
		minetest.after(0.2, minetest.sound_stop, handle)
	end
	local vel = self.object:getvelocity()
	local speed = vector.length(vel)
	if speed > 0 then
		self.sound_handle = minetest.sound_play(
			"carts_cart_moving", {
			object = self.object,
			gain = (speed / carts.speed_max) / 2,
			loop = true,
		})
	end
end

local function get_railparams(pos)
	local node = minetest.get_node(pos)
	return carts.railparams[node.name] or {}
end

local function rail_on_step(self, dtime)
	local vel = self.object:getvelocity()
	if self.punched then
		vel = vector.add(vel, self.velocity)
		self.object:setvelocity(vel)
		self.old_dir.y = 0
	elseif vector.equals(vel, {x=0, y=0, z=0}) then
		return
	end

	local pos = self.object:getpos()
	local update = {}

	-- stop cart if velocity vector flips
	if self.old_vel and self.old_vel.y == 0 and
			(self.old_vel.x * vel.x < 0 or self.old_vel.z * vel.z < 0) then
		self.old_vel = {x = 0, y = 0, z = 0}
		self.old_pos = pos
		self.object:setvelocity(vector.new())
		self.object:setacceleration(vector.new())
		rail_on_step_event(get_railparams(pos).on_step, self, dtime)
		return
	end
	self.old_vel = vector.new(vel)

	if self.old_pos and not self.punched then
		local flo_pos = vector.round(pos)
		local flo_old = vector.round(self.old_pos)
		if vector.equals(flo_pos, flo_old) then
			-- Do not check one node multiple times
			return
		end
	end

	local ctrl, player

	-- Get player controls
	if self.driver then
		player = minetest.get_player_by_name(self.driver)
		if player then
			ctrl = player:get_player_control()
		end
	end

	if self.old_pos then
		-- Detection for "skipping" nodes
		local found_path = carts:pathfinder(
			pos, self.old_pos, self.old_dir, ctrl, self.old_switch, self.railtype
		)

		if not found_path then
			-- No rail found: reset back to the expected position
			pos = vector.new(self.old_pos)
			update.pos = true
		end
	end

	local cart_dir = carts:velocity_to_dir(vel)
	local railparams

	-- dir:         New moving direction of the cart
	-- switch_keys: Currently pressed L/R key, used to ignore the key on the next rail node
	local dir, switch_keys = carts:get_rail_direction(
		pos, cart_dir, ctrl, self.old_switch, self.railtype
	)

	local new_acc = {x=0, y=0, z=0}
	if vector.equals(dir, {x=0, y=0, z=0}) then
		vel = {x = 0, y = 0, z = 0}
		pos = vector.round(pos)
		update.pos = true
		update.vel = true
	else
		-- Direction change detected
		if not vector.equals(dir, self.old_dir) then
			vel = vector.multiply(dir, math.abs(vel.x + vel.z))
			update.vel = true
			if dir.y ~= self.old_dir.y then
				pos = vector.round(pos)
				update.pos = true
			end
		end
		-- Center on the rail
		if dir.z ~= 0 and math.floor(pos.x + 0.5) ~= pos.x then
			pos.x = math.floor(pos.x + 0.5)
			update.pos = true
		end
		if dir.x ~= 0 and math.floor(pos.z + 0.5) ~= pos.z then
			pos.z = math.floor(pos.z + 0.5)
			update.pos = true
		end

		-- Slow down or speed up..
		local acc = dir.y * -4.0

		-- Get rail for corrected position
		railparams = get_railparams(pos)

		-- no need to check for railparams == nil since we always make it exist.
		local speed_mod = railparams.acceleration
		if speed_mod and speed_mod ~= 0 then
			-- Try to make it similar to the original carts mod
			acc = acc + speed_mod
		else
			-- Handbrake or coast
			if ctrl and ctrl.down then
				acc = acc - 3
			else
				acc = acc - 0.4
			end
		end

		new_acc = vector.multiply(dir, acc)
	end

	-- Limits
	local max_vel = carts.speed_max
	for _, v in pairs({"x","y","z"}) do
		if math.abs(vel[v]) > max_vel then
			vel[v] = carts:get_sign(vel[v]) * max_vel
			new_acc[v] = 0
			update.vel = true
		end
	end

	self.object:setacceleration(new_acc)
	self.old_pos = vector.new(pos)
	if not vector.equals(dir, {x=0, y=0, z=0}) then
		self.old_dir = vector.new(dir)
	end
	self.old_switch = switch_keys

	if self.punched then
		-- Collect dropped items
		for _, obj_ in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if not obj_:is_player() and
					obj_:get_luaentity() and
					not obj_:get_luaentity().physical_state and
					obj_:get_luaentity().name == "__builtin:item" then

				obj_:set_attach(self.object, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
				self.attached_items[#self.attached_items + 1] = obj_
			end
		end
		self.punched = false
		update.vel = true
	end

	railparams = railparams or get_railparams(pos)

	if not (update.vel or update.pos) then
		rail_on_step_event(railparams.on_step, self, dtime)
		return
	end

	local yaw = 0
	if self.old_dir.x < 0 then
		yaw = 0.5
	elseif self.old_dir.x > 0 then
		yaw = 1.5
	elseif self.old_dir.z < 0 then
		yaw = 1
	end
	self.object:setyaw(yaw * math.pi)

	local anim = {x=0, y=0}
	if dir.y == -1 then
		anim = {x=1, y=1}
	elseif dir.y == 1 then
		anim = {x=2, y=2}
	end
	self.object:set_animation(anim, 1, 0)

	self.object:setvelocity(vel)
	if update.pos then
		self.object:setpos(pos)
	end

	-- call event handler
	rail_on_step_event(railparams.on_step, self, dtime)
end

function cart_entity:on_step(dtime)
	rail_on_step(self, dtime)
	rail_sound(self, dtime)
end

minetest.register_entity("carts:cart", cart_entity)

minetest.register_craftitem("carts:cart", {
	description = S("Cart (Sneak+Click to pick up)"),
	inventory_image = minetest.inventorycube("carts_cart_top.png", "carts_cart_side.png", "carts_cart_side.png"),
	wield_image = "carts_cart_side.png",
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		if carts:is_rail(pointed_thing.under) then
			minetest.add_entity(pointed_thing.under, "carts:cart")
		elseif carts:is_rail(pointed_thing.above) then
			minetest.add_entity(pointed_thing.above, "carts:cart")
		else
			return
		end

		minetest.sound_play({name = "default_place_node_metal", gain = 0.5},
			{pos = pointed_thing.above})

		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = "carts:cart",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})
