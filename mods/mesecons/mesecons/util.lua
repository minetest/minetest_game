function mesecon:move_node(pos, newpos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos):to_table()
	minetest.remove_node(pos)
	minetest.add_node(newpos, node)
	minetest.get_meta(pos):from_table(meta)
end

--[[ new functions:
mesecon:flattenrules(allrules)
mesecon:rule2bit(findrule, allrules)
mesecon:rule2meta(findrule, allrules)
dec2bin(n)
mesecon:getstate(nodename, states)
mesecon:getbinstate(nodename, states)
mesecon:get_bit(binary, bit)
mesecon:set_bit(binary, bit, value)
mesecon:invertRule(r)
--]]

function mesecon:flattenrules(allrules)
--[[
	{
		{
			{xyz},
			{xyz},
		},
		{
			{xyz},
			{xyz},
		},
	}
--]]
	if allrules[1] and
	   allrules[1].x then
		return allrules
	end

	local shallowrules = {}
	for _, metarule in ipairs( allrules) do
	for _,     rule in ipairs(metarule ) do
		table.insert(shallowrules, rule)
	end
	end
	return shallowrules
--[[
	{
		{xyz},
		{xyz},
		{xyz},
		{xyz},
	}
--]]
end

function mesecon:rule2bit(findrule, allrules)
	--get the bit of the metarule the rule is in, or bit 1
	if (allrules[1] and
	    allrules[1].x) or
	    not findrule then
		return 1
	end
	for m,metarule in ipairs( allrules) do
	for _,    rule in ipairs(metarule ) do
		if mesecon:cmpPos(findrule, rule) and mesecon:cmpSpecial(findrule, rule) then
			return m
		end
	end
	end
end

function mesecon:rule2metaindex(findrule, allrules)
	--get the metarule the rule is in, or allrules

	if allrules[1].x then
		return nil
	end

	if not(findrule) then
		return mesecon:flattenrules(allrules)
	end

	for m, metarule in ipairs( allrules) do
	for _,     rule in ipairs(metarule ) do
		if mesecon:cmpPos(findrule, rule) and mesecon:cmpSpecial(findrule, rule) then
			return m
		end
	end
	end
end

function mesecon:rule2meta(findrule, allrules)
	local index = mesecon:rule2metaindex(findrule, allrules)
	if index == nil then
		if allrules[1].x then
			return allrules
		else
			return {}
		end
	end
	return allrules[index]
end

if convert_base then
	print(
		"base2dec is tonumber(num,base1)\n"..
		"commonlib needs dec2base(num,base2)\n"..
		"and it needs base2base(num,base1,base2),\n"..
		"which is dec2base(tonumber(num,base1),base2)"
	)
else
	function dec2bin(n)
		local x, y = math.floor(n / 2), n % 2
		if (n > 1) then
			return dec2bin(x)..y
		else
			return ""..y
		end
	end
end

function mesecon:getstate(nodename, states)
	for state, name in ipairs(states) do
		if name == nodename then
			return state
		end
	end
	error(nodename.." doesn't mention itself in "..dump(states))
end

function mesecon:getbinstate(nodename, states)
	return dec2bin(mesecon:getstate(nodename, states)-1)
end

function mesecon:get_bit(binary,bit)
	bit = bit or 1
	local c = binary:len()-(bit-1)
	return binary:sub(c,c) == "1"
end

function mesecon:set_bit(binary,bit,value)
	if value == "1" then
		if not mesecon:get_bit(binary,bit) then
			return dec2bin(tonumber(binary,2)+math.pow(2,bit-1))
		end
	elseif value == "0" then
		if mesecon:get_bit(binary,bit) then
			return dec2bin(tonumber(binary,2)-math.pow(2,bit-1))
		end
	end
	return binary
	
end

function mesecon:invertRule(r)
	return {x = -r.x, y = -r.y, z = -r.z, sx = r.sx, sy = r.sy, sz = r.sz}
end

function mesecon:addPosRule(p, r)
	return {x = p.x + r.x, y = p.y + r.y, z = p.z + r.z}
end

function mesecon:cmpPos(p1, p2)
	return (p1.x == p2.x and p1.y == p2.y and p1.z == p2.z)
end

function mesecon:cmpSpecial(r1, r2)
	return (r1.sx == r2.sx and r1.sy == r2.sy and r1.sz == r2.sz)
end

function mesecon:tablecopy(table) -- deep table copy
	if type(table) ~= "table" then return table end -- no need to copy
	local newtable = {}

	for idx, item in pairs(table) do
		if type(item) == "table" then
			newtable[idx] = mesecon:tablecopy(item)
		else
			newtable[idx] = item
		end
	end

	return newtable
end

function mesecon:cmpAny(t1, t2)
	if type(t1) ~= type(t2) then return false end
	if type(t1) ~= "table" and type(t2) ~= "table" then return t1 == t2 end

	for i, e in pairs(t1) do
		if not mesecon:cmpAny(e, t2[i]) then return false end
	end

	return true
end
