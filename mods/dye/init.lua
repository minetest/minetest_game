-- minetest/dye/init.lua

-- Other mods can use these for looping through available colors
dye = {}
dye.basecolors = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
dye.excolors = {"white", "lightgrey", "grey", "darkgrey", "black", "red", "orange", "yellow", "lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta", "red_violet"}

-- Local stuff
local dyelocal = {}

-- Intllib
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end
dye.intllib = S

-- This collection of colors is partly a historic thing, partly something else.
dyelocal.dyes = {
	{"white",      S("White dye"),     {dye=1, basecolor_white=1,   excolor_white=1,     unicolor_white=1}},
	{"grey",       S("Grey dye"),      {dye=1, basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1}},
	{"dark_grey",  S("Dark grey dye"), {dye=1, basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1}},
	{"black",      S("Black dye"),     {dye=1, basecolor_black=1,   excolor_black=1,     unicolor_black=1}},
	{"violet",     S("Violet dye"),    {dye=1, basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1}},
	{"blue",       S("Blue dye"),      {dye=1, basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1}},
	{"cyan",       S("Cyan dye"),      {dye=1, basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1}},
	{"dark_green", S("Dark green dye"),{dye=1, basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green",      S("Green dye"),     {dye=1, basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow",     S("Yellow dye"),    {dye=1, basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown",      S("Brown dye"),     {dye=1, basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1}},
	{"orange",     S("Orange dye"),    {dye=1, basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red",        S("Red dye"),       {dye=1, basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
	{"magenta",    S("Magenta dye"),   {dye=1, basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1}},
	{"pink",       S("Pink dye"),      {dye=1, basecolor_red=1,     excolor_red=1,       unicolor_light_red=1}},
}

-- Define items
for _, row in ipairs(dyelocal.dyes) do
	local name = row[1]
	local description = row[2]
	local groups = row[3]
	local item_name = "dye:"..name
	local item_image = "dye_"..name..".png"
	minetest.register_craftitem(item_name, {
		inventory_image = item_image,
		description = description,
		groups = groups
	})
	minetest.register_craft({
		type = "shapeless",
		output = item_name.." 4",
		recipe = {"group:flower,color_"..name},
	})
end
-- manually add coal->black dye
minetest.register_craft({
	type = "shapeless",
	output = "dye:black 4",
	recipe = {"group:coal"},
})

-- Mix recipes
-- Just mix everything to everything somehow sanely

dyelocal.mixbases = {"magenta", "red", "orange", "brown", "yellow", "green", "dark_green", "cyan", "blue", "violet", "black", "dark_grey", "grey", "white"}

dyelocal.mixes = {
	--       magenta,  red,    orange,   brown,    yellow,  green,  dark_green, cyan,    blue,   violet,   black,  dark_grey,  grey,   white
	white = {"pink",  "pink", "orange", "orange", "yellow", "green", "green",  "grey",  "cyan", "violet",  "grey",  "grey",   "white", "white"},
	grey  = {"pink",  "pink", "orange", "orange", "yellow", "green", "green",  "grey",  "cyan",  "pink",  "dark_grey","grey", "grey"},
	dark_grey={"brown","brown", "brown", "brown", "brown","dark_green","dark_green","blue","blue","violet","black", "black"},
	black = {"black", "black", "black",  "black", "black",  "black", "black",  "black", "black", "black",  "black"},
	violet= {"magenta","magenta","red",  "brown", "red",    "cyan",  "brown",  "blue",  "violet","violet"},
	blue  = {"violet", "magenta","brown","brown","dark_green","cyan","cyan",   "cyan",  "blue"},
	cyan  = {"blue","brown","dark_green","dark_grey","green","cyan","dark_green","cyan"},
	dark_green={"brown","brown","brown", "brown", "green",  "green", "dark_green"},
	green = {"brown", "yellow","yellow","dark_green","green","green"},
	yellow= {"red",  "orange", "yellow","orange", "yellow"},
	brown = {"brown", "brown","orange", "brown"},
	orange= {"red",  "orange","orange"},
	red   = {"magenta","red"},
	magenta={"magenta"},
}

for one,results in pairs(dyelocal.mixes) do
	for i,result in ipairs(results) do
		local another = dyelocal.mixbases[i]
		minetest.register_craft({
			type = "shapeless",
			output = 'dye:'..result..' 2',
			recipe = {'dye:'..one, 'dye:'..another},
		})
	end
end
