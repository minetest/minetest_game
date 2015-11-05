-- minetest/fire/init.lua

-- Global namespace for functions

fire = {}


-- Register flame nodes

minetest.register_node("fire:basic_flame", {
	description = "Basic Flame",
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

	on_construct = function(pos)
		minetest.after(0, fire.on_flame_add_at, pos)
	end,

	on_destruct = function(pos)
		minetest.after(0, fire.on_flame_remove_at, pos)
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


-- Update fire sounds on flame node construct or destruct

function fire.on_flame_add_at(pos)
	fire.update_sounds_around(pos)
end


function fire.on_flame_remove_at(pos)
	fire.update_sounds_around(pos)
end


-- Return positions for flames around a burning node

function fire.find_pos_for_flame_around(pos)
	return minetest.find_node_near(pos, 1, {"air"})
end


-- Detect nearby extinguishing nodes

function fire.flame_should_extinguish(pos)
	return minetest.find_node_near(pos, 1, {"group:puts_out_fire"})
end


-- Extinguish all flames quickly with water, snow, ice

minetest.register_abm({
	nodenames = {"fire:basic_flame", "fire:permanent_flame"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 2,
	catch_up = false,
	action = function(p0, node, _, _)
		minetest.remove_node(p0)
		minetest.sound_play("fire_extinguish_flame",
			{pos = p0, max_hear_distance = 16, gain = 0.25})
	end,
})


-- Enable the following ABMs according to 'disable fire' setting

if minetest.setting_getbool("disable_fire") then

	-- Remove basic flames only

	minetest.register_abm({
		nodenames = {"fire:basic_flame"},
		interval = 7,
		chance = 2,
		catch_up = false,
		action = function(p0, node, _, _)
			minetest.remove_node(p0)
		end,
	})

else

	-- Ignite neighboring nodes, add basic flames

	minetest.register_abm({
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		interval = 7,
		chance = 16,
		catch_up = false,
		action = function(p0, node, _, _)
			-- If there is water or stuff like that around node, don't ignite
			if fire.flame_should_extinguish(p0) then
				return
			end
			local p = fire.find_pos_for_flame_around(p0)
			if p then
				minetest.set_node(p, {name = "fire:basic_flame"})
			end
		end,
	})

	-- Remove basic flames and flammable nodes

	minetest.register_abm({
		nodenames = {"fire:basic_flame"},
		interval = 5,
		chance = 16,
		catch_up = false,
		action = function(p0, node, _, _)
			-- If there are no flammable nodes around flame, remove flame
			if not minetest.find_node_near(p0, 1, {"group:flammable"}) then
				minetest.remove_node(p0)
				return
			end
			if math.random(1, 4) == 1 then
				-- remove flammable nodes around flame
				local p = minetest.find_node_near(p0, 1, {"group:flammable"})
				if p then
					minetest.remove_node(p)
					nodeupdate(p)
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
	action = function(p0, node, _, _)
		local reg = minetest.registered_nodes[node.name]
		if not reg or not reg.groups.igniter or reg.groups.igniter < 2 then
			return
		end
		local d = reg.groups.igniter
		local p = minetest.find_node_near(p0, d, {"group:flammable"})
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
