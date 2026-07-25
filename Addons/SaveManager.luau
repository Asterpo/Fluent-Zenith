local httpService = game:GetService("HttpService")
local Runtime = require(script.Parent.Runtime)

local function CallFilesystem(Name: string, ...: any): (boolean, ...any)
	return Runtime.CallSafely(Name, Runtime.GetGlobal(Name), ...)
end

local function IsFile(Path: string): boolean
	local Success, Exists = CallFilesystem("isfile", Path)
	return Success and Exists == true
end

type Dropdown = { Value: any, Values: { i: any }, Multi: boolean, Displayer: (v) -> n?, SetValue: (any) -> () }

local DisplayerParser = {
	Encode = function(Value)
		local Encoded = {}

		for Val: any, Bool: boolean in Value do
			table.insert(Encoded, Val)
		end

		return Encoded
	end,
}

local function TableEqual(Table, Reflect)
	for Index, Value in Table do
		if Reflect[Index] ~= Value then
			return false
		end
	end

	return true
end

local function SetDisplayerDropdownValue(Dropdown: Dropdown, Value)
	if Dropdown.Multi then
		local Values = {}

		for _, DataValue in Value do
			for _, DropdownValue in Dropdown.Values do
				if typeof(DropdownValue) ~= "table" or not TableEqual(DataValue, DropdownValue) then
					continue
				end

				Values[DropdownValue] = true
				break
			end
		end

		Dropdown:SetValue(Values)
	else
		for _, DropdownValue in Dropdown.Values do
			if typeof(DropdownValue) ~= "table" or not TableEqual(Value, DropdownValue) then
				continue
			end

			Dropdown:SetValue(DropdownValue)
			break
		end
	end
end

local SaveManager = {}
do
	SaveManager.Folder = "FluentZenithSettings"
	SaveManager.Ignore = {}
	SaveManager.Options, SaveManager.Library =
		{} :: {
			[string]: {
				Type: string,
				Value: any,
				SetValues: (self: any, NewValue: { [any]: any }) -> nil,
				SetValue: (self: any, NewValue: any, ...any) -> nil,
				SetValueRGB: (self: any, NewValue: Color3, Transparency: number?) -> nil,
			},
		},
		{}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object)
				return { type = "Toggle", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				local HasDisplayer = object.CustomDisplayer

				return {
					type = "Dropdown",
					idx = idx,
					value = (HasDisplayer and object.Multi and DisplayerParser.Encode(object.Value) or object.Value),
					mutli = object.Multi,
					Timestamp = object.Instance.CreatedAt,
					displayer = HasDisplayer,
				}
			end,
			Load = function(idx, data)
				if data.value == nil then
					return
				end

				local DropdownElement = SaveManager.Options[idx]
				if not DropdownElement then
					return
				end

				local Value = data.value
				if typeof(Value) ~= "table" or not data.displayer then
					DropdownElement:SetValue(Value)
					return
				end

				SetDisplayerDropdownValue(DropdownElement, Value)
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return {
					type = "Colorpicker",
					idx = idx,
					value = object.Value:ToHex(),
					transparency = object.Transparency,
					Timestamp = object.Instance.CreatedAt,
				}
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return {
					type = "Keybind",
					idx = idx,
					mode = object.Mode,
					key = object.Value,
					Timestamp = object.Instance.CreatedAt,
				}
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:Save(name): (boolean, string?)
		if not name then
			return false, "No config file is selected"
		end

		local fullPath = `{self.Folder}/settings/{name}.json`

		local data = {
			objects = {},
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then
				continue
			end
			if self.Ignore[idx] then
				continue
			end

			data.objects[#data.objects + 1] = self.Parser[option.Type].Save(idx, option)
		end

		table.sort(data.objects, function(v1: { Timestamp: number }, v2: { Timestamp: number })
			return v1.Timestamp < v2.Timestamp
		end)

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "Failed to JSON-Encode data"
		end

		local Written = CallFilesystem("writefile", fullPath, encoded)
		if not Written then
			return false, "File persistence is unavailable"
		end
		return true
	end

	function SaveManager:Load(name): (boolean, string?)
		if not name then
			return false, "No config file is selected"
		end

		local file = `{self.Folder}/settings/{name}.json`
		if not IsFile(file) then
			return false, "invalid file"
		end

		local Read, Content = CallFilesystem("readfile", file)
		if not Read then
			return false, "File persistence is unavailable"
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, Content)
		if not success then
			return false, "decode error"
		end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(self.Library.SafeCallback, self.Library, self.Parser[option.type].Load, option.idx, option)
			end
		end

		self.Library:SetTheme(self.Library.Theme)

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({
			"InterfaceManager_InterfaceTheme",
			"InterfaceManager_AcrylicToggle",
			"InterfaceManager_TransparentToggle",
			"InterfaceManager_MenuKeybind",
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			`{self.Folder}/settings`,
		}

		for i = 1, #paths do
			local str = paths[i]
			local Checked, Exists = CallFilesystem("isfolder", str)
			if not Checked then
				return false
			end
			if not Exists then
				local Created = CallFilesystem("makefolder", str)
				if not Created then
					return false
				end
			end
		end

		return true
	end

	function SaveManager:RefreshConfigList()
		local Listed, list = CallFilesystem("listfiles", `{self.Folder}/settings`)
		if not Listed or typeof(list) ~= "table" then
			return {}
		end

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == ".json" then
				local pos = file:find(".json", 1, true)
				local start = pos

				if typeof(pos) == "number" and typeof(start) == "number" then
					local char = file:sub(pos, pos)
					while char ~= "/" and char ~= "\\" and char ~= "" do
						pos = pos - 1
						char = file:sub(pos, pos)
					end

					if char == "/" or char == "\\" then
						local name = file:sub(pos + 1, start - 1)
						if name ~= "options" then
							out[#out + 1] = name
						end
					end
				end
			end
		end

		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
		self.Options = library.Options
	end

	function SaveManager:LoadAutoloadConfig()
		if IsFile(`{self.Folder}/settings/autoload.txt`) then
			local Read, name = CallFilesystem("readfile", `{self.Folder}/settings/autoload.txt`)
			if not Read then
				return nil
			end

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = `Failed to load autoload config: {err}`,
					Duration = 7,
				})
			end

			return self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = string.format("Auto loaded config %q", name),
				Duration = 7,
			})
		end

		return nil
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("Configuration")

		section:AddInput("SaveManager_ConfigName", { Title = "Config name" })
		section:AddDropdown(
			"SaveManager_ConfigList",
			{ Title = "Config list", Values = self:RefreshConfigList(), AllowNull = true }
		)

		section:AddButton({
			Title = "Create config",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigName.Value

				if string.gsub(name, " ", "") == "" then
					return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = "Invalid config name (empty)",
						Duration = 7,
					})
				end

				local success, err = self:Save(name)
				if not success then
					return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = "Failed to save config: " .. err,
						Duration = 7,
					})
				end

				self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = string.format("Created config %q", name),
					Duration = 7,
				})

				SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
				SaveManager.Options.SaveManager_ConfigList:SetValue(nil)

				return nil
			end,
		})

		section:AddButton({
			Title = "Load config",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigList.Value

				local success, err = self:Load(name)
				if not success then
					return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = "Failed to load config: " .. err,
						Duration = 7,
					})
				end

				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = string.format("Loaded config %q", name),
					Duration = 7,
				})
			end,
		})

		section:AddButton({
			Title = "Overwrite config",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigList.Value

				local success, err = self:Save(name)
				if not success then
					return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = "Failed to overwrite config: " .. err,
						Duration = 7,
					})
				end

				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = string.format("Overwrote config %q", name),
					Duration = 7,
				})
			end,
		})

		section:AddButton({
			Title = "Refresh list",
			Callback = function()
				SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
				SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
			end,
		})

		local AutoloadButton
		AutoloadButton = section:AddButton({
			Title = "Set as autoload",
			Description = "Current autoload config: none",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigList.Value
				local Written = CallFilesystem("writefile", `{self.Folder}/settings/autoload.txt`, name)
				if not Written then
					return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = "File persistence is unavailable in this runtime.",
						Duration = 7,
					})
				end
				AutoloadButton:SetDesc("Current autoload config: " .. name)
				self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = string.format("Set %q to auto load", name),
					Duration = 7,
				})
			end,
		})

		if IsFile(`{self.Folder}/settings/autoload.txt`) then
			local Read, name = CallFilesystem("readfile", `{self.Folder}/settings/autoload.txt`)
			if Read then
				AutoloadButton:SetDesc("Current autoload config: " .. name)
			end
		end

		SaveManager:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
