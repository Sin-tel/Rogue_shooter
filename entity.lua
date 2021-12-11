Entity = {}

function Entity:new(chr,clr,name)
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	new.pos = Pos:new(0,0)
	if(type(chr) ~= "number") then
		chr = toChar(chr or '?')
	end
	new.char = chr
	new.color = clr or {0.6,0.6,0.6}
	new.dead = false
	new.solid = true
	new.z = 2
	--new.visible = true
	new.name = name or "noName"

	new.components = {}

	return new
end

function Entity:addComponent(c)
	c.owner = self
	table.insert(self.components,c)
	assert(not self[c.name],"Trying to add two components with same name!")
	self[c.name] = c
	--c:event(Event:new("init"))
end

--[[
function Entity:addEntity(c)
	c.owner = self
	table.insert(self.components,c)
	self[c.name] = c
	
end]]

function Entity:event( id, parameters )
	if(type(id) == "string") then
		e = Event:new( id, parameters, self )
	else
		e = id
	end
	
	for i,v in ipairs(self.components) do
		e = v:event(e)
	end
	
	return e
end

function Entity:getName()
	return Cstring:new(self.name,self.color)
end

Event = {}

function Event:new( id, parameters, entity )
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	
	new.id = id
	parameters = parameters or {}
	for k,v in pairs(parameters) do 
		new[k] = v
	end
	new.entity = entity

	return new
end