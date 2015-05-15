-- Intllib
give_initial_stuff = {}

local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end
give_initial_stuff.intllib = S

minetest.register_on_newplayer(function(player)
	--print("on_newplayer")
	if minetest.setting_getbool("give_initial_stuff") then
		minetest.log("action", S("Giving initial stuff to player @1", player:get_player_name()))
		player:get_inventory():add_item('main', 'default:pick_steel')
		player:get_inventory():add_item('main', 'default:torch 99')
		player:get_inventory():add_item('main', 'default:axe_steel')
		player:get_inventory():add_item('main', 'default:shovel_steel')
		player:get_inventory():add_item('main', 'default:cobble 99')
	end
end)

