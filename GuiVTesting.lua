--[[
    LiquidGlass UI Library v1.0
    Phong cách: iOS 26 Liquid Glass + Smooth Animations
    Tác giả: Custom Library
    Sử dụng: local UI = loadstring(...)()
]]

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    
    -- Colors
    Glass = Color3.fromRGB(28, 28, 32),
    GlassLight = Color3.fromRGB(45, 45, 52),
    GlassBorder = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(245, 245, 250),
    TextDim = Color3.fromRGB(160, 160, 175),
    Accent = Color3.fromRGB(120, 140, 255),
    Accent2 = Color3.fromRGB(180, 120, 255),
    Success = Color3.fromRGB(80, 220, 140),
    Danger = Color3.fromRGB(255, 90, 90),
    Warning = Color3.fromRGB(255, 190, 80),
    
    -- Sizes
    CornerRadius = UDim.new(0, 16),
    CornerSmall = UDim.new(0, 10),
    CornerPill = UDim.new(1, 0),
    
    -- Animation
    AnimFast = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    AnimNormal = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    AnimSlow = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    AnimSpring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function Tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function Round(num, places)
    local mult = 10 ^ (places or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- ============================================================
-- BLUR / GLASS EFFECT
-- ============================================================
local function CreateBlur(parent, size)
    local blur = Create("ImageLabel", {
        Name = "GlassBlur",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857472", -- blur texture
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(50, 50, 50, 50),
        Parent = parent,
    })
    return blur
end

local function CreateGlassFrame(parent, props)
    props = props or {}
    local frame = Create("Frame", {
        Name = props.Name or "GlassFrame",
        Size = props.Size or UDim2.fromScale(1, 1),
        Position = props.Position or UDim2.fromScale(0, 0),
        BackgroundColor3 = props.Color or Config.Glass,
        BackgroundTransparency = props.Transparency or 0.25,
        BorderSizePixel = 0,
        Parent = parent,
    })
    
    local corner = Create("UICorner", {
        CornerRadius = props.Corner or Config.CornerRadius,
        Parent = frame,
    })
    
    -- Glass highlight (top gradient)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(0.5, 0.88),
            NumberSequenceKeypoint.new(1, 0.92),
        }),
        Rotation = 90,
        Parent = frame,
    })
    
    -- Border stroke
    local stroke = Create("UIStroke", {
        Color = Config.GlassBorder,
        Thickness = 1,
        Transparency = props.StrokeTransparency or 0.75,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = frame,
    })
    
    -- Inner highlight
    local innerStroke = Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Transparency = 0.92,
        Parent = frame,
    })
    
    -- Inner shadow frame
    local shadow = Create("Frame", {
        Name = "InnerShadow",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = frame,
    })
    Create("UICorner", { CornerRadius = props.Corner or Config.CornerRadius, Parent = shadow })
    
    return frame, corner, stroke
end

-- ============================================================
-- MAIN WINDOW CLASS
-- ============================================================
function LiquidGlass.new(options)
    options = options or {}
    local self = setmetatable({}, LiquidGlass)
    
    self.Options = options
    self.Tabs = {}
    self.CurrentTab = nil
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    self.Minimized = false
    self.Dragging = false
    self.Connections = {}
    self.Notifications = {}
    
    self:CreateScreenGui()
    self:CreateWindow()
    self:BindToggle()
    
    return self
end

function LiquidGlass:CreateScreenGui()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    
    local parent = gethui and gethui() or CoreGui
    local ok = pcall(function()
        self.ScreenGui = Create("ScreenGui", {
            Name = "LiquidGlassUI_" .. math.random(100000, 999999),
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 9999,
            Parent = parent,
        })
    end)
    if not ok or not self.ScreenGui then
        self.ScreenGui = Create("ScreenGui", {
            Name = "LiquidGlassUI",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 9999,
            Parent = LP:WaitForChild("PlayerGui"),
        })
    end
    
    -- Background blur overlay when window visible
    self.BlurOverlay = Create("Frame", {
        Name = "BlurOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = self.ScreenGui,
    })
    
    self.NotifyHolder = Create("Frame", {
        Name = "NotifyHolder",
        Size = UDim2.new(0, 340, 1, -40),
        Position = UDim2.new(1, -360, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 500,
        Parent = self.ScreenGui,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = self.NotifyHolder,
    })
end

function LiquidGlass:CreateWindow()
    local opts = self.Options
    
    -- Main container
    self.Container = Create("Frame", {
        Name = "Container",
        Size = opts.Size or UDim2.fromOffset(720, 500),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = self.ScreenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = self.Container })
    
    -- Glass effect layers
    local glassGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 55, 65)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 38)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 26)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(0.5, 0.82),
            NumberSequenceKeypoint.new(1, 0.88),
        }),
        Rotation = 120,
        Parent = self.Container,
    })
    
    local containerStroke = Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.2,
        Transparency = 0.65,
        Parent = self.Container,
    })
    
    local innerStroke = Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Transparency = 0.9,
        Parent = self.Container,
    })
    
    -- Inner shadow
    local innerShadow = Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = self.Container,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = innerShadow })
    
    -- Drop shadow (behind window)
    self.DropShadow = Create("Frame", {
        Name = "DropShadow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, 8),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 9,
        Parent = self.ScreenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 28), Parent = self.DropShadow })
    
    -- ===== TOP BAR =====
    self.TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = self.Container,
    })
    
    -- Traffic light buttons (macOS style) or iOS style window buttons
    local btnHolder = Create("Frame", {
        Name = "BtnHolder",
        Size = UDim2.fromOffset(90, 52),
        BackgroundTransparency = 1,
        Parent = self.TopBar,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = btnHolder,
    })
    
    local function createWindowBtn(color, hoverColor, callback)
        local btn = Create("TextButton", {
            Size = UDim2.fromOffset(12, 12),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = btnHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
        Create("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1, Transparency = 0.85, Parent = btn })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, Config.AnimFast, { BackgroundColor3 = hoverColor, Size = UDim2.fromOffset(14, 14) })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, Config.AnimFast, { BackgroundColor3 = color, Size = UDim2.fromOffset(12, 12) })
        end)
        btn.MouseButton1Click:Connect(callback or function() end)
        return btn
    end
    
    createWindowBtn(Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 120, 115), function()
        self:Toggle()
    end)
    createWindowBtn(Color3.fromRGB(255, 189, 46), Color3.fromRGB(255, 210, 90), function()
        self:Minimize()
    end)
    createWindowBtn(Color3.fromRGB(39, 201, 63), Color3.fromRGB(70, 220, 90), function() end)
    
    -- Title
    local titleHolder = Create("Frame", {
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.fromOffset(100, 0),
        BackgroundTransparency = 1,
        Parent = self.TopBar,
    })
    
    self.TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = opts.Title or "LiquidGlass",
        TextColor3 = Config.Text,
        Font = Config.FontBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleHolder,
    })
    
    self.SubTitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = opts.SubTitle or "v1.0",
        TextColor3 = Config.TextDim,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleHolder,
    })
    
    -- Drag support
    self:MakeDraggable(self.TopBar, self.Container)
    self:MakeDraggable(self.TopBar, self.DropShadow)
    
    -- ===== SIDEBAR =====
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, -64),
        Position = UDim2.fromOffset(6, 58),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 15,
        Parent = self.Container,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = self.Sidebar })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.88, Parent = self.Sidebar })
    
    -- Nav header container
    self.NavHolder = Create("ScrollingFrame", {
        Name = "NavHolder",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Config.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = self.NavHolder,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.NavHolder,
    })
    
    -- ===== CONTENT AREA =====
    self.Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -200, 1, -64),
        Position = UDim2.fromOffset(194, 58),
        BackgroundTransparency = 1,
        ZIndex = 15,
        Parent = self.Container,
    })
    
    -- Initial fade in animation
    self.Container.BackgroundTransparency = 1
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    self.DropShadow.BackgroundTransparency = 1
    self.DropShadow.Size = UDim2.new(0, 0, 0, 0)
    
    task.spawn(function()
        Tween(self.Container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = opts.Size or UDim2.fromOffset(720, 500),
            BackgroundTransparency = 0.15,
        })
        Tween(self.DropShadow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 20, 1, 20),
            BackgroundTransparency = 0.55,
        })
    end)
end

function LiquidGlass:MakeDraggable(handle, target)
    local dragging, dragStart, startPos
    local conn
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            target.Position = newPos
            if target == self.Container and self.DropShadow then
                self.DropShadow.Position = UDim2.new(
                    newPos.X.Scale, newPos.X.Offset - 10,
                    newPos.Y.Scale, newPos.Y.Offset + 8
                )
            end
        end
    end)
end

function LiquidGlass:BindToggle()
    local conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)
    table.insert(self.Connections, conn)
end

function LiquidGlass:Toggle()
    self.Minimized = not self.Minimized
    local targetSize = self.Minimized and UDim2.fromOffset(220, 56) or (self.Options.Size or UDim2.fromOffset(720, 500))
    local targetTrans = self.Minimized and 0.5 or 0.15
    
    Tween(self.Container, Config.AnimNormal, {
        Size = targetSize,
        BackgroundTransparency = targetTrans,
    })
    
    if self.Minimized then
        self.Sidebar.Visible = false
        self.Content.Visible = false
    else
        task.wait(0.1)
        self.Sidebar.Visible = true
        self.Content.Visible = true
    end
end

function LiquidGlass:Minimize()
    self.Minimized = true
    Tween(self.Container, Config.AnimNormal, {
        Size = UDim2.fromOffset(220, 56),
        BackgroundTransparency = 0.5,
    })
    self.Sidebar.Visible = false
    self.Content.Visible = false
end

-- ============================================================
-- NAV HEADER
-- ============================================================
function LiquidGlass:AddNavHeader(text, order)
    local header = Create("TextLabel", {
        Size = UDim2.new(1, -8, 0, 28),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        TextColor3 = Config.TextDim,
        Font = Config.FontBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order or (#self.NavHolder:GetChildren()),
        Parent = self.NavHolder,
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        Parent = header,
    })
    return header
end

-- ============================================================
-- TAB
-- ============================================================
function LiquidGlass:CreateTab(options)
    options = options or {}
    local tabData = {
        Title = options.Title or "Tab",
        Icon = options.Icon or "◆",
        LayoutOrder = options.LayoutOrder or (#self.Tabs + 1),
        Groups = {},
    }
    
    -- Tab button
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = tabData.LayoutOrder,
        Parent = self.NavHolder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })
    
    local icon = Create("TextLabel", {
        Size = UDim2.fromOffset(28, 40),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = tabData.Icon,
        TextColor3 = Config.TextDim,
        Font = Config.FontBold,
        TextSize = 15,
        Parent = btn,
    })
    
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.fromOffset(42, 0),
        BackgroundTransparency = 1,
        Text = tabData.Title,
        TextColor3 = Config.TextDim,
        Font = Config.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    
    -- Active indicator
    local indicator = Create("Frame", {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Accent,
        BorderSizePixel = 0,
        Parent = btn,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = indicator })
    
    -- Tab content container
    local content = Create("Frame", {
        Name = "Tab_" .. tabData.Title,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 15,
        Parent = self.Content,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = content,
    })
    
    tabData.Button = btn
    tabData.Label = label
    tabData.Icon = icon
    tabData.Indicator = indicator
    tabData.Content = content
    
    -- Hover
    btn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabData then
            Tween(btn, Config.AnimFast, { BackgroundTransparency = 0.9 })
            Tween(label, Config.AnimFast, { TextColor3 = Config.Text })
            Tween(icon, Config.AnimFast, { TextColor3 = Config.Text })
        end
    end)
    btn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabData then
            Tween(btn, Config.AnimFast, { BackgroundTransparency = 1 })
            Tween(label, Config.AnimFast, { TextColor3 = Config.TextDim })
            Tween(icon, Config.AnimFast, { TextColor3 = Config.TextDim })
        end
    end)
    
    -- Click
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)
    
    table.insert(self.Tabs, tabData)
    
    -- Auto-select first tab
    if not self.CurrentTab then
        self:SelectTab(tabData)
    end
    
    -- Tab object
    local tabObj = {}
    
    function tabObj:CreateGroupBox(side, title, subtitle, icon)
        return self:AddGroupBox(tabData, side, title, subtitle, icon)
    end
    
    function tabObj:AddSection(title)
        return self:AddSection(tabData, title)
    end
    
    -- Bind methods
    setmetatable(tabObj, {
        __index = function(t, k)
            if k == "AddGroupBox" then
                return function(_, side, title, subtitle, icon)
                    return LiquidGlass.AddGroupBox(self, tabData, side, title, subtitle, icon)
                end
            elseif k == "AddSection" then
                return function(_, title)
                    return LiquidGlass.AddSection(self, tabData, title)
                end
            end
            return nil
        end
    })
    
    tabData.Object = tabObj
    return tabObj
end

function LiquidGlass:SelectTab(tabData)
    if self.CurrentTab == tabData then return end
    
    -- Deactivate old
    if self.CurrentTab then
        local old = self.CurrentTab
        Tween(old.Button, Config.AnimFast, { BackgroundTransparency = 1 })
        Tween(old.Label, Config.AnimFast, { TextColor3 = Config.TextDim })
        Tween(old.Icon, Config.AnimFast, { TextColor3 = Config.TextDim })
        Tween(old.Indicator, Config.AnimFast, { Size = UDim2.new(0, 3, 0, 0) })
        old.Content.Visible = false
    end
    
    -- Activate new
    self.CurrentTab = tabData
    tabData.Content.Visible = true
    
    Tween(tabData.Button, Config.AnimFast, { BackgroundTransparency = 0.85 })
    Tween(tabData.Label, Config.AnimFast, { TextColor3 = Config.Text })
    Tween(tabData.Icon, Config.AnimFast, { TextColor3 = Config.Accent })
    Tween(tabData.Indicator, Config.AnimFast, { Size = UDim2.new(0, 3, 0, 22) })
    
    -- Slide-in animation for content
    tabData.Content.Position = UDim2.fromOffset(20, 0)
    Tween(tabData.Content, Config.AnimNormal, { Position = UDim2.fromOffset(0, 0) })
end

-- ============================================================
-- GROUP BOX
-- ============================================================
function LiquidGlass:AddGroupBox(tabData, side, title, subtitle, icon)
    local container = Create("Frame", {
        Size = side == "Left" and UDim2.new(0.5, -6, 1, 0) or UDim2.new(0.5, -6, 1, 0),
        Position = side == "Left" and UDim2.fromOffset(0, 0) or UDim2.new(0.5, 6, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = #tabData.Groups + 1,
        Parent = tabData.Content,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container,
    })
    
    -- Header
    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(35, 35, 44),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = container,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = header })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.88, Parent = header })
    
    local headerIcon = Create("TextLabel", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(10, 8),
        BackgroundColor3 = Config.Accent,
        BackgroundTransparency = 0.8,
        Text = icon or "◆",
        TextColor3 = Config.Accent,
        Font = Config.FontBold,
        TextSize = 14,
        Parent = header,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = headerIcon })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 18),
        Position = UDim2.fromOffset(46, 5),
        BackgroundTransparency = 1,
        Text = title or "Group",
        TextColor3 = Config.Text,
        Font = Config.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 14),
        Position = UDim2.fromOffset(46, 23),
        BackgroundTransparency = 1,
        Text = subtitle or "",
        TextColor3 = Config.TextDim,
        Font = Config.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    
    -- Items container
    local items = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -52),
        Position = UDim2.fromOffset(0, 52),
        BackgroundTransparency = 1,
        Parent = container,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = items,
    })
    
    local groupData = {
        Container = container,
        Header = header,
        Items = items,
        Parent = tabData,
    }
    
    table.insert(tabData.Groups, groupData)
    
    -- Group object with methods
    local groupObj = {}
    
    function groupObj:AddToggle(title, desc, default, callback)
        return LiquidGlass.AddToggle(self, groupData, title, desc, default, callback)
    end
    
    function groupObj:AddSlider(title, min, max, default, suffix, callback)
        return LiquidGlass.AddSlider(self, groupData, title, min, max, default, suffix, callback)
    end
    
    function groupObj:AddDropdown(title, options, default, callback)
        return LiquidGlass.AddDropdown(self, groupData, title, options, default, callback)
    end
    
    function groupObj:AddInput(title, placeholder, default, callback)
        return LiquidGlass.AddInput(self, groupData, title, placeholder, default, callback)
    end
    
    function groupObj:AddButton(title, desc, callback)
        return LiquidGlass.AddButton(self, groupData, title, desc, callback)
    end
    
    function groupObj:AddActionRow(title, desc, icon, callback)
        return LiquidGlass.AddActionRow(self, groupData, title, desc, icon, callback)
    end
    
    function groupObj:AddColorPicker(title, default, callback)
        return LiquidGlass.AddColorPicker(self, groupData, title, default, callback)
    end
    
    function groupObj:AddModeSelector(title, options, default, callback)
        return LiquidGlass.AddModeSelector(self, groupData, title, options, default, callback)
    end
    
    function groupObj:AddParagraph(title, text)
        return LiquidGlass.AddParagraph(self, groupData, title, text)
    end
    
    function groupObj:AddDangerButton(title, desc, icon, callback)
        return LiquidGlass.AddDangerButton(self, groupData, title, desc, icon, callback)
    end
    
    groupData.Object = groupObj
    return groupObj
end

function LiquidGlass:AddSection(tabData, title)
    -- Simple section header
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = #tabData.Groups + 1,
        Parent = tabData.Content,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = string.upper(title),
        TextColor3 = Config.TextDim,
        Font = Config.FontBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local sectionData = {Container = container, Parent = tabData, Items = container}
    table.insert(tabData.Groups, sectionData)
    
    local sectionObj = {}
    function sectionObj:AddToggle(title, desc, default, callback)
        return LiquidGlass.AddToggle(self, sectionData, title, desc, default, callback)
    end
    function sectionObj:AddSlider(title, min, max, default, suffix, callback)
        return LiquidGlass.AddSlider(self, sectionData, title, min, max, default, suffix, callback)
    end
    function sectionObj:AddDropdown(title, options, default, callback)
        return LiquidGlass.AddDropdown(self, sectionData, title, options, default, callback)
    end
    function sectionObj:AddInput(title, placeholder, default, callback)
        return LiquidGlass.AddInput(self, sectionData, title, placeholder, default, callback)
    end
    function sectionObj:AddButton(title, desc, callback)
        return LiquidGlass.AddButton(self, sectionData, title, desc, callback)
    end
    function sectionObj:AddActionRow(title, desc, icon, callback)
        return LiquidGlass.AddActionRow(self, sectionData, title, desc, icon, callback)
    end
    function sectionObj:AddParagraph(title, text)
        return LiquidGlass.AddParagraph(self, sectionData, title, text)
    end
    function sectionObj:AddDangerButton(title, desc, icon, callback)
        return LiquidGlass.AddDangerButton(self, sectionData, title, desc, icon, callback)
    end
    
    sectionData.Object = sectionObj
    return sectionObj
end

-- ============================================================
-- COMPONENTS
-- ============================================================

-- TOGGLE
function LiquidGlass:AddToggle(groupObj, groupData, title, desc, default, callback)
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 18),
        Position = UDim2.fromOffset(12, 4),
        BackgroundTransparency = 1,
        Text = title or "Toggle",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    if desc and desc ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(1, -70, 0, 14),
            Position = UDim2.fromOffset(12, 22),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.TextDim,
            Font = Config.Font,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = item,
        })
    end
    
    -- Switch track
    local track = Create("Frame", {
        Size = UDim2.fromOffset(42, 24),
        Position = UDim2.new(1, -54, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    
    -- Switch knob
    local knob = Create("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    
    local state = default or false
    
    local function updateVisual(animate)
        local info = animate and Config.AnimSpring or TweenInfo.new(0)
        if state then
            Tween(track, info, { BackgroundColor3 = Config.Accent })
            Tween(knob, info, { Position = UDim2.fromOffset(20, 2) })
        else
            Tween(track, info, { BackgroundColor3 = Color3.fromRGB(60, 60, 70) })
            Tween(knob, info, { Position = UDim2.fromOffset(2, 2) })
        end
    end
    
    updateVisual(false)
    
    local btn = Create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = item,
    })
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual(true)
        if callback then
            pcall(callback, state)
        end
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.4 })
    end)
    btn.MouseLeave:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.5 })
    end)
    
    local obj = {Item = item, State = state}
    function obj:Set(v)
        state = v
        updateVisual(true)
    end
    function obj:Get() return state end
    return obj
end

-- SLIDER
function LiquidGlass:AddSlider(groupObj, groupData, title, min, max, default, suffix, callback)
    min = min or 0
    max = max or 100
    default = default or min
    suffix = suffix or ""
    
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 16),
        Position = UDim2.fromOffset(12, 6),
        BackgroundTransparency = 1,
        Text = title or "Slider",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    local valueLbl = Create("TextLabel", {
        Size = UDim2.new(0.3, -24, 0, 16),
        Position = UDim2.new(0.7, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default) .. " " .. suffix,
        TextColor3 = Config.Accent,
        Font = Config.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = item,
    })
    
    local track = Create("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.fromOffset(12, 34),
        BackgroundColor3 = Color3.fromRGB(55, 55, 65),
        BorderSizePixel = 0,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    
    local fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Config.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    
    local knob = Create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    Create("UIStroke", { Color = Config.Accent, Thickness = 2, Parent = knob })
    
    local value = default
    local dragging = false
    
    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local newVal = math.floor(min + (max - min) * relX)
        value = newVal
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -8, 0.5, -8)
        valueLbl.Text = tostring(value) .. " " .. suffix
        if callback then pcall(callback, value) end
    end
    
    local btn = Create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = item,
    })
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
            Tween(knob, Config.AnimFast, { Size = UDim2.fromOffset(20, 20) })
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(knob, Config.AnimFast, { Size = UDim2.fromOffset(16, 16) })
        end
    end)
    
    -- Hover
    btn.MouseEnter:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.4 })
    end)
    btn.MouseLeave:Connect(function()
        if not dragging then
            Tween(item, Config.AnimFast, { BackgroundTransparency = 0.5 })
        end
    end)
    
    local obj = {}
    function obj:Set(v)
        value = math.clamp(v, min, max)
        local relX = (value - min) / (max - min)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -8, 0.5, -8)
        valueLbl.Text = tostring(value) .. " " .. suffix
    end
    function obj:Get() return value end
    return obj
end

-- DROPDOWN
function LiquidGlass:AddDropdown(groupObj, groupData, title, options, default, callback)
    options = options or {}
    default = default or (options[1] or "")
    
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(0.5, -12, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = title or "Dropdown",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    local valueLbl = Create("TextLabel", {
        Size = UDim2.new(0.5, -30, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default) .. "  ▾",
        TextColor3 = Config.Accent,
        Font = Config.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = item,
    })
    
    local listHolder = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 0),
        Position = UDim2.fromOffset(4, 42),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = listHolder })
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = listHolder,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = listHolder,
    })
    
    local isOpen = false
    local value = default
    
    local function closeList()
        if not isOpen then return end
        isOpen = false
        local targetSize = 0
        Tween(listHolder, Config.AnimFast, { Size = UDim2.new(1, -8, 0, 0) })
        Tween(item, Config.AnimFast, { Size = UDim2.new(1, 0, 0, 42) })
    end
    
    local optionButtons = {}
    for i, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Config.Accent,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            Parent = listHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = optBtn })
        
        local optLbl = Create("TextLabel", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            Text = tostring(opt),
            TextColor3 = Config.Text,
            Font = Config.Font,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = optBtn,
        })
        
        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, Config.AnimFast, { BackgroundTransparency = 0.85 })
        end)
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, Config.AnimFast, { BackgroundTransparency = 1 })
        end)
        optBtn.MouseButton1Click:Connect(function()
            value = opt
            valueLbl.Text = tostring(value) .. "  ▾"
            closeList()
            if callback then pcall(callback, value) end
        end)
        
        table.insert(optionButtons, optBtn)
    end
    
    local openBtn = Create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = item,
    })
    
    openBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local h = 8 + #options * 30
            Tween(listHolder, Config.AnimFast, { Size = UDim2.new(1, -8, 0, h) })
            Tween(item, Config.AnimFast, { Size = UDim2.new(1, 0, 0, 42 + h) })
        else
            closeList()
        end
    end)
    
    openBtn.MouseEnter:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.4 })
    end)
    openBtn.MouseLeave:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.5 })
    end)
    
    local obj = {}
    function obj:Set(v)
        value = v
        valueLbl.Text = tostring(v) .. "  ▾"
    end
    function obj:Get() return value end
    return obj
end

-- INPUT
function LiquidGlass:AddInput(groupObj, groupData, title, placeholder, default, callback)
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    Create("TextLabel", {
        Size = UDim2.new(0.4, -12, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = title or "Input",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    local box = Create("Frame", {
        Size = UDim2.new(0.6, -12, 0, 26),
        Position = UDim2.new(0.4, 0, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = box })
    
    local input = Create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = default or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = Config.TextDim,
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = box,
    })
    
    input.Focused:Connect(function()
        Tween(box, Config.AnimFast, { BackgroundColor3 = Color3.fromRGB(25, 25, 35) })
        Create("UIStroke", { Color = Config.Accent, Thickness = 1, Parent = box, Name = "FocusStroke" })
    end)
    input.FocusLost:Connect(function()
        Tween(box, Config.AnimFast, { BackgroundColor3 = Color3.fromRGB(18, 18, 24) })
        local s = box:FindFirstChild("FocusStroke")
        if s then s:Destroy() end
        if callback then pcall(callback, input.Text) end
    end)
    
    local obj = {}
    function obj:Set(v) input.Text = v end
    function obj:Get() return input.Text end
    return obj
end

-- BUTTON
function LiquidGlass:AddButton(groupObj, groupData, title, desc, callback)
    local item = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, desc and desc ~= "" and 44 or 34),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -12, 0, desc and desc ~= "" and 18 or 34),
        Position = UDim2.fromOffset(12, desc and desc ~= "" and 4 or 0),
        BackgroundTransparency = 1,
        Text = title or "Button",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    if desc and desc ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(1, -12, 0, 14),
            Position = UDim2.fromOffset(12, 22),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.TextDim,
            Font = Config.Font,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = item,
        })
    end
    
    item.MouseEnter:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(40, 40, 50) })
    end)
    item.MouseLeave:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(30, 30, 38) })
    end)
    item.MouseButton1Click:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundColor3 = Config.Accent })
        task.wait(0.1)
        Tween(item, Config.AnimFast, { BackgroundColor3 = Color3.fromRGB(40, 40, 50) })
        if callback then pcall(callback) end
    end)
    
    return {Item = item}
end

-- ACTION ROW (with icon on right)
function LiquidGlass:AddActionRow(groupObj, groupData, title, desc, icon, callback)
    local item = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    local iconBox = Create("Frame", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -42, 0.5, -15),
        BackgroundColor3 = Config.Accent,
        BackgroundTransparency = 0.8,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = iconBox })
    
    Create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = tostring(icon) or "▶",
        TextColor3 = Config.Accent,
        Font = Config.FontBold,
        TextSize = 14,
        Parent = iconBox,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        Position = UDim2.fromOffset(12, 4),
        BackgroundTransparency = 1,
        Text = title or "Action",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    if desc and desc ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 14),
            Position = UDim2.fromOffset(12, 23),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.TextDim,
            Font = Config.Font,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = item,
        })
    end
    
    item.MouseEnter:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.3 })
        Tween(iconBox, Config.AnimFast, { BackgroundTransparency = 0.6 })
    end)
    item.MouseLeave:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.5 })
        Tween(iconBox, Config.AnimFast, { BackgroundTransparency = 0.8 })
    end)
    item.MouseButton1Click:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundColor3 = Config.Accent })
        task.wait(0.1)
        Tween(item, Config.AnimFast, { BackgroundColor3 = Color3.fromRGB(30, 30, 38) })
        if callback then pcall(callback) end
    end)
    
    return {Item = item}
end

-- DANGER BUTTON
function LiquidGlass:AddDangerButton(groupObj, groupData, title, desc, icon, callback)
    local item = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(60, 25, 30),
        BackgroundTransparency = 0.5,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Config.Danger, Thickness = 1, Transparency = 0.6, Parent = item })
    
    local iconBox = Create("Frame", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -42, 0.5, -15),
        BackgroundColor3 = Config.Danger,
        BackgroundTransparency = 0.7,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = iconBox })
    
    Create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = tostring(icon) or "!",
        TextColor3 = Config.Danger,
        Font = Config.FontBold,
        TextSize = 16,
        Parent = iconBox,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        Position = UDim2.fromOffset(12, 4),
        BackgroundTransparency = 1,
        Text = title or "Danger",
        TextColor3 = Config.Danger,
        Font = Config.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    if desc and desc ~= "" then
        Create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 14),
            Position = UDim2.fromOffset(12, 23),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Config.TextDim,
            Font = Config.Font,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = item,
        })
    end
    
    item.MouseEnter:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(80, 30, 35) })
    end)
    item.MouseLeave:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(60, 25, 30) })
    end)
    item.MouseButton1Click:Connect(function()
        Tween(item, Config.AnimFast, { BackgroundColor3 = Config.Danger })
        task.wait(0.15)
        Tween(item, Config.AnimFast, { BackgroundColor3 = Color3.fromRGB(80, 30, 35) })
        if callback then pcall(callback) end
    end)
    
    return {Item = item}
end

-- COLOR PICKER
function LiquidGlass:AddColorPicker(groupObj, groupData, title, default, callback)
    default = default or Color3.fromRGB(120, 140, 255)
    
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 18),
        Position = UDim2.fromOffset(12, 4),
        BackgroundTransparency = 1,
        Text = title or "Color",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    local preview = Create("Frame", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -42, 0.5, -15),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = preview })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.7, Parent = preview })
    
    -- Color picker panel
    local panel = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 0),
        Position = UDim2.fromOffset(4, 44),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = panel })
    
    -- Hue slider
    local hueTrack = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 14),
        Position = UDim2.fromOffset(10, 10),
        BorderSizePixel = 0,
        Parent = panel,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueTrack })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueTrack,
    })
    
    local h, s, v = default:ToHSV()
    local knob = Create("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(h, -9, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = hueTrack,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    Create("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 2, Transparency = 0.5, Parent = knob })
    
    local isOpen = false
    local dragging = false
    
    local function updateHue(input)
        local relX = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
        h = relX
        knob.Position = UDim2.new(relX, -9, 0.5, -9)
        local c = Color3.fromHSV(h, math.max(s, 0.7), v)
        preview.BackgroundColor3 = c
        if callback then pcall(callback, c) end
    end
    
    local hBtn = Create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = hueTrack,
    })
    hBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateHue(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateHue(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Preset colors
    local presets = {
        Color3.fromRGB(120, 140, 255),
        Color3.fromRGB(255, 90, 90),
        Color3.fromRGB(80, 220, 140),
        Color3.fromRGB(255, 190, 80),
        Color3.fromRGB(180, 120, 255),
        Color3.fromRGB(255, 120, 200),
        Color3.fromRGB(80, 220, 255),
        Color3.fromRGB(255, 255, 255),
    }
    
    local presetHolder = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.fromOffset(10, 32),
        BackgroundTransparency = 1,
        Parent = panel,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = presetHolder,
    })
    
    for i, pc in ipairs(presets) do
        local pb = Create("TextButton", {
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = pc,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            Parent = presetHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pb })
        Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.7, Parent = pb })
        
        pb.MouseEnter:Connect(function()
            Tween(pb, Config.AnimFast, { Size = UDim2.fromOffset(24, 24) })
        end)
        pb.MouseLeave:Connect(function()
            Tween(pb, Config.AnimFast, { Size = UDim2.fromOffset(20, 20) })
        end)
        pb.MouseButton1Click:Connect(function()
            h, s, v = pc:ToHSV()
            knob.Position = UDim2.new(h, -9, 0.5, -9)
            preview.BackgroundColor3 = pc
            if callback then pcall(callback, pc) end
        end)
    end
    
    local toggleBtn = Create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = item,
    })
    
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Tween(panel, Config.AnimFast, { Size = UDim2.new(1, -8, 0, 68) })
            Tween(item, Config.AnimFast, { Size = UDim2.new(1, 0, 0, 116) })
        else
            Tween(panel, Config.AnimFast, { Size = UDim2.new(1, -8, 0, 0) })
            Tween(item, Config.AnimFast, { Size = UDim2.new(1, 0, 0, 44) })
        end
    end)
    
    local obj = {}
    function obj:Set(c)
        preview.BackgroundColor3 = c
        h, s, v = c:ToHSV()
        knob.Position = UDim2.new(h, -9, 0.5, -9)
    end
    return obj
end

-- MODE SELECTOR
function LiquidGlass:AddModeSelector(groupObj, groupData, title, modes, default, callback)
    modes = modes or {}
    default = default or modes[1]
    
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -12, 0, 16),
        Position = UDim2.fromOffset(12, 6),
        BackgroundTransparency = 1,
        Text = title or "Mode",
        TextColor3 = Config.Text,
        Font = Config.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    local segHolder = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.fromOffset(10, 24),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        Parent = item,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = segHolder })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = segHolder,
    })
    
    local indicator = Create("Frame", {
        Size = UDim2.new(1/#modes, 0, 1, 0),
        BackgroundColor3 = Config.Accent,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = segHolder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = indicator })
    
    local buttons = {}
    for i, mode in ipairs(modes) do
        local btn = Create("TextButton", {
            Size = UDim2.new(1/#modes, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(mode),
            TextColor3 = (mode == default) and Color3.fromRGB(255,255,255) or Config.TextDim,
            Font = Config.Font,
            TextSize = 10,
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 2,
            Parent = segHolder,
        })
        
        btn.MouseButton1Click:Connect(function()
            Tween(indicator, Config.AnimSpring, { Position = UDim2.new((i-1)/#modes, 0, 0, 0) })
            for _, b in ipairs(buttons) do
                Tween(b, Config.AnimFast, { TextColor3 = Config.TextDim })
            end
            Tween(btn, Config.AnimFast, { TextColor3 = Color3.fromRGB(255,255,255) })
            if callback then pcall(callback, mode) end
        end)
        
        table.insert(buttons, btn)
    end
    
    -- Set initial indicator position
    for i, mode in ipairs(modes) do
        if mode == default then
            indicator.Position = UDim2.new((i-1)/#modes, 0, 0, 0)
        end
    end
    
    return {Item = item}
end

-- PARAGRAPH
function LiquidGlass:AddParagraph(groupObj, groupData, title, text)
    local item = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = #groupData.Items:GetChildren() + 1,
        Parent = groupData.Items,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = item })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9, Parent = item })
    
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.fromOffset(10, 6),
        BackgroundTransparency = 1,
        Text = title or "Info",
        TextColor3 = Config.Accent,
        Font = Config.FontBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = item,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.fromOffset(10, 22),
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = Config.TextDim,
        Font = Config.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = item,
    })
    
    local obj = {Item = item}
    function obj:SetTitle(t) titleLbl.Text = t end
    function obj:SetText(t)
        for _, c in ipairs(item:GetChildren()) do
            if c:IsA("TextLabel") and c ~= titleLbl then
                c.Text = t
            end
        end
    end
    return obj
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
function LiquidGlass:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 4
    local ntype = options.Type or "info"
    
    local accentColor = Config.Accent
    if ntype == "success" then accentColor = Config.Success
    elseif ntype == "error" then accentColor = Config.Danger
    elseif ntype == "warning" then accentColor = Config.Warning end
    
    local notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.new(1, 100, 0, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 500,
        Parent = self.NotifyHolder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = notif })
    Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.75, Parent = notif })
    
    -- Accent bar
    local accent = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = notif,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = accent })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 18),
        Position = UDim2.fromOffset(20, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.Text,
        Font = Config.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 32),
        Position = UDim2.fromOffset(20, 30),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Config.TextDim,
        Font = Config.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notif,
    })
    
    -- Progress bar
    local progress = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = notif,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progress })
    
    -- Slide in
    Tween(notif, Config.AnimSpring, { Position = UDim2.new(0, 0, 0, 0) })
    Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
    
    task.delay(duration, function()
        if notif and notif.Parent then
            Tween(notif, Config.AnimNormal, { Position = UDim2.new(1, 100, 0, 0) })
            task.wait(0.4)
            if notif and notif.Parent then notif:Destroy() end
        end
    end)
    
    return notif
end

-- ============================================================
-- CREATE FLOATING TOGGLE BUTTON
-- ============================================================
function LiquidGlass:CreateToggleButton(icon)
    if self.FloatBtn then self.FloatBtn:Destroy() end
    
    local btn = Create("ImageButton", {
        Size = UDim2.fromOffset(52, 52),
        Position = UDim2.new(0, 20, 0.5, -26),
        BackgroundColor3 = Config.Glass,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Image = icon or "rbxassetid://12359659240",
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        ZIndex = 100,
        Parent = self.ScreenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
    Create("UIStroke", { Color = Config.Accent, Thickness = 2, Transparency = 0.5, Parent = btn })
    
    -- Glow
    local glow = Create("ImageLabel", {
        Size = UDim2.fromScale(1.5, 1.5),
        Position = UDim2.fromScale(-0.25, -0.25),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Config.Accent,
        ImageTransparency = 0.7,
        ZIndex = 99,
        Parent = btn,
    })
    
    -- Rainbow animation
    task.spawn(function()
        while btn.Parent do
            local t = tick() * 0.5
            local c = Color3.fromHSV(t % 1, 0.6, 1)
            btn.UIStroke.Color = c
            glow.ImageColor3 = c
            task.wait(0.05)
        end
    end)
    
    -- Drag
    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        self:Toggle()
        Tween(btn, Config.AnimSpring, { Size = UDim2.fromOffset(60, 60) })
        task.wait(0.15)
        Tween(btn, Config.AnimFast, { Size = UDim2.fromOffset(52, 52) })
    end)
    
    self.FloatBtn = btn
    return btn
end

-- ============================================================
-- DESTROY
-- ============================================================
function LiquidGlass:Destroy()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end
end

-- ============================================================
-- ICONS
-- ============================================================
LiquidGlass.Icons = {
    Dashboard = "▦",
    Combat = "⚔",
    Visuals = "◉",
    Teleport = "◈",
    Settings = "⚙",
    Star = "★",
    Zap = "⚡",
    Skull = "☠",
    Copy = "⧉",
    Logo = "✦",
    Player = "☺",
    Map = "🗺",
    Sword = "⚔",
    User = "☺",
    Wrench = "🔧",
    Search = "🔍",
}

return LiquidGlass
