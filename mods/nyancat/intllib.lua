local S, NS = dofile(minetest.get_modpath(minetest.get_current_modname()).."/intllib.lua")


-- Fallback functions for when `intllib` is not installed.
-- Code released under Unlicense <http://unlicense.org>.

-- Get the latest version of this file at:
--   https://raw.githubusercontent.com/minetest-mods/intllib/master/lib/intllib.lua

local function format(str, ...)
	local args = { ... }
	local function repl(escape, open, num, close)
		if escape == "" then
			local replacement = tostring(args[tonumber(num)])
			if open == "" then
				replacement = replacement..close
			end
			return replacement
		else
			return "@"..open..num..close
		end
	end
	return (str:gsub("(@?)@(%(?)(%d+)(%)?)", repl))
end

local gettext, ngettext
if minetest.get_modpath("intllib") then
	if intllib.make_gettext_pair then
		-- New method using gettext.
		gettext, ngettext = intllib.make_gettext_pair()
	else
		-- Old method using text files.
		gettext = intllib.Getter()
	end
end

-- Fill in missing functions.

gettext = gettext or function(msgid, ...)
	return format(msgid, ...)
end

ngettext = ngettext or function(msgid, msgid_plural, n, ...)
	return format(n==1 and msgid or msgid_plural, ...)
end

return gettext, ngettext
