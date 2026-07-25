# Installation

## Roblox Studio

1. Build `Src` with Rojo or insert the released `Fluent.rbxm` into `ReplicatedStorage`.
2. Require the module from a `LocalScript` after `PlayerGui` is available.
3. Create one window and call `Library:Destroy()` when the owning UI is no longer needed.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fluent = require(ReplicatedStorage:WaitForChild("Fluent Zenith").MainModule)

local window = Fluent:Window({
	Title = "My Studio tool",
	SubTitle = "Powered by Fluent Zenith",
	Theme = "Dark",
})
```

Studio and PlayerGui do not need UNC globals. Fluent Zenith detects optional runtime APIs and uses safe in-memory fallbacks when they are unavailable.

## Release loader

Only use this in environments where remote loading is permitted and you trust the published release:

```lua
local source = game:GetService("HttpService"):GetAsync(
	"https://github.com/Asterpo/Fluent-Zenith/releases/latest/download/Fluent.luau"
)
local Fluent = loadstring(source)()
```

For pinned production deployments, replace `latest` with a verified tag and check `SHA256SUMS.txt` before execution.
