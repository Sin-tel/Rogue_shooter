Tail = {}

--TODO: fix getting stuck, rolled up in corner

-- woooorm
-- eeeeel
-- loooop?
-- 
-- snake (boring)
-- serpent

function Tail:new(list)
	local new = Component:new("tail")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.segments = list

	for i,v in ipairs(list) do
		v.pPos = Pos:new(0,0)
	end

	return new
end

function Tail:event(e)
	if(e.id == "move") then
		local count = 0
		for i,v in ipairs(self.segments) do
			local head = self.segments[i-1] or self.owner

			if(head.dead) then
				v.dead = true
			end

			if(v.pPos ~= head.pos) then
				v.pos = v.pPos
			end

			v.pPos = head.pos

			if(not v.dead) then
				count = count + 1
			end
		end
		if(count == 0) then
			self.owner.move.speed = 1
		end
	elseif (e.id == "death") then
		for i,v in ipairs(self.segments) do
			v.dead = true
		end
	end
	return e
end