--[[
 Action times:
 fast: 5	ex: shooting pistol
 normal: 10		ex: most actions
 slow: 25 		ex: moving
 slowWW: 100 	ex: reload, use injector
]]


Counter = {}

function Counter:new(time)
	local new = Component:new("counter")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.time = time or 0

	return new
end

function Counter:event(e)
	if(e.id == "wait") then
		

		--slow down when bloody
		if(self.owner.hp) then
			if( self.owner.hp:getState() == "bloody") then
				self.time = self.time + e.time*1.4
			elseif( self.owner.hp:getState() == "boosted") then
				self.time = self.time + e.time*0.6
			else
				self.time = self.time + e.time
			end
		else
			self.time = self.time + e.time
		end
	elseif(e.id == "update") then
		self.time = self.time - 1
		if(self.time <= 0) then
			self.owner:event("turn")
		end
	end

	return e
end