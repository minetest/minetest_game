farming.register_hoe(":farming:hoe_wood", {
	description = "Wooden Hoe",
	inventory_image = "farming_tool_woodhoe.png",
	max_uses = 30,
	material = "group:wood",
	groups = {hoe = 1, flammable = 2},
})

farming.register_hoe(":farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_tool_stonehoe.png",
	max_uses = 90,
	material = "group:stone",
	groups = {hoe = 1}
})

farming.register_hoe(":farming:hoe_steel", {
	description = "Steel Hoe",
	inventory_image = "farming_tool_steelhoe.png",
	max_uses = 500,
	material = "default:steel_ingot",
	groups = {hoe = 1}
})

-- The following are deprecated by removing the 'material' field to prevent
-- crafting and removing from creative inventory, to cause them to eventually
-- disappear from worlds. The registrations should be removed in a future
-- release.

farming.register_hoe(":farming:hoe_bronze", {
	description = "Bronze Hoe",
	inventory_image = "farming_tool_bronzehoe.png",
	max_uses = 220,
	groups = {hoe = 1, not_in_creative_inventory = 1},
})

farming.register_hoe(":farming:hoe_mese", {
	description = "Mese Hoe",
	inventory_image = "farming_tool_mesehoe.png",
	max_uses = 350,
	groups = {hoe = 1, not_in_creative_inventory = 1},
})

farming.register_hoe(":farming:hoe_diamond", {
	description = "Diamond Hoe",
	inventory_image = "farming_tool_diamondhoe.png",
	max_uses = 500,
	groups = {hoe = 1, not_in_creative_inventory = 1},
})
