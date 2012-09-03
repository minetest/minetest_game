minetest.register_abm({
	nodenames = {"default:papyrus"},
	interval = 50,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y-1
		local name = minetest.env:get_node(pos).name
		if name == "default:dirt" or name == "default:dirt_with_grass" then
			if minetest.env:find_node_near(pos, 3, {"default:water_source", "default:water_flowing"}) == nil then
				return
			end
			pos.y = pos.y+1
			local height = 0
			while minetest.env:get_node(pos).name == "default:papyrus" do
				height = height+1
				pos.y = pos.y+1
			end
			if height < 4 then
				if minetest.env:get_node(pos).name == "air" then
					minetest.env:set_node(pos, node)
				end
			end
		end
	end
})
