-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into doc/lua_api.txt

-- Set mesh for all players
function switch_player_visual()
	prop = {
		mesh = "player.x",
		textures = {"player.png", },
		colors = {{255, 255, 255, 255}, },
		visual = "mesh",
		visual_size = {x=1, y=1},
	}
	
	for _, obj in pairs(minetest.get_connected_players()) do
		obj:set_properties(prop)
		obj:set_animation({x=1, y=50}, 35, 0)
		--obj:set_bone_position("", {x=0,y=0,z=0}, {x=0,y=0,z=0})
	end

	minetest.after(1.0, switch_player_visual)
end
minetest.after(1.0, switch_player_visual)

-- Test case for attachments: An object is spawned and attached to the player with the specified name (use your own playername there) 10 seconds after the server starts

test2 = {
  collisionbox = { 0, 0, 0, 0, 0, 0 },
  visual = "cube"
}

minetest.register_entity("default:test2", test2)

function detachments(newobject)
	newobject:set_detach()
	print ("Detached test object")
end

function attachments()
	prop = {
		mesh = "player.x",
		textures = {"player.png", },
		colors = {{255, 255, 255, 255}, },
		visual = "mesh",
		visual_size = {x=1, y=1},
	}

	local pos={x=0,y=0,z=0}
	local newobject=minetest.env:add_entity(pos, "test:test2")
	newobject:set_properties(prop)
	newobject:set_animation({x=1, y=50}, 35, 0)
	print ("Spawned test object")

	for _, obj in pairs(minetest.get_connected_players()) do
		if(obj:get_player_name() == "MirceaKitsune") then
			newobject:set_attach(obj, "Bone.001", {x=0,y=3,z=0}, {x=0,y=45,z=0})
			print ("Attached test object to "..obj:get_player_name())
		end
	end

	minetest.after(5.0, function() detachments(newobject) end)
end
minetest.after(15.0, attachments)]]

-- Test case for player to player attachments

function attachments_player()
	for _, obj in pairs(minetest.get_connected_players()) do
		if(obj:get_player_name() == "MirceaKitsune") then
			for _, obj2 in pairs(minetest.get_connected_players()) do
				if(obj2:get_player_name() == "MirceaKitsune1") then
					obj2:set_attach(obj, "Bone.001", {x=0,y=6,z=0}, {x=0,y=45,z=0})
					print ("Attached player "..obj2:get_player_name().." to player "..obj:get_player_name())
				end
			end
		end
	end
end

minetest.after(10.0, attachments_player)

-- Definitions made by this mod that other mods can use too
default = {}

-- Load other files
dofile(minetest.get_modpath("default").."/mapgen.lua")
dofile(minetest.get_modpath("default").."/leafdecay.lua")

-- END
