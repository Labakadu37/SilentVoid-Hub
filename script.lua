--[[
    SilentVoid Hub - Édition Phantom avec Assistance Visuelle Avancée
    Interface transparente avec onglets en haut.
    Système de cadres 2D (Boxes), Distances et Lignes de suivi (Tracers) 100% Légitime.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 🎨 DESIGN & THÈME PHANTOM
--------------------------------------------------------------------------------
local Theme = {
    Background = Color3.fromRGB(15, 12, 22),
    BackgroundTransparency = 0.35,
    Topbar = Color3.fromRGB(10, 8, 15),
    Accent = Color3.fromRGB(150, 50, 255), -- Violet Néon
    Text = Color3.fromRGB(245, 240, 255),
    TextMuted = Color3.fromRGB(140, 130, 160),
    ButtonBg = Color3.fromRGB(30, 25, 40),
    ButtonHover = Color3.fromRGB(55, 35, 80),
    Font = Enum.Font.GothamBold
}

local HubState = {
    Visible = true,
    CurrentTab = "Esp Visual",
    InfiniteJump = false,
    VisualsEnabled = false -- Activé via le bouton de l'interface
}

--------------------------------------------------------------------------------
-- 🛠️ STRUCTURE DE L'INTERFACE (PANEL CENTRAL)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentVoidPhantom"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Dossier de stockage pour les éléments visuels de repérage
local VisualsFolder = Instance.new("Folder")
VisualsFolder.Name = "SV_Visuals"
VisualsFolder.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = Theme.BackgroundTransparency
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Accent
UIStroke.Thickness = 1.2
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

--------------------------------------------------------------------------------
-- 🧭 BARRE SUPÉRIEURE & CATÉGORIES (TOP NAVIGATION)
--------------------------------------------------------------------------------
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 85)
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.BackgroundTransparency = 0.2
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.5, 0, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Font = Theme.Font
Title.Text = "SILENTVOID // ASSISTANCE ACCESSIBILITÉ"
Title.TextColor3 = Theme.Accent
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -20, 0, 35)
TabsContainer.Position = UDim2.new(0, 10, 0, 45)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = Topbar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Parent = TabsContainer
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 8)

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Position = UDim2.new(0, 15, 0, 100)
ContentContainer.Size = UDim2.new(1, -30, 1, -115)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

--------------------------------------------------------------------------------
-- 🔄 SYSTÈME DE GLISSEMENT (DRAG)
--------------------------------------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--------------------------------------------------------------------------------
-- 📂 GESTION DES CATÉGORIES
--------------------------------------------------------------------------------
local Pages = {}
local TabButtons = {}

local function CreateCategory(name, order)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Tab"
    Button.Size = UDim2.new(0, 140, 1, 0)
    Button.BackgroundColor3 = Theme.ButtonBg
    Button.BackgroundTransparency = 0.5
    Button.Font = Theme.Font
    Button.Text = name
    Button.TextColor3 = Theme.TextMuted
    Button.TextSize = 13
    Button.LayoutOrder = order
    Button.Parent = TabsContainer
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = Page
    TabButtons[name] = Button

    Button.MouseButton1Click:Connect(function()
        for _, v in pairs(Pages) do v.Visible = false end
        for _, v in pairs(TabButtons) do 
            v.TextColor3 = Theme.TextMuted 
            v.BackgroundTransparency = 0.5
            v.BackgroundColor3 = Theme.ButtonBg
        end
        
        Page.Visible = true
        Button.TextColor3 = Theme.Text
        Button.BackgroundTransparency = 0
        Button.BackgroundColor3 = Theme.ButtonHover
        HubState.CurrentTab = name
    end)
end

CreateCategory("Esp Visual", 1)
CreateCategory("Fun Outils", 2)
CreateCategory("Paramètres", 3)

TabButtons["Esp Visual"].TextColor3 = Theme.Text
TabButtons["Esp Visual"].BackgroundTransparency = 0
TabButtons["Esp Visual"].BackgroundColor3 = Theme.ButtonHover
Pages["Esp Visual"].Visible = true

--------------------------------------------------------------------------------
-- 🎨 CONSTRUCTEURS DE COMPOSANTS CONTRÔLES
--------------------------------------------------------------------------------
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.98, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 30)
    ToggleFrame.BackgroundTransparency = 0.4
    ToggleFrame.Parent = parent

    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Theme.Font
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 45, 0, 22)
    Switch.Position = UDim2.new(1, -55, 0.5, -11)
    Switch.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50, 45, 65)
    Switch.Text = ""
    Switch.Parent = ToggleFrame
    
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)

    local State = default
    Switch.MouseButton1Click:Connect(function()
        State = not State
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State and Theme.Accent or Color3.fromRGB(50, 45, 65)}):Play()
        callback(State)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.98, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 30)
    SliderFrame.BackgroundTransparency = 0.4
    SliderFrame.Parent = parent

    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Font = Theme.Font
    Label.Text = text .. " : " .. default
    Label.TextColor3 = Theme.Text
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local SlideBar = Instance.new("Frame")
    SlideBar.Size = UDim2.new(1, -20, 0, 5)
    SlideBar.Position = UDim2.new(0, 10, 0, 34)
    SlideBar.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
    SlideBar.BorderSizePixel = 0
    SlideBar.Parent = SliderFrame

    local SlideFill = Instance.new("Frame")
    SlideFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SlideFill.BackgroundColor3 = Theme.Accent
    SlideFill.BorderSizePixel = 0
    SlideFill.Parent = SlideBar

    local IsSliding = false

    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
        SlideFill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (pos * (max - min)))
        Label.Text = text .. " : " .. value
        callback(value)
    end

    SlideBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then IsSliding = true UpdateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if IsSliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then IsSliding = false end
    end)
end

--------------------------------------------------------------------------------
-- 👁️ LOGIQUE AVANCÉE : RECTANGLES, TEXTES ET TRACERS (100% LÉGITIME)
--------------------------------------------------------------------------------

local ActiveVisuals = {}

-- Fonction de nettoyage d'un joueur déconnecté ou mort
local function RemovePlayerVisual(player)
    if ActiveVisuals[player] then
        if ActiveVisuals[player].Box then ActiveVisuals[player].Box:Destroy() end
        if ActiveVisuals[player].Tracer then ActiveVisuals[player].Tracer:Destroy() end
        if ActiveVisuals[player].Label then ActiveVisuals[player].Label:Destroy() end
        ActiveVisuals[player] = nil
    end
end

-- Création des conteneurs visuels pour un joueur
local function CreateVisualElements(player)
    if ActiveVisuals[player] then RemovePlayerVisual(player) end

    -- 1. Le Rectangle (Box)
    local Box = Instance.new("Frame")
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 0
    Box.Visible = false
    Box.Parent = VisualsFolder

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Accent
    Stroke.Thickness = 1.5
    Stroke.Parent = Box

    -- 2. La ligne de suivi (Tracer)
    local Tracer = Instance.new("Frame")
    Tracer.BackgroundColor3 = Theme.Accent
    Tracer.BorderSizePixel = 0
    Tracer.AnchorPoint = Vector2.new(0.5, 1)
    Tracer.Visible = false
    Tracer.Parent = VisualsFolder

    -- 3. Le Texte (Pseudo + Distance)
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Theme.Font
    InfoLabel.TextSize = 12
    InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoLabel.TextStrokeTransparency = 0.5
    InfoLabel.Visible = false
    InfoLabel.Parent = VisualsFolder

    ActiveVisuals[player] = {
        Box = Box,
        Tracer = Tracer,
        Label = InfoLabel
    }
end

-- Boucle de rendu mathématique pour aligner la 2D de l'écran avec la 3D du jeu
RunService.RenderStepped:Connect(function()
    if not HubState.VisualsEnabled then
        VisualsFolder:ClearAllChildren()
        table.clear(ActiveVisuals)
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                if not ActiveVisuals[player] then
                    CreateVisualElements(player)
                end

                -- Calcul des coordonnées écran
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    -- Calcul de la taille de la boite selon la distance
                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local factor = (1 / distance) * 1000
                    local boxWidth = math.clamp(factor * 3.5, 20, 150)
                    local boxHeight = math.clamp(factor * 5, 30, 220)

                    local elements = ActiveVisuals[player]

                    -- Mise à jour du Rectangle (Box)
                    elements.Box.Visible = true
                    elements.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                    elements.Box.Position = UDim2.new(0, hrpPos.X - (boxWidth / 2), 0, hrpPos.Y - (boxHeight / 2))

                    -- Mise à jour des Textes (Pseudo @Nom [Distance])
                    elements.Label.Visible = true
                    elements.Label.Text = string.format("%s\n[%d Mètres]", player.DisplayName, math.floor(distance))
                    elements.Label.Position = UDim2.new(0, hrpPos.X, 0, hrpPos.Y - (boxHeight / 2) - 25)
                    
                    -- Alerte couleur de danger si trop proche
                    if distance < 30 then
                        elements.Label.TextColor3 = Color3.fromRGB(255, 50, 50) -- Rouge danger
                    else
                        elements.Label.TextColor3 = Theme.Text
                    end

                    -- Mise à jour du Tracer (Ligne partant du bas de l'écran vers le bas du rectangle)
                    elements.Tracer.Visible = true
                    local startX = Camera.ViewportSize.X / 2
                    local startY = Camera.ViewportSize.Y -- Bas de l'écran
                    local endX = hrpPos.X
                    local endY = hrpPos.Y + (boxHeight / 2) -- Bas du rectangle

                    local distance2D = math.sqrt((endX - startX)^2 + (endY - startY)^2)
                    local angle = math.atan2(endY - startY, endX - startX)

                    elements.Tracer.Size = UDim2.new(0, 1.5, 0, distance2D)
                    elements.Tracer.Position = UDim2.new(0, startX, 0, startY)
                    elements.Tracer.Rotation = math.deg(angle) - 90
                else
                    -- Si le joueur sort de l'écran, on cache ses éléments
                    if ActiveVisuals[player] then
                        ActiveVisuals[player].Box.Visible = false
                        ActiveVisuals[player].Tracer.Visible = false
                        ActiveVisuals[player].Label.Visible = false
                    end
                end
            else
                RemovePlayerVisual(player)
            end
        else
            RemovePlayerVisual(player)
        end
    end
end)

-- Activer / Désactiver l'assistance visuelle
CreateToggle(Pages["Esp Visual"], "Activer les Rectangles d'Aide Visuelle", false, function(state)
    HubState.VisualsEnabled = state
    if not state then
        VisualsFolder:ClearAllChildren()
        table.clear(ActiveVisuals)
    end
end)

--------------------------------------------------------------------------------
-- 🚀 CATEGORY 2 : FUN OUTILS (Contrôles du personnage)
--------------------------------------------------------------------------------

CreateSlider(Pages["Fun Outils"], "Vitesse de déplacement", 16, 150, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end)

CreateSlider(Pages["Fun Outils"], "Hauteur / Puissance de Saut", 50, 250, 50, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum.UseJumpPower then
            hum.JumpPower = value
        else
            hum.JumpHeight = value / 3
        end
    end
end)

CreateToggle(Pages["Fun Outils"], "Saut Infini (Anti-Chute)", false, function(state)
    HubState.InfiniteJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if HubState.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

--------------------------------------------------------------------------------
-- ⚙️ CATEGORY 3 : PARAMÈTRES
--------------------------------------------------------------------------------

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.98, 0, 0, 35)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 40)
CloseBtn.Font = Theme.Font
CloseBtn.Text = "Désactiver et Fermer proprement le Hub"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 13
CloseBtn.Parent = Pages["Paramètres"]

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    HubState.VisualsEnabled = false
    VisualsFolder:ClearAllChildren()
    ScreenGui:Destroy()
end)

--------------------------------------------------------------------------------
-- ⌨️ COMMANDE D'OUVERTURE / FERMETURE (Touche : Right-Shift)
--------------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        HubState.Visible = not HubState.Visible
        
        local targetSize = HubState.Visible and UDim2.new(0, 580, 0, 380) or UDim2.new(0, 580, 0, 0)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
    end
end)

print("SilentVoid Phantom (Aide Visuelle Avancée) chargé.")
