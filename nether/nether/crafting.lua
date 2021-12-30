minetest.register_craft({
	output = "nether:fim",
	recipe = {
		{"nether:shroom_head"},
		{"nether:fruit_no_leaf"},
		{"nether:shroom_head"},
	}
})

minetest.register_craft({
	output = "nether:fruit_leaves",
	recipe = {
		{"nether:fruit_leaf", "nether:fruit_leaf", "nether:fruit_leaf"},
		{"nether:fruit_leaf", "nether:fruit_leaf", "nether:fruit_leaf"},
		{"nether:fruit_leaf", "nether:fruit_leaf", "nether:fruit_leaf"},
	}
})

minetest.register_craft({
	output = "nether:pick_mushroom",
	recipe = {
		{"nether:shroom_head", "nether:shroom_head", "nether:shroom_head"},
		{"", "nether:shroom_stem", ""},
		{"", "nether:shroom_stem", ""},
	}
})

minetest.register_craft({
	output = "nether:pick_wood",
	recipe = {
		{"nether:wood_cooked", "nether:wood_cooked", "nether:wood_cooked"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

for _,m in pairs({"netherrack", "netherrack_blue", "white"}) do
	local input = "nether:"..m

	minetest.register_craft({
		output = "nether:pick_"..m,
		recipe = {
			{input, input, input},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		}
	})

	minetest.register_craft({
		output = "nether:axe_"..m,
		recipe = {
			{input, input},
			{input, "group:stick"},
			{"", "group:stick"},
		}
	})

	minetest.register_craft({
		output = "nether:sword_"..m,
		recipe = {
			{input},
			{input},
			{"group:stick"},
		}
	})

	minetest.register_craft({
		output = "nether:shovel_"..m,
		recipe = {
			{input},
			{"group:stick"},
			{"group:stick"},
		}
	})
end

minetest.register_craft({
	output = "nether:netherrack_brick 4",
	recipe = {
		{"nether:netherrack", "nether:netherrack"},
		{"nether:netherrack", "nether:netherrack"},
	}
})

minetest.register_craft({
	output = "nether:netherrack_brick_black 4",
	recipe = {
		{"nether:netherrack_black", "nether:netherrack_black"},
		{"nether:netherrack_black", "nether:netherrack_black"},
	}
})

minetest.register_craft({
	output = "nether:netherrack_brick_blue 4",
	recipe = {
		{"nether:netherrack_blue", "nether:netherrack_blue"},
		{"nether:netherrack_blue", "nether:netherrack_blue"},
	}
})

minetest.register_craft({
	output = "default:furnace",
	recipe = {
		{"nether:netherrack_brick", "nether:netherrack_brick", "nether:netherrack_brick"},
		{"nether:netherrack_brick", "", "nether:netherrack_brick"},
		{"nether:netherrack_brick", "nether:netherrack_brick", "nether:netherrack_brick"},
	}
})

minetest.register_craft({
	output = "nether:extractor",
	recipe = {
		{"nether:netherrack_brick", "nether:blood_top_cooked", "nether:netherrack_brick"},
		{"nether:blood_cooked", "nether:shroom_stem", "nether:blood_cooked"},
		{"nether:netherrack_brick", "nether:blood_stem_cooked", "nether:netherrack_brick"},
	}
})

minetest.register_craft({
	output = "nether:wood 4",
	recipe = {
		{"nether:blood_stem"},
	}
})

minetest.register_craft({
	output = "nether:wood_empty 4",
	recipe = {
		{"nether:blood_stem_empty"},
	}
})

minetest.register_craft({
	output = "nether:stick 4",
	recipe = {
		{"nether:wood_empty"},
	}
})

minetest.register_craft({
	output = "nether:torch",
	recipe = {
		{"nether:bark"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "nether:forest_wood",
	recipe = {
		{"nether:forest_planks", "nether:forest_planks", "nether:forest_planks"},
		{"nether:forest_planks", "", "nether:forest_planks"},
		{"nether:forest_planks", "nether:forest_planks", "nether:forest_planks"},
	}
})

minetest.register_craft({
	output = "nether:forest_planks 8",
	recipe = {
		{"nether:forest_wood"},
	}
})

minetest.register_craft({
	output = "nether:forest_planks 7",
	recipe = {
		{"nether:tree"},
	},
})

local sound_allowed = true
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "nether:forest_planks"
	or itemstack:get_count() ~= 7 then
		return
	end
	local tree
	for i = 1,9 do
		if old_craft_grid[i]:get_name() == "nether:tree" then
			tree = i
			break
		end
	end
	if not tree then	-- do nth if theres no tree
		return
	end
	local rdif = math.random(-1,1)	-- add a bit randomness
	local barkstack = ItemStack("nether:bark "..4-rdif)
	local inv = player:get_inventory()
	if not inv:room_for_item("main", barkstack) then	-- disallow crafting if there's not enough free space
		craft_inv:set_list("craft", old_craft_grid)
		itemstack:set_name("")
		return
	end
	itemstack:set_count(7+rdif)
	inv:add_item("main", barkstack)
	if not sound_allowed then	-- avoid playing the sound multiple times, e.g. when middle mouse click
		return
	end
	minetest.sound_play("default_wood_footstep", {pos=player:get_pos(),  gain=0.25})
	sound_allowed = false
	minetest.after(0, function()
		sound_allowed = true
	end)
end)

minetest.register_craft({
	output = "default:paper",
	recipe = {
		{"nether:grass_dried", "nether:grass_dried", "nether:grass_dried"},
	}
})


minetest.register_craft({
	type = "cooking",
	output = "default:coal_lump",
	recipe = "nether:tree",
})

minetest.register_craft({
	type = "cooking",
	output = "nether:grass_dried",
	recipe = "nether:grass",
})

minetest.register_craft({
	type = "cooking",
	output = "nether:pearl",
	recipe = "nether:fim",
})

minetest.register_craft({
	type = "cooking",
	output = "nether:hotbed",
	recipe = "nether:blood_extracted",
})

for  _,i in ipairs({"nether:blood", "nether:blood_top", "nether:blood_stem", "nether:wood"}) do
	local cooked = i.."_cooked"

	minetest.register_craft({
		type = "cooking",
		output = cooked,
		recipe = i,
	})

	minetest.register_craft({
		type = "fuel",
		recipe = cooked,
		burntime = 30,
	})
end
