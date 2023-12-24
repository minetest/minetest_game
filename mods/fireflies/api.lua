-- fireflies/api.lua

fireflies = {}
-- If necessary, add other functions related to fireflies here

--------------------------------------------------------------
-- Global function to record the decoration of fireflies.
-- Perhaps other parameters can be added to improve decoration registration control.
function fireflies.register_decoration(biomes, place_on)
  local mg_name = minetest.get_mapgen_setting("mg_name")
  
  if mg_name == "v6" then
		minetest.register_decoration({
			name = "fireflies:firefly_low",
			deco_type = "simple",
			place_on = place_on,
			place_offset_y = 2,
			sidelen = 80,
			fill_ratio = 0.0002,
			y_max = 31000,
			y_min = 1,
			decoration = "fireflies:hidden_firefly",
		})

		minetest.register_decoration({
			name = "fireflies:firefly_high",
			deco_type = "simple",
			place_on = place_on,
			place_offset_y = 3,
			sidelen = 80,
			fill_ratio = 0.0002,
			y_max = 31000,
			y_min = 1,
			decoration = "fireflies:hidden_firefly",
		})
    
  else
		minetest.register_decoration({
			name = "fireflies:firefly_low",
			deco_type = "simple",
			place_on = place_on,
			place_offset_y = 2,
			sidelen = 80,
			fill_ratio = 0.0005,
			biomes = biomes,
			y_max = 31000,
			y_min = -1,
			decoration = "fireflies:hidden_firefly",
		})

		minetest.register_decoration({
			name = "fireflies:firefly_high",
			deco_type = "simple",
			place_on = place_on,
			place_offset_y = 3,
			sidelen = 80,
			fill_ratio = 0.0005,
			biomes = biomes,
			y_max = 31000,
			y_min = -1,
			decoration = "fireflies:hidden_firefly",
		})
  end
end
