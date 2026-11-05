# OrcaHub UI

A clean, modern UI library for Roblox script hubs, built for OrcaHub. It works in any executor (Potassium, Volt and others) and is designed to be comfortable on mobile.

## Loading

Use a **pinned version** in your published scripts, so library updates can never break them:

```lua
local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/v2.1.0/OrcaHub.lua"))()
```

Or always get the newest version (good while developing):

```lua
local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/main/OrcaHub.lua"))()
```

## Features

**Look and feel**
- Ocean-blue gradient accent, soft shadow, Lucide icons, and four themes (Orca, Abyss, Reef, Coral)
- Animations throughout: spring window open, sliding tab highlight, page fades, springy toggles, ripple buttons, sliding popups and notifications
- Highlight on the row under the mouse, tooltips (`Tooltip = "..."`) and a "No results" state for search

**Sections that are easy to use**
- **Tap or click anywhere on a section header** to open or close it. A badge shows how many options a closed section holds.
- **Drag a header** to move the section anywhere, including the other column. On mobile, press and hold first, so normal swipes still scroll.
- Layout and open/closed state are remembered. An optional "one section open at a time" mode keeps small screens tidy.

**Resizing**
- Drag **any edge or corner** of the window. A thin accent line shows on the edge under the mouse, and a corner grip also works on touch screens.
- **Double-click (or double-tap) the title bar**, or use the maximize button, to fill the screen and back.
- Settings has size presets (Small, Medium, Large, Fit Screen, Auto) and an interface scale slider.
- Size and position are remembered between runs.

**Mobile**
- The window sizes itself to the screen. The sidebar starts as icons only, and sections start closed so the page stays compact.
- A **floating button** opens and closes the menu. Drag it anywhere and it snaps to the nearest edge. It can also be turned on for PC in Settings.
- Bigger touch targets, and narrow screens switch to one column.
- On narrow windows (phones in portrait) the tabs move to a **bottom navigation bar**, and search shrinks to an icon that expands when tapped.

**Building blocks**
- Tabs with **sub-tabs** (e.g. Silent Aim / Aimbot / Weapon)
- Toggle (switch or checkbox style), button, slider, dropdown (single, multi or searchable), **segmented control**, **progress bar**, input, keybind, colour picker, label, paragraph, divider
- **Locked elements** (e.g. "Premium") that explain themselves when clicked
- **Keybinds and colour pickers attached to a toggle**, on the same row
- **Search across all tabs**, with match counts on each tab
- **Floating panels** (e.g. a Target Info card), a **watermark** (FPS, ping, time) and a **keybind list**
- Notifications (Info, Success, Warning, Error) with optional buttons, confirm dialogs, an optional **key system**
- A **loading screen** with a spinning ring around the logo, step-by-step status, a shimmering progress bar and percentage, which then morphs into the window
- Custom accent colours, and **copy/paste settings** to share them with friends
- Configs (save, load, delete, autoload) and a ready-made Settings tab

## Mobile preview (no phone needed)

Run [`ExampleMobile.lua`](ExampleMobile.lua) on PC to see the mobile version inside a simulated device. Use the buttons above it to switch between phone landscape, phone portrait and tablet, or to close the preview.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/main/ExampleMobile.lua"))()
```

To preview your own script, set the flag before loading OrcaHub:

```lua
getgenv().OrcaHubMobilePreview = "Phone" -- or "Portrait" / "Tablet"
local OrcaHub = loadstring(game:HttpGet(".../OrcaHub.lua"))()
```

The flag only applies to that one load, so your normal scripts are unaffected. Touch-only gestures (press-and-hold to drag) behave like mouse input in the preview.

## Quick start

```lua
local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Subtitle = "Grow a Garden",
	Footer = "discord.gg/yourserver",
	Loading = true,
})

local Farming = Window:Tab({ Name = "Farming", Icon = "sprout", Description = "Automate your farm" })
local Collect = Farming:Section({ Name = "Auto Collect", Icon = "leaf", Side = "Left" })

Collect:Toggle({ Name = "Auto Collect", Flag = "AutoCollect", Callback = function(on) print(on) end })
	:AddKeybind({ Default = Enum.KeyCode.C })

local Combat = Window:Tab({ Name = "Combat", Icon = "crosshair" })
local Silent = Combat:SubTab({ Name = "Silent Aim" })
Silent:Section({ Name = "Silent Aim" }):Toggle({ Name = "Enabled" })
	:AddColorpicker({ Default = Color3.fromRGB(56, 160, 255) })

Window:CreateSettingsTab()
OrcaHub:LoadAutoloadConfig()
```

See [`Example.lua`](Example.lua) for a full demo.

## API

### Window

| Method | Options |
| --- | --- |
| `OrcaHub:CreateWindow(opts)` | `Title`, `Subtitle`, `Icon`, `Footer`, `Size` (Vector2/UDim2), `ToggleKey`, `Theme`, `Compact`, `SectionsCollapsed`, `Accordion`, `ToggleButton`, `Loading` (true or `{ Title, Steps, Duration, Done }`), `ShowProfile`, `Folder`, `ConfigKey` |
| `Window:SetLoadingStatus(text, progress)` | Report real progress (0-1) while the loading screen is showing |
| `Window:SetSize(Vector2, animate)` / `Window:ToggleMaximize()` / `Window:SetAutoSize()` | |
| `Window:Tab(opts)` | `Name`, `Icon`, `Description` |
| `Window:Divider(text)` | Group label in the sidebar |
| `Window:Panel(opts)` | `Title`, `Icon`, `Width`, `Position`. Returns a panel with `:Row(name, value)`, `:Bar({ Value, Max, Color })`, `:Text(text)`, `:SetTitle`, `:SetVisible`, `:Clear`, `:Destroy` |
| `Window:Watermark(opts)` | `Text`, `ShowFPS`, `ShowPing`, `ShowTime`, `Position` |
| `Window:KeybindList(opts)` | Panel listing bound keys; keys attached to an active toggle are highlighted |
| `Window:CreateSettingsTab(opts)` | Theme, scale, toggle key, compact sidebar, floating button, accordion, watermark, keybind list, layout reset, configs |
| `Window:Dialog(opts)` | `Title`, `Content`, `Buttons = { { Title, Primary, Callback } }` |
| `Window:SetVisible(bool)` / `Window:Toggle()` | |
| `Window:SetCompact(bool)`, `Window:SetToggleKey(key)`, `Window:SetToggleButtonVisible(bool)`, `Window:ResetLayout()`, `Window:Destroy()` | |

Running the script again closes the previous window first.

### Tabs, sub-tabs and sections

| Method | Options |
| --- | --- |
| `Tab:Section(opts)` | `Name`, `Icon`, `Side` (`"Left"`/`"Right"`), `Collapsed` |
| `Tab:SubTab(opts)` | `Name`. Returns a sub-tab with `:Section(opts)` and `:Select()` |
| `Tab:Select()` | |
| `Section:SetCollapsed(bool)` / `Section:ToggleCollapsed()` | |

Use either sections directly on a tab, or sub-tabs; don't mix them on the same tab.

### Elements

Every element accepts `Tooltip = "..."` to show an info icon with an explanation.

| Method | Options | Returned object |
| --- | --- | --- |
| `Section:Toggle(opts)` | `Name`, `Description`, `Default`, `Style` (`"Checkbox"`), `Flag`, `Callback(bool)` | `:Set(v)`, `:Get()`, `:AddKeybind(opts)`, `:AddColorpicker(opts)` |
| `Section:Segmented(opts)` | `Name`, `Options`, `Default`, `Flag`, `Callback(value)` | `:Set(v)`, `:Get()` |
| `Section:Progress(opts)` | `Name`, `Value`, `Max`, `Color`, `Format(value, max)` | `:Set(value, max)`, `:Get()` |
| `Section:Button(opts)` | `Name`, `Icon`, `Style` (`"Primary"`), `Callback()` | `:Fire()` |
| `Section:Slider(opts)` | `Name`, `Min`, `Max`, `Default`, `Increment`, `Suffix`, `OnRelease`, `Flag`, `Callback(number)` | `:Set(v)`, `:Get()` |
| `Section:Dropdown(opts)` | `Name`, `Options`, `Default`, `Multi`, `Searchable`, `Flag`, `Callback(value)` | `:Set(v)`, `:Get()`, `:Refresh(options, keepSelection)` |
| `Section:Input(opts)` | `Name`, `Icon`, `Default`, `Placeholder`, `Numeric`, `Flag`, `Callback(text, enterPressed)` | `:Set(v)`, `:Get()` |
| `Section:Keybind(opts)` | `Name`, `Default` (KeyCode), `Flag`, `Callback(key)`, `ChangedCallback(key)` | `:Set(key)`, `:Get()` |
| `Section:Colorpicker(opts)` | `Name`, `Default` (Color3), `Flag`, `Callback(color)` | `:Set(c)`, `:Get()` |
| `Section:Label(text)` | | `:Set(text)` |
| `Section:Paragraph(opts)` | `Title`, `Content` | `:Set(title, content)` |
| `Section:Divider()` | | |

`toggle:AddKeybind({ Default, Mode, Flag, Callback })`: `Mode = "Toggle"` (default) flips the toggle on each press; `"Hold"` keeps it on only while the key is held. `toggle:AddColorpicker({ Default, Flag, Callback })` adds a small swatch.

Every element also has `:SetVisible(bool)`, `:Lock(reason)`, `:Unlock()` and `:Destroy()`. Pass `Locked = "Premium"` to create it locked. Elements with a `Flag` store their value in `OrcaHub.Flags[flag]`, and configs save them.

### Notifications

```lua
OrcaHub:Notify({ Title = "Saved", Content = "Config saved.", Type = "Success", Duration = 4 })
OrcaHub:Notify({ Title = "Update", Content = "Open settings?", Buttons = { { Title = "Open", Primary = true, Callback = fn }, { Title = "Later" } } })
```

### Key system

Call it before `CreateWindow`. It waits until a valid key is entered and remembers it for next time.

```lua
OrcaHub:KeySystem({
	Title = "OrcaHub",
	Note = "Join the Discord to get a key.",
	Keys = { "orca-free" },                -- or Validate = function(key) return true/false end
	KeyLink = "https://example.com/getkey", -- "Get Key" copies this
})
```

### Configs

```lua
OrcaHub:SaveConfig("legit")
OrcaHub:LoadConfig("legit")
OrcaHub:ListConfigs()
OrcaHub:SetAutoload("legit")
OrcaHub:LoadAutoloadConfig()
local text = OrcaHub:ExportConfig()   -- share as text
OrcaHub:ImportConfig(text)
```

Files go in `OrcaHub/configs/<PlaceId>/` in the executor workspace.

## Icons

818 [Lucide](https://lucide.dev) icons are built in, already uploaded to Roblox. Use the Lucide name, e.g. `"sprout"`, `"crosshair"`, `"user"` or `"settings"`. Any `"rbxassetid://..."` works too.

## Theming

```lua
OrcaHub:SetTheme("Abyss")
OrcaHub:SetTheme({ Accent = Color3.fromRGB(255, 120, 0), Accent2 = Color3.fromRGB(255, 200, 0) })
```

The available colours are `Background`, `Sidebar`, `Section`, `Element`, `ElementHover`, `Stroke`, `StrokeLight`, `Text`, `SubText`, `DimText`, `Accent`, `Accent2`, `ToggleOff` and `Knob`.

## Testing

Tests run outside Roblox with [rbx-ui-testkit](https://github.com/donhubroblox/rbx-ui-testkit). Clone it next to this repo, then:

```bash
pip install lupa
python3 ../rbx-ui-testkit/rbxtest.py run tests/features_test.lua --lib OrcaHub.lua
python3 ../rbx-ui-testkit/rbxtest.py run tests/features_test.lua --lib OrcaHub.lua --mobile
python3 ../rbx-ui-testkit/rbxtest.py run Example.lua --lib OrcaHub.lua --fuzz
python3 ../rbx-ui-testkit/rbxtest.py run Example.lua --lib OrcaHub.lua --fuzz --mobile
```

## Versions

- **2.2.0**:
  - Resize from any edge or corner, maximize, size presets, and the window size and position are remembered.
  - Bottom navigation bar on narrow screens, and a collapsible search box.
  - New loading screen.
  - Segmented control, progress bar, checkbox toggles, locked elements and notification buttons.
  - Custom accent colours, and copy/paste settings.
- **2.1.1**: mobile preview mode (`ExampleMobile.lua`).
- **2.1.0**:
  - Tap a header to open or close a section; long-press to drag on mobile.
  - Sub-tabs, toggle keybind and colour add-ons, floating panels, watermark, keybind list, key system, loading screen and tooltips.
  - Search now covers all tabs.
  - Mobile now sizes the window to the screen.
  - Floating button snaps to the screen edge.
  - All dragging goes through one shared input listener.
- **2.0.0**: redesign, draggable sections, mobile support, Lucide icons, configs.
