local this = nil

local walkingStartPosition = nil
local walkingStartTick = nil

ModeAccelerate = {
	name = "modeAccelerate",

	onLoaded = function ()
	end,

	init = function (playerMemory)
		Log.print(this.name, " init() ")
		local pm = playerMemory
		Tools.updateWalkingSpeed(pm)
		pm.player.character_running_speed_modifier = pm.currentModifier
	end,

	onWalkingStopped = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = false
		Tools.updateWalkingSpeed(pm)
		if global.isMultiplayer then pm.speedModifier = -0.99999 end -- TODO experimental, seems not to help
		pm.player.character_running_speed_modifier = pm.currentModifier

		if walkingStartPosition == nil then return end
		local duration = game.tick - walkingStartTick
		local distance = Calc.distance(walkingStartPosition, player.position)
		local speed    = Calc.speed(distance,duration)
		Log.print("t:",duration," d:",distance," s:",speed," tiles/tick ")
	end,

	onWalkingStarted = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = true
		Tools.updateWalkingSpeed(pm)
		pm.acceleratingTick = game.tick
		pm.accelerationDuration = 0
		pm.isAccelerating = true --must be true
		walkingStartPosition = player.position
		walkingStartTick = game.tick
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

		if pm.isAccelerating then Tools.accelerate(pm) end

		if not global.cheatMode and pm.currentModifier > 0 then
			local consumption = 0.001 * ticks -- ca 16,6 s / buffer

			if pm.movementEnergy - consumption < 0 then
				if not Tools.tryAddMovementEnergy(pm,"turbo") then
					Modules.control.setSpeedMode(pm, 0)
					consumption = 0
				end
			end
			pm.movementEnergy = pm.movementEnergy - consumption
			--log.print("consumption: ",consumption," (",pm.movementEnergy,")")
		end

		pm.position = player.position
		pm.currentModifier = Calc.speedModifierBySpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.walkingSpeed)
		player.character_running_speed_modifier = pm.currentModifier
	end
}

Modules.modeAccelerate = ModeAccelerate
this = ModeAccelerate -- init local this