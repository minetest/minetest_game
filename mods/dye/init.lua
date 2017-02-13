dye = {}

-- Make dye names and descriptions available globally.
-- Other mods can use these for looping through available colors.
dye.dyes = {
	white      = { name = "White", html = "#FFFFFF" },
	grey       = { name = "Grey", html = "#7F7F7F" },
	dark_grey  = { name = "Dark Grey", html = "#3F3F3F" },
	black      = { name = "Black", html = "#000000" },
	violet     = { name = "Violet", html = "#8000FF" },
	blue       = { name = "Blue", html = "#0000FF" },
	cyan       = { name = "Cyan", html = "#00FFFF" },
	dark_green = { name = "Dark Green", html = "#007F00" },
	green      = { name = "Green", html = "#00FF00" },
	yellow     = { name = "Yellow", html = "#FFFF00" },
	brown      = { name = "Brown", html = "#854C30" },
	orange	   = { name = "Orange", html = "#FF7F00" },
	red        = { name = "Red", html = "#FF0000" },
	magenta    = { name = "Magenta", html = "#FF00FF" },
	pink       = { name = "Pink", html = "#FF7FFF" },
}

----
-- Helper functions.
----

-- Convert an html color in the format of #RRGGBB into red, green, and blue values on the range of [0..255].
local function hex_to_rgb(html_color)
	html_color = html_color:gsub("#", "")
	return tonumber("0x"..html_color:sub(1, 2)), tonumber("0x"..html_color:sub(3, 4)), tonumber("0x"..html_color:sub(5, 6))
end

-- Convert the red, green, and blue color components back into an html color string.
local function rgb_to_hex(red, green, blue)
	return string.format("#%02X%02X%02X", red, green, blue)
end


-- Convert red, green, and blue values from the range of [0..255] into hue, saturation, and value/lightness values on the range of...?
local function rgb_to_hsv(red, green, blue)
	local r = red / 255
	local g = green / 255
	local b = blue / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, v = max, max, max

	local d = max - min;
	if max ~= 0 then
		s = d / max
	end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
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
		h = h / 6
	end
	return h, s, v
end

--[[
	Convert the hue, saturation, and value/lightness values output from rgb_to_hsv
	back into red, green, and blue values on the range of [0..255].
]]
local function hsv_to_rgb(hue, saturation, value)
	local i = math.floor(hue * 6)
	local f = hue * 6 - i
	local p = value * (1 - saturation)
	local q = value * (1 - f * saturation)
	local t = value * (1 - (1 - f) * saturation)

	local red, green, blue

	local cases = {
		[0] = function() red, green, blue = value, t, p end,
		[1] = function() red, green, blue = q, value, p end,
		[2] = function() red, green, blue = p, value, t end,
		[3] = function() red, green, blue = p, q, value end,
		[4] = function() red, green, blue = t, p, value end,
		[5] = function() red, green, blue = value, p, q end
	}
	cases[i % 6]()

	return math.floor(red * 255 + 0.5), math.floor(green * 255 + 0.5), math.floor(blue * 255 + 0.5)
end

-- Make the input html color darker by the given percent.
local function darken_color(html_color, percent)
	local r, g, b = hex_to_rgb(html_color)
	local h, s, v = rgb_to_hsv(r, g, b)
	v = v * (1 - percent)
	r, g, b = hsv_to_rgb(h, s, v)
	return rgb_to_hex(r, g, b)
end

----
-- Define items.
----

for key, value in pairs(dye.dyes) do
	local item_name = "dye:"..key

	minetest.register_craftitem(item_name, {
		inventory_image = "(dye_base.png^[colorize:"..darken_color(value.html, 0.25)..")^(dye_highlight.png^[colorize:"..value.html ..")",
		description = value.name.." Dye",
		groups = "color_"..key
	})
	minetest.register_craft({
		type = "shapeless",
		output = item_name .. " 4",
		recipe = {"group:flower,color_"..key},
	})
end

-- Manually add coal->black dye.
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
