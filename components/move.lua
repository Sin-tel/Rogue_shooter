Move = {}

function Move:new(speed)
	local new = Component:new("move")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.speed = speed or 3

	return new
end

function Move:event(e)
	if(e.id == "move") then
		local dir = e.dir
		local np = self.owner.pos + dir

		if np:passable(true) then
			local cost =  np:get(moveCost)
			self.owner.pos = np
			self.owner:event( "wait", {time = cost*100/self.speed} )
			
			if(self.owner == player) then
				teamD["player"]:calculate(self.owner.pos)
				teamF["player"]:calculateFlee(teamD["player"])
			end
		end
	end

	return e
end