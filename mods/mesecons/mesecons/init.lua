-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija, Uberi (Temperest), sfan5, VanessaE
--
--
--
-- This mod adds mesecons[=minecraft redstone] and different receptors/effectors to minetest.
-- See the documentation on the forum for additional information, especially about crafting
--
--
-- For developer documentation see the Developers' section on mesecons.TK
--
--
--
--Quick draft for the mesecons array in the node's definition
--mesecons =
--{
--	receptor =
--	{
--		state = mesecon.state.on/off
--		rules = rules/get_rules
--	},
--	effector =
--	{
--		action_on = function
--		action_off = function
--		action_change = function
--		rules = rules/get_rules
--	},
--	conductor = 
--	{
--		state = mesecon.state.on/off
--		offstate = opposite state (for state = on only)
--		onstate = opposite state (for state = off only)
--		rules = rules/get_rules
--	}
--}


-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.queue={} -- contains the ActionQueue
mesecon.queue.funcs={} -- contains all ActionQueue functions

-- Settings
dofile(minetest.get_modpath("mesecons").."/settings.lua")

-- Presets (eg default rules)
dofile(minetest.get_modpath("mesecons").."/presets.lua");


-- Utilities like comparing positions,
-- adding positions and rules,
-- mostly things that make the source look cleaner
dofile(minetest.get_modpath("mesecons").."/util.lua");

-- The ActionQueue
-- Saves all the actions that have to be execute in the future
dofile(minetest.get_modpath("mesecons").."/actionqueue.lua");

-- Internal stuff
-- This is the most important file
-- it handles signal transmission and basically everything else
-- It is also responsible for managing the nodedef things,
-- like calling action_on/off/change
dofile(minetest.get_modpath("mesecons").."/internal.lua");

-- Deprecated stuff
-- To be removed in future releases
-- Currently there is nothing here
dofile(minetest.get_modpath("mesecons").."/legacy.lua");

-- API
-- these are the only functions you need to remember

mesecon.queue:add_function("receptor_on", function (pos, rules)
	rules = rules or mesecon.rules.default

	-- if area (any of the rule targets) is not loaded, keep trying and call this again later
	if MESECONS_GLOBALSTEP then -- trying to enable resuming with globalstep disabled would cause an endless loop
		for _, rule in ipairs(mesecon:flattenrules(rules)) do
			local np = mesecon:addPosRule(pos, rule)
			-- if area is not loaded, keep trying
			if minetest.get_node_or_nil(np) == nil then
				mesecon.queue:add_action(pos, "receptor_on", {rules}, nil, rules)
				return
			end
		end
	end

	-- execute action
	for _, rule in ipairs(mesecon:flattenrules(rules)) do
		local np = mesecon:addPosRule(pos, rule)
		local rulenames = mesecon:rules_link_rule_all(pos, rule)
		for _, rulename in ipairs(rulenames) do
			mesecon:turnon(np, rulename)
		end
	end
end)

function mesecon:receptor_on(pos, rules)
	mesecon.queue:add_action(pos, "receptor_on", {rules}, nil, rules)
end

mesecon.queue:add_function("receptor_off", function (pos, rules)
	rules = rules or mesecon.rules.default

	-- if area (any of the rule targets) is not loaded, keep trying and call this again later
	if MESECONS_GLOBALSTEP then
		for _, rule in ipairs(mesecon:flattenrules(rules)) do
			local np = mesecon:addPosRule(pos, rule)
			if minetest.get_node_or_nil(np) == nil then
				mesecon.queue:add_action(pos, "receptor_off", {rules}, nil, rules)
				return
			end
		end
	end

	for _, rule in ipairs(mesecon:flattenrules(rules)) do
		local np = mesecon:addPosRule(pos, rule)
		local rulenames = mesecon:rules_link_rule_all(pos, rule)
		for _, rulename in ipairs(rulenames) do
			if not mesecon:connected_to_receptor(np, mesecon:invertRule(rule)) then
				mesecon:turnoff(np, rulename)
			else
				mesecon:changesignal(np, minetest.get_node(np), rulename, mesecon.state.off, 2)
			end
		end
	end
end)

function mesecon:receptor_off(pos, rules)
	mesecon.queue:add_action(pos, "receptor_off", {rules}, nil, rules)
end


print("[OK] Mesecons")

--The actual wires
dofile(minetest.get_modpath("mesecons").."/wires.lua");

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
