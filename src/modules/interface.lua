--- interface
-- /c remote.call( "Kux-Running", "on" )
-- /c remote.call( "Kux-Running", "off" )
local interface = {

	on = function()
		Modules.control.enable()
	end,

	off = function()
		Modules.control.disable()
	end,

	getIsEnabled = function()
		return global.isEnabled
	end,
}

return interface