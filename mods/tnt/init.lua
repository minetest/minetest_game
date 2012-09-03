local destroy = function(pos)
	if math.random(1,5) <= 4 then
		minetest.env:add_entity({x=pos.x+math.random(0,10)/10-0.5, y=pos.y, z=pos.z+math.random(0,10)/10-0.5}, "tnt:smoke")
	end
	local nodename = minetest.env:get_node(pos).name
	if nodename ~= "air" then
		minetest.env:remove_node(pos)
		if minetest.registered_nodes[nodename].groups.flammable ~= nil then
			minetest.env:set_node(pos, {name="fire:basic_flame"})
			return
		end
		local drop = minetest.get_node_drops(nodename, "")
		for _,item in ipairs(drop) do
			if type(item) == "string" then
				local obj = minetest.env:add_item(pos, item)
				if obj == nil then
					return
				end
				obj:get_luaentity().collect = true
				obj:setacceleration({x=0, y=-10, z=0})
				obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
			else
				for i=1,item:get_count() do
					local obj = minetest.env:add_item(pos, item:get_name())
					if obj == nil then
						return
					end
					obj:get_luaentity().collect = true
					obj:setacceleration({x=0, y=-10, z=0})
					obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
				end
			end
		end
	end
end

boom = function(pos, time)
	minetest.after(time, function(pos)
		if minetest.env:get_node(pos).name ~= "tnt:tnt_burning" then
			return
		end
		minetest.sound_play("tnt_explode", {pos=pos, gain=1.5, max_hear_distance=2*64})
		minetest.env:set_node(pos, {name="tnt:boom"})
		minetest.after(0.5, function(pos)
			minetest.env:remove_node(pos)
		end, {x=pos.x, y=pos.y, z=pos.z})
		
		local objects = minetest.env:get_objects_inside_radius(pos, 7)
		for _,obj in ipairs(objects) do
			if obj:is_player() or obj:get_luaentity().name ~= "__builtin:item" then
				local obj_p = obj:getpos()
				local vec = {x=obj_p.x-pos.x, y=obj_p.y-pos.y, z=obj_p.z-pos.z}
				local dist = (vec.x^2+vec.y^2+vec.z^2)^0.5
				local damage = (80*0.5^dist)*2
				obj:set_hp(obj:get_hp()-damage)
				--[[obj:punch(obj, 1.0, { FIXME
					full_punch_interval=1.0,
					groupcaps={
						fleshy={times={[1]=1/damage, [2]=1/damage, [3]=1/damage}},
						snappy={times={[1]=1/damage, [2]=1/damage, [3]=1/damage}},
					}
				}, nil)]]
			end
		end
		
		for dx=-2,2 do
			for dz=-2,2 do
				for dy=-2,2 do
					pos.x = pos.x+dx
					pos.y = pos.y+dy
					pos.z = pos.z+dz
					
					local node =  minetest.env:get_node(pos)
					if node.name == "tnt:tnt" or node.name == "tnt:tnt_burning" then
						minetest.env:set_node(pos, {name="tnt:tnt_burning"})
						boom({x=pos.x, y=pos.y, z=pos.z}, 0)
					elseif node.name == "fire:basic_flame" or string.find(node.name, "default:water_") or string.find(node.name, "default:lava_") or node.name == "tnt:boom" then
						
					else
						if math.abs(dx)<2 and math.abs(dy)<2 and math.abs(dz)<2 then
							destroy(pos)
						else
							if math.random(1,5) <= 4 then
								destroy(pos)
							end
						end
					end
					
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end
	end, pos)
end

minetest.register_node("tnt:tnt", {
	description = "TNT",
	tiles = {"tnt_top.png", "tnt_bottom.png", "tnt_side.png"},
	groups = {dig_immediate=2, mesecon=2},
	sounds = default.node_sound_wood_defaults(),
	
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.sound_play("tnt_ignite", {pos=pos})
			minetest.env:set_node(pos, {name="tnt:tnt_burning"})
			boom(pos, 4)
		end
	end,
})

minetest.register_node("tnt:tnt_burning", {
	--tiles = {"tnt_top_burning.png", "tnt_bottom.png", "tnt_side.png"},
	tiles = {{name="tnt_top_burning_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1}}, "tnt_bottom.png", "tnt_side.png"},
	light_source = 5,
	drop = "",
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("tnt:boom", {
	drawtype = "plantlike",
	tiles = {"tnt_boom.png"},
	light_source = LIGHT_MAX,
	walkable = false,
})

burn = function(pos)
	if minetest.env:get_node(pos).name == "tnt:tnt" then
		minetest.sound_play("tnt_ignite", {pos=pos})
		minetest.env:set_node(pos, {name="tnt:tnt_burning"})
		boom(pos, 1)
		return
	end
	if minetest.env:get_node(pos).name ~= "tnt:gunpowder" then
		return
	end
	minetest.sound_play("tnt_gunpowder_burning", {pos=pos, gain=2})
	minetest.env:set_node(pos, {name="tnt:gunpowder_burning"})
	
	minetest.after(1, function(pos)
		if minetest.env:get_node(pos).name ~= "tnt:gunpowder_burning" then
			return
		end
		minetest.after(0.5, function(pos)
			minetest.env:remove_node(pos)
		end, {x=pos.x, y=pos.y, z=pos.z})
		for dx=-1,1 do
			for dz=-1,1 do
				for dy=-1,1 do
					pos.x = pos.x+dx
					pos.y = pos.y+dy
					pos.z = pos.z+dz
					
					if not (math.abs(dx) == 1 and math.abs(dz) == 1) then
						if dy == 0 then
							burn({x=pos.x, y=pos.y, z=pos.z})
						else
							if math.abs(dx) == 1 or math.abs(dz) == 1 then
								burn({x=pos.x, y=pos.y, z=pos.z})
							end
						end
					end
					
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end
	end, pos)
end

minetest.register_node("tnt:gunpowder", {
	description = "Gun Powder",
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	tiles = {"tnt_gunpowder.png",},
	inventory_image = "tnt_gunpowder_inventory.png",
	wield_image = "tnt_gunpowder_inventory.png",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {dig_immediate=2},
	sounds = default.node_sound_leaves_defaults(),
	
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			burn(pos)
		end
	end,
})

minetest.register_node("tnt:gunpowder_burning", {
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	--tiles = {"tnt_gunpowder_burning.png"},
	tiles = {{name="tnt_gunpowder_burning_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1}}},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	drop = "",
	groups = {dig_immediate=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_abm({
	nodenames = {"tnt:tnt", "tnt:gunpowder"},
	neighbors = {"fire:basic_flame"},
	interval = 2,
	chance = 10,
	action = function(pos, node)
		if node.name == "tnt:tnt" then
			minetest.env:set_node(pos, {name="tnt:tnt_burning"})
			boom({x=pos.x, y=pos.y, z=pos.z}, 0)
		else
			burn(pos)
		end
	end
})

minetest.register_craft({
	output = "tnt:gunpowder",
	type = "shapeless",
	recipe = {"default:coal_lump", "default:gravel"}
})

minetest.register_craft({
	output = "tnt:tnt",
	recipe = {
		{"", "default:wood", ""},
		{"default:wood", "tnt:gunpowder", "default:wood"},
		{"", "default:wood", ""}
	}
})

minetest.register_entity("tnt:smoke", {
	physical = true,
	visual = "sprite",
	textures = {"tnt_smoke.png"},
	collisionbox = {0,0,0,0,0,0},
	
	timer = 0,
	time = 5,
	
	on_activate = function(self, staticdata)
		self.object:setacceleration({x=math.random(0,10)/10-0.5, y=5, z=math.random(0,10)/10-0.5})
		self.time = math.random(1, 10)/10
	end,
	
	on_step = function(self, dtime)
		self.timer = self.timer+dtime
		if self.timer > self.time then
			self.object:remove()
		end
	end,
})

if minetest.get_modpath("mesecons") ~= nil then
	minetest.after(0, function()
		
		--mesecon:add_rules("tnt_above", {{x=0,y=1,z=0}}) FIXME
		mesecon:register_effector("tnt:tnt", "tnt:tnt") --, mesecon:get_rules("tnt_above"))
		
		mesecon:register_on_signal_on(function(pos, node)
			if node.name == "tnt:tnt" then
				minetest.env:set_node(pos, {name="tnt:tnt_burning"})
				boom(pos, 0)
			end
		end)
		
	end)
end
