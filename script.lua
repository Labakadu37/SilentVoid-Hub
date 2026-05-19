-- =============================================================================
--  KICK A LUCKY BLOCK — AETHER HUB
--  Style : Phantom noir | CoreGui | Sidebar navigation
-- =============================================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local lp = Players.LocalPlayer

local function char()  return lp.Character end
local function root()  local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char() return c and c:FindFirstChildOfClass("Humanoid") end

lp.CharacterAdded:Connect(function() task.wait(1) end)

-- =============================================================================
--  SETTINGS
-- =============================================================================
local S = {
    AutoFarm    = false,
    AutoMuscle  = false,
    AutoViolet  = false,
    AutoMoney   = false,
    AntiAFK     = true,
    PerfectOnly = true,
    FarmDelay   = 0.08,
}

-- =============================================================================
--  UTILITAIRES
-- =============================================================================
local function tp(cf)
    local r = root() if r then r.CFrame = cf end
end

local function fireRemote(name, ...)
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find(name:lower()) then
            v:FireServer(...) return true
        end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find(name:lower()) then
            v:FireServer(...) return true
        end
    end
    return false
end

local function findParts(pattern)
    local list = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:lower():find(pattern:lower()) then
            table.insert(list, v)
        end
    end
    return list
end

local function getPos(v)
    if v:IsA("BasePart") then return v.Position end
    if v:IsA("Model") then
        local p = v.PrimaryPart or v:FindFirstChildOfClass("BasePart")
        return p and p.Position
    end
end

local function clickPart(part)
    local pp = part:FindFirstChildOfClass("ProximityPrompt") or part:FindFirstChild("ProximityPrompt", true)
    if pp then pcall(fireproximityprompt, pp) return end
    local r = root() if r then r.CFrame = CFrame.new((getPos(part) or r.Position) + Vector3.new(0,3,0)) end
end

-- =============================================================================
--  ANTI AFK
-- =============================================================================
task.spawn(function()
    while true do
        task.wait(55)
        if S.AntiAFK then
            local h = hum() if h then h.Jump = true end
        end
    end
end)

-- =============================================================================
--  MODULE 1 — AUTO FARM (perfect kick)
-- =============================================================================
local KICK_REMOTES = {"Kick","KickBlock","HitBlock","ThrowBlock","Throw","Launch","DoKick"}
local ZONE_NAMES   = {"KickZone","ThrowZone","LaunchZone","Zone","Pad","KickPad","Plate","Platform"}

local function findKickZone()
    for _, n in ipairs(ZONE_NAMES) do
        local f = Workspace:FindFirstChild(n, true)
        if f and (f:IsA("BasePart") or f:IsA("Model")) then return f end
    end
    local z = findParts("zone") if #z>0 then return z[1] end
    local p = findParts("pad")  if #p>0 then return p[1] end
end

local function findKickBar()
    local pg = lp:FindFirstChild("PlayerGui") if not pg then return end
    for _, v in ipairs(pg:GetDescendants()) do
        if v:IsA("Frame") and (v.Name:lower():find("bar") or v.Name:lower():find("meter")
            or v.Name:lower():find("power") or v.Name:lower():find("kick") or v.Name:lower():find("charge")) then
            return v
        end
    end
end

local function isPerfect(bar)
    if not bar then return true end
    return bar.Position.Y.Scale <= 0.15
end

local function doKick()
    for _, n in ipairs(KICK_REMOTES) do if fireRemote(n) then return true end end
    local pg = lp:FindFirstChild("PlayerGui") if not pg then return end
    for _, v in ipairs(pg:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) then
            local n = v.Name:lower()
            if n:find("kick") or n:find("throw") or n:find("tap") or n:find("coup") then
                pcall(function() v.MouseButton1Click:Fire() end) return true
            end
        end
    end
end

local farmThread
local function startAutoFarm()
    if farmThread then task.cancel(farmThread) end
    farmThread = task.spawn(function()
        while S.AutoFarm do
            pcall(function()
                local zone = findKickZone()
                if zone then
                    local pos = getPos(zone) or Vector3.new(0,5,0)
                    tp(CFrame.new(pos + Vector3.new(0,5,0)))
                end
                if S.PerfectOnly then
                    local bar = findKickBar()
                    local t = 0
                    while not isPerfect(bar) and t < 3 do
                        task.wait(0.01) t = t + 0.01 bar = findKickBar()
                    end
                end
                doKick()
            end)
            task.wait(S.FarmDelay)
        end
    end)
end

-- =============================================================================
--  MODULE 2 — AUTO MUSCLE GRAB
-- =============================================================================
local MUSCLE_NAMES = {"Muscle","Giant","Big","Boss","Huge","Brainrot","Drop","Reward","Prize"}

local function findMuscleItem()
    local candidates = {}
    for _, n in ipairs(MUSCLE_NAMES) do
        for _, v in ipairs(findParts(n)) do table.insert(candidates, v) end
    end
    table.sort(candidates, function(a, b)
        local sa = a:IsA("BasePart") and a.Size.Magnitude or 0
        local sb = b:IsA("BasePart") and b.Size.Magnitude or 0
        return sa > sb
    end)
    return candidates[1]
end

local muscleThread
local function startAutoMuscle()
    if muscleThread then task.cancel(muscleThread) end
    muscleThread = task.spawn(function()
        while S.AutoMuscle do
            pcall(function()
                local item = findMuscleItem()
                if item then
                    local pos = getPos(item)
                    if pos then
                        tp(CFrame.new(pos + Vector3.new(0,3,0)))
                        clickPart(item)
                        fireRemote("Collect", item)
                        fireRemote("Grab", item)
                    end
                end
            end)
            task.wait(0.15)
        end
    end)
end

-- =============================================================================
--  MODULE 3 — AUTO VIOLET ×2
-- =============================================================================
local VIOLET_NAMES = {"Brainrot","Violet","Purple","Rare","Special","Brain","Rot","Aleatoire","Random"}

local function isViolet(p)
    if not p:IsA("BasePart") then return false end
    local c = p.Color
    return c.B > 0.4 and c.R > 0.2 and c.G < 0.4
end

local function findVioletItems()
    local list = {}
    for _, n in ipairs(VIOLET_NAMES) do
        for _, v in ipairs(findParts(n)) do table.insert(list, v) end
    end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if isViolet(v) then table.insert(list, v) end
    end
    return list
end

local violetThread
local function startAutoViolet()
    if violetThread then task.cancel(violetThread) end
    violetThread = task.spawn(function()
        while S.AutoViolet do
            pcall(function()
                for _, item in ipairs(findVioletItems()) do
                    local pos = getPos(item)
                    if pos then
                        tp(CFrame.new(pos + Vector3.new(0,3,0)))
                        clickPart(item) fireRemote("Click", item)
                        task.wait(0.05)
                        clickPart(item) fireRemote("Click", item)
                        task.wait(0.04)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- =============================================================================
--  MODULE 4 — AUTO MONEY
-- =============================================================================
local MONEY_NAMES = {"Cash","Money","Coin","Dollar","Bill","Gold","Drop","Credit","Token"}

local function findMoneyDrops()
    local list = {}
    local r = root() if not r then return list end
    for _, n in ipairs(MONEY_NAMES) do
        for _, v in ipairs(findParts(n)) do
            local pos = getPos(v)
            if pos and (r.Position - pos).Magnitude <= 60 then
                table.insert(list, v)
            end
        end
    end
    return list
end

local moneyThread
local function startAutoMoney()
    if moneyThread then task.cancel(moneyThread) end
    moneyThread = task.spawn(function()
        while S.AutoMoney do
            pcall(function()
                for _, drop in ipairs(findMoneyDrops()) do
                    local pos = getPos(drop)
                    if pos then
                        tp(CFrame.new(pos + Vector3.new(0,2,0)))
                        fireRemote("Collect", drop)
                        task.wait(0.02)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- =============================================================================
--  STOP ALL
-- =============================================================================
local function stopAll()
    S.AutoFarm=false S.AutoMuscle=false S.AutoViolet=false S.AutoMoney=false
    if farmThread   then task.cancel(farmThread)   farmThread=nil   end
    if muscleThread then task.cancel(muscleThread) muscleThread=nil end
    if violetThread then task.cancel(violetThread) violetThread=nil end
    if moneyThread  then task.cancel(moneyThread)  moneyThread=nil  end
end

-- =============================================================================
--  GUI — PHANTOM NOIR
-- =============================================================================
if CoreGui:FindFirstChild("AetherHub") then CoreGui:FindFirstChild("AetherHub"):Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "AetherHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = CoreGui

-- Couleurs phantom
local C = {
    Base    = Color3.fromRGB(10,  10,  12),   -- noir quasi-pur
    Sidebar = Color3.fromRGB(14,  14,  17),   -- noir légèrement plus clair
    Card    = Color3.fromRGB(18,  18,  22),   -- fond des cartes
    Active  = Color3.fromRGB(22,  22,  28),   -- onglet actif
    Border  = Color3.fromRGB(38,  38,  46),   -- bordure subtile
    Accent  = Color3.fromRGB(220, 220, 230),  -- blanc froid (texte/accent)
    Dim     = Color3.fromRGB(85,  85,  100),  -- texte secondaire
    ON      = Color3.fromRGB(180, 255, 180),  -- vert très pâle = activé
    OFF     = Color3.fromRGB(100, 100, 115),  -- gris = désactivé
    Red     = Color3.fromRGB(200, 70,  70),
    Stripe  = Color3.fromRGB(30,  30,  36),   -- séparateur
}

local function corner(p, r)
    local c = Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=p return c
end
local function stroke(p, col, t)
    local s = Instance.new("UIStroke") s.Color=col or C.Border s.Thickness=t or 1 s.Parent=p return s
end
local function lbl(p, txt, sz, col, xa, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency=1 l.Text=txt l.TextSize=sz or 13
    l.TextColor3=col or C.Accent l.Font=Enum.Font.Gotham l.RichText=true
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    for k,v in pairs(props or {}) do l[k]=v end
    l.Parent=p return l
end

-- ── Fenêtre principale ────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Size             = UDim2.new(0, 520, 0, 340)
MainFrame.Position         = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = C.Base
MainFrame.Active           = true
MainFrame.Draggable        = true   -- drag natif Roblox
MainFrame.Parent           = ScreenGui
corner(MainFrame, 8)
stroke(MainFrame, C.Border, 1)

-- Séparateur vertical sidebar/content
local Sep = Instance.new("Frame")
Sep.Size             = UDim2.new(0,1,1,-10)
Sep.Position         = UDim2.new(0,150,0,5)
Sep.BackgroundColor3 = C.Stripe
Sep.BorderSizePixel  = 0
Sep.Parent           = MainFrame

-- ── Sidebar ───────────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0,150,1,0)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel  = 0
Sidebar.Parent           = MainFrame
corner(Sidebar, 8)
-- Fix arrondi droit
local SideFix = Instance.new("Frame")
SideFix.Size=UDim2.new(0.5,0,1,0) SideFix.Position=UDim2.new(0.5,0,0,0)
SideFix.BackgroundColor3=C.Sidebar SideFix.BorderSizePixel=0 SideFix.Parent=Sidebar

-- Logo / titre sidebar
local LogoArea = Instance.new("Frame")
LogoArea.Size=UDim2.new(1,0,0,52) LogoArea.BackgroundTransparency=1 LogoArea.Parent=Sidebar

lbl(LogoArea, "AETHER", 15, C.Accent, Enum.TextXAlignment.Center, {
    Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,12),
    Font=Enum.Font.GothamBold,
})
lbl(LogoArea, "lucky block hub", 10, C.Dim, Enum.TextXAlignment.Center, {
    Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0,34),
})

-- Ligne sous logo
local LogoLine = Instance.new("Frame")
LogoLine.Size=UDim2.new(1,-20,0,1) LogoLine.Position=UDim2.new(0,10,0,52)
LogoLine.BackgroundColor3=C.Stripe LogoLine.BorderSizePixel=0 LogoLine.Parent=Sidebar

-- Liste des onglets (sidebar)
local TabList = Instance.new("Frame")
TabList.Size=UDim2.new(1,0,1,-60) TabList.Position=UDim2.new(0,0,0,58)
TabList.BackgroundTransparency=1 TabList.Parent=Sidebar
local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding=UDim.new(0,3) TabLayout.Parent=TabList
Instance.new("UIPadding",TabList).PaddingLeft=UDim.new(0,8)

-- ── Zone de contenu (droite) ──────────────────────────────────────
local Content = Instance.new("Frame")
Content.Size=UDim2.new(1,-160,1,-10)
Content.Position=UDim2.new(0,158,0,5)
Content.BackgroundTransparency=1
Content.ClipsDescendants=true
Content.Parent=MainFrame

-- ── Pages ─────────────────────────────────────────────────────────
local pages = {}

local function newPage(name)
    local p = Instance.new("Frame")
    p.Size=UDim2.new(1,0,1,0) p.BackgroundTransparency=1 p.Visible=false p.Parent=Content
    pages[name] = p
    return p
end

-- ── Onglet helper ─────────────────────────────────────────────────
local tabs = {}
local activeTab = nil

local function setPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, t in pairs(tabs) do
        if n == name then
            t.BackgroundColor3 = C.Active
            t.TextColor3       = C.Accent
        else
            t.BackgroundColor3 = Color3.fromRGB(0,0,0)
            t.BackgroundTransparency = 1
            t.TextColor3       = C.Dim
        end
    end
    activeTab = name
end

local function newTab(name, icon, pageName)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-4,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 1
    btn.Text             = icon .. "  " .. name
    btn.TextColor3       = C.Dim
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = TabList
    corner(btn, 5)
    -- Padding texte
    local pad = Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,10) pad.Parent=btn

    btn.MouseButton1Click:Connect(function() setPage(pageName) end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= pageName then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3=C.Accent}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= pageName then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3=C.Dim}):Play()
        end
    end)
    tabs[pageName] = btn
    return btn
end

-- =============================================================================
--  PAGE : ACCUEIL
-- =============================================================================
local PageHome = newPage("home")
newTab("Accueil", "⌂", "home")

lbl(PageHome, "Bienvenue", 18, C.Accent, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,30), Position=UDim2.new(0,4,0,6),
    Font=Enum.Font.GothamBold,
})
lbl(PageHome, "Sélectionne un onglet pour commencer.", 12, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,4,0,38),
})

-- Ligne séparateur
local function hline(page, y)
    local l=Instance.new("Frame") l.Size=UDim2.new(1,0,0,1) l.Position=UDim2.new(0,0,0,y)
    l.BackgroundColor3=C.Stripe l.BorderSizePixel=0 l.Parent=page
end
hline(PageHome, 65)

-- Stats live (kicks / argent)
local StatKick = lbl(PageHome, "⚡  Kicks :", 12, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,22), Position=UDim2.new(0,4,0,76),
})
local StatMoney = lbl(PageHome, "💰  Argent :", 12, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,22), Position=UDim2.new(0,4,0,104),
})

-- Update stats chaque seconde
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        pcall(function()
            local ls = lp:FindFirstChild("leaderstats") or lp:FindFirstChild("Stats")
            if not ls then return end
            local kicks = ls:FindFirstChild("Kicks") or ls:FindFirstChild("TotalKicks") or ls:FindFirstChild("Blocks")
            local money = ls:FindFirstChild("Cash")  or ls:FindFirstChild("Coins") or ls:FindFirstChild("Money")
            if kicks then StatKick.Text  = "⚡  Kicks :   " .. tostring(kicks.Value) end
            if money then
                local v = money.Value
                local f = v>=1e15 and ("$"..string.format("%.1f",v/1e15).."Q")
                    or v>=1e12 and ("$"..string.format("%.1f",v/1e12).."T")
                    or v>=1e9  and ("$"..string.format("%.1f",v/1e9).."B")
                    or v>=1e6  and ("$"..string.format("%.1f",v/1e6).."M")
                    or ("$"..tostring(v))
                StatMoney.Text = "💰  Argent :   " .. f
            end
        end)
    end
end)

-- =============================================================================
--  PAGE : AUTO FARM
-- =============================================================================
local PageFarm = newPage("farm")
newTab("Auto Farm", "▶", "farm")

-- Description
lbl(PageFarm, "Auto Farm", 16, C.Accent, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,26), Position=UDim2.new(0,4,0,4),
    Font=Enum.Font.GothamBold,
})
hline(PageFarm, 34)

-- =============================================================================
--  TOGGLE helper (style phantom : ON = texte vert pâle, OFF = gris)
-- =============================================================================
local toggleSetters = {}

local function newToggle(page, y, labelTxt, descTxt, settingKey, onEnable, onDisable)
    local card = Instance.new("Frame")
    card.Size=UDim2.new(1,-8,0,46) card.Position=UDim2.new(0,4,0,y)
    card.BackgroundColor3=C.Card card.BorderSizePixel=0 card.Parent=page
    corner(card,6) stroke(card,C.Border,1)

    lbl(card, labelTxt, 13, C.Accent, Enum.TextXAlignment.Left, {
        Size=UDim2.new(1,-70,0,20), Position=UDim2.new(0,10,0,5),
        Font=Enum.Font.GothamSemibold,
    })
    lbl(card, descTxt, 10, C.Dim, Enum.TextXAlignment.Left, {
        Size=UDim2.new(1,-70,0,16), Position=UDim2.new(0,10,0,26),
    })

    -- Pill toggle (sobre)
    local pill = Instance.new("Frame")
    pill.Size=UDim2.new(0,44,0,22) pill.Position=UDim2.new(1,-52,0.5,-11)
    pill.BackgroundColor3=Color3.fromRGB(28,28,33) pill.BorderSizePixel=0 pill.Parent=card
    corner(pill,11)
    local knob = Instance.new("Frame")
    knob.Size=UDim2.new(0,16,0,16) knob.Position=UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3=C.Dim knob.BorderSizePixel=0 knob.Parent=pill
    corner(knob,8)

    local state = S[settingKey] or false

    local function setVisual(on)
        TweenService:Create(pill, TweenInfo.new(0.18,Enum.EasingStyle.Quad),
            {BackgroundColor3 = on and Color3.fromRGB(40,60,40) or Color3.fromRGB(28,28,33)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.18,Enum.EasingStyle.Back),
            {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
             BackgroundColor3 = on and C.ON or C.Dim}):Play()
    end
    setVisual(state)
    toggleSetters[settingKey] = setVisual

    local click = Instance.new("TextButton")
    click.Size=UDim2.new(1,0,1,0) click.BackgroundTransparency=1 click.Text=""
    click.ZIndex=5 click.Parent=card
    click.AutoButtonColor=false

    click.MouseButton1Click:Connect(function()
        state = not state
        S[settingKey] = state
        setVisual(state)
        if state then if onEnable  then onEnable()  end
        else          if onDisable then onDisable() end end
    end)

    return card
end

-- Toggles de la page Farm
newToggle(PageFarm, 40,
    "Auto Farm",
    "Se téléporte dans la zone + kick auto",
    "AutoFarm",
    function() startAutoFarm() end,
    function() S.AutoFarm=false end
)
newToggle(PageFarm, 94,
    "Perfect Only",
    "Attend que la barre soit en haut",
    "PerfectOnly", nil, nil
)

-- =============================================================================
--  PAGE : COLLECTE
-- =============================================================================
local PageCollect = newPage("collect")
newTab("Collecte", "◈", "collect")

lbl(PageCollect, "Collecte", 16, C.Accent, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,26), Position=UDim2.new(0,4,0,4),
    Font=Enum.Font.GothamBold,
})
hline(PageCollect, 34)

newToggle(PageCollect, 40,
    "Auto Muscle Grab",
    "Ramasse le gros item musclé",
    "AutoMuscle",
    function() startAutoMuscle() end,
    function() S.AutoMuscle=false end
)
newToggle(PageCollect, 94,
    "Auto Violet ×2",
    "Clique les brainrots violets deux fois",
    "AutoViolet",
    function() startAutoViolet() end,
    function() S.AutoViolet=false end
)
newToggle(PageCollect, 148,
    "Auto Money",
    "Ramasse l'argent et les pièces au sol",
    "AutoMoney",
    function() startAutoMoney() end,
    function() S.AutoMoney=false end
)

-- =============================================================================
--  PAGE : PARAMÈTRES
-- =============================================================================
local PageSettings = newPage("settings")
newTab("Paramètres", "⚙", "settings")

lbl(PageSettings, "Paramètres", 16, C.Accent, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,26), Position=UDim2.new(0,4,0,4),
    Font=Enum.Font.GothamBold,
})
hline(PageSettings, 34)

newToggle(PageSettings, 40,
    "Anti AFK",
    "Empêche le kick d'inactivité",
    "AntiAFK", nil, nil
)

-- Bouton TOUT ACTIVER
local AllBtn = Instance.new("TextButton")
AllBtn.Size=UDim2.new(1,-8,0,34) AllBtn.Position=UDim2.new(0,4,0,140)
AllBtn.BackgroundColor3=C.Card
AllBtn.Text="▶  Tout activer"
AllBtn.TextColor3=C.ON AllBtn.Font=Enum.Font.GothamSemibold AllBtn.TextSize=13
AllBtn.BorderSizePixel=0 AllBtn.AutoButtonColor=false AllBtn.Parent=PageSettings
corner(AllBtn,6) stroke(AllBtn,C.Border,1)
AllBtn.MouseButton1Click:Connect(function()
    S.AutoFarm=true S.AutoMuscle=true S.AutoViolet=true S.AutoMoney=true
    for k,fn in pairs(toggleSetters) do
        if k=="AutoFarm" or k=="AutoMuscle" or k=="AutoViolet" or k=="AutoMoney" then fn(true) end
    end
    startAutoFarm() startAutoMuscle() startAutoViolet() startAutoMoney()
    TweenService:Create(AllBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,45,30)}):Play()
    task.delay(0.3,function() TweenService:Create(AllBtn,TweenInfo.new(0.2),{BackgroundColor3=C.Card}):Play() end)
end)

-- Bouton TOUT STOPPER
local StopBtn = Instance.new("TextButton")
StopBtn.Size=UDim2.new(1,-8,0,34) StopBtn.Position=UDim2.new(0,4,0,182)
StopBtn.BackgroundColor3=C.Card
StopBtn.Text="■  Tout stopper"
StopBtn.TextColor3=C.Red AllBtn.Font=Enum.Font.GothamSemibold StopBtn.TextSize=13
StopBtn.BorderSizePixel=0 StopBtn.AutoButtonColor=false StopBtn.Parent=PageSettings
corner(StopBtn,6) stroke(StopBtn,C.Border,1)
StopBtn.MouseButton1Click:Connect(function()
    stopAll()
    for k,fn in pairs(toggleSetters) do
        if k=="AutoFarm" or k=="AutoMuscle" or k=="AutoViolet" or k=="AutoMoney" then fn(false) end
    end
    TweenService:Create(StopBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(45,20,20)}):Play()
    task.delay(0.3,function() TweenService:Create(StopBtn,TweenInfo.new(0.2),{BackgroundColor3=C.Card}):Play() end)
end)

-- Version
lbl(PageSettings, "v3.0  —  AetherScripts", 10, C.Dim, Enum.TextXAlignment.Left, {
    Size=UDim2.new(1,-10,0,18), Position=UDim2.new(0,4,1,-22),
})

-- =============================================================================
--  BOUTON FERMER (coin haut droit de la fenêtre)
-- =============================================================================
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,22,0,22) CloseBtn.Position=UDim2.new(1,-28,0,6)
CloseBtn.BackgroundColor3=Color3.fromRGB(45,20,20)
CloseBtn.Text="✕" CloseBtn.TextColor3=C.Red
CloseBtn.Font=Enum.Font.GothamBold CloseBtn.TextSize=12
CloseBtn.BorderSizePixel=0 CloseBtn.AutoButtonColor=false CloseBtn.ZIndex=10
CloseBtn.Parent=MainFrame
corner(CloseBtn,5)
CloseBtn.MouseButton1Click:Connect(function()
    stopAll()
    TweenService:Create(MainFrame, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.delay(0.25, function() ScreenGui:Destroy() end)
end)

-- =============================================================================
--  OUVERTURE ANIMÉE + PAGE PAR DÉFAUT
-- =============================================================================
MainFrame.Size=UDim2.new(0,0,0,0)
MainFrame.Position=UDim2.new(0.5,0,0.5,0)
TweenService:Create(MainFrame, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,520,0,340), Position=UDim2.new(0.5,-260,0.5,-170)}):Play()

task.delay(0.05, function() setPage("home") end)

print("[AetherHub] ✓ Kick a Lucky Block — chargé")
