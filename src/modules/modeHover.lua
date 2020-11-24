local round = Tools.round

local this = nil

local d=0.7071 --diagonal
local vectorTable = {{x=0, y=-1},{x=d, y=-d},{x=1, y=0},{x=d, y=d},{x=0, y=1},{x=-d, y=d},{x=-1, y=0},{x=-d, y=-d}}
local walkingStartPosition = nil
local walkingStartTick = nil
ModeHover = {
	name = "modeHover",

	onLoaded = function ()
	end,

	init = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.speedModifier = -0.999999 --stop the walk animation
		player.character_running_speed_modifier = pm.speedModifier
	end,

	onAccelerationModeChanged = function(playerMemory)
		local pm = playerMemory
		local player = pm.player
		local isWalking = player.walking_state.walking
		if isWalking then
			--
		else
			Tools.updateWalkingSpeed(pm)
			pm.walkingSpeed = pm.initialSpeed
			--pm.speedModifier = calc.speedModifierBySpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.walkingSpeed)
			pm.speedModifier = -0.99999 --stop the walk animation
			player.character_running_speed_modifier = pm.speedModifier
		end
	end,

	onWalkingStopped = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = false
		Tools.updateWalkingSpeed(pm)
		pm.walkingSpeed = pm.initialSpeed
		--pm.speedModifier = calc.speedModifierBySpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.walkingSpeed)
		pm.speedModifier = -0.99999 --stop the walk animation
		player.character_running_speed_modifier = pm.speedModifier

		if walkingStartPosition == nil then return end
		local duration = game.tick - walkingStartTick
		local distance = Calc.distance(walkingStartPosition, player.position)
		local speed    = Calc.speed(distance,duration)
		Log.print("onWalkingStopped duration:",duration," distance:",distance," s:",speed," tiles/tick")
	end,

	onWalkingStarted = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = true
		Tools.updateWalkingSpeed(pm,true)
		pm.walkingSpeed = pm.initialSpeed
		pm.speedModifier = -0.99999 --stop the walk animation
		player.character_running_speed_modifier = pm.speedModifier
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
		local direction = player.walking_state.direction
		local ticks = e.tick - global.lastTick

		if player.character.surface.get_tile(player.position).prototype.name == "se-space" then return end

		local isWalkingStarted = isWalking and not pm.isWalking
		local isWalkingStopped = pm.isWalking and not isWalking
		if isWalkingStopped then this.onWalkingStopped(pm); return
		elseif isWalkingStarted then this.onWalkingStarted(pm)
		elseif not isWalking then return end

		-- TODO better teleport detection
		pm.position = pm.position or player.position
		if math.abs(pm.position.x - player.position.x) > 10 or math.abs(pm.position.y - player.position.y) > 10 then
			-- possible teleport, use new position
			Log.print("teleport detected")
			pm.position = player.position
			return
		end

		-- movementEnergy always checked on control.onPlayerTick
		--[[
		if not global.cheatMode then
			local ticks = 1
			local consumption = 0.001 * ticks -- ca 16,6 s / buffer

			if pm.movementEnergy - consumption < 0 then
				if not tools.tryAddMovementEnergy(pm,"turbo") then
					modules.control.onToggleHover(pm) -- toggle off
					return
				end
			end
			pm.movementEnergy = pm.movementEnergy - consumption
			--log.print("consumption: ",consumption," (",pm.movementEnergy,")")
		end
		]]

		if pm.isAccelerating then Tools.accelerate(pm) end

		local v = vectorTable[direction+1]
		local distance = pm.walkingSpeed * ticks
		local xo = distance * v.x
		local yo = distance * v.y

		--log.print("position: ",pm.position.x,";", pm.position.y, " + offset: ",xo,";",yo, " distance: ", distance, " vector: ", v.x,";",v.y)
		pm.position = {x=pm.position.x + xo, y=pm.position.y + yo}

		-- avoid jump back if teleport is smaller then walk
		--[[
		if     v.x>0 and player.position.x > pm.position.x then pm.position = player.position; return
		elseif v.x<0 and player.position.x < pm.position.x then pm.position = player.position; return
		elseif v.y>0 and player.position.y > pm.position.y then pm.position = player.position; return
		elseif v.y<0 and player.position.y < pm.position.y then pm.position = player.position; return
		end
		]]
		local tileName = Tools.getTileName(player.surface.get_tile(pm.position))
		if tileName=="out-of-factory" then -- Factorissimo2
			pm.position = player.position
			return
		end

		player.teleport(pm.position)
		--log.print(pm.accelerationDuration,": ",round(player.position.x,3), ">", round(pm.position.x,3)," o:", round(xo,3))
	end
}
Modules.modeHover = ModeHover
this = ModeHover -- init local this