--!strict

local Runtime = {}

local warned = {}

function Runtime.GetGlobal(Name: string): any
	local Environment = if typeof(getfenv) == "function" then getfenv(0) else _G
	return rawget(Environment, Name)
end

function Runtime.CallSafely(Name: string, Callback: any, ...: any): (boolean, ...any)
	if typeof(Callback) ~= "function" then
		if not warned[Name] then
			warned[Name] = true
			warn(`Fluent Zenith: optional runtime API "{Name}" is unavailable; using the safe fallback.`)
		end
		return false, `Optional runtime API "{Name}" is unavailable`
	end

	local Result = table.pack(pcall(Callback, ...))
	if not Result[1] then
		if not warned[Name] then
			warned[Name] = true
			warn(`Fluent Zenith: optional runtime API "{Name}" failed: {tostring(Result[2])}`)
		end
		return false, Result[2]
	end

	return true, table.unpack(Result, 2, Result.n)
end

return Runtime
