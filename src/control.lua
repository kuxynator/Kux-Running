modules = {}
static = static or {}
require("lib/lua")
local core           = require("lib/core")
local log            = require("lib/log")
local colors         = require("lib/colors")
local flyingText     = require("lib/flyingText")
local settings       = require("modules.settings")
local tools          = require("modules.tools")
local playerMemory   = require("modules.playerMemory")
local modeHover      = require("modules.modeHover")
local modeAccelerate = require("modules.modeAccelerate")
local modeZoom       = require("modules.modeZoom")
local kuxZooming     = require("modules.kuxZooming")
local nauvisMelange  = require("modules.nauvisMelange")

if script.active_mods["gvv"] then require("__gvv__.gvv")() end

local flyingSpeedModeSymbols = {"0", ">", ">>"}
local flyingSpeedModeColors = {colors.lightgrey, colors.cyan, colors.purple}
local flyingAccelerationSymbols = {"-", "<", "*"}
local flyingAccelerationColors = {colors.red, colors.yellow, colors.green}
local this = nil

modules.control = {
	name = "control",
	isEnabled = nil,

	onToggleSpeedMode = function (event)
		local player = game.players[event.player_index]
		local pm = playerMemory.get(player)
		if(pm.mode~="accelerate" and pm.mode ~= "hover") then return end
		local v = pm.speedMode
		if v == 3 then v = 1 else v = v + 1 end
		this.setSpeedMode(pm, v)
	end,

	setSpeedMode = function(playerMemory, newMode)
		local pm = playerMemory
		if newMode > 3 then newMode = 3 elseif newMode < 1 then newMode = 1 end
		if pm.speedMode == newMode then return end
		pm.speedMode = newMode
		--log.print("setSpeedMode ",pm.speedMode," ",flyingSpeedModeSymbols[pm.speedMode])
		flyingText.create(pm.player, flyingSpeedModeSymbols[pm.speedMode], flyingSpeedModeColors[pm.speedMode])
		pm.speedModifier = pm.speedTable[pm.speedMode]
	end,

	onToggleAccelerationMode = function (event)
		local player = game.players[event.player_index]
		local pm = playerMemory.get(player)
		if pm.mode~="accelerate" and pm.mode ~= "hover" then return end

		if pm.accelerationMode == 3 then pm.accelerationMode = 1 else pm.accelerationMode = pm.accelerationMode + 1 end
		flyingText.create(player, flyingAccelerationSymbols[pm.accelerationMode], flyingAccelerationColors[pm.accelerationMode])
		pm.isWalking = true --TODO check necessity
		--if pm.mode == "accelerate" then modules.modeAccelerate.onAccelerationModeChanged(pm) end
		if pm.mode == "hover" then modules.modeHover.onAccelerationModeChanged(pm) end
	end,

	onToggleHover = function(eventOrPlayerMemory) -- on_lua_shortcut event or PlayerMemory
		log.print("onToggleHover(..)")
		local player = nil
		local pm = nil
		if eventOrPlayerMemory.input_name ~= nil then
			player = game.get_player(eventOrPlayerMemory.player_index)
			pm = playerMemory.get(player)
		else
			pm = eventOrPlayerMemory --TODO asuming PlayerMemory
			player = pm.player
		end

		if pm.mode == "zoom" then
			if pm.canHover then
				pm.canHover = false
				player.print("Zoom mode. Hover mode off.")
			else
				pm.canHover = true
				modules.modeZoom.init(pm)
				player.print("Zoom mode. Hover mode on.")
			end
			return
		end

		if not pm.isHovering then
			-- try turn on hover
			if player.character == nil then return end
			if pm.movementEnergy > 0.1 then pm.isHovering = true
			elseif tools.tryAddMovementEnergy(pm,"hover") then pm.isHovering = true
			else return end
		else
			--onHoverStopped(pm)
			pm.isHovering = false
		end
		--if pm.isHovering then onHoverStarted(pm) end
		log.trace("onToggleHover ", pm.isHovering)

		if pm.isHovering and pm.mode == "accelerate" then
			pm.mode = "hover"
			modules.modeHover.init(pm)
		elseif not pm.isHovering and pm.mode == "hover" then
			pm.mode = "accelerate"
			modules.modeAccelerate.init(pm)
		end
	end,

	onToggleZoom = function(eventOrPlayerMemory) -- on_lua_shortcut event or PlayerMemory
		log.print("onToggleZoom(..)")
		local player = nil
		local pm = nil
		if eventOrPlayerMemory.input_name ~= nil then
			player = game.get_player(eventOrPlayerMemory.player_index)
			pm = playerMemory.get(player)
		else
			pm = eventOrPlayerMemory --TODO asuming PlayerMemory
			player = pm.player
		end

		if pm.mode == "zoom" then
			-- turn off zoom mode
			if pm.isHovering then
				pm.mode = "hover"
				modules.modeHover.init(pm)
				player.print("Zoom mode off. Hover mode on.")
			else 
				pm.mode = "accelerate"
				player.print("Zoom mode off.")
			end
		else
			-- turn on zoom mode
			if pm.isHovering then
				pm.mode = "zoom"
				pm.canHover = true
				modules.modeZoom.init(pm)
				player.print("Zoom mode on (hover)")
			else 
				pm.mode = "zoom"
				pm.canHover = false
				player.print("Zoom mode on")
			end
		end
	end,

	onTickOneTime = function (e)
		script.on_nth_tick(nil)
		this.onLoaded(e)
	end,

	onLoaded = function(e)
		log.trace(e.tick," onLoaded")
		if not settings.getIsEnabled() then return end

		for name,module in pairs(modules) do if name~="control" and module.onLoaded ~=nil then module.onLoaded(e) end end

		tools.registerForEvents();

		global.lastTick = global.lastTick or e.tick-1		
		modules.kuxZooming.onZoomFactorChanged_register()
		modules.nauvisMelange.onSpiceInfluenceChanged_add()

		this.isEnabled = false
		global.tickFreqency = 0
		global.nthTick = 0
		settings.check.cheatMode()

		--log.print("isMultiplayer: ",global.isMultiplayer)

		global.isMultiplayer = game.is_multiplayer()
		if not global.isMultiplayer then
			global.player = game.get_player(1)
			global.playerMemory = playerMemory.get(global.player)
		end

		for _, player in pairs(game.players) do
			local pm = playerMemory.get(player)
			if player.character ~= nil then
				pm.isWalking = player.walking_state.walking
				pm.position = player.position
				pm.movementBonus = tools.getMovementBonus(player)
				pm.tileWalkingSpeedModifier = tools.getTileSpeedModifier(player)
				pm.location.surfaceName = player.surface.name
				pm.location.tilePosition = player.character.surface.get_tile(player.character.position).position
			end
			if(nauvisMelange.isAvailable) then
				pm.hasSpiceInfluence = nauvisMelange.getHasSpiceInfluence(pm)
			end
		end

		this.enable()
	end,

	onTickSafe = function (e)
		try(
			function () this.onTickEx(e) end,
			function (ex) print(ex)	end
		)
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
			local pm = playerMemory.get(player)
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
			this.initPlayer(player, "player character detected")
		elseif player.character == nil then
			return
		end

		-- here because used in mode zoom and in mode hover
		if not global.cheatMode and pm.isHovering then
			local consumption = 0.0002778 * ticks -- 1 min / buffer
			if pm.movementEnergy - consumption < 0 then
				if not tools.tryAddMovementEnergy(pm,"hover") then
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
		if    (mode == "accelerate"           ) then modeAccelerate.onTick(e, pm)
		elseif(mode == "hover"                ) then modeHover.onTick(e, pm)
		elseif(mode == "zoom" and pm.canHover ) then modeZoom.onTick(e, pm) end
	end,

	setTick = function(n)
		if(global.tickFreqency == n) then return end
		script.on_nth_tick(nil)
		if n > 0 then script.on_nth_tick(n, this.onTick) end
		global.tickFreqency = n
		global.nthTick = 0
		log.trace("setTick ",n)
	end,

	enable = function ()
		log.trace(this.name, ".enable()")
		if this.isEnabled then return end

		for _, player in pairs(game.players) do
			this.initPlayer(player)
			::next::
		end
		if global.isMultiplayer then
			this.setTick(1)
		else
			this.setTick(10)
		end
		this.isEnabled = true
	end,

	initPlayer = function (player, reason)
		log.print(this.name, ".initPlayer(",player.index,") ",reason)
		--if(playerMemory.get(player).isInitialized) then error("initPlayer") end

		if(not player.connected or player.character == nil) then return end
		local pm = playerMemory.get(player)
		local mode = pm.mode
		pm.canHover = true -- enable hover (in zoom mode) for all

		if    (mode == "accelerate") then modeAccelerate.init(pm)
		elseif(mode == "hover"     ) then modeHover.init(pm)
		elseif(mode == "zoom"      ) then modeZoom.init(pm) end
		pm.isInitialized = true

	end,

	disable = function ()
		if not this.isEnabled then return end
		script.on_nth_tick(nil)
		global.tickFreqency = 0
		for _, player in pairs(game.players) do
			local pm = playerMemory.get(player)
			tools.tryRestoreCharacterRunningSpeedModifier(player)
			pm.isInitialized = false
		end
		this.isEnabled = false
	end,

	onModeChanged = function (playerMemory, newMode)
		local player = playerMemory.player
		playerMemory.mode = newMode
		if(player.character == nil) then
			player.print("Kux-Running: Can not change the mode. No character.", colors.lightred)
			playerMemory.hasCharakter = false
			return
		end
		if newMode == "none" then
			tools.tryRestoreCharacterRunningSpeedModifier(player)
		elseif newMode == "accelerate" then
			modules.modeAccelerate.init(playerMemory)
		elseif newMode == "hover" then
			modules.modeHover.init(playerMemory)
		elseif newMode == "zoom" then
			modules.modeZoom.init(playerMemory)
			modules.kuxZooming.onModeChanged(playerMemory.player)
		end
	end,

	onSurfaceChanged = function(playerMemory, surface)
		local pm = playerMemory
		pm.location.surfaceName = surface.name
	end,

	onTilePositionChanged = function(playerMemory, tile)
		--log.trace("onTilePositionChanged position:",tile.position.x,";",tile.position.y,", name:", tile.prototype.name)
		local pm = playerMemory
		pm.location.tilePosition             = tile.position
		pm.location.tileWalkingSpeedModifier = tools.getTileSpeedModifier(tile)
		pm.location.tileName                 = tile.prototype.name
	end,

	--- event on_player_changed_surface
	onPlayerChangedSurface= function (e)
		--BUG? e.surface_index returns previous surface index!
		local player = game.get_player(e.player_index)
		local surface = player.surface
		local surfaceIndex = player.surface.index
		local pm = playerMemory.get(player)
		-- local surface = game.get_surface(e.surface_index) --
		log.trace("onPlayerChangedSurface"," player:", e.player_index, " index:", surfaceIndex,"(",e.surface_index,"), name:", surface.name, " hasCharacter:",player.character~=nil)
		this.onSurfaceChanged(pm, surface)
	end,

	--- event on_player_changed_position
	onPlayerChangedPosition = function (e)
		-- the event 'on_player_changed_position' seems to be called only one time per tile
		local player = game.get_player(e.player_index)
		local pm = playerMemory.get(player)
		--if pm.isHovering then return end --UPS optimization, but we need information on orbit!

		if player.character then
			--log.trace("onPlayerChangedPosition", player.character.position.x,";",player.character.position.y)
			local surface = player.character.surface
			local surfaceName = surface.name
			local hasSurfaceChanged = pm.location.surfaceName ~= surfaceName
			if hasSurfaceChanged then this.onSurfaceChanged(pm, surface)end
			local tile = surface.get_tile(player.position)
			local tilePosition = tile.position
			local hasTilePositionChanged = hasSurfaceChanged or pm.location.tilePosition.x ~= tilePosition.x or pm.location.tilePosition.y ~= tilePosition.y
			if hasTilePositionChanged then this.onTilePositionChanged(pm, tile) end

			if player.walking_state.walking then
				if not pm.isWalking and global.tickFreqency ~= 1 then
					this.setTick(1, "on_player_changed_position by walking")
				end
			else
				log.trace("onPlayerChangedPosition ", player.walking_state.walking, pm.isWalking, global.tickFreqency, "teleport")
			end
		else
			log.trace("onPlayerChangedPosition ", "no-character")
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
		log.trace("onPlayerArmorInventoryChanged")
		local player = game.get_player(e.player_index)
		local pm = playerMemory.get(player)
		local value = tools.getMovementBonus(player)
		if pm.movementBonus == value then return end
		this.onMovementBonusChanged(pm)
	end,

	onMovementBonusChanged = function(playerMemory)
		log.trace("onMovementBonusChanged")
	end

}

this = modules.control --init local this
script.on_init                 (function () log.trace("on_init") end)
script.on_configuration_changed(function () log.trace("on_configuration_changed") end)
script.on_load                 (function () log.trace("on_load") end)
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