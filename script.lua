-- [[ ZENTYHUBV1 - NEON PURPLE EDITION ]]
-- Framework d'interface basé sur le style visuel fourni (Teintes Violettes & Anthracite)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

-- -------------------------------------------------------------
-- CONFIGURATION DE LA PALETTE DE COULEURS (Style Fidèle aux Images)
-- -------------------------------------------------------------
local THEME = {
    Background = Color3.fromRGB(22, 19, 32),       -- Fond très sombre avec une nuance violette
    BackgroundTrans = 0.2,                         -- Transparence "Ghost" fluide
    AccentPurple = Color3.fromRGB(138, 79, 227),   -- Violet Néon Principal (Bordures, Boutons)
    PurpleDark = Color3.fromRGB(48, 36, 74),       -- Violet Sombre pour les arrière-plans d'éléments
    TextMain = Color3.fromRGB(245, 242, 255),     -- Blanc pur / Lumineux
    TextDark = Color3.fromRGB(152, 140, 179),     -- Texte secondaire grisé/violet
    CardBg = Color3.fromRGB(31, 26, 46),           -- Fond des conteneurs internes
    CardTrans = 0.4
}

-- -------------------------------------------------------------
-- FONCTIONS COMPOSANTS UTILS
-- -------------------------------------------------------------
local function createRoundCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1.2
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function applyTween(instance, duration, properties)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(instance, info, properties):Play()
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- -------------------------------------------------------------
-- STRUCTURE DE L'INTERFACE PRINCIPALE
-- -------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyPurple_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- FENÊTRE PRINCIPALE
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 820, 0, 500)
MainFrame.Position = UDim2.new(0.5, -410, 0.5, -250)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BackgroundTransparency = THEME.BackgroundTrans
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

createRoundCorner(MainFrame, 14)
createStroke(MainFrame, THEME.AccentPurple, 1.5, 0.1)

-- BANNIÈRE IMAGE / DESIGN CENTRAL (Style Anime de l'image 2)
local CenterBanner = Instance.new("ImageLabel")
CenterBanner.Name = "CenterBanner"
CenterBanner.Size = UDim2.new(0, 320, 1, -40)
CenterBanner.Position = UDim2.new(1, -330, 0, 20)
CenterBanner.BackgroundTransparency = 1
CenterBanner.Image = "rbxassetid://135892797276701" -- ! REMPLACE PAR TON ASSET ID D'IMAGE ICI !
CenterBanner.ScaleType = Enum.ScaleType.Crop
CenterBanner.Parent = MainFrame
createRoundCorner(CenterBanner, 10)

-- Dégradé sombre sur l'image pour l'intégration
local ImageUIGradient = Instance.new("UIGradient")
ImageUIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, THEME.Background)
})
ImageUIGradient.Rotation = 90
ImageUIGradient.Parent = CenterBanner

-- BARRE LATÉRALE DE NAVIGATION (Gauche)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 60, 1, -20)
Sidebar.Position = UDim2.new(0, 10, 0, 10)
Sidebar.BackgroundColor3 = THEME.PurpleDark
Sidebar.BackgroundTransparency = 0.6
Sidebar.Parent = MainFrame
createRoundCorner(Sidebar, 10)

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 12)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 15)
SidebarPadding.Parent = Sidebar

-- CONTENEUR DES PAGES
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -420, 1, -30)
ContentArea.Position = UDim2.new(0, 80, 0, 15)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

makeDraggable(MainFrame, MainFrame)

-- -------------------------------------------------------------
-- SYSTÈME DE CONNEXION (IMAGE 1)
-- -------------------------------------------------------------
local LoginFrame = Instance.new("Frame")
LoginFrame.Name = "LoginFrame"
LoginFrame.Size = UDim2.new(0, 420, 0, 260)
LoginFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
LoginFrame.BackgroundColor3 = THEME.Background
LoginFrame.BackgroundTransparency = 0.1
LoginFrame.Parent = ScreenGui
createRoundCorner(LoginFrame, 12)
createStroke(LoginFrame, THEME.AccentPurple, 1.5, 0.2)

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, 0, 0, 60)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Text = "Zenty Hub - Authentification"
LoginTitle.Font = Enum.Font.GothamBold
LoginTitle.TextSize = 20
LoginTitle.TextColor3 = THEME.TextMain
LoginTitle.Parent = LoginFrame

local PassLabel = Instance.new("TextLabel")
PassLabel.Size = UDim2.new(1, -60, 0, 20)
PassLabel.Position = UDim2.new(0, 30, 0, 75)
PassLabel.BackgroundTransparency = 1
PassLabel.Text = "Mot de Passe"
PassLabel.Font = Enum.Font.GothamMedium
PassLabel.TextSize = 14
PassLabel.TextColor3 = THEME.TextDark
PassLabel.TextXAlignment = Enum.TextXAlignment.Left
PassLabel.Parent = LoginFrame

local PasswordInput = Instance.new("TextBox")
PasswordInput.Size = UDim2.new(1, -60, 0, 45)
PasswordInput.Position = UDim2.new(0, 30, 0, 100)
PasswordInput.BackgroundColor3 = THEME.CardBg
PasswordInput.Text = ""
PasswordInput.PlaceholderText = "Entrez le mot de passe..."
PasswordInput.Font = Enum.Font.Gotham
PasswordInput.TextSize = 14
PasswordInput.TextColor3 = THEME.TextMain
PasswordInput.PlaceholderColor3 = THEME.TextDark
PasswordInput.Parent = LoginFrame
createRoundCorner(PasswordInput, 8)
createStroke(PasswordInput, THEME.PurpleDark, 1.2, 0.3)

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(1, -60, 0, 45)
LoginBtn.Position = UDim2.new(0, 30, 0, 170)
LoginBtn.BackgroundColor3 = THEME.AccentPurple
LoginBtn.Text = "Accéder au Panel"
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.TextSize = 16
LoginBtn.TextColor3 = THEME.TextMain
LoginBtn.Parent = LoginFrame
createRoundCorner(LoginBtn, 8)

-- Interaction Login
LoginBtn.MouseButton1Click:Connect(function()
    if PasswordInput.Text == "ZentyV1" then
        applyTween(LoginFrame, 0.4, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
        task.wait(0.4)
        LoginFrame.Visible = false
        MainFrame.Visible = true
    else
        local err = createStroke(PasswordInput, Color3.fromRGB(240, 50, 50), 1.5, 0)
        task.wait(0.5)
        err:Destroy()
    end
end)

-- -------------------------------------------------------------
-- COMPOSANTS DE STYLE POUR LES ONGLETS (Boutons, Sliders)
-- -------------------------------------------------------------
local pages = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.AccentPurple
    page.Visible = false
    page.Parent = ContentArea
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page
    
    pages[name] = page
    return page
end

local function addIconButton(iconAssetId, pageName, order)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 1
    btn.Image = iconAssetId
    btn.ImageColor3 = THEME.TextDark
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    createRoundCorner(btn, 8)
    
    btn.MouseEnter:Connect(function()
        applyTween(btn, 0.2, {BackgroundTransparency = 0.8, ImageColor3 = THEME.AccentPurple})
    end)
    btn.MouseLeave:Connect(function()
        applyTween(btn, 0.2, {BackgroundTransparency = 1, ImageColor3 = THEME.TextDark})
    end)
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        if pages[pageName] then pages[pageName].Visible = true end
    end)
end

-- Exemple d'un Slider façon Image 2
local function createStyleSlider(parent, titleText, min, max)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = THEME.CardBg
    row.BackgroundTransparency = THEME.CardTrans
    row.Parent = parent
    createRoundCorner(row, 8)
    createStroke(row, THEME.PurpleDark, 1, 0.5)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0, 150, 1, 0)
    txt.Position = UDim2.new(0, 12)
    txt.Text = titleText
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 13
    txt.TextColor3 = THEME.TextMain
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = row
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -240, 0, 5)
    sliderBar.Position = UDim2.new(0, 160, 0.5, -2)
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
    sliderBar.Parent = row
    createRoundCorner(sliderBar, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.6, 0, 1, 0)
    fill.BackgroundColor3 = THEME.AccentPurple
    fill.Parent = sliderBar
    createRoundCorner(fill, 3)
end

-- -------------------------------------------------------------
-- INITIALISATION DES CONTENUS
-- -------------------------------------------------------------
local MainTab = createPage("Main")
local CombatTab = createPage("Combat")

-- Boutons avec Icônes (Sidebar ultra compacte)
addIconButton("rbxassetid://10747373151", "Main", 1)
addIconButton("rbxassetid://10747383471", "Combat", 2)

-- Injection des sliders d'exemples violet
createStyleSlider(MainTab, "Speed Modifier", 16, 250)
createStyleSlider(MainTab, "Jump Power", 50, 300)
createStyleSlider(CombatTab, "Aimbot FOV", 30, 300)

-- Ouvrir la première page par défaut
MainTab.Visible = true
