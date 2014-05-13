mesecon.rules = {}
mesecon.state = {}

mesecon.rules.default =
{{x=0,  y=0,  z=-1},
 {x=1,  y=0,  z=0},
 {x=-1, y=0,  z=0},
 {x=0,  y=0,  z=1},
 {x=1,  y=1,  z=0},
 {x=1,  y=-1, z=0},
 {x=-1, y=1,  z=0},
 {x=-1, y=-1, z=0},
 {x=0,  y=1,  z=1},
 {x=0,  y=-1, z=1},
 {x=0,  y=1,  z=-1},
 {x=0,  y=-1, z=-1}}

mesecon.rules.buttonlike =
{{x = 1,  y = 0, z = 0},
 {x = 1,  y = 1, z = 0},
 {x = 1,  y =-1, z = 0},
 {x = 1,  y =-1, z = 1}, 
 {x = 1,  y =-1, z =-1},
 {x = 2,  y = 0, z = 0}}

mesecon.rules.flat =
{{x = 1, y = 0, z = 0},
 {x =-1, y = 0, z = 0},
 {x = 0, y = 0, z = 1},
 {x = 0, y = 0, z =-1}}
 
mesecon.rules.buttonlike_get = function(node)
	local rules = mesecon.rules.buttonlike
	if node.param2 == 2 then
		rules=mesecon:rotate_rules_left(rules)
	elseif node.param2 == 3 then
		rules=mesecon:rotate_rules_right(mesecon:rotate_rules_right(rules))
	elseif node.param2 == 0 then
		rules=mesecon:rotate_rules_right(rules)
	end
	return rules
end

mesecon.state.on = "on"
mesecon.state.off = "off"
