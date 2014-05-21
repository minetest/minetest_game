-- Nodes

-- Natural Blocks
minetest.register_node("moontest:stone", {
	description = "Moon Stone",
	tiles = {"moontest_stone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:dust", {
	description = "Moon Dust",
	tiles = {"moontest_dust.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.1},
	}),
})

minetest.register_node("moontest:basalt", {
	description = "Basalt",
	tiles = {"moontest_basalt.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

-- Footsteps
minetest.register_node("moontest:dustprint1", {
	description = "Moon Dust Footprint1",
	tiles = {"moontest_dustprint1.png", "moontest_dust.png"},
	groups = {crumbly=3, falling_node=1},
	drop = "moontest:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.1},
	}),
})

minetest.register_node("moontest:dustprint2", {
	description = "Moon Dust Footprint2",
	tiles = {"moontest_dustprint2.png", "moontest_dust.png"},
	groups = {crumbly=3, falling_node=1},
	drop = "moontest:dust",
	sounds = default.node_sound_sand_defaults({
		footstep = {name="default_sand_footstep", gain=0.1},
	}),
})

minetest.register_node("moontest:vacuum", {
	description = "Vacuum",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drowning = 1,
})

minetest.register_node("moontest:air", {
	description = "Life Support Air",
	drawtype = "glasslike",
	tiles = {"moontest_air.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
})

minetest.register_node("moontest:airgen", {
	description = "Air Generator",
	tiles = {"moontest_airgen.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		--fire up the voxel manipulator
		local vm = minetest.get_voxel_manip()
		local p1 = {x=x-16,y=y-16,z=z-16}
		local p2 = {x=x+16,y=y+16,z=z+16}
		pmin, pmax = vm:read_from_map(p1,p2)
		local area = VoxelArea:new{MinEdge=pmin, MaxEdge=pmax}
		local data = vm:get_data()
		
		local c_vac = minetest.get_content_id("moontest:vacuum")
		local c_gair = minetest.get_content_id("moontest:air")
		
		for i = -16,16 do
		for j = -16,16 do
		for k = -16,16 do
			if not (i == 0 and j == 0 and k == 0) then
				if i*i+j*j+k*k <= 16 * 16 + 16 then
					--grab the location of the node in question
					local vi = area:index(x+i, y+j, z+k)
					--if it's vacuum, it won't be now!
					if data[vi] == c_vac then
						data[vi] = c_gair
					end
				end
			end
		end
		end
		end
		
		--write the voxel manipulator data back to world
		vm:set_data(data)
		vm:write_to_map(data)
		vm:update_map()
	end
})

minetest.register_node("moontest:waterice", {
	description = "Water Ice",
	tiles = {"moontest_waterice.png"},
	light_source = 1,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,melts=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moontest:hlflowing", {
	description = "Flowing Hydroponic Liquid",
	inventory_image = minetest.inventorycube("moontest_hl.png"),
	drawtype = "flowingliquid",
	tiles = {"moontest_hl.png"},
	special_tiles = {
		{
			image="moontest_hlflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="moontest_hlflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = 224,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "moontest:hlflowing",
	liquid_alternative_source = "moontest:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("moontest:hlsource", {
	description = "Hydroponic Liquid Source",
	inventory_image = minetest.inventorycube("moontest_hl.png"),
	drawtype = "liquid",
	tiles = {
		{name="moontest_hlflowing_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}}
	},
	special_tiles = {
		{
			image="moontest_hlflowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
		{
			image="moontest_hlflowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2}
		},
	},
	alpha = 224,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "moontest:hlflowing",
	liquid_alternative_source = "moontest:hlsource",
	liquid_viscosity = 1,
	post_effect_color = {a=224, r=115, g=55, b=24},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

minetest.register_node("moontest:soil", {
	description = "Moonsoil",
	tiles = {"moontest_soil.png"},
	groups = {crumbly=3, falling_node=1, soil=3},
	drop = "moontest:dust",
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("moontest:airlock", {
	description = "Airlock",
	tiles = {"moontest_airlock.png"},
	light_source = 14,
	walkable = false,
	post_effect_color = {a=255, r=0, g=0, b=0},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:glass", {
	description = "MR Glass",
	drawtype = "glasslike",
	tiles = {"default_obsidian_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("moontest:sapling", {
	description = "Moon Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	groups = {snappy=2,dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("moontest:tree", {
	description = "Moon Tree",
	tiles = {"moontest_tree_top.png", "moontest_tree_top.png", "moontest_tree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("moontest:leaves", {
	description = "Moon Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"moontest_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"moontest:sapling"},rarity = 20,},
			{items = {"moontest:leaves"},}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("moontest:stonebrick", {
	description = "Moon Stone Brick",
	tiles = {"moontest_stonebricktop.png", "moontest_stonebrickbot.png", "moontest_stonebrick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:stoneslab", {
	description = "Moon Stone Slab",
	tiles = {"moontest_stonebricktop.png", "moontest_stonebrickbot.png", "moontest_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
		},
	},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:stonestair", {
	description = "Moon Stone Stair",
	tiles = {"moontest_stonebricktop.png", "moontest_stonebrickbot.png", "moontest_stonebrick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5},
		},
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:lightore", {
	description = "Light ore",
	tiles = {"moontest_stone.png^moontest_light_ore.png"},
	light_source = 7,
	groups = {cracky = 3, stone = 1},
	drop = "moontest:light_crystal",
})

minetest.register_node("moontest:phosphorusore", {
	description = "Phosphorus Ore",
	tiles = {"moontest_stone.png^moontest_mineral_phosphorus.png"},
	groups = {cracky = 3, stone = 1},
	drop = "moontest:phosphorus_lump",
})

minetest.register_node("moontest:siliconore", {
	description = "Silicon ore",
	tiles = {"moontest_stone.png^moontest_mineral_silicon.png"},
	groups = {cracky = 3, stone = 1},
	drop = "mesecons_materials:silicon",
})

minetest.register_node("moontest:titaniumore", {
	description = "Titanium ore",
	tiles = {"moontest_stone.png^moontest_mineral_titanium.png"},
	groups = {cracky = 2, stone = 1},
	drop = "moontest:titanium_lump",
})

minetest.register_node(":default:stone_with_iron", {
	description = "Iron Ore",
	tiles = {"moontest_stone.png^default_mineral_iron.png"},
	is_ground_content = true,
	groups = {cracky=2, stone = 1},
	drop = 'default:iron_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(":default:stone_with_mese", {
	description = "Mese Ore",
	tiles = {"moontest_stone.png^default_mineral_mese.png"},
	is_ground_content = true,
	groups = {cracky=1, stone = 1},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:lunariumore", {
	description = "Lunarium Ore",
	tiles = {"moontest_stone.png^moontest_mineral_lunarium.png"},
	is_ground_content = true,
	groups = {cracky=1, stone = 1},
	drop = "moontest:lunarium_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("moontest:light", {
	description = "Light",
	tiles = {"moontest_light.png"},
	light_source = 14,
	groups = {cracky = 3},
	drop = "moontest:light_crystal",
})

minetest.register_node("moontest:light_stick", {
	description = "Torch",
	drawtype = "torchlike",
	tiles = {"moontest_light_stick_on_floor.png", "moontest_light_stick_on_ceiling.png", "moontest_light_stick.png"},
	--tiles = {
		--{name="default_torch_on_floor_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		--{name="default_torch_on_ceiling_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		--{name="default_torch_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	--},
	inventory_image = "moontest_light_stick_on_floor.png",
	wield_image = "moontest_light_stick_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = LIGHT_MAX-2,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})

--define unlit torch
minetest.register_node("moontest:unlit_torch", {
	description = "Unlit Torch",
	drawtype = "torchlike",
	tiles = {"moontest_unlit_torch_on_floor.png", "moontest_unlit_torch_on_ceiling.png", "moontest_unlit_torch.png"},
	inventory_image = "default_torch_on_floor.png",
	wield_image = "moontest_unlit_torch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = 0,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,flammable=1,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		--check if the player is holding a stick to relight it
		if player:get_wielded_item():get_name() == "default:stick" then
			--store whether the area is in a vacuum
			local is_vacuum = false
			--check in a three-node cube around the torch for vacuum
			for x=-1,1 do
				for y=-1,1 do
					for z=-1,1 do
						local vpos = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
						--this is a vacuum!
						if minetest.get_node(vpos).name == "moontest:vacuum" then
							is_vacuum = true
							break
						end
					end
				end
			end
			--if those loops didn't find vacuum, assume air
			if is_vacuum ~= true then
				local par2 = node.param2 --store the rotation of the old torch
				minetest.set_node(pos, {name="default:torch", param2=par2})
			else	
				print("this is a vacuum!") --you idiot!
			end
		end
	end,
})

--ABM to extinguish torches in vacuum
minetest.register_abm({
	nodenames = {"default:torch"},
	neighbors = {"moontest:vacuum"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local p2 = node.param2 --store rotation of old torch
		minetest.set_node(pos, {name = "moontest:unlit_torch", param2=p2})
	end,
})

-- Items

minetest.register_craftitem("moontest:spacesuit", {
	description = "Spacesuit",
	inventory_image = "moontest_spacesuit.png",
})

minetest.register_craftitem("moontest:light_crystal", {
	description = "Light Cyrstal",
	inventory_image = "moontest_light_crystal.png",
})

minetest.register_craftitem("moontest:phosphorus_lump", {
	description = "Phosphorus Lump",
	inventory_image = "moontest_phosphorus_lump.png",
})

minetest.register_craftitem("moontest:titanium_lump", {
	description = "Titanium Lump",
	inventory_image = "moontest_titanium_lump.png",
})

minetest.register_craftitem("moontest:titanium_ingot", {
	description = "Titanium Ingot",
	inventory_image = "moontest_titanium_ingot.png",
})

minetest.register_craftitem("moontest:lunarium_lump", {
	description = "Lunarium Lump",
	inventory_image = "moontest_lunarium_lump.png",
})

minetest.register_craftitem("moontest:lunarium_ingot", {
	description = "Lunarium Ingot",
	inventory_image = "moontest_lunarium_ingot.png",
})

minetest.register_craftitem("moontest:helmet", {
	description = "Helmet",
	inventory_image = "moontest_helmet.png",
})

minetest.register_craftitem("moontest:lifesupport", {
	description = "Life Support",
	inventory_image = "moontest_lifesupport.png",
})
