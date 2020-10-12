local function isEnabled()
	return game.get_player(1).mod_settings["Kux-Running_debug"].value
end
local this = nil
--- Deug module
-- @module debug
modules.debug = {

	modName = "not specified",

	joinArgs = function (...)
		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
	end,

	print = function(...)
		--print(this.joinArgs(...)) does not work
		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		print(msg)
	end,

	onSettingsChanged = function()
		--
	end,

	trace = function(...)
		if not isEnabled() then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 0.7, g = 0.7, b = 0.7, a = 1})
	end,

	warning = function(...)
		if not isEnabled() then return end

		local msg = ""
		for i = 1, select("#",...) do
			local v = select(i,...)
			if v == nil then v = "{nil}"
			else v = tostring(v) end
			msg = msg .. v
		end
		game.get_player(1).print(msg, {r = 1, g = 1, b = 0, a = 1})
	end,

	error = function(...)
		if not isEnabled() then return end

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

this = modules.debug --init local this
return this