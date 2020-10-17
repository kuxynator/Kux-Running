
function iif(condition, p0, p1)
	if condition then
		return p0
	else
		return p1
	end
end

function try(f, catch_f)
	local status, exception = pcall(f)
	if not status then
		catch_f(exception)
	end
end

function switch(key, dictionary, default)
	local v = dictionary[key]
	if v == nil then return default end
	return v
end

function switchp(key, ...)
	local dic = {}
	local count = select("#",...)
	local default = nil
	for i = 1, count, 2 do
		local k = select(i,...)
		if type(k) == "function" then k = k() end
		if(i+1>count) then default = k; break end
		local v = select(i+1,...)
		if type(v) == "function" then v = v() end
		dic[k]=v
		if(i+1==count) then default = v end
	end
	return switch(key,dic,default)
end