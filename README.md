# OrcaHub UI

A clean, modern dark UI library for Roblox script hubs. It is built for OrcaHub and works in any executor (Potassium, Volt and others).

## Features

- Sidebar tabs with an active indicator, two-column sections, and a footer
- Search bar that filters the elements on the current tab
- Draggable and resizable window, with a toggle key to show/hide it (RightShift by default)
- Toggles, buttons, sliders, dropdowns (single and multi-select), text inputs, keybinds, labels and paragraphs
- Notifications
- Flags: every element with a `Flag` stores its value in `OrcaHub.Flags`
- Icons drawn from plain Frames, so no asset ids are needed and they render the same everywhere

## Loading

```lua
local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui-/main/OrcaHub.lua"))()
```

> The repository must be **public** for `HttpGet` to work. While it is private, put `OrcaHub.lua` in your executor's workspace folder and load it with `loadstring(readfile("OrcaHub.lua"))()`.

## Quick start

```lua
local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Footer = "discord.gg/yourserver",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Main = Window:Tab({ Name = "Farming" })
local Section = Main:Section({ Name = "Auto Collect", Side = "Left" })

Section:Toggle({ Name = "Auto Collect", Flag = "AutoCollect", Callback = function(on) print(on) end })
```

See [`Example.lua`](Example.lua) for a full demo.

## API

### Window

| Method | Options |
| --- | --- |
| `OrcaHub:CreateWindow(opts)` | `Title`, `Footer`, `Size` (UDim2), `ToggleKey` (KeyCode), `Logo` |
| `Window:Tab(opts)` | `Name`, `Icon` |
| `Window:Destroy()` | |
| `OrcaHub:Notify(opts)` | `Title`, `Content`, `Duration` (seconds) |

### Tab

| Method | Options |
| --- | --- |
| `Tab:Section(opts)` | `Name`, `Side` (`"Left"` or `"Right"`) |
| `Tab:Select()` | |

### Section elements

| Method | Options | Returned object |
| --- | --- | --- |
| `Section:Toggle(opts)` | `Name`, `Default`, `Flag`, `Callback(bool)` | `:Set(v)`, `:Get()` |
| `Section:Button(opts)` | `Name`, `Callback()` | |
| `Section:Slider(opts)` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix`, `Flag`, `Callback(number)` | `:Set(v)`, `:Get()` |
| `Section:Dropdown(opts)` | `Name`, `Options`, `Default`, `Multi`, `Flag`, `Callback(value)` | `:Set(v)`, `:Get()`, `:Refresh(options)` |
| `Section:Input(opts)` | `Name`, `Default`, `Placeholder`, `Flag`, `Callback(text, enterPressed)` | `:Set(v)`, `:Get()` |
| `Section:Keybind(opts)` | `Name`, `Default` (KeyCode), `Flag`, `Callback(key)` | `:Set(key)` |
| `Section:Label(text)` | | `:Set(text)` |
| `Section:Paragraph(opts)` | `Title`, `Content` | `:Set(title, content)` |

A multi-select dropdown passes a list of the selected options to its callback.

## Icons

Tab and logo icons are drawn as letter badges for now. To use images (for example Lucide icons uploaded to Roblox), register them before creating the window and they replace the drawn icons automatically:

```lua
OrcaHub:LoadIcons({ user = "rbxassetid://123456" })
Window:Tab({ Name = "Player", Icon = "user" })
```

## Theming

Change colours in `OrcaHub.Theme` before calling `CreateWindow`:

```lua
OrcaHub.Theme.Accent = Color3.fromRGB(59, 130, 246)
```
