--[[

Everything for displaying the scrolling maps

]]
Graphics = {}

function Graphics:load()
	self.screen = Map:new(0,true) 
	self.screen_c = Map:new({1,1,1},true) 
	self.bg_c = Map:new({0,0,0},true)  

	self.zbuffer = Map:new(0,true) 
	self.overlay = Map:new(false,true) 


	self.cw = 8
	self.ch = 12
end 

function Graphics:draw()
	for x=0,Map.sw do
		for y=0,Map.sh do
			local p = Pos:new(x,y) + view
			local c = self.bg_c[x][y]
			local f = p:get(FOV)

			if(self.overlay[x][y]) then
				f = 1.00
				c = {c[1]*0.3,c[2]*0.3,c[3]*0.3}
			end

			--make edges smooth
			f = f * math.min(1.0,(Map.sw-(x-offsetx/8)))
			f = f * math.min(1.0,(Map.sh-(y-offsety/8)))


			if(c[1]>=0.01 or c[2] >=0.01 or c[3] >= 0.01) then
				self:drawGlyph(c_fill,c,f,x,y)
			end
			
			local c = self.screen_c[x][y]
			local char = self.screen[x][y]

			if(char>0) then
				self:drawGlyph(char,c,f,x,y)
			end
		end
	end
	
	gui:draw()
	--console:draw()

	--draw mouse highlight
	if(mouseX < Map.sw and mouseY < Map.sh) then
		local mp = mouseP - view
		Graphics:drawGlyph(c_select,{0.4,0.4,0.4},1,mp.x,mp.y)
	end
end 

function Graphics:drawGlyph(char,c,f,x,y)
	batch:setColor({c[1]*f,c[2]*f,c[3]*f})
	x = x*8-offsetx 
	y = y*8-offsety

	--x = x + math.floor(1*math.sin(y/30+3*time))
	--y = y + math.floor(1*math.sin(x/30-3*time))

	batch:add(quads[char],x,y)
end

function Graphics:calculate()
	-- put characters on screen
	for x=0,Map.sw do
		for y=0,Map.sh do

			local p = Pos:new(x,y) + view
			Graphics:reset(x,y) 
			local f = p:get(FOV)

			if(f>0.01) then
				local z = 1
				local char = p:get(map)
				local c = p:get(map_c)
				local bc = p:get(damageColor)

				
					--local v = p:get(teamF["predator"]) or 0
					--bc = {0,v*3,v*10}
				

				if(char == c_wall) then
					bc = c
					z = 5
				end
				--[[if(p:get(blockFOV)) then
					z = 5
				end]]
				
				Graphics:put(char,c,x,y,z)
				--print(z)
				self.bg_c[x][y] = bc
			end


		end
	end

	for i,v in pairs(entities) do
		local p = v.pos
		local z = v.z
		local char = 0
		local c = {0.4,0.4,0.4}
		local f = p:get(FOV)

		if(f>0.01) then
			if  (f>0.5) then
				char = v.char
				c = v.color
				if(v.blink and blink) then
					c = {1,1,1-c[3]}
				end
			end

			if(char>0) then
				p = p - view
				if(p.x >= 0 and p.x <= Map.sw and p.y >= 0 and p.y <= Map.sh) then
					Graphics:put(char,c,p.x,p.y,z)
				end
			end
		end
	end

	particles:draw()
end 


function Graphics:drawMap()
	local px = 8
	local py = 8*(Map.sh+1)
	local list = {}
	for x=0,Map.w do
		for y=0,Map.h do
			--if(FOV[x][y] > 0) then

				v = 20/255

				if(map[x][y] == c_wall) then
					v = v + 80/255
				end
				
				--v = v + 30*math.floor(FOV[x][y]+0.4)
				--[[love.graphics.setColor(100, 100, 100,75)
				
				love.graphics.rectangle("fill", px + x*1, py + y*1, 1, 1)]]
				table.insert(list,{px + x,py + y, v,v,v})
			--end
		end
	end
	love.graphics.setColor(1, 1, 1,1)
	love.graphics.points(list)
end 

function Graphics:reset(x,y) 
	self.screen[x][y] = 0
	self.bg_c[x][y] = {0,0,0}
	self.zbuffer[x][y] = 0
	self.overlay[x][y] = false
end

function Graphics:put(char,c,x,y,z,overlay) 
	if z >= self.zbuffer[x][y] then
		self.screen[x][y] = char
		self.screen_c[x][y] = c
		self.zbuffer[x][y] = z
		self.overlay[x][y] = overlay
	end
end