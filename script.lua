-- ╔══════════════════════════════════════════════╗
-- ║         SILENTVOID HUB & MULTI GAMES         ║
-- ║  Style : Dark Premium Noir Semi-Transparent  ║
-- ║       Fix Tracers Mobile & Custom RGB        ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════
--  DESIGN ET COULEURS INITIALES
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(10, 10, 12),      
    SIDEBAR     = Color3.fromRGB(14, 14, 16),      
    PANEL       = Color3.fromRGB(18, 18, 22),      
    ROW         = Color3.fromRGB(22, 22, 26),      
    WHITE       = Color3.fromRGB(255, 255, 255),   
    GRAY        = Color3.fromRGB(150, 150, 160),   
    CYAN        = Color3.fromRGB(0, 210, 255),     
    RED         = Color3.fromRGB(255, 60, 60),      
    BORDER      = Color3.fromRGB(40, 40, 45),      
}

-- Tout est décoché par défaut au démarrage
local espConfig = {
    Enabled         = false,
    BoxVisible      = false,
    TracerVisible   = false,
    ShowName        = false,
    ShowDistance    = false,
    TeamCheck       = false,
    
    -- Valeurs de base pour le créateur RGB personnalisé
    R = 0,
    G = 210,
    B = 255
}

-- Fonction pour obtenir la couleur personnalisée choisie par le joueur
local function GetCustomColor()
    return Color3.fromRGB(espConfig.R, espConfig.G, espConfig.B)
end

local RenderCache = {}

-- ══════════════════════════════════════════════
--  FONCTIONS INTERFACE UTILITAIRES
-- ══════════════════════════════════════════════
local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
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
--  INTERFACE GRAPHIQUE PRINCIPALE
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "SilentVoidHubV3"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = player:WaitForChild("PlayerGui")

local ESPContainer = frame({ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, sg)

local win = frame({
    Size = UDim2.new(0, 560, 0, 420),
    Position = UDim2.new(0.5, -280, 0.5, -210),
    BackgroundColor3 = C.BG,
    BackgroundTransparency = 0.25,
    Active = true,
    Draggable = true,
}, sg)
corner(10, win)
stroke(C.BORDER, 1.5, win)

local titleBar = frame({ Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.25 }, win)
corner(10, titleBar)

frame({ Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.25 }, titleBar)

lbl({ Text = " ✕  SilentVoid Hub & Multi Games", Size = UDim2.new(0, 400, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextColor3 = C.WHITE, TextSize = 14, Font = Enum.Font.GothamBold }, titleBar)

local closeB = btn({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -38, 0, 6), BackgroundColor3 = Color3.fromRGB(30, 15, 15), Text = "✕", TextColor3 = C.RED }, titleBar)
corner(6, closeB)

-- Sidebar
local sidebar = frame({ Size = UDim2.new(0, 160, 1, -42), Position = UDim2.new(0, 0, 0, 42), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.3 }, win)
frame({ Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.BORDER }, sidebar)

local navContainer = frame({ Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1 }, sidebar)
local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navContainer

local pages = {}
local navBtns = {}

local function addTab(id, icon, name)
    local nb = btn({ Size = UDim2.new(1, -16, 0, 38), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 1, Text = "" }, navContainer)
    corner(6, nb)
    lbl({ Text = icon, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.GRAY }, nb)
    lbl({ Text = "| " .. name, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 38, 0, 0), TextColor3 = C.GRAY }, nb)
    local p = frame({ Size = UDim2.new(1, -160, 1, -42), Position = UDim2.new(0, 160, 0, 42), BackgroundTransparency = 1, Visible = false }, win)
    pages[id] = p; navBtns[id] = nb
    return p
end

local pHome = addTab("home", "⌂", "Accueil")
local pVisuals = addTab("visuals", "👁", "Visuals / ESP")
local pColors = addTab("colors", "🎨", "Couleurs RGB")

-- Créateur de Toggles
local function makeRow(parent, yOff, title, sub, initVal, onChange)
    local row = frame({ Size = UDim2.new(1, -20, 0, 48), Position = UDim2.new(0, 10, 0, yOff), BackgroundColor3 = C.ROW, BackgroundTransparency = 0.2 }, parent)
    corner(8, row); stroke(C.BORDER, 1, row)
    lbl({ Text = title, Size = UDim2.new(1, -110, 0, 22), Position = UDim2.new(0, 12, 0, 4), Font = Enum.Font.GothamBold }, row)
    lbl({ Text = sub, Size = UDim2.new(1, -110, 0, 18), Position = UDim2.new(0, 12, 0, 24), TextColor3 = C.GRAY, TextSize = 11 }, row)

    local state = initVal
    local track = frame({ Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -54, 0.5, -11), BackgroundColor3 = state and C.CYAN or C.PANEL }, row)
    corner(20, track); stroke(C.BORDER, 1, track)
    local knob = frame({ Size = UDim2.new(0, 16, 0, 16), Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = C.WHITE }, track)
    corner(20, knob)

    btn({ Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "" }, track).MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.1), {BackgroundColor3 = state and C.CYAN or C.PANEL}):Play()
        TweenService:Create(knob, TweenInfo.new(0.1), {Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
        onChange(state)
    end)
end

-- Créateur de Sliders de Couleur (Pour configurer ton RGB proprement sur Mobile)
local function makeColorSlider(parent, yOff, channelName, maxVal, initVal, onSliderChange)
    local row = frame({ Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, yOff), BackgroundColor3 = C.ROW, BackgroundTransparency = 0.2 }, parent)
    corner(6, row); stroke(C.BORDER, 1, row)
    
    local title = lbl({ Text = channelName .. " : " .. initVal, Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 12, 0, 0), Font = Enum.Font.GothamBold }, row)
    
    local slideBg = frame({ Size = UDim2.new(1, -120, 0, 6), Position = UDim2.new(0, 100, 0.5, -3), BackgroundColor3 = C.PANEL }, row)
    corner(3, slideBg)
    
    local slideFill = frame({ Size = UDim2.new(initVal/maxVal, 0, 1, 0), BackgroundColor3 = C.CYAN }, slideBg)
    corner(3, slideFill)
    
    local targetButton = btn({ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, slideBg)
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
        slideFill.Size = UDim2.new(percentage, 0, 1, 0)
        local calculatedValue = math.floor(percentage * maxVal)
        title.Text = channelName .. " : " .. calculatedValue
        onSliderChange(calculatedValue)
    end
    
    local dragging = false
    targetButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ── CONTENU ACCUEIL ───────────────────────────
lbl({ Text = "SilentVoid Hub", Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 14, 0, 15), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.CYAN }, pHome)
lbl({ Text = "Correctif Tracers Mobile appliqué.\n\nTout est décoché au démarrage.\nCochez vos options dans 'Visuals / ESP'.\nCréez votre propre couleur dans 'Couleurs RGB'.", Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 14, 0, 50), TextColor3 = C.GRAY }, pHome)

-- ── CONTENU VISUALS ───────────────────────────
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -10); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 360); scroll.ScrollBarThickness = 2; scroll.Parent = pVisuals

makeRow(scroll, 10, "Activer l'ESP Global", "Doit être coché pour voir les éléments", espConfig.Enabled, function(v) espConfig.Enabled = v end)
makeRow(scroll, 65, "Afficher les Boîtes (Boxes)", "Cadre autour des vrais membres de la map", espConfig.BoxVisible, function(v) espConfig.BoxVisible = v end)
makeRow(scroll, 120, "Afficher les Lignes (Tracers)", "Ligne droite parfaite depuis le haut", espConfig.TracerVisible, function(v) espConfig.TracerVisible = v end)
makeRow(scroll, 175, "Afficher le Pseudo", "Affiche le vrai nom au-dessus du joueur", espConfig.ShowName, function(v) espConfig.ShowName = v end)
makeRow(scroll, 230, "Afficher la Distance", "Affiche la distance exacte en temps réel", espConfig.ShowDistance, function(v) espConfig.ShowDistance = v end)
makeRow(scroll, 285, "Filtre d'Équipe", "Ignore les alliés", espConfig.TeamCheck, function(v) espConfig.TeamCheck = v end)

-- ── CONTENU COULEURS RGB ──────────────────────
lbl({ Text = "Créateur de couleur ESP personnalisée (RGB)", Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 14, 0, 15), Font = Enum.Font.GothamBold }, pColors)

local previewColor = frame({ Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0, 14, 0, 45), BackgroundColor3 = GetCustomColor() }, pColors)
corner(8, previewColor); stroke(C.WHITE, 1, previewColor)

local function updatePreview()
    previewColor.BackgroundColor3 = GetCustomColor()
end

makeColorSlider(pColors, 120, "Rouge (R)", 255, espConfig.R, function(v) espConfig.R = v updatePreview() end)
makeColorSlider(pColors, 165, "Vert (G)", 255, espConfig.G, function(v) espConfig.G = v updatePreview() end)
makeColorSlider(pColors, 210, "Bleu (B)", 255, espConfig.B, function(v) espConfig.B = v updatePreview() end)

-- ══════════════════════════════════════════════
--  MOTEUR ESP STABLE CORRIGÉ POUR MOBILE
-- ══════════════════════════════════════════════
local function IsPlayerValid(p)
    local char = p.Character
    return char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function CreateVisualElements(p)
    if RenderCache[p] then return end
    local elements = {}
    
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1; box.Visible = false; box.Parent = ESPContainer
    stroke(GetCustomColor(), 1.5, box)
    elements.Box = box
    
    -- Le Tracer utilise maintenant un Frame d'épaisseur fixe sans rotation compliquée (Correction mobile complète)
    local tracer = frame({ BackgroundColor3 = GetCustomColor(), Visible = false }, ESPContainer)
    elements.Tracer = tracer
    
    local infoTag = lbl({ Size = UDim2.new(0, 200, 0, 30), Text = "", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Visible = false }, ESPContainer)
    infoTag.Font = Enum.Font.GothamBold
    stroke(Color3.fromRGB(0,0,0), 1.5, infoTag) -- Contour noir anti-aliasing pour mobile
    elements.InfoTag = infoTag
    
    RenderCache[p] = elements
end

local function ClearVisualElements(p)
    if RenderCache[p] then
        if RenderCache[p].Box then RenderCache[p].Box:Destroy() end
        if RenderCache[p].Tracer then RenderCache[p].Tracer:Destroy() end
        if RenderCache[p].InfoTag then RenderCache[p].InfoTag:Destroy() end
        RenderCache[p] = nil
    end
end

RunService.RenderStepped:Connect(function()
    local customColor = GetCustomColor()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not RenderCache[p] then CreateVisualElements(p) end
        local visual = RenderCache[p]
        
        if not espConfig.Enabled or not IsPlayerValid(p) or not IsPlayerValid(player) then
            visual.Box.Visible = false; visual.Tracer.Visible = false; visual.InfoTag.Visible = false
            continue
        end
        
        if espConfig.TeamCheck and p.Team == player.Team then
            visual.Box.Visible = false; visual.Tracer.Visible = false; visual.InfoTag.Visible = false
            continue
        end
        
        local char = p.Character
        local root = char.HumanoidRootPart
        local distance = (root.Position - Camera.CFrame.Position).Magnitude
        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
        
        if onScreen then
            local scale = (5.2 * Camera.ViewportSize.Y) / (2 * distance * math.tan(math.rad(Camera.FieldOfView / 2)))
            local w, h = scale * 0.85, scale * 1.15
            
            -- 1. AFFICHAGE DES CADRES (BOXES)
            if espConfig.BoxVisible then
                visual.Box.Size = UDim2.new(0, w, 0, h)
                visual.Box.Position = UDim2.new(0, screenPos.X - (w / 2), 0, screenPos.Y - (h / 2))
                visual.Box:FindFirstChildOfClass("UIStroke").Color = customColor
                visual.Box.Visible = true
            else
                visual.Box.Visible = false
            end
            
            -- 2. AFFICHAGE DES LIGNES (TRACERS) — FIX MOBILE ABSOLU
            if espConfig.TracerVisible then
                local startX, startY = Camera.ViewportSize.X / 2, 0 -- Haut-Milieu exact
                local endX, endY = screenPos.X, screenPos.Y - (h / 2) -- Tête du joueur
                
                local dx = endX - startX
                local dy = endY - startY
                local length = math.sqrt(dx^2 + dy^2)
                
                -- Positionnement par géométrie vectorielle directe pour éviter les sauts d'écrans mobiles
                visual.Tracer.Size = UDim2.new(0, length, 0, 2)
                visual.Tracer.Position = UDim2.new(0, startX + dx / 2, 0, startY + dy / 2)
                visual.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                visual.Tracer.Rotation = math.deg(math.atan2(dy, dx))
                visual.Tracer.BackgroundColor3 = customColor
                visual.Tracer.Visible = true
            else
                visual.Tracer.Visible = false
            end
            
            -- 3. AFFICHAGE DES PSEUDOS ET DISTANCES
            if espConfig.ShowName or espConfig.ShowDistance then
                local labelText = ""
                if espConfig.ShowName then labelText = labelText .. p.Name end
                if espConfig.ShowDistance then
                    if labelText ~= "" then labelText = labelText .. " [" .. math.floor(distance) .. "s]" else labelText = math.floor(distance) .. "s" end
                end
                
                visual.InfoTag.Text = labelText
                visual.InfoTag.TextColor3 = customColor
                visual.InfoTag.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 25)
                visual.InfoTag.Visible = true
            else
                visual.InfoTag.Visible = false
            end
        else
            visual.Box.Visible = false; visual.Tracer.Visible = false; visual.InfoTag.Visible = false
        end
    end
end)

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
    for _, p in ipairs(Players:GetPlayers()) do ClearVisualElements(p) end
    sg:Destroy()
end)
