Pos = {}

function Pos:new(x,y)
	local new = {}	
	setmetatable(new, self)
	self.__index = self
	self.__add = self.add
	self.__sub = self.sub
	self.__mul = self.mul
	self.__eq = self.eq

	new.x = x
	new.y = y

	return new
end

function Pos:get(map)
	if(map[self.x] and (map[self.x][self.y] ~= nil)) then
		return map[self.x][self.y]
	else
		return map.default
	end
end

function Pos:getEntities()
	local list = {}
	for k,v in pairs(entities) do		
		if(self==v.pos) then
			table.insert(list,v)
		end
	end
	return list
end

function Pos:set(map,val)
	if(map[self.x]) then
		map[self.x][self.y] = val
	end
end

function Pos:los(pos2)
	local d = normVector(self,pos2)
	local l = self + Pos:new(math.random(),math.random()) -- monte carlo sampling (?)

	local dist = dist(self,pos2)
	for i = 0,dist do
		local lf = l:floor()
		if (lf:get(map) > 200) then
			return false
			--break
		end
		l = l + d
	end
	return true
end

function Pos:random()
	return self:new(math.random(2,Map.w-1),math.random(2,Map.h-1))
end

function Pos:passable(creatures)
	local check = (not self:get(solid))

	if(creatures and check) then
		for i,v in pairs(self:getEntities()) do
			if(v.solid) then
				check = false
				break
			end
		end
	end

	return check
end

function Pos:inBounds()
	if(self.x > 0 and self.x<Map.w and self.y > 0 and self.y<Map.h) then
		return true
	else
		return false
	end
end

function Pos:floor()
	return self:new(math.floor(self.x),math.floor(self.y))
end

function Pos.add(p1,p2)
	return Pos:new(p1.x+p2.x,p1.y+p2.y)
end

function Pos.sub(p1,p2)
	return Pos:new(p1.x-p2.x,p1.y-p2.y)
end

function Pos.mul(p1,r)
	return Pos:new(p1.x*r,p1.y*r)
end

function Pos.eq(p1,p2)
	return p1.x == p2.x and p1.y == p2.y
end


Dir = {}

Dir.pos = {Pos:new(1,0),Pos:new(0,1),Pos:new(-1,0),Pos:new(0,-1)}

function Dir:new(r)
	local new = {}	
	setmetatable(new, self)
	self.__index = self
	self.__add = self.add
	self.__sub = self.sub
	self.__unm = self.unm


	new.r = (r-1)%4 + 1
	new.x = self.pos[new.r].x
	new.y = self.pos[new.r].y
	return new
end

function Dir:getAll()
	local d = Dir:new(1)
	return {(d),(d+1),(d+2),(d+3)}
end

function Dir:random()
	return self:new(math.random(4))
end

function Dir.unm(r1)
	local r = 1
	if(r1.r == 1) then
		r = 3
	elseif(r1.r == 2) then
		r = 4
	elseif(r1.r == 3) then
		r = 1
	elseif(r1.r == 4) then
		r = 2
	end
	return Dir:new(r)
end

function Dir.add(r1,r)
	return Dir:new(r1.r+r)
end

function Dir.sub(r1,r)
	return Dir:new(r1.r-r)
end

function normVector(p1,p2)
	local dist =  dist(p1,p2)
	local d = p2 - p1

	if(dist == 0) then
		return Pos:new(1,0)
	else
		return Pos:new(d.x/dist,d.y/dist)
	end
end

function dist(p1,p2,squared)
	local dsq = (p1.x-p2.x)^2 + (p1.y-p2.y)^2 
	if(squared) then
		return dsq
	else
		return math.sqrt(dsq)
	end
end

function manh(p1,p2)
	return math.abs(p1.x-p2.x) + math.abs(p1.y-p2.y)
end

function cheby(p1,p2)
	return math.max(math.abs(p1.x-p2.x), math.abs(p1.y-p2.y))
end

function rotateVector(v , a)
	local x = v.x
	local y = v.y

	v.x = x*math.cos(a) - y*math.sin(a)
	v.y = x*math.sin(a) + y*math.cos(a)

	return v
end