c_bullet1 = 16
c_bullet2 = 17
c_bullet3 = 18
c_bullet4 = 19
c_bullet = 21
c_bulletActive = 20

ammo = {}

function newAmmo(name,damage,shots)
	local new = {}

	new.name = name
	new.damage = damage or 5
	new.shots = shots or 1

	return new
end



ammo.pistol = newAmmo("9mm rounds",5)

function ammo.pistol.new(accuracy)
	local new = Entity:new("?",{1,1,1}, "bullet")

	new:addComponent(Projectile:new(accuracy,true))
	new.projectile.damage = ammo.pistol.damage
	new.solid = false

	return new
end

ammo.shotgun = newAmmo("shells",2,12)

function ammo.shotgun.new(accuracy)
	local new = Entity:new(c_bulletActive,{1,1,1}, "bullet")

	new:addComponent(Projectile:new(accuracy,true))
	new.projectile.damage = ammo.shotgun.damage
	new.solid = false

	return new
end

ammo.battery = newAmmo("energy cells")