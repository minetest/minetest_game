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
local player_sneak = {}
local ANIM_STAND = 0
local ANIM_WALK  = 1
local ANIM_WALK_MINE = 2
local ANIM_MINE = 3
local ANIM_DEATH = 4

-- Frame ranges for each player model
function player_get_animations(model)
	if model == "character.x" then
		return {
		stand_START = 0,
		stand_END = 79,
		walk_START = 81,
		walk_END = 100,
		mine_START = 102,
		mine_END = 111,
		walk_mine_START = 113,
		walk_mine_END = 132,
		death_START = 134,
		death_END = 153
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

		local walking = false
		if controls.up or controls.down or controls.left or controls.right then
			walking = true
		end

		local animation_speed_modified = animation_speed
		if controls.sneak and pl:get_hp() ~= 0 and (walking or controls.LMB) then
			animation_speed_modified = animation_speed_modified / 2
			-- Refresh player animation below
			if not player_sneak[name] then
				player_anim[name] = -1
				player_sneak[name] = true
			end
		else
			-- Refresh player animation below
			if player_sneak[name] then
				player_anim[name] = -1
				player_sneak[name] = false
			end
		end

		if pl:get_hp() == 0 then
			if player_anim[name] ~= ANIM_DEATH then
				-- TODO: The death animation currently loops, we must make it play only once then stay at the last frame somehow
				pl:set_animation({x=anim.death_START, y=anim.death_END}, animation_speed_modified, animation_blend)
				player_anim[name] = ANIM_DEATH
			end
		elseif walking and controls.LMB then
			if player_anim[name] ~= ANIM_WALK_MINE then
				pl:set_animation({x=anim.walk_mine_START, y=anim.walk_mine_END}, animation_speed_modified, animation_blend)
				player_anim[name] = ANIM_WALK_MINE
			end
		elseif walking then
			if player_anim[name] ~= ANIM_WALK then
				pl:set_animation({x=anim.walk_START, y=anim.walk_END}, animation_speed_modified, animation_blend)
				player_anim[name] = ANIM_WALK
			end
		elseif controls.LMB then
			if player_anim[name] ~= ANIM_MINE then
				pl:set_animation({x=anim.mine_START, y=anim.mine_END}, animation_speed_modified, animation_blend)
				player_anim[name] = ANIM_MINE
			end
		elseif player_anim[name] ~= ANIM_STAND then
			pl:set_animation({x=anim.stand_START, y=anim.stand_END}, animation_speed_modified, animation_blend)
			player_anim[name] = ANIM_STAND
		end
	end
end
minetest.register_globalstep(on_step)

-- END
