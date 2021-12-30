vector.meta = vector.meta or {}
vector.meta.nodes = {}

vector.meta.nodes_file = {
	load = function()
		local nodesfile = io.open(minetest.get_worldpath()..'/vector_nodes.txt', "r")
		if nodesfile then
			local contents = nodesfile:read('*all')
			io.close(nodesfile)
			if contents ~= nil then
				local lines = string.split(contents, "\n")
				for _,entry in ipairs(lines) do
					local name, px, py, pz, meta = unpack(string.split(entry, "°"))
					vector.meta.set_node({x=px, y=py, z=pz}, name, meta)
				end
			end
		end
	end,
	save = function() --WRITE CHANGES TO FILE
		local output = ''
		for x,ys in pairs(vector.meta.nodes) do
			for y,zs in pairs(ys) do
				for z,names in pairs(zs) do
					for name,meta in pairs(names) do
						output = name.."°"..x.."°"..y.."°"..z.."°"..dump(meta).."\n"
					end
				end
			end
		end
		local f = io.open(minetest.get_worldpath()..'/vector_nodes.txt', "w")
		f:write(output)
		io.close(f)
	end
}

local function table_empty(tab) --looks if it's an empty table
	if next(tab) == nil then
		return true
	end
	return false
end

function vector.meta.nodes_info() --returns an info string of the node table
	local tmp = "[vector] "..dump(vector.meta.nodes).."\n[vector]:\n"
	for x,a in pairs(vector.meta.nodes) do
		for y,b in pairs(a) do
			for z,c in pairs(b) do
				for name,meta in pairs(c) do
					tmp = tmp..">\t"..name.." "..x.." "..y.." "..z.." "..dump(meta).."\n"
				end
			end
		end
	end
	return tmp
end

function vector.meta.clean_node_table() --replaces {} with nil
	local again = true
	while again do
		again = false
		for x,ys in pairs(vector.meta.nodes) do
			if table_empty(ys) then
				vector.meta.nodes[x] = nil
				again = true
			else
				for y,zs in pairs(ys) do
					if table_empty(zs) then
						vector.meta.nodes[x][y] = nil
						again = true
					else
						for z,names in pairs(zs) do
							if table_empty(names) then
								vector.meta.nodes[x][y][z] = nil
								again = true
							else
								for name,meta in pairs(names) do
									if table_empty(meta)
									or meta == "" then
										vector.meta.nodes[x][y][z][name] = nil
										again = true
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function vector.meta.complete_node_table(pos, name) --neccesary because tab[1] wouldn't work if tab is not a table
	local tmp = vector.meta.nodes[pos.x]
	if not tmp then
		vector.meta.nodes[pos.x] = {}
	end
	tmp = vector.meta.nodes[pos.x][pos.y]
	if not tmp then
		vector.meta.nodes[pos.x][pos.y] = {}
	end
	tmp = vector.meta.nodes[pos.x][pos.y][pos.z]
	if not tmp then
		vector.meta.nodes[pos.x][pos.y][pos.z] = {}
	end
	tmp = vector.meta.nodes[pos.x][pos.y][pos.z][name]
	if not tmp then
		vector.meta.nodes[pos.x][pos.y][pos.z][name] = {}
	end
end

function vector.meta.get_node(pos, name)
	if not pos then
		return false
	end
	local tmp = vector.meta.nodes[pos.x]
	if not tmp
	or table_empty(tmp) then
		return false
	end
	tmp = vector.meta.nodes[pos.x][pos.y]
	if not tmp
	or table_empty(tmp) then
		return false
	end
	tmp = vector.meta.nodes[pos.x][pos.y][pos.z]
	if not tmp
	or table_empty(tmp) then
		return false
	end

	-- if name isn't mentioned, just look if there's a node
	if not name then
		return true
	end

	tmp = vector.meta.nodes[pos.x][pos.y][pos.z][name]
	if not tmp
	or table_empty(tmp) then
		return false
	end
	return tmp
end

function vector.meta.remove_node(pos)
	if not pos then
		return false
	end
	if vector.meta.get_node(pos) then
		vector.meta.nodes[pos.x][pos.y][pos.z] = nil
		local xarr = vector.meta.nodes[pos.x]
		if table_empty(xarr[pos.y]) then
			vector.meta.nodes[pos.x][pos.y] = nil
		end
		if table_empty(xarr) then
			vector.meta.nodes[pos.x] = nil
		end
	else
		print("[vector_extras] Warning: The node at "..vector.pos_to_string(pos).." wasn't stored in vector.meta.nodes.")
	end
end

function vector.meta.set_node(pos, name, meta)
	if not (name or pos) then
		return false
	end
	vector.meta.complete_node_table(pos, name)
	meta = meta or true
	vector.meta.nodes[pos.x][pos.y][pos.z][name] = meta
end

minetest.register_chatcommand('cleanvectormetatable',{
	description = 'Tidy up it.',
	params = "",
	privs = {},
	func = function(name)
		vector.meta.clean_node_table()
		local tmp = vector.meta.nodes_info()
		minetest.chat_send_player(name, tmp)
		print("[vector_extras] "..tmp)
	end
})

vector.meta.nodes_file.load()
