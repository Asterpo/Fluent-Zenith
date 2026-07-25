--!strict

local InputValue = {}

function InputValue.Normalize(Value: any, Numeric: boolean, PreviousValue: any, MaxLength: number?): (any, string)
	local Text = if Value == nil then "" else tostring(Value)

	if MaxLength and #Text > MaxLength then
		Text = Text:sub(1, MaxLength)
	end

	if not Numeric then
		return Text, Text
	end

	if Text ~= "" and tonumber(Text) == nil then
		local PreviousText = if PreviousValue == nil then "" else tostring(PreviousValue)
		return PreviousValue, PreviousText
	end

	return tonumber(Text), Text
end

return InputValue
