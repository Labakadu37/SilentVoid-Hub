--[[
    ███████╗███████╗███╗   ██╗████████╗██╗   ██╗██╗  ██╗██╗   ██╗██████╗ 
    ╚══███╔╝██╔════╝████╗  ██║╚══██╔══╝╚██╗ ██╔╝██║  ██║██║   ██║██╔══██╗
      ███╔╝ ███████╗██╔██╗ ██║   ██║    ╚████╔╝ ███████║██║   ██║██████╦╝
     ███╔╝  ██╔════╝██║╚██╗██║   ██║     ╚██╔╝  ██╔══██║██║   ██║██╔══██╗
    ███████╗███████╗██║  ████║   ██║      ██║   ██║  ██║╚██████╔╝██████╦╝
    ╚══════╝╚══════╝╚═╝   ╚═══╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    [+] Version 7.5 : Édition MM2 (Murder Mystery 2) Intégrée
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Parent sécurisé dans PlayerGui
local TargetParent = LocalPlayer:WaitForChild("PlayerGui")
local oldUI = TargetParent:FindFirstChild("ZentyHub_Premium")
if oldUI then oldUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyHub_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

-- --- CONFIGURATION GLOBALE ---
local ZentyConfig = {
    Aimbot = { Enabled = false, TargetMurdererOnly = false, FOV = 150, Smoothness = 5, ShowFOV = true, TargetLine = true, Color = Color3.fromRGB(130, 0, 255) },
    Visuals = { EspBoxes = false, EspNames = false, EspDistances = false, RoleESP = false, Color = Color3.fromRGB(130, 0, 255) },
    Fun = { SpinBot = false, SpinSpeed = 50, InfiniteJump = false, NoClip = false },
    MM2 = { KillAllActive = false }
}

local SelectedPlayerForTp = ""
local MM2_ID = 142823686 -- Place ID de Murder Mystery 2

-- --- CERCLE DE FOV STABLE ---
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "ZentyFOV"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1 
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.5
FOVStroke.Color = ZentyConfig.Aimbot.Color
FOVStroke.Parent = FOVFrame

-- --- TARGET LINE CORRIGÉE ---
local LineFrame = Instance.new("Frame")
LineFrame.Name = "ZentyTargetLine"
LineFrame.BackgroundColor3 = ZentyConfig.Aimbot.Color
LineFrame.BorderSizePixel = 0
LineFrame.AnchorPoint = Vector2.new(0, 0.5) 
LineFrame.Size = UDim2.new(0, 0, 0, 2)
LineFrame.Visible = false
LineFrame.Parent = ScreenGui

local LineStroke = Instance.new("UIStroke")
LineStroke.Thickness = 0.5
LineStroke.Color = ZentyConfig.Aimbot.Color
LineStroke.Parent = LineFrame

-- --- MAIN FRAME (MENU) ---
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Système de Drag
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(130, 0, 255)
MainStroke.Parent = MainFrame

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "ZentyHub <font color='rgb(180, 100, 255)'>▼ MM2 Edition</font>"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.RichText = true
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Boutons Fenêtre
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(130, 0, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -78, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TopBar
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeBtn

local MenuMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    MenuMinimized = not MenuMinimized
    for _, child in pairs(MainFrame:GetChildren()) do
        if child ~= TopBar and child:IsA("GuiObject") then
            child.Visible = not MenuMinimized
        end
    end
    if MenuMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 550, 0, 45)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 550, 0, 350)}):Play()
    end
end)

-- --- NAVIGATION ---
local Navigation = Instance.new("Frame")
Navigation.Size = UDim2.new(0, 130, 1, -60)
Navigation.Position = UDim2.new(0, 10, 0, 50)
Navigation.BackgroundTransparency = 1
Navigation.Parent = MainFrame

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 8)
NavLayout.Parent = Navigation

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -160, 1, -60)
PagesContainer.Position = UDim2.new(0, 150, 0, 50)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local Pages = {}
local Categories = {"Aimbot", "Visual", "Player", "Movement", "Fun", "Settings"}

-- Ajout de la page MM2
if game.PlaceId == MM2_ID or true then -- "or true" permet de la voir même si l'ID diffère légèrement
    table.insert(Categories, #Categories, "MM2 Hacks")
end

for i, catName in ipairs(Categories) do
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, 0, 0, 35)
    NavBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    NavBtn.BackgroundTransparency = 0.5
    NavBtn.Text = "  " .. catName
    NavBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    NavBtn.Font = Enum.Font.GothamSemibold
    NavBtn.TextSize = 13
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.Parent = Navigation
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = NavBtn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(50, 40, 70)
    BtnStroke.Parent = NavBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(130, 0, 255)
    Page.Parent = PagesContainer
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.Parent = Page

    Pages[catName] = Page

    NavBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(Navigation:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundColor3 = Color3.fromRGB(25, 20, 35)}):Play()
                b:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(50, 40, 70)
            end
        end
        Page.Visible = true
        TweenService:Create(NavBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(130, 0, 255)}):Play()
        BtnStroke.Color = Color3.fromRGB(180, 100, 255)
    end)
    
    if i == 1 then
        Page.Visible = true
        NavBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
        NavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnStroke.Color = Color3.fromRGB(180, 100, 255)
    end
end

-- --- LIBRAIRIE COMPOSANTS ---
local UILibrary = {}

function UILibrary:CreateToggle(parent, text, default, callback)
    local Enabled = default
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(1, -10, 0, 40)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    ToggleBg.Parent = parent
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleBg
    
    local TText = Instance.new("TextLabel")
    TText.Size = UDim2.new(0, 200, 1, 0)
    TText.Position = UDim2.new(0, 15, 0, 0)
    TText.BackgroundTransparency = 1
    TText.Text = text
    TText.TextColor3 = Color3.fromRGB(230, 230, 230)
    TText.Font = Enum.Font.Gotham
    TText.TextSize = 13
    TText.TextXAlignment = Enum.TextXAlignment.Left
    TText.Parent = ToggleBg
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 45, 0, 22)
    Switch.Position = UDim2.new(1, -60, 0.5, -11)
    Switch.BackgroundColor3 = Enabled and Color3.fromRGB(130, 0, 255) or Color3.fromRGB(40, 35, 50)
    Switch.Text = ""
    Switch.Parent = ToggleBg
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(1, 0)
    SCorner.Parent = Switch
    
    local SliderCircle = Instance.new("Frame")
    SliderCircle.Size = UDim2.new(0, 16, 0, 16)
    SliderCircle.Position = Enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderCircle.Parent = Switch
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = SliderCircle
    
    Switch.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        local targetPos = Enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        local targetColor = Enabled and Color3.fromRGB(130, 0, 255) or Color3.fromRGB(40, 35, 50)
        TweenService:Create(SliderCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.25), {BackgroundColor3 = targetColor}):Play()
        callback(Enabled)
    end)
end

function UILibrary:CreateSlider(parent, text, min, max, default, callback)
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -10, 0, 50)
    SliderBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    SliderBg.Parent = parent
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 6)
    SCorner.Parent = SliderBg
    
    local SText = Instance.new("TextLabel")
    SText.Size = UDim2.new(0, 200, 0, 25)
    SText.Position = UDim2.new(0, 15, 0, 2)
    SText.BackgroundTransparency = 1
    SText.Text = text
    SText.TextColor3 = Color3.fromRGB(230, 230, 230)
    SText.Font = Enum.Font.Gotham
    SText.TextSize = 13
    SText.TextXAlignment = Enum.TextXAlignment.Left
    SText.Parent = SliderBg
    
    local ValText = Instance.new("TextLabel")
    ValText.Size = UDim2.new(0, 50, 0, 25)
    ValText.Position = UDim2.new(1, -65, 0, 2)
    ValText.BackgroundTransparency = 1
    ValText.Text = tostring(default)
    ValText.TextColor3 = Color3.fromRGB(180, 100, 255)
    ValText.Font = Enum.Font.GothamBold
    ValText.TextSize = 13
    ValText.TextXAlignment = Enum.TextXAlignment.Right
    ValText.Parent = SliderBg

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -30, 0, 6)
    Track.Position = UDim2.new(0, 15, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
    Track.Text = ""
    Track.Parent = SliderBg
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(1, 0)
    FCorner.Parent = Fill

    local Sliding = false
    local function UpdateSlider()
        local mousePos = UserInputService:GetMouseLocation().X
        local trackPos = Track.AbsolutePosition.X
        local trackWidth = Track.AbsoluteSize.X
        local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
        local value = math.floor(min + (max - min) * percentage)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        ValText.Text = tostring(value)
        callback(value)
    end
    Track.MouseButton1Down:Connect(function() Sliding = true UpdateSlider() end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
    UserInputService.InputChanged:Connect(function(input) if Sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider() end end)
end

function UILibrary:CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 25, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = parent
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = Btn
    local BStroke = Instance.new("UIStroke")
    BStroke.Thickness = 1
    BStroke.Color = Color3.fromRGB(130, 0, 255)
    BStroke.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
end

function UILibrary:CreatePlayerDropdown(parent, text, callback)
    local DropBg = Instance.new("Frame")
    DropBg.Size = UDim2.new(1, -10, 0, 40)
    DropBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    DropBg.ClipsDescendants = true
    DropBg.Parent = parent
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 6)
    DCorner.Parent = DropBg
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(1, 0, 0, 40)
    DropBtn.BackgroundTransparency = 1
    DropBtn.Text = "  " .. text .. " : Aucun"
    DropBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropBtn.Font = Enum.Font.GothamSemibold
    DropBtn.TextSize = 13
    DropBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropBtn.Parent = DropBg

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 0, 120)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = DropBg
    
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, 0)
    ScrollList.BackgroundTransparency = 1
    ScrollList.CanvasSize = UDim2.new(0,0,0,0)
    ScrollList.ScrollBarThickness = 2
    ScrollList.Parent = ContentFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = ScrollList

    local Toggled = false
    
    local function RefreshPlayers()
        for _, c in pairs(ScrollList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                count = count + 1
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
                OptBtn.Text = "    " .. p.Name
                OptBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Parent = ScrollList
                OptBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = "  " .. text .. " : " .. p.Name
                    Toggled = false
                    TweenService:Create(DropBg, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 40)}):Play()
                    callback(p.Name)
                end)
            end
        end
        ScrollList.CanvasSize = UDim2.new(0, 0, 0, count * 30)
    end

    DropBtn.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        if Toggled then
            RefreshPlayers()
            TweenService:Create(DropBg, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 160)}):Play()
        else
            TweenService:Create(DropBg, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        end
    end)
end

-- --- MM2 LOGIC : RÉCUPÉRER LE ROLE ---
local function GetPlayerMM2Role(player)
    local hasKnife = false
    local hasGun = false
    
    -- Vérifie dans le sac à dos
    if player:FindFirstChild("Backpack") then
        if player.Backpack:FindFirstChild("Knife") then hasKnife = true end
        if player.Backpack:FindFirstChild("Gun") then hasGun = true end
    end
    -- Vérifie dans le personnage (si l'arme est équipée)
    if player.Character then
        if player.Character:FindFirstChild("Knife") then hasKnife = true end
        if player.Character:FindFirstChild("Gun") then hasGun = true end
    end

    if hasKnife then
        return "Murderer", Color3.fromRGB(255, 0, 0)
    elseif hasGun then
        return "Sheriff", Color3.fromRGB(0, 100, 255)
    else
        return "Innocent", Color3.fromRGB(0, 255, 0)
    end
end

-- --- CATEGORIES CONFIG ---
UILibrary:CreateToggle(Pages["Aimbot"], "Activer l'Aimbot", ZentyConfig.Aimbot.Enabled, function(v) ZentyConfig.Aimbot.Enabled = v end)
UILibrary:CreateToggle(Pages["Aimbot"], "Viser uniquement le Murderer (MM2)", ZentyConfig.Aimbot.TargetMurdererOnly, function(v) ZentyConfig.Aimbot.TargetMurdererOnly = v end)
UILibrary:CreateToggle(Pages["Aimbot"], "Afficher le Cercle FOV", ZentyConfig.Aimbot.ShowFOV, function(v) ZentyConfig.Aimbot.ShowFOV = v end)
UILibrary:CreateToggle(Pages["Aimbot"], "Ligne de Cible (Target Line)", ZentyConfig.Aimbot.TargetLine, function(v) ZentyConfig.Aimbot.TargetLine = v end)
UILibrary:CreateSlider(Pages["Aimbot"], "Taille du FOV", 50, 500, ZentyConfig.Aimbot.FOV, function(v) ZentyConfig.Aimbot.FOV = v end)
UILibrary:CreateSlider(Pages["Aimbot"], "Smoothness (Lissage)", 1, 25, ZentyConfig.Aimbot.Smoothness, function(v) ZentyConfig.Aimbot.Smoothness = v end)

UILibrary:CreateToggle(Pages["Visual"], "Activer MM2 Role ESP (Vert/Bleu/Rouge)", ZentyConfig.Visuals.RoleESP, function(v) ZentyConfig.Visuals.RoleESP = v end)
UILibrary:CreateToggle(Pages["Visual"], "Box ESP (Contours)", ZentyConfig.Visuals.EspBoxes, function(v) ZentyConfig.Visuals.EspBoxes = v end)
UILibrary:CreateToggle(Pages["Visual"], "Afficher les Pseudos", ZentyConfig.Visuals.EspNames, function(v) ZentyConfig.Visuals.EspNames = v end)
UILibrary:CreateToggle(Pages["Visual"], "Afficher la Distance", ZentyConfig.Visuals.EspDistances, function(v) ZentyConfig.Visuals.EspDistances = v end)

UILibrary:CreatePlayerDropdown(Pages["Player"], "Choisir un joueur", function(selected) SelectedPlayerForTp = selected end)
UILibrary:CreateButton(Pages["Player"], "Se téléporter au joueur", function()
    if SelectedPlayerForTp ~= "" then
        local target = Players:FindFirstChild(SelectedPlayerForTp)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end)

local SoonTxt = Instance.new("TextLabel")
SoonTxt.Size = UDim2.new(1, 0, 0, 50)
SoonTxt.BackgroundTransparency = 1
SoonTxt.Text = "SOON... V2"
SoonTxt.TextColor3 = Color3.fromRGB(130, 0, 255)
SoonTxt.Font = Enum.Font.GothamBold
SoonTxt.TextSize = 24
SoonTxt.Parent = Pages["Movement"]

UILibrary:CreateToggle(Pages["Fun"], "Activer le SpinBot", false, function(v) ZentyConfig.Fun.SpinBot = v end)
UILibrary:CreateSlider(Pages["Fun"], "Vitesse du Spin", 10, 200, ZentyConfig.Fun.SpinSpeed, function(v) ZentyConfig.Fun.SpinSpeed = v end)
UILibrary:CreateToggle(Pages["Fun"], "Infinite Jump", false, function(v) ZentyConfig.Fun.InfiniteJump = v end)
UILibrary:CreateToggle(Pages["Fun"], "Noclip Intelligent", false, function(v) ZentyConfig.Fun.NoClip = v end)

UILibrary:CreateButton(Pages["Settings"], "Changer Thème : Néon Rose", function() MainStroke.Color = Color3.fromRGB(255, 0, 127) FOVStroke.Color = Color3.fromRGB(255, 0, 127) ZentyConfig.Aimbot.Color = Color3.fromRGB(255, 0, 127) end)
UILibrary:CreateButton(Pages["Settings"], "Reset UI par défaut", function() MainStroke.Color = Color3.fromRGB(130, 0, 255) FOVStroke.Color = Color3.fromRGB(130, 0, 255) ZentyConfig.Aimbot.Color = Color3.fromRGB(130, 0, 255) end)

-- --- MM2 HACKS CONFIG ---
local MM2Page = Pages["MM2 Hacks"]
if MM2Page then
    UILibrary:CreateToggle(MM2Page, "Auto Kill All (Si t'es Murderer)", false, function(v) 
        ZentyConfig.MM2.KillAllActive = v 
        if v then
            task.spawn(function()
                while ZentyConfig.MM2.KillAllActive do
                    task.wait(0.2)
                    local myRole = GetPlayerMM2Role(LocalPlayer)
                    if myRole == "Murderer" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        -- Équiper le couteau si pas déjà fait
                        local knife = LocalPlayer.Backpack:FindFirstChild("Knife")
                        if knife then LocalPlayer.Character.Humanoid:EquipTool(knife) end
                        
                        -- Téléporter et tuer chaque joueur
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                                -- Note: Le slash est manuel (clic gauche) ou simulé, on peut faire un mouse1click
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
        end
    end)

    UILibrary:CreateButton(MM2Page, "Téléporter au Murderer & Tuer (Si Shérif)", function()
        local murdererPlayer = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local role, _ = GetPlayerMM2Role(p)
                if role == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    murdererPlayer = p
                    break
                end
            end
        end

        if murdererPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- On équipe le Gun si on l'a
            local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
            if gun then LocalPlayer.Character.Humanoid:EquipTool(gun) end
            
            -- TP dans son dos
            LocalPlayer.Character.HumanoidRootPart.CFrame = murdererPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            
            -- Viser sa tête et tirer (Simulation)
            task.wait(0.1)
            local head = murdererPlayer.Character:FindFirstChild("Head")
            if head then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end
    end)
end

-- --- BOUCLES DE FONCTIONS FUN ---
UserInputService.JumpRequest:Connect(function()
    if ZentyConfig.Fun.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.Stepped:Connect(function()
    if ZentyConfig.Fun.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(ZentyConfig.Fun.SpinSpeed), 0)
    end
    
    if ZentyConfig.Fun.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                local ray = Ray.new(part.Position, Vector3.new(0, 4, 0))
                local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                part.CanCollide = hit and true or false
            end
        end
    end
end)

-- --- ENGINE D'AIMBOT ---
local function GetClosestPlayerToCenter()
    local closestTarget = nil
    local maxDistance = ZentyConfig.Aimbot.FOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            -- Filtre pour l'Aimbot Murderer Only
            if ZentyConfig.Aimbot.TargetMurdererOnly then
                local role, _ = GetPlayerMM2Role(player)
                if role ~= "Murderer" then continue end
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                if distance < maxDistance then closestTarget = player maxDistance = distance end
            end
        end
    end
    return closestTarget
end

-- --- ENGINES ESP ---
local EspContainer = Instance.new("Folder")
EspContainer.Name = "ZentyESP_Folder"
EspContainer.Parent = ScreenGui

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local espName = player.Name .. "_ZentyESP"
            local existingEsp = EspContainer:FindFirstChild(espName)
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen and (ZentyConfig.Visuals.EspBoxes or ZentyConfig.Visuals.EspNames or ZentyConfig.Visuals.EspDistances) then
                    local sizeX = math.clamp(2000 / screenPos.Z, 15, 250)
                    local sizeY = math.clamp(2800 / screenPos.Z, 20, 350)
                    
                    if not existingEsp then
                        existingEsp = Instance.new("Frame")
                        existingEsp.Name = espName
                        existingEsp.BackgroundTransparency = 1
                        existingEsp.AnchorPoint = Vector2.new(0.5, 0.5)
                        existingEsp.Parent = EspContainer
                        
                        local stroke = Instance.new("UIStroke")
                        stroke.Thickness = 1.5
                        stroke.Name = "BoxOutline"
                        stroke.Parent = existingEsp

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "EspText"
                        textLabel.Size = UDim2.new(1, 0, 0, 20)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextSize = 12
                        textLabel.Parent = existingEsp
                    end
                    
                    -- Attribution de la couleur (Role MM2 ou Config Standard)
                    local drawColor = ZentyConfig.Aimbot.Color
                    local roleName = ""
                    if ZentyConfig.Visuals.RoleESP then
                        local rName, rColor = GetPlayerMM2Role(player)
                        drawColor = rColor
                        roleName = rName
                    end

                    existingEsp.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    existingEsp.Size = UDim2.new(0, sizeX, 0, sizeY)
                    existingEsp.BoxOutline.Enabled = ZentyConfig.Visuals.EspBoxes
                    existingEsp.BoxOutline.Color = drawColor
                    existingEsp.EspText.TextColor3 = drawColor
                    existingEsp.EspText.Position = UDim2.new(0, 0, 0, -(sizeY/2) - 15)
                    
                    if ZentyConfig.Visuals.EspNames or ZentyConfig.Visuals.EspDistances or ZentyConfig.Visuals.RoleESP then
                        local labelText = ""
                        if ZentyConfig.Visuals.RoleESP then labelText = "["..roleName.."] " end
                        if ZentyConfig.Visuals.EspNames then labelText = labelText .. player.Name end
                        if ZentyConfig.Visuals.EspDistances then
                            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                            labelText = labelText .. " [" .. distance .. "m]"
                        end
                        existingEsp.EspText.Text = labelText
                        existingEsp.EspText.Visible = true
                    else
                        existingEsp.EspText.Visible = false
                    end
                    existingEsp.Visible = true
                else
                    if existingEsp then existingEsp.Visible = false end
                end
            else
                if existingEsp then existingEsp.Visible = false end
            end
        end
    end
end

-- --- RENDER LOOP (RENDU GRAPHIQUE CONTINU) ---
RunService.RenderStepped:Connect(function()
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    FOVStroke.Color = ZentyConfig.Aimbot.Color
    LineFrame.BackgroundColor3 = ZentyConfig.Aimbot.Color

    if ZentyConfig.Aimbot.ShowFOV then
        FOVFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)
        FOVFrame.Size = UDim2.new(0, ZentyConfig.Aimbot.FOV * 2, 0, ZentyConfig.Aimbot.FOV * 2)
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end

    local target = GetClosestPlayerToCenter()
    if ZentyConfig.Aimbot.Enabled and target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        
        if onScreen then
            if ZentyConfig.Aimbot.TargetLine then
                local endPos = Vector2.new(headPos.X, headPos.Y)
                local distance = (endPos - centerScreen).Magnitude
                local angle = math.atan2(endPos.Y - centerScreen.Y, endPos.X - centerScreen.X)
                
                LineFrame.Size = UDim2.new(0, distance, 0, 2)
                LineFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)
                LineFrame.Rotation = math.deg(angle)
                LineFrame.Visible = true
            else
                LineFrame.Visible = false
            end
            
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService.TouchEnabled then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / ZentyConfig.Aimbot.Smoothness)
            end
        else
            LineFrame.Visible = false
        end
    else
        LineFrame.Visible = false
    end

    UpdateESP()
end)

