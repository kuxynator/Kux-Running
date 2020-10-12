local debug    = require "lib/debug"
local settings    = require "module/settings"
local this = nil

--- nauvisMelange module
-- @module: nauvisMelange
modules.nauvisMelange = {
	interfaceName = "Kux-Running_nauvisMelange",
	remoteInterfaceName = "nauvis_melange_player",
	isAvailable = false,

	functions = {

	},

	--- 
	--@playerIndex		index of player
	--@factor:          factor
	--@consequence:     'bad_trip' if bad_trip should be applied
	--                  'no_consumption' all items should be returned if not enough (includes pre_consumed)
	--                  'no_further_consumption' the pre consumed items are not returned
	--@isPreConsumption: in case an initial amount or so was needed that should not be added to the calculation
	fillBuffer = function (playerIndex, factor, consequence, preConsumption)
		if consequence == nil then consequence = "no_consumption" end
		if preConsumption == nil then preConsumption = 0 end
		if not this.isAvailable then return false end
		debug.print("fillBuffer")
		local result = false
		try(
			function()
				result = remote.call(this.remoteInterfaceName, "consume_spice", playerIndex, factor, consequence, preConsumption)
			end,
			function (ex)
				print(ex)
				game.print("Remote interface conflict! Please uptate Kux-Runiung and Nauvis Melange.")
			end
		)
		return result
	end
}

this = modules.nauvisMelange -- init local this

if script.active_mods["nauvis-melange"] then
	debug.print("nauvis-melange detected")
	remote.add_interface(this.interfaceName, this.functions)
	this.isAvailable = true
else
	debug.print("nauvis-melange not detected")
	this.isAvailable = false
end

return this