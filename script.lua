--[[
    Framework de Visuels Compétitif Complet (ESP)
    Style : Néon Cyberpunk
    Engine : Roblox (Client-Side)
    Optimisation : Maximale via Drawing API & Cache
--]]

--// Services Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

--// Variables Globales
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Configuration Centrale
local Config = {
    Enabled = true,
    TeamCheck = true,
    VisibilityCheck = true,
    DistanceCheck = true,
    MaxDistance = 600, -- Distance max en Studs
    
    Visuals = {
        BoxColor = Color3.fromRGB(0, 255, 140),       -- Vert Néon (Visible)
        HiddenColor = Color3.fromRGB(255, 30, 70),    -- Rouge Néon (Caché derrière un mur)
        TracerColor = Color3.fromRGB(0, 180, 255),    -- Bleu Néon
        Thickness = 1.5,
        Transparency = 0.9,
    }
}

--// Cache de rendu et paramètres physiques
local RenderCache = {}
local RaycastParamsInstance = RaycastParams.new()
RaycastParamsInstance.FilterType = Enum.RaycastFilterType.Exclude

--====================================================================
-- FONCTIONS UTILITAIRES & LOGIQUE INTERNE
--====================================================================

local function IsAlive(player)
    return player.Character 
        and player.Character:FindFirstChild("HumanoidRootPart") 
        and player.Character:FindFirstChild("Humanoid") 
        and player.Character.Humanoid.Health > 0
end

local function CheckVisibility(character, origin)
    local targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    if not targetPart then return false end
    
    RaycastParamsInstance.FilterDescendantsInstances = {LocalPlayer.Character, character}
    
    local direction = targetPart.Position - origin
    local raycastResult = Workspace:Raycast(origin, direction, RaycastParamsInstance)
    
    return raycastResult == nil -- Retourne vrai si aucun mur ne bloque le rayon
end

--====================================================================
-- STRUCTURE DE RENDU POUR LES JOUEURS (Drawing API)
--====================================================================
local PlayerVisual = {}
PlayerVisual.__index = PlayerVisual

function PlayerVisual.new(player)
    local self = setmetatable({}, PlayerVisual)
    self.Player = player
    
    -- Création de la boîte 2D
    self.Box = Drawing.new("Square")
    self.Box.Visible = false
    self.Box.Thickness = Config.Visuals.Thickness
    self.Box.Color = Config.Visuals.BoxColor
    self.Box.Filled = false
    self.Box.Transparency = Config.Visuals.Transparency
    
    -- Création de la ligne (Tracer)
    self.Tracer = Drawing.new("Line")
    self.Tracer.Visible = false
    self.Tracer.Thickness = Config.Visuals.Thickness
    self.Tracer.Color = Config.Visuals.TracerColor
    self.Tracer.Transparency = Config.Visuals.Transparency
    
    return self
end

function PlayerVisual:Update()
    -- Validation des conditions d'affichage globale et locale
    if not Config.Enabled or not IsAlive(self.Player) or not IsAlive(LocalPlayer) then
        self:Hide()
        return
    end
    
    -- Vérification d'équipe (Team Check)
    if Config.TeamCheck and self.Player.Team == LocalPlayer.Team then
        self:Hide()
        return
    end
    
    local character = self.Player.Character
    local rootPart = character.HumanoidRootPart
    local cameraPos = Camera.CFrame.Position
    
    -- Vérification de distance
    local distance = (rootPart.Position - cameraPos).Magnitude
    if Config.DistanceCheck and distance > Config.MaxDistance then
        self:Hide()
        return
    end
    
    -- Projection de l'espace 3D vers l'écran 2D
    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        self:Hide()
        return
    end
    
    -- Calcul précis de la taille de la boîte en fonction de la distance
    local extentsHeight = 5.2
    local scaleFactor = (extentsHeight * Camera.ViewportSize.Y) / (2 * distance * math.tan(math.rad(Camera.FieldOfView / 2)))
    local boxWidth = scaleFactor * 0.85
    local boxHeight = scaleFactor * 1.15
    
    local screenX = rootPos.X - (boxWidth / 2)
    local screenY = rootPos.Y - (boxHeight / 2)
    
    -- Calcul de la visibilité (Raycast)
    local isVisible = true
    if Config.VisibilityCheck then
        isVisible = CheckVisibility(character, cameraPos)
    end
    
    -- Mise à jour de la Boîte
    self.Box.Size = Vector2.new(boxWidth, boxHeight)
    self.Box.Position = Vector2.new(screenX, screenY)
    self.Box.Color = isVisible and Config.Visuals.BoxColor or Config.Visuals.HiddenColor
    self.Box.Visible = true
    
    -- Mise à jour du Tracer (Part du haut-milieu de l'écran vers le haut de la boîte)
    self.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
    self.Tracer.To = Vector2.new(rootPos.X, screenY)
    self.Tracer.Color = Config.Visuals.TracerColor
    self.Tracer.Visible = true
end

function PlayerVisual:Hide()
    self.Box.Visible = false
    self.Tracer.Visible = false
end

function PlayerVisual:Destroy()
    self:Hide()
    self.Box:Remove()
    self.Tracer:Remove()
end

--====================================================================
-- GESTIONNAIRE DE CONNEXIONS DES JOUEURS
--====================================================================
local function CharacterAdded(player)
    if player == LocalPlayer then return end
    if not RenderCache[player] then
        RenderCache[player] = PlayerVisual.new(player)
    end
end

local function PlayerAdded(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.3) -- Attente du chargement complet des membres du personnage
        CharacterAdded(player)
    end)
    if player.Character then
        CharacterAdded(player)
    end
end

local function PlayerRemoving(player)
    if RenderCache[player] then
        RenderCache[player]:Destroy()
        RenderCache[player] = nil
    end
end

-- Initialisation de la liste des joueurs existants
for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

-- Boucle de Rendu cadencée sur le rafraîchissement de l'écran (RenderStepped)
RunService.RenderStepped:Connect(function()
    for _, visualObject in pairs(RenderCache) do
        pcall(function()
            visualObject:Update()
        end)
    end
end)

--====================================================================
-- INTERFACE GRAPHIQUE (PANEL DE CONTROLE NEON MOVIZBLE)
--====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonVisualsMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Panel Principal
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Parent = ScreenGui
MainPanel.Size = UDim2.new(0, 220, 0, 270)
MainPanel.Position = UDim2.new(0.05, 0, 0.2, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainPanel.BorderSizePixel = 2
MainPanel.BorderColor3 = Color3.fromRGB(0, 255, 140)

-- Titre du Panel
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainPanel
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "  CYBER VISUALS v1.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Fonction pour créer des boutons On/Off stylisés
local function CreateToggleButton(name, text, positionY, defaultConfigValue, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = MainPanel
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.Position = UDim2.new(0, 10, 0, positionY)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Button.BorderSizePixel = 1
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 12
    
    local function UpdateStyle(state)
        if state then
            Button.Text = text .. " : ACTIF"
            Button.TextColor3 = Color3.fromRGB(0, 255, 140)
            Button.BorderColor3 = Color3.fromRGB(0, 255, 140)
        else
            Button.Text = text .. " : INACTIF"
            Button.TextColor3 = Color3.fromRGB(255, 50, 70)
            Button.BorderColor3 = Color3.fromRGB(255, 50, 70)
        end
    end
    
    local active = defaultConfigValue
    UpdateStyle(active)
    
    Button.MouseButton1Click:Connect(function()
        active = not active
        UpdateStyle(active)
        callback(active)
    end)
    
    return Button
end

-- Création des contrôles dans le Panel
CreateToggleButton("ToggleMain", "ESP SYSTEM", 55, Config.Enabled, function(state)
    Config.Enabled = state
    if not state then
        for _, visualObject in pairs(RenderCache) do visualObject:Hide() end
    end
end)

CreateToggleButton("ToggleTeam", "TEAM CHECK", 100, Config.TeamCheck, function(state)
    Config.TeamCheck = state
end)

CreateToggleButton("ToggleVis", "WALL CHECK", 145, Config.VisibilityCheck, function(state)
    Config.VisibilityCheck = state
end)

CreateToggleButton("ToggleDist", "DIST LIMIT", 190, Config.DistanceCheck, function(state)
    Config.DistanceCheck = state
end)

-- Note d'information en bas du menu
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Parent = MainPanel
FooterLabel.Size = UDim2.new(1, 0, 0, 20)
FooterLabel.Position = UDim2.new(0, 0, 1, -25)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Insert / Mettez le script dans votre exécuteur"
FooterLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
FooterLabel.TextSize = 9
FooterLabel.Font = Enum.Font.SourceSansItalic

--====================================================================
-- SYSTÈME DRAG-AND-DROP (Glisser-Déposer le Menu)
--====================================================================
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainPanel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("[Cyber Visuals] Chargé avec succès. Menu disponible à l'écran.")
