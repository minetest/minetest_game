-- mods/default/item_entity.lua

local item = minetest.registered_entities["__builtin:item"]

local orig_set_item = item.set_item
function item:set_item(itemstring)
	orig_set_item(self, itemstring)

	local stack = ItemStack(itemstring)
	local itemdef = minetest.registered_items[stack:get_name()]
	if itemdef and itemdef.groups.flammable ~= 0 then
		self.flammable = itemdef.groups.flammable
	end
end

function item:burn_up()
	-- disappear in a smoke puff
	self.object:remove()
	local p = self.object:get_pos()
	minetest.sound_play("default_item_smoke", {
		pos = p,
		max_hear_distance = 8,
	})
	minetest.add_particlespawner({
		amount = 3,
		time = 0.1,
		minpos = {x = p.x - 0.1, y = p.y + 0.1, z = p.z - 0.1 },
		maxpos = {x = p.x + 0.1, y = p.y + 0.2, z = p.z + 0.1 },
		minvel = {x = 0, y = 2.5, z = 0},
		maxvel = {x = 0, y = 2.5, z = 0},
		minacc = {x = -0.15, y = -0.02, z = -0.15},
		maxacc = {x = 0.15, y = -0.01, z = 0.15},
		minexptime = 4,
		maxexptime = 6,
		minsize = 5,
		maxsize = 5,
		collisiondetection = true,
		texture = "default_item_smoke.png"
	})
end

local orig_on_step = item.on_step
function item:on_step(dtime)
	orig_on_step(self, dtime)

	if self.flammable then
		-- flammable, check for igniters
		self.ignite_timer = (self.ignite_timer or 0) + dtime
		if self.ignite_timer > 10 then
			self.ignite_timer = 0

			local node = minetest.get_node_or_nil(self.object:get_pos())
			if not node then
				return
			end

			-- Immediately burn up flammable items in lava
			if minetest.get_item_group(node.name, "lava") > 0 then
				self:burn_up()
			else
				--  otherwise there'll be a chance based on its igniter value
				local burn_chance = self.flammable
					* minetest.get_item_group(node.name, "igniter")
				if burn_chance > 0 and math.random(0, burn_chance) ~= 0 then
					self:burn_up()
				end
			end
		end
	end
end
