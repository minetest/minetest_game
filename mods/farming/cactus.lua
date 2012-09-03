minetest.register_abm({
	nodenames = {"default:cactus"},
	interval = 50,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y-1
		local name = minetest.env:get_node(pos).name
		if name == "default:desert_sand" or name == "default:sand" then
			pos.y = pos.y+1
			local height = 0
			while minetest.env:get_node(pos).name == "default:cactus" do
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
