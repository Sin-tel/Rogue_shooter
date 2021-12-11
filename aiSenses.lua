--[[
Vision -> do sight checks
Smell  -> tracking player w/ not visible, finding food
Hearing  -> investigate shots/fights
Touch  -> basic 8 cells around entity
]]


Senses = {}

function Senses:new(ai)
	local new = {}
	setmetatable(new, self)
	self.__index = self

	--new.entities = {}
	new.vRange = vision or 8                   --euclidian range
	new.vRangeM = math.floor(new.vRange*math.sqrt(2)) --max manhattan range
	new.ai = ai

	new.teamScore = {}
	for k,v in pairs(teams) do
		new.teamScore[v] = 0
	end

	new.meleeEnemy = nil
	new.smell = true

	return new
end

function Senses:turn()
	for k,v in pairs(teams) do
		self.teamScore[v] = 0
	end
	self.meleeEnemy = nil
	--self.entities = {}
	for k,v in pairs(entities) do
		if(manh(self.ai.owner.pos,v.pos) <= self.vRangeM) then
			if(v~=self.ai.owner) then
				if(LOS(self.ai.owner.pos,v.pos,self.vRange)) then
					--table.insert(self.entities,v)
					if(v.team) then
						self.teamScore[v.team] = self.teamScore[v.team] + 1/manh(v.pos,self.ai.owner.pos)
						if(v.team ~= self.ai.owner.team and cheby(v.pos,self.ai.owner.pos) <= 1) then --TODO select weakest enemy
							self.meleeEnemy = v
						end
					end


				end
			end
		end
	end
end
