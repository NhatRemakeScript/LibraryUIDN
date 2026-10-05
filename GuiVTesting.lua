--[[
    LiquidGlass UI - Simple Edition
    - Window kéo được
    - Tabs + GroupBoxes
    - Toggle / Slider / Dropdown / Input / Button
    - Notification
    - 4 themes
    - Ngắn gọn, không lỗi
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass
LiquidGlass.Version = "1.0-simple"

-- ============================================================
-- THEMES
-- ============================================================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(22, 22, 28),
        Sidebar    = Color3.fromRGB(18, 18, 24),
        Box        = Color3.fromRGB(30, 30, 38),
        SubBox     = Color3.fromRGB(38, 38, 48),
        Accent     = Color3.fromRGB(120, 140, 255),
        Accent2    = Color3.fromRGB(180, 120, 255),
        Border     = Color3.fromRGB(60, 60, 78),
        Text       = Color3.fromRGB(245, 245, 250),
        TextDim    = Color3.fromRGB(150, 150, 170),
        Danger     = Color3.fromRGB(255, 90, 90),
        Success    = Color3.fromRGB(80, 220, 140),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Sidebar    = Color3.fromRGB(225, 225, 235),
        Box        = Color3.fromRGB(250, 250, 255),
        SubBox     = Color3.fromRGB(235, 235, 245),
        Accent     = Color3.fromRGB(90, 110, 240),
        Accent2    = Color3.fromRGB(150, 100, 240),
        Border     = Color3.fromRGB(200, 200, 215),
        Text       = Color3.fromRGB(30, 30, 40),
        TextDim    = Color3.fromRGB(110, 110, 130),
        Danger     = Color3.fromRGB(230, 70, 80),
        Success    = Color3.fromRGB(50, 190, 110),
    },
    Mint = {
        Background = Color3.fromRGB(18, 28, 26),
        Sidebar    = Color3.fromRGB(14, 24, 22),
        Box        = Color3.fromRGB(26, 38, 36),
        SubBox     = Color3.fromRGB(34, 48, 46),
        Accent     = Color3.fromRGB(110, 230, 190),
        Accent2    = Color3.fromRGB(110, 200, 230),
        Border     = Color3.fromRGB(55, 90, 82),
        Text       = Color3.fromRGB(240, 255, 250),
        TextDim    = Color3.fromRGB(140, 175, 165),
        Danger     = Color3.fromRGB(255, 100, 110),
        Success    = Color3.fromRGB(120, 240, 160),
    },
    Sakura = {
        Background = Color3.fromRGB(30, 20, 26),
        Sidebar    = Color3.fromRGB(24, 16, 22),
        Box        = Color3.fromRGB(44, 30, 38),
        SubBox     = Color3.fromRGB(56, 40, 50),
        Accent     = Color3.fromRGB(255, 170, 200),
        Accent2    = Color3.fromRGB(255, 140, 170),
        Border     = Color3.fromRGB(105, 75, 90),
        Text       = Color3.fromRGB(255, 250, 252),
        TextDim    = Color3.fromRGB(185, 155, 168),
        Danger     = Color3.fromRGB(255, 90, 110),
        Success    = Color3.fromRGB(140, 220, 160),
    },
}

-- ============================================================
-- HELPERS
-- ============================================================
local function Tween(obj, dur, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function New(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function SafeParent()
    local ok, p = pcall(function()
        if type(gethui) == "function" then return gethui() end
        return CoreGui
    end)
    return (ok and p) or LP:WaitForChild("PlayerGui")
end

-- ============================================================
-- NEW INSTANCE
-- ============================================================
function LiquidGlass.new(opts)
    opts = opts or {}
    local self = setmetatable({}, LiquidGlass)

    self.Settings = {
        Theme = opts.Theme or "Dark",
        ToggleKey = opts.ToggleKey or Enum.KeyCode.RightControl,
    }

    self.Theme = Themes[self.Settings.Theme] or Themes.Dark
    self.Connections = {}
    self.Windows = {}

    return self
end

function LiquidGlass:SetTheme(name)
    if Themes[name] then
        self.Theme = Themes[name]
        self.Settings.Theme = name
        for _, w in ipairs(self.Windows) do
            pcall(function() w:_ApplyTheme() end)
        end
    end
end

-- ============================================================
-- NOTIFY
-- ============================================================
function LiquidGlass:Notify(cfg)
    cfg = cfg or {}
    local parent = SafeParent()
    local existing = parent:FindFirstChild("LiquidGlass_Notify")
    if not existing then
        existing = New("ScreenGui", {
            Name = "LiquidGlass_Notify",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 9999,
            Parent = parent,
        })
    end

    local notif = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(360, 60),
        Position = UDim2.new(0.5, 0, 0, -70),
        BackgroundColor3 = self.Theme.Box,
        BorderSizePixel = 0,
        Parent = existing,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = notif })
    local stroke = New("UIStroke", {
        Color = self.Theme.Accent, Thickness = 1.2,
        Transparency = 0.5, Parent = notif,
    })

    New("TextLabel", {
        Size = UDim2.new(1, -24, 0, 20),
        Position = UDim2.fromOffset(16, 10),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = cfg.Title or "Notification",
        Parent = notif,
    })
    New("TextLabel", {
        Size = UDim2.new(1, -24, 0, 16),
        Position = UDim2.fromOffset(16, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = self.Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = cfg.Content or "",
        Parent = notif,
    })

    Tween(notif, 0.35, { Position = UDim2.new(0.5, 0, 0, 24) }, Enum.EasingStyle.Back)
    task.delay(cfg.Duration or 3.5, function()
        if notif and notif.Parent then
            Tween(notif, 0.25, { Position = UDim2.new(0.5, 0, 0, -70), BackgroundTransparency = 1 })
            task.wait(0.3)
            if notif and notif.Parent then notif:Destroy() end
        end
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function LiquidGlass:CreateWindow(cfg)
    cfg = cfg or {}
    local Theme = self.Theme

    local gui = New("ScreenGui", {
        Name = "LiquidGlass_UI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
        Parent = SafeParent(),
    })

    local main = New("Frame", {
        Name = "Main",
        Size = cfg.Size or UDim2.fromOffset(700, 480),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = gui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 18), Parent = main })
    local mainStroke = New("UIStroke", {
        Color = Theme.Border, Thickness = 1.2,
        Transparency = 0.3, Parent = main,
    })

    -- Header
    local header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = main,
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = header,
    })

    -- Traffic dots
    local dots = New("Frame", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.fromOffset(14, 0),
        BackgroundTransparency = 1,
        Parent = header,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = dots,
    })

    local function Dot(col, hoverCol, fn)
        local d = New("TextButton", {
            Size = UDim2.fromOffset(12, 12),
            BackgroundColor3 = col,
            Text = "",
            AutoButtonColor = false,
            Parent = dots,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = d })
        d.MouseEnter:Connect(function() Tween(d, 0.15, {BackgroundColor3 = hoverCol}) end)
        d.MouseLeave:Connect(function() Tween(d, 0.15, {BackgroundColor3 = col}) end)
        d.MouseButton1Click:Connect(fn)
    end

    Dot(Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 130, 120), function()
        Tween(main, 0.25, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
        task.delay(0.3, function() main.Visible = false end)
    end)
    Dot(Color3.fromRGB(254, 188, 46), Color3.fromRGB(255, 215, 80), function()
        Tween(main, 0.25, {Size = UDim2.new(0, main.Size.X.Offset, 0, 48)})
    end)
    Dot(Color3.fromRGB(39, 201, 63), Color3.fromRGB(75, 235, 100), function()
        Tween(main, 0.3, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = cfg.Size or UDim2.fromOffset(700, 480),
        }, Enum.EasingStyle.Back)
    end)

    -- Title
    New("TextLabel", {
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.fromOffset(88, 8),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = cfg.Title or "LiquidGlass",
        Parent = header,
    })
    New("TextLabel", {
        Size = UDim2.new(1, -100, 0, 14),
        Position = UDim2.fromOffset(88, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = cfg.SubTitle or "v1.0",
        Parent = header,
    })

    -- Drag
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)
    header.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Body
    local body = New("Frame", {
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = main,
    })

    -- Sidebar
    local sidebar = New("Frame", {
        Size = UDim2.new(0, 170, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = body,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 14), Parent = sidebar })

    local navScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Parent = sidebar,
    })
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = navScroll,
    })

    -- Content
    local content = New("Frame", {
        Size = UDim2.new(1, -182, 1, -12),
        Position = UDim2.new(0, 176, 0, 6),
        BackgroundTransparency = 1,
        Parent = body,
    })

    -- Window object
    local Win = {
        Gui = gui,
        Main = main,
        Sidebar = sidebar,
        Content = content,
        Tabs = {},
        ActiveTab = nil,
    }

    -- Apply theme (cho SetTheme sau này)
    function Win:_ApplyTheme()
        local T = self.Theme
        main.BackgroundColor3 = T.Background
        mainStroke.Color = T.Border
        sidebar.BackgroundColor3 = T.Sidebar
    end
    Win.Theme = Theme

    function Win:Toggle()
        main.Visible = not main.Visible
    end

    function Win:Destroy()
        pcall(function() gui:Destroy() end)
    end

    function Win:CreateTab(cfg)
        cfg = cfg or {}
        local name = cfg.Title or "Tab"
        local order = cfg.LayoutOrder or (#Win.Tabs + 1)

        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.SubBox,
            BackgroundTransparency = 0.85,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = navScroll,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })
        local btnStroke = New("UIStroke", {
            Color = Theme.Border, Thickness = 1,
            Transparency = 0.7, Parent = btn,
        })
        local nameLbl = New("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(14, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = name,
            Parent = btn,
        })

        local page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            Visible = false,
            Parent = content,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            Parent = page,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = page,
        })

        local Tab = { Name = name, Button = btn, Page = page }

        btn.MouseEnter:Connect(function()
            if Win.ActiveTab ~= Tab then
                Tween(btn, 0.15, {BackgroundTransparency = 0.7})
                Tween(nameLbl, 0.15, {TextColor3 = Theme.Text})
            end
        end)
        btn.MouseLeave:Connect(function()
            if Win.ActiveTab ~= Tab then
                Tween(btn, 0.15, {BackgroundTransparency = 0.85})
                Tween(nameLbl, 0.15, {TextColor3 = Theme.TextDim})
            end
        end)

        local function Activate()
            if Win.ActiveTab == Tab then return end
            for _, t in ipairs(Win.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 0.85
                t.Button.UIStroke.Transparency = 0.7
                local lbl = t.Button:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.TextColor3 = Theme.TextDim end
            end
            Win.ActiveTab = Tab
            page.Visible = true
            btn.BackgroundTransparency = 0.6
            btnStroke.Transparency = 0.3
            nameLbl.TextColor3 = Theme.Text
            nameLbl.Font = Enum.Font.GothamBold
        end

        btn.MouseButton1Click:Connect(Activate)
        Tab.Activate = Activate

        table.insert(Win.Tabs, Tab)
        if #Win.Tabs == 1 then Activate() end

        -- ===== CreateGroupBox =====
        function Tab:CreateGroupBox(side, title, badge, icon)
            side = side or "Left"
            title = title or "Group"

            local group = New("Frame", {
                Size = UDim2.new(0.5, -6, 0, 0),
                Position = side == "Left" and UDim2.fromOffset(0, 0) or UDim2.new(0.5, 6, 0, 0),
                BackgroundColor3 = Theme.Box,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #page:GetChildren(),
                Parent = page,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = group })
            local gs = New("UIStroke", {
                Color = Theme.Border, Thickness = 1,
                Transparency = 0.7, Parent = group,
            })

            -- Header
            New("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Parent = group,
            })
            New("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.fromOffset(14, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = string.upper(title),
                Parent = group,
            })
            New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0, 35),
                BackgroundColor3 = Theme.Border,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Parent = group,
            })

            -- Items container
            local items = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.fromOffset(0, 36),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = group,
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = items,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 12),
                Parent = items,
            })

            local Group = { Frame = group, Items = items }

            -- ===== Toggle =====
            function Group:AddToggle(title, desc, default, callback)
                callback = callback or function() end
                local state = default or false

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.SubBox,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel = 0,
                    LayoutOrder = #items:GetChildren(),
                    Parent = items,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
                New("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.7, Parent = row })

                New("TextLabel", {
                    Size = UDim2.new(1, -70, 0, 18),
                    Position = UDim2.fromOffset(12, 6),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "Toggle",
                    Parent = row,
                })
                if desc and desc ~= "" then
                    New("TextLabel", {
                        Size = UDim2.new(1, -70, 0, 14),
                        Position = UDim2.fromOffset(12, 26),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        TextColor3 = Theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = desc,
                        Parent = row,
                    })
                end

                local track = New("Frame", {
                    Size = UDim2.fromOffset(42, 24),
                    Position = UDim2.new(1, -54, 0.5, -12),
                    BackgroundColor3 = Color3.fromRGB(70, 70, 80),
                    BorderSizePixel = 0,
                    Parent = row,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

                local knob = New("Frame", {
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.fromOffset(2, 2),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = track,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

                local function Update(anim)
                    local info = anim and TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out) or TweenInfo.new()
                    if state then
                        Tween(track, info.Scale or 0.3, {BackgroundColor3 = Theme.Accent})
                        Tween(knob, info.Scale or 0.3, {Position = UDim2.fromOffset(20, 2)})
                    else
                        Tween(track, info.Scale or 0.3, {BackgroundColor3 = Color3.fromRGB(70, 70, 80)})
                        Tween(knob, info.Scale or 0.3, {Position = UDim2.fromOffset(2, 2)})
                    end
                end
                Update(false)

                local click = New("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                })
                click.MouseButton1Click:Connect(function()
                    state = not state
                    Update(true)
                    pcall(callback, state)
                end)

                local obj = {}
                function obj:Set(v) state = v Update(true) end
                function obj:Get() return state end
                return obj
            end

            -- ===== Slider =====
            function Group:AddSlider(title, minV, maxV, default, suffix, callback)
                callback = callback or function() end
                minV, maxV = minV or 0, maxV or 100
                default = default or minV
                suffix = suffix or ""

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = Theme.SubBox,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel = 0,
                    LayoutOrder = #items:GetChildren(),
                    Parent = items,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
                New("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.7, Parent = row })

                New("TextLabel", {
                    Size = UDim2.new(0.7, 0, 0, 16),
                    Position = UDim2.fromOffset(12, 6),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "Slider",
                    Parent = row,
                })
                local vl = New("TextLabel", {
                    Size = UDim2.new(0.3, -24, 0, 16),
                    Position = UDim2.new(0.7, 12, 0, 6),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Text = tostring(default) .. " " .. suffix,
                    Parent = row,
                })

                local track = New("Frame", {
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.fromOffset(12, 34),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    BorderSizePixel = 0,
                    Parent = row,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

                local ratio = (default - minV) / math.max(maxV - minV, 0.001)
                local fill = New("Frame", {
                    Size = UDim2.new(ratio, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = track,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

                local knob = New("Frame", {
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.new(ratio, -8, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = track,
                })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

                local value = default
                local dragging = false

                local function Update(input)
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                    value = math.floor(minV + (maxV - minV) * rel)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, -8, 0.5, -8)
                    vl.Text = tostring(value) .. " " .. suffix
                    pcall(callback, value)
                end

                local btn = New("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                })
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(i)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        Update(i)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local obj = {}
                function obj:Set(v)
                    value = math.clamp(v, minV, maxV)
                    local r = (value - minV) / math.max(maxV - minV, 0.001)
                    fill.Size = UDim2.new(r, 0, 1, 0)
                    knob.Position = UDim2.new(r, -8, 0.5, -8)
                    vl.Text = tostring(value) .. " " .. suffix
                end
                function obj:Get() return value end
                return obj
            end

            -- ===== Dropdown =====
            function Group:AddDropdown(title, options, default, callback)
                callback = callback or function() end
                options = options or {}
                local selected = default or options[1] or ""
                local isOpen = false

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.SubBox,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    LayoutOrder = #items:GetChildren(),
                    Parent = items,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
                New("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.7, Parent = row })

                New("TextLabel", {
                    Size = UDim2.new(0.5, -12, 1, 0),
                    Position = UDim2.fromOffset(12, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "Dropdown",
                    Parent = row,
                })
                local vl = New("TextLabel", {
                    Size = UDim2.new(0.5, -30, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Text = tostring(selected) .. "  ▾",
                    Parent = row,
                })

                local list = New("Frame", {
                    Size = UDim2.new(1, -8, 0, 0),
                    Position = UDim2.fromOffset(4, 44),
                    BackgroundColor3 = Theme.Background,
                    BackgroundTransparency = 0.15,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = row,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = list })
                New("UIListLayout", { Padding = UDim.new(0, 2), Parent = list })
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
                    Parent = list,
                })

                local function Close()
                    isOpen = false
                    Tween(list, 0.2, {Size = UDim2.new(1, -8, 0, 0)})
                    Tween(row, 0.2, {Size = UDim2.new(1, 0, 0, 44)})
                end

                for i, opt in ipairs(options) do
                    local ob = New("TextButton", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = Theme.SubBox,
                        BackgroundTransparency = 1,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        Parent = list,
                    })
                    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ob })
                    New("TextLabel", {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.fromOffset(8, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        TextColor3 = Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = tostring(opt),
                        Parent = ob,
                    })
                    ob.MouseEnter:Connect(function() Tween(ob, 0.15, {BackgroundTransparency = 0.7}) end)
                    ob.MouseLeave:Connect(function() Tween(ob, 0.15, {BackgroundTransparency = 1}) end)
                    ob.MouseButton1Click:Connect(function()
                        selected = opt
                        vl.Text = tostring(selected) .. "  ▾"
                        Close()
                        pcall(callback, selected)
                    end)
                end

                local openBtn = New("TextButton", {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                })
                openBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local h = 8 + #options * 30
                        Tween(list, 0.2, {Size = UDim2.new(1, -8, 0, h)})
                        Tween(row, 0.2, {Size = UDim2.new(1, 0, 0, 44 + h)})
                    else
                        Close()
                    end
                end)

                local obj = {}
                function obj:Set(v) selected = v vl.Text = tostring(v) .. "  ▾" end
                function obj:Get() return selected end
                return obj
            end

            -- ===== Input =====
            function Group:AddInput(title, placeholder, default, callback)
                callback = callback or function() end

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.SubBox,
                    BackgroundTransparency = 0.4,
                    BorderSizePixel = 0,
                    LayoutOrder = #items:GetChildren(),
                    Parent = items,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
                New("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.7, Parent = row })

                New("TextLabel", {
                    Size = UDim2.new(0.4, -12, 1, 0),
                    Position = UDim2.fromOffset(12, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "Input",
                    Parent = row,
                })

                local box = New("Frame", {
                    Size = UDim2.new(0.6, -12, 0, 28),
                    Position = UDim2.new(0.4, 0, 0.5, -14),
                    BackgroundColor3 = Theme.Background,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = box })
                local bs = New("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.7, Parent = box })

                local input = New("TextBox", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.fromOffset(8, 0),
                    BackgroundTransparency = 1,
                    Text = default or "",
                    PlaceholderText = placeholder or "",
                    PlaceholderColor3 = Theme.TextDim,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = box,
                })
                input.Focused:Connect(function() bs.Color = Theme.Accent end)
                input.FocusLost:Connect(function()
                    bs.Color = Theme.Border
                    pcall(callback, input.Text)
                end)

                local obj = {}
                function obj:Set(v) input.Text = v end
                function obj:Get() return input.Text end
                return obj
            end

            -- ===== Button =====
            function Group:AddButton(title, desc, callback)
                callback = callback or function() end
                local hasDesc = desc and desc ~= ""

                local btn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, hasDesc and 44 or 34),
                    BackgroundColor3 = Theme.SubBox,
                    BackgroundTransparency = 0.4,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = #items:GetChildren(),
                    Parent = items,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })
                New("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.7, Parent = btn })

                New("TextLabel", {
                    Size = UDim2.new(1, -12, 0, hasDesc and 18 or 34),
                    Position = UDim2.fromOffset(12, hasDesc and 4 or 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "Button",
                    Parent = btn,
                })
                if hasDesc then
                    New("TextLabel", {
                        Size = UDim2.new(1, -12, 0, 14),
                        Position = UDim2.fromOffset(12, 24),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        TextColor3 = Theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = desc,
                        Parent = btn,
                    })
                end

                btn.MouseEnter:Connect(function() Tween(btn, 0.15, {BackgroundTransparency = 0.2}) end)
                btn.MouseLeave:Connect(function() Tween(btn, 0.15, {BackgroundTransparency = 0.4}) end)
                btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                    Tween(btn, 0.1, {BackgroundColor3 = Theme.Accent})
                    task.delay(0.15, function()
                        Tween(btn, 0.2, {BackgroundColor3 = Theme.SubBox})
                    end)
                end)
                return { Button = btn }
            end

            -- ===== Danger Button =====
            function Group:AddDangerButton(title, desc, callback)
                callback = callback or function() end
                local hasDesc = desc and desc ~= ""

                local btn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, hasDesc and 44 or 34),
                    BackgroundColor3 = Color3.fromRGB(70, 28, 32),
                    BackgroundTransparency = 0.3,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = #items:GetChildren(),
                    Parent = items,
                })
                New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })
                New("UIStroke", { Color = Theme.Danger, Thickness = 1, Transparency = 0.4, Parent = btn })

                New("TextLabel", {
                    Size = UDim2.new(1, -12, 0, hasDesc and 18 or 34),
                    Position = UDim2.fromOffset(12, hasDesc and 4 or 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Theme.Danger,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "Danger",
                    Parent = btn,
                })
                if hasDesc then
                    New("TextLabel", {
                        Size = UDim2.new(1, -12, 0, 14),
                        Position = UDim2.fromOffset(12, 24),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        TextColor3 = Theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = desc,
                        Parent = btn,
                    })
                end

                btn.MouseEnter:Connect(function()
                    Tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(90, 32, 38), BackgroundTransparency = 0.15})
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(70, 28, 32), BackgroundTransparency = 0.3})
                end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, 0.1, {BackgroundColor3 = Theme.Danger})
                    task.delay(0.15, function()
                        Tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(90, 32, 38)})
                    end)
                    pcall(callback)
                end)
                return { Button = btn }
            end

            return Group
        end

        return Tab
    end

    -- ===== KEYBIND =====
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == self.Settings.ToggleKey then
            Win:Toggle()
        end
    end)

    table.insert(self.Windows, Win)
    return Win
end

pcall(function()
    _G.LiquidGlass = LiquidGlass
    if getgenv then getgenv().LiquidGlass = LiquidGlass end
end)

return LiquidGlass
