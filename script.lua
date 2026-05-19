-- ╔══════════════════════════════════════════════╗
-- ║        AETHER HUB  —  Visuals Update         ║
-- ║  Style : dark hub vert/noir type Lucky Block  ║
-- ║  ESP Boxes + Tracers (Ultra-compatible UI)    ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════
--  CONSTANTES DESIGN (Inspiré de ton thème)
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(14, 16, 14),
    SIDEBAR     = Color3.fromRGB(18, 22, 18),
    PANEL       = Color3.fromRGB(22, 28, 22),
    ROW         = Color3.fromRGB(26, 34, 26),
    GREEN       = Color3.fromRGB(80, 220, 60),
    GREEN_DIM   = Color3.fromRGB(40, 120, 30),
    GREEN_DARK  = Color3.fromRGB(20, 60, 15),
    ACCENT      = Color3.fromRGB(100, 255, 70),
    TEXT        = Color3.fromRGB(220, 235, 220),
    TEXT_DIM    = Color3.fromRGB(120, 150, 110),
    TEXT_BRIGHT = Color3.fromRGB(255, 255, 255),
    RED         = Color3.fromRGB(220, 60, 60),
    BORDER      = Color3.fromRGB(50, 100, 40),
}

-- ══════════════════════════════════════════════
--  ÉTAT DES OPTIONS (ESP & COMPACT)
-- ══════════════════════════════════════════════
local espConfig = {
    Enabled         = true,
    TeamCheck       = false, -- Mis sur false par défaut pour Brookhaven
    VisibilityCheck = true,
    DistanceCheck   = true,
    MaxDistance     = 800,
    BoxColor        = Color3.fromRGB(80, 220, 60),
    HiddenColor     = Color3.fromRGB(220, 60, 60),
    TracerColor     = Color3.fromRGB(100, 255, 70)
}

local RenderCache = {}
local RaycastParamsInstance = RaycastParams.new()
RaycastParamsInstance.FilterType = Enum.RaycastFilterType.Exclude

-- ══════════════════════════════════════════════
--  HELPERS GUI NATIVES
-- ══════════════════════════════════════════════
local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end
local function stroke(col, thick, p)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BORDER
    s.Thickness = thick or 1
    s.Parent = p
    return s
end
local function lbl(props, parent)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextColor3 = C.TEXT
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    for k,v in pairs(props) do l[k]=v end
    l.Parent = parent
    return l
end
local function frame(props, parent)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k]=v end
    f.Parent = parent
    return f
end
local function btn(props, parent)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = C.TEXT_BRIGHT
    b.TextSize = 13
    b.AutoButtonColor = false
    for k,v in pairs(props) do b[k]=v end
    b.Parent = parent
    return b
end

-- ══════════════════════════════════════════════
--  SCREEN GUI PRINCIPAL
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "AetherHubVisuals"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = player:WaitForChild("PlayerGui")

-- Conteneur sécurisé pour le rendu des lignes et boîtes (évite les bugs d'affichage)
local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESPContainer"
ESPContainer.Parent = sg

-- Fenêtre principale
local win = frame({
    Size = UDim2.new(0, 560, 0, 400),
    Position = UDim2.new(0.5, -280, 0.5, -200),
    BackgroundColor3 = C.BG,
    Active = true,
    Draggable = true,
}, sg)
corner(10, win)
stroke(C.GREEN_DIM, 1.5, win)

-- Barre titre
local titleBar = frame({
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = C.SIDEBAR,
}, win)
corner(10, titleBar)

local titleFix = frame({
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = C.SIDEBAR,
}, titleBar)

lbl({
    Text = "⬡  Aether Hub — Shooter Edition",
    Size = UDim2.new(0, 300, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    TextColor3 = C.GREEN,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
}, titleBar)

-- Bouton X (Fermeture)
local closeB = btn({
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -36, 0, 5),
    BackgroundColor3 = Color3.fromRGB(40, 20, 20),
    Text = "✕",
    TextSize = 14,
    TextColor3 = C.RED,
}, titleBar)
corner(6, closeB)

-- ── Sidebar ──────────────────────────────────
local sidebar = frame({
    Size = UDim2.new(0, 160, 1, -38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = C.SIDEBAR,
}, win)

frame({
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = C.BORDER,
}, sidebar)

-- Nav items
local navItems = {
    { icon = "⌂", label = "Home",        id = "home" },
    { icon = "👁", label = "Visuals/ESP", id = "visuals" },
}

local navBtns = {}
local navContainer = frame({
    Size = UDim2.new(1, 0, 1, -50),
    Position = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1,
}, sidebar)

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navContainer

for _, item in ipairs(navItems) do
    local nb = btn({
        Size = UDim2.new(1, -16, 0, 40),
        BackgroundColor3 = C.SIDEBAR,
        Text = "",
    }, navContainer)
    corner(6, nb)

    lbl({
        Text = item.icon,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = C.TEXT_DIM,
        TextSize = 16,
    }, nb)
    
    lbl({
        Text = "| " .. item.label,
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        TextColor3 = C.TEXT_DIM,
        TextSize = 13,
    }, nb)

    navBtns[item.id] = nb
end

local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 8)
navPad.PaddingRight = UDim.new(0, 8)
navPad.Parent = navContainer

-- ── Zone contenu ─────────────────────────────
local content = frame({
    Size = UDim2.new(1, -160, 1, -38),
    Position = UDim2.new(0, 160, 0, 38),
    BackgroundTransparency = 1,
}, win)

local pages = {}
local function newPage(id)
    local p = frame({
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    }, content)
    pages[id] = p
    return p
end

-- Row créateur type Aether Hub
local function makeRow(parent, yOff, title, sub, rightWidget)
    local row = frame({
        Size = UDim2.new(1, -20, 0, 52),
        Position = UDim2.new(0, 10, 0, yOff),
        BackgroundColor3 = C.ROW,
    }, parent)
    corner(8, row)
    stroke(Color3.fromRGB(35, 50, 30), 1, row)

    lbl({ Text = title, Size = UDim2.new(1, -110, 0, 24), Position = UDim2.new(0, 14, 0, 6), TextColor3 = C.TEXT_BRIGHT, TextSize = 13, Font = Enum.Font.GothamBold }, row)
    lbl({ Text = sub, Size = UDim2.new(1, -110, 0, 20), Position = UDim2.new(0, 14, 0, 28), TextColor3 = C.TEXT_DIM, TextSize = 11 }, row)

    if rightWidget then rightWidget(row) end
    return row
end

local function makeToggle(parent, initVal, onChange)
    local state = initVal or false
    local track = frame({
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -55, 0.5, -12),
        BackgroundColor3 = state and C.GREEN or C.PANEL,
    }, parent)
    corner(20, track)
    stroke(C.BORDER, 1, track)

    local knob = frame({
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = C.TEXT_BRIGHT,
    }, track)
    corner(20, knob)

    local clickZone = btn({ Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "" }, track)
    clickZone.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.12), {BackgroundColor3 = state and C.GREEN or C.PANEL}):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
        if onChange then onChange(state) end
    end)
end

-- ══════════════════════════════════════════════
--  PAGE 1 : HOME
-- ══════════════════════════════════════════════
local pHome = newPage("home")
lbl({ Text = "Home", Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 14, 0, 10), TextColor3 = C.ACCENT, TextSize = 15, Font = Enum.Font.GothamBold }, pHome)

local welcomeBox = frame({ Size = UDim2.new(1, -20, 0, 80), Position = UDim2.new(0, 10, 0, 40), BackgroundColor3 = C.GREEN_DARK }, pHome)
corner(10, welcomeBox)
stroke(C.GREEN_DIM, 1, welcomeBox)

lbl({ Text = "⚡ Aether Hub — ESP Visuals chargé", Size = UDim2.new(1,-20,0,28), Position = UDim2.new(0,12,0,8), TextColor3 = C.GREEN, TextSize = 14, Font = Enum.Font.GothamBold }, welcomeBox)
lbl({ Text = "Boîtes 2D dynamiques & Tracers hautes performances.\nAllez dans l'onglet 'Visuals/ESP' pour configurer.", Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,12,0,36), TextColor3 = C.TEXT_DIM, TextSize = 11 }, welcomeBox)

-- ══════════════════════════════════════════════
--  PAGE 2 : VISUALS (ESP CONTROLS)
-- ══════════════════════════════════════════════
local pVisuals = newPage("visuals")
lbl({ Text = "Options de Vision (ESP)", Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 14, 0, 10), TextColor3 = C.ACCENT, TextSize = 15, Font = Enum.Font.GothamBold }, pVisuals)

local r_esp = makeRow(pVisuals, 40, "🟢 Activer l'ESP", "Affiche les boîtes et les tracés", function(r)
    makeToggle(r, espConfig.Enabled, function(v) espConfig.Enabled = v end)
end)

local r_team = makeRow(pVisuals, 98, "👥 Vérification d'Équipe", "Cache les membres de votre équipe", function(r)
    makeToggle(r, espConfig.TeamCheck, function(v) espConfig.TeamCheck = v end)
end)

local r_wall = makeRow(pVisuals, 156, "🧱 Vérification des Murs", "Change de couleur si l'ennemi est caché", function(r)
    makeToggle(r, espConfig.VisibilityCheck, function(v) espConfig.VisibilityCheck = v end)
end)

local r_dist = makeRow(pVisuals, 214, "📏 Limite de Distance", "Optimise le rendu à moins de 800 studs", function(r)
    makeToggle(r, espConfig.DistanceCheck, function(v) espConfig.DistanceCheck = v end)
end)

-- ══════════════════════════════════════════════
--  MOTEUR DE RENDU ESP (UI COMPATIBLE DELTA)
-- ══════════════════════════════════════════════
local function IsAlive(p)
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function CheckVisibility(character, origin)
    local targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    if not targetPart then return false end
    RaycastParamsInstance.FilterDescendantsInstances = {player.Character, character}
    local direction = targetPart.Position - origin
    local raycastResult = Workspace:Raycast(origin, direction, RaycastParamsInstance)
    return raycastResult == nil
end

-- Création des éléments de rendu
local function CreateESP(targetPlayer)
    if RenderCache[targetPlayer] then return end

    local objects = {}

    -- Boîte en éléments UI natifs (Parfaitement stable)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = ESPContainer
    stroke(espConfig.BoxColor, 1.5, box)
    objects.Box = box

    -- Ligne en élément UI natif (Tracer via Frame orientée)
    local tracer = Instance.new("Frame")
    tracer.AnchorPoint = Vector2.new(0.5, 0)
    tracer.BorderSizePixel = 0
    tracer.BackgroundColor3 = espConfig.TracerColor
    tracer.Visible = false
    tracer.Parent = ESPContainer
    objects.Tracer = tracer

    RenderCache[targetPlayer] = objects
end

local function RemoveESP(targetPlayer)
    if RenderCache[targetPlayer] then
        if RenderCache[targetPlayer].Box then RenderCache[targetPlayer].Box:Destroy() end
        if RenderCache[targetPlayer].Tracer then RenderCache[targetPlayer].Tracer:Destroy() end
        RenderCache[targetPlayer] = nil
    end
end

-- Boucle de calcul synchrone sur l'écran
RunService.RenderStepped:Connect(function()
    for targetPlayer, visual in pairs(RenderCache) do
        if not espConfig.Enabled or not IsAlive(targetPlayer) or not IsAlive(player) then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end

        if espConfig.TeamCheck and targetPlayer.Team == player.Team then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end

        local character = targetPlayer.Character
        local rootPart = character.HumanoidRootPart
        local cameraPos = Camera.CFrame.Position
        local distance = (rootPart.Position - cameraPos).Magnitude

        if espConfig.DistanceCheck and distance > espConfig.MaxDistance then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end

        -- Calcul de taille de la boîte proportionnelle
        local scaleFactor = (5.2 * Camera.ViewportSize.Y) / (2 * distance * math.tan(math.rad(Camera.FieldOfView / 2)))
        local boxWidth, boxHeight = scaleFactor * 0.85, scaleFactor * 1.15

        -- Placement de la boîte UI
        visual.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
        visual.Box.Position = UDim2.new(0, rootPos.X - (boxWidth / 2), 0, rootPos.Y - (boxHeight / 2))
        
        -- Changement de couleur dynamique (murs)
        local isVisible = true
        if espConfig.VisibilityCheck then
            isVisible = CheckVisibility(character, cameraPos)
        end
        visual.Box:FindFirstChildOfClass("UIStroke").Color = isVisible and espConfig.BoxColor or espConfig.HiddenColor
        visual.Box.Visible = true

        -- Dessin mathématique du Tracer (De l'UI haut-milieu vers l'ennemi)
        local startX, startY = Camera.ViewportSize.X / 2, 0
        local endX, endY = rootPos.X, rootPos.Y - (boxHeight / 2)

        local distanceX = endX - startX
        local distanceY = endY - startY
        local lineLength = math.sqrt(distanceX^2 + distanceY^2)
        local angle = math.atan2(distanceY, distanceX)

        visual.Tracer.Size = UDim2.new(0, 1.5, 0, lineLength)
        visual.Tracer.Position = UDim2.new(0, startX, 0, startY)
        visual.Tracer.Rotation = math.deg(angle) - 90
        visual.Tracer.Visible = true
    end
end)

-- ══════════════════════════════════════════════
--  INITIALISATION ET SUPPORTS JOUEURS
-- ══════════════════════════════════════════════
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= player then CreateESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

-- ══════════════════════════════════════════════
--  NAVIGATION & NETTOYAGE
-- ══════════════════════════════════════════════
local function switchPage(id)
    for pid, p in pairs(pages) do p.Visible = (pid == id) end
    for nid, nb in pairs(navBtns) do
        local active = (nid == id)
        TweenService:Create(nb, TweenInfo.new(0.12), {BackgroundColor3 = active and C.GREEN_DARK or C.SIDEBAR}):Play()
    end
end

switchPage("home")

for id, nb in pairs(navBtns) do
    nb.MouseButton1Click:Connect(function() switchPage(id) end)
end

closeB.MouseButton1Click:Connect(function()
    espConfig.Enabled = false
    sg:Destroy()
end)
