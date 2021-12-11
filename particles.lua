particles = {}

c_smoke = 240
c_fire = 240 + 4 
c_zap = 240 + 8
c_charge = 240 + 12

function particles:reset()
	for i,v in pairs(self) do
		if(type(i) == "number") then
			self[i] = nil
		end
	end
end

function particles:update(dt)
	for i,v in ipairs(self) do
		v:update(dt)
		if(v.dead) then
			table.remove(self,i)
		end
	end

	for x=0,Map.w do
		for y=0,Map.h do
			for i in ipairs(damageColor[x][y]) do
				if damageColor[x][y][i] > 0 and damageColor[x][y][i] < 0.01 then
					damageColor[x][y][i] = 0
				else
					damageColor[x][y][i] = damageColor[x][y][i]*(1-dt*4)
				end
			end
		end
	end
end

function particles:draw()
	for i,v in ipairs(self) do
		local p = v.pos
		local z = v.z
		local char = v.char
		local c = v.color
		--[[if(v.blink and blink) then
			c = {255,255,255-c[3]}
		end]]

		p = p - view
		if(p.x >= 0 and p.x <= Map.sw and p.y >= 0 and p.y <= Map.sh) then
			Graphics:put(char,c,p.x,p.y,z,v.overlay)
		end
		
	end
end

function particles:spawn(p,type,t)
	if(type == "string") then
		if(p:get(FOV)>0.5) then
			local s = t.s .. ""
			p = p - Pos:new(math.floor(#s/2),1)
			
			for i = 1, #s do
				local char = (string.byte(s, i))
				table.insert(self,Particle:create({char = char,x=p.x + i -1,y=p.y,vy = -50,f=12,c1 = t.c, t = math.random()*0.3+0.6,z =20, overlay = true}))
			end
		end
	elseif(type == "explosion") then
		for i = 1,12 do
			table.insert(self,Particle:create({char = c_fire,x=p.x + math.random()*4-2, y=p.y+ math.random()*4-2, c1={1,1,0}, c2={0.8,0,0}, t = math.random()*3,animate = true,z=2}))
		end
		for i = 1,80 do
			local rand = math.random()
			local c = {rand*0.4+0.6,rand*0.4+0.6,rand*0.4+0.6}
			table.insert(self,Particle:create({char = c_smoke,x=p.x, y=p.y, vx = math.random()*80-40,vy = math.random()*80-40,ay = -20, f=8, c1=c, c2={0.4,0.4,0.4}, t = -math.log(math.random()+0.1),animate = true}))
		end
	elseif(type == "boost") then
		for i = 1,10 do
			table.insert(self,Particle:create({char = toChar("+"),x=p.x, y=p.y, vx = math.random()*40-20,vy = math.random()*40-20,ay = -90, f=5, c1={0,0.4,0},c2 = {0.4,0.8,0.4}, t = math.random()*0.4,overlay = true}))
		end
	elseif(type == "charge") then
		--[[for x=0,Map.w do
			for y=0,Map.h do
				q = Pos:new(x,y)
				if(q:get(t.field)) then
					table.insert(self,Particle:create({char = c_charge,x=x, y=y, c1={100,0,100},c2 = {255,255,255}, t = math.random()*0.4,animate = true}))
				end
			end
		end]]
		for i = 1,15 do
			table.insert(self,Particle:create({char = c_charge,x=p.x+math.random()*5-2, y=p.y + math.random()*5-2, c1={0.4,0,0.4},c2 = {1,1,1}, t = math.random()*0.4,animate = true}))
		end
	end
end

Particle = {}

function Particle:create(t)
	local new = {}
	setmetatable(new, self)
	self.__index = self
	
	new.x = t.x
	new.y = t.y
	new.pos = Pos:new(new.x,new.y):floor()
	new.z = t.z or 10
	new.vx = t.vx or 0
	new.vy = t.vy or 0
	new.ax = t.ax or 0
	new.ay = t.ay or 0
	new.f = t.f or 0
	new.animate = t.animate
	new.overlay = t.overlay

	new.c1 = t.c1 or {150,150,150}
	new.c2 = t.c2 or new.c1
	new.color = {new.c1[1],new.c1[2],new.c1[3]}

	new.dead = false
	new.age = 0
	new.time = t.t or 1.0

	new.char = t.char or c_bulletActive
	new.firstChar = new.char

	return new
end

function Particle:update(dt)
	self.age = self.age + dt

	self.vx = self.vx + self.ax*dt
	self.vy = self.vy + self.ay*dt

	self.vx = self.vx*(1-dt*self.f)
	self.vy = self.vy*(1-dt*self.f)

	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt

	if(self.animate) then
		self.char = self.firstChar + math.floor((self.age/self.time)*4)
	end

	for i in ipairs(self.color) do
		self.color[i] = lerp(self.c1[i],self.c2[i],self.age/self.time)
	end

	if(self.age>self.time) then
		self.dead = true
	end

	self.pos = Pos:new(math.floor(self.x),math.floor(self.y))
end

function Particle:draw()
	
end


