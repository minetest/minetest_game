-- minetest/default/leafdecay.lua

-- To enable leaf decay for a node, add it to the "leafdecay" group.
--
-- The rating of the group determines how far from a node in the group "tree"
-- the node can be without decaying.
--
-- If param2 of the node is ~= 0, the node will always be preserved. Thus, if
-- the player places a node of that kind, you will want to set param2=1 or so.

default.leafdecay_trunk_cache = {}
default.leafdecay_enable_cache = true

minetest.register_abm({
	nodenames = {"group:leafdecay"},
	neighbors = {"air", "group:liquid"},
	-- A low interval and a high inverse chance spreads the load
	interval = 2,
	chance = 5,

	action = function(p0, node, _, _)
		--print("leafdecay ABM at "..p0.x..", "..p0.y..", "..p0.z..")")
		local do_preserve = false
		local d = minetest.registered_nodes[node.name].groups.leafdecay
		if not d or d == 0 then
			--print("not groups.leafdecay")
			return
		end
		local n0 = minetest.env:get_node(p0)
		if n0.param2 ~= 0 then
			--print("param2 ~= 0")
			return
		end
		local p0_hash = nil
		if default.leafdecay_enable_cache then
			p0_hash = minetest.hash_node_position(p0)
			local trunkp = default.leafdecay_trunk_cache[p0_hash]
			if trunkp then
				local n = minetest.env:get_node(trunkp)
				local reg = minetest.registered_nodes[n.name]
				if reg.groups.tree and reg.groups.tree ~= 0 then
					--print("cached trunk still exists")
					return
				end
				--print("cached trunk is invalid")
				-- Cache is invalid
				table.remove(default.leafdecay_trunk_cache, p0_hash)
			end
		end
		for dx = -d, d do if do_preserve then break end
		for dy = -d, d do if do_preserve then break end
		for dz = -d, d do if do_preserve then break end
			local p = {
				x = p0.x + dx,
				y = p0.y + dy,
				z = p0.z + dz,
			}
			local n = minetest.env:get_node(p)
			local reg = minetest.registered_nodes[n.name]
			if reg.groups.tree and reg.groups.tree ~= 0 then
				do_preserve = true
				if default.leafdecay_enable_cache then
					--print("caching trunk")
					-- Cache the trunk
					default.leafdecay_trunk_cache[p0_hash] = p
				end
			end
		end
		end
		end
		if not do_preserve then
			minetest.env:remove_node(p0)
		end
	end
})

