-- Builds a full window, then drives every element through the mock.
local mock = MOCK
local OrcaHub = LIB()

local function find(root, pred)
	for _, d in ipairs(root:GetDescendants()) do
		if pred(d) then return d end
	end
end
local function findText(root, text, class)
	return find(root, function(d) return d.Text == text and (not class or d.ClassName == class) end)
end
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end print("ok  " .. msg) end

local log = {}
local Window = OrcaHub:CreateWindow({ Title = "OrcaHub", Subtitle = "Grow a Garden", Footer = "discord.gg/orcahub" })
local gui = Window.Gui
check(gui.Parent ~= nil, "gui parented")

Window:Divider("Main")
local Farming = Window:Tab({ Name = "Farming", Icon = "sprout", Description = "Automate your farm" })
local Shop = Window:Tab({ Name = "Shop", Icon = "shopping-cart" })
local NoIcon = Window:Tab({ Name = "Misc" })

local A = Farming:Section({ Name = "AutoBuy", Icon = "coins" })
local B = Farming:Section({ Name = "Farming Actions", Side = "Right" })
local C = Farming:Section({ Name = "Auto Collect" })

local tog = A:Toggle({ Name = "Auto Buy Seeds", Description = "Buys seeds", Flag = "AutoBuy", Callback = function(v) log.toggle = v end })
local dd = A:Dropdown({ Name = "Seeds", Options = { "Carrot", "Tomato", "Corn" }, Multi = true, Flag = "Seeds", Callback = function(v) log.dd = v end })
local single = A:Dropdown({ Name = "Mode", Options = { "Instant", "Tween" }, Default = "Instant", Flag = "Mode" })
local sl = A:Slider({ Name = "Range", Min = 0, Max = 10, Increment = 0.5, Default = 2, Suffix = "m", Flag = "Range", Callback = function(v) log.slider = v end })
B:Label("Money: 20")
B:Paragraph({ Title = "Info", Content = "Hello" })
B:Divider()
local btnHit = 0
B:Button({ Name = "Sell All", Icon = "coins", Callback = function() btnHit = btnHit + 1 end })
B:Button({ Name = "Primary", Style = "Primary", Icon = "save", Callback = function() btnHit = btnHit + 1 end })
local inp = B:Input({ Name = "Name", Numeric = true, Flag = "Name", Callback = function(t) log.input = t end })
local kb = B:Keybind({ Name = "Key", Default = Enum.KeyCode.G, Flag = "Key", Callback = function() log.key = true end })
local cp = C:Colorpicker({ Name = "ESP Color", Default = Color3.fromRGB(255, 0, 0), Flag = "Color", Callback = function(c) log.color = c end })
Window:CreateSettingsTab()
mock.advance(1)

-- toggle
local hit = tog.Row:GetChildren()[1]
hit:_fire("MouseButton1Click")
mock.advance(0.1)
check(log.toggle == true and OrcaHub.Flags.AutoBuy == true, "toggle click fires callback + flag")

-- buttons
local sell = findText(gui, "Sell All")
local sellBtn = sell.Parent.Parent
sellBtn:_fire("MouseButton1Down", 5, 5)
sellBtn:_fire("MouseButton1Click")
mock.advance(1)
check(btnHit == 1, "button callback")

-- dropdown (multi)
local head = find(dd.Row, function(d) return d.ClassName == "TextButton" end)
head:_fire("MouseButton1Click")
mock.advance(0.5)
local tomato = findText(Window.Overlay, "Tomato")
check(tomato ~= nil, "dropdown popup lists options")
tomato.Parent:_fire("MouseButton1Click")
mock.advance(0.1)
check(log.dd and log.dd[1] == "Tomato", "multi dropdown selection")
local catcher = Window.Overlay:GetChildren()[1]
catcher:_fire("MouseButton1Click")
mock.advance(0.5)
check(findText(Window.Overlay, "Tomato") == nil, "click outside closes popup")
single:Set("Tween")
check(single:Get() == "Tween", "single dropdown set/get")
dd:Refresh({ "A", "B" })
check(#dd:Get() == 0, "dropdown refresh clears selection")

-- searchable dropdown with many options
local many = {}
for i = 1, 12 do many[i] = "Opt" .. i end
local big = C:Dropdown({ Name = "Big", Options = many })
find(big.Row, function(d) return d.ClassName == "TextButton" end):_fire("MouseButton1Click")
mock.advance(0.5)
local filter = find(Window.Overlay, function(d) return d.ClassName == "TextBox" and d.PlaceholderText == "Search..." end)
check(filter ~= nil, "big dropdown gets search box")
filter.Text = "opt1"
check(findText(Window.Overlay, "Opt2").Parent.Visible == false, "dropdown search filters")
Window:_closePopup()
mock.advance(0.5)

-- slider
local sliderHit
for _, c in ipairs(sl.Row:GetChildren()) do if c.ClassName == "TextButton" then sliderHit = c end end
local press = mock.input("MouseButton1", 150, 0)
sliderHit:_fire("InputBegan", press)
mock.UIS.InputEnded:Fire(press)
mock.advance(0.5)
check(log.slider == 5, "slider drag to middle = 5 (got " .. tostring(log.slider) .. ")")
sl:Set(3.26)
check(sl:Get() == 3.5, "slider rounds to increment")

-- input numeric filter
local box = find(inp.Row, function(d) return d.ClassName == "TextBox" end)
box.Text = "12ab3"
check(box.Text == "123", "numeric input filters letters")
box:_fire("FocusLost", true)
mock.advance(0.1)
check(log.input == "123", "input callback")

-- keybind
mock.UIS.InputBegan:Fire(mock.input("Keyboard", 0, 0, { KeyCode = Enum.KeyCode.G }), false)
mock.advance(0.1)
check(log.key == true, "keybind fires")
local pillBtn = find(kb.Row, function(d) return d.ClassName == "TextButton" end)
pillBtn:_fire("MouseButton1Click")
mock.UIS.InputBegan:Fire(mock.input("Keyboard", 0, 0, { KeyCode = Enum.KeyCode.H }), false)
mock.advance(0.1)
check(kb:Get() == Enum.KeyCode.H, "keybind rebinding")

-- colour picker
local swatch = find(cp.Row, function(d) return d.ClassName == "TextButton" end)
swatch:_fire("MouseButton1Click")
mock.advance(0.5)
local hex = find(Window.Overlay, function(d) return d.ClassName == "TextBox" and d.Text:sub(1, 1) == "#" end)
check(hex and hex.Text == "#FF0000", "colour picker shows hex")
hex.Text = "#00ff00"
hex:_fire("FocusLost")
mock.advance(0.1)
check(log.color and log.color:ToHex() == "00ff00", "colour picker hex input")
Window:_closePopup()
mock.advance(0.5)

-- section collapse + layout
A._bodyH = 120 -- the mock never fires AbsoluteContentSize changes
local beforeH = A:_height()
local chevronBtn = find(A.Frame, function(d) return d.ClassName == "TextButton" and d.Parent.Parent == A.Frame end)
chevronBtn:_fire("MouseButton1Click")
mock.advance(0.5)
check(A.Collapsed and A:_height() < beforeH, "section collapses")
A:SetCollapsed(false)

-- section drag (mouse): move AutoBuy to right column
local header = A.Header
local press2 = mock.input("MouseButton1", 20, 20)
header:_fire("InputBegan", press2)
mock.UIS.InputChanged:Fire(mock.input("MouseMovement", 30, 20))
check(Farming._dragging == A, "drag starts after moving")
mock.UIS.InputChanged:Fire(mock.input("MouseMovement", 450, 20))
mock.Heartbeat:Fire()
mock.UIS.InputEnded:Fire(press2)
mock.advance(0.5)
check(Farming.Columns[2][1] == A or Farming.Columns[2][2] == A, "section dropped into right column")
check(Farming._dragging == nil, "drag ends")

-- touch: a long press on the header starts a drag, a quick swipe scrolls instead
if TEST_MOBILE then
	check(Window.ToggleButton.Visible, "floating toggle button visible on mobile")
	local swipe = mock.input("Touch", 20, 20)
	B.Header:_fire("InputBegan", swipe)
	mock.UIS.InputChanged:Fire(swipe)
	swipe.Position = { X = 20, Y = 80, Z = 0 }
	mock.UIS.InputChanged:Fire(swipe)
	mock.advance(0.5)
	check(Farming._dragging == nil, "touch swipe does not start a drag")
	local hold = mock.input("Touch", 20, 20)
	B.Header:_fire("InputBegan", hold)
	mock.advance(0.35)
	check(Farming._dragging == B, "touch long-press starts drag")
	mock.UIS.InputEnded:Fire(hold)
	mock.advance(0.5)
	check(Farming._dragging == nil, "touch drag ends")
end

-- search
local search = find(gui, function(d) return d.ClassName == "TextBox" and d.PlaceholderText == "Search..." end)
search.Text = "sell"
check(C.Frame.Visible == false and B.Frame.Visible == true, "search hides sections without matches")
search.Text = ""
check(C.Frame.Visible == true, "clearing search restores")

-- tabs, theme, compact, visibility
Shop:Select()
mock.advance(0.5)
check(Window.CurrentTab == Shop, "tab switch")
for _, name in ipairs({ "Abyss", "Reef", "Coral", "Orca" }) do OrcaHub:SetTheme(name) end
mock.advance(0.5)
check(OrcaHub.ThemeName == "Orca", "theme switching")
Window:SetCompact(true)
mock.advance(0.5)
Window:SetCompact(false)
mock.advance(0.5)
mock.UIS.InputBegan:Fire(mock.input("Keyboard", 0, 0, { KeyCode = Enum.KeyCode.RightShift }), false)
mock.advance(0.5)
check(Window.Visible == false, "toggle key hides")
Window:Toggle()
mock.advance(0.5)
check(Window.Visible == true, "toggle shows")
mock.camera.ViewportSize = Vector2.new(700, 360)
check(Window.Scale < 1, "auto scales on small screens (" .. Window.Scale .. ")")

-- notifications + dialog
OrcaHub:Notify({ Title = "Hi", Content = "There", Type = "Success", Duration = 1 })
OrcaHub:Notify({ Title = "Hi" })
mock.advance(6)
check(#Window.NotifyHolder:GetChildren() == 1, "notifications clean up (only layout left)")
local d = Window:Dialog({ Title = "Q", Buttons = { { Title = "Yes", Primary = true, Callback = function() log.dialog = true end } } })
local yes = findText(Window.Overlay, "Yes")
yes:_fire("MouseButton1Click")
mock.advance(0.5)
check(log.dialog == true, "dialog button")

-- configs
local saved = OrcaHub:SaveConfig("test")
check(saved, "config saved")
tog:Set(false)
sl:Set(9)
cp:Set(Color3.new(0, 0, 1))
check(OrcaHub:LoadConfig("test"), "config loaded")
mock.advance(0.1)
check(tog:Get() == true and sl:Get() == 3.5 and cp:Get():ToHex() == "00ff00" and kb:Get() == Enum.KeyCode.H, "config restores values")
check(#OrcaHub:ListConfigs() == 1, "list configs")

-- layout persistence: recreate window, AutoBuy should still be on the right
local W2 = OrcaHub:CreateWindow({ Title = "OrcaHub" })
mock.advance(1)
check(gui.Parent == nil, "re-running destroys the previous window")
local F2 = W2:Tab({ Name = "Farming" })
local A2 = F2:Section({ Name = "AutoBuy" })
F2:Section({ Name = "Farming Actions", Side = "Right" })
check(F2.Columns[2][1] == A2 or F2.Columns[2][2] == A2, "saved section layout restored")
W2:Destroy()
mock.advance(1)
print("ALL CHECKS PASSED, instances created: " .. mock.created .. ", warnings: " .. tostring(mock.warnings or 0))
