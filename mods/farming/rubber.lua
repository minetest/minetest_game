minetest.register_node("farming:rubber_sapling", {
	description = "Rubber Tree Sapling",
	drawtype = "plantlike",
	tiles = {"farming_rubber_sapling.png"},
	inventory_image = "farming_rubber_sapling.png",
	wield_image = "farming_rubber_sapling.png",
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,flammable=2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("farming:rubber_tree_full", {
	description = "Rubber Tree",
	tiles = {"default_tree_top.png", "default_tree_top.png", "farming_rubber_tree_full.png"},
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	drop = "default:tree",
	sounds = default.node_sound_wood_defaults(),
	
	on_dig = function(pos, node, digger)
		minetest.node_dig(pos, node, digger)
		minetest.env:remove_node(pos)
	end,
	
	after_destruct = function(pos, oldnode)
		oldnode.name = "farming:rubber_tree_empty"
		minetest.env:set_node(pos, oldnode)
	end
})


minetest.register_node("farming:rubber_tree_empty", {
	tiles = {"default_tree_top.png", "default_tree_top.png", "farming_rubber_tree_empty.png"},
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2, not_in_creative_inventory=1},
	drop = "default:tree",
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_abm({
	nodenames = {"farming:rubber_tree_empty"},
	interval = 60,
	chance = 15,
	action = function(pos, node)
		node.name = "farming:rubber_tree_full"
		minetest.env:set_node(pos, node)
	end
})

minetest.register_node("farming:rubber_leaves", {
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, not_in_creative_inventory=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'farming:rubber_sapling'},
				rarity = 20,
			},
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_abm({
	nodenames = {"farming:rubber_sapling"},
	interval = 60,
	chance = 20,
	action = function(pos, node)
		farming:generate_tree(pos, "farming:rubber_tree_full", "farming:rubber_leaves", {"default:dirt", "default:dirt_with_grass"})
	end
})

minetest.register_on_generated(function(minp, maxp, blockseed)
	if math.random(1, 100) > 5 then
		return
	end
	local tmp = {x=(maxp.x-minp.x)/2+minp.x, y=(maxp.y-minp.y)/2+minp.y, z=(maxp.z-minp.z)/2+minp.z}
	local pos = minetest.env:find_node_near(tmp, maxp.x-minp.x, {"default:dirt_with_grass"})
	if pos ~= nil then
		farming:generate_tree({x=pos.x, y=pos.y+1, z=pos.z}, "farming:rubber_tree_full", "farming:rubber_leaves", {"default:dirt", "default:dirt_with_grass"})
	end
end)

minetest.register_craftitem("farming:bucket_rubber", {
	description = "Bucket with Caoutchouc",
	inventory_image = "farming_bucket_rubber.png",
	stack_max = 1,
})

local bucket_tmp = {
	source = "farming:rubber_tree_full",
	itemname = "farming:bucket_rubber"
}
bucket.liquids["farming:rubber_tree_full"] = bucket_tmp

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming:rubber_sapling",
	burntime = 10
})
