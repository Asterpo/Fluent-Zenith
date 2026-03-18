local Root = script.Parent.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)
local Signal = require(Root.Packages.Signal)

local Creator = {
	Registry = {},
	Signals = {},
	Threads = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 14,
			RichText = true,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			RichText = true,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			RichText = true,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
	Theme = {
		Updating = false,
		Updated = Signal.new(),
	},
}

local function ReusableThreadCall(Function, Thread: thread, ...)
	Function(...)
	table.insert(Creator.Threads, Thread)
end

local function ReusableThread()
	while true do
		ReusableThreadCall(coroutine.yield())
	end
end

local function ApplyCustomProps(Object, Props: { [string]: any }?)
	if typeof(Props) == "table" and Props.ThemeTag then
		Creator.Spawn(Creator.AddThemeObject, Object, Props.ThemeTag)
	end
end

function Creator.Spawn(Function, ...)
	local length = table.maxn(Creator.Threads)
	if length == 0 then
		local thread = coroutine.create(ReusableThread)
		coroutine.resume(thread)
		return task.spawn(thread, Function, thread, ...)
	else
		local thread = Creator.Threads[length]
		Creator.Threads[length] = nil -- Remove from free threads list.
		return task.spawn(thread, Function, thread, ...)
	end
end

function Creator.Defer(Function, ...)
	local length = table.maxn(Creator.Threads)
	if length == 0 then
		local thread = coroutine.create(ReusableThread)
		coroutine.resume(thread)
		return task.defer(thread, Function, thread, ...)
	else
		local thread = Creator.Threads[length]
		Creator.Threads[length] = nil -- Remove from free threads list.
		return task.defer(thread, Function, thread, ...)
	end
end

function Creator.Delay(Delay, Function, ...)
	local length = table.maxn(Creator.Threads)
	if length == 0 then
		local thread = coroutine.create(ReusableThread)
		coroutine.resume(thread)
		return task.delay(Delay, thread, Function, thread, ...)
	else
		local thread = Creator.Threads[length]
		Creator.Threads[length] = nil -- Remove from free threads list.
		return task.delay(Delay, thread, Function, thread, ...)
	end
end

function Creator.AddSignal(Signal: RBXScriptSignal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)

		if Connection then
			Connection:Disconnect()
		end
	end
end

function Creator.GetThemeProperty(Property)
	local Theme = require(Root).Theme

	if Themes[Theme][Property] then
		return Themes[Theme][Property]
	end

	return Themes["Dark"][Property]
end

function Creator.UpdateTheme(RegistryIndex: Instance?)
	if Creator.Theme.Updating then
		Creator.Theme.Updated:Wait()
	end

	Creator.Theme.Updating = true

	if typeof(RegistryIndex) == "Instance" and Creator.Registry[RegistryIndex] then
		for Property, ColorIdx in next, Creator.Registry[RegistryIndex].Properties do
			Creator.Spawn(function()
				RegistryIndex[Property] = Creator.GetThemeProperty(ColorIdx)
			end)
		end
	else
		for _, Object in next, Creator.Registry do
			for Property, ColorIdx in next, Object.Properties do
				Creator.Spawn(function()
					Object.Object[Property] = Creator.GetThemeProperty(ColorIdx)
				end)
			end
		end
	end

	for Idx: number, Motor in next, Creator.TransparencyMotors do
		Creator.Spawn(function()
			Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
		end)
	end

	Creator.Theme.Updating = false
	Creator.Theme.Updated:Fire()
end

function Creator.AddThemeObject(Object: Instance, Properties: { [string]: any })
	local Idx = #Creator.Registry + 1
	local Data = {
		Object = Object,
		Properties = Properties,
		Idx = Idx,
	}

	Creator.Registry[Object] = Data
	Creator.UpdateTheme(Object)

	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object].Properties = Properties
	Creator.UpdateTheme(Object)
end

function Creator.New(Name, Properties: { [string]: any }?, Children: { [number]: Instance }?): Instance
	local Object = Instance.new(Name)

	-- Default properties
	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	-- Properties
	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)

	return Object
end

function Creator.SpringMotor(
	Initial: any,
	Instance: Object,
	Prop: string,
	IgnoreDialogCheck: boolean?,
	ResetOnThemeChange: boolean?
)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)

	if ResetOnThemeChange then
		Creator.TransparencyMotors[#Creator.TransparencyMotors + 1] = Motor
	end

	local function SetValue(Value, Ignore: boolean?)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end
		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator
