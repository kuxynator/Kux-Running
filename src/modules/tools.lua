local gameSpeed = nil -- used for updateWalkingSpeed

--- Tools module
-- @module tools
Tools = {

	registerEvents=function()
		local control = Modules.control
		script.on_event(defines.events.on_player_created                , function () Log.print("on_player_created") end)
		script.on_event(defines.events.on_player_joined_game            , function () Log.print("on_player_joined_game") end)

		script.on_event("Kux-Running_hotkey-ToggleAccelerationMode"     , control.onToggleAccelerationMode)
		script.on_event("Kux-Running_hotkey-ToggleSpeedMode"            , control.onToggleSpeedMode)
		script.on_event("Kux-Running_hotkey-ToggleHover"                , control.onToggleHover)
		script.on_event("Kux-Running_hotkey-ToggleZoom"                 , control.onToggleZoom)		
		script.on_event(defines.events.on_player_armor_inventory_changed, control.onPlayerArmorInventoryChanged)
		script.on_event(defines.events.on_player_changed_position       , control.onPlayerChangedPosition)
		script.on_event(defines.events.on_player_changed_surface        , control.onPlayerChangedSurface)
		script.on_event(defines.events.on_player_died                   , function () Log.print("on_player_died") end)
		script.on_event(defines.events.on_player_kicked                 , function () Log.print("on_player_kicked") end)
		script.on_event(defines.events.on_player_left_game              , function () Log.print("on_player_left_game") end)
		script.on_event(defines.events.on_player_removed                , function () Log.print("on_player_removed") end)
		script.on_event(defines.events.on_player_respawned              , function () Log.print("on_player_respawned") end)
	end,

	unregisterEvents=function()
		script.on_event(defines.events.on_player_created                , nil)
		script.on_event(defines.events.on_player_joined_game            , nil)

		script.on_event("Kux-Running_hotkey-ToggleAccelerationMode"     , nil)
		script.on_event("Kux-Running_hotkey-ToggleSpeedMode"            , nil)
		script.on_event("Kux-Running_hotkey-ToggleHover"                , nil)
		script.on_event("Kux-Running_hotkey-ToggleZoom"                 , nil)
		script.on_event(defines.events.on_player_armor_inventory_changed, nil)
		script.on_event(defines.events.on_player_changed_position       , nil)
		script.on_event(defines.events.on_player_changed_surface        , nil)
		script.on_event(defines.events.on_player_died                   , nil)
		script.on_event(defines.events.on_player_kicked                 , nil)
		script.on_event(defines.events.on_player_left_game              , nil)
		script.on_event(defines.events.on_player_removed                , nil)
		script.on_event(defines.events.on_player_respawned              , nil)
	end,


	getSurfaceNameOrDefault = function (player)
		return player.surface.name
	end,

	getTilePositionOrDefault = function(player)
		local character = player.character
		if not character then return nil end
		return character.surface.get_tile(character.position).position
	end,

	tryAddMovementEnergy = function (playerMemory,usage)
		--log.trace("tryAddMovementEnergy")
		local nauvisMelange = Modules.nauvisMelange
		local pm = playerMemory
		local player = pm.player

		if global.cheatMode then pm.movementEnergy = 1000000; return true end

		if nauvisMelange.isAvailable then
			if(true) then
				if nauvisMelange.tryConsumeSpice(pm) then
					pm.movementEnergy = 1000000000 -- buffer nut used
					return true
				else
					--log.print("nauvisMelange.tryConsumeSpice returns false")
					player.print("You need more spice to use the "..usage.." mode!", Colors.lightred)
					return false
				end
			else --fallback to self consumption
				local inventory = player.get_main_inventory()
				local count = inventory.get_item_count("spice")
				if(count >= 10) then
					inventory.remove({name="spice", count=10})
					pm.movementEnergy = pm.movementEnergy + 1
					return true
				else
					player.print("You need more spice for "..usage.."!", Colors.lightred)
					return false
				end
			end
		else
			local itemName = "movement-fuel"
			local inventory = player.get_main_inventory()
			local count = inventory.get_item_count(itemName)
			local consume = 1
			if(count >= consume) then
				inventory.remove({name=itemName, count=consume})
				pm.movementEnergy = pm.movementEnergy + 1/30
				print({"","use "..consume.." ",{itemName}})
				return true
			else
				player.print({"","You need more ",{itemName}," to "..usage.."!"}, Colors.lightred)		
				return false
			end
		end
	end,

	getMovementBonus = function(player)
		local armorInventory = player.get_inventory(defines.inventory.character_armor)

		if armorInventory == nil then return 0 end
		local armor = armorInventory[1]
		if armor==nil or  armor.valid_for_read==false or armor.grid== nil then return 0 end

		local bonus = 0
		for _, equipment in pairs(armor.grid.equipment) do
			bonus = bonus + equipment.movement_bonus
		end
		return bonus
	end,

	getTileSpeedModifier = function (obj)
		if obj.object_name == "LuaPlayer" then return obj.character.surface.get_tile(obj.position).prototype.walking_speed_modifier end
		if obj.object_name == "LuaTile" then return obj.prototype.walking_speed_modifier end
		error("Argument out of range. name:obj ",serpent.block(obj))
	end,
	getTileName = function (obj)
		if obj.object_name == "LuaPlayer" then return obj.character.surface.get_tile(obj.position).prototype.name end
		if obj.object_name == "LuaTile" then return obj.prototype.name end
		error("Argument out of range. name:obj ",serpent.block(obj))
	end,

	tryRestoreCharacterRunningSpeedModifier = function(playerMemory)
		local pm = playerMemory
		local player = pm.player
		if player.character == nil then
			player.print("Can not restore character speed modifier. No character.", Colors.red)
			return false
		else
			player.character_running_speed_modifier = Settings.getDefaultCharacterRunningSpeedModifier(player)
			return true
		end
	end,

	round = function (number, decimalDigits)
		local f = 10^decimalDigits
		return math.floor(number*f + 0.5) / f
	end,

	updateWalkingSpeed = function (playerMemory, ignoreModifiers)
		local pm = playerMemory
		if gameSpeed ~= game.speed then
			gameSpeed = game.speed
			Settings.check.initialSpeedFactor(pm)
			Settings.check.speedTable(pm)
		end

		local speedFactor = iif(pm.accelerationMode <= 2, pm.initialSpeedFactor, pm.speedTable[pm.speedMode])

		--pm.movementBonus            = this.getMovementBonus(pm.player)        --set by event
		--pm.location.tileWalkingSpeedModifier = this.getTileSpeedModifier(pm.player)	--set by event
		pm.defaultWalkingSpeed      = Calc.walkingSpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, 0)

		pm.initialSpeedFactor       = Settings.getInitialSpeedFactor(pm.player)
		pm.initialSpeed             = 0.15 * pm.initialSpeedFactor

		pm.maxWalkingSpeedFactor    = pm.speedTable[pm.speedMode]
		pm.maxWalkingSpeed          = 0.15 * pm.maxWalkingSpeedFactor

		pm.walkingSpeed             = Calc.walkingSpeed(pm.movementBonus, pm.location.tileWalkingSpeedModifier, speedFactor-1)
		pm.currentModifier          = Calc.speedModifierByFactor(pm.movementBonus, pm.location.tileWalkingSpeedModifier, speedFactor)
	end,

	updateLocation = function (playerMemory, reason)
		if Tools.tryUpdateLocation(playerMemory, reason) then return end
		if playerMemory.player.character == nil then error("Character required!") end
	end,

	--- Updates playerMemory.location. requires character.
	tryUpdateLocation = function (playerMemory, reason)
		local pm = playerMemory
		local player = pm.player
		--if player.character == nil then return false end
		local surface = player.surface
		local tile = surface.get_tile(player.position)

		pm.location.surface = surface
		pm.location.surfaceName	             = surface.name
		pm.location.isOrbit                  = string.find(pm.location.surfaceName, "Orbit$") -- Space Exploration TODO maybe localized name?

		pm.location.tile = tile
		pm.location.tilePosition             = tile.position
		pm.location.tileWalkingSpeedModifier = tile.prototype.walking_speed_modifier
		pm.location.tileName                 = tile.prototype.name
		pm.location.tilePosition             = tile.position
		pm.location.tileName                 = tile.prototype.name
		return true
	end,

	accelerate = function (playerMemory)
		local pm = playerMemory
		local startTick = 15 --TODO move to config
		local endTick   = 75 --TODO move to config
		if pm.accelerationMode == 1 then
			-- keep slow
			pm.isAccelerating = false
		elseif pm.accelerationMode == 2 then
			pm.accelerationDuration = game.tick - pm.acceleratingTick

			if(pm.accelerationDuration < startTick) then
				-- slow constant		
			elseif pm.accelerationDuration <=endTick then
				pm.walkingSpeed = (pm.accelerationDuration-startTick)/(endTick-startTick)*(pm.maxWalkingSpeed-pm.initialSpeed)+pm.initialSpeed
			else
				pm.walkingSpeed = pm.maxWalkingSpeed
				pm.isAccelerating = false
			end
		elseif pm.accelerationMode == 3 then
			-- fast
			pm.walkingSpeed = pm.maxWalkingSpeed
			pm.isAccelerating = false
		end
		--log.print("tools.accelerate: ",pm.accelerationDuration," ",this.round(pm.walkingSpeed,6)," ",pm.isAccelerating)
	end,

	deepcopy = function(orig)
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[Tools.deepcopy(orig_key)] = Tools.deepcopy(orig_value)
			end
			setmetatable(copy, Tools.deepcopy(getmetatable(orig)))
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end,

	setSpaceshipInventory=function ()
		local spaceship = game.surfaces["nauvis"].find_entity("crash-site-spaceship", {-5,-6})
		local inventory = spaceship.get_inventory(defines.inventory.chest)
		inventory.insert({name="movement-fuel", count=1000})
		print("movement-fuel added to crash-site-spaceship")
	end
}