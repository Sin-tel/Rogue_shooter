Tunneler = {}



function Tunneler:new(pos,dir) 
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	new.pos = pos or Pos:random()

	new.dir = dir or Dir:random()

	new.time = 0
	new.maxTime = math.random(10,120)
	new.dead = false

	new.turn = math.random(10,20)

	new.w = 2
	--[[if(math.random()<0.2) then
		new.w = 1
	end]]
	if(math.random()<0.2) then
		new.w = 3
	end

	return new
end

function Tunneler:update()
	Level.space = Level.space + self.w*2-1

	Level:put(self.pos,"floor")
	if(self.w >= 2) then
		Level:put(self.pos+(self.dir+1),"floor")
		Level:put(self.pos+(self.dir-1),"floor")
	end
	if(self.w >= 3) then
		Level:put(self.pos+(self.dir+1)+(self.dir+1),"floor")
		Level:put(self.pos+(self.dir-1)+(self.dir-1),"floor")
	end

	self.pos = self.pos + self.dir

	if((self.pos):get(map) == 0 and self.time>5) then
		self.dead = true
	end

	if(self.turn<0) then
		local nd = 0
		if(math.random()<0.5) then
			nd = self.dir-1
		else
			nd = self.dir+1
		end

		if(math.random()<0.5) then
			local np = self.pos - nd
			table.insert(Level.tunnelers, Tunneler:new(np,-nd))
		else
			self.dir = nd

			if(self.w >= 2) then
				self.pos = self.pos - nd
			end
			if(self.w >= 3) then
				self.pos = self.pos - nd
			end
		end
		if(math.random()< 0.2) then
			self.time = 0
			local l = math.random(2,4)
			for x = -l,l do
				for y = -l,l do
					local pp = Pos:new(x,y)
					Level:put(self.pos+pp,"floor")
				end
			end
		end
		self.turn = math.random(7,15)
	end

	self.time = self.time + 1
	self.turn = self.turn - 1
	if(self.time >= self.maxTime or  (not self.pos:inBounds())) then
		self.dead = true
	end
end

function makeRoom(pos,dir)
	local w = math.random(4,12)
	local h = math.random(4,12)

	local p = pos + dir 

	local door = p
	

	local xstart = 0
	if(dir.x == 0) then
		xstart = -math.random(0,w)
	elseif(dir.x == -1) then
		xstart = -w
	end
	local ystart = 0
	if(dir.y == 0) then
		ystart = -math.random(0,h)
	elseif(dir.y == -1) then
		ystart = -h
	end

	p = p+dir

	local free = true
	for x=xstart-1,xstart+w+1 do
		for y=ystart-1,ystart+h+1 do
			local pp = p + Pos:new(x,y)
			if(pp:get(map) == 0 or not pp:inBounds()) then
				free = false
			end
		end
	end
	if(free) then
		Level.space = Level.space + w*h
		--if(math.random()<0.5) then -- make secret room without door sometimes
			Level:put(door,"floor")
		--end
		for x=xstart,xstart+w do
			for y=ystart,ystart+h do
				local pp = p + Pos:new(x,y)
				Level:put(pp,"floor")
			end
		end
	end

end

function makeHall(pos,dir)
	local pc = pos
	local len = 1
	local free = false
	--search for next open space to connect to, if it is not found, no hall is made
	for i = 1,20 do
		pc = pc + dir
		if(pc:get(map) == 0) then
			len = i-2
			--if(i > 5) then
				free = true --make hall when long enough
			--end
			break
		end
	end

	-- w,h are the proposed width for the hall (0 -> 1 tile wide)
	local w = 0--math.random(0,3)
	local h = 0--math.random(0,3)

	-- xo, yo are the offsets to search for hall placement
	-- search is widened by 1 cell perpendicular to dir
	local xo = 1
	local yo = 1

	if(dir.x == 0) then
		yo = 0
		h = len
	end
	if(dir.y == 0) then
		xo = 0
		w = len
	end
	
	local p = pos+dir

	--find starting locations based on p
	local xstart = 0
	if(dir.x == 0) then
		xstart = -math.random(0,w)
		
	elseif(dir.x == -1) then
		xstart = -w
	end
	local ystart = 0
	if(dir.y == 0) then
		ystart = -math.random(0,h)
		xo = 0
	elseif(dir.y == -1) then
		ystart = -h
	end


	--search for space with only walls
	for x=xstart-xo,xstart+w+xo do
		for y=ystart-yo,ystart+h+yo do
			local pp = p + Pos:new(x,y)
			if(pp:get(map) == 0 or not pp:inBounds()) then
				free = false
			end
		end
	end
	--if legal, build the hall
	
	
	if(free) then
		Level.space = Level.space + (w+1)*(h+1)
		for x=xstart,xstart+w do
			for y=ystart,ystart+h do
				local pp = p + Pos:new(x,y)
				Level:put(pp,"floor")
			end
		end
	end
	--[[Level:put(p + Pos:new(xstart,ystart),"vent")
	Level:put(p + Pos:new(xstart+w,ystart+h),"vent")]]
end
