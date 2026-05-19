--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           KICK A LUCKY BLOCK — PREMIUM AUTO FARM            ║
    ║                     by AetherScripts                        ║
    ║                        v2.0.0                               ║
    ╚══════════════════════════════════════════════════════════════╝

    Features:
      ✦ Auto Farm (kick blocks automatically)
      ✦ Auto Collect (coins / items)
      ✦ Auto Rebirth
      ✦ Auto Equip Best item
      ✦ Teleport System (Farm zone / Rebirth zone)
      ✦ Anti AFK
      ✦ Tween smooth movement
      ✦ Mobile support (tap-friendly buttons)
      ✦ Notifications system
      ✦ Save settings (via writefile / readfile)
      ✦ Draggable GUI
      ✦ Toggle buttons with animated state
      ✦ Dark blue / black neon design

    NOTE: Inject via a supported executor (Synapse, KRNL, Fluxus, etc.)
          Works on PC and Mobile.
]]

-- ─────────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────────
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local StarterGui         = game:GetService("StarterGui")
local VirtualInputManager = game:FindService("VirtualInputManager") -- mobile

-- ─────────────────────────────────────────────────────────────────
--  LOCAL PLAYER / CHARACTER
-- ─────────────────────────────────────────────────────────────────
local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Character    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid     = Character:WaitForChild("Humanoid")

-- Re-grab character on respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character        = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid         = newChar:WaitForChild("Humanoid")
end)

-- ─────────────────────────────────────────────────────────────────
--  SETTINGS (saved / loaded)
-- ─────────────────────────────────────────────────────────────────
local SETTINGS_FILE = "AetherKLB_Settings.json"

local DefaultSettings = {
    AutoFarm     = false,
    AutoCollect  = false,
    AutoRebirth  = false,
    AutoEquip    = false,
    AntiAFK      = true,
    TweenMove    = true,
    TweenSpeed   = 0.3,   -- seconds per tween segment
    RebirthCash  = 1e15,  -- rebirth when cash >= this value (1 quadrillion)
}

-- Load settings from file (if executor supports it)
local function LoadSettings()
    local ok, data = pcall(function()
        if isfile and isfile(SETTINGS_FILE) then
            return game:GetService("HttpService"):JSONDecode(readfile(SETTINGS_FILE))
        end
    end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do
            if DefaultSettings[k] ~= nil then
                DefaultSettings[k] = v
            end
        end
    end
end

local function SaveSettings()
    pcall(function()
        if writefile then
            writefile(SETTINGS_FILE, game:GetService("HttpService"):JSONEncode(DefaultSettings))
        end
    end)
end

LoadSettings()

-- ─────────────────────────────────────────────────────────────────
--  UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────

--- Smooth tween to a CFrame position
local function TweenTo(targetCFrame, duration)
    duration = duration or DefaultSettings.TweenSpeed
    if DefaultSettings.TweenMove and HumanoidRootPart then
        local tween = TweenService:Create(
            HumanoidRootPart,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { CFrame = targetCFrame }
        )
        tween:Play()
        tween.Completed:Wait()
    else
        -- Instant teleport fallback
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = targetCFrame
        end
    end
end

--- Get all blocks in workspace matching a name pattern
local function GetBlocks(namePattern)
    local blocks = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(namePattern:lower()) then
            table.insert(blocks, obj)
        end
    end
    return blocks
end

--- Get the nearest object from a list to the player
local function GetNearest(objects)
    local nearest, nearestDist = nil, math.huge
    if not HumanoidRootPart then return nil end
    for _, obj in ipairs(objects) do
        local dist = (HumanoidRootPart.Position - obj.Position).Magnitude
        if dist < nearestDist then
            nearest    = dist < nearestDist and obj or nearest
            nearestDist = dist
        end
    end
    return nearest
end

--- Fire a remote event safely
local function FireRemote(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        or Workspace:FindFirstChild(remoteName, true)
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(...)
        return true
    end
    return false
end

--- Invoke a remote function safely
local function InvokeRemote(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        or Workspace:FindFirstChild(remoteName, true)
    if remote and remote:IsA("RemoteFunction") then
        return pcall(function() return remote:InvokeServer(...) end)
    end
    return false
end

-- ─────────────────────────────────────────────────────────────────
--  NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────────────────────────
local NotifQueue = {}
local NotifActive = false

local function ShowNotif(title, message, duration)
    table.insert(NotifQueue, { title = title, message = message, duration = duration or 3 })
end

local function ProcessNotifQueue(notifFrame, notifTitle, notifMsg)
    if NotifActive or #NotifQueue == 0 then return end
    NotifActive = true
    local n = table.remove(NotifQueue, 1)

    notifTitle.Text = n.title
    notifMsg.Text   = n.message
    notifFrame.Position = UDim2.new(1, 10, 1, -80)  -- start off-screen right

    -- Slide in
    TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(1, -270, 1, -80) }):Play()

    task.delay(n.duration, function()
        -- Slide out
        local t = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 10, 1, -80) })
        t:Play()
        t.Completed:Wait()
        NotifActive = false
    end)
end

-- ─────────────────────────────────────────────────────────────────
--  ANTI AFK
-- ─────────────────────────────────────────────────────────────────
local antiAfkConn
local function StartAntiAFK()
    if antiAfkConn then return end
    antiAfkConn = RunService.Heartbeat:Connect(function()
        if DefaultSettings.AntiAFK then
            -- Simulate a small movement to prevent kick
            LocalPlayer:Move(Vector3.new(0, 0, 0), false)
        end
    end)
end

local function StopAntiAFK()
    if antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end
end

-- Anti AFK via VirtualInputManager on mobile
task.spawn(function()
    while task.wait(60) do
        if DefaultSettings.AntiAFK then
            pcall(function()
                -- Simulate a key press / tap so Roblox doesn't count as AFK
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end
            end)
        end
    end
end)

StartAntiAFK()

-- ─────────────────────────────────────────────────────────────────
--  CORE FARM LOGIC — KICK A LUCKY BLOCK
-- ─────────────────────────────────────────────────────────────────

-- Known remote / function names for Kick a Lucky Block
-- Adjust these if the game updates them.
local REMOTES = {
    KickBlock    = "KickBlock",      -- Fire to kick a block
    Collect      = "CollectCoins",   -- Collect dropped items
    Rebirth      = "Rebirth",        -- Trigger rebirth
    EquipItem    = "EquipItem",      -- Equip an item
}

local BLOCK_NAMES     = { "luckyblock", "block", "lucky" }
local COLLECT_NAMES   = { "coin", "drop", "item", "reward" }

-- ── Auto Farm loop ────────────────────────────────────────────────
local farmConn
local function StartAutoFarm()
    if farmConn then return end
    farmConn = RunService.Heartbeat:Connect(function()
        if not DefaultSettings.AutoFarm then return end
        pcall(function()
            -- Try to find any lucky block
            local blocks = {}
            for _, n in ipairs(BLOCK_NAMES) do
                local found = GetBlocks(n)
                for _, b in ipairs(found) do table.insert(blocks, b) end
            end

            local target = GetNearest(blocks)
            if target then
                -- Move near the block
                local offset = (HumanoidRootPart.Position - target.Position).Unit * 4
                TweenTo(CFrame.new(target.Position + offset))

                -- Fire kick remote
                FireRemote(REMOTES.KickBlock, target)

                -- Small wait before next kick
                task.wait(0.05)
            end
        end)
    end)
end

local function StopAutoFarm()
    if farmConn then
        farmConn:Disconnect()
        farmConn = nil
    end
end

-- ── Auto Collect loop ─────────────────────────────────────────────
local collectConn
local function StartAutoCollect()
    if collectConn then return end
    collectConn = RunService.Heartbeat:Connect(function()
        if not DefaultSettings.AutoCollect then return end
        pcall(function()
            local drops = {}
            for _, n in ipairs(COLLECT_NAMES) do
                local found = GetBlocks(n)
                for _, d in ipairs(found) do table.insert(drops, d) end
            end

            for _, drop in ipairs(drops) do
                -- Teleport directly onto each drop to collect
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = CFrame.new(drop.Position)
                end
                FireRemote(REMOTES.Collect, drop)
                task.wait(0.01)
            end
        end)
    end)
end

local function StopAutoCollect()
    if collectConn then
        collectConn:Disconnect()
        collectConn = nil
    end
end

-- ── Auto Rebirth loop ─────────────────────────────────────────────
local function CheckRebirth()
    -- Try to read the player's cash from the leaderboard
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            or LocalPlayer:FindFirstChild("Stats")
        if not leaderstats then return end

        local cash = leaderstats:FindFirstChild("Cash")
            or leaderstats:FindFirstChild("Coins")
            or leaderstats:FindFirstChild("Money")

        if cash and (cash.Value >= DefaultSettings.RebirthCash) then
            FireRemote(REMOTES.Rebirth)
            ShowNotif("✦ Auto Rebirth", "Rebirth triggered!", 3)
        end
    end)
end

-- ── Auto Equip Best ───────────────────────────────────────────────
local function AutoEquipBest()
    pcall(function()
        -- Find the player's inventory / backpack
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end

        local bestTool, bestPower = nil, -1

        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                -- Try to find a power / damage attribute
                local power = tool:GetAttribute("Power")
                    or tool:GetAttribute("Damage")
                    or tool:GetAttribute("CPS")
                    or 0

                if power > bestPower then
                    bestPower = power
                    bestTool  = tool
                end
            end
        end

        if bestTool then
            -- Equip by moving to character
            bestTool.Parent = Character
            FireRemote(REMOTES.EquipItem, bestTool.Name)
        end
    end)
end

-- ── Teleport Zones ────────────────────────────────────────────────
local ZONES = {
    FarmZone    = Vector3.new(0, 5, 0),   -- adjust to actual farm zone coords
    RebirthZone = Vector3.new(50, 5, 50), -- adjust to actual rebirth zone coords
}

local function TeleportTo(zoneName)
    local pos = ZONES[zoneName]
    if pos then
        TweenTo(CFrame.new(pos + Vector3.new(0, 3, 0)))
        ShowNotif("✦ Teleport", "Moved to " .. zoneName, 2)
    end
end

-- ── Main loop for rebirth / equip (every 2 seconds) ──────────────
task.spawn(function()
    while task.wait(2) do
        if DefaultSettings.AutoRebirth then
            CheckRebirth()
        end
        if DefaultSettings.AutoEquip then
            AutoEquipBest()
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────
--  GUI CONSTRUCTION
-- ─────────────────────────────────────────────────────────────────
-- Remove any previous instance
if PlayerGui:FindFirstChild("AetherKLB") then
    PlayerGui:FindFirstChild("AetherKLB"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name              = "AetherKLB"
ScreenGui.ResetOnSpawn      = false
ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder      = 999
ScreenGui.IgnoreGuiInset    = true
ScreenGui.Parent            = PlayerGui

-- ── Color palette ─────────────────────────────────────────────────
local C = {
    BG        = Color3.fromRGB(8,   12,  25),   -- deep space black-blue
    Panel     = Color3.fromRGB(12,  18,  38),
    Card      = Color3.fromRGB(16,  24,  50),
    Accent    = Color3.fromRGB(0,   140, 255),  -- neon blue
    AccentDim = Color3.fromRGB(0,   80,  160),
    Green     = Color3.fromRGB(0,   220, 100),
    Red       = Color3.fromRGB(220, 50,  50),
    TextHi    = Color3.fromRGB(220, 235, 255),
    TextLo    = Color3.fromRGB(100, 130, 180),
    Border    = Color3.fromRGB(0,   80,  180),
    Glow      = Color3.fromRGB(0,   100, 200),
}

-- ── Helper: create a UIStroke ──────────────────────────────────────
local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or C.Border
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

-- ── Helper: create a UICorner ─────────────────────────────────────
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- ── Helper: create a TextLabel ────────────────────────────────────
local function Label(parent, text, size, color, font, props)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Text       = text
    lbl.TextSize   = size or 14
    lbl.TextColor3 = color or C.TextHi
    lbl.Font       = font or Enum.Font.GothamBold
    lbl.RichText   = true
    for k, v in pairs(props or {}) do lbl[k] = v end
    lbl.Parent = parent
    return lbl
end

-- ── Main Window ───────────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Size              = UDim2.new(0, 340, 0, 480)
MainFrame.Position          = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3  = C.BG
MainFrame.BorderSizePixel   = 0
MainFrame.ClipsDescendants  = false
MainFrame.Parent            = ScreenGui
Corner(MainFrame, 14)
Stroke(MainFrame, C.Accent, 1.5)

-- Outer glow effect (shadow frame)
local GlowFrame = Instance.new("ImageLabel")
GlowFrame.Name              = "Glow"
GlowFrame.Size              = UDim2.new(1, 40, 1, 40)
GlowFrame.Position          = UDim2.new(0, -20, 0, -20)
GlowFrame.BackgroundTransparency = 1
GlowFrame.Image             = "rbxassetid://5028857084"  -- radial gradient
GlowFrame.ImageColor3       = C.Glow
GlowFrame.ImageTransparency = 0.75
GlowFrame.ZIndex            = 0
GlowFrame.Parent            = MainFrame

-- ── Title Bar ─────────────────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Name              = "TitleBar"
TitleBar.Size              = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3  = C.Panel
TitleBar.BorderSizePixel   = 0
TitleBar.Parent            = MainFrame
Corner(TitleBar, 14)

-- Bottom-round fix (only round on top)
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size              = UDim2.new(1, 0, 0.5, 0)
TitleBarFix.Position          = UDim2.new(0, 0, 0.5, 0)
TitleBarFix.BackgroundColor3  = C.Panel
TitleBarFix.BorderSizePixel   = 0
TitleBarFix.Parent            = TitleBar

-- Logo dot
local LogoDot = Instance.new("Frame")
LogoDot.Size             = UDim2.new(0, 10, 0, 10)
LogoDot.Position         = UDim2.new(0, 14, 0.5, -5)
LogoDot.BackgroundColor3 = C.Accent
LogoDot.BorderSizePixel  = 0
LogoDot.Parent           = TitleBar
Corner(LogoDot, 5)

-- Pulsing animation on logo dot
task.spawn(function()
    while true do
        TweenService:Create(LogoDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0.6 }):Play()
        task.wait(1)
        TweenService:Create(LogoDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0 }):Play()
        task.wait(1)
    end
end)

Label(TitleBar, "AETHER  <font color='#0088FF'>LUCKY BLOCK</font>", 15, C.TextHi, Enum.Font.GothamBold, {
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 32, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
})

Label(TitleBar, "v2.0.0", 11, C.TextLo, Enum.Font.Gotham, {
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(1, -100, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Right,
})

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3  = Color3.fromRGB(200, 50, 50)
CloseBtn.Text              = "✕"
CloseBtn.TextColor3        = C.TextHi
CloseBtn.TextSize          = 13
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.BorderSizePixel   = 0
CloseBtn.Parent            = TitleBar
Corner(CloseBtn, 7)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
    task.delay(0.35, function() ScreenGui:Destroy() end)
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 28, 0, 28)
MinBtn.Position         = UDim2.new(1, -72, 0.5, -14)
MinBtn.BackgroundColor3 = C.AccentDim
MinBtn.Text             = "—"
MinBtn.TextColor3       = C.TextHi
MinBtn.TextSize         = 13
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.Parent           = TitleBar
Corner(MinBtn, 7)

local minimized = false
local expandedSize = UDim2.new(0, 340, 0, 480)
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 340, 0, 44) or expandedSize
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Size = targetSize }):Play()
end)

-- ── Scroll container for toggles ──────────────────────────────────
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name              = "Scroll"
ScrollFrame.Size              = UDim2.new(1, -16, 1, -56)
ScrollFrame.Position          = UDim2.new(0, 8, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel   = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = C.Accent
ScrollFrame.CanvasSize        = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent            = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding        = UDim.new(0, 8)
ListLayout.SortOrder      = Enum.SortOrder.LayoutOrder
ListLayout.Parent         = ScrollFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 8)
Padding.PaddingTop    = UDim.new(0, 4)
Padding.Parent        = ScrollFrame

-- ── Section header helper ─────────────────────────────────────────
local sectionOrder = 0
local function MakeSection(title)
    sectionOrder = sectionOrder + 1
    local s = Instance.new("Frame")
    s.Size              = UDim2.new(1, 0, 0, 24)
    s.BackgroundTransparency = 1
    s.LayoutOrder       = sectionOrder
    s.Parent            = ScrollFrame

    local line = Instance.new("Frame")
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = C.Border
    line.BorderSizePixel  = 0
    line.Parent           = s

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize     = Enum.AutomaticSize.X
    lbl.Position          = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundColor3  = C.BG
    lbl.BackgroundTransparency = 0
    lbl.Text              = "  " .. title .. "  "
    lbl.TextSize          = 11
    lbl.TextColor3        = C.Accent
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.BorderSizePixel   = 0
    lbl.Parent            = s
end

-- ── Toggle button helper ──────────────────────────────────────────
local function MakeToggle(labelText, settingKey, icon, onToggle)
    sectionOrder = sectionOrder + 1

    local card = Instance.new("Frame")
    card.Size              = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3  = C.Card
    card.BorderSizePixel   = 0
    card.LayoutOrder       = sectionOrder
    card.Parent            = ScrollFrame
    Corner(card, 10)
    Stroke(card, C.Border, 1)

    -- Icon
    local iconLbl = Label(card, icon, 20, C.Accent, Enum.Font.GothamBold, {
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    -- Label
    Label(card, labelText, 13, C.TextHi, Enum.Font.GothamBold, {
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.new(0, 46, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    Label(card, settingKey == "AntiAFK" and "Prevents inactivity kick" or
                settingKey == "TweenMove" and "Smooth movement interpolation" or
                "Auto " .. labelText:lower(), 10, C.TextLo, Enum.Font.Gotham, {
        Size = UDim2.new(1, -100, 0, 16),
        Position = UDim2.new(0, 46, 0, 28),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Toggle pill
    local pillBG = Instance.new("Frame")
    pillBG.Size             = UDim2.new(0, 50, 0, 26)
    pillBG.Position         = UDim2.new(1, -62, 0.5, -13)
    pillBG.BackgroundColor3 = DefaultSettings[settingKey] and C.Accent or Color3.fromRGB(40, 50, 70)
    pillBG.BorderSizePixel  = 0
    pillBG.Parent           = card
    Corner(pillBG, 13)

    local knob = Instance.new("Frame")
    knob.Size              = UDim2.new(0, 20, 0, 20)
    knob.Position          = DefaultSettings[settingKey]
        and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3  = C.TextHi
    knob.BorderSizePixel   = 0
    knob.Parent            = pillBG
    Corner(knob, 10)

    -- Clickable area over the entire card
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size              = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text              = ""
    clickBtn.ZIndex            = 5
    clickBtn.Parent            = card

    clickBtn.MouseButton1Click:Connect(function()
        DefaultSettings[settingKey] = not DefaultSettings[settingKey]
        local on = DefaultSettings[settingKey]

        -- Animate pill
        TweenService:Create(pillBG, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            { BackgroundColor3 = on and C.Accent or Color3.fromRGB(40, 50, 70) }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back),
            { Position = on and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10) }):Play()

        -- Card highlight pulse
        TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            { BackgroundColor3 = on and Color3.fromRGB(16, 30, 65) or C.Card }):Play()

        if onToggle then onToggle(on) end
        SaveSettings()

        ShowNotif(labelText, on and "✦ Enabled" or "✦ Disabled", 2)
    end)

    return card
end

-- ── Action button helper ──────────────────────────────────────────
local function MakeActionBtn(labelText, icon, callback)
    sectionOrder = sectionOrder + 1

    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3  = C.AccentDim
    btn.Text              = icon .. "  " .. labelText
    btn.TextColor3        = C.TextHi
    btn.TextSize          = 13
    btn.Font              = Enum.Font.GothamBold
    btn.BorderSizePixel   = 0
    btn.LayoutOrder       = sectionOrder
    btn.Parent            = ScrollFrame
    Corner(btn, 10)
    Stroke(btn, C.Accent, 1)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.Accent }):Play()
        task.delay(0.15, function()
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = C.AccentDim }):Play()
        end)
        if callback then callback() end
    end)

    return btn
end

-- ─────────────────────────────────────────────────────────────────
--  BUILD THE TOGGLE LIST
-- ─────────────────────────────────────────────────────────────────

MakeSection("⬡  AUTO FARM")
MakeToggle("Auto Farm",    "AutoFarm",    "🟩", function(on)
    if on then StartAutoFarm() else StopAutoFarm() end
end)
MakeToggle("Auto Collect", "AutoCollect", "🪙", function(on)
    if on then StartAutoCollect() else StopAutoCollect() end
end)
MakeToggle("Auto Rebirth", "AutoRebirth", "♻", nil)
MakeToggle("Auto Equip Best", "AutoEquip", "⚔", nil)

MakeSection("⬡  MOVEMENT")
MakeToggle("Tween Movement", "TweenMove", "🌀", nil)

MakeSection("⬡  SYSTEM")
MakeToggle("Anti AFK",     "AntiAFK",    "🛡", function(on)
    if on then StartAntiAFK() else StopAntiAFK() end
end)

MakeSection("⬡  TELEPORT")
MakeActionBtn("Farm Zone",    "📍", function() TeleportTo("FarmZone") end)
MakeActionBtn("Rebirth Zone", "🔁", function() TeleportTo("RebirthZone") end)

MakeSection("⬡  ACTIONS")
MakeActionBtn("Equip Best Now", "⚡", function()
    AutoEquipBest()
    ShowNotif("Auto Equip", "Best item equipped!", 2)
end)
MakeActionBtn("Collect All Now", "💰", function()
    -- Immediate one-shot collect
    pcall(function()
        for _, n in ipairs(COLLECT_NAMES) do
            local drops = GetBlocks(n)
            for _, drop in ipairs(drops) do
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = CFrame.new(drop.Position)
                end
                FireRemote(REMOTES.Collect, drop)
            end
        end
    end)
    ShowNotif("Collect All", "Collected all drops!", 2)
end)

-- ─────────────────────────────────────────────────────────────────
--  NOTIFICATION FRAME (bottom-right)
-- ─────────────────────────────────────────────────────────────────
local NotifFrame = Instance.new("Frame")
NotifFrame.Name             = "NotifFrame"
NotifFrame.Size             = UDim2.new(0, 260, 0, 64)
NotifFrame.Position         = UDim2.new(1, 10, 1, -80)  -- starts off screen
NotifFrame.BackgroundColor3 = C.Panel
NotifFrame.BorderSizePixel  = 0
NotifFrame.ZIndex           = 100
NotifFrame.Parent           = ScreenGui
Corner(NotifFrame, 10)
Stroke(NotifFrame, C.Accent, 1.5)

local NotifAccent = Instance.new("Frame")
NotifAccent.Size             = UDim2.new(0, 4, 1, -16)
NotifAccent.Position         = UDim2.new(0, 8, 0, 8)
NotifAccent.BackgroundColor3 = C.Accent
NotifAccent.BorderSizePixel  = 0
NotifAccent.Parent           = NotifFrame
Corner(NotifAccent, 2)

local NotifTitle = Label(NotifFrame, "Notification", 13, C.Accent, Enum.Font.GothamBold, {
    Size = UDim2.new(1, -26, 0, 22),
    Position = UDim2.new(0, 20, 0, 8),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 101,
})
local NotifMsg = Label(NotifFrame, "", 11, C.TextLo, Enum.Font.Gotham, {
    Size = UDim2.new(1, -26, 0, 20),
    Position = UDim2.new(0, 20, 0, 30),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 101,
})

-- Poll notification queue
RunService.Heartbeat:Connect(function()
    ProcessNotifQueue(NotifFrame, NotifTitle, NotifMsg)
end)

-- ─────────────────────────────────────────────────────────────────
--  DRAGGABLE GUI
-- ─────────────────────────────────────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil

local function StartDrag(input)
    dragging  = true
    dragStart = input.Position
    startPos  = MainFrame.Position
end

local function UpdateDrag(input)
    if not dragging then return end
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        StartDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        UpdateDrag(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ─────────────────────────────────────────────────────────────────
--  OPENING ANIMATION
-- ─────────────────────────────────────────────────────────────────
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame,
    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = expandedSize, Position = UDim2.new(0.5, -170, 0.5, -240) }
):Play()

-- ─────────────────────────────────────────────────────────────────
--  STARTUP NOTIFICATION
-- ─────────────────────────────────────────────────────────────────
task.delay(0.6, function()
    ShowNotif("✦ AetherScripts", "Kick a Lucky Block v2.0.0 loaded!", 4)
end)

-- ─────────────────────────────────────────────────────────────────
--  START LOOPS FOR ANY TOGGLES ALREADY ON (from saved settings)
-- ─────────────────────────────────────────────────────────────────
if DefaultSettings.AutoFarm    then StartAutoFarm()    end
if DefaultSettings.AutoCollect then StartAutoCollect() end

-- ─────────────────────────────────────────────────────────────────
--  DONE
-- ─────────────────────────────────────────────────────────────────
print("[AetherKLB] Script loaded successfully — Kick a Lucky Block v2.0.0")
