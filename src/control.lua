Modules = {}
require("lib/lua")
require("lib/Log")
require("lib/Colors")
require("lib/FlyingText")
require("modules/PlayerMemory")
require("modules/Settings")
require("modules/Tools")
require("modules/Calc")
require("modules/ModeHover")
require("modules/ModeAccelerate")
require("modules/ModeZoom")
require("modules/KuxZooming")
require("modules/NauvisMelange")

if script.active_mods["gvv"] then require("__gvv__.gvv")() end

local flyingSpeedModeSymbols = {"0", ">", ">>"}
local flyingSpeedModeColors = {Colors.lightgrey, Colors.cyan, Colors.purple}
local flyingAccelerationSymbols = {"-", "<", "*"}
local flyingAccelerationColors = {Colors.red, Colors.yellow, Colors.green}
local this = nil

Modules.control = {
	name = "control",

	--- deterministic data of control module
	data = {
		isEnabled = false
	},

	onToggleSpeedMode = function (event)
		local player = game.players[event.player_index]
		local pm = PlayerMemory.get(player)
		if(pm.mode~="accelerate" and pm.mode ~= "hover") then return end
		if not pm.player.character then return end

		local v = pm.speedMode
		if v == 3 then v = 1 else v = v + 1 end
		this.setSpeedMode(pm, v)
	end,

	setSpeedMode = function(playerMemory, newMode)
		Log.trace("setSpeedMode ",playerMemory.player.index," ",newMode)
		local pm = playerMemory
		if newMode > 3 then newMode = 3 elseif newMode < 1 then newMode = 1 end
		if pm.speedMode == newMode then return end
		pm.speedMode = newMode
		FlyingText.create(pm.player, flyingSpeedModeSymbols[pm.speedMode], flyingSpeedModeColors[pm.speedMode])
		pm.speedModifier = pm.speedTable[pm.speedMode]
	end,

	onToggleAccelerationMode = function (event)
		local player = game.players[event.player_index]
		local pm = PlayerMemory.get(player)
		if pm.mode~="accelerate" and pm.mode ~= "hover" then return end
		if not pm.player.character then return end

		local newMode = pm.accelerationMode
		if newMode == 3 then newMode = 1 else newMode = newMode + 1 end

		Log.trace("onToggleAccelerationMode ",pm.player.index," ",newMode)
		pm.accelerationMode = newMode 
		FlyingText.create(player, flyingAccelerationSymbols[pm.accelerationMode], flyingAccelerationColors[pm.accelerationMode])

		--if pm.mode == "accelerate" then modules.modeAccelerate.onAccelerationModeChanged(pm) end
		if pm.mode == "hover" then Modules.modeHover.onAccelerationModeChanged(pm) end
	end,

	onToggleHover = function(eventOrPlayerMemory) -- on_lua_shortcut event or PlayerMemory
		Log.print("onToggleHover(..)")
		local player = nil
		local pm = nil
		if eventOrPlayerMemory.input_name ~= nil then
			player = game.get_player(eventOrPlayerMemory.player_index)
			pm = PlayerMemory.get(player)
		else
			pm = eventOrPlayerMemory --TODO asuming PlayerMemory
			player = pm.player
		end

		if not pm.player.character then return end

		if pm.mode == "zoom" then
			if pm.canHover then
				pm.canHover = false
				player.print("Zoom mode")
				FlyingText.create(pm.player,"Zoom")
			else
				pm.canHover = true
				Modules.modeZoom.init(pm)
				player.print("Zoom+Hover mode")
				FlyingText.create(pm.player,"Zoom+Hover")
			end
			pm.isHovering = pm.canHover
			return
		end

		if not pm.isHovering then
			-- try turn on hover
			if player.character == nil then return end
			if pm.movementEnergy > 0.1 then pm.isHovering = true
			elseif Tools.tryAddMovementEnergy(pm,"hover") then pm.isHovering = true
			else return end
		else
			--onHoverStopped(pm)
			pm.isHovering = false
		end
		--if pm.isHovering then onHoverStarted(pm) end
		Log.trace("onToggleHover ", pm.isHovering)

		if pm.isHovering and pm.mode == "accelerate" then
			pm.mode = "hover"
			Modules.modeHover.init(pm)
			pm.player.print("Hover mode")
			FlyingText.create(pm.player,"Hover mode")
		elseif not pm.isHovering and pm.mode == "hover" then
			pm.mode = "accelerate"
			Modules.modeAccelerate.init(pm)
			pm.player.print("Accelerate mode")
			FlyingText.create(pm.player,"Accelerate")
		end
	end,

	onToggleZoom = function(eventOrPlayerMemory) -- on_lua_shortcut event or PlayerMemory
		Log.print("onToggleZoom(..)")
		local pm = eventOrPlayerMemory
		if eventOrPlayerMemory.input_name ~= nil then pm = PlayerMemory.get(game.get_player(eventOrPlayerMemory.player_index)) end
		if not pm.player.character then return end

		if pm.mode == "zoom" then
			-- turn off zoom mode
			if pm.canHover then
				pm.mode = "hover"
				Modules.modeHover.init(pm)
				pm.player.print("Hover mode")
				FlyingText.create(pm.player,"Hover")
			else 
				pm.mode = "accelerate"
				Modules.modeAccelerate.init(pm)
				pm.player.print("Accelerate mode")
				FlyingText.create(pm.player,"Accelerate")
			end
		else
			-- turn on zoom mode
			if pm.mode == "hover" then
				pm.mode = "zoom"
				pm.canHover = true
				Modules.modeZoom.init(pm)
				pm.player.print("Zoom mode ON (hover)")
				FlyingText.create(pm.player,"Zoom+Hover")
			else
				pm.mode = "zoom"
				pm.canHover = false
				pm.player.print("Zoom mode ON")
				FlyingText.create(pm.player,"Zoom")
			end
		end
	end,

	onTickOneTime = function (e)
		script.on_nth_tick(nil)
		this.onLoaded(e)
	end,

	onLoaded = function(e)
		Log.trace("onLoaded")

		global.moduleData = global.moduleData or {}
		this.data = global.moduleData.control or this.data -- load data from global

		-- read config, this will override values from last session
		global.isEnabled = Settings.getIsEnabled()

		global.isMultiplayer = game.is_multiplayer()

		-- distribute onLoaded to all modules
		for name,module in pairs(Modules) do if name~="control" and module.onLoaded ~=nil then module.onLoaded(e) end end
		script.on_event(defines.events.on_runtime_mod_setting_changed, Settings.onSettingsChanged)

		if not global.isEnabled then return end

		this.enable()
		this.onTick(e)
	end,

	onTick = function (e) -- on_nth_tick(1)
		local nthTick = global.nthTick or 0
		global.currentTick = e.tick

		if not global.isMultiplayer then
			local player = global.player
			local pm = global.playerMemory
			local mode = pm.mode

			--log.print("onTick ", mode," w:", player.walking_state.walking," h:",  pm.isHovering)

			local isWalking = player.walking_state.walking

			if(isWalking and global.tickFreqency ~= 1 and (mode == "hover" or mode == "accelerate" or (mode == "zoom" and pm.canHover))) then
				this.setTick(1, "is walking")
			elseif not isWalking and global.tickFreqency ~= 10 then
				this.setTick(10, "is not walking")
			end
		end

		for _, player in pairs(game.players) do
			local pm = PlayerMemory.get(player)
			this.onPlayerTick(e,pm)
		end

		global.nthTick = iif(nthTick == 9, 0, nthTick + 1)
		global.lastTick = e.tick
	end,

	onPlayerTick = function(e, playerMemory)
		--log.print(this.name, ".onPlayerTick(",playerMemory.player.index,")")
		local player = playerMemory.player
		local pm = playerMemory
		local ticks = e.tick - global.lastTick

		if pm.hasCharacter and (not player.connected or player.character == nil) then
			--onCharacterDisonnected(pm)
			pm.hasCharacter = false
			--TODO if pm.isWalking stop walking
			return
		elseif not pm.hasCharacter and player.connected and player.character ~= nil then
			--onCharacterConnected(pm)
			pm.hasCharacter = true
			this.initPlayer(pm, "player character connected")
		elseif player.character == nil then
			return
		end

		-- here because its used in mode zoom and in mode hover
		if not global.cheatMode and pm.isHovering then
			local consumption = 0.0002778 * ticks -- 1 min / buffer
			if pm.movementEnergy - consumption < 0 then
				if not Tools.tryAddMovementEnergy(pm,"hover") then
					this.onToggleHover(pm) -- toggle off
				end
			end
			if pm.isHovering then
				pm.movementEnergy = pm.movementEnergy - consumption
				--log.print("consumption: ",consumption," (",pm.movementEnergy,")")#
			end
		end

		local mode = pm.mode
		--if(pm.mode ~= mode) then settings.onModeChanged(pm, mode) end -- this will also call control.onModeChanged
		if    (mode == "accelerate"           ) then ModeAccelerate.onTick(e, pm)
		elseif(mode == "hover"                ) then ModeHover.onTick(e, pm)
		elseif(mode == "zoom" and pm.canHover ) then ModeZoom.onTick(e, pm) end
	end,

	setTick = function(n)
		if n == 10 then n = 1 end --hack for test
		if(global.tickFreqency == n) then return end
		script.on_nth_tick(nil)		
		if n > 0 then script.on_nth_tick(n, this.onTick) end
		global.tickFreqency = n
		global.nthTick = 0
		Log.trace("setTick ",n)
	end,

	enable = function ()
		Log.trace("enabe")

		Tools.registerEvents();
		Modules.kuxZooming.onZoomFactorChanged_register()
		Modules.nauvisMelange.onSpiceInfluenceChanged_add()

		global.lastTick = global.lastTick or game.tick-1

		global.tickFreqency = 0
		global.nthTick = 0
		Settings.check.cheatMode()

		--log.print("isMultiplayer: ",global.isMultiplayer)

		for _, player in pairs(game.players) do
			local pm = PlayerMemory.get(player)
			this.initPlayer(pm, "mod enabled")
		end

		if not global.isMultiplayer then
			global.player = game.get_player(1)
			global.playerMemory = PlayerMemory.get(global.player)
		end

		this.setTick(iif(global.isMultiplayer, 1, 10))
		global.isEnabled = true
	end,

	initPlayer = function (playerMemory, reason)
		Log.trace("initPlayer() ",playerMemory.player.index," ",reason)
		local pm = playerMemory
		local player = pm.player
		if(not player.connected or player.character == nil) then return end

		pm.isWalking = player.walking_state.walking
		pm.position = player.position
		pm.movementBonus = Tools.getMovementBonus(player)
		Tools.updateLocation(pm)

		pm.canHover = true -- enable hover (in zoom mode) for all

		pm.movementBonus = Tools.getMovementBonus(player)
		Tools.updateLocation(pm)

		if(NauvisMelange.isAvailable) then
			pm.hasSpiceInfluence = NauvisMelange.getHasSpiceInfluence(pm)
		end

		if    (pm.mode == "accelerate") then ModeAccelerate.init(pm)
		elseif(pm.mode == "hover"     ) then ModeHover.init(pm)
		elseif(pm.mode == "zoom"      ) then ModeZoom.init(pm) end

		pm.isInitialized = true
	end,

	disable = function ()
		Log.trace("disable()")

		Tools.unregisterEvents(); -- except on_runtime_mod_setting_changed
		Modules.kuxZooming.onZoomFactorChanged_remove()
		Modules.nauvisMelange.onSpiceInfluenceChanged_remove()

		this.setTick(0)

		for _, player in pairs(game.players) do
			local pm = PlayerMemory.get(player)
			Tools.tryRestoreCharacterRunningSpeedModifier(pm)
			pm.isInitialized = false
		end

		global.isEnabled = false
	end,

	onModeChanged = function (playerMemory, newMode)
		local pm = playerMemory
		local player = pm.player
		pm.mode = newMode
		if(player.character == nil) then
			player.print("Kux-Running: Can not change the mode. No character.", Colors.lightred)
			pm.hasCharakter = false
			return
		end
		if newMode == "none" then
			Tools.tryRestoreCharacterRunningSpeedModifier(pm)
		elseif newMode == "accelerate" then
			Modules.modeAccelerate.init(pm)
		elseif newMode == "hover" then
			Modules.modeHover.init(pm)
		elseif newMode == "zoom" then
			Modules.modeZoom.init(pm)
			Modules.kuxZooming.onModeChanged(pm.player)
		end
	end,

	onSurfaceChanged = function(playerMemory, surface)
		local pm = playerMemory
		Tools.updateLocation(pm, "surface changed")
	end,

	onTilePositionChanged = function(playerMemory, tile)
		--log.trace("onTilePositionChanged position:",tile.position.x,";",tile.position.y,", name:", tile.prototype.name)
		local pm = playerMemory
		Tools.updateLocation(pm, "position changed")
	end,

	--- event on_player_changed_surface
	onPlayerChangedSurface= function (e)
		--BUG? e.surface_index returns previous surface index!
		-- local surface = game.get_surface(e.surface_index)
		local player = game.get_player(e.player_index)
		local surface = player.surface
		local surfaceIndex = player.surface.index
		--Log.trace("onPlayerChangedSurface"," player:", e.player_index, " index:", surfaceIndex,"(",e.surface_index,"), name:", surface.name, " hasCharacter:",player.character~=nil)

		local pm = PlayerMemory.get(player)
		this.onSurfaceChanged(pm, surface)
	end,

	--- event on_player_changed_position
	onPlayerChangedPosition = function (e)
		-- NOTE the event 'on_player_changed_position' seems to be called only one time per tile
		local player = game.get_player(e.player_index)
		local pm = PlayerMemory.get(player)
		--if pm.isHovering then return end --UPS optimization, but we need information on orbit!

		if not player.character then
			Log.trace("onPlayerChangedPosition ", "no-character")
			return
		end

		--Log.trace("onPlayerChangedPosition", player.character.position.x,";",player.character.position.y)
		local surface = player.surface
		local tile = surface.get_tile(player.position)

		local hasSurfaceChanged = pm.location.surfaceName ~= player.surface.name
		local hasTilePositionChanged = pm.location.tilePosition.x ~= tile.position.x or pm.location.tilePosition.y ~= tile.position.y

		if hasSurfaceChanged then this.onSurfaceChanged(pm, player.surface) end
		if hasTilePositionChanged then this.onTilePositionChanged(pm, tile) end

		if player.walking_state.walking then
			if not pm.isWalking and global.tickFreqency ~= 1 then
				this.setTick(1, "on_player_changed_position by walking")
			end
			if not pm.isWalking then this.onPlayerTick(e, pm) end
		else
			--Log.trace("onPlayerChangedPosition ", player.walking_state.walking, pm.isWalking, global.tickFreqency, "teleport")
		end


		--[[if pm.position.x ~= player.position.x or pm.position.y ~= player.position.y then
			log.print("onPlayerChangedPosition ",player.position.x,";",player.position.y," (", pm.position.x,";",pm.position.y,")")
			if global.tickFreqency ~= 1 then
				this.onTick(e)
			end
		end--]]
	end,

	--- event on_player_armor_inventory_changed
	onPlayerArmorInventoryChanged = function (e)
		Log.trace("onPlayerArmorInventoryChanged")
		local player = game.get_player(e.player_index)
		local pm = PlayerMemory.get(player)
		local value = Tools.getMovementBonus(pm.player)
		if pm.movementBonus == value then return end
		this.onMovementBonusChanged(pm)
	end,

	onMovementBonusChanged = function(playerMemory)
		Log.trace("onMovementBonusChanged")
	end,

	--- script.on_load
	onLoad = function()
		if global.isEnabled then Tools.registerEvents() end
		script.on_event(defines.events.on_runtime_mod_setting_changed, Settings.onSettingsChanged)
	end
}

this = Modules.control --init local this
script.on_init                 (function () Log.trace("on_init") end)
script.on_load                 (this.onLoad)
script.on_configuration_changed(function () Log.trace("on_configuration_changed") end)
script.on_nth_tick             (1, this.onTickOneTime)

--[[
script.on_event(defines.events.on_player_created, function () log.print("on_player_created") end)
script.on_event(defines.events.on_player_joined_game, function () log.print("on_player_joined_game") end)


script.on_nth_tick(1, this.onTickOneTime)
script.on_event("Kux-Running_hotkey-ToggleAccelerationMode", this.onToggleAccelerationMode)
script.on_event("Kux-Running_hotkey-ToggleSpeedMode", this.onToggleSpeedMode)
script.on_event("Kux-Running_hotkey-ToggleHover", this.onToggleHover)
script.on_event(defines.events.on_runtime_mod_setting_changed, settings.onSettingsChanged)
script.on_event(defines.events.on_player_armor_inventory_changed, this.onPlayerArmorInventoryChanged)
script.on_event(defines.events.on_player_changed_position, this.onPlayerChangedPosition)
script.on_event(defines.events.on_player_changed_surface, this.onPlayerChangedSurface)

script.on_event(defines.events.on_player_died, function () log.print("on_player_died") end)
script.on_event(defines.events.on_player_kicked, function () log.print("on_player_kicked") end)
script.on_event(defines.events.on_player_left_game, function () log.print("on_player_left_game") end)
script.on_event(defines.events.on_player_removed, function () log.print("on_player_removed") end)
script.on_event(defines.events.on_player_respawned, function () log.print("on_player_respawned") end)

script.on_event(defines.events.on_runtime_mod_setting_changed, settings.onSettingsChanged)
]]
remote.add_interface("Kux-Running", require("modules.interface"))

--[[
# new single player
on_init
on_player_created
on_player_joined_game
onLoaded

# load single plaayer
on_load
on_configuration_changed
onLoaded

# new multiplayer
..
]]