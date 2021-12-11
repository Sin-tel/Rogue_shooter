Inventory = {}

--[[
Entities with an inventory should always have an equipment component!
]]

function Inventory:new()
	local new = Component:new("inventory")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.maxItems = 20
	new.items = {}
	for i=1,new.maxItems do
		new.items[i] = {}
	end

	new.ammo = {}
	for k,v in pairs(ammo) do
		new.ammo[v] = 20
	end

	return new
end

function Inventory:event(e)
	if(e.id == "pickup") then
		for k,v in ipairs(self.owner.pos:getEntities()) do
			if(v.item) then
				self:add(v)
				particles:spawn(self.owner.pos,"string",{s = v.name, c = v.color})
			end
		end
	elseif(e.id == "remove") then
		self:remove(e.item)
	elseif(e.id == "drop") then
		self:drop(e.item)
	elseif(e.id == "select") then
		item = self.items[e.index][1]
		if(item) then
			--try equipping item, otherwise, use it 
			--TODO fix guns etc. being used when entity has no equipment component
			if(not (self.owner.equipment and self.owner.equipment:equip(item))) then
				e.id = "use"
				item:event(e)
			end
		end
	elseif(e.id == "getAmmo") then
		self.ammo[e.bullet] = self.ammo[e.bullet] - e.amount
		if(self.ammo[e.bullet] < 0) then
			e.amount = e.amount + self.ammo[e.bullet]
			self.ammo[e.bullet] = 0
		end
	elseif(e.id == "addAmmo") then
		self.ammo[e.bullet] = self.ammo[e.bullet] + e.amount
	end
	return e
end

function Inventory:add(item)
	--do bullet pickup here

	local done = false

	--try finding stack 
	if(item.maxStack > 1) then
		for i=1,self.maxItems do
			n = #self.items[i]
			if(self.items[i][1] and self.items[i][1].name == item.name and n < self.items[i][1].maxStack) then
				table.insert(self.items[i],item)
				done = true
				break
			end
		end
	end

	--add to empty slot
	if(not done) then
		for i=1,self.maxItems do
			if(not self.items[i][1]) then
				self.items[i][1] = item
				done = true
				break
			end
		end
	end

	if done then
		item.dead = true
	else
		console:println("Inventory full!")
	end

	return done
end

function Inventory:remove(item)
	local index = 0

	--remove item
	for i = 1, self.maxItems do
		if(self.items[i][1] == item) then
			table.remove(self.items[i],1)
			index = i
			break
		end
	end
	--try equipping next item in stack
	if(index>0) then
		item = self.items[index][1]

		if(self.owner.equipment) then
			self.owner.equipment:equip(item)
		end
	end
end

function Inventory:drop(item)
	if(item) then
		self:remove(item)
		Level:addEntity(self.owner.pos,item)
	end
end

function Inventory:getItem(index)
	return self.items[index][1]
end

