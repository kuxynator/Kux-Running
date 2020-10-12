print("loading module/playerMemory.lua")
local debug = require("lib/debug")
local kuxZooming = require("module/kuxZooming")
local settings   = require("module/settings")

local this = nil

--- Player memory module
-- @module playerMemory
modules.playerMemory = {
	muduleName = "playerMemory",
	dataVersion = 4, -- increment if getDefault changed
	table = global.playerMemoryTable,

	getDefault = function (player)
		return {
			dataVersion          = this.dataVersion,
			tableName            = "playerMemory",
			player               = player,
			isWalking            = true,  -- true to trigger the initialization at first tick
			accelerationMode     = 2,     -- 1 slow, 2 progressive, 3 fast
			currentModifier      = 0,     -- current modifier
			modifierMax          = 0,     -- record the modifier maximum (with all speed gear working)
			isAccelerating       = false,
			acceleratingTick     = 0,     -- game tick on accelleration start
			accelerationDuration = 0,     -- duration of current acceleration
			speedModifier        = 0,
			speedTable           = {0, 1.5, 5},
			speedMode            = 1,      -- 1 normal, 2: 1,5, 3: 5
			renderMode           = player.render_mode,
			zoomFactor           = kuxZooming.getZoomFactor(player),
			mode                 = settings.getMode(player),
			initialSpeedFactor   = settings.getInitialSpeedFactor(player),
			accelerationFactor   = settings.getAccelerationFactor(player),
			zoomSpeedModificator = settings.getZoomSpeedModificator(player),
			canHover             = false,
			isHovering           = false,
			hoverEnergy          = 0
		}
	end,

	migrate = function (name, obj, def)
		if(obj[name] == nil) then obj[name] = def[name] end
	end,

	--- Gets the memory for the specified player
	-- @player: LuaPlayer
	get = function (player)
		if type(player) == "number" then player = game.get_player(player) end
		global.playerMemoryTable = global.playerMemoryTable or {}
		global.playerMemoryTable[player.index] = global.playerMemoryTable[player.index] or this.getDefault(player)

		local m = global.playerMemoryTable[player.index]

		--migratiom
		if m.dataVersion < this.dataVersion then
			local default = this.getDefault(player)
			this.migrate("initialSpeedFactor"  , m, default)
			this.migrate("accelerationFactor"  , m, default)
			this.migrate("zoomSpeedModificator", m, default)
			this.migrate("canHover"            , m, default)
			this.migrate("isHovering"          , m, default)
			this.migrate("hoverEnergy"         , m, default)
			--this.migrate("zoomFactor"        , m, default)
			m.dataVersion = this.dataVersion
		end

		return m
	end
}

this = modules.playerMemory -- init local this
return this