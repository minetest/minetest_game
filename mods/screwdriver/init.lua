minetest.register_tool("screwdriver:screwdriver", {
	description = "Screwdriver",
	inventory_image = "screwdriver.png",
	on_use = function(itemstack, user, pointed_thing)
	screwdriver_handler(itemstack,user,pointed_thing)
	return itemstack
	end,
})

for i=1,4,1 do
minetest.register_tool("screwdriver:screwdriver"..i, {
	description = "Screwdriver in Mode "..i,
	inventory_image = "screwdriver.png^tool_mode"..i..".png",
	wield_image = "screwdriver.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
	screwdriver_handler(itemstack,user,pointed_thing)
	return itemstack
	end,
})
end
faces_table=
{
--look dir  +X  +Y  +Z    -Z  -Y  -X
			2 , 0 , 4 ,    5 , 1 , 3 ,  -- rotate around y+ 0 - 3
			4 , 0 , 3 ,    2 , 1 , 5 ,
			3 , 0 , 5 ,    4 , 1 , 2 ,
			5 , 0 , 2 ,    3 , 1 , 4 ,

			2 , 5 , 0 ,    1 , 4 , 3 ,  -- rotate around z+ 4 - 7
			4 , 2 , 0 ,    1 , 3 , 5 ,
			3 , 4 , 0 ,    1 , 5 , 2 ,
			5 , 3 , 0 ,    1 , 2 , 4 ,

			2 , 4 , 1 ,    0 , 5 , 3 ,  -- rotate around z- 8 - 11
			4 , 3 , 1 ,    0 , 2 , 5 ,
			3 , 5 , 1 ,    0 , 4 , 2 ,
			5 , 2 , 1 ,    0 , 3 , 4 ,

			0 , 3 , 4 ,    5 , 2 , 1 ,  -- rotate around x+ 12 - 15
			0 , 5 , 3 ,    2 , 4 , 1 ,
			0 , 2 , 5 ,    4 , 3 , 1 ,
			0 , 4 , 2 ,    3 , 5 , 1 ,

			1 , 2 , 4 ,    5 , 3 , 0 ,  -- rotate around x- 16 - 19  
			1 , 4 , 3 ,    2 , 5 , 0 ,  
			1 , 3 , 5 ,    4 , 2 , 0 ,  
			1 , 5 , 2 ,    3 , 4 , 0 ,  

			3 , 1 , 4 ,    5 , 0 , 2 ,  -- rotate around y- 20 - 23
			5 , 1 , 3 ,    2 , 0 , 4 ,  
			2 , 1 , 5 ,    4 , 0 , 3 ,  
			4 , 1 , 2 ,    3 , 0 , 5  
}

function screwdriver_handler (itemstack,user,pointed_thing)
	local keys=user:get_player_control()
	local player_name=user:get_player_name()
	local item=itemstack:to_table()
	if item["metadata"]=="" or keys["sneak"]==true then return screwdriver_setmode(user,itemstack) end
	local mode=tonumber((item["metadata"]))
	if pointed_thing.type~="node" then return end
	local pos=minetest.get_pointed_thing_position(pointed_thing,above)
	local node=minetest.get_node(pos)
	local node_name=node.name
	if minetest.registered_nodes[node_name].paramtype2 == "facedir" then
		if minetest.registered_nodes[node_name].drawtype == "nodebox" then
			if minetest.registered_nodes[node_name].node_box["type"]~="fixed" then return end
			end
		if node.param2==nil  then return end
		-- Get ready to set the param2
			local n = node.param2
			local axisdir=math.floor(n/4)
			local rotation=n-axisdir*4
			if mode==1 then 
				rotation=rotation+1
				if rotation>3 then rotation=0 end
				n=axisdir*4+rotation
			end

			if mode==2 then 
				local ppos=user:getpos()
				local pvect=user:get_look_dir()
				local face=get_node_face(pos,ppos,pvect)
				if face == nil then return end
				local index=convertFaceToIndex(face)
				local face1=faces_table[n*6+index+1]
				local found = 0
				while found == 0 do
					n=n+1
					if n>23 then n=0 end
					if faces_table[n*6+index+1]==face1 then found=1 end
				end
			end
				
			if mode==3 then 
				axisdir=axisdir+1
				if axisdir>5 then axisdir=0 end
				n=axisdir*4
			end

			if mode==4 then 
				local ppos=user:getpos()
				local pvect=user:get_look_dir()
				local face=get_node_face(pos,ppos,pvect)
				if face == nil then return end
				if axisdir == face then
					rotation=rotation+1
				if rotation>3 then rotation=0 end
					n=axisdir*4+rotation
				else
					n=face*4
				end
			end
			--print (dump(axisdir..", "..rotation))
			local meta = minetest.get_meta(pos)
			local meta0 = meta:to_table()
			node.param2 = n
			minetest.set_node(pos,node)
			meta = minetest.get_meta(pos)
			meta:from_table(meta0)
			local item=itemstack:to_table()
			local item_wear=tonumber((item["wear"]))
			item_wear=item_wear+327 
			if item_wear>65535 then itemstack:clear() return itemstack end
			item["wear"]=tostring(item_wear)
			itemstack:replace(item)
			return itemstack
	end
end

mode_text={
{"Change rotation, Don't change axisdir."},
{"Keep choosen face in front then rotate it."},
{"Change axis dir, Reset rotation."},
{"Bring top in front then rotate it."},
}

function screwdriver_setmode(user,itemstack)
local player_name=user:get_player_name()
local item=itemstack:to_table()
local mode
if item["metadata"]=="" then
	minetest.chat_send_player(player_name,"Hold shift and use to change screwdriwer modes.")
	mode=0
else mode=tonumber((item["metadata"]))
end
mode=mode+1
if mode==5 then mode=1 end
minetest.chat_send_player(player_name, "Screwdriver mode : "..mode.." - "..mode_text[mode][1] )
item["name"]="screwdriver:screwdriver"..mode
item["metadata"]=tostring(mode)
itemstack:replace(item)
return itemstack
end

minetest.register_craft({
output = "screwdriver:screwdriver",
recipe = {
{"default:steel_ingot"},
{"default:stick"}
}
})

function get_node_face(pos,ppos,pvect)
	ppos={x=ppos.x-pos.x,y=ppos.y-pos.y+1.5,z=ppos.z-pos.z}
	if pvect.x>0 then
		local t=(-0.5-ppos.x)/pvect.x
		local y_int=ppos.y+t*pvect.y
		local z_int=ppos.z+t*pvect.z
		if y_int>-0.4 and y_int<0.4 and z_int>-0.4 and z_int<0.4 then return 4 end 
	elseif pvect.x<0 then
		local t=(0.5-ppos.x)/pvect.x
		local y_int=ppos.y+t*pvect.y
		local z_int=ppos.z+t*pvect.z
		if y_int>-0.4 and y_int<0.4 and z_int>-0.4 and z_int<0.4 then return 3 end 
	end
	if pvect.y>0 then
		local t=(-0.5-ppos.y)/pvect.y
		local x_int=ppos.x+t*pvect.x
		local z_int=ppos.z+t*pvect.z
		if x_int>-0.4 and x_int<0.4 and z_int>-0.4 and z_int<0.4 then return 5 end 
	elseif pvect.y<0 then
		local t=(0.5-ppos.y)/pvect.y
		local x_int=ppos.x+t*pvect.x
		local z_int=ppos.z+t*pvect.z
		if x_int>-0.4 and x_int<0.4 and z_int>-0.4 and z_int<0.4 then return 0 end 
	end
	if pvect.z>0 then
		local t=(-0.5-ppos.z)/pvect.z
		local x_int=ppos.x+t*pvect.x
		local y_int=ppos.y+t*pvect.y
		if x_int>-0.4 and x_int<0.4 and y_int>-0.4 and y_int<0.4 then return 2 end 
	elseif pvect.z<0 then
		local t=(0.5-ppos.z)/pvect.z
		local x_int=ppos.x+t*pvect.x
		local y_int=ppos.y+t*pvect.y
		if x_int>-0.4 and x_int<0.4 and y_int>-0.4 and y_int<0.4 then return 1 end 
	end
end

function convertFaceToIndex (face)
if face==0 then return 1 end
if face==1 then return 2 end
if face==2 then return 3 end
if face==3 then return 0 end
if face==4 then return 5 end
if face==5 then return 4 end
end

