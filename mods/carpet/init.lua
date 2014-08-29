-- Carpet API
carpet = {}

-- Registering carpet ( carpet.register() )
--[[
	def is a table that contains:
	name		: itemstring "carpet:name"
	description	: node description (optional)
	images		: node tiles
	recipeitem	: node crafting recipeitem {recipeitem,recipeitem}
	groups		: node groups
	sounds		: node sounds (optional)
--]]
-- Carpet will be named carpet:name
function carpet.register(def)
	local name = def.name
	local desc = def.description or ""
	local recipeitem = def.recipeitem
	local sounds = def.sounds or default.node_sound_defaults()
	-- Node Definition
	minetest.register_node("carpet:"..name, {
		description = desc,
		tiles = def.images,
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -7/16, 0.5},
		},
		drawtype = "nodebox",
		groups = def.groups,
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
local added_wool = {
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

for _, row in ipairs(added_wool) do
	local name = row[1]
	local desc = row[2]
	carpet.register({
		name = name,
		description = desc..' Carpet',
		images = {'wool_'..name..'.png'},
		recipeitem = 'wool:'..name,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,flammable=3,falling_node=1,carpet=1},
		sounds = default.node_sound_defaults()
	})
end
