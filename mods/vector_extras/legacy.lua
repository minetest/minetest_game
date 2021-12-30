local funcs = vector_extras_functions

function funcs.scalar(v1, v2)
	minetest.log("deprecated", "[vector_extras] vector.scalar is " ..
		"deprecated, use vector.dot instead.")
	return vector.dot(v1, v2)
end

function funcs.get_data_from_pos(tab, z,y,x)
	minetest.log("deprecated", "[vector_extras] get_data_from_pos is " ..
		"deprecated, use the minetest pos hash function instead.")
	local data = tab[z]
	if data then
		data = data[y]
		if data then
			return data[x]
		end
	end
end

function funcs.set_data_to_pos(tab, z,y,x, data)
	minetest.log("deprecated", "[vector_extras] set_data_to_pos is " ..
		"deprecated, use the minetest pos hash function instead.")
	if tab[z] then
		if tab[z][y] then
			tab[z][y][x] = data
			return
		end
		tab[z][y] = {[x] = data}
		return
	end
	tab[z] = {[y] = {[x] = data}}
end

function funcs.set_data_to_pos_optional(tab, z,y,x, data)
	minetest.log("deprecated", "[vector_extras] set_data_to_pos_optional is " ..
		"deprecated, use the minetest pos hash function instead.")
	if vector.get_data_from_pos(tab, z,y,x) ~= nil then
		return
	end
	funcs.set_data_to_pos(tab, z,y,x, data)
end

function funcs.remove_data_from_pos(tab, z,y,x)
	minetest.log("deprecated", "[vector_extras] remove_data_from_pos is " ..
		"deprecated, use the minetest pos hash function instead.")
	if vector.get_data_from_pos(tab, z,y,x) == nil then
		return
	end
	tab[z][y][x] = nil
	if not next(tab[z][y]) then
		tab[z][y] = nil
	end
	if not next(tab[z]) then
		tab[z] = nil
	end
end

function funcs.get_data_pos_table(tab)
	minetest.log("deprecated", "[vector_extras] get_data_pos_table likely " ..
		"is deprecated, use the minetest pos hash function instead.")
	local t,n = {},1
	local minz, miny, minx, maxz, maxy, maxx
	for z,yxs in pairs(tab) do
		if not minz then
			minz = z
			maxz = z
		else
			minz = math.min(minz, z)
			maxz = math.max(maxz, z)
		end
		for y,xs in pairs(yxs) do
			if not miny then
				miny = y
				maxy = y
			else
				miny = math.min(miny, y)
				maxy = math.max(maxy, y)
			end
			for x,v in pairs(xs) do
				if not minx then
					minx = x
					maxx = x
				else
					minx = math.min(minx, x)
					maxx = math.max(maxx, x)
				end
				t[n] = {z,y,x, v}
				n = n+1
			end
		end
	end
	return t, {x=minx, y=miny, z=minz}, {x=maxx, y=maxy, z=maxz}, n-1
end
