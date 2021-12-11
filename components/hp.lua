Hp = {}

function Hp:new(hp)
	local new = Component:new("hp")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	
	new.hp = hp or 30
	new.maxHp = hp or 30

	return new
end

function Hp:event(e)
	if(e.id == "hit") then
		--local start = love.timer.getTime()

		self.hp = self.hp - e.damage
		

		local c = {255,20,20+math.random()*50}
		if(self.owner == player) then
			hitShake = hitShake + e.damage
			c = {160,150,20+math.random()*50}
		end
		if(self.hp>0) then
			particles:spawn(self.owner.pos,"string",{s = e.damage,c = c})
			if(math.random()<e.damage/20) then
				
				Level:put(self.owner.pos,"blood")
			end
		end
		--local result = love.timer.getTime() - start
		--print( string.format( "It took %.6f milliseconds to calculate hit", result * 1000 ))
	elseif(e.id == "update") then
		if(self:getState() == "boosted") then
			self.owner.blink = true
		else
			self.owner.blink = false
		end

		if(self.hp>self.maxHp) then
			--boosted, so slowly "bleed"
			self.hp = self.hp - 0.02
		end

		if(self.hp <= 0) then
			self.owner.dead = true
		end
	elseif(e.id == "boost") then
		self.hp = self.hp + (e.val*self.maxHp)
	elseif(e.id == "heal") then
		if(self.hp<self.maxHp) then
			self.hp = self.hp + e.val
		end
	elseif(e.id == "description") then
		e.s = e.s .. self:getDescription() .. "\n"
	end

	return e
end

function Hp:getState()
	if(self.hp<=self.maxHp*(1/3)) then
		return "bloody"
	elseif(self.hp<=self.maxHp*(2/3)) then
		return "hurt"
	elseif(self.hp<=self.maxHp*1.1) then
		return "fine"
	else
		return "boosted"
	end
end


function Hp:getDescription()
	local s = self:getState()
	local c = {0,180,0}

	if(s == "bloody") then
		c = {180,0,0}
	elseif(s == "hurt") then
		c ={180,180,0}
	elseif(s == "boosted") then
		c = {40,180,120}
	end

	return Cstring:new(s,c)
end

function Hp:getHp()
	return math.floor(self.hp+0.5) , self.maxHp
end