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
rbx.click(A.Header)
rbx.wait(0.5)
expect(A.Collapsed == true and A:_height() < before, "tapping anywhere on a section header collapses it")
rbx.click(A.Header)
rbx.wait(0.5)
expect(A.Collapsed == false, "tapping the header again expands it")

-- dragging the header moves the section instead of collapsing it
if MOBILE then
	rbx.longPress(A.Header, 0.6)
	rbx.wait(0.5)
	expect(A.Collapsed == false, "long-press starts a drag instead of collapsing")
else
	rbx.drag(A.Header, 400, 0)
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

rbx.expectNoErrors("feature tests ran without errors")
