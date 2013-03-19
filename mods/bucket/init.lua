-- Minetest 0.4 mod: bucket
-- See README.txt for licensing and other information.

local liquid_max = 8  --The number of water levels when liquid_finite is enabled

minetest.register_alias("bucket", "bucket:bucket_empty")
minetest.register_alias("bucket_water", "bucket:bucket_water")
minetest.register_alias("bucket_lava", "bucket:bucket_lava")

minetest.register_craft({
	output = 'bucket:bucket_empty 1',
	recipe = {
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'', 'default:steel_ingot', ''},
	}
})

bucket = {}
bucket.liquids = {}

-- Register a new liquid
--   source = name of the source node
--   flowing = name of the flowing node
--   itemname = name of the new bucket item (or nil if liquid is not takeable)
--   inventory_image = texture of the new bucket item (ignored if itemname == nil)
-- This function can be called from any mod (that depends on bucket).
function bucket.register_liquid(source, flowing, itemname, inventory_image, name)
	bucket.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
	}
	bucket.liquids[flowing] = bucket.liquids[source]

	if itemname ~= nil then
		minetest.register_craftitem(itemname, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 1,
			liquids_pointable = true,
			on_use = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end

				local place_liquid = function(pos, node, source, flowing, fullness)
					if math.floor(fullness/128) == 1 or (not minetest.setting_getbool("liquid_finite")) then
						minetest.env:add_node(pos, {name=source, param2=fullness})
						return
					elseif node.name == flowing then
						fullness = fullness + node.param2
					elseif node.name == source then
						fullness = liquid_max
					end

					if fullness >= liquid_max then
						minetest.env:add_node(pos, {name=source, param2=liquid_max})
					else
						minetest.env:add_node(pos, {name=flowing, param2=fullness})
					end
				end

				-- Check if pointing to a buildable node
				local node = minetest.env:get_node(pointed_thing.under)
				local fullness = tonumber(itemstack:get_metadata())

				if minetest.registered_nodes[node.name].buildable_to then
					-- buildable; replace the node
					place_liquid(pointed_thing.under, node, source, flowing, fullness)
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced
					local node = minetest.env:get_node(pointed_thing.above)
					if minetest.registered_nodes[node.name].buildable_to then
						place_liquid(pointed_thing.above, node, source, flowing, fullness)
					else
						-- do not remove the bucket with the liquid
						return
					end
				end
				return {name="bucket:bucket_empty"}
			end
		})
	end
end

minetest.register_craftitem("bucket:bucket_empty", {
	description = "Empty Bucket",
	inventory_image = "bucket.png",
	stack_max = 1,
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return
		end
		-- Check if pointing to a liquid source
		node = minetest.env:get_node(pointed_thing.under)
		liquiddef = bucket.liquids[node.name]
		if liquiddef ~= nil and liquiddef.itemname ~= nil and (node.name == liquiddef.source or
			(node.name == liquiddef.flowing and minetest.setting_getbool("liquid_finite"))) then

			minetest.env:add_node(pointed_thing.under, {name="air"})

			if node.name == liquiddef.source then node.param2 = liquid_max end
			return ItemStack({name = liquiddef.itemname, metadata = tostring(node.param2)})
		end
	end,
})

bucket.register_liquid(
	"default:water_source",
	"default:water_flowing",
	"bucket:bucket_water",
	"bucket_water.png",
	"Water bucket"
)

bucket.register_liquid(
	"default:lava_source",
	"default:lava_flowing",
	"bucket:bucket_lava",
	"bucket_lava.png",
	"Lava bucket"
)

minetest.register_craft({
	type = "fuel",
	recipe = "bucket:bucket_lava",
	burntime = 60,
	replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},
})
