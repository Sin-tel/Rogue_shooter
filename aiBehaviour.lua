--[[
Base priority should always be limit case! (-> never return higher)

]]

P_NONE = 0
P_LOW = 25
P_NORMAL = 100
P_HIGH = 200
P_HIGHEST = 500

function logistic(x,k,half)
	k = k or 1
	half = half or 0
	return 1/(1+ math.exp(-k*(x-half)))
end

function expo(x,slope)
	slope = slope or 1
	return 1 - math.exp(-x*slope)
end


Behaviour = {}

function Behaviour:new()
	local new = {}
	self.__index = self

	new.priority = P_LOW

	return new
end

function Behaviour:evaluate()

end

function Behaviour:execute()
	
end

Wander = {}
setmetatable( Wander, { __index = Behaviour } )

function Wander:new()
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = 1
	new.turn = math.random(3,20)

	return new
end

function Wander:execute()
	self.turn = self.turn - 1
	if(self.turn <= 0) then
		if(math.random()<0.5) then
			self.ai.dir = self.ai.dir+1
		else
			self.ai.dir = self.ai.dir-1
		end
		self.turn = math.random(3,20)
	end
	self.ai.owner:event("move",{dir = self.ai.dir})
	if(self.ai.owner.counter.time <= 0) then
		if(math.random()<0.5) then
			self.ai.dir = self.ai.dir+1
		else
			self.ai.dir = self.ai.dir-1
		end
	end
end

Flee = {}
setmetatable( Flee, { __index = Behaviour } )

function Flee:new(team,base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = 0
	new.baseP = base or P_NORMAL

	new.team = team
	return new
end

function Flee:evaluate()
	self.priority = self.baseP*expo(self.ai.senses.teamScore[self.team],2)
end

function Flee:execute()
	self.ai:followDijkstra(teamF[self.team])
	self.ai.owner:event("move",{dir = self.ai.dir})
end


Attack = {}
setmetatable( Attack, { __index = Behaviour } )

function Attack:new(base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = P_NONE
	new.baseP = base or P_HIGHEST

	return new
end

function Attack:evaluate()
	if(self.ai.senses.meleeEnemy) then
		self.priority = self.baseP
	else
		self.priority = P_NONE
	end

end

function Attack:execute()
	self.ai.owner:event("use",{name = "attack", target = self.ai.senses.meleeEnemy.pos})
end

Approach = {}
setmetatable( Approach, { __index = Behaviour } )

function Approach:new(team,base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = 0
	new.baseP = base or P_NORMAL

	new.team = team
	return new
end

function Approach:evaluate()
	self.priority = self.baseP*expo(self.ai.senses.teamScore[self.team] + self.ai.owner.pos:get(scent)/30,2)
end

function Approach:execute()
	if(self.ai.senses.teamScore[self.team] > 0) then
		self.ai:followDijkstra(teamD[self.team])
	else
		self.ai:followSmell()
	end
	
	self.ai.owner:event("move",{dir = self.ai.dir})
end

FindFood = {}
setmetatable( Approach, { __index = Behaviour } )

function FindFood:new(base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = 0
	new.baseP = base or P_NORMAL

	new.time = math.random(100)

	return new
end

function FindFood:evaluate()
	if(self.ai.owner.pos:get(meatD) < math.huge) then
		self.priority = self.baseP*logistic(self.time,0.05,100)
	else
		self.priority = 0
	end
	self.time = self.time + 1
end

function FindFood:execute()
	if(self.ai.owner.pos:get(meatD)>1) then
		self.ai:followDijkstra(meatD)
		self.ai.owner:event("move",{dir = self.ai.dir})
	else
		for k,v in pairs(Dir:getAll()) do
			for l,w in pairs((self.ai.owner.pos+v):getEntities()) do
				if(w.food) then
					w:event("eat")
					self.ai.owner:event("wait",{time = 50})
					self.time = 0
				end
			end
		end
	end
end