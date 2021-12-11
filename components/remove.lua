Remove = {}

function Remove:new(consume)
	local new = Component:new("remove")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.consume = consume

	return new
end

function Remove:event(e)
	if(e.id == "use") then
		if(self.consume) then
			e.entity:event("remove",{item = self.owner})
		else
		    e.entity:event("drop",{item = self.owner})
		end
	end
	return e
end