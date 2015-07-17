local items = {
	"default:pick_steel",
	"default:axe_steel",
	"default:shovel_steel",
	"default:torch 99",
	"default:cobble 99"
}

minetest.register_on_newplayer(function(player)
	if minetest.setting_getbool("give_initial_stuff") then
		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
		local inv = player:get_inventory()
		for _, item in ipairs(items) do
			inv:add_item("main", item)
		end
	end
end)
