local log        = require("lib/log")
local colors     = require "lib.colors"
local flyingText = require "lib.flyingText"
local settings   = require "modules.settings"
local this = nil

--- nauvisMelange module
-- @module: nauvisMelange
modules.nauvisMelange = {

	interfaceName = "Kux-Running_nauvisMelange",
	functions = {
		onSpiceInfluenceChanged = function(e)
			log.trace("nauvisMelange.onSpiceInfluenceChanged ",e.player_index, e.on_spice)
			local player = game.get_player(e.player_index)
			local pm = modules.playerMemory.get(player)
			flyingText.create(player, iif(e.on_spice,"..aaahhh..","..*#% urghs.."),iif(e.on_spice,colors.yellow,colors.lightred))
			pm.hasSpiceInfluence = e.on_spice
			pm.movementEnergy = iif(e.on_spice, 1000000, 0)
		end
	},

	modName = "nauvis-melange",
	remoteInterfaceName = "nauvis_melange_player",
	isAvailable = false,

	onSpiceInfluenceChanged_add = function()
		log.trace("nauvisMelange.onSpiceInfluenceChanged_add")
		try(
			function()
				remote.call(this.remoteInterfaceName, "spice_influence_changed_add", this.interfaceName, "onSpiceInfluenceChanged")
				log.print(" : success")
			end,
			function (ex)
				print(ex)
				game.print("Remote interface incompatibility! Please uptate Kux-Running and/or Nauvis Melange.", colors.lightred)
			end
		)
	end,

	onSpiceInfluenceChanged_remove = function()
		try(
			function()
				remote.call(this.remoteInterfaceName, "spice_influence_changed_remove", this.interfaceName, "onSpiceInfluenceChanged")
			end,
			function (ex)
				print(ex)
				game.print("Remote interface incompatibility! Please uptate Kux-Running and/or Nauvis Melange.", colors.lightred)
			end
		)
	end,

	getHasSpiceInfluence = function(playerMemory)
		log.trace("nauvisMelange.getHasSpiceInfluence ",playerMemory.player.index)
		local value = false
		try(	
			function()
				value = remote.call(this.remoteInterfaceName, "has_spice_influence", playerMemory.player.index)
				log.print(" : ",value)
			end,
			function (ex)
				print(ex)
				game.print("Remote interface incompatibility! Please uptate Kux-Running and/or Nauvis Melange.", colors.lightred)
			end
		)		
		return value
	end,

	tryConsumeSpice = function(playerMemory)
		if not this.isAvailable then return false end
		local consequence = "no_consumption"
		local preConsumption = 0
		local factor = 0 -- only activate the trip
		log.trace("tryConsumeSpice ",playerMemory.player.index," ",factor," ", consequence," ", preConsumption)
		local result = false
		try(
			function()
				result = remote.call(this.remoteInterfaceName, "consume_spice", playerMemory.player.index, factor, consequence, preConsumption)
				log.print(" : ",result)
			end,
			function (ex)
				print(ex)
				game.print("Remote interface incompatibility! Please uptate Kux-Runiung and/or Nauvis Melange.", colors.lightred)
			end
		)
		return result
	end,

	--- nauvis_melange_player.consume_spice
	--@param playerIndex	index of player
	--@param factor:        factor
	--@param consequence    'bad_trip'       if bad_trip should be applied
	--                      'no_consumption' all items should be returned if not enough (includes pre_consumed)
	--                      'no_further_consumption' the pre consumed items are not returned
	--@param preConsumption in case an initial amount or so was needed that should not be added to the calculation
	tryConsumeSpiceEx = function (playerMemory, factor, consequence, preConsumption)
		if consequence == nil then consequence = "no_consumption" end
		if preConsumption == nil then preConsumption = 0 end
		if not this.isAvailable then return false end
		log.trace("tryConsumeSpice ",playerMemory.player.index," ",factor," ", consequence," ", preConsumption)
		local result = false
		try(
			function()
				result = remote.call(this.remoteInterfaceName, "consume_spice", playerMemory.player.index, factor, consequence, preConsumption)
			end,
			function (ex)
				print(ex)
				game.print("Remote interface incompatibility! Please uptate Kux-Runiung and/or Nauvis Melange.")
			end
		)
		return result
	end
}

this = modules.nauvisMelange -- init local this

if script.active_mods[this.modName] then
	log.trace(this.modName.." active. add_interface: "..this.interfaceName)
	remote.add_interface(this.interfaceName, this.functions)
	this.isAvailable = true
else
	log.trace(this.modName.." not active")
	this.isAvailable = false
end

return this