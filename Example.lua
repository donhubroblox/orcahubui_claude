local source = (isfile and isfile("OrcaHub.lua")) and readfile("OrcaHub.lua")
	or game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/main/OrcaHub.lua")
local OrcaHub = loadstring(source)()

-- Optional key system (remove this block if your hub is keyless)
-- OrcaHub:KeySystem({ Title = "OrcaHub", Keys = { "orca-free" }, KeyLink = "https://example.com/getkey" })

local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Subtitle = "Grow a Garden",
	Icon = "waves",
	Footer = "discord.gg/orcahub",
	ToggleKey = Enum.KeyCode.RightShift,
	Loading = { Steps = { "Preparing interface", "Loading Grow a Garden", "Applying your settings" } },
})

Window:Divider("Main")
local Farming = Window:Tab({ Name = "Farming", Icon = "sprout", Description = "Automate planting, collecting and selling" })
local Combat = Window:Tab({ Name = "Combat", Icon = "crosshair", Description = "Aim assistance" })
local Shop = Window:Tab({ Name = "Shop & Misc", Icon = "shopping-cart", Description = "Buy seeds and gear" })
Window:Divider("Player")
local Player = Window:Tab({ Name = "Player", Icon = "user", Description = "Movement and visuals" })

---------------------------------------------------------------- Farming

local AutoBuy = Farming:Section({ Name = "AutoBuy", Icon = "coins", Side = "Left" })
AutoBuy:Toggle({
	Name = "Auto Buy Seeds", Description = "Buys the selected seeds when in stock", Flag = "AutoBuySeeds",
	Tooltip = "Checks the shop every few seconds.", Callback = print,
})
AutoBuy:Dropdown({ Name = "Seeds to Buy", Options = { "Carrot", "Strawberry", "Blueberry", "Tomato", "Corn" }, Multi = true, Flag = "SeedsToBuy" })

local Collect = Farming:Section({ Name = "Auto Collect", Icon = "leaf", Side = "Left" })
Collect:Toggle({ Name = "Auto Collect", Flag = "AutoCollect" }):AddKeybind({ Default = Enum.KeyCode.C })
Collect:Toggle({ Name = "Collect Aura", Flag = "CollectAura" })
Collect:Segmented({ Name = "Collection Mode", Options = { "Instant", "Tween", "Walk" }, Default = "Instant", Flag = "CollectMode" })
Collect:Slider({ Name = "Aura Range", Min = 5, Max = 100, Default = 25, Suffix = " studs", Flag = "AuraRange" })

local Actions = Farming:Section({ Name = "Farming Actions", Side = "Right" })
local money = Actions:Label("Money: 20¢")
Actions:Button({
	Name = "Check Inventory Worth", Icon = "coins",
	Callback = function()
		OrcaHub:Notify({ Title = "Inventory", Content = "Your inventory is worth 1,240¢", Type = "Success" })
	end,
})
Actions:Toggle({ Name = "Anti AFK", Flag = "AntiAFK", Style = "Checkbox" })
Actions:Toggle({ Name = "Low Graphics", Flag = "LowGraphics", Style = "Checkbox" })
local bag = Actions:Progress({ Name = "Backpack", Value = 12, Max = 60, Format = function(v, m) return v .. " / " .. m end })
Actions:Toggle({ Name = "Auto Rebirth", Locked = "Premium" })
Actions:Divider()
Actions:Button({ Name = "Sell All", Style = "Primary", Icon = "shopping-cart" })
Actions:Button({ Name = "Sell On Hand" })

local Events = Farming:Section({ Name = "Event Detector", Side = "Right", Collapsed = true })
Events:Toggle({ Name = "Pause While Raining" })
Events:Toggle({ Name = "Pause While Frost Event" })
Events:Toggle({ Name = "Pause While Blood Moon" })

---------------------------------------------------------------- Combat (sub-tabs)

local SilentAim = Combat:SubTab({ Name = "Silent Aim" })
local Aimbot = Combat:SubTab({ Name = "Aimbot" })
Combat:SubTab({ Name = "Weapon" }):Section({ Name = "Coming soon" }):Label("Nothing here yet.")

local SA = SilentAim:Section({ Name = "Silent Aim", Side = "Left" })
SA:Toggle({ Name = "Silent Aim", Flag = "SilentAim" }):AddKeybind({ Default = Enum.KeyCode.Q, Mode = "Toggle" })
SA:Toggle({ Name = "Show FOV", Flag = "ShowFOV" }):AddColorpicker({ Default = Color3.fromRGB(56, 160, 255), Flag = "FOVColor" })
SA:Slider({ Name = "FOV Size", Min = 20, Max = 500, Default = 150, Suffix = "px", Flag = "FOVSize" })
SA:Toggle({ Name = "Predict Movement", Flag = "Predict", Tooltip = "Leads the target based on its velocity." })

local Checks = SilentAim:Section({ Name = "Checks", Side = "Right" })
Checks:Toggle({ Name = "Exclude Friends", Default = true })
Checks:Toggle({ Name = "Visible Check" })
Checks:Dropdown({ Name = "Aim Part", Options = { "Head", "Torso", "Random" }, Default = "Head" })

Aimbot:Section({ Name = "Aimbot", Side = "Left" }):Toggle({ Name = "Aimbot" }):AddKeybind({ Default = Enum.KeyCode.E, Mode = "Hold" })

---------------------------------------------------------------- Player

local Movement = Player:Section({ Name = "Movement", Side = "Left" })
Movement:Slider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Flag = "WalkSpeed" })
Movement:Slider({ Name = "JumpPower", Min = 50, Max = 300, Default = 50, Flag = "JumpPower" })
Movement:Toggle({ Name = "Fly" }):AddKeybind({ Default = Enum.KeyCode.F })

local Visuals = Player:Section({ Name = "Visuals", Side = "Right" })
Visuals:Toggle({ Name = "Player ESP", Flag = "ESP" }):AddColorpicker({ Default = Color3.fromRGB(56, 160, 255), Flag = "ESPColor" })
Visuals:Input({ Name = "Target Player", Placeholder = "username", Icon = "user" })
Visuals:Paragraph({ Title = "Tip", Content = "Tap a section header to open or close it. Drag it (or press and hold on mobile) to move it." })

Shop:Section({ Name = "Coming soon" }):Label("Nothing here yet.")

---------------------------------------------------------------- Floating panels

local Target = Window:Panel({ Title = "Target Info", Icon = "crosshair", Position = UDim2.new(1, -250, 0, 80) })
local targetName = Target:Row("Target", "None")
local targetDistance = Target:Row("Distance", "-")
local targetHealth = Target:Bar({ Value = 100, Max = 100, Color = Color3.fromRGB(74, 222, 128) })
Target:SetVisible(false)

---------------------------------------------------------------- Settings

Window:CreateSettingsTab()
OrcaHub:LoadAutoloadConfig()

OrcaHub:Notify({
	Title = "OrcaHub loaded", Content = "Press RightShift to toggle the menu.", Duration = 6,
	Buttons = { { Title = "Open Settings", Primary = true, Callback = function() Window.Tabs[#Window.Tabs]:Select() end }, { Title = "Dismiss" } },
})

task.spawn(function()
	local amount = 20
	while Window.Gui.Parent do
		task.wait(2)
		amount = amount + math.random(1, 15)
		money:Set("Money: " .. amount .. "¢")
		bag:Set(math.random(0, 60))
		if OrcaHub.Flags.SilentAim then
			Target:SetVisible(true)
			targetName:Set("Alexei")
			targetDistance:Set(math.random(20, 600) .. "m")
			targetHealth:Set(math.random(10, 100), 100)
		else
			Target:SetVisible(false)
		end
	end
end)
