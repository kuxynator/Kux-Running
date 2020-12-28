local this = nil

local getIsEnabled = function ()
	local entry = settings.global[script.mod_name.."_EnableLog"]
	if entry == nil then return false end
	return entry.value
end

--- deterministic data of log module
local data = {
	isEnabled = false
}

--- Log module
-- @module log
Log = {

	onLoaded = function ()
		data = global.moduleData.log or data
		this.data = data
		this.onSettingsChanged() -- force update
	end,
	--- to debug bootstraap set isEnabled to true

	onSettingsChanged = function()
		data.isEnabled = getIsEnabled()
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
		--if not data.isEnabled then return end
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
		if not data.isEnabled then return end

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
		if not data.isEnabled then return end

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
		if not data.isEnabled then return end

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
		if not data.isEnabled then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 0, b = 0, a = 1})
	end,
}

this = Log --init local this
Modules.log = Log -- add to modules
return Log