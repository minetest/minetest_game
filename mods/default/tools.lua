-- mods/default/tools.lua

-- support for MT game translation.
local S = default.get_translator

-- The hand
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {fleshy=1},
	}
})

--
-- Picks
--

local tool_pick = {
	wood = {
		desc = "Wooden Pickaxe",
		punch = 1.2, drop = 0, damage = 2,
		cap = {times={[3]=1.60}, uses=10, maxlevel=1},
		groups = {flammable = 2},
	},
	stone = {
		desc = "Stone Pickaxe",
		punch = 1.3, drop = 0, damage = 3,
		cap = {times={[2]=2.0, [3]=1.00}, uses=20, maxlevel=1},
	},
	bronze = {
		desc = "Bronze Pickaxe",
		punch = 1.0, drop = 1, damage = 4,
		cap = {times={[1]=4.50, [2]=1.80, [3]=0.90}, uses=20, maxlevel=2},
	},
	steel = {
		desc = "Steel Pickaxe",
		punch = 1.0, drop = 1, damage = 4,
		cap = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
	},
	mese = {
		desc = "Mese Pickaxe",
		punch = 0.9, drop = 3, damage = 5,
		cap = {times={[1]=2.4, [2]=1.2, [3]=0.60}, uses=20, maxlevel=3},
	},
	diamond = {
		desc = "Diamond Pickaxe",
		punch = 0.9, drop = 3, damage = 5,
		cap = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
	}
}

for mat, tool in pairs(tool_pick) do
	tool.groups = tool.groups or {}
	tool.groups.pickaxe = 1
	minetest.register_tool("default:pick_".. mat, {
		description = S(tool.desc),
		inventory_image = "default_tool_".. mat .."pick.png",
		tool_capabilities = {
			full_punch_interval = tool.punch,
			max_drop_level = tool.drop,
			groupcaps={
				cracky = tool.cap,
			},
			damage_groups = {fleshy = tool.damage},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = tool.groups
	})
end

--
-- Shovels
--

local tool_shovel = {
	wood = {
		desc = "Wooden Shovel",
		punch = 1.2, drop = 0, damage = 2,
		cap = {times={[1]=3.00, [2]=1.60, [3]=0.60}, uses=10, maxlevel=1},
		groups = {flammable = 2},
	},
	stone = {
		desc = "Stone Shovel",
		punch = 1.4, drop = 0, damage = 2,
		cap = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
	},
	bronze = {
		desc = "Bronze Shovel",
		punch = 1.2, drop = 1, damage = 3,
		cap = {times={[1]=1.65, [2]=1.05, [3]=0.45}, uses=25, maxlevel=2},
	},
	steel = {
		desc = "Steel Shovel",
		punch = 1.1, drop = 1, damage = 3,
		cap = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
	},
	mese = {
		desc = "Mese Shovel",
		punch = 1.0, drop = 3, damage = 4,
		cap = {times={[1]=1.20, [2]=0.60, [3]=0.30}, uses=20, maxlevel=3},
	},
	diamond = {
		desc = "Diamond Shovel",
		punch = 1.0, drop = 1, damage = 4,
		cap = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
	}
}

for mat, tool in pairs(tool_shovel) do
	tool.groups = tool.groups or {}
	tool.groups.shovel = 1
	minetest.register_tool("default:shovel_".. mat, {
		description = S(tool.desc),
		inventory_image = "default_tool_".. mat .."shovel.png",
		wield_image = "default_tool_".. mat .."shovel.png^[transformR90",
		tool_capabilities = {
			full_punch_interval = tool.punch,
			max_drop_level = tool.drop,
			groupcaps={
				crumbly = tool.cap,
			},
			damage_groups = {fleshy = tool.damage},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = tool.groups
	})
end

--
-- Axes
--

local tool_axe = {
	wood = {
		desc = "Wooden Axe",
		punch = 1.0, drop = 0, damage = 2,
		cap = {times={[2]=3.00, [3]=1.60}, uses=10, maxlevel=1},
		groups = {flammable = 2},
	},
	stone = {
		desc = "Stone Axe",
		punch = 1.2, drop = 0, damage = 3,
		cap = {times={[1]=3.00, [2]=2.00, [3]=1.30}, uses=20, maxlevel=1},
	},
	bronze = {
		desc = "Bronze Axe",
		punch = 1.0, drop = 1, damage = 4,
		cap = {times={[1]=2.75, [2]=1.70, [3]=1.15}, uses=20, maxlevel=2},
	},
	steel = {
		desc = "Steel Axe",
		punch = 1.0, drop = 1, damage = 4,
		cap = {times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
	},
	mese = {
		desc = "Mese Axe",
		punch = 0.9, drop = 1, damage = 6,
		cap = {times={[1]=2.20, [2]=1.00, [3]=0.60}, uses=20, maxlevel=3},
	},
	diamond = {
		desc = "Diamond Axe",
		punch = 0.9, drop = 1, damage = 7,
		cap = {times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3},
	}
}

for mat, tool in pairs(tool_axe) do
	tool.groups = tool.groups or {}
	tool.groups.axe = 1
	minetest.register_tool("default:axe_".. mat, {
		description = S(tool.desc),
		inventory_image = "default_tool_".. mat .."axe.png",
		tool_capabilities = {
			full_punch_interval = tool.punch,
			max_drop_level = tool.drop,
			groupcaps={
				choppy = tool.cap,
			},
			damage_groups = {fleshy = tool.damage},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = tool.groups
	})
end

--
-- Swords
--

local tool_sword = {
	wood = {
		desc = "Wooden Sword",
		punch = 1.0, drop = 0, damage = 2,
		cap = {times={[2]=1.6, [3]=0.40}, uses=10, maxlevel=1},
		groups = {flammable = 2},
	},
	stone = {
		desc = "Stone Sword",
		punch = 1.2, drop = 0, damage = 4,
		cap = {times={[2]=1.4, [3]=0.40}, uses=20, maxlevel=1},
	},
	bronze = {
		desc = "Bronze Sword",
		punch = 0.8, drop = 1, damage = 6,
		cap = {times={[1]=2.75, [2]=1.30, [3]=0.375}, uses=25, maxlevel=2},
	},
	steel = {
		desc = "Steel Sword",
		punch = 0.8, drop = 1, damage = 6,
		cap = {times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
	},
	mese = {
		desc = "Mese Sword",
		punch = 0.7, drop = 1, damage = 7,
		cap = {times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=30, maxlevel=3},
	},
	diamond = {
		desc = "Diamond Sword",
		punch = 0.7, drop = 1, damage = 8,
		cap = {times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
	}
}

for mat, tool in pairs(tool_sword) do
	tool.groups = tool.groups or {}
	tool.groups.sword = 1
	minetest.register_tool("default:sword_".. mat, {
		description = S(tool.desc),
		inventory_image = "default_tool_".. mat .."sword.png",
		tool_capabilities = {
			full_punch_interval = tool.punch,
			max_drop_level = tool.drop,
			groupcaps={
				snappy = tool.cap,
			},
			damage_groups = {fleshy = tool.damage},
		},
		sound = {breaks = "default_tool_breaks"},
		groups = tool.groups
	})
end

--
-- Register Craft Recipies
--

local craft_ingreds = {
	wood = "group:wood",
	stone = "group:stone",
	steel = "default:steel_ingot",
	bronze = "default:bronze_ingot",
	mese = "default:mese_crystal",
	diamond = "default:diamond"
}

for name, mat in pairs(craft_ingreds) do
	minetest.register_craft({
		output = "default:pick_".. name,
		recipe = {
			{mat, mat, mat},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
		}
	})

	minetest.register_craft({
		output = "default:shovel_".. name,
		recipe = {
			{mat},
			{"group:stick"},
			{"group:stick"}
		}
	})

	minetest.register_craft({
		output = "default:axe_".. name,
		recipe = {
			{mat, mat},
			{mat, "group:stick"},
			{"", "group:stick"}
		}
	})

	minetest.register_craft({
		output = "default:sword_".. name,
		recipe = {
			{mat},
			{mat},
			{"group:stick"}
		}
	})
end

minetest.register_tool("default:key", {
	description = S("Key"),
	inventory_image = "default_key.png",
	groups = {key = 1, not_in_creative_inventory = 1},
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if def and def.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local pos = pointed_thing.under
		node = minetest.get_node(pos)

		if not node or node.name == "ignore" then
			return itemstack
		end

		local ndef = minetest.registered_nodes[node.name]
		if not ndef then
			return itemstack
		end

		local on_key_use = ndef.on_key_use
		if on_key_use then
			on_key_use(pos, placer)
		end

		return nil
	end
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:pick_wood",
	burntime = 6,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:shovel_wood",
	burntime = 4,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:axe_wood",
	burntime = 6,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:sword_wood",
	burntime = 5,
})
