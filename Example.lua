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
-- built the first time it is opened
Window:Tab({ Name = "Elements", Icon = "layers", Description = "Every input OrcaHub offers", Badge = "NEW", Build = function(tab)
	local Inputs = tab:Section({ Name = "Inputs", Icon = "text-cursor-input", Side = "Left" })
	Inputs:Header("Text")
	Inputs:Textbox({ Name = "Webhook URL", Placeholder = "https://...", Icon = "link" })
	Inputs:TextArea({ Name = "Chat Message", Placeholder = "Message to spam...", Lines = 3, Flag = "ChatMessage" })
	Inputs:Header("Numbers")
	Inputs:Number({ Name = "Seeds Per Buy", Min = 1, Max = 50, Default = 5, Flag = "SeedsPerBuy" })
	Inputs:Range({ Name = "Sell Price Window", Min = 0, Max = 1000, Default = { 100, 750 }, Suffix = "¢", Flag = "SellWindow" })
	Inputs:Slider({ Name = "Delay", Min = 0, Max = 2, Increment = 0.05, Default = 0.25, Suffix = "s", Flag = "Delay" })

	local Choices = tab:Section({ Name = "Choices", Icon = "list", Side = "Right" })
	Choices:Radio({ Name = "Target Priority", Options = { "Nearest", "Lowest Health", "Highest Value" }, Default = "Nearest", Flag = "Priority" })
	Choices:Segmented({ Name = "Speed", Options = { "Slow", "Normal", "Fast" }, Default = "Normal", Flag = "Speed" })
	Choices:PlayerDropdown({ Name = "Spectate Player" })
	Choices:Toggle({ Name = "Use Checkbox Style", Style = "Checkbox" })

	local Display = tab:Section({ Name = "Display", Icon = "image", Side = "Left" })
	Display:Value({ Name = "Session Time", Value = "0m" })
	Display:Value({ Name = "Seeds Bought", Value = "0" })
	Display:Progress({ Name = "Quest Progress", Value = 3, Max = 5, Format = function(v, m) return v .. " / " .. m end })
	Display:Code("loadstring(game:HttpGet(\"https://example.com/orcahub.lua\"))()")
	Display:Image({ Image = "rbxassetid://10747376931", Height = 80, Caption = "Images work too" })

	local Actions2 = tab:Section({ Name = "Actions", Icon = "mouse-pointer-click", Side = "Right" })
	Actions2:Buttons({
		{ Name = "Rejoin", Icon = "refresh-cw", Confirm = "Rejoin this server?" },
		{ Name = "Server Hop", Icon = "shuffle", Style = "Primary", Confirm = true },
	})
	Actions2:Button({ Name = "Reset Character", Icon = "rotate-ccw", Confirm = "Reset your character?" })
	Actions2:Paragraph({ Title = "Tip", Content = "Right-click (or long-press on mobile) any option to add it to Favourites or reset it." })
end })

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

local SettingsTab = Window:CreateSettingsTab()
OrcaHub:LoadAutoloadConfig()

OrcaHub:Notify({
	Title = "OrcaHub loaded", Content = "Press RightShift to toggle the menu.", Duration = 6,
	Buttons = { { Title = "Open Settings", Primary = true, Callback = function() SettingsTab:Select() end }, { Title = "Dismiss" } },
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
