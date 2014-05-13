local pp_box_off = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
}

local pp_box_on = {
	type = "fixed",
	fixed = { -7/16, -8/16, -7/16, 7/16, -7.5/16, 7/16 },
}

pp_on_timer = function (pos, elapsed)
	local node   = minetest.get_node(pos)
	local ppspec = minetest.registered_nodes[node.name].pressureplate

	-- This is a workaround for a strange bug that occurs when the server is started
	-- For some reason the first time on_timer is called, the pos is wrong
	if not ppspec then return end

	local objs   = minetest.get_objects_inside_radius(pos, 1)
	local two_below = mesecon:addPosRule(pos, {x = 0, y = -2, z = 0})

	if objs[1] == nil and node.name == ppspec.onstate then
		minetest.add_node(pos, {name = ppspec.offstate})
		mesecon:receptor_off(pos)
		-- force deactivation of mesecon two blocks below (hacky)
		if not mesecon:connected_to_receptor(two_below) then
			mesecon:turnoff(two_below)
		end
	else
		for k, obj in pairs(objs) do
			local objpos = obj:getpos()
			if objpos.y > pos.y-1 and objpos.y < pos.y then
				minetest.add_node(pos, {name=ppspec.onstate})
				mesecon:receptor_on(pos)
				-- force activation of mesecon two blocks below (hacky)
				mesecon:turnon(two_below)
			end
		end
	end
	return true
end

-- Register a Pressure Plate
-- offstate:	name of the pressure plate when inactive
-- onstate:	name of the pressure plate when active
-- description:	description displayed in the player's inventory
-- tiles_off:	textures of the pressure plate when inactive
-- tiles_on:	textures of the pressure plate when active
-- image:	inventory and wield image of the pressure plate
-- recipe:	crafting recipe of the pressure plate

function mesecon:register_pressure_plate(offstate, onstate, description, textures_off, textures_on, image_w, image_i, recipe)
	local ppspec = {
		offstate = offstate,
		onstate  = onstate
	}

	minetest.register_node(offstate, {
		drawtype = "nodebox",
		tiles = textures_off,
		inventory_image = image_i,
		wield_image = image_w,
		paramtype = "light",
		selection_box = pp_box_off,
		node_box = pp_box_off,
		groups = {snappy = 2, oddly_breakable_by_hand = 3},
	    	description = description,
		pressureplate = ppspec,
		on_timer = pp_on_timer,
		mesecons = {receptor = {
			state = mesecon.state.off
		}},
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
	})

	minetest.register_node(onstate, {
		drawtype = "nodebox",
		tiles = textures_on,
		paramtype = "light",
		selection_box = pp_box_on,
		node_box = pp_box_on,
		groups = {snappy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
		drop = offstate,
		pressureplate = ppspec,
		on_timer = pp_on_timer,
		sounds = default.node_sound_wood_defaults(),
		mesecons = {receptor = {
			state = mesecon.state.on
		}},
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(PRESSURE_PLATE_INTERVAL)
		end,
		after_dig_node = function(pos)
			local two_below = mesecon:addPosRule(pos, {x = 0, y = -2, z = 0})
			if not mesecon:connected_to_receptor(two_below) then
				mesecon:turnoff(two_below)
			end
		end
	})

	minetest.register_craft({
		output = offstate,
		recipe = recipe,
	})
end

mesecon:register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_wood_off",
	"mesecons_pressureplates:pressure_plate_wood_on",
	"Wooden Pressure Plate",
	{"jeija_pressure_plate_wood_off.png","jeija_pressure_plate_wood_off.png","jeija_pressure_plate_wood_off_edges.png"},
	{"jeija_pressure_plate_wood_on.png","jeija_pressure_plate_wood_on.png","jeija_pressure_plate_wood_on_edges.png"},
	"jeija_pressure_plate_wood_wield.png",
	"jeija_pressure_plate_wood_inv.png",
	{{"group:wood", "group:wood"}})

mesecon:register_pressure_plate(
	"mesecons_pressureplates:pressure_plate_stone_off",
	"mesecons_pressureplates:pressure_plate_stone_on",
	"Stone Pressure Plate",
	{"jeija_pressure_plate_stone_off.png","jeija_pressure_plate_stone_off.png","jeija_pressure_plate_stone_off_edges.png"},
	{"jeija_pressure_plate_stone_on.png","jeija_pressure_plate_stone_on.png","jeija_pressure_plate_stone_on_edges.png"},
	"jeija_pressure_plate_stone_wield.png",
	"jeija_pressure_plate_stone_inv.png",
	{{"default:cobble", "default:cobble"}})
