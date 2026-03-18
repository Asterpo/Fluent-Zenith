local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Max, "Slider - Missing maximum value.")

	local Slider = {
		Value = nil,
		Min = typeof(Config.Min) == "number" and Config.Min or 0,
		Max = Config.Max,
		Rounding = typeof(Config.Rounding) == "number" and Config.Rounding or 0,
		Ranged = typeof(Config.Ranged) == "boolean" and Config.Ranged or false,
		Callback = typeof(Config.Callback) == "function" and Config.Callback or function(Value, OldValue) end,
		Changed = Config.Changed or function() end,
		Type = "Slider"
	}

	

	local SliderFrame = require(Components.Element)(Config.Title or "Slider", Config.Description, self.Container, false)
	SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc
	
	local Null = table.freeze({})
	
	local DotCount = Slider.Ranged and 2 or 1
	
	local SliderDots = table.create(DotCount, Null)
	local Dragging = table.create(DotCount, Null)
	
	for i = 1, DotCount do
		
		Dragging[i] = false
		
		local SliderDot = New("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, -7, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			Image = "http://www.roblox.com/asset/?id=12266946128",
			ThemeTag = {
				ImageColor3 = "Accent",
			}
		})
		
		Creator.AddSignal(SliderDot.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				Dragging[i] = true
			end
		end)

		Creator.AddSignal(SliderDot.InputEnded, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				Dragging[i] = false
			end
		end)
		
		SliderDots[i] = SliderDot
	end

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(1, -14, 1, 0)
	}, SliderDots)

	local SliderFill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		ThemeTag = {
			BackgroundColor3 = "Accent",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		})
	})

	local SliderDisplay = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = "Value",
		ClearTextOnFocus = true,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 14),
		Position = UDim2.new(0, -4, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = {
			TextColor3 = "SubText",
		}
	})

	New("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 0.4,
		Parent = SliderFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "SliderRail",
		}
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		New("UISizeConstraint", {
			MaxSize = Vector2.new(150, math.huge),
		}),
		SliderDisplay,
		SliderFill,
		SliderRail
	})

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Library:SafeCallback(Func, Slider.Value, Slider.Value)
	end

	function Slider:SetVisibility(Bool)
		SliderFrame.Frame.Visible = Bool
	end

	function Slider:SetValue(Value: number | NumberRange)
		local OldValue = self.Value or Value
		
		if Slider.Ranged then
			rawset(self, "Value", NumberRange.new(Library.Utilities:Round(math.clamp(Value.Min, Slider.Min, Slider.Max), Slider.Rounding), Library.Utilities:Round(math.clamp(Value.Max, Slider.Min, Slider.Max), Slider.Rounding)))
			local min = math.map(self.Value.Min, Slider.Min, Slider.Max, 0, 1)
			local max = math.map(self.Value.Max, Slider.Min, Slider.Max, 0, 1)
			SliderDots[1].Position = UDim2.new(min, -7, 0.5, 0)
			SliderDots[2].Position = UDim2.new(max, -7, 0.5, 0)
			SliderFill.Position = UDim2.new((min * SliderRail.AbsoluteSize.X) / (SliderRail.AbsoluteSize.X + 14), 7, SliderFill.Position.Y.Scale, SliderFill.Position.Y.Offset)
			SliderFill.Size = UDim2.new(0, SliderDots[2].AbsolutePosition.X - SliderDots[1].AbsolutePosition.X, 1, 0)
			SliderDisplay.Text = tostring(self.Value)
		else
			rawset(self, "Value", Library.Utilities:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding))
			SliderDots[1].Position = UDim2.new(math.map(self.Value, Slider.Min, Slider.Max, 0, 1), -7, 0.5, 0)
			SliderFill.Size = UDim2.fromScale(math.map(self.Value, Slider.Min, Slider.Max, 0, 1), 1)
			SliderDisplay.Text = tostring(self.Value)
		end

		if typeof(Slider.Callback) == "function" then
			Library:SafeCallback(Slider.Callback, self.Value, OldValue)
		end
		
		if typeof(Slider.Changed) == "function" then
			Library:SafeCallback(Slider.Changed, self.Value, OldValue)
		end
	end
	
	local onInputChanged
	
	if Slider.Ranged then
		function onInputChanged(Input: InputObject)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
				local SizeScale = math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
				local Value = NumberRange.new(0)
				if Dragging[1] then
					local Min = Slider.Min + ((Slider.Max - Slider.Min) * SizeScale)
					local Max = math.max(Min, Slider.Value.Max)
					Value = NumberRange.new(Min, Max)
					Slider:SetValue(Value)
				elseif Dragging[2] then
					local Max = Slider.Min + ((Slider.Max - Slider.Min) * SizeScale)
					local Min = math.min(Max, Slider.Value.Min)
					Value = NumberRange.new(Min, Max)
					Slider:SetValue(Value)
				end
			end
		end
	else
		function onInputChanged(Input: InputObject)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
				if Dragging[1] then
					local SizeScale =
						math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
					Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
				end
			end
		end
	end
	
	Creator.AddSignal(UserInputService.InputChanged, onInputChanged)

	Creator.AddSignal(SliderDisplay.FocusLost, function()
		if Slider.Ranged then
			local Split = string.split(SliderDisplay.Text, " ")
			local Min = tonumber(Split[1])
			local Max = tonumber(Split[2])
			local Value = NumberRange.new(Min, Max)
			Slider:SetValue(Value or Slider.Value)
		else
			Slider:SetValue(tonumber(SliderDisplay.Text) or Slider.Value)
		end
	end)

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end
	
	if Slider.Ranged then
		Slider:SetValue(typeof(Config.Default) == "NumberRange" and Config.Default or NumberRange.new(Slider.Min))
	else
		Slider:SetValue(typeof(Config.Default) == "number" and Config.Default or Slider.Min)
	end

	Library.Options[Idx] = Slider

	Slider.Instance = SliderFrame

	return setmetatable(Slider, {
		__newindex =  function(self, index, newvalue)
			if index == "Value" then
				Creator.Spawn(Slider.SetValue, Slider, newvalue)
			end
			rawset(self, index, newvalue)
		end
	})
end

return Element
