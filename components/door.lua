Door = {}

function Door:new(sliding)
	local new = Component:new("door")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.sliding = sliding
	new.state = "closed"

	return new
end

function Door:event(e)
	if(e.id == "interact") then
		if(not self.sliding) then
			if(self.state == "open") then
				self:close()
				self.owner.pos:set(solid,true)
			else
				self:open()
				self.owner.pos:set(solid,false)
			end
		end
	elseif(e.id == "update" and self.sliding) then
		local sw = false
		for i,v in pairs(entities) do
			if(manh(self.owner.pos,v.pos)==1 and v.move) then
				sw = true
			end
		end
		if(sw) then
			self:open()
		else
			self:close()
		end
	end
	return e
end

function Door:open()
	self.state = "open"
	self.owner.solid = false
	Level:put(self.owner.pos,"door open")
	self.owner.char = toChar("/")
end
function Door:close()
	self.state = "closed"
	self.owner.solid = true
	Level:put(self.owner.pos,"door closed")
	self.owner.char = toChar("+")
end