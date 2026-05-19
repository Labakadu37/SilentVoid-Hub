-- ╔══════════════════════════════════════════════╗
-- ║         SILENTVOID HUB & MULTI GAMES         ║
-- ║  Style : Dark Premium Noir Semi-Transparent  ║
-- ║    Aimbot Raycast Direct & Clear ESP V8      ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local originalGravity = Workspace.Gravity

-- Nettoyage automatique au lancement
if player:WaitForChild("PlayerGui"):FindFirstChild("SilentVoidHubV8") then
    player.PlayerGui.SilentVoidHubV8:Destroy()
end

-- ══════════════════════════════════════════════
--  DESIGN ET CONFIGURATION (Décoché par défaut)
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

local config = {
    EspEnabled     = false,
    BoxVisible     = false,
    TracerVisible  = false,
    ShowName       = false,
    ShowDistance   = false,
    
    AimbotEnabled  = false,
    FovEnabled     = false,
    FovRadius      = 140, 
    
    FlyEnabled     = false,
    FlySpeed       = 2, 
    NoClipEnabled  = false,
    
    R = 0, G = 210, B = 255
}

local function GetCustomColor()
    return Color3.fromRGB(config.R, config.G, config.B)
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
--  CREATION DE L'INTERFACE INTERNE
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "SilentVoidHubV8"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = player:WaitForChild("PlayerGui")

local ESPContainer = frame({ Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, sg)

-- Rond du FOV Centré
local fovCircle = frame({
    Size = UDim2.new(0, config.FovRadius * 2, 0, config.FovRadius * 2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    Visible = false
}, sg)
corner(config.FovRadius * 2, fovCircle)
local fovStroke = stroke(C.CYAN, 1, fovCircle)

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

local openB = btn({
    Size = UDim2.new(0, 110, 0, 32),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = C.BG,
    BackgroundTransparency = 0.3,
    Text = "SV Hub 👁",
    Visible = false
}, sg)
corner(6, openB)
stroke(C.CYAN, 1, openB)

local titleBar = frame({ Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.25 }, win)
corner(10, titleBar)
frame({ Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.25 }, titleBar)

lbl({ Text = " ✕  SilentVoid Hub & Multi Games", Size = UDim2.new(0, 350, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextColor3 = C.WHITE, TextSize = 14, Font = Enum.Font.GothamBold }, titleBar)

local closeB = btn({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -38, 0, 6), BackgroundColor3 = Color3.fromRGB(30, 15, 15), Text = "✕", TextColor3 = C.RED }, titleBar)
corner(6, closeB)

local minimizeB = btn({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -74, 0, 6), BackgroundColor3 = Color3.fromRGB(20, 20, 25), Text = "—", TextColor3 = C.WHITE }, titleBar)
corner(6, minimizeB)

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
    
    local indicator = frame({ Size = UDim2.new(0, 4, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = C.CYAN, BackgroundTransparency = 1 }, nb)
    corner(2, indicator)

    lbl({ Text = icon, Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.GRAY }, nb)
    lbl({ Text = "| " .. name, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 38, 0, 0), TextColor3 = C.GRAY }, nb)
    
    local p = frame({ Size = UDim2.new(1, -160, 1, -42), Position = UDim2.new(0, 160, 0, 42), BackgroundTransparency = 1, Visible = false }, win)
    
    pages[id] = p
    navBtns[id] = {btn = nb, ind = indicator}
    return p
end

local pHome    = addTab("home", "⌂", "Accueil")
local pVisuals = addTab("visuals", "👁", "Visuals / ESP")
local pCombat  = addTab("combat", "⚔", "Combat / Aimbot")
local pFun     = addTab("fun", "🚀", "Options Fun")

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

lbl({ Text = "SilentVoid Hub - Version 8 (Mobile)", Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 14, 0, 15), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.CYAN }, pHome)
lbl({ Text = "Correctifs V8 :\n- Aimbot silencieux par Raycast (Plus de caméra forcée qui tremble).\n- ESP global ultra stable recalibré pour tout exécuteur mobile.", Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 14, 0, 50), TextColor3 = C.GRAY }, pHome)

local scrVis = Instance.new("ScrollingFrame")
scrVis.Size = UDim2.new(1, 0, 1, -10); scrVis.BackgroundTransparency = 1; scrVis.BorderSizePixel = 0; scrVis.CanvasSize = UDim2.new(0, 0, 0, 300); scrVis.Parent = pVisuals
makeRow(scrVis, 10, "Activer l'ESP Global", "Trace l'intégralité des joueurs présents", config.EspEnabled, function(v) config.EspEnabled = v end)
makeRow(scrVis, 65, "Afficher les Boîtes (Boxes)", "Délimitation carrée sur la cible", config.BoxVisible, function(v) config.BoxVisible = v end)
makeRow(scrVis, 120, "Afficher les Lignes (Tracers)", "Lignes de visée directes", config.TracerVisible, function(v) config.TracerVisible = v end)
makeRow(scrVis, 175, "Afficher le Pseudo", "Affiche l'identité", config.ShowName, function(v) config.ShowName = v end)
makeRow(scrVis, 230, "Afficher la Distance", "Affiche l'éloignement en Studs", config.ShowDistance, function(v) config.ShowDistance = v end)

makeRow(pCombat, 15, "Activer l'Aimbot Raycast", "Simule l'impact de tir directement sur la cible", config.AimbotEnabled, function(v) config.AimbotEnabled = v end)
makeRow(pCombat, 70, "Afficher le Rond FOV", "Périmètre de détection de l'aimbot", config.FovEnabled, function(v) config.FovEnabled = v fovCircle.Visible = v end)

makeRow(pFun, 15, "Activer le Fly Mobile Stable", "Aucune chute. SAUT pour monter, Joystick pour bouger", config.FlyEnabled, function(v) 
    config.FlyEnabled = v 
    if not v then Workspace.Gravity = originalGravity end
end)
makeRow(pFun, 75, "Activer le NoClip Stable", "Franchit les structures en gardant l'ancrage au sol", config.NoClipEnabled, function(v) config.NoClipEnabled = v end)

-- ══════════════════════════════════════════════
--  MOTEURS PHYSIQUES ET LOGIQUES CORRIGÉS
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
    
    local tracer = frame({ BackgroundColor3 = GetCustomColor(), Visible = false }, ESPContainer)
    elements.Tracer = tracer
    
    local infoTag = lbl({ Size = UDim2.new(0, 200, 0, 30), Text = "", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Visible = false }, ESPContainer)
    infoTag.Font = Enum.Font.GothamBold; stroke(Color3.fromRGB(0,0,0), 1.5, infoTag)
    elements.InfoTag = infoTag
    
    RenderCache[p] = elements
end

-- Recherche du joueur le plus proche présent à l'intérieur du cercle
local function GetClosestPlayerInFOV()
    local closest, maxScreenDist = nil, config.FovRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and IsPlayerValid(p) and IsPlayerValid(player) then
            local root = p.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
            
            if onScreen then
                local playerCoord = Vector2.new(screenPos.X, screenPos.Y)
                local distFromCenter = (playerCoord - screenCenter).Magnitude
                
                if distFromCenter < maxScreenDist then
                    maxScreenDist = distFromCenter
                    closest = p
                end
            end
        end
    end
    return closest
end

-- Hook d'activation pour l'Aimbot Silencieux Mobile
local metatable = getrawmetatable(game)
local oldNamecall = metatable.__namecall
setreadonly(metatable, false)

metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if config.AimbotEnabled and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") then
        local target = GetClosestPlayerInFOV()
        if target and IsPlayerValid(target) then
            -- Redirige l'impact physique de l'outil vers le torse de la cible
            local targetPart = target.Character.HumanoidRootPart
            if args[1] and typeof(args[1]) == "Ray" then
                args[1] = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 999)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(metatable, true)

-- Traitement Rendu et ESP synchrone
RunService.RenderStepped:Connect(function()
    local customColor = GetCustomColor()
    fovStroke.Color = customColor
    
    -- MOTEUR ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not RenderCache[p] then CreateVisualElements(p) end
        local visual = RenderCache[p]
        
        if not config.EspEnabled or not IsPlayerValid(p) or not IsPlayerValid(player) then
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
            
            if config.BoxVisible then
                visual.Box.Size = UDim2.new(0, w, 0, h)
                visual.Box.Position = UDim2.new(0, screenPos.X - (w / 2), 0, screenPos.Y - (h / 2))
                visual.Box:FindFirstChildOfClass("UIStroke").Color = customColor
                visual.Box.Visible = true
            else visual.Box.Visible = false end
            
            if config.TracerVisible then
                local startX, startY = Camera.ViewportSize.X / 2, 0
                local endX, endY = screenPos.X, screenPos.Y - (h / 2)
                local dx, dy = endX - startX, endY - startY
                local length = math.sqrt(dx^2 + dy^2)
                
                visual.Tracer.Size = UDim2.new(0, length, 0, 2)
                visual.Tracer.Position = UDim2.new(0, startX + dx / 2, 0, startY + dy / 2)
                visual.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                visual.Tracer.Rotation = math.deg(math.atan2(dy, dx))
                visual.Tracer.BackgroundColor3 = customColor
                visual.Tracer.Visible = true
            else visual.Tracer.Visible = false end
            
            if config.ShowName or config.ShowDistance then
                local txt = ""
                if config.ShowName then txt = txt .. p.Name end
                if config.ShowDistance then txt = (txt ~= "" and txt .. " | " or "") .. math.floor(distance) .. "s" end
                visual.InfoTag.Text = txt
                visual.InfoTag.TextColor3 = customColor
                visual.InfoTag.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 25)
                visual.InfoTag.Visible = true
            else visual.InfoTag.Visible = false end
        else
            visual.Box.Visible = false; visual.Tracer.Visible = false; visual.InfoTag.Visible = false
        end
    end
    
    -- SIMULATION DE CLIC AUTOMATIQUE (Pas de tremblement d'écran)
    if config.AimbotEnabled then
        local target = GetClosestPlayerInFOV()
        if target and IsPlayerValid(target) and IsPlayerValid(player) then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then 
                tool:Activate() 
            end
        end
    end
end)

-- Fly CFrame Mobile Synchrone
RunService.Heartbeat:Connect(function()
    if not IsPlayerValid(player) then return end
    local char = player.Character
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if config.FlyEnabled then
        Workspace.Gravity = 0
        hum.PlatformStand = true
        
        local moveDir = hum.MoveDirection
        local newVelocity = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then newVelocity = moveDir * config.FlySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then newVelocity = newVelocity + Vector3.new(0, config.FlySpeed, 0) end
        
        root.CFrame = root.CFrame + newVelocity
        root.Velocity = Vector3.new(0, 0, 0)
    else
        if hum.PlatformStand then 
            hum.PlatformStand = false 
            Workspace.Gravity = originalGravity
        end
    end
end)

-- NoClip Physique Forcé
RunService.Stepped:Connect(function()
    if config.NoClipEnabled and IsPlayerValid(player) then
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                if part.Name ~= "LeftFoot" and part.Name ~= "RightFoot" and part.Name ~= "LowerTorso" then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════
--  GESTION DE L'INTERFACE GRAPHIQUE
-- ══════════════════════════════════════════════
local function showPage(id)
    for pid, p in pairs(pages) do p.Visible = (pid == id) end
    for nid, data in pairs(navBtns) do
        local active = (nid == id)
        data.btn.BackgroundTransparency = active and 0.85 or 1
        data.btn:FindFirstChildOfClass("TextLabel").TextColor3 = active and C.CYAN or C.GRAY
        data.ind.BackgroundTransparency = active and 0 or 1
    end
end

showPage("home")

for id, data in pairs(navBtns) do
    data.btn.MouseButton1Click:Connect(function() showPage(id) end)
end

minimizeB.MouseButton1Click:Connect(function()
    win.Visible = false
    openB.Visible = true
end)

openB.MouseButton1Click:Connect(function()
    win.Visible = true
    openB.Visible = false
end)

closeB.MouseButton1Click:Connect(function()
    config.EspEnabled = false
    config.AimbotEnabled = false
    config.FlyEnabled = false
    config.NoClipEnabled = false
    Workspace.Gravity = originalGravity
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
    for _, p in ipairs(Players:GetPlayers()) do
        if RenderCache[p] then
            if RenderCache[p].Box then RenderCache[p].Box:Destroy() end
            if RenderCache[p].Tracer then RenderCache[p].Tracer:Destroy() end
            if RenderCache[p].InfoTag then RenderCache[p].InfoTag:Destroy() end
        end
    end
    sg:Destroy()
end)

Players.PlayerRemoving:Connect(function(p)
    if RenderCache[p] then RenderCache[p] = nil end
end)
