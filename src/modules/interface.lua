local log      = require("lib/log")

--- interface
-- /c remote.call( "Kux-Running", "on" )
-- /c remote.call( "Kux-Running", "off" )
local interface = {

	on = function()
		modules.control.enable()
	end,

	off = function()
		modules.control.disable()
	end,

	getIsEnabled = function()
		return modules.control.isEnabled
	end,
}

return interface