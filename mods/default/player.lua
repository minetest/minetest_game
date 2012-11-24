-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

-- Animation speed
animation_speed = 30
-- Animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
animation_blend = 0

-- Default player appearance
default_model = "character.x"
default_texture = "character.png"

-- Player states
local player_model = {}
local player_anim = {}
local ANIM_STAND = 0
local ANIM_WALK_FORWARD = 1
local ANIM_WALK_BACKWARD = 2
local ANIM_WALK_LEFT = 3
local ANIM_WALK_RIGHT = 4
local ANIM_MINE = 5
local ANIM_DEATH = 6

-- Frame ranges for each player model
function player_get_animations(model)
	if model == "character.x" then
		return {
		stand_START = 0,
		stand_END = 79,
		walk_forward_START = 81,
		walk_forward_END = 100,
		walk_backward_START = 102,
		walk_backward_END = 121,
		walk_right_START = 123,
		walk_right_END = 142,
		walk_left_START = 144,
		walk_left_END = 163,
		mine_START = 165,
		mine_END = 179,
		death_START = 181,
		death_END = 200
		}
	end
end

-- Called whenever a player's appearance needs to be updated
function player_update_visuals(player)
	player_model[player:get_player_name()] = default_model
	player_anim[player:get_player_name()] = ANIM_STAND

	local name = player:get_player_name()
	local anim = player_get_animations(player_model[name])
	prop = {
		mesh = default_model,
		textures = {default_texture, },
		visual = "mesh",
		visual_size = {x=1, y=1},
	}
	player:set_properties(prop)
	player:set_animation({x=anim.stand_START, y=anim.stand_END}, animation_speed, animation_blend) -- initial animation
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(player_update_visuals)

-- Global environment step function
function on_step(dtime)
	for _, pl in pairs(minetest.get_connected_players()) do
		local name = pl:get_player_name()
		local anim = player_get_animations(player_model[name])
		local controls = pl:get_player_control()

		if controls.up then
			if player_anim[name] ~= ANIM_WALK_FORWARD then
				pl:set_animation({x=anim.walk_forward_START, y=anim.walk_forward_END}, animation_speed, animation_blend)
				player_anim[name] = ANIM_WALK_FORWARD
			end
		elseif controls.down then
			if player_anim[name] ~= ANIM_WALK_BACKWARD then
				pl:set_animation({x=anim.walk_backward_START, y=anim.walk_backward_END}, animation_speed, animation_blend)
				player_anim[name] = ANIM_WALK_BACKWARD
			end
		elseif controls.left then
			if player_anim[name] ~= ANIM_WALK_LEFT then
				pl:set_animation({x=anim.walk_left_START, y=anim.walk_left_END}, animation_speed, animation_blend)
				player_anim[name] = ANIM_WALK_LEFT
			end
		elseif controls.right then
			if player_anim[name] ~= ANIM_WALK_RIGHT then
				pl:set_animation({x=anim.walk_right_START, y=anim.walk_right_END}, animation_speed, animation_blend)
				player_anim[name] = ANIM_WALK_RIGHT
			end
		elseif controls.LMB then
			if player_anim[name] ~= ANIM_MINE then
				pl:set_animation({x=anim.mine_START, y=anim.mine_END}, animation_speed, animation_blend)
				player_anim[name] = ANIM_MINE
			end
		elseif player_anim[name] ~= ANIM_WALK_STAND then
			pl:set_animation({x=anim.stand_START, y=anim.stand_END}, animation_speed, animation_blend)
			player_anim[name] = ANIM_WALK_STAND
		end
	end
end
minetest.register_globalstep(on_step)

-- END
