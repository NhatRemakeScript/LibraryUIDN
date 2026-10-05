--[[
    LiquidGlass UI Library v2.0
    - Style: iOS 26 Liquid Glass
    - Integrated: WindUI-style Shapes (Squircle/Glass), Icons (lucide), Acrylic Blur,
                  Theme System, Key System, OpenButton, Tab positioning
    - Author: Custom Build
    - Usage: local LG = loadstring(game:HttpGet("URL"))()
]]

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass
LiquidGlass.Version = "2.0.0"

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")

local LP = Players.LocalPlayer

local function SafeParent()
    local ok, p = pcall(function()
        if type(gethui) == "function" then return gethui() end
        if CoreGui then return CoreGui end
    end)
    return (ok and p) or LP:WaitForChild("PlayerGui")
end

-- ============================================================
-- SHAPE MODULE (Squircle / Circle / Glass / Auto-Change)
-- ============================================================
local Shape = {}
Shape.Shapes = {
    Circle = {
        Image = "rbxassetid://111665032676235",
        Rect = Rect.new(512,512,512,512),
        Radius = 512,
    },
    CircleOutline = {
        Image = "rbxassetid://108556680453287",
        Rect = Rect.new(512,512,512,512),
        Radius = 512,
    },
    CircleGlass = {
        Image = "rbxassetid://95600044758841",
        Rect = Rect.new(512,512,512,512),
        Radius = 512,
    },
    Squircle = {
        Image = "rbxassetid://89641024074289",
        Rect = Rect.new(460,460,460,460),
        Radius = 310,
    },
    SquircleOutline = {
        Image = "rbxassetid://74029063732681",
        Rect = Rect.new(512,512,512,512),
        Radius = 310,
    },
    SquircleGlass = {
        Image = "rbxassetid://131126436897551",
        Rect = Rect.new(512,512,512,512),
        Radius = 310,
    },
    ["Squircle-TL-TR"] = {
        Image = "rbxassetid://75712142040725",
        Rect = Rect.new(512,512,512,512),
        Radius = 310,
        AutoChange = false,
    },
    ["Squircle-BL-BR"] = {
        Image = "rbxassetid://83676684425544",
        Rect = Rect.new(512,0,512,0),
        Radius = 310,
        AutoChange = false,
    },
    Square = {
        Image = "rbxassetid://82909646051652",
        Rect = Rect.new(512,512,512,512),
        Radius = 512,
        AutoChange = false,
    },
}

local function GetShapeData(name)
    return Shape.Shapes[name] or Shape.Shapes.Circle
end

-- Create a shape-based image
function Shape.New(parent, radius, shapeType, props, children, useButton, useScale)
    radius = radius or 0
    shapeType = shapeType or "Squircle"
    props = props or {}
    useScale = useScale ~= false

    local className = useButton and "ImageButton" or "ImageLabel"
    local shapeData = GetShapeData(shapeType)

    local inst = Instance.new(className)
    inst.BackgroundTransparency = 1
    inst.ScaleType = useScale and Enum.ScaleType.Slice or nil
    inst.SliceCenter = shapeData.Rect
    inst.Image = shapeData.Image

    for k, v in pairs(props) do
        if k ~= "ThemeTag" then
            inst[k] = v
        end
    end

    -- Apply slice scale based on radius
    local function ApplyRadius(r)
        inst.SliceScale = math.max(r / shapeData.Radius, 0.0001)
    end

    ApplyRadius(radius)
    inst.Parent = parent

    -- Children
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end

    -- Auto shape change on size change (WindUI style)
    if shapeData.AutoChange ~= false and string.find(shapeType, "Squircle") then
        local conn
        conn = inst:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local x, y = inst.AbsoluteSize.X, inst.AbsoluteSize.Y
            if x <= 0 or y <= 0 then return end
            local minDim = math.min(x, y)
            local ratio = radius ~= 0 and radius or minDim / 2
            local newType = shapeType

            if math.abs(x - y) < 2 then
                newType = ratio / minDim >= 310/1024 and "Circle" or "Squircle"
            elseif x > y then
                newType = ratio / minDim >= 310/1024 and "SquircleH" or "Squircle"
            else
                newType = ratio / minDim >= 310/1024 and "SquircleV" or "Squircle"
            end

            -- (Bỏ qua H/V variants nếu không cần, dùng default)
        end)
    end

    return inst, {
        SetRadius = function(_, r)
            radius = r
            ApplyRadius(r)
        end,
        SetType = function(_, t)
            shapeType = t
            local d = GetShapeData(t)
            inst.Image = d.Image
            inst.SliceCenter = d.Rect
            ApplyRadius(radius)
        end,
    }
end

-- ============================================================
-- ICON MODULE (lucide-style via ReplicatedStorage.GetIcons)
-- ============================================================
local Icons = {}
Icons.Cache = nil

function Icons.Init()
    pcall(function()
        local remote = ReplicatedStorage:WaitForChild("GetIcons", 5)
        if remote and remote.InvokeServer then
            Icons.Cache = remote:InvokeServer()
        end
    end)
end

function Icons.Get(name, iconType)
    if not Icons.Cache then return nil end
    iconType = iconType or Icons.Cache.IconsType or "lucide"
    if Icons.Cache.Icons and Icons.Cache.Icons[iconType] then
        local entry = Icons.Cache.Icons[iconType][name]
        if entry then
            return entry
        end
    end
    return nil
end

function Icons.Create(name, iconType, size, color)
    size = size or UDim2.fromOffset(24, 24)
    color = color or Color3.fromRGB(255, 255, 255)

    local entry = Icons.Get(name, iconType)
    local img = Instance.new("ImageLabel")
    img.Size = size
    img.BackgroundTransparency = 1
    img.ImageColor3 = color
    img.ScaleType = Enum.ScaleType.Fit

    if entry then
        if type(entry) == "table" and entry.Image then
            img.Image = entry.Image
            if entry.ImageRectSize then
                img.ImageRectSize = entry.ImageRectSize
                img.ImageRectOffset = entry.ImageRectPosition
            end
        elseif type(entry) == "string" then
            img.Image = entry
        end
    else
        -- Fallback to unicode
        local uni = Instance.new("TextLabel")
        uni.Size = size
        uni.BackgroundTransparency = 1
        uni.Text = "◆"
        uni.TextColor3 = color
        uni.TextSize = size.X.Offset
        uni.Font = Enum.Font.GothamBold
        return uni
    end

    return img
end

Icons.Init()

-- ============================================================
-- ACRYLIC BLUR MODULE (real 3D glass behind GUI)
-- ============================================================
local Acrylic = {}
Acrylic.Enabled = false

local function CreateAcrylicPart()
    local part = Instance.new("Part")
    part.Name = "LiquidGlass_AcrylicBody"
    part.Color = Color3.new(0,0,0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1,1,0)
    part.Anchored = true
    part.CanCollide = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    local mesh = Instance.new("SpecialMesh", part)
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Offset = Vector3.new(0,0,-1e-6)
    return part
end

local function MapRange(v, a1, a2, b1, b2)
    return (v - a1) * (b2 - b1) / (a2 - a1) + b1
end

function Acrylic.Create(targetFrame)
    local folder = Instance.new("Folder")
    folder.Name = "LiquidGlass_Acrylic"
    folder.Parent = workspace.CurrentCamera

    local part = CreateAcrylicPart()
    part.Parent = folder

    local points = {TL = Vector2.new(), TR = Vector2.new(), BR = Vector2.new()}

    local function UpdatePositions(size, pos)
        points.TL = pos
        points.TR = pos + Vector2.new(size.X, 0)
        points.BR = pos + size
    end

    local function Render()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local cframe = cam.CFrame
        local depth = 0.001
        local tl = cam:ScreenPointToRay(points.TL.X, points.TL.Y).Origin
                     + cam:ScreenPointToRay(points.TL.X, points.TL.Y).Direction * depth
        local tr = cam:ScreenPointToRay(points.TR.X, points.TR.Y).Origin
                     + cam:ScreenPointToRay(points.TR.X, points.TR.Y).Direction * depth
        local br = cam:ScreenPointToRay(points.BR.X, points.BR.Y).Origin
                     + cam:ScreenPointToRay(points.BR.X, points.BR.Y).Direction * depth

        local w = (tr - tl).Magnitude
        local h = (tr - br).Magnitude
        part.CFrame = CFrame.fromMatrix((tl + br)/2, cframe.XVector, cframe.YVector, cframe.ZVector)
        part.Mesh.Scale = Vector3.new(w, h, 0)
    end

    local function Update()
        local size = targetFrame.AbsoluteSize
        local offset = MapRange(size.Y, 0, 2560, 8, 56)
        local innerSize = size - Vector2.new(offset, offset)
        local innerPos = targetFrame.AbsolutePosition + Vector2.new(offset/2, offset/2)
        UpdatePositions(innerSize, innerPos)
        task.spawn(Render)
    end

    local conns = {}
    table.insert(conns, targetFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(Update))
    table.insert(conns, targetFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update))

    local cam = workspace.CurrentCamera
    if cam then
        table.insert(conns, cam:GetPropertyChangedSignal("CFrame"):Connect(Render))
        table.insert(conns, cam:GetPropertyChangedSignal("ViewportSize"):Connect(Render))
    end

    task.spawn(Update)

    return {
        Frame = targetFrame,
        Model = part,
        SetVisible = function(visible)
            part.Transparency = visible and 0.98 or 1
        end,
        Destroy = function()
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            folder:Destroy()
        end,
    }
end

-- ============================================================
-- THEMES (liquid glass colors)
-- ============================================================
LiquidGlass.Themes = {
    Aurora = {
        Name = "Aurora",
        Grad1 = Color3.fromRGB(120, 200, 255),
        Grad2 = Color3.fromRGB(180, 140, 255),
        Accent = Color3.fromRGB(120, 180, 255),
        AccentLight = Color3.fromRGB(180, 200, 255),
        Background = Color3.fromRGB(20, 24, 34),
        Sidebar = Color3.fromRGB(16, 20, 28),
        Box = Color3.fromRGB(30, 36, 48),
        SubBox = Color3.fromRGB(40, 48, 64),
        Border = Color3.fromRGB(70, 90, 120),
        BorderLight = Color3.fromRGB(110, 140, 180),
        TextTitle = Color3.fromRGB(250, 252, 255),
        TextBody = Color3.fromRGB(220, 228, 240),
        TextDim = Color3.fromRGB(150, 170, 195),
        TextMuted = Color3.fromRGB(100, 120, 145),
        Success = Color3.fromRGB(80, 220, 140),
        Danger = Color3.fromRGB(255, 90, 110),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    Sunset = {
        Name = "Sunset",
        Grad1 = Color3.fromRGB(255, 140, 90),
        Grad2 = Color3.fromRGB(255, 90, 160),
        Accent = Color3.fromRGB(255, 140, 120),
        AccentLight = Color3.fromRGB(255, 180, 150),
        Background = Color3.fromRGB(32, 20, 24),
        Sidebar = Color3.fromRGB(26, 16, 20),
        Box = Color3.fromRGB(46, 30, 36),
        SubBox = Color3.fromRGB(60, 40, 48),
        Border = Color3.fromRGB(110, 70, 80),
        BorderLight = Color3.fromRGB(160, 100, 115),
        TextTitle = Color3.fromRGB(255, 250, 250),
        TextBody = Color3.fromRGB(240, 220, 225),
        TextDim = Color3.fromRGB(180, 150, 160),
        TextMuted = Color3.fromRGB(125, 100, 110),
        Success = Color3.fromRGB(120, 220, 140),
        Danger = Color3.fromRGB(255, 80, 80),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    Mint = {
        Name = "Mint",
        Grad1 = Color3.fromRGB(120, 255, 200),
        Grad2 = Color3.fromRGB(120, 220, 255),
        Accent = Color3.fromRGB(130, 240, 210),
        AccentLight = Color3.fromRGB(160, 255, 230),
        Background = Color3.fromRGB(20, 32, 30),
        Sidebar = Color3.fromRGB(16, 26, 24),
        Box = Color3.fromRGB(28, 42, 40),
        SubBox = Color3.fromRGB(38, 54, 52),
        Border = Color3.fromRGB(60, 100, 90),
        BorderLight = Color3.fromRGB(90, 140, 125),
        TextTitle = Color3.fromRGB(245, 255, 252),
        TextBody = Color3.fromRGB(210, 235, 228),
        TextDim = Color3.fromRGB(140, 180, 168),
        TextMuted = Color3.fromRGB(90, 125, 115),
        Success = Color3.fromRGB(120, 240, 160),
        Danger = Color3.fromRGB(255, 90, 110),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    Sakura = {
        Name = "Sakura",
        Grad1 = Color3.fromRGB(255, 180, 210),
        Grad2 = Color3.fromRGB(255, 140, 180),
        Accent = Color3.fromRGB(255, 170, 200),
        AccentLight = Color3.fromRGB(255, 210, 230),
        Background = Color3.fromRGB(32, 22, 28),
        Sidebar = Color3.fromRGB(26, 18, 24),
        Box = Color3.fromRGB(46, 32, 40),
        SubBox = Color3.fromRGB(58, 42, 52),
        Border = Color3.fromRGB(110, 80, 95),
        BorderLight = Color3.fromRGB(160, 115, 135),
        TextTitle = Color3.fromRGB(255, 250, 252),
        TextBody = Color3.fromRGB(240, 220, 228),
        TextDim = Color3.fromRGB(185, 155, 168),
        TextMuted = Color3.fromRGB(128, 105, 118),
        Success = Color3.fromRGB(140, 220, 160),
        Danger = Color3.fromRGB(255, 90, 110),
        Glass = Color3.fromRGB(255, 255, 255),
    },
    Obsidian = {
        Name = "Obsidian",
        Grad1 = Color3.fromRGB(180, 200, 220),
        Grad2 = Color3.fromRGB(140, 160, 190),
        Accent = Color3.fromRGB(170, 190, 210),
        AccentLight = Color3.fromRGB(210, 225, 240),
        Background = Color3.fromRGB(18, 20, 26),
        Sidebar = Color3.fromRGB(14, 16, 22),
        Box = Color3.fromRGB(26, 30, 38),
        SubBox = Color3.fromRGB(36, 40, 50),
        Border = Color3.fromRGB(58, 66, 82),
        BorderLight = Color3.fromRGB(90, 100, 120),
        TextTitle = Color3.fromRGB(245, 248, 255),
        TextBody = Color3.fromRGB(210, 218, 230),
        TextDim = Color3.fromRGB(145, 155, 175),
        TextMuted = Color3.fromRGB(95, 105, 125),
        Success = Color3.fromRGB(80, 220, 140),
        Danger = Color3.fromRGB(255, 90, 110),
        Glass = Color3.fromRGB(255, 255, 255),
    },
}

-- ============================================================
-- CONFIG
-- ============================================================
LiquidGlass.Settings = {
    Theme = "Aurora",
    AccentStyle = "Gradient",
    SoundEnabled = true,
    SoundVolume = 0.55,
    WindowTransparency = 0.08,
    ShowFloatingToggle = true,
    ControlsPosition = "Left",
    KeybindMode = "Toggle",
    ToggleKey = "RightControl",
    AutoSave = true,
    ConfigFile = "LiquidGlass_Config.json",
    UseAcrylic = true,
}

local DEFAULTS = {}
for k, v in pairs(LiquidGlass.Settings) do DEFAULTS[k] = v end

local SoundMap = {
    Click     = { id = "rbxassetid://6895079853", pitch = 1.10, vol = 0.32 },
    ToggleOn  = { id = "rbxassetid://6895079853", pitch = 1.40, vol = 0.35 },
    ToggleOff = { id = "rbxassetid://6895079853", pitch = 0.88, vol = 0.28 },
    TabSwitch = { id = "rbxassetid://6895079853", pitch = 1.25, vol = 0.30 },
    Dropdown  = { id = "rbxassetid://6895079853", pitch = 1.00, vol = 0.30 },
    Notify    = { id = "rbxassetid://4590662766", pitch = 1.35, vol = 0.38 },
}

local function Tween(obj, duration, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    tw:Play()
    return tw
end

local function MicroBounce(obj, scale)
    scale = scale or 0.94
    local s = obj:FindFirstChildOfClass("UIScale")
    if not s then s = Instance.new("UIScale", obj) end
    Tween(s, 0.08, {Scale = scale}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.08, function()
        Tween(s, 0.2, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

local function ColorToHex(col)
    return string.format("#%02x%02x%02x", math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255))
end

local function HexToColor(hex)
    if not hex or type(hex) ~= "string" then return nil end
    local clean = hex:gsub("#", ""):gsub("%s+", "")
    if #clean == 6 then
        return Color3.fromRGB(
            tonumber(clean:sub(1,2),16) or 0,
            tonumber(clean:sub(3,4),16) or 0,
            tonumber(clean:sub(5,6),16) or 0
        )
    end
    return nil
end

-- ============================================================
-- LIBRARY INIT
-- ============================================================
function LiquidGlass.new(options)
    options = options or {}
    local self = setmetatable({}, LiquidGlass)

    self.Icons = Icons
    self.Shape = Shape
    self.Acrylic = Acrylic

    self.ThemeRegistry = {
        Gradients = {}, Accents = {}, Backgrounds = {}, Sidebars = {},
        Boxes = {}, SubBoxes = {}, Borders = {}, ModeSelectors = {},
    }

    self.Instances = {}
    self.Connections = {}
    self.Windows = {}
    self.Notifications = {}
    self.ActiveNotification = nil
    self.AutoSaveDebounce = nil

    for k, v in pairs(DEFAULTS) do
        self.Settings[k] = options[k] ~= nil and options[k] or v
    end

    self.Theme = self.Themes[self.Settings.Theme] or self.Themes.Aurora

    self:_LoadConfig()

    return self
end

function LiquidGlass:_Register(cat, obj)
    if self.ThemeRegistry[cat] then
        table.insert(self.ThemeRegistry[cat], obj)
    end
end

function LiquidGlass:_PlaySound(name)
    if not self.Settings.SoundEnabled then return end
    local conf = SoundMap[name] or SoundMap.Click
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = conf.id
        s.Volume = conf.vol * (self.Settings.SoundVolume or 0.55)
        s.PlaybackSpeed = conf.pitch
        s.Parent = SoundService
        s.Ended:Connect(function() s:Destroy() end)
        task.delay(1.5, function() if s and s.Parent then s:Destroy() end end)
        s:Play()
    end)
end

function LiquidGlass:_ApplyGradient(parent, c1, c2, rotation)
    if parent:IsA("TextLabel") or parent:IsA("TextButton") then
        parent.TextColor3 = Color3.fromRGB(255,255,255)
    end
    local isSolid = (self.Settings.AccentStyle == "Solid")
    c1 = c1 or self.Theme.Grad1
    c2 = isSolid and c1 or (c2 or self.Theme.Grad2)
    local grad = parent:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Parent = parent
    end
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    grad.Rotation = rotation or 0
    self:_Register("Gradients", grad)
    return grad
end

function LiquidGlass:_UpdateLiveTheme()
    local isSolid = (self.Settings.AccentStyle == "Solid")
    local c1 = self.Theme.Grad1 or self.Theme.Accent
    local c2 = isSolid and c1 or (self.Theme.Grad2 or self.Theme.AccentLight)

    for _, g in ipairs(self.ThemeRegistry.Gradients) do
        if g and g.Parent then
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(1, c2)
            })
        end
    end
    for _, item in ipairs(self.ThemeRegistry.Accents) do
        if item and item.Parent then
            if item:IsA("UIStroke") then
                item.Color = self.Theme.Accent
            elseif item:IsA("ImageLabel") or item:IsA("ImageButton") then
                item.ImageColor3 = self.Theme.AccentLight
            elseif item:IsA("TextLabel") or item:IsA("TextButton") then
                if item:FindFirstChildOfClass("UIGradient") then
                    item.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    item.TextColor3 = self.Theme.AccentLight
                end
            elseif item:IsA("Frame") then
                item.BackgroundColor3 = self.Theme.Accent
            end
        end
    end
    for _, bg in ipairs(self.ThemeRegistry.Backgrounds) do
        if bg and bg.Parent then bg.BackgroundColor3 = self.Theme.Background end
    end
    for _, sb in ipairs(self.ThemeRegistry.Sidebars) do
        if sb and sb.Parent then sb.BackgroundColor3 = self.Theme.Sidebar end
    end
    for _, bx in ipairs(self.ThemeRegistry.Boxes) do
        if bx and bx.Parent then bx.BackgroundColor3 = self.Theme.Box end
    end
    for _, sb in ipairs(self.ThemeRegistry.SubBoxes) do
        if sb and sb.Parent then sb.BackgroundColor3 = self.Theme.SubBox end
    end
    for _, st in ipairs(self.ThemeRegistry.Borders) do
        if st and st.Parent then
            if st:IsA("UIStroke") then
                st.Color = self.Theme.Border
            elseif st:IsA("Frame") then
                st.BackgroundColor3 = self.Theme.Border
            end
        end
    end
    for _, fn in ipairs(self.ThemeRegistry.ModeSelectors) do
        pcall(fn)
    end
end

function LiquidGlass:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.Settings.Theme = themeName
    self.Theme = self.Themes[themeName]
    self:_UpdateLiveTheme()
    self:_AutoSave()
end

function LiquidGlass:SetAccentStyle(style)
    self.Settings.AccentStyle = style
    self:_UpdateLiveTheme()
    self:_AutoSave()
end

function LiquidGlass:SaveConfig()
    pcall(function()
        if writefile then
            local data = {}
            for k, v in pairs(self.Settings) do
                if type(v) ~= "table" then
                    data[k] = v
                end
            end
            writefile(self.Settings.ConfigFile, HttpService:JSONEncode(data))
        end
    end)
end

function LiquidGlass:_LoadConfig()
    pcall(function()
        if isfile and readfile and isfile(self.Settings.ConfigFile) then
            local raw = readfile(self.Settings.ConfigFile)
            if raw and raw ~= "" then
                local data = HttpService:JSONDecode(raw)
                if type(data) == "table" then
                    for k, v in pairs(data) do
                        if DEFAULTS[k] ~= nil then
                            self.Settings[k] = v
                        end
                    end
                end
            end
        end
    end)
    if self.Themes[self.Settings.Theme] then
        self.Theme = self.Themes[self.Settings.Theme]
    end
end

function LiquidGlass:_AutoSave()
    if not self.Settings.AutoSave then return end
    if self.AutoSaveDebounce then task.cancel(self.AutoSaveDebounce) end
    self.AutoSaveDebounce = task.delay(0.35, function()
        self:SaveConfig()
        self.AutoSaveDebounce = nil
    end)
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
function LiquidGlass:Notify(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Notification"
    local content = cfg.Content or ""
    local duration = cfg.Duration or 3.5
    local badge = cfg.Badge or "INFO"
    local badgeColor = cfg.BadgeColor or self.Theme.AccentLight

    self:_PlaySound("Notify")

    if self.ActiveNotification and self.ActiveNotification.Parent then
        pcall(function() self.ActiveNotification:Destroy() end)
    end

    local parent = nil
    if self.CurrentWindow and self.CurrentWindow.MainWindow and self.CurrentWindow.MainWindow.Visible then
        parent = self.CurrentWindow.MainWindow
    else
        parent = self.ScreenGui
    end

    if not parent then return end

    local notif = Instance.new("Frame")
    notif.Name = "LiquidGlass_Notification"
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.Size = UDim2.new(0, 380, 0, 62)
    notif.Position = UDim2.new(0.5, 0, 0, -70)
    notif.BackgroundColor3 = self.Theme.Box
    notif.BackgroundTransparency = 0.1
    notif.ZIndex = 5000
    notif.ClipsDescendants = true
    notif.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.4
    stroke.Color = self.Theme.BorderLight
    stroke.Transparency = 0.3
    stroke.Parent = notif
    self:_ApplyGradient(stroke, self.Theme.Grad1, self.Theme.Grad2, 45)

    -- Icon
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 38, 0, 38)
    iconFrame.Position = UDim2.new(0, 12, 0.5, -19)
    iconFrame.BackgroundColor3 = self.Theme.SubBox
    iconFrame.BackgroundTransparency = 0.15
    iconFrame.BorderSizePixel = 0
    iconFrame.ZIndex = 5001
    iconFrame.Parent = notif
    local ic2 = Instance.new("UICorner"); ic2.CornerRadius = UDim.new(0, 10); ic2.Parent = iconFrame

    local icon = Icons.Create(cfg.Icon or "bell", nil, UDim2.fromOffset(22, 22), self.Theme.AccentLight)
    icon.Position = UDim2.new(0.5, -11, 0.5, -11)
    icon.Parent = iconFrame
    self:_Register("Accents", icon)

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -170, 0, 18)
    titleLbl.Position = UDim2.new(0, 60, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12
    titleLbl.TextColor3 = self.Theme.TextTitle
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.Text = string.upper(title)
    titleLbl.ZIndex = 5001
    titleLbl.Parent = notif

    -- Content
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -170, 0, 16)
    descLbl.Position = UDim2.new(0, 60, 0, 32)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.GothamMedium
    descLbl.TextSize = 10
    descLbl.TextColor3 = self.Theme.AccentLight
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextTruncate = Enum.TextTruncate.AtEnd
    descLbl.Text = content
    descLbl.ZIndex = 5001
    descLbl.Parent = notif
    self:_Register("Accents", descLbl)

    -- Badge
    local badgeFrame = Instance.new("Frame")
    badgeFrame.Size = UDim2.new(0, 66, 0, 22)
    badgeFrame.Position = UDim2.new(1, -78, 0.5, -11)
    badgeFrame.BackgroundColor3 = badgeColor
    badgeFrame.BackgroundTransparency = 0.82
    badgeFrame.ZIndex = 5001
    badgeFrame.Parent = notif
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = badgeFrame
    local bs = Instance.new("UIStroke")
    bs.Color = badgeColor; bs.Thickness = 0.8; bs.Transparency = 0.4
    bs.Parent = badgeFrame

    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Size = UDim2.fromScale(1, 1)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Font = Enum.Font.GothamBold
    badgeLbl.TextSize = 9
    badgeLbl.TextColor3 = badgeColor
    badgeLbl.Text = string.upper(badge)
    badgeLbl.ZIndex = 5002
    badgeLbl.Parent = badgeFrame

    self.ActiveNotification = notif

    -- Animate
    Tween(notif, 0.4, {
        Position = UDim2.new(0.5, 0, 0, 24)
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local dismissed = false
    local function Dismiss()
        if dismissed then return end
        dismissed = true
        Tween(notif, 0.3, {
            Position = UDim2.new(0.5, 0, 0, -70),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.35, function()
            if notif and notif.Parent then notif:Destroy() end
        end)
    end

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.fromScale(1, 1)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 5005
    clickArea.Parent = notif
    clickArea.MouseButton1Click:Connect(Dismiss)

    task.delay(duration, Dismiss)

    return notif
end

-- ============================================================
-- WINDOW CREATION
-- ============================================================
function LiquidGlass:CreateWindow(cfg)
    cfg = cfg or {}
    local self_ = self

    local title = cfg.Title or "LiquidGlass"
    local subtitle = cfg.SubTitle or "v2.0"
    local winSize = cfg.Size or UDim2.fromOffset(720, 485)
    local toggleKey = cfg.ToggleKey or Enum.KeyCode[self.Settings.ToggleKey] or Enum.KeyCode.RightControl
    local logo = cfg.Logo

    local parent = SafeParent()

    -- Clean up old
    pcall(function()
        local old = parent:FindFirstChild("LiquidGlass_Host")
        if old then old:Destroy() end
    end)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LiquidGlass_Host"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = parent
    self.ScreenGui = screenGui

    -- ===== MAIN WINDOW =====
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = winSize
    main.Position = UDim2.new(0.5, -winSize.X.Offset/2, 0.5, -winSize.Y.Offset/2)
    main.BackgroundColor3 = self.Theme.Background
    main.BackgroundTransparency = self.Settings.WindowTransparency
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.ZIndex = 10
    main.Parent = screenGui
    self:_Register("Backgrounds", main)

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 22)
    mainCorner.Parent = main

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = self.Theme.BorderLight
    mainStroke.Thickness = 1.2
    mainStroke.Transparency = 0.6
    mainStroke.Parent = main
    self:_Register("Borders", mainStroke)

    -- Glass gradient overlay
    local glassGrad = Instance.new("UIGradient")
    glassGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220,220,230)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,180,200)),
    })
    glassGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.92),
        NumberSequenceKeypoint.new(1, 0.96),
    })
    glassGrad.Rotation = 120
    glassGrad.Parent = main

    -- ===== ACRYLIC =====
    local acrylic = nil
    if self.Settings.UseAcrylic and Acrylic then
        acrylic = Acrylic.Create(main)
    end

    -- ===== WINDOW SCALE =====
    local winScale = Instance.new("UIScale")
    winScale.Scale = 1
    winScale.Parent = main

    local function UpdateResponsiveScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local isTouch = UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled and UserInputService.MouseEnabled)
        if isTouch or vp.X < 920 or vp.Y < 560 then
            local sx = (vp.X * 0.92) / 720
            local sy = (vp.Y * 0.90) / 485
            winScale.Scale = math.clamp(math.min(sx, sy), 0.55, 0.92)
        else
            winScale.Scale = 1
        end
    end
    UpdateResponsiveScale()
    if workspace.CurrentCamera then
        table.insert(self.Connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale))
    end

    -- ===== DRAG =====
    local function AttachDrag(handle)
        local dragging, dragStart, startPos
        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = inp.Position
                startPos = main.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        handle.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ===== HEADER =====
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundTransparency = 1
    header.ZIndex = 20
    header.Parent = main
    AttachDrag(header)

    -- Header bottom line
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = self.Theme.Border
    headerLine.BackgroundTransparency = 0.5
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header
    self:_Register("Borders", headerLine)

    -- Traffic dots
    local traffic = Instance.new("Frame")
    traffic.Size = UDim2.new(0, 62, 1, 0)
    traffic.Position = UDim2.new(0, 16, 0, 0)
    traffic.BackgroundTransparency = 1
    traffic.Parent = header
    local tcLayout = Instance.new("UIListLayout")
    tcLayout.FillDirection = Enum.FillDirection.Horizontal
    tcLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tcLayout.Padding = UDim.new(0, 8)
    tcLayout.Parent = traffic

    local function MakeDot(color, hoverColor, callback)
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.fromOffset(12, 12)
        dot.BackgroundColor3 = color
        dot.Text = ""
        dot.AutoButtonColor = false
        dot.Parent = traffic
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = dot
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(0,0,0); s.Thickness = 0.5; s.Transparency = 0.7
        s.Parent = dot

        dot.MouseEnter:Connect(function()
            Tween(dot, 0.15, {BackgroundColor3 = hoverColor})
        end)
        dot.MouseLeave:Connect(function()
            Tween(dot, 0.15, {BackgroundColor3 = color})
        end)
        dot.MouseButton1Click:Connect(function()
            self:_PlaySound("Click")
            MicroBounce(dot)
            if callback then callback() end
        end)
        return dot
    end

    MakeDot(Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 130, 120), function()
        Tween(main, 0.25, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
        task.delay(0.3, function()
            main.Visible = false
        end)
        if acrylic then acrylic.SetVisible(false) end
    end)

    MakeDot(Color3.fromRGB(254, 188, 46), Color3.fromRGB(255, 215, 80), function()
        Tween(main, 0.25, {Size = UDim2.new(0, winSize.X.Offset, 0, 48)})
    end)

    MakeDot(Color3.fromRGB(39, 201, 63), Color3.fromRGB(75, 235, 100), function()
        Tween(main, 0.3, {
            Position = UDim2.new(0.5, -winSize.X.Offset/2, 0.5, -winSize.Y.Offset/2)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -220, 0, 20)
    titleLbl.Position = UDim2.new(0, 90, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = self.Theme.TextTitle
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = title
    titleLbl.Parent = header

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -220, 0, 14)
    subLbl.Position = UDim2.new(0, 90, 0, 28)
    subLbl.BackgroundTransparency = 1
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 10
    subLbl.TextColor3 = self.Theme.TextDim
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Text = subtitle
    subLbl.Parent = header

    -- ===== BODY =====
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -48)
    body.Position = UDim2.new(0, 0, 0, 48)
    body.BackgroundTransparency = 1
    body.ZIndex = 15
    body.Parent = main

    -- ===== SIDEBAR =====
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 178, 1, -12)
    sidebar.Position = UDim2.new(0, 6, 0, 6)
    sidebar.BackgroundColor3 = self.Theme.Sidebar
    sidebar.BackgroundTransparency = 0.4
    sidebar.BorderSizePixel = 0
    sidebar.Parent = body
    self:_Register("Sidebars", sidebar)
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 16); sc.Parent = sidebar
    local sStroke = Instance.new("UIStroke")
    sStroke.Color = self.Theme.BorderLight
    sStroke.Thickness = 1
    sStroke.Transparency = 0.85
    sStroke.Parent = sidebar

    -- Logo
    local logoHolder = Instance.new("Frame")
    logoHolder.Size = UDim2.new(1, 0, 0, 90)
    logoHolder.BackgroundTransparency = 1
    logoHolder.Parent = sidebar

    local logoBtn = Instance.new("TextButton")
    logoBtn.Size = UDim2.fromOffset(72, 72)
    logoBtn.Position = UDim2.new(0.5, -36, 0.5, -36)
    logoBtn.BackgroundColor3 = self.Theme.Box
    logoBtn.BackgroundTransparency = 0.2
    logoBtn.Text = ""
    logoBtn.AutoButtonColor = false
    logoBtn.Parent = logoHolder
    local lbc = Instance.new("UICorner"); lbc.CornerRadius = UDim.new(0, 20); lbc.Parent = logoBtn
    local lbs = Instance.new("UIStroke")
    lbs.Thickness = 1.6
    lbs.Parent = logoBtn
    self:_ApplyGradient(lbs, self.Theme.Grad1, self.Theme.Grad2, 45)

    local logoIcon = Icons.Create(logo or "sparkles", nil, UDim2.fromOffset(56, 56), Color3.fromRGB(255,255,255))
    logoIcon.Position = UDim2.new(0.5, -28, 0.5, -28)
    logoIcon.Parent = logoBtn

    logoBtn.MouseEnter:Connect(function()
        Tween(logoBtn, 0.2, {Size = UDim2.fromOffset(78, 78), Position = UDim2.new(0.5, -39, 0.5, -39)})
    end)
    logoBtn.MouseLeave:Connect(function()
        Tween(logoBtn, 0.2, {Size = UDim2.fromOffset(72, 72), Position = UDim2.new(0.5, -36, 0.5, -36)})
    end)

    -- Nav scroll
    local navScroll = Instance.new("ScrollingFrame")
    navScroll.Size = UDim2.new(1, -12, 1, -100)
    navScroll.Position = UDim2.new(0, 6, 0, 94)
    navScroll.BackgroundTransparency = 1
    navScroll.BorderSizePixel = 0
    navScroll.ScrollBarThickness = 2
    navScroll.ScrollBarImageColor3 = self.Theme.Border
    navScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    navScroll.CanvasSize = UDim2.new()
    navScroll.Parent = sidebar

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)
    navLayout.Parent = navScroll

    local navPad = Instance.new("UIPadding")
    navPad.PaddingTop = UDim.new(0, 8)
    navPad.PaddingBottom = UDim.new(0, 10)
    navPad.Parent = navScroll

    -- ===== CONTENT =====
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -190, 1, -12)
    content.Position = UDim2.new(0, 184, 0, 6)
    content.BackgroundTransparency = 1
    content.Parent = body

    -- ===== WINDOW OBJECT =====
    local WindowObj = {
        ScreenGui = screenGui,
        MainWindow = main,
        Body = body,
        Sidebar = sidebar,
        Content = content,
        Header = header,
        Acrylic = acrylic,
        Tabs = {},
        ActiveTab = nil,
        Keybind = toggleKey,
        AllSearchable = {},
        IsMinimized = false,
        _lib = self,
    }

    function WindowObj:Notify(cfg) return self_:Notify(cfg) end

    function WindowObj:Toggle()
        if main.Visible then
            Tween(winScale, 0.22, {Scale = 0.85}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.22, function()
                main.Visible = false
                winScale.Scale = 1
            end)
            if acrylic then acrylic.SetVisible(false) end
            self_:_PlaySound("ToggleOff")
        else
            main.Visible = true
            winScale.Scale = 0.85
            Tween(winScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            if acrylic then acrylic.SetVisible(true) end
            self_:_PlaySound("ToggleOn")
        end
    end

    function WindowObj:SetKeybind(keyCode)
        WindowObj.Keybind = keyCode
        self_.Settings.ToggleKey = keyCode.Name
        self_:_AutoSave()
    end

    function WindowObj:Destroy()
        if acrylic then acrylic.Destroy() end
        for _, c in ipairs(self_.Connections) do
            pcall(function() c:Disconnect() end)
        end
        pcall(function() screenGui:Destroy() end)
    end

    function WindowObj:AddNavHeader(text, order)
        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(1, -8, 0, 26)
        h.BackgroundTransparency = 1
        h.Font = Enum.Font.GothamBold
        h.TextSize = 9
        h.TextColor3 = self_.Theme.TextDim
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Text = string.upper(text)
        h.LayoutOrder = order or (#navScroll:GetChildren() + 1)
        h.Parent = navScroll
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 8)
        p.Parent = h
        return h
    end

    function WindowObj:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local tabTitle = tabCfg.Title or "Tab"
        local tabIcon = tabCfg.Icon or "home"
        local badge = tabCfg.BadgeText
        local order = tabCfg.LayoutOrder or (#WindowObj.Tabs + 1)

        -- Tab button
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.Parent = navScroll
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = btn

        local activeBg = Instance.new("Frame")
        activeBg.Size = UDim2.fromScale(1, 1)
        activeBg.BackgroundColor3 = self_.Theme.Accent
        activeBg.BackgroundTransparency = 1
        activeBg.BorderSizePixel = 0
        activeBg.Parent = btn
        local abcg = Instance.new("UICorner"); abcg.CornerRadius = UDim.new(0, 10); abcg.Parent = activeBg

        local iconLbl = Icons.Create(tabIcon, nil, UDim2.fromOffset(18, 18), self_.Theme.TextDim)
        iconLbl.Position = UDim2.fromOffset(12, 11)
        iconLbl.Parent = btn

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -50, 1, 0)
        nameLbl.Position = UDim2.fromOffset(42, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamMedium
        nameLbl.TextSize = 12
        nameLbl.TextColor3 = self_.Theme.TextDim
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Text = tabTitle
        nameLbl.Parent = btn

        -- Content page
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = self_.Theme.Border
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new()
        page.Visible = false
        page.Parent = content

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingTop = UDim.new(0, 8)
        pagePad.PaddingBottom = UDim.new(0, 20)
        pagePad.PaddingLeft = UDim.new(0, 4)
        pagePad.PaddingRight = UDim.new(0, 4)
        pagePad.Parent = page

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.Parent = page

        local TabData = {
            Title = tabTitle,
            Icon = tabIcon,
            Button = btn,
            IconLbl = iconLbl,
            NameLbl = nameLbl,
            ActiveBg = activeBg,
            Page = page,
            Layout = pageLayout,
        }

        -- Hover
        btn.MouseEnter:Connect(function()
            if WindowObj.ActiveTab ~= TabData then
                Tween(activeBg, 0.15, {BackgroundTransparency = 0.88})
                Tween(nameLbl, 0.15, {TextColor3 = self_.Theme.TextTitle})
                if iconLbl.ImageColor3 then
                    Tween(iconLbl, 0.15, {ImageColor3 = self_.Theme.TextTitle})
                end
            end
        end)
        btn.MouseLeave:Connect(function()
            if WindowObj.ActiveTab ~= TabData then
                Tween(activeBg, 0.15, {BackgroundTransparency = 1})
                Tween(nameLbl, 0.15, {TextColor3 = self_.Theme.TextDim})
                if iconLbl.ImageColor3 then
                    Tween(iconLbl, 0.15, {ImageColor3 = self_.Theme.TextDim})
                end
            end
        end)

        local function Activate()
            if WindowObj.ActiveTab == TabData then return end
            self_:_PlaySound("TabSwitch")
            MicroBounce(btn)

            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                t.ActiveBg.BackgroundTransparency = 1
                t.NameLbl.TextColor3 = self_.Theme.TextDim
                t.NameLbl.Font = Enum.Font.GothamMedium
                if t.IconLbl.ImageColor3 then
                    t.IconLbl.ImageColor3 = self_.Theme.TextDim
                end
            end

            WindowObj.ActiveTab = TabData
            page.Visible = true
            page.Position = UDim2.fromOffset(8, 0)
            Tween(page, 0.25, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            activeBg.BackgroundTransparency = 0.82
            nameLbl.TextColor3 = self_.Theme.TextTitle
            nameLbl.Font = Enum.Font.GothamBold
            if iconLbl.ImageColor3 then
                iconLbl.ImageColor3 = self_.Theme.AccentLight
            end
        end

        btn.MouseButton1Click:Connect(Activate)
        TabData.Activate = Activate

        table.insert(WindowObj.Tabs, TabData)
        if #WindowObj.Tabs == 1 then Activate() end

        -- ===== TAB METHODS =====
        local TabObj = {}

        TabObj.CreateGroupBox = function(_, side, title, badge, icon)
            side = side or "Left"
            title = title or "Group"
            badge = badge or ""
            icon = icon or "settings"

            local groupFrame = Instance.new("Frame")
            groupFrame.Name = "Group_" .. title
            groupFrame.Size = UDim2.new(0.5, -6, 0, 40)
            groupFrame.Position = side == "Left" and UDim2.fromOffset(0, 0) or UDim2.new(0.5, 6, 0, 0)
            groupFrame.BackgroundColor3 = self_.Theme.Box
            groupFrame.BackgroundTransparency = 0.3
            groupFrame.BorderSizePixel = 0
            groupFrame.AutomaticSize = Enum.AutomaticSize.Y
            groupFrame.LayoutOrder = #page:GetChildren()
            groupFrame.Parent = page
            local gfc = Instance.new("UICorner"); gfc.CornerRadius = UDim.new(0, 14); gfc.Parent = groupFrame
            local gfs = Instance.new("UIStroke")
            gfs.Color = self_.Theme.BorderLight
            gfs.Thickness = 1
            gfs.Transparency = 0.75
            gfs.Parent = groupFrame
            self_:_Register("Boxes", groupFrame)
            self_:_Register("Borders", gfs)

            -- Header
            local gh = Instance.new("Frame")
            gh.Size = UDim2.new(1, 0, 0, 40)
            gh.BackgroundTransparency = 1
            gh.Parent = groupFrame

            local ghIcon = Icons.Create(icon, nil, UDim2.fromOffset(16, 16), self_.Theme.AccentLight)
            ghIcon.Position = UDim2.fromOffset(14, 12)
            ghIcon.Parent = gh
            self_:_Register("Accents", ghIcon)

            local ghTitle = Instance.new("TextLabel")
            ghTitle.Size = UDim2.new(1, -100, 0, 16)
            ghTitle.Position = UDim2.fromOffset(38, 8)
            ghTitle.BackgroundTransparency = 1
            ghTitle.Font = Enum.Font.GothamBold
            ghTitle.TextSize = 11
            ghTitle.TextColor3 = self_.Theme.TextTitle
            ghTitle.TextXAlignment = Enum.TextXAlignment.Left
            ghTitle.Text = string.upper(title)
            ghTitle.Parent = gh

            if badge ~= "" then
                local ghBadge = Instance.new("TextLabel")
                ghBadge.Size = UDim2.fromOffset(70, 18)
                ghBadge.Position = UDim2.new(1, -80, 0.5, -9)
                ghBadge.BackgroundColor3 = self_.Theme.SubBox
                ghBadge.BackgroundTransparency = 0.3
                ghBadge.Font = Enum.Font.GothamBold
                ghBadge.TextSize = 9
                ghBadge.TextColor3 = self_.Theme.Success
                ghBadge.Text = string.upper(badge)
                ghBadge.Parent = gh
                local bc2 = Instance.new("UICorner"); bc2.CornerRadius = UDim.new(1, 0); bc2.Parent = ghBadge
            end

            local ghLine = Instance.new("Frame")
            ghLine.Size = UDim2.new(1, 0, 0, 1)
            ghLine.Position = UDim2.new(0, 0, 1, -1)
            ghLine.BackgroundColor3 = self_.Theme.Border
            ghLine.BackgroundTransparency = 0.5
            ghLine.BorderSizePixel = 0
            ghLine.Parent = gh

            -- Items container
            local items = Instance.new("Frame")
            items.Size = UDim2.new(1, 0, 0, 0)
            items.Position = UDim2.fromOffset(0, 40)
            items.BackgroundTransparency = 1
            items.AutomaticSize = Enum.AutomaticSize.Y
            items.Parent = groupFrame

            local il = Instance.new("UIListLayout")
            il.SortOrder = Enum.SortOrder.LayoutOrder
            il.Padding = UDim.new(0, 8)
            il.Parent = items

            local ip = Instance.new("UIPadding")
            ip.PaddingLeft = UDim.new(0, 14)
            ip.PaddingRight = UDim.new(0, 14)
            ip.PaddingTop = UDim.new(0, 6)
            ip.PaddingBottom = UDim.new(0, 14)
            ip.Parent = items

            -- ===== GROUP OBJECT =====
            local GroupObj = { Frame = groupFrame, Items = items }

            -- Helper to register search
            local function Register(f, text)
                table.insert(WindowObj.AllSearchable, { Frame = f, SearchText = string.lower(text or "") })
            end

            GroupObj.AddToggle = function(_, tTitle, tDesc, default, callback)
                callback = callback or function() end
                local state = default or false

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 44)
                row.BackgroundColor3 = self_.Theme.SubBox
                row.BackgroundTransparency = 0.4
                row.BorderSizePixel = 0
                row.LayoutOrder = #items:GetChildren()
                row.Parent = items
                local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 10); rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = self_.Theme.Border; rs.Thickness = 1; rs.Transparency = 0.8; rs.Parent = row

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, -70, 0, 18)
                tl.Position = UDim2.fromOffset(12, 6)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.TextBody
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Toggle"
                tl.Parent = row

                if tDesc and tDesc ~= "" then
                    local dl = Instance.new("TextLabel")
                    dl.Size = UDim2.new(1, -70, 0, 14)
                    dl.Position = UDim2.fromOffset(12, 26)
                    dl.BackgroundTransparency = 1
                    dl.Font = Enum.Font.Gotham
                    dl.TextSize = 10
                    dl.TextColor3 = self_.Theme.TextDim
                    dl.TextXAlignment = Enum.TextXAlignment.Left
                    dl.Text = tDesc
                    dl.Parent = row
                end

                -- Switch track
                local track = Instance.new("Frame")
                track.Size = UDim2.fromOffset(42, 24)
                track.Position = UDim2.new(1, -54, 0.5, -12)
                track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                track.BorderSizePixel = 0
                track.Parent = row
                local tc2 = Instance.new("UICorner"); tc2.CornerRadius = UDim.new(1, 0); tc2.Parent = track

                -- Knob
                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(20, 20)
                knob.Position = UDim2.fromOffset(2, 2)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.Parent = track
                local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

                local grad = nil

                local function UpdateVisual(animate)
                    local info = animate and TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out) or TweenInfo.new(0)
                    if state then
                        Tween(track, info, {BackgroundColor3 = self_.Theme.Accent})
                        Tween(knob, info, {Position = UDim2.fromOffset(20, 2)})
                        if not grad then
                            grad = self_:_ApplyGradient(track, self_.Theme.Grad1, self_.Theme.Grad2, 0)
                        end
                    else
                        if grad then grad:Destroy() grad = nil end
                        Tween(track, info, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)})
                        Tween(knob, info, {Position = UDim2.fromOffset(2, 2)})
                    end
                end

                UpdateVisual(false)

                local clickArea = Instance.new("TextButton")
                clickArea.Size = UDim2.fromScale(1, 1)
                clickArea.BackgroundTransparency = 1
                clickArea.Text = ""
                clickArea.Parent = row

                clickArea.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateVisual(true)
                    self_:_PlaySound(state and "ToggleOn" or "ToggleOff")
                    MicroBounce(track, 0.92)
                    pcall(callback, state)
                end)

                clickArea.MouseEnter:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.25})
                end)
                clickArea.MouseLeave:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.4})
                end)

                Register(row, tTitle .. " " .. (tDesc or ""))

                local obj = {}
                function obj:Set(v) state = v UpdateVisual(true) end
                function obj:Get() return state end
                return obj
            end

            GroupObj.AddSlider = function(_, tTitle, minVal, maxVal, default, suffix, callback)
                callback = callback or function() end
                minVal = minVal or 0
                maxVal = maxVal or 100
                default = default or minVal
                suffix = suffix or ""

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 52)
                row.BackgroundColor3 = self_.Theme.SubBox
                row.BackgroundTransparency = 0.4
                row.BorderSizePixel = 0
                row.LayoutOrder = #items:GetChildren()
                row.Parent = items
                local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 10); rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = self_.Theme.Border; rs.Thickness = 1; rs.Transparency = 0.8; rs.Parent = row

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(0.7, 0, 0, 16)
                tl.Position = UDim2.fromOffset(12, 6)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 11
                tl.TextColor3 = self_.Theme.TextBody
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Slider"
                tl.Parent = row

                local vl = Instance.new("TextLabel")
                vl.Size = UDim2.new(0.3, -24, 0, 16)
                vl.Position = UDim2.new(0.7, 12, 0, 6)
                vl.BackgroundTransparency = 1
                vl.Font = Enum.Font.GothamBold
                vl.TextSize = 11
                vl.TextColor3 = self_.Theme.AccentLight
                vl.TextXAlignment = Enum.TextXAlignment.Right
                vl.Text = tostring(default) .. " " .. suffix
                vl.Parent = row
                self_:_Register("Accents", vl)

                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -24, 0, 6)
                track.Position = UDim2.fromOffset(12, 34)
                track.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
                track.BorderSizePixel = 0
                track.Parent = row
                local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = track

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((default - minVal) / math.max(maxVal - minVal, 0.0001), 0, 1, 0)
                fill.BackgroundColor3 = self_.Theme.Accent
                fill.BorderSizePixel = 0
                fill.Parent = track
                local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill
                self_:_ApplyGradient(fill, self_.Theme.Grad1, self_.Theme.Grad2, 0)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(16, 16)
                knob.Position = UDim2.new((default - minVal) / math.max(maxVal - minVal, 0.0001), -8, 0.5, -8)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.Parent = track
                local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob
                local ks = Instance.new("UIStroke")
                ks.Color = self_.Theme.Accent; ks.Thickness = 2; ks.Parent = knob

                local value = default
                local dragging = false

                local function UpdateFromInput(input)
                    local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = math.floor(minVal + (maxVal - minVal) * relX)
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    knob.Position = UDim2.new(relX, -8, 0.5, -8)
                    vl.Text = tostring(value) .. " " .. suffix
                    pcall(callback, value)
                end

                local btn2 = Instance.new("TextButton")
                btn2.Size = UDim2.fromScale(1, 1)
                btn2.BackgroundTransparency = 1
                btn2.Text = ""
                btn2.Parent = row

                btn2.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateFromInput(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromInput(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                btn2.MouseEnter:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.25})
                end)
                btn2.MouseLeave:Connect(function()
                    if not dragging then
                        Tween(row, 0.15, {BackgroundTransparency = 0.4})
                    end
                end)

                Register(row, tTitle)

                local obj = {}
                function obj:Set(v)
                    value = math.clamp(v, minVal, maxVal)
                    local relX = (value - minVal) / math.max(maxVal - minVal, 0.0001)
                    fill.Size = UDim2.new(relX, 0, 1, 0)
                    knob.Position = UDim2.new(relX, -8, 0.5, -8)
                    vl.Text = tostring(value) .. " " .. suffix
                end
                function obj:Get() return value end
                return obj
            end

            GroupObj.AddDropdown = function(_, tTitle, options, default, callback)
                callback = callback or function() end
                options = options or {}
                default = default or (options[1] or "")
                local selected = default
                local isOpen = false

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 44)
                row.BackgroundColor3 = self_.Theme.SubBox
                row.BackgroundTransparency = 0.4
                row.BorderSizePixel = 0
                row.ClipsDescendants = true
                row.LayoutOrder = #items:GetChildren()
                row.Parent = items
                local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 10); rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = self_.Theme.Border; rs.Thickness = 1; rs.Transparency = 0.8; rs.Parent = row

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(0.5, -12, 0, 44)
                tl.Position = UDim2.fromOffset(12, 0)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.TextBody
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Dropdown"
                tl.Parent = row

                local vl = Instance.new("TextLabel")
                vl.Size = UDim2.new(0.5, -30, 0, 44)
                vl.Position = UDim2.new(0.5, 0, 0, 0)
                vl.BackgroundTransparency = 1
                vl.Font = Enum.Font.GothamBold
                vl.TextSize = 11
                vl.TextColor3 = self_.Theme.AccentLight
                vl.TextXAlignment = Enum.TextXAlignment.Right
                vl.Text = tostring(selected) .. "  ▾"
                vl.Parent = row
                self_:_Register("Accents", vl)

                local listHolder = Instance.new("Frame")
                listHolder.Size = UDim2.new(1, -8, 0, 0)
                listHolder.Position = UDim2.fromOffset(4, 44)
                listHolder.BackgroundColor3 = self_.Theme.Background
                listHolder.BackgroundTransparency = 0.15
                listHolder.BorderSizePixel = 0
                listHolder.ClipsDescendants = true
                listHolder.Parent = row
                local lc = Instance.new("UICorner"); lc.CornerRadius = UDim.new(0, 8); lc.Parent = listHolder
                local ll = Instance.new("UIListLayout")
                ll.Padding = UDim.new(0, 2); ll.Parent = listHolder
                local lp = Instance.new("UIPadding")
                lp.PaddingTop = UDim.new(0, 4); lp.PaddingBottom = UDim.new(0, 4)
                lp.PaddingLeft = UDim.new(0, 4); lp.PaddingRight = UDim.new(0, 4)
                lp.Parent = listHolder

                local function CloseList()
                    if not isOpen then return end
                    isOpen = false
                    Tween(listHolder, 0.2, {Size = UDim2.new(1, -8, 0, 0)})
                    Tween(row, 0.2, {Size = UDim2.new(1, 0, 0, 44)})
                end

                for i, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, 28)
                    optBtn.BackgroundColor3 = self_.Theme.SubBox
                    optBtn.BackgroundTransparency = 1
                    optBtn.Text = ""
                    optBtn.AutoButtonColor = false
                    optBtn.LayoutOrder = i
                    optBtn.Parent = listHolder
                    local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0, 6); oc.Parent = optBtn

                    local ol = Instance.new("TextLabel")
                    ol.Size = UDim2.new(1, -12, 1, 0)
                    ol.Position = UDim2.fromOffset(8, 0)
                    ol.BackgroundTransparency = 1
                    ol.Font = Enum.Font.Gotham
                    ol.TextSize = 11
                    ol.TextColor3 = self_.Theme.TextBody
                    ol.TextXAlignment = Enum.TextXAlignment.Left
                    ol.Text = tostring(opt)
                    ol.Parent = optBtn

                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, 0.15, {BackgroundTransparency = 0.7})
                    end)
                    optBtn.MouseLeave:Connect(function()
                        Tween(optBtn, 0.15, {BackgroundTransparency = 1})
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        vl.Text = tostring(selected) .. "  ▾"
                        self_:_PlaySound("Dropdown")
                        CloseList()
                        pcall(callback, selected)
                    end)
                end

                local openBtn = Instance.new("TextButton")
                openBtn.Size = UDim2.fromScale(1, 1)
                openBtn.BackgroundTransparency = 1
                openBtn.Text = ""
                openBtn.Parent = row

                openBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    self_:_PlaySound("Dropdown")
                    if isOpen then
                        local h = 8 + #options * 30
                        Tween(listHolder, 0.2, {Size = UDim2.new(1, -8, 0, h)})
                        Tween(row, 0.2, {Size = UDim2.new(1, 0, 0, 44 + h)})
                    else
                        CloseList()
                    end
                end)

                openBtn.MouseEnter:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.25})
                end)
                openBtn.MouseLeave:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.4})
                end)

                Register(row, tTitle)

                local obj = {}
                function obj:Set(v) selected = v vl.Text = tostring(v) .. "  ▾" end
                function obj:Get() return selected end
                return obj
            end

            GroupObj.AddInput = function(_, tTitle, placeholder, default, callback)
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 44)
                row.BackgroundColor3 = self_.Theme.SubBox
                row.BackgroundTransparency = 0.4
                row.BorderSizePixel = 0
                row.LayoutOrder = #items:GetChildren()
                row.Parent = items
                local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 10); rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = self_.Theme.Border; rs.Thickness = 1; rs.Transparency = 0.8; rs.Parent = row

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(0.4, -12, 0, 44)
                tl.Position = UDim2.fromOffset(12, 0)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.TextBody
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Input"
                tl.Parent = row

                local box = Instance.new("Frame")
                box.Size = UDim2.new(0.6, -12, 0, 28)
                box.Position = UDim2.new(0.4, 0, 0.5, -14)
                box.BackgroundColor3 = self_.Theme.Background
                box.BackgroundTransparency = 0.3
                box.BorderSizePixel = 0
                box.Parent = row
                local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = box
                local bs = Instance.new("UIStroke")
                bs.Color = self_.Theme.Border; bs.Thickness = 1; bs.Transparency = 0.7; bs.Parent = box

                local input = Instance.new("TextBox")
                input.Size = UDim2.new(1, -16, 1, 0)
                input.Position = UDim2.fromOffset(8, 0)
                input.BackgroundTransparency = 1
                input.Text = default or ""
                input.PlaceholderText = placeholder or ""
                input.PlaceholderColor3 = self_.Theme.TextMuted
                input.TextColor3 = self_.Theme.TextTitle
                input.Font = Enum.Font.Gotham
                input.TextSize = 11
                input.TextXAlignment = Enum.TextXAlignment.Left
                input.ClearTextOnFocus = false
                input.Parent = box

                input.Focused:Connect(function()
                    Tween(box, 0.15, {BackgroundTransparency = 0.1})
                    bs.Color = self_.Theme.Accent
                    bs.Transparency = 0.3
                end)
                input.FocusLost:Connect(function()
                    Tween(box, 0.15, {BackgroundTransparency = 0.3})
                    bs.Color = self_.Theme.Border
                    bs.Transparency = 0.7
                    pcall(callback, input.Text)
                end)

                Register(row, tTitle)

                local obj = {}
                function obj:Set(v) input.Text = v end
                function obj:Get() return input.Text end
                return obj
            end

            GroupObj.AddButton = function(_, tTitle, tDesc, callback)
                callback = callback or function() end
                local hasDesc = tDesc and tDesc ~= ""

                local btn2 = Instance.new("TextButton")
                btn2.Size = UDim2.new(1, 0, 0, hasDesc and 44 or 34)
                btn2.BackgroundColor3 = self_.Theme.SubBox
                btn2.BackgroundTransparency = 0.4
                btn2.Text = ""
                btn2.AutoButtonColor = false
                btn2.LayoutOrder = #items:GetChildren()
                btn2.Parent = items
                local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = btn2
                local bs = Instance.new("UIStroke")
                bs.Color = self_.Theme.Border; bs.Thickness = 1; bs.Transparency = 0.8; bs.Parent = btn2

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, -12, 0, hasDesc and 18 or 34)
                tl.Position = UDim2.fromOffset(12, hasDesc and 4 or 0)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.TextTitle
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Button"
                tl.Parent = btn2

                if hasDesc then
                    local dl = Instance.new("TextLabel")
                    dl.Size = UDim2.new(1, -12, 0, 14)
                    dl.Position = UDim2.fromOffset(12, 24)
                    dl.BackgroundTransparency = 1
                    dl.Font = Enum.Font.Gotham
                    dl.TextSize = 10
                    dl.TextColor3 = self_.Theme.TextDim
                    dl.TextXAlignment = Enum.TextXAlignment.Left
                    dl.Text = tDesc
                    dl.Parent = btn2
                end

                btn2.MouseEnter:Connect(function()
                    Tween(btn2, 0.15, {BackgroundTransparency = 0.25})
                end)
                btn2.MouseLeave:Connect(function()
                    Tween(btn2, 0.15, {BackgroundTransparency = 0.4})
                end)
                btn2.MouseButton1Click:Connect(function()
                    self_:_PlaySound("Click")
                    MicroBounce(btn2)
                    Tween(btn2, 0.1, {BackgroundColor3 = self_.Theme.Accent})
                    task.delay(0.1, function()
                        Tween(btn2, 0.15, {BackgroundColor3 = self_.Theme.SubBox})
                    end)
                    pcall(callback)
                end)

                Register(btn2, tTitle .. " " .. (tDesc or ""))

                return {Button = btn2}
            end

            GroupObj.AddActionRow = function(_, tTitle, tDesc, iconName, callback)
                callback = callback or function() end
                local hasDesc = tDesc and tDesc ~= ""

                local btn2 = Instance.new("TextButton")
                btn2.Size = UDim2.new(1, 0, 0, 44)
                btn2.BackgroundColor3 = self_.Theme.SubBox
                btn2.BackgroundTransparency = 0.4
                btn2.Text = ""
                btn2.AutoButtonColor = false
                btn2.LayoutOrder = #items:GetChildren()
                btn2.Parent = items
                local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = btn2
                local bs = Instance.new("UIStroke")
                bs.Color = self_.Theme.Border; bs.Thickness = 1; bs.Transparency = 0.8; bs.Parent = btn2

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, -60, 0, 18)
                tl.Position = UDim2.fromOffset(12, hasDesc and 5 or 13)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.TextTitle
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Action"
                tl.Parent = btn2

                if hasDesc then
                    local dl = Instance.new("TextLabel")
                    dl.Size = UDim2.new(1, -60, 0, 14)
                    dl.Position = UDim2.fromOffset(12, 24)
                    dl.BackgroundTransparency = 1
                    dl.Font = Enum.Font.Gotham
                    dl.TextSize = 10
                    dl.TextColor3 = self_.Theme.TextDim
                    dl.TextXAlignment = Enum.TextXAlignment.Left
                    dl.TextTruncate = Enum.TextTruncate.AtEnd
                    dl.Text = tDesc
                    dl.Parent = btn2
                end

                local iconBox = Instance.new("Frame")
                iconBox.Size = UDim2.fromOffset(30, 30)
                iconBox.Position = UDim2.new(1, -42, 0.5, -15)
                iconBox.BackgroundColor3 = self_.Theme.Accent
                iconBox.BackgroundTransparency = 0.75
                iconBox.Parent = btn2
                local ibc = Instance.new("UICorner"); ibc.CornerRadius = UDim.new(0, 8); ibc.Parent = iconBox
                self_:_Register("Accents", iconBox)

                local ic2 = Icons.Create(iconName or "arrow-right", nil, UDim2.fromOffset(16, 16), self_.Theme.AccentLight)
                ic2.Position = UDim2.new(0.5, -8, 0.5, -8)
                ic2.Parent = iconBox
                self_:_Register("Accents", ic2)

                btn2.MouseEnter:Connect(function()
                    Tween(btn2, 0.15, {BackgroundTransparency = 0.25})
                    Tween(iconBox, 0.15, {BackgroundTransparency = 0.55})
                end)
                btn2.MouseLeave:Connect(function()
                    Tween(btn2, 0.15, {BackgroundTransparency = 0.4})
                    Tween(iconBox, 0.15, {BackgroundTransparency = 0.75})
                end)
                btn2.MouseButton1Click:Connect(function()
                    self_:_PlaySound("Click")
                    MicroBounce(btn2)
                    pcall(callback)
                end)

                Register(btn2, tTitle .. " " .. (tDesc or ""))

                return {Button = btn2}
            end

            GroupObj.AddDangerButton = function(_, tTitle, tDesc, iconName, callback)
                callback = callback or function() end
                local hasDesc = tDesc and tDesc ~= ""

                local btn2 = Instance.new("TextButton")
                btn2.Size = UDim2.new(1, 0, 0, 44)
                btn2.BackgroundColor3 = Color3.fromRGB(60, 25, 30)
                btn2.BackgroundTransparency = 0.3
                btn2.Text = ""
                btn2.AutoButtonColor = false
                btn2.LayoutOrder = #items:GetChildren()
                btn2.Parent = items
                local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = btn2
                local bs = Instance.new("UIStroke")
                bs.Color = self_.Theme.Danger; bs.Thickness = 1; bs.Transparency = 0.5; bs.Parent = btn2

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, -60, 0, 18)
                tl.Position = UDim2.fromOffset(12, hasDesc and 5 or 13)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.Danger
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Danger"
                tl.Parent = btn2

                if hasDesc then
                    local dl = Instance.new("TextLabel")
                    dl.Size = UDim2.new(1, -60, 0, 14)
                    dl.Position = UDim2.fromOffset(12, 24)
                    dl.BackgroundTransparency = 1
                    dl.Font = Enum.Font.Gotham
                    dl.TextSize = 10
                    dl.TextColor3 = self_.Theme.TextDim
                    dl.TextXAlignment = Enum.TextXAlignment.Left
                    dl.TextTruncate = Enum.TextTruncate.AtEnd
                    dl.Text = tDesc
                    dl.Parent = btn2
                end

                local iconBox = Instance.new("Frame")
                iconBox.Size = UDim2.fromOffset(30, 30)
                iconBox.Position = UDim2.new(1, -42, 0.5, -15)
                iconBox.BackgroundColor3 = self_.Theme.Danger
                iconBox.BackgroundTransparency = 0.7
                iconBox.Parent = btn2
                local ibc = Instance.new("UICorner"); ibc.CornerRadius = UDim.new(0, 8); ibc.Parent = iconBox

                local ic2 = Icons.Create(iconName or "trash", nil, UDim2.fromOffset(16, 16), self_.Theme.Danger)
                ic2.Position = UDim2.new(0.5, -8, 0.5, -8)
                ic2.Parent = iconBox

                btn2.MouseEnter:Connect(function()
                    Tween(btn2, 0.15, {BackgroundTransparency = 0.15, BackgroundColor3 = Color3.fromRGB(80, 30, 35)})
                end)
                btn2.MouseLeave:Connect(function()
                    Tween(btn2, 0.15, {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(60, 25, 30)})
                end)
                btn2.MouseButton1Click:Connect(function()
                    self_:_PlaySound("Click")
                    MicroBounce(btn2)
                    pcall(callback)
                end)

                return {Button = btn2}
            end

            GroupObj.AddModeSelector = function(_, tTitle, modes, defaultMode, callback)
                callback = callback or function() end
                modes = modes or {}
                defaultMode = defaultMode or modes[1]

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 60)
                row.BackgroundColor3 = self_.Theme.SubBox
                row.BackgroundTransparency = 0.4
                row.BorderSizePixel = 0
                row.LayoutOrder = #items:GetChildren()
                row.Parent = items
                local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 10); rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = self_.Theme.Border; rs.Thickness = 1; rs.Transparency = 0.8; rs.Parent = row

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(1, -12, 0, 16)
                tl.Position = UDim2.fromOffset(12, 6)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 10
                tl.TextColor3 = self_.Theme.TextDim
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = string.upper(tTitle or "Mode")
                tl.Parent = row

                local segHolder = Instance.new("Frame")
                segHolder.Size = UDim2.new(1, -24, 0, 28)
                segHolder.Position = UDim2.fromOffset(12, 26)
                segHolder.BackgroundColor3 = self_.Theme.Background
                segHolder.BackgroundTransparency = 0.3
                segHolder.BorderSizePixel = 0
                segHolder.Parent = row
                local shc = Instance.new("UICorner"); shc.CornerRadius = UDim.new(0, 8); shc.Parent = segHolder
                local shl = Instance.new("UIListLayout")
                shl.FillDirection = Enum.FillDirection.Horizontal
                shl.SortOrder = Enum.SortOrder.LayoutOrder
                shl.Parent = segHolder

                local indicator = Instance.new("Frame")
                indicator.Size = UDim2.new(1 / math.max(#modes,1), 0, 1, 0)
                indicator.BackgroundColor3 = self_.Theme.Accent
                indicator.BorderSizePixel = 0
                indicator.ZIndex = 1
                indicator.Parent = segHolder
                local ic3 = Instance.new("UICorner"); ic3.CornerRadius = UDim.new(0, 7); ic3.Parent = indicator
                self_:_ApplyGradient(indicator, self_.Theme.Grad1, self_.Theme.Grad2, 0)

                local btns = {}
                for i, mode in ipairs(modes) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1 / math.max(#modes,1), 0, 1, 0)
                    b.BackgroundTransparency = 1
                    b.Text = tostring(mode)
                    b.TextColor3 = (mode == defaultMode) and Color3.fromRGB(255,255,255) or self_.Theme.TextDim
                    b.Font = Enum.Font.GothamBold
                    b.TextSize = 10
                    b.AutoButtonColor = false
                    b.LayoutOrder = i
                    b.ZIndex = 2
                    b.Parent = segHolder

                    b.MouseButton1Click:Connect(function()
                        self_:_PlaySound("Click")
                        Tween(indicator, 0.3, {Position = UDim2.new((i-1)/#modes, 0, 0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        for _, bb in ipairs(btns) do
                            Tween(bb, 0.15, {TextColor3 = self_.Theme.TextDim})
                        end
                        Tween(b, 0.15, {TextColor3 = Color3.fromRGB(255,255,255)})
                        pcall(callback, mode)
                    end)

                    table.insert(btns, b)
                end

                for i, mode in ipairs(modes) do
                    if mode == defaultMode then
                        indicator.Position = UDim2.new((i-1)/#modes, 0, 0, 0)
                    end
                end

                Register(row, tTitle)

                return {Frame = row}
            end

            GroupObj.AddColorPickerRow = function(_, tTitle, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or self_.Theme.Accent

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 40)
                row.BackgroundColor3 = self_.Theme.SubBox
                row.BackgroundTransparency = 0.4
                row.BorderSizePixel = 0
                row.LayoutOrder = #items:GetChildren()
                row.Parent = items
                local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 10); rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = self_.Theme.Border; rs.Thickness = 1; rs.Transparency = 0.8; rs.Parent = row

                local tl = Instance.new("TextLabel")
                tl.Size = UDim2.new(0.6, -12, 1, 0)
                tl.Position = UDim2.fromOffset(12, 0)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamMedium
                tl.TextSize = 12
                tl.TextColor3 = self_.Theme.TextTitle
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.Text = tTitle or "Color"
                tl.Parent = row

                local swatch = Instance.new("Frame")
                swatch.Size = UDim2.fromOffset(24, 24)
                swatch.Position = UDim2.new(1, -40, 0.5, -12)
                swatch.BackgroundColor3 = defaultColor
                swatch.BorderSizePixel = 0
                swatch.Parent = row
                local sc2 = Instance.new("UICorner"); sc2.CornerRadius = UDim.new(0, 8); sc2.Parent = swatch
                local ss = Instance.new("UIStroke")
                ss.Color = Color3.fromRGB(255,255,255); ss.Thickness = 1; ss.Transparency = 0.6; ss.Parent = swatch

                local hexLbl = Instance.new("TextLabel")
                hexLbl.Size = UDim2.new(0, 80, 1, 0)
                hexLbl.Position = UDim2.new(1, -130, 0, 0)
                hexLbl.BackgroundTransparency = 1
                hexLbl.Font = Enum.Font.GothamBold
                hexLbl.TextSize = 10
                hexLbl.TextColor3 = self_.Theme.AccentLight
                hexLbl.TextXAlignment = Enum.TextXAlignment.Right
                hexLbl.Text = ColorToHex(defaultColor)
                hexLbl.Parent = row
                self_:_Register("Accents", hexLbl)

                local clickBtn = Instance.new("TextButton")
                clickBtn.Size = UDim2.fromScale(1, 1)
                clickBtn.BackgroundTransparency = 1
                clickBtn.Text = ""
                clickBtn.Parent = row

                clickBtn.MouseEnter:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.25})
                end)
                clickBtn.MouseLeave:Connect(function()
                    Tween(row, 0.15, {BackgroundTransparency = 0.4})
                end)
                clickBtn.MouseButton1Click:Connect(function()
                    self_:_PlaySound("Click")
                    -- Simple color cycle demo (real picker nếu muốn phải add popup)
                    local hues = {0, 0.08, 0.16, 0.33, 0.5, 0.66, 0.83}
                    local h = defaultColor:ToHSV()
                    local nextH = (h + 0.15) % 1
                    local newColor = Color3.fromHSV(nextH, 0.7, 0.95)
                    swatch.BackgroundColor3 = newColor
                    hexLbl.Text = ColorToHex(newColor)
                    defaultColor = newColor
                    pcall(callback, newColor, ColorToHex(newColor))
                end)

                Register(row, tTitle)

                local obj = {Frame = row}
                function obj:Set(c)
                    swatch.BackgroundColor3 = c
                    hexLbl.Text = ColorToHex(c)
                    defaultColor = c
                end
                function obj:Get() return defaultColor end
                return obj
            end

            return GroupObj
        end

        return TabObj
    end

    -- ===== FLOATING TOGGLE BUTTON =====
    if self.Settings.ShowFloatingToggle then
        local floatBtn = Instance.new("TextButton")
        floatBtn.Name = "LiquidGlass_Floating"
        floatBtn.Size = UDim2.fromOffset(54, 54)
        floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
        floatBtn.BackgroundColor3 = self.Theme.Box
        floatBtn.BackgroundTransparency = 0.1
        floatBtn.Text = ""
        floatBtn.AutoButtonColor = false
        floatBtn.ZIndex = 100
        floatBtn.Parent = screenGui
        local fbc = Instance.new("UICorner"); fbc.CornerRadius = UDim.new(1, 0); fbc.Parent = floatBtn
        local fbs = Instance.new("UIStroke")
        fbs.Thickness = 3
        fbs.Color = self.Theme.Accent
        fbs.Parent = floatBtn
        self:_ApplyGradient(fbs, self.Theme.Grad1, self.Theme.Grad2, 45)

        local fbi = Icons.Create(logo or "sparkles", nil, UDim2.fromOffset(28, 28), Color3.fromRGB(255,255,255))
        fbi.Position = UDim2.new(0.5, -14, 0.5, -14)
        fbi.Parent = floatBtn

        -- Pulse glow
        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(1, 8, 1, 8)
        glow.Position = UDim2.new(0.5, -4, 0.5, -4)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundColor3 = self.Theme.Accent
        glow.BackgroundTransparency = 0.85
        glow.BorderSizePixel = 0
        glow.ZIndex = 99
        glow.Parent = floatBtn
        local gc = Instance.new("UICorner"); gc.CornerRadius = UDim.new(1, 0); gc.Parent = glow

        task.spawn(function()
            while floatBtn.Parent do
                Tween(glow, 1.5, {Size = UDim2.new(1, 16, 1, 16), BackgroundTransparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.5)
                if not floatBtn.Parent then break end
                Tween(glow, 1.5, {Size = UDim2.new(1, 8, 1, 8), BackgroundTransparency = 0.9}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.5)
            end
        end)

        -- Draggable
        local dragging, dragStart, startPos
        floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = floatBtn.Position
            end
        end)
        floatBtn.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                floatBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        floatBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        floatBtn.MouseButton1Click:Connect(function()
            MicroBounce(floatBtn)
            WindowObj:Toggle()
        end)

        WindowObj.FloatingBtn = floatBtn
    end

    -- ===== KEYBIND =====
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == WindowObj.Keybind then
            if self.Settings.KeybindMode == "Toggle" then
                WindowObj:Toggle()
            end
        end
    end)

    self.CurrentWindow = WindowObj
    table.insert(self.Windows, WindowObj)

    return WindowObj
end

-- ============================================================
-- CLEANUP
-- ============================================================
function LiquidGlass:Destroy()
    for _, w in ipairs(self.Windows) do
        pcall(function() w:Destroy() end)
    end
    self.Windows = {}
    self.CurrentWindow = nil
end

pcall(function()
    if getgenv then getgenv().LiquidGlass = LiquidGlass end
    _G.LiquidGlass = LiquidGlass
end)

return LiquidGlass
