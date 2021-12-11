require 'components/move'
require 'components/counter'
require 'components/ai'
require 'components/scent'
require 'components/projectile'
require 'components/hp'
require 'components/equipment'
require 'components/melee'
require 'components/gun'
require 'components/regenerate'
require 'components/inventory'
require 'components/door'
require 'components/boost'
require 'components/corpse'
require 'components/remove'
require 'components/grenade'
require 'components/laser'
require 'components/ammoBox'
require 'components/food'
require 'components/tail'



--[[
glossary of messages:
update	: every step
turn 	: do turn
wait 	: wait for [time] steps
move 	: move in [dir]
hit 	: take [damage]
heal    : heal [val] wounds
boost   : heal [val]*100% stamina
use 	: use ability/slot [name] [target] -gets passed to item-
select  : select inventory slot [index]
death   : called on death
reload  : fetch [amount] bullets of [type] from inventory. Returns [amount]
fire    : fire projectile/bullet at [target]

pickup  : put items in inventory
remove  : remove [item] from inventory/equipement
drop    : drop [item] to level

deprecated:
init	: initialise component after constructor
bump	: called on entity occupying the space where another entity wants to move
]]

Component = {}

function Component:new(name)
	local new = {}	
	--setmetatable(new, self)
	self.__index = self

	new.name = name
	return new
end

function Component:event(e)
	return e
end


