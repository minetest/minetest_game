-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into doc/lua_api.txt

-- Default animation speed. Special animations (such as the walk animation) should be offset from this factor
animation_speed = 30

-- Animation blending / transitioning amount
animation_blend = 0

-- Animations frame ranges:
animation_stand_START = 0
animation_stand_END = 79
animation_walk_forward_START = 81
animation_walk_forward_END = 100
animation_walk_backward_START = 102
animation_walk_backward_END = 121
animation_walk_right_START = 123
animation_walk_right_END = 142
animation_walk_left_START = 144
animation_walk_left_END = 163
animation_mine_START = 165
animation_mine_END = 179

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
		obj:set_animation({x=animation_stand_START, y=animation_walk_forward_END}, animation_speed, animation_blend)
	end

	minetest.after(10.0, switch_player_visual)
end
minetest.after(10.0, switch_player_visual)

-- Definitions made by this mod that other mods can use too
default = {}

-- Load other files
dofile(minetest.get_modpath("default").."/mapgen.lua")
dofile(minetest.get_modpath("default").."/leafdecay.lua")

-- END
