-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into doc/lua_api.txt

-- Default animation speed. Special animations (such as the walk animation) should be offset from this factor
animation_speed = 30

-- Animation blending / transitioning amount
animation_blend = 0

-- Animations frame ranges:
-- For player.x:
animation_player_stand_START = 0
animation_player_stand_END = 79
animation_player_walk_forward_START = 81
animation_player_walk_forward_END = 100
animation_player_walk_backward_START = 102
animation_player_walk_backward_END = 121
animation_player_walk_right_START = 123
animation_player_walk_right_END = 142
animation_player_walk_left_START = 144
animation_player_walk_left_END = 163
animation_player_mine_START = 165
animation_player_mine_END = 179
animation_player_death_START = 181
animation_player_death_END = 200

-- Set mesh for all players
function switch_player_visual()
	prop = {
		mesh = "character.x",
		textures = {"character.png", },
		visual = "mesh",
		visual_size = {x=1, y=1},
	}

	for _, obj in pairs(minetest.get_connected_players()) do
		obj:set_properties(prop)
		obj:set_animation({x=animation_player_death_START, y=animation_player_death_END}, animation_speed, animation_blend)
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
