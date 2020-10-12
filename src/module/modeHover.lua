local debug        = require("lib/debug")
local tools        = require("module/tools")
local settings     = require("module/settings")

local round = tools.round
local this = nil
modules.modeHover = {
	name = "modeHover",

	onLoaded = function ()
	end,

	init = function (playerMemory)
		playerMemory.player.character_running_speed_modifier = -0.999
	end,

	onAccelerationModeChanged = function(playerMemory)
		local pm = playerMemory
		local player = pm.player
		local isWalking = player.walking_state.walking
		if isWalking then
			--
		else
			if pm.accelerationMode == 3 then
				player.character_running_speed_modifier = 0 --TODO calc best value for high speed
			else
				this.slow(pm)
			end
		end
	end,

	slow = function (playerMemory)
		local pm = playerMemory
		local player = pm.player

		pm.modifierMax = pm.speedModifier
		pm.currentModifier = pm.initialSpeedFactor/(1+pm.modifierMax) -1
		pm.accelerationDuration = 0
		player.character_running_speed_modifier = -0.5 --TODO calc best value
	end,

	onTick = function (event, playerMemory)
		local pm = playerMemory
		local player = pm.player
		local isWalking = player.walking_state.walking
		local direction = player.walking_state.direction

		if player.character.surface.get_tile(player.position).prototype.name == "se-space" then
			return
		end

		local isWalkingStarted = false
		local isWalkingStopped = false
		if not isWalking then
			if pm.isWalking then
				-- walking stopped
				isWalkingStopped = true
				pm.isWalking = false
				this.slow(pm)
			end
			return -- not walking, nothing to do
		else
			if not pm.isWalking then
				-- walking started
				isWalkingStarted = true
				pm.isWalking = true
				pm.accelerationDuration = 0
				player.character_running_speed_modifier = -0.999 --stop the walk animation
				
			end
		end

		local xd = 1
		local yd = 1;
		if     direction == 0 then xd =  0; yd = -1
		elseif direction == 1 then xd =  1; yd = -1
		elseif direction == 2 then xd =  1; yd =  0
		elseif direction == 3 then xd =  1; yd =  1
		elseif direction == 4 then xd =  0; yd =  1
		elseif direction == 5 then xd = -1; yd =  1
		elseif direction == 6 then xd = -1; yd =  0
		elseif direction == 7 then xd = -1; yd = -1
		end

		local f = 0.16
		local xo=xd*f
		local yo=yd*f
		pm.position = pm.position or player.position
		if math.abs(pm.position.x - player.position.x) > 10 or math.abs(pm.position.y - player.position.y) > 10 then
			-- possible teleport, use new position
			debug.print("teleport detected")
			pm.position = player.position
			return
		end

		if isWalkingStarted then
			if pm.accelerationMode == 3 then
				-- fast
				pm.currentModifier = pm.speedModifier
				pm.isAccelerating = false
			else
				-- start slow
				pm.isAccelerating = true
				pm.acceleratingTick = event.tick
				pm.currentModifier = pm.initialSpeedFactor/(1+pm.modifierMax) - 1
			end
		end

		if pm.accelerationMode == 2 and pm.isAccelerating then
			-- accelerate
			pm.accelerationDuration = event.tick - pm.acceleratingTick
			if pm.accelerationDuration < 30 then
				pm.currentModifier = pm.currentModifier + 0.1 * pm.accelerationFactor
			elseif pm.accelerationDuration < 90 then
				pm.currentModifier = pm.currentModifier + 0.2 * pm.accelerationFactor
			else
				local f = (pm.speedModifier-pm.currentModifier) / 10
				pm.currentModifier = pm.currentModifier + f * pm.accelerationFactor
			end
			if pm.currentModifier > pm.speedModifier then
				pm.currentModifier = pm.speedModifier
				pm.isAccelerating = false
			end
		end

		xo = xo + xo * pm.currentModifier
		yo = yo + yo * pm.currentModifier

		pm.position = {x=pm.position.x + xo, y=pm.position.y + yo}

		-- avoid jump back if teleport is smaller then walk
		if     xd>0 and player.position.x > pm.position.x then pm.position = player.position; return
		elseif xd<0 and player.position.x < pm.position.x then pm.position = player.position; return
		elseif yd>0 and player.position.y > pm.position.y then pm.position = player.position; return
		elseif yd<0 and player.position.y < pm.position.y then pm.position = player.position; return
		end

		player.teleport(pm.position)
		--debug.print(pm.accelerationDuration,": ",round(player.position.x,3), ">", round(pm.position.x,3)," o:", round(xo,3))
	end
}
this = modules.modeHover -- init local this
return this