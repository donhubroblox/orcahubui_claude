local OrcaHub = loadstring(readfile and isfile and isfile("OrcaHub.lua") and readfile("OrcaHub.lua") or game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui-/main/OrcaHub.lua"))()

local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Footer = "discord.gg/yourserver",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Farming = Window:Tab({ Name = "Farming", Icon = "user" })
Window:Tab({ Name = "Shop & Misc", Icon = "shopping-cart" })
Window:Tab({ Name = "Teleports", Icon = "map-pin" })
Window:Tab({ Name = "Settings", Icon = "settings" })

local AutoBuy = Farming:Section({ Name = "AutoBuy", Side = "Left" })
AutoBuy:Toggle({ Name = "Auto Buy Seeds", Flag = "AutoBuy", Callback = print })
AutoBuy:Dropdown({ Name = "Seeds to Buy", Options = { "Carrot", "Tomato", "Corn" }, Multi = true, Callback = print })

local Collect = Farming:Section({ Name = "Auto Collect", Side = "Left" })
Collect:Toggle({ Name = "Auto Collect" })
Collect:Toggle({ Name = "Collect Aura" })
Collect:Dropdown({ Name = "Collection Mode", Options = { "Instant", "Tween" }, Default = "Instant" })
Collect:Slider({ Name = "Aura Range", Min = 0, Max = 200, Default = 50, Suffix = "m" })

local Actions = Farming:Section({ Name = "Farming Actions", Side = "Right" })
Actions:Label("Money: 20¢")
Actions:Button({ Name = "Check Inventory Worth", Callback = function()
	OrcaHub:Notify({ Title = "Inventory", Content = "Worth: 1,240¢" })
end })
Actions:Toggle({ Name = "Anti AFK" })
Actions:Button({ Name = "Sell All" })
Actions:Keybind({ Name = "Sell Keybind", Default = Enum.KeyCode.G })
Actions:Input({ Name = "Player Name", Placeholder = "username" })
