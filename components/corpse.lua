Corpse = {}

function Corpse:new()
	local new = Component:new("corpse")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	return new
end

function Corpse:event(e)
	if(e.id == "death") then
		
		local corpse = factory.corpse(self.owner)
		Level:addEntity(self.owner.pos,corpse)
	end
	return e
end