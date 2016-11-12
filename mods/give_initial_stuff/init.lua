local stuff_string = minetest.setting_get("initial_stuff") or
		"default:pick_steel,default:axe_steel,default:shovel_steel," ..
		"default:torch 99,default:cobble 99"

local items = {}

give_initial_stuff = {}

function give_initial_stuff.give(player)
	minetest.log("action",
			"Giving initial stuff to player " .. player:get_player_name())
	local inv = player:get_inventory()
	for _, stack in ipairs(items) do
		inv:add_item("main", stack)
	end
end

function give_initial_stuff.add(stack)
	items[#items + 1] = ItemStack(stack)
end

function give_initial_stuff.clear()
	items = {}
end

function give_initial_stuff.add_from_csv(str)
	local add_items = str:split(",")
	for _, itemname in ipairs(add_items) do
		give_initial_stuff.add(itemname)
	end
end

function give_initial_stuff.set_list(list)
	items = list
end

function give_initial_stuff.get_list()
	local copied = {}
	for _, stack in ipairs(items) do
		copied[#copied + 1] = ItemStack(stack)
	end
	return copied
end

give_initial_stuff.add_from_csv(stuff_string)
if minetest.setting_getbool("give_initial_stuff") then
	minetest.register_on_newplayer(give_initial_stuff.give)
end
