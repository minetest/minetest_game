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


--
-- Sounds
--

-- Update fire sounds in sound area of position
-- Deprected but kept temporarily as an empty function to not break mod
-- fire nodes that call this

function fire.update_sounds_around(pos)
end


--
-- ABMs
--

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
