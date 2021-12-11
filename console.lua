console = {}

function console:load()
	self.x = 8
	self.y = 32*8

	self.cursor = 1

	self.w = 29
	self.h = 13

	self.colors = {}
	self.lines = {}
	for j = 1,self.h do
		self.colors[j] = {}
		self.lines[j] = {}
		for i = 1,self.w do
			self.colors[j][i] = {0.6,0.6,0.6}
			self.lines[j][i] = 0
		end
	end

	--self:println("You wake up.")
end 

function console:draw()
	local c = 0
	for j in ipairs(self.lines) do
		--print(j,#self.lines-j+1)
		for i = 1,self.w do

			c = self.lines[#self.lines-j+1][i]
			c = c or 0
			
			local color = self.colors[#self.lines-j+1][i]
			batch:setColor(color[1],color[2],color[3])
			batch:add(quads[c],(i-1)*Cstring.cw+self.x,(j-1)*Cstring.cw+self.y)
		end
	end

	
end

function console:println(s,col)
	self:print(s,col)
	self:print("\n")
end

function console:print(s,col)
	col = col or {0.6,0.6,0.6}

	for j = 1,#s do
		if(string.byte(s, j) == string.byte('\n')) then
			self:newline()
		else
			self.lines[self.h][self.cursor]=string.byte(s, j)
			self.colors[self.h][self.cursor] = col 
			self.cursor = self.cursor + 1
			if(self.cursor > self.w) then
				self:newline()
			end
		end
	end

end

function console:newline()
	self.cursor = 1
	for i=1,(#self.lines-1) do
		for j = 1,self.w do
			self.lines[i][j]=self.lines[i+1][j]
			self.colors[i][j] = self.colors[i+1][j]
		end
	end

	for j = 1,self.w do
		self.lines[self.h][j]= 0
		self.colors[self.h][j] = {0.6,0.6,0.6}
	end
end

--deprecated
function console:printDamage(damage,subject)
	if(damage.origin == player) then
		self:print("You ",player.color)
		self:print("hit ")
	else
		self:print("The ")
		self:print(damage.origin.name,damage.origin.color) 
		self:print(" hits ")
	end

	if(subject == player) then
		if(damage.origin == player) then
			self:print("yourself ",player.color)
		else
			self:print("you ",player.color)
		end
	else
		self:print("the ")
		self:print(subject.name,subject.color)
		self:print(" ")
	end
	self:print("" .. damage.val )
	--[[if(damage.weapon) then
		self:print(" (" )
		self:print(damage.weapon.name,damage.weapon.color)
		self:print(")")
	end]]
	self:println(".")
end

function console:printDeath(subject)
	if(subject == player) then
		self:print("You ",player.color)
		console:println(" died.")
		console:println("------------")
		console:println(" GAME OVER!" , {0.6,0.2,0.2})
		console:println("------------")
	else
		--[[console:print("The ")
		self:print(subject.name,subject.color)
		console:println(" dies.")]]
	end
end
