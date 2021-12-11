Gun = {}

function Gun:new(bullet,shootTime,magSize,accuracy)
	local new = Component:new("gun")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.bullet = bullet or ammo.pistol
	new.shootTime = shootTime or 5
	new.reloadTime = 50
	new.magSize = magSize or 6
	new.accuracy = accuracy or 0.8

	new.mag = 0

	new.shake = 5

	return new
end

function Gun:event(e)
	if(e.id == "use") then
		if(self.mag > 0) then
			shake = shake + self.shake
			slowmo()
			
			local shots = self.bullet.shots
			for i = 1, shots do
				local bullet = self.bullet.new(self.accuracy) 

				Level:addEntity(e.entity.pos,bullet)

				bullet:event(e)
			end

			self.mag = self.mag - 1

			e.entity:event("wait",{time = self.shootTime})
		else
			self:reload(e.entity)
		end
	elseif(e.id == "reload") then
		self:reload(e.entity)
	elseif(e.id == "description") then
		local damageS = "Dmg: " .. self.bullet.damage .. "\n"

		if(self.bullet.shots > 1) then
			damageS = "Dmg: " ..  self.bullet.shots .. "x" .. self.bullet.damage .. "\n"
		end

		e.s = e.s .. damageS .. "Accuracy: " .. math.floor(self.accuracy*100) .. "%\n" .. "Shoots " .. self.bullet.name .. "\n" 
	end

	return e
end

function Gun:reload(entity)
	local a = self.magSize - self.mag

	local e = entity:event("getAmmo",{bullet = self.bullet, amount = a})

	self.mag = self.mag + e.amount
	if(e.amount>0) then
		entity:event("wait",{time = self.reloadTime})
	end
end