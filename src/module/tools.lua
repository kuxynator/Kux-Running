local debug    = require("lib/debug")
local colors   = require("lib/colors")
local settings = require("module/settings")
local this = nil

--- Tools module
-- @module tools
modules.tools = modules.tools or {

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

	tryRestoreCharacterRunningSpeedModifier = function(player)
		if player.character == nil then
			player.print("Can not restore character speed modifier. No character.", colors.red)
			return false
		else
			player.character_running_speed_modifier = settings.getDefaultCharacterRunningSpeedModifier(player)
			return true
		end
	end,

	round = function (number, decimalDigits)
		local f = 10^decimalDigits
		return math.ceil(number*f) / f
	end
}
this = modules.tools -- init local this
return this