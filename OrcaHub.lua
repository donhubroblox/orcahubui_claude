--[[
	OrcaHub UI Library
	https://github.com/donhubroblox/orcahubui_claude

	local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/main/OrcaHub.lua"))()
	local Window = OrcaHub:CreateWindow({ Title = "OrcaHub" })
]]

local cloneref = cloneref or function(o) return o end
local function Service(name) return cloneref(game:GetService(name)) end

local Players = Service("Players")
local TweenService = Service("TweenService")
local UserInputService = Service("UserInputService")
local RunService = Service("RunService")
local HttpService = Service("HttpService")
local GuiService = Service("GuiService")

local LocalPlayer = Players.LocalPlayer

local OrcaHub = {
	Version = "2.0.0",
	Flags = {},
	Options = {},
	Icons = {},
	Folder = "OrcaHub",
	FontFamily = "rbxasset://fonts/families/GothamSSm.json",
	IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	ThemeName = "Orca",
}

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

OrcaHub.Themes = {
	Orca = {
		Background = rgb(9, 11, 15), Sidebar = rgb(12, 15, 20), Section = rgb(15, 18, 24),
		Element = rgb(22, 26, 33), ElementHover = rgb(30, 35, 44),
		Stroke = rgb(31, 36, 46), StrokeLight = rgb(44, 51, 64),
		Text = rgb(236, 240, 247), SubText = rgb(146, 156, 172), DimText = rgb(88, 97, 113),
		Accent = rgb(56, 160, 255), Accent2 = rgb(64, 224, 208),
		ToggleOff = rgb(36, 41, 52), Knob = rgb(245, 248, 252),
	},
	Abyss = {
		Background = rgb(11, 10, 15), Sidebar = rgb(15, 13, 20), Section = rgb(18, 16, 24),
		Element = rgb(26, 23, 34), ElementHover = rgb(34, 30, 45),
		Stroke = rgb(36, 32, 47), StrokeLight = rgb(52, 46, 66),
		Text = rgb(240, 237, 247), SubText = rgb(160, 152, 176), DimText = rgb(99, 92, 116),
		Accent = rgb(139, 92, 246), Accent2 = rgb(217, 70, 239),
		ToggleOff = rgb(41, 37, 54), Knob = rgb(248, 246, 252),
	},
	Reef = {
		Background = rgb(8, 12, 12), Sidebar = rgb(11, 16, 16), Section = rgb(14, 20, 20),
		Element = rgb(20, 28, 28), ElementHover = rgb(27, 37, 37),
		Stroke = rgb(29, 40, 40), StrokeLight = rgb(41, 56, 56),
		Text = rgb(236, 246, 244), SubText = rgb(142, 166, 162), DimText = rgb(84, 106, 102),
		Accent = rgb(34, 197, 94), Accent2 = rgb(45, 212, 191),
		ToggleOff = rgb(33, 45, 45), Knob = rgb(246, 252, 250),
	},
	Coral = {
		Background = rgb(14, 10, 11), Sidebar = rgb(19, 13, 15), Section = rgb(23, 16, 18),
		Element = rgb(32, 23, 26), ElementHover = rgb(42, 30, 34),
		Stroke = rgb(45, 33, 37), StrokeLight = rgb(64, 47, 52),
		Text = rgb(248, 238, 240), SubText = rgb(178, 152, 158), DimText = rgb(115, 92, 98),
		Accent = rgb(244, 63, 94), Accent2 = rgb(251, 146, 60),
		ToggleOff = rgb(51, 38, 42), Knob = rgb(252, 247, 248),
	},
}

OrcaHub.Theme = {}
for k, v in pairs(OrcaHub.Themes.Orca) do OrcaHub.Theme[k] = v end
local function T() return OrcaHub.Theme end

local MOBILE = OrcaHub.IsMobile
local ROW_H = MOBILE and 36 or 32
local BOX_H = MOBILE and 34 or 30
local TAB_H = MOBILE and 42 or 38
local ITEM_H = MOBILE and 32 or 28
local SIDEBAR_W, SIDEBAR_COMPACT = 200, 60
local TOPBAR_H, FOOTER_H = 58, 28
local SECTION_HEADER = 42
local PAD, GAP = 12, 12

local STATUS = {
	Info = { Icon = "info" },
	Success = { Icon = "check-circle", Color = rgb(74, 222, 128) },
	Warning = { Icon = "alert-triangle", Color = rgb(250, 204, 21) },
	Error = { Icon = "x-circle", Color = rgb(248, 113, 113) },
}

---------------------------------------------------------------- theming

local Themed = setmetatable({}, { __mode = "k" })
local Refreshers = {}

local function resolveTheme(key)
	if type(key) == "function" then return key(OrcaHub.Theme) end
	return OrcaHub.Theme[key]
end

local function applyTheme(inst, map)
	local entry = Themed[inst]
	if not entry then
		entry = {}
		Themed[inst] = entry
	end
	for prop, key in pairs(map) do
		entry[prop] = key
		inst[prop] = resolveTheme(key)
	end
end

local function tween(inst, props, time, style, direction)
	local tw = TweenService:Create(inst, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function set(inst, props, animate, time, style)
	if animate then return tween(inst, props, time, style) end
	for k, v in pairs(props) do inst[k] = v end
end

function OrcaHub:SetTheme(theme)
	local source = type(theme) == "table" and theme or self.Themes[theme]
	if not source then return end
	for k, v in pairs(source) do self.Theme[k] = v end
	self.ThemeName = type(theme) == "string" and theme or "Custom"
	for inst, map in pairs(Themed) do
		if inst.Parent then
			for prop, key in pairs(map) do
				local value = resolveTheme(key)
				if typeof(value) == "Color3" then
					tween(inst, { [prop] = value }, 0.3)
				else
					inst[prop] = value
				end
			end
		end
	end
	for _, fn in ipairs(Refreshers) do pcall(fn) end
end

---------------------------------------------------------------- helpers

local function create(class, props, children)
	local inst = Instance.new(class)
	local parent, theme
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				parent = v
			elseif k == "Theme" then
				theme = v
			else
				inst[k] = v
			end
		end
	end
	if theme then applyTheme(inst, theme) end
	if children then
		for _, child in ipairs(children) do child.Parent = inst end
	end
	if parent then inst.Parent = parent end
	return inst
end

local function corner(r)
	return create("UICorner", { CornerRadius = UDim.new(0, r or 8) })
end

local function stroke(key, thickness)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = thickness or 1,
		Theme = { Color = key or "Stroke" },
	})
end

local function padding(top, right, bottom, left)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		PaddingLeft = UDim.new(0, left or right or top or 0),
	})
end

local function accentGradient(rotation)
	return create("UIGradient", {
		Rotation = rotation or 0,
		Theme = { Color = function(t) return ColorSequence.new(t.Accent, t.Accent2) end },
	})
end

local function font(weight)
	local ok, f = pcall(function() return Font.new(OrcaHub.FontFamily, weight) end)
	if ok then return f end
	return nil
end

local function text(props)
	local class = props.Class or "TextLabel"
	local weight = Enum.FontWeight[props.Weight or "Regular"]
	props.Class, props.Weight = nil, nil
	local base = {
		BackgroundTransparency = 1,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Theme = { TextColor3 = "Text" },
	}
	local f = font(weight)
	if f then base.FontFace = f else base.Font = Enum.Font.Gotham end
	for k, v in pairs(props) do base[k] = v end
	return create(class, base)
end

local function iconImage(name)
	if name == nil or name == "" then return nil end
	if type(name) == "number" then return "rbxassetid://" .. name end
	if string.find(name, "rbxasset", 1, true) or string.find(name, "http", 1, true) then return name end
	local id = OrcaHub.Icons[(string.gsub(name, "^lucide%-", ""))]
	return id and ("rbxassetid://" .. id) or nil
end

local function Icon(name, size, themeKey, props)
	local img = create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Image = iconImage(name) or "",
		ScaleType = Enum.ScaleType.Fit,
		Theme = themeKey and { ImageColor3 = themeKey } or nil,
	})
	if props then
		for k, v in pairs(props) do img[k] = v end
	end
	return img
end

local function safeCall(fn, ...)
	if type(fn) ~= "function" then return end
	task.spawn(function(...)
		local ok, err = pcall(fn, ...)
		if not ok then warn("[OrcaHub] callback error: " .. tostring(err)) end
	end, ...)
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input, pressInput)
	if input.UserInputType == Enum.UserInputType.MouseMovement then return true end
	return input.UserInputType == Enum.UserInputType.Touch and (pressInput == nil or input == pressInput)
end

local function vec2(v3) return Vector2.new(v3.X, v3.Y) end

local function guiParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	local core = Service("CoreGui")
	local canUse = pcall(function()
		local f = Instance.new("Folder")
		f.Parent = core
		f:Destroy()
	end)
	if canUse then return core end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function viewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

---------------------------------------------------------------- files

local function hasFS()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function ensureFolder(path)
	if type(makefolder) ~= "function" or type(isfolder) ~= "function" then return end
	local current = ""
	for part in string.gmatch(path, "[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		if not isfolder(current) then makefolder(current) end
	end
end

local function readJSON(path)
	if not hasFS() or not isfile(path) then return nil end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	return ok and data or nil
end

local function writeJSON(path, data)
	if not hasFS() then return false end
	local folder = string.match(path, "^(.*)/[^/]+$")
	if folder then ensureFolder(folder) end
	return pcall(function() writefile(path, HttpService:JSONEncode(data)) end)
end

local function serialize(v)
	if typeof(v) == "Color3" then return { __t = "Color3", v = v:ToHex() } end
	if typeof(v) == "EnumItem" then return { __t = "KeyCode", v = v.Name } end
	return v
end

local function deserialize(v)
	if type(v) == "table" and v.__t == "Color3" then return Color3.fromHex(v.v) end
	if type(v) == "table" and v.__t == "KeyCode" then return Enum.KeyCode[v.v] end
	return v
end

function OrcaHub:_configFolder()
	return self.Folder .. "/configs/" .. tostring(self.ConfigKey or game.PlaceId)
end

function OrcaHub:SaveConfig(name)
	if not hasFS() or not name or name == "" then return false end
	local data = {}
	for flag, option in pairs(self.Options) do
		if option.Get and not option.NoSave then data[flag] = serialize(option:Get()) end
	end
	return writeJSON(self:_configFolder() .. "/" .. name .. ".json", data)
end

function OrcaHub:LoadConfig(name)
	local data = readJSON(self:_configFolder() .. "/" .. tostring(name) .. ".json")
	if not data then return false end
	for flag, value in pairs(data) do
		local option = self.Options[flag]
		if option and option.Set then pcall(function() option:Set(deserialize(value)) end) end
	end
	return true
end

function OrcaHub:DeleteConfig(name)
	local path = self:_configFolder() .. "/" .. tostring(name) .. ".json"
	if type(delfile) == "function" and isfile(path) then delfile(path) return true end
	return false
end

function OrcaHub:ListConfigs()
	local out = {}
	if type(listfiles) ~= "function" or not hasFS() then return out end
	local folder = self:_configFolder()
	ensureFolder(folder)
	local ok, files = pcall(listfiles, folder)
	if not ok then return out end
	for _, file in ipairs(files) do
		local name = string.match(file, "([^/\\]+)%.json$")
		if name then table.insert(out, name) end
	end
	table.sort(out)
	return out
end

function OrcaHub:SetAutoload(name)
	if not hasFS() then return end
	ensureFolder(self:_configFolder())
	writefile(self:_configFolder() .. "/autoload.txt", name or "")
end

function OrcaHub:GetAutoload()
	local path = self:_configFolder() .. "/autoload.txt"
	if hasFS() and isfile(path) then
		local name = readfile(path)
		if name ~= "" then return name end
	end
	return nil
end

function OrcaHub:LoadAutoloadConfig()
	local name = self:GetAutoload()
	if name then return self:LoadConfig(name) end
	return false
end

---------------------------------------------------------------- notifications

local notifyCounter = 0
local function nextNotifyOrder()
	notifyCounter = notifyCounter + 1
	return notifyCounter
end

function OrcaHub:Notify(o)
	o = o or {}
	local window = self.Window
	if not window or not window.NotifyHolder then
		warn("[OrcaHub] Notify called before CreateWindow")
		return
	end
	local status = STATUS[o.Type or "Info"] or STATUS.Info
	local duration = o.Duration or 4

	local wrapper = create("Frame", {
		Parent = window.NotifyHolder, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = nextNotifyOrder(),
	})
	local card = create("TextButton", {
		Parent = wrapper, Text = "", AutoButtonColor = false,
		Position = UDim2.new(1, 24, 0, 0), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Theme = { BackgroundColor3 = "Section" },
	}, { corner(10), stroke("StrokeLight") })
	local inner = create("Frame", {
		Parent = card, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
	}, { padding(12, 14, 14, 46) })
	local icon = Icon(o.Icon or status.Icon, 20, (not status.Color) and "Accent" or nil, {
		Parent = card, Position = UDim2.fromOffset(14, 13),
	})
	if status.Color then icon.ImageColor3 = status.Color end
	create("UIListLayout", { Parent = inner, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })
	text({
		Parent = inner, Text = o.Title or "OrcaHub", Weight = "SemiBold", TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1,
	})
	if o.Content and o.Content ~= "" then
		text({
			Parent = inner, Text = o.Content, TextSize = 12, TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2,
			Theme = { TextColor3 = "SubText" },
		})
	end
	local progress = create("Frame", {
		Parent = card, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2),
	}, { accentGradient(0) })
	if status.Color then
		progress:FindFirstChildOfClass("UIGradient"):Destroy()
		progress.BackgroundColor3 = status.Color
	end

	tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.45, Enum.EasingStyle.Back)
	tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		tween(card, { Position = UDim2.new(1, 24, 0, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.wait(0.3)
		wrapper.AutomaticSize = Enum.AutomaticSize.None
		wrapper.Size = UDim2.new(1, 0, 0, wrapper.AbsoluteSize.Y)
		tween(wrapper, { Size = UDim2.new(1, 0, 0, 0) }, 0.25)
		task.wait(0.26)
		wrapper:Destroy()
	end
	card.MouseButton1Click:Connect(function() task.spawn(close) end)
	task.delay(duration, close)
end

---------------------------------------------------------------- window

function OrcaHub:CreateWindow(opts)
	opts = opts or {}
	local env = (type(getgenv) == "function" and getgenv()) or _G
	if env.__OrcaHubWindow then pcall(function() env.__OrcaHubWindow:Destroy() end) end

	if opts.Theme then self:SetTheme(opts.Theme) end
	if opts.Folder then self.Folder = opts.Folder end
	if opts.ConfigKey then self.ConfigKey = opts.ConfigKey end

	local Window = {
		Tabs = {},
		Conns = {},
		Visible = true,
		UserScale = 1,
		Scale = 1,
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
		Compact = opts.Compact,
		LayoutPath = self.Folder .. "/layouts/" .. tostring(opts.ConfigKey or game.PlaceId) .. ".json",
	}
	if Window.Compact == nil then Window.Compact = MOBILE end
	Window.SavedLayout = readJSON(Window.LayoutPath) or {}
	self.Window = Window
	env.__OrcaHubWindow = Window

	local function track(conn)
		table.insert(Window.Conns, conn)
		return conn
	end
	Window._track = track

	local size = opts.Size or (MOBILE and Vector2.new(640, 380) or Vector2.new(780, 500))
	if typeof(size) == "UDim2" then size = Vector2.new(size.X.Offset, size.Y.Offset) end
	Window.Size = size

	local gui = create("ScreenGui", {
		Name = HttpService:GenerateGUID(false),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = 100,
	})
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	gui.Parent = guiParent()
	Window.Gui = gui

	-- notifications
	Window.NotifyHolder = create("Frame", {
		Parent = gui, BackgroundTransparency = 1, ZIndex = 20,
		AnchorPoint = MOBILE and Vector2.new(1, 0) or Vector2.new(1, 1),
		Position = MOBILE and UDim2.new(1, -12, 0, 12) or UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, MOBILE and 260 or 300, 1, -32),
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = MOBILE and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom,
		}),
	})

	-- window shell
	local holder = create("Frame", {
		Parent = gui, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
	})
	local uiScale = create("UIScale", { Parent = holder })
	for i, spread in ipairs({ 4, 10, 18 }) do
		create("Frame", {
			Parent = holder, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.78 + i * 0.06,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 4),
			Size = UDim2.new(1, spread * 2, 1, spread * 2), ZIndex = 0,
		}, { corner(12 + spread) })
	end

	local main = create("Frame", {
		Parent = holder, Size = UDim2.fromScale(1, 1), ClipsDescendants = true,
		Theme = { BackgroundColor3 = "Background" },
	}, { corner(12) })
	local mainStroke = create("UIStroke", {
		Parent = main, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1, 1, 1),
	})
	create("UIGradient", {
		Parent = mainStroke, Rotation = 35,
		Theme = {
			Color = function(t)
				return ColorSequence.new({
					ColorSequenceKeypoint.new(0, t.Accent),
					ColorSequenceKeypoint.new(0.3, t.StrokeLight),
					ColorSequenceKeypoint.new(1, t.Stroke),
				})
			end,
		},
	})
	Window.Main = main

	local cover = create("Frame", {
		Parent = holder, Size = UDim2.fromScale(1, 1), ZIndex = 30, BackgroundTransparency = 1,
		Theme = { BackgroundColor3 = "Background" },
	}, { corner(12) })

	-- popup overlay (dropdowns, colour pickers, dialogs)
	local overlay = create("Frame", { Parent = main, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 40 })
	local catcher = create("TextButton", {
		Parent = overlay, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), Visible = false,
	})
	local activePopup
	function Window:_closePopup()
		if activePopup then
			local p = activePopup
			activePopup = nil
			catcher.Visible = false
			p.Close()
		end
	end
	function Window:_openPopup(popup)
		self:_closePopup()
		activePopup = popup
		catcher.Visible = true
	end
	catcher.MouseButton1Click:Connect(function() Window:_closePopup() end)

	function Window:_toMain(absPos)
		return (absPos - main.AbsolutePosition) / self.Scale
	end
	Window.Overlay = overlay

	---------------------------------------------------------------- sidebar

	local sidebarW = Window.Compact and SIDEBAR_COMPACT or SIDEBAR_W
	local sidebar = create("Frame", {
		Parent = main, Size = UDim2.new(0, sidebarW, 1, 0), ClipsDescendants = true,
		Theme = { BackgroundColor3 = "Sidebar" },
	}, { corner(12) })
	create("Frame", {
		Parent = sidebar, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 12, 1, 0),
		Theme = { BackgroundColor3 = "Sidebar" },
	})
	create("Frame", {
		Parent = sidebar, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), ZIndex = 3,
		Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
		Theme = { BackgroundColor3 = "Stroke" },
	})

	local brand = create("Frame", { Parent = sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, TOPBAR_H) })
	local logo = create("Frame", {
		Parent = brand, BackgroundColor3 = Color3.new(1, 1, 1),
		Position = UDim2.new(0, 14, 0.5, -16), Size = UDim2.fromOffset(32, 32),
	}, { corner(9), accentGradient(45) })
	Icon(opts.Icon or opts.Logo or "waves", 18, nil, {
		Parent = logo, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(1, 1, 1),
	})
	local brandTitle = text({
		Parent = brand, Text = opts.Title or "OrcaHub", Weight = "Bold", TextSize = 15,
		Position = UDim2.new(0, 56, 0.5, -15), Size = UDim2.new(1, -64, 0, 18),
	})
	local brandSub = text({
		Parent = brand, Text = opts.Subtitle or ("v" .. OrcaHub.Version), TextSize = 11,
		Position = UDim2.new(0, 56, 0.5, 3), Size = UDim2.new(1, -64, 0, 14),
		Theme = { TextColor3 = "DimText" },
	})
	create("Frame", {
		Parent = brand, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Stroke" },
	})

	local profileH = opts.ShowProfile == false and 0 or 60
	local tabArea = create("Frame", {
		Parent = sidebar, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, TOPBAR_H), Size = UDim2.new(1, -1, 1, -TOPBAR_H - profileH),
	})
	local pill = create("Frame", {
		Parent = tabArea, Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, TAB_H),
		Visible = false, Theme = { BackgroundColor3 = "Element" },
	}, { corner(8), stroke("Stroke") })
	create("Frame", {
		Parent = pill, BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 18),
	}, { corner(2), accentGradient(90) })

	local tabList = create("ScrollingFrame", {
		Parent = tabArea, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
		Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, {
		create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
		padding(8, 8, 8, 8),
	})
	local fadeLabels = { brandTitle, brandSub }

	if profileH > 0 then
		local profile = create("Frame", {
			Parent = sidebar, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, -1, 0, profileH),
		})
		create("Frame", {
			Parent = profile, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1),
			Theme = { BackgroundColor3 = "Stroke" },
		})
		local avatar = create("ImageLabel", {
			Parent = profile, Position = UDim2.new(0, 14, 0.5, -16), Size = UDim2.fromOffset(32, 32),
			Theme = { BackgroundColor3 = "Element" },
		}, { corner(16), stroke("StrokeLight") })
		task.spawn(function()
			local ok, img = pcall(function()
				return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok then avatar.Image = img end
		end)
		local display = text({
			Parent = profile, Text = LocalPlayer.DisplayName, Weight = "Medium", TextSize = 13,
			Position = UDim2.new(0, 56, 0.5, -15), Size = UDim2.new(1, -64, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd,
		})
		local username = text({
			Parent = profile, Text = "@" .. LocalPlayer.Name, TextSize = 11,
			Position = UDim2.new(0, 56, 0.5, 2), Size = UDim2.new(1, -64, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd,
			Theme = { TextColor3 = "DimText" },
		})
		table.insert(fadeLabels, display)
		table.insert(fadeLabels, username)
	end

	---------------------------------------------------------------- content

	local content = create("Frame", {
		Parent = main, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(sidebarW, 0), Size = UDim2.new(1, -sidebarW, 1, 0),
	})
	local topbar = create("Frame", { Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, TOPBAR_H) })
	create("Frame", {
		Parent = topbar, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Stroke" },
	})

	local function iconButton(iconName, position, hoverColor)
		local b = create("TextButton", {
			Parent = topbar, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5), Position = position, Size = UDim2.fromOffset(30, 30),
			Theme = { BackgroundColor3 = "Element" },
		}, { corner(8) })
		local ic = Icon(iconName, 16, "DimText", {
			Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		})
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundTransparency = 0 })
			tween(ic, { ImageColor3 = hoverColor or T().Text })
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundTransparency = 1 })
			tween(ic, { ImageColor3 = T().DimText })
		end)
		return b
	end

	local collapseBtn = iconButton("sidebar", UDim2.new(0, 12, 0.5, 0))
	local pageTitle = text({
		Parent = topbar, Text = "", Weight = "SemiBold", TextSize = 15,
		Position = UDim2.fromOffset(52, 11), Size = UDim2.new(1, -330, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local pageDesc = text({
		Parent = topbar, Text = "", TextSize = 12,
		Position = UDim2.fromOffset(52, 31), Size = UDim2.new(1, -330, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "DimText" },
	})

	local closeBtn = iconButton("x", UDim2.new(1, -42, 0.5, 0), rgb(248, 113, 113))
	local minBtn = iconButton("minus", UDim2.new(1, -76, 0.5, 0))

	local searchW = MOBILE and 150 or 210
	local search = create("Frame", {
		Parent = topbar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -86, 0.5, 0),
		Size = UDim2.fromOffset(searchW, 32), Theme = { BackgroundColor3 = "Element" },
	}, { corner(8) })
	local searchStroke = stroke("Stroke")
	searchStroke.Parent = search
	Icon("search", 14, "DimText", { Parent = search, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
	local searchBox = text({
		Class = "TextBox", Parent = search, Text = "", PlaceholderText = "Search...", ClearTextOnFocus = false,
		Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0),
		Theme = { TextColor3 = "Text", PlaceholderColor3 = "DimText" },
	})
	searchBox.Focused:Connect(function() tween(searchStroke, { Color = T().Accent }) end)
	searchBox.FocusLost:Connect(function() tween(searchStroke, { Color = T().Stroke }) end)

	local pages = create("Frame", {
		Parent = content, BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.fromOffset(0, TOPBAR_H), Size = UDim2.new(1, 0, 1, -TOPBAR_H - FOOTER_H),
	})
	local pageCover = create("Frame", {
		Parent = pages, Size = UDim2.fromScale(1, 1), ZIndex = 20, BackgroundTransparency = 1, Visible = false,
		Theme = { BackgroundColor3 = "Background" },
	})

	local footer = create("Frame", {
		Parent = content, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, FOOTER_H),
	})
	create("Frame", {
		Parent = footer, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Stroke" },
	})
	text({
		Parent = footer, Text = opts.Footer or "", TextSize = 11,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -60, 1, 0),
		Theme = { TextColor3 = "DimText" },
	})

	---------------------------------------------------------------- scaling, dragging, resizing

	function Window:_updateScale()
		local vp = viewport()
		local fit = math.min(1, (vp.X - 24) / self.Size.X, (vp.Y - 24) / self.Size.Y)
		self.Scale = math.max(0.4, fit) * self.UserScale
		uiScale.Scale = self.Scale
	end
	Window:_updateScale()

	local function clampPosition(x, y)
		local vp = viewport()
		local w, h = Window.Size.X * Window.Scale, Window.Size.Y * Window.Scale
		local maxX = vp.X / 2 + w / 2 - 80
		local minY = h / 2 - vp.Y / 2
		local maxY = vp.Y / 2 + h / 2 - 60
		return math.clamp(x, -maxX, maxX), math.clamp(y, math.min(minY, maxY), maxY)
	end

	local function dragFrom(handle, onStart)
		handle.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			local start = vec2(input.Position)
			local startPos = holder.Position
			if onStart then onStart() end
			local moveConn, endConn
			moveConn = track(UserInputService.InputChanged:Connect(function(i)
				if isMove(i, input.UserInputType == Enum.UserInputType.Touch and input or nil) then
					local d = vec2(i.Position) - start
					local x, y = clampPosition(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
					holder.Position = UDim2.new(0.5, x, 0.5, y)
				end
			end))
			endConn = track(UserInputService.InputEnded:Connect(function(i)
				if i == input or i.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConn:Disconnect()
					endConn:Disconnect()
				end
			end))
		end)
	end
	dragFrom(topbar, function() Window:_closePopup() end)
	dragFrom(brand, function() Window:_closePopup() end)

	if not MOBILE then
		local grip = create("TextButton", {
			Parent = footer, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(18, 18),
		})
		local gripIcon = Icon("move-diagonal-2", 13, "DimText", {
			Parent = grip, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		})
		grip.MouseEnter:Connect(function() tween(gripIcon, { ImageColor3 = T().Accent }) end)
		grip.MouseLeave:Connect(function() tween(gripIcon, { ImageColor3 = T().DimText }) end)
		grip.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			local start = vec2(input.Position)
			local startSize = Window.Size
			local moveConn, endConn
			moveConn = track(UserInputService.InputChanged:Connect(function(i)
				if isMove(i) then
					local d = (vec2(i.Position) - start) / Window.Scale
					Window.Size = Vector2.new(math.max(600, startSize.X + d.X), math.max(380, startSize.Y + d.Y))
					holder.Size = UDim2.fromOffset(Window.Size.X, Window.Size.Y)
				end
			end))
			endConn = track(UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConn:Disconnect()
					endConn:Disconnect()
				end
			end))
		end)
	end

	local function watchCamera()
		local cam = workspace.CurrentCamera
		if cam then
			track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() Window:_updateScale() end))
		end
	end
	watchCamera()
	track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		watchCamera()
		Window:_updateScale()
	end))

	---------------------------------------------------------------- visibility

	local fab = create("TextButton", {
		Parent = gui, Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 44, 0.5, 0), Size = UDim2.fromOffset(48, 48),
		Visible = MOBILE, ZIndex = 10,
	}, { corner(14), accentGradient(45) })
	local fabScale = create("UIScale", { Parent = fab })
	Icon(opts.Icon or opts.Logo or "waves", 22, nil, {
		Parent = fab, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(1, 1, 1),
	})
	Window.ToggleButton = fab

	function Window:SetVisible(v)
		if v == self.Visible then return end
		self.Visible = v
		if v then
			holder.Visible = true
			uiScale.Scale = self.Scale * 0.94
			cover.BackgroundTransparency = 0
			tween(uiScale, { Scale = self.Scale }, 0.4, Enum.EasingStyle.Back)
			tween(cover, { BackgroundTransparency = 1 }, 0.3)
		else
			self:_closePopup()
			tween(uiScale, { Scale = self.Scale * 0.94 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tween(cover, { BackgroundTransparency = 0 }, 0.18).Completed:Connect(function()
				if not self.Visible then holder.Visible = false end
			end)
		end
		if not MOBILE then fab.Visible = not v end
	end

	function Window:Toggle() self:SetVisible(not self.Visible) end

	function Window:SetToggleKey(key) self.ToggleKey = key end

	do
		local pressed, start, startPos, moved = nil, nil, nil, false
		fab.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			pressed, start, startPos, moved = input, vec2(input.Position), fab.Position, false
			tween(fabScale, { Scale = 0.9 }, 0.15)
		end)
		track(UserInputService.InputChanged:Connect(function(i)
			if pressed and isMove(i, pressed.UserInputType == Enum.UserInputType.Touch and pressed or nil) then
				local d = vec2(i.Position) - start
				if d.Magnitude > 6 then moved = true end
				if moved then
					fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end))
		track(UserInputService.InputEnded:Connect(function(i)
			if pressed and (i == pressed or i.UserInputType == Enum.UserInputType.MouseButton1) then
				pressed = nil
				tween(fabScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
				if not moved then Window:Toggle() end
			end
		end))
	end

	track(UserInputService.InputBegan:Connect(function(input, processed)
		if processed or Window._capturing then return end
		if input.KeyCode == Window.ToggleKey then Window:Toggle() end
	end))

	minBtn.MouseButton1Click:Connect(function()
		Window:SetVisible(false)
		if not MOBILE then
			OrcaHub:Notify({ Title = "Hidden", Content = "Press " .. Window.ToggleKey.Name .. " or the floating button to reopen.", Duration = 3 })
		end
	end)

	---------------------------------------------------------------- dialog

	function Window:Dialog(o)
		o = o or {}
		self:_closePopup()
		local backdrop = create("TextButton", {
			Parent = overlay, Text = "", AutoButtonColor = false, ZIndex = 5,
			BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		})
		local card = create("Frame", {
			Parent = backdrop, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(320, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Theme = { BackgroundColor3 = "Section" },
		}, { corner(12), stroke("StrokeLight"), padding(18, 18, 18, 18) })
		local cardScale = create("UIScale", { Parent = card, Scale = 0.9 })
		create("UIListLayout", { Parent = card, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
		text({ Parent = card, Text = o.Title or "Are you sure?", Weight = "SemiBold", TextSize = 16, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 })
		if o.Content then
			text({
				Parent = card, Text = o.Content, TextSize = 13, TextWrapped = true, LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Theme = { TextColor3 = "SubText" },
			})
		end
		local row = create("Frame", { Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 3 }, {
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8),
			}),
		})

		local closing = false
		local function close()
			if closing then return end
			closing = true
			tween(backdrop, { BackgroundTransparency = 1 }, 0.2)
			tween(cardScale, { Scale = 0.9 }, 0.2)
			for _, d in ipairs(card:GetDescendants()) do
				if d:IsA("TextLabel") or d:IsA("TextButton") then tween(d, { TextTransparency = 1 }, 0.15) end
			end
			tween(card, { BackgroundTransparency = 1 }, 0.2)
			task.delay(0.22, function() backdrop:Destroy() end)
		end

		for _, b in ipairs(o.Buttons or { { Title = "OK" } }) do
			local primary = b.Primary
			local btn = text({
				Class = "TextButton", Parent = row, Text = b.Title or "OK", AutoButtonColor = false,
				Weight = "Medium", TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1, 1, 1),
				Theme = (not primary) and { BackgroundColor3 = "Element", TextColor3 = "Text" } or false,
				TextColor3 = Color3.new(1, 1, 1),
			}, nil)
			corner(8).Parent = btn
			padding(0, 16, 0, 16).Parent = btn
			if primary then
				accentGradient(0).Parent = btn
			else
				stroke("StrokeLight").Parent = btn
			end
			btn.MouseButton1Click:Connect(function()
				close()
				safeCall(b.Callback)
			end)
		end

		tween(backdrop, { BackgroundTransparency = 0.45 }, 0.25)
		tween(cardScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
		return { Close = close }
	end

	closeBtn.MouseButton1Click:Connect(function()
		Window:Dialog({
			Title = "Close " .. (opts.Title or "OrcaHub") .. "?",
			Content = "This will unload the interface. Your features may keep running.",
			Buttons = {
				{ Title = "Cancel" },
				{ Title = "Close", Primary = true, Callback = function() Window:Destroy() end },
			},
		})
	end)

	---------------------------------------------------------------- sidebar behaviour

	function Window:_moveIndicator(animate)
		local tab = self.CurrentTab
		if not tab then return end
		local btn = tab.Button
		local y = (btn.AbsolutePosition.Y - tabArea.AbsolutePosition.Y) / self.Scale
		local h = btn.AbsoluteSize.Y / self.Scale
		pill.Visible = true
		set(pill, { Position = UDim2.new(0, 8, 0, y), Size = UDim2.new(1, -16, 0, h) }, animate, 0.35)
	end
	tabList:GetPropertyChangedSignal("CanvasPosition"):Connect(function() Window:_moveIndicator(false) end)
	tabArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Window:_moveIndicator(false) end)

	local tooltip = text({
		Parent = overlay, Text = "", TextSize = 12, Weight = "Medium", Visible = false, ZIndex = 8,
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0,
		Theme = { BackgroundColor3 = "Element", TextColor3 = "Text" },
	})
	corner(6).Parent = tooltip
	stroke("StrokeLight").Parent = tooltip
	padding(0, 10, 0, 10).Parent = tooltip

	function Window:SetCompact(v, instant)
		self.Compact = v
		local w = v and SIDEBAR_COMPACT or SIDEBAR_W
		local t = instant and 0 or 0.35
		set(sidebar, { Size = UDim2.new(0, w, 1, 0) }, not instant, t)
		set(content, { Position = UDim2.fromOffset(w, 0), Size = UDim2.new(1, -w, 1, 0) }, not instant, t)
		for _, lbl in ipairs(fadeLabels) do
			set(lbl, { TextTransparency = v and 1 or 0 }, not instant, t * 0.6)
		end
		task.delay(t + 0.05, function()
			for _, tab in ipairs(self.Tabs) do tab:_queueLayout(false) end
			self:_moveIndicator(false)
		end)
	end
	collapseBtn.MouseButton1Click:Connect(function() Window:SetCompact(not Window.Compact) end)

	local orderCounter = 0
	local function nextOrder()
		orderCounter = orderCounter + 1
		return orderCounter
	end

	function Window:Divider(name)
		local row = create("Frame", { Parent = tabList, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = nextOrder() })
		local lbl = text({
			Parent = row, Text = string.upper(name or ""), TextSize = 10, Weight = "SemiBold",
			Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -12, 1, -6),
			Theme = { TextColor3 = "DimText" }, TextTransparency = Window.Compact and 1 or 0,
		})
		table.insert(fadeLabels, lbl)
	end

	---------------------------------------------------------------- layout persistence

	function Window:SaveLayout()
		local data = {}
		for _, tab in ipairs(self.Tabs) do
			local entry = { columns = { {}, {} }, collapsed = {} }
			for ci = 1, 2 do
				for _, s in ipairs(tab.Columns[ci]) do table.insert(entry.columns[ci], s.Name) end
			end
			for _, s in ipairs(tab.Sections) do
				if s.Collapsed then entry.collapsed[s.Name] = true end
			end
			data[tab.Name] = entry
		end
		self.SavedLayout = data
		writeJSON(self.LayoutPath, data)
	end

	function Window:ResetLayout()
		for _, tab in ipairs(self.Tabs) do
			tab.Columns = { {}, {} }
			for _, s in ipairs(tab.Sections) do
				table.insert(tab.Columns[s.DefaultSide], s)
				if s.Collapsed then s:SetCollapsed(false, true) end
			end
			tab:_layout(true)
		end
		self.SavedLayout = {}
		if hasFS() and type(delfile) == "function" and isfile(self.LayoutPath) then pcall(delfile, self.LayoutPath) end
	end

	---------------------------------------------------------------- search

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local tab = Window.CurrentTab
		if not tab then return end
		local q = string.lower((string.gsub(searchBox.Text, "^%s+", "")))
		Window._searching = q ~= ""
		for _, section in ipairs(tab.Sections) do
			local sectionMatch = q ~= "" and string.find(string.lower(section.Name), q, 1, true) ~= nil
			local any = false
			for _, el in ipairs(section.Elements) do
				local show = q == "" or sectionMatch or string.find(el.SearchText, q, 1, true) ~= nil
				el.Row.Visible = show
				if show then any = true end
			end
			section.Frame.Visible = q == "" or any or sectionMatch
		end
		tab:_layout(true)
	end)

	---------------------------------------------------------------- tabs

	function Window:Tab(o)
		o = o or {}
		local Tab = {
			Name = o.Name or "Tab",
			Description = o.Description or "",
			Sections = {},
			Columns = { {}, {} },
			Window = Window,
		}
		local saved = Window.SavedLayout[Tab.Name]

		local btn = create("TextButton", {
			Parent = tabList, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, TAB_H), LayoutOrder = nextOrder(),
		})
		Tab.Button = btn
		local iconInst
		if iconImage(o.Icon) then
			iconInst = Icon(o.Icon, 18, nil, {
				Parent = btn, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 13, 0.5, 0),
				ImageColor3 = T().DimText,
			})
		else
			iconInst = text({
				Parent = btn, Text = string.upper(string.sub(Tab.Name, 1, 1)), Weight = "Bold", TextSize = 15,
				AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 13, 0.5, 0), Size = UDim2.fromOffset(18, 18),
				TextXAlignment = Enum.TextXAlignment.Center, Theme = false, TextColor3 = T().DimText,
			})
		end
		local iconProp = iconInst:IsA("ImageLabel") and "ImageColor3" or "TextColor3"
		local label = text({
			Parent = btn, Text = Tab.Name, TextSize = 13, Weight = "Medium",
			Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -46, 1, 0),
			Theme = false, TextColor3 = T().SubText, TextTransparency = Window.Compact and 1 or 0,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		table.insert(fadeLabels, label)

		local page = create("ScrollingFrame", {
			Parent = pages, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
			Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
			ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
			Theme = { ScrollBarImageColor3 = "StrokeLight" },
		})
		local origin = create("Frame", { Parent = page, BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0) })
		local placeholder = create("Frame", {
			Parent = page, Visible = false, BackgroundTransparency = 0.92,
			Theme = { BackgroundColor3 = "Accent" },
		}, { corner(10) })
		local placeholderStroke = create("UIStroke", {
			Parent = placeholder, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.4,
			Theme = { Color = "Accent" },
		})
		placeholderStroke.Thickness = 1
		Tab.Page = page

		local function renderTab(active, animate)
			set(label, { TextColor3 = active and T().Text or T().SubText }, animate)
			set(iconInst, { [iconProp] = active and T().Accent or T().DimText }, animate)
		end
		table.insert(Refreshers, function() renderTab(Window.CurrentTab == Tab, false) end)

		btn.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then tween(label, { TextColor3 = T().Text }) end
			if Window.Compact and not MOBILE then
				local pos = Window:_toMain(btn.AbsolutePosition)
				tooltip.Text = Tab.Name
				tooltip.Position = UDim2.fromOffset(SIDEBAR_COMPACT + 6, pos.Y + (TAB_H - 26) / 2)
				tooltip.Visible = true
			end
		end)
		btn.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then tween(label, { TextColor3 = T().SubText }) end
			tooltip.Visible = false
		end)

		function Tab:Select()
			if Window.CurrentTab == Tab then return end
			Window:_closePopup()
			local prev = Window.CurrentTab
			Window.CurrentTab = Tab
			if prev then
				prev:_render(false)
				prev.Page.Visible = false
			end
			renderTab(true, true)
			pageTitle.Text = Tab.Name
			pageDesc.Text = Tab.Description
			pageTitle.Position = UDim2.fromOffset(52, Tab.Description == "" and 19 or 11)
			pageTitle.TextTransparency = 1
			pageDesc.TextTransparency = 1
			tween(pageTitle, { TextTransparency = 0 }, 0.3)
			tween(pageDesc, { TextTransparency = 0 }, 0.4)

			page.Visible = true
			page.Position = UDim2.fromOffset(0, 16)
			tween(page, { Position = UDim2.fromOffset(0, 0) }, 0.4)
			pageCover.Visible = true
			pageCover.BackgroundTransparency = 0
			tween(pageCover, { BackgroundTransparency = 1 }, 0.3).Completed:Connect(function()
				if pageCover.BackgroundTransparency >= 1 then pageCover.Visible = false end
			end)

			if searchBox.Text ~= "" then searchBox.Text = "" end
			Tab:_layout(false)
			task.defer(function() Window:_moveIndicator(prev ~= nil) end)
		end

		function Tab:_render(active)
			renderTab(active, true)
		end

		btn.MouseButton1Click:Connect(function() Tab:Select() end)

		---------------------------------------------------- masonry layout

		function Tab:_layout(animate)
			local width = page.AbsoluteWindowSize.X / Window.Scale
			if width <= 0 then return end
			local single = width < 540
			Tab.Single = single
			local colW = single and (width - PAD * 2) or math.floor((width - PAD * 2 - GAP) / 2)
			local lists = Tab.Columns
			if single then
				local merged = {}
				for ci = 1, 2 do
					for _, s in ipairs(Tab.Columns[ci]) do table.insert(merged, s) end
				end
				lists = { merged }
			end
			local maxY = 0
			for ci, list in ipairs(lists) do
				local x = PAD + (ci - 1) * (colW + GAP)
				local y = PAD
				for _, s in ipairs(list) do
					if s.Frame.Visible then
						local h = s:_height()
						s._targetX, s._targetY, s._width = x, y, colW
						if s == Tab._dragging then
							placeholder.Position = UDim2.fromOffset(x, y)
							placeholder.Size = UDim2.fromOffset(colW, h)
							s.Frame.Size = UDim2.fromOffset(colW, s.Frame.Size.Y.Offset)
						else
							s.Frame.Size = UDim2.fromOffset(colW, s.Frame.Size.Y.Offset)
							set(s.Frame, { Position = UDim2.fromOffset(x, y) }, animate, 0.35)
						end
						y = y + h + GAP
					end
				end
				maxY = math.max(maxY, y)
			end
			page.CanvasSize = UDim2.fromOffset(0, math.max(0, maxY - GAP + PAD))
		end

		function Tab:_queueLayout(animate)
			if Tab._queued then
				Tab._queuedAnimate = Tab._queuedAnimate or animate
				return
			end
			Tab._queued, Tab._queuedAnimate = true, animate
			task.defer(function()
				Tab._queued = false
				Tab:_layout(Tab._queuedAnimate)
			end)
		end

		page:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function() Tab:_queueLayout(false) end)
		page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if not Tab._dragging then Window:_closePopup() end
		end)

		---------------------------------------------------- section dragging

		local function canvasPoint(screenPos)
			return (screenPos - origin.AbsolutePosition) / Window.Scale
		end

		function Tab:_startDrag(section, pressInput, startScreen)
			Window:_closePopup()
			Tab._dragging = section
			local frame = section.Frame
			local grab = canvasPoint(startScreen) - Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
			local pointer = startScreen
			frame.ZIndex = 10
			tween(section._scale, { Scale = 1.02 }, 0.2)
			tween(section._stroke, { Color = T().Accent }, 0.2)
			page.ScrollingEnabled = false
			placeholder.Visible = true
			placeholder.ZIndex = 1
			Tab:_layout(true)

			local function location()
				for ci = 1, 2 do
					for i, s in ipairs(Tab.Columns[ci]) do
						if s == section then return ci, i end
					end
				end
			end

			local function target(p)
				if Tab.Single then
					local count, c1 = 0, 0
					for ci = 1, 2 do
						for _, s in ipairs(Tab.Columns[ci]) do
							if s ~= section then
								if ci == 1 then c1 = c1 + 1 end
								if s.Frame.Visible and p.Y > s._targetY + s:_height() / 2 then count = count + 1 end
							end
						end
					end
					if count <= c1 then return 1, count + 1 end
					return 2, count - c1 + 1
				end
				local width = page.AbsoluteWindowSize.X / Window.Scale
				local ci = p.X > width / 2 and 2 or 1
				local idx = 1
				for _, s in ipairs(Tab.Columns[ci]) do
					if s ~= section and s.Frame.Visible and p.Y > s._targetY + s:_height() / 2 then idx = idx + 1 end
				end
				return ci, idx
			end

			local function update()
				local p = canvasPoint(pointer)
				frame.Position = UDim2.fromOffset(p.X - grab.X, p.Y - grab.Y)
				local center = Vector2.new(p.X - grab.X + frame.Size.X.Offset / 2, p.Y - grab.Y + section:_height() / 2)
				local ci, idx = target(center)
				local curC, curI = location()
				if ci ~= curC or idx ~= curI then
					table.remove(Tab.Columns[curC], curI)
					table.insert(Tab.Columns[ci], math.min(idx, #Tab.Columns[ci] + 1), section)
					Tab:_layout(true)
				end
			end

			local moveConn, endConn, stepConn
			local touch = pressInput.UserInputType == Enum.UserInputType.Touch
			moveConn = track(UserInputService.InputChanged:Connect(function(i)
				if isMove(i, touch and pressInput or nil) then
					pointer = vec2(i.Position)
					update()
				end
			end))
			stepConn = track(RunService.Heartbeat:Connect(function()
				local top = page.AbsolutePosition.Y
				local bottom = top + page.AbsoluteSize.Y
				local delta = 0
				if pointer.Y < top + 40 then delta = -8 elseif pointer.Y > bottom - 40 then delta = 8 end
				if delta ~= 0 then
					local maxScroll = math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteWindowSize.Y)
					local y = math.clamp(page.CanvasPosition.Y + delta, 0, maxScroll)
					if y ~= page.CanvasPosition.Y then
						page.CanvasPosition = Vector2.new(0, y)
						update()
					end
				end
			end))
			endConn = track(UserInputService.InputEnded:Connect(function(i)
				if i == pressInput or i.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConn:Disconnect()
					endConn:Disconnect()
					stepConn:Disconnect()
					Tab._dragging = nil
					page.ScrollingEnabled = true
					placeholder.Visible = false
					tween(section._scale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
					tween(section._stroke, { Color = T().Stroke }, 0.3)
					Tab:_layout(true)
					task.delay(0.36, function()
						if Tab._dragging ~= section then frame.ZIndex = 1 end
					end)
					Window:SaveLayout()
				end
			end))
		end

		---------------------------------------------------- sections

		function Tab:Section(so)
			so = so or {}
			local Section = {
				Name = so.Name or "Section",
				Elements = {},
				Collapsed = false,
				DefaultSide = (so.Side == "Right" or so.Side == 2) and 2 or 1,
				_bodyH = 0,
			}
			local savedEntry = saved and saved.collapsed and saved.collapsed[Section.Name]
			if so.Collapsed or savedEntry then Section.Collapsed = true end

			local frame = create("Frame", {
				Parent = page, ClipsDescendants = true,
				Size = UDim2.fromOffset(300, SECTION_HEADER), Position = UDim2.fromOffset(PAD, PAD),
				Theme = { BackgroundColor3 = "Section" },
			}, { corner(10) })
			Section.Frame = frame
			Section._stroke = stroke("Stroke")
			Section._stroke.Parent = frame
			Section._scale = create("UIScale", { Parent = frame })

			local header = create("Frame", { Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, SECTION_HEADER) })
			Section.Header = header
			local grip = Icon("grip-vertical", 14, "DimText", {
				Parent = header, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0),
				ImageTransparency = MOBILE and 0.3 or 0.6,
			})
			local titleX = 26
			if so.Icon and iconImage(so.Icon) then
				Icon(so.Icon, 15, "Accent", { Parent = header, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 26, 0.5, 0) })
				titleX = 48
			end
			text({
				Parent = header, Text = Section.Name, Weight = "SemiBold", TextSize = 13,
				Position = UDim2.fromOffset(titleX, 0), Size = UDim2.new(1, -titleX - 40, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			local chevronBtn = create("TextButton", {
				Parent = header, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(26, 26),
				Theme = { BackgroundColor3 = "Element" },
			}, { corner(6) })
			local chevron = Icon("chevron-down", 14, "DimText", {
				Parent = chevronBtn, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				Rotation = Section.Collapsed and -90 or 0,
			})
			local headerLine = create("Frame", {
				Parent = header, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
				BackgroundTransparency = Section.Collapsed and 1 or 0, Theme = { BackgroundColor3 = "Stroke" },
			})

			local body = create("Frame", {
				Parent = frame, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, SECTION_HEADER), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			}, { padding(8, 12, 12, 12) })
			local list = create("UIListLayout", { Parent = body, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

			function Section:_height()
				return SECTION_HEADER + (Section.Collapsed and 0 or Section._bodyH)
			end

			local function resize(animate)
				local target = UDim2.fromOffset(Section._width or frame.Size.X.Offset, Section:_height())
				set(frame, { Size = target }, animate, 0.35)
			end

			list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section._bodyH = list.AbsoluteContentSize.Y / Window.Scale + 20
				resize(false)
				Tab:_queueLayout(false)
			end)

			function Section:SetCollapsed(v, skipSave)
				Section.Collapsed = v
				tween(chevron, { Rotation = v and -90 or 0 }, 0.3)
				tween(headerLine, { BackgroundTransparency = v and 1 or 0 }, 0.2)
				resize(true)
				Tab:_layout(true)
				if not skipSave then Window:SaveLayout() end
			end

			chevronBtn.MouseEnter:Connect(function() tween(chevronBtn, { BackgroundTransparency = 0 }) end)
			chevronBtn.MouseLeave:Connect(function() tween(chevronBtn, { BackgroundTransparency = 1 }) end)
			chevronBtn.MouseButton1Click:Connect(function() Section:SetCollapsed(not Section.Collapsed) end)

			frame.MouseEnter:Connect(function() if not MOBILE then tween(grip, { ImageTransparency = 0 }) end end)
			frame.MouseLeave:Connect(function() if not MOBILE then tween(grip, { ImageTransparency = 0.6 }) end end)

			header.InputBegan:Connect(function(input)
				if not isPress(input) or Window._searching or Tab._dragging then return end
				local start = vec2(input.Position)
				local touch = input.UserInputType == Enum.UserInputType.Touch
				local done = false
				local moveConn, endConn
				local function cleanup()
					done = true
					if moveConn then moveConn:Disconnect() end
					if endConn then endConn:Disconnect() end
				end
				if touch then
					task.delay(0.3, function()
						if not done then
							cleanup()
							Tab:_startDrag(Section, input, start)
						end
					end)
				end
				moveConn = UserInputService.InputChanged:Connect(function(i)
					if isMove(i, touch and input or nil) and (vec2(i.Position) - start).Magnitude > 6 then
						cleanup()
						if not touch then Tab:_startDrag(Section, input, start) end
					end
				end)
				endConn = UserInputService.InputEnded:Connect(function(i)
					if i == input or i.UserInputType == Enum.UserInputType.MouseButton1 then cleanup() end
				end)
			end)

			-- place into column, honouring a saved layout
			local column, index = Section.DefaultSide, nil
			if saved and saved.columns then
				for ci = 1, 2 do
					for i, name in ipairs(saved.columns[ci] or {}) do
						if name == Section.Name then column, index = ci, i end
					end
				end
			end
			Section._savedIndex = index or math.huge
			local col = Tab.Columns[column]
			local insertAt = #col + 1
			for i, other in ipairs(col) do
				if (other._savedIndex or math.huge) > Section._savedIndex then
					insertAt = i
					break
				end
			end
			table.insert(col, insertAt, Section)
			table.insert(Tab.Sections, Section)
			resize(false)
			Tab:_queueLayout(false)

			------------------------------------------------ element helpers

			local order = 0
			local function newRow(height)
				order = order + 1
				return create("Frame", {
					Parent = body, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or ROW_H), LayoutOrder = order,
				})
			end

			local function titleBlock(parent, name, desc, rightInset, top)
				local holderFrame = create("Frame", {
					Parent = parent, BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, top or 0),
					Size = top and UDim2.new(1, -(rightInset or 0), 0, 18) or UDim2.new(1, -(rightInset or 0), 1, 0),
				})
				create("UIListLayout", {
					Parent = holderFrame, VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1),
				})
				local title = text({
					Parent = holderFrame, Text = name, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1,
					TextTruncate = Enum.TextTruncate.AtEnd, Theme = false, TextColor3 = T().SubText,
				})
				if desc and not top then
					text({
						Parent = holderFrame, Text = desc, TextSize = 11, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2,
						TextTruncate = Enum.TextTruncate.AtEnd, Theme = { TextColor3 = "DimText" },
					})
				end
				return title
			end

			local function register(kind, o, row, obj)
				obj.Type = kind
				obj.Name = o.Name or o.Title or kind
				obj.Row = row
				obj.Flag = o.Flag
				obj.SearchText = string.lower(obj.Name .. " " .. (o.Description or ""))
				function obj:SetVisible(v)
					row.Visible = v
				end
				function obj:Destroy()
					row:Destroy()
					for i, e in ipairs(Section.Elements) do
						if e == obj then table.remove(Section.Elements, i) break end
					end
					if o.Flag then OrcaHub.Options[o.Flag] = nil end
				end
				table.insert(Section.Elements, obj)
				if o.Flag then OrcaHub.Options[o.Flag] = obj end
				return obj
			end

			local function hoverTitle(btn, title, isActive)
				btn.MouseEnter:Connect(function()
					if not isActive() then tween(title, { TextColor3 = T().Text }) end
				end)
				btn.MouseLeave:Connect(function()
					if not isActive() then tween(title, { TextColor3 = T().SubText }) end
				end)
			end

			------------------------------------------------ label / paragraph / divider

			function Section:Label(o)
				if type(o) == "string" then o = { Text = o } end
				local row = newRow(0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				local lbl = text({
					Parent = row, Text = o.Text or "", TextWrapped = true, RichText = true,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
					Theme = { TextColor3 = "SubText" },
				})
				padding(4, 0, 4, 0).Parent = row
				local obj = { Set = function(_, v) lbl.Text = v end }
				return register("Label", { Name = o.Text }, row, obj)
			end

			function Section:Paragraph(o)
				local row = newRow(0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				local card = create("Frame", {
					Parent = row, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
					Theme = { BackgroundColor3 = "Element" },
				}, { corner(8), stroke("Stroke"), padding(10, 12, 10, 12) })
				create("UIListLayout", { Parent = card, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })
				local title = text({ Parent = card, Text = o.Title or "", Weight = "SemiBold", Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1 })
				local bodyText = text({
					Parent = card, Text = o.Content or "", TextSize = 12, TextWrapped = true, RichText = true, LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Theme = { TextColor3 = "SubText" },
				})
				local obj = {}
				function obj:Set(t, c)
					if t then title.Text = t end
					if c then bodyText.Text = c end
				end
				return register("Paragraph", { Name = (o.Title or "") .. " " .. (o.Content or "") }, row, obj)
			end

			function Section:Divider()
				local row = newRow(9)
				create("Frame", {
					Parent = row, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1),
					Theme = { BackgroundColor3 = "Stroke" },
				})
				return register("Divider", { Name = "" }, row, {})
			end

			------------------------------------------------ button

			function Section:Button(o)
				local row = newRow(BOX_H + 2)
				local primary = o.Style == "Primary"
				local b = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false, ClipsDescendants = true,
					Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
					Theme = (not primary) and { BackgroundColor3 = "Element" } or nil,
				}, { corner(8) })
				if primary then accentGradient(0).Parent = b else stroke("Stroke").Parent = b end
				local scale = create("UIScale", { Parent = b })
				local content = create("Frame", {
					Parent = b, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
				}, {
					create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})
				if o.Icon and iconImage(o.Icon) then
					local ic = Icon(o.Icon, 15, (not primary) and "SubText" or nil, { Parent = content, LayoutOrder = 1 })
					if primary then ic.ImageColor3 = Color3.new(1, 1, 1) end
				end
				text({
					Parent = content, Text = o.Name or "Button", Weight = "Medium", LayoutOrder = 2,
					Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X,
					Theme = (not primary) and { TextColor3 = "Text" } or false, TextColor3 = Color3.new(1, 1, 1),
				})

				b.MouseEnter:Connect(function()
					if primary then tween(b, { BackgroundTransparency = 0.12 }) else tween(b, { BackgroundColor3 = T().ElementHover }) end
				end)
				b.MouseLeave:Connect(function()
					if primary then tween(b, { BackgroundTransparency = 0 }) else tween(b, { BackgroundColor3 = T().Element }) end
					tween(scale, { Scale = 1 }, 0.2)
				end)
				b.MouseButton1Down:Connect(function()
					tween(scale, { Scale = 0.97 }, 0.12)
					local mouse = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
					local rel = (mouse - b.AbsolutePosition) / Window.Scale
					local w = b.AbsoluteSize.X / Window.Scale
					rel = Vector2.new(math.clamp(rel.X, 0, w), math.clamp(rel.Y, 0, BOX_H))
					local ripple = create("Frame", {
						Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(rel.X, rel.Y),
						Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.85, ZIndex = 0,
					}, { corner(999) })
					tween(ripple, { Size = UDim2.fromOffset(w * 2.2, w * 2.2), BackgroundTransparency = 1 }, 0.6)
					task.delay(0.6, function() ripple:Destroy() end)
				end)
				b.MouseButton1Up:Connect(function() tween(scale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back) end)
				b.MouseButton1Click:Connect(function() safeCall(o.Callback) end)

				local obj = {}
				function obj:Fire() safeCall(o.Callback) end
				return register("Button", o, row, obj)
			end

			------------------------------------------------ toggle

			function Section:Toggle(o)
				local state = o.Default == true
				local row = newRow(o.Description and ROW_H + 12 or ROW_H)
				local hit = create("TextButton", { Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
				local title = titleBlock(row, o.Name or "Toggle", o.Description, 56)
				local switch = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(40, 22),
					Theme = { BackgroundColor3 = "ToggleOff" },
				}, { corner(11) })
				local fill = create("Frame", {
					Parent = switch, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
				}, { corner(11), accentGradient(0) })
				local knob = create("Frame", {
					Parent = switch, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16),
					ZIndex = 2, Theme = { BackgroundColor3 = "Knob" },
				}, { corner(8) })

				local obj = {}
				local function render(animate)
					set(fill, { BackgroundTransparency = state and 0 or 1 }, animate, 0.25)
					set(knob, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, animate, 0.4, Enum.EasingStyle.Back)
					set(title, { TextColor3 = state and T().Text or T().SubText }, animate, 0.2)
				end
				table.insert(Refreshers, function() render(false) end)

				function obj:Set(v, silent)
					state = v and true or false
					render(true)
					if o.Flag then OrcaHub.Flags[o.Flag] = state end
					if not silent then safeCall(o.Callback, state) end
				end
				function obj:Get() return state end

				hoverTitle(hit, title, function() return state end)
				hit.MouseButton1Click:Connect(function() obj:Set(not state) end)
				render(false)
				if o.Flag then OrcaHub.Flags[o.Flag] = state end
				return register("Toggle", o, row, obj)
			end

			------------------------------------------------ slider

			function Section:Slider(o)
				local min, max = o.Min or 0, o.Max or 100
				local inc = o.Increment or o.Rounding or 1
				local suffix = o.Suffix or ""
				local value = math.clamp(o.Default or min, min, max)
				local decimals = 0
				local incText = tostring(inc)
				local dot = string.find(incText, ".", 1, true)
				if dot then decimals = #incText - dot end

				local row = newRow(ROW_H + 18)
				titleBlock(row, o.Name or "Slider", nil, 70, 2)
				local valueBox = text({
					Class = "TextBox", Parent = row, Text = "", TextSize = 12, ClearTextOnFocus = false,
					TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0,
					AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(0, 22),
					AutomaticSize = Enum.AutomaticSize.X,
					Theme = { BackgroundColor3 = "Element", TextColor3 = "Text" },
				})
				corner(6).Parent = valueBox
				padding(0, 8, 0, 8).Parent = valueBox
				create("UISizeConstraint", { Parent = valueBox, MinSize = Vector2.new(44, 22) })

				local bar = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, 0, 0, 6),
					Theme = { BackgroundColor3 = "ToggleOff" },
				}, { corner(3) })
				local fill = create("Frame", {
					Parent = bar, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(0, 1),
				}, { corner(3), accentGradient(0) })
				local knob = create("Frame", {
					Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14),
					ZIndex = 2, Theme = { BackgroundColor3 = "Knob" },
				}, { corner(7) })
				local knobStroke = create("UIStroke", { Parent = knob, Thickness = 2, Theme = { Color = "Accent" } })
				knobStroke.Transparency = 0
				local hit = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 22),
				})

				local function format(v)
					return string.format("%." .. decimals .. "f", v)
				end

				local obj = {}
				function obj:Set(v, silent)
					v = tonumber(v) or value
					v = math.floor((v - min) / inc + 0.5) * inc + min
					v = tonumber(format(math.clamp(v, min, max)))
					local changed = v ~= value
					value = v
					local pct = max == min and 0 or (v - min) / (max - min)
					tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.12)
					valueBox.Text = format(v) .. suffix
					if o.Flag then OrcaHub.Flags[o.Flag] = v end
					if changed and not silent then safeCall(o.Callback, v) end
				end
				function obj:Get() return value end

				local dragging
				local function update(x)
					local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					obj:Set(min + (max - min) * pct, o.OnRelease)
				end
				hit.InputBegan:Connect(function(input)
					if not isPress(input) then return end
					dragging = input
					page.ScrollingEnabled = false
					tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.2, Enum.EasingStyle.Back)
					update(input.Position.X)
				end)
				track(UserInputService.InputChanged:Connect(function(i)
					if dragging and isMove(i, dragging.UserInputType == Enum.UserInputType.Touch and dragging or nil) then
						update(i.Position.X)
					end
				end))
				track(UserInputService.InputEnded:Connect(function(i)
					if dragging and (i == dragging or i.UserInputType == Enum.UserInputType.MouseButton1) then
						dragging = nil
						page.ScrollingEnabled = true
						tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.2)
						if o.OnRelease then safeCall(o.Callback, value) end
					end
				end))
				valueBox.FocusLost:Connect(function()
					local n = tonumber((string.gsub(valueBox.Text, "[^%d%.%-]", "")))
					obj:Set(n or value)
				end)

				obj:Set(value, true)
				return register("Slider", o, row, obj)
			end

			------------------------------------------------ input

			function Section:Input(o)
				local row = newRow(BOX_H + 22)
				titleBlock(row, o.Name or "Input", nil, 0, 0)
				local box = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, BOX_H),
					Theme = { BackgroundColor3 = "Element" },
				}, { corner(8) })
				local boxStroke = stroke("Stroke")
				boxStroke.Parent = box
				local x = 10
				if o.Icon and iconImage(o.Icon) then
					Icon(o.Icon, 14, "DimText", { Parent = box, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
					x = 32
				end
				local input = text({
					Class = "TextBox", Parent = box, Text = o.Default or "", PlaceholderText = o.Placeholder or "Type here...",
					ClearTextOnFocus = false, Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x - 10, 1, 0),
					TextTruncate = Enum.TextTruncate.AtEnd,
					Theme = { TextColor3 = "Text", PlaceholderColor3 = "DimText" },
				})
				if o.Numeric then
					input:GetPropertyChangedSignal("Text"):Connect(function()
						local clean = string.gsub(input.Text, "[^%d%.%-]", "")
						if clean ~= input.Text then input.Text = clean end
					end)
				end
				input.Focused:Connect(function() tween(boxStroke, { Color = T().Accent }) end)

				local obj = {}
				function obj:Set(v, silent)
					input.Text = tostring(v or "")
					if o.Flag then OrcaHub.Flags[o.Flag] = input.Text end
					if not silent then safeCall(o.Callback, input.Text, false) end
				end
				function obj:Get() return input.Text end
				input.FocusLost:Connect(function(enter)
					tween(boxStroke, { Color = T().Stroke })
					if o.Flag then OrcaHub.Flags[o.Flag] = input.Text end
					safeCall(o.Callback, input.Text, enter)
				end)
				if o.Flag then OrcaHub.Flags[o.Flag] = input.Text end
				return register("Input", o, row, obj)
			end

			------------------------------------------------ popups

			local function popupAt(anchor, width, height)
				local pos = Window:_toMain(anchor.AbsolutePosition)
				local anchorH = anchor.AbsoluteSize.Y / Window.Scale
				local mainH = main.AbsoluteSize.Y / Window.Scale
				local mainW = main.AbsoluteSize.X / Window.Scale
				local y = pos.Y + anchorH + 6
				local up = false
				if y + height > mainH - 8 then
					y = math.max(8, pos.Y - height - 6)
					up = true
				end
				local x = math.clamp(pos.X + (anchor.AbsoluteSize.X / Window.Scale) - width, 8, mainW - width - 8)
				local frame = create("Frame", {
					Parent = overlay, ZIndex = 2, ClipsDescendants = true,
					Position = UDim2.fromOffset(x, up and (y + height) or y), Size = UDim2.fromOffset(width, 0),
					Theme = { BackgroundColor3 = "Section" },
				}, { corner(8), stroke("StrokeLight") })
				tween(frame, { Size = UDim2.fromOffset(width, height), Position = UDim2.fromOffset(x, y) }, 0.3)
				local function close()
					tween(frame, { Size = UDim2.fromOffset(width, 0), Position = UDim2.fromOffset(x, up and (y + height) or y) }, 0.2)
					task.delay(0.21, function() frame:Destroy() end)
				end
				return frame, close
			end

			------------------------------------------------ dropdown

			function Section:Dropdown(o)
				local options = o.Options or o.Values or {}
				local multi = o.Multi == true
				local selected
				if multi then
					selected = {}
					for _, v in ipairs(type(o.Default) == "table" and o.Default or {}) do selected[v] = true end
				else
					selected = o.Default
				end

				local row = newRow(BOX_H + 22)
				titleBlock(row, o.Name or "Dropdown", nil, 0, 0)
				local head = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false,
					AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, BOX_H),
					Theme = { BackgroundColor3 = "Element" },
				}, { corner(8) })
				local headStroke = stroke("Stroke")
				headStroke.Parent = head
				local valueLbl = text({
					Parent = head, Text = "", Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -36, 1, 0),
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				local chevron = Icon("chevron-down", 14, "DimText", {
					Parent = head, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
				})

				local obj = {}
				local function values()
					if not multi then return selected end
					local out = {}
					for _, opt in ipairs(options) do
						if selected[opt] then table.insert(out, opt) end
					end
					return out
				end
				local function display()
					if multi then
						local v = values()
						valueLbl.Text = #v > 0 and table.concat(v, ", ") or "None"
					else
						valueLbl.Text = selected ~= nil and tostring(selected) or "None"
					end
				end
				local function fire(silent)
					local v = values()
					if o.Flag then OrcaHub.Flags[o.Flag] = v end
					if not silent then safeCall(o.Callback, v) end
				end

				local open = false
				local function openList()
					open = true
					local searchable = o.Searchable or #options > 7
					local searchH = searchable and (BOX_H + 6) or 0
					local listH = math.min(math.max(#options, 1), 6) * (ITEM_H + 2) + 8
					local width = head.AbsoluteSize.X / Window.Scale
					local frame, closeFrame = popupAt(head, width, listH + searchH)
					tween(chevron, { Rotation = 180 }, 0.25)
					tween(headStroke, { Color = T().Accent }, 0.2)
					Window:_openPopup({
						Close = function()
							open = false
							tween(chevron, { Rotation = 0 }, 0.25)
							tween(headStroke, { Color = T().Stroke }, 0.2)
							closeFrame()
						end,
					})

					local filterBox
					if searchable then
						local sb = create("Frame", {
							Parent = frame, Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 0, BOX_H),
							Theme = { BackgroundColor3 = "Element" },
						}, { corner(6) })
						Icon("search", 13, "DimText", { Parent = sb, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0) })
						filterBox = text({
							Class = "TextBox", Parent = sb, Text = "", PlaceholderText = "Search...", ClearTextOnFocus = false,
							TextSize = 12, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -34, 1, 0),
							Theme = { TextColor3 = "Text", PlaceholderColor3 = "DimText" },
						})
					end
					local scroll = create("ScrollingFrame", {
						Parent = frame, BackgroundTransparency = 1, BorderSizePixel = 0,
						Position = UDim2.fromOffset(0, searchH), Size = UDim2.new(1, 0, 1, -searchH),
						CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
						ScrollBarThickness = 2, Theme = { ScrollBarImageColor3 = "StrokeLight" },
					}, {
						create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
						padding(4, 4, 4, 4),
					})

					local items = {}
					local function paint(item, animate)
						local on = multi and selected[item.Value] or (not multi and selected == item.Value)
						set(item.Button, { BackgroundTransparency = on and 0 or 1 }, animate, 0.15)
						set(item.Label, { TextColor3 = on and T().Text or T().SubText }, animate, 0.15)
						set(item.Check, { ImageTransparency = on and 0 or 1 }, animate, 0.15)
						set(item.Bar, { BackgroundTransparency = on and 0 or 1 }, animate, 0.15)
					end
					for i, opt in ipairs(options) do
						local b = create("TextButton", {
							Parent = scroll, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, ITEM_H), LayoutOrder = i,
							Theme = { BackgroundColor3 = "Element" },
						}, { corner(6) })
						local barFrame = create("Frame", {
							Parent = b, BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(2, 14), BackgroundTransparency = 1,
						}, { corner(1), accentGradient(90) })
						local l = text({
							Parent = b, Text = tostring(opt), TextSize = 12, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -36, 1, 0),
							TextTruncate = Enum.TextTruncate.AtEnd, Theme = false, TextColor3 = T().SubText,
						})
						local check = Icon("check", 14, "Accent", {
							Parent = b, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), ImageTransparency = 1,
						})
						local item = { Value = opt, Button = b, Label = l, Check = check, Bar = barFrame }
						table.insert(items, item)
						paint(item, false)
						b.MouseEnter:Connect(function() if b.BackgroundTransparency > 0.5 then tween(l, { TextColor3 = T().Text }) end end)
						b.MouseLeave:Connect(function() paint(item, true) end)
						b.MouseButton1Click:Connect(function()
							if multi then
								selected[opt] = (not selected[opt]) or nil
							else
								selected = opt
							end
							for _, it in ipairs(items) do paint(it, true) end
							display()
							fire()
							if not multi then Window:_closePopup() end
						end)
					end
					if filterBox then
						filterBox:GetPropertyChangedSignal("Text"):Connect(function()
							local q = string.lower(filterBox.Text)
							for _, it in ipairs(items) do
								it.Button.Visible = q == "" or string.find(string.lower(tostring(it.Value)), q, 1, true) ~= nil
							end
						end)
					end
				end

				head.MouseEnter:Connect(function() tween(head, { BackgroundColor3 = T().ElementHover }) end)
				head.MouseLeave:Connect(function() tween(head, { BackgroundColor3 = T().Element }) end)
				head.MouseButton1Click:Connect(function()
					if open then Window:_closePopup() else openList() end
				end)

				function obj:Set(v, silent)
					if multi then
						selected = {}
						for _, opt in ipairs(type(v) == "table" and v or { v }) do selected[opt] = true end
					else
						selected = v
					end
					display()
					fire(silent)
				end
				function obj:Get() return values() end
				function obj:Refresh(newOptions, keep)
					options = newOptions or options
					if not keep then
						if multi then selected = {} else selected = nil end
					end
					if open then Window:_closePopup() end
					display()
					fire(true)
				end
				obj.SetOptions = obj.Refresh

				display()
				fire(true)
				return register("Dropdown", o, row, obj)
			end

			------------------------------------------------ keybind

			function Section:Keybind(o)
				local key = o.Default or Enum.KeyCode.Unknown
				local row = newRow(ROW_H)
				local title = titleBlock(row, o.Name or "Keybind", nil, 90)
				local pillBtn = text({
					Class = "TextButton", Parent = row, Text = "", AutoButtonColor = false, TextSize = 12, Weight = "Medium",
					TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(0, 24),
					AutomaticSize = Enum.AutomaticSize.X, Theme = { BackgroundColor3 = "Element", TextColor3 = "Text" },
				})
				corner(6).Parent = pillBtn
				padding(0, 10, 0, 10).Parent = pillBtn
				local pillStroke = stroke("Stroke")
				pillStroke.Parent = pillBtn
				create("UISizeConstraint", { Parent = pillBtn, MinSize = Vector2.new(40, 24) })

				local listening = false
				local obj = {}
				local function display()
					pillBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
				end
				function obj:Set(k)
					key = k or Enum.KeyCode.Unknown
					display()
					if o.Flag then OrcaHub.Flags[o.Flag] = key end
					safeCall(o.ChangedCallback, key)
				end
				function obj:Get() return key end

				pillBtn.MouseButton1Click:Connect(function()
					listening = true
					Window._capturing = true
					pillBtn.Text = "..."
					tween(pillStroke, { Color = T().Accent })
					tween(pillBtn, { TextColor3 = T().Accent })
				end)
				hoverTitle(pillBtn, title, function() return false end)
				track(UserInputService.InputBegan:Connect(function(input, processed)
					if listening then
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
						listening = false
						tween(pillStroke, { Color = T().Stroke })
						tween(pillBtn, { TextColor3 = T().Text })
						local k = input.KeyCode
						if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then k = Enum.KeyCode.Unknown end
						obj:Set(k)
						task.defer(function() Window._capturing = false end)
					elseif not processed and key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
						safeCall(o.Callback, key)
					end
				end))
				display()
				if o.Flag then OrcaHub.Flags[o.Flag] = key end
				return register("Keybind", o, row, obj)
			end

			------------------------------------------------ colour picker

			function Section:Colorpicker(o)
				local color = o.Default or T().Accent
				local h, s, v = color:ToHSV()
				local row = newRow(ROW_H)
				local title = titleBlock(row, o.Name or "Color", nil, 60)
				local swatch = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false, BackgroundColor3 = color,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(40, 22),
				}, { corner(6), stroke("StrokeLight") })
				hoverTitle(swatch, title, function() return false end)

				local obj = {}
				local listeners = {}
				function obj:Set(c, silent)
					color = c
					h, s, v = c:ToHSV()
					swatch.BackgroundColor3 = c
					for _, fn in ipairs(listeners) do fn() end
					if o.Flag then OrcaHub.Flags[o.Flag] = c end
					if not silent then safeCall(o.Callback, c) end
				end
				function obj:Get() return color end

				local function fromHSV(silent)
					local c = Color3.fromHSV(h, s, v)
					color = c
					swatch.BackgroundColor3 = c
					for _, fn in ipairs(listeners) do fn() end
					if o.Flag then OrcaHub.Flags[o.Flag] = c end
					if not silent then safeCall(o.Callback, c) end
				end

				swatch.MouseButton1Click:Connect(function()
					local W, H = 230, 196
					local frame, closeFrame = popupAt(swatch, W, H)
					Window:_openPopup({
						Close = function()
							listeners = {}
							closeFrame()
						end,
					})

					local sv = create("TextButton", {
						Parent = frame, Text = "", AutoButtonColor = false,
						Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(W - 46, 130),
						BackgroundColor3 = Color3.fromHSV(h, 1, 1),
					}, { corner(6) })
					create("Frame", {
						Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
					}, {
						corner(6),
						create("UIGradient", { Transparency = NumberSequence.new(0, 1) }),
					})
					create("Frame", {
						Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 2,
					}, {
						corner(6),
						create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }),
					})
					local svCursor = create("Frame", {
						Parent = sv, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 3,
						BackgroundTransparency = 1,
					}, { corner(6), create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })

					local keypoints = {}
					for i = 0, 6 do
						table.insert(keypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 == 1 and 0.999 or i / 6, 1, 1)))
					end
					local hue = create("TextButton", {
						Parent = frame, Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1),
						Position = UDim2.fromOffset(W - 28, 10), Size = UDim2.fromOffset(18, 130),
					}, { corner(6), create("UIGradient", { Rotation = 90, Color = ColorSequence.new(keypoints) }) })
					local hueCursor = create("Frame", {
						Parent = hue, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 4, 0, 5),
						BackgroundColor3 = Color3.new(1, 1, 1),
					}, { corner(3), create("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.6 }) })

					local preview = create("Frame", {
						Parent = frame, Position = UDim2.fromOffset(10, 150), Size = UDim2.fromOffset(36, 34),
						BackgroundColor3 = color,
					}, { corner(6), stroke("StrokeLight") })
					local hexBox = text({
						Class = "TextBox", Parent = frame, Text = "", ClearTextOnFocus = false, TextSize = 12,
						Position = UDim2.fromOffset(54, 150), Size = UDim2.new(1, -64, 0, 34), BackgroundTransparency = 0,
						Theme = { BackgroundColor3 = "Element", TextColor3 = "Text" },
					})
					corner(6).Parent = hexBox
					padding(0, 10, 0, 10).Parent = hexBox

					local function paint()
						sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						svCursor.Position = UDim2.fromScale(s, 1 - v)
						hueCursor.Position = UDim2.fromScale(0.5, h)
						preview.BackgroundColor3 = color
						if not hexBox:IsFocused() then hexBox.Text = "#" .. string.upper(color:ToHex()) end
					end
					table.insert(listeners, paint)
					paint()

					local function bindDrag(target, apply)
						target.InputBegan:Connect(function(input)
							if not isPress(input) then return end
							apply(vec2(input.Position))
							local touch = input.UserInputType == Enum.UserInputType.Touch
							local moveConn, endConn
							moveConn = track(UserInputService.InputChanged:Connect(function(i)
								if isMove(i, touch and input or nil) then apply(vec2(i.Position)) end
							end))
							endConn = track(UserInputService.InputEnded:Connect(function(i)
								if i == input or i.UserInputType == Enum.UserInputType.MouseButton1 then
									moveConn:Disconnect()
									endConn:Disconnect()
								end
							end))
						end)
					end
					bindDrag(sv, function(p)
						local rel = p - sv.AbsolutePosition
						s = math.clamp(rel.X / sv.AbsoluteSize.X, 0, 1)
						v = 1 - math.clamp(rel.Y / sv.AbsoluteSize.Y, 0, 1)
						fromHSV()
					end)
					bindDrag(hue, function(p)
						h = math.clamp((p.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
						fromHSV()
					end)
					hexBox.FocusLost:Connect(function()
						local ok, c = pcall(Color3.fromHex, (string.gsub(hexBox.Text, "#", "")))
						if ok and c then obj:Set(c) else paint() end
					end)
				end)

				if o.Flag then OrcaHub.Flags[o.Flag] = color end
				return register("Colorpicker", o, row, obj)
			end
			Section.ColorPicker = Section.Colorpicker

			return Section
		end

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then Tab:Select() end
		return Tab
	end

	---------------------------------------------------------------- settings tab

	function Window:CreateSettingsTab(o)
		o = o or {}
		local tab = self:Tab({ Name = o.Name or "Settings", Icon = o.Icon or "settings", Description = "Interface and configs" })
		local ui = tab:Section({ Name = "Interface", Side = "Left", Icon = "palette" })

		local themeNames = {}
		for name in pairs(OrcaHub.Themes) do table.insert(themeNames, name) end
		table.sort(themeNames)
		ui:Dropdown({
			Name = "Theme", Options = themeNames, Default = OrcaHub.ThemeName, Flag = "__OrcaTheme",
			Callback = function(v) OrcaHub:SetTheme(v) end,
		})
		ui:Slider({
			Name = "Interface Scale", Min = 60, Max = 140, Default = 100, Increment = 5, Suffix = "%", OnRelease = true,
			Flag = "__OrcaScale",
			Callback = function(v)
				Window.UserScale = v / 100
				Window:_updateScale()
			end,
		})
		ui:Keybind({
			Name = "Toggle Key", Default = Window.ToggleKey, Flag = "__OrcaToggleKey",
			ChangedCallback = function(k) Window:SetToggleKey(k) end,
		})
		ui:Toggle({
			Name = "Compact Sidebar", Default = Window.Compact,
			Callback = function(v) Window:SetCompact(v) end,
		})
		ui:Button({ Name = "Reset Section Layout", Icon = "rotate-ccw", Callback = function() Window:ResetLayout() end })

		local cfg = tab:Section({ Name = "Configs", Side = "Right", Icon = "folder" })
		if not hasFS() then
			cfg:Label("Your executor doesn't support saving files.")
			return tab
		end
		local nameInput = cfg:Input({ Name = "Config Name", Placeholder = "my-config", Icon = "type" })
		local list = cfg:Dropdown({ Name = "Saved Configs", Options = OrcaHub:ListConfigs() })
		list.NoSave = true

		local function chosen()
			local n = nameInput:Get()
			if n ~= "" then return n end
			return list:Get()
		end
		cfg:Button({
			Name = "Save Config", Icon = "save", Style = "Primary",
			Callback = function()
				local n = chosen()
				if not n then
					return OrcaHub:Notify({ Title = "Config", Content = "Enter a config name first.", Type = "Warning" })
				end
				OrcaHub:SaveConfig(n)
				list:Refresh(OrcaHub:ListConfigs())
				OrcaHub:Notify({ Title = "Config saved", Content = n, Type = "Success" })
			end,
		})
		cfg:Button({
			Name = "Load Config", Icon = "folder-open",
			Callback = function()
				local n = chosen()
				if n and OrcaHub:LoadConfig(n) then
					OrcaHub:Notify({ Title = "Config loaded", Content = n, Type = "Success" })
				else
					OrcaHub:Notify({ Title = "Config", Content = "Couldn't load that config.", Type = "Error" })
				end
			end,
		})
		cfg:Button({
			Name = "Delete Config", Icon = "trash-2",
			Callback = function()
				local n = chosen()
				if n and OrcaHub:DeleteConfig(n) then
					list:Refresh(OrcaHub:ListConfigs())
					OrcaHub:Notify({ Title = "Config deleted", Content = n })
				end
			end,
		})
		local autoLabel = cfg:Label("Autoload: " .. (OrcaHub:GetAutoload() or "none"))
		cfg:Button({
			Name = "Set As Autoload", Icon = "refresh-cw",
			Callback = function()
				local n = chosen()
				OrcaHub:SetAutoload(n)
				autoLabel:Set("Autoload: " .. (n or "none"))
			end,
		})
		return tab
	end

	---------------------------------------------------------------- teardown

	function Window:Destroy()
		if self.Destroyed then return end
		self.Destroyed = true
		for _, c in ipairs(self.Conns) do pcall(function() c:Disconnect() end) end
		self.Conns = {}
		for i = #Refreshers, 1, -1 do Refreshers[i] = nil end
		for inst in pairs(Themed) do Themed[inst] = nil end
		OrcaHub.Options = {}
		if OrcaHub.Window == self then OrcaHub.Window = nil end
		if env.__OrcaHubWindow == self then env.__OrcaHubWindow = nil end
		tween(uiScale, { Scale = self.Scale * 0.94 }, 0.2)
		tween(cover, { BackgroundTransparency = 0 }, 0.2)
		task.delay(0.22, function() gui:Destroy() end)
	end

	-- opening animation
	uiScale.Scale = Window.Scale * 0.94
	cover.BackgroundTransparency = 0
	tween(uiScale, { Scale = Window.Scale }, 0.5, Enum.EasingStyle.Back)
	tween(cover, { BackgroundTransparency = 1 }, 0.4)

	return Window
end

---------------------------------------------------------------- lucide icons (name -> asset id)
--@icons-begin
OrcaHub.Icons = {
	["accessibility"]=10709751939,["activity"]=10709752035,["air-vent"]=10709752131,["airplay"]=10709752254,
	["alarm-check"]=10709752405,["alarm-clock"]=10709752630,["alarm-clock-off"]=10709752508,
	["alarm-minus"]=10709752732,["alarm-plus"]=10709752825,["album"]=10709752906,["alert-circle"]=10709752996,
	["alert-octagon"]=10709753064,["alert-triangle"]=10709753149,["align-center"]=10709753570,
	["align-center-horizontal"]=10709753272,["align-center-vertical"]=10709753421,
	["align-end-horizontal"]=10709753692,["align-end-vertical"]=10709753808,
	["align-horizontal-distribute-center"]=10747779791,["align-horizontal-distribute-end"]=10747784534,
	["align-horizontal-distribute-start"]=10709754118,["align-horizontal-justify-center"]=10709754204,
	["align-horizontal-justify-end"]=10709754317,["align-horizontal-justify-start"]=10709754436,
	["align-horizontal-space-around"]=10709754590,["align-horizontal-space-between"]=10709754749,
	["align-justify"]=10709759610,["align-left"]=10709759764,["align-right"]=10709759895,
	["align-start-horizontal"]=10709760051,["align-start-vertical"]=10709760244,
	["align-vertical-distribute-center"]=10709760351,["align-vertical-distribute-end"]=10709760434,
	["align-vertical-distribute-start"]=10709760612,["align-vertical-justify-center"]=10709760814,
	["align-vertical-justify-end"]=10709761003,["align-vertical-justify-start"]=10709761176,
	["align-vertical-space-around"]=10709761324,["align-vertical-space-between"]=10709761434,
	["anchor"]=10709761530,["angry"]=10709761629,["annoyed"]=10709761722,["aperture"]=10709761813,
	["apple"]=10709761889,["archive"]=10709762233,["archive-restore"]=10709762058,["armchair"]=10709762327,
	["arrow-big-down"]=10747796644,["arrow-big-left"]=10709762574,["arrow-big-right"]=10709762727,
	["arrow-big-up"]=10709762879,["arrow-down"]=10709767827,["arrow-down-circle"]=10709763034,
	["arrow-down-left"]=10709767656,["arrow-down-right"]=10709767750,["arrow-left"]=10709768114,
	["arrow-left-circle"]=10709767936,["arrow-left-right"]=10709768019,["arrow-right"]=10709768347,
	["arrow-right-circle"]=10709768226,["arrow-up"]=10709768939,["arrow-up-circle"]=10709768432,
	["arrow-up-down"]=10709768538,["arrow-up-left"]=10709768661,["arrow-up-right"]=10709768787,
	["asterisk"]=10709769095,["at-sign"]=10709769286,["award"]=10709769406,["axe"]=10709769508,
	["axis-3d"]=10709769598,["baby"]=10709769732,["backpack"]=10709769841,["baggage-claim"]=10709769935,
	["banana"]=10709770005,["banknote"]=10709770178,["bar-chart"]=10709773755,["bar-chart-2"]=10709770317,
	["bar-chart-3"]=10709770431,["bar-chart-4"]=10709770560,["bar-chart-horizontal"]=10709773669,
	["barcode"]=10747360675,["baseline"]=10709773863,["bath"]=10709773963,["battery"]=10709774640,
	["battery-charging"]=10709774068,["battery-full"]=10709774206,["battery-low"]=10709774370,
	["battery-medium"]=10709774513,["beaker"]=10709774756,["bed"]=10709775036,["bed-double"]=10709774864,
	["bed-single"]=10709774968,["beer"]=10709775167,["bell"]=10709775704,["bell-minus"]=10709775241,
	["bell-off"]=10709775320,["bell-plus"]=10709775448,["bell-ring"]=10709775560,["bike"]=10709775894,
	["binary"]=10709776050,["bitcoin"]=10709776126,["bluetooth"]=10709776655,["bluetooth-connected"]=10709776240,
	["bluetooth-off"]=10709776344,["bluetooth-searching"]=10709776501,["bold"]=10747813908,["bomb"]=10709781460,
	["bone"]=10709781605,["book"]=10709781824,["book-open"]=10709781717,["bookmark"]=10709782154,
	["bookmark-minus"]=10709781919,["bookmark-plus"]=10709782044,["bot"]=10709782230,["box"]=10709782497,
	["box-select"]=10709782342,["boxes"]=10709782582,["briefcase"]=10709782662,["brush"]=10709782758,
	["bug"]=10709782845,["building"]=10709783051,["building-2"]=10709782939,["bus"]=10709783137,
	["cake"]=10709783217,["calculator"]=10709783311,["calendar"]=10709789505,["calendar-check"]=10709783474,
	["calendar-check-2"]=10709783392,["calendar-clock"]=10709783577,["calendar-days"]=10709783673,
	["calendar-heart"]=10709783835,["calendar-minus"]=10709783959,["calendar-off"]=10709788784,
	["calendar-plus"]=10709788937,["calendar-range"]=10709789053,["calendar-search"]=10709789200,
	["calendar-x"]=10709789407,["calendar-x-2"]=10709789329,["camera"]=10709789686,["camera-off"]=10747822677,
	["car"]=10709789810,["carrot"]=10709789960,["cast"]=10709790097,["charge"]=10709790202,["check"]=10709790644,
	["check-circle"]=10709790387,["check-circle-2"]=10709790298,["check-square"]=10709790537,
	["chef-hat"]=10709790757,["cherry"]=10709790875,["chevron-down"]=10709790948,["chevron-first"]=10709791015,
	["chevron-last"]=10709791130,["chevron-left"]=10709791281,["chevron-right"]=10709791437,
	["chevron-up"]=10709791523,["chevrons-down"]=10709796864,["chevrons-down-up"]=10709791632,
	["chevrons-left"]=10709797151,["chevrons-left-right"]=10709797006,["chevrons-right"]=10709797382,
	["chevrons-right-left"]=10709797274,["chevrons-up"]=10709797622,["chevrons-up-down"]=10709797508,
	["chrome"]=10709797725,["circle"]=10709798174,["circle-dot"]=10709797837,["circle-ellipsis"]=10709797985,
	["circle-slashed"]=10709798100,["citrus"]=10709798276,["clapperboard"]=10709798350,["clipboard"]=10709799288,
	["clipboard-check"]=10709798443,["clipboard-copy"]=10709798574,["clipboard-edit"]=10709798682,
	["clipboard-list"]=10709798792,["clipboard-signature"]=10709798890,["clipboard-type"]=10709798999,
	["clipboard-x"]=10709799124,["clock"]=10709805144,["clock-1"]=10709799535,["clock-10"]=10709799718,
	["clock-11"]=10709799818,["clock-12"]=10709799962,["clock-2"]=10709803876,["clock-3"]=10709803989,
	["clock-4"]=10709804164,["clock-5"]=10709804291,["clock-6"]=10709804435,["clock-7"]=10709804599,
	["clock-8"]=10709804784,["clock-9"]=10709804996,["cloud"]=10709806740,["cloud-cog"]=10709805262,
	["cloud-drizzle"]=10709805371,["cloud-fog"]=10709805477,["cloud-hail"]=10709805596,
	["cloud-lightning"]=10709805727,["cloud-moon"]=10709805942,["cloud-moon-rain"]=10709805838,
	["cloud-off"]=10709806060,["cloud-rain"]=10709806277,["cloud-rain-wind"]=10709806166,
	["cloud-snow"]=10709806374,["cloud-sun"]=10709806631,["cloud-sun-rain"]=10709806475,["cloudy"]=10709806859,
	["clover"]=10709806995,["code"]=10709810463,["code-2"]=10709807111,["codepen"]=10709810534,
	["codesandbox"]=10709810676,["coffee"]=10709810814,["cog"]=10709810948,["coins"]=10709811110,
	["columns"]=10709811261,["command"]=10709811365,["compass"]=10709811445,["component"]=10709811595,
	["concierge-bell"]=10709811706,["connection"]=10747361219,["contact"]=10709811834,["contrast"]=10709811939,
	["cookie"]=10709812067,["copy"]=10709812159,["copyleft"]=10709812251,["copyright"]=10709812311,
	["corner-down-left"]=10709812396,["corner-down-right"]=10709812485,["corner-left-down"]=10709812632,
	["corner-left-up"]=10709812784,["corner-right-down"]=10709812939,["corner-right-up"]=10709813094,
	["corner-up-left"]=10709813185,["corner-up-right"]=10709813281,["cpu"]=10709813383,["croissant"]=10709818125,
	["crop"]=10709818245,["cross"]=10709818399,["crosshair"]=10709818534,["crown"]=10709818626,
	["cup-soda"]=10709818763,["curly-braces"]=10709818847,["currency"]=10709818931,["database"]=10709818996,
	["delete"]=10709819059,["diamond"]=10709819149,["dice-1"]=10709819266,["dice-2"]=10709819361,
	["dice-3"]=10709819508,["dice-4"]=10709819670,["dice-5"]=10709819801,["dice-6"]=10709819896,
	["dices"]=10723343321,["diff"]=10723343416,["disc"]=10723343537,["divide"]=10723343805,
	["divide-circle"]=10723343636,["divide-square"]=10723343737,["dollar-sign"]=10723343958,
	["download"]=10723344270,["download-cloud"]=10723344088,["droplet"]=10723344432,["droplets"]=10734883356,
	["drumstick"]=10723344737,["edit"]=10734883598,["edit-2"]=10723344885,["edit-3"]=10723345088,
	["egg"]=10723345518,["egg-fried"]=10723345347,["electricity"]=10723345749,["electricity-off"]=10723345643,
	["equal"]=10723345990,["equal-not"]=10723345866,["eraser"]=10723346158,["euro"]=10723346372,
	["expand"]=10723346553,["external-link"]=10723346684,["eye"]=10723346959,["eye-off"]=10723346871,
	["factory"]=10723347051,["fan"]=10723354359,["fast-forward"]=10723354521,["feather"]=10723354671,
	["figma"]=10723354801,["file"]=10723374641,["file-archive"]=10723354921,["file-audio"]=10723355148,
	["file-audio-2"]=10723355026,["file-axis-3d"]=10723355272,["file-badge"]=10723355622,
	["file-badge-2"]=10723355451,["file-bar-chart"]=10723355887,["file-bar-chart-2"]=10723355746,
	["file-box"]=10723355989,["file-check"]=10723356210,["file-check-2"]=10723356100,["file-clock"]=10723356329,
	["file-code"]=10723356507,["file-cog"]=10723356830,["file-cog-2"]=10723356676,["file-diff"]=10723357039,
	["file-digit"]=10723357151,["file-down"]=10723357322,["file-edit"]=10723357495,["file-heart"]=10723357637,
	["file-image"]=10723357790,["file-input"]=10723357933,["file-json"]=10723364435,["file-json-2"]=10723364361,
	["file-key"]=10723364605,["file-key-2"]=10723364515,["file-line-chart"]=10723364725,["file-lock"]=10723364957,
	["file-lock-2"]=10723364861,["file-minus"]=10723365254,["file-minus-2"]=10723365086,
	["file-output"]=10723365457,["file-pie-chart"]=10723365598,["file-plus"]=10723365877,
	["file-plus-2"]=10723365766,["file-question"]=10723365987,["file-scan"]=10723366167,
	["file-search"]=10723366550,["file-search-2"]=10723366340,["file-signature"]=10723366741,
	["file-spreadsheet"]=10723366962,["file-symlink"]=10723367098,["file-terminal"]=10723367244,
	["file-text"]=10723367380,["file-type"]=10723367606,["file-type-2"]=10723367509,["file-up"]=10723367734,
	["file-video"]=10723373884,["file-video-2"]=10723367834,["file-volume"]=10723374172,
	["file-volume-2"]=10723374030,["file-warning"]=10723374276,["file-x"]=10723374544,["file-x-2"]=10723374378,
	["files"]=10723374759,["film"]=10723374981,["filter"]=10723375128,["fingerprint"]=10723375250,
	["flag"]=10723375890,["flag-off"]=10723375443,["flag-triangle-left"]=10723375608,
	["flag-triangle-right"]=10723375727,["flame"]=10723376114,["flashlight"]=10723376471,
	["flashlight-off"]=10723376365,["flask-conical"]=10734883986,["flask-round"]=10723376614,
	["flip-horizontal"]=10723376884,["flip-horizontal-2"]=10723376745,["flip-vertical"]=10723377138,
	["flip-vertical-2"]=10723377026,["flower"]=10747830374,["flower-2"]=10723377305,["focus"]=10723377537,
	["folder"]=10723387563,["folder-archive"]=10723384478,["folder-check"]=10723384605,
	["folder-clock"]=10723384731,["folder-closed"]=10723384893,["folder-cog"]=10723385213,
	["folder-cog-2"]=10723385036,["folder-down"]=10723385338,["folder-edit"]=10723385445,
	["folder-heart"]=10723385545,["folder-input"]=10723385721,["folder-key"]=10723385848,
	["folder-lock"]=10723386005,["folder-minus"]=10723386127,["folder-open"]=10723386277,
	["folder-output"]=10723386386,["folder-plus"]=10723386531,["folder-search"]=10723386787,
	["folder-search-2"]=10723386674,["folder-symlink"]=10723386930,["folder-tree"]=10723387085,
	["folder-up"]=10723387265,["folder-x"]=10723387448,["folders"]=10723387721,["form-input"]=10723387841,
	["forward"]=10723388016,["frame"]=10723394389,["framer"]=10723394565,["frown"]=10723394681,
	["fuel"]=10723394846,["function-square"]=10723395041,["gamepad"]=10723395457,["gamepad-2"]=10723395215,
	["gauge"]=10723395708,["gavel"]=10723395896,["gem"]=10723396000,["ghost"]=10723396107,["gift"]=10723396402,
	["gift-card"]=10723396225,["git-branch"]=10723396676,["git-branch-plus"]=10723396542,
	["git-commit"]=10723396812,["git-compare"]=10723396954,["git-fork"]=10723397049,["git-merge"]=10723397165,
	["git-pull-request"]=10723397431,["git-pull-request-closed"]=10723397268,
	["git-pull-request-draft"]=10734884302,["glass"]=10723397788,["glass-2"]=10723397529,
	["glass-water"]=10723397678,["glasses"]=10723397895,["globe"]=10723404337,["globe-2"]=10723398002,
	["grab"]=10723404472,["graduation-cap"]=10723404691,["grape"]=10723404822,["grid"]=10723404936,
	["grip-horizontal"]=10723405089,["grip-vertical"]=10723405236,["hammer"]=10723405360,["hand"]=10723405649,
	["hand-metal"]=10723405508,["hard-drive"]=10723405749,["hard-hat"]=10723405859,["hash"]=10723405975,
	["haze"]=10723406078,["headphones"]=10723406165,["heart"]=10723406885,["heart-crack"]=10723406299,
	["heart-handshake"]=10723406480,["heart-off"]=10723406662,["heart-pulse"]=10723406795,
	["help-circle"]=10723406988,["hexagon"]=10723407092,["highlighter"]=10723407192,["history"]=10723407335,
	["home"]=10723407389,["hourglass"]=10723407498,["ice-cream"]=10723414308,["image"]=10723415040,
	["image-minus"]=10723414487,["image-off"]=10723414677,["image-plus"]=10723414827,["import"]=10723415205,
	["inbox"]=10723415335,["indent"]=10723415494,["indian-rupee"]=10723415642,["infinity"]=10723415766,
	["info"]=10723415903,["inspect"]=10723416057,["italic"]=10723416195,["japanese-yen"]=10723416363,
	["joystick"]=10723416527,["key"]=10723416652,["keyboard"]=10723416765,["lamp"]=10723417513,
	["lamp-ceiling"]=10723416922,["lamp-desk"]=10723417016,["lamp-floor"]=10723417131,
	["lamp-wall-down"]=10723417240,["lamp-wall-up"]=10723417356,["landmark"]=10723417608,
	["languages"]=10723417703,["laptop"]=10723423881,["laptop-2"]=10723417797,["lasso"]=10723424235,
	["lasso-select"]=10723424058,["laugh"]=10723424372,["layers"]=10723424505,["layout"]=10723425376,
	["layout-dashboard"]=10723424646,["layout-grid"]=10723424838,["layout-list"]=10723424963,
	["layout-template"]=10723425187,["leaf"]=10723425539,["library"]=10723425615,["life-buoy"]=10723425685,
	["lightbulb"]=10723425852,["lightbulb-off"]=10723425762,["line-chart"]=10723426393,["link"]=10723426722,
	["link-2"]=10723426595,["link-2-off"]=10723426513,["list"]=10723433811,["list-checks"]=10734884548,
	["list-end"]=10723426886,["list-minus"]=10723426986,["list-music"]=10723427081,["list-ordered"]=10723427199,
	["list-plus"]=10723427334,["list-start"]=10723427494,["list-video"]=10723427619,["list-x"]=10723433655,
	["loader"]=10723434070,["loader-2"]=10723433935,["locate"]=10723434557,["locate-fixed"]=10723434236,
	["locate-off"]=10723434379,["lock"]=10723434711,["log-in"]=10723434830,["log-out"]=10723434906,
	["luggage"]=10723434993,["magnet"]=10723435069,["mail"]=10734885430,["mail-check"]=10723435182,
	["mail-minus"]=10723435261,["mail-open"]=10723435342,["mail-plus"]=10723435443,["mail-question"]=10723435515,
	["mail-search"]=10734884739,["mail-warning"]=10734885015,["mail-x"]=10734885247,["mails"]=10734885614,
	["map"]=10734886202,["map-pin"]=10734886004,["map-pin-off"]=10734885803,["maximize"]=10734886735,
	["maximize-2"]=10734886496,["medal"]=10734887072,["megaphone"]=10734887454,["megaphone-off"]=10734887311,
	["meh"]=10734887603,["menu"]=10734887784,["message-circle"]=10734888000,["message-square"]=10734888228,
	["mic"]=10734888864,["mic-2"]=10734888430,["mic-off"]=10734888646,["microscope"]=10734889106,
	["microwave"]=10734895076,["milestone"]=10734895310,["minimize"]=10734895698,["minimize-2"]=10734895530,
	["minus"]=10734896206,["minus-circle"]=10734895856,["minus-square"]=10734896029,["monitor"]=10734896881,
	["monitor-off"]=10734896360,["monitor-speaker"]=10734896512,["moon"]=10734897102,
	["more-horizontal"]=10734897250,["more-vertical"]=10734897387,["mountain"]=10734897956,
	["mountain-snow"]=10734897665,["mouse"]=10734898592,["mouse-pointer"]=10734898476,
	["mouse-pointer-2"]=10734898194,["mouse-pointer-click"]=10734898355,["move"]=10734900011,
	["move-3d"]=10734898756,["move-diagonal"]=10734899164,["move-diagonal-2"]=10734898934,
	["move-horizontal"]=10734899414,["move-vertical"]=10734899821,["music"]=10734905958,["music-2"]=10734900215,
	["music-3"]=10734905665,["music-4"]=10734905823,["navigation"]=10734906744,["navigation-2"]=10734906332,
	["navigation-2-off"]=10734906144,["navigation-off"]=10734906580,["network"]=10734906975,
	["newspaper"]=10734907168,["octagon"]=10734907361,["option"]=10734907649,["outdent"]=10734907933,
	["package"]=10734909540,["package-2"]=10734908151,["package-check"]=10734908384,["package-minus"]=10734908626,
	["package-open"]=10734908793,["package-plus"]=10734909016,["package-search"]=10734909196,
	["package-x"]=10734909375,["paint-bucket"]=10734909847,["paintbrush"]=10734910187,
	["paintbrush-2"]=10734910030,["palette"]=10734910430,["palmtree"]=10734910680,["paperclip"]=10734910927,
	["party-popper"]=10734918735,["pause"]=10734919336,["pause-circle"]=10735024209,["pause-octagon"]=10734919143,
	["pen-tool"]=10734919503,["pencil"]=10734919691,["percent"]=10734919919,["person-standing"]=10734920149,
	["phone"]=10734921524,["phone-call"]=10734920305,["phone-forwarded"]=10734920508,
	["phone-incoming"]=10734920694,["phone-missed"]=10734920845,["phone-off"]=10734921077,
	["phone-outgoing"]=10734921288,["pie-chart"]=10734921727,["piggy-bank"]=10734921935,["pin"]=10734922324,
	["pin-off"]=10734922180,["pipette"]=10734922497,["pizza"]=10734922774,["plane"]=10734922971,
	["play"]=10734923549,["play-circle"]=10734923214,["plus"]=10734924532,["plus-circle"]=10734923868,
	["plus-square"]=10734924219,["podcast"]=10734929553,["pointer"]=10734929723,["pound-sterling"]=10734929981,
	["power"]=10734930466,["power-off"]=10734930257,["printer"]=10734930632,["puzzle"]=10734930886,
	["quote"]=10734931234,["radio"]=10734931596,["radio-receiver"]=10734931402,
	["rectangle-horizontal"]=10734931777,["rectangle-vertical"]=10734932081,["recycle"]=10734932295,
	["redo"]=10734932822,["redo-2"]=10734932586,["refresh-ccw"]=10734933056,["refresh-cw"]=10734933222,
	["refrigerator"]=10734933465,["regex"]=10734933655,["repeat"]=10734933966,["repeat-1"]=10734933826,
	["reply"]=10734934252,["reply-all"]=10734934132,["rewind"]=10734934347,["rocket"]=10734934585,
	["rocking-chair"]=10734939942,["rotate-3d"]=10734940107,["rotate-ccw"]=10734940376,["rotate-cw"]=10734940654,
	["rss"]=10734940825,["ruler"]=10734941018,["russian-ruble"]=10734941199,["sailboat"]=10734941354,
	["save"]=10734941499,["scale"]=10734941912,["scale-3d"]=10734941739,["scaling"]=10734942072,
	["scan"]=10734942565,["scan-face"]=10734942198,["scan-line"]=10734942351,["scissors"]=10734942778,
	["screen-share"]=10734943193,["screen-share-off"]=10734942967,["scroll"]=10734943448,["search"]=10734943674,
	["send"]=10734943902,["separator-horizontal"]=10734944115,["separator-vertical"]=10734944326,
	["server"]=10734949856,["server-cog"]=10734944444,["server-crash"]=10734944554,["server-off"]=10734944668,
	["settings"]=10734950309,["settings-2"]=10734950020,["share"]=10734950813,["share-2"]=10734950553,
	["sheet"]=10734951038,["shield"]=10734951847,["shield-alert"]=10734951173,["shield-check"]=10734951367,
	["shield-close"]=10734951535,["shield-off"]=10734951684,["shirt"]=10734952036,["shopping-bag"]=10734952273,
	["shopping-cart"]=10734952479,["shovel"]=10734952773,["shower-head"]=10734952942,["shrink"]=10734953073,
	["shrub"]=10734953241,["shuffle"]=10734953451,["sidebar"]=10734954301,["sidebar-close"]=10734953715,
	["sidebar-open"]=10734954000,["sigma"]=10734954538,["signal"]=10734961133,["signal-high"]=10734954807,
	["signal-low"]=10734955080,["signal-medium"]=10734955336,["signal-zero"]=10734960878,["siren"]=10734961284,
	["skip-back"]=10734961526,["skip-forward"]=10734961809,["skull"]=10734962068,["slack"]=10734962339,
	["slash"]=10734962600,["slice"]=10734963024,["sliders"]=10734963400,["sliders-horizontal"]=10734963191,
	["smartphone"]=10734963940,["smartphone-charging"]=10734963671,["smile"]=10734964441,
	["smile-plus"]=10734964188,["snowflake"]=10734964600,["sofa"]=10734964852,["sort-asc"]=10734965115,
	["sort-desc"]=10734965287,["speaker"]=10734965419,["sprout"]=10734965572,["square"]=10734965702,
	["star"]=10734966248,["star-half"]=10734965897,["star-off"]=10734966097,["stethoscope"]=10734966384,
	["sticker"]=10734972234,["sticky-note"]=10734972463,["stop-circle"]=10734972621,
	["stretch-horizontal"]=10734972862,["stretch-vertical"]=10734973130,["strikethrough"]=10734973290,
	["subscript"]=10734973457,["sun"]=10734974297,["sun-dim"]=10734973645,["sun-medium"]=10734973778,
	["sun-moon"]=10734973999,["sun-snow"]=10734974130,["sunrise"]=10734974522,["sunset"]=10734974689,
	["superscript"]=10734974850,["swiss-franc"]=10734975024,["switch-camera"]=10734975214,["sword"]=10734975486,
	["swords"]=10734975692,["syringe"]=10734975932,["table"]=10734976230,["table-2"]=10734976097,
	["tablet"]=10734976394,["tag"]=10734976528,["tags"]=10734976739,["target"]=10734977012,["tent"]=10734981750,
	["terminal"]=10734982144,["terminal-square"]=10734981995,["text-cursor"]=10734982395,
	["text-cursor-input"]=10734982297,["thermometer"]=10734983134,["thermometer-snowflake"]=10734982571,
	["thermometer-sun"]=10734982771,["thumbs-down"]=10734983359,["thumbs-up"]=10734983629,["ticket"]=10734983868,
	["timer"]=10734984606,["timer-off"]=10734984138,["timer-reset"]=10734984355,["toggle-left"]=10734984834,
	["toggle-right"]=10734985040,["tornado"]=10734985247,["toy-brick"]=10747361919,["train"]=10747362105,
	["trash"]=10747362393,["trash-2"]=10747362241,["tree-deciduous"]=10747362534,["tree-pine"]=10747362748,
	["trees"]=10747363016,["trending-down"]=10747363205,["trending-up"]=10747363465,["triangle"]=10747363621,
	["trophy"]=10747363809,["truck"]=10747364031,["tv"]=10747364593,["tv-2"]=10747364302,["type"]=10747364761,
	["umbrella"]=10747364971,["underline"]=10747365191,["undo"]=10747365484,["undo-2"]=10747365359,
	["unlink"]=10747365771,["unlink-2"]=10747397871,["unlock"]=10747366027,["upload"]=10747366434,
	["upload-cloud"]=10747366266,["usb"]=10747366606,["user"]=10747373176,["user-check"]=10747371901,
	["user-cog"]=10747372167,["user-minus"]=10747372346,["user-plus"]=10747372702,["user-x"]=10747372992,
	["users"]=10747373426,["utensils"]=10747373821,["utensils-crossed"]=10747373629,["venetian-mask"]=10747374003,
	["verified"]=10747374131,["vibrate"]=10747374489,["vibrate-off"]=10747374269,["video"]=10747374938,
	["video-off"]=10747374721,["view"]=10747375132,["voicemail"]=10747375281,["volume"]=10747376008,
	["volume-1"]=10747375450,["volume-2"]=10747375679,["volume-x"]=10747375880,["wallet"]=10747376205,
	["wand"]=10747376565,["wand-2"]=10747376349,["watch"]=10747376722,["waves"]=10747376931,
	["webcam"]=10747381992,["wifi"]=10747382504,["wifi-off"]=10747382268,["wind"]=10747382750,
	["wrap-text"]=10747383065,["wrench"]=10747383470,["x"]=10747384394,["x-circle"]=10747383819,
	["x-octagon"]=10747384037,["x-square"]=10747384217,["zoom-in"]=10747384552,["zoom-out"]=10747384679,
}
--@icons-end

return OrcaHub
