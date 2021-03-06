local this = nil

ModeZoom = {
	name ="modeZoom",

	onLoaded = function ()

	end,

	init = function (playerMemory)
		if(playerMemory.canHover) then
			playerMemory.player.character_running_speed_modifier = -0.5 --TODO calc best value
		else
			Tools.tryRestoreCharacterRunningSpeedModifier(playerMemory.player)
		end
	end,

	onTick = function (event, playerMemory)
		local pm = playerMemory
		local player = playerMemory.player
		local isWalking = player.walking_state.walking
		local direction = player.walking_state.direction

		if player.character.surface.get_tile(player.position).prototype.name == "se-space" then
			return
		end

		if(isWalking and not pm.isWalking) then
			--start walking
			player.character_running_speed_modifier = -0.999 -- stop the walk animation
			Modules.control.setTick(1)
		elseif not isWalking and pm.isWalking then
			--stop walking
			player.character_running_speed_modifier = -0.5 --TODO calc best value
			Modules.control.setTick(10)
		end
		pm.isWalking = isWalking
		if not isWalking then return end

		local xd = 1
		local yd = 1;
		if     direction == 0 then xd =  0; yd = -1
		elseif direction == 1 then xd =  1; yd = -1
		elseif direction == 2 then xd =  1; yd =  0
		elseif direction == 3 then xd =  1; yd =  1
		elseif direction == 4 then xd =  0; yd =  1
		elseif direction == 5 then xd = -1; yd =  1
		elseif direction == 6 then xd = -1; yd =  0
		elseif direction == 7 then xd = -1; yd = -1
		end

		local f = 0.15 / pm.zoomFactor * Settings.getZoomSpeedModificator(player) --TODO cache value
		local xo=xd*f
		local yo=yd*f
		pm.position = pm.position or player.position --TODO optimize, move to onLoaded
		if math.abs(pm.position.x - player.position.x) > 10 or math.abs(pm.position.y - player.position.y) > 10 then
			-- possible teleport, use new position
			pm.position = player.position
			return
		end
		pm.position = {x=pm.position.x + xo, y=pm.position.y + yo}

		local tileName = Tools.getTileName(player.surface.get_tile(pm.position))
		if tileName=="out-of-factory" 	-- Factorissimo2
		or tileName=="underground-wall" -- Surfaces_Reloaded	"surfacedmod-cavern-*""
		or tileName=="sky-void" 		-- Surfaces_Reloaded	"surfacedmod-platform-*""
		or tileName=="out-of-map" 		-- base
		then
			pm.position = player.position
			return
		end

		player.teleport(pm.position)
	end
}
Modules.modeZoom = ModeZoom
this = ModeZoom