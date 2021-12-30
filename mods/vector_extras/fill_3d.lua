-- Algorithm created by sofar and changed by others:
-- https://github.com/minetest/minetest/commit/d7908ee49480caaab63d05c8a53d93103579d7a9

local function search(go, p, apply_move, moves)
	local num_moves = #moves

	-- We make a stack, and manually maintain size for performance.
	-- Stored in the stack, we will maintain tables with pos, and
	-- last neighbor visited. This way, when we get back to each
	-- node, we know which directions we have already walked, and
	-- which direction is the next to walk.
	local s = {}
	local n = 0
	-- The neighbor order we will visit from our table.
	local v = 1

	while true do
		-- Push current pos onto the stack.
		n = n + 1
		s[n] = {p = p, v = v}
		-- Select next node from neighbor list.
		p = apply_move(p, moves[v])
		-- Now we check out the node. If it is in need of an update,
		-- it will let us know in the return value (true = updated).
		if not go(p) then
			-- If we don't need to "recurse" (walk) to it then pop
			-- our previous pos off the stack and continue from there,
			-- with the v value we were at when we last were at that
			-- node
			repeat
				local pop = s[n]
				p = pop.p
				v = pop.v
				s[n] = nil
				n = n - 1
				-- If there's nothing left on the stack, and no
				-- more sides to walk to, we're done and can exit
				if n == 0 and v == num_moves then
					return
				end
			until v < num_moves
			-- The next round walk the next neighbor in list.
			v = v + 1
		else
			-- If we did need to walk the neighbor, then
			-- start walking it from the walk order start (1),
			-- and not the order we just pushed up the stack.
			v = 1
		end
	end
end

return search
