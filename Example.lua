local source = (isfile and isfile("OrcaHub.lua")) and readfile("OrcaHub.lua")
	or game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui-/main/OrcaHub.lua")
local OrcaHub = loadstring(source)()

local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Subtitle = "Grow a Garden",
	Icon = "waves",
	Footer = "discord.gg/orcahub",
	ToggleKey = Enum.KeyCode.RightShift,
})

Window:Divider("Main")
local Farming = Window:Tab({ Name = "Farming", Icon = "sprout", Description = "Automate planting, collecting and selling" })
local Shop = Window:Tab({ Name = "Shop & Misc", Icon = "shopping-cart", Description = "Buy seeds and gear" })
local Teleports = Window:Tab({ Name = "Teleports", Icon = "map-pin" })
Window:Divider("Player")
local Player = Window:Tab({ Name = "Player", Icon = "user", Description = "Movement and visuals" })

---------------------------------------------------------------- Farming

local AutoBuy = Farming:Section({ Name = "AutoBuy", Icon = "coins", Side = "Left" })
AutoBuy:Toggle({ Name = "Auto Buy Seeds", Description = "Buys the selected seeds when in stock", Flag = "AutoBuySeeds", Callback = print })
AutoBuy:Dropdown({ Name = "Seeds to Buy", Options = { "Carrot", "Strawberry", "Blueberry", "Tomato", "Corn" }, Multi = true, Flag = "SeedsToBuy" })

local Collect = Farming:Section({ Name = "Auto Collect", Icon = "leaf", Side = "Left" })
Collect:Toggle({ Name = "Auto Collect", Flag = "AutoCollect" })
Collect:Toggle({ Name = "Collect Aura", Flag = "CollectAura" })
Collect:Dropdown({ Name = "Collection Mode", Options = { "Instant", "Tween", "Walk" }, Default = "Instant", Flag = "CollectMode" })
Collect:Slider({ Name = "Aura Range", Min = 5, Max = 100, Default = 25, Suffix = " studs", Flag = "AuraRange" })

local Actions = Farming:Section({ Name = "Farming Actions", Side = "Right" })
local money = Actions:Label("Money: 20¢")
Actions:Button({
	Name = "Check Inventory Worth", Icon = "coins",
	Callback = function()
		OrcaHub:Notify({ Title = "Inventory", Content = "Your inventory is worth 1,240¢", Type = "Success" })
	end,
})
Actions:Toggle({ Name = "Anti AFK", Flag = "AntiAFK" })
Actions:Toggle({ Name = "Low Graphics", Flag = "LowGraphics" })
Actions:Divider()
Actions:Button({ Name = "Sell All", Style = "Primary", Icon = "shopping-cart" })
Actions:Button({ Name = "Sell On Hand" })

local Events = Farming:Section({ Name = "Event Detector", Side = "Right", Collapsed = true })
Events:Toggle({ Name = "Pause While Raining" })
Events:Toggle({ Name = "Pause While Frost Event" })
Events:Toggle({ Name = "Pause While Blood Moon" })

---------------------------------------------------------------- Player

local Movement = Player:Section({ Name = "Movement", Side = "Left" })
Movement:Slider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Flag = "WalkSpeed" })
Movement:Slider({ Name = "JumpPower", Min = 50, Max = 300, Default = 50, Flag = "JumpPower" })
Movement:Keybind({ Name = "Fly", Default = Enum.KeyCode.F, Callback = function() print("fly") end })

local Visuals = Player:Section({ Name = "Visuals", Side = "Right" })
Visuals:Toggle({ Name = "Player ESP", Flag = "ESP" })
Visuals:Colorpicker({ Name = "ESP Color", Default = Color3.fromRGB(56, 160, 255), Flag = "ESPColor" })
Visuals:Input({ Name = "Target Player", Placeholder = "username", Icon = "user" })
Visuals:Paragraph({ Title = "Tip", Content = "Drag sections by their header to rearrange them. Your layout is remembered." })

Shop:Section({ Name = "Coming soon" }):Label("Nothing here yet.")
Teleports:Section({ Name = "Coming soon" }):Label("Nothing here yet.")

---------------------------------------------------------------- Settings

Window:CreateSettingsTab()
OrcaHub:LoadAutoloadConfig()

OrcaHub:Notify({ Title = "OrcaHub loaded", Content = "Press RightShift to toggle the menu.", Duration = 5 })

task.spawn(function()
	local amount = 20
	while Window.Gui.Parent do
		task.wait(2)
		amount = amount + math.random(1, 15)
		money:Set("Money: " .. amount .. "¢")
	end
end)
