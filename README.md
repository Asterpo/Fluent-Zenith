# Fluent Zenith

![Fluent Zenith Title](Assets/darkmode.png#gh-dark-mode-only)
![Fluent Zenith Title](Assets/darkmode.png#gh-light-mode-only)

## Features

- Modern, themeable Roblox UI components
- Lifecycle-safe windows, elements, signals, and connections
- Studio-first operation with defensive optional UNC compatibility
- Typed public API and reproducible release artifacts

## Installation

For Roblox Studio, follow the [Studio installation guide](docs/installation.md#roblox-studio). For compatible remote-loading runtimes, load the verified release asset:

```lua
local Library = loadstring(game:GetService("HttpService"):GetAsync(
	"https://github.com/Asterpo/Fluent-Zenith/releases/latest/download/Fluent.luau"
))()
```

For a production deployment, pin a versioned release and verify its `SHA256SUMS.txt` before executing it.

## Usage

- [Studio example](Example.client.luau)
- [Remote-runtime example](Example.luau)
- [Public API](docs/api.md)
- [Public Luau declarations](PublicTypes.luau)
- [Release runbook](docs/releasing.md)

## Credits

- [Fluent Zenith](https://github.com/Asterpo/Fluent-Zenith)
- [Adiont](https://github.com/Adi0nt/Fluent-Renewed-Plus), [Master Oogway](https://github.com/ActualMasterOogway/Fluent-Renewed), and [dawid](https://github.com/dawid-scripts/Fluent)
- [Lucide](https://github.com/lucide-icons), [Phosphor](https://github.com/phosphor-icons), and the upstream projects listed in the source headers
