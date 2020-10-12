local tools        = require("module/tools")
local settings     = require("module/settings")
local playerMemory = require("module/playerMemory")
local kuxZooming   = require("module/kuxZooming")

local this = nil

modules.modeAccelerate = {
	name = "modeAccelerate",

	onLoaded = function ()
	end,

	init = function (playerMemory)
		this.slow(playerMemory)
	end,

	slow = function (playerMemory)
		local pm = playerMemory
		local movementBonus = tools.getMovementBonus(pm.player)
		local initialSpeedFactor = settings.getInitialSpeedFactor(pm.player)
		pm.modifierMax = movementBonus
		pm.currentModifier = initialSpeedFactor/(1+pm.modifierMax) - 1
		pm.player.character_running_speed_modifier = pm.currentModifier
	end,

	onTick = function (event, playerMemory)
		local pm = playerMemory
		local player = pm.player
		local isWalking = player.walking_state.walking

		if isWalking then
			if pm.accelerationMode == 3 then
				-- fast
				pm.currentModifier = pm.speedModifier
				pm.isAccelerating = false
				pm.isWalking = true
				player.character_running_speed_modifier = pm.currentModifier
			elseif not pm.isWalking then
				-- start slow
				this.slow(pm)
				pm.isWalking = true
				pm.accelerationDuration = 0
				pm.isAccelerating = true
				pm.acceleratingTick = event.tick
				pm.accelerationFactor = settings.getAccelerationFactor(player)
			elseif pm.isAccelerating and pm.accelerationMode == 2 then
				-- accelerating
				pm.accelerationDuration = event.tick - pm.acceleratingTick
				if(pm.accelerationDuration < 30) then
					pm.currentModifier = pm.currentModifier + 0.1 * pm.accelerationFactor
				elseif(pm.accelerationDuration < 90) then
					pm.currentModifier = pm.currentModifier + 0.2 * pm.accelerationFactor
				else
					local f = (pm.speedModifier-pm.currentModifier) / 10
					pm.currentModifier = pm.currentModifier + f * pm.accelerationFactor
				end
				if pm.currentModifier > pm.speedModifier then
					pm.currentModifier = pm.speedModifier
					pm.isAccelerating = false
				end
				player.character_running_speed_modifier = pm.currentModifier
			end
		elseif pm.isWalking and pm.accelerationMode < 3 then
			-- reset to slow
			this.slow(pm)
			pm.isWalking = false
		end
	end
}

this = modules.modeAccelerate -- init local this
return this