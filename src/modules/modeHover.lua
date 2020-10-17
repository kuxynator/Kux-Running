local log      = require("lib/log")
local tools        = require("modules.tools")
local calc         = require("modules.calc")
local settings     = require("modules.settings")
local round = tools.round

local this = nil

local d=0.7071 --diagonal
local vectorTable = {{x=0, y=-1},{x=d, y=-d},{x=1, y=0},{x=d, y=d},{x=0, y=1},{x=-d, y=d},{x=-1, y=0},{x=-d, y=-d}}

modules.modeHover = {
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
			tools.updateWalkingSpeed(pm)
			pm.walkingSpeed = pm.initialSpeed
			pm.speedModifier = calc.speedModifierBySpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.walkingSpeed)
			player.character_running_speed_modifier = pm.speedModifier
		end
	end,

	onWalkingStopped = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = false
		tools.updateWalkingSpeed(pm)
		pm.walkingSpeed = pm.initialSpeed
		pm.speedModifier = calc.speedModifierBySpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.walkingSpeed)
		player.character_running_speed_modifier = pm.speedModifier

		if static.walkingStartPosition == nil then return end
		local duration = game.tick - static.walkingStartTick
		local distance = calc.distance(static.walkingStartPosition, player.position)
		local speed    = calc.speed(distance,duration)
		log.print("onWalkingStopped duration:",duration," distance:",distance," s:",speed," tiles/tick")
	end,

	onWalkingStarted = function (playerMemory)
		local pm = playerMemory
		local player = pm.player
		pm.isWalking = true
		tools.updateWalkingSpeed(pm,true)
		pm.walkingSpeed = pm.initialSpeed
		pm.speedModifier = -0.99999 --stop the walk animation
		player.character_running_speed_modifier = pm.speedModifier
		pm.acceleratingTick = game.tick
		pm.accelerationDuration = 0
		pm.isAccelerating = true --must be true
		static.walkingStartPosition = player.position
		static.walkingStartTick = game.tick
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

		pm.position = pm.position or player.position
		if math.abs(pm.position.x - player.position.x) > 10 or math.abs(pm.position.y - player.position.y) > 10 then
			-- possible teleport, use new position
			log.print("teleport detected")
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

		if pm.isAccelerating then tools.accelerate(pm) end

		local v = vectorTable[direction+1]
		local distance = pm.walkingSpeed * ticks
		local xo = distance * v.x
		local yo = distance * v.y

		--log.print("position: ",pm.position.x,";", pm.position.y, " + offset: ",xo,";",yo, " distance: ", distance, " vector: ", v.x,";",v.y)
		pm.position = {x=pm.position.x + xo, y=pm.position.y + yo}

		-- avoid jump back if teleport is smaller then walk
		if     v.x>0 and player.position.x > pm.position.x then pm.position = player.position; return
		elseif v.x<0 and player.position.x < pm.position.x then pm.position = player.position; return
		elseif v.y>0 and player.position.y > pm.position.y then pm.position = player.position; return
		elseif v.y<0 and player.position.y < pm.position.y then pm.position = player.position; return
		end
		local tileName = tools.getTileName(player.surface.get_tile(pm.position))
		if tileName=="out-of-factory" then -- Factorissimo2
			pm.position = player.position
			return
		end

		player.teleport(pm.position)
		--log.print(pm.accelerationDuration,": ",round(player.position.x,3), ">", round(pm.position.x,3)," o:", round(xo,3))
	end
}
this = modules.modeHover -- init local this
return this