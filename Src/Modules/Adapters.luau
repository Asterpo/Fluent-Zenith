--!strict

local Runtime = require(script.Parent.Runtime)

local Adapters = {}

function Adapters.RobloxHostAdapter(parent: Instance?)
	return {
		GetGuiParent = function()
			if parent then
				return parent
			end
			local players = game:GetService("Players")
			local player = players.LocalPlayer
			return player and player:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
		end,
	}
end

function Adapters.DeltaHostAdapter()
	return {
		GetGuiParent = function()
			local ok, host =
				Runtime.CallSafely("gethui", Runtime.GetGlobal("gethui") or Runtime.GetGlobal("get_hidden_ui"))
			return if ok then host else nil
		end,
	}
end

function Adapters.UNCFilePersistenceAdapter()
	local readfile, writefile, isfile =
		Runtime.GetGlobal("readfile"), Runtime.GetGlobal("writefile"), Runtime.GetGlobal("isfile")
	local memory: { [string]: string } = {}
	return {
		Read = function(path: string): string?
			local exists = Runtime.CallSafely("isfile", isfile, path)
			if exists then
				local ok, value = Runtime.CallSafely("readfile", readfile, path)
				if ok then
					return value
				end
			end
			return memory[path]
		end,
		Write = function(path: string, value: string): boolean
			local ok = Runtime.CallSafely("writefile", writefile, path, value)
			if not ok then
				memory[path] = value
			end
			return ok
		end,
	}
end

function Adapters.ClonerefResolver()
	local clone = Runtime.GetGlobal("cloneref") or Runtime.GetGlobal("clonereference")
	return function<T>(value: T): T
		local ok, result = Runtime.CallSafely("cloneref", clone, value)
		return if ok then result else value
	end
end

return Adapters
