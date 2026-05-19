-- ╔══════════════════════════════════════════════╗
-- ║         SILENTVOID HUB & MULTI GAMES         ║
-- ║  Style : Dark Premium Noir Semi-Transparent  ║
-- ║  ESP Stable & Fluide pour Delta (Brookhaven) ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════
--  DESIGN NOIR SEMI-TRANSPARENT
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(10, 10, 12),      -- Noir Profond
    SIDEBAR     = Color3.fromRGB(14, 14, 16),      -- Noir Sidebar
    PANEL       = Color3.fromRGB(18, 18, 22),      -- Fond des options
    ROW         = Color3.fromRGB(22, 22, 26),      -- Lignes
    WHITE       = Color3.fromRGB(255, 255, 255),   -- Blanc Lumineux
    GRAY        = Color3.fromRGB(150, 150, 160),   -- Texte secondaire
    CYAN        = Color3.fromRGB(0, 210, 255),     -- Couleur Tracer/Box actif
    RED         = Color3.fromRGB(255, 60, 60),      -- Couleur Box caché / Éteint
    BORDER      = Color3.fromRGB(40, 40, 45),      -- Bordures discrètes
}

-- ══════════════════════════════════════════════
--  CONFIGURATION : TOUT EST DÉCOCHÉ PAR DÉFAUT
-- ══════════════════════════════════════════════
local espConfig = {
    Enabled         = false, -- Décoché
    TeamCheck       = false, -- Décoché
    VisibilityCheck = false, -- Décoché
    DistanceCheck   = false, -- Décoché
    MaxDistance     = 1000,
    BoxColor        = Color3.fromRGB(0, 255, 150),
    HiddenColor     = Color3.fromRGB(255, 50, 70),
    TracerColor     = Color3.fromRGB(0, 200, 255)
}

local RenderCache = {}

-- ══════════════════════════════════════════════
--  FONCTIONS DE SÉCURITÉ ET INTERFACE
-- ══════════════════════════════════════════════
local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function stroke(col, thick, p, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BORDER
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = p
    return s
end

local function lbl(props, parent)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextColor3 = C.WHITE
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
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
    b.TextColor3 = C.WHITE
    b.TextSize = 13
    b.AutoButtonColor = false
    for k,v in pairs(props) do b[k]=v end
    b.Parent = parent
    return b
end

-- ══════════════════════════════════════════════
--  INTERFACE INTERNE
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "SilentVoidHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = player:WaitForChild("PlayerGui")

local ESPContainer = frame({
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
}, sg)

-- Fenêtre principale (Noir transparent à 0.25)
local win = frame({
    Size = UDim2.new(0, 560, 0, 400),
    Position = UDim2.new(0.5, -280, 0.5, -200),
    BackgroundColor3 = C.BG,
    BackgroundTransparency = 0.25,
    Active = true,
    Draggable = true,
}, sg)
corner(10, win)
stroke(C.BORDER, 1.5, win)

-- Barre de titre
local titleBar = frame({
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = C.SIDEBAR,
    BackgroundTransparency = 0.25,
}, win)
corner(10, titleBar)

frame({
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = C.SIDEBAR,
    BackgroundTransparency = 0.25,
}, titleBar)

lbl({
    Text = " ✕  SilentVoid Hub & Multi Games",
    Size = UDim2.new(0, 400, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    TextColor3 = C.WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
}, titleBar)

local closeB = btn({
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -38, 0, 6),
    BackgroundColor3 = Color3.fromRGB(30, 15, 15),
    Text = "✕",
    TextColor3 = C.RED,
}, titleBar)
corner(6, closeB)

-- Sidebar
local sidebar = frame({
    Size = UDim2.new(0, 160, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = C.SIDEBAR,
    BackgroundTransparency = 0.3,
}, win)

frame({
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = C.BORDER,
}, sidebar)

local navContainer = frame({
    Size = UDim2.new(1, 0, 1, -40),
    Position = UDim2.new(0, 0, 0, 15),
    BackgroundTransparency = 1,
}, sidebar)

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navContainer

local pages = {}
local navBtns = {}

local function addTab(id, icon, name)
    local nb = btn({
        Size = UDim2.new(1, -16, 0, 38),
        BackgroundColor3 = C.SIDEBAR,
        BackgroundTransparency = 1,
        Text = "",
    }, navContainer)
    corner(6, nb)
    
    lbl({ Text = icon, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.GRAY }, nb)
    lbl({ Text = "| " .. name, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 38, 0, 0), TextColor3 = C.GRAY }, nb)
    
    local p = frame({ Size = UDim2.new(1, -160, 1, -42), Position = UDim2.new(0, 160, 0, 42), BackgroundTransparency = 1, Visible = false }, win)
    
    pages[id] = p
    navBtns[id] = nb
    return p
end

local pHome = addTab("home", "⌂", "Accueil")
local pVisuals = addTab("visuals", "👁", "Visuals / ESP")

local function makeRow(parent, yOff, title, sub, initVal, onChange)
    local row = frame({
        Size = UDim2.new(1, -20, 0, 52),
        Position = UDim2.new(0, 10, 0, yOff),
        BackgroundColor3 = C.ROW,
        BackgroundTransparency = 0.2,
    }, parent)
    corner(8, row)
    stroke(C.BORDER, 1, row)

    lbl({ Text = title, Size = UDim2.new(1, -110, 0, 24), Position = UDim2.new(0, 14, 0, 6), Font = Enum.Font.GothamBold }, row)
    lbl({ Text = sub, Size = UDim2.new(1, -110, 0, 20), Position = UDim2.new(0, 14, 0, 26), TextColor3 = C.GRAY, TextSize = 11 }, row)

    local state = initVal
    local track = frame({
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = state and C.CYAN or C.PANEL,
    }, row)
    corner(20, track)
    stroke(C.BORDER, 1, track)

    local knob = frame({
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = C.WHITE,
    }, track)
    corner(20, knob)

    local click = btn({ Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "" }, track)
    click.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.1), {BackgroundColor3 = state and C.CYAN or C.PANEL}):Play()
        TweenService:Create(knob, TweenInfo.new(0.1), {Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
        onChange(state)
    end)
end

-- Contenu Accueil
lbl({ Text = "SilentVoid Hub", Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 14, 0, 15), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.CYAN }, pHome)
lbl({ Text = "Bienvenue. Tout est désactivé par défaut.\nUtilisez l'onglet de gauche pour activer les fonctions.", Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0, 14, 0, 45), TextColor3 = C.GRAY }, pHome)

-- Contenu Options (Tout sur false)
makeRow(pVisuals, 15, "Activer ESP Core", "Affiche la boîte et la ligne sur les vrais joueurs", espConfig.Enabled, function(v) espConfig.Enabled = v end)
makeRow(pVisuals, 73, "Filtre d'Équipe (Team)", "Masque vos alliés si le jeu possède des équipes", espConfig.TeamCheck, function(v) espConfig.TeamCheck = v end)
makeRow(pVisuals, 131, "Filtre de Visibilité", "Boîte rouge si le joueur est derrière un mur", espConfig.VisibilityCheck, function(v) espConfig.VisibilityCheck = v end)
makeRow(pVisuals, 189, "Limite de Distance", "Masque les cibles à plus de 1000 Studs", espConfig.DistanceCheck, function(v) espConfig.DistanceCheck = v end)

-- ══════════════════════════════════════════════
--  MOTEUR DE DÉTECTION ET RENDU RÉEL (Membres Map)
-- ══════════════════════════════════════════════
local function GetCharacter(p)
    return p.Character
end

local function IsPlayerValid(p)
    local char = GetCharacter(p)
    return char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function CreateVisualElements(p)
    if RenderCache[p] then return end
    
    local elements = {}
    
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.Visible = false
    box.Parent = ESPContainer
    stroke(espConfig.BoxColor, 1.5, box)
    elements.Box = box
    
    local tracer = frame({
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = espConfig.TracerColor,
        Visible = false,
    }, ESPContainer)
    elements.Tracer = tracer
    
    RenderCache[p] = elements
end

local function ClearVisualElements(p)
    if RenderCache[p] then
        if RenderCache[p].Box then RenderCache[p].Box:Destroy() end
        if RenderCache[p].Tracer then RenderCache[p].Tracer:Destroy() end
        RenderCache[p] = nil
    end
end

-- Boucle de synchronisation forcée
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        
        -- Crée les éléments s'ils n'existent pas encore pour ce joueur réel
        if not RenderCache[p] then CreateVisualElements(p) end
        
        local visual = RenderCache[p]
        
        -- Si l'interrupteur principal est éteint ou si le joueur n'est pas valide
        if not espConfig.Enabled or not IsPlayerValid(p) or not IsPlayerValid(player) then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end
        
        -- Team Check
        if espConfig.TeamCheck and p.Team == player.Team then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end
        
        local char = p.Character
        local root = char.HumanoidRootPart
        local distance = (root.Position - Camera.CFrame.Position).Magnitude
        
        -- Distance Check
        if espConfig.DistanceCheck and distance > espConfig.MaxDistance then
            visual.Box.Visible = false
            visual.Tracer.Visible = false
            continue
        end
        
        -- Traduction de la position 3D réelle en coordonnées écran
        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
        
        if onScreen then
            -- Calcul de dimensionnement de la boîte
            local scale = (5.2 * Camera.ViewportSize.Y) / (2 * distance * math.tan(math.rad(Camera.FieldOfView / 2)))
            local w, h = scale * 0.85, scale * 1.15
            
            -- Affichage de la boîte
            visual.Box.Size = UDim2.new(0, w, 0, h)
            visual.Box.Position = UDim2.new(0, screenPos.X - (w / 2), 0, screenPos.Y - (h / 2))
            
            -- Visibilité des murs (Raycast)
            local isVisible = true
            if espConfig.VisibilityCheck then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {player.Character, char}
                local ray = Workspace:Raycast(Camera.CFrame.Position, root.Position - Camera.CFrame.Position, params)
                if ray then isVisible = false end
            end
            
            visual.Box:FindFirstChildOfClass("UIStroke").Color = isVisible and espConfig.BoxColor or espConfig.HiddenColor
            visual.Box.Visible = true
            
            -- Tracé de la ligne (Haut de l'écran vers la tête du joueur)
            local startX, startY = Camera.ViewportSize.X / 2, 0
            local endX, endY = screenPos.X, screenPos.Y - (h / 2)
            
            local dx = endX - startX
            local dy = endY - startY
            local length = math.sqrt(dx^2 + dy^2)
            local angle = math.atan2(dy, dx)
            
            visual.Tracer.Size = UDim2.new(0, 1.5, 0, length)
            visual.Tracer.Position = UDim2.new(0, startX, 0, startY)
            visual.Tracer.Rotation = math.deg(angle) - 90
            visual.Tracer.Visible = true
        else
            visual.Box.Visible = false
            visual.Tracer.Visible = false
        end
    end
end)

-- Nettoyage automatique des déco
Players.PlayerRemoving:Connect(ClearVisualElements)

-- ══════════════════════════════════════════════
--  NAVIGATION INTERFACE
-- ══════════════════════════════════════════════
local function showPage(id)
    for pid, p in pairs(pages) do p.Visible = (pid == id) end
    for nid, b in pairs(navBtns) do
        local active = (nid == id)
        b.BackgroundTransparency = active and 0.85 or 1
        b:FindFirstChildOfClass("TextLabel").TextColor3 = active and C.CYAN or C.GRAY
    end
end

showPage("home")

for id, b in pairs(navBtns) do
    b.MouseButton1Click:Connect(function() showPage(id) end)
end

closeB.MouseButton1Click:Connect(function()
    espConfig.Enabled = false
    for _, v in pairs(RenderCache) do
        if v.Box then v.Box:Destroy() end
        if v.Tracer then v.Tracer:Destroy() end
    end
    sg:Destroy()
end)
