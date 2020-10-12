
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