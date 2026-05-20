--[[
    SilentVoid Hub - Édition Phantom (Top Navigation)
    Interface moderne semi-transparente avec catégories horizontales.
    Utilisation exclusive des API légitimes de Roblox.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 🎨 DESIGN & THÈME PHANTOM
--------------------------------------------------------------------------------
local Theme = {
    Background = Color3.fromRGB(15, 12, 22),
    BackgroundTransparency = 0.35, -- Effet transparent "Phantom"
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
    CurrentTab = "Assistance Visual",
    SelectedPlayer = nil,
    VisualsEnabled = false,
    InfiniteJump = false,
    HighlightColor = Color3.fromRGB(150, 50, 255)
}

--------------------------------------------------------------------------------
-- 🛠️ STRUCTURE DE L'INTERFACE (PANEL CENTRAL)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentVoidPhantom"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame (Le Panel Violet Transparent)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 380)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = Theme.BackgroundTransparency
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Coins arrondis du panel
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Bordure Néon Violette très fine
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

-- Titre "SilentVoid" à gauche
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.3, 0, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Font = Theme.Font
Title.Text = "SILENTVOID // PHANTOM"
Title.TextColor3 = Theme.Accent
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

-- Conteneur horizontal pour les catégories (Onglets)
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

-- Zone de contenu sous la barre supérieure
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
-- 📂 CRÉATION LOGIQUE DES CATÉGORIES (TOP TABS)
--------------------------------------------------------------------------------
local Pages = {}
local TabButtons = {}

local function CreateCategory(name, order)
    -- Bouton de l'onglet en haut
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Tab"
    Button.Size = UDim2.new(0, 130, 1, 0)
    Button.BackgroundColor3 = Theme.ButtonBg
    Button.BackgroundTransparency = 0.5
    Button.Font = Theme.Font
    Button.Text = name
    Button.TextColor3 = Theme.TextMuted
    Button.TextSize = 13
    Button.LayoutOrder = order
    Button.Parent = TabsContainer
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button

    -- Page de contenu (Vertical Scrolling)
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

    -- Interaction des onglets
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

-- Création des 3 catégories majeures en haut
CreateCategory("Esp Visual", 1)
CreateCategory("Fun Outils", 2)
CreateCategory("Paramètres", 3)

-- Activer la première catégorie par défaut
TabButtons["Esp Visual"].TextColor3 = Theme.Text
TabButtons["Esp Visual"].BackgroundTransparency = 0
TabButtons["Esp Visual"].BackgroundColor3 = Theme.ButtonHover
Pages["Esp Visual"].Visible = true

--------------------------------------------------------------------------------
-- 🎨 CONSTRUCTEURS DE COMPOSANTS MODERNES
--------------------------------------------------------------------------------
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.98, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 30)
    ToggleFrame.BackgroundTransparency = 0.4
    ToggleFrame.Parent = parent

    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
    ToggleFrame.Parent = parent

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
    Switch.Parent = ToggleFrame

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
    SliderFrame.Parent = parent

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
-- 👁️ CATEGORY 1 : ESP VISUAL (Aide légitime au repérage)
--------------------------------------------------------------------------------

-- Système d'affichage d'aide avec l'instance Highlight officielle
local HighlightActive = false
local TrackingHighlights = {}

local function ApplyHighlightToPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        if not player.Character:FindFirstChild("SV_Highlight") then
            local hl = Instance.new("Highlight")
            hl.Name = "SV_Highlight"
            hl.FillColor = Theme.Accent
            hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0.2
            hl.Adornee = player.Character
            hl.Parent = player.Character
            TrackingHighlights[player] = hl
        end
    end
end

local function RemoveHighlights()
    for player, hl in pairs(TrackingHighlights) do
        if hl then hl:Destroy() end
    end
    table.clear(TrackingHighlights)
end

CreateToggle(Pages["Esp Visual"], "Mettre en surbrillance les joueurs (Highlight)", false, function(state)
    HighlightActive = state
    if state then
        for _, p in pairs(Players:GetPlayers()) do ApplyHighlightToPlayer(p) end
    else
        RemoveHighlights()
    end
end)

-- Actualisation dynamique des personnages pour le repérage visuel
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if HighlightActive then ApplyHighlightToPlayer(p) end
    end)
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

CreateToggle(Pages["Fun Outils"], "Saut Infini (Anti-Difficulté)", false, function(state)
    HubState.InfiniteJump = state
end)

-- Logique du saut infini déclenché proprement par l'utilisateur
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
CloseBtn.Text = "Désactiver et Fermer le Hub"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 13
CloseBtn.Parent = Pages["Paramètres"]

Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
CloseBtn.Parent = Pages["Paramètres"]

CloseBtn.MouseButton1Click:Connect(function()
    RemoveHighlights()
    ScreenGui:Destroy()
end)

--------------------------------------------------------------------------------
-- ⌨️ COMMANDE D'OUVERTURE / FERMETURE (Touche : Right-Shift)
--------------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        HubState.Visible = not HubState.Visible
        
        local targetSize = HubState.Visible and UDim2.new(0, 580, 0, 380) or UDim2.new(0, 580, 0, 0)
        local targetTransparency = HubState.Visible and Theme.BackgroundTransparency or 1
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
    end
end)

print("SilentVoid Phantom Edition chargé avec succès.")
