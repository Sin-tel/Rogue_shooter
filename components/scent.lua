Scent = {}

function Scent:new()
	local new = Component:new("scent")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	return new
end

function Scent:event(e)
	if(e.id == "update") then
		self.owner.pos:set(scent,30)
	end

	return e
end

