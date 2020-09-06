-- player/init.lua

dofile(minetest.get_modpath("player_api") .. "/api.lua")

-- Default player appearance
player_api.register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		-- Standard animations.
		stand     = {x = 0,   y = 79},
		lay       = {x = 162, y = 166},
		walk      = {x = 168, y = 187},
		mine      = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit       = {x = 81,  y = 160},
	},
})

player_api.register_model("upright_sprite", {
	textures = {"player.png", "player_back.png"},
	visual = "upright_sprite",
	visual_size = {x = 1, y = 2},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.75, 0.3},
	eye_height = 1.625,
})

player_api.read_textures_and_meta()

player_api.register_skin("sprite", {
	description = "Demo sprite player",
	textures = { "player.png", "player_back.png" },
	model_name = "upright_sprite",
	preview = "player.png"
})

player_api.default_model = "character.b3d"
player_api.default_skin = "character"

-- Apply default model to all skins
player_api.register_skin_dyn_values("model_name", function(skin, othermod_value)
	return othermod_value or player_api.default_model
end )

-- Some compatibility bits
player_api.register_skin_dyn_values("texture", function(skin, othermod_value)
	return othermod_value or ( skin.textures and skin.textures[1] )
end )
