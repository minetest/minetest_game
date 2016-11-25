-- minetest/fire/init.lua

-- Global namespace for functions

fire = {}


-- Register flame nodes

minetest.register_node("fire:basic_flame", {
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 14,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 4,
	groups = {igniter = 2, dig_immediate = 3, not_in_creative_inventory = 1},
	on_timer = function(pos)
		local f = minetest.find_node_near(pos, 1, {"group:flammable"})
		if not f then
			minetest.remove_node(pos)
			return
		end
		-- restart timer
		return true
	end,
	drop = "",

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(30, 60))
		minetest.after(0, fire.update_sounds_around, pos)
	end,

	on_destruct = function(pos)
		minetest.after(0, fire.update_sounds_around, pos)
	end,

	on_blast = function()
	end, -- unaffected by explosions
})

minetest.register_node("fire:permanent_flame", {
	description = "Permanent Flame",
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 14,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 4,
	groups = {igniter = 2, dig_immediate = 3},
	drop = "",

	on_blast = function()
	end,
})


-- Flint and steel

minetest.register_tool("fire:flint_and_steel", {
	description = "Flint and Steel",
	inventory_image = "fire_flint_steel.png",
	sound = {breaks = "default_tool_breaks"},

	on_use = function(itemstack, user, pointed_thing)
		local pt = pointed_thing
		minetest.sound_play(
			"fire_flint_and_steel",
			{pos = pt.above, gain = 0.5, max_hear_distance = 8}
		)
		if pt.type == "node" then
			local node_under = minetest.get_node(pt.under).name
			local nodedef = minetest.registered_nodes[node_under]
			if not nodedef then
				return
			end
			local player_name = user:get_player_name()
			if minetest.is_protected(pt.under, player_name) then
				minetest.chat_send_player(player_name, "This area is protected")
				return
			end
			if nodedef.on_ignite then
				nodedef.on_ignite(pt.under, user)
			elseif minetest.get_item_group(node_under, "flammable") >= 1
					and minetest.get_node(pt.above).name == "air" then
				minetest.set_node(pt.above, {name = "fire:basic_flame"})
			end
		end
		if not minetest.setting_getbool("creative_mode") then
			-- wear tool
			local wdef = itemstack:get_definition()
			itemstack:add_wear(1000)
			-- tool break sound
			if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
				minetest.sound_play(wdef.sound.breaks, {pos = pt.above, gain = 0.5})
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "fire:flint_and_steel",
	recipe = {
		{"default:flint", "default:steel_ingot"}
	}
})


-- Override coalblock to enable permanent flame above
-- Coalblock is non-flammable to avoid unwanted basic_flame nodes

minetest.override_item("default:coalblock", {
	after_destruct = function(pos, oldnode)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "fire:permanent_flame" then
			minetest.remove_node(pos)
		end
	end,
	on_ignite = function(pos, igniter)
		local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		if minetest.get_node(flame_pos).name == "air" then
			minetest.set_node(flame_pos, {name = "fire:permanent_flame"})
		end
	end,
})

-- Get sound area of position

fire.D = 6 -- size of sound areas

function fire.get_area_p0p1(pos)
	local p0 = {
		x = math.floor(pos.x / fire.D) * fire.D,
		y = math.floor(pos.y / fire.D) * fire.D,
		z = math.floor(pos.z / fire.D) * fire.D,
	}
	local p1 = {
		x = p0.x + fire.D - 1,
		y = p0.y + fire.D - 1,
		z = p0.z + fire.D - 1
	}
	return p0, p1
end


-- Fire sounds table
-- key: position hash of low corner of area
-- value: {handle=sound handle, name=sound name}
fire.sounds = {}


-- Update fire sounds in sound area of position

function fire.update_sounds_around(pos)
	local p0, p1 = fire.get_area_p0p1(pos)
	local cp = {x = (p0.x + p1.x) / 2, y = (p0.y + p1.y) / 2, z = (p0.z + p1.z) / 2}
	local flames_p = minetest.find_nodes_in_area(p0, p1, {"fire:basic_flame"})
	--print("number of flames at "..minetest.pos_to_string(p0).."/"
	--		..minetest.pos_to_string(p1)..": "..#flames_p)
	local should_have_sound = (#flames_p > 0)
	local wanted_sound = nil
	if #flames_p >= 9 then
		wanted_sound = {name = "fire_large", gain = 0.7}
	elseif #flames_p > 0 then
		wanted_sound = {name = "fire_small", gain = 0.9}
	end
	local p0_hash = minetest.hash_node_position(p0)
	local sound = fire.sounds[p0_hash]
	if not sound then
		if should_have_sound then
			fire.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound,
					{pos = cp, max_hear_distance = 16, loop = true}),
				name = wanted_sound.name,
			}
		end
	else
		if not wanted_sound then
			minetest.sound_stop(sound.handle)
			fire.sounds[p0_hash] = nil
		elseif sound.name ~= wanted_sound.name then
			minetest.sound_stop(sound.handle)
			fire.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound,
					{pos = cp, max_hear_distance = 16, loop = true}),
				name = wanted_sound.name,
			}
		end
	end
end


-- Extinguish all flames quickly with water, snow, ice

minetest.register_abm({
	label = "Extinguish flame",
	nodenames = {"fire:basic_flame", "fire:permanent_flame"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
		minetest.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.25})
	end,
})


-- Enable the following ABMs according to 'enable fire' setting

local fire_enabled = minetest.setting_getbool("enable_fire")
if fire_enabled == nil then
	-- New setting not specified, check for old setting.
	-- If old setting is also not specified, 'not nil' is true.
	fire_enabled = not minetest.setting_getbool("disable_fire")
end

if not fire_enabled then

	-- Remove basic flames only

	minetest.register_abm({
		label = "Remove disabled fire",
		nodenames = {"fire:basic_flame"},
		interval = 7,
		chance = 1,
		catch_up = false,
		action = minetest.remove_node,
	})

else -- Fire enabled

	-- Ignite neighboring nodes, add basic flames

	minetest.register_abm({
		label = "Ignite flame",
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		interval = 7,
		chance = 12,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- If there is water or stuff like that around node, don't ignite
			if minetest.find_node_near(pos, 1, {"group:puts_out_fire"}) then
				return
			end
			local p = minetest.find_node_near(pos, 1, {"air"})
			if p then
				minetest.set_node(p, {name = "fire:basic_flame"})
			end
		end,
	})

	-- Remove flammable nodes

	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"fire:basic_flame"},
		neighbors = "group:flammable",
		interval = 5,
		chance = 18,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local p = minetest.find_node_near(pos, 1, {"group:flammable"})
			if p then
				-- remove flammable nodes around flame
				local flammable_node = minetest.get_node(p)
				local def = minetest.registered_nodes[flammable_node.name]
				if def.on_burn then
					def.on_burn(p)
				else
					minetest.remove_node(p)
					minetest.check_for_falling(p)
				end
			end
		end,
	})

end


-- Rarely ignite things from far

--[[ Currently disabled to reduce the chance of uncontrollable spreading
	fires that disrupt servers. Also for less lua processing load.

minetest.register_abm({
	nodenames = {"group:igniter"},
	neighbors = {"air"},
	interval = 5,
	chance = 10,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local reg = minetest.registered_nodes[node.name]
		if not reg or not reg.groups.igniter or reg.groups.igniter < 2 then
			return
		end
		local d = reg.groups.igniter
		local p = minetest.find_node_near(pos, d, {"group:flammable"})
		if p then
			-- If there is water or stuff like that around flame, don't ignite
			if fire.flame_should_extinguish(p) then
				return
			end
			local p2 = fire.find_pos_for_flame_around(p)
			if p2 then
				minetest.set_node(p2, {name = "fire:basic_flame"})
			end
		end
	end,
})
--]]
