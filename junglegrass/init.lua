-- Junglegrass mod by VanessaE (using ironzorg's flowers mod as a basis)
-- 2012-08-03
--
-- Now featuring perlin noise for better growth control! :-)
--
-- License:  WTFPL for the code, cc-by-sa for the textures

math.randomseed(os.time())

local DEBUG = 0

local SEED = 52453235636 -- chosen by mashing the keyboard ;-)  map seed + this = perlin noise seed
local ABUNDANCE = 0.6 -- lower = more abundant
local GROWING_DELAY = 500 -- higher = run the ABM less often
local RADIUS = 7 -- higher = less dense within the biome area

local GRASSES = {
        "junglegrass:shortest",
        "junglegrass:short",
        "junglegrass:medium",
        "default:junglegrass",
	"default:dry_shrub",
	"default:cactus",
}

local dbg = function(s)
	if DEBUG == 1 then
		print('[JUNGLEGRASS] ' .. s)
	end
end

local is_node_loaded = function(nodenames, node_pos)
	n = minetest.env:get_node_or_nil(node_pos)
	if (n == nil) or (n.name == 'ignore') then
		return false
	end
	return true
end

junglegrass_spawn_on_surfaces = function(growdelay, grownames, surfaces)
	for _, surface in ipairs(surfaces) do
		minetest.register_abm({
			nodenames = { surface.name },
			interval = growdelay,
			chance = surface.chance,
			action = function(pos, node, active_object_count, active_object_count_wider)
				local p_top = { x = pos.x, y = pos.y + 1, z = pos.z }	
				local n_top = minetest.env:get_node(p_top)
				local perlin = minetest.env:get_perlin(SEED, 3, 0.5, 150 ) -- using numbers suggested by Splizard
				local noise = perlin:get2d({x=p_top.x, y=p_top.z})
				if ( noise > ABUNDANCE )
					and (n_top.name == "air")
					and (is_node_loaded(grownames, p_top) == true)
					and ((minetest.env:find_node_near(p_top, RADIUS, GRASSES) == nil ) or (surface.name == "default:cactus"))
					then
						local nnode = grownames[math.random(1, #grownames)]
						dbg("Perlin noise value: "..noise)
						dbg('Spawning '
						  .. nnode .. ' at ('
						  .. p_top.x .. ', '
						  .. p_top.y .. ', '
						  .. p_top.z .. ') on '
						  .. surface.name)
						minetest.env:add_node(p_top, { name = nnode })
				end
			end
		})
	end
end

grow_on_surfaces = function(growdelay, grownames, surfaces)
	for _, surface in ipairs(surfaces) do
		minetest.register_abm({
			nodenames = { surface.name },
			interval = growdelay,
			chance = surface.chance,
			action = function(pos, node, active_object_count, active_object_count_wider)
				local p_top = { x = pos.x, y = pos.y + 1, z = pos.z }	
				local n_top = minetest.env:get_node(p_top)
				local nnode = grownames[math.random(1, #grownames)]

				if (is_node_loaded(grownames, p_top) == true) then
					if (n_top.name == "junglegrass:shortest") then
						dbg('Growing shortest into short at ('
						  .. p_top.x .. ', '
						  .. p_top.y .. ', '
						  .. p_top.z .. ') on '
						  .. surface.name)
						minetest.env:add_node(p_top, { name = "junglegrass:short" })
					end
	
					if (surface.name == "default:desert_sand") then
						if (n_top.name == "junglegrass:short") or (n_top.name == "junglegrass:medium") or (n_top.name == "default:junglegrass") then
							dbg(nnode .. ' in desert turns to dry shrub at ('
							  .. p_top.x .. ', '
							  .. p_top.y .. ', '
							  .. p_top.z .. ') on '
							  .. surface.name)
							minetest.env:add_node(p_top, { name = "default:dry_shrub" })
						end
					else
						if (n_top.name == "junglegrass:short") then
							dbg('Growing short into medium at ('
							  .. p_top.x .. ', '
							  .. p_top.y .. ', '
							  .. p_top.z .. ') on '
							  .. surface.name)
							minetest.env:add_node(p_top, { name = "junglegrass:medium" })
						end

						if (n_top.name == "junglegrass:medium") then
							dbg('Growing medium into full size at ('
							  .. p_top.x .. ', '
							  .. p_top.y .. ', '
							  .. p_top.z .. ') on '
							  .. surface.name)
							minetest.env:add_node(p_top, { name = "default:junglegrass" })
						end

						if (n_top.name == "default:junglegrass") then
							dbg(nnode .. ' dies at ('
							  .. p_top.x .. ', '
							  .. p_top.y .. ', '
							  .. p_top.z .. ') on '
							  .. surface.name)
							minetest.env:remove_node(p_top)
						end
					end
				end
			end
		})
	end
end

-- On regular fertile ground, any size can spawn

junglegrass_spawn_on_surfaces(GROWING_DELAY, {
	"junglegrass:shortest",
	"junglegrass:short",
	"junglegrass:medium",
	"default:junglegrass",
	}, {
	{name = "default:dirt_with_grass",	chance = 2},
	{name = "default:dirt",			chance = 2},
	{name = "default:sand",			chance = 5},
})

-- On cactus, papyrus, and desert sand, only the two smallest sizes can spawn

junglegrass_spawn_on_surfaces(GROWING_DELAY, {
	"junglegrass:shortest",
	"junglegrass:short",
	}, {
	{name = "default:papyrus",		chance = 1.5},
	{name = "default:cactus",		chance = 3},
	{name = "default:desert_sand",		chance = 10},
})

-- make the grasses grow and die

grow_on_surfaces(GROWING_DELAY, {
	"junglegrass:shortest",
	"junglegrass:short",
	"junglegrass:medium",
	"default:junglegrass",
	}, {
	{name = "default:dirt_with_grass",	chance = 5},
	{name = "default:dirt",			chance = 5},
	{name = "default:sand",			chance = 5},
	{name = "default:desert_sand",		chance = 20}
})

-- The actual node definitions

minetest.register_node('junglegrass:medium', {
	description = "Jungle Grass (medium height)",
	drawtype = 'plantlike',
	tile_images = { 'junglegrass_medium.png' },
	inventory_image = 'junglegrass_medium.png',
	wield_image = 'junglegrass_medium.png',
	sunlight_propagates = true,
	paramtype = 'light',
	walkable = false,
	groups = { snappy = 3,flammable=2 },
	sounds = default.node_sound_leaves_defaults(),
	drop = 'default:junglegrass',

	selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	},
})

minetest.register_node('junglegrass:short', {
	description = "Jungle Grass (short)",
	drawtype = 'plantlike',
	tile_images = { 'junglegrass_short.png' },
	inventory_image = 'junglegrass_short.png',
	wield_image = 'junglegrass_short.png',
	sunlight_propagates = true,
	paramtype = 'light',
	walkable = false,
	groups = { snappy = 3,flammable=2 },
	sounds = default.node_sound_leaves_defaults(),
	drop = 'default:junglegrass',
	selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4, 0.3, 0.4},
	},
})

minetest.register_node('junglegrass:shortest', {
	description = "Jungle Grass (very short)",
	drawtype = 'plantlike',
	tile_images = { 'junglegrass_shortest.png' },
	inventory_image = 'junglegrass_shortest.png',
	wield_image = 'junglegrass_shortest.png',
	sunlight_propagates = true,
	paramtype = 'light',
	walkable = false,
	groups = { snappy = 3,flammable=2 },
	sounds = default.node_sound_leaves_defaults(),
	drop = 'default:junglegrass',
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3},
	},
})


print("[Junglegrass] Loaded!")
