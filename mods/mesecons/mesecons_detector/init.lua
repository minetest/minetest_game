-- Object detector
-- Detects players in a certain radius
-- The radius can be specified in mesecons/settings.lua

local object_detector_make_formspec = function (pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", "size[9,2.5]" ..
		"field[0.3,  0;9,2;scanname;Name of player to scan for (empty for any):;${scanname}]"..
		"field[0.3,1.5;4,2;digiline_channel;Digiline Channel (optional):;${digiline_channel}]"..
		"button_exit[7,0.75;2,3;;Save]")
end

local object_detector_on_receive_fields = function(pos, formname, fields)
	if fields.quit then
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("scanname", fields.scanname)
	meta:set_string("digiline_channel", fields.digiline_channel)
	object_detector_make_formspec(pos)
end

-- returns true if player was found, false if not
local object_detector_scan = function (pos)
	local objs = minetest.get_objects_inside_radius(pos, OBJECT_DETECTOR_RADIUS)
	for k, obj in pairs(objs) do
		local isname = obj:get_player_name() -- "" is returned if it is not a player; "" ~= nil!
		local scanname = minetest.get_meta(pos):get_string("scanname")
		if (isname == scanname and isname ~= "") or (isname  ~= "" and scanname == "") then -- player with scanname found or not scanname specified
			return true
		end
	end
	return false
end

-- set player name when receiving a digiline signal on a specific channel
object_detector_digiline = {
	effector = {
		action = function (pos, node, channel, msg)
			local meta = minetest.get_meta(pos)
			local active_channel = meta:get_string("digiline_channel")
			if channel == active_channel then
				meta:set_string("scanname", msg)
				object_detector_make_formspec(pos)
			end
		end,
	}
}

minetest.register_node("mesecons_detector:object_detector_off", {
	tiles = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"},
	paramtype = "light",
	walkable = true,
	groups = {cracky=3},
	description="Player Detector",
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_construct = object_detector_make_formspec,
	on_receive_fields = object_detector_on_receive_fields,
	sounds = default.node_sound_stone_defaults(),
	digiline = object_detector_digiline
})

minetest.register_node("mesecons_detector:object_detector_on", {
	tiles = {"default_steel_block.png", "default_steel_block.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png"},
	paramtype = "light",
	walkable = true,
	groups = {cracky=3,not_in_creative_inventory=1},
	drop = 'mesecons_detector:object_detector_off',
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_construct = object_detector_make_formspec,
	on_receive_fields = object_detector_on_receive_fields,
	sounds = default.node_sound_stone_defaults(),
	digiline = object_detector_digiline
})

minetest.register_craft({
	output = 'mesecons_detector:object_detector_off',
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "mesecons_luacontroller:luacontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "group:mesecon_conductor_craftable", "default:steel_ingot"},
	}
})

minetest.register_abm(
	{nodenames = {"mesecons_detector:object_detector_off"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		if object_detector_scan(pos) then
			minetest.swap_node(pos, {name = "mesecons_detector:object_detector_on"})
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm(
	{nodenames = {"mesecons_detector:object_detector_on"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		if not object_detector_scan(pos) then
			minetest.swap_node(pos, {name = "mesecons_detector:object_detector_off"})
			mesecon:receptor_off(pos)
		end
	end,
})
