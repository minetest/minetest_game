local function register_flower(name)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.006,
			spread = {x=100, y=100, z=100},
			seed = 436,
			octaves = 3,
			persist = 0.6
		},
		y_min = 1,
		y_max = 30,
		decoration = "flowers:"..name,
	})
end

local function register_mushroom(name)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"default:dirt_with_grass", "default:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.006,
			spread = {x=100, y=100, z=100},
			seed = 7133,
			octaves = 3,
			persist = 0.6
		},
		y_min = -31000,
		y_max = 30,
		decoration = "flowers:"..name,
	})
end

function flowers.register_mgv6_decorations()
	register_flower("rose")
	register_flower("tulip")
	register_flower("dandelion_yellow")
	register_flower("geranium")
	register_flower("viola")
	register_flower("dandelion_white")

	register_mushroom("mushroom_brown")
	register_mushroom("mushroom_red")
end

-- Enable in mapgen v6 only

if minetest.get_mapgen_params().mgname == "v6" then
	flowers.register_mgv6_decorations()
end

