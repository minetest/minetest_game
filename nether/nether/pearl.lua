
local function throw_pearl(item, player)
	local playerpos = player:get_pos()
	playerpos.y = playerpos.y+1.625
	local obj = minetest.add_entity(playerpos, "nether:pearl_entity")
	local dir = player:get_look_dir()
	obj:setvelocity(vector.multiply(dir, 30))
	obj:setacceleration({x=dir.x*-3, y=-dir.y^8*80-10, z=dir.z*-3})
	local pname = player:get_player_name()
	obj:get_luaentity().player = pname
	if not minetest.is_creative_enabled(pname) then
		item:take_item()
		return item
	end
end

local function get_node(pos)
	local name = minetest.get_node(pos).name
	if name ~= "ignore" then
		return name
	end
	minetest.get_voxel_manip():read_from_map(pos, pos)
	name = minetest.get_node_or_nil(pos)
	if not name then
		return
	end
	return name.name
end

local softs = {}
local function is_soft(pos)
	local name = get_node(pos)
	if not name then
		return false
	end
	local is_soft = softs[name]
	if is_soft ~= nil then
		return is_soft
	end
	if not minetest.registered_nodes[name] then
		softs[name] = false
		return false
	end
	is_soft = minetest.registered_nodes[name].walkable == false
	softs[name] = is_soft
	return is_soft
end

-- teleports the player there if there's free space
local function teleport_player(pos, player)
	if not is_soft(pos) then
		return false
	end
	if not is_soft({x=pos.x, y=pos.y+1, z=pos.z})
	and not is_soft({x=pos.x, y=pos.y-1, z=pos.z}) then
		return false
	end
	pos.y = pos.y+0.05
	player:moveto(pos)
	return true
end

--[[
local dg_ps = {}
local function forceload(pos)
	dg_ps[#dg_ps+1] = pos
	minetest.forceload_block(pos)
	minetest.after(5, function(pos)
		minetest.forceload_free_block(pos)
		for i,p in pairs(dg_ps) do
			if vector.equals(p, pos) then
				dg_ps[i] = nil
				return
			end
		end
	end, pos)
end
minetest.register_on_shutdown(function()
	for _,p in pairs(dg_ps) do
		minetest.forceload_free_block(p)
	end
end)--]]

minetest.register_entity("nether:pearl_entity", {
	collisionbox = {0,0,0,0,0,0}, --not pointable
	visual_size = {x=0.1, y=0.1},
	physical = false, -- Collides with things
	textures = {"nether_pearl.png"},
	on_activate = function(self, staticdata)
		if not staticdata
		or staticdata == "" then
			return
		end
		local tmp = minetest.deserialize(staticdata)
		if not tmp then
			minetest.log("error", "[nether] pearl: invalid staticdata ")
			return
		end
		self.player = tmp.player
	end,
	get_staticdata = function(self)
		--forceload(vector.round(self.object:get_pos()))
		return minetest.serialize({
			player = self.player,
		})
	end,
	timer = 0,
	on_step = function(self, dtime)
		self.timer = self.timer+dtime

	--[[
		local delay = self.delay
		if delay < 0.1 then
			self.delay = delay+dtime
			return
		end
		self.delay = 0--]]

		if self.timer > 20 then
			self.object:remove()
			return
		end

		local pos = self.object:get_pos()
		local rpos = vector.round(pos)
		local lastpos = self.lastpos
		if not lastpos then
			self.lastpos = vector.new(rpos)
			return
		end
		if lastpos.x
		and vector.equals(vector.round(lastpos), rpos) then
			return
		end

		local player = self.player
		if not player then
			minetest.log("error", "[nether] pearl: missing playername")
			self.object:remove()
			return
		end
		player = minetest.get_player_by_name(player)
		if not player then
			minetest.log("error", "[nether] pearl: missing player")
			self.object:remove()
			return
		end

		if not get_node(rpos) then
			minetest.log("error", "[nether] pearl: missing node")
			self.object:remove()
			return
		end

		self.lastpos = vector.new(pos)

		local free, p = minetest.line_of_sight(lastpos, pos)
		if free then
			return
		end
		if is_soft(p) then
			return
		end
		self.object:remove()
		minetest.after(0, function(p) --minetest.after is used that the sound is played after the teleportation
			minetest.sound_play("nether_pearl", {pos=p, max_hear_distance=10})
		end, p)
		p.y = p.y+1
		if teleport_player(vector.new(p), player) then
			return
		end
		p.y = p.y-2
		for i = -1,1,2 do
			for _,j in pairs({{i, 0}, {0, i}}) do
				if teleport_player({x=p.x+j[1], y=p.y, z=p.z+j[2]}, player) then
					return
				end
			end
		end
		for i = -1,1,2 do
			for j = -1,1,2 do
				if teleport_player({x=p.x+j, y=p.y, z=p.z+i}, player) then
					return
				end
			end
		end
	end
})

minetest.override_item("nether:pearl", {on_use = throw_pearl})
