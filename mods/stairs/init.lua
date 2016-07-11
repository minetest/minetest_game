-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.


-- Global namespace for functions

stairs = {}


-- Register aliases for new pine node names

minetest.register_alias("stairs:stair_pinewood", "stairs:stair_pine_wood")
minetest.register_alias("stairs:slab_pinewood", "stairs:slab_pine_wood")


-- Get setting for replace ABM

local replace = minetest.setting_getbool("enable_stairs_replace_abm")


-- Register stairs.
-- Node will be called stairs:stair_<subname>

function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	groups.stair = 1
	minetest.register_node(":stairs:stair_" .. subname, {
		description = description,
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
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

			if p0.y - 1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
	})

	-- for replace ABM
	if replace then
		minetest.register_node(":stairs:stair_" .. subname .. "upside_down", {
			replace_name = "stairs:stair_" .. subname,
			groups = {slabs_replace = 1},
		})
	end

	if recipeitem then
		minetest.register_craft({
			output = 'stairs:stair_' .. subname .. ' 8',
			recipe = {
				{recipeitem, "", ""},
				{recipeitem, recipeitem, ""},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Flipped recipe for the silly minecrafters
		minetest.register_craft({
			output = 'stairs:stair_' .. subname .. ' 8',
			recipe = {
				{"", "", recipeitem},
				{"", recipeitem, recipeitem},
				{recipeitem, recipeitem, recipeitem},
			},
		})
	end
end


-- Register slabs.
-- Node will be called stairs:slab_<subname>

local function get_node_face(pointed_thing)
	local ay = pointed_thing.above.y
	local uy = pointed_thing.under.y

	if     ay > uy then return 1	 -- Top face pointed.
	elseif ay < uy then return 2 end -- Bottom face pointed.
end

function stairs.register_slab(subname, recipeitem, groups, images, description, sounds)
	groups.slab = 1
	minetest.register_node(":stairs:slab_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local wield_item = clicker:get_wielded_item():get_name()
			local player_name = clicker:get_player_name()
			local face = get_node_face(pointed_thing)

			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
				return
			end

			if wield_item == "stairs:slab_" .. subname and node.param2 <= 3 and face then
				if face == 1 then
					minetest.set_node(pos, {name = recipeitem, param2 = node.param2})
				else
					minetest.set_node(pointed_thing.above, {name = wield_item, param2 = 20})
				end
			else
				minetest.item_place_node(ItemStack(wield_item), clicker, pointed_thing)
			end

			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end

			return itemstack
		end,
	})

	-- for replace ABM
	if replace then
		minetest.register_node(":stairs:slab_" .. subname .. "upside_down", {
			replace_name = "stairs:slab_".. subname,
			groups = {slabs_replace = 1},
		})
	end

	if recipeitem then
		minetest.register_craft({
			output = 'stairs:slab_' .. subname .. ' 6',
			recipe = {
				{recipeitem, recipeitem, recipeitem},
			},
		})
	end
end


-- Optionally replace old "upside_down" nodes with new param2 versions.
-- Disabled by default.

if replace then
	minetest.register_abm({
		nodenames = {"group:slabs_replace"},
		interval = 16,
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
end


-- Stair/slab registration function.
-- Nodes will be called stairs:{stair,slab}_<subname>

function stairs.register_stair_and_slab(subname, recipeitem,
		groups, images, desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds)
end


-- Register default stairs and slabs

stairs.register_stair_and_slab(
	"wood",
	"default:wood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_wood.png"},
	"Wooden Stair",
	"Wooden Slab",
	default.node_sound_wood_defaults()
)

stairs.register_stair_and_slab(
	"junglewood",
	"default:junglewood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_junglewood.png"},
	"Jungle Wood Stair",
	"Jungle Wood Slab",
	default.node_sound_wood_defaults()
)

stairs.register_stair_and_slab(
	"pine_wood",
	"default:pine_wood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_pine_wood.png"},
	"Pine Wood Stair",
	"Pine Wood Slab",
	default.node_sound_wood_defaults()
)

stairs.register_stair_and_slab(
	"acacia_wood",
	"default:acacia_wood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_acacia_wood.png"},
	"Acacia Wood Stair",
	"Acacia Wood Slab",
	default.node_sound_wood_defaults()
)

stairs.register_stair_and_slab(
	"aspen_wood",
	"default:aspen_wood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_aspen_wood.png"},
	"Aspen Wood Stair",
	"Aspen Wood Slab",
	default.node_sound_wood_defaults()
)

stairs.register_stair_and_slab(
	"stone",
	"default:stone",
	{cracky = 3},
	{"default_stone.png"},
	"Stone Stair",
	"Stone Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"cobble",
	"default:cobble",
	{cracky = 3},
	{"default_cobble.png"},
	"Cobblestone Stair",
	"Cobblestone Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"mossycobble",
	nil,
	{cracky = 3},
	{"default_mossycobble.png"},
	"Mossy Cobblestone Stair",
	"Mossy Cobblestone Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"stonebrick",
	"default:stonebrick",
	{cracky = 2},
	{"default_stone_brick.png"},
	"Stone Brick Stair",
	"Stone Brick Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"stone_block",
	"default:stone_block",
	{cracky = 2},
	{"default_stone_block.png"},
	"Stone Block Stair",
	"Stone Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"desert_stone",
	"default:desert_stone",
	{cracky = 3},
	{"default_desert_stone.png"},
	"Desert Stone Stair",
	"Desert Stone Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"desert_cobble",
	"default:desert_cobble",
	{cracky = 3},
	{"default_desert_cobble.png"},
	"Desert Cobblestone Stair",
	"Desert Cobblestone Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"desert_stonebrick",
	"default:desert_stonebrick",
	{cracky = 2},
	{"default_desert_stone_brick.png"},
	"Desert Stone Brick Stair",
	"Desert Stone Brick Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"desert_stone_block",
	"default:desert_stone_block",
	{cracky = 2},
	{"default_desert_stone_block.png"},
	"Desert Stone Block Stair",
	"Desert Stone Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"sandstone",
	"default:sandstone",
	{crumbly = 1, cracky = 3},
	{"default_sandstone.png"},
	"Sandstone Stair",
	"Sandstone Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"sandstonebrick",
	"default:sandstonebrick",
	{cracky = 2},
	{"default_sandstone_brick.png"},
	"Sandstone Brick Stair",
	"Sandstone Brick Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"sandstone_block",
	"default:sandstone_block",
	{cracky = 2},
	{"default_sandstone_block.png"},
	"Sandstone Block Stair",
	"Sandstone Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"obsidian",
	"default:obsidian",
	{cracky = 1, level = 2},
	{"default_obsidian.png"},
	"Obsidian Stair",
	"Obsidian Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"obsidianbrick",
	"default:obsidianbrick",
	{cracky = 1, level = 2},
	{"default_obsidian_brick.png"},
	"Obsidian Brick Stair",
	"Obsidian Brick Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"obsidian_block",
	"default:obsidian_block",
	{cracky = 1, level = 2},
	{"default_obsidian_block.png"},
	"Obsidian Block Stair",
	"Obsidian Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"brick",
	"default:brick",
	{cracky = 3},
	{"default_brick.png"},
	"Brick Stair",
	"Brick Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"straw",
	"farming:straw",
	{snappy = 3, flammable = 4},
	{"farming_straw.png"},
	"Straw Stair",
	"Straw Slab",
	default.node_sound_leaves_defaults()
)

stairs.register_stair_and_slab(
	"steelblock",
	"default:steelblock",
	{cracky = 1, level = 2},
	{"default_steel_block.png"},
	"Steel Block Stair",
	"Steel Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"copperblock",
	"default:copperblock",
	{cracky = 1, level = 2},
	{"default_copper_block.png"},
	"Copper Block Stair",
	"Copper Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"bronzeblock",
	"default:bronzeblock",
	{cracky = 1, level = 2},
	{"default_bronze_block.png"},
	"Bronze Block Stair",
	"Bronze Block Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab(
	"goldblock",
	"default:goldblock",
	{cracky = 1},
	{"default_gold_block.png"},
	"Gold Block Stair",
	"Gold Block Slab",
	default.node_sound_stone_defaults()
)
