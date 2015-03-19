-- minetest_game/mods/i18n/init.lua

i18n = {}
i18n.hash = {}

-- Following 4 lines coming from https://github.com/kaeza/minetest-intllib
-- (released as WTFPL)
local LANG = minetest.setting_get("language")
if not (LANG and (LANG ~= "")) then LANG = os.getenv("LANG") end
if not (LANG and (LANG ~= "")) then LANG = "en" end
i18n.LANG = LANG:sub(1, 2)

function i18n.gettext(text)
	return i18n.hash[text] or text
end

_=assert(i18n.gettext)

--
-- Original load_mo_file() function coming from :
-- 	http://lua-users.org/lists/lua-l/2010-04/msg00005.html
-- (released as public domain)
--
-- Function sligthly modified, original comment is below.
--
-----------------------------------------------------------
-- load an mo file and return a lua table
-- @param mo_file name of the file to load
-- @return table on success
-- @return nil,string on failure
-- @copyright J.Jorgen von Bargen
-- @licence I provide this as public domain
-- @see http://www.gnu.org/software/hello/manual/gettext/MO-Files.html
-----------------------------------------------------------

function i18n.load_mo_file(modpath, modname)
	local mo_file = modpath.."/i18n/"..i18n.LANG.."/"..modname..".mo"

	--------------------------------
	-- open file and read data
	--------------------------------
	local fd,err=io.open(mo_file,"rb")
	if not fd then return nil,err end
	local mo_data=fd:read("*all")
	fd:close()

	--------------------------------
	-- precache some functions
	--------------------------------
	local byte=string.byte
	local sub=string.sub

	--------------------------------
	-- check format
	--------------------------------
	local peek_long --localize
	local magic=sub(mo_data,1,4)
	-- intel magic 0xde120495
	if magic=="\222\018\004\149" then
		peek_long=function(offs)
			local a,b,c,d=byte(mo_data,offs+1,offs+4)
			return ((d*256+c)*256+b)*256+a
		end
	-- motorola magic = 0x950412de
	elseif magic=="\149\004\018\222" then
		peek_long=function(offs)
			local a,b,c,d=byte(mo_data,offs+1,offs+4)
			return ((a*256+b)*256+c)*256+d
		end
	else
		return nil,"no valid mo-file"
	end

	--------------------------------
	-- version
	--------------------------------
	local V=peek_long(4)
	if V~=0 then
		return nul,"unsupported version"
	end

	------------------------------
	-- get number of offsets of table
	------------------------------
	local N,O,T=peek_long(8),peek_long(12),peek_long(16)
	------------------------------
	-- traverse and get strings
	------------------------------
	local hash={}
	for nstr=1,N do
		local ol,oo=peek_long(O),peek_long(O+4) O=O+8
		local tl,to=peek_long(T),peek_long(T+4) T=T+8
		hash[sub(mo_data,oo+1,oo+ol)]=sub(mo_data,to+1,to+tl)
	end
	i18n.hash = hash
end

