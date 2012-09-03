farming = {}

function farming:add_plant(full_grown, names, interval, chance)
	minetest.register_abm({
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			pos.y = pos.y-1
			if minetest.env:get_node(pos).name ~= "farming:soil_wet" then
				return
			end
			pos.y = pos.y+1
			if minetest.env:get_node_light(pos) < 8 then
				return
			end
			local step = nil
			for i,name in ipairs(names) do
				if name == node.name then
					step = i
					break
				end
			end
			if step == nil then
				return
			end
			local new_node = {name=names[step+1]}
			if new_node.name == nil then
				new_node.name = full_grown
			end
			minetest.env:set_node(pos, new_node)
		end
}	)
end

function farming:generate_tree(pos, trunk, leaves, underground, replacements)
	pos.y = pos.y-1
	local nodename = minetest.env:get_node(pos).name
	local ret = true
	for _,name in ipairs(underground) do
		if nodename == name then
			ret = false
			break
		end
	end
	pos.y = pos.y+1
	if ret or minetest.env:get_node_light(pos) < 8 then
		return
	end
	
	node = {name = ""}
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.env:get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	node.name = trunk
	for dy=0,4 do
		pos.y = pos.y+dy
		minetest.env:set_node(pos, node)
		pos.y = pos.y-dy
	end
	
	if not replacements then
		replacements = {}
	end
	
	node.name = leaves
	pos.y = pos.y+3
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz
				
				if dx == 0 and dz == 0 and dy==3 then
					if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.env:set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
							end
						end
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.env:set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
							end
						end
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.env:get_node(pos).name == "air" then
						minetest.env:set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
							end
						end
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.env:set_node(pos, node)
							for name,rarity in pairs(replacements) do
								if math.random(1, rarity) == 1 then
								minetest.env:set_node(pos, {name=name})
								end
							end
						end
					end
				end
				
				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end

farming.seeds = {
	["farming:wheat_seed"]=20,
	["farming:cotton_seed"]=30,
	["farming:pumpkin_seed"]=60,
	["farming:strawberry_seed"]=30,
	["farming:rhubarb_seed"]=30,
	["farming:potatoe_seed"]=30,
	["farming:tomato_seed"]=30,
	["farming:orange_seed"]=30,
	["farming:carrot_seed"]=30,
}

-- ========= SOIL =========
dofile(minetest.get_modpath("farming").."/soil.lua")

-- ========= HOES =========
dofile(minetest.get_modpath("farming").."/hoes.lua")

-- ========= CORN =========
dofile(minetest.get_modpath("farming").."/wheat.lua")

-- ========= COTTON =========
dofile(minetest.get_modpath("farming").."/cotton.lua")

-- ========= PUMPKINS =========
dofile(minetest.get_modpath("farming").."/pumpkin.lua")

-- ========= RUBBER =========
dofile(minetest.get_modpath("farming").."/rubber.lua")

-- ========= WEED =========
dofile(minetest.get_modpath("farming").."/weed.lua")

-- ========= STRAWBERRIES =========
dofile(minetest.get_modpath("farming").."/strawberries.lua")

-- ========= RHUBARB =========
dofile(minetest.get_modpath("farming").."/rhubarb.lua")

-- ========= POTATOES =========
dofile(minetest.get_modpath("farming").."/potatoes.lua")

-- ========= TOMATOES =========
dofile(minetest.get_modpath("farming").."/tomatoes.lua")

-- ========= ORANGES =========
dofile(minetest.get_modpath("farming").."/oranges.lua")

-- ========= BANANAS =========
dofile(minetest.get_modpath("farming").."/bananas.lua")

-- ========= PAPYRUS =========
dofile(minetest.get_modpath("farming").."/papyrus.lua")

-- ========= CACTUS =========
dofile(minetest.get_modpath("farming").."/cactus.lua")

-- ========= CARROTS =========
dofile(minetest.get_modpath("farming").."/carrots.lua")
