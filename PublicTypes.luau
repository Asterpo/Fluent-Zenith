--!strict
-- Public type declarations for Fluent Zenith 1.2.0.

export type MobileConfig = {
	GetIcon: (isMinimized: boolean) -> { Image: string, ImageRectOffset: Vector2, ImageRectSize: Vector2 },
	Size: UDim2,
}

export type WindowConfig = {
	Title: string?,
	SubTitle: string?,
	TabWidth: number?,
	MinSize: Vector2?,
	Size: UDim2?,
	Resize: boolean?,
	MinimizeKey: Enum.KeyCode?,
	Acrylic: boolean?,
	Theme: string?,
	Mobile: MobileConfig?,
}

export type Element = {
	Value: any,
	SetValue: ((self: Element, value: any) -> ())?,
}

export type Window = {
	Scope: any,
	Destroy: (self: Window) -> (),
}

export type Library = {
	Version: string,
	Flags: { [string]: any },
	Themes: { string },
	Window: (self: Library, config: WindowConfig) -> Window,
	CreateWindow: (self: Library, config: WindowConfig) -> Window,
	AddWindow: (self: Library, config: WindowConfig) -> Window,
	overrideSetting: (self: Library, flag: string, value: any) -> boolean,
	SetTheme: (self: Library, name: string) -> (),
	Destroy: (self: Library) -> (),
	Notify: (self: Library, config: { [string]: any }) -> any,
}

return nil
