local function skins_sort(skinslist)
	table.sort(skinslist, function(a,b)
		local a_sortid = a.sort_id or ""
		local b_sortid = b.sort_id or ""
		if a_sortid ~= b_sortid then
			return a_sortid < b_sortid
		else
			return tostring(a.description or a.name or "") < tostring(b.description or b.name or "")
		end
	 end)
end

-- Get skinlist for player. If no player given, public skins only selected
function skinsdb5.get_skinlist_for_player(playername)
	local skinslist = {}
	for _, skin in pairs(player_api.registered_skins) do
		if skin.in_inventory_list ~= false and
				(not skin.playername or (playername and skin.playername:lower() == playername:lower())) then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end

-- Get skinlist selected by metadata
function skinsdb5.get_skinlist_with_meta(key, value)
	assert(key, "key parameter for skinsdb5.get_skinlist_with_meta() missed")
	local skinslist = {}
	for _, skin in pairs(player_api.registered_skins) do
		if skin[key] == value then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end
