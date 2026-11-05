--[[
	OrcaHub mobile preview

	Run this on PC to see how OrcaHub looks and behaves on a phone. It turns on the
	library's mobile layout (compact sidebar, sections start closed, floating toggle
	button, bigger touch targets) and draws it inside a simulated device screen.

	Use the buttons above the device to switch between phone landscape, phone portrait
	and tablet, or close the preview. Your normal Example.lua is unaffected.
]]

-- "Phone" (landscape), "Portrait" or "Tablet"
getgenv().OrcaHubMobilePreview = "Phone"

local example = (isfile and isfile("Example.lua")) and readfile("Example.lua")
	or game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_claude/main/Example.lua")
loadstring(example)()
