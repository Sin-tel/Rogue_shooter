--[[
Working title: Hive
TWO OLD WAYS:
CHURCH OF MEKHANE
SARKICISM

-> android > both but low hp/handicap

TODO
[x] inventory
[x] pick-up
[x] doors
[x] graphics handling + z-buffer
[x] fix damage class
[x] AoE damage (cone,circle,line)
[x] colored string class
[x] ammo/bullet handling
[x] new system for equipping
[x] corpses
[x] grenade
[x] make 2 more weapons
[x] make 2 more items
[x] make movement faster in relation to other actions
[x] slide door
[x] ammo drops
[x] particles
[x] redesign hp
[x] level gen
[x] ai vision
[x] ai pathing
[x] implement AI states/trees/utility?
[-] visual ammo/reloading
[ ] add fleeing
[ ] make ranged enemy
[ ] effects system (~ damage types)
[ ] ongoing status effects
[ ] fix console Cstring (remove console??)
[ ] crits?
[ ] armor
[ ] generate treasure rooms w/ enemies
[ ] add vents
[ ] sound implementation
[ ] how to handle automatic guns vs non-automatic? --> volleys
[ ] sound implementation
[ ] more level scenery
[x] plants
[x] slow terrain -> Dijkstra?
[ ] widescreen support (variable resolution or emulated monitor?) 
[ ] level loading en exits
[ ] basic sfxr sounds
[ ] sound generation
[ ] gun knockback 
[ ] destructible terrain??
[ ] generative music system
[ ] digging worms (can go through walls or underground?)
]]

require 'cstring'
require 'graphics'
require 'level'
require 'factory'
require 'ammo'
require 'damage'
require 'map'
require 'dijkstra'
require 'pos'
require 'gui'
--require 'console'
require 'particles'

--print console directly
io.stdout:setvbuf("no")

--set window & canvas
width = 1280  
height = 720 
love.window.setMode(width,height,{vsync=true,fullscreen=false})
canv = love.graphics.newCanvas(640,360)
blurCanvas = love.graphics.newCanvas(640,360)
--total tiles: 60*45

--time related globals
turns = 0
t = 0
speed = 1.0
dturns = 0

time = 0
blink = false

--graphics related globals
view = Pos:new(0,0)
viewPreFilter = Pos:new(0,0)

drawmap = false

offsetx = 0
offsety = 0

shake = 0
hitShake = 0
shakeColor = {1,0,0}

--globals
font = love.graphics.newFont("E4.ttf", 8)

godmode = false

mouseP = Pos:new(0,0)
mouseX,mouseY = 0,0

action = nil

entities = {}

teams = {"predator","player","prey"}

function love.load()
	math.randomseed(os.time())

	Graphics:load()

	love.graphics.setFont(font)
	canv:setFilter("nearest", "nearest")
	blur = love.graphics.newShader("blur.glsl")
	blur:send("size", {blurCanvas:getWidth(), blurCanvas:getHeight()})

	scanlines = love.graphics.newImage("scanlines.png")

	font = love.graphics.newImage( "tile.png" )
	quads = {}
	for i=0,255 do
		quads[i] = love.graphics.newQuad((i%16)*8, math.floor(i/16)*12, 8, 12, font:getWidth(), font:getHeight())
	end	
	batch = love.graphics.newSpriteBatch(font, 3000,"stream")

	gui:load()
	--console:load()
	Cstring:load()

	scent = Map:new(0)
	damage = Map:new(0)
	damageColor = Map:new({0,0,0})
	FOV = Map:new(0)  

	Level:generate()

	for k,v in pairs(teams) do
		teamD[v] = Dijkstra:new()
		teamF[v] = Dijkstra:new()
	end
	meatD = Dijkstra:new()
	
	player = factory.player()

	
	player.pos = Pos:new(40,30)
	Level:addRandom(player)
	
	for i=1,20 do 
		Level:addRandom(factory.rat())
	end

	for i=1,6 do 
		Level:addRandom(factory.worm())
	end

	for i=1,10 do 
		Level:addRandom(factory.cleaver())
	end


	for i=1,3 do 
		Level:addRandom(factory.staminaBoost())
		Level:addRandom(factory.staminaBoost2())
	end

	for i=1,3 do 
		Level:addRandom(factory.shotgun())
		Level:addRandom(factory.laser())
		Level:addRandom(factory.grenade())
		Level:addRandom(factory.grenade())
		Level:addRandom(factory.ammoBox(ammo.pistol,math.random(1,3)*6))
		Level:addRandom(factory.ammoBox(ammo.shotgun,math.random(2,7)*2))
		Level:addRandom(factory.ammoBox(ammo.battery,math.random(6,30)))
	end
	

	player.inventory:add(factory.knife())
	player.inventory:add(factory.revolver())
	player:event("select",{index = 1})
	player:event("select",{index = 2})

end

function act(dt)
	if(player.counter.time<=0) then
		speed = 1.0


		local dir = 0
		if(not action) then
			if     love.keyboard.isDown('w') then dir = 4; action='move'
			elseif love.keyboard.isDown('a') then dir = 3; action='move'
			elseif love.keyboard.isDown('s') then dir = 2; action='move'
			elseif love.keyboard.isDown('d') then dir = 1; action='move'
			end
		end
   
		if(action == 'move') then
			player:event('move',{dir = Dir:new(dir)})

		elseif(action == 'left') then
			player:event("use",{name = "ranged", target = mouseP})

		elseif(action == 'right') then
			player:event("use",{name = "melee", target = mouseP})

		elseif(action == 'select') then
			player:event("select",{index = action_select})

		elseif(action == 'pickup') then
			player:event("pickup")

			for k,v in pairs(Dir:getAll()) do
				for l,w in pairs((player.pos+v):getEntities()) do
					w:event("interact")
				end
			end

			player:event("wait",{time = 10})
		elseif(action == 'reload') then
			player:event("reload")
		end

		action = nil
	else
		dturns = dturns + 1
		t = t +1
		speed = math.min(1.0,speed + 0.1)

		local start = love.timer.getTime()


		for k,v in ipairs(teams) do

			if(k == t%10 and v ~= "player") then
				list = {}
				for j,e in pairs(entities) do
					if(e.team == v) then
						table.insert(list,e.pos)
					end
				end
				if(v == "prey" and #list<10) then
					Level:addRandom(factory.rat())
					print("added rat")
				end

				
				teamD[v]:calculateMG(list)
				

				teamF[v]:calculateFlee(teamD[v])
			end
			
			
		end
		local result = love.timer.getTime() - start
		if(result > 0.01) then
			print( string.format( "It took %.3f milliseconds to make map!", result * 1000 ))
		end
		if(t%10 == 8) then
			list = {}
			for j,e in pairs(entities) do
				if(e.food) then
					table.insert(list,e.pos)
				end
			end
			meatD:calculateMG(list)
		end

		--update
		for k,v in pairs(entities) do
			if(entities[k].dead) then
				entities[k]:event("death")
				entities[k] = nil
				if(v.hp) then
					--console:printDeath(v)
					particles:spawn(v.pos,"string",{s = "x_x", c = {180,20,20}})
				end
			else
				entities[k]:event("update")
			end
		end
		damageUpdate()
		updateScent()	
	end
end

function love.update(dt)	
	

	if love.keyboard.isDown('q') then slowmo() end
	--do non-turn timing
	shake = shake*(1.0-dt*10)
	hitShake = hitShake*(1.0-dt*30)
	blink = (time%0.1 < 0.05)
	blur:send("time", time)

	dt = dt

	time = time + dt
	
	particles:update(dt)
	
	--mouse input
	mouseX,mouseY = love.mouse.getPosition( )

	mouseX=mouseX/16
	mouseY=mouseY/16
	mouseP = Pos:new(mouseX+view.x+offsetx/8,mouseY+view.y+offsety/8):floor()
	 
	--do turns
	dturns = 0

	if(love.keyboard.isDown('lshift')) then
		player:event("wait",{time = 100*dt})
		--speed = 0.1
	end
	local turnspeed = 100*speed*dt
	
	turns = turns - turnspeed

	while(turns < 0) do -- turns per second
		act(dt)
		turns = turns + 1
	end

	-- calculate graphic-related stuff
	moveView(dt)
	doFov()
	gui:update()
end

function love.draw()
	love.graphics.setBlendMode("alpha")
	--calc glyphs
	Graphics:calculate()

	--draw glyphs batch
	love.graphics.setCanvas(canv)
	love.graphics.clear(0,0,0)
	batch:clear( )
	Graphics:draw()


	--draw to canvas
	love.graphics.setColor( 1, 1, 1)
	love.graphics.draw(batch)

	if drawmap then
		Graphics:drawMap()
	end

	--draw FPS counter
	love.graphics.setColor(0.6,0.4,0.6)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 2, 1)

	--bloom canvas
	love.graphics.setCanvas(blurCanvas)
	love.graphics.setShader(blur)
	love.graphics.clear(0,0,0)
    --chroma effect
	love.graphics.setBlendMode("add")
	love.graphics.setColor(1,0,0)
	love.graphics.draw(canv,-1-hitShake*2,0)
	love.graphics.setColor(0,1,0)
	love.graphics.draw(canv,0,0)
	love.graphics.setColor(0,0,1)
	love.graphics.draw(canv,1+hitShake*2,0)

	--draw canvas to screen
	local xo,yo = (love.graphics.getWidth()-width)/2,(love.graphics.getHeight()-height)/2

	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.clear(0,0,0)


	
	love.graphics.setBlendMode("add")

	love.graphics.setColor( shakeColor)
	love.graphics.draw(canv,xo+shake*rnd()-hitShake+1,yo+shake*rnd()+1, 0, 2)
	
	love.graphics.setColor(1-shakeColor[1], 1-shakeColor[2], 1-shakeColor[3])
	love.graphics.draw(canv,xo+shake*rnd()+hitShake  ,yo+shake*rnd()  , 0, 2)

	--draw scanlines TODO: render without image
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(1, 1, 1,math.min(1,0.4 + hitShake*0.6))
	-- love.graphics.draw(scanlines,xo,yo)



 	--draw bloom to screen
 	love.graphics.setBlendMode("add", "premultiplied")
	love.graphics.setColor( 1,1,1)
	-- love.graphics.draw(blurCanvas,xo,yo, 0, 2)

	love.graphics.setColor(0.02+hitShake*0.05,0.02,0.02)
	love.graphics.rectangle("fill", xo, yo, width, height)
	
	
end

function love.mousepressed( x, y, button )
	if(mouseX < Map.sw and mouseY < Map.sh) then
		if(button == 1) then
			action = 'left'
		elseif(button == 2) then
			action = 'right'
		end
	else
		gui:mousepressed(button)
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit( )
	elseif key == "m" then
		drawmap = not drawmap 
	elseif key == "g" then
		godmode = not godmode
		FOV = Map:new(0)  
		--console:println("Switched godmode", {150,150,0})
	elseif key == "space" then
		action = 'pickup'
	elseif key == "r" then
		action = "reload"
	elseif key == "z" then
		Level:generate()
	elseif type(tonumber(key)) == "number" then
		action = 'select'
		action_select = tonumber(key)
		if action_select == 0 then
			action_select = 10
		end
	end

end

function rnd()
	return (math.random()-0.5)*2
end

function toChar(c)
	return string.byte(c)
end

function doFov()
	--fov angle steps should be 1/200, but the MC sampling makes it perform good at 1/20 or so
	for a = 0,math.pi*2, 1/50 do
		--local a = math.random()*math.pi*2
		local d = Pos:new(math.cos(a),math.sin(a))
		local l = player.pos + Pos:new(math.random(),math.random()) --monte carlo sampling
		for i = 0,12 do
			l = l + d
			local lf = l:floor()
			if(i<8) then
				lf:set(FOV,1.0)
			else
				lf:set(FOV,math.max(0.5,lf:get(FOV)))
			end
			if (lf:get(blockFOV)) then
				break
			end
			
		end
	end
	for x = -1,1 do
		for y = -1,1 do
			local p = player.pos+Pos:new(x,y)
			p:set(FOV,1.0)
		end
	end

	for x=0,Map.sw do
		for y=0,Map.sh do
			local p = Pos:new(x,y) + view
			local f = p:get(FOV)

			if(f>0.5) then
				p:set(FOV,math.max(0,p:get(FOV)-dturns*0.01))
			end

			if(godmode) then
				p:set(FOV,1)
			end
		end
	end
end

function updateScent()
	

	if(t%10 == 7) then
		for x=0,Map.w do
			for y=0,Map.h do
				if(scent[x][y] > 0) then
					scent[x][y] = scent[x][y] -1
				end
			end
		end
	end

	if(t%30 == 5) then
		local nScent = {}
		for x=0,Map.w do
			nScent[x] = {}
			for y=0,Map.h do
				nScent[x][y] = scent[x][y]
			end
		end
		for x=0,Map.w do
			for y=0,Map.h do
				if(scent[x][y] > 0 and not solid[x][y]) then
					local val = scent[x][y]

					for i,v in pairs({{0,1},{0,-1},{1,0},{-1,0}}) do
						local tx = x + v[1]
						local ty = y + v[2]

						if(not solid[tx][ty] and nScent[tx][ty] < val - 1) then
							nScent[tx][ty] = val - 1
						end
					end
				end
			end
		end
		scent = nScent
	end

	

end

function moveView(dt)
	--limit camera movement to view
	local mouseX = math.min(mouseX,Map.sw)
	local mouseY = math.min(mouseY,Map.sh)


	viewPreFilter.x = lerp(viewPreFilter.x, (player.pos.x*0.9+(mouseX+viewPreFilter.x)*0.1)-20,dt*10)
	viewPreFilter.y = lerp(viewPreFilter.y, (player.pos.y*0.9+(mouseY+viewPreFilter.y)*0.1)-15,dt*10)

	view = viewPreFilter:floor()
	
	offsetx = math.floor((viewPreFilter.x-view.x)*8)
	offsety = math.floor((viewPreFilter.y-view.y)*8) 
	--[[
	if(view.x<0) then
		view.x = 0
		offsetx = 0
	end

	if(view.y<0) then
		view.y = 0
		offsety = 0
	end
	
	if(view.x+41>Map.w) then
		view.x = Map.w-41
		offsetx = 8
	end

	if(view.y+31>Map.h) then
		view.y = Map.h-31
		offsety = 8
	end]]
end

function lerp(a, b, k) --smooth transitions
    return a * (1-k) + b * k 
end

function slowmo()
	--love.timer.sleep(1/30)
	speed = 0.2
	--slowmoTime = t + 3
end

function LOS(p1,p2,r)

	local angle = math.atan2( (p2.y-p1.y), (p2.x-p1.x) )


	local d = Pos:new(math.cos(angle),math.sin(angle))
	local l = p1 + Pos:new(0.5,0.5)

	for i = 1,r do
		local lf = l:floor()
		if (not lf:passable(false)) then
			return false
		elseif(lf == p2) then
			return true
		end
		l = l + d
	end

	return false
end