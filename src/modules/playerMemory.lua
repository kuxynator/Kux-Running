local this = nil
local dataVersion = 10 -- increment if playerMemory_prototype changed
local playerMemory_prototype = {
	dataVersion          = dataVersion,
	tableName            = "playerMemory",
	player               = nil,
	hasCharakter         = false,
	isWalking            = true,  -- true to trigger the initialization at first tick
	accelerationMode     = 2,     -- 1 slow, 2 progressive, 3 fast (toggle wwith F7)
	maxWalkingSpeedFactor = 1, 	  -- calculated later >> pm.speedTable[pm.speedMode]
	maxWalkingSpeed      = 0.15,  -- calculated later >> 0.15 * pm.maxWalkingSpeedFactor
	defaultWalkingSpeed  = 0.15,  -- default game walking speed w/o mod modifications. calculated later >> calc.maxSpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, 1)
	walkingSpeed         = 0.15,  -- current walking speed. calculated later  >> calc.maxSpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.initialSpeedFactor)
	currentModifier      = 0,     -- current modifier, the calulated character_running_speed_modifier
	isAccelerating       = false,
	acceleratingTick     = 0,     -- game tick on accelleration start
	accelerationDuration = 0,     -- duration of current acceleration
	speedModifier        = 0,     -- ???
	speedTable           = {1, 2, 5},
	speedMode            = 1,      -- index for speedTable, toggle with F6
	renderMode           = 0, --player.render_mode,
	zoomFactor           = 1, -- kuxZooming.getZoomFactor(player),
	mode                 = 0, --settings.getMode(player),
	initialSpeedFactor   = 0, --settings.getInitialSpeedFactor(player),
	zoomSpeedModificator = 0, --settings.getZoomSpeedModificator(player),
	canHover             = false,
	isHovering           = false,
	movementEnergy       = 0,
	hasSpiceInfluence    = false,
	movementBonus = 0,
	location 			 = { -- use tools.updateLocation()
		surfaceName              = nil,
		tilePosition             = nil,
		tileName                 = nil,
		tileWalkingSpeedModifier = 0 -- player.character.surface.get_tile(player.position).prototype.walking_speed_modifier
	}
}

local getPlayerMemoryTable=function ()
	global.playerMemoryTable = global.playerMemoryTable or {tableName="playerMemoryTable"}
	return global.playerMemoryTable
end

local new = function (player)
	local pm = Tools.deepcopy(playerMemory_prototype)
	pm.dataVersion          = dataVersion
	pm.tableName            = "playerMemory"
	pm.player               = player
	pm.hasCharakter         = false
	pm.isWalking            = true -- true to trigger the initialization at first tick
	pm.accelerationMode     = 2     -- 1 slow, 2 progressive, 3 fast (toggle wwith F7)
	pm.maxWalkingSpeedFactor = 1 	  -- calculated later >> pm.speedTable[pm.speedMode]
	pm.maxWalkingSpeed      = 0.15  -- calculated later >> 0.15 * pm.maxWalkingSpeedFactor
	pm.defaultWalkingSpeed  = 0.15  -- default game walking speed w/o mod modifications. calculated later >> calc.maxSpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, 1)
	pm.walkingSpeed         = 0.15  -- current walking speed. calculated later  >> calc.maxSpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, pm.initialSpeedFactor)
	pm.currentModifier      = 0     -- current modifier, the calulated character_running_speed_modifier
	pm.isAccelerating       = false
	pm.acceleratingTick     = 0     -- game tick on accelleration start
	pm.accelerationDuration = 0     -- duration of current acceleration
	pm.speedModifier        = 0     -- ???
	Settings.check.speedTable(pm)
	pm.speedMode            = 1      -- index for speedTable, toggle with F6
	pm.renderMode           = player.render_mode
	pm.zoomFactor           = KuxZooming.getZoomFactor(player)
	pm.mode                 = Settings.getMode(player)
	pm.initialSpeedFactor   = Settings.getInitialSpeedFactor(player)
	pm.zoomSpeedModificator = Settings.getZoomSpeedModificator(player)
	pm.canHover             = false
	pm.isHovering           = false
	pm.movementEnergy       = 0
	pm.hasSpiceInfluence    = false
	--if player.character then
		pm.movementBonus        = Tools.getMovementBonus(player)
		Tools.updateLocation(pm)
	--end
	return pm
end

local migrate = function (table, default)
	for name, value in pairs(default) do
		if(table[name] == nil) then table[name] = value end
	end
end

--- Player memory module
-- @module playerMemory
PlayerMemory = {
	muduleName = "playerMemory",
	table = nil, -- initialized in get(), because 'global' is requiered

	--- Gets the memory for the specified player
	--@param player  LuaPlayer or player index
	--@return PlayerMemory table {tableName = "playerMemory",...}
	get = function (player)
		if type(player) == "number" then player = game.get_player(player) end
		if this.table == nil then this.table=getPlayerMemoryTable() end
		this.table[player.index] = this.table[player.index] or new(player)
		local pm = this.table[player.index]

		--migration
		if pm.dataVersion < dataVersion then
			local default = new(player)
			for name, value in pairs(default) do
				if pm[name] == nil then pm[name] = value end
				if name=="location" then migrate(pm[name], value) end
			end
			Settings.check.speedTable(pm)
			pm.dataVersion = dataVersion
		end

		return pm
	end
}
Modules.playerMemory = PlayerMemory -- add to modules
this = PlayerMemory -- init local this