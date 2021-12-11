--[[
slot types:
ranged
melee


non-equipping types:
attack

]]

Equipment = {}

function Equipment:new()
	local new = Component:new("equipment")
	setmetatable(new, self)
	self.__index = self

	new.slots = {}

	return new
end

function Equipment:event(e)
	if(e.id == "use") then
		for k,v in pairs(self.slots) do
			if (e.name == v.type) then
				v:event(e)
				break
			end
		end
	elseif(e.id == "reload") then
		for k,v in pairs(self.slots) do
			v:event(e)
		end
	elseif(e.id == "update") then
		for k,v in pairs(self.slots) do
			v:event(e)
		end
	elseif(e.id == "remove" or e.id == "drop") then
		self:unEquip(e.item)
	elseif(e.id == "description") then
		e.s = e.s .. "Equipped:\n"
		for i in ipairs(self.slots) do
			if(i>1) then
				e.s = e.s .. ", "
			end
			e.s = e.s .. self.slots[i]:getName() 
		end
		e.s = e.s .. "\n"
	end
	return e
end

function Equipment:equip(item)
	if(item) then
		for k,v in pairs(self.slots) do
			if(item.type == v.type) then
				v:equip(item)
				return true
			end
		end
	end

	return false
end

function Equipment:unEquip(item)
	for k,v in pairs(self.slots) do
		if(item == v.item) then
			v:unEquip()
			return true
		end
	end

	return false
end

function Equipment:isEquipped(item)
	if(item) then
		for k,v in pairs(self.slots) do
			if(item == v.item) then
				return true
			end
		end
	end

	return false
end

function Equipment:addSlot(type,ability)
	local slot = Slot:new(type,ability)
	table.insert(self.slots,slot)
end

Slot = {}

function Slot:new(type,default)
	local new = {}
	setmetatable(new, self)
	self.__index = self

	new.type = type
	new.default = default
	new.item = nil 
	return new
end

function Slot:equip(item)
	self.item = item
end

function Slot:unEquip()
	self.item = nil
end

function Slot:event(e)
	if(self.item) then
		self.item:event(e)
	elseif(self.default) then
		self.default:event(e)
	end
end

function Slot:getName()
	if(self.item) then
		return self.item:getName()
	elseif(self.default) then
		return self.default:getName()
	else
		return ""
	end
end