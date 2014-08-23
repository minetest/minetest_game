carpet = {}

-- Carpet API
--[[
	name		: itemstring "carpet:name"
	desc		: node description
	images		: node tiles
	recipeitem	: node crafting recipeitem {recipeitem,recipeitem}
	groups		: node groups
	sounds		: node sounds
--]]
-- Carpet will be named carpet:name
function carpet.add(name, desc, images, recipeitem, groups, sounds)
	-- Node Definition
	minetest.register_node("carpet:"..name, {
		description = desc,
		tiles = images,
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -7/16, 0.5},
		},
		drawtype = "nodebox",
		groups = groups,
		sounds = sounds,
	})
	-- Crafting Definition
	minetest.register_craft({
		output = 'carpet:'..name..' 4',
		recipe = {
			{recipeitem, recipeitem},
		}
	})
end

-- Add carpet from wool mod
carpet.wool = {
	{"white",		"White"},
	{"grey",		"Grey"},
	{"black",		"Black"},
	{"red",			"Red"},
	{"yellow",		"Yellow"},
	{"green",		"Green"},
	{"cyan",		"Cyan"},
	{"blue",		"Blue"},
	{"magenta",		"Magenta"},
	{"orange",		"Orange"},
	{"violet",		"Violet"},
	{"brown",		"Brown"},
	{"pink",		"Pink"},
	{"dark_grey",	"Dark Grey"},
	{"dark_green",	"Dark Green"},
}

for _, row in ipairs(carpet.wool) do
	local name = row[1]
	local desc = row[2]
	carpet.add(
		name, desc..' Carpet',
		{'wool_'..name..'.png'}, 'wool:'..name,
		{snappy=2,choppy=2,oddly_breakable_by_hand=3,flammable=3,falling_node=1,carpet=1},
		default.node_sound_defaults()
	)
end
