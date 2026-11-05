--[[
	OrcaHub UI Library
	Usage:
		local OrcaHub = loadstring(game:HttpGet("<raw url>"))()
		local Window = OrcaHub:CreateWindow({ Title = "OrcaHub", Footer = "discord.gg/xxx" })
		local Tab = Window:Tab({ Name = "Farming", Icon = "user" })
		local Section = Tab:Section({ Name = "Auto Collect", Side = "Left" })
		Section:Toggle({ Name = "Auto Collect", Default = false, Callback = function(v) end })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Library = {
	Flags = {},
	Icons = {},
	Theme = {
		Background = Color3.fromRGB(13, 13, 15),
		Sidebar = Color3.fromRGB(17, 17, 20),
		Section = Color3.fromRGB(20, 20, 24),
		Element = Color3.fromRGB(28, 28, 33),
		ElementHover = Color3.fromRGB(36, 36, 42),
		Stroke = Color3.fromRGB(38, 38, 45),
		Text = Color3.fromRGB(235, 235, 240),
		SubText = Color3.fromRGB(150, 150, 160),
		DimText = Color3.fromRGB(95, 95, 105),
		Accent = Color3.fromRGB(139, 92, 246),
		ToggleOff = Color3.fromRGB(45, 45, 52),
	},
	Font = Enum.Font.Gotham,
	FontMedium = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
}

-- Icons: pass a lucide name ("user", "settings") resolved via Library.Icons,
-- or a raw "rbxassetid://..." id. Load a lucide name->asset map with Library:LoadIcons(tbl).
function Library:LoadIcons(map)
	for k, v in pairs(map) do
		self.Icons[k] = v
	end
end

local function resolveIcon(icon)
	if not icon or icon == "" then return nil end
	if string.find(icon, "rbxasset") then return icon end
	return Library.Icons[icon] or Library.Icons["lucide-" .. icon]
end

---------------------------------------------------------------- helpers

local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then inst[k] = v end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

local function corner(r)
	return create("UICorner", { CornerRadius = UDim.new(0, r or 6) })
end

local function stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color or Library.Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(t, b, l, r)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
		PaddingLeft = UDim.new(0, l or t or 0),
		PaddingRight = UDim.new(0, r or l or t or 0),
	})
end

local function tween(inst, props, t, style)
	local tw = TweenService:Create(inst, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function label(props)
	local base = {
		BackgroundTransparency = 1,
		Font = Library.Font,
		TextColor3 = Library.Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		RichText = true,
	}
	for k, v in pairs(props) do base[k] = v end
	return create("TextLabel", base)
end

-- Icons are drawn from Frames/text so they render in every executor without asset ids.
-- If an image id is registered via LoadIcons, it is used instead (future lucide support).
local function bar(parent, w, h, rot, pos)
	return create("Frame", {
		Parent = parent, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(w, h), Position = pos or UDim2.fromScale(0.5, 0.5), Rotation = rot or 0,
	}, { corner(math.ceil(math.min(w, h) / 2)) })
end

local Shapes = {}

function Shapes.chevron(f, s)
	local t = math.max(2, math.floor(s / 8))
	local len = s * 0.5
	bar(f, len, t, 45, UDim2.new(0.5, -len * 0.3, 0.5, 0))
	bar(f, len, t, -45, UDim2.new(0.5, len * 0.3, 0.5, 0))
end

function Shapes.search(f, s)
	local r = s * 0.62
	create("Frame", {
		Parent = f, BackgroundTransparency = 1, Size = UDim2.fromOffset(r, r), Position = UDim2.fromOffset(0, 0),
	}, { corner(r), stroke(Color3.new(1, 1, 1), 2) })
	bar(f, s * 0.38, 2, 45, UDim2.fromOffset(s * 0.78, s * 0.78))
end

function Shapes.move(f, s)
	bar(f, s, 2, 0)
	bar(f, 2, s, 0)
end

function Shapes.grip(f, s)
	for i = 0, 2 do
		for j = 0, 2 - i do
			bar(f, 3, 3, 0, UDim2.fromScale(1 - i * 0.38 - 0.12, 1 - j * 0.38 - 0.12))
		end
	end
end

local function Icon(name, size, color, fallbackText)
	local frame = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size) })
	local image = resolveIcon(name)
	if image then
		create("ImageLabel", {
			Parent = frame, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Image = image, ScaleType = Enum.ScaleType.Fit,
		})
	elseif Shapes[name] then
		Shapes[name](frame, size)
	else
		-- letter badge for tab/logo icons
		local badge = create("Frame", {
			Parent = frame, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		}, { corner(5), stroke(Color3.new(1, 1, 1), 1.5) })
		create("TextLabel", {
			Parent = badge, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Font = Library.FontBold, TextSize = math.floor(size * 0.6),
			Text = string.upper(string.sub(fallbackText or name or "?", 1, 1)),
		})
	end

	local obj = { Instance = frame }
	function obj:SetColor(c, animate)
		for _, d in ipairs(frame:GetDescendants()) do
			local props
			if d:IsA("ImageLabel") then props = { ImageColor3 = c }
			elseif d:IsA("TextLabel") then props = { TextColor3 = c }
			elseif d:IsA("UIStroke") then props = { Color = c }
			elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then props = { BackgroundColor3 = c } end
			if props then
				if animate then tween(d, props) else for k, v in pairs(props) do d[k] = v end end
			end
		end
	end
	obj:SetColor(color or Library.Theme.SubText)
	return obj
end

local function getGuiParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	local ok2, core = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and core then
		local test = pcall(function() local f = Instance.new("Folder"); f.Parent = core; f:Destroy() end)
		if test then return core end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

local function isClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

---------------------------------------------------------------- notifications

local NotifyHolder

function Library:Notify(opts)
	opts = opts or {}
	if not NotifyHolder then return end
	local T = Library.Theme
	local card = create("Frame", {
		Parent = NotifyHolder,
		BackgroundColor3 = T.Section,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, { corner(8), stroke(T.Stroke), padding(10, 10, 12, 12) })
	local accentBar = create("Frame", {
		Parent = card, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 2, 1, -6), Position = UDim2.new(0, -8, 0, 3),
	}, { corner(2) })
	label({ Parent = card, Text = opts.Title or "Notification", Font = Library.FontBold, TextSize = 13, Size = UDim2.new(1, 0, 0, 16) })
	label({
		Parent = card, Text = opts.Content or "", TextColor3 = T.SubText, TextSize = 12,
		Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
	})
	tween(card, { BackgroundTransparency = 0 }, 0.25)
	task.delay(opts.Duration or 4, function()
		tween(card, { BackgroundTransparency = 1 }, 0.25)
		for _, d in ipairs(card:GetDescendants()) do
			if d:IsA("TextLabel") then tween(d, { TextTransparency = 1 }, 0.25)
			elseif d:IsA("UIStroke") then tween(d, { Transparency = 1 }, 0.25)
			elseif d == accentBar then tween(d, { BackgroundTransparency = 1 }, 0.25) end
		end
		task.wait(0.3)
		card:Destroy()
	end)
end

---------------------------------------------------------------- window

function Library:CreateWindow(opts)
	opts = opts or {}
	local T = Library.Theme
	local Window = { Tabs = {}, Elements = {} }

	local gui = create("ScreenGui", {
		Name = HttpService:GenerateGUID(false),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	})
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	gui.Parent = getGuiParent()
	Window.Gui = gui

	NotifyHolder = create("Frame", {
		Parent = gui, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(280, 400), ZIndex = 50,
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local size = opts.Size or UDim2.fromOffset(760, 500)
	local main = create("Frame", {
		Parent = gui, Name = "Main",
		BackgroundColor3 = T.Background,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		ClipsDescendants = true,
	}, { corner(10), stroke(T.Stroke) })
	Window.Main = main

	-- sidebar
	local sidebar = create("Frame", {
		Parent = main, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
		Size = UDim2.new(0, 190, 1, -28),
	})
	create("Frame", { -- divider
		Parent = sidebar, BackgroundColor3 = T.Stroke, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0),
	})

	local brand = create("Frame", { Parent = sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56) })
	create("Frame", {
		Parent = brand, BackgroundColor3 = T.Stroke, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
	})
	local logo = Icon(opts.Logo, 22, T.Accent, opts.Title or "OrcaHub")
	logo.Instance.Position = UDim2.new(0, 18, 0.5, -11)
	logo.Instance.Parent = brand
	label({
		Parent = brand, Text = opts.Title or "OrcaHub", Font = Library.FontBold, TextSize = 17,
		Position = UDim2.fromOffset(opts.Logo == false and 18 or 50, 0), Size = UDim2.new(1, -60, 1, 0),
	})

	local tabList = create("ScrollingFrame", {
		Parent = sidebar, BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 62), Size = UDim2.new(1, -1, 1, -62),
		ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, {
		create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		padding(0, 8, 8, 8),
	})

	-- topbar
	local content = create("Frame", {
		Parent = main, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(190, 0), Size = UDim2.new(1, -190, 1, -28),
	})
	local topbar = create("Frame", { Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56) })
	create("Frame", {
		Parent = topbar, BackgroundColor3 = T.Stroke, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
	})

	local searchBox = create("Frame", {
		Parent = topbar, BackgroundColor3 = T.Element,
		Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -60, 0, 36),
	}, { corner(6), stroke(T.Stroke) })
	local searchIcon = Icon("search", 14, T.DimText)
	searchIcon.Instance.Position = UDim2.new(0, 13, 0.5, -7)
	searchIcon.Instance.Parent = searchBox
	local searchInput = create("TextBox", {
		Parent = searchBox, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -48, 1, 0),
		Font = Library.Font, TextSize = 13, Text = "", PlaceholderText = "Search",
		PlaceholderColor3 = T.DimText, TextColor3 = T.Text, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local moveIcon = Icon("move", 18, T.DimText)
	moveIcon.Instance.AnchorPoint = Vector2.new(1, 0.5)
	moveIcon.Instance.Position = UDim2.new(1, -16, 0.5, 0)
	moveIcon.Instance.Parent = topbar
	makeDraggable(topbar, main)
	makeDraggable(brand, main)

	-- footer
	local footer = create("Frame", {
		Parent = main, BackgroundColor3 = T.Sidebar, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 28),
	})
	create("Frame", { Parent = footer, BackgroundColor3 = T.Stroke, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1) })
	label({
		Parent = footer, Text = opts.Footer or "", TextColor3 = T.DimText, TextSize = 12,
		Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
	})

	-- resize grip
	local grip = create("TextButton", {
		Parent = footer, BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(14, 14),
	})
	local gripIcon = Icon("grip", 14, T.DimText)
	gripIcon.Instance.Parent = grip
	do
		local resizing, startMouse, startSize
		grip.InputBegan:Connect(function(input)
			if isClick(input) then
				resizing, startMouse, startSize = true, input.Position, main.AbsoluteSize
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then resizing = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - startMouse
				main.Size = UDim2.fromOffset(math.max(560, startSize.X + d.X), math.max(360, startSize.Y + d.Y))
			end
		end)
	end

	local pages = create("Frame", {
		Parent = content, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56),
	})

	-- toggle visibility
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == toggleKey then
			main.Visible = not main.Visible
		end
	end)

	-- search filters elements on the current tab
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(searchInput.Text)
		local tab = Window.CurrentTab
		if not tab then return end
		for _, el in ipairs(tab.Elements) do
			el.Frame.Visible = q == "" or string.find(string.lower(el.Name), q, 1, true) ~= nil
		end
	end)

	---------------------------------------------------------------- tabs

	function Window:Tab(topts)
		topts = topts or {}
		local Tab = { Name = topts.Name or "Tab", Elements = {} }

		local btn = create("TextButton", {
			Parent = tabList, BackgroundColor3 = T.Element, BackgroundTransparency = 1,
			AutoButtonColor = false, Text = "", Size = UDim2.new(1, 0, 0, 38),
			LayoutOrder = #Window.Tabs + 1,
		}, { corner(6) })
		local indicator = create("Frame", {
			Parent = btn, BackgroundColor3 = T.Accent, BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, -8), Size = UDim2.fromOffset(2, 16), BackgroundTransparency = 1,
		}, { corner(2) })
		local ico = Icon(topts.Icon, 18, T.DimText, Tab.Name)
		ico.Instance.Position = UDim2.new(0, 12, 0.5, -9)
		ico.Instance.Parent = btn
		local txt = label({
			Parent = btn, Text = Tab.Name, TextColor3 = T.SubText, TextSize = 14,
			Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -44, 1, 0),
		})

		local page = create("ScrollingFrame", {
			Parent = pages, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
			Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = T.Stroke,
		}, { padding(10, 10, 10, 10) })

		local function column(x)
			return create("Frame", {
				Parent = page, BackgroundTransparency = 1,
				Position = UDim2.new(x, x == 0 and 0 or 5, 0, 0), Size = UDim2.new(0.5, -5, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, { create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
		end
		local left, right = column(0), column(0.5)

		function Tab:Select()
			for _, other in ipairs(Window.Tabs) do
				other:_set(false)
			end
			Tab:_set(true)
			Window.CurrentTab = Tab
			searchInput.Text = ""
		end

		function Tab:_set(on)
			page.Visible = on
			tween(btn, { BackgroundTransparency = on and 0 or 1 })
			tween(indicator, { BackgroundTransparency = on and 0 or 1 })
			tween(txt, { TextColor3 = on and T.Text or T.SubText })
			ico:SetColor(on and T.Accent or T.DimText, true)
		end

		btn.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then tween(txt, { TextColor3 = T.Text }) end
		end)
		btn.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then tween(txt, { TextColor3 = T.SubText }) end
		end)
		btn.MouseButton1Click:Connect(function() Tab:Select() end)

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then Tab:Select() end

		------------------------------------------------------------ sections

		function Tab:Section(sopts)
			sopts = sopts or {}
			local Section = {}
			local parentCol = (sopts.Side == "Right") and right or left

			local frame = create("Frame", {
				Parent = parentCol, BackgroundColor3 = T.Section,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			}, { corner(8), stroke(T.Stroke) })

			local header = create("Frame", { Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38) })
			label({
				Parent = header, Text = sopts.Name or "Section", Font = Library.FontMedium, TextSize = 14,
				Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0),
			})
			create("Frame", {
				Parent = header, BackgroundColor3 = T.Stroke, BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
			})

			local body = create("Frame", {
				Parent = frame, BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
				padding(8, 10, 10, 10),
			})

			local function register(name, frameInst, obj)
				obj.Name = name
				obj.Frame = frameInst
				table.insert(Tab.Elements, obj)
				return obj
			end

			local function row(h)
				return create("Frame", { Parent = body, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h or 30) })
			end

			-------------------------------------------------- label / paragraph

			function Section:Label(text)
				local r = row(20)
				local l = label({ Parent = r, Text = text, TextColor3 = T.SubText, Size = UDim2.fromScale(1, 1), TextWrapped = true })
				return register(text, r, { Set = function(_, v) l.Text = v end })
			end

			function Section:Paragraph(popts)
				local r = row(0)
				r.AutomaticSize = Enum.AutomaticSize.Y
				create("UIListLayout", { Parent = r, Padding = UDim.new(0, 2) })
				local title = label({ Parent = r, Text = popts.Title or "", Font = Library.FontMedium, Size = UDim2.new(1, 0, 0, 18) })
				local body2 = label({
					Parent = r, Text = popts.Content or "", TextColor3 = T.SubText, TextSize = 12, TextWrapped = true,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				})
				return register(popts.Title or "", r, {
					Set = function(_, t, c) title.Text = t or title.Text; body2.Text = c or body2.Text end,
				})
			end

			-------------------------------------------------- button

			function Section:Button(bopts)
				local r = row(30)
				local b = create("TextButton", {
					Parent = r, BackgroundColor3 = T.Element, AutoButtonColor = false,
					Size = UDim2.fromScale(1, 1), Font = Library.Font, TextSize = 13,
					TextColor3 = T.Text, Text = bopts.Name or "Button",
				}, { corner(5), stroke(T.Stroke) })
				b.MouseEnter:Connect(function() tween(b, { BackgroundColor3 = T.ElementHover }) end)
				b.MouseLeave:Connect(function() tween(b, { BackgroundColor3 = T.Element }) end)
				b.MouseButton1Down:Connect(function() tween(b, { TextColor3 = T.Accent }, 0.08) end)
				b.MouseButton1Up:Connect(function() tween(b, { TextColor3 = T.Text }) end)
				b.MouseButton1Click:Connect(function()
					if bopts.Callback then task.spawn(bopts.Callback) end
				end)
				return register(bopts.Name or "Button", r, {})
			end

			-------------------------------------------------- toggle

			function Section:Toggle(topts2)
				local state = topts2.Default or false
				local r = row(30)
				local hit = create("TextButton", { Parent = r, BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1) })
				local l = label({ Parent = r, Text = topts2.Name or "Toggle", TextColor3 = T.SubText, Size = UDim2.new(1, -50, 1, 0) })
				local track = create("Frame", {
					Parent = r, BackgroundColor3 = T.ToggleOff,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(38, 20),
				}, { corner(10), stroke(T.Stroke) })
				local knob = create("Frame", {
					Parent = track, BackgroundColor3 = Color3.fromRGB(230, 230, 235),
					AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(14, 14),
				}, { corner(7) })

				local obj = {}
				function obj:Set(v, silent)
					state = v and true or false
					tween(track, { BackgroundColor3 = state and T.Accent or T.ToggleOff })
					tween(knob, { Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
					tween(l, { TextColor3 = state and T.Text or T.SubText })
					if topts2.Flag then Library.Flags[topts2.Flag] = state end
					if not silent and topts2.Callback then task.spawn(topts2.Callback, state) end
				end
				function obj:Get() return state end
				hit.MouseButton1Click:Connect(function() obj:Set(not state) end)
				obj:Set(state, true)
				return register(topts2.Name or "Toggle", r, obj)
			end

			-------------------------------------------------- slider

			function Section:Slider(sl)
				local min, max = sl.Min or 0, sl.Max or 100
				local inc = sl.Increment or 1
				local value = sl.Default or min
				local suffix = sl.Suffix or ""
				local r = row(42)
				label({ Parent = r, Text = sl.Name or "Slider", TextColor3 = T.SubText, Size = UDim2.new(1, -60, 0, 20) })
				local valLbl = label({
					Parent = r, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 80, 0, 20),
				})
				local bar = create("TextButton", {
					Parent = r, BackgroundColor3 = T.Element, AutoButtonColor = false, Text = "",
					Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 6),
				}, { corner(3) })
				local fill = create("Frame", { Parent = bar, BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) }, { corner(3) })
				local knob = create("Frame", {
					Parent = fill, BackgroundColor3 = Color3.fromRGB(240, 240, 245),
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(12, 12),
				}, { corner(6), stroke(T.Accent, 2) })

				local obj = {}
				function obj:Set(v, silent)
					v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
					value = v
					local pct = (max == min) and 0 or (v - min) / (max - min)
					tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.08)
					valLbl.Text = tostring(v) .. suffix .. ' <font color="#5f5f69">/ ' .. tostring(max) .. suffix .. "</font>"
					if sl.Flag then Library.Flags[sl.Flag] = v end
					if not silent and sl.Callback then task.spawn(sl.Callback, v) end
				end
				function obj:Get() return value end

				local dragging = false
				local function update(x)
					local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					obj:Set(min + (max - min) * pct)
				end
				bar.InputBegan:Connect(function(input)
					if isClick(input) then dragging = true; update(input.Position.X) end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if isClick(input) then dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						update(input.Position.X)
					end
				end)
				obj:Set(value, true)
				return register(sl.Name or "Slider", r, obj)
			end

			-------------------------------------------------- textbox

			function Section:Input(iopts)
				local r = row(52)
				label({ Parent = r, Text = iopts.Name or "Input", Font = Library.FontMedium, Size = UDim2.new(1, 0, 0, 18) })
				local box = create("TextBox", {
					Parent = r, BackgroundColor3 = T.Element, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 28),
					Font = Library.Font, TextSize = 13, TextColor3 = T.Text, Text = iopts.Default or "",
					PlaceholderText = iopts.Placeholder or "...", PlaceholderColor3 = T.DimText,
					ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
				}, { corner(5), padding(0, 0, 10, 10) })
				local st = stroke(T.Stroke); st.Parent = box
				box.Focused:Connect(function() tween(st, { Color = T.Accent }) end)
				box.FocusLost:Connect(function(enter)
					tween(st, { Color = T.Stroke })
					if iopts.Flag then Library.Flags[iopts.Flag] = box.Text end
					if iopts.Callback then task.spawn(iopts.Callback, box.Text, enter) end
				end)
				return register(iopts.Name or "Input", r, {
					Set = function(_, v) box.Text = v end,
					Get = function() return box.Text end,
				})
			end

			-------------------------------------------------- dropdown

			function Section:Dropdown(dopts)
				local options = dopts.Options or {}
				local multi = dopts.Multi or false
				local selected = multi and {} or dopts.Default
				if multi and type(dopts.Default) == "table" then
					for _, v in ipairs(dopts.Default) do selected[v] = true end
				end

				local r = row(52)
				r.ClipsDescendants = false
				label({ Parent = r, Text = dopts.Name or "Dropdown", Font = Library.FontMedium, Size = UDim2.new(1, 0, 0, 18) })
				local head = create("TextButton", {
					Parent = r, BackgroundColor3 = T.Element, AutoButtonColor = false, Text = "",
					Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 28),
				}, { corner(5), stroke(T.Stroke) })
				local valueLbl = label({
					Parent = head, Text = "---", Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -36, 1, 0),
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				local chevronIcon = Icon("chevron", 12, T.SubText)
				local chevron = chevronIcon.Instance
				chevron.AnchorPoint = Vector2.new(1, 0.5)
				chevron.Position = UDim2.new(1, -10, 0.5, 0)
				chevron.Parent = head

				local list = create("Frame", {
					Parent = r, BackgroundColor3 = T.Element, Visible = false,
					Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, ZIndex = 10,
				}, { corner(5), stroke(T.Stroke) })
				local scroll = create("ScrollingFrame", {
					Parent = list, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
					CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 2, ScrollBarImageColor3 = T.Stroke, ZIndex = 10,
				}, {
					create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
					padding(4, 4, 4, 4),
				})

				local obj, open = {}, false
				local optionBtns = {}

				local function display()
					if multi then
						local t = {}
						for _, o in ipairs(options) do if selected[o] then table.insert(t, o) end end
						valueLbl.Text = #t > 0 and table.concat(t, ", ") or "---"
					else
						valueLbl.Text = selected and tostring(selected) or "---"
					end
					for o, b in pairs(optionBtns) do
						local on = multi and selected[o] or (not multi and selected == o)
						b.TextColor3 = on and T.Accent or T.SubText
						b.BackgroundTransparency = on and 0 or 1
					end
				end

				local function fire()
					local v = selected
					if multi then
						v = {}
						for _, o in ipairs(options) do if selected[o] then table.insert(v, o) end end
					end
					if dopts.Flag then Library.Flags[dopts.Flag] = v end
					if dopts.Callback then task.spawn(dopts.Callback, v) end
				end

				local function setOpen(v)
					open = v
					local h = math.min(#options, 6) * 28 + 8
					tween(chevron, { Rotation = open and 180 or 0 })
					if open then
						list.Visible = true
						r.Size = UDim2.new(1, 0, 0, 52 + h + 4)
						tween(list, { Size = UDim2.new(1, 0, 0, h) })
					else
						r.Size = UDim2.new(1, 0, 0, 52)
						tween(list, { Size = UDim2.new(1, 0, 0, 0) }).Completed:Connect(function()
							if not open then list.Visible = false end
						end)
					end
				end

				function obj:Refresh(newOptions)
					options = newOptions or options
					for _, b in pairs(optionBtns) do b:Destroy() end
					optionBtns = {}
					for i, o in ipairs(options) do
						local b = create("TextButton", {
							Parent = scroll, BackgroundColor3 = T.ElementHover, BackgroundTransparency = 1,
							AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i,
							Font = Library.Font, TextSize = 13, TextColor3 = T.SubText, Text = "  " .. tostring(o),
							TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
						}, { corner(4) })
						b.MouseButton1Click:Connect(function()
							if multi then
								selected[o] = not selected[o] or nil
							else
								selected = o
								setOpen(false)
							end
							display(); fire()
						end)
						optionBtns[o] = b
					end
					if open then setOpen(true) end
					display()
				end

				function obj:Set(v)
					if multi then
						selected = {}
						for _, o in ipairs(v) do selected[o] = true end
					else
						selected = v
					end
					display(); fire()
				end
				function obj:Get() return selected end

				head.MouseButton1Click:Connect(function() setOpen(not open) end)
				obj:Refresh(options)
				return register(dopts.Name or "Dropdown", r, obj)
			end

			-------------------------------------------------- keybind

			function Section:Keybind(kopts)
				local key = kopts.Default or Enum.KeyCode.Unknown
				local r = row(30)
				label({ Parent = r, Text = kopts.Name or "Keybind", TextColor3 = T.SubText, Size = UDim2.new(1, -90, 1, 0) })
				local b = create("TextButton", {
					Parent = r, BackgroundColor3 = T.Element, AutoButtonColor = false,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
					Font = Library.Font, TextSize = 12, TextColor3 = T.Text, Text = key.Name,
				}, { corner(4), stroke(T.Stroke), padding(0, 0, 8, 8) })
				local listening = false
				local obj = {}
				function obj:Set(k)
					key = k; b.Text = k.Name
					if kopts.Flag then Library.Flags[kopts.Flag] = k end
				end
				b.MouseButton1Click:Connect(function()
					listening = true; b.Text = "..."; b.TextColor3 = T.Accent
				end)
				UserInputService.InputBegan:Connect(function(input, gp)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						listening = false; b.TextColor3 = T.Text
						obj:Set(input.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or input.KeyCode)
					elseif not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
						if kopts.Callback then task.spawn(kopts.Callback, key) end
					end
				end)
				return register(kopts.Name or "Keybind", r, obj)
			end

			return Section
		end

		return Tab
	end

	function Window:Destroy()
		gui:Destroy()
	end

	return Window
end

return Library
