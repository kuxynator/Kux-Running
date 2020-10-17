local log      = require("lib/log")
local tools        = require("modules.tools")
local calc         = require("modules.calc")
local settings     = require("modules.settings")
local playerMemory = require("modules.playerMemory")
local kuxZooming   = require("modules.kuxZooming")
local round = tools.round
local this = nil

modules.modeAccelerate = {
	name = "modeAccelerate",

	onLoaded = function ()
	end,

	init = function (playerMemory)
		log.print(this.name, " init() ")
		local pm = playerMemory
		tools.updateWalkingSpeed(pm)
		pm.player.character_running_speed_modifier = pm.currentModifier
	end,

	onWalkingStopped = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = false
		tools.updateWalkingSpeed(pm)
		pm.player.character_running_speed_modifier = pm.currentModifier

		if static.walkingStartPosition == nil then return end
		local duration = game.tick - static.walkingStartTick
		local distance = calc.distance(static.walkingStartPosition, player.position)
		local speed    = calc.speed(distance,duration)
		log.print("t:",duration," d:",distance," s:",speed," tiles/tick ")
	end,

	onWalkingStarted = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = true
		tools.updateWalkingSpeed(pm)
		pm.acceleratingTick = global.currentTick
		pm.accelerationDuration = 0
		pm.isAccelerating = true --must be true
		static.walkingStartPosition = player.position
		static.walkingStartTick = game.tick
	end,

	onTick = function (e, playerMemory)
		local pm = playerMemory
		local player = pm.player
		local isWalking = player.walking_state.walking
		local ticks = e.tick - global.lastTick

		local isWalkingStarted = isWalking and not pm.isWalking
		local isWalkingStopped = pm.isWalking and not isWalking
		if isWalkingStopped then this.onWalkingStopped(pm); return
		elseif isWalkingStarted then this.onWalkingStarted(pm)
		elseif not isWalking then return end

		if pm.isAccelerating then tools.accelerate(pm) end

		if not global.cheatMode and pm.currentModifier > 0 then
			local consumption = 0.001 * ticks -- ca 16,6 s / buffer

			if pm.movementEnergy - consumption < 0 then
				if not tools.tryAddMovementEnergy(pm,"turbo") then
					modules.control.setSpeedMode(pm, 0)
					consumption = 0
				end
			end
			pm.movementEnergy = pm.movementEnergy - consumption
			--log.print("consumption: ",consumption," (",pm.movementEnergy,")")
		end

		pm.position = player.position
		pm.currentModifier = calc.speedModifierBySpeed(pm.movementBonus, pm.tileWalkingSpeedModifier, pm.walkingSpeed)
		player.character_running_speed_modifier = pm.currentModifier
	end
}

this = modules.modeAccelerate -- init local this
return this