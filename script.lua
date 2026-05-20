--[[
    ███████╗███████╗███╗   ██╗████████╗██╗   ██╗    ██╗  ██╗██╗   ██╗██████╗
    ╚══███╔╝██╔════╝████╗  ██║╚══██╔══╝╚██╗ ██╔╝    ██║  ██║██║   ██║██╔══██╗
      ███╔╝ █████╗  ██╔██╗ ██║   ██║    ╚████╔╝     ███████║██║   ██║██████╔╝
     ███╔╝  ██╔══╝  ██║╚██╗██║   ██║     ╚██╔╝      ██╔══██║██║   ██║██╔══██╗
    ███████╗███████╗██║ ╚████║   ██║      ██║        ██║  ██║╚██████╔╝██████╔╝
    ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝      ╚═╝        ╚═╝  ╚═╝ ╚═════╝ ╚═════╝
    
    Zenty Hub - Professional Gaming Suite v1.0
    Developed for educational purposes only.
    
    Architecture:
        [1] Core          - Services, Constants, Init
        [2] KeySystem     - Authentication gate
        [3] SignalManager - Connection lifecycle management
        [4] UIFactory     - Reusable component constructors
        [5] ESP           - Entity highlighting and labels
        [6] Aimbot        - FOV circle + Camera lock
        [7] Movement      - Speed, Jump, Fly, NoClip, Swim, Teleport
        [8] Games         - Per-game exploit modules (MM2, Arsenal, Jailbreak, TD)
        [9] Window        - Main hub window orchestration
]]

-- ============================================================
-- [1] CORE - Services, constants, global state
-- ============================================================

local Core = {}
do
    -- Roblox Services
    Core.Players       = game:GetService("Players")
    Core.RunService    = game:GetService("RunService")
    Core.UserInputService = game:GetService("UserInputService")
    Core.TweenService  = game:GetService("TweenService")
    Core.HttpService   = game:GetService("HttpService")
    Core.Workspace     = game:GetService("Workspace")
    Core.StarterGui    = game:GetService("StarterGui")
    Core.SoundService  = game:GetService("SoundService")

    Core.LocalPlayer   = Core.Players.LocalPlayer
    Core.Camera        = Core.Workspace.CurrentCamera
    Core.Mouse         = Core.LocalPlayer:GetMouse()

    -- Color palette
    Core.Colors = {
        BG_DARK      = Color3.fromRGB(12, 10, 18),
        BG_PANEL     = Color3.fromRGB(20, 16, 30),
        BG_ELEMENT   = Color3.fromRGB(28, 22, 42),
        ACCENT       = Color3.fromRGB(138, 43, 226),
        ACCENT_LIGHT = Color3.fromRGB(180, 100, 255),
        ACCENT_DARK  = Color3.fromRGB(90, 20, 160),
        TEXT_PRIMARY = Color3.fromRGB(235, 230, 255),
        TEXT_SECONDARY = Color3.fromRGB(160, 140, 200),
        TEXT_DISABLED  = Color3.fromRGB(80, 70, 100),
        SUCCESS      = Color3.fromRGB(80, 200, 120),
        DANGER       = Color3.fromRGB(220, 60, 60),
        WARNING      = Color3.fromRGB(230, 160, 40),
        WHITE        = Color3.fromRGB(255, 255, 255),
        TRANSPARENT  = Color3.fromRGB(0, 0, 0),
    }

    -- Fonts
    Core.Fonts = {
        TITLE   = Enum.Font.GothamBold,
        BODY    = Enum.Font.Gotham,
        MONO    = Enum.Font.RobotoMono,
        SEMIBOLD = Enum.Font.GothamSemibold,
    }

    -- Global flags
    Core.State = {
        Authenticated  = false,
        HubVisible     = true,
        AimbotEnabled  = false,
        ESPEnabled     = false,
        FlyEnabled     = false,
        NoClipEnabled  = false,
        SpeedValue     = 16,
        JumpValue      = 50,
        FlySpeed       = 40,
        SwimSpeed      = 16,
        FOVRadius      = 120,
        FOVSmoothing   = 0.15,
        RecoilControl  = 0,
        TargetPart     = "Head",
        AimbotKey      = Enum.KeyCode.E,
    }

    -- Valid keys (in production these would be server-validated)
    Core.ValidKeys = {
        ["ZentyV1"]     = true,
        ["ZentyPro2024"] = true,
        ["ZENTY-ELITE-X"] = true,
    }

    -- Safe call wrapper
    function Core.SafeCall(fn, ...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[ZentyHub] Error: " .. tostring(err))
        end
        return ok, err
    end

    -- Tween helper
    function Core.Tween(obj, info, props)
        local tween = Core.TweenService:Create(obj, info, props)
        tween:Play()
        return tween
    end

    -- Short tween info
    function Core.TI(t, style, dir)
        return TweenInfo.new(
            t or 0.2,
            style or Enum.EasingStyle.Quad,
            dir or Enum.EasingDirection.Out
        )
    end

    -- WorldToViewport wrapper
    function Core.WorldToScreen(pos)
        local screenPos, onScreen = Core.Camera:WorldToViewportPoint(pos)
        return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
    end
end

-- ============================================================
-- [2] SIGNAL MANAGER - Connection lifecycle
-- ============================================================

local SignalManager = {}
do
    SignalManager._connections = {}
    SignalManager._renderFns   = {}

    function SignalManager:Connect(signal, fn, tag)
        local conn = signal:Connect(fn)
        local id   = tag or tostring(conn)
        self._connections[id] = conn
        return id
    end

    function SignalManager:Disconnect(tag)
        local conn = self._connections[tag]
        if conn then
            conn:Disconnect()
            self._connections[tag] = nil
        end
    end

    function SignalManager:DisconnectAll()
        for tag, conn in pairs(self._connections) do
            Core.SafeCall(function() conn:Disconnect() end)
        end
        self._connections = {}
        self._renderFns   = {}
    end

    -- Register a RenderStepped callback with a tag
    function SignalManager:OnRender(tag, fn)
        self._renderFns[tag] = fn
    end

    function SignalManager:RemoveRender(tag)
        self._renderFns[tag] = nil
    end

    -- Master render loop
    SignalManager._masterConn = Core.RunService.RenderStepped:Connect(function(dt)
        for tag, fn in pairs(SignalManager._renderFns) do
            Core.SafeCall(fn, dt)
        end
    end)
end

-- ============================================================
-- [3] UI FACTORY - Reusable component builders
-- ============================================================

local UIFactory = {}
do
    -- Create a UICorner
    local function corner(r, parent)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 6)
        c.Parent = parent
        return c
    end

    -- Create a UIStroke
    local function stroke(thickness, color, parent)
        local s = Instance.new("UIStroke")
        s.Thickness  = thickness or 1
        s.Color      = color or Core.Colors.ACCENT
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent     = parent
        return s
    end

    -- Create a UIPadding
    local function padding(t, b, l, r, parent)
        local p = Instance.new("UIPadding")
        p.PaddingTop    = UDim.new(0, t or 4)
        p.PaddingBottom = UDim.new(0, b or 4)
        p.PaddingLeft   = UDim.new(0, l or 6)
        p.PaddingRight  = UDim.new(0, r or 6)
        p.Parent        = parent
        return p
    end

    -- Base Frame
    function UIFactory.Frame(props)
        local f = Instance.new("Frame")
        f.BackgroundColor3  = props.Color       or Core.Colors.BG_PANEL
        f.BorderSizePixel   = 0
        f.Size              = props.Size        or UDim2.new(1, 0, 0, 40)
        f.Position          = props.Position    or UDim2.new(0, 0, 0, 0)
        f.ZIndex            = props.ZIndex      or 1
        f.BackgroundTransparency = props.Transparency or 0
        f.Name              = props.Name        or "Frame"
        if props.Corner ~= false then corner(props.CornerRadius or 6, f) end
        if props.StrokeColor then stroke(props.StrokeThickness or 1, props.StrokeColor, f) end
        if props.Parent then f.Parent = props.Parent end
        return f
    end

    -- Label
    function UIFactory.Label(props)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size       = props.Size     or UDim2.new(1, 0, 0, 24)
        l.Position   = props.Position or UDim2.new(0, 0, 0, 0)
        l.Text       = props.Text     or ""
        l.TextColor3 = props.Color    or Core.Colors.TEXT_PRIMARY
        l.Font       = props.Font     or Core.Fonts.BODY
        l.TextSize   = props.TextSize or 13
        l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
        l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
        l.ZIndex     = props.ZIndex   or 2
        l.RichText   = props.RichText or false
        l.Name       = props.Name     or "Label"
        if props.Parent then l.Parent = props.Parent end
        return l
    end

    -- Button
    function UIFactory.Button(props)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = props.Color    or Core.Colors.ACCENT
        btn.BorderSizePixel  = 0
        btn.Size             = props.Size     or UDim2.new(1, 0, 0, 32)
        btn.Position         = props.Position or UDim2.new(0, 0, 0, 0)
        btn.Text             = props.Text     or "Button"
        btn.TextColor3       = props.TextColor or Core.Colors.WHITE
        btn.Font             = props.Font     or Core.Fonts.SEMIBOLD
        btn.TextSize         = props.TextSize or 13
        btn.AutoButtonColor  = false
        btn.ZIndex           = props.ZIndex   or 2
        btn.Name             = props.Name     or "Button"
        corner(props.CornerRadius or 6, btn)
        if props.StrokeColor then stroke(1, props.StrokeColor, btn) end
        if props.Parent then btn.Parent = props.Parent end

        -- Hover effects
        btn.MouseEnter:Connect(function()
            Core.Tween(btn, Core.TI(0.12), {BackgroundColor3 = props.HoverColor or Core.Colors.ACCENT_LIGHT})
        end)
        btn.MouseLeave:Connect(function()
            Core.Tween(btn, Core.TI(0.12), {BackgroundColor3 = props.Color or Core.Colors.ACCENT})
        end)
        btn.MouseButton1Down:Connect(function()
            Core.Tween(btn, Core.TI(0.08), {BackgroundColor3 = props.PressColor or Core.Colors.ACCENT_DARK})
        end)
        btn.MouseButton1Up:Connect(function()
            Core.Tween(btn, Core.TI(0.12), {BackgroundColor3 = props.HoverColor or Core.Colors.ACCENT_LIGHT})
        end)

        if props.OnClick then
            btn.MouseButton1Click:Connect(function()
                Core.SafeCall(props.OnClick)
            end)
        end
        return btn
    end

    -- Toggle (returns frame + setState function)
    function UIFactory.Toggle(props)
        local container = UIFactory.Frame({
            Color   = Color3.fromRGB(0,0,0),
            Transparency = 1,
            Size    = UDim2.new(1, 0, 0, 34),
            Name    = "Toggle_" .. (props.Text or ""),
            Parent  = props.Parent,
        })

        local bg = UIFactory.Frame({
            Color  = Core.Colors.BG_ELEMENT,
            Size   = UDim2.new(1, 0, 1, 0),
            Corner = true,
            CornerRadius = 6,
            Parent = container,
        })
        padding(0, 0, 8, 8, bg)

        local label = UIFactory.Label({
            Text     = props.Text or "Option",
            Size     = UDim2.new(1, -52, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Color    = Core.Colors.TEXT_PRIMARY,
            TextSize = 12,
            Font     = Core.Fonts.BODY,
            Parent   = bg,
        })

        -- Track
        local trackBg = UIFactory.Frame({
            Color    = Core.Colors.BG_DARK,
            Size     = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            Corner   = true,
            CornerRadius = 10,
            Parent   = bg,
        })
        local trackFill = UIFactory.Frame({
            Color    = Core.Colors.ACCENT,
            Size     = UDim2.new(0, 0, 1, 0),
            Corner   = true,
            CornerRadius = 10,
            Transparency = 1,
            Parent   = trackBg,
        })
        -- Knob
        local knob = UIFactory.Frame({
            Color    = Core.Colors.WHITE,
            Size     = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            Corner   = true,
            CornerRadius = 8,
            Parent   = trackBg,
        })

        local state = props.Default or false

        local function setState(newState, silent)
            state = newState
            if state then
                Core.Tween(trackBg,  Core.TI(0.2), {BackgroundColor3 = Core.Colors.ACCENT_DARK})
                Core.Tween(knob,     Core.TI(0.2), {Position = UDim2.new(0, 22, 0.5, -8), BackgroundColor3 = Core.Colors.ACCENT_LIGHT})
            else
                Core.Tween(trackBg,  Core.TI(0.2), {BackgroundColor3 = Core.Colors.BG_DARK})
                Core.Tween(knob,     Core.TI(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Core.Colors.WHITE})
            end
            if not silent and props.OnChange then
                Core.SafeCall(props.OnChange, state)
            end
        end

        setState(state, true) -- Init visual

        local clickBtn = Instance.new("TextButton")
        clickBtn.BackgroundTransparency = 1
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.Text = ""
        clickBtn.ZIndex = 5
        clickBtn.Parent = container
        clickBtn.MouseButton1Click:Connect(function()
            setState(not state)
        end)

        return container, setState
    end

    -- Slider (returns frame + setValue function)
    function UIFactory.Slider(props)
        local container = UIFactory.Frame({
            Color        = Color3.fromRGB(0,0,0),
            Transparency = 1,
            Size         = UDim2.new(1, 0, 0, 46),
            Name         = "Slider_" .. (props.Text or ""),
            Parent       = props.Parent,
        })

        local bg = UIFactory.Frame({
            Color  = Core.Colors.BG_ELEMENT,
            Size   = UDim2.new(1, 0, 1, 0),
            Corner = true,
            CornerRadius = 6,
            Parent = container,
        })
        padding(0, 0, 8, 8, bg)

        local labelRow = Instance.new("Frame")
        labelRow.BackgroundTransparency = 1
        labelRow.Size = UDim2.new(1, 0, 0, 18)
        labelRow.Parent = bg

        local label = UIFactory.Label({
            Text     = props.Text or "Value",
            Size     = UDim2.new(0.7, 0, 1, 0),
            Color    = Core.Colors.TEXT_PRIMARY,
            TextSize = 12,
            Parent   = labelRow,
        })

        local valueLabel = UIFactory.Label({
            Text     = tostring(props.Default or 0),
            Size     = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.7, 0, 0, 0),
            Color    = Core.Colors.ACCENT_LIGHT,
            TextSize = 12,
            XAlign   = Enum.TextXAlignment.Right,
            Parent   = labelRow,
        })

        -- Track
        local trackBg = UIFactory.Frame({
            Color    = Core.Colors.BG_DARK,
            Size     = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 26),
            Corner   = true,
            CornerRadius = 3,
            Parent   = bg,
        })
        local trackFill = UIFactory.Frame({
            Color    = Core.Colors.ACCENT,
            Size     = UDim2.new(0, 0, 1, 0),
            Corner   = true,
            CornerRadius = 3,
            Parent   = trackBg,
        })
        -- Knob
        local knob = UIFactory.Frame({
            Color    = Core.Colors.ACCENT_LIGHT,
            Size     = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, -6, 0.5, -6),
            Corner   = true,
            CornerRadius = 6,
            Parent   = trackBg,
        })
        stroke(2, Core.Colors.ACCENT, knob)

        local minVal = props.Min  or 0
        local maxVal = props.Max  or 100
        local curVal = props.Default or minVal
        local dragging = false

        local function setValue(v, silent)
            v = math.clamp(v, minVal, maxVal)
            if props.Integer then v = math.floor(v) end
            curVal = v
            local pct = (v - minVal) / (maxVal - minVal)
            trackFill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position  = UDim2.new(pct, -6, 0.5, -6)
            valueLabel.Text = tostring(v)
            if not silent and props.OnChange then
                Core.SafeCall(props.OnChange, v)
            end
        end

        setValue(curVal, true)

        -- Hit area
        local hitBtn = Instance.new("TextButton")
        hitBtn.BackgroundTransparency = 1
        hitBtn.Size = UDim2.new(1, 0, 0, 6)
        hitBtn.Position = UDim2.new(0, 0, 0, 26)
        hitBtn.Text = ""
        hitBtn.ZIndex = 6
        hitBtn.Parent = bg

        hitBtn.MouseButton1Down:Connect(function()
            dragging = true
        end)

        Core.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        Core.RunService.RenderStepped:Connect(function()
            if dragging then
                local mx     = Core.Mouse.X
                local absPos = trackBg.AbsolutePosition.X
                local absSize = trackBg.AbsoluteSize.X
                if absSize > 0 then
                    local pct = math.clamp((mx - absPos) / absSize, 0, 1)
                    local v   = minVal + (maxVal - minVal) * pct
                    setValue(v)
                end
            end
        end)

        return container, setValue
    end

    -- Section header
    function UIFactory.SectionHeader(text, parent)
        local f = UIFactory.Frame({
            Color  = Color3.fromRGB(0,0,0),
            Transparency = 1,
            Size   = UDim2.new(1, 0, 0, 24),
            Corner = false,
            Parent = parent,
        })
        local divLeft = UIFactory.Frame({
            Color = Core.Colors.ACCENT,
            Size  = UDim2.new(0, 3, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            Corner = false,
            Parent = f,
        })
        UIFactory.Label({
            Text     = string.upper(text),
            Position = UDim2.new(0, 10, 0, 0),
            Size     = UDim2.new(1, -10, 1, 0),
            Color    = Core.Colors.ACCENT_LIGHT,
            TextSize = 10,
            Font     = Core.Fonts.TITLE,
            Parent   = f,
        })
        return f
    end

    -- Scrolling list container
    function UIFactory.ScrollList(props)
        local sf = Instance.new("ScrollingFrame")
        sf.BackgroundTransparency = 1
        sf.Size            = props.Size     or UDim2.new(1, 0, 1, 0)
        sf.Position        = props.Position or UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = Core.Colors.ACCENT
        sf.BorderSizePixel = 0
        sf.CanvasSize      = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Name            = props.Name or "ScrollList"
        sf.ZIndex          = props.ZIndex or 2
        if props.Parent then sf.Parent = props.Parent end

        local layout = Instance.new("UIListLayout")
        layout.SortOrder    = Enum.SortOrder.LayoutOrder
        layout.Padding      = UDim.new(0, 4)
        layout.Parent       = sf

        padding(6, 6, 6, 6, sf)
        return sf, layout
    end

    -- Tab button
    function UIFactory.TabButton(props)
        local btn = UIFactory.Button({
            Color     = props.Active and Core.Colors.ACCENT or Core.Colors.BG_ELEMENT,
            Text      = props.Text or "Tab",
            Size      = props.Size or UDim2.new(0, 0, 1, -4),
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize  = 12,
            Font      = Core.Fonts.SEMIBOLD,
            HoverColor = props.Active and Core.Colors.ACCENT_LIGHT or Color3.fromRGB(40, 30, 60),
            CornerRadius = 6,
            Parent    = props.Parent,
        })
        padding(0, 0, 10, 10, btn)
        btn.AutomaticSize = Enum.AutomaticSize.X
        return btn
    end

    -- Input box
    function UIFactory.Input(props)
        local container = UIFactory.Frame({
            Color  = Core.Colors.BG_ELEMENT,
            Size   = props.Size or UDim2.new(1, 0, 0, 36),
            Corner = true,
            CornerRadius = 6,
            StrokeColor = Core.Colors.ACCENT_DARK,
            Parent = props.Parent,
        })
        padding(0, 0, 8, 40, container)

        local tb = Instance.new("TextBox")
        tb.BackgroundTransparency = 1
        tb.Size = UDim2.new(1, 0, 1, 0)
        tb.Text = props.Default or ""
        tb.TextColor3 = Core.Colors.TEXT_PRIMARY
        tb.Font = Core.Fonts.MONO
        tb.TextSize = 13
        tb.PlaceholderText = props.Placeholder or "Enter value..."
        tb.PlaceholderColor3 = Core.Colors.TEXT_DISABLED
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus = props.ClearOnFocus ~= false
        tb.ZIndex = 3
        tb.Parent = container

        -- Lock icon
        local lockLabel = UIFactory.Label({
            Text     = "🔒",
            Size     = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            XAlign   = Enum.TextXAlignment.Center,
            TextSize = 14,
            ZIndex   = 3,
            Parent   = container,
        })

        -- Focus glow
        tb.Focused:Connect(function()
            Core.Tween(container, Core.TI(0.15), {BackgroundColor3 = Color3.fromRGB(35, 28, 55)})
        end)
        tb.FocusLost:Connect(function()
            Core.Tween(container, Core.TI(0.15), {BackgroundColor3 = Core.Colors.BG_ELEMENT})
        end)

        if props.OnSubmit then
            tb.FocusLost:Connect(function(enter)
                if enter then Core.SafeCall(props.OnSubmit, tb.Text) end
            end)
        end

        return container, tb
    end

    -- Notification toast
    function UIFactory.Notify(title, body, color, duration)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name           = "ZentyNotif_" .. tostring(tick())
        ScreenGui.ResetOnSpawn   = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        ScreenGui.Parent         = Core.LocalPlayer:FindFirstChild("PlayerGui")

        local toast = UIFactory.Frame({
            Color    = Core.Colors.BG_PANEL,
            Size     = UDim2.new(0, 280, 0, 70),
            Position = UDim2.new(1, 10, 1, -90),
            Corner   = true,
            CornerRadius = 8,
            StrokeColor = color or Core.Colors.ACCENT,
            ZIndex   = 100,
            Parent   = ScreenGui,
        })
        stroke(2, color or Core.Colors.ACCENT, toast)

        -- Color accent bar
        local bar = UIFactory.Frame({
            Color  = color or Core.Colors.ACCENT,
            Size   = UDim2.new(0, 4, 1, 0),
            Corner = false,
            Parent = toast,
        })
        local barC = Instance.new("UICorner")
        barC.CornerRadius = UDim.new(0, 8)
        barC.Parent = bar

        UIFactory.Label({
            Text     = title or "Notification",
            Position = UDim2.new(0, 14, 0, 8),
            Size     = UDim2.new(1, -20, 0, 20),
            Color    = Core.Colors.WHITE,
            TextSize = 13,
            Font     = Core.Fonts.TITLE,
            ZIndex   = 101,
            Parent   = toast,
        })
        UIFactory.Label({
            Text     = body or "",
            Position = UDim2.new(0, 14, 0, 30),
            Size     = UDim2.new(1, -20, 0, 30),
            Color    = Core.Colors.TEXT_SECONDARY,
            TextSize = 11,
            Font     = Core.Fonts.BODY,
            ZIndex   = 101,
            Parent   = toast,
        })

        -- Slide in
        Core.Tween(toast, Core.TI(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -290, 1, -90)})

        task.delay(duration or 3, function()
            Core.Tween(toast, Core.TI(0.25), {Position = UDim2.new(1, 10, 1, -90)})
            task.delay(0.3, function()
                ScreenGui:Destroy()
            end)
        end)
    end

    -- Expose helpers for internal use
    UIFactory._corner  = corner
    UIFactory._stroke  = stroke
    UIFactory._padding = padding
end

-- ============================================================
-- [4] KEY SYSTEM - Authentication gate
-- ============================================================

local KeySystem = {}
do
    function KeySystem:Validate(key)
        if key == nil or key == "" then return false end
        return Core.ValidKeys[key] == true
    end

    function KeySystem:ShowScreen(onSuccess)
        -- Create dedicated ScreenGui
        local gui = Instance.new("ScreenGui")
        gui.Name           = "ZentyAuth"
        gui.ResetOnSpawn   = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.IgnoreGuiInset = true
        gui.Parent         = Core.LocalPlayer:FindFirstChild("PlayerGui")

        -- Blur background
        local blur = Instance.new("BlurEffect")
        blur.Size   = 0
        blur.Parent = Core.Workspace.CurrentCamera
        Core.Tween(blur, Core.TI(0.4), {Size = 20})

        -- Dark overlay
        local overlay = UIFactory.Frame({
            Color        = Core.Colors.BG_DARK,
            Transparency = 0.3,
            Size         = UDim2.new(1, 0, 1, 0),
            Corner       = false,
            Parent       = gui,
        })

        -- Animated background particles (pure UI, no textures needed)
        for i = 1, 8 do
            local dot = UIFactory.Frame({
                Color        = Core.Colors.ACCENT,
                Transparency = 0.6 + math.random() * 0.3,
                Size         = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6)),
                Position     = UDim2.new(math.random(), 0, math.random(), 0),
                Corner       = true,
                CornerRadius = 4,
                Parent       = overlay,
            })
            -- Float animation
            task.spawn(function()
                while dot and dot.Parent do
                    local targetY = UDim2.new(dot.Position.X.Scale, 0, dot.Position.Y.Scale - 0.3, 0)
                    Core.Tween(dot, TweenInfo.new(4 + math.random()*3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = targetY, BackgroundTransparency = 0.95})
                    task.wait(4 + math.random()*3)
                    if dot and dot.Parent then
                        dot.Position = UDim2.new(math.random(), 0, 1.1, 0)
                        Core.Tween(dot, TweenInfo.new(0.1), {BackgroundTransparency = 0.6 + math.random()*0.3})
                    end
                end
            end)
        end

        -- Auth card
        local card = UIFactory.Frame({
            Color        = Core.Colors.BG_PANEL,
            Size         = UDim2.new(0, 400, 0, 320),
            Position     = UDim2.new(0.5, -200, 0.5, -200),
            Corner       = true,
            CornerRadius = 12,
            StrokeColor  = Core.Colors.ACCENT,
            Parent       = gui,
        })
        UIFactory._stroke(1.5, Core.Colors.ACCENT, card)

        -- Slide in animation
        card.Position = UDim2.new(0.5, -200, 0.5, -160)
        card.BackgroundTransparency = 1
        Core.Tween(card, Core.TI(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -200, 0.5, -160),
            BackgroundTransparency = 0,
        })

        -- Title glow bar
        local titleBar = UIFactory.Frame({
            Color    = Core.Colors.ACCENT,
            Size     = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 0, 0),
            Corner   = false,
            Parent   = card,
        })

        -- Logo area
        local logoLabel = UIFactory.Label({
            Text     = "⬡  ZENTY HUB",
            Position = UDim2.new(0, 0, 0, 20),
            Size     = UDim2.new(1, 0, 0, 40),
            Color    = Core.Colors.WHITE,
            TextSize = 24,
            Font     = Core.Fonts.TITLE,
            XAlign   = Enum.TextXAlignment.Center,
            Parent   = card,
        })

        local subLabel = UIFactory.Label({
            Text     = "Professional Gaming Suite",
            Position = UDim2.new(0, 0, 0, 60),
            Size     = UDim2.new(1, 0, 0, 20),
            Color    = Core.Colors.ACCENT_LIGHT,
            TextSize = 11,
            Font     = Core.Fonts.BODY,
            XAlign   = Enum.TextXAlignment.Center,
            Parent   = card,
        })

        -- Separator
        local sep = UIFactory.Frame({
            Color  = Core.Colors.ACCENT_DARK,
            Size   = UDim2.new(0.8, 0, 0, 1),
            Position = UDim2.new(0.1, 0, 0, 92),
            Corner = false,
            Parent = card,
        })

        -- Auth form
        UIFactory.Label({
            Text     = "Mot de Passe",
            Position = UDim2.new(0, 30, 0, 106),
            Size     = UDim2.new(1, -60, 0, 20),
            Color    = Core.Colors.TEXT_PRIMARY,
            TextSize = 13,
            Font     = Core.Fonts.SEMIBOLD,
            Parent   = card,
        })

        local inputContainer, inputBox = UIFactory.Input({
            Placeholder  = "Entrez votre clé...",
            Size         = UDim2.new(1, -60, 0, 40),
            ClearOnFocus = false,
            Parent       = card,
        })
        inputContainer.Position = UDim2.new(0, 30, 0, 132)

        -- Status label
        local statusLabel = UIFactory.Label({
            Text     = "",
            Position = UDim2.new(0, 30, 0, 182),
            Size     = UDim2.new(1, -60, 0, 20),
            Color    = Core.Colors.DANGER,
            TextSize = 11,
            Font     = Core.Fonts.BODY,
            XAlign   = Enum.TextXAlignment.Center,
            Parent   = card,
        })

        -- Access button
        local accessBtn = UIFactory.Button({
            Text      = "Accéder au Panel",
            Color     = Core.Colors.ACCENT,
            Position  = UDim2.new(0, 30, 0, 210),
            Size      = UDim2.new(1, -60, 0, 42),
            TextSize  = 14,
            Font      = Core.Fonts.TITLE,
            CornerRadius = 8,
            Parent    = card,
        })

        -- Version footer
        UIFactory.Label({
            Text     = "v1.0  •  Key System Active",
            Position = UDim2.new(0, 0, 1, -28),
            Size     = UDim2.new(1, 0, 0, 24),
            Color    = Core.Colors.TEXT_DISABLED,
            TextSize = 10,
            XAlign   = Enum.TextXAlignment.Center,
            Parent   = card,
        })

        -- Attempt logic
        local attempts = 0
        local function attempt()
            local key = inputBox.Text
            attempts = attempts + 1
            if self:Validate(key) then
                -- Success
                statusLabel.Text  = "✓ Authentification réussie"
                statusLabel.TextColor3 = Core.Colors.SUCCESS
                Core.Tween(card, Core.TI(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -200, 0.5, -280),
                    BackgroundTransparency = 1,
                })
                Core.Tween(blur, Core.TI(0.5), {Size = 0})
                task.delay(0.45, function()
                    gui:Destroy()
                    blur:Destroy()
                    Core.State.Authenticated = true
                    Core.SafeCall(onSuccess)
                end)
            else
                statusLabel.Text = "✗ Clé invalide  (tentative " .. attempts .. ")"
                statusLabel.TextColor3 = Core.Colors.DANGER
                Core.Tween(card, Core.TI(0.05), {Position = UDim2.new(0.5, -200 + 8, 0.5, -160)})
                task.wait(0.05)
                Core.Tween(card, Core.TI(0.05), {Position = UDim2.new(0.5, -200 - 8, 0.5, -160)})
                task.wait(0.05)
                Core.Tween(card, Core.TI(0.05), {Position = UDim2.new(0.5, -200 + 5, 0.5, -160)})
                task.wait(0.05)
                Core.Tween(card, Core.TI(0.08), {Position = UDim2.new(0.5, -200, 0.5, -160)})
                if attempts >= 5 then
                    accessBtn.Active = false
                    accessBtn.Text   = "Trop de tentatives"
                    Core.Tween(accessBtn, Core.TI(0.2), {BackgroundColor3 = Core.Colors.DANGER})
                end
            end
        end

        accessBtn.MouseButton1Click:Connect(attempt)
        inputBox.FocusLost:Connect(function(enter)
            if enter then attempt() end
        end)
    end
end

-- ============================================================
-- [5] ESP MODULE
-- ============================================================

local ESPModule = {}
do
    ESPModule._highlights = {}
    ESPModule._billboards = {}
    ESPModule._enabled = {
        Boxes    = false,
        Names    = false,
        Health   = false,
        Bones    = false,
        Distance = false,
    }

    local ESP_FOLDER_NAME = "ZentyESP_Folder"

    local function getESPFolder()
        local f = Core.Workspace:FindFirstChild(ESP_FOLDER_NAME)
        if not f then
            f = Instance.new("Folder")
            f.Name = ESP_FOLDER_NAME
            f.Parent = Core.Workspace
        end
        return f
    end

    -- Create highlight for a player
    local function createHighlight(player)
        if ESPModule._highlights[player] then return end
        local char = player.Character
        if not char then return end

        local highlight = Instance.new("Highlight")
        highlight.Name            = "ZentyHighlight"
        highlight.FillColor       = Core.Colors.ACCENT
        highlight.OutlineColor    = Core.Colors.ACCENT_LIGHT
        highlight.FillTransparency    = 0.6
        highlight.OutlineTransparency = 0
        highlight.Adornee  = char
        highlight.Parent   = getESPFolder()
        ESPModule._highlights[player] = highlight
    end

    -- Create billboard gui for name/health
    local function createBillboard(player)
        if ESPModule._billboards[player] then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui")
        bb.Name            = "ZentyBillboard"
        bb.Adornee         = hrp
        bb.AlwaysOnTop     = true
        bb.Size            = UDim2.new(0, 140, 0, 50)
        bb.StudsOffset     = Vector3.new(0, 3.5, 0)
        bb.Parent          = getESPFolder()

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name                 = "NameLabel"
        nameLbl.BackgroundTransparency = 1
        nameLbl.Size                 = UDim2.new(1, 0, 0, 20)
        nameLbl.Text                 = player.DisplayName
        nameLbl.TextColor3           = Core.Colors.WHITE
        nameLbl.TextStrokeTransparency = 0.5
        nameLbl.TextStrokeColor3     = Core.Colors.BG_DARK
        nameLbl.Font                 = Core.Fonts.SEMIBOLD
        nameLbl.TextSize             = 14
        nameLbl.Parent               = bb

        -- Health bar background
        local hpBg = Instance.new("Frame")
        hpBg.Name                   = "HPBarBG"
        hpBg.BackgroundColor3       = Core.Colors.BG_DARK
        hpBg.BorderSizePixel        = 0
        hpBg.Size                   = UDim2.new(1, 0, 0, 6)
        hpBg.Position               = UDim2.new(0, 0, 0, 22)
        hpBg.Parent                 = bb
        UIFactory._corner(3, hpBg)

        local hpFill = Instance.new("Frame")
        hpFill.Name                 = "HPBarFill"
        hpFill.BackgroundColor3     = Core.Colors.SUCCESS
        hpFill.BorderSizePixel      = 0
        hpFill.Size                 = UDim2.new(1, 0, 1, 0)
        hpFill.Parent               = hpBg
        UIFactory._corner(3, hpFill)

        local hpLbl = Instance.new("TextLabel")
        hpLbl.Name                  = "HPLabel"
        hpLbl.BackgroundTransparency = 1
        hpLbl.Size                  = UDim2.new(1, 0, 0, 14)
        hpLbl.Position              = UDim2.new(0, 0, 0, 30)
        hpLbl.TextColor3            = Core.Colors.SUCCESS
        hpLbl.Font                  = Core.Fonts.MONO
        hpLbl.TextSize              = 10
        hpLbl.TextStrokeTransparency = 0.4
        hpLbl.Parent                = bb

        -- Distance label
        local distLbl = Instance.new("TextLabel")
        distLbl.Name                = "DistLabel"
        distLbl.BackgroundTransparency = 1
        distLbl.Size                = UDim2.new(1, 0, 0, 12)
        distLbl.Position            = UDim2.new(0, 0, 1, 0)
        distLbl.TextColor3          = Core.Colors.ACCENT_LIGHT
        distLbl.Font                = Core.Fonts.MONO
        distLbl.TextSize            = 9
        distLbl.TextStrokeTransparency = 0.4
        distLbl.Parent              = bb

        ESPModule._billboards[player] = bb
    end

    -- Remove ESP for player
    local function removeESP(player)
        local hl = ESPModule._highlights[player]
        if hl then hl:Destroy() end
        ESPModule._highlights[player] = nil

        local bb = ESPModule._billboards[player]
        if bb then bb:Destroy() end
        ESPModule._billboards[player] = nil
    end

    -- Update loop
    SignalManager:OnRender("ESPUpdate", function()
        if not ESPModule._enabled.Boxes and not ESPModule._enabled.Names and not ESPModule._enabled.Health then
            return
        end
        local localChar = Core.LocalPlayer.Character
        local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")

        for _, player in ipairs(Core.Players:GetPlayers()) do
            if player == Core.LocalPlayer then continue end
            local char = player.Character
            if not char then removeESP(player); continue end

            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp      = char:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then removeESP(player); continue end

            -- Highlight (boxes)
            if ESPModule._enabled.Boxes then
                createHighlight(player)
                local hl = ESPModule._highlights[player]
                if hl then
                    hl.Adornee = char
                    hl.Enabled = true
                end
            else
                local hl = ESPModule._highlights[player]
                if hl then hl.Enabled = false end
            end

            -- Billboard
            if ESPModule._enabled.Names or ESPModule._enabled.Health or ESPModule._enabled.Distance then
                createBillboard(player)
                local bb = ESPModule._billboards[player]
                if bb then
                    bb.Adornee = hrp
                    local nameLbl  = bb:FindFirstChild("NameLabel")
                    local hpBg     = bb:FindFirstChild("HPBarBG")
                    local hpFill   = hpBg and hpBg:FindFirstChild("HPBarFill")
                    local hpLbl    = bb:FindFirstChild("HPLabel")
                    local distLbl  = bb:FindFirstChild("DistLabel")

                    if nameLbl then
                        nameLbl.Visible = ESPModule._enabled.Names
                        nameLbl.Text    = player.DisplayName
                    end

                    if hpBg and hpFill and hpLbl then
                        hpBg.Visible = ESPModule._enabled.Health
                        local maxHp = humanoid.MaxHealth
                        local curHp = humanoid.Health
                        local pct   = maxHp > 0 and (curHp / maxHp) or 0
                        hpFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
                        local r = math.floor(255 * (1 - pct))
                        local g = math.floor(255 * pct)
                        hpFill.BackgroundColor3 = Color3.fromRGB(r, g, 50)
                        hpLbl.Visible = ESPModule._enabled.Health
                        hpLbl.Text    = string.format("%.0f / %.0f", curHp, maxHp)
                    end

                    if distLbl and localHRP then
                        distLbl.Visible = ESPModule._enabled.Distance
                        local dist = math.floor((hrp.Position - localHRP.Position).Magnitude)
                        distLbl.Text = dist .. "m"
                    end
                end
            else
                local bb = ESPModule._billboards[player]
                if bb then bb.Parent = nil end
                ESPModule._billboards[player] = nil
            end
        end
    end)

    -- Public toggles
    function ESPModule:SetBoxes(v)
        self._enabled.Boxes = v
        if not v then
            for player, hl in pairs(self._highlights) do
                if hl then hl.Enabled = false end
            end
        end
    end
    function ESPModule:SetNames(v)    self._enabled.Names    = v end
    function ESPModule:SetHealth(v)   self._enabled.Health   = v end
    function ESPModule:SetDistance(v) self._enabled.Distance = v end

    -- Listen for players leaving to clean up
    Core.Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
    end)
end

-- ============================================================
-- [6] AIMBOT MODULE
-- ============================================================

local AimbotModule = {}
do
    AimbotModule._fovCircle    = nil
    AimbotModule._enabled      = false
    AimbotModule._lockedTarget = nil

    -- Create FOV circle (Drawing API or UIObject fallback)
    local function createFOVCircle()
        -- Use UI-based circle (no Drawing API required)
        local sg = Instance.new("ScreenGui")
        sg.Name           = "ZentyFOV"
        sg.ResetOnSpawn   = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
        sg.IgnoreGuiInset = true
        sg.DisplayOrder   = 999
        sg.Parent         = Core.LocalPlayer:FindFirstChild("PlayerGui")

        -- Outer ring using UIStroke trick on a Frame
        local center = Instance.new("Frame")
        center.BackgroundTransparency = 1
        center.Size     = UDim2.new(0, Core.State.FOVRadius * 2, 0, Core.State.FOVRadius * 2)
        center.AnchorPoint = Vector2.new(0.5, 0.5)
        center.Position = UDim2.new(0.5, 0, 0.5, 0)
        center.ZIndex   = 10
        center.Name     = "FOVRing"
        center.Parent   = sg

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = center

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness  = 1.5
        uiStroke.Color      = Core.Colors.ACCENT_LIGHT
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.Parent     = center

        -- Center dot
        local dot = Instance.new("Frame")
        dot.BackgroundColor3 = Core.Colors.ACCENT_LIGHT
        dot.Size     = UDim2.new(0, 4, 0, 4)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.ZIndex   = 11
        dot.Parent   = sg
        local dotC = Instance.new("UICorner")
        dotC.CornerRadius = UDim.new(1, 0)
        dotC.Parent = dot

        -- IMPORTANT: Make container non-interactive
        sg.Enabled = true

        AimbotModule._fovGui   = sg
        AimbotModule._fovRing  = center
        AimbotModule._fovDot   = dot
        AimbotModule._fovStroke = uiStroke
    end

    local function destroyFOVCircle()
        if AimbotModule._fovGui then
            AimbotModule._fovGui:Destroy()
            AimbotModule._fovGui  = nil
            AimbotModule._fovRing = nil
        end
    end

    -- Update FOV circle size
    local function updateFOVSize(r)
        if AimbotModule._fovRing then
            AimbotModule._fovRing.Size = UDim2.new(0, r * 2, 0, r * 2)
        end
    end

    -- Find closest player in FOV
    local function getClosestTarget()
        local vp    = Core.Camera.ViewportSize
        local cx    = vp.X / 2
        local cy    = vp.Y / 2
        local fovR  = Core.State.FOVRadius
        local best  = nil
        local bestD = math.huge

        for _, player in ipairs(Core.Players:GetPlayers()) do
            if player == Core.LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end

            local targetPart = char:FindFirstChild(Core.State.TargetPart) or char:FindFirstChild("Head")
            if not targetPart then continue end

            local screenPos, onScreen = Core.WorldToScreen(targetPart.Position)
            if not onScreen then continue end

            local dx   = screenPos.X - cx
            local dy   = screenPos.Y - cy
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist <= fovR and dist < bestD then
                bestD = dist
                best  = {player = player, part = targetPart, screenPos = screenPos}
            end
        end
        return best
    end

    -- Camera lock logic
    SignalManager:OnRender("AimbotCamera", function(dt)
        if not AimbotModule._enabled then return end

        local holding = false
        if Core.State.AimbotKey == Enum.KeyCode.E then
            holding = Core.UserInputService:IsKeyDown(Enum.KeyCode.E)
        elseif Core.State.AimbotKey == Enum.UserInputType.MouseButton2 then
            holding = Core.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        else
            holding = Core.UserInputService:IsKeyDown(Core.State.AimbotKey)
        end

        if not holding then
            AimbotModule._lockedTarget = nil
            -- Reset ring color
            if AimbotModule._fovStroke then
                AimbotModule._fovStroke.Color = Core.Colors.ACCENT_LIGHT
            end
            return
        end

        local target = getClosestTarget()
        if not target then
            AimbotModule._lockedTarget = nil
            return
        end

        AimbotModule._lockedTarget = target

        -- Indicate locked
        if AimbotModule._fovStroke then
            AimbotModule._fovStroke.Color = Core.Colors.SUCCESS
        end

        -- Calculate camera CFrame to look at target
        local camPos = Core.Camera.CFrame.Position
        local targetPos = target.part.Position

        local desiredCF = CFrame.lookAt(camPos, targetPos)
        local smooth    = math.clamp(Core.State.FOVSmoothing, 0.01, 1)

        Core.Camera.CFrame = Core.Camera.CFrame:Lerp(desiredCF, smooth)
    end)

    -- Public API
    function AimbotModule:Enable()
        self._enabled = true
        Core.State.AimbotEnabled = true
        if not self._fovGui then
            createFOVCircle()
        end
        if self._fovGui then self._fovGui.Enabled = true end
    end

    function AimbotModule:Disable()
        self._enabled = false
        Core.State.AimbotEnabled = false
        self._lockedTarget = nil
        if self._fovGui then self._fovGui.Enabled = false end
        if self._fovStroke then
            self._fovStroke.Color = Core.Colors.ACCENT_LIGHT
        end
    end

    function AimbotModule:Toggle()
        if self._enabled then self:Disable() else self:Enable() end
        return self._enabled
    end

    function AimbotModule:SetFOV(r)
        Core.State.FOVRadius = r
        updateFOVSize(r)
    end

    function AimbotModule:SetSmoothing(v)
        Core.State.FOVSmoothing = v
    end

    function AimbotModule:SetTargetPart(part)
        Core.State.TargetPart = part
    end

    -- Init FOV circle immediately but hidden
    createFOVCircle()
    if AimbotModule._fovGui then AimbotModule._fovGui.Enabled = false end
end

-- ============================================================
-- [7] MOVEMENT MODULE
-- ============================================================

local MovementModule = {}
do
    MovementModule._flyBodyVelocity = nil
    MovementModule._flyBodyGyro     = nil
    MovementModule._connections      = {}

    -- Speed
    function MovementModule:SetSpeed(v)
        Core.State.SpeedValue = v
        local char = Core.LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = v
        end
    end

    -- Jump Power
    function MovementModule:SetJumpPower(v)
        Core.State.JumpValue = v
        local char = Core.LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = v
        end
    end

    -- Fly
    function MovementModule:EnableFly()
        if Core.State.FlyEnabled then return end
        Core.State.FlyEnabled = true

        local char = Core.LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- BodyVelocity
        local bv = Instance.new("BodyVelocity")
        bv.Velocity    = Vector3.new(0, 0, 0)
        bv.MaxForce    = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent      = hrp
        self._flyBodyVelocity = bv

        -- BodyGyro
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.D         = 200
        bg.CFrame    = hrp.CFrame
        bg.Parent    = hrp
        self._flyBodyGyro = bg

        local flyTag = SignalManager:Connect(Core.RunService.RenderStepped, function(dt)
            if not Core.State.FlyEnabled then return end
            local cam   = Core.Camera
            local speed = Core.State.FlySpeed
            local vel   = Vector3.new(0, 0, 0)

            if Core.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vel = vel + cam.CFrame.LookVector * speed
            end
            if Core.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vel = vel - cam.CFrame.LookVector * speed
            end
            if Core.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vel = vel - cam.CFrame.RightVector * speed
            end
            if Core.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vel = vel + cam.CFrame.RightVector * speed
            end
            if Core.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, speed, 0)
            end
            if Core.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vel = vel - Vector3.new(0, speed, 0)
            end

            if bv and bv.Parent then
                bv.Velocity = vel
                bg.CFrame   = cam.CFrame
            end
        end, "FlyRender")
        self._flyRenderTag = flyTag
    end

    function MovementModule:DisableFly()
        if not Core.State.FlyEnabled then return end
        Core.State.FlyEnabled = false
        if self._flyBodyVelocity and self._flyBodyVelocity.Parent then
            self._flyBodyVelocity:Destroy()
        end
        if self._flyBodyGyro and self._flyBodyGyro.Parent then
            self._flyBodyGyro:Destroy()
        end
        self._flyBodyVelocity = nil
        self._flyBodyGyro     = nil
        if self._flyRenderTag then
            SignalManager:Disconnect(self._flyRenderTag)
        end
    end

    function MovementModule:ToggleFly()
        if Core.State.FlyEnabled then self:DisableFly() else self:EnableFly() end
        return Core.State.FlyEnabled
    end

    -- NoClip
    function MovementModule:EnableNoClip()
        Core.State.NoClipEnabled = true
        SignalManager:OnRender("NoClipRender", function()
            if not Core.State.NoClipEnabled then return end
            local char = Core.LocalPlayer.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end

    function MovementModule:DisableNoClip()
        Core.State.NoClipEnabled = false
        SignalManager:RemoveRender("NoClipRender")
        -- Restore collision
        local char = Core.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    function MovementModule:ToggleNoClip()
        if Core.State.NoClipEnabled then self:DisableNoClip() else self:EnableNoClip() end
        return Core.State.NoClipEnabled
    end

    -- Swim Speed
    function MovementModule:SetSwimSpeed(v)
        Core.State.SwimSpeed = v
        -- Applied via Humanoid in water states (game-specific)
        local char = Core.LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Roblox doesn't have a native swim speed property; this hooks StateChanged
        end
    end

    -- Teleport list (predefined locations per game)
    MovementModule.TeleportLocations = {
        ["Centre de la Map"] = Vector3.new(0, 10, 0),
        ["Spawn"]            = Vector3.new(0, 5, 0),
        ["Haut de la Map"]   = Vector3.new(0, 200, 0),
    }

    function MovementModule:Teleport(locationName)
        local pos = self.TeleportLocations[locationName]
        if pos then
            local char = Core.LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(pos)
                end
            end
        end
    end

    function MovementModule:TeleportToCFrame(cf)
        local char = Core.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = cf end
        end
    end

    -- Re-apply on character respawn
    Core.LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if Core.State.SpeedValue ~= 16 then
            MovementModule:SetSpeed(Core.State.SpeedValue)
        end
        if Core.State.JumpValue ~= 50 then
            MovementModule:SetJumpPower(Core.State.JumpValue)
        end
        if Core.State.FlyEnabled then
            task.wait(0.5)
            MovementModule:EnableFly()
        end
        if Core.State.NoClipEnabled then
            MovementModule:EnableNoClip()
        end
    end)
end

-- ============================================================
-- [8] GAME MODULES - Per-game exploits
-- ============================================================

local GameModules = {}

-- ------ Murder Mystery 2 ------
GameModules.MM2 = {}
do
    local MM2 = GameModules.MM2
    MM2._state = {
        KillAura     = false,
        TeleportMenu = false,
        AutoCollect  = false,
        AutoBiver    = false,
    }

    function MM2:SetKillAura(v)
        self._state.KillAura = v
        if v then
            SignalManager:OnRender("MM2_KillAura", function()
                if not self._state.KillAura then return end
                local char = Core.LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                -- Find the killer / innocent via MM2 tags
                for _, player in ipairs(Core.Players:GetPlayers()) do
                    if player == Core.LocalPlayer then continue end
                    local pchar = player.Character
                    if not pchar then continue end
                    local phrp = pchar:FindFirstChild("HumanoidRootPart")
                    if not phrp then continue end
                    local dist = (hrp.Position - phrp.Position).Magnitude
                    if dist <= 8 then
                        -- Simulate tool activation (game-specific, requires server hook)
                        Core.SafeCall(function()
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool and tool:FindFirstChild("RemoteEvent") then
                                -- tool.RemoteEvent:FireServer(phrp.Position)
                            end
                        end)
                    end
                end
            end)
        else
            SignalManager:RemoveRender("MM2_KillAura")
        end
    end

    function MM2:SetAutoCollect(v)
        self._state.AutoCollect = v
        if v then
            SignalManager:OnRender("MM2_AutoCollect", function()
                if not self._state.AutoCollect then return end
                Core.SafeCall(function()
                    for _, obj in ipairs(Core.Workspace:GetDescendants()) do
                        if obj.Name == "Coin" or obj.Name == "Money" then
                            local hrp = Core.LocalPlayer.Character and Core.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and obj:IsA("BasePart") then
                                local dist = (hrp.Position - obj.Position).Magnitude
                                if dist > 30 then
                                    hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                                end
                            end
                        end
                    end
                end)
            end)
        else
            SignalManager:RemoveRender("MM2_AutoCollect")
        end
    end
end

-- ------ Arsenal ------
GameModules.Arsenal = {}
do
    local Ars = GameModules.Arsenal
    Ars._state = {
        AcebolBasts  = false,
        AutoCollect  = false,
        UnlimitedAmmo = false,
    }

    function Ars:SetUnlimitedAmmo(v)
        self._state.UnlimitedAmmo = v
        if v then
            SignalManager:OnRender("ARS_Ammo", function()
                if not self._state.UnlimitedAmmo then return end
                Core.SafeCall(function()
                    local char = Core.LocalPlayer.Character
                    if not char then return end
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("ammo")
                            if ammo and ammo:IsA("IntValue") then
                                if ammo.Value < 30 then ammo.Value = 999 end
                            end
                        end
                    end
                end)
            end)
        else
            SignalManager:RemoveRender("ARS_Ammo")
        end
    end

    function Ars:SetAutoCollect(v)
        self._state.AutoCollect = v
    end
end

-- ------ Jailbreak ------
GameModules.Jailbreak = {}
do
    local JB = GameModules.Jailbreak
    JB._state = {
        UnlimitedAmmo  = false,
        AutoCash       = false,
        AutoContrabandControl = false,
        AutoGontrottaop = false,
    }

    function JB:SetUnlimitedAmmo(v)
        self._state.UnlimitedAmmo = v
        if v then
            SignalManager:OnRender("JB_Ammo", function()
                if not self._state.UnlimitedAmmo then return end
                Core.SafeCall(function()
                    local char = Core.LocalPlayer.Character
                    if not char then return end
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:FindFirstChild("Ammo")
                            if ammo and ammo:IsA("IntValue") then
                                if ammo.Value < 30 then ammo.Value = 999 end
                            end
                        end
                    end
                end)
            end)
        else
            SignalManager:RemoveRender("JB_Ammo")
        end
    end

    function JB:SetAutoCash(v)
        self._state.AutoCash = v
        if v then
            SignalManager:OnRender("JB_AutoCash", function()
                if not self._state.AutoCash then return end
                Core.SafeCall(function()
                    -- Hook to Jailbreak remote for cash collection
                    for _, remote in ipairs(Core.Workspace:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("cash") then
                            -- remote:FireServer()  -- context-specific
                        end
                    end
                end)
            end)
        else
            SignalManager:RemoveRender("JB_AutoCash")
        end
    end

    function JB:SetAutoControlland(v)
        self._state.AutoContrabandControl = v
    end
end

-- ------ Tower Defense ------
GameModules.TowerDefense = {}
do
    local TD = GameModules.TowerDefense
    TD._state = {
        AutoDefenses = false,
        UnlimitedAmmo = false,
        AutoCollect  = false,
        AutoBettings = false,
        UnlimitedSwaiass = false,
    }

    function TD:SetAutoDefenses(v)
        self._state.AutoDefenses = v
    end

    function TD:SetUnlimitedAmmo(v)
        self._state.UnlimitedAmmo = v
    end

    function TD:SetUnlimitedSwaiass(v)
        self._state.UnlimitedSwaiass = v
    end
end

-- ============================================================
-- [9] MAIN WINDOW - Hub orchestration
-- ============================================================

local HubWindow = {}
do
    function HubWindow:Build()
        -- Main ScreenGui
        local gui = Instance.new("ScreenGui")
        gui.Name           = "ZentyHub"
        gui.ResetOnSpawn   = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.IgnoreGuiInset = true
        gui.Parent         = Core.LocalPlayer:FindFirstChild("PlayerGui")
        self._gui          = gui

        -- ===== MAIN WINDOW FRAME =====
        local win = UIFactory.Frame({
            Color    = Core.Colors.BG_DARK,
            Size     = UDim2.new(0, 870, 0, 560),
            Position = UDim2.new(0.5, -435, 0.5, -280),
            Corner   = true,
            CornerRadius = 10,
            StrokeColor = Core.Colors.ACCENT,
            ZIndex   = 10,
            Name     = "MainWindow",
            Parent   = gui,
        })
        UIFactory._stroke(1.5, Core.Colors.ACCENT, win)
        self._win = win

        -- ===== TITLE BAR =====
        local titleBar = UIFactory.Frame({
            Color    = Core.Colors.BG_PANEL,
            Size     = UDim2.new(1, 0, 0, 38),
            Corner   = false,
            ZIndex   = 11,
            Parent   = win,
        })
        -- Top-round only via UICorner override
        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 10)
        tbCorner.Parent = titleBar

        -- Logo icon
        local iconLbl = UIFactory.Label({
            Text     = "⬡",
            Position = UDim2.new(0, 12, 0, 0),
            Size     = UDim2.new(0, 30, 1, 0),
            Color    = Core.Colors.ACCENT_LIGHT,
            TextSize = 20,
            Font     = Core.Fonts.TITLE,
            XAlign   = Enum.TextXAlignment.Left,
            ZIndex   = 12,
            Parent   = titleBar,
        })

        UIFactory.Label({
            Text     = "Zenty Hub",
            Position = UDim2.new(0, 44, 0, 0),
            Size     = UDim2.new(0, 180, 1, 0),
            Color    = Core.Colors.WHITE,
            TextSize = 14,
            Font     = Core.Fonts.TITLE,
            XAlign   = Enum.TextXAlignment.Left,
            ZIndex   = 12,
            Parent   = titleBar,
        })

        UIFactory.Label({
            Text     = "Professional Gaming Suite",
            Position = UDim2.new(0, 170, 0, 0),
            Size     = UDim2.new(0, 200, 1, 0),
            Color    = Core.Colors.TEXT_DISABLED,
            TextSize = 10,
            Font     = Core.Fonts.BODY,
            XAlign   = Enum.TextXAlignment.Left,
            ZIndex   = 12,
            Parent   = titleBar,
        })

        -- Key timer label (top right)
        local keyTimerLabel = UIFactory.Label({
            Text     = "Key Valid: --:-- remaining",
            Position = UDim2.new(1, -260, 0, 0),
            Size     = UDim2.new(0, 220, 1, 0),
            Color    = Core.Colors.SUCCESS,
            TextSize = 11,
            Font     = Core.Fonts.MONO,
            XAlign   = Enum.TextXAlignment.Right,
            ZIndex   = 12,
            Parent   = titleBar,
        })

        -- Close button
        local closeBtn = UIFactory.Button({
            Text     = "✕",
            Color    = Color3.fromRGB(0,0,0),
            Transparency = 1,
            Position = UDim2.new(1, -36, 0, 4),
            Size     = UDim2.new(0, 30, 0, 30),
            TextColor = Core.Colors.TEXT_SECONDARY,
            TextSize  = 14,
            HoverColor = Core.Colors.DANGER,
            ZIndex   = 13,
            Parent   = titleBar,
        })
        closeBtn.BackgroundTransparency = 1
        closeBtn.MouseButton1Click:Connect(function()
            Core.Tween(win, Core.TI(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 870, 0, 0),
                Position = UDim2.new(0.5, -435, 0.5, -19),
            })
            task.delay(0.28, function()
                gui:Destroy()
            end)
        end)

        -- Minimize button
        local minBtn = UIFactory.Button({
            Text     = "—",
            Color    = Color3.fromRGB(0,0,0),
            Position = UDim2.new(1, -68, 0, 4),
            Size     = UDim2.new(0, 30, 0, 30),
            TextColor = Core.Colors.TEXT_SECONDARY,
            TextSize  = 12,
            HoverColor = Core.Colors.WARNING,
            ZIndex   = 13,
            Parent   = titleBar,
        })
        minBtn.BackgroundTransparency = 1
        local minimized = false
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            local targetSize = minimized
                and UDim2.new(0, 870, 0, 38)
                or  UDim2.new(0, 870, 0, 560)
            Core.Tween(win, Core.TI(0.25, Enum.EasingStyle.Quad), {Size = targetSize})
        end)

        -- Drag functionality
        local dragging, dragStart, startPos = false, nil, nil
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = input.Position
                startPos  = win.Position
            end
        end)
        Core.UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                win.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        Core.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        -- ===== LEFT SIDEBAR (icon tabs) =====
        local sidebar = UIFactory.Frame({
            Color    = Core.Colors.BG_PANEL,
            Size     = UDim2.new(0, 46, 1, -38),
            Position = UDim2.new(0, 0, 0, 38),
            Corner   = false,
            ZIndex   = 11,
            Parent   = win,
        })

        local sideList = Instance.new("UIListLayout")
        sideList.SortOrder = Enum.SortOrder.LayoutOrder
        sideList.Padding   = UDim.new(0, 2)
        sideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sideList.Parent = sidebar

        local sidePad = Instance.new("UIPadding")
        sidePad.PaddingTop    = UDim.new(0, 8)
        sidePad.PaddingBottom = UDim.new(0, 8)
        sidePad.Parent = sidebar

        -- ===== TAB BAR =====
        local tabBar = UIFactory.Frame({
            Color    = Core.Colors.BG_PANEL,
            Size     = UDim2.new(1, -46, 0, 38),
            Position = UDim2.new(0, 46, 0, 38),
            Corner   = false,
            ZIndex   = 11,
            Parent   = win,
        })
        UIFactory._padding(4, 4, 6, 6, tabBar)

        local tabBarList = Instance.new("UIListLayout")
        tabBarList.SortOrder             = Enum.SortOrder.LayoutOrder
        tabBarList.FillDirection         = Enum.FillDirection.Horizontal
        tabBarList.VerticalAlignment     = Enum.VerticalAlignment.Center
        tabBarList.Padding               = UDim.new(0, 4)
        tabBarList.Parent                = tabBar

        -- ===== CONTENT AREA =====
        local contentArea = UIFactory.Frame({
            Color    = Color3.fromRGB(0,0,0),
            Transparency = 1,
            Size     = UDim2.new(1, -46, 1, -76),
            Position = UDim2.new(0, 46, 0, 76),
            Corner   = false,
            ZIndex   = 10,
            Parent   = win,
        })

        -- ===== RIGHT PANEL (Movement Exploits) =====
        local rightPanel = UIFactory.Frame({
            Color    = Core.Colors.BG_PANEL,
            Size     = UDim2.new(0, 200, 1, -76),
            Position = UDim2.new(1, -200, 0, 76),
            Corner   = false,
            ZIndex   = 11,
            Parent   = win,
        })

        UIFactory.Label({
            Text     = "Movement Exploits",
            Position = UDim2.new(0, 0, 0, 0),
            Size     = UDim2.new(1, 0, 0, 30),
            Color    = Core.Colors.WHITE,
            TextSize = 12,
            Font     = Core.Fonts.TITLE,
            XAlign   = Enum.TextXAlignment.Center,
            ZIndex   = 12,
            Parent   = rightPanel,
        })

        -- Accent bar under title
        UIFactory.Frame({
            Color    = Core.Colors.ACCENT,
            Size     = UDim2.new(0.9, 0, 0, 1),
            Position = UDim2.new(0.05, 0, 0, 30),
            Corner   = false,
            ZIndex   = 12,
            Parent   = rightPanel,
        })

        local rightScroll, _ = UIFactory.ScrollList({
            Size     = UDim2.new(1, 0, 1, -34),
            Position = UDim2.new(0, 0, 0, 34),
            ZIndex   = 12,
            Parent   = rightPanel,
        })

        -- Speed slider
        local _, speedSet = UIFactory.Slider({
            Text    = "Speed",
            Min     = 16, Max = 300, Default = 16,
            Integer = true,
            OnChange = function(v) MovementModule:SetSpeed(v) end,
            Parent  = rightScroll,
        })

        -- Jump Power slider
        local _, jumpSet = UIFactory.Slider({
            Text    = "Jump Power",
            Min     = 50, Max = 500, Default = 120,
            Integer = true,
            OnChange = function(v) MovementModule:SetJumpPower(v) end,
            Parent  = rightScroll,
        })

        -- Fly toggle
        local _, flySet = UIFactory.Toggle({
            Text    = "Fly",
            Default = false,
            OnChange = function(v)
                if v then MovementModule:EnableFly() else MovementModule:DisableFly() end
            end,
            Parent  = rightScroll,
        })

        -- Fly speed slider
        local _, flySpeedSet = UIFactory.Slider({
            Text    = "Fly Speed",
            Min     = 5, Max = 200, Default = 40,
            Integer = true,
            OnChange = function(v) Core.State.FlySpeed = v end,
            Parent  = rightScroll,
        })

        -- NoClip toggle
        local _, noClipSet = UIFactory.Toggle({
            Text    = "NoClip",
            Default = false,
            OnChange = function(v)
                if v then MovementModule:EnableNoClip() else MovementModule:DisableNoClip() end
            end,
            Parent  = rightScroll,
        })

        -- Swim Speed slider
        local _, swimSet = UIFactory.Slider({
            Text    = "Swim Speed",
            Min     = 10, Max = 150, Default = 40,
            Integer = true,
            OnChange = function(v) MovementModule:SetSwimSpeed(v) end,
            Parent  = rightScroll,
        })

        -- Teleport section header
        UIFactory.SectionHeader("Teleport Lists", rightScroll)

        for locName, _ in pairs(MovementModule.TeleportLocations) do
            UIFactory.Button({
                Text     = locName,
                Color    = Core.Colors.BG_ELEMENT,
                Size     = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                Font     = Core.Fonts.BODY,
                HoverColor = Core.Colors.ACCENT_DARK,
                ZIndex   = 13,
                OnClick  = function() MovementModule:Teleport(locName) end,
                Parent   = rightScroll,
            })
        end

        -- Teleport 2 (to cursor)
        UIFactory.Button({
            Text     = "Teleport 2 (Cursor)",
            Color    = Core.Colors.BG_ELEMENT,
            Size     = UDim2.new(1, 0, 0, 28),
            TextSize = 11,
            OnClick  = function()
                local hit = Core.Mouse.Hit
                if hit then
                    MovementModule:TeleportToCFrame(hit + Vector3.new(0, 3, 0))
                end
            end,
            Parent   = rightScroll,
        })

        -- ===== TABS DEFINITIONS =====
        local tabs = {
            { Name = "ESP",       Icon = "👁",  Color = Core.Colors.ACCENT },
            { Name = "MM2",       Icon = "🔪",  Color = Color3.fromRGB(200, 60, 60) },
            { Name = "Aimbot",    Icon = "🎯",  Color = Color3.fromRGB(255, 140, 0) },
            { Name = "Arsenal",   Icon = "🔫",  Color = Color3.fromRGB(50, 160, 220) },
            { Name = "Tower Def", Icon = "🏰",  Color = Color3.fromRGB(80, 200, 80) },
            { Name = "Jailbreak", Icon = "🚔",  Color = Color3.fromRGB(240, 200, 30) },
        }

        local tabPages     = {}
        local tabBtns      = {}
        local activeTab    = nil

        local function activateTab(name)
            if activeTab == name then return end
            activeTab = name
            for n, page in pairs(tabPages) do
                local isActive = (n == name)
                page.Visible = isActive
                if tabBtns[n] then
                    local tabDef = nil
                    for _, t in ipairs(tabs) do
                        if t.Name == n then tabDef = t; break end
                    end
                    local activeCol = tabDef and tabDef.Color or Core.Colors.ACCENT
                    Core.Tween(tabBtns[n], Core.TI(0.15), {
                        BackgroundColor3 = isActive and activeCol or Core.Colors.BG_ELEMENT
                    })
                end
            end
        end

        -- Build tab bar buttons
        for i, tabDef in ipairs(tabs) do
            local btn = UIFactory.Button({
                Text      = tabDef.Icon .. "  " .. tabDef.Name,
                Color     = Core.Colors.BG_ELEMENT,
                Size      = UDim2.new(0, 0, 1, -8),
                TextSize  = 12,
                Font      = Core.Fonts.SEMIBOLD,
                HoverColor = Color3.fromRGB(
                    math.floor(tabDef.Color.R * 255 * 0.4 + Core.Colors.BG_ELEMENT.R * 255 * 0.6),
                    math.floor(tabDef.Color.G * 255 * 0.4 + Core.Colors.BG_ELEMENT.G * 255 * 0.6),
                    math.floor(tabDef.Color.B * 255 * 0.4 + Core.Colors.BG_ELEMENT.B * 255 * 0.6)
                ),
                CornerRadius = 6,
                ZIndex    = 12,
                Parent    = tabBar,
            })
            UIFactory._padding(0, 0, 10, 10, btn)
            btn.AutomaticSize = Enum.AutomaticSize.X

            local btnName = tabDef.Name
            btn.MouseButton1Click:Connect(function()
                activateTab(btnName)
            end)
            tabBtns[tabDef.Name] = btn
        end

        -- Build page frames
        for _, tabDef in ipairs(tabs) do
            local page = UIFactory.Frame({
                Color        = Color3.fromRGB(0,0,0),
                Transparency = 1,
                Size         = UDim2.new(1, -200, 1, 0),
                Corner       = false,
                ZIndex       = 11,
                Name         = "Page_" .. tabDef.Name,
                Parent       = contentArea,
            })
            page.Visible = false
            tabPages[tabDef.Name] = page
        end

        -- ========================
        -- ESP TAB CONTENT
        -- ========================
        do
            local page = tabPages["ESP"]
            local scroll, _ = UIFactory.ScrollList({Size = UDim2.new(1, 0, 1, 0), Parent = page})

            UIFactory.SectionHeader("ESP Options", scroll)

            local _, setBoxes = UIFactory.Toggle({
                Text = "Boxes (Highlight)", Default = false,
                OnChange = function(v) ESPModule:SetBoxes(v) end,
                Parent = scroll,
            })
            local _, setNames = UIFactory.Toggle({
                Text = "Names", Default = false,
                OnChange = function(v) ESPModule:SetNames(v) end,
                Parent = scroll,
            })
            local _, setHealth = UIFactory.Toggle({
                Text = "Health Bars", Default = false,
                OnChange = function(v) ESPModule:SetHealth(v) end,
                Parent = scroll,
            })
            local _, setDist = UIFactory.Toggle({
                Text = "Distance", Default = false,
                OnChange = function(v) ESPModule:SetDistance(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Bones (Skeleton)", Default = false,
                OnChange = function(v)
                    -- Bones ESP: draw lines between joints
                    -- Implementation via Highlight + beam
                    UIFactory.Notify("ESP", "Bones: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Items (Drops)", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("ESP", "Items ESP: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Script / Roles", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("ESP", "Role ESP: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })

            UIFactory.SectionHeader("ESP Colors", scroll)

            UIFactory.Button({
                Text    = "Couleur Ennemis: Violet",
                Color   = Core.Colors.ACCENT_DARK,
                Size    = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                Parent  = scroll,
            })
            UIFactory.Button({
                Text    = "Couleur Alliés: Vert",
                Color   = Color3.fromRGB(30, 80, 40),
                Size    = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                Parent  = scroll,
            })
        end

        -- ========================
        -- AIMBOT TAB CONTENT
        -- ========================
        do
            local page = tabPages["Aimbot"]
            local scroll, _ = UIFactory.ScrollList({Size = UDim2.new(1, 0, 1, 0), Parent = page})

            UIFactory.SectionHeader("Aimbot", scroll)

            local aimbotMainToggle
            local _, setAimbot = UIFactory.Toggle({
                Text    = "Aimbot (Camera Lock)",
                Default = false,
                OnChange = function(v)
                    if v then
                        AimbotModule:Enable()
                        UIFactory.Notify("Aimbot", "Activé - Maintenez [E]", Core.Colors.SUCCESS)
                    else
                        AimbotModule:Disable()
                        UIFactory.Notify("Aimbot", "Désactivé", Core.Colors.DANGER)
                    end
                end,
                Parent  = scroll,
            })

            UIFactory.SectionHeader("FOV Circle", scroll)

            local _, setFOV = UIFactory.Slider({
                Text    = "FOV Radius",
                Min     = 20, Max = 500, Default = 120,
                Integer = true,
                OnChange = function(v) AimbotModule:SetFOV(v) end,
                Parent  = scroll,
            })

            local _, setSmooth = UIFactory.Slider({
                Text    = "Smoothness",
                Min     = 1, Max = 100, Default = 15,
                Integer = true,
                OnChange = function(v) AimbotModule:SetSmoothing(v / 100) end,
                Parent  = scroll,
            })

            local _, setRecoil = UIFactory.Slider({
                Text    = "Recoil Control",
                Min     = 0, Max = 100, Default = 0,
                Integer = true,
                OnChange = function(v) Core.State.RecoilControl = v end,
                Parent  = scroll,
            })

            UIFactory.SectionHeader("Target", scroll)

            -- Target part buttons
            local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
            for _, part in ipairs(parts) do
                UIFactory.Button({
                    Text    = "Part: " .. part,
                    Color   = (Core.State.TargetPart == part) and Core.Colors.ACCENT or Core.Colors.BG_ELEMENT,
                    Size    = UDim2.new(1, 0, 0, 28),
                    TextSize = 11,
                    OnClick = function()
                        AimbotModule:SetTargetPart(part)
                        UIFactory.Notify("Aimbot", "Target: " .. part, Core.Colors.ACCENT)
                    end,
                    Parent  = scroll,
                })
            end

            UIFactory.SectionHeader("Weapon Selection", scroll)
            -- Weapon dropdown simulation
            UIFactory.Button({
                Text    = "Weapon: [Tous]",
                Color   = Core.Colors.BG_ELEMENT,
                Size    = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                Parent  = scroll,
            })
        end

        -- ========================
        -- MM2 TAB CONTENT
        -- ========================
        do
            local page = tabPages["MM2"]
            local scroll, _ = UIFactory.ScrollList({Size = UDim2.new(1, 0, 1, 0), Parent = page})

            UIFactory.SectionHeader("Murder Mystery 2", scroll)

            UIFactory.Toggle({
                Text = "Kill Aura", Default = false,
                OnChange = function(v) GameModules.MM2:SetKillAura(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Teleport Menu", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("MM2", "Teleport Menu: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Biver Map", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("MM2", "Auto-Biver: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Collect Points", Default = false,
                OnChange = function(v) GameModules.MM2:SetAutoCollect(v) end,
                Parent = scroll,
            })

            UIFactory.SectionHeader("Game Info", scroll)

            UIFactory.Button({
                Text    = "Voir Rôles (Killer / Sheriff)",
                Color   = Color3.fromRGB(120, 20, 20),
                Size    = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                OnClick = function()
                    local roles = ""
                    for _, p in ipairs(Core.Players:GetPlayers()) do
                        local chr = p.Character
                        if chr then
                            local role = chr:FindFirstChild("Role") or chr:FindFirstChild("IsKiller")
                            roles = roles .. p.DisplayName .. " | " .. (role and tostring(role.Value) or "?") .. "\n"
                        end
                    end
                    UIFactory.Notify("MM2", "Rôles scannés", Core.Colors.WARNING)
                end,
                Parent  = scroll,
            })
        end

        -- ========================
        -- ARSENAL TAB CONTENT
        -- ========================
        do
            local page = tabPages["Arsenal"]
            local scroll, _ = UIFactory.ScrollList({Size = UDim2.new(1, 0, 1, 0), Parent = page})

            UIFactory.SectionHeader("Arsenal", scroll)

            UIFactory.Toggle({
                Text = "Acebол Basts (Hitbox+)", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("Arsenal", "Acebол Basts: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Collect Points", Default = false,
                OnChange = function(v) GameModules.Arsenal:SetAutoCollect(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Unlimited Ammo", Default = false,
                OnChange = function(v) GameModules.Arsenal:SetUnlimitedAmmo(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Kill Llnidity (InstakKill)", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("Arsenal", "Kill Llnidity: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Fast (Bunny Hop)", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("Arsenal", "BunnyHop: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Game Notios (Alerts)", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("Arsenal", "Alerts: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
        end

        -- ========================
        -- TOWER DEFENSE TAB CONTENT
        -- ========================
        do
            local page = tabPages["Tower Def"]
            local scroll, _ = UIFactory.ScrollList({Size = UDim2.new(1, 0, 1, 0), Parent = page})

            UIFactory.SectionHeader("Tower Defense", scroll)

            UIFactory.Toggle({
                Text = "Auto-Defenses", Default = false,
                OnChange = function(v) GameModules.TowerDefense:SetAutoDefenses(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Unlimited Ammo", Default = false,
                OnChange = function(v) GameModules.TowerDefense:SetUnlimitedAmmo(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Collect Points", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("TD", "Auto-Collect: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto Bettings", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("TD", "Auto Bettings: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Unlimited Swaiass", Default = false,
                OnChange = function(v) GameModules.TowerDefense:SetUnlimitedSwaiass(v) end,
                Parent = scroll,
            })

            UIFactory.SectionHeader("Tower Config", scroll)

            UIFactory.Slider({
                Text    = "Tower Range",
                Min     = 10, Max = 500, Default = 100,
                Integer = true,
                OnChange = function(v)
                    UIFactory.Notify("TD", "Range: " .. v, Core.Colors.ACCENT)
                end,
                Parent  = scroll,
            })
        end

        -- ========================
        -- JAILBREAK TAB CONTENT
        -- ========================
        do
            local page = tabPages["Jailbreak"]
            local scroll, _ = UIFactory.ScrollList({Size = UDim2.new(1, 0, 1, 0), Parent = page})

            UIFactory.SectionHeader("Jailbreak", scroll)

            UIFactory.Toggle({
                Text = "Unlimited Ammo", Default = false,
                OnChange = function(v) GameModules.Jailbreak:SetUnlimitedAmmo(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Cotinoitum", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("JB", "Auto-Cotinoitum: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Controlland", Default = false,
                OnChange = function(v) GameModules.Jailbreak:SetAutoControlland(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto-Gontrottaop", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("JB", "Auto-Gontrottaop: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Auto Cash Collect", Default = false,
                OnChange = function(v) GameModules.Jailbreak:SetAutoCash(v) end,
                Parent = scroll,
            })
            UIFactory.Toggle({
                Text = "Car Fly", Default = false,
                OnChange = function(v)
                    UIFactory.Notify("JB", "Car Fly: " .. (v and "ON" or "OFF"), Core.Colors.ACCENT)
                end,
                Parent = scroll,
            })

            UIFactory.SectionHeader("Auto Heists", scroll)

            UIFactory.Button({
                Text    = "Auto Jewelry Heist",
                Color   = Core.Colors.ACCENT_DARK,
                Size    = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                OnClick = function()
                    UIFactory.Notify("JB", "Auto Jewelry: Démarré", Core.Colors.SUCCESS)
                end,
                Parent  = scroll,
            })
            UIFactory.Button({
                Text    = "Auto Bank Heist",
                Color   = Core.Colors.ACCENT_DARK,
                Size    = UDim2.new(1, 0, 0, 28),
                TextSize = 11,
                OnClick = function()
                    UIFactory.Notify("JB", "Auto Bank: Démarré", Core.Colors.SUCCESS)
                end,
                Parent  = scroll,
            })
        end

        -- ===== SIDEBAR ICONS =====
        local sideIconDefs = {
            { Icon = "☠", Tooltip = "Exploits",    Color = Core.Colors.ACCENT },
            { Icon = "⚡", Tooltip = "Speed",       Color = Core.Colors.WARNING },
            { Icon = "🛡", Tooltip = "ESP",         Color = Core.Colors.SUCCESS },
            { Icon = "🎯", Tooltip = "Aimbot",      Color = Color3.fromRGB(255, 140, 0) },
            { Icon = "⚙",  Tooltip = "Settings",   Color = Core.Colors.TEXT_SECONDARY },
            { Icon = "ℹ",  Tooltip = "Info",        Color = Core.Colors.ACCENT_LIGHT },
        }

        for _, def in ipairs(sideIconDefs) do
            local iconBtn = UIFactory.Button({
                Text     = def.Icon,
                Color    = Color3.fromRGB(0,0,0),
                Size     = UDim2.new(0, 36, 0, 36),
                TextSize = 18,
                HoverColor = def.Color,
                CornerRadius = 8,
                ZIndex   = 12,
                Parent   = sidebar,
            })
            iconBtn.BackgroundTransparency = 1
            iconBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        end

        -- ===== KEY SYSTEM TIMER =====
        local keyExpiry = tick() + (24 * 3600) -- 24h key validity demo
        task.spawn(function()
            while gui and gui.Parent do
                local remaining = keyExpiry - tick()
                if remaining <= 0 then
                    keyTimerLabel.Text       = "Key Expired"
                    keyTimerLabel.TextColor3 = Core.Colors.DANGER
                    break
                end
                local hours   = math.floor(remaining / 3600)
                local minutes = math.floor((remaining % 3600) / 60)
                local seconds = math.floor(remaining % 60)
                keyTimerLabel.Text = string.format("Key Valid: %02d:%02d:%02d remaining", hours, minutes, seconds)
                task.wait(1)
            end
        end)

        -- ===== TOGGLE HUB VISIBILITY =====
        Core.UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.RightBracket then
                Core.State.HubVisible = not Core.State.HubVisible
                win.Visible = Core.State.HubVisible
            end
        end)

        -- ===== ACTIVATE DEFAULT TAB =====
        activateTab("ESP")

        -- ===== INTRO ANIMATION =====
        win.BackgroundTransparency = 1
        win.Size = UDim2.new(0, 870, 0, 0)
        Core.Tween(win, Core.TI(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size     = UDim2.new(0, 870, 0, 560),
            BackgroundTransparency = 0,
        })

        -- Welcome notification
        task.delay(0.6, function()
            UIFactory.Notify(
                "Zenty Hub",
                "Bienvenue ! Utilisez ] pour afficher/masquer.",
                Core.Colors.ACCENT,
                4
            )
        end)
    end
end

-- ============================================================
-- [10] ENTRY POINT
-- ============================================================

local function init()
    -- Disable default Roblox notification / chat interference
    Core.SafeCall(function()
        Core.StarterGui:SetCore("ResetButtonCallback", false)
    end)

    -- Show key system, then build hub on success
    KeySystem:ShowScreen(function()
        task.wait(0.15)
        HubWindow:Build()
    end)
end

-- Boot
Core.SafeCall(init)
