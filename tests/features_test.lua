-- Feature tests for OrcaHub. Run with the testkit (https://github.com/donhubroblox/rbx-ui-testkit):
--   python3 ../rbx-ui-testkit/rbxtest.py run tests/features_test.lua --lib OrcaHub.lua
--   python3 ../rbx-ui-testkit/rbxtest.py run tests/features_test.lua --lib OrcaHub.lua --mobile

local OrcaHub = loadstring(game:HttpGet("OrcaHub.lua"))()
local MOBILE = OrcaHub.IsMobile
local expect = rbx.expect

local log = {}
local Window = OrcaHub:CreateWindow({ Title = "OrcaHub", Footer = "test" })
local Main = Window:Tab({ Name = "Main", Icon = "home" })
local Combat = Window:Tab({ Name = "Combat", Icon = "crosshair" })

local A = Main:Section({ Name = "Alpha", Collapsed = false })
local B = Main:Section({ Name = "Bravo", Side = "Right", Collapsed = false })
local toggle = A:Toggle({ Name = "Auto Farm", Flag = "AutoFarm", Tooltip = "Farms for you", Callback = function(v) log.toggle = v end })
local bind = toggle:AddKeybind({ Default = Enum.KeyCode.K })
local color = toggle:AddColorpicker({ Default = Color3.fromRGB(255, 0, 0), Flag = "FarmColor" })
B:Slider({ Name = "Speed", Min = 0, Max = 10, Default = 5, Flag = "Speed" })
B:Button({ Name = "Sell", Callback = function() log.sold = true end })

local Silent = Combat:SubTab({ Name = "Silent Aim" })
local Aimbot = Combat:SubTab({ Name = "Aimbot" })
Silent:Section({ Name = "Silent", Collapsed = false }):Toggle({ Name = "Silent Aim", Flag = "Silent" })
Aimbot:Section({ Name = "Aim", Collapsed = false }):Toggle({ Name = "Aimbot Enabled", Flag = "Aimbot" })
rbx.wait(1)

-- toggle + keybind add-on
rbx.clickText("Auto Farm")
rbx.wait(0.2)
expect(log.toggle == true and OrcaHub.Flags.AutoFarm == true, "clicking the toggle row turns it on")
rbx.pressKey("K")
expect(toggle:Get() == false, "toggle keybind add-on flips the toggle")
expect(bind:Get() == Enum.KeyCode.K, "keybind add-on keeps its key")
expect(color:Get():ToHex() == "FF0000", "colour add-on keeps its colour")

-- header tap collapses, tapping again expands
local before = A:_height()
rbx.click(A.HeaderFrame)
rbx.wait(0.5)
expect(A.Collapsed == true and A:_height() < before, "tapping anywhere on a section header collapses it")
rbx.click(A.HeaderFrame)
rbx.wait(0.5)
expect(A.Collapsed == false, "tapping the header again expands it")

-- dragging the header moves the section instead of collapsing it
if MOBILE then
	rbx.longPress(A.HeaderFrame, 0.6)
	rbx.wait(0.5)
	expect(A.Collapsed == false, "long-press starts a drag instead of collapsing")
else
	rbx.drag(A.HeaderFrame, 400, 0)
	rbx.wait(0.5)
	expect(A.Collapsed == false, "dragging a header does not collapse it")
end

-- search across tabs shows badges, clear button restores
local search
for _, box in ipairs(rbx.findAll(function(i) return i.ClassName == "TextBox" and i.PlaceholderText == "Search all tabs..." end)) do search = box end
search.Text = "aimbot"
rbx.wait(0.3)
expect(rbx.find("No results for \"aimbot\"", { visible = true }) ~= nil, "current tab shows an empty state when nothing matches")
search.Text = ""
rbx.wait(0.3)
expect(rbx.find("Auto Farm", { visible = true }) ~= nil, "clearing search restores the page")

-- sub-tabs
rbx.clickText("Combat")
rbx.wait(0.5)
expect(rbx.find("Silent Aim", { visible = true }) ~= nil, "first sub-tab is shown")
rbx.clickText("Aimbot")
rbx.wait(0.5)
expect(rbx.find("Aimbot Enabled", { visible = true }) ~= nil, "switching sub-tab shows its sections")

-- floating panel, watermark and keybind list
local panel = Window:Panel({ Title = "Target Info" })
local row = panel:Row("Target", "None")
local bar = panel:Bar({ Value = 50, Max = 100 })
row:Set("Alexei")
bar:Set(25, 100)
expect(rbx.find("Alexei") ~= nil, "panel rows update")
local wm = Window:Watermark()
rbx.wait(1)
expect(rbx.findText("fps", { exact = false }) ~= nil, "watermark shows fps")
Window:KeybindList()
rbx.wait(0.5)
expect(rbx.find("[K]") ~= nil, "keybind list shows bound keys")

-- floating toggle button
Window:SetVisible(false)
rbx.wait(0.5)
expect(Window.ToggleButton.Visible, "floating button shows while the window is hidden")
rbx.click(Window.ToggleButton)
rbx.wait(0.5)
expect(Window.Visible, "floating button reopens the window")

-- settings tab + configs
Window:CreateSettingsTab()
rbx.wait(0.5)
makefolder("OrcaHub")
expect(OrcaHub:SaveConfig("t"), "config saves")
toggle:Set(false)
expect(OrcaHub:LoadConfig("t"), "config loads")

-- new in 2.2: segmented, progress, checkbox, locked, notification buttons, config sharing
local More = Main:Section({ Name = "More", Collapsed = false })
local seg = More:Segmented({ Name = "Mode", Options = { "Instant", "Tween" }, Flag = "Mode", Callback = function(v) log.seg = v end })
rbx.wait(0.2)
rbx.clickText("Tween")
rbx.wait(0.3)
expect(seg:Get() == "Tween" and log.seg == "Tween", "segmented control switches option")
local prog = More:Progress({ Name = "Bag", Value = 5, Max = 10 })
prog:Set(10)
expect(rbx.find("100%") ~= nil, "progress bar shows percentage")
local box = More:Toggle({ Name = "Checkbox Thing", Style = "Checkbox" })
rbx.clickText("Checkbox Thing")
rbx.wait(0.3)
expect(box:Get() == true, "checkbox-style toggle works")
local locked = More:Toggle({ Name = "Premium Thing", Locked = "Premium" })
rbx.click(locked._lock)
rbx.wait(0.3)
expect(locked:Get() == false, "locked element ignores clicks")
locked:Unlock()
rbx.clickText("Premium Thing")
rbx.wait(0.3)
expect(locked:Get() == true, "unlocked element works again")
OrcaHub:Notify({ Title = "Ask", Buttons = { { Title = "Yes please", Callback = function() log.notifyButton = true end } } })
rbx.wait(0.6)
rbx.clickText("Yes please")
rbx.wait(0.3)
expect(log.notifyButton == true, "notification buttons run their callback")
local exported = OrcaHub:ExportConfig()
seg:Set("Instant")
expect(OrcaHub:ImportConfig(exported) and seg:Get() == "Tween", "config export/import round-trips")

-- resizing, maximize and bottom navigation
local before = Window.Size
Window:SetSize(Vector2.new(700, 450), false)
rbx.wait(0.2)
expect(Window.Size.X == 700 and Window.Size.Y <= 450, "SetSize changes the window size (clamped to the screen)")
Window:ToggleMaximize()
rbx.wait(0.5)
expect(Window.Maximized and Window.Size.X > 700, "maximize fills the screen")
Window:ToggleMaximize()
rbx.wait(0.5)
expect(not Window.Maximized and Window.Size.X == 700, "maximize toggles back to the previous size")
Window:SetSize(Vector2.new(400, 500), false)
rbx.wait(0.3)
expect(Window.NavMode == true, "narrow window switches tabs to a bottom bar")
rbx.clickText("Main")
rbx.wait(0.3)
expect(Window.CurrentTab.Name == "Main", "bottom bar tabs still switch pages")
Window:SetSize(Vector2.new(780, 500), false)
rbx.wait(0.3)
expect(Window.NavMode == false, "wide window returns to the sidebar")

-- new in 2.3: more elements
local E = Main:Section({ Name = "Elements", Collapsed = false })
E:Header("Inputs")
local num = E:Number({ Name = "Amount", Min = 0, Max = 10, Default = 5, Step = 1, Flag = "Amount" })
local range = E:Range({ Name = "Distance", Min = 0, Max = 100, Default = { 20, 80 }, Flag = "Distance", Callback = function(a, b) log.range = { a, b } end })
local radio = E:Radio({ Name = "Target", Options = { "Nearest", "Lowest HP" }, Default = "Nearest", Flag = "Target" })
local area = E:TextArea({ Name = "Notes", Lines = 3, Flag = "Notes" })
local value = E:Value({ Name = "Coins", Value = 10 })
E:Code("print('hello')")
E:Image({ Image = "user", Height = 60, Caption = "Avatar" })
E:Space(6)
E:Buttons({ { Name = "One", Callback = function() log.one = true end }, { Name = "Two", Style = "Primary" } })
local tb = E:Textbox({ Name = "Alias Box" })
local pd = E:PlayerDropdown({ Name = "Players", ExcludeLocal = false })
rbx.wait(0.5)
rbx.clickText("One")
rbx.wait(0.2)
expect(log.one == true, "button row buttons work")
local plusBtn
for _, d in ipairs(num.Row:GetDescendants()) do if d.ClassName == "TextButton" then plusBtn = d end end
rbx.click(plusBtn)
rbx.wait(0.2)
expect(num:Get() == 6, "number input + button increments")
num:Set(99)
expect(num:Get() == 10, "number input clamps to max")
range:Set({ 90, 10 })
expect(range:Get()[1] == 10 and range:Get()[2] == 90, "range keeps low <= high")
rbx.clickText("Lowest HP")
rbx.wait(0.2)
expect(radio:Get() == "Lowest HP", "radio group selects an option")
area:Set("line 1\nline 2")
expect(area:Get() == "line 1\nline 2", "multi-line text box keeps newlines")
value:SetValue(25)
expect(rbx.find("25") ~= nil, "value row updates")
expect(tb.Type == "Input", "Textbox is an alias for Input")
expect(#rbx.findAll(function(i) return i.ClassName == "TextLabel" and i.Text == "Player1" end) >= 0, "player dropdown builds")

-- favourites through the right-click menu
local favToggle = E:Toggle({ Name = "Starred Toggle", Flag = "Starred" })
rbx.wait(0.2)
local input = rbx.makeInput("MouseButton2", favToggle.Row.AbsolutePosition + rbx.v2(10, 10))
rbx.fire(rbx.getEvent(favToggle.Row, "InputBegan"), input)
rbx.wait(0.3)
rbx.clickText("Add to favourites")
rbx.wait(0.6)
local favTab
for _, t in ipairs(Window.Tabs) do if t.Name == "Favourites" then favTab = t end end
expect(favTab ~= nil and not favTab.Hidden, "favourites tab appears")
expect(table.find(Window.FavKeys, favToggle._key) ~= nil, "favourite key is stored")
favTab:Select()
rbx.wait(0.5)
rbx.click(favToggle._mirrors[1].Row:FindFirstChildWhichIsA("TextButton"))
rbx.wait(0.3)
expect(favToggle:Get() == true, "toggling the favourite copy changes the original")
favToggle:Set(false)
rbx.wait(0.2)
expect(favToggle._mirrors[1]:Get() == false, "changing the original updates the favourite copy")
Window:ToggleFavourite(favToggle)
rbx.wait(0.5)
expect(favTab.Hidden == true, "favourites tab hides when empty")

-- reset to default through the menu
num:Set(3)
rbx.fire(rbx.getEvent(num.Row, "InputBegan"), rbx.makeInput("MouseButton2", num.Row.AbsolutePosition))
rbx.wait(0.3)
rbx.clickText("Reset to default")
rbx.wait(0.2)
expect(num:Get() == 5, "reset to default restores the original value")

-- lazy tabs build on first open, and saved configs still reach them
local built = 0
local lazyToggle
OrcaHub:ImportConfig('{"LazyFlag": true}')
local Lazy = Window:Tab({ Name = "Lazy", Icon = "layers", Badge = "NEW", Build = function(tab)
	built = built + 1
	lazyToggle = tab:Section({ Name = "Late", Collapsed = false }):Toggle({ Name = "Lazy Toggle", Flag = "LazyFlag" })
end })
expect(built == 0, "lazy tab is not built until opened")
Lazy:Select()
rbx.wait(0.3)
expect(built == 1 and lazyToggle ~= nil, "lazy tab builds when opened")
expect(lazyToggle:Get() == true, "config loaded before the tab was built is applied")
Lazy:Select()
expect(built == 1, "lazy tab builds only once")

-- styles and themes
for _, style in ipairs({ "Glass", "Sharp", "Soft", "Default" }) do OrcaHub:SetStyle(style) end
for _, theme in ipairs({ "Midnight", "Sakura", "Light", "Orca" }) do OrcaHub:SetTheme(theme) end
rbx.wait(0.5)
expect(OrcaHub.StyleName == "Default" and OrcaHub.ThemeName == "Orca", "styles and themes switch")

-- confirm dialog on buttons
local confirmed = false
E:Button({ Name = "Danger", Confirm = "Really?", Callback = function() confirmed = true end })
rbx.wait(0.2)
rbx.clickText("Danger")
rbx.wait(0.4)
expect(not confirmed, "confirm button waits for the dialog")
rbx.clickText("Confirm")
rbx.wait(0.4)
expect(confirmed, "confirming runs the callback")

rbx.expectNoErrors("feature tests ran without errors")
