Boost = {}

function Boost:new(value)
	local new = Component:new("boost")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	--boost in percentage of maximum stamina
	self.val = value or 0.2

	return new
end

function Boost:event(e)
	if(e.id == "use") then
		e.entity:event("boost",{val = self.val})
		e.entity:event("wait",{time = 100})
		particles:spawn(e.entity.pos,"boost")
	elseif(e.id == "description") then
		e.s = e.s .. Cstring:new("Regenerates " .. self.val*100 ..  "%\n")
	end
	return e
end