local settings    = require "module/settings"
--local playerMemory = require "module/playerMemory"  --circular reference
local this = nil

--- kuxZooming module
-- @module: kuxZooming
modules.kuxZooming = {
	name = "Kux-Running_kuxZooming",

	-- the interface
	functions = {
		onZoomFactorChanged = function(event)
			local player = game.players[event.playerIndex]
			local mem = modules.playerMemory.get(player)
			local zoomFactor = event.zoomFactor
			local renderMode = event.renderMode
			mem.renderMode = renderMode
			mem.zoomFactor = zoomFactor
			if mem.mode == "zoom" and not mem.canHover and player.connected and player.character ~= nil and renderMode == defines.render_mode.game then
				local modifier = 0
				if(zoomFactor <= 1) then
					modifier = 1 / zoomFactor -1
				else
					modifier = (1/zoomFactor - 1) / 1.5
				end
				player.character_running_speed_modifier = modifier
				--player.print("onZoomFactorChanged: "..zoomFactor..", character_running_speed_modifier:"..modifier)
			else
				--player.print("onZoomFactorChanged: "..zoomFactor)
			end
		end,
	},

	--- Gets a value indicating wether the mod Kux-Zooming is available.
	isAvailabe = false,

	--- registers the onZoomFactorChanged callback
	onZoomFactorChanged_register = function ()
		if modules.kuxZooming.onZoomFactorChanged_registered then return end
		if not modules.kuxZooming.isAvailabe then return end
		remote.call("Kux-Zooming", "onZoomFactorChanged_add", "Kux-Running_kuxZooming", "onZoomFactorChanged")
		modules.kuxZooming.onZoomFactorChanged_registered = true
	end,

	--- Gets the current zoom factor of the specified player
	-- @player: LuaPlayer
	getZoomFactor = function(player)
		if not modules.kuxZooming.isAvailabe then return 1 end
		return remote.call("Kux-Zooming", "getZoomFactor", player.index)
	end,

	onModeChanged = function (player)
		if settings.getMode(player) == "zoom" then

			if not modules.kuxZooming.isAvailabe then
				player.print("Kux-Running: Mode 'Zoom' is not available. Please install the mod Kux-Zooming")
				settings.setMode(player, "accelerate")
				return
			end

			if player.render_mode == defines.render_mode.game then
				local zoomFactor = modules.kuxZooming.getZoomFactor(player)
				modules.kuxZooming.functions.onZoomFactorChanged({
					playerIndex = player.index,
					zoomFactor = zoomFactor,
					renderMode = player.render_mode
				})
			end
		end
	end
}

if script.active_mods["Kux-Zooming"] then
	remote.add_interface(modules.kuxZooming.name, modules.kuxZooming.functions)
	modules.kuxZooming.isAvailabe = true
else
	modules.kuxZooming.isAvailabe = false
end

this = modules.kuxZooming -- init local this
return this