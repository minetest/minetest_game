-- naming scheme: wire:(xp)(zp)(xm)(zm)_on/off
-- The conditions in brackets define whether there is a mesecon at that place or not
-- 1 = there is one; 0 = there is none
-- y always means y+

box_center = {-1/16, -.5, -1/16, 1/16, -.5+1/16, 1/16}
box_bump1 =  { -2/16, -8/16,  -2/16, 2/16, -13/32, 2/16 }

box_xp = {1/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}
box_zp = {-1/16, -.5, 1/16, 1/16, -.5+1/16, 8/16}
box_xm = {-8/16, -.5, -1/16, -1/16, -.5+1/16, 1/16}
box_zm = {-1/16, -.5, -8/16, 1/16, -.5+1/16, -1/16}

box_xpy = {.5-1/16, -.5+1/16, -1/16, .5, .4999+1/16, 1/16}
box_zpy = {-1/16, -.5+1/16, .5-1/16, 1/16, .4999+1/16, .5}
box_xmy = {-.5, -.5+1/16, -1/16, -.5+1/16, .4999+1/16, 1/16}
box_zmy = {-1/16, -.5+1/16, -.5, 1/16, .4999+1/16, -.5+1/16}

-- Registering the wires

for xp=0, 1 do
for zp=0, 1 do
for xm=0, 1 do
for zm=0, 1 do
for xpy=0, 1 do
for zpy=0, 1 do
for xmy=0, 1 do
for zmy=0, 1 do
	if (xpy == 1 and xp == 0) or (zpy == 1 and zp == 0) 
	or (xmy == 1 and xm == 0) or (zmy == 1 and zm == 0) then break end

	local groups
	local nodeid = 	tostring(xp )..tostring(zp )..tostring(xm )..tostring(zm )..
			tostring(xpy)..tostring(zpy)..tostring(xmy)..tostring(zmy)

	if nodeid == "00000000" then
		groups = {dig_immediate = 3, mesecon_conductor_craftable=1}
		wiredesc = "Mesecon"
	else
		groups = {dig_immediate = 3, not_in_creative_inventory = 1}
		wiredesc = "Mesecons Wire (ID: "..nodeid..")"
	end

	local nodebox = {}
	local adjx = false
	local adjz = false
	if xp == 1 then table.insert(nodebox, box_xp) adjx = true end
	if zp == 1 then table.insert(nodebox, box_zp) adjz = true end
	if xm == 1 then table.insert(nodebox, box_xm) adjx = true end
	if zm == 1 then table.insert(nodebox, box_zm) adjz = true end
	if xpy == 1 then table.insert(nodebox, box_xpy) end
	if zpy == 1 then table.insert(nodebox, box_zpy) end
	if xmy == 1 then table.insert(nodebox, box_xmy) end
	if zmy == 1 then table.insert(nodebox, box_zmy) end

	if adjx and adjz and (xp + zp + xm + zm > 2) then
		table.insert(nodebox, box_bump1)
		tiles_off = {
			"wires_bump_off.png",
			"wires_bump_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png"
		}
		tiles_on = {
			"wires_bump_on.png",
			"wires_bump_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png"
		}
	else
		table.insert(nodebox, box_center)
		tiles_off = {
			"wires_off.png",
			"wires_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png",
			"wires_vertical_off.png"
		}
		tiles_on = {
			"wires_on.png",
			"wires_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png",
			"wires_vertical_on.png"
		}
	end

	if nodeid == "00000000" then
		nodebox = {-8/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}
	end

	minetest.register_node("mesecons:wire_"..nodeid.."_off", {
		description = wiredesc,
		drawtype = "nodebox",
		tiles = tiles_off,
--		inventory_image = "wires_inv.png",
--		wield_image = "wires_inv.png",
		inventory_image = "jeija_mesecon_off.png",
		wield_image = "jeija_mesecon_off.png",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		selection_box = {
              		type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.5+4/16, .5}
		},
		node_box = {
			type = "fixed",
			fixed = nodebox
		},
		groups = groups,
		walkable = false,
		stack_max = 99,
		drop = "mesecons:wire_00000000_off",
		mesecons = {conductor={
			state = mesecon.state.off,
			onstate = "mesecons:wire_"..nodeid.."_on"
		}}
	})

	minetest.register_node("mesecons:wire_"..nodeid.."_on", {
		description = "Wire ID:"..nodeid,
		drawtype = "nodebox",
		tiles = tiles_on,
--		inventory_image = "wires_inv.png",
--		wield_image = "wires_inv.png",
		inventory_image = "jeija_mesecon_off.png",
		wield_image = "jeija_mesecon_off.png",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		selection_box = {
              		type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.5+4/16, .5}
		},
		node_box = {
			type = "fixed",
			fixed = nodebox
		},
		groups = {dig_immediate = 3, mesecon = 2, not_in_creative_inventory = 1},
		walkable = false,
		stack_max = 99,
		drop = "mesecons:wire_00000000_off",
		mesecons = {conductor={
			state = mesecon.state.on,
			offstate = "mesecons:wire_"..nodeid.."_off"
		}}
	})
end
end
end
end
end
end
end
end

-- Updating the wires:
-- Place the right connection wire

local update_on_place_dig = function (pos, node)
	if minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecons then
		mesecon:update_autoconnect(pos)
	end
end

minetest.register_on_placenode(update_on_place_dig)
minetest.register_on_dignode(update_on_place_dig)

function mesecon:update_autoconnect(pos, secondcall, replace_old)
	local xppos = {x=pos.x+1, y=pos.y, z=pos.z}
	local zppos = {x=pos.x, y=pos.y, z=pos.z+1}
	local xmpos = {x=pos.x-1, y=pos.y, z=pos.z}
	local zmpos = {x=pos.x, y=pos.y, z=pos.z-1}

	local xpympos = {x=pos.x+1, y=pos.y-1, z=pos.z}
	local zpympos = {x=pos.x, y=pos.y-1, z=pos.z+1}
	local xmympos = {x=pos.x-1, y=pos.y-1, z=pos.z}
	local zmympos = {x=pos.x, y=pos.y-1, z=pos.z-1}

	local xpypos = {x=pos.x+1, y=pos.y+1, z=pos.z}
	local zpypos = {x=pos.x, y=pos.y+1, z=pos.z+1}
	local xmypos = {x=pos.x-1, y=pos.y+1, z=pos.z}
	local zmypos = {x=pos.x, y=pos.y+1, z=pos.z-1}

	if secondcall == nil then
		mesecon:update_autoconnect(xppos, true)
		mesecon:update_autoconnect(zppos, true)
		mesecon:update_autoconnect(xmpos, true)
		mesecon:update_autoconnect(zmpos, true)

		mesecon:update_autoconnect(xpypos, true)
		mesecon:update_autoconnect(zpypos, true)
		mesecon:update_autoconnect(xmypos, true)
		mesecon:update_autoconnect(zmypos, true)

		mesecon:update_autoconnect(xpympos, true)
		mesecon:update_autoconnect(zpympos, true)
		mesecon:update_autoconnect(xmympos, true)
		mesecon:update_autoconnect(zmympos, true)
	end

	nodename = minetest.get_node(pos).name
	if string.find(nodename, "mesecons:wire_") == nil and not replace_old then return nil end

	if mesecon:rules_link_anydir(pos, xppos) then xp = 1 else xp = 0 end
	if mesecon:rules_link_anydir(pos, xmpos) then xm = 1 else xm = 0 end
	if mesecon:rules_link_anydir(pos, zppos) then zp = 1 else zp = 0 end
	if mesecon:rules_link_anydir(pos, zmpos) then zm = 1 else zm = 0 end

	if mesecon:rules_link_anydir(pos, xpympos) then xp = 1 end
	if mesecon:rules_link_anydir(pos, xmympos) then xm = 1 end
	if mesecon:rules_link_anydir(pos, zpympos) then zp = 1 end
	if mesecon:rules_link_anydir(pos, zmympos) then zm = 1 end

	if mesecon:rules_link_anydir(pos, xpypos) then xpy = 1 else xpy = 0 end
	if mesecon:rules_link_anydir(pos, zpypos) then zpy = 1 else zpy = 0 end
	if mesecon:rules_link_anydir(pos, xmypos) then xmy = 1 else xmy = 0 end
	if mesecon:rules_link_anydir(pos, zmypos) then zmy = 1 else zmy = 0 end

	if xpy == 1 then xp = 1 end
	if zpy == 1 then zp = 1 end
	if xmy == 1 then xm = 1 end
	if zmy == 1 then zm = 1 end

	local nodeid = 	tostring(xp )..tostring(zp )..tostring(xm )..tostring(zm )..
			tostring(xpy)..tostring(zpy)..tostring(xmy)..tostring(zmy)

	
	if string.find(nodename, "_off") ~= nil then
		minetest.set_node(pos, {name = "mesecons:wire_"..nodeid.."_off"})
	else
		minetest.set_node(pos, {name = "mesecons:wire_"..nodeid.."_on" })
	end
end

if not minetest.registered_nodes["default:stone_with_mese"] then --before MESE update, use old recipes
	minetest.register_craft({
		output = "mesecons:wire_00000000_off 18",
		recipe = {
			{"default:mese"},
		}
	})
else

	minetest.register_craft({
		type = "cooking",
		output = "mesecons:wire_00000000_off 2",
		recipe = "default:mese_crystal_fragment",
		cooktime = 3,
	})

	minetest.register_craft({
		type = "cooking",
		output = "mesecons:wire_00000000_off 18",
		recipe = "default:mese_crystal",
		cooktime = 15,
	})

	minetest.register_craft({
		type = "cooking",
		output = "mesecons:wire_00000000_off 162",
		recipe = "default:mese",
		cooktime = 30,
	})

end

minetest.register_craft({
	type = "cooking",
	output = "mesecons:wire_00000000_off 16",
	recipe = "default:mese_crystal",
})
