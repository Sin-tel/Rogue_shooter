Cname = {}

function Cname:new()
	local new = Component:new("name")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	return new
end

function Cname:event(e)
	if(e.id == "update") then

	end
	return e
end