local log      = require("lib/log")
local colors   = require("lib/colors")
local settings = require("modules.settings")
local this = nil

--- Calculation module
-- @module calc
modules.calc = {
	name = "calc",

	distance = function (p1,p2)
		return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
	end,

	speed = function (distance, ticks, unit)
		local v = distance / ticks
		if unit=="t" or unit==nil then return v
		elseif unit=="s" then return v * 60
		elseif unit=="m" then return v * 60*60
		elseif unit=="h" then return v * 60*60*60
		else error("Parameter out of range. Parameter 'unit' in function "..script.mod_name..".'tools.speed'") end
	end,

	--- Calculates the speed modifier
	--@param movementBonus The movement bonus [double]
	--@param tileModifier  The tile walking speed modifier [double]
	--@param speedFactor   The speed factor [double]
	--@return speed modifier [double]
	speedModifierByFactor = function (movementBonus, tileModifier, speedFactor)
		return this.speedModifierBySpeed(movementBonus, tileModifier, 0.15 * speedFactor)
	end,

	--- Calculates the speed modifier
	--@param movementBonus The movement bonus [double]
	--@param tileModifier  The tile walking speed modifier [double]
	--@param desiredSpeed   The desired speed [double] in tiles/tick (default is 0.15)
	--@return speed modifier [double]
	speedModifierBySpeed = function (movementBonus, tileModifier, desiredSpeed)
		local currentSpeed = this.walkingSpeed(movementBonus, tileModifier)
		if desiredSpeed > currentSpeed then return desiredSpeed / currentSpeed
		elseif desiredSpeed < currentSpeed then return -1 + desiredSpeed / currentSpeed
		else return 0 end
	end,

	--- Calculates the walking speed
	--@param movementBonus The movement bonus [double]
	--@param tileModifier  The tile walking speed modifier [double]
	--@param speedModifier   The speed modifier  [double] {-1..max} (optional)
	--@return speed [double] tiles/tick
	walkingSpeed = function (movementBonus, tileModifier, speedModifier)
		--if movementBonus == nil then movementBonus = 0.0 end
		--if tileModifier == nil then tileModifier = 1.0 end
		if speedModifier == nil then speedModifier = 0 end
		local speed = (0.15 + 0.15 * movementBonus) * tileModifier * (speedModifier + 1)
		return speed
	end
	
}

this = modules.calc -- init local this
return this