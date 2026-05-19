-- =============================================================================
--  AETHER HUB — NOCLIP & FLY
--  Style : Phantom noir | CoreGui | Draggable
-- =============================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local lp     = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function char() return lp.Character end
local function root()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- =============================================================================
--  VARIABLES
-- =============================================================================
local flying    = false
local noclip    = false
local flySpeed  = 50
local bGyro, bVel
local keys = {}

-- =============================================================================
--  FLY
-- =============================================================================
local function startFly()
    local r = root() if not r then return end
    local h = hum()  if h then h.PlatformStand = true end

    bGyro           = Instance.new("BodyGyro")
    bGyro.P         = 9e4
    bGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bGyro.CFrame    = r.CFrame
    bGyro.Parent    = r

    bVel          = Instance.new("BodyVelocity")
    bVel.Velocity  = Vector3.new(0, 0.1, 0)
    bVel.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    bVel.Parent    = r

    flying = true

    task.spawn(function()
        while flying do
            RunService.RenderStepped:Wait()
            local r2 = root() if not r2 or not bVel or not bGyro then break end
            local cam = camera.CFrame
            local dir = Vector3.new(0, 0, 0)

            if keys[Enum.KeyCode.W] or keys[Enum.KeyCode.Z] then dir = dir + cam.LookVector  end
            if keys[Enum.KeyCode.S]                          then dir = dir - cam.LookVector  end
            if keys[Enum.KeyCode.A] or keys[Enum.KeyCode.Q] then dir = dir - cam.RightVector end
            if keys[Enum.KeyCode.D]                          then dir = dir + cam.RightVector end
            if keys[Enum.KeyCode.Space]                      then dir = dir + Vector3.new(0,1,0) end
            if keys[Enum.KeyCode.LeftControl]                then dir = dir - Vector3.new(0,1,0) end

            bGyro.CFrame = cam
            bVel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new(0, 0, 0)
        end
    end)
end

local function stopFly()
    flying = false
    if bGyro then bGyro:Destroy() bGyro = nil end
    if bVel  then bVel:Destroy()  bVel  = nil end
    local h = hum() if h then h.PlatformStand = false end
end

-- =============================================================================
--  NOCLIP
-- =============================================================================
local noclipConn

local function startNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        local c = char() if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end)
    noclip = true
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    noclip = false
    -- Réactive les collisions
    local c = char() if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = true end
    end
end

-- =============================================================================
--  INPUT
-- =============================================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    keys[input.KeyCode] = true
end)
UserInputService.InputEnded:Connect(function(input)
    keys[input.KeyCode] = nil
end)

-- Réinitialise sur respawn
lp.CharacterAdded:Connect(function()
    flying = false noclip = false
    if bGyro then bGyro:Destroy() bGyro = nil end
    if bVel  then bVel:Destroy()  bVel  = nil end
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end)

-- =============================================================================
--  GUI
-- =============================================================================
if CoreGui:FindFirstChild("AetherFly") then CoreGui:FindFirstChild("AetherFly"):Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name           = "AetherFly"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent         = CoreGui

-- Palette phantom
local C = {
    Base    = Color3.fromRGB(10,  10,  12),
    Sidebar = Color3.fromRGB(14,  14,  17),
    Card    = Color3.fromRGB(18,  18,  22),
    Active  = Color3.fromRGB(22,  22,  28),
    Border  = Color3.fromRGB(38,  38,  46),
    Accent  = Color3.fromRGB(220, 220, 230),
    Dim     = Color3.fromRGB(85,  85, 100),
    ON      = Color3.fromRGB(180, 255, 180),
    Red     = Color3.fromRGB(200,  70,  70),
    Stripe  = Color3.fromRGB(30,  30,  36),
}

local function mkCorner(p, r)
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 6) c.Parent = p
end
local function mkStroke(p, col, t)
    local s = Instance.new("UIStroke") s.Color = col or C.Border s.Thickness = t or 1 s.Parent = p
end
local function mkLabel(p, txt, sz, col, xa, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = txt l.TextSize = sz or 13
    l.TextColor3 = col or C.Accent
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    for k, v in pairs(props or {}) do l[k] = v end
    l.Parent = p return l
end

-- ── Fenêtre ───────────────────────────────────────────────────────
local Win = Instance.new("Frame")
Win.Size             = UDim2.new(0, 460, 0, 300)
Win.Position         = UDim2.new(0.5, -230, 0.5, -150)
Win.BackgroundColor3 = C.Base
Win.Active           = true
Win.Draggable        = true
Win.Parent           = SG
mkCorner(Win, 8)
mkStroke(Win, C.Border, 1)

-- Séparateur sidebar / content
local Sep = Instance.new("Frame")
Sep.Size = UDim2.new(0,1,1,-10) Sep.Position = UDim2.new(0,140,0,5)
Sep.BackgroundColor3 = C.Stripe Sep.BorderSizePixel = 0 Sep.Parent = Win

-- ── Sidebar ───────────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel  = 0
Sidebar.Parent           = Win
mkCorner(Sidebar, 8)
-- Fix coins droits
local SFix = Instance.new("Frame")
SFix.Size = UDim2.new(0.5,0,1,0) SFix.Position = UDim2.new(0.5,0,0,0)
SFix.BackgroundColor3 = C.Sidebar SFix.BorderSizePixel = 0 SFix.Parent = Sidebar

-- Titre sidebar
mkLabel(Sidebar, "AETHER", 15, C.Accent, Enum.TextXAlignment.Center, {
    Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,0,12),
    Font=Enum.Font.GothamBold,
})
mkLabel(Sidebar, "movement hub", 10, C.Dim, Enum.TextXAlignment.Center, {
    Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,34),
})
local LogoLine = Instance.new("Frame")
LogoLine.Size=UDim2.new(1,-20,0,1) LogoLine.Position=UDim2.new(0,10,0,54)
LogoLine.BackgroundColor3=C.Stripe LogoLine.BorderSizePixel=0 LogoLine.Parent=Sidebar

-- Tab list
local TabList = Instance.new("Frame")
TabList.Size=UDim2.new(1,0,1,-62) TabList.Position=UDim2.new(0,0,0,60)
TabList.BackgroundTransparency=1 TabList.Parent=Sidebar
local TL = Instance.new("UIListLayout") TL.Padding=UDim.new(0,3) TL.Parent=TabList
local TP = Instance.new("UIPadding") TP.PaddingLeft=UDim.new(0,8) TP.Parent=TabList

-- ── Content ───────────────────────────────────────────────────────
local Content = Instance.new("Frame")
Content.Size=UDim2.new(1,-150,1,-10) Content.Position=UDim2.new(0,148,0,5)
Content.BackgroundTransparency=1 Content.ClipsDescendants=true Content.Parent=Win

local pages = {}
local tabs  = {}
local activePage = nil

local function setPage(name)
    for n, p in pairs(pages)  do p.Visible = (n == name) end
    for n, t in pairs(tabs) do
        if n == name then
            t.BackgroundColor3       = C.Active
            t.BackgroundTransparency = 0
            t.TextColor3             = C.Accent
        else
            t.BackgroundColor3       = Color3.fromRGB(0,0,0)
            t.BackgroundTransparency = 1
            t.TextColor3             = C.Dim
        end
    end
    activePage = name
end

local function newPage(id)
    local p = Instance.new("Frame")
    p.Size=UDim2.new(1,0,1,0) p.BackgroundTransparency=1 p.Visible=false p.Parent=Content
    pages[id] = p return p
end

local function newTab(label, icon, pageId)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(1,-4,0,32) b.BackgroundTransparency=1
    b.BackgroundColor3=Color3.fromRGB(0,0,0)
    b.Text=icon.."  "..label b.TextColor3=C.Dim
    b.Font=Enum.Font.Gotham b.TextSize=12
    b.TextXAlignment=Enum.TextXAlignment.Left
    b.BorderSizePixel=0 b.AutoButtonColor=false b.Parent=TabList
    mkCorner(b,5)
    local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,10) pad.Parent=b
    b.MouseButton1Click:Connect(function() setPage(pageId) end)
    b.MouseEnter:Connect(function() if activePage~=pageId then TweenService:Create(b,TweenInfo.new(0.15),{TextColor3=C.Accent}):Play() end end)
    b.MouseLeave:Connect(function() if activePage~=pageId then TweenService:Create(b,TweenInfo.new(0.15),{TextColor3=C.Dim}):Play()   end end)
    tabs[pageId] = b return b
end

-- ── Helpers UI ────────────────────────────────────────────────────
local function hline(page, y)
    local l=Instance.new("Frame") l.Size=UDim2.new(1,0,0,1) l.Position=UDim2.new(0,0,0,y)
    l.BackgroundColor3=C.Stripe l.BorderSizePixel=0 l.Parent=page
end

-- Toggle sobre
local function newToggle(page, y, label, desc, initState, onEnable, onDisable)
    local card = Instance.new("Frame")
    card.Size=UDim2.new(1,-8,0,50) card.Position=UDim2.new(0,4,0,y)
    card.BackgroundColor3=C.Card card.BorderSizePixel=0 card.Parent=page
    mkCorner(card,6) mkStroke(card,C.Border,1)

    mkLabel(card, label, 13, C.Accent, Enum.TextXAlignment.Left, {
        Size=UDim2.new(1,-70,0,22), Position=UDim2.new(0,12,0,6),
        Font=Enum.Font.GothamSemibold,
    })
    mkLabel(card, desc, 10, C.Dim, Enum.TextXAlignment.Left, {
        Size=UDim2.new(1,-70,0,16), Position=UDim2.new(0,12,0,28),
    })

    local pill = Instance.new("Frame")
    pill.Size=UDim2.new(0,44,0,22) pill.Position=UDim2.new(1,-52,0.5,-11)
    pill.BackgroundColor3=Color3.fromRGB(28,28,33) pill.BorderSizePixel=0 pill.Parent=card
    mkCorner(pill,11)

    local knob = Instance.new("Frame")
    knob.Size=UDim2.new(0,16,0,16) knob.Position=UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3=C.Dim knob.BorderSizePixel=0 knob.Parent=pill
    mkCorner(knob,8)

    local state = initState or false

    local function setV(on)
        TweenService:Create(pill, TweenInfo.new(0.18,Enum.EasingStyle.Quad),
            {BackgroundColor3 = on and Color3.fromRGB(35,55,35) or Color3.fromRGB(28,28,33)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.18,Enum.EasingStyle.Back),
            {Position      = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
             BackgroundColor3 = on and C.ON or C.Dim}):Play()
    end
    setV(state)

    local click = Instance.new("TextButton")
    click.Size=UDim2.new(1,0,1,0) click.BackgroundTransparency=1 click.Text=""
    click.ZIndex=5 click.AutoButtonColor=false click.Parent=card

    click.MouseButton1Click:Connect(function()
        state = not state
        setV(state)
        if state then if onEnable  then onEnable()  end
        else          if onDisable then onDisable() end end
    end)

    return setV  -- retourne la fonction pour màj externe
end

-- Slider sobre
local function newSlider(page, y, label, min, max, init, onChange)
    local card = Instance.new("Frame")
    card.Size=UDim2.new(1,-8,0,50) card.Position=UDim2.new(0,4,0,y)
    card.BackgroundColor3=C.Card card.BorderSizePixel=0 card.Parent=page
    mkCorner(card,6) mkStroke(card,C.Border,1)

    local valLbl = mkLabel(card, label..":  "..init, 12, C.Accent, Enum.TextXAlignment.Left, {
        Size=UDim2.new(1,-12,0,20), Position=UDim2.new(0,12,0,6),
        Font=Enum.Font.GothamSemibold,
    })

    -- Track
    local track = Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,4) track.Position=UDim2.new(0,12,0,34)
    track.BackgroundColor3=C.Border track.BorderSizePixel=0 track.Parent=card
    mkCorner(track,2)

    -- Fill
    local fill = Instance.new("Frame")
    fill.Size=UDim2.new((init-min)/(max-min),0,1,0)
    fill.BackgroundColor3=C.Accent fill.BorderSizePixel=0 fill.Parent=track
    mkCorner(fill,2)

    -- Knob
    local kn = Instance.new("Frame")
    kn.Size=UDim2.new(0,12,0,12) kn.AnchorPoint=Vector2.new(0.5,0.5)
    kn.Position=UDim2.new((init-min)/(max-min),0,0.5,0)
    kn.BackgroundColor3=C.Accent kn.BorderSizePixel=0 kn.Parent=track
    mkCorner(kn,6)

    local sliding = false
    local function updateSlider(x)
        local abs = track.AbsolutePosition.X
        local w   = track.AbsoluteSize.X
        local t   = math.clamp((x - abs) / w, 0, 1)
        local val = math.floor(min + t*(max-min))
        fill.Size = UDim2.new(t,0,1,0)
        kn.Position = UDim2.new(t,0,0.5,0)
        valLbl.Text = label..":  "..val
        if onChange then onChange(val) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true updateSlider(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            updateSlider(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)
end

-- =============================================================================
--  PAGE FLY
-- =============================================================================
local PageFly = newPage("fly")
newTab("Fly", "✈", "fly")

mkLabel(PageFly, "Fly", 16, C.Accent, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,26), Position=UDim2.new(0,4,0,4),
    Font=Enum.Font.GothamBold,
})
mkLabel(PageFly, "WASD / ZQSD  •  Espace = monter  •  Ctrl = descendre", 10, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,4,0,26),
})
hline(PageFly, 48)

local setFlyVisual = newToggle(PageFly, 54,
    "Activer le Fly",
    "Vole librement avec la caméra",
    false,
    function() startFly() end,
    function() stopFly()  end
)

newSlider(PageFly, 112, "Vitesse", 10, 200, 50, function(v) flySpeed = v end)

-- =============================================================================
--  PAGE NOCLIP
-- =============================================================================
local PageNoclip = newPage("noclip")
newTab("Noclip", "◻", "noclip")

mkLabel(PageNoclip, "Noclip", 16, C.Accent, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,26), Position=UDim2.new(0,4,0,4),
    Font=Enum.Font.GothamBold,
})
mkLabel(PageNoclip, "Traverse les murs et le sol librement.", 10, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,4,0,26),
})
hline(PageNoclip, 48)

newToggle(PageNoclip, 54,
    "Activer le Noclip",
    "CanCollide = false sur tout le perso",
    false,
    function() startNoclip() end,
    function() stopNoclip()  end
)

-- Tip
mkLabel(PageNoclip, "💡  Combine avec Fly pour traverser et voler.", 10, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,4,0,180),
})

-- =============================================================================
--  FERMER
-- =============================================================================
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,22,0,22) CloseBtn.Position=UDim2.new(1,-28,0,6)
CloseBtn.BackgroundColor3=Color3.fromRGB(40,18,18)
CloseBtn.Text="✕" CloseBtn.TextColor3=C.Red
CloseBtn.Font=Enum.Font.GothamBold CloseBtn.TextSize=12
CloseBtn.BorderSizePixel=0 CloseBtn.AutoButtonColor=false CloseBtn.ZIndex=10
CloseBtn.Parent=Win
mkCorner(CloseBtn,5)
CloseBtn.MouseButton1Click:Connect(function()
    stopFly() stopNoclip()
    TweenService:Create(Win, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.delay(0.25, function() SG:Destroy() end)
end)

-- =============================================================================
--  OUVERTURE
-- =============================================================================
Win.Size=UDim2.new(0,0,0,0) Win.Position=UDim2.new(0.5,0,0.5,0)
TweenService:Create(Win, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,460,0,300), Position=UDim2.new(0.5,-230,0.5,-150)}):Play()

task.delay(0.05, function() setPage("fly") end)

print("[AetherHub] Fly + Noclip chargé")
