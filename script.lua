--[[
    ███████╗███████╗███╗   ██╗████████╗██╗   ██╗██╗  ██╗██╗   ██╗██████╗ 
    ╚══███╔╝██╔════╝████╗  ██║╚══██╔══╝╚██╗ ██╔╝██║  ██║██║   ██║██╔══██╗
      ███╔╝ ███████╗██╔██╗ ██║   ██║    ╚████╔╝ ███████║██║   ██║██████╦╝
     ███╔╝  ██╔════╝██║╚██╗██║   ██║     ╚██╔╝  ██╔══██║██║   ██║██╔══██╗
    ███████╗███████╗██║  ████║   ██║      ██║   ██║  ██║╚██████╔╝██████╦╝
    ╚══════╝╚══════╝╚═╝   ╚═══╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    [+] Version 4.0 ULTRA OVERPOWERED : Panel Massif Sans Perte de Code (600+ Lignes)
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TargetParent = LocalPlayer:WaitForChild("PlayerGui")
local oldUI = TargetParent:FindFirstChild("ZentyHub_Premium")
if oldUI then oldUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyHub_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = TargetParent

-- --- CONFIGURATION GLOBALE ULTRA ÉTENDUE ---
local ZentyConfig = {
    Aimbot = { Enabled = false, TargetMurdererOnly = false, FOV = 150, LockPower = 50, ShowFOV = true, Color = Color3.fromRGB(130, 0, 255), TargetPart = "Head" },
    Visuals = { EspBoxes = false, EspNames = false, EspDistances = false, RoleESP = false, Tracers = false, Color = Color3.fromRGB(130, 0, 255), Chams = false, GunEsp = false, TracersOrigin = "Top" },
    Movement = { SpeedEnabled = false, Speed = 16, JumpEnabled = false, Jump = 50, FlyEnabled = false, FlySpeed = 50, BunnyHop = false },
    Fun = { SpinBot = false, SpinSpeed = 50, InfiniteJump = false, NoClip = false, ChatSpam = false, CarFly = false, GameFOVEnabled = false, GameFOV = 70, HitboxSize = 2, HitboxEnabled = false },
    PlayerAdvanced = { BringAll = false, KillAllActive = false, ClickTP = false, Invisible = false, GodMode = false, FlingAll = false, AntiAim = false, SafeZoneTP = false },
    MM2 = { GrabGun = false, AutoExpose = false, AutoFarmCoins = false, AntiKnife = false }
}

local SelectedPlayerForTp = ""
local SpamMessages = {"ZentyHub On Top !", "Imagine losing to ZentyHub", "Get good, get ZentyHub", "ZentyHub owned this server"}
local SafeZonePlatform = nil

-- --- CERCLE DE FOV ---
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

-- --- MAIN FRAME (PANEL GEANT CONFIGURÉ) ---
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 460)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 9, 18)
MainFrame.BackgroundTransparency = 0.12
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local PanelBackgroundImg = Instance.new("ImageLabel")
PanelBackgroundImg.Name = "PanelBackgroundImg"
PanelBackgroundImg.Size = UDim2.new(1, 0, 1, 0)
PanelBackgroundImg.BackgroundTransparency = 1
PanelBackgroundImg.Image = "rbxassetid://1000057472" 
PanelBackgroundImg.ImageTransparency = 0.8
PanelBackgroundImg.ScaleType = Enum.ScaleType.Crop
PanelBackgroundImg.ZIndex = 0
PanelBackgroundImg.Parent = MainFrame

-- Système de Drag (Glissement) Restauré et Sécurisé
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
MainCorner.CornerRadius = UDim.new(0, 14)
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
TopBar.ZIndex = 2
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 400, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "ZentyHub <font color='rgb(180, 100, 255)'>▼ V4.0 ULTRA OVERPOWERED</font>"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.PlayerAdvanced = Enum.Font.GothamBold
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
CloseBtn.ZIndex = 3
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -78, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 100, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 3
MinimizeBtn.Parent = TopBar

local MenuMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    MenuMinimized = not MenuMinimized
    for _, child in pairs(MainFrame:GetChildren()) do
        if child ~= TopBar and child ~= PanelBackgroundImg and child:IsA("GuiObject") then
            child.Visible = not MenuMinimized
        end
    end
    if MenuMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 720, 0, 45)}):Play()
        PanelBackgroundImg.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 720, 0, 460)}):Play()
        PanelBackgroundImg.Visible = true
    end
end)

-- --- NAVIGATION ÉTENDUE ---
local Navigation = Instance.new("Frame")
Navigation.Size = UDim2.new(0, 160, 1, -60)
Navigation.Position = UDim2.new(0, 10, 0, 50)
Navigation.BackgroundTransparency = 1
Navigation.ZIndex = 2
Navigation.Parent = MainFrame

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 6)
NavLayout.Parent = Navigation

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -190, 1, -60)
PagesContainer.Position = UDim2.new(0, 180, 0, 50)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ZIndex = 2
PagesContainer.Parent = MainFrame

local Pages = {}
local Categories = {"Aimbot", "Visuals", "Deplacement", "Joueurs (Avance)", "Fun", "MM2 (Exclusif)", "Settings"}
local IsFirstPage = true

for i, catName in ipairs(Categories) do
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, 0, 0, 36)
    NavBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    NavBtn.BackgroundTransparency = 0.3
    NavBtn.Text = "  " .. catName
    NavBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    NavBtn.Font = Enum.Font.GothamSemibold
    NavBtn.TextSize = 13
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.ZIndex = 3
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
    Page.CanvasSize = UDim2.new(0, 0, 3.2, 0) -- Énorme espace de défilement pour toutes les commandes
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(130, 0, 255)
    Page.ZIndex = 3
    Page.Parent = PagesContainer
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
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
    
    if IsFirstPage then
        Page.Visible = true
        NavBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
        NavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnStroke.Color = Color3.fromRGB(180, 100, 255)
        IsFirstPage = false
    end
end

-- --- LIBRAIRIE COMPOSANTS COMPLÈTE ET SÉCURISÉE ---
local UILibrary = {}

function UILibrary:CreateToggle(parent, text, default, callback)
    local Enabled = default
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(1, -10, 0, 40)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    ToggleBg.BackgroundTransparency = 0.2
    ToggleBg.ZIndex = 4
    ToggleBg.Parent = parent
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleBg
    
    local TText = Instance.new("TextLabel")
    TText.Size = UDim2.new(0, 250, 1, 0)
    TText.Position = UDim2.new(0, 15, 0, 0)
    TText.BackgroundTransparency = 1
    TText.Text = text
    TText.TextColor3 = Color3.fromRGB(230, 230, 230)
    TText.Font = Enum.Font.Gotham
    TText.TextSize = 13
    TText.TextXAlignment = Enum.TextXAlignment.Left
    TText.ZIndex = 5
    TText.Parent = ToggleBg
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 45, 0, 22)
    Switch.Position = UDim2.new(1, -60, 0.5, -11)
    Switch.BackgroundColor3 = Enabled and Color3.fromRGB(130, 0, 255) or Color3.fromRGB(40, 35, 50)
    Switch.Text = ""
    Switch.ZIndex = 5
    Switch.Parent = ToggleBg
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(1, 0)
    SCorner.Parent = Switch
    
    local SliderCircle = Instance.new("Frame")
    SliderCircle.Size = UDim2.new(0, 16, 0, 16)
    SliderCircle.Position = Enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderCircle.ZIndex = 6
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

function UILibrary:CreateSlider(parent, text, min, max, default, suffix, callback)
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -10, 0, 50)
    SliderBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    SliderBg.BackgroundTransparency = 0.2
    SliderBg.ZIndex = 4
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
    SText.ZIndex = 5
    SText.Parent = SliderBg
    
    local ValText = Instance.new("TextLabel")
    ValText.Size = UDim2.new(0, 65, 0, 25)
    ValText.Position = UDim2.new(1, -80, 0, 2)
    ValText.BackgroundTransparency = 1
    ValText.Text = tostring(default) .. suffix
    ValText.TextColor3 = Color3.fromRGB(180, 100, 255)
    ValText.Font = Enum.Font.GothamBold
    ValText.TextSize = 13
    ValText.TextXAlignment = Enum.TextXAlignment.Right
    ValText.ZIndex = 5
    ValText.Parent = SliderBg

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -30, 0, 6)
    Track.Position = UDim2.new(0, 15, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
    Track.Text = ""
    Track.ZIndex = 5
    Track.Parent = SliderBg
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 6
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
        ValText.Text = tostring(value) .. suffix
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
    Btn.BackgroundTransparency = 0.1
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.ZIndex = 4
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

function UILibrary:CreateDropdown(parent, text, items, callback)
    local DropBg = Instance.new("Frame")
    DropBg.Size = UDim2.new(1, -10, 0, 40)
    DropBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    DropBg.BackgroundTransparency = 0.2
    DropBg.ClipsDescendants = true
    DropBg.ZIndex = 4
    DropBg.Parent = parent
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 6)
    DCorner.Parent = DropBg
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(1, 0, 0, 40)
    DropBtn.BackgroundTransparency = 1
    DropBtn.Text = "  " .. text .. " : " .. tostring(items[1])
    DropBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropBtn.Font = Enum.Font.GothamSemibold
    DropBtn.TextSize = 13
    DropBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropBtn.ZIndex = 5
    DropBtn.Parent = DropBg

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 0, #items * 30)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ZIndex = 5
    ContentFrame.Parent = DropBg
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = ContentFrame

    local Toggled = false
    for _, item in pairs(items) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
        OptBtn.Text = "    " .. tostring(item)
        OptBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 6
        OptBtn.Parent = ContentFrame
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = "  " .. text .. " : " .. tostring(item)
            Toggled = false
            TweenService:Create(DropBg, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 40)}):Play()
            callback(item)
        end)
    end

    DropBtn.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        if Toggled then
            TweenService:Create(DropBg, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 40 + (#items * 30))}):Play()
        else
            TweenService:Create(DropBg, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        end
    end)
end

function UILibrary:CreatePlayerDropdown(parent, text, callback)
    local DropBg = Instance.new("Frame")
    DropBg.Size = UDim2.new(1, -10, 0, 40)
    DropBg.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    DropBg.BackgroundTransparency = 0.2
    DropBg.ClipsDescendants = true
    DropBg.ZIndex = 4
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
    DropBtn.ZIndex = 5
    DropBtn.Parent = DropBg

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 0, 120)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ZIndex = 5
    ContentFrame.Parent = DropBg
    
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, 0)
    ScrollList.BackgroundTransparency = 1
    ScrollList.CanvasSize = UDim2.new(0,0,0,0)
    ScrollList.ScrollBarThickness = 2
    ScrollList.ZIndex = 6
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
                OptBtn.ZIndex = 7
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

-- --- MM2 UTILS CORE ---
local function GetPlayerMM2Role(player)
    local hasKnife = false
    local hasGun = false
    if player:FindFirstChild("Backpack") then
        if player.Backpack:FindFirstChild("Knife") then hasKnife = true end
        if player.Backpack:FindFirstChild("Gun") then hasGun = true end
    end
    if player.Character then
        if player.Character:FindFirstChild("Knife") then hasKnife = true end
        if player.Character:FindFirstChild("Gun") then hasGun = true end
    end
    if hasKnife then return "Murderer", Color3.fromRGB(255, 0, 0)
    elseif hasGun then return "Sheriff", Color3.fromRGB(0, 120, 255)
    else return "Innocent", Color3.fromRGB(0, 255, 0) end
end

local function ApplyChams(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("ZentyCham")
        if ZentyConfig.Visuals.Chams then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ZentyCham"
                highlight.Parent = player.Character
            end
            local _, roleColor = GetPlayerMM2Role(player)
            highlight.FillColor = roleColor
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Enabled = true
        else
            if highlight then highlight:Destroy() end
        end
    end
end

-- --- REMPLISSAGE DES OPTIONS DU MENU (ZÉRO PERTE + MASS COMMANDES) ---

-- 1. CATEGORY AIMBOT
UILibrary:CreateToggle(Pages["Aimbot"], "Activer l'Aimbot", ZentyConfig.Aimbot.Enabled, function(v) ZentyConfig.Aimbot.Enabled = v end)
UILibrary:CreateToggle(Pages["Aimbot"], "Afficher le Cercle FOV", ZentyConfig.Aimbot.ShowFOV, function(v) ZentyConfig.Aimbot.ShowFOV = v end)
UILibrary:CreateSlider(Pages["Aimbot"], "Taille du FOV", 50, 500, ZentyConfig.Aimbot.FOV, "px", function(v) ZentyConfig.Aimbot.FOV = v end)
UILibrary:CreateSlider(Pages["Aimbot"], "Puissance de Lock", 0, 100, ZentyConfig.Aimbot.LockPower, "%", function(v) ZentyConfig.Aimbot.LockPower = v end)
UILibrary:CreateDropdown(Pages["Aimbot"], "Cible Aim", {"Head", "HumanoidRootPart", "LowerTorso"}, function(v) ZentyConfig.Aimbot.TargetPart = v end)

-- 2. CATEGORY VISUALS
UILibrary:CreateToggle(Pages["Visuals"], "Box ESP Contours Fixes", ZentyConfig.Visuals.EspBoxes, function(v) ZentyConfig.Visuals.EspBoxes = v end)
UILibrary:CreateToggle(Pages["Visuals"], "Tracers (Lignes)", ZentyConfig.Visuals.Tracers, function(v) ZentyConfig.Visuals.Tracers = v end)
UILibrary:CreateDropdown(Pages["Visuals"], "Origine des Tracers", {"Top", "Center", "Bottom"}, function(v) ZentyConfig.Visuals.TracersOrigin = v end)
UILibrary:CreateToggle(Pages["Visuals"], "Afficher les Pseudos", ZentyConfig.Visuals.EspNames, function(v) ZentyConfig.Visuals.EspNames = v end)
UILibrary:CreateToggle(Pages["Visuals"], "Afficher la Distance", ZentyConfig.Visuals.EspDistances, function(v) ZentyConfig.Visuals.EspDistances = v end)
UILibrary:CreateToggle(Pages["Visuals"], "Activer les Chams (Murs)", false, function(v) ZentyConfig.Visuals.Chams = v for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyChams(p) end end end)

-- 3. CATEGORY DEPLACEMENT
UILibrary:CreateToggle(Pages["Deplacement"], "Activer Modification Vitesse", false, function(v) ZentyConfig.Movement.SpeedEnabled = v end)
UILibrary:CreateSlider(Pages["Deplacement"], "Vitesse de Marche", 16, 150, ZentyConfig.Movement.Speed, "", function(v) ZentyConfig.Movement.Speed = v end)
UILibrary:CreateToggle(Pages["Deplacement"], "Activer Modification Saut", false, function(v) ZentyConfig.Movement.JumpEnabled = v end)
UILibrary:CreateSlider(Pages["Deplacement"], "Hauteur de Saut", 50, 250, ZentyConfig.Movement.Jump, "", function(v) ZentyConfig.Movement.Jump = v end)
UILibrary:CreateToggle(Pages["Deplacement"], "Activer le Mode Fly (Voler)", false, function(v) ZentyConfig.Movement.FlyEnabled = v end)
UILibrary:CreateSlider(Pages["Deplacement"], "Vitesse de Vol", 10, 150, ZentyConfig.Movement.FlySpeed, "", function(v) ZentyConfig.Movement.FlySpeed = v end)
UILibrary:CreateToggle(Pages["Deplacement"], "Infinite Jump", false, function(v) ZentyConfig.Movement.InfiniteJump = v end)
UILibrary:CreateToggle(Pages["Deplacement"], "Noclip Intelligent", false, function(v) ZentyConfig.Movement.NoClip = v end)
UILibrary:CreateToggle(Pages["Deplacement"], "BunnyHop Auto", false, function(v) ZentyConfig.Movement.BunnyHop = v end)

-- 4. CATEGORY JOUEURS (AVANCE) --> REMPLACÉ ET ENRICHI SELON TES SOUHAITS EXACTS
UILibrary:CreateToggle(Pages["Joueurs (Avance)"], "Téléporter TOUT LE MONDE sur moi (Bring All)", false, function(v)
    ZentyConfig.PlayerAdvanced.BringAll = v
    if v then
        task.spawn(function()
            while ZentyConfig.PlayerAdvanced.BringAll do
                task.wait(0.3)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                        end
                    end
                end
            end
        end)
    end
end)

-- [AJOUT] FLING ALL (ÉJECTER TOUT LE SERVEUR DANS LES AIRS)
UILibrary:CreateToggle(Pages["Joueurs (Avance)"], "Fling All (Faire voler tout le serveur)", false, function(v)
    ZentyConfig.PlayerAdvanced.FlingAll = v
    if v then
        task.spawn(function()
            while ZentyConfig.PlayerAdvanced.FlingAll do
                task.wait(0.1)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local oldVelocity = LocalPlayer.Character.HumanoidRootPart.Velocity
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(99999, 99999, 99999)
                            task.wait(0.05)
                        end
                    end
                    LocalPlayer.Character.HumanoidRootPart.Velocity = oldVelocity
                end
            end
        end)
    end
end)

-- [AJOUT] ANTI-AIM / SPINBOT DEFENSE (RÉDUIT LES CHANCES DE SE FAIRE VISER)
UILibrary:CreateToggle(Pages["Joueurs (Avance)"], "Anti-Aim Client (Esquive les tirs)", false, function(v)
    ZentyConfig.PlayerAdvanced.AntiAim = v
    if v then
        task.spawn(function()
            while ZentyConfig.PlayerAdvanced.AntiAim do
                task.wait(0.02)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
                end
            end
        end)
    end
end)

-- [AJOUT] TP SECURISE COMPLET (ZONE PROTECTION HORS MAP)
UILibrary:CreateToggle(Pages["Joueurs (Avance)"], "Téléporter dans une Zone Sécurisée", false, function(v)
    ZentyConfig.PlayerAdvanced.SafeZoneTP = v
    if v then
        if not SafeZonePlatform then
            SafeZonePlatform = Instance.new("Part", workspace)
            SafeZonePlatform.Size = Vector3.new(30, 1, 30)
            SafeZonePlatform.Position = Vector3.new(0, 2000, 0)
            SafeZonePlatform.Anchored = true
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 2003, 0)
        end
    else
        if SafeZonePlatform then SafeZonePlatform:Destroy() SafeZonePlatform = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0 -- Respawn automatique hors zone
        end
    end
end)

UILibrary:CreateToggle(Pages["Joueurs (Avance)"], "Click TP (Ctrl + Click Gauche)", false, function(v) ZentyConfig.PlayerAdvanced.ClickTP = v end)
UILibrary:CreateToggle(Pages["Joueurs (Avance)"], "Mode Invisible (Semi-Bypass)", false, function(v) 
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("LowerTorso") then
        local root = char.HumanoidRootPart
        if root:FindFirstChild("RootJoint") then
            root.RootJoint.C0 = v and CFrame.new(0, 500, 0) or CFrame.new(0, 0, 0)
        end
    end
end)

UILibrary:CreatePlayerDropdown(Pages["Joueurs (Avance)"], "Choisir un joueur", function(selected) SelectedPlayerForTp = selected end)
UILibrary:CreateButton(Pages["Joueurs (Avance)"], "Se téléporter au joueur choisi", function()
    if SelectedPlayerForTp ~= "" then
        local target = Players:FindFirstChild(SelectedPlayerForTp)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- 5. CATEGORY FUN
UILibrary:CreateToggle(Pages["Fun"], "Activer le SpinBot", false, function(v) ZentyConfig.Fun.SpinBot = v end)
UILibrary:CreateSlider(Pages["Fun"], "Vitesse du Spin", 10, 200, ZentyConfig.Fun.SpinSpeed, "", function(v) ZentyConfig.Fun.SpinSpeed = v end)

-- [AJOUT] CONFIGURATEUR TAILLE HITBOX (GROSSE TÊTE ENNEMIE)
UILibrary:CreateToggle(Pages["Fun"], "Grossir les Têtes (Hitbox Magnifiée)", false, function(v) ZentyConfig.Fun.HitboxEnabled = v end)
UILibrary:CreateSlider(Pages["Fun"], "Multiplicateur de Hitbox", 2, 25, ZentyConfig.Fun.HitboxSize, " studs", function(v) ZentyConfig.Fun.HitboxSize = v end)

UILibrary:CreateToggle(Pages["Fun"], "Forcer la Caméra FOV", false, function(v) ZentyConfig.Fun.GameFOVEnabled = v end)
UILibrary:CreateSlider(Pages["Fun"], "Vision FOV Jeu", 70, 140, ZentyConfig.Fun.GameFOV, "°", function(v) ZentyConfig.Fun.GameFOV = v end)

UILibrary:CreateToggle(Pages["Fun"], "Spam Chat Automatique", false, function(v) 
    ZentyConfig.Fun.ChatSpam = v 
    task.spawn(function()
        while ZentyConfig.Fun.ChatSpam do
            task.wait(2)
            local msg = SpamMessages[math.random(1, #SpamMessages)]
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end)
end)

-- 6. CATEGORY MM2 EXCLUSIF
UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "MM2 Rôles ESP Couleurs", ZentyConfig.Visuals.RoleESP, function(v) ZentyConfig.Visuals.RoleESP = v end)
UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "Aimbot : Cible Uniquement le Murderer", ZentyConfig.Aimbot.TargetMurdererOnly, function(v) ZentyConfig.Aimbot.TargetMurdererOnly = v end)
UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "ESP de l'Arme au Sol", false, function(v) ZentyConfig.Visuals.GunEsp = v end)

UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "Prendre le Pistolet Auto s'il tombe", false, function(v)
    ZentyConfig.MM2.GrabGun = v
    if v then
        task.spawn(function()
            while ZentyConfig.MM2.GrabGun do
                task.wait(0.2)
                local gunDrop = workspace:FindFirstChild("GunDrop")
                if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
                end
            end
        end)
    end
end)

-- [AJOUT] AUTO-FARM COINS (TÉLÉPORTE SUR TOUTES LES PIÈCES DES MAPS DE MM2)
UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "Auto-Farm de Pièces (Coins)", false, function(v)
    ZentyConfig.MM2.AutoFarmCoins = v
    if v then
        task.spawn(function()
            while ZentyConfig.MM2.AutoFarmCoins do
                task.wait(0.4)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local normalContainer = workspace:FindFirstChild("Normal")
                    if normalContainer then
                        local coinContainer = normalContainer:FindFirstChild("CoinContainer")
                        if coinContainer then
                            for _, coin in pairs(coinContainer:GetChildren()) do
                                if coin:IsA("BasePart") and ZentyConfig.MM2.AutoFarmCoins then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- [AJOUT] ANTI-KNIFE KILL (TÉLÉPORTE AUTOMATIQUEMENT HORS DE PORTÉE DU MURDERER S'IL S'APPROCHE APPRÊTÉ)
UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "Anti-Knife (Bypass Couteau Tueur)", false, function(v)
    ZentyConfig.MM2.AntiKnife = v
    if v then
        task.spawn(function()
            while ZentyConfig.MM2.AntiKnife do
                task.wait(0.1)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and GetPlayerMM2Role(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            local isKnifeEquipped = p.Character:FindFirstChild("Knife")
                            if distance < 18 and isKnifeEquipped then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0) -- Esquive verticale
                            end
                        end
                    end
                end
            end
        end)
    end
end)

UILibrary:CreateToggle(Pages["MM2 (Exclusif)"], "Auto Kill All (Si tu as l'arme en main)", false, function(v) 
    ZentyConfig.PlayerAdvanced.KillAllActive = v 
    if v then
        task.spawn(function()
            while ZentyConfig.PlayerAdvanced.KillAllActive do
                task.wait(0.2)
                local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if currentTool then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait(0.05)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                    end
                end
            end
        end)
    end
end)

UILibrary:CreateButton(Pages["MM2 (Exclusif)"], "Révéler les Rôles dans le Chat", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local role, _ = GetPlayerMM2Role(p)
            if role == "Murderer" or role == "Sheriff" then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[ZentyHub EXPOSE] " .. p.Name .. " est " .. role .. " !", "All")
                task.wait(0.5)
            end
        end
    end
end)

-- 7. CATEGORY SETTINGS
UILibrary:CreateButton(Pages["Settings"], "Thème : Violet d'origine", function() MainStroke.Color = Color3.fromRGB(130, 0, 255) FOVStroke.Color = Color3.fromRGB(130, 0, 255) ZentyConfig.Aimbot.Color = Color3.fromRGB(130, 0, 255) end)
UILibrary:CreateButton(Pages["Settings"], "Thème : Rouge Sang", function() MainStroke.Color = Color3.fromRGB(255, 0, 50) FOVStroke.Color = Color3.fromRGB(255, 0, 50) ZentyConfig.Aimbot.Color = Color3.fromRGB(255, 0, 50) end)
UILibrary:CreateButton(Pages["Settings"], "Thème : Cyber Cyan", function() MainStroke.Color = Color3.fromRGB(0, 230, 255) FOVStroke.Color = Color3.fromRGB(0, 230, 255) ZentyConfig.Aimbot.Color = Color3.fromRGB(0, 230, 255) end)


-- --- MOTEURS CENTRALISÉS ET BOUCLES CONSTANTES ---

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and ZentyConfig.PlayerAdvanced.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if ZentyConfig.Movement.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        if ZentyConfig.Movement.SpeedEnabled then char.Humanoid.WalkSpeed = ZentyConfig.Movement.Speed end
        if ZentyConfig.Movement.JumpEnabled then char.Humanoid.JumpPower = ZentyConfig.Movement.Jump end
        
        if ZentyConfig.Movement.BunnyHop and char.Humanoid.FloorMaterial ~= Enum.Material.Air then
            char.Humanoid:ChangeState("Jumping")
        end

        if ZentyConfig.Movement.FlyEnabled then
            char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            local moveDir = char.Humanoid.MoveDirection
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (moveDir * (ZentyConfig.Movement.FlySpeed / 10))
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, ZentyConfig.Movement.FlySpeed / 15, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, ZentyConfig.Movement.FlySpeed / 15, 0)
            end
        end

        if ZentyConfig.Fun.SpinBot then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(ZentyConfig.Fun.SpinSpeed), 0)
        end
        
        if ZentyConfig.Movement.NoClip then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

local function GetClosestPlayerToCenter()
    local closestTarget = nil
    local maxDistance = ZentyConfig.Aimbot.FOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if player.Character:FindFirstChild(ZentyConfig.Aimbot.TargetPart) then
                if ZentyConfig.Aimbot.TargetMurdererOnly and GetPlayerMM2Role(player) ~= "Murderer" then continue end
                local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character[ZentyConfig.Aimbot.TargetPart].Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                    if distance < maxDistance then closestTarget = player maxDistance = distance end
                end
            end
        end
    end
    return closestTarget
end

local EspContainer = Instance.new("Folder", ScreenGui)

-- CORE ET RENDER GESTION ESP + HITBOX EXTENDER
RunService.RenderStepped:Connect(function()
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if ZentyConfig.Fun.GameFOVEnabled then Camera.FieldOfView = ZentyConfig.Fun.GameFOV end
    if ZentyConfig.Aimbot.ShowFOV then
        FOVFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)
        FOVFrame.Size = UDim2.new(0, ZentyConfig.Aimbot.FOV * 2, 0, ZentyConfig.Aimbot.FOV * 2)
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end

    -- Moteur Aim
    local target = GetClosestPlayerToCenter()
    if ZentyConfig.Aimbot.Enabled and ZentyConfig.Aimbot.LockPower > 0 and target and target.Character and target.Character:FindFirstChild(ZentyConfig.Aimbot.TargetPart) then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService.TouchEnabled then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Character[ZentyConfig.Aimbot.TargetPart].Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, ZentyConfig.Aimbot.LockPower / 100)
        end
    end

    -- ESP Arme Tombée
    local gunDrop = workspace:FindFirstChild("GunDrop")
    local gunEsp = EspContainer:FindFirstChild("GunDropESP")
    if gunDrop and ZentyConfig.Visuals.GunEsp then
        if not gunEsp then
            gunEsp = Instance.new("Frame", EspContainer)
            gunEsp.Name = "GunDropESP"
            gunEsp.Size = UDim2.new(0, 40, 0, 40)
            gunEsp.BackgroundTransparency = 1
            local stroke = Instance.new("UIStroke", gunEsp)
            stroke.Thickness = 2
            stroke.Color = Color3.fromRGB(255, 215, 0)
            local text = Instance.new("TextLabel", gunEsp)
            text.Size = UDim2.new(1, 0, 0, 15)
            text.Position = UDim2.new(0, 0, 0, -20)
            text.Text = "Pistolet Tombé !"
            text.TextColor3 = Color3.fromRGB(255, 215, 0)
            text.Font = Enum.Font.GothamBold
            text.TextSize = 12
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(gunDrop.Position)
        gunEsp.Visible = onScreen
        if onScreen then gunEsp.Position = UDim2.new(0, screenPos.X - 20, 0, screenPos.Y - 20) end
    else
        if gunEsp then gunEsp.Visible = false end
    end

    -- Boucle Joueurs (ESP Box / Tracers / Chams / Hitbox Size)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ApplyChams(player)
            
            -- Gestion Taille de la Hitbox
            if player.Character and player.Character:FindFirstChild("Head") then
                if ZentyConfig.Fun.HitboxEnabled then
                    player.Character.Head.Size = Vector3.new(ZentyConfig.Fun.HitboxSize, ZentyConfig.Fun.HitboxSize, ZentyConfig.Fun.HitboxSize)
                    player.Character.Head.Transparency = 0.6
                else
                    player.Character.Head.Size = Vector3.new(1.2, 1.2, 1.2)
                    player.Character.Head.Transparency = 0
                end
            end

            local char = player.Character
            local espName = player.Name .. "_ZentyESP"
            local tracerName = player.Name .. "_ZentyTracer"
            
            local existingEsp = EspContainer:FindFirstChild(espName)
            local existingTracer = EspContainer:FindFirstChild(tracerName)
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local drawColor = ZentyConfig.Visuals.Color
                    local roleName = ""
                    local rName, rColor = GetPlayerMM2Role(player)
                    if ZentyConfig.Visuals.RoleESP then drawColor = rColor roleName = rName end

                    -- Tracers Origin Calculateur
                    if ZentyConfig.Visuals.Tracers then
                        if not existingTracer then
                            existingTracer = Instance.new("Frame", EspContainer)
                            existingTracer.Name = tracerName
                            existingTracer.BorderSizePixel = 0
                            existingTracer.AnchorPoint = Vector2.new(0.5, 0.5)
                        end
                        local startPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        if ZentyConfig.Visuals.TracersOrigin == "Center" then
                            startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        elseif ZentyConfig.Visuals.TracersOrigin == "Bottom" then
                            startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        end
                        local endPos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (endPos - startPos).Magnitude
                        local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)
                        
                        existingTracer.Size = UDim2.new(0, distance, 0, 1.5)
                        existingTracer.Position = UDim2.new(0, (startPos.X + endPos.X) / 2, 0, (startPos.Y + endPos.Y) / 2)
                        existingTracer.Rotation = math.deg(angle)
                        existingTracer.BackgroundColor3 = drawColor
                        existingTracer.Visible = true
                    else
                        if existingTracer then existingTracer.Visible = false end
                    end

                    -- Box ESP + Pseudo + Distance Text Moteur
                    if ZentyConfig.Visuals.EspBoxes or ZentyConfig.Visuals.EspNames or ZentyConfig.Visuals.EspDistances then
                        local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
                        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                        local boxWidth = boxHeight * 0.6
                        
                        if not existingEsp then
                            existingEsp = Instance.new("Frame", EspContainer)
                            existingEsp.Name = espName
                            existingEsp.BackgroundTransparency = 1
                            existingEsp.AnchorPoint = Vector2.new(0.5, 0.5)
                            local stroke = Instance.new("UIStroke", existingEsp)
                            stroke.Thickness = 1.8
                            stroke.Name = "BoxOutline"
                            local textLabel = Instance.new("TextLabel", existingEsp)
                            textLabel.Name = "EspText"
                            textLabel.Size = UDim2.new(1, 0, 0, 20)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Font = Enum.Font.GothamBold
                            textLabel.TextSize = 11
                        end
                        
                        existingEsp.Position = UDim2.new(0, screenPos.X, 0, (topPos.Y + bottomPos.Y) / 2)
                        existingEsp.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                        existingEsp.BoxOutline.Enabled = ZentyConfig.Visuals.EspBoxes
                        existingEsp.BoxOutline.Color = drawColor
                        existingEsp.EspText.TextColor3 = drawColor
                        existingEsp.EspText.Position = UDim2.new(0, 0, 0, -(boxHeight/2) - 15)
                        
                        local labelText = ""
                        if ZentyConfig.Visuals.RoleESP then labelText = "["..roleName.."] " end
                        if ZentyConfig.Visuals.EspNames then labelText = labelText .. player.Name end
                        if ZentyConfig.Visuals.EspDistances then
                            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                            labelText = labelText .. " [" .. dist .. "m]"
                        end
                        existingEsp.EspText.Text = labelText
                        existingEsp.EspText.Visible = (labelText ~= "")
                        existingEsp.Visible = true
                    else
                        if existingEsp then existingEsp.Visible = false end
                    end
                else
                    if existingEsp then existingEsp.Visible = false end
                    if existingTracer then existingTracer.Visible = false end
                end
            else
                if existingEsp then existingEsp.Visible = false end
                if existingTracer then existingTracer.Visible = false end
            end
        end
    end
end)
