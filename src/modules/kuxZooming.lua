local this = nil

local data = {
	--- Gets a value indicating wether the mod Kux-Zooming is available.
	isAvailabe = false,
}
local moduleName = "kuxZooming"

--- kuxZooming module
-- @module: kuxZooming
KuxZooming = {
	moduleName = moduleName,

	onLoaded = function ()
		Log.trace(moduleName..".onLoaded")
		data = global.moduleData.kuxZooming or data
		this.data = data

		data.isAvailabe = script.active_mods["Kux-Zooming"] ~= nil
		if data.isAvailabe then
			remote.add_interface(this.interfaceName, this.functions)
		end
	end,

	interfaceName = "Kux-Running_kuxZooming",
	-- the interface
	functions = {
		onZoomFactorChanged = function(event)
			if not global.isEnabled then return end

			local player = game.players[event.playerIndex]
			local pm = Modules.playerMemory.get(player)
			local zoomFactor = event.zoomFactor
			local renderMode = event.renderMode
			pm.renderMode = renderMode
			pm.zoomFactor = zoomFactor

			if not player.character or renderMode ~= defines.render_mode.game then return end

			if pm.mode == "zoom" 
				and not pm.canHover 
				and Settings.getZoomHoverModeAutoToggleFactor(player) > 0
				and	zoomFactor > Settings.getZoomHoverModeAutoToggleFactor(player)
			then
				Modules.control.onToggleHover(pm)
			elseif pm.mode == "zoom"
				and	Settings.getZoomModeAutoToggleFactor(player) > 0
				and zoomFactor > Settings.getZoomModeAutoToggleFactor(player)
			then
				Modules.control.onToggleZoom(pm)
				return
			elseif (pm.mode == "accelerate" or pm.mode == "hover")
				and Settings.getZoomModeAutoToggleFactor(player) > 0
				and	zoomFactor < Settings.getZoomModeAutoToggleFactor(player)
			then
				Modules.control.onToggleZoom(pm)
			end

			if pm.mode == "zoom" and not pm.canHover then
				local modifier = 0
				modifier = (1/zoomFactor) * Settings.getZoomSpeedModificator(player) * Settings.getUpsAdjustment(player) -1
				pm.speedModifier = modifier
				player.character_running_speed_modifier = pm.speedModifier
				--player.print("onZoomFactorChanged: "..zoomFactor..", character_running_speed_modifier:"..modifier)
			else
				--player.print("onZoomFactorChanged: "..zoomFactor)
			end
		end,
	},

	--- registers the onZoomFactorChanged callback
	onZoomFactorChanged_register = function ()
		if data.onZoomFactorChanged_registered then return end
		if not data.isAvailabe then return end
		remote.call("Kux-Zooming", "onZoomFactorChanged_add", "Kux-Running_kuxZooming", "onZoomFactorChanged")
		Modules.kuxZooming.onZoomFactorChanged_registered = true
	end,

	onZoomFactorChanged_remove = function ()
		if data.onZoomFactorChanged_registered then return end
		if not data.isAvailabe then return end
		remote.call("Kux-Zooming", "onZoomFactorChanged_remove", "Kux-Running_kuxZooming")
		data.onZoomFactorChanged_registered = false
	end,

	--- Gets the current zoom factor of the specified player
	-- @player: LuaPlayer
	getZoomFactor = function(player)
		if not data.isAvailabe then return 1 end
		return remote.call("Kux-Zooming", "getZoomFactor", player.index)
	end,

	onModeChanged = function (player)
		if Settings.getMode(player) == "zoom" then

			if not data.isAvailabe then
				player.print("Kux-Running: Mode 'Zoom' is not available. Please install the mod Kux-Zooming")
				Settings.setMode(player, "accelerate")
				return
			end

			if player.render_mode == defines.render_mode.game then
				local zoomFactor = Modules.kuxZooming.getZoomFactor(player)
				Modules.kuxZooming.functions.onZoomFactorChanged({
					playerIndex = player.index,
					zoomFactor  = zoomFactor,
					renderMode  = player.render_mode
				})
			end
		end
	end
}
this = KuxZooming -- init local this
Modules.kuxZooming = KuxZooming