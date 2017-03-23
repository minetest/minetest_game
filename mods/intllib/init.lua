
-- Old multi-load method compatibility
if rawget(_G, "intllib") then return end

intllib = {
	getters = {},
	strings = {},
}


local MP = minetest.get_modpath("intllib")

dofile(MP.."/lib.lua")


local LANG = minetest.setting_get("language")
if not (LANG and (LANG ~= "")) then LANG = os.getenv("LANG") end
if not (LANG and (LANG ~= "")) then LANG = "en" end


local INS_CHAR = intllib.INSERTION_CHAR
local insertion_pattern = "("..INS_CHAR.."?)"..INS_CHAR.."(%(?)(%d+)(%)?)"

local function do_replacements(str, ...)
	local args = {...}
	-- Outer parens discard extra return values
	return (str:gsub(insertion_pattern, function(escape, open, num, close)
		if escape == "" then
			local replacement = tostring(args[tonumber(num)])
			if open == "" then
				replacement = replacement..close
			end
			return replacement
		else
			return INS_CHAR..open..num..close
		end
	end))
end

local function make_getter(msgstrs)
	return function(s, ...)
		local str
		if msgstrs then
			str = msgstrs[s]
		end
		if not str or str == "" then
			str = s
		end
		if select("#", ...) == 0 then
			return str
		end
		return do_replacements(str, ...)
	end
end


local function Getter(modname)
	modname = modname or minetest.get_current_modname()
	if not intllib.getters[modname] then
		local msgstr = intllib.get_strings(modname)
		intllib.getters[modname] = make_getter(msgstr)
	end
	return intllib.getters[modname]
end


function intllib.Getter(modname)
	minetest.log("deprecated", "intllib.Getter is deprecated."
			.."Please use intllib.make_gettext_pair instead.")
	return Getter(modname)
end


local gettext = dofile(minetest.get_modpath("intllib").."/gettext.lua")


local function catgettext(catalogs, msgid)
	for _, cat in ipairs(catalogs) do
		local msgstr = cat and cat[msgid]
		if msgstr and msgstr~="" then
			local msg = msgstr[0]
			return msg~="" and msg or nil
		end
	end
end

local function catngettext(catalogs, msgid, msgid_plural, n)
	n = math.floor(n)
	for i, cat in ipairs(catalogs) do
		local msgstr = cat and cat[msgid]
		if msgstr then
			local index = cat.plural_index(n)
			local msg = msgstr[index]
			return msg~="" and msg or nil
		end
	end
	return n==1 and msgid or msgid_plural
end


local gettext_getters = { }
function intllib.make_gettext_pair(modname)
	modname = modname or minetest.get_current_modname()
	if gettext_getters[modname] then
		return unpack(gettext_getters[modname])
	end
	local localedir = minetest.get_modpath(modname).."/locale"
	local catalogs = gettext.load_catalogs(localedir)
	local getter = Getter(modname)
	local function gettext(msgid, ...)
		local msgstr = (catgettext(catalogs, msgid)
				or getter(msgid))
		return do_replacements(msgstr, ...)
	end
	local function ngettext(msgid, msgid_plural, n, ...)
		local msgstr = (catngettext(catalogs, msgid, msgid_plural, n)
				or getter(msgid))
		return do_replacements(msgstr, ...)
	end
	gettext_getters[modname] = { gettext, ngettext }
	return gettext, ngettext
end


local function get_locales(code)
	local ll, cc = code:match("^(..)_(..)")
	if ll then
		return { ll.."_"..cc, ll, ll~="en" and "en" or nil }
	else
		return { code, code~="en" and "en" or nil }
	end
end


function intllib.get_strings(modname, langcode)
	langcode = langcode or LANG
	modname = modname or minetest.get_current_modname()
	local msgstr = intllib.strings[modname]
	if not msgstr then
		local modpath = minetest.get_modpath(modname)
		msgstr = { }
		for _, l in ipairs(get_locales(langcode)) do
			local t = intllib.load_strings(modpath.."/locale/"..l..".txt") or { }
			for k, v in pairs(t) do
				msgstr[k] = msgstr[k] or v
			end
		end
		intllib.strings[modname] = msgstr
	end
	return msgstr
end

