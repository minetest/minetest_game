-- Disable by mapgen, setting or if 'static_spawnpoint' is set

local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name == "v6" or mg_name == "singlenode" or
		minetest.settings:get("static_spawnpoint") or
		minetest.settings:get_bool("engine_spawn") then
	return
end


-- On new player spawn and player respawn

-- Search for spawn position once per server session. If successful, store
-- position and reposition players, otherwise leave them at engine spawn
-- position.

-- Search parameters
local pos = {x = 0, y = 8, z = 0}
local radius = 4096
local spacing = 64
local biome_ids = {
	minetest.get_biome_id("taiga"),
	minetest.get_biome_id("coniferous_forest"),
	minetest.get_biome_id("deciduous_forest"),
	minetest.get_biome_id("grassland"),
	minetest.get_biome_id("savanna"),
}

local spawn_pos = {}

local function on_spawn(player)
	if not spawn_pos.x then
		local result = spawn.search(pos, radius, spacing, biome_ids)
		if result then
			spawn_pos = result
		end
	end
	if spawn_pos.x then
		player:set_pos(spawn_pos)
	end
end

minetest.register_on_newplayer(function(player)
	on_spawn(player)
end)

local enable_bed_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_bed_respawn == nil then
	enable_bed_respawn = true
end

minetest.register_on_respawnplayer(function(player)
	-- Avoid respawn conflict with beds mod
	if beds and enable_bed_respawn and
			beds.spawn[player:get_player_name()] then
		return
	end

	on_spawn(player)
	return true
end)
