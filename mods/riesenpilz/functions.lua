if riesenpilz.info then
	function riesenpilz.inform(msg, spam, t)
		if spam <= riesenpilz.max_spam then
			local info
			if t then
				info = string.format("[riesenpilz] "..msg.." after ca. %.2fs", os.clock() - t)
			else
				info = "[riesenpilz] "..msg
			end
			print(info)
			if riesenpilz.inform_all then
				minetest.chat_send_all(info)
			end
		end
	end
else
	function riesenpilz.inform()
	end
end

local circle_tables = {}
function riesenpilz.circle(r)
	local circle = circle_tables[r]
	if circle then
		return circle
	end
	circle = {}
	for i = -r, r do
		for j = -r, r do
			if math.floor(math.sqrt(i * i + j * j) + 0.5) == r then
				circle[#circle+1] = {x=i, y=0, z=j}
			end
		end
	end
	circle_tables[r] = circle
	return circle
end
