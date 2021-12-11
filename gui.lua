gui = {}

c_bg = 0
c_select = 2
c_ammoF = 3
c_ammo = 4

function gui:load()
	self.x = 42
	self.y = 1

	self.w = 18
	self.h = Map.sh

	self.x_inv = 12

	self.w_dsc = 29
	self.h_dsc = math.floor(Map.sh*(8/12))


	self.str_player = Cstring:new()
	self.str_inv = Cstring:new()
	self.str_dsc = Cstring:new()
end 

function gui:mousepressed(button)
	if(self.highlight>0) then
		if(button == 1) then
			player:event("select",{index = self.highlight})
		elseif(button == 2) then
			local item = player.inventory:getItem(self.highlight)
			player:event("drop",{item = item})
		end
	end
end


function gui:update()
	local y = math.floor(mouseY*(8/12))
	if(mouseX>=Map.sw and 11<=y and y-self.x_inv<= 20) then
		self.highlight = y-self.x_inv
	else
		self.highlight = -1
	end

	self.str_player = Cstring:new()
	self.str_inv = Cstring:new()
	self.str_dsc = Cstring:new()

	local c = player.hp:getDescription().color[1]
	local hp,maxHp = player.hp:getHp()

	self.str_player = 
	player:getName() .. "\n" ..
	Cstring:new(hp .. "/" .. maxHp,c) .. "\n" .. "\n" .. "\n" .. "\n" .. "\n" .."\n" .."\n" .."\n" 


	for i in ipairs(player.equipment.slots) do
		local item = player.equipment.slots[i].item
		if(item) then
			if(item.gun) then
				local gun = item.gun
				self.str_player = self.str_player .. gun.bullet.name .. ": " .. player.inventory.ammo[gun.bullet] .. "\n"
				for j = 1 , gun.magSize do
					if(j<=gun.mag) then
						self.str_player = self.str_player .. string.char(c_ammoF)
					else
						self.str_player = self.str_player .. string.char(c_ammo)
					end
				end
			elseif(item.laser) then
				local gun = item.laser
				self.str_player = self.str_player .. "\n" .. gun.bullet.name .. ": " .. player.inventory.ammo[gun.bullet] .. "\n"
			end
		end
	end
	

	if(mouseP:get(FOV) > 0.5) then
		local list = mouseP:getEntities()
		local getInfo = nil

		local z = 0
		for i,v in pairs(list) do
			if(v.z > z) then
				z = v.z
				getInfo = v
			end

		end
	
		self:info(getInfo)
	end

	if(self.highlight>0) then
		self:info(player.inventory.items[self.highlight][1])
	end

	self.str_inv = Cstring:new("------------------",{0.4,0.4,0.4})

	for i=1,20 do
		local s =  Cstring:new()
		local item = player.inventory.items[i][1]

		if(i<11) then
			s = s .. Cstring:new("" .. i%10,{0.25,0.25,0.25})
		else
			s = s .. Cstring:new("-", {0.2,0.2,0.2})
		end

		if(item) then
			if(item.maxStack > 1) then
				local n = # player.inventory.items[i]
				if(n > 1) then
					s = s .. Cstring:new(n .. "x", {0.5,0.5,0.5})
				end
			end
			
			s = s .. Cstring:new(item.name, item.color)
			if(item.gun) then
				s = s .. Cstring:new(" " .. item.gun.mag .. "/" .. player.inventory.ammo[item.gun.bullet])
			end
			if(item.laser) then
				s = s .. Cstring:new(" " .. player.inventory.ammo[item.laser.bullet])
			end
		end
		s = s .. "\n"
		s:shorten(18)

		--s.string = string.sub(s.string, 1,10)
		
		self.str_inv = self.str_inv .. s
	end
end

function gui:info(e)
	if(e) then
		self.str_dsc = e:getName() .. "\n" .. e:event("description",{s = Cstring:new()}).s
	end
end

function gui:draw()
	--draw highlight equipped and mouse-over

	for i=1,20 do
		local item = player.inventory.items[i][1]
		if(player.equipment:isEquipped(item)) then
			for j=1,self.w do
				batch:setColor(1,1,1,0.1)
				batch:add(quads[c_bg],(j-1+self.x)*Graphics.cw,(i-1+self.x_inv+self.y)*Graphics.ch)
			end
		end
	end

	if(self.highlight>0) then
		for i=1,self.w do
			batch:setColor(1,1,1,0.1)
			batch:add(quads[c_bg],(i-1+self.x)*Graphics.cw,(self.highlight-1+self.x_inv+self.y)*Graphics.ch)
		end
	end

	for x=0,Map.sw do
		batch:setColor(0.6,0.6,0.6)
		batch:add(quads[16],x*Graphics.cw,self.h_dsc*Graphics.ch)
	end

	for y=0,44 do
		batch:setColor(0.6,0.6,0.6)
		batch:add(quads[18],41*Graphics.cw,y*Graphics.ch)
	end

	--[[for y=self.h_dsc+2,Map.h do
		batch:setColor(0.6,0.6,0.6)
		batch:add(quads[18],30*8,y*8)
	end]]


	self.str_player:draw(self.x, self.y, self.w)
	self.str_inv:draw(self.x, self.y+self.x_inv-1, self.w)
	self.str_dsc:draw(1, self.y+self.h_dsc+1, self.w_dsc)
end
