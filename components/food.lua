Food = {}

function Food:new(amt)
	local new = Component:new("food")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.amount = amt or 1

	return new
end

function Food:event(e)
	if(e.id == "eat") then
		self.amount = self.amount-1
		particles:spawn(self.owner.pos,"string",{s = "nom",c = {150,80,50}})
		if(self.amount <= 0) then
			self.owner.dead = true
		end
	end
	return e
end