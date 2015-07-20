-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.

stairs = {}

local recipeitem_things = {"tiles","use_texture_alpha","alpha","light_source","sounds","groups"}

-- Node will be called stairs:stair_<subname>
function stairs.register_stair(subname, recipeitem, groups_or_def, images, description, sounds)
	local recipe_def = table.copy(minetest.registered_nodes[recipeitem]) or {}
	local node_def = {
		description = recipe_def.description.." Stair",
		is_ground_content = false,
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:getpos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)
			end

			if p0.y-1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
	}

	for _,i in ipairs(recipeitem_things) do
		node_def[i] = recipe_def[i] or node_def[i]
	end

	if not images and groups_or_def then
		for n,i in pairs(groups_or_def) do
			node_def[n] = i
		end
	else
		node_def.groups = groups_or_def or node_def.groups
	end

	node_def.tiles = images or node_def.tiles
	node_def.sounds = sounds or node_def.sounds
	node_def.description = description or node_def.description

	minetest.register_node(":stairs:stair_" .. subname, node_def)

	-- for replace ABM
	minetest.register_node(":stairs:stair_" .. subname.."upside_down", {
		replace_name = "stairs:stair_" .. subname,
		groups = {slabs_replace=1},
	})

	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 6',
		recipe = {
			{recipeitem, "", ""},
			{recipeitem, recipeitem, ""},
			{recipeitem, recipeitem, recipeitem},
		},
	})

	-- Flipped recipe for the silly minecrafters
	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 6',
		recipe = {
			{"", "", recipeitem},
			{"", recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Node will be called stairs:slab_<subname>
function stairs.register_slab(subname, recipeitem, groups_or_def, images, description, sounds)
	local recipe_def = table.copy(minetest.registered_nodes[recipeitem]) or {}
	local node_def = {
		description = recipe_def.description.." Slab",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- If it's being placed on an another similar one, replace it with
			-- a full block
			local slabpos = nil
			local slabnode = nil
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local n0 = minetest.get_node(p0)
			local n1 = minetest.get_node(p1)
			local param2 = 0

			local n0_is_upside_down = (n0.name == "stairs:slab_" .. subname and
					n0.param2 >= 20)

			if n0.name == "stairs:slab_" .. subname and not n0_is_upside_down and p0.y+1 == p1.y then
				slabpos = p0
				slabnode = n0
			elseif n1.name == "stairs:slab_" .. subname then
				slabpos = p1
				slabnode = n1
			end
			if slabpos then
				-- Remove the slab at slabpos
				minetest.remove_node(slabpos)
				-- Make a fake stack of a single item and try to place it
				local fakestack = ItemStack(recipeitem)
				fakestack:set_count(itemstack:get_count())

				pointed_thing.above = slabpos
				local success
				fakestack, success = minetest.item_place(fakestack, placer, pointed_thing)
				-- If the item was taken from the fake stack, decrement original
				if success then
					itemstack:set_count(fakestack:get_count())
				-- Else put old node back
				else
					minetest.set_node(slabpos, slabnode)
				end
				return itemstack
			end
			
			-- Upside down slabs
			if p0.y-1 == p1.y then
				-- Turn into full block if pointing at a existing slab
				if n0_is_upside_down  then
					-- Remove the slab at the position of the slab
					minetest.remove_node(p0)
					-- Make a fake stack of a single item and try to place it
					local fakestack = ItemStack(recipeitem)
					fakestack:set_count(itemstack:get_count())

					pointed_thing.above = p0
					local success
					fakestack, success = minetest.item_place(fakestack, placer, pointed_thing)
					-- If the item was taken from the fake stack, decrement original
					if success then
						itemstack:set_count(fakestack:get_count())
					-- Else put old node back
					else
						minetest.set_node(p0, n0)
					end
					return itemstack
				end

				-- Place upside down slab
				param2 = 20
			end

			-- If pointing at the side of a upside down slab
			if n0_is_upside_down and p0.y+1 ~= p1.y then
				param2 = 20
			end

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end
	}

	for _,i in ipairs(recipeitem_things) do
		node_def[i] = recipe_def[i] or node_def[i]
	end

	if not images and groups_or_def then
		for n,i in pairs(groups_or_def) do
			node_def[n] = i
		end
	else
		node_def.groups = groups_or_def or node_def.groups
	end

	node_def.tiles = images or node_def.tiles
	node_def.sounds = sounds or node_def.sounds
	node_def.description = description or node_def.description

	minetest.register_node(":stairs:slab_" .. subname, node_def)

	-- for replace ABM
	minetest.register_node(":stairs:slab_" .. subname.."upside_down", {
		replace_name = "stairs:slab_"..subname,
		groups = {slabs_replace=1},
	})

	minetest.register_craft({
		output = 'stairs:slab_' .. subname .. ' 6',
		recipe = {
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Replace old "upside_down" nodes with new param2 versions
minetest.register_abm({
	nodenames = {"group:slabs_replace"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		node.name = minetest.registered_nodes[node.name].replace_name
		node.param2 = node.param2 + 20
		if node.param2 == 21 then
			node.param2 = 23
		elseif node.param2 == 23 then
			node.param2 = 21
		end
		minetest.set_node(pos, node)
	end,
})

-- Nodes will be called stairs:{stair,slab}_<subname>
function stairs.register_stair_and_slab(subname, recipeitem, groups_or_def, images, desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups_or_def, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups_or_def, images, desc_slab, sounds)
end

stairs.register_stair_and_slab("wood", "default:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_wood.png"},
		"Wooden Stair",
		"Wooden Slab")

stairs.register_stair_and_slab("junglewood", "default:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_junglewood.png"},
		"Junglewood Stair",
		"Junglewood Slab")

stairs.register_stair_and_slab("pinewood", "default:pinewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_pinewood.png"},
		"Pinewood Stair",
		"Pinewood Slab")

stairs.register_stair_and_slab("brick", "default:brick",
		{cracky=3},
		{"default_brick.png"},
		"Brick Stair",
		"Brick Slab")

stairs.register_stair_and_slab("stone", "default:stone")

stairs.register_stair_and_slab("cobble", "default:cobble")

stairs.register_stair_and_slab("desert_stone", "default:desert_stone")

stairs.register_stair_and_slab("desert_cobble", "default:desert_cobble")

stairs.register_stair_and_slab("desert_stonebrick", "default:desert_stonebrick")

stairs.register_stair_and_slab("sandstone", "default:sandstone")

stairs.register_stair_and_slab("stonebrick", "default:stonebrick")
		
stairs.register_stair_and_slab("sandstonebrick", "default:sandstonebrick")

stairs.register_stair_and_slab("obsidian", "default:obsidian")

stairs.register_stair_and_slab("obsidianbrick", "default:obsidianbrick")
