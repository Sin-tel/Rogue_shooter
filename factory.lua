require 'component'
require 'entity'

factory = {}


function factory.player()
	local new = Entity:new('@',{0.24,0.67,0.67},"Jake Emmerson")

	new.team = "player"

	factory.isCreature(new,100)
	new.move.speed = 12

	new:addComponent(Regenerate:new(500))
	new:addComponent(Inventory:new())

	local equipment = Equipment:new()
	equipment:addSlot("melee",factory.fist())
	equipment:addSlot("ranged")
	new:addComponent(equipment)

	new:addComponent(Scent:new())

	return new
end


function factory.corpse(e)
	local new = Entity:new('%',{0.5,0.1,0.2}, e.name  .. " corpse")
	factory.isItem(new,5)
	new.solid = false
	new:addComponent(Food:new(math.floor(e.hp.maxHp/3)))

	--Level:put(e.pos,"blood")

	return new
end

function factory.rat()
	local new = Entity:new('r', {0.4,0.2,0.2}, "Rat")

	new.team = "prey"

	factory.isCreature(new,2)
	new.move.speed = 12

	new:addComponent(Ai:new({Wander:new(), Flee:new("predator"), Flee:new("player",P_HIGH), Attack:new(P_LOW), FindFood:new() }))

	local equipment = Equipment:new()
	equipment:addSlot("attack",factory.bite())
	new:addComponent(equipment)

	return new
end

function factory.worm()
	local new = Entity:new('w', {0.67,0.15,0.3}, "Giant worm (head)")

	new.team = "prey"

	factory.isCreature(new,40)
	new.move.speed = 5

	new:addComponent(Ai:new({Wander:new(), Attack:new()}))

	local equipment = Equipment:new()
	equipment:addSlot("attack",factory.bite())
	new:addComponent(equipment)

	local segments = {}
	local len = math.random(3,6)
	for i=1,len do
		local c = "o"
		if(i == len-1) then
			c= "r"
		elseif(i == len) then
			c= "m"
		end
		local segment = factory.wormTail(c)
		Level:addEntity(new.pos,segment)
		table.insert(segments,segment)
	end

	new:addComponent(Tail:new(segments))

	return new
end

function factory.wormTail(c)
	local new = Entity:new(c, {0.6,0.1,0.2}, "Giant worm (body)")

	new:addComponent(Hp:new(10))
	new:addComponent(Corpse:new())
	new.z = 4
	new.solid = true

	new:addComponent(Regenerate:new(50))
	return new
end


function factory.cleaver()
	local new = Entity:new('c', {0.5,0.2,0.6},"Cleaver")

	new.team = "predator"

	factory.isCreature(new,10)
	new.move.speed = math.random(9,15)

	new:addComponent(Ai:new({Wander:new(),Attack:new(), Approach:new("prey",P_LOW), Approach:new("player",P_NORMAL), FindFood:new() }))

	new:addComponent(Regenerate:new(200))


	local equipment = Equipment:new()
	equipment:addSlot("attack",factory.claws())
	new:addComponent(equipment)

	return new
end

function factory.bite()
	local new = Entity:new("?",{0.6,0.2,0.15},"Bite")
	factory.isMelee(new,2,25)

	return new
end

function factory.claws()
	local new = Entity:new('?',{130,140,130},"claws")
	factory.isMelee(new,5,20)

	new.type = "melee"
	return new
end

function factory.fist()
	local new = Entity:new("?",{0.5,0.4,0.3},"Fist")
	factory.isMelee(new,1,30)

	return new
end

function factory.revolver()
	local new = Entity:new(']',{0.35,0.35,0.6},"Revolver")
	factory.isItem(new)
	new:addComponent(Gun:new(ammo.pistol,5,6,0.9))
	new.type = "ranged"
	
	return new
end

function factory.shotgun()
	local new = Entity:new('}',{0.35,0.35,0.6},"Shotgun")
	factory.isItem(new)
	new:addComponent(Gun:new(ammo.shotgun,10,2,0.6))
	new.gun.shake = 12
	new.type = "ranged"
	
	return new
end

function factory.laser()
	local new = Entity:new(']',{0.6,0.35,0.8},"Laser gun")
	factory.isItem(new)
	new.type = "ranged"

	new:addComponent(Laser:new(10,2))

	return new
end

function factory.knife()
	local new = Entity:new('|',{0.5,0.55,0.5},"Knife")
	factory.isItem(new)
	factory.isMelee(new,3,20)

	new.type = "melee"
	
	return new
end

function factory.grenade()
	local new = Entity:new(c_bullet,{0.8,0.4,0.15},"Grenade")
	factory.isItem(new,20)
	
	new:addComponent(Remove:new(false))
	new:addComponent(Projectile:new())
	new:addComponent(Grenade:new(120))
	

	new.type = "ranged"
	
	return new
end

function factory.staminaBoost()
	local new = Entity:new('+',{0.15,0.7,0.15},"Injector")
	factory.isItem(new,5)

	new:addComponent(Boost:new(0.1))
	new:addComponent(Remove:new(true))

	return new
end

function factory.staminaBoost2()
	local new = Entity:new('+',{0.25,0.8,0.25},"Injector II")
	factory.isItem(new,2)

	new:addComponent(Boost:new(0.3))
	new:addComponent(Remove:new(true))

	return new
end

function factory.ammoBox(ammo,amount)
	local new = Entity:new(c_box,{0.5,0.3,0.2},"Box of " .. ammo.name)
	new.solid = false

	new:addComponent(AmmoBox:new(ammo,amount))

	return new
end

function factory.door(p)
	local new = Entity:new('+',{0.5,0.5,0.4},"Blast door")
	new.solid = true
	new:addComponent(Door:new())

	Level:put(p,"door closed")
	p:set(solid,true)

	return new
end

function factory.doorSlide(p)
	local new = Entity:new('+',{0.4,0.6,0.6},"Slide door")
	new.solid = true
	new:addComponent(Door:new(true))

	p:set(solid,false)

	return new
end

function factory.isCreature(e,hp)   
	e.z = 4
	e:addComponent(Move:new())
	e:addComponent(Counter:new(math.random(10)))
	e:addComponent(Hp:new(hp))
	e:addComponent(Corpse:new())
	return e
end

function factory.isItem(e,stack)
	e.z = 3
	e.item = true
	e.maxStack = stack or 1
	e.solid = false
	return e
end

function factory.isMelee(e,damage,time)
	e:addComponent(Melee:new(damage,time))
	return e
end