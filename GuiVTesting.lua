local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local function LoadCustomImage(urlOrAsset, defaultAsset)
    defaultAsset = defaultAsset or "rbxassetid://10709819149"
    if not urlOrAsset or urlOrAsset == "" then return defaultAsset end
    local assetNum = urlOrAsset:match("%d+")
    if urlOrAsset:find("roblox%.com") and assetNum then
        return "rbxassetid://" .. assetNum
    end
    if string.find(urlOrAsset, "^rbxassetid://") or tonumber(urlOrAsset) then
        return tonumber(urlOrAsset) and ("rbxassetid://" .. urlOrAsset) or urlOrAsset
    end
    if string.find(urlOrAsset, "^http") and writefile and isfile then
        local safeName = "liquidglass_logo_" .. tostring(math.abs(urlOrAsset:len() * 37 + (urlOrAsset:byte(1) or 0) * 17)) .. ".png"
        pcall(function()
            if not isfile(safeName) then
                local res = game:HttpGet(urlOrAsset)
                if res and #res > 100 then
                    writefile(safeName, res)
                end
            end
        end)
        if isfile and isfile(safeName) then
            if getcustomasset then
                return getcustomasset(safeName)
            elseif getsynasset then
                return getsynasset(safeName)
            end
        end
    end
    return urlOrAsset
end

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

LiquidGlass.Icons = {
    Logo        = "rbxassetid://10709819149",
    Search      = "rbxassetid://10734943674",
    Close       = "rbxassetid://10747384394",
    Minimize    = "rbxassetid://10709791185",
    Settings    = "rbxassetid://10734950309",
    ChevronDown = "rbxassetid://10709790948",
    Palette     = "rbxassetid://10734910430",
    Save        = "rbxassetid://10734941499",
    Skull       = "rbxassetid://10734962068",
    Dashboard   = "rbxassetid://10709752035",
    Combat      = "rbxassetid://10709818534",
    Visuals     = "rbxassetid://10747375132",
    Teleport    = "rbxassetid://10723404337",
    Refresh     = "rbxassetid://10734933222",
    Server      = "rbxassetid://10734963400",
    Copy        = "rbxassetid://10709812159",
    Sound       = "rbxassetid://10709810814",
    SoundMute   = "rbxassetid://10709810619",
    Bell        = "rbxassetid://10709752996",
    Info        = "rbxassetid://10709752996",
    Check       = "rbxassetid://10709790644",
    Zap         = "rbxassetid://10709791882"
}

LiquidGlass.Themes = {
    Midnight = {
        Name        = "Midnight",
        Grad1       = Color3.fromRGB(120, 140, 255),
        Grad2       = Color3.fromRGB(180, 120, 255),
        Accent      = Color3.fromRGB(120, 140, 255),
        AccentLight = Color3.fromRGB(180, 140, 255),
        Background  = Color3.fromRGB(20, 20, 26),
        Sidebar     = Color3.fromRGB(16, 16, 22),
        Box         = Color3.fromRGB(28, 28, 36),
        SubBox      = Color3.fromRGB(36, 36, 46),
        Border      = Color3.fromRGB(60, 60, 78),
        BorderLight = Color3.fromRGB(90, 90, 115),
        TextTitle   = Color3.fromRGB(245, 245, 250),
        TextBody    = Color3.fromRGB(210, 210, 225),
        TextDim     = Color3.fromRGB(150, 150, 170),
        TextMuted   = Color3.fromRGB(100, 100, 120),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    RoseGold = {
        Name        = "Rose Gold",
        Grad1       = Color3.fromRGB(244, 114, 142),
        Grad2       = Color3.fromRGB(251, 160, 180),
        Accent      = Color3.fromRGB(244, 114, 142),
        AccentLight = Color3.fromRGB(251, 160, 180),
        Background  = Color3.fromRGB(24, 18, 22),
        Sidebar     = Color3.fromRGB(20, 14, 18),
        Box         = Color3.fromRGB(34, 24, 30),
        SubBox      = Color3.fromRGB(44, 32, 40),
        Border      = Color3.fromRGB(70, 48, 60),
        BorderLight = Color3.fromRGB(105, 72, 90),
        TextTitle   = Color3.fromRGB(255, 245, 250),
        TextBody    = Color3.fromRGB(235, 220, 228),
        TextDim     = Color3.fromRGB(165, 145, 158),
        TextMuted   = Color3.fromRGB(115, 95, 108),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    MintFresh = {
        Name        = "Mint Fresh",
        Grad1       = Color3.fromRGB(80, 220, 180),
        Grad2       = Color3.fromRGB(120, 240, 200),
        Accent      = Color3.fromRGB(80, 220, 180),
        AccentLight = Color3.fromRGB(120, 240, 200),
        Background  = Color3.fromRGB(16, 22, 22),
        Sidebar     = Color3.fromRGB(12, 18, 18),
        Box         = Color3.fromRGB(22, 30, 30),
        SubBox      = Color3.fromRGB(30, 40, 40),
        Border      = Color3.fromRGB(46, 64, 64),
        BorderLight = Color3.fromRGB(72, 100, 100),
        TextTitle   = Color3.fromRGB(240, 255, 252),
        TextBody    = Color3.fromRGB(210, 235, 228),
        TextDim     = Color3.fromRGB(140, 175, 168),
        TextMuted   = Color3.fromRGB(95, 125, 120),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    OceanBlue = {
        Name        = "Ocean Blue",
        Grad1       = Color3.fromRGB(60, 140, 240),
        Grad2       = Color3.fromRGB(100, 180, 255),
        Accent      = Color3.fromRGB(60, 140, 240),
        AccentLight = Color3.fromRGB(100, 180, 255),
        Background  = Color3.fromRGB(14, 20, 30),
        Sidebar     = Color3.fromRGB(10, 16, 26),
        Box         = Color3.fromRGB(20, 28, 42),
        SubBox      = Color3.fromRGB(28, 38, 54),
        Border      = Color3.fromRGB(42, 58, 84),
        BorderLight = Color3.fromRGB(66, 90, 130),
        TextTitle   = Color3.fromRGB(240, 248, 255),
        TextBody    = Color3.fromRGB(210, 225, 240),
        TextDim     = Color3.fromRGB(140, 160, 185),
        TextMuted   = Color3.fromRGB(90, 110, 140),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    SunsetOrange = {
        Name        = "Sunset Orange",
        Grad1       = Color3.fromRGB(245, 140, 60),
        Grad2       = Color3.fromRGB(255, 180, 100),
        Accent      = Color3.fromRGB(245, 140, 60),
        AccentLight = Color3.fromRGB(255, 180, 100),
        Background  = Color3.fromRGB(24, 18, 14),
        Sidebar     = Color3.fromRGB(20, 14, 10),
        Box         = Color3.fromRGB(34, 24, 18),
        SubBox      = Color3.fromRGB(44, 32, 24),
        Border      = Color3.fromRGB(70, 50, 36),
        BorderLight = Color3.fromRGB(105, 75, 54),
        TextTitle   = Color3.fromRGB(255, 250, 245),
        TextBody    = Color3.fromRGB(240, 225, 210),
        TextDim     = Color3.fromRGB(170, 150, 135),
        TextMuted   = Color3.fromRGB(120, 100, 85),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    VioletDream = {
        Name        = "Violet Dream",
        Grad1       = Color3.fromRGB(160, 100, 240),
        Grad2       = Color3.fromRGB(200, 140, 255),
        Accent      = Color3.fromRGB(160, 100, 240),
        AccentLight = Color3.fromRGB(200, 140, 255),
        Background  = Color3.fromRGB(20, 16, 28),
        Sidebar     = Color3.fromRGB(16, 12, 22),
        Box         = Color3.fromRGB(28, 22, 38),
        SubBox      = Color3.fromRGB(38, 30, 50),
        Border      = Color3.fromRGB(58, 46, 78),
        BorderLight = Color3.fromRGB(90, 70, 120),
        TextTitle   = Color3.fromRGB(250, 245, 255),
        TextBody    = Color3.fromRGB(225, 215, 240),
        TextDim     = Color3.fromRGB(160, 145, 180),
        TextMuted   = Color3.fromRGB(110, 95, 130),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    Crimson = {
        Name        = "Crimson",
        Grad1       = Color3.fromRGB(235, 55, 75),
        Grad2       = Color3.fromRGB(255, 110, 80),
        Accent      = Color3.fromRGB(235, 55, 75),
        AccentLight = Color3.fromRGB(255, 110, 130),
        Background  = Color3.fromRGB(22, 16, 20),
        Sidebar     = Color3.fromRGB(18, 12, 16),
        Box         = Color3.fromRGB(30, 22, 28),
        SubBox      = Color3.fromRGB(40, 30, 38),
        Border      = Color3.fromRGB(64, 44, 54),
        BorderLight = Color3.fromRGB(96, 66, 82),
        TextTitle   = Color3.fromRGB(255, 245, 248),
        TextBody    = Color3.fromRGB(240, 220, 228),
        TextDim     = Color3.fromRGB(170, 145, 155),
        TextMuted   = Color3.fromRGB(120, 95, 105),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    },
    Gold = {
        Name        = "Gold",
        Grad1       = Color3.fromRGB(245, 180, 40),
        Grad2       = Color3.fromRGB(255, 210, 80),
        Accent      = Color3.fromRGB(245, 180, 40),
        AccentLight = Color3.fromRGB(255, 210, 80),
        Background  = Color3.fromRGB(22, 20, 14),
        Sidebar     = Color3.fromRGB(18, 16, 10),
        Box         = Color3.fromRGB(30, 28, 20),
        SubBox      = Color3.fromRGB(40, 36, 26),
        Border      = Color3.fromRGB(64, 56, 36),
        BorderLight = Color3.fromRGB(96, 84, 54),
        TextTitle   = Color3.fromRGB(255, 252, 240),
        TextBody    = Color3.fromRGB(240, 232, 210),
        TextDim     = Color3.fromRGB(170, 158, 130),
        TextMuted   = Color3.fromRGB(120, 108, 85),
        Success     = Color3.fromRGB(80, 220, 140),
        Danger      = Color3.fromRGB(255, 90, 90)
    }
}

local DEFAULTS = {
    Theme = "Midnight",
    AccentStyle = "Gradient",
    CustomColor1 = "",
    CustomColor2 = "",
    SoundEnabled = true,
    SoundVolume = 0.55,
    WindowTransparency = 0,
    ShowFloatingToggle = true,
    ControlsPosition = "Left",
    KeybindMode = "Toggle",
    ToggleKey = "RightControl",
    AutoSaveEnabled = true,
    ConfigFile = "LiquidGlass_Config.json"
}

local BubbleSoundMap = {
    Click     = { id = "rbxassetid://6895079853", pitch = 1.10, vol = 0.32 },
    ToggleOn  = { id = "rbxassetid://6895079853", pitch = 1.40, vol = 0.35 },
    ToggleOff = { id = "rbxassetid://6895079853", pitch = 0.88, vol = 0.28 },
    TabSwitch = { id = "rbxassetid://6895079853", pitch = 1.25, vol = 0.30 },
    Dropdown  = { id = "rbxassetid://6895079853", pitch = 1.00, vol = 0.30 },
    Notify    = { id = "rbxassetid://4590662766", pitch = 1.35, vol = 0.38 }
}

local function Tween(obj, duration, props, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    tw:Play()
    return tw
end

local function MicroBounce(obj)
    local s = obj:FindFirstChildOfClass("UIScale")
    if not s then s = Instance.new("UIScale", obj) end
    Tween(s, 0.08, {Scale = 0.94}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.08, function()
        Tween(s, 0.2, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

local function GetSafeGuiParent()
    local ok, p = pcall(function()
        if type(gethui) == "function" then return gethui() end
        if CoreGui then return CoreGui end
    end)
    return (ok and p) or LP:WaitForChild("PlayerGui")
end

local function ColorToHex(col)
    return string.format("#%02x%02x%02x", math.floor(col.R * 255), math.floor(col.G * 255), math.floor(col.B * 255))
end

local function HexToColor(hex)
    if not hex or type(hex) ~= "string" then return nil end
    local clean = hex:gsub("#", ""):gsub("%s+", "")
    if #clean == 6 then
        local r = tonumber(clean:sub(1, 2), 16)
        local g = tonumber(clean:sub(3, 4), 16)
        local b = tonumber(clean:sub(5, 6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
    end
    return nil
end

function LiquidGlass.new(options)
    options = options or {}
    local self = setmetatable({}, LiquidGlass)

    self.Options = options
    self.Tabs = {}
    self.CurrentTab = nil
    self.Tabs_Meta = {}
    self.ThemeRegistry = {
        Gradients = {}, Accents = {}, Backgrounds = {}, Sidebars = {},
        Boxes = {}, SubBoxes = {}, Borders = {}, ModeSelectors = {}
    }
    self.Notifications = {}
    self.ActiveDiscordNotification = nil
    self.Connections = {}
    self.Keybinds = {}
    self.BlurCache = nil
    self.AutoSaveDebounce = nil

    self.Settings = {
        Theme = options.Theme or DEFAULTS.Theme,
        AccentStyle = options.AccentStyle or DEFAULTS.AccentStyle,
        CustomColor1 = options.CustomColor1 or DEFAULTS.CustomColor1,
        CustomColor2 = options.CustomColor2 or DEFAULTS.CustomColor2,
        SoundEnabled = options.SoundEnabled ~= false and DEFAULTS.SoundEnabled,
        SoundVolume = options.SoundVolume or DEFAULTS.SoundVolume,
        WindowTransparency = options.WindowTransparency or DEFAULTS.WindowTransparency,
        ShowFloatingToggle = options.ShowFloatingToggle ~= false and DEFAULTS.ShowFloatingToggle,
        ControlsPosition = options.ControlsPosition or DEFAULTS.ControlsPosition,
        KeybindMode = options.KeybindMode or DEFAULTS.KeybindMode,
        ToggleKey = options.ToggleKey and tostring(options.ToggleKey) or DEFAULTS.ToggleKey,
        AutoSaveEnabled = options.AutoSaveEnabled ~= false and DEFAULTS.AutoSaveEnabled,
        ConfigFile = options.ConfigFile or DEFAULTS.ConfigFile
    }

    self.Theme = self.Themes[self.Settings.Theme] or self.Themes.Midnight

    self:_LoadConfig()

    return self
end

function LiquidGlass:_RegisterElement(cat, obj)
    if self.ThemeRegistry[cat] then
        table.insert(self.ThemeRegistry[cat], obj)
    end
end

function LiquidGlass:_ApplyGradient(parentObj, c1, c2, rotation)
    if parentObj:IsA("TextLabel") or parentObj:IsA("TextButton") then
        parentObj.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    local isSolid = (self.Settings.AccentStyle == "Solid")
    c1 = c1 or self.Theme.Grad1
    c2 = isSolid and c1 or (c2 or self.Theme.Grad2)
    rotation = rotation or 0
    local grad = parentObj:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Parent = parentObj
    end
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    grad.Rotation = rotation
    self:_RegisterElement("Gradients", grad)
    return grad
end

function LiquidGlass:_PlaySound(name)
    if not self.Settings.SoundEnabled then return end
    local conf = BubbleSoundMap[name] or BubbleSoundMap.Click
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

function LiquidGlass:ApplyTheme(themeName)
    if not themeName then return end
    if self.Themes[themeName] then
        self.Settings.Theme = themeName
        self.Theme = self.Themes[themeName]
        if themeName == "Custom" and self.Settings.CustomColor1 ~= "" then
            local c1 = HexToColor(self.Settings.CustomColor1)
            if c1 then self.Theme.Accent = c1 self.Theme.Grad1 = c1 end
            if self.Settings.CustomColor2 ~= "" then
                local c2 = HexToColor(self.Settings.CustomColor2)
                if c2 then self.Theme.AccentLight = c2 self.Theme.Grad2 = c2 end
            end
        end
        self:_UpdateLiveTheme()
        self:_AutoSave()
    end
end

function LiquidGlass:SetAccentStyle(style)
    self.Settings.AccentStyle = style
    self:_UpdateLiveTheme()
    self:_AutoSave()
end

function LiquidGlass:SetCustomColors(c1, c2)
    self.Settings.Theme = "Custom"
    self.Settings.CustomColor1 = c1 and ColorToHex(c1) or self.Settings.CustomColor1
    self.Settings.CustomColor2 = c2 and ColorToHex(c2) or self.Settings.CustomColor2

    if self.Themes[themeName] then
        self.Theme = self.Themes[themeName]
    else
        self.Theme = {}
        for k, v in pairs(self.Themes.Midnight) do self.Theme[k] = v end
    end
    if c1 then self.Theme.Accent = c1 self.Theme.Grad1 = c1 self.Theme.AccentLight = c1 self.Theme.Grad2 = c1 end
    if c2 then self.Theme.AccentLight = c2 self.Theme.Grad2 = c2 end
    self:_UpdateLiveTheme()
    self:_AutoSave()
end

function LiquidGlass:_UpdateLiveTheme()
    local isSolid = (self.Settings.AccentStyle == "Solid")
    local c1 = self.Theme.Grad1 or self.Theme.Accent
    local c2 = isSolid and c1 or (self.Theme.Grad2 or self.Theme.AccentLight)

    for _, g in ipairs(self.ThemeRegistry.Gradients) do
        if g and g.Parent then
            if g.Name == "ChasingRingGrad" then
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, c1),
                    ColorSequenceKeypoint.new(0.50, c2),
                    ColorSequenceKeypoint.new(1.00, c1)
                })
            else
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c1),
                    ColorSequenceKeypoint.new(1, c2)
                })
            end
            if g.Parent:IsA("TextLabel") or g.Parent:IsA("TextButton") then
                g.Parent.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
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
                    item.TextColor3 = Color3.fromRGB(255, 255, 255)
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

function LiquidGlass:SaveConfig()
    pcall(function()
        if writefile then
            local data = {}
            for k, v in pairs(self.Settings) do
                data[k] = v
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
                        if self.Settings[k] ~= nil then
                            self.Settings[k] = v
                        end
                    end
                end
            end
        end
    end)
    if self.Themes[self.Settings.Theme] then
        self.Theme = self.Themes[self.Settings.Theme]
    else
        self.Theme = self.Themes.Midnight
    end
end

function LiquidGlass:_AutoSave()
    if self.Settings.AutoSaveEnabled == false then return end
    if self.AutoSaveDebounce then task.cancel(self.AutoSaveDebounce) end
    self.AutoSaveDebounce = task.delay(0.35, function()
        self:SaveConfig()
        self.AutoSaveDebounce = nil
    end)
end

function LiquidGlass:Notify(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Notification"
    local desc = cfg.Content or cfg.Description or ""
    local duration = cfg.Duration or 3.5
    local iconId = cfg.Icon or self.Icons.Bell
    local badgeText = cfg.Badge or "INFO"
    local badgeCol = cfg.BadgeColor or (badgeText == "COPIED" and Color3.fromRGB(34, 197, 94) or self.Theme.AccentLight)

    self:_PlaySound("Notify")

    if self.ActiveDiscordNotification and self.ActiveDiscordNotification.Parent then
        pcall(function() self.ActiveDiscordNotification:Destroy() end)
        self.ActiveDiscordNotification = nil
    end

    local targetParent = nil
    local isProtruding = false
    if self.MainWindow and self.MainWindow.Parent and self.MainWindow.Visible then
        targetParent = self.MainWindow
        isProtruding = true
    else
        local host = GetSafeGuiParent():FindFirstChild("LiquidGlass_Host")
        targetParent = host or GetSafeGuiParent()
        isProtruding = false
    end

    if not targetParent then return end

    local modal = nil
    pcall(function()
        modal = Instance.new("Frame", targetParent)
        modal.Name = "DiscordNotificationModal"
        modal.AnchorPoint = Vector2.new(0.5, 0)
        modal.Size = UDim2.new(0, 390, 0, 58)
        modal.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
        modal.BackgroundTransparency = 0.05
        modal.ZIndex = 5000
        modal.ClipsDescendants = true
        Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 14)

        local mStroke = Instance.new("UIStroke", modal)
        mStroke.Thickness = 1.4
        mStroke.Color = self.Theme.BorderLight
        self:_ApplyGradient(mStroke, self.Theme.Grad1, self.Theme.Grad2, 45)

        local pGlow = Instance.new("Frame", modal)
        pGlow.Name = "ModalGlow"
        pGlow.Size = UDim2.new(1, 0, 1, 0)
        pGlow.BackgroundColor3 = self.Theme.Accent
        pGlow.BackgroundTransparency = 0.95
        pGlow.BorderSizePixel = 0
        pGlow.ZIndex = 5000
        Instance.new("UICorner", pGlow).CornerRadius = UDim.new(0, 14)
        self:_RegisterElement("Accents", pGlow)

        local icBadge = Instance.new("Frame", modal)
        icBadge.Size = UDim2.new(0, 36, 0, 36)
        icBadge.Position = UDim2.new(0, 12, 0.5, -18)
        icBadge.BackgroundColor3 = self.Theme.SubBox
        icBadge.BackgroundTransparency = 0.2
        icBadge.BorderSizePixel = 0
        icBadge.ZIndex = 5001
        Instance.new("UICorner", icBadge).CornerRadius = UDim.new(0, 10)
        local ibStroke = Instance.new("UIStroke", icBadge)
        ibStroke.Color = self.Theme.Border
        ibStroke.Thickness = 0.8
        ibStroke.Transparency = 0.5

        local icImg = Instance.new("ImageLabel", icBadge)
        icImg.Size = UDim2.new(0, 20, 0, 20)
        icImg.Position = UDim2.new(0.5, -10, 0.5, -10)
        icImg.BackgroundTransparency = 1
        icImg.Image = tostring(iconId)
        icImg.ImageColor3 = self.Theme.AccentLight
        icImg.ZIndex = 5002
        self:_RegisterElement("Accents", icImg)

        local tL = Instance.new("TextLabel", modal)
        tL.Size = UDim2.new(1, -145, 0, 16)
        tL.Position = UDim2.new(0, 58, 0, 11)
        tL.BackgroundTransparency = 1
        tL.Font = Enum.Font.GothamBold
        tL.TextSize = 11
        tL.TextColor3 = self.Theme.TextTitle
        tL.TextXAlignment = Enum.TextXAlignment.Left
        tL.TextTruncate = Enum.TextTruncate.AtEnd
        tL.Text = string.upper(title)
        tL.ZIndex = 5001

        local sL = Instance.new("TextLabel", modal)
        sL.Size = UDim2.new(1, -145, 0, 16)
        sL.Position = UDim2.new(0, 58, 0, 29)
        sL.BackgroundTransparency = 1
        sL.Font = Enum.Font.GothamMedium
        sL.TextSize = 9.5
        sL.TextColor3 = self.Theme.AccentLight
        sL.TextXAlignment = Enum.TextXAlignment.Left
        sL.TextTruncate = Enum.TextTruncate.AtEnd
        sL.Text = desc
        sL.ZIndex = 5001
        self:_RegisterElement("Accents", sL)

        local tag = Instance.new("Frame", modal)
        tag.Size = UDim2.new(0, 64, 0, 22)
        tag.Position = UDim2.new(1, -76, 0.5, -11)
        tag.BackgroundColor3 = badgeCol
        tag.BackgroundTransparency = 0.82
        tag.ZIndex = 5001
        Instance.new("UICorner", tag).CornerRadius = UDim.new(1, 0)
        local tagStroke = Instance.new("UIStroke", tag)
        tagStroke.Color = badgeCol
        tagStroke.Thickness = 0.8
        tagStroke.Transparency = 0.4

        local tagText = Instance.new("TextLabel", tag)
        tagText.Size = UDim2.new(1, 0, 1, 0)
        tagText.BackgroundTransparency = 1
        tagText.Font = Enum.Font.GothamBold
        tagText.TextSize = 8.5
        tagText.TextColor3 = badgeCol
        tagText.Text = string.upper(badgeText)
        tagText.ZIndex = 5002

        local clickBtn = Instance.new("TextButton", modal)
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.ZIndex = 5005

        self.ActiveDiscordNotification = modal

        local startY = isProtruding and -75 or -60
        local targetY = isProtruding and -36 or 24
        local exitY = isProtruding and -75 or -60

        modal.Position = UDim2.new(0.5, 0, 0, startY)
        Tween(modal, 0.35, {Position = UDim2.new(0.5, 0, 0, targetY)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local isDismissed = false
        local function Dismiss()
            if isDismissed then return end
            isDismissed = true
            pcall(function()
                local tw = Tween(modal, 0.25, {Position = UDim2.new(0.5, 0, 0, exitY), BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                tw.Completed:Connect(function()
                    if modal and modal.Parent then modal:Destroy() end
                    if self.ActiveDiscordNotification == modal then self.ActiveDiscordNotification = nil end
                end)
            end)
            task.delay(0.28, function()
                if modal and modal.Parent then modal:Destroy() end
                if self.ActiveDiscordNotification == modal then self.ActiveDiscordNotification = nil end
            end)
        end

        clickBtn.MouseButton1Click:Connect(Dismiss)
        task.delay(duration, Dismiss)
        task.delay(duration + 0.8, function()
            if modal and modal.Parent then modal:Destroy() end
        end)
    end)
end

function LiquidGlass:CreateWindow(cfg)
    cfg = cfg or {}
    local WinTitle = cfg.Title or "LiquidGlass"
    local WinSubTitle = cfg.SubTitle or "v1.0"
    local WinSize = cfg.Size or UDim2.new(0, 720, 0, 485)
    local savedKey = nil
    if self.Settings.ToggleKey and type(self.Settings.ToggleKey) == "string" then
        pcall(function() savedKey = Enum.KeyCode[self.Settings.ToggleKey] end)
    end
    local ToggleKey = savedKey or cfg.ToggleKey or Enum.KeyCode.RightControl
    local LogoInput = cfg.Logo or "rbxassetid://10709819149"
    local ResolvedLogo = LoadCustomImage(LogoInput, self.Icons.Logo)

    local GuiParent = GetSafeGuiParent()
    pcall(function()
        local old = GuiParent:FindFirstChild("LiquidGlass_Host")
        if old then old:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LiquidGlass_Host"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GuiParent

    local MainWindow = Instance.new("Frame", ScreenGui)
    MainWindow.Name = "MainWindow"
    MainWindow.Size = WinSize
    MainWindow.Position = UDim2.new(0.5, -WinSize.X.Offset/2, 0.5, -WinSize.Y.Offset/2)
    MainWindow.BackgroundColor3 = self.Theme.Background
    MainWindow.BackgroundTransparency = self.Settings.WindowTransparency
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = false
    Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 16)
    local MainStroke = Instance.new("UIStroke", MainWindow)
    MainStroke.Color = self.Theme.Border
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.2

    self:_RegisterElement("Backgrounds", MainWindow)
    self:_RegisterElement("Borders", MainStroke)

    local winScale = Instance.new("UIScale", MainWindow)

    local function UpdateResponsiveScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local isTouch = UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled and UserInputService.MouseEnabled)
        if isTouch or vp.X < 920 or vp.Y < 560 then
            local scaleX = (vp.X * 0.92) / 720
            local scaleY = (vp.Y * 0.90) / 485
            winScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.55, 0.92)
        else
            winScale.Scale = 1.0
        end
    end

    UpdateResponsiveScale()
    pcall(function()
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale)
        end
    end)

    local FxCanvas = Instance.new("Frame", MainWindow)
    FxCanvas.Name = "FxCanvas"
    FxCanvas.Size = UDim2.new(1, 0, 1, 0)
    FxCanvas.BackgroundTransparency = 1
    FxCanvas.ClipsDescendants = true
    FxCanvas.ZIndex = 0
    Instance.new("UICorner", FxCanvas).CornerRadius = UDim.new(0, 16)

    local function AttachDrag(handle, target)
        local dragging = false
        local dragInput, dragStart, startPos
        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = inp.Position
                startPos = target.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        handle.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                dragInput = inp
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging then
                local delta = inp.Position - dragStart
                Tween(target, 0.04, {
                    Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                }, Enum.EasingStyle.Linear)
            end
        end)
    end

    local BodyContainer = nil
    local Header = Instance.new("Frame", MainWindow)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 44)
    Header.BackgroundTransparency = 1
    AttachDrag(Header, MainWindow)

    local HeaderLine = Instance.new("Frame", Header)
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, -1)
    HeaderLine.BackgroundColor3 = self.Theme.Border
    HeaderLine.BorderSizePixel = 0
    self:_RegisterElement("Borders", HeaderLine)

    local TrafficContainer = Instance.new("Frame", Header)
    TrafficContainer.Name = "TrafficContainer"
    TrafficContainer.Size = UDim2.new(0, 60, 1, 0)
    TrafficContainer.Position = UDim2.new(0, 14, 0, 0)
    TrafficContainer.BackgroundTransparency = 1
    local tcLayout = Instance.new("UIListLayout", TrafficContainer)
    tcLayout.FillDirection = Enum.FillDirection.Horizontal
    tcLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tcLayout.Padding = UDim.new(0, 7)

    local function MakeTrafficDot(col, hovCol, fn)
        local d = Instance.new("TextButton", TrafficContainer)
        d.Size = UDim2.new(0, 12, 0, 12)
        d.BackgroundColor3 = col
        d.Text = ""
        d.AutoButtonColor = false
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
        local s = Instance.new("UIStroke", d)
        s.Color = hovCol
        s.Thickness = 0.5
        s.Transparency = 0.4

        d.MouseEnter:Connect(function() Tween(d, 0.15, {BackgroundColor3 = hovCol}) end)
        d.MouseLeave:Connect(function() Tween(d, 0.15, {BackgroundColor3 = col}) end)
        d.MouseButton1Click:Connect(function()
            self:_PlaySound("Click")
            MicroBounce(d)
            fn()
        end)
        return d
    end

    local isMinimized = false

    local function ToggleMainWindow(show)
        if show == nil then show = not MainWindow.Visible end
        if show then
            MainWindow.Visible = true
            winScale.Scale = 0.8
            MainWindow.Position = UDim2.new(0.5, -WinSize.X.Offset/2, 0.5, -WinSize.Y.Offset/2)
            MainWindow.Size = isMinimized and UDim2.new(0, WinSize.X.Offset, 0, 44) or WinSize
            if isMinimized then
                HeaderLine.Visible = false
                MainWindow.ClipsDescendants = true
            else
                HeaderLine.Visible = true
                MainWindow.ClipsDescendants = false
                if BodyContainer then BodyContainer.Visible = true end
            end
            self:_PlaySound("ToggleOn")
            Tween(winScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self:_PlaySound("ToggleOff")
            local tw = Tween(winScale, 0.22, {Scale = 0.8}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            tw.Completed:Connect(function()
                if not MainWindow.Visible or winScale.Scale <= 0.85 then
                    MainWindow.Visible = false
                    winScale.Scale = 1
                end
            end)
            task.delay(0.24, function()
                if not MainWindow.Visible or winScale.Scale <= 0.85 then
                    MainWindow.Visible = false
                    winScale.Scale = 1
                end
            end)
        end
    end

    MakeTrafficDot(Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 130, 120), function()
        ToggleMainWindow(false)
    end)

    MakeTrafficDot(Color3.fromRGB(254, 188, 46), Color3.fromRGB(255, 215, 80), function()
        isMinimized = not isMinimized
        self:_PlaySound(isMinimized and "ToggleOff" or "ToggleOn")
        if isMinimized then
            if BodyContainer then BodyContainer.Visible = false end
            HeaderLine.Visible = false
            MainWindow.ClipsDescendants = true
            Tween(MainWindow, 0.25, {Size = UDim2.new(0, WinSize.X.Offset, 0, 44)}, Enum.EasingStyle.Quart)
        else
            MainWindow.ClipsDescendants = false
            HeaderLine.Visible = true
            Tween(MainWindow, 0.3, {Size = UDim2.new(0, WinSize.X.Offset, 0, WinSize.Y.Offset)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.delay(0.05, function()
                if not isMinimized and BodyContainer then BodyContainer.Visible = true end
            end)
        end
    end)

    MakeTrafficDot(Color3.fromRGB(39, 201, 63), Color3.fromRGB(75, 235, 100), function()
        self:_PlaySound("Click")
        Tween(MainWindow, 0.32, {Position = UDim2.new(0.5, -WinSize.X.Offset/2, 0.5, -WinSize.Y.Offset/2)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.AutomaticSize = Enum.AutomaticSize.X
    TitleLabel.Size = UDim2.new(0, 0, 0, 16)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextColor3 = self.Theme.TextTitle
    TitleLabel.Text = WinTitle

    local SubLabel = Instance.new("TextLabel", Header)
    SubLabel.AutomaticSize = Enum.AutomaticSize.X
    SubLabel.Size = UDim2.new(0, 0, 0, 12)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 9.5
    SubLabel.TextColor3 = self.Theme.TextDim
    SubLabel.Text = WinSubTitle

    local function SetControlsPosition(pos)
        self.Settings.ControlsPosition = pos
        if pos == "Right" then
            TrafficContainer.Position = UDim2.new(1, -78, 0, 0)
            TitleLabel.AnchorPoint = Vector2.new(0, 0)
            TitleLabel.Position = UDim2.new(0, 18, 0, 8)
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            SubLabel.AnchorPoint = Vector2.new(0, 0)
            SubLabel.Position = UDim2.new(0, 18, 0, 24)
            SubLabel.TextXAlignment = Enum.TextXAlignment.Left
        else
            TrafficContainer.Position = UDim2.new(0, 14, 0, 0)
            TitleLabel.AnchorPoint = Vector2.new(1, 0)
            TitleLabel.Position = UDim2.new(1, -18, 0, 8)
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Right
            SubLabel.AnchorPoint = Vector2.new(1, 0)
            SubLabel.Position = UDim2.new(1, -18, 0, 24)
            SubLabel.TextXAlignment = Enum.TextXAlignment.Right
        end
    end
    SetControlsPosition(self.Settings.ControlsPosition)

    BodyContainer = Instance.new("Frame", MainWindow)
    BodyContainer.Name = "BodyContainer"
    BodyContainer.Size = UDim2.new(1, 0, 1, -44)
    BodyContainer.Position = UDim2.new(0, 0, 0, 44)
    BodyContainer.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", BodyContainer)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = self.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 16)
    self:_RegisterElement("Sidebars", Sidebar)

    local LogoHolder = Instance.new("Frame", Sidebar)
    LogoHolder.Size = UDim2.new(1, 0, 0, 94)
    LogoHolder.Position = UDim2.new(0, 0, 0, 6)
    LogoHolder.BackgroundTransparency = 1

    local BrandSquircle = Instance.new("TextButton", LogoHolder)
    BrandSquircle.Size = UDim2.new(0, 74, 0, 74)
    BrandSquircle.Position = UDim2.new(0.5, -37, 0.5, -37)
    BrandSquircle.BackgroundColor3 = self.Theme.Box
    BrandSquircle.Text = ""
    BrandSquircle.AutoButtonColor = false
    Instance.new("UICorner", BrandSquircle).CornerRadius = UDim.new(0, 20)
    local bsStroke = Instance.new("UIStroke", BrandSquircle)
    bsStroke.Thickness = 1.6
    self:_ApplyGradient(bsStroke, self.Theme.Grad1, self.Theme.Grad2, 45)
    self:_RegisterElement("Boxes", BrandSquircle)
    self:_RegisterElement("Borders", bsStroke)

    local BrandIcon = Instance.new("ImageLabel", BrandSquircle)
    BrandIcon.Size = UDim2.new(0, 62, 0, 62)
    BrandIcon.Position = UDim2.new(0.5, -31, 0.5, -31)
    BrandIcon.BackgroundTransparency = 1
    BrandIcon.ScaleType = Enum.ScaleType.Fit
    BrandIcon.Image = ResolvedLogo
    BrandIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    BrandSquircle.MouseEnter:Connect(function()
        Tween(BrandSquircle, 0.15, {Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0.5, -40, 0.5, -40)})
    end)
    BrandSquircle.MouseLeave:Connect(function()
        Tween(BrandSquircle, 0.15, {Size = UDim2.new(0, 74, 0, 74), Position = UDim2.new(0.5, -37, 0.5, -37)})
    end)
    BrandSquircle.MouseButton1Click:Connect(function()
        MicroBounce(BrandSquircle)
        self:_PlaySound("Click")
    end)

    local SearchBox = Instance.new("Frame", Sidebar)
    SearchBox.Size = UDim2.new(1, -16, 0, 28)
    SearchBox.Position = UDim2.new(0, 8, 0, 104)
    SearchBox.BackgroundColor3 = self.Theme.Box
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 9)
    local sStroke = Instance.new("UIStroke", SearchBox)
    sStroke.Color = self.Theme.Border
    self:_RegisterElement("Boxes", SearchBox)
    self:_RegisterElement("Borders", sStroke)

    local sIcon = Instance.new("ImageLabel", SearchBox)
    sIcon.Size = UDim2.new(0, 13, 0, 13)
    sIcon.Position = UDim2.new(0, 8, 0.5, -6.5)
    sIcon.BackgroundTransparency = 1
    sIcon.Image = self.Icons.Search
    sIcon.ImageColor3 = self.Theme.TextMuted

    local SearchInput = Instance.new("TextBox", SearchBox)
    SearchInput.Size = UDim2.new(1, -44, 1, 0)
    SearchInput.Position = UDim2.new(0, 26, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 10.5
    SearchInput.TextColor3 = self.Theme.TextTitle
    SearchInput.PlaceholderColor3 = self.Theme.TextMuted
    SearchInput.PlaceholderText = "Search..."
    SearchInput.ClearTextOnFocus = false
    SearchInput.Text = ""

    local sClear = Instance.new("TextButton", SearchBox)
    sClear.Size = UDim2.new(0, 16, 0, 16)
    sClear.Position = UDim2.new(1, -20, 0.5, -8)
    sClear.BackgroundTransparency = 1
    sClear.Text = "X"
    sClear.Font = Enum.Font.GothamBold
    sClear.TextSize = 9
    sClear.TextColor3 = self.Theme.TextMuted
    sClear.Visible = false

    sClear.MouseButton1Click:Connect(function()
        SearchInput.Text = ""
        sClear.Visible = false
    end)

    local NavScroll = Instance.new("ScrollingFrame", Sidebar)
    NavScroll.Name = "NavScroll"
    NavScroll.Size = UDim2.new(1, -8, 1, -146)
    NavScroll.Position = UDim2.new(0, 4, 0, 140)
    NavScroll.BackgroundTransparency = 1
    NavScroll.BorderSizePixel = 0
    NavScroll.ScrollBarThickness = 2
    NavScroll.ScrollBarImageColor3 = self.Theme.Border
    NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local navLayout = Instance.new("UIListLayout", NavScroll)
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 4)

    local navPad = Instance.new("UIPadding", NavScroll)
    navPad.PaddingLeft = UDim.new(0, 4)
    navPad.PaddingRight = UDim.new(0, 4)
    navPad.PaddingTop = UDim.new(0, 4)
    navPad.PaddingBottom = UDim.new(0, 12)

    local ContentArea = Instance.new("Frame", BodyContainer)
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -175, 1, 0)
    ContentArea.Position = UDim2.new(0, 175, 0, 0)
    ContentArea.BackgroundTransparency = 1

    local FloatingSquircle = Instance.new("Frame", ScreenGui)
    FloatingSquircle.Name = "LiquidGlass_FloatingSquircle"
    FloatingSquircle.Size = UDim2.new(0, 52, 0, 52)
    FloatingSquircle.Position = UDim2.new(0, 20, 0.45, 0)
    FloatingSquircle.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    FloatingSquircle.BackgroundTransparency = 0.05
    FloatingSquircle.Visible = self.Settings.ShowFloatingToggle
    Instance.new("UICorner", FloatingSquircle).CornerRadius = UDim.new(1, 0)

    local flScale = Instance.new("UIScale", FloatingSquircle)
    flScale.Scale = 1

    local flCircleStroke = Instance.new("UIStroke", FloatingSquircle)
    flCircleStroke.Color = Color3.fromRGB(255, 255, 255)
    flCircleStroke.Thickness = 3.6
    flCircleStroke.Transparency = 0

    local flGrad = Instance.new("UIGradient", flCircleStroke)
    flGrad.Name = "ChasingRingGrad"
    local c1 = self.Theme.Grad1 or self.Theme.Accent
    local c2 = self.Theme.Grad2 or self.Theme.AccentLight
    flGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, c1),
        ColorSequenceKeypoint.new(0.50, c2),
        ColorSequenceKeypoint.new(1.00, c1)
    })
    flGrad.Rotation = 0
    self:_RegisterElement("Gradients", flGrad)
    self:_RegisterElement("Boxes", FloatingSquircle)

    local flAura = Instance.new("Frame", FloatingSquircle)
    flAura.Name = "AuraGlow"
    flAura.AnchorPoint = Vector2.new(0.5, 0.5)
    flAura.Position = UDim2.new(0.5, 0, 0.5, 0)
    flAura.Size = UDim2.new(1, 10, 1, 10)
    flAura.BackgroundColor3 = self.Theme.Accent
    flAura.BackgroundTransparency = 0.88
    flAura.BorderSizePixel = 0
    flAura.ZIndex = 0
    Instance.new("UICorner", flAura).CornerRadius = UDim.new(1, 0)
    self:_RegisterElement("Accents", flAura)

    task.spawn(function()
        while FloatingSquircle and FloatingSquircle.Parent do
            Tween(flAura, 1.4, {Size = UDim2.new(1, 16, 1, 16), BackgroundTransparency = 0.82}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
            if not FloatingSquircle or not FloatingSquircle.Parent then break end
            Tween(flAura, 1.4, {Size = UDim2.new(1, 8, 1, 8), BackgroundTransparency = 0.94}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.4)
        end
    end)

    local flLogoGlow = Instance.new("Frame", FloatingSquircle)
    flLogoGlow.Name = "LogoUnderglow"
    flLogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    flLogoGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    flLogoGlow.Size = UDim2.new(0, 30, 0, 30)
    flLogoGlow.BackgroundColor3 = self.Theme.Accent
    flLogoGlow.BackgroundTransparency = 0.75
    flLogoGlow.BorderSizePixel = 0
    flLogoGlow.ZIndex = 3
    Instance.new("UICorner", flLogoGlow).CornerRadius = UDim.new(1, 0)
    self:_RegisterElement("Accents", flLogoGlow)

    local flIconShadow = Instance.new("ImageLabel", FloatingSquircle)
    flIconShadow.Name = "IconShadow"
    flIconShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    flIconShadow.Size = UDim2.new(0, 28, 0, 28)
    flIconShadow.Position = UDim2.new(0.5, 1, 0.5, 2)
    flIconShadow.BackgroundTransparency = 1
    flIconShadow.ScaleType = Enum.ScaleType.Fit
    flIconShadow.Image = ResolvedLogo
    flIconShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    flIconShadow.ImageTransparency = 0.6
    flIconShadow.ZIndex = 5

    local flIcon = Instance.new("ImageLabel", FloatingSquircle)
    flIcon.Name = "MainLogo"
    flIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    flIcon.Size = UDim2.new(0, 28, 0, 28)
    flIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    flIcon.BackgroundTransparency = 1
    flIcon.ScaleType = Enum.ScaleType.Fit
    flIcon.Image = ResolvedLogo
    flIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    flIcon.Rotation = 0
    flIcon.ZIndex = 10
    local flIconScale = Instance.new("UIScale", flIcon)

    RunService.RenderStepped:Connect(function()
        if flGrad and flGrad.Parent then
            flGrad.Rotation = (tick() * 120) % 360
        end
    end)

    AttachDrag(FloatingSquircle, FloatingSquircle)

    local flBtn = Instance.new("TextButton", FloatingSquircle)
    flBtn.Name = "HitboxButton"
    flBtn.Size = UDim2.new(1, 0, 1, 0)
    flBtn.BackgroundTransparency = 1
    flBtn.Text = ""
    flBtn.ZIndex = 25

    local function UpdateFloatingToggleVisual()
        if not FloatingSquircle or not FloatingSquircle.Parent then return end
        local isOpen = MainWindow and MainWindow.Visible
        if isOpen then
            Tween(flCircleStroke, 0.25, {Thickness = 3.6, Transparency = 0})
            Tween(flAura, 0.25, {BackgroundTransparency = 0.80})
            Tween(flLogoGlow, 0.25, {BackgroundTransparency = 0.65})
        else
            Tween(flCircleStroke, 0.25, {Thickness = 3.2, Transparency = 0.25})
            Tween(flAura, 0.25, {BackgroundTransparency = 0.90})
            Tween(flLogoGlow, 0.25, {BackgroundTransparency = 0.85})
        end
    end

    flBtn.MouseEnter:Connect(function()
        Tween(flScale, 0.2, {Scale = 1.1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(flCircleStroke, 0.2, {Thickness = 4.2, Transparency = 0})
        Tween(flAura, 0.2, {BackgroundTransparency = 0.70, Size = UDim2.new(1, 18, 1, 18)})
        Tween(flLogoGlow, 0.2, {BackgroundTransparency = 0.55})
    end)

    flBtn.MouseLeave:Connect(function()
        Tween(flScale, 0.2, {Scale = 1.0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        UpdateFloatingToggleVisual()
    end)

    flBtn.MouseButton1Click:Connect(function()
        Tween(flScale, 0.06, {Scale = 0.88}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.06, function()
            Tween(flScale, 0.22, {Scale = 1.0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)

        flIconScale.Scale = 0.84
        Tween(flIconScale, 0.3, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local ripple = Instance.new("Frame", FloatingSquircle)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 10, 0, 10)
        ripple.BackgroundColor3 = self.Theme.AccentLight
        ripple.BackgroundTransparency = 0.35
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 1
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        local ripTw = Tween(ripple, 0.45, {
            Size = UDim2.new(2.4, 0, 2.4, 0),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        ripTw.Completed:Connect(function() ripple:Destroy() end)
        task.delay(0.5, function() if ripple and ripple.Parent then ripple:Destroy() end end)

        ToggleMainWindow()
        UpdateFloatingToggleVisual()
    end)

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainWindow = MainWindow,
        FloatingSquircle = FloatingSquircle,
        Tabs = {},
        ActiveTab = nil,
        Keybind = ToggleKey,
        AllSearchableItems = {}
    }

    WindowObj.ShowDiscordModal = function(self_, inviteUrl)
        inviteUrl = inviteUrl or "https://discord.gg/"
        pcall(function() setclipboard(inviteUrl) end)
        self:Notify({
            Title = "DISCORD LINK COPIED",
            Content = inviteUrl,
            Icon = self.Icons.Copy,
            Badge = "COPIED",
            BadgeColor = Color3.fromRGB(34, 197, 94),
            Duration = 3.5
        })
    end

    WindowObj.Notify = function(self_, cfg) self:Notify(cfg) end
    WindowObj.Toggle = ToggleMainWindow

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(SearchInput.Text)
        sClear.Visible = (q ~= "")
        for _, item in ipairs(WindowObj.AllSearchableItems) do
            if item.Frame and item.SearchText then
                item.Frame.Visible = (q == "" or string.find(item.SearchText, q) ~= nil)
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == WindowObj.Keybind then
            if self.Settings.KeybindMode == "Toggle" then
                ToggleMainWindow()
            elseif self.Settings.KeybindMode == "Hold" then
                ToggleMainWindow(true)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == WindowObj.Keybind then
            if self.Settings.KeybindMode == "Hold" then
                ToggleMainWindow(false)
            end
        end
    end)

    WindowObj.AddNavHeader = function(self_, titleText, order)
        local hFrame = Instance.new("Frame", NavScroll)
        hFrame.Name = "NavHeader_" .. titleText
        hFrame.Size = UDim2.new(1, -4, 0, 24)
        hFrame.BackgroundTransparency = 1
        hFrame.LayoutOrder = order or 1

        local h = Instance.new("TextLabel", hFrame)
        h.Size = UDim2.new(0, 80, 1, 0)
        h.Position = UDim2.new(0, 6, 0, 0)
        h.BackgroundTransparency = 1
        h.Font = Enum.Font.GothamBold
        h.TextSize = 9
        h.TextColor3 = self.Theme.TextDim
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Text = string.upper(titleText)

        local divLine = Instance.new("Frame", hFrame)
        divLine.Size = UDim2.new(1, -92, 0, 1)
        divLine.Position = UDim2.new(0, 88, 0.5, 0)
        divLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        divLine.BorderSizePixel = 0
        local dGrad = Instance.new("UIGradient", divLine)
        dGrad.Color = ColorSequence.new(self.Theme.Border)
        dGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35),
            NumberSequenceKeypoint.new(1, 1)
        })
        self:_RegisterElement("Borders", divLine)

        return hFrame
    end

    local ColorPickerModal = Instance.new("Frame", MainWindow)
    ColorPickerModal.Name = "ColorPickerModal"
    ColorPickerModal.Size = UDim2.new(0, 350, 0, 265)
    ColorPickerModal.Position = UDim2.new(0.5, -175, 0.5, -132)
    ColorPickerModal.BackgroundColor3 = Color3.fromRGB(30, 27, 40)
    ColorPickerModal.BorderSizePixel = 0
    ColorPickerModal.Visible = false
    ColorPickerModal.ZIndex = 100
    ColorPickerModal.ClipsDescendants = true
    Instance.new("UICorner", ColorPickerModal).CornerRadius = UDim.new(0, 14)
    local cpStroke = Instance.new("UIStroke", ColorPickerModal)
    cpStroke.Color = Color3.fromRGB(70, 62, 92)
    cpStroke.Thickness = 1.2

    local cpHeader = Instance.new("Frame", ColorPickerModal)
    cpHeader.Size = UDim2.new(1, 0, 0, 36)
    cpHeader.BackgroundTransparency = 1
    cpHeader.ZIndex = 101
    AttachDrag(cpHeader, ColorPickerModal)

    local cpTitle = Instance.new("TextLabel", cpHeader)
    cpTitle.Size = UDim2.new(1, -50, 1, 0)
    cpTitle.Position = UDim2.new(0, 14, 0, 0)
    cpTitle.BackgroundTransparency = 1
    cpTitle.Font = Enum.Font.GothamBold
    cpTitle.TextSize = 13
    cpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cpTitle.TextXAlignment = Enum.TextXAlignment.Left
    cpTitle.Text = "Colorpicker"
    cpTitle.ZIndex = 101

    local cpClose = Instance.new("TextButton", cpHeader)
    cpClose.Size = UDim2.new(0, 22, 0, 22)
    cpClose.Position = UDim2.new(1, -30, 0.5, -11)
    cpClose.BackgroundColor3 = Color3.fromRGB(42, 38, 56)
    cpClose.Text = "X"
    cpClose.Font = Enum.Font.GothamBold
    cpClose.TextSize = 10
    cpClose.TextColor3 = Color3.fromRGB(190, 185, 210)
    cpClose.ZIndex = 102
    Instance.new("UICorner", cpClose).CornerRadius = UDim.new(1, 0)

    local currH, currS, currV = 0.45, 1, 0.9
    local oldColor = Color3.fromRGB(0, 255, 140)
    local activeColor = oldColor
    local activeColorCallback = nil
    local isUpdatingInternal = false

    local SVBox = Instance.new("Frame", ColorPickerModal)
    SVBox.Name = "SVBox"
    SVBox.Size = UDim2.new(0, 155, 0, 125)
    SVBox.Position = UDim2.new(0, 14, 0, 42)
    SVBox.BackgroundColor3 = Color3.fromHSV(currH, 1, 1)
    SVBox.BorderSizePixel = 0
    SVBox.ClipsDescendants = true
    SVBox.ZIndex = 101
    Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 6)

    local WhiteOverlay = Instance.new("Frame", SVBox)
    WhiteOverlay.Size = UDim2.new(1, 0, 1, 0)
    WhiteOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
    WhiteOverlay.BorderSizePixel = 0
    WhiteOverlay.ZIndex = 102
    local wGrad = Instance.new("UIGradient", WhiteOverlay)
    wGrad.Color = ColorSequence.new(Color3.new(1, 1, 1))
    wGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    wGrad.Rotation = 0

    local BlackOverlay = Instance.new("Frame", SVBox)
    BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
    BlackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    BlackOverlay.BorderSizePixel = 0
    BlackOverlay.ZIndex = 103
    local bGrad = Instance.new("UIGradient", BlackOverlay)
    bGrad.Color = ColorSequence.new(Color3.new(0, 0, 0))
    bGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    bGrad.Rotation = 90

    local SVCursor = Instance.new("Frame", SVBox)
    SVCursor.Size = UDim2.new(0, 11, 0, 11)
    SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    SVCursor.Position = UDim2.new(currS, 0, 1 - currV, 0)
    SVCursor.BackgroundTransparency = 1
    SVCursor.ZIndex = 104
    Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1, 0)
    local curStroke = Instance.new("UIStroke", SVCursor)
    curStroke.Color = Color3.new(1, 1, 1)
    curStroke.Thickness = 1.6

    local HueBar = Instance.new("Frame", ColorPickerModal)
    HueBar.Name = "HueBar"
    HueBar.Size = UDim2.new(0, 11, 0, 125)
    HueBar.Position = UDim2.new(0, 178, 0, 42)
    HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
    HueBar.BorderSizePixel = 0
    HueBar.ZIndex = 101
    Instance.new("UICorner", HueBar).CornerRadius = UDim.new(1, 0)
    local hueGrad = Instance.new("UIGradient", HueBar)
    hueGrad.Rotation = 90
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    })

    local HueKnob = Instance.new("Frame", HueBar)
    HueKnob.Size = UDim2.new(1, 6, 0, 6)
    HueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    HueKnob.Position = UDim2.new(0.5, 0, currH, 0)
    HueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueKnob.ZIndex = 104
    Instance.new("UICorner", HueKnob).CornerRadius = UDim.new(1, 0)
    local hkStroke = Instance.new("UIStroke", HueKnob)
    hkStroke.Color = Color3.fromRGB(48, 44, 62)
    hkStroke.Thickness = 1.2

    local InputsContainer = Instance.new("Frame", ColorPickerModal)
    InputsContainer.Size = UDim2.new(1, -204, 0, 125)
    InputsContainer.Position = UDim2.new(0, 198, 0, 42)
    InputsContainer.BackgroundTransparency = 1
    InputsContainer.ZIndex = 101

    local inLayout = Instance.new("UIListLayout", InputsContainer)
    inLayout.SortOrder = Enum.SortOrder.LayoutOrder
    inLayout.Padding = UDim.new(0, 6)

    local function MakeField(labelName, order)
        local row = Instance.new("Frame", InputsContainer)
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.ZIndex = 101

        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(1, -44, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(44, 38, 58)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.GothamBold
        box.TextSize = 10.5
        box.ClearTextOnFocus = false
        box.ZIndex = 102
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local bSt = Instance.new("UIStroke", box)
        bSt.Color = Color3.fromRGB(64, 54, 84)
        bSt.Thickness = 1

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0, 40, 1, 0)
        lbl.Position = UDim2.new(1, -40, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 9.5
        lbl.TextColor3 = Color3.fromRGB(190, 185, 210)
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.Text = labelName
        lbl.ZIndex = 102

        return box
    end

    local hexInput   = MakeField("Hex", 1)
    local redInput   = MakeField("Red", 2)
    local greenInput = MakeField("Green", 3)
    local blueInput  = MakeField("Blue", 4)

    local SwatchRow = Instance.new("Frame", ColorPickerModal)
    SwatchRow.Size = UDim2.new(0, 175, 0, 24)
    SwatchRow.Position = UDim2.new(0, 14, 0, 176)
    SwatchRow.BackgroundTransparency = 1
    SwatchRow.ZIndex = 101

    local oldSwatch = Instance.new("TextButton", SwatchRow)
    oldSwatch.Size = UDim2.new(0.5, -4, 1, 0)
    oldSwatch.BackgroundColor3 = oldColor
    oldSwatch.Text = ""
    oldSwatch.AutoButtonColor = false
    oldSwatch.ZIndex = 102
    Instance.new("UICorner", oldSwatch).CornerRadius = UDim.new(0, 6)
    local osSt = Instance.new("UIStroke", oldSwatch)
    osSt.Color = Color3.fromRGB(70, 62, 92)
    osSt.Thickness = 1

    local newSwatch = Instance.new("Frame", SwatchRow)
    newSwatch.Size = UDim2.new(0.5, -4, 1, 0)
    newSwatch.Position = UDim2.new(0.5, 4, 0, 0)
    newSwatch.BackgroundColor3 = activeColor
    newSwatch.ZIndex = 102
    Instance.new("UICorner", newSwatch).CornerRadius = UDim.new(0, 6)
    local nsSt = Instance.new("UIStroke", newSwatch)
    nsSt.Color = Color3.fromRGB(255, 255, 255)
    nsSt.Thickness = 1
    nsSt.Transparency = 0.5

    local btnRow = Instance.new("Frame", ColorPickerModal)
    btnRow.Size = UDim2.new(1, -28, 0, 32)
    btnRow.Position = UDim2.new(0, 14, 1, -44)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 101

    local doneBtn = Instance.new("TextButton", btnRow)
    doneBtn.Size = UDim2.new(0.5, -5, 1, 0)
    doneBtn.BackgroundColor3 = Color3.fromRGB(44, 40, 60)
    doneBtn.Text = "Done"
    doneBtn.Font = Enum.Font.GothamBold
    doneBtn.TextSize = 11
    doneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    doneBtn.AutoButtonColor = false
    doneBtn.ZIndex = 102
    Instance.new("UICorner", doneBtn).CornerRadius = UDim.new(0, 8)

    local cancelBtn = Instance.new("TextButton", btnRow)
    cancelBtn.Size = UDim2.new(0.5, -5, 1, 0)
    cancelBtn.Position = UDim2.new(0.5, 5, 0, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(44, 40, 60)
    cancelBtn.Text = "Cancel"
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 11
    cancelBtn.TextColor3 = Color3.fromRGB(190, 185, 210)
    cancelBtn.AutoButtonColor = false
    cancelBtn.ZIndex = 102
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

    doneBtn.MouseEnter:Connect(function() Tween(doneBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(58, 52, 78)}) end)
    doneBtn.MouseLeave:Connect(function() Tween(doneBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(44, 40, 60)}) end)
    cancelBtn.MouseEnter:Connect(function() Tween(cancelBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(58, 52, 78)}) end)
    cancelBtn.MouseLeave:Connect(function() Tween(cancelBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(44, 40, 60)}) end)

    local function RefreshVisuals(fromInputs)
        activeColor = Color3.fromHSV(currH, currS, currV)
        SVBox.BackgroundColor3 = Color3.fromHSV(currH, 1, 1)
        SVCursor.Position = UDim2.new(currS, 0, 1 - currV, 0)
        HueKnob.Position = UDim2.new(0.5, 0, currH, 0)
        newSwatch.BackgroundColor3 = activeColor

        if not fromInputs then
            isUpdatingInternal = true
            hexInput.Text = ColorToHex(activeColor)
            redInput.Text = tostring(math.floor(activeColor.R * 255))
            greenInput.Text = tostring(math.floor(activeColor.G * 255))
            blueInput.Text = tostring(math.floor(activeColor.B * 255))
            isUpdatingInternal = false
        end
    end

    local svDragging = false
    local hueDragging = false

    local function UpdateSV(x, y)
        local w = SVBox.AbsoluteSize.X
        local h = SVBox.AbsoluteSize.Y
        local relX = math.clamp(x - SVBox.AbsolutePosition.X, 0, w)
        local relY = math.clamp(y - SVBox.AbsolutePosition.Y, 0, h)
        currS = relX / w
        currV = 1 - (relY / h)
        RefreshVisuals(false)
    end

    local function UpdateHue(y)
        local h = HueBar.AbsoluteSize.Y
        local relY = math.clamp(y - HueBar.AbsolutePosition.Y, 0, h)
        currH = relY / h
        RefreshVisuals(false)
    end

    SVBox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            UpdateSV(inp.Position.X, inp.Position.Y)
        end
    end)

    HueBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            UpdateHue(inp.Position.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            svDragging = false
            hueDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            if svDragging then UpdateSV(inp.Position.X, inp.Position.Y) end
            if hueDragging then UpdateHue(inp.Position.Y) end
        end
    end)

    hexInput.FocusLost:Connect(function()
        if isUpdatingInternal then return end
        local parsed = HexToColor(hexInput.Text)
        if parsed then
            currH, currS, currV = Color3.toHSV(parsed)
            RefreshVisuals(false)
        else
            hexInput.Text = ColorToHex(activeColor)
        end
    end)

    local function HandleRGBInput()
        if isUpdatingInternal then return end
        local r = math.clamp(tonumber(redInput.Text) or 0, 0, 255)
        local g = math.clamp(tonumber(greenInput.Text) or 0, 0, 255)
        local b = math.clamp(tonumber(blueInput.Text) or 0, 0, 255)
        local parsed = Color3.fromRGB(r, g, b)
        currH, currS, currV = Color3.toHSV(parsed)
        RefreshVisuals(false)
    end

    redInput.FocusLost:Connect(HandleRGBInput)
    greenInput.FocusLost:Connect(HandleRGBInput)
    blueInput.FocusLost:Connect(HandleRGBInput)

    oldSwatch.MouseButton1Click:Connect(function()
        self:_PlaySound("Click")
        currH, currS, currV = Color3.toHSV(oldColor)
        RefreshVisuals(false)
    end)

    doneBtn.MouseButton1Click:Connect(function()
        self:_PlaySound("Click")
        MicroBounce(doneBtn)
        ColorPickerModal.Visible = false
        if activeColorCallback then
            pcall(activeColorCallback, activeColor, ColorToHex(activeColor))
        end
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        self:_PlaySound("Click")
        ColorPickerModal.Visible = false
    end)

    cpClose.MouseButton1Click:Connect(function()
        ColorPickerModal.Visible = false
    end)

    WindowObj.OpenColorPicker = function(self_, initialColor, onColorChange, titleText)
        initialColor = initialColor or self.Theme.Accent
        oldColor = initialColor
        currH, currS, currV = Color3.toHSV(initialColor)
        oldSwatch.BackgroundColor3 = oldColor
        activeColorCallback = onColorChange
        cpTitle.Text = titleText or "Colorpicker"
        RefreshVisuals(false)
        ColorPickerModal.Visible = true
    end

    WindowObj.CreateTab = function(self_, tabConfig)
        tabConfig = tabConfig or {}
        local TabTitle = tabConfig.Title or "Tab"
        local TabIcon = tabConfig.IconId or self.Icons.Dashboard
        local BadgeText = tabConfig.BadgeText
        local LayoutOrder = tabConfig.LayoutOrder or (#WindowObj.Tabs + 5)

        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Name = "Page_" .. TabTitle
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = self.Theme.Border
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false

        local pagePad = Instance.new("UIPadding", Page)
        pagePad.PaddingLeft = UDim.new(0, 10)
        pagePad.PaddingRight = UDim.new(0, 10)
        pagePad.PaddingTop = UDim.new(0, 10)
        pagePad.PaddingBottom = UDim.new(0, 20)

        local pageLayout = Instance.new("UIListLayout", Page)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 10)

        local TopContainer = Instance.new("Frame", Page)
        TopContainer.Name = "TopContainer"
        TopContainer.Size = UDim2.new(1, 0, 0, 0)
        TopContainer.BackgroundTransparency = 1
        TopContainer.AutomaticSize = Enum.AutomaticSize.Y
        TopContainer.LayoutOrder = 1

        local topLayout = Instance.new("UIListLayout", TopContainer)
        topLayout.SortOrder = Enum.SortOrder.LayoutOrder
        topLayout.Padding = UDim.new(0, 8)

        local Columns = Instance.new("Frame", Page)
        Columns.Name = "Columns"
        Columns.Size = UDim2.new(1, 0, 0, 0)
        Columns.BackgroundTransparency = 1
        Columns.AutomaticSize = Enum.AutomaticSize.Y
        Columns.LayoutOrder = 2

        local LeftCol = Instance.new("Frame", Columns)
        LeftCol.Name = "LeftColumn"
        LeftCol.Size = UDim2.new(0.488, 0, 0, 0)
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.AutomaticSize = Enum.AutomaticSize.Y

        local leftLayout = Instance.new("UIListLayout", LeftCol)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.Padding = UDim.new(0, 10)

        local RightCol = Instance.new("Frame", Columns)
        RightCol.Name = "RightColumn"
        RightCol.Size = UDim2.new(0.488, 0, 0, 0)
        RightCol.Position = UDim2.new(0.512, 0, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.AutomaticSize = Enum.AutomaticSize.Y

        local rightLayout = Instance.new("UIListLayout", RightCol)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.Padding = UDim.new(0, 10)

        local TabBtn = Instance.new("TextButton", NavScroll)
        TabBtn.Name = "Nav_" .. TabTitle
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = self.Theme.SubBox
        TabBtn.BackgroundTransparency = 0.85
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.LayoutOrder = LayoutOrder
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        local tabStroke = Instance.new("UIStroke", TabBtn)
        tabStroke.Name = "TabStroke"
        tabStroke.Color = self.Theme.Border
        tabStroke.Thickness = 1
        tabStroke.Transparency = 0.75

        local activeGlow = Instance.new("Frame", TabBtn)
        activeGlow.Name = "ActiveGlow"
        activeGlow.Size = UDim2.new(1, 0, 1, 0)
        activeGlow.BackgroundColor3 = self.Theme.Accent
        activeGlow.BackgroundTransparency = 0.8
        activeGlow.BorderSizePixel = 0
        activeGlow.Visible = false
        Instance.new("UICorner", activeGlow).CornerRadius = UDim.new(0, 10)
        local agGrad = Instance.new("UIGradient", activeGlow)
        agGrad.Color = ColorSequence.new(self.Theme.Accent)
        agGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.65),
            NumberSequenceKeypoint.new(1, 1)
        })
        self:_RegisterElement("Accents", activeGlow)

        local iconBadge = Instance.new("Frame", TabBtn)
        iconBadge.Name = "IconBadge"
        iconBadge.Size = UDim2.new(0, 26, 0, 26)
        iconBadge.Position = UDim2.new(0, 8, 0.5, -13)
        iconBadge.BackgroundColor3 = self.Theme.SubBox
        iconBadge.BackgroundTransparency = 0.45
        iconBadge.BorderSizePixel = 0
        Instance.new("UICorner", iconBadge).CornerRadius = UDim.new(0, 8)
        local ibStroke = Instance.new("UIStroke", iconBadge)
        ibStroke.Name = "BadgeStroke"
        ibStroke.Color = self.Theme.Border
        ibStroke.Thickness = 1
        ibStroke.Transparency = 0.6

        local tIcon = Instance.new("ImageLabel", iconBadge)
        tIcon.Name = "TabIcon"
        tIcon.Size = UDim2.new(0, 15, 0, 15)
        tIcon.Position = UDim2.new(0.5, -7.5, 0.5, -7.5)
        tIcon.BackgroundTransparency = 1
        tIcon.Image = TabIcon
        tIcon.ImageColor3 = self.Theme.TextDim

        local tName = Instance.new("TextLabel", TabBtn)
        tName.Name = "TabName"
        tName.Size = UDim2.new(1, -70, 1, 0)
        tName.Position = UDim2.new(0, 40, 0, 0)
        tName.BackgroundTransparency = 1
        tName.Font = Enum.Font.GothamMedium
        tName.TextSize = 11.5
        tName.TextColor3 = self.Theme.TextDim
        tName.TextXAlignment = Enum.TextXAlignment.Left
        tName.Text = TabTitle

        if BadgeText then
            local bTag = Instance.new("Frame", TabBtn)
            bTag.Name = "BadgeTag"
            bTag.Size = UDim2.new(0, 46, 0, 18)
            bTag.Position = UDim2.new(1, -52, 0.5, -9)
            bTag.BackgroundColor3 = Color3.fromRGB(15, 26, 20)
            bTag.BackgroundTransparency = 0.25
            bTag.BorderSizePixel = 0
            Instance.new("UICorner", bTag).CornerRadius = UDim.new(1, 0)

            local btStroke = Instance.new("UIStroke", bTag)
            btStroke.Color = Color3.fromRGB(34, 197, 94)
            btStroke.Transparency = 0.5
            btStroke.Thickness = 1

            local bText = Instance.new("TextLabel", bTag)
            bText.BackgroundTransparency = 1
            bText.Font = Enum.Font.GothamBold
            bText.TextSize = 8.5
            bText.TextColor3 = Color3.fromRGB(34, 197, 94)
            bText.Text = BadgeText
            bText.Size = UDim2.new(1, 0, 1, 0)
            bText.TextXAlignment = Enum.TextXAlignment.Center
        end

        local TabObj = {
            Page = Page,
            Button = TabBtn,
            Title = TabTitle,
            TopContainer = TopContainer,
            Columns = Columns,
            LeftCol = LeftCol,
            RightCol = RightCol
        }

        TabBtn.MouseEnter:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                Tween(tabStroke, 0.18, {Color = self.Theme.BorderLight, Transparency = 0.2, Thickness = 1.2})
                Tween(TabBtn, 0.18, {BackgroundColor3 = self.Theme.SubBox, BackgroundTransparency = 0.35})
                Tween(iconBadge, 0.18, {Position = UDim2.new(0, 11, 0.5, -13), BackgroundTransparency = 0.25})
                Tween(ibStroke, 0.18, {Color = self.Theme.BorderLight, Transparency = 0.25})
                Tween(tName, 0.18, {Position = UDim2.new(0, 44, 0, 0), TextColor3 = self.Theme.TextTitle})
                Tween(tIcon, 0.18, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            end
        end)

        TabBtn.MouseLeave:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                Tween(tabStroke, 0.18, {Color = self.Theme.Border, Transparency = 0.75, Thickness = 1})
                Tween(TabBtn, 0.18, {BackgroundColor3 = self.Theme.SubBox, BackgroundTransparency = 0.85})
                Tween(iconBadge, 0.18, {Position = UDim2.new(0, 8, 0.5, -13), BackgroundTransparency = 0.45})
                Tween(ibStroke, 0.18, {Color = self.Theme.Border, Transparency = 0.6})
                Tween(tName, 0.18, {Position = UDim2.new(0, 40, 0, 0), TextColor3 = self.Theme.TextDim})
                Tween(tIcon, 0.18, {ImageColor3 = self.Theme.TextDim})
            end
        end)

        local function Activate()
            if WindowObj.ActiveTab == TabObj then return end
            self:_PlaySound("TabSwitch")
            MicroBounce(TabBtn)

            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = self.Theme.SubBox
                t.Button.BackgroundTransparency = 0.85
                local st = t.Button:FindFirstChild("TabStroke")
                if st then
                    st.Color = self.Theme.Border
                    st.Transparency = 0.75
                    st.Thickness = 1
                end
                local ag = t.Button:FindFirstChild("ActiveGlow")
                if ag then ag.Visible = false end
                local ib = t.Button:FindFirstChild("IconBadge")
                if ib then
                    ib.BackgroundColor3 = self.Theme.SubBox
                    ib.BackgroundTransparency = 0.45
                    local ibs = ib:FindFirstChild("BadgeStroke")
                    if ibs then ibs.Color = self.Theme.Border ibs.Transparency = 0.6 ibs.Thickness = 1 end
                    local ic = ib:FindFirstChild("TabIcon") or ib:FindFirstChildOfClass("ImageLabel")
                    if ic then ic.ImageColor3 = self.Theme.TextDim end
                end
                local tn = t.Button:FindFirstChild("TabName") or t.Button:FindFirstChildOfClass("TextLabel")
                if tn then
                    tn.TextColor3 = self.Theme.TextDim
                    tn.Font = Enum.Font.GothamMedium
                end
            end

            WindowObj.ActiveTab = TabObj

            Page.Position = UDim2.new(0, 0, 0, 6)
            Page.Visible = true
            Tween(Page, 0.22, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            activeGlow.Visible = true
            TabBtn.BackgroundColor3 = self.Theme.SubBox
            TabBtn.BackgroundTransparency = 0.15
            tabStroke.Color = self.Theme.Accent
            tabStroke.Transparency = 0.2
            tabStroke.Thickness = 1.2

            iconBadge.BackgroundColor3 = self.Theme.Accent
            iconBadge.BackgroundTransparency = 0.12
            ibStroke.Color = self.Theme.AccentLight
            ibStroke.Transparency = 0
            ibStroke.Thickness = 1.2
            tName.TextColor3 = self.Theme.TextTitle
            tName.Font = Enum.Font.GothamBold
            tIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabObj.Activate = Activate

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then Activate() end

        local groupCounter = 0
        TabObj.CreateGroupBox = function(self_, sideOrTitle, titleOrBadge, badgeOrIcon, iconOpt)
            local side, titleText, rightBadgeText, iconIdOpt
            if sideOrTitle == "Right" or sideOrTitle == "Left" or sideOrTitle == 1 or sideOrTitle == 2 then
                side = (sideOrTitle == "Right" or sideOrTitle == 2) and "Right" or "Left"
                titleText = titleOrBadge or "Group"
                rightBadgeText = badgeOrIcon
                iconIdOpt = iconOpt
            else
                groupCounter = groupCounter + 1
                side = (groupCounter % 2 == 0) and "Right" or "Left"
                titleText = sideOrTitle or "Group"
                rightBadgeText = titleOrBadge
                iconIdOpt = badgeOrIcon
            end

            local targetCol = (side == "Right") and RightCol or LeftCol
            local BoxCard = Instance.new("Frame", targetCol)
            BoxCard.Name = "GroupBox_" .. tostring(titleText)
            BoxCard.Size = UDim2.new(1, 0, 0, 36)
            BoxCard.BackgroundColor3 = self.Theme.Box
            BoxCard.BorderSizePixel = 0
            BoxCard.AutomaticSize = Enum.AutomaticSize.Y
            Instance.new("UICorner", BoxCard).CornerRadius = UDim.new(0, 12)
            local bStroke = Instance.new("UIStroke", BoxCard)
            bStroke.Color = self.Theme.Border
            bStroke.Thickness = 1

            self:_RegisterElement("Boxes", BoxCard)
            self:_RegisterElement("Borders", bStroke)

            local BoxHeader = Instance.new("Frame", BoxCard)
            BoxHeader.Size = UDim2.new(1, 0, 0, 34)
            BoxHeader.BackgroundTransparency = 1

            local bIcon = Instance.new("ImageLabel", BoxHeader)
            bIcon.Size = UDim2.new(0, 14, 0, 14)
            bIcon.Position = UDim2.new(0, 12, 0.5, -7)
            bIcon.BackgroundTransparency = 1
            bIcon.Image = iconIdOpt or self.Icons.Logo
            bIcon.ImageColor3 = self.Theme.AccentLight
            self:_RegisterElement("Accents", bIcon)

            local bTitle = Instance.new("TextLabel", BoxHeader)
            bTitle.Size = UDim2.new(1, -90, 1, 0)
            bTitle.Position = UDim2.new(0, 32, 0, 0)
            bTitle.BackgroundTransparency = 1
            bTitle.Font = Enum.Font.GothamBold
            bTitle.TextSize = 10.5
            bTitle.TextColor3 = self.Theme.TextTitle
            bTitle.TextXAlignment = Enum.TextXAlignment.Left
            bTitle.Text = string.upper(titleText)

            if rightBadgeText then
                local bBadge = Instance.new("TextLabel", BoxHeader)
                bBadge.Size = UDim2.new(0, 75, 0, 18)
                bBadge.Position = UDim2.new(1, -85, 0.5, -9)
                bBadge.BackgroundColor3 = self.Theme.SubBox
                bBadge.Font = Enum.Font.GothamBold
                bBadge.TextSize = 8.5
                bBadge.TextColor3 = self.Theme.Success
                bBadge.Text = string.upper(rightBadgeText)
                Instance.new("UICorner", bBadge).CornerRadius = UDim.new(1, 0)
                self:_RegisterElement("SubBoxes", bBadge)
            end

            local line = Instance.new("Frame", BoxHeader)
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 1, -1)
            line.BackgroundColor3 = self.Theme.Border
            line.BorderSizePixel = 0
            self:_RegisterElement("Borders", line)

            local Container = Instance.new("Frame", BoxCard)
            Container.Name = "Container"
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.Position = UDim2.new(0, 0, 0, 34)
            Container.BackgroundTransparency = 1
            Container.AutomaticSize = Enum.AutomaticSize.Y

            local cLayout = Instance.new("UIListLayout", Container)
            cLayout.SortOrder = Enum.SortOrder.LayoutOrder
            cLayout.Padding = UDim.new(0, 7)

            local cPad = Instance.new("UIPadding", Container)
            cPad.PaddingLeft = UDim.new(0, 12)
            cPad.PaddingRight = UDim.new(0, 12)
            cPad.PaddingTop = UDim.new(0, 8)
            cPad.PaddingBottom = UDim.new(0, 12)

            local BoxObj = { Card = BoxCard, Container = Container }

            BoxObj.AddToggle = function(self_, title, desc, defaultVal, callback)
                callback = callback or function() end
                local state = defaultVal or false

                local row = Instance.new("Frame", Container)
                row.Size = UDim2.new(1, 0, 0, 0)
                row.BackgroundTransparency = 1
                row.AutomaticSize = Enum.AutomaticSize.Y

                table.insert(WindowObj.AllSearchableItems, {
                    Frame = row,
                    SearchText = string.lower(title .. " " .. (desc or ""))
                })

                local textCol = Instance.new("Frame", row)
                textCol.Size = UDim2.new(1, -48, 0, 0)
                textCol.Position = UDim2.new(0, 0, 0, 2)
                textCol.BackgroundTransparency = 1
                textCol.AutomaticSize = Enum.AutomaticSize.Y

                local tcLayout = Instance.new("UIListLayout", textCol)
                tcLayout.SortOrder = Enum.SortOrder.LayoutOrder
                tcLayout.Padding = UDim.new(0, 2)

                local tLbl = Instance.new("TextLabel", textCol)
                tLbl.Size = UDim2.new(1, 0, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Font = Enum.Font.GothamMedium
                tLbl.TextSize = 11
                tLbl.TextColor3 = self.Theme.TextBody
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.TextWrapped = true
                tLbl.AutomaticSize = Enum.AutomaticSize.Y
                tLbl.Text = title

                if desc then
                    local dLbl = Instance.new("TextLabel", textCol)
                    dLbl.Size = UDim2.new(1, 0, 0, 0)
                    dLbl.BackgroundTransparency = 1
                    dLbl.Font = Enum.Font.Gotham
                    dLbl.TextSize = 9.5
                    dLbl.TextColor3 = self.Theme.TextDim
                    dLbl.TextXAlignment = Enum.TextXAlignment.Left
                    dLbl.TextWrapped = true
                    dLbl.AutomaticSize = Enum.AutomaticSize.Y
                    dLbl.Text = desc
                end

                local Pill = Instance.new("TextButton", row)
                Pill.Size = UDim2.new(0, 38, 0, 20)
                Pill.AnchorPoint = Vector2.new(1, 0.5)
                Pill.Position = UDim2.new(1, 0, 0.5, 0)
                Pill.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or self.Theme.SubBox
                Pill.Text = ""
                Pill.AutoButtonColor = false
                Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

                local pGrad = nil
                if state then pGrad = self:_ApplyGradient(Pill, self.Theme.Grad1, self.Theme.Grad2, 45) end

                local Knob = Instance.new("Frame", Pill)
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local function Set(v)
                    state = v
                    self:_PlaySound(state and "ToggleOn" or "ToggleOff")
                    MicroBounce(Pill)
                    if state then
                        Pill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        if not pGrad then pGrad = self:_ApplyGradient(Pill, self.Theme.Grad1, self.Theme.Grad2, 45) end
                        Tween(Knob, 0.2, {Position = UDim2.new(1, -17, 0.5, -7)})
                    else
                        if pGrad then pGrad:Destroy() pGrad = nil end
                        Pill.BackgroundColor3 = self.Theme.SubBox
                        Tween(Knob, 0.2, {Position = UDim2.new(0, 3, 0.5, -7)})
                    end
                    pcall(callback, state)
                end

                Pill.MouseButton1Click:Connect(function() Set(not state) end)
                return { Set = Set, Get = function() return state end }
            end

            BoxObj.AddSlider = function(self_, title, minVal, maxVal, defaultVal, suffix, callback)
                callback = callback or function() end
                suffix = suffix or ""
                local currentVal = math.clamp(defaultVal or minVal, minVal, maxVal)

                local row = Instance.new("Frame", Container)
                row.Size = UDim2.new(1, 0, 0, 0)
                row.BackgroundTransparency = 1
                row.AutomaticSize = Enum.AutomaticSize.Y

                local rLayout = Instance.new("UIListLayout", row)
                rLayout.SortOrder = Enum.SortOrder.LayoutOrder
                rLayout.Padding = UDim.new(0, 5)

                local topRow = Instance.new("Frame", row)
                topRow.Size = UDim2.new(1, 0, 0, 0)
                topRow.BackgroundTransparency = 1
                topRow.AutomaticSize = Enum.AutomaticSize.Y
                topRow.LayoutOrder = 1

                local tLbl = Instance.new("TextLabel", topRow)
                tLbl.Size = UDim2.new(1, -70, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Font = Enum.Font.GothamBold
                tLbl.TextSize = 10
                tLbl.TextColor3 = self.Theme.TextBody
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.TextWrapped = true
                tLbl.AutomaticSize = Enum.AutomaticSize.Y
                tLbl.Text = string.upper(title)

                local valLbl = Instance.new("TextLabel", topRow)
                valLbl.Size = UDim2.new(0, 65, 0, 15)
                valLbl.Position = UDim2.new(1, -65, 0, 0)
                valLbl.BackgroundTransparency = 1
                valLbl.Font = Enum.Font.GothamBold
                valLbl.TextSize = 10
                valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.Text = tostring(currentVal) .. " " .. suffix
                self:_ApplyGradient(valLbl, self.Theme.Grad1, self.Theme.Grad2, 0)

                local trackRow = Instance.new("Frame", row)
                trackRow.Size = UDim2.new(1, 0, 0, 20)
                trackRow.BackgroundTransparency = 1
                trackRow.LayoutOrder = 2

                local btnDown = Instance.new("TextButton", trackRow)
                btnDown.Size = UDim2.new(0, 20, 0, 20)
                btnDown.BackgroundColor3 = self.Theme.SubBox
                btnDown.Text = "-"
                btnDown.Font = Enum.Font.GothamBold
                btnDown.TextSize = 12
                btnDown.TextColor3 = self.Theme.TextDim
                Instance.new("UICorner", btnDown).CornerRadius = UDim.new(1, 0)
                local bdSt = Instance.new("UIStroke", btnDown)
                bdSt.Color = self.Theme.Border
                self:_RegisterElement("SubBoxes", btnDown)
                self:_RegisterElement("Borders", bdSt)

                local Track = Instance.new("Frame", trackRow)
                Track.Size = UDim2.new(1, -54, 0, 6)
                Track.Position = UDim2.new(0, 27, 0.5, -3)
                Track.BackgroundColor3 = self.Theme.SubBox
                Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

                local ratio = (currentVal - minVal) / (maxVal - minVal)
                local Fill = Instance.new("Frame", Track)
                Fill.Size = UDim2.new(ratio, 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
                self:_ApplyGradient(Fill, self.Theme.Grad1, self.Theme.Grad2, 0)

                local Knob = Instance.new("Frame", Track)
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new(ratio, -6, 0.5, -6)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local btnUp = Instance.new("TextButton", trackRow)
                btnUp.Size = UDim2.new(0, 20, 0, 20)
                btnUp.Position = UDim2.new(1, -20, 0, 0)
                btnUp.BackgroundColor3 = self.Theme.SubBox
                btnUp.Text = "+"
                btnUp.Font = Enum.Font.GothamBold
                btnUp.TextSize = 12
                btnUp.TextColor3 = self.Theme.TextDim
                Instance.new("UICorner", btnUp).CornerRadius = UDim.new(1, 0)
                local buSt = Instance.new("UIStroke", btnUp)
                buSt.Color = self.Theme.Border
                self:_RegisterElement("SubBoxes", btnUp)
                self:_RegisterElement("Borders", buSt)

                local function SetVal(v)
                    currentVal = math.clamp(v, minVal, maxVal)
                    local r = (currentVal - minVal) / (maxVal - minVal)
                    Fill.Size = UDim2.new(r, 0, 1, 0)
                    Knob.Position = UDim2.new(r, -6, 0.5, -6)
                    valLbl.Text = tostring(currentVal) .. " " .. suffix
                    valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    pcall(callback, currentVal)
                end

                btnDown.MouseButton1Click:Connect(function() self:_PlaySound("Click") SetVal(currentVal - 1) end)
                btnUp.MouseButton1Click:Connect(function() self:_PlaySound("Click") SetVal(currentVal + 1) end)

                local dragging = false
                Track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        self:_PlaySound("Click")
                        local w = Track.AbsoluteSize.X
                        local rel = math.clamp(inp.Position.X - Track.AbsolutePosition.X, 0, w)
                        SetVal(math.floor(minVal + (maxVal - minVal) * (rel / w)))
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        local w = Track.AbsoluteSize.X
                        local rel = math.clamp(inp.Position.X - Track.AbsolutePosition.X, 0, w)
                        SetVal(math.floor(minVal + (maxVal - minVal) * (rel / w)))
                    end
                end)
                return { Set = SetVal, Get = function() return currentVal end }
            end

            BoxObj.AddDropdown = function(self_, title, options, defaultVal, callback)
                callback = callback or function() end
                options = options or {}
                local selected = defaultVal or options[1] or ""
                local isOpen = false

                local row = Instance.new("Frame", Container)
                row.Size = UDim2.new(1, 0, 0, 48)
                row.BackgroundTransparency = 1
                row.ClipsDescendants = true

                local tLbl = Instance.new("TextLabel", row)
                tLbl.Size = UDim2.new(1, 0, 0, 14)
                tLbl.BackgroundTransparency = 1
                tLbl.Font = Enum.Font.GothamMedium
                tLbl.TextSize = 10
                tLbl.TextColor3 = self.Theme.TextDim
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.Text = string.upper(title)

                local Box = Instance.new("TextButton", row)
                Box.Size = UDim2.new(1, 0, 0, 28)
                Box.Position = UDim2.new(0, 0, 0, 18)
                Box.BackgroundColor3 = self.Theme.SubBox
                Box.Text = ""
                Box.AutoButtonColor = false
                Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
                local bSt = Instance.new("UIStroke", Box)
                bSt.Color = self.Theme.Border
                self:_RegisterElement("SubBoxes", Box)
                self:_RegisterElement("Borders", bSt)

                local vLbl = Instance.new("TextLabel", Box)
                vLbl.Size = UDim2.new(1, -26, 1, 0)
                vLbl.Position = UDim2.new(0, 10, 0, 0)
                vLbl.BackgroundTransparency = 1
                vLbl.Font = Enum.Font.GothamMedium
                vLbl.TextSize = 10.5
                vLbl.TextColor3 = self.Theme.TextTitle
                vLbl.TextXAlignment = Enum.TextXAlignment.Left
                vLbl.Text = selected

                local chev = Instance.new("ImageLabel", Box)
                chev.Size = UDim2.new(0, 12, 0, 12)
                chev.Position = UDim2.new(1, -20, 0.5, -6)
                chev.BackgroundTransparency = 1
                chev.Image = self.Icons.ChevronDown
                chev.ImageColor3 = self.Theme.TextDim

                local listFrame = Instance.new("Frame", row)
                listFrame.Size = UDim2.new(1, 0, 0, 0)
                listFrame.Position = UDim2.new(0, 0, 0, 50)
                listFrame.BackgroundTransparency = 1
                local lLayout = Instance.new("UIListLayout", listFrame)
                lLayout.Padding = UDim.new(0, 3)

                local function Toggle()
                    isOpen = not isOpen
                    self:_PlaySound("Dropdown")
                    local h = isOpen and (54 + (#options * 26)) or 48
                    Tween(row, 0.22, {Size = UDim2.new(1, 0, 0, h)})
                    Tween(chev, 0.22, {Rotation = isOpen and 180 or 0})
                end

                Box.MouseButton1Click:Connect(Toggle)

                for _, opt in ipairs(options) do
                    local ob = Instance.new("TextButton", listFrame)
                    ob.Size = UDim2.new(1, 0, 0, 24)
                    ob.BackgroundColor3 = self.Theme.Box
                    ob.Text = ""
                    ob.AutoButtonColor = false
                    Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 8)
                    self:_RegisterElement("Boxes", ob)

                    local ot = Instance.new("TextLabel", ob)
                    ot.Size = UDim2.new(1, -12, 1, 0)
                    ot.Position = UDim2.new(0, 10, 0, 0)
                    ot.BackgroundTransparency = 1
                    ot.Font = Enum.Font.Gotham
                    ot.TextSize = 10
                    ot.TextColor3 = self.Theme.TextBody
                    ot.TextXAlignment = Enum.TextXAlignment.Left
                    ot.Text = opt

                    ob.MouseButton1Click:Connect(function()
                        self:_PlaySound("Click")
                        selected = opt
                        vLbl.Text = opt
                        Toggle()
                        pcall(callback, opt)
                    end)
                end
                return { Get = function() return selected end }
            end

            BoxObj.AddInput = function(self_, name, placeholder, defaultVal, callback)
                local row = Instance.new("Frame", Container)
                row.Size = UDim2.new(1, 0, 0, 32)
                row.BackgroundTransparency = 1

                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(0.4, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 9.5
                lbl.TextColor3 = self.Theme.TextTitle
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Text = string.upper(name)

                local input = Instance.new("TextBox", row)
                input.Size = UDim2.new(0.6, 0, 0, 26)
                input.Position = UDim2.new(0.4, 0, 0.5, -13)
                input.BackgroundColor3 = self.Theme.SubBox
                input.Text = defaultVal or ""
                input.PlaceholderText = placeholder or ""
                input.PlaceholderColor3 = self.Theme.TextMuted
                input.Font = Enum.Font.Gotham
                input.TextSize = 9.5
                input.TextColor3 = self.Theme.TextTitle
                input.TextXAlignment = Enum.TextXAlignment.Left
                input.ClearTextOnFocus = false
                Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
                local inSt = Instance.new("UIStroke", input)
                inSt.Color = self.Theme.Border
                self:_RegisterElement("SubBoxes", input)
                self:_RegisterElement("Borders", inSt)

                local inPad = Instance.new("UIPadding", input)
                inPad.PaddingLeft = UDim.new(0, 8)
                inPad.PaddingRight = UDim.new(0, 8)

                input.FocusLost:Connect(function()
                    if callback then pcall(callback, input.Text) end
                end)
                return input
            end

            BoxObj.AddColorPickerRow = function(self_, name, defaultColor, callback)
                defaultColor = defaultColor or self.Theme.Accent
                local row = Instance.new("Frame", Container)
                row.Size = UDim2.new(1, 0, 0, 34)
                row.BackgroundTransparency = 1

                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(0.5, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 9.5
                lbl.TextColor3 = self.Theme.TextTitle
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Text = string.upper(name)

                local rightSide = Instance.new("Frame", row)
                rightSide.Size = UDim2.new(0.5, 0, 1, 0)
                rightSide.Position = UDim2.new(0.5, 0, 0, 0)
                rightSide.BackgroundTransparency = 1

                local swatch = Instance.new("Frame", rightSide)
                swatch.Size = UDim2.new(0, 18, 0, 18)
                swatch.Position = UDim2.new(1, -95, 0.5, -9)
                swatch.BackgroundColor3 = defaultColor
                Instance.new("UICorner", swatch).CornerRadius = UDim.new(1, 0)
                local swSt = Instance.new("UIStroke", swatch)
                swSt.Color = Color3.fromRGB(255, 255, 255)
                swSt.Thickness = 1
                swSt.Transparency = 0.4

                local hexLbl = Instance.new("TextLabel", rightSide)
                hexLbl.Size = UDim2.new(0, 60, 1, 0)
                hexLbl.Position = UDim2.new(1, -70, 0, 0)
                hexLbl.BackgroundTransparency = 1
                hexLbl.Font = Enum.Font.GothamBold
                hexLbl.TextSize = 10
                hexLbl.TextColor3 = self.Theme.AccentLight
                hexLbl.TextXAlignment = Enum.TextXAlignment.Left
                hexLbl.Text = ColorToHex(defaultColor)
                self:_RegisterElement("Accents", hexLbl)

                local palBtn = Instance.new("ImageLabel", rightSide)
                palBtn.Size = UDim2.new(0, 16, 0, 16)
                palBtn.Position = UDim2.new(1, -6, 0.5, -8)
                palBtn.BackgroundTransparency = 1
                palBtn.Image = self.Icons.Palette
                palBtn.ImageColor3 = self.Theme.TextDim

                local function Open()
                    self:_PlaySound("Click")
                    WindowObj:OpenColorPicker(swatch.BackgroundColor3, function(newCol, newHex)
                        swatch.BackgroundColor3 = newCol
                        hexLbl.Text = newHex
                        if callback then pcall(callback, newCol, newHex) end
                    end, name)
                end

                local clickArea = Instance.new("TextButton", row)
                clickArea.Size = UDim2.new(1, 0, 1, 0)
                clickArea.BackgroundTransparency = 1
                clickArea.Text = ""
                clickArea.MouseButton1Click:Connect(Open)

                return {
                    Row = row,
                    Set = function(c)
                        swatch.BackgroundColor3 = c
                        hexLbl.Text = ColorToHex(c)
                    end,
                    Get = function() return swatch.BackgroundColor3 end
                }
            end

            BoxObj.AddModeSelector = function(self_, name, modes, defaultMode, callback)
                local row = Instance.new("Frame", Container)
                row.Size = UDim2.new(1, 0, 0, 44)
                row.BackgroundTransparency = 1

                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(1, 0, 0, 14)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 9.5
                lbl.TextColor3 = self.Theme.TextDim
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Text = string.upper(name)

                local btnRow = Instance.new("Frame", row)
                btnRow.Size = UDim2.new(1, 0, 0, 26)
                btnRow.Position = UDim2.new(0, 0, 0, 18)
                btnRow.BackgroundTransparency = 1

                local bLayout = Instance.new("UIListLayout", btnRow)
                bLayout.FillDirection = Enum.FillDirection.Horizontal
                bLayout.Padding = UDim.new(0, 6)

                local active = defaultMode or modes[1]
                local modeButtons = {}

                local function RefreshSelector()
                    for nameMode, data in pairs(modeButtons) do
                        local isAct = (nameMode == active)
                        if isAct then
                            if self.Settings.AccentStyle == "Gradient" then
                                data.Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                if not data.Grad or not data.Grad.Parent then
                                    data.Grad = self:_ApplyGradient(data.Btn, self.Theme.Grad1, self.Theme.Grad2, 45)
                                else
                                    data.Grad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, self.Theme.Grad1 or self.Theme.Accent),
                                        ColorSequenceKeypoint.new(1, self.Theme.Grad2 or self.Theme.AccentLight)
                                    })
                                end
                            else
                                if data.Grad then data.Grad:Destroy() data.Grad = nil end
                                data.Btn.BackgroundColor3 = self.Theme.Accent
                            end
                            data.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            data.Stroke.Color = self.Theme.Accent
                        else
                            if data.Grad then data.Grad:Destroy() data.Grad = nil end
                            data.Btn.BackgroundColor3 = self.Theme.SubBox
                            data.Btn.TextColor3 = self.Theme.TextDim
                            data.Stroke.Color = self.Theme.Border
                        end
                    end
                end

                for _, m in ipairs(modes) do
                    local b = Instance.new("TextButton", btnRow)
                    b.Size = UDim2.new(1 / #modes, -((#modes - 1) * 6) / #modes, 1, 0)
                    b.Text = m
                    b.Font = Enum.Font.GothamBold
                    b.TextSize = 9.5
                    b.AutoButtonColor = false
                    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
                    local bSt = Instance.new("UIStroke", b)

                    modeButtons[m] = { Btn = b, Stroke = bSt, Grad = nil }

                    b.MouseButton1Click:Connect(function()
                        self:_PlaySound("Click")
                        active = m
                        RefreshSelector()
                        if callback then pcall(callback, m) end
                    end)
                end

                RefreshSelector()
                table.insert(self.ThemeRegistry.ModeSelectors, RefreshSelector)
            end

            BoxObj.AddActionRow = function(self_, title, subtitle, iconAsset, callback)
                callback = callback or function() end
                local row = Instance.new("TextButton", Container)
                row.Size = UDim2.new(1, 0, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.BackgroundColor3 = self.Theme.SubBox
                row.Text = ""
                row.AutoButtonColor = false
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
                local rStroke = Instance.new("UIStroke", row)
                rStroke.Color = self.Theme.Border
                self:_RegisterElement("SubBoxes", row)
                self:_RegisterElement("Borders", rStroke)

                local rPad = Instance.new("UIPadding", row)
                rPad.PaddingLeft = UDim.new(0, 10)
                rPad.PaddingRight = UDim.new(0, 30)
                rPad.PaddingTop = UDim.new(0, 6)
                rPad.PaddingBottom = UDim.new(0, 6)

                local rLayout = Instance.new("UIListLayout", row)
                rLayout.SortOrder = Enum.SortOrder.LayoutOrder
                rLayout.Padding = UDim.new(0, 2)

                local tLbl = Instance.new("TextLabel", row)
                tLbl.Size = UDim2.new(1, 0, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Font = Enum.Font.GothamBold
                tLbl.TextSize = 10.5
                tLbl.TextColor3 = self.Theme.TextTitle
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.TextWrapped = true
                tLbl.AutomaticSize = Enum.AutomaticSize.Y
                tLbl.Text = title

                if subtitle and subtitle ~= "" then
                    local sLbl = Instance.new("TextLabel", row)
                    sLbl.Size = UDim2.new(1, 0, 0, 0)
                    sLbl.BackgroundTransparency = 1
                    sLbl.Font = Enum.Font.Gotham
                    sLbl.TextSize = 8.5
                    sLbl.TextColor3 = self.Theme.TextDim
                    sLbl.TextXAlignment = Enum.TextXAlignment.Left
                    sLbl.TextWrapped = true
                    sLbl.AutomaticSize = Enum.AutomaticSize.Y
                    sLbl.Text = subtitle
                end

                local ic = Instance.new("ImageLabel", row)
                ic.Size = UDim2.new(0, 14, 0, 14)
                ic.AnchorPoint = Vector2.new(1, 0.5)
                ic.Position = UDim2.new(1, 22, 0.5, 0)
                ic.BackgroundTransparency = 1
                ic.Image = iconAsset or self.Icons.Copy
                ic.ImageColor3 = self.Theme.AccentLight
                self:_RegisterElement("Accents", ic)

                row.MouseButton1Click:Connect(function()
                    self:_PlaySound("Click")
                    MicroBounce(row)
                    pcall(callback)
                end)
                return row
            end

            BoxObj.AddDangerButton = function(self_, title, subtitle, iconAsset, callback)
                local btn = Instance.new("TextButton", Container)
                btn.Size = UDim2.new(1, 0, 0, 0)
                btn.AutomaticSize = Enum.AutomaticSize.Y
                btn.BackgroundColor3 = self.Theme.Danger
                btn.Text = ""
                btn.AutoButtonColor = false
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

                local bPad = Instance.new("UIPadding", btn)
                bPad.PaddingLeft = UDim.new(0, 32)
                bPad.PaddingRight = UDim.new(0, 10)
                bPad.PaddingTop = UDim.new(0, 7)
                bPad.PaddingBottom = UDim.new(0, 7)

                local bLayout = Instance.new("UIListLayout", btn)
                bLayout.SortOrder = Enum.SortOrder.LayoutOrder
                bLayout.Padding = UDim.new(0, 2)

                local ic = Instance.new("ImageLabel", btn)
                ic.Size = UDim2.new(0, 14, 0, 14)
                ic.AnchorPoint = Vector2.new(0, 0.5)
                ic.Position = UDim2.new(0, -22, 0.5, 0)
                ic.BackgroundTransparency = 1
                ic.Image = iconAsset or self.Icons.Skull
                ic.ImageColor3 = Color3.fromRGB(255, 255, 255)

                local tLbl = Instance.new("TextLabel", btn)
                tLbl.Size = UDim2.new(1, 0, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Font = Enum.Font.GothamBold
                tLbl.TextSize = 10
                tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.TextWrapped = true
                tLbl.AutomaticSize = Enum.AutomaticSize.Y
                tLbl.Text = title

                if subtitle and subtitle ~= "" then
                    local sLbl = Instance.new("TextLabel", btn)
                    sLbl.Size = UDim2.new(1, 0, 0, 0)
                    sLbl.BackgroundTransparency = 1
                    sLbl.Font = Enum.Font.Gotham
                    sLbl.TextSize = 8.5
                    sLbl.TextColor3 = Color3.fromRGB(255, 220, 220)
                    sLbl.TextXAlignment = Enum.TextXAlignment.Left
                    sLbl.TextWrapped = true
                    sLbl.AutomaticSize = Enum.AutomaticSize.Y
                    sLbl.Text = subtitle
                end

                btn.MouseButton1Click:Connect(function()
                    self:_PlaySound("Click")
                    MicroBounce(btn)
                    pcall(callback)
                end)
                return btn
            end

            return BoxObj
        end

        return TabObj
    end

    WindowObj.Destroy = function(self_)
        for _, conn in ipairs(self.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        self.Connections = {}
        pcall(function() ScreenGui:Destroy() end)
        self.MainWindow = nil
        self.FloatingSquircle = nil
        self.Tabs = {}
        self.ActiveTab = nil
    end

    self.MainWindow = MainWindow
    self.ScreenGui = ScreenGui
    self.WindowObj = WindowObj

    self:_UpdateLiveTheme()

    return WindowObj
end

pcall(function()
    if getgenv then
        getgenv().LiquidGlass = LiquidGlass
    end
    _G.LiquidGlass = LiquidGlass
end)

return LiquidGlass
