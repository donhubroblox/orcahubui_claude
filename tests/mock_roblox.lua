-- Minimal Roblox API mock so the library can be smoke-tested outside Roblox.
local M = {}

---------------------------------------------------------------- scheduler
local queue = {}
local now = 0
local function schedule(at, fn, ...)
	table.insert(queue, { at = at, fn = fn, args = table.pack(...) })
end
task = {
	spawn = function(fn, ...) local co = coroutine.create(fn); local ok, err = coroutine.resume(co, ...); if not ok then error(err, 0) end end,
	defer = function(fn, ...) schedule(now, function(...) task.spawn(fn, ...) end, ...) end,
	delay = function(t, fn, ...) schedule(now + (t or 0), function(...) task.spawn(fn, ...) end, ...) end,
	wait = function(t)
		local co = coroutine.running()
		schedule(now + (t or 0), function() local ok, err = coroutine.resume(co); if not ok then error(err, 0) end end)
		return coroutine.yield()
	end,
}
function M.advance(seconds)
	local target = now + seconds
	while true do
		table.sort(queue, function(a, b) return a.at < b.at end)
		local item = queue[1]
		if not item or item.at > target then break end
		table.remove(queue, 1)
		now = item.at
		item.fn(table.unpack(item.args, 1, item.args.n))
	end
	now = target
end
function os.clock() return now end

function math.clamp(x, a, b) if x < a then return a elseif x > b then return b end return x end
function warn(...) M.warnings = (M.warnings or 0) + 1; print("WARN", ...) end

---------------------------------------------------------------- signals
local function Signal()
	local s = { handlers = {} }
	function s:Connect(fn)
		local c = { Connected = true }
		table.insert(s.handlers, c)
		c.fn = fn
		function c:Disconnect() c.Connected = false end
		return c
	end
	function s:Fire(...)
		for _, c in ipairs(s.handlers) do if c.Connected then c.fn(...) end end
	end
	function s:Wait() return end
	return s
end
M.Signal = Signal

---------------------------------------------------------------- datatypes
local types = {}
function typeof(v)
	local mt = type(v) == "table" and getmetatable(v)
	if mt and types[mt] then return types[mt] end
	return type(v)
end

local V2 = {}
V2.__index = V2
types[V2] = "Vector2"
Vector2 = {}
function Vector2.new(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, V2) end
V2.__add = function(a, b) return Vector2.new(a.X + b.X, a.Y + b.Y) end
V2.__sub = function(a, b) return Vector2.new(a.X - b.X, a.Y - b.Y) end
V2.__mul = function(a, b) if type(b) == "number" then return Vector2.new(a.X * b, a.Y * b) end return Vector2.new(a.X * b.X, a.Y * b.Y) end
V2.__div = function(a, b) if type(b) == "number" then return Vector2.new(a.X / b, a.Y / b) end return Vector2.new(a.X / b.X, a.Y / b.Y) end
V2.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
V2.__index = function(t, k) if k == "Magnitude" then return math.sqrt(t.X ^ 2 + t.Y ^ 2) end return rawget(V2, k) end

local UD = {}
UD.__index = UD
types[UD] = "UDim"
UDim = { new = function(s, o) return setmetatable({ Scale = s or 0, Offset = o or 0 }, UD) end }
local UD2 = {}
UD2.__index = UD2
types[UD2] = "UDim2"
UDim2 = {}
function UDim2.new(xs, xo, ys, yo) return setmetatable({ X = UDim.new(xs, xo), Y = UDim.new(ys, yo) }, UD2) end
function UDim2.fromOffset(x, y) return UDim2.new(0, x or 0, 0, y or 0) end
function UDim2.fromScale(x, y) return UDim2.new(x or 0, 0, y or 0, 0) end

local C3 = {}
C3.__index = C3
types[C3] = "Color3"
Color3 = {}
function Color3.new(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, C3) end
function Color3.fromRGB(r, g, b) return Color3.new(r / 255, g / 255, b / 255) end
function Color3.fromHSV(h, s, v)
	assert(type(h) == "number" and type(s) == "number" and type(v) == "number", "fromHSV expects numbers")
	local i = math.floor(h * 6); local f = h * 6 - i
	local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
	local m = i % 6
	if m == 0 then return Color3.new(v, t, p) elseif m == 1 then return Color3.new(q, v, p)
	elseif m == 2 then return Color3.new(p, v, t) elseif m == 3 then return Color3.new(p, q, v)
	elseif m == 4 then return Color3.new(t, p, v) end
	return Color3.new(v, p, q)
end
function Color3.fromHex(hex)
	hex = hex:gsub("#", "")
	assert(#hex == 6, "bad hex")
	return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
function C3:ToHSV()
	local r, g, b = self.R, self.G, self.B
	local mx, mn = math.max(r, g, b), math.min(r, g, b)
	local d = mx - mn
	local h = 0
	if d > 0 then
		if mx == r then h = ((g - b) / d) % 6 elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
		h = h / 6
	end
	return h, mx == 0 and 0 or d / mx, mx
end
function C3:ToHex() return string.format("%02x%02x%02x", math.floor(self.R * 255 + 0.5), math.floor(self.G * 255 + 0.5), math.floor(self.B * 255 + 0.5)) end

local function simple(name, ctor)
	local mt = { __index = {} }
	types[mt] = name
	return function(...) return setmetatable(ctor(...), mt) end
end
ColorSequence = { new = simple("ColorSequence", function(a, b) return { a = a, b = b } end) }
ColorSequenceKeypoint = { new = simple("ColorSequenceKeypoint", function(t, c) assert(typeof(c) == "Color3"); return { t = t, c = c } end) }
NumberSequence = { new = simple("NumberSequence", function(a, b) return { a = a, b = b } end) }
NumberSequenceKeypoint = { new = simple("NumberSequenceKeypoint", function(t, v) return { t = t, v = v } end) }
TweenInfo = { new = simple("TweenInfo", function(t, s, d) return { Time = t, Style = s, Dir = d } end) }
Font = {
	new = simple("Font", function(family, weight) assert(type(family) == "string"); assert(weight ~= nil, "nil weight"); return { Family = family, Weight = weight } end),
	fromEnum = simple("Font", function(e) return { e = e } end),
}

---------------------------------------------------------------- Enum
local EI = {}
types[EI] = "EnumItem"
EI.__index = EI
EI.__tostring = function(e) return "Enum." .. e.EnumType .. "." .. e.Name end
Enum = setmetatable({}, {
	__index = function(t, enumName)
		local e = setmetatable({}, {
			__index = function(et, itemName)
				local item = setmetatable({ Name = itemName, EnumType = enumName }, EI)
				rawset(et, itemName, item)
				return item
			end,
		})
		rawset(t, enumName, e)
		return e
	end,
})

---------------------------------------------------------------- instances
local INST = {}
types[INST] = "Instance"
local classes = {}
M.created = 0

local defaults = {
	AbsolutePosition = function() return Vector2.new(0, 0) end,
	AbsoluteSize = function() return Vector2.new(300, 30) end,
	AbsoluteWindowSize = function() return Vector2.new(560, 400) end,
	AbsoluteCanvasSize = function() return Vector2.new(560, 900) end,
	AbsoluteContentSize = function() return Vector2.new(300, 120) end,
	CanvasPosition = function() return Vector2.new(0, 0) end,
	Visible = function() return true end,
	Text = function() return "" end,
	BackgroundTransparency = function() return 0 end,
	TextTransparency = function() return 0 end,
	ImageTransparency = function() return 0 end,
	ZIndex = function() return 1 end,
	Rotation = function() return 0 end,
	Scale = function() return 1 end,
	Size = function() return UDim2.new(0, 0, 0, 0) end,
	Position = function() return UDim2.new(0, 0, 0, 0) end,
	BackgroundColor3 = function() return Color3.new(1, 1, 1) end,
	TextColor3 = function() return Color3.new(0, 0, 0) end,
	ImageColor3 = function() return Color3.new(1, 1, 1) end,
	Color = function() return Color3.new(0, 0, 0) end,
	ScrollingEnabled = function() return true end,
}

local events = {
	MouseButton1Click = true, MouseButton1Down = true, MouseButton1Up = true, MouseEnter = true, MouseLeave = true,
	InputBegan = true, InputChanged = true, InputEnded = true, Focused = true, FocusLost = true, Changed = true,
	Activated = true,
}

local function isA(class, name)
	if class == name or name == "Instance" then return true end
	local gui = { Frame = 1, TextLabel = 1, TextButton = 1, TextBox = 1, ImageLabel = 1, ImageButton = 1, ScrollingFrame = 1 }
	if name == "GuiObject" then return gui[class] ~= nil end
	if name == "GuiButton" then return class == "TextButton" or class == "ImageButton" end
	return false
end

function M.newInstance(class)
	M.created = M.created + 1
	local props = { ClassName = class, Name = class }
	local children = {}
	local propSignals = {}
	local ev = {}
	local self = {}
	local proxy = setmetatable({}, {
		__index = function(_, k)
			if self[k] ~= nil then return self[k] end
			if props[k] ~= nil then return props[k] end
			if events[k] then
				ev[k] = ev[k] or Signal()
				return ev[k]
			end
			if defaults[k] then return defaults[k]() end
			if k == "Parent" then return nil end
			return nil
		end,
		__newindex = function(p, k, v)
			if self[k] ~= nil then error("cannot set method " .. k) end
			if events[k] then error("cannot assign event " .. k) end
			if k == "LayoutOrder" and math.type and math.type(v) == "float" and v ~= math.floor(v) then
				error("LayoutOrder must be an integer, got " .. tostring(v))
			end
			if k == "Parent" then
				local old = props.Parent
				if old then old:_removeChild(p) end
				if props._destroyed then error("parent of destroyed instance locked") end
				if v then v:_addChild(p) end
			end
			local old = props[k]
			props[k] = v
			if old ~= v and propSignals[k] then propSignals[k]:Fire() end
		end,
		__metatable = INST,
	})
	function self:_addChild(c) table.insert(children, c) end
	function self:_removeChild(c)
		for i, x in ipairs(children) do if x == c then table.remove(children, i) return end end
	end
	function self:GetChildren() local t = {} for i, c in ipairs(children) do t[i] = c end return t end
	function self:GetDescendants()
		local out = {}
		for _, c in ipairs(children) do
			table.insert(out, c)
			for _, d in ipairs(c:GetDescendants()) do table.insert(out, d) end
		end
		return out
	end
	function self:FindFirstChildOfClass(cn) for _, c in ipairs(children) do if c.ClassName == cn then return c end end end
	function self:FindFirstChild(n) for _, c in ipairs(children) do if c.Name == n then return c end end end
	function self:WaitForChild(n) return self:FindFirstChild(n) or M.newInstance("Folder") end
	function self:IsA(n) return isA(class, n) end
	function self:IsFocused() return false end
	function self:Destroy()
		for _, c in ipairs(self:GetChildren()) do c:Destroy() end
		proxy.Parent = nil
		props._destroyed = true
	end
	function self:GetPropertyChangedSignal(k)
		propSignals[k] = propSignals[k] or Signal()
		return propSignals[k]
	end
	function self:_fire(name, ...) ev[name] = ev[name] or Signal(); ev[name]:Fire(...) end
	return proxy
end

Instance = { new = function(class) return M.newInstance(class) end }
INST.__index = INST

---------------------------------------------------------------- services
local function service(tbl)
	return tbl
end

local Tween = {}
local TweenService = service({
	Create = function(_, inst, info, props)
		assert(typeof(info) == "TweenInfo", "TweenService:Create needs TweenInfo")
		for k, v in pairs(props) do
			local t = typeof(v)
			assert(t == "number" or t == "UDim2" or t == "Color3" or t == "Vector2" or t == "UDim", "untweenable " .. k .. " (" .. t .. ")")
		end
		local completed = Signal()
		return {
			Play = function()
				for k, v in pairs(props) do inst[k] = v end
				task.delay(info.Time or 0, function() completed:Fire(Enum.PlaybackState.Completed) end)
			end,
			Cancel = function() end,
			Completed = completed,
		}
	end,
})

local UIS = service({
	TouchEnabled = TEST_MOBILE or false,
	KeyboardEnabled = not TEST_MOBILE,
	InputBegan = Signal(), InputChanged = Signal(), InputEnded = Signal(),
	GetMouseLocation = function() return Vector2.new(10, 50) end,
})
M.UIS = UIS

local camera = M.newInstance("Camera")
camera.ViewportSize = Vector2.new(1280, 720)
workspace = M.newInstance("Workspace")
workspace.CurrentCamera = camera
M.camera = camera

local playerGui = M.newInstance("PlayerGui")
local LocalPlayer = { UserId = 1, Name = "tester", DisplayName = "Tester" }
function LocalPlayer:WaitForChild() return playerGui end

local services = {
	Players = service({ LocalPlayer = LocalPlayer, GetUserThumbnailAsync = function() return "rbxthumb://x" end }),
	TweenService = TweenService,
	UserInputService = UIS,
	RunService = service({ Heartbeat = Signal(), RenderStepped = Signal() }),
	HttpService = service({
		GenerateGUID = function() return "GUID" end,
		JSONEncode = function(_, v) return M.json_encode(v) end,
		JSONDecode = function(_, s) return M.json_decode(s) end,
	}),
	GuiService = service({ GetGuiInset = function() return Vector2.new(0, 36) end }),
	CoreGui = M.newInstance("CoreGui"),
}
M.Heartbeat = services.RunService.Heartbeat
game = { PlaceId = 123 }
function game:GetService(n) return assert(services[n], "unknown service " .. n) end
M.CoreGui = services.CoreGui

function M.input(kind, x, y, extra)
	local i = { UserInputType = Enum.UserInputType[kind], Position = { X = x or 0, Y = y or 0, Z = 0 }, KeyCode = Enum.KeyCode.Unknown }
	if extra then for k, v in pairs(extra) do i[k] = v end end
	return i
end

return M
