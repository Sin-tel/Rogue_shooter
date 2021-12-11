Laser = {}

function Laser:new(damage,energy)
	local new = Component:new("laser")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.bullet = ammo.battery

	new.shootTime = 40
	new.damage = damage or 5
	new.energy = energy or 1


	new.timer = 0
	new.active = false
	new.target = nil

	return new
end

function Laser:event(e)
	if(e.id == "use") then
		local v = e.entity:event("reload",{bullet = self.bullet, amount = self.energy})

		if (v.amount >= self.energy) then
			e.entity:event("wait",{time = self.shootTime})
			self.active = true
			self.timer = self.shootTime/2
			self.target = e.target
			particles:spawn(e.entity.pos,"charge")

		end
	elseif(e.id == "description") then
		e.s = e.s .. "Dmg:  " ..  self.damage .. " \nCost: " .. self.energy .. "\n" .."Fires a penetrating laser\n" 
	elseif (e.id == "update") then
		if(self.active) then
			self.timer = self.timer-1
			if(self.timer<=0) then
				self:shoot()
				self.active = false
			end
		end
	end

	return e
end

function Laser:shoot(...)
	for i=1, self.damage, 1 do
		damageAoE(AoE_line(e.entity.pos,self.target),1)
	end
end