Melee = {}

function Melee:new(damage,time)
	local new = Component:new("melee")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	
	new.time = time or 20
	new.damage = damage or 1
	new.flags = {}

	return new
end

function Melee:event(e)
	if(e.id == "use") then
		local p = e.entity.pos + Pos:new(0.5,0.5) + normVector(e.entity.pos,e.target)
		p = p:floor()

		damageAdd(p,self.damage)
		e.entity:event("wait",{time = self.time})
	elseif(e.id == "description") then
		e.s = e.s .. Cstring:new("Dmg: " .. self.damage .. "\n")
	end

	return e
end
