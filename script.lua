-- ╔══════════════════════════════════════════════╗
-- ║         SILENTVOID - PACK COMBAT PUR         ║
-- ║        ESP GLOBAL & AIMBOT CAMERA V9         ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Nettoyage des anciennes versions pour repartir sur du propre
if player:WaitForChild("PlayerGui"):FindFirstChild("SilentVoidCombatV9") then
    player.PlayerGui.SilentVoidCombatV9:Destroy()
end

-- ══════════════════════════════════════════════
--  CONFIGURATION SIMPLIFIÉE
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(12, 12, 14),      
    PANEL       = Color3.fromRGB(18, 18, 22),      
    ROW         = Color3.fromRGB(24, 24, 28),      
    WHITE       = Color3.fromRGB(255, 255, 255),   
    GRAY        = Color3.fromRGB(140, 140, 150),   
    CYAN        = Color3.fromRGB(0, 210, 255),     
    RED         = Color3.fromRGB(255, 60, 60),      
    BORDER      = Color3.fromRGB(35, 35, 40),      
}

local config = {
    EspEnabled     = false,
    BoxVisible     = false,
    ShowName       = false,
    
    AimbotEnabled  = false,
    FovEnabled     = false,
    FovRadius      = 130, -- Taille du rond de visée
}

local RenderCache = {}

-- ══════════════════════════════════════════════
--  FONCTIONS DU MENU DE CONTROLE
-- ══════════════════════════════════════════════
local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end

local function stroke(col, thick, p)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = thick or 1
    s.Parent = p
end

local function lbl(text, size, parent, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.Text = text
    l.TextSize = size
    l.TextColor3 = color or C.WHITE
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function frame(size, pos, bg, parent)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = bg
    f.Parent = parent
    return f
end

-- Base GUI
local sg = Instance.new("ScreenGui")
sg.Name = "SilentVoidCombatV9"
sg.ResetOnSpawn = false
sg.Parent = player:WaitForChild("PlayerGui")

local ESPContainer = frame(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.new(0,0,0), sg)
ESPContainer.BackgroundTransparency = 1

-- Dessin du FOV
local fovCircle = frame(UDim2.new(0, config.FovRadius * 2, 0, config.FovRadius * 2), UDim2.new(0.5, 0, 0.5, 0), Color3.new(0,0,0), sg)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
corner(config.FovRadius * 2, fovCircle)
stroke(C.CYAN, 1, fovCircle)

-- Fenêtre Principale
local win = frame(UDim2.new(0, 340, 0, 280), UDim2.new(0.5, -170, 0.5, -140), C.BG, sg)
win.BackgroundTransparency = 0.15
win.Active = true
win.Draggable = true
corner(8, win)
stroke(C.BORDER, 1.5, win)

-- Bouton Ouvrir / Fermer discret pour mobile
local toggleB = Instance.new("TextButton")
toggleB.Size = UDim2.new(0, 80, 0, 30)
toggleB.Position = UDim2.new(0, 10, 0, 10)
toggleB.BackgroundColor3 = C.BG
toggleB.Text = "Menu 👁"
toggleB.Font = Enum.Font.GothamBold
toggleB.TextColor3 = C.CYAN
toggleB.TextSize = 12
toggleB.Parent = sg
corner(6, toggleB)
stroke(C.BORDER, 1, toggleB)

toggleB.MouseButton1Click:Connect(function()
    win.Visible = not win.Visible
end)

-- Titre
local title = lbl("  SilentVoid Combat Mod (V9)", 14, win, C.CYAN)
title.Size = UDim2.new(1, 0, 0, 35)
title.Font = Enum.Font.GothamBold

-- Création des lignes d'options
local yPos = 45
local function addToggle(text, sub, defaultConfigKey, callback)
    local row = frame(UDim2.new(1, -20, 0, 42), UDim2.new(0, 10, 0, yPos), C.ROW, win)
    corner(6, row); stroke(C.BORDER, 1, row)
    
    local t = lbl(text, 12, row)
    t.Position = UDim2.new(0, 10, 0, 4)
    local s = lbl(sub, 10, row, C.GRAY)
    s.Position = UDim2.new(0, 10, 0, 20)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = config[defaultConfigKey] and C.CYAN or C.PANEL
    btn.Text = ""
    btn.Parent = row
    corner(10, btn)
    
    btn.MouseButton1Click:Connect(function()
        config[defaultConfigKey] = not config[defaultConfigKey]
        btn.BackgroundColor3 = config[defaultConfigKey] and C.CYAN or C.PANEL
        callback(config[defaultConfigKey])
    end)
    yPos = yPos + 48
end

addToggle("Activer l'Aimbot", "Verrouille les joueurs proches", "AimbotEnabled", function() end)
addToggle("Afficher le Cercle FOV", "Zone de détection à l'écran", "FovEnabled", function(v) fovCircle.Visible = v end)
addToggle("Activer l'ESP", "Affiche les cibles à travers les murs", "EspEnabled", function() end)
addToggle("Afficher les Boîtes ESP", "Met un cadre sur les joueurs", "BoxVisible", function() end)
addToggle("Afficher les Pseudos", "Affiche le nom au-dessus", "ShowName", function() end)

-- ══════════════════════════════════════════════
--  MOTEURS DE JEU (SANS LOGIQUE COMPLEXE)
-- ══════════════════════════════════════════════
local function IsValid(p)
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function GetClosestPlayerToCenter()
    local closest, maxDist = nil, config.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and IsValid(p) and IsValid(player) then
            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

-- Initialisation de l'ESP pour un joueur
local function SetupESP(p)
    if RenderCache[p] then return end
    local elements = {}
    
    local box = frame(UDim2.new(0,0,0,0), UDim2.new(0,0,0,0), Color3.new(0,0,0), ESPContainer)
    box.BackgroundTransparency = 1
    box.Visible = false
    stroke(C.RED, 1.5, box)
    elements.Box = box
    
    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 10
    name.TextColor3 = C.WHITE
    name.Visible = false
    name.Parent = ESPContainer
    stroke(Color3.new(0,0,0), 1, name)
    elements.Name = name
    
    RenderCache[p] = elements
end

-- Boucle principale de rendu léger
RunService.RenderStepped:Connect(function()
    -- GESTION AIMBOT CAMERA
    if config.AimbotEnabled and IsValid(player) then
        local target = GetClosestPlayerToCenter()
        if target and IsValid(target) then
            -- Calcule l'orientation vers la tête du joueur cible
            local targetPos = target.Character.Head.Position
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            
            -- Déplacement fluide de la caméra pour éviter les bugs de mouvements mobiles
            TweenService:Create(Camera, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {CFrame = targetCFrame}):Play()
            
            -- Auto-attaque si un outil est en main
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
    
    -- GESTION ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not RenderCache[p] then SetupESP(p) end
        local cache = RenderCache[p]
        
        if not config.EspEnabled or not IsValid(p) or not IsValid(player) then
            cache.Box.Visible = false
            cache.Name.Visible = false
            continue
        end
        
        local root = p.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
        
        if onScreen then
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            local scale = (5 * Camera.ViewportSize.Y) / (2 * dist * math.tan(math.rad(Camera.FieldOfView / 2)))
            local w, h = scale * 0.85, scale * 1.15
            
            if config.BoxVisible then
                cache.Box.Size = UDim2.new(0, w, 0, h)
                cache.Box.Position = UDim2.new(0, screenPos.X - (w / 2), 0, screenPos.Y - (h / 2))
                cache.Box.Visible = true
            else cache.Box.Visible = false end
            
            if config.ShowName then
                cache.Name.Text = p.Name .. " [" .. math.floor(dist) .. "m]"
                cache.Name.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 18)
                cache.Name.Size = UDim2.new(0, 200, 0, 15)
                cache.Name.Visible = true
            else cache.Name.Visible = false end
        else
            cache.Box.Visible = false
            cache.Name.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if RenderCache[p] then
        if RenderCache[p].Box then RenderCache[p].Box:Destroy() end
        if RenderCache[p].Name then RenderCache[p].Name:Destroy() end
        RenderCache[p] = nil
    end
end)
