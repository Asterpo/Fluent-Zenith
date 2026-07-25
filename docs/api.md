# Public API

Public Luau declarations live in [`PublicTypes.luau`](../PublicTypes.luau). The runtime API is intentionally small:

| API | Purpose |
| --- | --- |
| `Fluent:Window(config)` | Creates Fluent Zenith's single application window. |
| `Fluent:CreateWindow(config)` / `AddWindow(config)` | Compatibility aliases for `Window`. |
| `Fluent.Flags` | Current values for flagged elements. |
| `Fluent:overrideSetting(flag, value)` | Updates a flagged element when available. |
| `Fluent:SetTheme(name)` | Applies a named bundled theme. |
| `Fluent:Notify(config)` | Shows a notification. |
| `Fluent:Destroy()` | Idempotently disposes UI, signals, connections, and scoped resources. |

`WindowConfig` supports `Title`, `SubTitle`, `Theme`, `Size`, `MinSize`, `Resize`, `MinimizeKey`, `Acrylic`, `TabWidth`, and mobile configuration. See `PublicTypes.luau` for precise definitions.

### Lifecycle

Create one window per library instance. Treat it as owned by the code that created it and call `Destroy()` exactly when that owner is done. Repeated calls are safe.
