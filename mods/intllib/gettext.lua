
local strfind, strsub, strrep = string.find, string.sub, string.rep
local strmatch, strgsub = string.match, string.gsub
local floor = math.floor

local function split(str, sep)
	local pos, endp = 1, #str+1
	return function()
		if (not pos) or pos > endp then return end
		local s, e = strfind(str, sep, pos, true)
		local part = strsub(str, pos, s and s-1)
		pos = e and e + 1
		return part
	end
end

local function trim(str)
	return strmatch(str, "^%s*(.-)%s*$")
end

local escapes = { n="\n", r="\r", t="\t" }

local function unescape(str)
	return (strgsub(str, "(\\+)([nrt]?)", function(bs, c)
		local bsl = #bs
		local realbs = strrep("\\", bsl/2)
		if bsl%2 == 1 then
			c = escapes[c] or c
		end
		return realbs..c
	end))
end

local function parse_po(str)
	local state, msgid, msgid_plural, msgstrind
	local texts = { }
	local lineno = 0
	local function perror(msg)
		return error(msg.." at line "..lineno)
	end
	for line in split(str, "\n") do repeat
		lineno = lineno + 1
		line = trim(line)

		if line == "" or strmatch(line, "^#") then
			state, msgid, msgid_plural = nil, nil, nil
			break -- continue
		end

		local mid = strmatch(line, "^%s*msgid%s*\"(.*)\"%s*$")
		if mid then
			if state == "id" then
				return perror("unexpected msgid")
			end
			state, msgid = "id", unescape(mid)
			break -- continue
		end

		mid = strmatch(line, "^%s*msgid_plural%s*\"(.*)\"%s*$")
		if mid then
			if state ~= "id" then
				return perror("unexpected msgid_plural")
			end
			state, msgid_plural = "idp", unescape(mid)
			break -- continue
		end

		local ind, mstr = strmatch(line,
				"^%s*msgstr([0-9%[%]]*)%s*\"(.*)\"%s*$")
		if ind then
			if not msgid then
				return perror("missing msgid")
			elseif ind == "" then
				msgstrind = 0
			elseif strmatch(ind, "%[[0-9]+%]") then
				msgstrind = tonumber(strsub(ind, 2, -2))
			else
				return perror("malformed msgstr")
			end
			texts[msgid] = texts[msgid] or { }
			if msgid_plural then
				texts[msgid_plural] = texts[msgid]
			end
			texts[msgid][msgstrind] = unescape(mstr)
			state = "str"
			break -- continue
		end

		mstr = strmatch(line, "^%s*\"(.*)\"%s*$")
		if mstr then
			if state == "id" then
				msgid = msgid..unescape(mstr)
				break -- continue
			elseif state == "idp" then
				msgid_plural = msgid_plural..unescape(mstr)
				break -- continue
			elseif state == "str" then
				local text = texts[msgid][msgstrind]
				texts[msgid][msgstrind] = text..unescape(mstr)
				break -- continue
			end
		end

		return perror("malformed line")

	until true end -- end for

	return texts
end

local M = { }

local domains = { }
local dgettext_cache = { }
local dngettext_cache = { }
local langs

local function detect_languages()
	if langs then return langs end

	langs = { }

	local function addlang(l)
		local sep
		langs[#langs+1] = l
		sep = strfind(l, ".", 1, true)
		if sep then
			l = strsub(l, 1, sep-1)
			langs[#langs+1] = l
		end
		sep = strfind(l, "_", 1, true)
		if sep then
			langs[#langs+1] = strsub(l, 1, sep-1)
		end
	end

	local v

	v = minetest.setting_get("language")
	if v and v~="" then
		addlang(v)
	end

	v = os.getenv("LANGUAGE")
	if v then
		for item in split(v, ":") do
			addlang(item)
		end
	end

	v = os.getenv("LANG")
	if v then
		addlang(v)
	end

	return langs
end

local function warn(msg)
	minetest.log("warning", "[intllib] "..msg)
end

-- hax!
-- This function converts a C expression to an equivalent Lua expression.
-- It handles enough stuff to parse the `Plural-Forms` header correctly.
-- Note that it assumes the C expression is valid to begin with.
local function compile_plural_forms(str)
	local plural = strmatch(str, "plural=([^;]+);?$")
	local function replace_ternary(str)
		local c, t, f = strmatch(str, "^(.-)%?(.-):(.*)")
		if c then
			return ("__if("
					..replace_ternary(c)
					..","..replace_ternary(t)
					..","..replace_ternary(f)
					..")")
		end
		return str
	end
	plural = replace_ternary(plural)
	plural = strgsub(plural, "&&", " and ")
	plural = strgsub(plural, "||", " or ")
	plural = strgsub(plural, "!=", "~=")
	plural = strgsub(plural, "!", " not ")
	local f, err = loadstring([[
		local function __if(c, t, f)
			if c and c~=0 then return t else return f end
		end
		local function __f(n)
			return (]]..plural..[[)
		end
		return (__f(...))
	]])
	if not f then return nil, err end
	local env = { }
	env._ENV, env._G = env, env
	setfenv(f, env)
	return function(n)
		local v = f(n)
		if type(v) == "boolean" then
			-- Handle things like a plain `n != 1`
			v = v and 1 or 0
		end
		return v
	end
end

local function parse_headers(str)
	local headers = { }
	for line in split(str, "\n") do
		local k, v = strmatch(line, "^([^:]+):%s*(.*)")
		if k then
			headers[k] = v
		end
	end
	return headers
end

local function load_catalog(filename)
	local f, data, err

	local function bail(msg)
		warn(msg..(err and ": " or "")..(err or ""))
		return nil
	end

	f, err = io.open(filename, "rb")
	if not f then
		return --bail("failed to open catalog")
	end

	data, err = f:read("*a")

	f:close()

	if not data then
		return bail("failed to read catalog")
	end

	data, err = parse_po(data)
	if not data then
		return bail("failed to parse catalog")
	end

	err = nil
	local hdrs = data[""]
	if not (hdrs and hdrs[0]) then
		return bail("catalog has no headers")
	end

	hdrs = parse_headers(hdrs[0])

	local pf = hdrs["Plural-Forms"]
	if not pf then
		-- XXX: Is this right? Gettext assumes this if header not present.
		pf = "nplurals=2; plural=n != 1"
	end

	data.plural_index, err = compile_plural_forms(pf)
	if not data.plural_index then
		return bail("failed to compile plural forms")
	end

	--warn("loaded: "..filename)

	return data
end

function M.load_catalogs(path)
	detect_languages()

	local cats = { }
	for _, lang in ipairs(langs) do
		local cat = load_catalog(path.."/"..lang..".po")
		if cat then
			cats[#cats+1] = cat
		end
	end

	return cats
end

return M
