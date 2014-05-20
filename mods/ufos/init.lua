
ufos = {}

local floor_pos = function(pos)
	return {x=math.floor(pos.x),y=math.floor(pos.y),z=math.floor(pos.z)}
end

local UFO_SPEED = 2
local UFO_TURN_SPEED = 4
local UFO_MAX_SPEED = 20
local UFO_FUEL_USE = .01

ufos.fuel_from_wear = function(wear)
	local fuel
	if wear == 0 then
		fuel = 0
	else
		fuel = (65535-(wear-1))*100/65535
	end
	return fuel
end

ufos.wear_from_fuel = function(fuel)
	local wear = (100-(fuel))*65535/100+1
	if wear > 65535 then wear = 0 end
	return wear
end

ufos.get_fuel = function(self)
	return self.fuel
end

ufos.set_fuel = function(self,fuel,object)
	self.fuel = fuel
end

ufos.ufo_to_item = function(self)
	local wear = ufos.wear_from_fuel(ufos.get_fuel(self))
	return {name="ufos:ufo",wear=wear}
end

ufos.ufo_from_item = function(itemstack,placer,pointed_thing)
	-- set owner
	ufos.next_owner = placer:get_player_name()
	-- restore the fuel inside the item
	local wear = itemstack:get_wear()
	ufos.set_fuel(ufos.ufo,ufos.fuel_from_wear(wear))
	-- add the entity
	e = minetest.env:add_entity(pointed_thing.above, "ufos:ufo")
	-- remove the item
	itemstack:take_item()
	-- reset owner for next ufo
	ufos.next_owner = ""
end

ufos.check_owner = function(self, clicker)
	if self.owner_name ~= "" and clicker:get_player_name() ~= self.owner_name then
		minetest.chat_send_player(clicker:get_player_name(), "This UFO is owned by "..self.owner_name.." !")
		return false
	elseif self.owner_name == "" then
		minetest.chat_send_player(clicker:get_player_name(), "This UFO was not protected, you are now its owner !")
		self.owner_name = clicker:get_player_name()
	end
	return true
end


ufos.next_owner = ""
ufos.ufo = {
	physical = true,
	collisionbox = {-1.5,-.5,-1.5, 1.5,2,1.5},
	visual = "mesh",
	mesh = "ufo.x",
	textures = {"ufo_0.png"},
	
	driver = nil,
	owner_name = "",
	v = 0,
	fuel = 0,
	fueli = 0
}
function ufos.ufo:on_rightclick (clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		if ufos.check_owner(self,clicker) then
			self.driver = clicker
			clicker:set_attach(self.object, "", {x=0,y=7.5,z=0}, {x=0,y=0,z=0})
		end
	end
end

function ufos.ufo:on_activate (staticdata, dtime_s)
	if ufos.next_owner ~= "" then
		self.owner_name = ufos.next_owner
		ufos.next_owner = ""
	else
		local data = staticdata:split(';')
		if data and data[1] and data[2] then
			self.owner_name = data[1]
			self.fuel = tonumber(data[2])
		end
	end
	self.object:set_armor_groups({immortal=1})
end

function ufos.ufo:on_punch (puncher, time_from_last_punch, tool_capabilities, direction)
	if puncher and puncher:is_player() then
		if ufos.check_owner(self,puncher) then
			puncher:get_inventory():add_item("main", ufos.ufo_to_item(self))
			self.object:remove()
		end
	end
end

function ufos.ufo:on_step (dtime)
	local fuel = ufos.get_fuel(self)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		local vel = self.object:getvelocity()
		if fuel == nil then fuel = 0 end
		if fuel > 0 and ctrl.up then
			vel.x = vel.x + math.cos(self.object:getyaw()+math.pi/2)*UFO_SPEED
			vel.z = vel.z + math.sin(self.object:getyaw()+math.pi/2)*UFO_SPEED
			fuel = fuel - UFO_FUEL_USE
		else
			vel.x = vel.x*.99
			vel.z = vel.z*.99
		end
		if ctrl.down then
			vel.x = vel.x*.9
			vel.z = vel.z*.9
		end
		if fuel > 0 and ctrl.jump then
			vel.y = vel.y+UFO_SPEED
			fuel = fuel - UFO_FUEL_USE
		elseif fuel > 0 and ctrl.sneak then
			vel.y = vel.y-UFO_SPEED
			fuel = fuel - UFO_FUEL_USE
		else
			vel.y = vel.y*.9
		end
		if vel.x > UFO_MAX_SPEED then vel.x = UFO_MAX_SPEED end
		if vel.x < -UFO_MAX_SPEED then vel.x = -UFO_MAX_SPEED end
		if vel.y > UFO_MAX_SPEED then vel.y = UFO_MAX_SPEED end
		if vel.y < -UFO_MAX_SPEED then vel.y = -UFO_MAX_SPEED end
		if vel.z > UFO_MAX_SPEED then vel.z = UFO_MAX_SPEED end
		if vel.z < -UFO_MAX_SPEED then vel.z = -UFO_MAX_SPEED end
		self.object:setvelocity(vel)
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120*UFO_TURN_SPEED)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120*UFO_TURN_SPEED)
		end
		if ctrl.aux1 then
			local pos = self.object:getpos()
			local t = {{x=2,z=0},{x=-2,z=0},{x=0,z=2},{x=0,z=-2}}
			for _, i in ipairs(t) do
				pos.x = pos.x + i.x; pos.z = pos.z + i.z;
				if minetest.env:get_node(pos).name == "ufos:furnace" then
					meta = minetest.env:get_meta(pos)
					if fuel < 100 and meta:get_int("charge") > 0 then
						fuel = fuel + 1
						meta:set_int("charge",meta:get_int("charge")-1)
						meta:set_string("formspec", ufos.furnace_inactive_formspec
							.. "label[0,0;Charge: "..meta:get_int("charge"))
					end
				end
				pos.x = pos.x - i.x; pos.z = pos.z - i.z;
			end
		end
	end
	
	if fuel < 0 then fuel = 0 end
	if fuel > 100 then fuel = 100 end
	if self.fueli ~= math.floor(fuel*8/100) then
		self.fueli = math.floor(fuel*8/100)
		print(self.fueli)
		self.textures = {"ufo_"..self.fueli..".png"}
		self.object:set_properties(self)
	end
	ufos.set_fuel(self,fuel)
end

function ufos.ufo:get_staticdata()
	return self.owner_name..";"..tostring(self.fuel)
end

minetest.register_entity("ufos:ufo", ufos.ufo)


minetest.register_tool("ufos:ufo", {
	description = "ufo",
	inventory_image = "ufos_inventory.png",
	wield_image = "ufos_inventory.png",
	tool_capabilities = {load=0,max_drop_level=0, groupcaps={fleshy={times={}, uses=100, maxlevel=0}}},
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		
		-- Call on_rightclick if the pointed node defines it
		if placer and not placer:get_player_control().sneak then
			local n = minetest.get_node(pointed_thing.under)
			local nn = n.name
			if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
				return minetest.registered_nodes[nn].on_rightclick(pointed_thing.under, n, placer, itemstack) or itemstack
			end
		end
		
		ufos.ufo_from_item(itemstack,placer,pointed_thing)
		return itemstack
	end,
})

minetest.register_craft( {
	output = 'ufos:ufo',
	recipe = {
		{ "", "default:glass", ""},
		{ "moontest:lunarium_lump", "", "moontest:lunarium_lump"},
		{ "default:steelblock", "moontest:lunarium_ingot", "default:steelblock"},
	},
})


-- ufos box kept for compatibility only
minetest.register_node("ufos:box", {
	description = "UFO BOX (you hacker you!)",
	tiles = {"ufos_box.png"},
	groups = {not_in_creative_inventory=1},
	on_rightclick = function(pos, node, clicker, itemstack)
		meta = minetest.env:get_meta(pos)
		if meta:get_string("owner") == clicker:get_player_name() then
			-- set owner
			ufos.next_owner = meta:get_string("owner")
			-- restore the fuel inside the node
			ufos.set_fuel(ufos.ufo,meta:get_int("fuel"))
			-- add the entity
			e = minetest.env:add_entity(pos, "ufos:ufo")
			-- remove the node
			minetest.env:remove_node(pos)
			-- reset owner for next ufo
			ufos.next_owner = ""
		end
	end,
})

dofile(minetest.get_modpath("ufos").."/furnace.lua")

