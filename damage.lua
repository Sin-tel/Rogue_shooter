--[[

IDEA:
two damage types:
-force
-bleed

*force does direct damage
 - most weapons
 - explosions
 - electricity
*bleed does slowly does damage (bleed value / 100 turns)
 - rats
 - poison
 - fire

some things do both:
 - bullets


Damage types

wound
R	- fire/heat   (explosions, fire)        -> light things, on fire effect
G	- acid       (some organic enemies)     -> corrosion
Cy	- electric (robots, tasers)             -> stun, jam robots, force locks
Ye	- force  (explosions)                   -> knockback
Wh	- physical/normal (swords, bullets, ...)
B ?
Ma	- lasers?

effects
	- poison, sickness (ongoing)
	- on fire (ongoing)

corrupting, necrotic        -> causes random mutations, things growing on you, tumors, ...
  does no damage on its own
  only affects organic creatures

]]

function damageAdd(p,val)
	local dmg = p:get(damage)

	dmg = dmg + val

	p:set(damage,dmg)
end

function damageAoE(field,val)
	for x=0,Map.w do
		for y=0,Map.h do
			q = Pos:new(x,y)
			if(q:get(field)) then
				damageAdd(q,val)
			end
		end
	end
end

function AoE_circle(p,r,var)
	

	var = var or 0

	local field = map:new(false)

	local step = 1/(r+1)   --r+1 to improve accuracy with small radii

	for a = 0,math.pi*2, step do
		local d = Pos:new(math.cos(a),math.sin(a))
		local l = p + Pos:new(0.5,0.5)

		local rr = r * ((1.0 - var) + 2*var*math.random())
		for i = 0,rr do
			local lf = l:floor()
			lf:set(field,true)
			if (not lf:passable(false)) then
				break
			end
			l = l + d
		end
	end

	--[[for x=0,Map.w do
		for y=0,Map.h do
			q = Pos:new(x,y)
			if(dist(p,q)<r) then
				q:set(field,true)
			end
		end
	end]]

	return field
end

function AoE_line(p1,p2)
	

	local field = map:new(false)


	local angle = math.atan2( (p2.y-p1.y), (p2.x-p1.x) ) + math.random()*0.04 - 0.02


	local d = Pos:new(math.cos(angle),math.sin(angle))
	local l = p1 + Pos:new(math.random(),math.random())
	for i = 0,30 do
		local lf = l:floor()
		lf:set(field,true)
		if (not lf:passable(false)) then
			break
		end
		l = l + d
	end

	p1:set(field,false)
	return field

end

function AoE_cone(p1,p2,r,theta)
	
	local field = map:new(false)

	local step = (1/r)*theta/(2*math.pi)

	local angle = math.atan2( (p2.y-p1.y), (p2.x-p1.x) )

	for a = -theta/2,theta/2, step do
		local d = Pos:new(math.cos(a+angle),math.sin(a+angle))
		local l = p1 + Pos:new(0.5,0.5)
		for i = 0,r do
			local lf = l:floor()
			lf:set(field,true)
			if (not lf:passable(false)) then
				break
			end
			l = l + d
		end
	end
	p1:set(field,false)
	return field
end

function damageUpdate()
	for k,v in pairs(entities) do
		local dmg = v.pos:get(damage)
		if(dmg > 0) then
			
			local dmg = math.floor(dmg*(1+math.random()*0.5-0.25) + 0.5) -- +/-25%
			--[[if(math.random()<0.05) then
				dmg = dmg*3 -- crit
			end]]

			v:event("hit",{damage = dmg})
		end
	end

	for x=0,Map.w do
		for y=0,Map.h do
			if(damage[x][y] > 0) then
				--dmg color: red - white - blue (black body color!)

				local d = damage[x][y]
				local r = 50
				local g = 50
				local b = 255

				if(d<10) then
					r = lerp(1,1,d/10)
					g = lerp(0.2,1,d/10)
					b = lerp(0.2,0.6,d/10)
				elseif(d<50) then
					r = lerp(1,0.2,(d-10)/40)
					g = lerp(1,0.2,(d-10)/40)
					b = lerp(0.6,1,(d-10)/40)
				end

				damageColor[x][y] = {r,g,b}
				damage[x][y] = 0
			end
		end
	end
end