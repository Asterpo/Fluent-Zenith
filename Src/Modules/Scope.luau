--!strict

-- Owns resources created by a window, tab, or element.  Disposal is deliberately
-- idempotent so callers can safely tear down partially-created interfaces.
local Scope = {}
Scope.__index = Scope

export type Scope = {
	Add: (self: Scope, resource: any) -> any,
	Connection: (self: Scope, connection: RBXScriptConnection) -> RBXScriptConnection,
	Instance: (self: Scope, instance: Instance) -> Instance,
	Motor: (self: Scope, motor: any) -> any,
	Child: (self: Scope) -> Scope,
	Destroy: (self: Scope) -> (),
	Destroyed: boolean,
	_resources: { any },
}

local function dispose(resource: any)
	if typeof(resource) == "RBXScriptConnection" then
		if resource.Connected then
			resource:Disconnect()
		end
	elseif typeof(resource) == "Instance" then
		resource:Destroy()
	elseif typeof(resource) == "function" then
		resource()
	elseif type(resource) == "table" then
		if typeof(resource.Destroy) == "function" then
			resource:Destroy()
		elseif typeof(resource.destroy) == "function" then
			resource:destroy()
		elseif typeof(resource.disconnect) == "function" then
			resource:disconnect()
		end
	end
end

function Scope.new(): Scope
	return setmetatable({ Destroyed = false, _resources = {} }, Scope) :: any
end

function Scope:Add(resource: any): any
	if self.Destroyed then
		dispose(resource)
		return resource
	end
	table.insert(self._resources, resource)
	return resource
end

function Scope:Connection(connection: RBXScriptConnection): RBXScriptConnection
	return self:Add(connection)
end
function Scope:Instance(instance: Instance): Instance
	return self:Add(instance)
end
function Scope:Motor(motor: any): any
	return self:Add(motor)
end
function Scope:Child(): Scope
	return self:Add(Scope.new())
end

function Scope:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	for index = #self._resources, 1, -1 do
		dispose(self._resources[index])
	end
	table.clear(self._resources)
end

return Scope
