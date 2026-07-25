local fs = require("@lune/fs")

local InputValue = require("./Src/Modules/InputValue")
local Runtime = require("./Addons/Runtime")

local function expect(Condition: boolean, Message: string)
	if not Condition then
		error(`Test failed: {Message}`, 0)
	end
end

local Value, Text = InputValue.Normalize("", true, 42)
expect(Value == nil and Text == "", "empty numeric input should remain empty")

Value, Text = InputValue.Normalize("not a number", true, 42)
expect(Value == 42 and Text == "42", "invalid numeric input should preserve the previous value")

Value, Text = InputValue.Normalize("12345", false, "", 3)
expect(Value == "123" and Text == "123", "input maximum length should be enforced")

local Success, Result = Runtime.CallSafely("test success", function(ValueToReturn)
	return ValueToReturn
end, "ok")
expect(Success and Result == "ok", "callSafely should return successful callback values")

Success = Runtime.CallSafely("test failure", function()
	error("expected failure")
end)
expect(not Success, "callSafely should contain callback failures")

local ElementSource = fs.readFile("Src/Components/Element.luau")
expect(
	ElementSource:find('Element.TitleLabel.Text = tostring(Set or "")', 1, true) ~= nil,
	"nil title fallback must remain"
)

local WindowSource = fs.readFile("Src/Components/Window.luau")
expect(WindowSource:find("ImageRectSize", 1, true) ~= nil, "mobile image rectangle size regression must remain fixed")

local ScopeSource = fs.readFile("Src/Modules/Scope.luau")
expect(ScopeSource:find("self.Destroyed", 1, true) ~= nil, "scope destruction must stay idempotent")

local AdapterSource = fs.readFile("Src/Modules/Adapters.luau")
expect(
	AdapterSource:find("UNCFilePersistenceAdapter", 1, true) ~= nil,
	"file persistence adapter must remain available"
)

local PackageVersion = fs.readFile("wally.toml"):match('version%s*=%s*"([^"]+)"')
local RuntimeVersion = fs.readFile("Src/init.luau"):match('Version%s*=%s*"([^"]+)"')
expect(PackageVersion ~= nil and PackageVersion == RuntimeVersion, "package and runtime versions must match")

local PlaceProject = fs.readFile("place.project.json")
expect(
	PlaceProject:find('"Fluent Zenith"', 1, true) ~= nil,
	"Studio project must mount Fluent Zenith at the documented path"
)

print("v1.2.3 regression tests passed")
