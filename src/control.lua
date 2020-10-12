modules = {}
require("lib/lua")
local core           = require("lib/core")
local debug          = require("lib/debug"); modules.debug.modName = "Kux-Running"
local colors         = require("lib/colors")
local flyingText     = require("lib/flyingText")
local settings       = require("module/settings")
local tools          = require("module/tools")
local playerMemory   = require("module/playerMemory")
local modeHover      = require("module/modeHover")
local modeAccelerate = require("module/modeAccelerate")
local modeZoom       = require("module/modeZoom")
local kuxZooming     = require("module/kuxZooming")
local nauvisMelange  = require("module/nauvisMelange")

if script.active_mods["gvv"] then require("__gvv__.gvv")() end

local flyingSpeedModeSymbols = {"0", ">", ">>"}
local flyingSpeedModeColors = {colors.lightgrey, colors.cyan, colors.purple}
local flyingAccelerationSymbols = {"-", "<", "*"}
local flyingAccelerationColors = {colors.red, colors.yellow, colors.green}
local this = nil

modules.control = {

	isEnabled = nil,

	onToggleSpeedMode = function (event)
		local player = game.players[event.player_index]
		local m = playerMemory.get(player)
		if(m.mode~="accelerate" and m.mode ~= "hover") then return end

		if m.speedMode == 3 then m.speedMode = 1 else m.speedMode = m.speedMode + 1 end
		flyingText.create(player, flyingSpeedModeSymbols[m.speedMode], flyingSpeedModeColors[m.speedMode])
		m.speedModifier = m.speedTable[m.speedMode]
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
		debug.print("onToggleHover")
		local player = nil
		local pm = nil
		if eventOrPlayerMemory.input_name ~= nil then
			player = game.get_player(eventOrPlayerMemory.player_index)
			pm = playerMemory.get(player)
		else
			pm = eventOrPlayerMemory --TODO asuming PlayerMemory
			player = pm.player
		end

		if not pm.isHovering then
			if player.character == nil then return end
			if(pm.hoverEnergy>0.5) then pm.isHovering = true
			elseif this.tryAddHoverEnergy(pm) then pm.isHovering = true
			else return end
		else
			pm.isHovering = false
		end
		debug.print(pm.isHovering)

		if pm.isHovering and pm.mode == "accelerate" then
			pm.mode = "hover"
			modules.modeHover.init(pm)
		elseif not pm.isHovering and pm.mode == "hover" then
			pm.mode = "accelerate"
			modules.modeAccelerate.init(pm)
		end
	end,

	tryAddHoverEnergy = function (playerMemory)
		debug.print("tryAddHoverEnergy")
		local pm = playerMemory
		local player = pm.player
		if global.cheatMode then pm.hoverEnergy = 1; return true end

		if nauvisMelange.isAvailable then
			if(true) then
				if nauvisMelange.fillBuffer(player.index, 1.0) then
					pm.hoverEnergy = pm.hoverEnergy + 1
					return true
				else
					print("nauvisMelange.fillBuffer returns false")
					player.print("You need more spice to use the hover mode!", colors.lightred)
					return false
				end
			else --fallback to self consumption
				local inventory = player.get_main_inventory()
				local count = inventory.get_item_count("spice")
				if(count >= 10) then
					inventory.remove({name="spice", count=10})
					pm.hoverEnergy = pm.hoverEnergy + 1
					return true
				else
					player.print("You need more spice to hover!", colors.lightred)
					return false
				end
			end
		else
			local inventory = player.get_main_inventory()
			local count = inventory.get_item_count("coal")
			if(count >= 100) then
				inventory.remove({name="coal", count=100})
				pm.hoverEnergy = pm.hoverEnergy + 1
				debug.print("use coal")
				return true
			else
				player.print("You need more coal to hover!", colors.lightred)
				return false
			end
		end
	end,

	tryAddTurboEnergy = function (playerMemory)
		debug.print("tryAddTurboEnergy")
		local pm = playerMemory
		local player = pm.player
		if global.cheatMode then pm.turboEnergy = 1; return true end

		if nauvisMelange.isAvailable then
			if(true) then
				if nauvisMelange.fillBuffer(player.index, 1.0) then
					pm.turboEnergy = pm.turboEnergy + 1
					return true
				else
					print("nauvisMelange.fillBuffer returns false")
					player.print("You need more spice to use the turbo!", colors.lightred)
					return false
				end
			else --fallback
				local inventory = player.get_main_inventory()
				local count = inventory.get_item_count("spice")
				if(count >= 10) then
					inventory.remove({name="spice", count=10})
					pm.turboEnergy = pm.turboEnergy + 1
					return true
				else
					player.print("You need more spice to use the turbo!", colors.lightred)
					return false
				end
			end
		else
			--local count = inventory.get_item_count("nuclear-fuel")
			--local count = inventory.get_item_count("rocket-fuel")
			local inventory = player.get_main_inventory()
			local count = inventory.get_item_count("coal")
			if(count >= 100) then
				inventory.remove({name="coal", count=100})
				pm.turboEnergy = pm.turboEnergy + 1
				return true
			else
				player.print("You need more fuel to use the turbo!", colors.lightred)
				return false
			end
		end
	end,

	onTickOneTime = function (e)
		script.on_nth_tick(nil)
		this.onLoaded(e)
	end,

	onLoaded = function(e)
		global.lastTick = global.lastTick or e.tick-1
		modules.kuxZooming.onZoomFactorChanged_register()
		global.isMultiplayer = game.is_multiplayer()
		this.isEnabled = false
		global.tickFreqency = 0
		global.nthTick = 0
		settings.check.cheatMode()

		if not global.isMultiplayer then
			global.player = game.get_player(1)
			global.playerMemory = playerMemory.get(global.player)
		end
		if not settings.getIsEnabled() then return end
		for _, player in pairs(game.players) do
			local pm = playerMemory.get(global.player)
			pm.isWalking = player.walking_state.walking
		end
		this.enable()
	end,

	onTick = function (e) -- on_nth_tick(1)
		local nthTick = global.nthTick or 0
		global.currentTick = e.tick
		local ticks = e.tick - global.lastTick
		global.lastTick = e.tick

		if not global.isMultiplayer then
			if global.player.character == nil then
				if playerMemory.hasCharakter == true then
					playerMemory.hasCharakter = false
				end
				return
			elseif not playerMemory.hasCharakter then
				playerMemory.hasCharakter = true
				this.initPlayer(global.player)
			end

			local pm = global.playerMemory
			local mode = pm.mode
			if pm.mode == "hover" then --TODO or zoom, use isHovering
				local consumption = 0.0002778 * ticks -- 1 min / buffer
				pm.hoverEnergy = pm.hoverEnergy - consumption
				debug.print("consumption: ",consumption," (",pm.hoverEnergy,")")
				if pm.hoverEnergy < 0 then
					this.tryAddHoverEnergy(pm)
					if pm.hoverEnergy < 0 then
						this.onToggleHover(pm) -- toggle off
					end
				end
				debug.print("hoverEnergy: ",pm.hoverEnergy)
			end

			--if(mem.mode ~= mode) then settings.onModeChanged(mem, mode) end -- this will also call control.onModeChanged
			if    (mode == "accelerate" and nthTick == 0) then modeAccelerate.onTick(e, pm)
			elseif(mode == "hover"                      ) then modeHover.onTick(e, pm)
			elseif(mode == "zoom" and pm.canHover       ) then modeZoom.onTick(e, pm) end

			if(global.player.walking_state.walking ~= this.isWalking) then
				this.isWalking = global.player.walking_state.walking
				if(this.isWalking and mode == "hover" or (mode == "zoom" and pm.canHover)) then
					this.setTick(1)
				else
					this.setTick(10)
				end
			elseif global.tickFreqency == 1 then
				global.nthTick = iif(nthTick == 9, 0, nthTick + 1)
			end
		else
			for _, player in pairs(game.players) do
				local pm = playerMemory.get(player)
				if pm.hasCharacter and (not player.connected or global.player.character == nil) then
					pm.hasCharacter = false
					goto next
				elseif not playerMemory.hasCharakter and player.connected and global.player.character ~= nil then
					pm.hasCharacter = true
					this.initPlayer(player)
				end

				local mode = pm.mode
				if(pm.mode ~= mode) then settings.onModeChanged(pm, mode) end -- this will also call control.onModeChanged
				if    (mode == "accelerate" and nthTick == 0) then modeAccelerate.onTick(e, pm)
				elseif(mode == "hover"                      ) then modeHover.onTick(e, pm)
				elseif(mode == "zoom" and pm.canHover       ) then modeZoom.onTick(e, pm) end
				::next::
			end
			global.nthTick = iif(nthTick == 9, 0, nthTick + 1)
		end
	end,

	setTick = function(n)
		if(global.tickFreqency == n) then return end
		script.on_nth_tick(nil)
		if n > 0 then script.on_nth_tick(n, this.onTick) end
		global.tickFreqency = n
		global.nthTick = 0
	end,

	enable = function ()
		if this.isEnabled then return end

		for _, player in pairs(game.players) do
			this.initPlayer(player)
			::next::
		end
		this.setTick(10)
		this.isEnabled = true
	end,

	initPlayer = function (player)
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
			player.print("Kux-Running: Can not change the mode. No character.")
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
}

this = modules.control --init locaal this

script.on_event("Kux-Running_hotkey-ToggleAccelerationMode", this.onToggleAccelerationMode)
script.on_event("Kux-Running_hotkey-ToggleSpeedMode", this.onToggleSpeedMode)
script.on_event("Kux-Running_hotkey-ToggleHover", this.onToggleHover)
script.on_nth_tick(1, this.onTickOneTime)
--script.on_configuration_changed(settings.onConfigurationChanged)
script.on_event(defines.events.on_runtime_mod_setting_changed, settings.onConfigurationChanged)

remote.add_interface("Kux-Running", require("module/interface"))
