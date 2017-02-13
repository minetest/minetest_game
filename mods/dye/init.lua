dye = {}

-- Make dye names and descriptions available globally.
-- Other mods can use these for looping through available colors.
dye.dyes = {
	white		= { name = "White", html = "#FFFFFF" },
	grey		= { name = "Grey", html = "#7F7F7F" },
	dark_grey	= { name = "Dark Grey", html = "#3F3F3F" },
	black		= { name = "Black", html = "#000000" },
	violet		= { name = "Violet", html = "#8000FF" },
	blue		= { name = "Blue", html = "#0000FF" },
	cyan		= { name = "Cyan", html = "#00FFFF" },
	dark_green	= { name = "Dark Green", html = "#007F00" },
	green		= { name = "Green", html = "#00FF00" },
	yellow		= { name = "Yellow", html = "#FFFF00" },
	brown		= { name = "Brown", html = "#854C30" },
	orange		= { name = "Orange", html = "#FF7F00" },
	red			= { name = "Red", html = "#FF0000" },
	magenta		= { name = "Magenta", html = "#FF00FF" },
	pink		= { name = "Pink", html = "#FF7FFF" },
}

----
-- Helper functions.
----

--[[
	Convert an html color in the format of #RRGGBB into red, green, and blue values on the range of [0..255].
]]
function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function rgb2hex(r, g, b)
	return string.format("#%02X%02X%02X", r, g, b)
end


--[[
	Convert red, green, and blue values from the range of [0..255]
	into hue, saturation, and value/lightness values on the range of...?
]]
function rgbToHsv(red, green, blue)
	local r = red / 255
	local g = green / 255
	local b = blue / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, v = max, max, max

	local d = max - min;
	if max == 0 then
		s = 0
	else
		s = d / max
	end

	if(max == min) then
		h = 0; -- achromatic
	else
		if   max == r then
			if g < b then
				h = (g - b) / d + 6
			else
				h = (g - b) / d + 0
			end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6;
	end
	return h, s, v
end

--[[
	Convert the hue, saturation, and value/lightness values output from rgbToHsv
	back into red, green, and blue values on the range of [0..255].
]]
function hsvToRgb(h, s, v)
	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	local r, g, b;
	local switch = i % 6
	if     switch == 0 then r, g, b = v, t, p
	elseif switch == 1 then r, g, b = q, v, p
	elseif switch == 2 then r, g, b = p, v, t
	elseif switch == 3 then r, g, b = p, q, v
	elseif switch == 4 then r, g, b = t, p, v
	elseif switch == 5 then r, g, b = v, p, q end

	return math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)
end

function darken(hexColor)
	local r, g, b = hex2rgb(hexColor)
	local h, s, v = rgbToHsv(r, g, b)
	v = v * 0.75
	r, g, b = hsvToRgb(h, s, v)
	return rgb2hex(r, g, b)
end

----
-- Define items.
----

for key, value in pairs(dye.dyes) do
	local itemName = "dye:"..key

	minetest.log("info", "Darkened dye: "..value.html.." to: "..darken(value.html))

	minetest.register_craftitem(itemName, {
		--inventory_image = "dye_"..key..".png",
		inventory_image = "(dye_base.png^[colorize:"..darken(value.html)..")^(dye_highlight.png^[colorize:"..value.html ..")",
		description = value.name,
		groups = "color_"..key
	})
	minetest.register_craft({
		type = "shapeless",
		output = itemName .. " 4",
		recipe = {"group:flower,color_"..key},
	})
end

-- Manually add coal->black dye.
-- TODO: Is this still desirable?

minetest.register_craft({
	type = "shapeless",
	output = "dye:black 4",
	recipe = {"group:coal"},
})

-- Mix recipes
local dye_recipes = {
	-- src1, src2, dst
	-- RYB mixes
	{"red", "blue", "violet"}, -- "purple"
	{"yellow", "red", "orange"},
	{"yellow", "blue", "green"},
	-- RYB complementary mixes
	{"red", "green", "dark_grey"},
	{"yellow", "violet", "dark_grey"},
	{"blue", "orange", "dark_grey"},
	-- CMY mixes - approximation
	{"cyan", "yellow", "green"},
	{"cyan", "magenta", "blue"},
	{"yellow", "magenta", "red"},
	-- other mixes that result in a color we have
	{"red", "green", "brown"},
	{"magenta", "blue", "violet"},
	{"green", "blue", "cyan"},
	{"pink", "violet", "magenta"},
	-- mixes with black
	{"white", "black", "grey"},
	{"grey", "black", "dark_grey"},
	{"green", "black", "dark_green"},
	{"orange", "black", "brown"},
	-- mixes with white
	{"white", "red", "pink"},
	{"white", "dark_grey", "grey"},
	{"white", "dark_green", "green"},
}

for _, mix in pairs(dye_recipes) do
	minetest.register_craft({
		type = "shapeless",
		output = 'dye:' .. mix[3] .. ' 2',
		recipe = {'dye:' .. mix[1], 'dye:' .. mix[2]},
	})
end
