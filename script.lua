-- ================================================
--          ZENTY HUB - Professional Gaming Suite
--          Password: ZentyHubV1
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ================================================
-- VARIABLES GLOBALES
-- ================================================
local Settings = {
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Bones = false,
        Lines = false,
        TracerOrigin = "Bottom",
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        DistanceColor = Color3.fromRGB(255, 200, 0),
        HealthColor = Color3.fromRGB(0, 255, 0),
        TracerColor = Color3.fromRGB(255, 255, 255),
        MaxDistance = 500,
    },
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.15,
        TargetPart = "Head",
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        Key = Enum.UserInputType.MouseButton2,
    },
    Movement = {
        Speed = false,
        SpeedValue = 16,
        JumpPower = false,
        JumpValue = 50,
        Fly = false,
        FlySpeed = 50,
        NoClip = false,
        Spin = false,
        SpinSpeed = 5,
        InfiniteJump = false,
    },
    GameSpecific = {},
}

local ESPObjects = {}
local Flying = false
local Spinning = false
local NoClipping = false
local CurrentGame = ""
local PASSWORD = "ZentyHubV1"
local Unlocked = false

-- ================================================
-- DETECTION DU JEU
-- ================================================
local function DetectGame()
    local placeId = game.PlaceId
    local gameMap = {
        [142823291]  = "MurderMystery2",
        [155615604]  = "Arsenal",
        [606849621]  = "JailBreak",
        [3233893879] = "BrookHaven",
        [189707] = "NaturalDisaster",
        [6516141723] = "Doors",
        [292439477] = "PrisonLife",
        [13822889] = "WorkAtAPizzaPlace",
        [1962086868] = "Adopt_Me",
        [537413528] = "RoBeats",
        [2788229376] = "PetSimulator",
        [8737899140] = "Bloxburg",
        [286090429] = "BedWars",
        [3260590327] = "PhoneLover",
        [4106483924] = "BrokenBones",
        [921808248] = "MeepCity",
    }
    return gameMap[placeId] or "Unknown"
end

CurrentGame = DetectGame()

-- ================================================
-- UI PRINCIPALE
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = game:GetService("CoreGui")

-- ================================================
-- SCREEN PASSWORD
-- ================================================
local AuthFrame = Instance.new("Frame")
AuthFrame.Name = "AuthFrame"
AuthFrame.Size = UDim2.new(0, 450, 0, 280)
AuthFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
AuthFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
AuthFrame.BorderSizePixel = 0
AuthFrame.Parent = ScreenGui

local AuthCorner = Instance.new("UICorner")
AuthCorner.CornerRadius = UDim.new(0, 14)
AuthCorner.Parent = AuthFrame

-- Bordure violette
local AuthStroke = Instance.new("UIStroke")
AuthStroke.Color = Color3.fromRGB(140, 60, 255)
AuthStroke.Thickness = 2
AuthStroke.Parent = AuthFrame

-- Gradient bg
local AuthGrad = Instance.new("UIGradient")
AuthGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 20)),
})
AuthGrad.Rotation = 135
AuthGrad.Parent = AuthFrame

-- Logo image (anime girl violette)
local AuthLogo = Instance.new("ImageLabel")
AuthLogo.Size = UDim2.new(0, 80, 0, 80)
AuthLogo.Position = UDim2.new(0.5, -40, 0, 10)
AuthLogo.BackgroundTransparency = 1
AuthLogo.Image = "rbxassetid://13463187020" -- fallback anime image roblox
AuthLogo.ImageColor3 = Color3.fromRGB(160, 80, 255)
AuthLogo.Parent = AuthFrame

-- Titre
local AuthTitle = Instance.new("TextLabel")
AuthTitle.Size = UDim2.new(1, 0, 0, 35)
AuthTitle.Position = UDim2.new(0, 0, 0, 95)
AuthTitle.BackgroundTransparency = 1
AuthTitle.Text = "Zenty Hub - Authentification"
AuthTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthTitle.Font = Enum.Font.GothamBold
AuthTitle.TextSize = 18
AuthTitle.Parent = AuthFrame

-- Label mot de passe
local PassLabel = Instance.new("TextLabel")
PassLabel.Size = UDim2.new(1, -40, 0, 25)
PassLabel.Position = UDim2.new(0, 20, 0, 135)
PassLabel.BackgroundTransparency = 1
PassLabel.Text = "Mot de Passe"
PassLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PassLabel.Font = Enum.Font.Gotham
PassLabel.TextSize = 14
PassLabel.TextXAlignment = Enum.TextXAlignment.Left
PassLabel.Parent = AuthFrame

-- Input field
local PassBox = Instance.new("Frame")
PassBox.Size = UDim2.new(1, -40, 0, 44)
PassBox.Position = UDim2.new(0, 20, 0, 163)
PassBox.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
PassBox.BorderSizePixel = 0
PassBox.Parent = AuthFrame

local PassBoxCorner = Instance.new("UICorner")
PassBoxCorner.CornerRadius = UDim.new(0, 8)
PassBoxCorner.Parent = PassBox

local PassBoxStroke = Instance.new("UIStroke")
PassBoxStroke.Color = Color3.fromRGB(100, 40, 200)
PassBoxStroke.Thickness = 1.5
PassBoxStroke.Parent = PassBox

local PassInput = Instance.new("TextBox")
PassInput.Size = UDim2.new(1, -50, 1, 0)
PassInput.Position = UDim2.new(0, 12, 0, 0)
PassInput.BackgroundTransparency = 1
PassInput.Text = ""
PassInput.PlaceholderText = "Entrez le mot de passe..."
PassInput.PlaceholderColor3 = Color3.fromRGB(120, 100, 150)
PassInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PassInput.Font = Enum.Font.Gotham
PassInput.TextSize = 14
PassInput.TextXAlignment = Enum.TextXAlignment.Left
PassInput.ClearTextOnFocus = false
PassInput.Parent = PassBox

-- Lock icon
local LockIcon = Instance.new("TextLabel")
LockIcon.Size = UDim2.new(0, 35, 1, 0)
LockIcon.Position = UDim2.new(1, -40, 0, 0)
LockIcon.BackgroundTransparency = 1
LockIcon.Text = "🔒"
LockIcon.TextSize = 18
LockIcon.Parent = PassBox

-- Bouton accéder
local AccesBtn = Instance.new("TextButton")
AccesBtn.Size = UDim2.new(1, -40, 0, 44)
AccesBtn.Position = UDim2.new(0, 20, 0, 218)
AccesBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 255)
AccesBtn.BorderSizePixel = 0
AccesBtn.Text = "Accéder au Panel"
AccesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AccesBtn.Font = Enum.Font.GothamBold
AccesBtn.TextSize = 15
AccesBtn.Parent = AuthFrame

local AccesBtnCorner = Instance.new("UICorner")
AccesBtnCorner.CornerRadius = UDim.new(0, 10)
AccesBtnCorner.Parent = AccesBtn

-- Gradient bouton
local BtnGrad = Instance.new("UIGradient")
BtnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 60, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 30, 200)),
})
BtnGrad.Rotation = 90
BtnGrad.Parent = AccesBtn

-- Error label
local ErrLabel = Instance.new("TextLabel")
ErrLabel.Size = UDim2.new(1, 0, 0, 20)
ErrLabel.Position = UDim2.new(0, 0, 1, 5)
ErrLabel.BackgroundTransparency = 1
ErrLabel.Text = ""
ErrLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
ErrLabel.Font = Enum.Font.Gotham
ErrLabel.TextSize = 12
ErrLabel.Parent = AuthFrame

-- ================================================
-- PANEL PRINCIPAL (caché au départ)
-- ================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 780, 0, 520)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(120, 40, 220)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 10, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 4, 18)),
})
MainGrad.Rotation = 120
MainGrad.Parent = MainFrame

-- ================================================
-- TOPBAR
-- ================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 12, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0.5, 0)
TopFix.Position = UDim2.new(0, 0, 0.5, 0)
TopFix.BackgroundColor3 = Color3.fromRGB(20, 12, 40)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

-- Skull icon
local SkullIcon = Instance.new("TextLabel")
SkullIcon.Size = UDim2.new(0, 30, 1, 0)
SkullIcon.Position = UDim2.new(0, 10, 0, 0)
SkullIcon.BackgroundTransparency = 1
SkullIcon.Text = "💀"
SkullIcon.TextSize = 18
SkullIcon.Parent = TopBar

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(0, 300, 1, 0)
HubTitle.Position = UDim2.new(0, 40, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "Zenty Hub - Professional Gaming Suite"
HubTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 13
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Parent = TopBar

-- Key info
local KeyInfo = Instance.new("TextLabel")
KeyInfo.Size = UDim2.new(0, 200, 1, 0)
KeyInfo.Position = UDim2.new(1, -280, 0, 0)
KeyInfo.BackgroundTransparency = 1
KeyInfo.Text = "🔑 Key System"
KeyInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
KeyInfo.Font = Enum.Font.Gotham
KeyInfo.TextSize = 12
KeyInfo.Parent = TopBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.Parent = TopBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 6)
MinBtnCorner.Parent = MinBtn

-- ================================================
-- SIDEBAR (catégories)
-- ================================================
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 52, 1, -42)
SideBar.Position = UDim2.new(0, 0, 0, 42)
SideBar.BackgroundColor3 = Color3.fromRGB(16, 10, 30)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 4)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = SideBar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 8)
SidePad.Parent = SideBar

-- ================================================
-- TABS NAVIGATION (haut)
-- ================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -52, 0, 34)
TabBar.Position = UDim2.new(0, 52, 0, 42)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 12, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 2)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent = TabBar

local TabPad = Instance.new("UIPadding")
TabPad.PaddingLeft = UDim.new(0, 6)
TabPad.Parent = TabBar

-- ================================================
-- CONTENT AREA
-- ================================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -52, 1, -76)
ContentFrame.Position = UDim2.new(0, 52, 0, 76)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- ================================================
-- SEARCH BAR
-- ================================================
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(0, 200, 0, 28)
SearchFrame.Position = UDim2.new(0, 8, 0, 3)
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 18, 50)
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = TabBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchFrame

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -30, 1, 0)
SearchInput.Position = UDim2.new(0, 8, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "Search..."
SearchInput.PlaceholderColor3 = Color3.fromRGB(120, 100, 150)
SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchInput.Font = Enum.Font.Gotham
SearchInput.TextSize = 12
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.ClearTextOnFocus = false
SearchInput.Parent = SearchFrame

-- ================================================
-- HELPER FUNCTIONS
-- ================================================
local function CreateToggle(parent, text, yPos, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 32)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 36, 0, 20)
    toggleBg.Position = UDim2.new(1, -44, 0.5, -10)
    toggleBg.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 14, 0, 14)
    toggleDot.Position = UDim2.new(0, 3, 0.5, -7)
    toggleDot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleBg

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = toggleDot

    local toggled = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 50, 255)}):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 30, 80)}):Play()
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        callback(toggled)
    end)

    return row, function() return toggled end
end

local function CreateSlider(parent, text, yPos, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 52)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, -10, 0, 22)
    valLbl.Position = UDim2.new(0.7, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(160, 80, 255)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 34)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(130, 50, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
    dot.BorderSizePixel = 0
    dot.ZIndex = 5
    dot.Parent = sliderBg

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local dragging = false
    dot.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local bgPos = sliderBg.AbsolutePosition.X
            local bgSize = sliderBg.AbsoluteSize.X
            local rel = math.clamp((inp.Position.X - bgPos) / bgSize, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            dot.Position = UDim2.new(rel, -7, 0.5, -7)
            valLbl.Text = tostring(val)
            callback(val)
        end
    end)

    return frame
end

local function CreateSection(parent, title, yPos)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, -20, 0, 24)
    sec.Position = UDim2.new(0, 10, 0, yPos)
    sec.BackgroundTransparency = 1
    sec.Text = "── " .. title .. " ──"
    sec.TextColor3 = Color3.fromRGB(140, 60, 255)
    sec.Font = Enum.Font.GothamBold
    sec.TextSize = 12
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.Parent = parent
    return sec
end

-- ================================================
-- CREATE TAB
-- ================================================
local ActiveTab = nil
local TabPages = {}

local function CreateTab(tabBar, contentFrame, name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, -6)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Color3.fromRGB(30, 18, 55)
    btn.BorderSizePixel = 0
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(160, 140, 190)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = tabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 10)
    btnPad.PaddingRight = UDim.new(0, 10)
    btnPad.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 255)
    page.Visible = false
    page.Parent = contentFrame

    TabPages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        for _, b in pairs(tabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(30, 18, 55)
                b.TextColor3 = Color3.fromRGB(160, 140, 190)
            end
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(100, 35, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActiveTab = name
    end)

    return page, btn
end

-- ================================================
-- TABS
-- ================================================
local ESPPage, ESPBtn       = CreateTab(TabBar, "ESP", "👁")
local AimbotPage, AimBtn    = CreateTab(TabBar, "Aimbot", "🎯")
local MovePage, MoveBtn     = CreateTab(TabBar, "Movement", "⚡")
local GamePage, GameBtn     = CreateTab(TabBar, "Game: "..CurrentGame, "🎮")
local MiscPage, MiscBtn     = CreateTab(TabBar, "Misc", "⚙")

-- Activer ESP par défaut
ESPPage.Visible = true
ESPBtn.BackgroundColor3 = Color3.fromRGB(100, 35, 200)
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ================================================
-- ESP PAGE
-- ================================================
local espY = 8

CreateSection(ESPPage, "ESP Principal", espY) espY = espY + 28

CreateToggle(ESPPage, "ESP Activé", espY, function(v)
    Settings.ESP.Enabled = v
end) espY = espY + 38

CreateToggle(ESPPage, "Boîtes (Carrées)", espY, function(v)
    Settings.ESP.Boxes = v
end) espY = espY + 38

CreateToggle(ESPPage, "Noms des joueurs", espY, function(v)
    Settings.ESP.Names = v
end) espY = espY + 38

CreateToggle(ESPPage, "Distance", espY, function(v)
    Settings.ESP.Distance = v
end) espY = espY + 38

CreateToggle(ESPPage, "Santé", espY, function(v)
    Settings.ESP.Health = v
end) espY = espY + 38

CreateToggle(ESPPage, "Bones (Squelette)", espY, function(v)
    Settings.ESP.Bones = v
end) espY = espY + 38

CreateToggle(ESPPage, "Lignes (Tracers)", espY, function(v)
    Settings.ESP.Lines = v
end) espY = espY + 38

CreateSection(ESPPage, "Distance max", espY) espY = espY + 28
CreateSlider(ESPPage, "Distance maximale", espY, 50, 2000, 500, function(v)
    Settings.ESP.MaxDistance = v
end) espY = espY + 58

ESPPage.CanvasSize = UDim2.new(0, 0, 0, espY + 20)

-- ================================================
-- AIMBOT PAGE
-- ================================================
local aimY = 8

CreateSection(AimbotPage, "Aimbot", aimY) aimY = aimY + 28

CreateToggle(AimbotPage, "Aimbot Activé (Clic droit)", aimY, function(v)
    Settings.Aimbot.Enabled = v
end) aimY = aimY + 38

CreateToggle(AimbotPage, "Afficher FOV", aimY, function(v)
    Settings.Aimbot.ShowFOV = v
end) aimY = aimY + 38

CreateSection(AimbotPage, "Paramètres", aimY) aimY = aimY + 28
CreateSlider(AimbotPage, "FOV Radius", aimY, 10, 500, 150, function(v)
    Settings.Aimbot.FOV = v
end) aimY = aimY + 58

CreateSlider(AimbotPage, "Smoothness", aimY, 1, 50, 5, function(v)
    Settings.Aimbot.Smoothness = v / 100
end) aimY = aimY + 58

AimbotPage.CanvasSize = UDim2.new(0, 0, 0, aimY + 20)

-- ================================================
-- MOVEMENT PAGE
-- ================================================
local movY = 8

CreateSection(MovePage, "Vitesse & Sauts", movY) movY = movY + 28

CreateToggle(MovePage, "Speed Hack", movY, function(v)
    Settings.Movement.Speed = v
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v and Settings.Movement.SpeedValue or 16 end
    end
end) movY = movY + 38

CreateSlider(MovePage, "Vitesse", movY, 16, 300, 50, function(v)
    Settings.Movement.SpeedValue = v
    if Settings.Movement.Speed and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end) movY = movY + 58

CreateToggle(MovePage, "Jump Power", movY, function(v)
    Settings.Movement.JumpPower = v
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v and Settings.Movement.JumpValue or 50 end
    end
end) movY = movY + 38

CreateSlider(MovePage, "Puissance saut", movY, 50, 500, 150, function(v)
    Settings.Movement.JumpValue = v
    if Settings.Movement.JumpPower and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v end
    end
end) movY = movY + 58

CreateSection(MovePage, "Exploits", movY) movY = movY + 28

CreateToggle(MovePage, "Infinite Jump (Voler)", movY, function(v)
    Settings.Movement.InfiniteJump = v
end) movY = movY + 38

CreateToggle(MovePage, "Fly", movY, function(v)
    Settings.Movement.Fly = v
    Flying = v
end) movY = movY + 38

CreateSlider(MovePage, "Vitesse vol", movY, 10, 200, 50, function(v)
    Settings.Movement.FlySpeed = v
end) movY = movY + 58

CreateToggle(MovePage, "NoClip (Passer les murs)", movY, function(v)
    Settings.Movement.NoClip = v
    NoClipping = v
end) movY = movY + 38

CreateSection(MovePage, "Fun", movY) movY = movY + 28

CreateToggle(MovePage, "Spin (Corps qui tourne)", movY, function(v)
    Settings.Movement.Spin = v
    Spinning = v
end) movY = movY + 38

CreateSlider(MovePage, "Vitesse spin", movY, 1, 50, 10, function(v)
    Settings.Movement.SpinSpeed = v
end) movY = movY + 58

MovePage.CanvasSize = UDim2.new(0, 0, 0, movY + 20)

-- ================================================
-- MISC PAGE
-- ================================================
local miscY = 8
CreateSection(MiscPage, "Interface", miscY) miscY = miscY + 28

CreateToggle(MiscPage, "Anti-AFK", miscY, function(v)
    if v then
        local vj = Instance.new("VirtualUser")
        vj.Parent = game
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vj:CaptureController()
            vj:ClickButton2(Vector2.new())
        end)
    end
end) miscY = miscY + 38

MiscPage.CanvasSize = UDim2.new(0, 0, 0, miscY + 20)

-- ================================================
-- GAME-SPECIFIC PAGE
-- ================================================
local gameY = 8

local function LoadGameSpecific()
    -- Nettoyer
    for _, c in pairs(GamePage:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    gameY = 8

    if CurrentGame == "MurderMystery2" then
        CreateSection(GamePage, "Murder Mystery 2", gameY) gameY = gameY + 28

        CreateToggle(GamePage, "ESP Innocents (Vert)", gameY, function(v)
            Settings.GameSpecific.MM2_InnocentESP = v
        end) gameY = gameY + 38

        CreateToggle(GamePage, "ESP Sheriff (Bleu)", gameY, function(v)
            Settings.GameSpecific.MM2_SheriffESP = v
        end) gameY = gameY + 38

        CreateToggle(GamePage, "ESP Murderer (Rouge)", gameY, function(v)
            Settings.GameSpecific.MM2_MurdererESP = v
        end) gameY = gameY + 38

        CreateToggle(GamePage, "Auto-Collect Coins", gameY, function(v)
            Settings.GameSpecific.MM2_AutoCoins = v
        end) gameY = gameY + 38

    elseif CurrentGame == "Arsenal" then
        CreateSection(GamePage, "Arsenal", gameY) gameY = gameY + 28

        CreateToggle(GamePage, "Aimbot Arsenal", gameY, function(v)
            Settings.GameSpecific.ARS_Aimbot = v
        end) gameY = gameY + 38

        CreateToggle(GamePage, "Auto-Collect Points", gameY, function(v)
            Settings.GameSpecific.ARS_AutoPoints = v
        end) gameY = gameY + 38

    elseif CurrentGame == "JailBreak" then
        CreateSection(GamePage, "JailBreak", gameY) gameY = gameY + 28

        CreateToggle(GamePage, "Auto-Rob", gameY, function(v)
            Settings.GameSpecific.JB_AutoRob = v
        end) gameY = gameY + 38

        CreateToggle(GamePage, "Infinite Ammo", gameY, function(v)
            Settings.GameSpecific.JB_InfAmmo = v
        end) gameY = gameY + 38

    elseif CurrentGame == "BrookHaven" then
        CreateSection(GamePage, "BrookHaven", gameY) gameY = gameY + 28

        CreateToggle(GamePage, "ESP Joueurs", gameY, function(v)
            Settings.GameSpecific.BH_ESP = v
        end) gameY = gameY + 38

    elseif CurrentGame == "Doors" then
        CreateSection(GamePage, "Doors", gameY) gameY = gameY + 28

        CreateToggle(GamePage, "ESP Entités (monstre)", gameY, function(v)
            Settings.GameSpecific.DO_MonsterESP = v
        end) gameY = gameY + 38

        CreateToggle(GamePage, "ESP Items (clés, etc.)", gameY, function(v)
            Settings.GameSpecific.DO_ItemESP = v
        end) gameY = gameY + 38

    else
        local noGame = Instance.new("TextLabel")
        noGame.Size = UDim2.new(1, 0, 0, 50)
        noGame.Position = UDim2.new(0, 0, 0, gameY)
        noGame.BackgroundTransparency = 1
        noGame.Text = "Aucune catégorie pour ce jeu\n(" .. CurrentGame .. ")"
        noGame.TextColor3 = Color3.fromRGB(150, 120, 200)
        noGame.Font = Enum.Font.Gotham
        noGame.TextSize = 13
        noGame.Parent = GamePage
    end

    GamePage.CanvasSize = UDim2.new(0, 0, 0, gameY + 20)
end

LoadGameSpecific()

-- ================================================
-- FOV CIRCLE (Aimbot)
-- ================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ================================================
-- ESP LOGIC
-- ================================================
local function GetCharacterParts(char)
    local parts = {}
    if char then
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") then
                table.insert(parts, p)
            end
        end
    end
    return parts
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function GetBoundingBox(character)
    local min, max = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
    for _, part in pairs(GetCharacterParts(character)) do
        local pos = part.Position
        local size = part.Size / 2
        min = Vector3.new(math.min(min.X, pos.X - size.X), math.min(min.Y, pos.Y - size.Y), math.min(min.Z, pos.Z - size.Z))
        max = Vector3.new(math.max(max.X, pos.X + size.X), math.max(max.Y, pos.Y + size.Y), math.max(max.Z, pos.Z + size.Z))
    end
    return min, max
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end

    local drawings = {}

    -- Box (4 lignes pour carré)
    drawings.BoxLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Settings.ESP.BoxColor
        line.Thickness = 1.5
        table.insert(drawings.BoxLines, line)
    end

    -- Nom
    drawings.Name = Drawing.new("Text")
    drawings.Name.Visible = false
    drawings.Name.Color = Settings.ESP.NameColor
    drawings.Name.Size = 14
    drawings.Name.Font = 2
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.OutlineColor = Color3.fromRGB(0, 0, 0)

    -- Distance
    drawings.Distance = Drawing.new("Text")
    drawings.Distance.Visible = false
    drawings.Distance.Color = Settings.ESP.DistanceColor
    drawings.Distance.Size = 12
    drawings.Distance.Font = 2
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)

    -- Health bar
    drawings.HealthBg = Drawing.new("Line")
    drawings.HealthBg.Visible = false
    drawings.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthBg.Thickness = 4

    drawings.HealthFill = Drawing.new("Line")
    drawings.HealthFill.Visible = false
    drawings.HealthFill.Color = Color3.fromRGB(0, 255, 0)
    drawings.HealthFill.Thickness = 3

    -- Tracer (ligne depuis le bas)
    drawings.Tracer = Drawing.new("Line")
    drawings.Tracer.Visible = false
    drawings.Tracer.Color = Settings.ESP.TracerColor
    drawings.Tracer.Thickness = 1

    ESPObjects[player] = drawings
end

local function RemoveESPForPlayer(player)
    if ESPObjects[player] then
        for _, d in pairs(ESPObjects[player]) do
            if type(d) == "table" then
                for _, line in pairs(d) do pcall(function() line:Remove() end) end
            else
                pcall(function() d:Remove() end)
            end
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if not (char and root and hum and head) or not Settings.ESP.Enabled then
            for _, d in pairs(drawings) do
                if type(d) == "table" then for _, l in pairs(d) do l.Visible = false end
                else d.Visible = false end
            end
            -- eslint-disable-next
        else
            local rootPos = root.Position
            local dist = (rootPos - Camera.CFrame.Position).Magnitude

            if dist > Settings.ESP.MaxDistance then
                for _, d in pairs(drawings) do
                    if type(d) == "table" then for _, l in pairs(d) do l.Visible = false end
                    else d.Visible = false end
                end
            else
                local minBB, maxBB = GetBoundingBox(char)

                -- Box carrée
                local topLeft3D     = Vector3.new(minBB.X, maxBB.Y, rootPos.Z)
                local topRight3D    = Vector3.new(maxBB.X, maxBB.Y, rootPos.Z)
                local bottomLeft3D  = Vector3.new(minBB.X, minBB.Y, rootPos.Z)
                local bottomRight3D = Vector3.new(maxBB.X, minBB.Y, rootPos.Z)

                local tl, tlV = WorldToScreen(topLeft3D)
                local tr, trV = WorldToScreen(topRight3D)
                local bl, blV = WorldToScreen(bottomLeft3D)
                local br, brV = WorldToScreen(bottomRight3D)

                if tlV and Settings.ESP.Boxes then
                    drawings.BoxLines[1].From = tl drawings.BoxLines[1].To = tr drawings.BoxLines[1].Visible = true
                    drawings.BoxLines[2].From = tr drawings.BoxLines[2].To = br drawings.BoxLines[2].Visible = true
                    drawings.BoxLines[3].From = br drawings.BoxLines[3].To = bl drawings.BoxLines[3].Visible = true
                    drawings.BoxLines[4].From = bl drawings.BoxLines[4].To = tl drawings.BoxLines[4].Visible = true
                else
                    for _, l in pairs(drawings.BoxLines) do l.Visible = false end
                end

                -- Nom
                local headSP, headV = WorldToScreen(head.Position + Vector3.new(0, 0.7, 0))
                if headV and Settings.ESP.Names then
                    drawings.Name.Position = headSP - Vector2.new(0, 16)
                    drawings.Name.Text = player.Name
                    drawings.Name.Visible = true
                else drawings.Name.Visible = false end

                -- Distance
                if headV and Settings.ESP.Distance then
                    local dText = string.format("[%dm]", math.floor(dist / 3))
                    drawings.Distance.Position = Vector2.new(tl.X + (tr.X - tl.X) / 2, bl.Y + 4)
                    drawings.Distance.Text = dText
                    drawings.Distance.Visible = true
                else drawings.Distance.Visible = false end

                -- Health
                if tlV and Settings.ESP.Health then
                    local hp = hum.Health / hum.MaxHealth
                    local barX = tl.X - 6
                    local barTop = tl.Y
                    local barBot = bl.Y
                    local barMid = barTop + (barBot - barTop) * (1 - hp)
                    drawings.HealthBg.From = Vector2.new(barX, barTop)
                    drawings.HealthBg.To = Vector2.new(barX, barBot)
                    drawings.HealthBg.Visible = true
                    drawings.HealthFill.From = Vector2.new(barX, barMid)
                    drawings.HealthFill.To = Vector2.new(barX, barBot)
                    drawings.HealthFill.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                    drawings.HealthFill.Visible = true
                else
                    drawings.HealthBg.Visible = false
                    drawings.HealthFill.Visible = false
                end

                -- Tracer
                if headV and Settings.ESP.Lines then
                    local screenMid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local rootSP = WorldToScreen(rootPos)
                    drawings.Tracer.From = screenMid
                    drawings.Tracer.To = rootSP
                    drawings.Tracer.Visible = true
                else drawings.Tracer.Visible = false end

                -- Game specific MM2 colors
                if CurrentGame == "MurderMystery2" then
                    local role = "Innocent"
                    local ok, val = pcall(function()
                        return player:GetAttribute("Role") or ""
                    end)
                    if ok then role = val end

                    local col = Color3.fromRGB(0, 255, 80)
                    if role == "Sheriff" then col = Color3.fromRGB(0, 120, 255) end
                    if role == "Murderer" then col = Color3.fromRGB(255, 40, 40) end

                    local show = (role == "Innocent" and Settings.GameSpecific.MM2_InnocentESP)
                        or (role == "Sheriff" and Settings.GameSpecific.MM2_SheriffESP)
                        or (role == "Murderer" and Settings.GameSpecific.MM2_MurdererESP)

                    for _, l in pairs(drawings.BoxLines) do l.Color = col l.Visible = l.Visible and show end
                    drawings.Name.Color = col
                end
            end
        end
    end
end

-- ================================================
-- AIMBOT LOGIC
-- ================================================
local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDist = Settings.Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = WorldToScreen(head.Position)
                if onScreen then
                    local dist = (screenPos - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function UpdateAimbot()
    if not Settings.Aimbot.Enabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local target = GetClosestPlayer()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local pos, onScreen = WorldToScreen(head.Position)
            if onScreen then
                local cam = Camera.CFrame
                local dir = (head.Position - cam.Position).Unit
                local smooth = Settings.Aimbot.Smoothness
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(cam.Position, cam.Position + dir),
                    smooth
                )
            end
        end
    end
end

-- ================================================
-- FLY LOGIC
-- ================================================
local flyBodyVel, flyBodyGyro

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    flyBodyVel.Parent = root

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root
end

local function StopFly()
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

local function UpdateFly()
    if not Flying then StopFly() return end
    if not flyBodyVel then StartFly() end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local speed = Settings.Movement.FlySpeed
    local dir = Vector3.new(0, 0, 0)
    local cam = Camera.CFrame

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

    flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.new(0, 0, 0)
    flyBodyGyro.CFrame = cam
end

-- ================================================
-- SPIN LOGIC
-- ================================================
local spinAngle = 0

local function UpdateSpin()
    if not Spinning then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    spinAngle = spinAngle + Settings.Movement.SpinSpeed
    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
end

-- ================================================
-- NOCLIP LOGIC
-- ================================================
local function UpdateNoClip()
    if not NoClipping then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- ================================================
-- INFINITE JUMP
-- ================================================
UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ================================================
-- MAIN LOOP
-- ================================================
RunService.RenderStepped:Connect(function()
    -- FOV circle
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    UpdateESP()
    UpdateAimbot()
    UpdateFly()
    UpdateSpin()
    UpdateNoClip()
end)

-- Init ESP pour les joueurs existants
for _, p in pairs(Players:GetPlayers()) do
    CreateESPForPlayer(p)
end
Players.PlayerAdded:Connect(CreateESPForPlayer)
Players.PlayerRemoving:Connect(RemoveESPForPlayer)

LocalPlayer.CharacterAdded:Connect(function()
    if Flying then task.wait(0.1) StartFly() end
end)

-- ================================================
-- DRAG MAIN FRAME
-- ================================================
local dragStart, startPos, dragging2 = nil, nil, false

TopBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging2 = true
        dragStart = inp.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging2 = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ================================================
-- CLOSE / MINIMIZE
-- ================================================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentFrame.Visible = not minimized
    TabBar.Visible = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 780, 0, 42)
    else
        MainFrame.Size = UDim2.new(0, 780, 0, 520)
    end
end)

-- ================================================
-- TOGGLE GUI (INSERT key)
-- ================================================
UserInputService.InputBegan:Connect(function(inp, processed)
    if not processed and inp.KeyCode == Enum.KeyCode.Insert then
        if Unlocked then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

-- ================================================
-- AUTH LOGIC
-- ================================================
AccesBtn.MouseButton1Click:Connect(function()
    if PassInput.Text == PASSWORD then
        TweenService:Create(AuthFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -225, 0.3, -140)}):Play()
        for _, child in pairs(AuthFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
        end
        task.delay(0.45, function()
            AuthFrame:Destroy()
            MainFrame.Visible = true
            Unlocked = true
        end)
    else
        ErrLabel.Text = "❌ Mot de passe incorrect !"
        TweenService:Create(AuthFrame, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -215, 0.5, -140)}):Play()
        task.wait(0.05)
        TweenService:Create(AuthFrame, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -235, 0.5, -140)}):Play()
        task.wait(0.05)
        TweenService:Create(AuthFrame, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -225, 0.5, -140)}):Play()
        task.delay(2, function() ErrLabel.Text = "" end)
    end
end)

-- Enter key aussi
PassInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then AccesBtn.MouseButton1Click:Fire() end
end)

print("[ZentyHub] Chargé avec succès ! Mot de passe: ZentyHubV1")
print("[ZentyHub] Jeu détecté: " .. CurrentGame)
print("[ZentyHub] Appuie sur INSERT pour afficher/cacher le panel")
