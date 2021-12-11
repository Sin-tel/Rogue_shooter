AmmoBox = {}

function AmmoBox:new(ammo,amount)
	local new = Component:new("ammoBox")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.ammo = ammo
	new.amount = amount or 10

	return new
end

function AmmoBox:event(e)
	if(e.id == "update") then
		for i,v in pairs(self.owner.pos:getEntities()) do
			if(v == player) then
				v:event("addAmmo", {bullet = self.ammo, amount = self.amount})
				particles:spawn(self.owner.pos,"string",{s = self.amount .. " " .. self.ammo.name})
				self.owner.dead = true
			end
		end
	elseif(e.id == "description") then
		e.s = e.s .. "contains " .. self.amount
	end
	return e
end