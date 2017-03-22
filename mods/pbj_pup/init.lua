
--[[

  Minetest's official Peanut Butter & Jelly Pup mod

]]--

local enable = minetest.setting_getbool("pbj_pup_enable")
if enable == false then
	return
end

local function howl(ttl, player)
	if not player then
		return
	end
	ttl = ttl - 15
	if ttl < 0 then
		return
	end

	minetest.sound_play("pbj_pup_howl", {object = player, loop = false})
	minetest.do_item_eat(5, nil, ItemStack("pbj_pup:pbj_pup"), player, nil)

	minetest.after(15, howl, ttl, player)
end

--
-- nodes
--
minetest.register_node("pbj_pup:pbj_pup", {
	description = "PB&J Pup",
	tiles = {
		"pbj_pup_sides.png",
		"pbj_pup_jelly.png",
		"pbj_pup_sides.png",
		"pbj_pup_sides.png",
		"pbj_pup_back.png",
		"pbj_pup_front.png"
	},
	paramtype = "light",
	light_source = default.LIGHT_MAX,
	paramtype2 = "facedir",
	groups = {cracky = 2},
	is_ground_content = false,
	legacy_facedir_simple = true,
	sounds = default.node_sound_defaults(),
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		howl(300, user)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_node("pbj_pup:pbj_pup_candies", {
	description = "PB&J Pup Candies",
	tiles = {{
		name = "pbj_pup_candies_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1.6
		}
	}},
	paramtype = "light",
	light_source = default.LIGHT_MAX,
	paramtype2 = "facedir",
	groups = {cracky = 2},
	is_ground_content = false,
	stack_max = 5,
	sounds = default.node_sound_defaults(),
	on_use = function(itemstack, user, pointed_thing)
		minetest.do_item_eat(5, nil, itemstack, user, pointed_thing)
		minetest.sound_play("pbj_pup_barks", {object = user, loop = false})
		itemstack:take_item()
		return itemstack
	end,
})

--
-- mapgen
--
local gen = minetest.setting_getbool("pbj_pup_generate")
if gen == nil or gen then
	local function place(pos, facedir, length)
		if facedir > 3 then
			facedir = 0
		end
		local tailvec = minetest.facedir_to_dir(facedir)
		local p = {x = pos.x, y = pos.y, z = pos.z}
		minetest.set_node(p, {name = "pbj_pup:pbj_pup", param2 = facedir})
		for i = 1, length do
			p.x = p.x + tailvec.x
			p.z = p.z + tailvec.z
			minetest.set_node(p, {name = "pbj_pup:pbj_pup_candies", param2 = facedir})
		end
	end

	local function generate(minp, maxp, seed)
		local height_min = -31000
		local height_max = -32
		if maxp.y < height_min or minp.y > height_max then
			return
		end
		local y_min = math.max(minp.y, height_min)
		local y_max = math.min(maxp.y, height_max)
		local volume = (maxp.x - minp.x + 1) * (y_max - y_min + 1) * (maxp.z - minp.z + 1)
		local pr = PseudoRandom(seed + 9324342)
		local max_num = math.floor(volume / (16 * 16 * 16))
		for i = 1, max_num do
			if pr:next(0, 1000) == 0 then
				local x0 = pr:next(minp.x, maxp.x)
				local y0 = pr:next(minp.y, maxp.y)
				local z0 = pr:next(minp.z, maxp.z)
				local p0 = {x = x0, y = y0, z = z0}
				place(p0, pr:next(0, 3), pr:next(3, 15))
			end
		end
	end

	minetest.register_on_generated(generate)
end
--
-- compat
--

if minetest.setting_getbool("pbj_pup_alias_nyancat") then
	minetest.register_alias("default:nyancat", "pbj_pup:pbj_pup")
	minetest.register_alias("default:nyancat_rainbow","pbj_pup:pbj_pup_candies")
	minetest.register_alias("nyancat", "pbj_pup:pbj_pup")
	minetest.register_alias("nyancat_rainbow", "pbj_pup:pbj_pup_candies")
	minetest.register_alias("nyancat:nyancat", "pbj_pup:pbj_pup")
	minetest.register_alias("nyancat:nyancat_rainbow", "pbj_pup:pbj_pup_candies")
end
