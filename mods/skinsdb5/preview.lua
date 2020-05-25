-- stohlen from https://github.com/GreenXenith/skinsdb/blob/master/skin_meta_api.lua
function skinsdb5.get_preview(texture, format)
	local player_skin = "("..texture..")"
	local skin = ""

	-- Consistent on both sizes:
	--Chest
	skin = skin .. "([combine:16x32:-16,-12=" .. player_skin .. "^[mask:skindb_mask_chest.png)^"
	--Head
	skin = skin .. "([combine:16x32:-4,-8=" .. player_skin .. "^[mask:skindb_mask_head.png)^"
	--Hat
	skin = skin .. "([combine:16x32:-36,-8=" .. player_skin .. "^[mask:skindb_mask_head.png)^"
	--Right Arm
	skin = skin .. "([combine:16x32:-44,-12=" .. player_skin .. "^[mask:skindb_mask_rarm.png)^"
	--Right Leg
	skin = skin .. "([combine:16x32:0,0=" .. player_skin .. "^[mask:skindb_mask_rleg.png)^"

	-- 64x skins have non-mirrored arms and legs
	local left_arm
	local left_leg

	if format == "1.8" then
		left_arm = "([combine:16x32:-24,-44=" .. player_skin .. "^[mask:(skindb_mask_rarm.png^[transformFX))^"
		left_leg = "([combine:16x32:-12,-32=" .. player_skin .. "^[mask:(skindb_mask_rleg.png^[transformFX))^"
	else
		left_arm = "([combine:16x32:-44,-12=" .. player_skin .. "^[mask:skindb_mask_rarm.png^[transformFX)^"
		left_leg = "([combine:16x32:0,0=" .. player_skin .. "^[mask:skindb_mask_rleg.png^[transformFX)^"
	end

	-- Left Arm
	skin = skin .. left_arm
	--Left Leg
	skin = skin .. left_leg

	-- Add overlays for 64x skins. these wont appear if skin is 32x because it will be cropped out
	--Chest Overlay
	skin = skin .. "([combine:16x32:-16,-28=" .. player_skin .. "^[mask:skindb_mask_chest.png)^"
	--Right Arm Overlay
	skin = skin .. "([combine:16x32:-44,-28=" .. player_skin .. "^[mask:skindb_mask_rarm.png)^"
	--Right Leg Overlay
	skin = skin .. "([combine:16x32:0,-16=" .. player_skin .. "^[mask:skindb_mask_rleg.png)^"
	--Left Arm Overlay
	skin = skin .. "([combine:16x32:-40,-44=" .. player_skin .. "^[mask:(skindb_mask_rarm.png^[transformFX))^"
	--Left Leg Overlay
	skin = skin .. "([combine:16x32:4,-32=" .. player_skin .. "^[mask:(skindb_mask_rleg.png^[transformFX))"

	-- Full Preview
	skin = "(((" .. skin .. ")^[resize:64x128)^[mask:skindb_transform.png)"
	return minetest.formspec_escape(skin)
end

player_api.register_on_skin_change(function(player, model_name, skin_name)
	local skin = player_api.registered_skins[skin_name]
	if not skin.preview then
		local texture = skin.texture or (skin.textures and skin.textures[1])
		if texture then
			skin.preview = skinsdb5.get_preview(texture, skin.format)
		end
	end
end)
