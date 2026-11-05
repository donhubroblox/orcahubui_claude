# OrcaHub UI

A clean, modern UI library for Roblox script hubs, built for OrcaHub. It works in any executor (Potassium, Volt and others) and on mobile.

## Features

- **Modern look**: an ocean-blue gradient accent, a soft shadow, Lucide icons, and four built-in themes (Orca, Abyss, Reef, Coral)
- **Animated throughout**: the window opens with a spring, the active-tab highlight slides, pages fade in, toggles spring, buttons show a ripple, and dropdowns, notifications and dialogs slide in
- **Movable sections**: drag any section by its header to rearrange it, including into the other column. On mobile, press and hold the header first. Your arrangement is saved automatically
- **Collapsible sections** with the arrow in the header
- **Works on mobile**: the window scales to fit the screen, a floating button toggles the window, touch targets are larger, and narrow windows switch to one column
- **Compact sidebar**: collapse the sidebar to icons only, with a tooltip on hover
- **Search** that filters elements on the current tab
- **Configs**: save, load, delete and autoload settings per game, plus a ready-made Settings tab
- **Elements**: toggle, button, slider, dropdown (single, multi or searchable), input, keybind, colour picker, label, paragraph and divider
- **Notifications and dialogs**: notifications come in Info, Success, Warning and Error styles

## Loading

```lua
local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/main/OrcaHub.lua"))()
```

> The repository must be **public** for `HttpGet` to work. While it is private, put `OrcaHub.lua` in your executor's workspace folder and load it with `loadstring(readfile("OrcaHub.lua"))()`.

## Quick start

```lua
local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Subtitle = "Grow a Garden",
	Footer = "discord.gg/yourserver",
})

local Farming = Window:Tab({ Name = "Farming", Icon = "sprout", Description = "Automate your farm" })
local Section = Farming:Section({ Name = "Auto Collect", Icon = "leaf", Side = "Left" })

Section:Toggle({ Name = "Auto Collect", Flag = "AutoCollect", Callback = function(on) print(on) end })

Window:CreateSettingsTab()
OrcaHub:LoadAutoloadConfig()
```

See [`Example.lua`](Example.lua) for a full demo.

## API

### Window

| Method | Options |
| --- | --- |
| `OrcaHub:CreateWindow(opts)` | `Title`, `Subtitle`, `Icon`, `Footer`, `Size` (Vector2 or UDim2), `ToggleKey`, `Theme`, `Compact`, `ShowProfile`, `Folder`, `ConfigKey` |
| `Window:Tab(opts)` | `Name`, `Icon`, `Description` |
| `Window:Divider(text)` | Adds a group label to the sidebar |
| `Window:CreateSettingsTab(opts)` | Adds the theme, scale, toggle key, layout and config controls |
| `Window:Dialog(opts)` | `Title`, `Content`, `Buttons = { { Title, Primary, Callback } }` |
| `Window:SetVisible(bool)` / `Window:Toggle()` | |
| `Window:SetCompact(bool)` | Collapses the sidebar to icons only |
| `Window:SetToggleKey(KeyCode)` | |
| `Window:ResetLayout()` | Puts every section back where the script placed it |
| `Window:Destroy()` | |

Running the script again closes the previous window first.

### Tab and Section

| Method | Options |
| --- | --- |
| `Tab:Section(opts)` | `Name`, `Icon`, `Side` (`"Left"` or `"Right"`), `Collapsed` |
| `Tab:Select()` | |
| `Section:SetCollapsed(bool)` | |

### Elements

| Method | Options | Returned object |
| --- | --- | --- |
| `Section:Toggle(opts)` | `Name`, `Description`, `Default`, `Flag`, `Callback(bool)` | `:Set(v)`, `:Get()` |
| `Section:Button(opts)` | `Name`, `Icon`, `Style` (`"Primary"`), `Callback()` | `:Fire()` |
| `Section:Slider(opts)` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix`, `OnRelease`, `Flag`, `Callback(number)` | `:Set(v)`, `:Get()` |
| `Section:Dropdown(opts)` | `Name`, `Options`, `Default`, `Multi`, `Searchable`, `Flag`, `Callback(value)` | `:Set(v)`, `:Get()`, `:Refresh(options, keepSelection)` |
| `Section:Input(opts)` | `Name`, `Icon`, `Default`, `Placeholder`, `Numeric`, `Flag`, `Callback(text, enterPressed)` | `:Set(v)`, `:Get()` |
| `Section:Keybind(opts)` | `Name`, `Default` (KeyCode), `Flag`, `Callback(key)`, `ChangedCallback(key)` | `:Set(key)`, `:Get()` |
| `Section:Colorpicker(opts)` | `Name`, `Default` (Color3), `Flag`, `Callback(color)` | `:Set(c)`, `:Get()` |
| `Section:Label(text)` | | `:Set(text)` |
| `Section:Paragraph(opts)` | `Title`, `Content` | `:Set(title, content)` |
| `Section:Divider()` | | |

Every element object also has `:SetVisible(bool)` and `:Destroy()`. Elements with a `Flag` store their value in `OrcaHub.Flags[flag]`, and configs save them.

A multi-select dropdown passes a list of the selected options to its callback. Dropdowns with more than 7 options get a search box automatically.

### Notifications

```lua
OrcaHub:Notify({ Title = "Saved", Content = "Config saved.", Type = "Success", Duration = 4 })
```

`Type` is `Info`, `Success`, `Warning` or `Error`. Click a notification to dismiss it.

### Configs

```lua
OrcaHub:SaveConfig("legit")
OrcaHub:LoadConfig("legit")
OrcaHub:ListConfigs()
OrcaHub:SetAutoload("legit")
OrcaHub:LoadAutoloadConfig()
```

Files are stored in `OrcaHub/configs/<PlaceId>/` in your executor's workspace. Pass `ConfigKey` to `CreateWindow` to use a different key, and `Folder` to rename the root folder.

## Icons

Icons are [Lucide](https://lucide.dev) icons that are already uploaded to Roblox; there are 818 to pick from. Use the Lucide name, for example `"sprout"`, `"shopping-cart"`, `"map-pin"`, `"user"` or `"settings"`. Any `"rbxassetid://..."` id works too, and you can add more with:

```lua
OrcaHub.Icons["my-icon"] = 1234567890
```

## Theming

```lua
OrcaHub:SetTheme("Abyss")
OrcaHub:SetTheme({ Accent = Color3.fromRGB(255, 120, 0), Accent2 = Color3.fromRGB(255, 200, 0) })
```

The available colours are `Background`, `Sidebar`, `Section`, `Element`, `ElementHover`, `Stroke`, `StrokeLight`, `Text`, `SubText`, `DimText`, `Accent`, `Accent2` (the second gradient colour), `ToggleOff` and `Knob`.

## Testing

`tests/` runs the library against a mocked Roblox API and clicks through every element:

```bash
pip install lupa
python3 tests/run.py
python3 tests/run.py --mobile
```
