-- ╔══════════════════════════════════════════════╗
-- ║          SILENTVOID - LOCK TOTAL V10         ║
-- ║       AIMBOT HARD-LOCK & ESP ENNEMI          ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local Workspace     = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Nettoyage des anciennes versions
if player:WaitForChild("PlayerGui"):FindFirstChild("SilentVoidCombatV10") then
    player.PlayerGui.SilentVoidCombatV10:Destroy()
end

-- ══════════════════════════════════════════════
--  CONFIGURATION STRICTE
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(15, 15, 18),      
    PANEL       = Color3.fromRGB(22, 22, 26),      
    CYAN        = Color3.fromRGB(0, 210, 255),     
    RED         = Color3.fromRGB(255, 50, 50),      
    WHITE       = Color3.fromRGB(255, 255, 255),
    BORDER      = Color3.fromRGB(45, 45, 50)
}

local config = {
    AimbotEnabled  = false,
    FovEnabled     = false,
    EspEnabled     = false,
    FovRadius      = 150
}

local RenderCache = {}

-- ══════════════════════════════════════════════
--  INTERFACE VISUELLE MOBILE
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "SilentVoidCombatV10"
sg.ResetOnSpawn = false
sg.Parent = player:WaitForChild("PlayerGui")

-- Conteneur ESP
local ESPContainer = Instance.new("Frame")
ESPContainer.Size = UDim2.new(1, 0, 1, 0)
ESPContainer.BackgroundTransparency = 1
ESPContainer.Parent = sg

-- Rond du FOV
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, config.FovRadius * 2, 0, config.FovRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = sg

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(0, config.FovRadius * 2)
circleCorner.Parent = fovCircle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = C.CYAN
circleStroke.Thickness = 1
circleStroke.Parent = fovCircle

-- Fenêtre de Contrôle
local win = Instance.new("Frame")
win.Size = UDim2.new(0, 260, 0, 200)
win.Position = UDim2.new(0.5, -130, 0.4, -100)
win.BackgroundColor3 = C.BG
win.Active = true
win.Draggable = true
win.Parent = sg

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 8)
winCorner.Parent = win

local winStroke = Instance.new("UIStroke")
winStroke.Color = C.BORDER
winStroke.Thickness = 1.5
winStroke.Parent = win

-- Bouton Menu Flottant
local toggleB = Instance.new("TextButton")
toggleB.Size = UDim2.new(0, 90, 0, 32)
toggleB.Position = UDim2.new(0, 10, 0, 10)
toggleB.BackgroundColor3 = C.BG
toggleB.Text = "SV COMBAT ✕"
toggleB.Font = Enum.Font.GothamBold
toggleB.TextColor3 = C.CYAN
toggleB.TextSize = 11
toggleB.Parent = sg

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleB

toggleB.MouseButton1Click:Connect(function()
    win.Visible = not win.Visible
end)

-- Titre Menu
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "  SILENTVOID LOCK V10"
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextColor3 = C.WHITE
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = win

-- Fonction de création des boutons ON/OFF
local yPos = 40
local function createToggle(text, configKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = C.PANEL
    btn.Font = Enum.Font.GothamBold
    btn.Text = text .. " : OFF"
    btn.TextColor3 = C.WHITE
    btn.TextSize = 11
    btn.Parent = win
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        config[configKey] = not config[configKey]
        if config[configKey] then
            btn.Text = text .. " : ON"
            btn.TextColor3 = C.CYAN
        else
            btn.Text = text .. " : OFF"
            btn.TextColor3 = C.WHITE
        end
        callback(config[configKey])
    end)
    yPos = yPos + 40
end

createToggle("HARD-LOCK AIMBOT", "AimbotEnabled", function() end)
createToggle("AFFICHER LE FOV", "FovEnabled", function(v) fovCircle.Visible = v end)
createToggle("ACTIVER ESP ENNEMI", "EspEnabled", function() end)

-- ══════════════════════════════════════════════
--  LOGIQUE LOGICIELLE D'ATTRACTION STRICTE
-- ══════════════════════════════════════════════
local function IsValidEnemy(p)
    return p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function GetClosestEnemy()
    local closest, maxDist = nil, config.FovRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if IsValidEnemy(p) then
            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

local function SetupESP(p)
    if RenderCache[p] then return end
    local elements = {}
    
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.Visible = false
    box.Parent = ESPContainer
    
    local s = Instance.new("UIStroke")
    s.Color = C.RED
    s.Thickness = 1.5
    s.Parent = box
    
    elements.Box = box
    RenderCache[p] = elements
end

-- Boucle d'exécution prioritaire par frame
RunService.RenderStepped:Connect(function()
    -- SÉCURITÉ DE LOCK AIMBOT HARDWARE
    if config.AimbotEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local target = GetClosestEnemy()
        if target and IsValidEnemy(target) then
            local targetHead = target.Character.Head.Position
            
            -- FORCE LA CAMÉRA SANS TRANSITION (LOCK TOTAL)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead)
            
            -- FORCE LE CORPS DU JOUEUR A FAIRE FACE A L'ENNEMI
            local root = player.Character.HumanoidRootPart
            root.CFrame = CFrame.new(root.Position, Vector3.new(targetHead.X, root.Position.Y, targetHead.Z))
            
            -- Déclenchement automatique de l'arme en main
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
    
    -- MISE A JOUR DE L'ESP ENNEMI
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not RenderCache[p] then SetupESP(p) end
        local cache = RenderCache[p]
        
        if not config.EspEnabled or not IsValidEnemy(p) or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            cache.Box.Visible = false
            continue
        end
        
        local root = p.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
        
        if onScreen then
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            local scale = (5 * Camera.ViewportSize.Y) / (2 * dist * math.tan(math.rad(Camera.FieldOfView / 2)))
            local w, h = scale * 0.85, scale * 1.15
            
            cache.Box.Size = UDim2.new(0, w, 0, h)
            cache.Box.Position = UDim2.new(0, screenPos.X - (w / 2), 0, screenPos.Y - (h / 2))
            cache.Box.Visible = true
        else
            cache.Box.Visible = false
        end
    end
end)

-- Nettoyage lors des déconnexions
Players.PlayerRemoving:Connect(function(p)
    if RenderCache[p] then
        if RenderCache[p].Box then RenderCache[p].Box:Destroy() end
        RenderCache[p] = nil
    end
end)

