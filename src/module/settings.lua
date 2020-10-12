local this = nil

--- Settings module
-- @module settings
modules.settings = {

	onModeChanged = function (playerMemory, newMode)
		playerMemory.mode = newMode
		modules.control.onModeChanged(playerMemory, newMode)
	end,

	check = {
		--[[ runtime-global ]] --

		isEnabled = function()
			local isEnabled = modules.settings.getIsEnabled()
			if isEnabled and not modules.control.isEnabled then modules.control.enable()
			elseif not isEnabled and modules.control.isEnabled then modules.control.disable() end
		end,

		cheatMode = function()
			local value = modules.settings.getCheatMode()
			if value and not global.cheatMode then
				global.cheatMode = true
				game.print("Kux-Running: Cheat mode enabled.")
			elseif not value and modules.control.isEnabled then
				global.cheatMode = false
				game.print("Kux-Running: Cheat mode disabled.")
			end
		end,

		--[[ runtime-per-user ]] --

		mode = function (playerMemory)
			local mode = modules.settings.getMode(playerMemory.player)
			if mode ~= playerMemory.mode then modules.settings.onModeChanged(playerMemory, mode) end
		end,

		initialSpeedFactor = function (playerMemory)
			local value = modules.settings.getInitialSpeedFactor(playerMemory.player)
			--if value ~= playerMemory.initialSpeedFactor then  end
			playerMemory.initialSpeedFactor = value
		end,

		accelerationFactor = function (playerMemory)
			local value = modules.settings.getAccelerationFactor(playerMemory.player)
			--if value ~= playerMemory.accelerationFactor then  end
			playerMemory.accelerationFactor = value
		end,

		zoomSpeedModificator = function (playerMemory)
			local value = modules.settings.getZoomSpeedModificator(playerMemory.player)
			--if value ~= playerMemory.getZoomSpeedModificator then  end
			playerMemory.zoomSpeedModificator = value
		end,
	},

	-- script.on_event(on_runtime_mod_setting_changed)
	onConfigurationChanged = function(event, player)
		if player == nil then

			this.check.isEnabled()
			this.check.cheatMode()

			if event.player_index == nil then --return end -- changed by a script
				for _, player in pairs(game.players) do
					this.onConfigurationChanged(event, player)
				end
			else
				this.onConfigurationChanged(event, game.players[event.player_index])
			end
		else
			local mem = modules.playerMemory.get(player)

			this.check.mode(mem)
			this.check.initialSpeedFactor(mem)
			this.check.accelerationFactor(mem)

			--local initialSpeedFactor = module.settings.getInitialSpeedFactor(player)
			--if initialSpeedFactor > 1 then
			--    local newValue = 1
			--    player.print("Invalid settings! Default initial speed factor has to be lower or equal than 1. Changed to " .. newValue)
			--    module.settings.get_player_settings(player.index)["Kux-Running_InitialSpeedFactor"] = { value = newValue }
			--end
		end
	end,

	--[[ runtime-global ]] --

	getIsEnabled = function()
		return settings.global["Kux-Running_Enable"].value
	end,

	getCheatMode = function()
		return settings.global["Kux-Running_CheatMode"].value
	end,

	--[[ runtime-per-user ]] --

	getMode = function(player)
		return player.mod_settings["Kux-Running_Mode"].value
	end,
	setMode = function (player, mode)
		player.mod_settings["Kux-Running_Mode"] = { value = mode }
	end,

	getDefaultCharacterRunningSpeedModifier = function(player)
		return player.mod_settings["Kux-Running_DefaultCharacterRunningSpeedModifier"].value
	end,
	setDefaultCharacterRunningSpeedModifier = function(player, value)
		player.mod_settings["Kux-Running_DefaultCharacterRunningSpeedModifier"] = { value = value }
	end,

	getInitialSpeedFactor = function(player)
		return player.mod_settings["Kux-Running_InitialSpeedFactor"].value
	end,

	getAccelerationFactor = function(player)
		return player.mod_settings["Kux-Running_AccelerationFactor"].value
	end,

	getZoomSpeedModificator = function(player)
		return player.mod_settings["Kux-Running_ZoomSpeedModificator"].value
	end,

	zoomSpeedOffset = function(player)
		return player.mod_settings["Kux-Running_ZoomSpeedOffset"].value
	end
}

this = modules.settings
return modules.settings