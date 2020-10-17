local this = nil
--- Log module
-- @module log
modules.log = {

	getIsEnabled = function ()
		local entry = settings.global[script.mod_name.."_EnableLog"]
		if entry == nil then return false end
		return entry.value
	end,

	--- to debug bootstraap set isEnabled to true
	isEnabled = false,

	onSettingsChanged = function()
		this.isEnabled = this.getIsEnabled()
	end,

	onLoaded = function(e)
		this.onSettingsChanged()
	end,

	joinArgs = function (...)
		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
	end,

	trace = function(...)
		if not this.isEnabled then return end

		local msg = script.mod_name..": "
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		print(msg)
	end,

	print = function(...)
		if not this.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		print(msg)
	end,

	userTrace = function(...)
		if not this.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 0.7, g = 0.7, b = 0.7, a = 1})
	end,

	userWarning = function(...)
		if not this.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 1, b = 0, a = 1})
	end,

	userError = function(...)
		if not this.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 0, b = 0, a = 1})
	end
}

this = modules.log --init local this
return this