
--[[

Copyright (C) 2012 PilzAdam
  modified by BlockMen (added sounds, glassdoors[glass, obsidian glass], trapdoor)
Copyright (C) 2015 - Auke Kok <sofar@foo-projects.org>

--]]

-- our API object
doors = {}

-- private data
local _doors = {}
_doors.registered_doors = {}
_doors.registered_trapdoors = {}

-- returns an object to a door object or nil
function doors.get(pos)
	if _doors.registered_doors[minetest.get_node(pos).name] then
		-- A normal upright door
		return {
			pos = pos,
			open = function(self, player)
				if self:state() then
					return false
				end
				return _doors.door_toggle(self.pos, player)
			end,
			close = function(self, player)
				if not self:state() then
					return false
				end
				return _doors.door_toggle(self.pos, player)
			end,
			toggle = function(self, player)
				return _doors.door_toggle(self.pos, player)
			end,
			state = function(self)
				local state = minetest.get_meta(self.pos):get_int("state")
				return state %2 == 1
			end
		}
	elseif _doors.registered_trapdoors[minetest.get_node(pos).name] then
		-- A trapdoor
		return {
			pos = pos,
			open = function(self, player)
				if self:state() then
					return false
				end
				return _doors.trapdoor_toggle(self.pos, player)
			end,
			close = function(self, player)
				if not self:state() then
					return false
				end
				return _doors.trapdoor_toggle(self.pos, player)
			end,
			toggle = function(self, player)
				return _doors.trapdoor_toggle(self.pos, player)
			end,
			state = function(self)
				local name = minetest.get_node(pos).name
				return name:sub(-5) == "_open"
			end
		}
	else
		return nil
	end
end

-- this hidden node is placed on top of the bottom, and prevents
-- nodes from being placed in the top half of the door.
minetest.register_node("doors:hidden", {
	description = "Hidden Door Segment",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = { not_in_creative_inventory = 1 },
	on_blast = function() end
})

-- table used to aid door opening/closing
local transform = {
	{
		{ v = "_a", param2 = 3 },
		{ v = "_a", param2 = 0 },
		{ v = "_a", param2 = 1 },
		{ v = "_a", param2 = 2 },
	},
	{
		{ v = "_b", param2 = 1 },
		{ v = "_b", param2 = 2 },
		{ v = "_b", param2 = 3 },
		{ v = "_b", param2 = 0 },
	},
	{
		{ v = "_b", param2 = 1 },
		{ v = "_b", param2 = 2 },
		{ v = "_b", param2 = 3 },
		{ v = "_b", param2 = 0 },
	},
	{
		{ v = "_a", param2 = 3 },
		{ v = "_a", param2 = 0 },
		{ v = "_a", param2 = 1 },
		{ v = "_a", param2 = 2 },
	},
}

function _doors.door_toggle(pos, clicker)
	local meta = minetest.get_meta(pos)
	local state = meta:get_int("state")
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	local name = def.door.basename

	if clicker then
		local owner = meta:get_string("doors_owner")
		if owner ~= "" then
			if clicker:get_player_name() ~= owner then
				return false
			end
		end
	end

	local old = state
	-- until Lua-5.2 we have no bitwise operators :(
	if state % 2 == 1 then
		state = state - 1
	else
		state = state + 1
	end

	local dir = minetest.get_node(pos).param2
	if state % 2 == 0 then
		minetest.sound_play(def.door.sounds[1], {pos = pos, gain = 0.3, max_hear_distance = 10})
	else
		minetest.sound_play(def.door.sounds[2], {pos = pos, gain = 0.3, max_hear_distance = 10})
	end

	minetest.swap_node(pos, {
		name = "doors:" .. name .. transform[state + 1][dir+1].v,
		param2 = transform[state + 1][dir+1].param2
	})
	meta:set_int("state", state)

	return true
end

function doors.register(name, def)
	-- replace old doors of this type automatically
	minetest.register_abm({
		nodenames = {"doors:"..name.."_b_1", "doors:"..name.."_b_2"},
		interval = 7.0,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local l = tonumber(node.name:sub(-1))
			local meta = minetest.get_meta(pos)
			local h = meta:get_int("right") + 1
			local p2 = node.param2
			local replace = {
				{ { type = "a", state = 0 }, { type = "a", state = 3 } },
				{ { type = "b", state = 1 }, { type = "b", state = 2 } }
			}
			local new = replace[l][h]
			-- retain infotext and doors_owner fields
			minetest.swap_node(pos, { name = "doors:" .. name .. "_" .. new.type, param2 = p2})
			meta:set_int("state", new.state)
			-- wipe meta on top node as it's unused
			minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z}, { name = "doors:hidden" })
		end
	})

	minetest.register_craftitem(":doors:" .. name, {
		description = def.description,
		inventory_image = def.inventory_image,

		on_place = function(itemstack, placer, pointed_thing)
			local pos = nil

			if not pointed_thing.type == "node" then
				return itemstack
			end

			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under,
						node, placer, itemstack)
			end

			if def and def.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				node = minetest.get_node(pos)
				def = minetest.registered_nodes[node.name]
				if not def or not def.buildable_to then
					return itemstack
				end
			end

			local above = { x = pos.x, y = pos.y + 1, z = pos.z }
			if not minetest.registered_nodes[minetest.get_node(above).name].buildable_to then
				return itemstack
			end

			local dir = minetest.dir_to_facedir(placer:get_look_dir())

			local ref = {
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = 0, y = 0, z = -1 },
			}

			local aside = {
				x = pos.x + ref[dir + 1].x,
				y = pos.y + ref[dir + 1].y,
				z = pos.z + ref[dir + 1].z,
			}

			local state = 0
			if minetest.get_item_group(minetest.get_node(aside).name, "door") == 1 then
				state = state + 2
				minetest.set_node(pos, {name = "doors:" .. name .. "_b", param2 = dir})
			else
				minetest.set_node(pos, {name = "doors:" .. name .. "_a", param2 = dir})
			end
			minetest.set_node(above, { name = "doors:hidden" })

			local meta = minetest.get_meta(pos)
			meta:set_int("state", state)

			if def.protected then
				local pn = placer:get_player_name()
				meta:set_string("doors_owner", pn)
				meta:set_string("infotext", "Owned by " .. pn)
			end

			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end

			return itemstack
		end
	})

	local can_dig = function(pos, digger)
		if not def.protected then
			return true
		end
		local meta = minetest.get_meta(pos)
		return meta:get_string("doors_owner") == digger:get_player_name()
	end

	if not def.sounds then
		def.sounds = default.node_sound_wood_defaults()
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end

	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	def.groups.not_in_creative_inventory = 1
	def.groups.door = 1
	def.drop = "doors:" .. name
	def.door = {
		basename = name,
		sounds = { def.sound_close, def.sound_open },
	}

	def.on_rightclick = function(pos, node, clicker)
		_doors.door_toggle(pos, clicker)
	end
	def.after_dig_node = function(pos, node, meta, digger)
		minetest.remove_node({ x = pos.x, y = pos.y + 1, z = pos.z})
	end
	def.can_dig = function(pos, player)
		return can_dig(pos, player)
	end
	def.on_rotate = function(pos, node, user, mode, new_param2)
		return false
	end

	if def.protected then
		def.on_blast = function() end
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			-- hidden node doesn't get blasted away.
			minetest.remove_node({ x = pos.x, y = pos.y + 1, z = pos.z})
			return { "doors:" .. name }
		end
	end

	minetest.register_node(":doors:" .. name .. "_a", {
		description = def.description,
		visual = "mesh",
		mesh = "door_a.obj",
		tiles = def.tiles,
		drawtype = "mesh",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		use_texture_alpha = true,
		walkable = true,
		is_ground_content = false,
		buildable_to = false,
		drop = def.drop,
		groups = def.groups,
		sounds = def.sounds,
		door = def.door,
		on_rightclick = def.on_rightclick,
		after_dig_node = def.after_dig_node,
		can_dig = def.can_dig,
		on_rotate = def.on_rotate,
		on_blast = def.on_blast,
		selection_box = {
			type = "fixed",
			fixed = { -1/2,-1/2,-1/2,1/2,3/2,-6/16}
		},
		collision_box = {
			type = "fixed",
			fixed = { -1/2,-1/2,-1/2,1/2,3/2,-6/16}
		},
	})

	minetest.register_node(":doors:" .. name .. "_b", {
		description = def.description,
		visual = "mesh",
		mesh = "door_b.obj",
		tiles = def.tiles,
		drawtype = "mesh",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		use_texture_alpha = true,
		walkable = true,
		is_ground_content = false,
		buildable_to = false,
		drop = def.drop,
		groups = def.groups,
		sounds = def.sounds,
		door = def.door,
		on_rightclick = def.on_rightclick,
		after_dig_node = def.after_dig_node,
		can_dig = def.can_dig,
		on_rotate = def.on_rotate,
		on_blast = def.on_blast,
		selection_box = {
			type = "fixed",
			fixed = { -1/2,-1/2,-1/2,1/2,3/2,-6/16}
		},
		collision_box = {
			type = "fixed",
			fixed = { -1/2,-1/2,-1/2,1/2,3/2,-6/16}
		},
	})

	minetest.register_craft({
		output = "doors:" .. name,
		recipe = {
			{def.material,def.material};
			{def.material,def.material};
			{def.material,def.material};
		}
	})

	_doors.registered_doors["doors:" .. name .. "_a"] = true
	_doors.registered_doors["doors:" .. name .. "_b"] = true
end

doors.register("door_wood", {
		tiles = {{ name = "doors_door_wood.png", backface_culling = true }},
		description = "Wooden Door",
		inventory_image = "doors_item_wood.png",
		groups = { snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
		material = "group:wood",
})

doors.register("door_steel", {
		tiles = {{ name = "doors_door_steel.png", backface_culling = true }},
		description = "Steel Door",
		inventory_image = "doors_item_steel.png",
		protected = true,
		groups = { snappy = 1, bendy = 2, cracky = 1, melty = 2, level = 2 },
		material = "default:steel_ingot",
})

doors.register("door_glass", {
		tiles = { "doors_door_glass.png"},
		description = "Glass Door",
		inventory_image = "doors_item_glass.png",
		groups = { snappy=1, cracky=1, oddly_breakable_by_hand=3 },
		material = "default:glass",
		sounds = default.node_sound_glass_defaults(),
})

doors.register("door_obsidian_glass", {
		tiles = { "doors_door_obsidian_glass.png" },
		description = "Glass Door",
		inventory_image = "doors_item_obsidian_glass.png",
		groups = { snappy=1, cracky=1, oddly_breakable_by_hand=3 },
		material = "default:obsidian_glass",
		sounds = default.node_sound_glass_defaults(),
})

----trapdoor----

function _doors.trapdoor_toggle(pos, clicker)
	if clicker then
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("doors_owner")
		if owner ~= "" then
			if clicker:get_player_name() ~= owner then
				return false
			end
		end
	end

	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	if string.sub(node.name, -5) == "_open" then
		minetest.sound_play(def.sound_close, {pos = pos, gain = 0.3, max_hear_distance = 10})
		minetest.swap_node(pos, {name = string.sub(node.name, 1, string.len(node.name) - 5), param1 = node.param1, param2 = node.param2})
	else
		minetest.sound_play(def.sound_open, {pos = pos, gain = 0.3, max_hear_distance = 10})
		minetest.swap_node(pos, {name = node.name .. "_open", param1 = node.param1, param2 = node.param2})
	end
end

function doors.register_trapdoor(name, def)
	local name_closed = name
	local name_opened = name.."_open"

	local function check_player_priv(pos, player)
		if not def.protected then
			return true
		end
		local meta = minetest.get_meta(pos)
		local pn = player:get_player_name()
		return meta:get_string("doors_owner") == pn
	end

	def.on_rightclick = function(pos, node, clicker)
		_doors.trapdoor_toggle(pos, clicker)
	end

	-- Common trapdoor configuration
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.is_ground_content = false
	def.can_dig = check_player_priv

	if def.protected then
		def.after_place_node = function(pos, placer, itemstack, pointed_thing)
			local pn = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("doors_owner", pn)
			meta:set_string("infotext", "Owned by "..pn)

			return minetest.setting_getbool("creative_mode")
		end

		def.on_blast = function() end
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			minetest.remove_node({ x = pos.x, y = pos.y + 1, z = pos.z})
			return { name }
		end
	end

	if not def.sounds then
		def.sounds = default.node_sound_wood_defaults()
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end

	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	def_closed.node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}
	def_closed.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}
	def_closed.tiles = { def.tile_front, def.tile_front, def.tile_side, def.tile_side,
		def.tile_side, def.tile_side }

	def_opened.node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}
	def_opened.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}
	def_opened.tiles = { def.tile_side, def.tile_side,
			def.tile_side .. '^[transform3',
			def.tile_side .. '^[transform1',
			def.tile_front, def.tile_front }

	def_opened.drop = name_closed
	def_opened.groups.not_in_creative_inventory = 1

	minetest.register_node(name_opened, def_opened)
	minetest.register_node(name_closed, def_closed)

	_doors.registered_trapdoors[name_opened] = true
	_doors.registered_trapdoors[name_closed] = true
end

doors.register_trapdoor("doors:trapdoor", {
	description = "Trapdoor",
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=2, door=1},
})

doors.register_trapdoor("doors:trapdoor_steel", {
	description = "Steel Trapdoor",
	inventory_image = "doors_trapdoor_steel.png",
	wield_image = "doors_trapdoor_steel.png",
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	protected = true,
	groups = {snappy=1, bendy=2, cracky=1, melty=2, level=2, door=1},
})

minetest.register_craft({
	output = 'doors:trapdoor 2',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'doors:trapdoor_steel',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot'},
	}
})

