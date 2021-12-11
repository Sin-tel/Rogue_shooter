--[[
Class representing colored strings.
]]

Cstring = {}

function Cstring:load()
	self.char = {}
	self.cw = 8
	self.ch = 12
end

function Cstring:new(string,color)
	local new = {}	
	setmetatable(new, self)
	self.__index = self
	self.__concat = self.concat
	self.__eq = self.eq

	new.string = string or ""
	new.color = {}

	for i = 1,#new.string do
		new.color[i] = color or {0.6,0.6,0.6}
	end


	return new
end

function Cstring:draw(x,y,w)
	local cx = x
	local cy = y
	local maxw = x + w

	for i = 1, #self.string do
		if(string.byte(self.string, i) == string.byte('\n')) then
			cx = x
			cy = cy + 1
		else
			local c = string.byte(self.string, i)
			local color = self.color[i] or {0.6,0.6,0.6}

			batch:setColor(color[1],color[2],color[3])
			batch:add(quads[c],cx*self.cw,cy*self.ch)

			cx = cx + 1

			if(cx >= maxw) then
				cx = x
				cy = cy + 1
			end
		end
	end
end

function Cstring:shorten(len)

	for i = 1, #self.string do
		if(i > len) then
			--self.string[i] = nil
			self.color[i] = nil
		end
	end
	if(#self.string > len) then
		self.string = self.string:sub(1,len-2) .. ".."
	end
end


function Cstring.concat(s1,s2)
	if(type(s1) == "string") then
		s1 = Cstring:new(s1)
	end
	if(type(s2) == "string") then
		s2 = Cstring:new(s2)
	end

	local cstr = Cstring:new(s1.string .. s2.string)
	for i=1,#s1.color do
		cstr.color[i] = s1.color[i]
	end
	for i=1,#s2.color do
		cstr.color[#s1.color+i] = s2.color[i]
	end

	return cstr
end

function Cstring.eq(s1,s2)
	return s1.string == s2.string
end