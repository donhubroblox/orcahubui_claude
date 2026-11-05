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
	Version = "2.3.0",
	Flags = {},
	Options = {},
	Icons = {},
	Folder = "OrcaHub",
	FontFamily = "rbxasset://fonts/families/GothamSSm.json",
	IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	ThemeName = "Orca",
	_pending = {},
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
	Midnight = {
		Background = rgb(10, 10, 11), Sidebar = rgb(14, 14, 16), Section = rgb(18, 18, 21),
		Element = rgb(26, 26, 30), ElementHover = rgb(34, 34, 39),
		Stroke = rgb(36, 36, 41), StrokeLight = rgb(52, 52, 59),
		Text = rgb(240, 240, 243), SubText = rgb(155, 155, 165), DimText = rgb(98, 98, 108),
		Accent = rgb(229, 229, 234), Accent2 = rgb(160, 160, 172),
		ToggleOff = rgb(40, 40, 46), Knob = rgb(250, 250, 252),
	},
	Sakura = {
		Background = rgb(15, 10, 14), Sidebar = rgb(20, 13, 19), Section = rgb(25, 16, 23),
		Element = rgb(35, 23, 32), ElementHover = rgb(45, 30, 41),
		Stroke = rgb(48, 32, 44), StrokeLight = rgb(68, 46, 62),
		Text = rgb(250, 238, 246), SubText = rgb(186, 152, 175), DimText = rgb(122, 92, 112),
		Accent = rgb(244, 114, 182), Accent2 = rgb(192, 132, 252),
		ToggleOff = rgb(54, 37, 50), Knob = rgb(253, 246, 251),
	},
	Light = {
		Background = rgb(244, 245, 248), Sidebar = rgb(235, 237, 242), Section = rgb(255, 255, 255),
		Element = rgb(239, 241, 245), ElementHover = rgb(228, 231, 237),
		Stroke = rgb(221, 224, 231), StrokeLight = rgb(205, 209, 218),
		Text = rgb(20, 24, 32), SubText = rgb(82, 90, 104), DimText = rgb(138, 145, 158),
		Accent = rgb(37, 99, 235), Accent2 = rgb(14, 165, 233),
		ToggleOff = rgb(208, 212, 221), Knob = rgb(255, 255, 255),
	},
}

OrcaHub.Theme = { MainTransparency = 0, SidebarTransparency = 0, PanelTransparency = 0 }
for k, v in pairs(OrcaHub.Themes.Orca) do OrcaHub.Theme[k] = v end
local function T() return OrcaHub.Theme end

-- Mobile preview: set getgenv().OrcaHubMobilePreview = true (or "Portrait"/"Tablet") before loading
-- to see the mobile layout inside a simulated device on PC.
local PREVIEW
do
	local env0 = (type(getgenv) == "function" and getgenv()) or _G
	PREVIEW = env0.OrcaHubMobilePreview
	env0.OrcaHubMobilePreview = nil
	if PREVIEW then OrcaHub.IsMobile = true end
end
local PREVIEW_DEVICES = {
	{ Name = "Phone", Label = "Phone (landscape)", Size = Vector2.new(844, 390) },
	{ Name = "Portrait", Label = "Phone (portrait)", Size = Vector2.new(390, 780) },
	{ Name = "Tablet", Label = "Tablet", Size = Vector2.new(1000, 640) },
}

local MOBILE = OrcaHub.IsMobile
local ROW_H = MOBILE and 34 or 32
local BOX_H = MOBILE and 32 or 30
local TAB_H = MOBILE and 40 or 38
local ITEM_H = MOBILE and 32 or 28
local SIDEBAR_W, SIDEBAR_COMPACT = 200, 60
local TOPBAR_H = MOBILE and 50 or 58
local FOOTER_H = MOBILE and 24 or 28
local SECTION_HEADER = MOBILE and 40 or 42
local SUBTAB_H = 34
local PAD = MOBILE and 10 or 12
local GAP = MOBILE and 10 or 12
local SINGLE_COLUMN_BELOW = 540

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
	if type(theme) == "string" then self.ThemeName = theme end
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

local Corners = setmetatable({}, { __mode = "k" })
OrcaHub.CornerScale = 1

local function scaledRadius(r)
	if r >= 100 then return r end
	return math.floor(r * OrcaHub.CornerScale + 0.5)
end

local function corner(r)
	r = r or 8
	local c = create("UICorner", { CornerRadius = UDim.new(0, scaledRadius(r)) })
	Corners[c] = r
	return c
end

OrcaHub.Styles = {
	Default = { Corners = 1, Glass = false },
	Glass = { Corners = 1, Glass = true },
	Sharp = { Corners = 0.35, Glass = false },
	Soft = { Corners = 1.45, Glass = false },
}
OrcaHub.StyleName = "Default"

function OrcaHub:SetStyle(name)
	local style = self.Styles[name]
	if not style then return end
	self.StyleName = name
	self.CornerScale = style.Corners
	for c, r in pairs(Corners) do
		if c.Parent then c.CornerRadius = UDim.new(0, scaledRadius(r)) end
	end
	self:SetTheme({
		MainTransparency = style.Glass and 0.12 or 0,
		SidebarTransparency = style.Glass and 0.3 or 0,
		PanelTransparency = style.Glass and 0.22 or 0,
	})
	if self.Window and self.Window._updateBlur then self.Window:_updateBlur() end
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

local function protect(gui)
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	gui.Parent = guiParent()
end

local function viewport()
	if OrcaHub.PreviewSize then return OrcaHub.PreviewSize end
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function newScreenGui(order)
	local gui = create("ScreenGui", {
		Name = HttpService:GenerateGUID(false),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = order or 100,
	})
	protect(gui)
	return gui
end

---------------------------------------------------------------- shared pointer tracking
-- One InputChanged/InputEnded listener drives every drag (sliders, windows, sections, pickers).

local Pointer = { active = {}, conns = {} }

function Pointer.track(pressInput, onMove, onEnd)
	local id = {}
	Pointer.active[id] = {
		input = pressInput,
		touch = pressInput.UserInputType == Enum.UserInputType.Touch,
		move = onMove,
		done = onEnd,
	}
	return function() Pointer.active[id] = nil end
end

function Pointer.start()
	if #Pointer.conns > 0 then return end
	table.insert(Pointer.conns, UserInputService.InputChanged:Connect(function(input)
		local list = {}
		for _, d in pairs(Pointer.active) do list[#list + 1] = d end
		for _, d in ipairs(list) do
			local match = (d.touch and input == d.input) or (not d.touch and input.UserInputType == Enum.UserInputType.MouseMovement)
			if match and d.move then d.move(vec2(input.Position), input) end
		end
	end))
	table.insert(Pointer.conns, UserInputService.InputEnded:Connect(function(input)
		local ended = {}
		for id, d in pairs(Pointer.active) do
			if input == d.input or (not d.touch and input.UserInputType == Enum.UserInputType.MouseButton1) then
				ended[#ended + 1] = id
			end
		end
		for _, id in ipairs(ended) do
			local d = Pointer.active[id]
			Pointer.active[id] = nil
			if d and d.done then d.done(vec2(input.Position)) end
		end
	end))
end

function Pointer.stop()
	for _, c in ipairs(Pointer.conns) do c:Disconnect() end
	Pointer.conns = {}
	Pointer.active = {}
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
	if not hasFS() then return nil end
	local ok, data = pcall(function()
		if not isfile(path) then return nil end
		return HttpService:JSONDecode(readfile(path))
	end)
	return ok and data or nil
end

local function writeJSON(path, data)
	if not hasFS() then return false end
	return pcall(function()
		local folder = string.match(path, "^(.*)/[^/]+$")
		if folder then ensureFolder(folder) end
		writefile(path, HttpService:JSONEncode(data))
	end)
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

function OrcaHub:_configData()
	local data = {}
	for flag, option in pairs(self.Options) do
		if option.Get and not option.NoSave then data[flag] = serialize(option:Get()) end
	end
	return data
end

function OrcaHub:_applyConfig(data)
	if type(data) ~= "table" then return false end
	for flag, value in pairs(data) do
		local option = self.Options[flag]
		if option and option.Set then
			pcall(function() option:Set(deserialize(value)) end)
		else
			self._pending[flag] = value
		end
	end
	return true
end

function OrcaHub:SaveConfig(name)
	if not hasFS() or not name or name == "" then return false end
	return writeJSON(self:_configFolder() .. "/" .. name .. ".json", self:_configData())
end

function OrcaHub:LoadConfig(name)
	return self:_applyConfig(readJSON(self:_configFolder() .. "/" .. tostring(name) .. ".json"))
end

-- share settings as text (e.g. through the clipboard)
function OrcaHub:ExportConfig()
	return HttpService:JSONEncode(self:_configData())
end

function OrcaHub:ImportConfig(json)
	local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
	return ok and self:_applyConfig(data) or false
end

function OrcaHub:DeleteConfig(name)
	local path = self:_configFolder() .. "/" .. tostring(name) .. ".json"
	if type(delfile) == "function" and hasFS() and isfile(path) then
		delfile(path)
		return true
	end
	return false
end

function OrcaHub:ListConfigs()
	local out = {}
	if type(listfiles) ~= "function" or not hasFS() then return out end
	local folder = self:_configFolder()
	pcall(ensureFolder, folder)
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
	pcall(function()
		ensureFolder(self:_configFolder())
		writefile(self:_configFolder() .. "/autoload.txt", name or "")
	end)
end

function OrcaHub:GetAutoload()
	local path = self:_configFolder() .. "/autoload.txt"
	local ok, name = pcall(function()
		if hasFS() and isfile(path) then return readfile(path) end
	end)
	if ok and name and name ~= "" then return name end
	return nil
end

function OrcaHub:LoadAutoloadConfig()
	local name = self:GetAutoload()
	if name then return self:LoadConfig(name) end
	return false
end

---------------------------------------------------------------- notifications

local notifyCounter = 0

function OrcaHub:Notify(o)
	o = o or {}
	local window = self.Window
	if not window or not window.NotifyHolder then
		warn("[OrcaHub] Notify called before CreateWindow")
		return
	end
	local status = STATUS[o.Type or "Info"] or STATUS.Info
	local duration = o.Duration or 4
	notifyCounter = notifyCounter + 1

	local wrapper = create("Frame", {
		Parent = window.NotifyHolder, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = notifyCounter,
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
	local close
	if o.Buttons then
		local brow = create("Frame", { Parent = inner, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 3 }, {
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		for i, b in ipairs(o.Buttons) do
			local btn = text({
				Class = "TextButton", Parent = brow, Text = b.Title or "OK", TextSize = 12, Weight = "Medium", AutoButtonColor = false,
				TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1, 1, 1), LayoutOrder = i,
				Theme = (not b.Primary) and { BackgroundColor3 = "Element", TextColor3 = "Text" } or false,
				TextColor3 = Color3.new(1, 1, 1),
			})
			corner(6).Parent = btn
			padding(0, 10, 0, 10).Parent = btn
			if b.Primary then accentGradient(0).Parent = btn else stroke("StrokeLight").Parent = btn end
			btn.MouseButton1Click:Connect(function()
				safeCall(b.Callback)
				task.spawn(function() close() end)
			end)
		end
	end
	local progress = create("Frame", {
		Parent = card, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2),
	})
	if status.Color then progress.BackgroundColor3 = status.Color else accentGradient(0).Parent = progress end

	tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.45, Enum.EasingStyle.Back)
	tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	local closed = false
	close = function()
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

---------------------------------------------------------------- key system

function OrcaHub:KeySystem(o)
	o = o or {}
	local savePath = self.Folder .. "/" .. (o.FileName or "key") .. ".txt"
	local function valid(key)
		key = tostring(key or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if key == "" then return false end
		if o.Validate then
			local ok, result = pcall(o.Validate, key)
			return ok and result == true
		end
		for _, k in ipairs(o.Keys or {}) do
			if k == key then return true end
		end
		return false
	end

	if o.SaveKey ~= false and hasFS() then
		local ok, saved = pcall(function() return isfile(savePath) and readfile(savePath) end)
		if ok and saved and valid(saved) then return true end
	end

	local gui = newScreenGui(200)
	local backdrop = create("Frame", {
		Parent = gui, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
	})
	local card = create("Frame", {
		Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(360, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Theme = { BackgroundColor3 = "Section" },
	}, { corner(14), padding(22, 22, 22, 22) })
	local cardStroke = stroke("StrokeLight")
	cardStroke.Parent = card
	local cardScale = create("UIScale", { Parent = card, Scale = 0.9 })
	create("UIListLayout", { Parent = card, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })

	local head = create("Frame", { Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1 })
	local logo = create("Frame", {
		Parent = head, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(40, 40),
	}, { corner(11), accentGradient(45) })
	Icon(o.Icon or "key", 20, nil, {
		Parent = logo, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = Color3.new(1, 1, 1),
	})
	text({ Parent = head, Text = o.Title or "OrcaHub", Weight = "Bold", TextSize = 16, Position = UDim2.fromOffset(52, 2), Size = UDim2.new(1, -52, 0, 20) })
	text({
		Parent = head, Text = o.Subtitle or "Key System", TextSize = 12, Position = UDim2.fromOffset(52, 22), Size = UDim2.new(1, -52, 0, 16),
		Theme = { TextColor3 = "DimText" },
	})
	if o.Note then
		text({
			Parent = card, Text = o.Note, TextSize = 12, TextWrapped = true, LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Theme = { TextColor3 = "SubText" },
		})
	end
	local boxFrame = create("Frame", {
		Parent = card, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = 3, Theme = { BackgroundColor3 = "Element" },
	}, { corner(8) })
	local boxStroke = stroke("Stroke")
	boxStroke.Parent = boxFrame
	local input = text({
		Class = "TextBox", Parent = boxFrame, Text = "", PlaceholderText = "Paste your key here", ClearTextOnFocus = false,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "Text", PlaceholderColor3 = "DimText" },
	})
	local status = text({
		Parent = card, Text = "", TextSize = 12, LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 14), Visible = false,
		Theme = { TextColor3 = "SubText" },
	})
	local row = create("Frame", { Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 5 }, {
		create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local function button(label, primary, order)
		local b = text({
			Class = "TextButton", Parent = row, Text = label, Weight = "Medium", AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(o.KeyLink and 0.5 or 1, o.KeyLink and -4 or 0, 1, 0),
			BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1, 1, 1), LayoutOrder = order,
			Theme = (not primary) and { BackgroundColor3 = "Element", TextColor3 = "Text" } or false,
			TextColor3 = Color3.new(1, 1, 1),
		})
		corner(8).Parent = b
		if primary then accentGradient(0).Parent = b else stroke("StrokeLight").Parent = b end
		return b
	end
	local getKey = o.KeyLink and button("Get Key", false, 1)
	local submit = button("Submit", true, 2)

	tween(backdrop, { BackgroundTransparency = 0.4 }, 0.3)
	tween(cardScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)

	local result
	local function say(msg, color)
		status.Visible = true
		status.Text = msg
		status.TextColor3 = color or T().SubText
	end
	if getKey then
		getKey.MouseButton1Click:Connect(function()
			local copied = pcall(function() setclipboard(o.KeyLink) end)
			say(copied and "Key link copied to your clipboard." or ("Get your key at: " .. o.KeyLink), T().Accent)
		end)
	end
	local function try()
		if valid(input.Text) then
			if o.SaveKey ~= false and hasFS() then
				pcall(function()
					ensureFolder(OrcaHub.Folder)
					writefile(savePath, input.Text)
				end)
			end
			say("Key accepted!", rgb(74, 222, 128))
			tween(cardStroke, { Color = rgb(74, 222, 128) }, 0.2)
			task.wait(0.5)
			result = true
		else
			say("Invalid key, try again.", rgb(248, 113, 113))
			tween(cardStroke, { Color = rgb(248, 113, 113) }, 0.15)
			local base = card.Position
			for _, dx in ipairs({ -8, 8, -5, 5, 0 }) do
				card.Position = base + UDim2.fromOffset(dx, 0)
				task.wait(0.04)
			end
			card.Position = base
			task.delay(0.6, function() if result == nil then tween(cardStroke, { Color = T().StrokeLight }, 0.3) end end)
		end
	end
	submit.MouseButton1Click:Connect(function() task.spawn(try) end)
	input.FocusLost:Connect(function(enter) if enter then task.spawn(try) end end)
	input.Focused:Connect(function() tween(boxStroke, { Color = T().Accent }) end)
	input.FocusLost:Connect(function() tween(boxStroke, { Color = T().Stroke }) end)

	while result == nil do task.wait(0.05) end
	tween(cardScale, { Scale = 0.9 }, 0.2)
	tween(backdrop, { BackgroundTransparency = 1 }, 0.2)
	task.wait(0.2)
	gui:Destroy()
	return result
end

---------------------------------------------------------------- mobile preview device

local function buildPreview(window, gui, choice)
	local deviceIndex = 1
	for i, d in ipairs(PREVIEW_DEVICES) do
		if d.Name == choice then deviceIndex = i end
	end
	local device = PREVIEW_DEVICES[deviceIndex]
	OrcaHub.PreviewSize = device.Size

	create("Frame", {
		Parent = gui, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35,
	})
	local bezel = create("Frame", {
		Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 22),
		Size = UDim2.fromOffset(device.Size.X + 24, device.Size.Y + 24), BackgroundColor3 = rgb(8, 8, 10),
	}, { corner(38), create("UIStroke", { Color = rgb(60, 62, 70), Thickness = 2 }) })
	local screen = create("Frame", {
		Parent = bezel, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(device.Size.X, device.Size.Y), ClipsDescendants = true,
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, {
		corner(26),
		create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, rgb(110, 170, 230)),
				ColorSequenceKeypoint.new(0.55, rgb(170, 210, 240)),
				ColorSequenceKeypoint.new(0.56, rgb(96, 160, 80)),
				ColorSequenceKeypoint.new(1, rgb(70, 125, 60)),
			}),
		}),
	})

	local bar = create("Frame", {
		Parent = gui, AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 22 - (device.Size.Y + 24) / 2 - 10), Size = UDim2.fromOffset(700, 34),
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local caption = text({
		Parent = bar, Text = "", Weight = "SemiBold", TextSize = 13, LayoutOrder = 0, Theme = false,
		TextColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X,
	})
	local buttons = {}
	local function pill(label, order, onClick)
		local b = text({
			Class = "TextButton", Parent = bar, Text = label, TextSize = 12, Weight = "Medium", AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = order, Theme = false,
			BackgroundTransparency = 0, BackgroundColor3 = rgb(30, 33, 40), TextColor3 = rgb(220, 225, 235),
			Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X,
		})
		corner(14).Parent = b
		padding(0, 12, 0, 12).Parent = b
		b.MouseButton1Click:Connect(onClick)
		return b
	end

	local function apply(index)
		deviceIndex = index
		device = PREVIEW_DEVICES[index]
		OrcaHub.PreviewSize = device.Size
		caption.Text = "Mobile preview: " .. device.Label .. "  " .. device.Size.X .. "x" .. device.Size.Y .. "   "
		bezel.Size = UDim2.fromOffset(device.Size.X + 24, device.Size.Y + 24)
		screen.Size = UDim2.fromOffset(device.Size.X, device.Size.Y)
		bar.Position = UDim2.new(0.5, 0, 0.5, 22 - (device.Size.Y + 24) / 2 - 10)
		for i, b in ipairs(buttons) do
			b.BackgroundColor3 = i == index and OrcaHub.Theme.Accent or rgb(30, 33, 40)
		end
		if window._updateScale then
			window:_updateScale()
			for _, tab in ipairs(window.Tabs) do tab:_relayout(false) end
			task.defer(function() if window._moveIndicator then window:_moveIndicator(false) end end)
		end
	end
	for i, d in ipairs(PREVIEW_DEVICES) do
		buttons[i] = pill(d.Name, i, function() apply(i) end)
	end
	pill("Close preview", 10, function() if window.Destroy then window:Destroy() end end)
	apply(deviceIndex)
	return screen
end

---------------------------------------------------------------- window

function OrcaHub:CreateWindow(opts)
	opts = opts or {}
	local env = (type(getgenv) == "function" and getgenv()) or _G
	if env.__OrcaHubWindow then pcall(function() env.__OrcaHubWindow:Destroy(true) end) end

	if opts.Theme then self:SetTheme(opts.Theme) end
	if opts.Folder then self.Folder = opts.Folder end
	if opts.ConfigKey then self.ConfigKey = opts.ConfigKey end

	local Window = {
		Tabs = {},
		Conns = {},
		Keybinds = {},
		Visible = true,
		UserScale = 1,
		Scale = 1,
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
		Compact = opts.Compact,
		Accordion = opts.Accordion == true,
		SectionsCollapsed = opts.SectionsCollapsed,
		LayoutPath = self.Folder .. "/layouts/" .. tostring(opts.ConfigKey or game.PlaceId) .. ".json",
	}
	if Window.Compact == nil then Window.Compact = MOBILE end
	if Window.SectionsCollapsed == nil then Window.SectionsCollapsed = MOBILE end
	Window.SavedLayout = readJSON(Window.LayoutPath) or {}
	self.Window = Window
	env.__OrcaHubWindow = Window

	local function track(conn)
		table.insert(Window.Conns, conn)
		return conn
	end
	Window._track = track
	Pointer.start()

	local function autoSize()
		local vp = viewport()
		return Vector2.new(math.clamp(vp.X - 24, 320, 900), math.clamp(vp.Y - 24, 260, 560))
	end
	local size = opts.Size or (MOBILE and autoSize() or Vector2.new(780, 500))
	if typeof(size) == "UDim2" then size = Vector2.new(size.X.Offset, size.Y.Offset) end
	Window.Size = size
	Window.AutoSize = MOBILE and opts.Size == nil

	local gui = newScreenGui(100)
	Window.Gui = gui
	local screen = gui
	if PREVIEW then screen = buildPreview(Window, gui, PREVIEW) end
	Window.Screen = screen

	Window.NotifyHolder = create("Frame", {
		Parent = screen, BackgroundTransparency = 1, ZIndex = 20,
		AnchorPoint = MOBILE and Vector2.new(1, 0) or Vector2.new(1, 1),
		Position = MOBILE and UDim2.new(1, -12, 0, 12) or UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, MOBILE and 260 or 300, 1, -32),
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = MOBILE and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom,
		}),
	})

	---------------------------------------------------------------- shell

	local holder = create("Frame", {
		Parent = screen, BackgroundTransparency = 1,
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
		Theme = { BackgroundColor3 = "Background", BackgroundTransparency = "MainTransparency" },
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

	-- overlay for popups, dialogs and tooltips
	local overlay = create("Frame", { Parent = main, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 40 })
	local catcher = create("TextButton", {
		Parent = overlay, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), Visible = false,
	})
	Window.Overlay = overlay
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
	function Window:_repositionPopup()
		if activePopup and activePopup.Reposition then activePopup.Reposition() end
	end
	catcher.MouseButton1Click:Connect(function() Window:_closePopup() end)

	function Window:_toMain(absPos)
		return (absPos - main.AbsolutePosition) / self.Scale
	end

	-- element tooltips
	local tipBubble = text({
		Parent = overlay, Text = "", TextSize = 12, Visible = false, ZIndex = 9, TextWrapped = true,
		Size = UDim2.fromOffset(220, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0,
		Theme = { BackgroundColor3 = "Element", TextColor3 = "SubText" },
	})
	corner(6).Parent = tipBubble
	stroke("StrokeLight").Parent = tipBubble
	padding(7, 10, 7, 10).Parent = tipBubble
	local tipToken = 0
	function Window:_showTip(anchor, message)
		tipToken = tipToken + 1
		local token = tipToken
		tipBubble.Text = message
		local pos = self:_toMain(anchor.AbsolutePosition)
		local mainW = main.AbsoluteSize.X / self.Scale
		tipBubble.Position = UDim2.fromOffset(math.clamp(pos.X - 100, 8, mainW - 228), pos.Y + anchor.AbsoluteSize.Y / self.Scale + 6)
		tipBubble.Visible = true
		tipBubble.TextTransparency = 1
		tipBubble.BackgroundTransparency = 1
		tween(tipBubble, { TextTransparency = 0, BackgroundTransparency = 0 }, 0.15)
		if MOBILE then
			task.delay(3, function() if tipToken == token then tipBubble.Visible = false end end)
		end
	end
	function Window:_hideTip() tipBubble.Visible = false end

	---------------------------------------------------------------- sidebar

	local sidebarW = Window.Compact and SIDEBAR_COMPACT or SIDEBAR_W
	local sidebar = create("Frame", {
		Parent = main, Size = UDim2.new(0, sidebarW, 1, 0), ClipsDescendants = true,
		Theme = { BackgroundColor3 = "Sidebar", BackgroundTransparency = "SidebarTransparency" },
	}, { corner(12) })
	local sideFiller = create("Frame", {
		Parent = sidebar, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 12, 1, 0),
		Theme = { BackgroundColor3 = "Sidebar", BackgroundTransparency = function(t) return t.SidebarTransparency > 0 and 1 or 0 end },
	})
	local sideLine = create("Frame", {
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
		TextTransparency = Window.Compact and 1 or 0,
	})
	local brandSub = text({
		Parent = brand, Text = opts.Subtitle or ("v" .. OrcaHub.Version), TextSize = 11,
		Position = UDim2.new(0, 56, 0.5, 3), Size = UDim2.new(1, -64, 0, 14),
		Theme = { TextColor3 = "DimText" }, TextTransparency = Window.Compact and 1 or 0,
	})
	create("Frame", {
		Parent = brand, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Stroke" },
	})

	local profileH = (opts.ShowProfile == false or MOBILE) and 0 or 60
	local tabArea = create("Frame", {
		Parent = sidebar, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, TOPBAR_H), Size = UDim2.new(1, -1, 1, -TOPBAR_H - profileH),
	})
	local pill = create("Frame", {
		Parent = tabArea, Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, TAB_H),
		Visible = false, Theme = { BackgroundColor3 = "Element" },
	}, { corner(8), stroke("Stroke") })
	local pillBar = create("Frame", {
		Parent = pill, BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 18),
	}, { corner(2), accentGradient(90) })

	local tabLayout = create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
	local tabList = create("ScrollingFrame", {
		Parent = tabArea, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
		Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, { tabLayout, padding(8, 8, 8, 8) })
	local fadeLabels = { brandTitle, brandSub }
	function Window:SetTitle(t) brandTitle.Text = t end
	function Window:SetSubtitle(t) brandSub.Text = t end

	local profile
	if profileH > 0 then
		profile = create("Frame", {
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
			if ok and avatar.Parent then avatar.Image = img end
		end)
		local display = text({
			Parent = profile, Text = LocalPlayer.DisplayName, Weight = "Medium", TextSize = 13,
			Position = UDim2.new(0, 56, 0.5, -15), Size = UDim2.new(1, -64, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd,
			TextTransparency = Window.Compact and 1 or 0,
		})
		local username = text({
			Parent = profile, Text = "@" .. LocalPlayer.Name, TextSize = 11,
			Position = UDim2.new(0, 56, 0.5, 2), Size = UDim2.new(1, -64, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd,
			Theme = { TextColor3 = "DimText" }, TextTransparency = Window.Compact and 1 or 0,
		})
		table.insert(fadeLabels, display)
		table.insert(fadeLabels, username)
	end

	---------------------------------------------------------------- content area

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
		Position = UDim2.fromOffset(52, 11), Size = UDim2.new(1, -370, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local pageDesc = text({
		Parent = topbar, Text = "", TextSize = 12,
		Position = UDim2.fromOffset(52, 31), Size = UDim2.new(1, -370, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "DimText" }, Visible = not MOBILE,
	})

	local closeBtn = iconButton("x", UDim2.new(1, -42, 0.5, 0), rgb(248, 113, 113))
	local minBtn = iconButton("minus", UDim2.new(1, -76, 0.5, 0))
	local maxBtn = iconButton("maximize-2", UDim2.new(1, -110, 0.5, 0))
	local maxIcon = maxBtn:FindFirstChildOfClass("ImageLabel")

	local searchW = MOBILE and 150 or 210
	local search = create("Frame", {
		Parent = topbar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -120, 0.5, 0),
		Size = UDim2.fromOffset(searchW, 32), Theme = { BackgroundColor3 = "Element" }, ClipsDescendants = true,
	}, { corner(8) })
	local searchStroke = stroke("Stroke")
	searchStroke.Parent = search
	Icon("search", 14, "DimText", { Parent = search, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
	local searchBox = text({
		Class = "TextBox", Parent = search, Text = "", PlaceholderText = "Search all tabs...", ClearTextOnFocus = false,
		Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0),
		Theme = { TextColor3 = "Text", PlaceholderColor3 = "DimText" },
	})
	searchBox.Focused:Connect(function() tween(searchStroke, { Color = T().Accent }) end)
	searchBox.FocusLost:Connect(function() tween(searchStroke, { Color = T().Stroke }) end)
	local clearSearch = create("TextButton", {
		Parent = search, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Visible = false,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(22, 22),
	})
	Icon("x", 13, "DimText", { Parent = clearSearch, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	clearSearch.MouseButton1Click:Connect(function() searchBox.Text = "" end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		clearSearch.Visible = searchBox.Text ~= ""
		searchBox.Size = UDim2.new(1, searchBox.Text ~= "" and -60 or -40, 1, 0)
	end)

	-- on narrow windows the search box shrinks to an icon that expands over the title when tapped
	local searchOpen = create("TextButton", {
		Parent = search, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Visible = false, ZIndex = 3,
		Size = UDim2.fromScale(1, 1),
	})
	local searchCollapsed, searchExpanded = false, false
	local function layoutSearch(animate)
		local width = searchW
		if searchCollapsed then
			width = searchExpanded and math.max(140, content.AbsoluteSize.X / Window.Scale - 136) or 32
		end
		set(search, { Size = UDim2.fromOffset(width, 32) }, animate, 0.25)
		searchBox.Visible = not searchCollapsed or searchExpanded
		searchOpen.Visible = searchCollapsed and not searchExpanded
		pageTitle.Visible = not searchExpanded
		pageDesc.Visible = not MOBILE and not searchExpanded
	end
	searchOpen.MouseButton1Click:Connect(function()
		searchExpanded = true
		layoutSearch(true)
		searchBox:CaptureFocus()
	end)
	function Window:_focusSearch()
		if searchCollapsed then
			searchExpanded = true
			layoutSearch(true)
		end
		searchBox:CaptureFocus()
	end
	searchBox.FocusLost:Connect(function()
		if searchCollapsed and searchBox.Text == "" then
			searchExpanded = false
			layoutSearch(true)
		end
	end)
	function Window:_setSearchCollapsed(v)
		if v == searchCollapsed then return end
		searchCollapsed = v
		if not v then searchExpanded = false end
		layoutSearch(false)
	end
	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		Window:_setSearchCollapsed(content.AbsoluteSize.X / Window.Scale < 500)
	end)

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
		if self.AutoSize then
			self.Size = autoSize()
			holder.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
		end
		local vp = viewport()
		local fit = math.min(1, (vp.X - 24) / (self.Size.X * self.UserScale), (vp.Y - 24) / (self.Size.Y * self.UserScale))
		self.Scale = math.max(0.4, fit) * self.UserScale
		uiScale.Scale = self.Scale
		if self._applyNav then self:_applyNav() end
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

	local MIN_W, MIN_H = MOBILE and 320 or 520, MOBILE and 250 or 340

	local function clampSize(w, h)
		local vp = viewport()
		local sc = Window.Scale
		return math.clamp(w, MIN_W, math.max(MIN_W, (vp.X - 24) / sc)), math.clamp(h, MIN_H, math.max(MIN_H, (vp.Y - 24) / sc))
	end

	function Window:_saveWindow()
		if PREVIEW then return end
		self.SavedLayout.__window = {
			w = self.Size.X, h = self.Size.Y, x = holder.Position.X.Offset, y = holder.Position.Y.Offset,
			auto = self.AutoSize, max = self.Maximized,
		}
		if self.SaveLayout then self:SaveLayout() end
	end

	function Window:SetSize(sz, animate)
		if typeof(sz) == "UDim2" then sz = Vector2.new(sz.X.Offset, sz.Y.Offset) end
		self.AutoSize = false
		self.Maximized = false
		maxIcon.Image = iconImage("maximize-2")
		local w, h = clampSize(sz.X, sz.Y)
		self.Size = Vector2.new(w, h)
		set(holder, { Size = UDim2.fromOffset(w, h), Position = UDim2.new(0.5, 0, 0.5, 0) }, animate, 0.35)
		task.delay(animate and 0.37 or 0, function()
			self:_updateScale()
			self:_saveWindow()
		end)
	end

	function Window:SetAutoSize()
		self.AutoSize = true
		self.Maximized = false
		self.Size = autoSize()
		tween(holder, { Size = UDim2.fromOffset(self.Size.X, self.Size.Y), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.35)
		task.delay(0.37, function()
			self:_updateScale()
			self:_saveWindow()
		end)
	end

	function Window:ToggleMaximize()
		if self.Maximized and self._restore then
			local r = self._restore
			self.Maximized = false
			self.Size = r.size
			tween(holder, { Size = UDim2.fromOffset(r.size.X, r.size.Y), Position = r.pos }, 0.35)
		else
			self._restore = { size = self.Size, pos = holder.Position }
			self.Maximized = true
			local vp = viewport()
			self.Size = Vector2.new(math.max(MIN_W, (vp.X - 24) / self.UserScale), math.max(MIN_H, (vp.Y - 24) / self.UserScale))
			tween(holder, { Size = UDim2.fromOffset(self.Size.X, self.Size.Y), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.35)
		end
		self.AutoSize = false
		maxIcon.Image = iconImage(self.Maximized and "minimize-2" or "maximize-2")
		task.delay(0.37, function()
			self:_updateScale()
			self:_saveWindow()
		end)
	end
	maxBtn.MouseButton1Click:Connect(function() Window:ToggleMaximize() end)

	-- drag the window by its title bar; double-click (or double-tap) it to maximize
	local lastTap = 0
	local function dragWindowFrom(handle)
		handle.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			local start = vec2(input.Position)
			local startPos = holder.Position
			local moved = false
			Window:_closePopup()
			Pointer.track(input, function(pos)
				local d = pos - start
				if d.Magnitude > 4 then moved = true end
				if not moved then return end
				local x, y = clampPosition(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
				holder.Position = UDim2.new(0.5, x, 0.5, y)
			end, function()
				if moved then
					Window:_saveWindow()
					return
				end
				local now = os.clock()
				if now - lastTap < 0.35 then
					lastTap = 0
					Window:ToggleMaximize()
				else
					lastTap = now
				end
			end)
		end)
	end
	dragWindowFrom(topbar)
	dragWindowFrom(brand)

	-- resize from any edge or corner
	local function resizeFrom(handle, dir)
		handle.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			local start = vec2(input.Position)
			local startSize, startPos = Window.Size, holder.Position
			Window.AutoSize = false
			Window.Maximized = false
			maxIcon.Image = iconImage("maximize-2")
			Window:_closePopup()
			Pointer.track(input, function(pos)
				local d = (pos - start) / Window.Scale
				local w, h = clampSize(startSize.X + d.X * dir.X, startSize.Y + d.Y * dir.Y)
				Window.Size = Vector2.new(w, h)
				holder.Size = UDim2.fromOffset(w, h)
				local dw, dh = (w - startSize.X) * Window.Scale, (h - startSize.Y) * Window.Scale
				holder.Position = UDim2.new(0.5, startPos.X.Offset + dw * dir.X / 2, 0.5, startPos.Y.Offset + dh * dir.Y / 2)
				if Window._applyNav then Window:_applyNav() end
			end, function()
				Window:_updateScale()
				Window:_saveWindow()
			end)
		end)
	end

	if not MOBILE then
		local edges = {
			{ dir = Vector2.new(1, 0), pos = UDim2.new(1, 0, 0.5, 0), size = UDim2.new(0, 10, 1, -28), line = UDim2.new(0, 2, 1, -40) },
			{ dir = Vector2.new(-1, 0), pos = UDim2.new(0, 0, 0.5, 0), size = UDim2.new(0, 10, 1, -28), line = UDim2.new(0, 2, 1, -40) },
			{ dir = Vector2.new(0, 1), pos = UDim2.new(0.5, 0, 1, 0), size = UDim2.new(1, -28, 0, 10), line = UDim2.new(1, -40, 0, 2) },
			{ dir = Vector2.new(0, -1), pos = UDim2.new(0.5, 0, 0, 0), size = UDim2.new(1, -28, 0, 10), line = UDim2.new(1, -40, 0, 2) },
			{ dir = Vector2.new(1, 1), pos = UDim2.new(1, 0, 1, 0), size = UDim2.fromOffset(18, 18) },
			{ dir = Vector2.new(-1, 1), pos = UDim2.new(0, 0, 1, 0), size = UDim2.fromOffset(18, 18) },
			{ dir = Vector2.new(1, -1), pos = UDim2.new(1, 0, 0, 0), size = UDim2.fromOffset(18, 18) },
			{ dir = Vector2.new(-1, -1), pos = UDim2.new(0, 0, 0, 0), size = UDim2.fromOffset(18, 18) },
		}
		for _, e in ipairs(edges) do
			local zone = create("Frame", {
				Parent = holder, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = e.pos, Size = e.size, ZIndex = 35,
			})
			if e.line then
				local line = create("Frame", {
					Parent = zone, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = e.line,
					BackgroundTransparency = 1, BorderSizePixel = 0, Theme = { BackgroundColor3 = "Accent" },
				}, { corner(1) })
				zone.MouseEnter:Connect(function() tween(line, { BackgroundTransparency = 0.3 }, 0.15) end)
				zone.MouseLeave:Connect(function() tween(line, { BackgroundTransparency = 1 }, 0.25) end)
			end
			resizeFrom(zone, e.dir)
		end
	end

	-- visible corner grip (bigger on touch screens)
	local gripSize = MOBILE and 30 or 20
	local grip = create("TextButton", {
		Parent = holder, Text = "", AutoButtonColor = false, BackgroundTransparency = MOBILE and 0.2 or 1, ZIndex = 36,
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -3, 1, -3), Size = UDim2.fromOffset(gripSize, gripSize),
		Theme = { BackgroundColor3 = "Element" },
	}, { corner(MOBILE and 9 or 6) })
	local gripIcon = Icon("move-diagonal-2", MOBILE and 16 or 13, "DimText", {
		Parent = grip, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	})
	grip.MouseEnter:Connect(function() tween(gripIcon, { ImageColor3 = T().Accent }) end)
	grip.MouseLeave:Connect(function() tween(gripIcon, { ImageColor3 = T().DimText }) end)
	resizeFrom(grip, Vector2.new(1, 1))

	-- restore the last size and position
	local savedWin = Window.SavedLayout.__window
	if not PREVIEW and not opts.Size and type(savedWin) == "table" and type(savedWin.w) == "number" then
		if savedWin.auto then
			Window.AutoSize = true
		else
			Window.AutoSize = false
			Window.Size = Vector2.new(savedWin.w, savedWin.h)
			holder.Size = UDim2.fromOffset(savedWin.w, savedWin.h)
		end
		Window:_updateScale()
		local x, y = clampPosition(savedWin.x or 0, savedWin.y or 0)
		holder.Position = UDim2.new(0.5, x, 0.5, y)
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

	---------------------------------------------------------------- floating toggle button

	local fabAlways = opts.ToggleButton
	if fabAlways == nil then fabAlways = MOBILE end
	local fab = create("TextButton", {
		Parent = screen, Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = env.__OrcaHubFabPosition or UDim2.new(0, 40, 0.5, 0),
		Size = UDim2.fromOffset(MOBILE and 52 or 46, MOBILE and 52 or 46),
		Visible = fabAlways, ZIndex = 10,
	}, { corner(16), accentGradient(45) })
	create("UIStroke", {
		Parent = fab, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1, 1, 1), Transparency = 0.75, Thickness = 1.5,
	})
	local fabScale = create("UIScale", { Parent = fab })
	local fabIcon = Icon(opts.Icon or opts.Logo or "waves", 24, nil, {
		Parent = fab, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(1, 1, 1),
	})
	Window.ToggleButton = fab

	fab.InputBegan:Connect(function(input)
		if not isPress(input) then return end
		local start = vec2(input.Position)
		local startPos = fab.Position
		local moved = false
		tween(fabScale, { Scale = 0.9 }, 0.15)
		Pointer.track(input, function(pos)
			local d = pos - start
			if d.Magnitude > 8 then moved = true end
			if moved then
				fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end, function()
			tween(fabScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
			if not moved then
				Window:Toggle()
				return
			end
			-- snap to the nearest side and keep it on screen
			local vp = viewport()
			local centre = fab.AbsolutePosition - screen.AbsolutePosition + fab.AbsoluteSize / 2
			local half = fab.AbsoluteSize.X / 2 + 12
			local x = centre.X < vp.X / 2 and half or (vp.X - half)
			local y = math.clamp(centre.Y, half, vp.Y - half - 40)
			local target = UDim2.fromOffset(x, y)
			tween(fab, { Position = target }, 0.35, Enum.EasingStyle.Back)
			env.__OrcaHubFabPosition = target
		end)
	end)

	---------------------------------------------------------------- visibility

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
			self:_hideTip()
			tween(uiScale, { Scale = self.Scale * 0.94 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tween(cover, { BackgroundTransparency = 0 }, 0.18).Completed:Connect(function()
				if not self.Visible then holder.Visible = false end
			end)
		end
		fab.Visible = fabAlways or not v
		tween(fabIcon, { Rotation = v and 0 or 180 }, 0.35)
		self:_updateBlur()
	end

	function Window:Toggle() self:SetVisible(not self.Visible) end

	-- Glass style blurs the game behind the window while it is open
	function Window:_updateBlur()
		local want = OrcaHub.Styles[OrcaHub.StyleName].Glass and self.Visible and not self.Destroyed
		if want and not self._blur then
			pcall(function()
				self._blur = Instance.new("BlurEffect")
				self._blur.Size = 0
				self._blur.Parent = Service("Lighting")
				tween(self._blur, { Size = 14 }, 0.3)
			end)
		elseif not want and self._blur then
			local b = self._blur
			self._blur = nil
			pcall(function()
				tween(b, { Size = 0 }, 0.2)
				task.delay(0.21, function() b:Destroy() end)
			end)
		end
	end
	function Window:SetToggleKey(key) self.ToggleKey = key end
	function Window:SetToggleButtonVisible(v)
		fabAlways = v
		fab.Visible = v or not self.Visible
	end

	-- one keyboard listener for the toggle key and every keybind
	track(UserInputService.InputBegan:Connect(function(input, processed)
		if Window._capturing then
			if input.UserInputType == Enum.UserInputType.Keyboard then Window._capturing(input.KeyCode) end
			return
		end
		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if input.KeyCode == Enum.KeyCode.F and Window.Visible
			and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			Window:_focusSearch()
			return
		end
		if input.KeyCode == Window.ToggleKey then Window:Toggle() end
		for _, kb in ipairs(Window.Keybinds) do
			if kb.Key ~= Enum.KeyCode.Unknown and input.KeyCode == kb.Key then kb.Pressed() end
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		for _, kb in ipairs(Window.Keybinds) do
			if kb.Released and input.KeyCode == kb.Key then kb.Released() end
		end
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
			})
			corner(8).Parent = btn
			padding(0, 16, 0, 16).Parent = btn
			if primary then accentGradient(0).Parent = btn else stroke("StrokeLight").Parent = btn end
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
		if self.NavMode then
			local x = (btn.AbsolutePosition.X - tabArea.AbsolutePosition.X) / self.Scale
			local w = btn.AbsoluteSize.X / self.Scale
			pill.Visible = true
			set(pill, { Position = UDim2.new(0, x, 0, 6), Size = UDim2.new(0, w, 1, -12) }, animate, 0.35)
			return
		end
		local y = (btn.AbsolutePosition.Y - tabArea.AbsolutePosition.Y) / self.Scale
		local h = btn.AbsoluteSize.Y / self.Scale
		pill.Visible = true
		set(pill, { Position = UDim2.new(0, 8, 0, y), Size = UDim2.new(1, -16, 0, h) }, animate, 0.35)
	end
	tabList:GetPropertyChangedSignal("CanvasPosition"):Connect(function() Window:_moveIndicator(false) end)
	tabArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Window:_moveIndicator(false) end)

	local sideTip = text({
		Parent = overlay, Text = "", TextSize = 12, Weight = "Medium", Visible = false, ZIndex = 8,
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0,
		Theme = { BackgroundColor3 = "Element", TextColor3 = "Text" },
	})
	corner(6).Parent = sideTip
	stroke("StrokeLight").Parent = sideTip
	padding(0, 10, 0, 10).Parent = sideTip

	function Window:SetCompact(v, instant)
		self.Compact = v
		if self.NavMode then return end
		local w = v and SIDEBAR_COMPACT or SIDEBAR_W
		local t = instant and 0 or 0.35
		set(sidebar, { Size = UDim2.new(0, w, 1, 0) }, not instant, t)
		set(content, { Position = UDim2.fromOffset(w, 0), Size = UDim2.new(1, -w, 1, 0) }, not instant, t)
		for _, lbl in ipairs(fadeLabels) do
			set(lbl, { TextTransparency = v and 1 or 0 }, not instant, t * 0.6)
		end
		task.delay(t + 0.05, function()
			for _, tab in ipairs(self.Tabs) do tab:_relayout(false) end
			self:_moveIndicator(false)
		end)
	end
	collapseBtn.MouseButton1Click:Connect(function() Window:SetCompact(not Window.Compact) end)

	-- narrow windows (phones in portrait, or a window resized small) move the tabs to a bottom bar
	local NAV_H = 56
	Window._dividerRows = {}
	function Window:_applyNav()
		local nav = self.Size.X < 560
		if nav == self.NavMode then return end
		self.NavMode = nav
		local w = self.Compact and SIDEBAR_COMPACT or SIDEBAR_W
		if nav then
			sidebar.Position = UDim2.new(0, 0, 1, -NAV_H)
			sidebar.Size = UDim2.new(1, 0, 0, NAV_H)
			content.Position = UDim2.fromOffset(0, 0)
			content.Size = UDim2.new(1, 0, 1, -NAV_H)
			sideFiller.AnchorPoint, sideFiller.Position, sideFiller.Size = Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.new(1, 0, 0, 12)
			sideLine.AnchorPoint, sideLine.Position, sideLine.Size = Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.new(1, 0, 0, 1)
			tabArea.Position, tabArea.Size = UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1)
			tabList.ScrollingDirection = Enum.ScrollingDirection.X
			tabList.AutomaticCanvasSize = Enum.AutomaticSize.X
			tabLayout.FillDirection = Enum.FillDirection.Horizontal
			tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			pillBar.AnchorPoint, pillBar.Position, pillBar.Size = Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, 0), UDim2.fromOffset(18, 3)
		else
			sidebar.Position = UDim2.fromOffset(0, 0)
			sidebar.Size = UDim2.new(0, w, 1, 0)
			content.Position = UDim2.fromOffset(w, 0)
			content.Size = UDim2.new(1, -w, 1, 0)
			sideFiller.AnchorPoint, sideFiller.Position, sideFiller.Size = Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.new(0, 12, 1, 0)
			sideLine.AnchorPoint, sideLine.Position, sideLine.Size = Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.new(0, 1, 1, 0)
			tabArea.Position, tabArea.Size = UDim2.fromOffset(0, TOPBAR_H), UDim2.new(1, -1, 1, -TOPBAR_H - profileH)
			tabList.ScrollingDirection = Enum.ScrollingDirection.Y
			tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
			tabLayout.FillDirection = Enum.FillDirection.Vertical
			tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			pillBar.AnchorPoint, pillBar.Position, pillBar.Size = Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0), UDim2.fromOffset(3, 18)
		end
		brand.Visible = not nav
		if profile then profile.Visible = not nav end
		collapseBtn.Visible = not nav
		pageTitle.Position = UDim2.fromOffset(nav and 14 or 52, pageTitle.Position.Y.Offset)
		pageDesc.Position = UDim2.fromOffset(nav and 14 or 52, 31)
		for _, row in ipairs(self._dividerRows) do row.Visible = not nav end
		for _, tab in ipairs(self.Tabs) do tab:_setNav(nav) end
		task.defer(function() self:_moveIndicator(false) end)
	end
	Window:_applyNav()

	local orderCounter = 0
	local function nextOrder()
		orderCounter = orderCounter + 1
		return orderCounter
	end

	function Window:Divider(name)
		local row = create("Frame", { Parent = tabList, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = nextOrder() })
		table.insert(Window._dividerRows, row)
		row.Visible = not Window.NavMode
		local lbl = text({
			Parent = row, Text = string.upper(name or ""), TextSize = 10, Weight = "SemiBold",
			Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -12, 1, -6),
			Theme = { TextColor3 = "DimText" }, TextTransparency = Window.Compact and 1 or 0,
		})
		table.insert(fadeLabels, lbl)
	end

	---------------------------------------------------------------- layout persistence

	local containers = {}

	function Window:SaveLayout()
		local data = {}
		for _, c in ipairs(containers) do
			local entry = { columns = { {}, {} }, collapsed = {} }
			for ci = 1, 2 do
				for _, s in ipairs(c.Columns[ci]) do table.insert(entry.columns[ci], s.Name) end
			end
			for _, s in ipairs(c.Sections) do
				entry.collapsed[s.Name] = s.Collapsed
			end
			data[c.Key] = entry
		end
		data.__window = self.SavedLayout.__window
		data.__favorites = self.SavedLayout.__favorites
		self.SavedLayout = data
		writeJSON(self.LayoutPath, data)
	end

	function Window:ResetLayout()
		for _, c in ipairs(containers) do
			c.Columns = { {}, {} }
			for _, s in ipairs(c.Sections) do
				table.insert(c.Columns[s.DefaultSide], s)
				if s.Collapsed ~= s.DefaultCollapsed then s:SetCollapsed(s.DefaultCollapsed, true) end
			end
			c:_layout(true)
		end
		self.SavedLayout = {}
		if hasFS() and type(delfile) == "function" then
			pcall(function() if isfile(self.LayoutPath) then delfile(self.LayoutPath) end end)
		end
	end

	---------------------------------------------------------------- search (all tabs)

	local function applySearch()
		local q = string.lower((string.gsub(searchBox.Text, "^%s+", "")))
		q = string.gsub(q, "%s+$", "")
		if q ~= "" then
			for _, tab in ipairs(Window.Tabs) do tab:_ensureBuilt() end
		end
		Window._searching = q ~= ""
		Window:_closePopup()
		for _, tab in ipairs(Window.Tabs) do
			local tabCount = 0
			for _, c in ipairs(tab.Containers) do
				local count = 0
				for _, section in ipairs(c.Sections) do
					local sectionMatch = q ~= "" and string.find(string.lower(section.Name), q, 1, true) ~= nil
					local any = false
					for _, el in ipairs(section.Elements) do
						local show = q == "" or sectionMatch or string.find(el.SearchText, q, 1, true) ~= nil
						el.Row.Visible = show
						if show and el.Type ~= "Divider" then
							any = true
							if q ~= "" then count = count + 1 end
						end
					end
					section.Frame.Visible = q == "" or any or sectionMatch
					section:_resize(false)
				end
				c:_setBadge(q ~= "" and count or nil)
				c:_setEmpty(q ~= "" and count == 0, searchBox.Text)
				c:_layout(false)
				tabCount = tabCount + count
			end
			tab:_setBadge(q ~= "" and tabCount or nil)
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

	---------------------------------------------------------------- favourites and the option menu

	Window.FavKeys = {}
	if type(Window.SavedLayout.__favorites) == "table" then
		for _, k in ipairs(Window.SavedLayout.__favorites) do table.insert(Window.FavKeys, k) end
	end
	Window.Elements = {}
	local favTab, favSection
	local favMirrors = {}

	local function isFav(key) return table.find(Window.FavKeys, key) ~= nil end

	-- a long-press opens the option menu; the touch release that follows must not also click
	local function suppressed() return os.clock() - (Window._longPressAt or -1) < 0.6 end
	Window._suppressed = suppressed

	function Window:_jumpTo(obj)
		local C = obj._container
		if not C then return end
		if C.Tab then C.Tab:Select() end
		if C.Sub then C.Sub:Select() end
		local section = obj.Section
		if section and section.Collapsed then section:SetCollapsed(false) end
		task.delay(0.45, function()
			if section and section._targetY then
				local maxScroll = math.max(0, C.Page.AbsoluteCanvasSize.Y - C.Page.AbsoluteWindowSize.Y) / self.Scale
				C.Page.CanvasPosition = Vector2.new(0, math.clamp(section._targetY - PAD, 0, maxScroll))
			end
			if obj.Row and obj.Row.Parent then
				local flash = create("Frame", {
					Parent = obj.Row, ZIndex = 0, Position = UDim2.fromOffset(-6, -2), Size = UDim2.new(1, 12, 1, 4),
					BackgroundTransparency = 0.6, Theme = { BackgroundColor3 = "Accent" },
				}, { corner(6) })
				tween(flash, { BackgroundTransparency = 1 }, 1.2)
				task.delay(1.25, function() flash:Destroy() end)
			end
		end)
	end

	function Window:_queueFavourites()
		if self._favQueued then return end
		self._favQueued = true
		task.defer(function()
			self._favQueued = false
			self:_renderFavourites()
		end)
	end

	function Window:_renderFavourites()
		for _, m in ipairs(favMirrors) do pcall(function() m:Destroy() end) end
		favMirrors = {}
		for _, obj in pairs(self.Elements) do obj._mirrors = {} end
		for _, key in ipairs(self.FavKeys) do
			for _, tab in ipairs(self.Tabs) do
				if not tab.Built and string.sub(key, 1, #tab.Name + 1) == tab.Name .. "/" then tab:_ensureBuilt() end
			end
		end
		local any = false
		for _, key in ipairs(self.FavKeys) do
			if self.Elements[key] then any = true end
		end
		if not any then
			if favTab then favTab:SetHidden(true) end
			return
		end
		if not favTab then
			favTab = self:Tab({ Name = "Favourites", Icon = "star", Description = "Right-click or long-press any option to star it", _order = -1 })
			favSection = favTab:Section({ Name = "Starred", Icon = "star", Collapsed = false })
		end
		favTab:SetHidden(false)
		for _, key in ipairs(self.FavKeys) do
			local obj = self.Elements[key]
			if obj then
				local o = obj._opts
				local base = { Name = obj.Name, Tooltip = o.Tooltip, _mirrorOf = obj }
				local m
				if obj.Type == "Toggle" then
					base.Default, base.Style = obj:Get(), o.Style
					base.Callback = function(v) obj:Set(v) end
					m = favSection:Toggle(base)
				elseif obj.Type == "Slider" then
					for _, k in ipairs({ "Min", "Max", "Increment", "Rounding", "Suffix" }) do base[k] = o[k] end
					base.Default = obj:Get()
					base.Callback = function(v) obj:Set(v) end
					m = favSection:Slider(base)
				elseif obj.Type == "Segmented" then
					base.Options, base.Default = o.Options, obj:Get()
					base.Callback = function(v) obj:Set(v) end
					m = favSection:Segmented(base)
				elseif obj.Type == "Button" then
					base.Icon, base.Style, base.Confirm = o.Icon, o.Style, o.Confirm
					base.Callback = function() obj:Fire() end
					m = favSection:Button(base)
				else
					base.Icon = "arrow-right"
					base.Callback = function() self:_jumpTo(obj) end
					m = favSection:Button(base)
				end
				table.insert(obj._mirrors, m)
				table.insert(favMirrors, m)
			end
		end
	end

	function Window:ToggleFavourite(obj)
		obj = obj._mirrorOf or obj
		local key = obj._key
		if not key then return end
		local i = table.find(self.FavKeys, key)
		if i then table.remove(self.FavKeys, i) else table.insert(self.FavKeys, key) end
		if obj._star then obj._star.Visible = not i end
		self.SavedLayout.__favorites = self.FavKeys
		self:SaveLayout()
		self:_renderFavourites()
		OrcaHub:Notify({ Title = i and "Removed from favourites" or "Added to favourites", Content = obj.Name, Duration = 2 })
	end

	function Window:_contextMenu(obj, screenPos)
		local target = obj._mirrorOf or obj
		local items = {}
		if target._key and (target.Set or target.Fire) then
			table.insert(items, {
				Title = isFav(target._key) and "Remove from favourites" or "Add to favourites", Icon = "star",
				Callback = function() self:ToggleFavourite(target) end,
			})
		end
		if target._default ~= nil and target.Set and target.Type ~= "Keybind" then
			table.insert(items, { Title = "Reset to default", Icon = "rotate-ccw", Callback = function() target:Set(target._default) end })
		end
		if obj._mirrorOf then
			table.insert(items, { Title = "Go to option", Icon = "arrow-right", Callback = function() self:_jumpTo(target) end })
		end
		if #items == 0 then return end
		local pos = self:_toMain(screenPos)
		local W, H = 200, #items * 32 + 8
		local mainW, mainH = main.AbsoluteSize.X / self.Scale, main.AbsoluteSize.Y / self.Scale
		local frame = create("Frame", {
			Parent = overlay, ZIndex = 3,
			Position = UDim2.fromOffset(math.clamp(pos.X, 8, mainW - W - 8), math.clamp(pos.Y, 8, mainH - H - 8)),
			Size = UDim2.fromOffset(W, H), Theme = { BackgroundColor3 = "Section" },
		}, { corner(8), stroke("StrokeLight"), padding(4, 4, 4, 4) })
		local sc = create("UIScale", { Parent = frame, Scale = 0.9 })
		tween(sc, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
		create("UIListLayout", { Parent = frame, SortOrder = Enum.SortOrder.LayoutOrder })
		for i, it in ipairs(items) do
			local b = create("TextButton", {
				Parent = frame, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, LayoutOrder = i,
				Size = UDim2.new(1, 0, 0, 32), Theme = { BackgroundColor3 = "ElementHover" },
			}, { corner(6) })
			Icon(it.Icon, 14, "Accent", { Parent = b, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
			text({ Parent = b, Text = it.Title, TextSize = 12, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -36, 1, 0) })
			b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0 }, 0.12) end)
			b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 1 }, 0.15) end)
			b.MouseButton1Click:Connect(function()
				self:_closePopup()
				safeCall(it.Callback)
			end)
		end
		self:_openPopup({ Close = function() frame:Destroy() end })
	end

	local function attachContext(row, obj)
		local function hook(gui)
			gui.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					if os.clock() - (obj._menuAt or -1) < 0.1 then return end
					obj._menuAt = os.clock()
					Window:_contextMenu(obj, vec2(input.Position))
				elseif input.UserInputType == Enum.UserInputType.Touch then
					local start = vec2(input.Position)
					local state = "pending"
					local cancel = Pointer.track(input, function(p)
						if (p - start).Magnitude > 10 then state = "moved" end
					end, function()
						if state == "pending" then state = "tap" end
					end)
					task.delay(0.55, function()
						if state == "pending" and os.clock() - (obj._menuAt or -1) > 0.1 then
							state = "long"
							cancel()
							obj._menuAt = os.clock()
							Window._longPressAt = os.clock()
							Window:_contextMenu(obj, start)
						end
					end)
				end
			end)
		end
		hook(row)
		for _, d in ipairs(row:GetDescendants()) do
			if d:IsA("GuiButton") then hook(d) end
		end
	end

	---------------------------------------------------------------- containers (a page of draggable sections)

	local function Container(page, key, onBadge)
		local C = { Key = key, Sections = {}, Columns = { {}, {} }, Page = page }
		table.insert(containers, C)
		local saved = Window.SavedLayout[key]

		local origin = create("Frame", { Parent = page, BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0) })
		local placeholder = create("Frame", {
			Parent = page, Visible = false, BackgroundTransparency = 0.92,
			Theme = { BackgroundColor3 = "Accent" },
		}, { corner(10) })
		create("UIStroke", {
			Parent = placeholder, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.4,
			Theme = { Color = "Accent" },
		})
		local empty = text({
			Parent = page, Text = "", TextSize = 13, Visible = false, TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 60), Position = UDim2.fromOffset(0, 40), Theme = { TextColor3 = "DimText" },
		})

		function C:_setEmpty(v, query)
			empty.Visible = v
			empty.Text = "No results for \"" .. tostring(query) .. "\""
		end
		function C:_setBadge(n)
			if onBadge then onBadge(n) end
		end

		function C:_layout(animate)
			local width = page.AbsoluteWindowSize.X / Window.Scale
			if width <= 0 then return end
			local single = width < SINGLE_COLUMN_BELOW
			C.Single = single
			local colW = single and (width - PAD * 2) or math.floor((width - PAD * 2 - GAP) / 2)
			local lists = C.Columns
			if single then
				local merged = {}
				for ci = 1, 2 do
					for _, s in ipairs(C.Columns[ci]) do table.insert(merged, s) end
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
						s.Frame.Size = UDim2.fromOffset(colW, s.Frame.Size.Y.Offset)
						if s == C._dragging then
							placeholder.Position = UDim2.fromOffset(x, y)
							placeholder.Size = UDim2.fromOffset(colW, h)
						else
							set(s.Frame, { Position = UDim2.fromOffset(x, y) }, animate, 0.35)
						end
						y = y + h + GAP
					end
				end
				maxY = math.max(maxY, y)
			end
			page.CanvasSize = UDim2.fromOffset(0, math.max(0, maxY - GAP + PAD))
		end

		function C:_queueLayout(animate)
			if C._queued then
				C._queuedAnimate = C._queuedAnimate or animate
				return
			end
			C._queued, C._queuedAnimate = true, animate
			task.defer(function()
				C._queued = false
				C:_layout(C._queuedAnimate)
			end)
		end

		page:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function() C:_queueLayout(false) end)
		page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if not C._dragging then Window:_repositionPopup() end
			Window:_hideTip()
		end)

		local function canvasPoint(screenPos)
			return (screenPos - origin.AbsolutePosition) / Window.Scale
		end

		function C:_startDrag(section, pressInput, startScreen)
			Window:_closePopup()
			C._dragging = section
			local frame = section.Frame
			local grab = canvasPoint(startScreen) - Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
			local pointer = startScreen
			frame.ZIndex = 10
			tween(section._scale, { Scale = 1.02 }, 0.2)
			tween(section._stroke, { Color = T().Accent }, 0.2)
			page.ScrollingEnabled = false
			placeholder.Visible = true
			C:_layout(true)

			local function location()
				for ci = 1, 2 do
					for i, s in ipairs(C.Columns[ci]) do
						if s == section then return ci, i end
					end
				end
			end

			local function target(p)
				if C.Single then
					local count, c1 = 0, 0
					for ci = 1, 2 do
						for _, s in ipairs(C.Columns[ci]) do
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
				for _, s in ipairs(C.Columns[ci]) do
					if s ~= section and s.Frame.Visible and p.Y > s._targetY + s:_height() / 2 then idx = idx + 1 end
				end
				return ci, idx
			end

			local function update()
				local p = canvasPoint(pointer)
				frame.Position = UDim2.fromOffset(p.X - grab.X, p.Y - grab.Y)
				local centre = Vector2.new(p.X - grab.X + frame.Size.X.Offset / 2, p.Y - grab.Y + section:_height() / 2)
				local ci, idx = target(centre)
				local curC, curI = location()
				if ci ~= curC or idx ~= curI then
					table.remove(C.Columns[curC], curI)
					table.insert(C.Columns[ci], math.min(idx, #C.Columns[ci] + 1), section)
					C:_layout(true)
				end
			end

			local stepConn = track(RunService.Heartbeat:Connect(function()
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

			Pointer.track(pressInput, function(pos)
				pointer = pos
				update()
			end, function()
				stepConn:Disconnect()
				C._dragging = nil
				page.ScrollingEnabled = true
				placeholder.Visible = false
				tween(section._scale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
				tween(section._stroke, { Color = T().Stroke }, 0.3)
				C:_layout(true)
				task.delay(0.36, function()
					if C._dragging ~= section then frame.ZIndex = 1 end
				end)
				Window:SaveLayout()
			end)
		end

		------------------------------------------------------------ sections

		function C:Section(so)
			so = so or {}
			local Section = {
				Name = so.Name or "Section",
				Elements = {},
				DefaultSide = (so.Side == "Right" or so.Side == 2) and 2 or 1,
				_bodyH = 0,
			}
			local defaultCollapsed = so.Collapsed
			if defaultCollapsed == nil then defaultCollapsed = Window.SectionsCollapsed end
			Section.DefaultCollapsed = defaultCollapsed
			Section.Collapsed = defaultCollapsed
			if saved and saved.collapsed and saved.collapsed[Section.Name] ~= nil then
				Section.Collapsed = saved.collapsed[Section.Name] == true
			end

			local frame = create("Frame", {
				Parent = page, ClipsDescendants = true,
				Size = UDim2.fromOffset(300, SECTION_HEADER), Position = UDim2.fromOffset(PAD, PAD),
				Theme = { BackgroundColor3 = "Section", BackgroundTransparency = "PanelTransparency" },
			}, { corner(10) })
			Section.Frame = frame
			Section._stroke = stroke("Stroke")
			Section._stroke.Parent = frame
			Section._scale = create("UIScale", { Parent = frame })

			local header = create("Frame", {
				Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, SECTION_HEADER),
				Theme = { BackgroundColor3 = "ElementHover" },
			})
			Section.HeaderFrame = header
			local grip = Icon("grip-vertical", 14, "DimText", {
				Parent = header, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0),
				ImageTransparency = MOBILE and 0.4 or 0.6,
			})
			local titleX = 26
			if so.Icon and iconImage(so.Icon) then
				Icon(so.Icon, 15, "Accent", { Parent = header, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 26, 0.5, 0) })
				titleX = 48
			end
			local sectionTitle = text({
				Parent = header, Text = Section.Name, Weight = "SemiBold", TextSize = 13,
				Position = UDim2.fromOffset(titleX, 0), Size = UDim2.new(1, -titleX - 74, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			function Section:SetTitle(t) sectionTitle.Text = t end
			local countBadge = text({
				Parent = header, Text = "", TextSize = 11, Weight = "Medium", TextXAlignment = Enum.TextXAlignment.Center,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -36, 0.5, 0), Size = UDim2.fromOffset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0, Visible = false,
				Theme = { BackgroundColor3 = "Element", TextColor3 = "SubText" },
			})
			corner(9).Parent = countBadge
			padding(0, 7, 0, 7).Parent = countBadge
			local chevron = Icon("chevron-down", 14, "DimText", {
				Parent = header, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
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

			local function isOpen() return not Section.Collapsed or Window._searching end

			function Section:_height()
				return SECTION_HEADER + (isOpen() and Section._bodyH or 0)
			end

			local function refreshBadge()
				local n = 0
				for _, el in ipairs(Section.Elements) do
					if el.Type ~= "Divider" and el.Type ~= "Label" then n = n + 1 end
				end
				countBadge.Text = tostring(n)
				countBadge.Visible = Section.Collapsed and not Window._searching and n > 0
			end

			function Section:_resize(animate)
				local target = UDim2.fromOffset(Section._width or frame.Size.X.Offset, Section:_height())
				set(frame, { Size = target }, animate, 0.35)
				refreshBadge()
			end

			list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section._bodyH = list.AbsoluteContentSize.Y / Window.Scale + 20
				Section:_resize(false)
				C:_queueLayout(false)
			end)

			function Section:SetCollapsed(v, skipSave)
				if Section.Collapsed == v then return end
				Section.Collapsed = v
				tween(chevron, { Rotation = v and -90 or 0 }, 0.3)
				tween(headerLine, { BackgroundTransparency = v and 1 or 0 }, 0.2)
				Section:_resize(true)
				if not v and Window.Accordion then
					for _, other in ipairs(C.Sections) do
						if other ~= Section and not other.Collapsed then other:SetCollapsed(true, true) end
					end
				end
				C:_layout(true)
				if not skipSave then Window:SaveLayout() end
			end
			function Section:ToggleCollapsed() Section:SetCollapsed(not Section.Collapsed) end

			-- the whole header toggles the section; dragging it moves the section
			header.MouseEnter:Connect(function()
				if MOBILE then return end
				tween(header, { BackgroundTransparency = 0.6 }, 0.15)
				tween(grip, { ImageTransparency = 0 }, 0.15)
				tween(chevron, { ImageColor3 = T().Text }, 0.15)
			end)
			header.MouseLeave:Connect(function()
				if MOBILE then return end
				tween(header, { BackgroundTransparency = 1 }, 0.2)
				tween(grip, { ImageTransparency = 0.6 }, 0.2)
				tween(chevron, { ImageColor3 = T().DimText }, 0.2)
			end)

			header.InputBegan:Connect(function(input)
				if not isPress(input) or C._dragging then return end
				local start = vec2(input.Position)
				local touch = input.UserInputType == Enum.UserInputType.Touch
				local state = "pending"
				local cancel
				if touch then
					tween(header, { BackgroundTransparency = 0.6 }, 0.1)
					if not Window._searching then
						task.delay(0.35, function()
							if state == "pending" then
								state = "drag"
								cancel()
								C:_startDrag(Section, input, start)
							end
						end)
					end
				end
				cancel = Pointer.track(input, function(pos)
					if state ~= "pending" then return end
					if (pos - start).Magnitude > (touch and 10 or 5) then
						if touch or Window._searching then
							state = "cancelled"
							cancel()
							if touch then tween(header, { BackgroundTransparency = 1 }, 0.2) end
						else
							state = "drag"
							cancel()
							C:_startDrag(Section, input, start)
						end
					end
				end, function()
					if touch then tween(header, { BackgroundTransparency = 1 }, 0.2) end
					if state == "pending" then
						state = "tap"
						if not Window._searching then Section:ToggleCollapsed() end
					end
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
			local col = C.Columns[column]
			local insertAt = #col + 1
			for i, other in ipairs(col) do
				if (other._savedIndex or math.huge) > Section._savedIndex then
					insertAt = i
					break
				end
			end
			table.insert(col, insertAt, Section)
			table.insert(C.Sections, Section)
			Section:_resize(false)
			C:_queueLayout(false)

			------------------------------------------------ element helpers

			local order = 0
			local function newRow(height)
				order = order + 1
				return create("Frame", {
					Parent = body, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or ROW_H), LayoutOrder = order,
				})
			end

			local function rowHover(row, hit)
				if MOBILE then return end
				local glow = create("Frame", {
					Parent = row, BackgroundTransparency = 1, ZIndex = 0,
					Position = UDim2.fromOffset(-6, -1), Size = UDim2.new(1, 12, 1, 2),
					Theme = { BackgroundColor3 = "ElementHover" },
				}, { corner(6) })
				hit.MouseEnter:Connect(function() tween(glow, { BackgroundTransparency = 0.55 }, 0.15) end)
				hit.MouseLeave:Connect(function() tween(glow, { BackgroundTransparency = 1 }, 0.2) end)
			end

			local lastLine
			local function titleBlock(parent, name, desc, rightInset, top, tooltip)
				local holderFrame = create("Frame", {
					Parent = parent, BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, top or 0),
					Size = top and UDim2.new(1, -(rightInset or 0), 0, 18) or UDim2.new(1, -(rightInset or 0), 1, 0),
				})
				create("UIListLayout", {
					Parent = holderFrame, VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1),
				})
				local line = create("Frame", { Parent = holderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1 }, {
					create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5),
					}),
				})
				lastLine = line
				local title = text({
					Parent = line, Text = name, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1,
					Theme = false, TextColor3 = T().SubText, TextTruncate = Enum.TextTruncate.AtEnd,
				})
				create("UISizeConstraint", { Parent = title, MaxSize = Vector2.new(MOBILE and 190 or 230, 16) })
				if tooltip then
					local tipBtn = create("TextButton", {
						Parent = line, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
						Size = UDim2.fromOffset(14, 14), LayoutOrder = 2,
					})
					local tipIcon = Icon("info", 13, "DimText", { Parent = tipBtn, Size = UDim2.fromScale(1, 1) })
					tipBtn.MouseEnter:Connect(function()
						tween(tipIcon, { ImageColor3 = T().Accent }, 0.15)
						Window:_showTip(tipBtn, tooltip)
					end)
					tipBtn.MouseLeave:Connect(function()
						tween(tipIcon, { ImageColor3 = T().DimText }, 0.2)
						Window:_hideTip()
					end)
					tipBtn.MouseButton1Click:Connect(function() Window:_showTip(tipBtn, tooltip) end)
				end
				if desc and not top then
					text({
						Parent = holderFrame, Text = desc, TextSize = 11, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2,
						TextTruncate = Enum.TextTruncate.AtEnd, Theme = { TextColor3 = "DimText" },
					})
				end
				return title, holderFrame
			end

			local function register(kind, o, row, obj)
				obj.Type = kind
				obj.Name = o.Name or o.Title or kind
				obj.Row = row
				obj.Flag = o.Flag
				obj.Section = Section
				obj.SearchText = string.lower(obj.Name .. " " .. (o.Description or "") .. " " .. (o.Tooltip or ""))
				function obj:SetVisible(v)
					row.Visible = v
				end
				function obj:Destroy()
					row:Destroy()
					for i, e in ipairs(Section.Elements) do
						if e == obj then table.remove(Section.Elements, i) break end
					end
					if o.Flag then OrcaHub.Options[o.Flag] = nil end
					refreshBadge()
				end
				function obj:Lock(reason)
					if obj._lock then return end
					local lock = create("TextButton", {
						Parent = row, Text = "", AutoButtonColor = false, ZIndex = 5,
						Position = UDim2.fromOffset(-6, -2), Size = UDim2.new(1, 12, 1, 4), BackgroundTransparency = 0.3,
						Theme = { BackgroundColor3 = "Section" },
					}, { corner(6) })
					local tag = create("Frame", {
						Parent = lock, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
						Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6,
						Theme = { BackgroundColor3 = "Element" },
					}, {
						corner(10), stroke("StrokeLight"), padding(0, 8, 0, 6),
						create("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
						}),
					})
					Icon("lock", 11, "Accent", { Parent = tag, LayoutOrder = 1, ZIndex = 6 })
					text({
						Parent = tag, Text = reason or "Locked", TextSize = 11, Weight = "Medium", LayoutOrder = 2, ZIndex = 6,
						Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, Theme = { TextColor3 = "SubText" },
					})
					lock.MouseButton1Click:Connect(function()
						OrcaHub:Notify({ Title = "Locked", Content = reason or "This option is locked.", Type = "Warning", Duration = 3 })
					end)
					obj._lock = lock
					obj.Locked = true
				end
				function obj:Unlock()
					if obj._lock then obj._lock:Destroy() end
					obj._lock = nil
					obj.Locked = false
				end
				table.insert(Section.Elements, obj)
				if o.Flag then OrcaHub.Options[o.Flag] = obj end
				if o.Locked then obj:Lock(type(o.Locked) == "string" and o.Locked or nil) end

				obj._opts = o
				obj._container = C
				obj._mirrors = {}
				obj._mirrorOf = o._mirrorOf
				obj._key = C.Key .. "/" .. Section.Name .. "/" .. obj.Name
				if obj.Get then
					local ok, d = pcall(function() return obj:Get() end)
					if ok then obj._default = type(d) == "table" and table.clone(d) or d end
				end
				local displayOnly = { Label = true, Paragraph = true, Header = true, Progress = true, Divider = true, Value = true, Code = true, Image = true, Buttons = true }
				local interactive = (obj.Set ~= nil or obj.Fire ~= nil) and not displayOnly[kind]
				if interactive and not o._mirrorOf then
					Window.Elements[obj._key] = obj
					if lastLine and lastLine:IsDescendantOf(row) then
						obj._star = Icon("star", 11, "Accent", { Parent = lastLine, LayoutOrder = 3, Visible = isFav(obj._key) })
					end
					if isFav(obj._key) then Window:_queueFavourites() end
				end
				lastLine = nil
				if obj.Set and interactive then
					local rawSet = obj.Set
					obj.Set = function(self, ...)
						rawSet(self, ...)
						for _, m in ipairs(obj._mirrors) do
							if m.Set and obj.Get then pcall(function() m:Set(obj:Get(), true) end) end
						end
					end
				end
				local rawDestroy = obj.Destroy
				obj.Destroy = function(self)
					if Window.Elements[obj._key] == obj then Window.Elements[obj._key] = nil end
					rawDestroy(self)
				end
				if interactive or o._mirrorOf then attachContext(row, obj) end
				if o.Flag and OrcaHub._pending[o.Flag] ~= nil and obj.Set then
					local value = OrcaHub._pending[o.Flag]
					OrcaHub._pending[o.Flag] = nil
					task.defer(function() pcall(function() obj:Set(deserialize(value)) end) end)
				end
				refreshBadge()
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

			------------------------------------------------ popups

			local function popupAt(anchor, width, height)
				local function place()
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
					return x, y, up
				end
				local x, y, up = place()
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
				local function reposition()
					local pageTop = page.AbsolutePosition.Y
					local pageBottom = pageTop + page.AbsoluteSize.Y
					local a = anchor.AbsolutePosition.Y
					if a + anchor.AbsoluteSize.Y < pageTop or a > pageBottom then
						Window:_closePopup()
						return
					end
					x, y, up = place()
					frame.Position = UDim2.fromOffset(x, y)
				end
				return frame, close, reposition
			end

			------------------------------------------------ shared controls (rows and toggle add-ons)

			local function keybindControl(parent, o, onPress, onRelease)
				local key = o.Default or Enum.KeyCode.Unknown
				local pillBtn = text({
					Class = "TextButton", Parent = parent, Text = "", AutoButtonColor = false, TextSize = 11, Weight = "Medium",
					TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0,
					Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
					Theme = { BackgroundColor3 = "Element", TextColor3 = "SubText" },
				})
				corner(6).Parent = pillBtn
				padding(0, 8, 0, 8).Parent = pillBtn
				local pillStroke = stroke("Stroke")
				pillStroke.Parent = pillBtn
				create("UISizeConstraint", { Parent = pillBtn, MinSize = Vector2.new(30, 22) })

				local ctl = {}
				local entry = { Key = key, Name = o.Name or "Keybind", Pressed = onPress, Released = onRelease }
				table.insert(Window.Keybinds, entry)
				ctl.Entry = entry
				local function display()
					pillBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
				end
				function ctl:Set(k)
					key = k or Enum.KeyCode.Unknown
					entry.Key = key
					display()
					if o.Flag then OrcaHub.Flags[o.Flag] = key end
					safeCall(o.ChangedCallback, key)
				end
				function ctl:Get() return key end
				pillBtn.MouseButton1Click:Connect(function()
					pillBtn.Text = "..."
					tween(pillStroke, { Color = T().Accent })
					tween(pillBtn, { TextColor3 = T().Accent })
					Window._capturing = function(k)
						tween(pillStroke, { Color = T().Stroke })
						tween(pillBtn, { TextColor3 = T().SubText })
						if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then k = Enum.KeyCode.Unknown end
						ctl:Set(k)
						task.defer(function() Window._capturing = nil end)
					end
				end)
				display()
				if o.Flag then OrcaHub.Flags[o.Flag] = key end
				return ctl, pillBtn
			end

			local function colorControl(parent, o)
				local color = o.Default or T().Accent
				local h, s, v = color:ToHSV()
				local swatch = create("TextButton", {
					Parent = parent, Text = "", AutoButtonColor = false, BackgroundColor3 = color,
					Size = UDim2.fromOffset(o.Small and 22 or 40, 22),
				}, { corner(6), stroke("StrokeLight") })

				local ctl = {}
				local listeners = {}
				local function changed(silent)
					swatch.BackgroundColor3 = color
					for _, fn in ipairs(listeners) do fn() end
					if o.Flag then OrcaHub.Flags[o.Flag] = color end
					if not silent then safeCall(o.Callback, color) end
				end
				function ctl:Set(c, silent)
					color = c
					h, s, v = c:ToHSV()
					changed(silent)
				end
				function ctl:Get() return color end

				swatch.MouseButton1Click:Connect(function()
					local W, H = 230, 196
					local frame, closeFrame, reposition = popupAt(swatch, W, H)
					Window:_openPopup({
						Close = function()
							listeners = {}
							closeFrame()
						end,
						Reposition = reposition,
					})

					local sv = create("TextButton", {
						Parent = frame, Text = "", AutoButtonColor = false,
						Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(W - 46, 130),
						BackgroundColor3 = Color3.fromHSV(h, 1, 1),
					}, { corner(6) })
					create("Frame", {
						Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
					}, { corner(6), create("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
					create("Frame", {
						Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 2,
					}, { corner(6), create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
					local svCursor = create("Frame", {
						Parent = sv, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 3,
						BackgroundTransparency = 1,
					}, { corner(6), create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })

					local keypoints = {}
					for i = 0, 6 do
						table.insert(keypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i == 6 and 0.999 or i / 6, 1, 1)))
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
							Pointer.track(input, function(pos) apply(pos) end)
						end)
					end
					bindDrag(sv, function(p)
						local rel = p - sv.AbsolutePosition
						s = math.clamp(rel.X / sv.AbsoluteSize.X, 0, 1)
						v = 1 - math.clamp(rel.Y / sv.AbsoluteSize.Y, 0, 1)
						color = Color3.fromHSV(h, s, v)
						changed()
					end)
					bindDrag(hue, function(p)
						h = math.clamp((p.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
						color = Color3.fromHSV(h, s, v)
						changed()
					end)
					hexBox.FocusLost:Connect(function()
						local ok, c = pcall(Color3.fromHex, (string.gsub(hexBox.Text, "#", "")))
						if ok and c then ctl:Set(c) else paint() end
					end)
				end)

				if o.Flag then OrcaHub.Flags[o.Flag] = color end
				return ctl, swatch
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

			------------------------------------------------ segmented control

			function Section:Segmented(o)
				local options = o.Options or {}
				local value = o.Default
				if value == nil then value = options[1] end
				local row = newRow(BOX_H + 22)
				titleBlock(row, o.Name or "Mode", nil, 0, 0, o.Tooltip)
				local bar = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, BOX_H),
					Theme = { BackgroundColor3 = "Element" },
				}, { corner(8), stroke("Stroke") })
				local segPill = create("Frame", {
					Parent = bar, Position = UDim2.fromOffset(3, 3), Size = UDim2.new(0, 0, 1, -6), BackgroundColor3 = Color3.new(1, 1, 1),
				}, { corner(6), accentGradient(0) })
				local list = create("Frame", { Parent = bar, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2 }, {
					create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }),
					padding(3, 3, 3, 3),
				})
				local buttons = {}
				local obj = {}
				local function render(animate)
					local idx = table.find(options, value) or 1
					local w = (bar.AbsoluteSize.X / Window.Scale - 6) / math.max(#options, 1)
					set(segPill, { Position = UDim2.fromOffset(3 + (idx - 1) * w, 3), Size = UDim2.new(0, w, 1, -6) }, animate, 0.3)
					for i, b in ipairs(buttons) do
						set(b, { TextColor3 = i == idx and Color3.new(1, 1, 1) or T().SubText }, animate, 0.2)
					end
				end
				for i, opt in ipairs(options) do
					local b = text({
						Class = "TextButton", Parent = list, Text = tostring(opt), TextSize = 12, Weight = "Medium", AutoButtonColor = false,
						TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1 / math.max(#options, 1), 0, 1, 0), LayoutOrder = i,
						Theme = false, TextColor3 = T().SubText, TextTruncate = Enum.TextTruncate.AtEnd,
					})
					b.MouseButton1Click:Connect(function() obj:Set(opt) end)
					buttons[i] = b
				end
				function obj:Set(v, silent)
					value = v
					render(true)
					if o.Flag then OrcaHub.Flags[o.Flag] = value end
					if not silent then safeCall(o.Callback, value) end
				end
				function obj:Get() return value end
				bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() render(false) end)
				table.insert(Refreshers, function() render(false) end)
				task.defer(function() render(false) end)
				if o.Flag then OrcaHub.Flags[o.Flag] = value end
				return register("Segmented", o, row, obj)
			end

			------------------------------------------------ progress bar

			function Section:Progress(o)
				local maxValue = o.Max or 100
				local value = o.Value or 0
				local row = newRow(ROW_H + 6)
				titleBlock(row, o.Name or "Progress", nil, 90, 2, o.Tooltip)
				local valueLbl = text({
					Parent = row, Text = "", TextSize = 12, Weight = "Medium", TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 2), Size = UDim2.fromOffset(90, 18),
					Theme = { TextColor3 = "SubText" },
				})
				local barBg = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -5), Size = UDim2.new(1, 0, 0, 8),
					Theme = { BackgroundColor3 = "ToggleOff" },
				}, { corner(4) })
				local fill = create("Frame", {
					Parent = barBg, Size = UDim2.fromScale(0, 1), BackgroundColor3 = o.Color or Color3.new(1, 1, 1),
				}, { corner(4) })
				if not o.Color then accentGradient(0).Parent = fill end
				local obj = {}
				function obj:Set(v, m)
					value = tonumber(v) or value
					maxValue = m or maxValue
					local pct = maxValue > 0 and math.clamp(value / maxValue, 0, 1) or 0
					tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.35)
					valueLbl.Text = o.Format and o.Format(value, maxValue) or (math.floor(pct * 100 + 0.5) .. "%")
				end
				function obj:Get() return value end
				obj.NoSave = true
				obj:Set(value)
				return register("Progress", o, row, obj)
			end

			------------------------------------------------ simple display elements

			function Section:Header(t)
				local row = newRow(24)
				local lbl = text({
					Parent = row, Text = string.upper(tostring(t or "")), TextSize = 11, Weight = "Bold",
					Position = UDim2.fromOffset(0, 4), Size = UDim2.new(0, 0, 1, -4), AutomaticSize = Enum.AutomaticSize.X,
					Theme = { TextColor3 = "Accent" },
				})
				local line = create("Frame", {
					Parent = row, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 2),
					Size = UDim2.new(1, -8, 0, 1), Theme = { BackgroundColor3 = "Stroke" },
				})
				local function fit() line.Size = UDim2.new(1, -(lbl.AbsoluteSize.X / Window.Scale + 10), 0, 1) end
				lbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
				fit()
				return register("Header", { Name = tostring(t or "") }, row, { Set = function(_, v) lbl.Text = string.upper(tostring(v)) end })
			end

			function Section:Space(h)
				return register("Divider", { Name = "" }, newRow(h or 8), {})
			end

			function Section:Value(o)
				if type(o) == "string" then o = { Name = o } end
				local row = newRow(26)
				text({ Parent = row, Text = o.Name or "", Size = UDim2.new(0.55, 0, 1, 0), Theme = { TextColor3 = "SubText" }, TextTruncate = Enum.TextTruncate.AtEnd })
				local v = text({
					Parent = row, Text = tostring(o.Value or ""), Weight = "Medium", TextXAlignment = Enum.TextXAlignment.Right, RichText = true,
					AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.45, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
				})
				local value = o.Value
				local obj = {}
				function obj:SetValue(x)
					value = x
					v.Text = tostring(x)
				end
				function obj:GetValue() return value end
				return register("Value", o, row, obj)
			end

			function Section:Code(o)
				if type(o) == "string" then o = { Text = o } end
				local row = newRow(0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				local box = create("Frame", {
					Parent = row, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
					Theme = { BackgroundColor3 = "Sidebar" },
				}, { corner(8), stroke("Stroke"), padding(9, 38, 9, 10) })
				local lbl = text({
					Parent = box, Text = o.Text or "", TextSize = 12, TextWrapped = true,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Theme = { TextColor3 = "Text" },
				})
				pcall(function() lbl.Font = Enum.Font.RobotoMono end)
				local copy = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false, ZIndex = 2, AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -6, 0, 6), Size = UDim2.fromOffset(24, 24), Theme = { BackgroundColor3 = "Element" },
				}, { corner(6) })
				local copyIcon = Icon("copy", 13, "DimText", { Parent = copy, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
				copy.MouseButton1Click:Connect(function()
					local ok = pcall(function() setclipboard(lbl.Text) end)
					tween(copyIcon, { ImageColor3 = ok and T().Accent or rgb(248, 113, 113) }, 0.15)
					task.delay(0.8, function() tween(copyIcon, { ImageColor3 = T().DimText }, 0.3) end)
				end)
				return register("Code", { Name = o.Name or o.Text or "" }, row, { SetText = function(_, t) lbl.Text = t end })
			end

			function Section:Image(o)
				if type(o) ~= "table" then o = { Image = o } end
				local h = o.Height or 120
				local row = newRow(h + (o.Caption and 20 or 0))
				local img = create("ImageLabel", {
					Parent = row, Size = UDim2.new(1, 0, 0, h), Image = iconImage(o.Image) or tostring(o.Image or ""),
					ScaleType = o.ScaleType or Enum.ScaleType.Crop, Theme = { BackgroundColor3 = "Element" },
				}, { corner(8), stroke("Stroke") })
				if o.Caption then
					text({
						Parent = row, Text = o.Caption, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center,
						Position = UDim2.fromOffset(0, h + 4), Size = UDim2.new(1, 0, 0, 14), Theme = { TextColor3 = "DimText" },
					})
				end
				return register("Image", { Name = o.Caption or "" }, row, {
					SetImage = function(_, i) img.Image = iconImage(i) or tostring(i) end,
				})
			end

			------------------------------------------------ button row

			function Section:Buttons(list)
				local row = newRow(BOX_H + 2)
				create("UIListLayout", {
					Parent = row, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
				})
				local n = #list
				local names = {}
				for i, bo in ipairs(list) do
					table.insert(names, bo.Name or "Button")
					local primary = bo.Style == "Primary"
					local b = create("TextButton", {
						Parent = row, Text = "", AutoButtonColor = false, LayoutOrder = i, ClipsDescendants = true,
						Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
						Theme = (not primary) and { BackgroundColor3 = "Element" } or nil,
					}, { corner(8) })
					if primary then accentGradient(0).Parent = b else stroke("Stroke").Parent = b end
					local sc = create("UIScale", { Parent = b })
					local inner = create("Frame", { Parent = b, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, {
						create("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
						}),
					})
					if bo.Icon and iconImage(bo.Icon) then
						local ic = Icon(bo.Icon, 14, (not primary) and "SubText" or nil, { Parent = inner, LayoutOrder = 1 })
						if primary then ic.ImageColor3 = Color3.new(1, 1, 1) end
					end
					text({
						Parent = inner, Text = bo.Name or "Button", Weight = "Medium", TextSize = 12, LayoutOrder = 2,
						Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, TextTruncate = Enum.TextTruncate.AtEnd,
						Theme = (not primary) and { TextColor3 = "Text" } or false, TextColor3 = Color3.new(1, 1, 1),
					})
					b.MouseEnter:Connect(function()
						if primary then tween(b, { BackgroundTransparency = 0.12 }) else tween(b, { BackgroundColor3 = T().ElementHover }) end
					end)
					b.MouseLeave:Connect(function()
						if primary then tween(b, { BackgroundTransparency = 0 }) else tween(b, { BackgroundColor3 = T().Element }) end
						tween(sc, { Scale = 1 }, 0.2)
					end)
					b.MouseButton1Down:Connect(function() tween(sc, { Scale = 0.96 }, 0.1) end)
					b.MouseButton1Up:Connect(function() tween(sc, { Scale = 1 }, 0.3, Enum.EasingStyle.Back) end)
					b.MouseButton1Click:Connect(function()
						if suppressed() then return end
						if bo.Confirm then
							Window:Dialog({
								Title = type(bo.Confirm) == "string" and bo.Confirm or ("Run \"" .. (bo.Name or "this") .. "\"?"),
								Buttons = { { Title = "Cancel" }, { Title = "Confirm", Primary = true, Callback = bo.Callback } },
							})
						else
							safeCall(bo.Callback)
						end
					end)
				end
				return register("Buttons", { Name = table.concat(names, " ") }, row, {})
			end

			------------------------------------------------ radio group

			function Section:Radio(o)
				local options = o.Options or {}
				local value = o.Default
				local row = newRow(0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				create("UIListLayout", { Parent = row, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
				if o.Name then
					local head = create("Frame", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 0 })
					titleBlock(head, o.Name, nil, 0, 2, o.Tooltip)
				end
				local items = {}
				local obj = {}
				local function render(animate)
					for _, it in ipairs(items) do
						local on = it.Value == value
						set(it.Dot, { BackgroundTransparency = on and 0 or 1 }, animate, 0.2)
						set(it.DotScale, { Scale = on and 1 or 0.3 }, animate, 0.3, Enum.EasingStyle.Back)
						set(it.Label, { TextColor3 = on and T().Text or T().SubText }, animate, 0.2)
					end
				end
				for i, opt in ipairs(options) do
					local b = create("TextButton", {
						Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, LayoutOrder = i,
						Size = UDim2.new(1, 0, 0, MOBILE and 30 or 26),
					})
					local ring = create("Frame", {
						Parent = b, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.fromOffset(16, 16),
					}, { corner(8), stroke("StrokeLight", 1.5) })
					local dot = create("Frame", {
						Parent = ring, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(8, 8), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
					}, { corner(4), accentGradient(45) })
					local dotScale = create("UIScale", { Parent = dot, Scale = 0.3 })
					local l = text({
						Parent = b, Text = tostring(opt), Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0),
						Theme = false, TextColor3 = T().SubText,
					})
					table.insert(items, { Value = opt, Dot = dot, DotScale = dotScale, Label = l })
					b.MouseButton1Click:Connect(function()
						if suppressed() then return end
						obj:Set(opt)
					end)
				end
				function obj:Set(v, silent)
					value = v
					render(true)
					if o.Flag then OrcaHub.Flags[o.Flag] = value end
					if not silent then safeCall(o.Callback, value) end
				end
				function obj:Get() return value end
				table.insert(Refreshers, function() render(false) end)
				render(false)
				if o.Flag then OrcaHub.Flags[o.Flag] = value end
				return register("Radio", o, row, obj)
			end

			------------------------------------------------ number input with - / + buttons

			function Section:Number(o)
				local min, max = o.Min or -math.huge, o.Max or math.huge
				local step = o.Step or o.Increment or 1
				local suffix = o.Suffix or ""
				local decimals = 0
				local dot = string.find(tostring(step), ".", 1, true)
				if dot then decimals = #tostring(step) - dot end
				local value = math.clamp(o.Default or (min > -math.huge and min or 0), min, max)
				local row = newRow(ROW_H)
				local title = titleBlock(row, o.Name or "Number", nil, 124, nil, o.Tooltip)
				local box = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(116, 26),
					Theme = { BackgroundColor3 = "Element" },
				}, { corner(7), stroke("Stroke") })
				local function stepButton(iconName, anchorX)
					local b = create("TextButton", {
						Parent = box, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(anchorX, 0.5), Position = UDim2.new(anchorX, 0, 0.5, 0), Size = UDim2.fromOffset(28, 26),
						Theme = { BackgroundColor3 = "ElementHover" },
					}, { corner(7) })
					local ic = Icon(iconName, 13, "SubText", { Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
					b.MouseEnter:Connect(function()
						tween(b, { BackgroundTransparency = 0 }, 0.12)
						tween(ic, { ImageColor3 = T().Accent }, 0.12)
					end)
					b.MouseLeave:Connect(function()
						tween(b, { BackgroundTransparency = 1 }, 0.15)
						tween(ic, { ImageColor3 = T().SubText }, 0.15)
					end)
					return b
				end
				local minus = stepButton("minus", 0)
				local plus = stepButton("plus", 1)
				local input = text({
					Class = "TextBox", Parent = box, Text = "", TextSize = 12, ClearTextOnFocus = false, Weight = "Medium",
					TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -56, 1, 0),
				})
				local function format(n) return string.format("%." .. decimals .. "f", n) end
				local obj = {}
				function obj:Set(v, silent)
					v = tonumber(v) or value
					v = math.clamp(v, min, max)
					v = tonumber(format(math.floor(v / step + 0.5) * step))
					v = math.clamp(v, min, max)
					local changed = v ~= value
					value = v
					input.Text = format(v) .. suffix
					if o.Flag then OrcaHub.Flags[o.Flag] = value end
					if changed and not silent then safeCall(o.Callback, value) end
				end
				function obj:Get() return value end
				minus.MouseButton1Click:Connect(function() obj:Set(value - step) end)
				plus.MouseButton1Click:Connect(function() obj:Set(value + step) end)
				input.FocusLost:Connect(function()
					obj:Set(tonumber((string.gsub(input.Text, "[^%d%.%-]", ""))) or value)
				end)
				obj:Set(value, true)
				if o.Flag then OrcaHub.Flags[o.Flag] = value end
				return register("Number", o, row, obj)
			end

			------------------------------------------------ range slider (two handles)

			function Section:Range(o)
				local min, max = o.Min or 0, o.Max or 100
				local inc = o.Increment or 1
				local suffix = o.Suffix or ""
				local decimals = 0
				local dot = string.find(tostring(inc), ".", 1, true)
				if dot then decimals = #tostring(inc) - dot end
				local lo = (o.Default and o.Default[1]) or min
				local hi = (o.Default and o.Default[2]) or max
				local row = newRow(ROW_H + 18)
				local title = titleBlock(row, o.Name or "Range", nil, 110, 2, o.Tooltip)
				local valueLbl = text({
					Parent = row, Text = "", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0,
					AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(0, 22),
					AutomaticSize = Enum.AutomaticSize.X, Theme = { BackgroundColor3 = "Element", TextColor3 = "Text" },
				})
				corner(6).Parent = valueLbl
				padding(0, 8, 0, 8).Parent = valueLbl
				local bar = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, 0, 0, 6),
					Theme = { BackgroundColor3 = "ToggleOff" },
				}, { corner(3) })
				local fill = create("Frame", { Parent = bar, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(0, 1) }, { corner(3), accentGradient(0) })
				local function knob()
					local k = create("Frame", {
						Parent = bar, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
						ZIndex = 2, Theme = { BackgroundColor3 = "Knob" },
					}, { corner(7) })
					create("UIStroke", { Parent = k, Thickness = 2, Theme = { Color = "Accent" } })
					return k
				end
				local kLo, kHi = knob(), knob()
				local hit = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, MOBILE and 26 or 22),
				})
				rowHover(row, hit)
				hoverTitle(hit, title, function() return false end)
				local function format(n) return string.format("%." .. decimals .. "f", n) end
				local function snap(n)
					n = math.floor((n - min) / inc + 0.5) * inc + min
					return tonumber(format(math.clamp(n, min, max)))
				end
				local obj = {}
				local function render()
					local a = max == min and 0 or (lo - min) / (max - min)
					local b = max == min and 0 or (hi - min) / (max - min)
					kLo.Position = UDim2.fromScale(a, 0.5)
					kHi.Position = UDim2.fromScale(b, 0.5)
					fill.Position = UDim2.fromScale(a, 0)
					fill.Size = UDim2.fromScale(b - a, 1)
					valueLbl.Text = format(lo) .. suffix .. "  -  " .. format(hi) .. suffix
				end
				function obj:Set(v, silent)
					if type(v) ~= "table" then return end
					local a, b = snap(tonumber(v[1]) or lo), snap(tonumber(v[2]) or hi)
					if a > b then a, b = b, a end
					local changed = a ~= lo or b ~= hi
					lo, hi = a, b
					render()
					if o.Flag then OrcaHub.Flags[o.Flag] = { lo, hi } end
					if changed and not silent then safeCall(o.Callback, lo, hi) end
				end
				function obj:Get() return { lo, hi } end
				hit.InputBegan:Connect(function(input)
					if not isPress(input) then return end
					page.ScrollingEnabled = false
					local function valueAt(x)
						return min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					end
					local v0 = valueAt(input.Position.X)
					local moveLow = math.abs(v0 - lo) <= math.abs(v0 - hi)
					if lo == hi then moveLow = v0 < lo end
					local function update(x)
						local v = snap(valueAt(x))
						if moveLow then obj:Set({ math.min(v, hi), hi }) else obj:Set({ lo, math.max(v, lo) }) end
					end
					update(input.Position.X)
					Pointer.track(input, function(pos) update(pos.X) end, function() page.ScrollingEnabled = true end)
				end)
				render()
				if o.Flag then OrcaHub.Flags[o.Flag] = { lo, hi } end
				return register("Range", o, row, obj)
			end

			------------------------------------------------ multi-line text box

			function Section:TextArea(o)
				local lines = o.Lines or 4
				local h = lines * 16 + 16
				local row = newRow(h + 22)
				titleBlock(row, o.Name or "Text", nil, 0, 0, o.Tooltip)
				local box = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, h),
					Theme = { BackgroundColor3 = "Element" },
				}, { corner(8) })
				local boxStroke = stroke("Stroke")
				boxStroke.Parent = box
				local input = text({
					Class = "TextBox", Parent = box, Text = o.Default or "", PlaceholderText = o.Placeholder or "Type here...",
					ClearTextOnFocus = false, MultiLine = true, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
					Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 1, -16),
					Theme = { TextColor3 = "Text", PlaceholderColor3 = "DimText" },
				})
				input.Focused:Connect(function() tween(boxStroke, { Color = T().Accent }) end)
				local obj = {}
				function obj:Set(v, silent)
					input.Text = tostring(v or "")
					if o.Flag then OrcaHub.Flags[o.Flag] = input.Text end
					if not silent then safeCall(o.Callback, input.Text) end
				end
				function obj:Get() return input.Text end
				input.FocusLost:Connect(function()
					tween(boxStroke, { Color = T().Stroke })
					if o.Flag then OrcaHub.Flags[o.Flag] = input.Text end
					safeCall(o.Callback, input.Text)
				end)
				if o.Flag then OrcaHub.Flags[o.Flag] = input.Text end
				return register("TextArea", o, row, obj)
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
				local inner = create("Frame", {
					Parent = b, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
				}, {
					create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})
				if o.Icon and iconImage(o.Icon) then
					local ic = Icon(o.Icon, 15, (not primary) and "SubText" or nil, { Parent = inner, LayoutOrder = 1 })
					if primary then ic.ImageColor3 = Color3.new(1, 1, 1) end
				end
				text({
					Parent = inner, Text = o.Name or "Button", Weight = "Medium", LayoutOrder = 2,
					Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X,
					Theme = (not primary) and { TextColor3 = "Text" } or false, TextColor3 = Color3.new(1, 1, 1),
				})
				if o.Tooltip then
					b.MouseEnter:Connect(function() Window:_showTip(b, o.Tooltip) end)
					b.MouseLeave:Connect(function() Window:_hideTip() end)
				end

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
				local obj = {}
				function obj:Fire() safeCall(o.Callback) end
				b.MouseButton1Click:Connect(function()
					if suppressed() then return end
					if o.Confirm then
						Window:Dialog({
							Title = type(o.Confirm) == "string" and o.Confirm or ("Run \"" .. (o.Name or "this") .. "\"?"),
							Buttons = { { Title = "Cancel" }, { Title = "Confirm", Primary = true, Callback = o.Callback } },
						})
					else
						safeCall(o.Callback)
					end
				end)
				return register("Button", o, row, obj)
			end

			------------------------------------------------ toggle (+ keybind / colour add-ons)

			function Section:Toggle(o)
				local state = o.Default == true
				local row = newRow(o.Description and ROW_H + 12 or ROW_H)
				local hit = create("TextButton", { Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
				rowHover(row, hit)
				local checkbox = o.Style == "Checkbox"
				local switchW = checkbox and 20 or 40
				local title, titleHolder = titleBlock(row, o.Name or "Toggle", o.Description, switchW + 16, nil, o.Tooltip)
				local switch = create("Frame", {
					Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(switchW, checkbox and 20 or 22), Theme = { BackgroundColor3 = "ToggleOff" },
				}, { corner(checkbox and 6 or 11) })
				if checkbox then stroke("StrokeLight").Parent = switch end
				local fill = create("Frame", {
					Parent = switch, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
				}, { corner(checkbox and 6 or 11), accentGradient(checkbox and 45 or 0) })
				local knob, check, checkScale
				if checkbox then
					check = Icon("check", 14, nil, {
						Parent = switch, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
						ImageColor3 = Color3.new(1, 1, 1), ImageTransparency = 1, ZIndex = 2,
					})
					checkScale = create("UIScale", { Parent = check, Scale = 0.6 })
				else
					knob = create("Frame", {
						Parent = switch, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16),
						ZIndex = 2, Theme = { BackgroundColor3 = "Knob" },
					}, { corner(8) })
				end
				local addons = create("Frame", {
					Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -(switchW + 8), 0.5, 0), Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
				}, {
					create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})
				local function fitTitle()
					titleHolder.Size = UDim2.new(1, -(switchW + 16 + addons.AbsoluteSize.X / Window.Scale + 6), 1, 0)
				end
				addons:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTitle)

				local obj = {}
				local function render(animate)
					set(fill, { BackgroundTransparency = state and 0 or 1 }, animate, 0.25)
					if checkbox then
						set(check, { ImageTransparency = state and 0 or 1 }, animate, 0.2)
						set(checkScale, { Scale = state and 1 or 0.6 }, animate, 0.35, Enum.EasingStyle.Back)
					else
						set(knob, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, animate, 0.4, Enum.EasingStyle.Back)
					end
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

				function obj:AddKeybind(ko)
					ko = ko or {}
					ko.Name = ko.Name or o.Name
					local mode = ko.Mode or "Toggle"
					local ctl = keybindControl(addons, ko, function()
						if mode == "Hold" then obj:Set(true) else obj:Set(not state) end
						safeCall(ko.Callback, state)
					end, mode == "Hold" and function() obj:Set(false) end or nil)
					ctl.Entry.IsActive = function() return state end
					if ko.Flag then OrcaHub.Options[ko.Flag] = ctl end
					fitTitle()
					return ctl
				end
				function obj:AddColorpicker(co)
					co = co or {}
					co.Small = true
					local ctl = colorControl(addons, co)
					if co.Flag then OrcaHub.Options[co.Flag] = ctl end
					fitTitle()
					return ctl
				end
				obj.AddColorPicker = obj.AddColorpicker

				hoverTitle(hit, title, function() return state end)
				hit.MouseButton1Click:Connect(function()
					if suppressed() then return end
					obj:Set(not state)
				end)
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
				local title = titleBlock(row, o.Name or "Slider", nil, 70, 2, o.Tooltip)
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
				create("UIStroke", { Parent = knob, Thickness = 2, Theme = { Color = "Accent" } })
				local hit = create("TextButton", {
					Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, MOBILE and 26 or 22),
				})
				rowHover(row, hit)
				hoverTitle(hit, title, function() return false end)

				local function format(n)
					return string.format("%." .. decimals .. "f", n)
				end

				local obj = {}
				function obj:Set(n, silent)
					n = tonumber(n) or value
					n = math.floor((n - min) / inc + 0.5) * inc + min
					n = tonumber(format(math.clamp(n, min, max)))
					local changed = n ~= value
					value = n
					local pct = max == min and 0 or (n - min) / (max - min)
					tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.12)
					valueBox.Text = format(n) .. suffix
					if o.Flag then OrcaHub.Flags[o.Flag] = n end
					if changed and not silent then safeCall(o.Callback, n) end
				end
				function obj:Get() return value end

				local function update(x)
					local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					obj:Set(min + (max - min) * pct, o.OnRelease)
				end
				hit.InputBegan:Connect(function(input)
					if not isPress(input) then return end
					page.ScrollingEnabled = false
					tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.2, Enum.EasingStyle.Back)
					update(input.Position.X)
					Pointer.track(input, function(pos) update(pos.X) end, function()
						page.ScrollingEnabled = true
						tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.2)
						if o.OnRelease then safeCall(o.Callback, value) end
					end)
				end)
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
				titleBlock(row, o.Name or "Input", nil, 0, 0, o.Tooltip)
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
				titleBlock(row, o.Name or "Dropdown", nil, 0, 0, o.Tooltip)
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
					local frame, closeFrame, reposition = popupAt(head, width, listH + searchH)
					tween(chevron, { Rotation = 180 }, 0.25)
					tween(headStroke, { Color = T().Accent }, 0.2)
					Window:_openPopup({
						Close = function()
							open = false
							tween(chevron, { Rotation = 0 }, 0.25)
							tween(headStroke, { Color = T().Stroke }, 0.2)
							closeFrame()
						end,
						Reposition = reposition,
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
					if suppressed() then return end
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

			------------------------------------------------ keybind / colour picker rows

			function Section:Keybind(o)
				local row = newRow(ROW_H)
				local hit = create("TextButton", { Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
				rowHover(row, hit)
				local title = titleBlock(row, o.Name or "Keybind", nil, 90, nil, o.Tooltip)
				local ctl
				local pillBtn
				ctl, pillBtn = keybindControl(row, o, function() safeCall(o.Callback, ctl:Get()) end)
				pillBtn.AnchorPoint = Vector2.new(1, 0.5)
				pillBtn.Position = UDim2.new(1, 0, 0.5, 0)
				hoverTitle(hit, title, function() return false end)
				return register("Keybind", o, row, ctl)
			end

			function Section:Colorpicker(o)
				local row = newRow(ROW_H)
				local hit = create("TextButton", { Parent = row, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
				rowHover(row, hit)
				local title = titleBlock(row, o.Name or "Color", nil, 60, nil, o.Tooltip)
				local ctl, swatch = colorControl(row, o)
				swatch.AnchorPoint = Vector2.new(1, 0.5)
				swatch.Position = UDim2.new(1, 0, 0.5, 0)
				hoverTitle(hit, title, function() return false end)
				return register("Colorpicker", o, row, ctl)
			end
			Section.ColorPicker = Section.Colorpicker

			function Section:PlayerDropdown(o)
				o = o or {}
				local function names()
					local out = {}
					for _, p in ipairs(Players:GetPlayers()) do
						if not (o.ExcludeLocal ~= false and p == LocalPlayer) then table.insert(out, p.Name) end
					end
					table.sort(out)
					return out
				end
				local copy = {}
				for k, v in pairs(o) do copy[k] = v end
				copy.Name = o.Name or "Player"
				copy.Options = names()
				local dd = Section:Dropdown(copy)
				track(Players.PlayerAdded:Connect(function() dd:Refresh(names(), true) end))
				track(Players.PlayerRemoving:Connect(function() task.defer(function() dd:Refresh(names(), true) end) end))
				return dd
			end

			Section.Textbox = Section.Input
			Section.TextBox = Section.Input
			Section.TextLabel = Section.Label

			return Section
		end

		return C
	end

	---------------------------------------------------------------- tabs

	function Window:Tab(o)
		o = o or {}
		local Tab = {
			Name = o.Name or "Tab",
			Description = o.Description or "",
			Containers = {},
			SubTabs = {},
			Window = Window,
		}

		local btn = create("TextButton", {
			Parent = tabList, Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, TAB_H), LayoutOrder = o._order or nextOrder(),
		})
		Tab.Button = btn
		Tab.Built = o.Build == nil
		function Tab:_ensureBuilt()
			if Tab.Built then return end
			Tab.Built = true
			local ok, err = pcall(o.Build, Tab)
			if not ok then warn("[OrcaHub] error building tab \"" .. Tab.Name .. "\": " .. tostring(err)) end
		end
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
		local iconFade = iconInst:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
		local label = text({
			Parent = btn, Text = Tab.Name, TextSize = 13, Weight = "Medium",
			Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -74, 1, 0),
			Theme = false, TextColor3 = T().SubText, TextTransparency = Window.Compact and 1 or 0,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		table.insert(fadeLabels, label)
		local badge = text({
			Parent = btn, Text = "", TextSize = 10, Weight = "Bold", TextXAlignment = Enum.TextXAlignment.Center,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(0, 16),
			AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0, Visible = false, ZIndex = 2,
			BackgroundColor3 = Color3.new(1, 1, 1), TextColor3 = Color3.new(1, 1, 1), Theme = false,
		})
		corner(8).Parent = badge
		padding(0, 5, 0, 5).Parent = badge
		accentGradient(0).Parent = badge

		local tabPage = create("Frame", {
			Parent = pages, BackgroundTransparency = 1, Visible = false, Size = UDim2.fromScale(1, 1),
		})
		Tab.Page = tabPage

		local function renderTab(active, animate)
			set(label, { TextColor3 = active and T().Text or T().SubText }, animate)
			set(iconInst, { [iconProp] = active and T().Accent or T().DimText }, animate)
		end
		table.insert(Refreshers, function() renderTab(Window.CurrentTab == Tab, false) end)

		local customBadge = o.Badge
		function Tab:SetBadge(t)
			customBadge = t
			Tab:_setBadge(nil)
		end
		function Tab:SetHidden(v)
			Tab.Hidden = v
			btn.Visible = not v
			if v and Window.CurrentTab == Tab then
				for _, t in ipairs(Window.Tabs) do
					if t ~= Tab and not t.Hidden then
						t:Select()
						break
					end
				end
			end
			task.defer(function() Window:_moveIndicator(false) end)
		end
		function Tab:_setBadge(n)
			if n == nil and customBadge then
				badge.Visible = not Window.Compact
				badge.Text = tostring(customBadge)
				set(label, { TextTransparency = Window.Compact and 1 or 0 }, true, 0.15)
				set(iconInst, { [iconFade] = 0 }, true, 0.15)
				return
			end
			badge.Visible = n ~= nil and n > 0 and not Window.Compact
			badge.Text = tostring(n or "")
			local dim = n ~= nil and n == 0
			set(label, { TextTransparency = Window.Compact and 1 or (dim and 0.6 or 0) }, true, 0.15)
			set(iconInst, { [iconFade] = dim and 0.6 or 0 }, true, 0.15)
		end

		btn.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then tween(label, { TextColor3 = T().Text }) end
			if Window.Compact and not MOBILE then
				local pos = Window:_toMain(btn.AbsolutePosition)
				sideTip.Text = Tab.Name
				sideTip.Position = UDim2.fromOffset(SIDEBAR_COMPACT + 6, pos.Y + (TAB_H - 26) / 2)
				sideTip.Visible = true
			end
		end)
		btn.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then tween(label, { TextColor3 = T().SubText }) end
			sideTip.Visible = false
		end)

		local function makePage(parent, top)
			return create("ScrollingFrame", {
				Parent = parent, BackgroundTransparency = 1, BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, top or 0), Size = UDim2.new(1, 0, 1, -(top or 0)), CanvasSize = UDim2.new(),
				ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
				Theme = { ScrollBarImageColor3 = "StrokeLight" },
			})
		end

		-- the tab's own page (used when the tab has no sub-tabs)
		local mainPage = makePage(tabPage)
		local mainContainer = Container(mainPage, Tab.Name)
		mainContainer.Tab = Tab
		table.insert(Tab.Containers, mainContainer)
		Tab.ActiveContainer = mainContainer

		function Tab:_relayout(animate)
			for _, c in ipairs(Tab.Containers) do c:_layout(animate) end
		end

		function Tab:Select()
			if Window.CurrentTab == Tab then return end
			Window:_closePopup()
			Window:_hideTip()
			local prev = Window.CurrentTab
			Window.CurrentTab = Tab
			if prev then
				prev:_render(false)
				prev.Page.Visible = false
			end
			renderTab(true, true)
			pageTitle.Text = Tab.Name
			pageDesc.Text = Tab.Description
			pageTitle.Position = UDim2.fromOffset(52, (Tab.Description == "" or MOBILE) and (TOPBAR_H / 2 - 10) or 11)
			pageTitle.TextTransparency = 1
			pageDesc.TextTransparency = 1
			tween(pageTitle, { TextTransparency = 0 }, 0.3)
			tween(pageDesc, { TextTransparency = 0 }, 0.4)

			tabPage.Visible = true
			tabPage.Position = UDim2.fromOffset(0, 16)
			tween(tabPage, { Position = UDim2.fromOffset(0, 0) }, 0.4)
			pageCover.Visible = true
			pageCover.BackgroundTransparency = 0
			tween(pageCover, { BackgroundTransparency = 1 }, 0.3).Completed:Connect(function()
				if pageCover.BackgroundTransparency >= 1 then pageCover.Visible = false end
			end)

			Tab:_ensureBuilt()
			Tab:_relayout(false)
			task.defer(function() Window:_moveIndicator(prev ~= nil) end)
		end

		function Tab:_render(active) renderTab(active, true) end

		function Tab:_setNav(nav)
			if nav then
				btn.Size = UDim2.new(0, 64, 1, 0)
				iconInst.AnchorPoint, iconInst.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, -7)
				label.Position, label.Size = UDim2.new(0, 2, 1, -16), UDim2.new(1, -4, 0, 14)
				label.TextSize = 10
				label.TextXAlignment = Enum.TextXAlignment.Center
				label.TextTransparency = 0
				badge.Position = UDim2.new(1, -4, 0, 8)
			else
				btn.Size = UDim2.new(1, 0, 0, TAB_H)
				iconInst.AnchorPoint, iconInst.Position = Vector2.new(0, 0.5), UDim2.new(0, 13, 0.5, 0)
				label.Position, label.Size = UDim2.fromOffset(42, 0), UDim2.new(1, -74, 1, 0)
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextTransparency = Window.Compact and 1 or 0
				badge.Position = UDim2.new(1, -8, 0.5, 0)
			end
		end
		if Window.NavMode then Tab:_setNav(true) end

		btn.MouseButton1Click:Connect(function() Tab:Select() end)

		function Tab:Section(so)
			return mainContainer:Section(so)
		end

		---------------------------------------------------- sub-tabs

		local subBar, subPill, subList
		local function ensureSubBar()
			if subBar then return end
			mainPage.Visible = false
			subBar = create("Frame", {
				Parent = tabPage, Position = UDim2.fromOffset(PAD, 10), Size = UDim2.new(1, -PAD * 2, 0, SUBTAB_H),
				Theme = { BackgroundColor3 = "Sidebar" },
			}, { corner(9), stroke("Stroke") })
			subPill = create("Frame", {
				Parent = subBar, Position = UDim2.fromOffset(3, 3), Size = UDim2.new(0, 0, 1, -6),
				Theme = { BackgroundColor3 = "Element" },
			}, { corner(7), stroke("StrokeLight") })
			create("Frame", {
				Parent = subPill, BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -2), Size = UDim2.new(0.5, 0, 0, 2),
			}, { corner(1), accentGradient(0) })
			subList = create("Frame", {
				Parent = subBar, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2,
			}, {
				create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }),
				padding(3, 3, 3, 3),
			})
		end

		local function movePill(animate)
			local active
			for i, st in ipairs(Tab.SubTabs) do
				if st.Container == Tab.ActiveContainer then active = i end
			end
			if not active then return end
			local w = (subBar.AbsoluteSize.X / Window.Scale - 6) / #Tab.SubTabs
			set(subPill, { Position = UDim2.fromOffset(3 + (active - 1) * w, 3), Size = UDim2.new(0, w, 1, -6) }, animate, 0.35)
		end

		function Tab:SubTab(so)
			so = so or {}
			ensureSubBar()
			local Sub = { Name = so.Name or "Sub" }
			local b = text({
				Class = "TextButton", Parent = subList, Text = Sub.Name, AutoButtonColor = false, Weight = "Medium",
				TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = #Tab.SubTabs + 1,
				Theme = false, TextColor3 = T().SubText,
			})
			Sub.Button = b
			local subBadge = text({
				Parent = b, Text = "", TextSize = 10, Weight = "Bold", TextXAlignment = Enum.TextXAlignment.Center,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(0, 14),
				AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0, Visible = false,
				BackgroundColor3 = Color3.new(1, 1, 1), TextColor3 = Color3.new(1, 1, 1), Theme = false,
			})
			corner(7).Parent = subBadge
			padding(0, 4, 0, 4).Parent = subBadge
			accentGradient(0).Parent = subBadge

			local subPage = makePage(tabPage, SUBTAB_H + 14)
			subPage.Visible = false
			local container = Container(subPage, Tab.Name .. "/" .. Sub.Name, function(n)
				subBadge.Visible = n ~= nil and n > 0
				subBadge.Text = tostring(n or "")
				set(b, { TextTransparency = (n ~= nil and n == 0) and 0.6 or 0 }, true, 0.15)
			end)
			Sub.Container = container
			Sub.Page = subPage
			container.Tab = Tab
			container.Sub = Sub
			table.insert(Tab.Containers, container)
			table.insert(Tab.SubTabs, Sub)
			for _, st in ipairs(Tab.SubTabs) do
				st.Button.Size = UDim2.new(1 / #Tab.SubTabs, 0, 1, 0)
			end

			function Sub:Select()
				for _, other in ipairs(Tab.SubTabs) do
					other.Page.Visible = other == Sub
					tween(other.Button, { TextColor3 = other == Sub and T().Text or T().SubText }, 0.2)
				end
				Tab.ActiveContainer = container
				Window:_closePopup()
				subPage.Position = UDim2.fromOffset(0, SUBTAB_H + 24)
				tween(subPage, { Position = UDim2.fromOffset(0, SUBTAB_H + 14) }, 0.35)
				container:_layout(false)
				task.defer(function() movePill(true) end)
			end
			b.MouseButton1Click:Connect(function() Sub:Select() end)
			b.MouseEnter:Connect(function() if Tab.ActiveContainer ~= container then tween(b, { TextColor3 = T().Text }) end end)
			b.MouseLeave:Connect(function() if Tab.ActiveContainer ~= container then tween(b, { TextColor3 = T().SubText }) end end)
			table.insert(Refreshers, function() b.TextColor3 = Tab.ActiveContainer == container and T().Text or T().SubText end)

			function Sub:Section(o2) return container:Section(o2) end
			if #Tab.SubTabs == 1 then
				subBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() movePill(false) end)
				Sub:Select()
			else
				task.defer(function() movePill(false) end)
			end
			return Sub
		end

		table.insert(Window.Tabs, Tab)
		if customBadge then Tab:_setBadge(nil) end
		if #Window.Tabs == 1 then Tab:Select() end
		return Tab
	end

	---------------------------------------------------------------- floating panels

	local panelCount = 0
	function Window:Panel(o)
		o = o or {}
		panelCount = panelCount + 1
		local width = o.Width or 230
		local frame = create("Frame", {
			Parent = screen, Position = o.Position or UDim2.fromOffset(20, 80 + (panelCount - 1) * 30), Size = UDim2.fromOffset(width, 0),
			AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 5, Theme = { BackgroundColor3 = "Section" },
		}, { corner(10), stroke("StrokeLight") })
		create("UIScale", { Parent = frame, Scale = MOBILE and 0.9 or 1 })
		create("UIListLayout", { Parent = frame, SortOrder = Enum.SortOrder.LayoutOrder })
		local header = create("Frame", { Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 0 })
		local x = 12
		if o.Icon and iconImage(o.Icon) then
			Icon(o.Icon, 15, "Accent", { Parent = header, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0) })
			x = 34
		end
		local titleLbl = text({
			Parent = header, Text = o.Title or "Panel", Weight = "SemiBold", Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x - 12, 1, 0),
		})
		create("Frame", {
			Parent = header, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
			Theme = { BackgroundColor3 = "Stroke" },
		})
		local body = create("Frame", {
			Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1,
		}, {
			create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
			padding(10, 12, 12, 12),
		})

		header.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			local start = vec2(input.Position)
			local startPos = frame.Position
			Pointer.track(input, function(pos)
				local d = pos - start
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end)
		end)

		local P = { Frame = frame }
		local rows = 0
		local function nextRow(h)
			rows = rows + 1
			return create("Frame", { Parent = body, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h), LayoutOrder = rows })
		end
		function P:SetTitle(t) titleLbl.Text = t end
		function P:SetVisible(v) frame.Visible = v end
		function P:Destroy() frame:Destroy() end
		function P:Text(t)
			local row = nextRow(0)
			row.AutomaticSize = Enum.AutomaticSize.Y
			local l = text({
				Parent = row, Text = t or "", TextSize = 12, TextWrapped = true, RichText = true,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Theme = { TextColor3 = "SubText" },
			})
			return { Set = function(_, v) l.Text = v end, Row = row }
		end
		function P:Row(name, value)
			local row = nextRow(16)
			text({ Parent = row, Text = name or "", TextSize = 12, Size = UDim2.new(0.5, 0, 1, 0), Theme = { TextColor3 = "DimText" } })
			local v = text({
				Parent = row, Text = tostring(value or ""), TextSize = 12, Weight = "Medium", TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.5, 0, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd, Theme = false, TextColor3 = T().Text,
			})
			local r = { Row = row }
			function r:Set(val, color)
				v.Text = tostring(val)
				v.TextColor3 = color or T().Text
			end
			return r
		end
		function P:Bar(bo)
			bo = bo or {}
			local row = nextRow(18)
			local barBg = create("Frame", {
				Parent = row, Size = UDim2.fromScale(1, 1), Theme = { BackgroundColor3 = "ToggleOff" },
			}, { corner(5) })
			local fill = create("Frame", { Parent = barBg, BackgroundColor3 = bo.Color or Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1) }, { corner(5) })
			if not bo.Color then accentGradient(0).Parent = fill end
			local lbl = text({
				Parent = barBg, Text = "", TextSize = 11, Weight = "SemiBold", TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1), ZIndex = 2, Theme = false, TextColor3 = Color3.new(1, 1, 1),
			})
			local r = { Row = row }
			function r:Set(value, max)
				max = max or bo.Max or 100
				local pct = max > 0 and math.clamp(value / max, 0, 1) or 0
				tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.25)
				lbl.Text = string.format("%s / %s", tostring(math.floor(value + 0.5)), tostring(max))
			end
			r:Set(bo.Value or 0, bo.Max)
			return r
		end
		function P:Clear()
			for _, c in ipairs(body:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() end
			end
		end
		frame.BackgroundTransparency = 1
		tween(frame, { BackgroundTransparency = 0 }, 0.3)
		return P
	end

	function Window:Watermark(o)
		o = o or {}
		local frame = create("Frame", {
			Parent = screen, Position = o.Position or (MOBILE and UDim2.new(0.5, 0, 0, 10) or UDim2.fromOffset(16, 16)),
			AnchorPoint = MOBILE and Vector2.new(0.5, 0) or Vector2.new(0, 0),
			Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6,
			Theme = { BackgroundColor3 = "Section" },
		}, { corner(8), stroke("StrokeLight"), padding(0, 12, 0, 10) })
		create("UIListLayout", {
			Parent = frame, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		})
		create("Frame", {
			Parent = frame, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(3, 14), LayoutOrder = 0,
		}, { corner(2), accentGradient(90) })
		local lbl = text({
			Parent = frame, Text = "", TextSize = 12, Weight = "Medium", Size = UDim2.fromOffset(0, 28),
			AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, RichText = true,
		})

		local custom = o.Text
		local frames, elapsed, fps = 0, 0, 60
		local function ping()
			local ok, value = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return ok and value and math.floor(value) or nil
		end
		local function refresh()
			local parts = { "<b>" .. (custom or opts.Title or "OrcaHub") .. "</b>" }
			if o.ShowFPS ~= false then table.insert(parts, fps .. " fps") end
			if o.ShowPing ~= false then
				local p = ping()
				if p then table.insert(parts, p .. " ms") end
			end
			if o.ShowTime ~= false then table.insert(parts, os.date("%H:%M")) end
			lbl.Text = table.concat(parts, '  <font transparency="0.6">|</font>  ')
		end
		track(RunService.Heartbeat:Connect(function(dt)
			frames = frames + 1
			elapsed = elapsed + dt
			if elapsed >= 0.5 then
				fps = math.floor(frames / elapsed + 0.5)
				frames, elapsed = 0, 0
				if frame.Visible then refresh() end
			end
		end))
		refresh()

		frame.InputBegan:Connect(function(input)
			if not isPress(input) then return end
			local start = vec2(input.Position)
			local startPos = frame.Position
			Pointer.track(input, function(pos)
				local d = pos - start
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end)
		end)

		local W = { Frame = frame }
		function W:SetVisible(v) frame.Visible = v end
		function W:SetText(t)
			custom = t
			refresh()
		end
		function W:Destroy() frame:Destroy() end
		Window.WatermarkObject = W
		return W
	end

	function Window:KeybindList(o)
		o = o or {}
		local panel = self:Panel({
			Title = o.Title or "Keybinds", Icon = o.Icon or "keyboard", Width = o.Width or 200,
			Position = o.Position or UDim2.new(0, 16, 0.5, -60),
		})
		local rowsByEntry = {}
		local elapsed = 0
		local function refresh()
			for _, entry in ipairs(Window.Keybinds) do
				if entry.Key ~= Enum.KeyCode.Unknown then
					local r = rowsByEntry[entry]
					if not r then
						r = panel:Row(entry.Name, "")
						rowsByEntry[entry] = r
					end
					r.Row.Visible = true
					local active = entry.IsActive and entry.IsActive()
					r:Set("[" .. entry.Key.Name .. "]", active and T().Accent or T().SubText)
				elseif rowsByEntry[entry] then
					rowsByEntry[entry].Row.Visible = false
				end
			end
		end
		track(RunService.Heartbeat:Connect(function(dt)
			elapsed = elapsed + dt
			if elapsed >= 0.25 then
				elapsed = 0
				if panel.Frame.Visible then refresh() end
			end
		end))
		refresh()
		Window.KeybindListObject = panel
		return panel
	end

	---------------------------------------------------------------- settings tab

	function Window:CreateSettingsTab(o)
		o = o or {}
		local tab = self:Tab({ Name = o.Name or "Settings", Icon = o.Icon or "settings", Description = "Interface and configs" })
		local ui = tab:Section({ Name = "Interface", Side = "Left", Icon = "palette", Collapsed = false })

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
		ui:Dropdown({
			Name = "Window Size", Options = { "Small", "Medium", "Large", "Fit Screen", "Auto" },
			Tooltip = "Or drag any edge or corner of the window. Double-click the title bar to maximize.",
			Callback = function(v)
				if v == "Small" then Window:SetSize(Vector2.new(620, 400), true)
				elseif v == "Medium" then Window:SetSize(Vector2.new(780, 500), true)
				elseif v == "Large" then Window:SetSize(Vector2.new(980, 620), true)
				elseif v == "Fit Screen" then
					if not Window.Maximized then Window:ToggleMaximize() end
				else
					Window:SetAutoSize()
				end
			end,
		}).NoSave = true
		ui:Dropdown({
			Name = "Window Style", Options = { "Default", "Glass", "Sharp", "Soft" }, Default = OrcaHub.StyleName, Flag = "__OrcaStyle",
			Tooltip = "Glass makes the window see-through and blurs the game behind it.",
			Callback = function(v) OrcaHub:SetStyle(v) end,
		})
		ui:Toggle({ Name = "Compact Sidebar", Default = Window.Compact, Callback = function(v) Window:SetCompact(v) end })
		ui:Toggle({
			Name = "Floating Toggle Button", Default = fabAlways, Flag = "__OrcaFab",
			Tooltip = "A button that stays on screen to open and close the menu.",
			Callback = function(v) Window:SetToggleButtonVisible(v) end,
		})
		ui:Toggle({
			Name = "One Section Open At A Time", Default = Window.Accordion, Flag = "__OrcaAccordion",
			Tooltip = "Opening a section closes the others on the same page. Handy on small screens.",
			Callback = function(v) Window.Accordion = v end,
		})
		ui:Toggle({
			Name = "Watermark", Default = false, Flag = "__OrcaWatermark",
			Callback = function(v)
				if v and not Window.WatermarkObject then Window:Watermark() end
				if Window.WatermarkObject then Window.WatermarkObject:SetVisible(v) end
			end,
		})
		ui:Toggle({
			Name = "Keybind List", Default = false, Flag = "__OrcaKeybindList",
			Callback = function(v)
				if v and not Window.KeybindListObject then Window:KeybindList() end
				if Window.KeybindListObject then Window.KeybindListObject:SetVisible(v) end
			end,
		})
		ui:Button({ Name = "Reset Section Layout", Icon = "rotate-ccw", Callback = function() Window:ResetLayout() end })

		local colours = tab:Section({ Name = "Colours", Side = "Left", Icon = "pipette", Collapsed = false })
		colours:Colorpicker({
			Name = "Accent", Default = OrcaHub.Theme.Accent, Flag = "__OrcaAccent",
			Callback = function(c) OrcaHub:SetTheme({ Accent = c }) end,
		})
		colours:Colorpicker({
			Name = "Accent 2", Default = OrcaHub.Theme.Accent2, Flag = "__OrcaAccent2", Tooltip = "Second colour of the gradients.",
			Callback = function(c) OrcaHub:SetTheme({ Accent2 = c }) end,
		})
		colours:Button({
			Name = "Reset Colours", Icon = "rotate-ccw",
			Callback = function() OrcaHub:SetTheme(OrcaHub.ThemeName) end,
		})

		local share = tab:Section({ Name = "Share Settings", Side = "Right", Icon = "copy", Collapsed = false })
		share:Button({
			Name = "Copy Settings", Icon = "copy",
			Tooltip = "Copies all your settings as text you can send to a friend.",
			Callback = function()
				local ok = pcall(function() setclipboard(OrcaHub:ExportConfig()) end)
				OrcaHub:Notify({
					Title = ok and "Copied" or "Clipboard unavailable",
					Content = ok and "Your settings are on the clipboard." or "Your executor doesn't support setclipboard.",
					Type = ok and "Success" or "Error",
				})
			end,
		})
		share:Input({
			Name = "Paste Settings", Placeholder = "Paste shared settings and press Enter",
			Callback = function(textValue, enter)
				if not enter or textValue == "" then return end
				local ok = OrcaHub:ImportConfig(textValue)
				OrcaHub:Notify({ Title = ok and "Settings applied" or "Invalid settings", Type = ok and "Success" or "Error" })
			end,
		}).NoSave = true

		local cfg = tab:Section({ Name = "Configs", Side = "Right", Icon = "folder", Collapsed = false })
		if not hasFS() then
			cfg:Label("Your executor doesn't support saving files.")
			return tab
		end
		local nameInput = cfg:Input({ Name = "Config Name", Placeholder = "my-config", Icon = "type" })
		nameInput.NoSave = true
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
		Pointer.stop()
		for i = #Refreshers, 1, -1 do Refreshers[i] = nil end
		for inst in pairs(Themed) do Themed[inst] = nil end
		OrcaHub.Options = {}
		self.Visible = false
		self:_updateBlur()
		if OrcaHub.Window == self then OrcaHub.Window = nil end
		OrcaHub.PreviewSize = nil
		if env.__OrcaHubWindow == self then env.__OrcaHubWindow = nil end
		tween(uiScale, { Scale = self.Scale * 0.94 }, 0.2)
		tween(cover, { BackgroundTransparency = 0 }, 0.2)
		task.delay(0.22, function() gui:Destroy() end)
	end

	---------------------------------------------------------------- opening (optional loading screen)

	-- scripts can report real progress while the loading screen is up
	function Window:SetLoadingStatus(status, progress)
		self._loadStatus = status
		self._loadProgress = progress
	end

	if opts.Loading then
		local l = type(opts.Loading) == "table" and opts.Loading or {}
		local steps = l.Steps or { "Preparing interface", "Loading features", "Applying settings" }
		local duration = l.Duration or 2.2
		holder.Visible = false
		Window.Visible = false
		fab.Visible = false
		local loops = {}
		local function loop(inst, props, time, style, reverses)
			local tw = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, reverses or false), props)
			tw:Play()
			table.insert(loops, tw)
		end

		local backdrop = create("Frame", {
			Parent = screen, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 49,
		})
		local splash = create("Frame", {
			Parent = screen, AnchorPoint = Vector2.new(0.5, 0.5), Position = holder.Position,
			Size = UDim2.fromOffset(320, 214), ZIndex = 50, ClipsDescendants = true,
			Theme = { BackgroundColor3 = "Section" },
		})
		local splashCorner = corner(18)
		splashCorner.Parent = splash
		local splashStroke = create("UIStroke", { Parent = splash, Color = Color3.new(1, 1, 1), Thickness = 1.5 })
		local sweep = create("UIGradient", {
			Parent = splashStroke,
			Theme = {
				Color = function(t)
					return ColorSequence.new({
						ColorSequenceKeypoint.new(0, t.StrokeLight), ColorSequenceKeypoint.new(0.42, t.Accent),
						ColorSequenceKeypoint.new(0.5, t.Accent2), ColorSequenceKeypoint.new(0.58, t.StrokeLight),
						ColorSequenceKeypoint.new(1, t.StrokeLight),
					})
				end,
			},
		})
		loop(sweep, { Rotation = 360 }, 2.4)
		local splashScale = create("UIScale", { Parent = splash, Scale = 0.85 })
		local body = create("Frame", { Parent = splash, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })

		-- logo with a spinning progress ring
		local ringHolder = create("Frame", {
			Parent = body, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 24),
			Size = UDim2.fromOffset(78, 78),
		})
		local track = create("Frame", { Parent = ringHolder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, { corner(39) })
		create("UIStroke", { Parent = track, Thickness = 3, Transparency = 0.5, Theme = { Color = "StrokeLight" } })
		local ring = create("Frame", { Parent = ringHolder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, { corner(39) })
		local ringStroke = create("UIStroke", { Parent = ring, Thickness = 3, Color = Color3.new(1, 1, 1) })
		local ringGradient = create("UIGradient", {
			Parent = ringStroke,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.1),
				NumberSequenceKeypoint.new(0.75, 1), NumberSequenceKeypoint.new(1, 1),
			}),
			Theme = { Color = function(t) return ColorSequence.new(t.Accent, t.Accent2) end },
		})
		loop(ringGradient, { Rotation = 360 }, 1.1)
		local logoTile = create("Frame", {
			Parent = ringHolder, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(52, 52), BackgroundColor3 = Color3.new(1, 1, 1),
		}, { corner(15), accentGradient(45) })
		local logoScale = create("UIScale", { Parent = logoTile })
		loop(logoScale, { Scale = 1.07 }, 0.9, Enum.EasingStyle.Sine, true)
		local logoIcon = Icon(opts.Icon or opts.Logo or "waves", 26, nil, {
			Parent = logoTile, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageColor3 = Color3.new(1, 1, 1),
		})

		local titleLbl = text({
			Parent = body, Text = l.Title or opts.Title or "OrcaHub", Weight = "Bold", TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 124), Size = UDim2.new(1, 0, 0, 22),
			TextTransparency = 1,
		})
		local status = text({
			Parent = body, Text = l.Subtitle or steps[1] or "Loading", TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 148), Size = UDim2.new(1, 0, 0, 16),
			Theme = { TextColor3 = "DimText" }, TextTransparency = 1,
		})
		local barBg = create("Frame", {
			Parent = body, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 176),
			Size = UDim2.new(1, -72, 0, 6), Theme = { BackgroundColor3 = "ToggleOff" },
		}, { corner(3) })
		local barFill = create("Frame", {
			Parent = barBg, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(0, 1), ClipsDescendants = true,
		}, { corner(3), accentGradient(0) })
		local shimmer = create("Frame", {
			Parent = barFill, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2,
		})
		local shimmerGradient = create("UIGradient", {
			Parent = shimmer, Offset = Vector2.new(-1, 0),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 1), NumberSequenceKeypoint.new(0.5, 0.55),
				NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 1),
			}),
		})
		loop(shimmerGradient, { Offset = Vector2.new(1, 0) }, 1.2)
		local percent = text({
			Parent = body, Text = "0%", TextSize = 11, Weight = "Medium",
			TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 188), Size = UDim2.new(1, 0, 0, 14),
			Theme = { TextColor3 = "DimText" }, TextTransparency = 1,
		})

		-- entrance
		tween(backdrop, { BackgroundTransparency = 0.45 }, 0.35)
		tween(splashScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
		titleLbl.Position = UDim2.fromOffset(0, 132)
		tween(titleLbl, { TextTransparency = 0, Position = UDim2.fromOffset(0, 124) }, 0.45)
		task.delay(0.12, function()
			tween(status, { TextTransparency = 0 }, 0.4)
			tween(percent, { TextTransparency = 0 }, 0.4)
		end)

		task.spawn(function()
			local shown = 0
			local function setStatus(msg)
				if status.Text == msg then return end
				tween(status, { TextTransparency = 1 }, 0.12).Completed:Wait()
				status.Text = msg
				tween(status, { TextTransparency = 0 }, 0.18)
			end
			local per = duration / math.max(#steps, 1)
			for i, step in ipairs(steps) do
				if Window.Destroyed then return end
				setStatus(Window._loadStatus or step)
				local target = Window._loadProgress or (i / #steps)
				tween(barFill, { Size = UDim2.fromScale(target, 1) }, per, Enum.EasingStyle.Quad)
				local t0 = os.clock()
				while os.clock() - t0 < per do
					shown = barFill.Size.X.Scale
					percent.Text = math.floor(shown * 100 + 0.5) .. "%"
					task.wait(0.03)
				end
			end
			barFill.Size = UDim2.fromScale(1, 1)
			percent.Text = "100%"
			setStatus(l.Done or "Ready")
			task.wait(0.3)
			if Window.Destroyed then return end

			-- morph the card into the window
			for _, tw in ipairs(loops) do tw:Cancel() end
			for _, d in ipairs(body:GetDescendants()) do
				if d:IsA("TextLabel") then tween(d, { TextTransparency = 1 }, 0.15) end
				if d:IsA("ImageLabel") then tween(d, { ImageTransparency = 1 }, 0.15) end
				if d:IsA("UIStroke") then tween(d, { Transparency = 1 }, 0.15) end
				if d:IsA("Frame") and d.BackgroundTransparency < 1 then tween(d, { BackgroundTransparency = 1 }, 0.15) end
			end
			task.wait(0.15)
			local target = Window.Size * Window.Scale
			tween(splash, { Size = UDim2.fromOffset(target.X, target.Y), Position = holder.Position }, 0.45, Enum.EasingStyle.Quint)
			tween(splashCorner, { CornerRadius = UDim.new(0, 12 * Window.Scale) }, 0.45)
			tween(backdrop, { BackgroundTransparency = 1 }, 0.45)
			task.wait(0.45)
			holder.Visible = true
			uiScale.Scale = Window.Scale
			cover.BackgroundTransparency = 0
			Window.Visible = true
			fab.Visible = fabAlways
			tween(cover, { BackgroundTransparency = 1 }, 0.35)
			tween(splash, { BackgroundTransparency = 1 }, 0.25)
			tween(splashStroke, { Transparency = 1 }, 0.25)
			task.wait(0.3)
			splash:Destroy()
			backdrop:Destroy()
		end)
	else
		uiScale.Scale = Window.Scale * 0.94
		cover.BackgroundTransparency = 0
		tween(uiScale, { Scale = Window.Scale }, 0.5, Enum.EasingStyle.Back)
		tween(cover, { BackgroundTransparency = 1 }, 0.4)
	end

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
