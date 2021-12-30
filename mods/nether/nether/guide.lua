local cube = minetest.inventorycube

-- the content of the guide
local guide_infos = {
	{
		description = "Mushrooms",
		{"text", "Nether mushrooms can be found on the nether's ground and\n"..
			"on netherrack soil, it can be dug by hand."},
		{"image", {1, 1, "riesenpilz_nether_shroom_side.png"}},
		{"y", 0.2},
		{"text", "If you drop it without holding the fast key, you can split it into its stem and head:"},
		{"image", {1, 1, "nether_shroom_top.png", 1}},
		{"image", {1, 1, "nether_shroom_stem.png"}},
		{"y", 0.1},
		{"text", "You can get more mushrooms by using a netherrack soil:\n"..
			"1. search a dark place and, if necessary, place netherrack with air about it\n"..
			"2. right click with cooked blood onto the netherrack to make it soiled\n"..
			"3. right click onto the netherrack soil with a nether mushroom head to add some spores\n"..
			"4. dig the mushroom which grew after some time to make place for another one"},
		{"image", {1, 1, "riesenpilz_nether_shroom_side.png", 6, 0.12}},
		{"y", 1},
		{"image", {1, 1, "nether_netherrack.png^nether_netherrack_soil.png", 1.8}},
		{"image", {1, 1, "nether_hotbed.png", 1.3, -0.4}},
		{"image", {1, 1, "nether_netherrack.png^nether_netherrack_soil.png", 3.6}},
		{"image", {1, 1, "nether_shroom_top.png", 3.1, -0.5}},
		{"image", {1, 1, "nether_netherrack.png^nether_netherrack_soil.png", 6}},
		{"image", {1, 1, "nether_netherrack.png"}},
	},
	{
		description = "Tools",
		{"text", "You can craft 5 kinds of tools in the nether,\n"..
			"which (except the mushroom pick) require sticks to be crafted:"},
		{"image", {1, 1, "nether_pick_mushroom.png"}},
		{"y", 0.1},
		{"text", "strength : 1\n"..
			"The mushroom pick needs mushroom stems and heads to be crafted."},
		{"image", {1, 1, "nether_pick_wood.png"}},
		{"y", 0.1},
		{"text", "strength : 2\n"..
			"The nether wood pick can be crafted with cooked nether blood wood."},
		{"image", {1, 1, "nether_axe_netherrack.png", 1.5}},
		{"image", {1, 1, "nether_shovel_netherrack.png", 3}},
		{"image", {1, 1, "nether_sword_netherrack.png", 4.5}},
		{"image", {1, 1, "nether_pick_netherrack.png"}},
		{"y", 0.1},
		{"text", "strength : 3\n"..
			"The red netherrack tools can be crafted with usual netherrack."},
		{"image", {1, 1, "nether_axe_netherrack_blue.png", 1.5}},
		{"image", {1, 1, "nether_shovel_netherrack_blue.png", 3}},
		{"image", {1, 1, "nether_sword_netherrack_blue.png", 4.5}},
		{"image", {1, 1, "nether_pick_netherrack_blue.png"}},
		{"y", 0.1},
		{"text", "strength : 3\n"..
			"The blue netherrack tools can be crafted with blue netherrack."},
		{"image", {1, 1, "nether_axe_white.png", 1.5}},
		{"image", {1, 1, "nether_shovel_white.png", 3}},
		{"image", {1, 1, "nether_sword_white.png", 4.5}},
		{"image", {1, 1, "nether_pick_white.png"}},
		{"y", 0.1},
		{"text", "strength : 3\n"..
			"The siwtonic tools can be crafted with the siwtonic ore."},
	},
	{
		description = "Blood structures",
		{"text", "You can find blood structures on the ground and\n"..
			"dig their nodes even with the bare hand."},
		{"y", 0.5},
		{"text", "One contains 4 kinds of blocks :"},
		{"image", {1, 1, cube("nether_blood.png"), 1}},
		{"image", {1, 1,
			cube("nether_blood_top.png",
				"nether_blood.png^nether_blood_side.png",
				"nether_blood.png^nether_blood_side.png"),
			2}},
		{"image", {1, 1, "nether_fruit.png", 3}},
		{"image", {1, 1, cube("nether_blood_stem_top.png",
			"nether_blood_stem.png", "nether_blood_stem.png")}},
		{"y", 0.1},
		{"text", "Blood stem, blood, blood head and nether fruit"},
		{"y", 0.1},
		{"text", "You can craft 4 blood wood with the stem :"},
		{"image", {1, 1, cube("nether_wood.png")}},
		{"y", 0.1},
		{"text", "The 4 blood nodes can be cooked and, except\n"..
			"blood wood, their blood can be extracted."},
	},
	{
		description = "Fruits",
		{"text", "You can find the nether fruits on blood structures\n"..
			"and dig them even with the bare hand."},
		{"image", {1, 1, "nether_fruit.png"}},
		{"text", "Eating it will make you lose life but\n"..
			"it might feed you and give you blood :"},
		{"image", {1, 1, "nether_blood_extracted.png"}},
		{"y", 0.2},
		{"text", "If you eat it at the right place inside a portal,\n"..
			"you will teleport instead of getting blood."},
		{"y", 0.2},
		{"text", "If you drop it without holding the fast key,\n"..
			"you can split it into its fruit and leaf:"},
		{"image", {1, 1, "nether_fruit_leaf.png", 1}},
		{"image", {1, 1, "nether_fruit_no_leaf.png"}},
		{"y", 0.2},
		{"text", "Craft a fruit leave block out of 9 fruit leaves\n"..
			"The fruit can be used to craft a nether pearl."},
		{"image", {1, 1, cube("nether_fruit_leaves.png")}},
		{"y", 0.2},
		{"text", "A fruit leaves block"},
	},
	{
		description = "Cooking",
		{"text", "To get a furnace you need to dig at least 8 netherrack bricks.\n"..
			"They can be found at pyramid like constructions and require at least\n"..
			"a strength 1 nether pick to be dug.\n"..
			"To craft the furnace, use the netherrack bricks like cobble:"},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 0.5}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 1}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png")}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 1}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png")}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 0.5}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 1}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png")}},
		{"y", 0.2},
		{"text", "To begin cooking stuff, you can use a mushroom or fruit.\n"..
			"After that it's recommended to use cooked blood nodes."},
		{"y", 0.1},
		{"text", "Some nether items can be cooked:"},
		{"image", {1, 1, cube("nether_blood_stem_top_cooked.png",
			"nether_blood_stem_cooked.png", "nether_blood_stem_cooked.png"),
			0.35}},
		{"image", {1, 1, cube("nether_blood_cooked.png"), 1.6}},
		{"image", {1, 1,
			cube("nether_blood_top_cooked.png",
				"nether_blood_cooked.png^nether_blood_side_cooked.png",
				"nether_blood_cooked.png^nether_blood_side_cooked.png"),
			2.9}},
		{"image", {1, 1, cube("nether_wood_cooked.png"), 4.3}},
		{"y", 1.2},
		{"text", "Some cooked blood stem, cooked blood,\n"..
			"cooked blood head and cooked blood wood,"},
		{"image", {1, 1, "nether_hotbed.png", 0.3}},
		{"image", {1, 1, "nether_pearl.png", 2}},
		{"y", 1.2},
		{"text", "Some cooked extracted blood and a nether pearl"},
	},
	{
		description = "Extractors",
		{"text", "Here you can find out information about the nether extractor."},
		{"y", 0.2},
		{"text", "Here you can see its craft recipe:"},
		{"image", {0.5, 0.5, cube("nether_blood_top_cooked.png",
			"nether_blood_cooked.png^nether_blood_side_cooked.png",
			"nether_blood_cooked.png^nether_blood_side_cooked.png"), 0.5}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 1}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png")}},
		{"image", {0.5, 0.5, cube("nether_blood_extractor.png"), 2.5}},
		{"image", {0.5, 0.5, "nether_shroom_stem.png", 0.5}},
		{"image", {0.5, 0.5, cube("nether_blood_cooked.png"), 1}},
		{"image", {0.5, 0.5, cube("nether_blood_cooked.png")}},
		{"image", {0.5, 0.5, cube("nether_blood_stem_top_cooked.png",
			"nether_blood_stem_cooked.png", "nether_blood_stem_cooked.png"),
			0.5}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png"), 1}},
		{"image", {0.5, 0.5, cube("nether_netherrack_brick.png")}},
		{"y", 0.2},
		{"text", "Extract blood from the blood nodes you get from the blood structures.\n"..
			"You can also get blood with a nether fruit."},
		{"y", 0.2},
		{"text", "So you can use it:\n"..
			"1. place it somewhere\n"..
			"2. place blood blocks next to it (4 or less)\n"..
			"3. right click with extracted blood onto it to power it\n"..
			"4. take the new extracted blood and dig the extracted nodes"},
		{"y", 0.2},
		{"text", "Example (view from the top):"},
		{"y", 0.88},
		{"image", {1, 1, "nether_blood_stem_top.png", 0.82, -0.88}},
		{"image", {1, 1, "nether_blood.png", 1.63}},
		{"image", {1, 1, "nether_blood_extractor.png", 0.82}},
		{"image", {1, 1, "nether_blood_stem_top_empty.png", 3.82, -0.88}},
		{"image", {1, 1, "nether_blood_empty.png", 4.63}},
		{"image", {1, 1, "nether_blood_empty.png", 3.001}},
		{"image", {1, 1, "nether_blood_extractor.png", 3.82}},
		{"image", {1, 1, "nether_blood.png"}},
		{"image", {1, 1, "nether_blood.png", 0.82, -0.12}},
		{"image", {1, 1, "nether_blood_empty.png", 3.82, -0.12}},
		{"y", 1.2},
		{"text", "The empty blood stem can be crafted into empty nether wood,\n"..
			"which can be crafted into nether sticks."},
	},
	{
		description = "Ores",
		{"text", "You can find 5 types of ores:"},
		{"image", {1, 1, cube("nether_netherrack_black.png"), 4}},
		{"image", {1, 1, cube("nether_netherrack.png")}},
		{"y", 0.2},
		{"text", "The red netherrack is generated like stone.\n"..
			"The black netherrack is generated like gravel.\n"..
			"Both require at least a strength 2 nether pick to be dug."},
		{"image", {1, 1, cube("nether_white.png"), 4}},
		{"image", {1, 1, cube("nether_netherrack_blue.png")}},
		{"y", 0.2},
		{"text", "The blue netherrack is generated like diamond ore.\n"..
			"The siwtonic ore is generated like mese blocks.\n"..
			"Both require at least a strength 3 nether pick to be dug."},
		{"image", {1, 1, cube("nether_netherrack_tiled.png"), 4}},
		{"image", {1, 1, cube("glow_stone.png")}},
		{"y", 0.2},
		{"text", "Glow stone can be used for lighting.\n"..
			"Tiled netherrack is generated like coal ore.\n"..
			"Glow stone requires at least a strength 1 pick to be dug.\n"..
			"Dig tiled netherrack with at least a level 2 pickaxe."},
	},
	{
		description = "Vines",
		{"text", "Feed nether vines with blood.\n"..
			"Dig them with anything."},
		{"image", {1, 1, "nether_vine.png"}},
		{"y", 0.2},
		{"text", "Grow nether child by placing\n"..
			"placing it to a dark place onto a\n"..
			"blood structure head node."},
		{"image", {1, 1, "nether_sapling.png"}},
		{"y", -0.10},
		{"image", {1, 1, "nether_blood.png^nether_blood_side.png"}},
	},
	{
		description = "Pearls",
		{"text", "The nether pearl can be used to teleport by throwing it.\n"..
			"Here is how to get one :"},
		{"y", 0.2},
		{"text", "First of all craft 2 mushroom heads and 1 nether fruit\n"..
			"without leaf together :"},
		{"image", {1, 1, "nether_shroom_top.png"}},
		{"image", {1, 1, "nether_fim.png", 3}},
		{"image", {1, 1, "nether_fruit_no_leaf.png"}},
		{"image", {1, 1, "nether_shroom_top.png"}},
		{"y", 0.2},
		{"text", "Put the result into the furnace\n"..
			"to cook it into a nether pearl :"},
		{"image", {1, 1, "nether_pearl.png"}},
	},
	{
		description = "Bricks",
		{"text", "Craft bricks out of red,\n"..
			"black and blue netherrack."},
		{"image", {1, 1, cube("nether_netherrack_brick_black.png"), 1}},
		{"image", {1, 1, cube("nether_netherrack_brick_blue.png"), 2}},
		{"image", {1, 1, cube("nether_netherrack_brick.png")}},
		{"y", 0.4},
		{"text", "Dig them with at least a level 1 pickaxe."},
		{"y", 0.2},
	},
	{
		description = "Portals",
		{"text", "Here you can find out how to built the nether portal."},
		{"y", 0.3},
		{"text", "A nether portal requires following nodes:"},
		{"y", 0.05},
		{"text", "25 empty nether wooden planks\n"..
			"16 black netherrack\n"..
			"12 blue netherrack bricks\n"..
			"8 red netherrack\n"..
			"8 cooked nether blood\n"..
			"4 nether fruits\n"..
			"2 siwtonic blocks"},
		{"y", 0.2},
		{"text", "It should look approximately like this one:"},
		{"image", {5.625, 6, "nether_teleporter.png", 0, -1.5}},
		{"y", 5.5},
		{"text", "Activate it by standing in the middle,\n"..
			"on the siwtonic block and eating a nether fruit.\n"..
			"Take enough stuff with you to build a portal when you'll come back."},
	},
	{
		description = "Forests",
		{"text", "The nether forest is generated in caves,\n"..
			"above the usual nether."},
		{"y", 0.2},
		{"text", "There you can find some plants:"},
		{"image", {1, 1, "nether_grass_middle.png", 1}},
		{"image", {1, 1, "nether_grass_big.png", 2}},
		{"image", {1, 1, "nether_grass_small.png"}},
		{"y", 0.2},
		{"text", "Use the nether forest grass to get paper.\n"..
			"Craft paper out of the dried grass."},
		{"image", {1, 1, cube("nether_tree_top.png", "nether_tree.png", "nether_tree.png")}},
		{"y", 0.2},
		{"text", "Nether trunks can be found at nether trees.\n"..
			"Craft nether wood out of nether trunk."},
		{"image", {1, 1, "nether_glowflower.png"}},
		{"y", 0.2},
		{"text", "Use it for lighting and decoration."},
	},
}

-- the size of guide pages
local guide_size = {x=40, y=10, cx=0.2, cy=0.2}

-- informations about settings and ...
local formspec_offset = {x=0.25, y=0.50}
local font_size
if minetest.is_singleplayer() then
	font_size = tonumber(minetest.settings:get("font_size")) or 13
else
	font_size = 13
end
guide_size.fx = math.floor((40*(guide_size.cx+formspec_offset.x))*font_size)
guide_size.fy = font_size/40

-- the default guide formspecs
local guide_forms = {
	contents = "size[3.6,"..(#guide_infos)-2 ..";]label["..guide_size.cx+0.7 ..","..guide_size.cy+0.2 ..";Contents:]",
}

-- change the infos to formspecs
for n,data in ipairs(guide_infos) do
	local form = ""
	local y = 0
	local x = guide_size.cx
	for _,i in ipairs(data) do
		local typ, content = unpack(i)
		if typ == "y" then
			y = y+content
		elseif typ == "x" then
			x = math.max(x, content)
		elseif typ == "text" then
			local tab = minetest.wrap_text(content, guide_size.fx, true)
			local l = guide_size.cx
			for _,str in ipairs(tab) do
				form = form.."label["..guide_size.cx ..","..guide_size.cy+y..";"..str.."]"
				y = y+guide_size.fy
				l = math.max(l, #str)
			end
			x = math.max(x, l/font_size)
		elseif typ == "image" then
			local w, h, texture_name, px, py = unpack(content)
			if not px then
				form = form.."image["..guide_size.cx..","..guide_size.cy+y+h*0.3 ..";"..w..","..h..";"..texture_name.."]"
				y = y+h
			else
				px = guide_size.cx+px
				py = py or 0
				form = form.."image["..px..","..
					guide_size.cy+y+h*0.3+py ..";"..w..","..h..";"..texture_name.."]"
				x = math.max(x, px+w)
			end
		end
	end
	form = "size["..x*1.8 ..","..y+1 ..";]"..form.."button["..x/2-0.5 ..","..y ..";1,2;quit;Back]"
	guide_forms[n] = {data.description, form}
end

local desc_tab = {}
for n,i in ipairs(guide_forms) do
	desc_tab[i[1]] = n
end

-- creates contents formspec
for y,i in ipairs(guide_forms) do
	local desc = i[1]
	local s = #desc * 1.3 / font_size + 1.5
	guide_forms.contents = guide_forms.contents ..
		"button[" .. guide_size.cx * 12 / s - 0.5 .. "," ..
		guide_size.cy + y / 1.3 .. ";" .. s .. ",1;name;" .. desc .. "]"
end

-- shows the contents of the formspec
local function show_guide(pname)
	minetest.show_formspec(pname, "nether_guide_contents", guide_forms["contents"])
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "nether_guide_contents" then
		local fname = fields.name
		local pname = player:get_player_name()
		if fname
		and pname then
			minetest.show_formspec(pname, "nether_guide", guide_forms[desc_tab[fname]][2])
		end
	elseif formname == "nether_guide" then
		local fname = fields.quit
		local pname = player:get_player_name()
		if fname
		and pname then
			minetest.show_formspec(pname, "nether_guide_contents", guide_forms["contents"])
		end
	end
end)

minetest.register_chatcommand("nether_help", {
	params = "",
	description = "Shows a nether guide",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			minetest.chat_send_player(name, "Something went wrong.")
			return false
		end
		if player:get_pos().y > nether.start then
			minetest.chat_send_player(name,
				"Usually you don't neet this guide here. " ..
				"You can view it in the nether.")
			return false
		end
		minetest.chat_send_player(name, "Showing guide...")
		show_guide(name)
		return true
	end
})
