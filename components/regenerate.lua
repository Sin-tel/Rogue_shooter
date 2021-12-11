Regenerate = {}

function Regenerate:new(time)
	local new = Component:new("regenerate")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.time = time or 1000
	new.timer = new.time

	return new
end

function Regenerate:event(e)

	if(e.id == "update") then
		self.timer = self.timer - 1

		if(self.timer <= 0) then
			self.timer = self.time
			self.owner:event("heal",{val = 1})

		end
	elseif(e.id == "description") then
		e.s = e.s .. Cstring:new("Regeneration\n", {100,150,100})
	end

	return e
end