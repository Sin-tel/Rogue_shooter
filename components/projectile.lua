Projectile = {}

function Projectile:new(accuracy,bullet)
	local new = Component:new("projectile")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.d = 0
	new.accuracy = accuracy or 0.8
	new.active = false
	-- variables used when shot
	new.realpos = Pos:new(0,0)
	new.v = Pos:new(0,1)
	new.dist = 1000

	--TODO add this to separate component 
	new.damage = 5

	-- variables to change
	new.speed = 0.5
	new.drop = true
	new.bounce = true
	if(bullet) then
		new.speed = 1.0
		new.drop = false
		new.bounce = false
	end



	return new
end

function Projectile:event(e)
	if(e.id == "update") then
		if(self.active) then
			self:move()
		end
	elseif(e.id == "use") then
		self.active = true
		--calculate speed vector

		self.realpos = self.owner.pos + Pos:new(0.5,0.5)
		target = e.target  + Pos:new(0.5,0.5) --0.51 to prevent division by zero in vector normalisation

		self.speed = self.speed * (1 + math.random()*0.2)

		self.v = normVector(self.realpos,target)
		self.v = rotateVector(self.v , love.math.randomNormal()*(1-self.accuracy)*0.5)

		--[[self.realpos = self.realpos + self.v*self.speed
		self.owner.pos = self.realpos:floor()]]

		if(self.drop) then
			self.dist = dist(self.realpos,target) 
		end

		--calculate sprite direction
		if(self.owner.char == toChar('?')) then
			local diagonal1 = math.abs(self.v.x+self.v.y)*0.75
			local diagonal2 = math.abs(self.v.x-self.v.y)*0.75
			
			local val = math.max(math.abs(self.v.x),math.abs(self.v.y),diagonal1,diagonal2)
			
			if(val == math.abs(self.v.x)) then
				self.owner.char = c_bullet1
			elseif(val == diagonal1) then
				self.owner.char = c_bullet4
			elseif(val == diagonal2) then
				self.owner.char = c_bullet2
			else
				self.owner.char =  c_bullet3
			end
		end

		if(self.owner.char == c_bullet) then
			self.owner.char = c_bulletActive
		end
	end
	return e
end

function Projectile:move()
	
			
	--calc collisions w/ pos
	self.d = self.d + self.speed
	self.realpos=self.realpos + self.v*self.speed
	
	local p = self.realpos:floor()

	if(self.bounce) then
		if not p:passable(false) then
			local pp = self.owner.pos
			if(Pos:new(pp.x,p.y):passable()) then
				self.v = Pos:new(-self.v.x,self.v.y)
			end
			if(Pos:new(p.x,pp.y):passable()) then
				self.v = Pos:new(self.v.x,-self.v.y)
			end
		else
			self.owner.pos = p
		end
	else
		if not p:passable(true) then
			damageAdd(p,self.damage)
			self.owner.dead=true
		else
			self.owner.pos = p
		end
	end

	if(self.d >= self.dist) then
		self.speed = 0
	end

	
end