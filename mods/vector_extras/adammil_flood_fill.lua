-- http://www.adammil.net/blog/v126_A_More_Efficient_Flood_Fill.html

local can_go
local marked_places
local function calc_2d_index(x, y)
	return (y + 32768) * 65536 + x + 32768
end
local function mark(x, y)
	marked_places[calc_2d_index(x, y)] = true
end

local _fill
local function fill(x, y)
	if can_go(x, y) then
		_fill(x, y)
	end
end

local corefill
function _fill(x, y)
	while true do
		local ox = x
		local oy = y
		while can_go(x, y-1) do
			y = y-1
		end
		while can_go(x-1, y) do
			x = x-1
		end
		if x == ox
		and y == oy then
			break
		end
	end
	corefill(x, y)
end

function corefill(x, y)
	local lastcnt = 0
	repeat
		local cnt = 0
		local sx = x
		if lastcnt ~= 0
		and not can_go(y, x) then
			-- go right to find the x start
			repeat
				lastcnt = lastcnt-1
				if lastcnt == 0 then
					return
				end
				x = x+1
			until can_go(x, y)
			sx = x
		else
			-- go left if possible, and mark and _fill above
			while can_go(x-1, y) do
				x = x-1
				mark(x, y)
				if can_go(x, y-1) then
					_fill(x, y-1)
				end
				cnt = cnt+1
				lastcnt = lastcnt+1
			end
		end

		-- go right if possible, and mark
		while can_go(sx, y) do
			mark(sx, y)
			cnt = cnt+1
			sx = sx+1
		end

		if cnt < lastcnt then
			local e = x + lastcnt
			sx = sx+1
			while sx < e do
				if can_go(sx, y) then
					corefill(sx, y)
				end
				sx = sx+1
			end
		elseif cnt > lastcnt then
			local ux = x + lastcnt + 1
			while ux < sx do
				if can_go(ux, y-1) then
					_fill(ux, y-1)
				end
				ux = ux+1
			end
		end
		lastcnt = cnt
		y = y+1
	until lastcnt == 0
end

local function apply_fill(go_test, x0, y0, allow_revisit)
	if allow_revisit then
		can_go = go_test
	else
		local visited = {}
		can_go = function(x, y)
			local vi = calc_2d_index(x, y)
			if visited[vi] then
				return false
			end
			visited[vi] = true
			return go_test(x, y)
		end
	end
	marked_places = {}
	fill(x0, y0)
	return marked_places
end

return apply_fill
