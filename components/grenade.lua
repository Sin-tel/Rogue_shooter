Grenade = {}

function Grenade:new(time)
	local new = Component:new("grenade")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.time1 = time or 100
	new.time2 = new.time1*0.25

	new.timer = 0
	new.active = false

	return new
end

function Grenade:event(e)
	if(e.id == "update") then
		if(self.active) then
			self:grenade()

			self.timer = self.timer + 1
		end
	elseif(e.id == "use") then
		self.active = true
	elseif(e.id == "description") then
		e.s = e.s .. "Dmg: 20-40"
	end
	return e
end

function Grenade:grenade()
	if(self.timer >= self.time1) then
		damageAoE( AoE_circle(self.owner.pos,7,0.3),20)
		
		damageAoE(AoE_circle(self.owner.pos,3,0.1),20)
		Level:destroy(self.owner.pos,4)
		slowmo()
		particles:spawn(self.owner.pos,"explosion")
		self.owner.dead = true
	end

	if(self.timer >= self.time2) then
		self.owner.blink = true
	end
end