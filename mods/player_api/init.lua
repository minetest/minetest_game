-- player/init.lua

dofile(minetest.get_modpath("player_api") .. "/api.lua")

-- Default player appearance
player_api.register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		-- Standard animations.
		stand     = {x = 0,   y = 159},
		lay       = {x = 161, y = 320},
		walk      = {x = 322, y = 326},
		mine      = {x = 328, y = 347},
		walk_mine = {x = 349, y = 358},
		sit       = {x = 360, y = 379},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.47,
})

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	player_api.player_attached[player:get_player_name()] = false
	player_api.set_model(player, "character.b3d")
	player:set_local_animation(
		{x = 0,   y = 159},
		{x = 328, y = 347},
		{x = 349, y = 358},
		{x = 360, y = 379},
		30
	)
end)
