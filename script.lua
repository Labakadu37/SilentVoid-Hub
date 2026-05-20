--[[
    ███████╗███████╗███╗   ██╗████████╗██╗   ██╗██╗  ██╗██╗   ██╗██████╗ 
    ╚══███╔╝██╔════╝████╗  ██║╚══██╔══╝╚██╗ ██╔╝██║  ██║██║   ██║██╔══██╗
      ███╔╝ ███████╗██╔██╗ ██║   ██║    ╚████╔╝ ███████║██║   ██║██████╦╝
     ███╔╝  ██╔════╝██║╚██╗██║   ██║     ╚██╔╝  ██╔══██║██║   ██║██╔══██╗
    ███████╗███████╗██║  ████║   ██║      ██║   ██║  ██║╚██████╔╝██████╦╝
    ╚══════╝╚══════╝╚═╝   ╚═══╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    [+] Version 3.0 : Fix Bug d'affichage & Crash Parent Loop
    [+] Système Anti-Crash Exécuteur Intégré
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Nettoyage des anciennes instances pour éviter les doublons
local oldUI = CoreGui:FindFirstChild("ZentyHub_Premium") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ZentyHub_Premium")
if oldUI then oldUI:Destroy() end

-- --- CRÉATION DE LA SCREEN GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyHub_Premium"
ScreenGui.ResetOnSpawn = false

-- Injection ultra-sécurisée
local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- --- CONFIGURATION GLOBALE ---
local ZentyConfig = {
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 5,
        ShowFOV = true,
        TargetLine = true,
        Color = Color3.fromRGB(130, 0, 255)
    },
    Visuals = {
        EspBoxes = false,
        EspNames = false,
        EspDistances = false,
        Color = Color3.fromRGB(130, 0, 255)
    }
}

-- --- CERCLE DE FOV (UI) ---
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "ZentyFOV"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundColor3 = ZentyConfig.Aimbot.Color
FOVFrame.BackgroundTransparency = 0.95
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.5
FOVStroke.Color = ZentyConfig.Aimbot.Color
FOVStroke.Parent = FOVFrame

-- --- TARGET LINE (UI) ---
local LineFrame = Instance.new("Frame")
LineFrame.Name = "ZentyTargetLine"
LineFrame.BackgroundColor3 = ZentyConfig.Aimbot.Color
LineFrame.BorderSizePixel = 0
LineFrame.AnchorPoint = Vector2.new(0, 0.5)
LineFrame.Visible = false
LineFrame.Parent = ScreenGui

-- --- MAIN FRAME (MENU PHANTOM VIOLET) ---
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui -- FIX: Parent direct à la ScreenGui

-- Script de Drag (Déplacement) moderne sans .Draggable (Anti-Crash PC/Mobile)
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
Title.Text = "ZentyHub <font color='rgb(180, 100, 255)'>▼ Phantom</font>"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.RichText = true
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

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

-- --- NAVIGATION MULTI-ONGLETS ---
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

-- --- COMPOSANTS DE L'UI ---
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

-- Remplissage des pages
UILibrary:CreateToggle(Pages["Aimbot"], "Activer l'Aimbot", ZentyConfig.Aimbot.Enabled, function(v) ZentyConfig.Aimbot.Enabled = v end)
UILibrary:CreateToggle(Pages["Aimbot"], "Afficher le Cercle FOV", ZentyConfig.Aimbot.ShowFOV, function(v) ZentyConfig.Aimbot.ShowFOV = v end)
UILibrary:CreateToggle(Pages["Aimbot"], "Ligne de Cible (Target Line)", ZentyConfig.Aimbot.TargetLine, function(v) ZentyConfig.Aimbot.TargetLine = v end)
UILibrary:CreateSlider(Pages["Aimbot"], "Taille du FOV", 50, 400, ZentyConfig.Aimbot.FOV, function(v) ZentyConfig.Aimbot.FOV = v end)
UILibrary:CreateSlider(Pages["Aimbot"], "Smoothness (Lissage)", 1, 25, ZentyConfig.Aimbot.Smoothness, function(v) ZentyConfig.Aimbot.Smoothness = v end)

UILibrary:CreateToggle(Pages["Visual"], "Box ESP (Contours Violet)", ZentyConfig.Visuals.EspBoxes, function(v) ZentyConfig.Visuals.EspBoxes = v end)
UILibrary:CreateToggle(Pages["Visual"], "Afficher les Pseudos", ZentyConfig.Visuals.EspNames, function(v) ZentyConfig.Visuals.EspNames = v end)
UILibrary:CreateToggle(Pages["Visual"], "Afficher la Distance", ZentyConfig.Visuals.EspDistances, function(v) ZentyConfig.Visuals.EspDistances = v end)

-- --- RECHERCHE DU JOUEUR LE PLUS PROCHE ---
local function GetClosestPlayer()
    local closestTarget = nil
    local maxDistance = ZentyConfig.Aimbot.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mouseLocation = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                if distance < maxDistance then
                    closestTarget = player
                    maxDistance = distance
                end
            end
        end
    end
    return closestTarget
end

-- --- ESP NATIVE ANTI-CRASH ---
local EspContainer = Instance.new("Folder")
local successContainer = pcall(function() EspContainer.Parent = CoreGui end)
if not successContainer then EspContainer.Parent = ScreenGui end

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
                    local sizeX = 1300 / screenPos.Z
                    local sizeY = 1800 / screenPos.Z
                    
                    if not existingEsp then
                        existingEsp = Instance.new("Frame")
                        existingEsp.Name = espName
                        existingEsp.BackgroundTransparency = 1
                        existingEsp.Size = UDim2.new(0, sizeX, 0, sizeY)
                        existingEsp.AnchorPoint = Vector2.new(0.5, 0.5)
                        existingEsp.Parent = EspContainer
                        
                        local stroke = Instance.new("UIStroke")
                        stroke.Thickness = 1.5
                        stroke.Color = ZentyConfig.Visuals.Color
                        stroke.Name = "BoxOutline"
                        stroke.Parent = existingEsp

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "EspText"
                        textLabel.Size = UDim2.new(1, 0, 0, 20)
                        textLabel.Position = UDim2.new(0, 0, 0, -25)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextSize = 12
                        textLabel.Parent = existingEsp
                    end
                    
                    existingEsp.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    existingEsp.Size = UDim2.new(0, sizeX, 0, sizeY)
                    existingEsp.BoxOutline.Enabled = ZentyConfig.Visuals.EspBoxes
                    
                    if ZentyConfig.Visuals.EspNames or ZentyConfig.Visuals.EspDistances then
                        local labelText = ""
                        if ZentyConfig.Visuals.EspNames then labelText = player.Name end
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

-- --- BOUCLE UNIVERSELLE ---
RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    
    -- Cercle de FOV
    if ZentyConfig.Aimbot.ShowFOV then
        FOVFrame.Position = UDim2.new(0, mouseLoc.X, 0, mouseLoc.Y)
        FOVFrame.Size = UDim2.new(0, ZentyConfig.Aimbot.FOV * 2, 0, ZentyConfig.Aimbot.FOV * 2)
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end

    -- Gestion Cible & Lock Viseur
    local target = GetClosestPlayer()
    
    if ZentyConfig.Aimbot.Enabled and target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        
        if onScreen then
            -- Target Line
            if ZentyConfig.Aimbot.TargetLine then
                local startPos = Vector2.new(mouseLoc.X, mouseLoc.Y)
                local endPos = Vector2.new(headPos.X, headPos.Y)
                local distance = (endPos - startPos).Magnitude
                local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)
                
                LineFrame.Size = UDim2.new(0, distance, 0, 2)
                LineFrame.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
                LineFrame.Rotation = math.deg(angle)
                LineFrame.Visible = true
            else
                LineFrame.Visible = false
            end
            
            -- Lock Caméra (Valide PC & Mobile)
            -- S'active automatiquement lorsque tu maintiens le clic droit/gauche ou appuie sur ton écran tactile
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

