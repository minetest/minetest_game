doors = {}

-- Registers a door
function doors.register_door(name, def)
	def.groups.not_in_creative_inventory = 1

	local box = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5+1.5/16}}

	if not def.node_box_bottom then
		def.node_box_bottom = box
	end
	if not def.node_box_top then
		def.node_box_top = box
	end
	if not def.selection_box_bottom then
		def.selection_box_bottom= box
	end
	if not def.selection_box_top then
		def.selection_box_top = box
	end

	if not def.sound_close_door then
		def.sound_close_door = "doors_door_close"
	end
	if not def.sound_open_door then
		def.sound_open_door = "doors_door_open"
	end
	
	
	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,

		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return itemstack
			end

			local ptu = pointed_thing.under
			local nu = minetest.get_node(ptu)
			if minetest.registered_nodes[nu.name].on_rightclick then
				return minetest.registered_nodes[nu.name].on_rightclick(ptu, nu, placer, itemstack)
			end

			local pt = pointed_thing.above
			local pt2 = {x=pt.x, y=pt.y, z=pt.z}
			pt2.y = pt2.y+1
			if
				not minetest.registered_nodes[minetest.get_node(pt).name].buildable_to or
				not minetest.registered_nodes[minetest.get_node(pt2).name].buildable_to or
				not placer or
				not placer:is_player()
			then
				return itemstack
			end

			if minetest.is_protected(pt, placer:get_player_name()) or
					minetest.is_protected(pt2, placer:get_player_name()) then
				minetest.record_protection_violation(pt, placer:get_player_name())
				return itemstack
			end

			local p2 = minetest.dir_to_facedir(placer:get_look_dir())
			local pt3 = {x=pt.x, y=pt.y, z=pt.z}
			if p2 == 0 then
				pt3.x = pt3.x-1
			elseif p2 == 1 then
				pt3.z = pt3.z+1
			elseif p2 == 2 then
				pt3.x = pt3.x+1
			elseif p2 == 3 then
				pt3.z = pt3.z-1
			end
			if minetest.get_item_group(minetest.get_node(pt3).name, "door") == 0 then
				minetest.set_node(pt, {name=name.."_b_1", param2=p2})
				minetest.set_node(pt2, {name=name.."_t_1", param2=p2})
			else
				minetest.set_node(pt, {name=name.."_b_2", param2=p2})
				minetest.set_node(pt2, {name=name.."_t_2", param2=p2})
				minetest.get_meta(pt):set_int("right", 1)
				minetest.get_meta(pt2):set_int("right", 1)
			end

			if def.only_placer_can_open then
				local pn = placer:get_player_name()
				local meta = minetest.get_meta(pt)
				meta:set_string("doors_owner", pn)
				meta:set_string("infotext", "Owned by "..pn)
				meta = minetest.get_meta(pt2)
				meta:set_string("doors_owner", pn)
				meta:set_string("infotext", "Owned by "..pn)
			end

			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
	})

	local tt = def.tiles_top
	local tb = def.tiles_bottom
	
	local function after_dig_node(pos, name, digger)
		local node = minetest.get_node(pos)
		if node.name == name then
			minetest.node_dig(pos, node, digger)
		end
	end

	local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
		pos.y = pos.y+dir
		if not minetest.get_node(pos).name == check_name then
			return
		end
		local p2 = minetest.get_node(pos).param2
		p2 = params[p2+1]
		
		minetest.swap_node(pos, {name=replace_dir, param2=p2})
		
		pos.y = pos.y-dir
		minetest.swap_node(pos, {name=replace, param2=p2})

		local snd_1 = def.sound_close_door
		local snd_2 = def.sound_open_door 
		if params[1] == 3 then
			snd_1 = def.sound_open_door 
			snd_2 = def.sound_close_door
		end

		if minetest.get_meta(pos):get_int("right") ~= 0 then
			minetest.sound_play(snd_1, {pos = pos, gain = 0.3, max_hear_distance = 10})
		else
			minetest.sound_play(snd_2, {pos = pos, gain = 0.3, max_hear_distance = 10})
		end
	end

	local function check_player_priv(pos, player)
		if not def.only_placer_can_open then
			return true
		end
		local meta = minetest.get_meta(pos)
		local pn = player:get_player_name()
		return meta:get_string("doors_owner") == pn
	end

	local function on_rotate(pos, node, dir, user, check_name, mode, new_param2)
		if not check_player_priv(pos, user) then
			return false
		end
		if mode ~= screwdriver.ROTATE_FACE then
			return false
		end

		pos.y = pos.y + dir
		if not minetest.get_node(pos).name == check_name then
			return false
		end
		if minetest.is_protected(pos, user:get_player_name()) then
			minetest.record_protection_violation(pos, user:get_player_name())
			return false
		end

		local node2 = minetest.get_node(pos)
		node2.param2 = (node2.param2 + 1) % 4
		minetest.swap_node(pos, node2)

		pos.y = pos.y - dir
		node.param2 = (node.param2 + 1) % 4
		minetest.swap_node(pos, node)
		return true
	end

	minetest.register_node(name.."_b_1", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], tb[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_1", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
			end
		end,
		
		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, 1, user, name.."_t_1", mode)
		end,

		can_dig = check_player_priv,
		sounds = def.sounds,
        	sunlight_propagates = def.sunlight
	})

	minetest.register_node(name.."_t_1", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], tt[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_1", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
			end
		end,
		
		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, -1, user, name.."_b_1", mode)
		end,

		can_dig = check_player_priv,
		sounds = def.sounds,
        	sunlight_propagates = def.sunlight,
	})

	minetest.register_node(name.."_b_2", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1].."^[transformfx", tb[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_2", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
			end
		end,
		
		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, 1, user, name.."_t_2", mode)
		end,

		can_dig = check_player_priv,
		sounds = def.sounds,
        	sunlight_propagates = def.sunlight
	})

	minetest.register_node(name.."_t_2", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1].."^[transformfx", tt[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_2", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
			end
		end,
		
		on_rotate = function(pos, node, user, mode, new_param2)
			return on_rotate(pos, node, -1, user, name.."_b_2", mode)
		end,

		can_dig = check_player_priv,
		sounds = def.sounds,
        	sunlight_propagates = def.sunlight
	})

end

doors.register_door("doors:door_wood", {
	description = "Wooden Door",
	inventory_image = "doors_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,door=1},
	tiles_bottom = {"doors_wood_b.png", "doors_brown.png"},
	tiles_top = {"doors_wood_a.png", "doors_brown.png"},
	sounds = default.node_sound_wood_defaults(),
	sunlight = false,
})

minetest.register_craft({
	output = "doors:door_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

doors.register_door("doors:door_steel", {
	description = "Steel Door",
	inventory_image = "doors_steel.png",
	groups = {snappy=1,bendy=2,cracky=1,melty=2,level=2,door=1},
	tiles_bottom = {"doors_steel_b.png", "doors_grey.png"},
	tiles_top = {"doors_steel_a.png", "doors_grey.png"},
	only_placer_can_open = true,
	sounds = default.node_sound_wood_defaults(),
	sunlight = false,
})

minetest.register_craft({
	output = "doors:door_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})

doors.register_door("doors:door_glass", {
	description = "Glass Door",
	inventory_image = "doors_glass.png",
	groups = {snappy=1,cracky=1,oddly_breakable_by_hand=3,door=1},
	tiles_bottom = {"doors_glass_b.png", "doors_glass_side.png"},
	tiles_top = {"doors_glass_a.png", "doors_glass_side.png"},
	sounds = default.node_sound_glass_defaults(),
	sunlight = true,
})

minetest.register_craft({
	output = "doors:door_glass",
	recipe = {
		{"default:glass", "default:glass"},
		{"default:glass", "default:glass"},
		{"default:glass", "default:glass"}
	}
})

doors.register_door("doors:door_obsidian_glass", {
	description = "Obsidian Glass Door",
	inventory_image = "doors_obsidian_glass.png",
	groups = {snappy=1,cracky=1,oddly_breakable_by_hand=3,door=1},
	tiles_bottom = {"doors_obsidian_glass_b.png", "doors_obsidian_glass_side.png"},
	tiles_top = {"doors_obsidian_glass_a.png", "doors_obsidian_glass_side.png"},
	sounds = default.node_sound_glass_defaults(),
	sunlight = true,
})

minetest.register_craft({
	output = "doors:door_obsidian_glass",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass"}
	}
})


----trapdoor----

function doors.register_trapdoor(name, def)
	local name_closed = name
	local name_opened = name.."_open"

	def.on_rightclick = function (pos, node)
		local newname = node.name == name_closed and name_opened or name_closed
		local sound = false
		if node.name == name_closed then sound = def.sound_open end
		if node.name == name_opened then sound = def.sound_close end
		if sound then
			minetest.sound_play(sound, {pos = pos, gain = 0.3, max_hear_distance = 10})
		end
		minetest.set_node(pos, {name = newname, param1 = node.param1, param2 = node.param2})
	end

	def.on_rotate = screwdriver.rotate_simple

	-- Common trapdoor configuration
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	def_closed.node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
	}
	def_closed.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
	}
	def_closed.tiles = { def.tile_front, def.tile_front, def.tile_side, def.tile_side,
		def.tile_side, def.tile_side }

	def_opened.node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	}
	def_opened.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	}
	def_opened.tiles = { def.tile_side, def.tile_side, def.tile_side, def.tile_side,
		def.tile_front, def.tile_front }
	def_opened.drop = name_closed
	def_opened.groups.not_in_creative_inventory = 1

	minetest.register_node(name_opened, def_opened)
	minetest.register_node(name_closed, def_closed)
end



doors.register_trapdoor("doors:trapdoor", {
	description = "Trapdoor",
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=2, door=1},
	sounds = default.node_sound_wood_defaults(),
	sound_open = "doors_door_open",
	sound_close = "doors_door_close"
})

minetest.register_craft({
	output = 'doors:trapdoor 2',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', '', ''},
	}
})
