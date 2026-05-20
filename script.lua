--[[
    ╔════════════════════════════════════════════════════════════╗
    ║                         ZENTY HUB V1                       ║
    ║                Premium Modern UI Framework                 ║
    ║           Clean Design - High Contrast - Responsive        ║
    ╚════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = player:GetMouse()

local originalGravity = Workspace.Gravity
local originalWalkSpeed = 16
local originalJumpPower = 50

-- Nettoyage des anciennes instances
if player:WaitForChild("PlayerGui"):FindFirstChild("ZentyHub") then
    player.PlayerGui.ZentyHub:Destroy()
end

local Hub = {
    GameMode = "Murder Mystery 2",
    Config = {
        Aimbot = false, AimbotPart = "Head", FovEnabled = false, FovRadius = 140, TeamCheck = false, WallCheck = false,
        EspPlayers = false, EspBoxes = false, EspTracers = false, EspNames = false,
        SpeedEnabled = false, SpeedValue = 16, JumpEnabled = false, JumpValue = 50, FlyEnabled = false, FlySpeed = 3, NoClip = false,
        SpinBot = false, SpinSpeed = 30, FlingAura = false, GravitySlider = 196.2, InfiniteJump = false,
        ClickTeleport = false, ViewSpy = false, HitboxExpanded = false, HitboxSize = 2, BlinkDashEnabled = false,
        EspChams = false,
        -- MM2 Master Package
        Mm2ShowRoles = false, 
        Mm2AutoCollect = false, 
        Mm2MurderAlert = false, 
        Mm2SheriffLock = false,
        Mm2KillMurderer = false,
        Mm2GrabGun = false,
        -- Options d'interface
        BgTransparency = 50
    },
    Cache = {},
    Themes = {
        Main = Color3.fromRGB(15, 15, 22),       
        Sidebar = Color3.fromRGB(10, 10, 14),        
        Accent = Color3.fromRGB(145, 90, 255), -- Violet Électrique Premium
        Row = Color3.fromRGB(22, 22, 30),         
        Text = Color3.fromRGB(255, 255, 255),     
        TextDark = Color3.fromRGB(140, 140, 155), 
        Border = Color3.fromRGB(40, 40, 55)        
    },
    Font = Enum.Font.SourceSansBold,
    FontSub = Enum.Font.SourceSans
}

-- ══════════════════════════════════════════════
--  INITIALISATION DE L'INTERFACE
-- ══════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function round(r, p) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = p return c end
local function line(col, th, p) local s = Instance.new("UIStroke") s.Color = col s.Thickness = th s.Parent = p return s end

-- ══════════════════════════════════════════════
--  PANEL DE CONNEXION (PASSWORD SYSTEM)
-- ══════════════════════════════════════════════
local LoginFrame = Instance.new("Frame")
LoginFrame.Size = UDim2.new(0, 320, 0, 180)
LoginFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
LoginFrame.BackgroundColor3 = Hub.Themes.Main
LoginFrame.Active = true; LoginFrame.Draggable = true; LoginFrame.Parent = ScreenGui
round(8, LoginFrame); line(Hub.Themes.Border, 1.5, LoginFrame)

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, 0, 0, 45)
LoginTitle.BackgroundTransparency = 1; LoginTitle.Text = "ZENTY HUB V1 // VERIFICATION"
LoginTitle.Font = Hub.Font; LoginTitle.TextSize = 15; LoginTitle.TextColor3 = Hub.Themes.Accent; LoginTitle.Parent = LoginFrame

local PasswordBox = Instance.new("TextBox")
PasswordBox.Size = UDim2.new(1, -32, 0, 36)
PasswordBox.Position = UDim2.new(0, 16, 0, 60)
PasswordBox.BackgroundColor3 = Hub.Themes.Row
PasswordBox.Text = ""; PasswordBox.PlaceholderText = "Entrez le mot de passe..."
PasswordBox.Font = Hub.FontSub; PasswordBox.TextSize = 14; PasswordBox.TextColor3 = Hub.Themes.Text
PasswordBox.ClearTextOnFocus = true; PasswordBox.Parent = LoginFrame
round(6, PasswordBox); line(Hub.Themes.Border, 1, PasswordBox)

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(1, -32, 0, 36)
LoginBtn.Position = UDim2.new(0, 16, 0, 115)
LoginBtn.BackgroundColor3 = Hub.Themes.Sidebar
LoginBtn.Text = "VALIDER MATRIX"
LoginBtn.Font = Hub.Font; LoginBtn.TextSize = 13; LoginBtn.TextColor3 = Hub.Themes.Accent; LoginBtn.Parent = LoginFrame
round(6, LoginBtn); line(Hub.Themes.Border, 1.2, LoginBtn)

-- ══════════════════════════════════════════════
--  PANEL PRINCIPAL ZENTY (MODERNE ET TRANSPARENT)
-- ══════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Hub.Themes.Main
MainFrame.BackgroundTransparency = 0.15 -- Laisse transparaître subtilement le jeu derrière
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.Parent = ScreenGui
round(8, MainFrame); line(Hub.Themes.Border, 1.5, MainFrame)

-- Image d'arrière-plan personnalisée (Style Anime / Zenty)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://11414702418" -- Remplace cet ID par ton image Roblox préférée
BackgroundImage.ImageTransparency = 0.5 -- Gère la visibilité de l'image en fond
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 1; BackgroundImage.Parent = MainFrame
round(8, BackgroundImage)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Hub.Themes.Sidebar
Sidebar.BackgroundTransparency = 0.15
Sidebar.ZIndex = 2; Sidebar.Parent = MainFrame
round(8, Sidebar)

local ContainerHolder = Instance.new("Frame")
ContainerHolder.Size = UDim2.new(1, -180, 1, -50)
ContainerHolder.Position = UDim2.new(0, 180, 0, 50)
ContainerHolder.BackgroundTransparency = 1; ContainerHolder.ZIndex = 2; ContainerHolder.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, 0, 0, 45)
HubTitle.Position = UDim2.new(0, 18, 0, 5)
HubTitle.BackgroundTransparency = 1; HubTitle.Text = "ZENTY HUB V1"
HubTitle.Font = Hub.Font; HubTitle.TextSize = 18; HubTitle.TextColor3 = Hub.Themes.Accent; HubTitle.TextXAlignment = Enum.TextXAlignment.Left; HubTitle.ZIndex = 3; HubTitle.Parent = Sidebar

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, 0, 1, -60)
NavList.Position = UDim2.new(0, 0, 0, 55)
NavList.BackgroundTransparency = 1; NavList.BorderSizePixel = 0; NavList.ScrollBarThickness = 0; NavList.ZIndex = 3; NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 4); NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; NavLayout.Parent = NavList

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -180, 0, 50)
Topbar.Position = UDim2.new(0, 180, 0, 0)
Topbar.BackgroundTransparency = 1; Topbar.ZIndex = 2; Topbar.Parent = MainFrame

local GameTag = Instance.new("TextLabel")
GameTag.Size = UDim2.new(1, -20, 1, 0)
GameTag.Position = UDim2.new(0, 15, 0, 0)
GameTag.BackgroundTransparency = 1; GameTag.Text = "SYSTEM ACTIVE // MODE: " .. Hub.GameMode:upper()
GameTag.Font = Hub.Font; GameTag.TextSize = 13; GameTag.TextColor3 = Hub.Themes.TextDark; GameTag.TextXAlignment = Enum.TextXAlignment.Left; GameTag.ZIndex = 3; GameTag.Parent = Topbar

local toggleB = Instance.new("TextButton")
toggleB.Size = UDim2.new(0, 130, 0, 32)
toggleB.Position = UDim2.new(0, 15, 0, 15)
toggleB.BackgroundColor3 = Hub.Themes.Main
toggleB.BackgroundTransparency = 0.1
toggleB.Text = "ZENTY UI"
toggleB.Font = Hub.Font; toggleB.TextColor3 = Hub.Themes.Accent; toggleB.TextSize = 13; toggleB.Visible = false; toggleB.Parent = ScreenGui
round(6, toggleB); line(Hub.Themes.Border, 1.5, toggleB)

toggleB.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Gestion de la connexion stricte
LoginBtn.MouseButton1Click:Connect(function()
    if PasswordBox.Text == "ZentyV1" then
        LoginFrame:Destroy()
        MainFrame.Visible = true
        toggleB.Visible = true
    else
        PasswordBox.Text = ""
        PasswordBox.PlaceholderText = "MOT DE PASSE INCORRECT !"
        task.wait(1.5)
        PasswordBox.PlaceholderText = "Entrez le mot de passe..."
    end
end)

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Hub.Config.FovRadius * 2, 0, Hub.Config.FovRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5); FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0); FOVCircle.BackgroundTransparency = 1; FOVCircle.Visible = false; FOVCircle.Parent = ScreenGui
round(Hub.Config.FovRadius * 2, FOVCircle); local FOVStroke = line(Hub.Themes.Accent, 1.5, FOVCircle)

local AlertLabel = Instance.new("TextLabel")
AlertLabel.Size = UDim2.new(0, 500, 0, 35)
AlertLabel.Position = UDim2.new(0.5, -250, 0, 50)
AlertLabel.BackgroundTransparency = 1
AlertLabel.Font = Hub.Font; AlertLabel.TextSize = 14; AlertLabel.TextColor3 = Color3.fromRGB(255, 65, 65)
AlertLabel.Text = ""; AlertLabel.Visible = false; AlertLabel.Parent = ScreenGui

-- ══════════════════════════════════════════════
--  BUILDER COMPOSANTS (Z-INDEX ADAPTÉS AU FOND)
-- ══════════════════════════════════════════════
local Pages, Buttons, firstPage = {}, {}, nil

local function CreatePage(id, name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0; Page.ScrollBarThickness = 4; Page.Visible = false; Page.ZIndex = 3; Page.Parent = ContainerHolder
    local PL = Instance.new("UIListLayout") PL.Padding = UDim.new(0, 6) PL.HorizontalAlignment = Enum.HorizontalAlignment.Center; PL.Parent = Page
    local PP = Instance.new("UIPadding") PP.PaddingTop = UDim.new(0, 4) PP.Parent = Page
    
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, -16, 0, 36)
    NavBtn.BackgroundColor3 = Color3.fromRGB(0,0,0); NavBtn.BackgroundTransparency = 1
    NavBtn.Text = "   " .. name
    NavBtn.Font = Hub.Font; NavBtn.TextSize = 13; NavBtn.TextColor3 = Hub.Themes.TextDark; NavBtn.TextXAlignment = Enum.TextXAlignment.Left; NavBtn.AutoButtonColor = false; NavBtn.ZIndex = 3; NavBtn.Parent = NavList
    round(6, NavBtn)
    
    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 3, 0, 16)
    Ind.Position = UDim2.new(0, 4, 0.5, -8); Ind.BackgroundColor3 = Hub.Themes.Accent; Ind.BackgroundTransparency = 1; Ind.ZIndex = 3; Ind.Parent = NavBtn
    round(2, Ind)
    
    Pages[id] = Page; Buttons[id] = {Btn = NavBtn, Ind = Ind}
    
    NavBtn.MouseButton1Click:Connect(function()
        for pid, pFrame in pairs(Pages) do
            pFrame.Visible = (pid == id)
            local bData = Buttons[pid]
            if pid == id then
                bData.Btn.TextColor3 = Hub.Themes.Text; bData.Btn.BackgroundTransparency = 0.1; bData.Btn.BackgroundColor3 = Hub.Themes.Row
                TweenService:Create(bData.Ind, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            else
                bData.Btn.TextColor3 = Hub.Themes.TextDark; bData.Btn.BackgroundTransparency = 1
                TweenService:Create(bData.Ind, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end
    end)
    if not firstPage then firstPage = id end
    return Page
end

local function AddToggle(page, title, sub, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -24, 0, 44) Row.BackgroundColor3 = Hub.Themes.Row Row.BackgroundTransparency = 0.2 Row.ZIndex = 3; Row.Parent = page
    round(6, Row); line(Hub.Themes.Border, 1.2, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(1, -100, 0, 18) Txt.Position = UDim2.new(0, 14, 0, 5) Txt.BackgroundTransparency = 1; Txt.Text = title; Txt.Font = Hub.Font; Txt.TextSize = 13; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.ZIndex = 3; Txt.Parent = Row
    local SubTxt = Instance.new("TextLabel") SubTxt.Size = UDim2.new(1, -100, 0, 14) SubTxt.Position = UDim2.new(0, 14, 0, 23) SubTxt.BackgroundTransparency = 1; SubTxt.Text = sub; SubTxt.Font = Hub.FontSub; SubTxt.TextSize = 11; SubTxt.TextColor3 = Hub.Themes.TextDark; SubTxt.TextXAlignment = Enum.TextXAlignment.Left; SubTxt.ZIndex = 3; SubTxt.Parent = Row
    
    local Switch = Instance.new("TextButton") Switch.Size = UDim2.new(0, 42, 0, 20) Switch.Position = UDim2.new(1, -56, 0.5, -10) Switch.BackgroundColor3 = Hub.Config[configKey] and Hub.Themes.Accent or Color3.fromRGB(30, 30, 40); Switch.Text = ""; Switch.ZIndex = 3; Switch.Parent = Row
    round(10, Switch); line(Hub.Themes.Border, 1, Switch)
    
    local Dots = Instance.new("Frame")
    Dots.Size = UDim2.new(0, 14, 0, 14)
    Dots.Position = UDim2.new(0, Hub.Config[configKey] and 24 or 4, 0.5, -7)
    Dots.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Dots.ZIndex = 3; Dots.Parent = Switch; round(7, Dots)
    
    Switch.MouseButton1Click:Connect(function()
        Hub.Config[configKey] = not Hub.Config[configKey]
        local enabled = Hub.Config[configKey]
        TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = enabled and Hub.Themes.Accent or Color3.fromRGB(30, 30, 40)}):Play()
        TweenService:Create(Dots, TweenInfo.new(0.15), {Position = UDim2.new(0, enabled and 24 or 4, 0.5, -7)}):Play()
        callback(enabled)
    end)
end

local function AddSlider(page, title, min, max, default, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -24, 0, 50) Row.BackgroundColor3 = Hub.Themes.Row Row.BackgroundTransparency = 0.2 Row.ZIndex = 3; Row.Parent = page
    round(6, Row); line(Hub.Themes.Border, 1.2, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 200, 0, 18) Txt.Position = UDim2.new(0, 14, 0, 6) Txt.BackgroundTransparency = 1; Txt.Text = title; Txt.Font = Hub.Font; Txt.TextSize = 13; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.ZIndex = 3; Txt.Parent = Row
    local ValTxt = Instance.new("TextLabel") ValTxt.Size = UDim2.new(0, 60, 0, 18) ValTxt.Position = UDim2.new(1, -74, 0, 6) ValTxt.BackgroundTransparency = 1; ValTxt.Text = tostring(default); ValTxt.Font = Hub.Font; ValTxt.TextSize = 12; ValTxt.TextColor3 = Hub.Themes.Accent; ValTxt.TextXAlignment = Enum.TextXAlignment.Right; ValTxt.ZIndex = 3; ValTxt.Parent = Row
    
    local SlideBar = Instance.new("TextButton") SlideBar.Size = UDim2.new(1, -28, 0, 6) SlideBar.Position = UDim2.new(0, 14, 0, 32) SlideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35); SlideBar.Text = ""; SlideBar.AutoButtonColor = false; SlideBar.ZIndex = 3; SlideBar.Parent = Row
    round(3, SlideBar)
    
    local SlideIn = Instance.new("Frame") SlideIn.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); SlideIn.BackgroundColor3 = Hub.Themes.Accent; SlideIn.ZIndex = 3; SlideIn.Parent = SlideBar
    round(3, SlideIn)
    
    local dragging = false
    local function updateSlider()
        local inputPos = UIS:GetMouseLocation().X
        local percentage = math.clamp((inputPos - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
        local roundedVal = math.floor(min + (percentage * (max - min)))
        SlideIn.Size = UDim2.new(percentage, 0, 1, 0)
        ValTxt.Text = tostring(roundedVal)
        Hub.Config[configKey] = roundedVal
        callback(roundedVal)
    end
    SlideBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true updateSlider() end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider() end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- ══════════════════════════════════════════════
--  CREATION DES PAGES ET DES OPTIONS
-- ══════════════════════════════════════════════
local pCombat = CreatePage("combat", "Combat Assist")
local pVisuals = CreatePage("visuals", "Visual Render")
local pLocal = CreatePage("local", "Player Physics")
local pFun = CreatePage("fun", "Blatant & Utility")
local pGameMod = CreatePage("gamemod", "Murder Master")
local pSettings = CreatePage("settings", "UI Customization")

-- Combat
AddToggle(pCombat, "Engine Lock-On", "Assistance de visée angulaire stricte", "Aimbot", function() end)
AddToggle(pCombat, "Raycast Occlusion Check", "Ignore les entités masquées par les murs", "WallCheck", function() end)
AddToggle(pCombat, "Draw Target Boundary", "Rendu du cercle d'acquisition", "FovEnabled", function(v) FOVCircle.Visible = v end)
AddSlider(pCombat, "Boundary Range Radius", 30, 400, 140, "FovRadius", function(v) FOVCircle.Size = UDim2.new(0, v*2, 0, v*2) round(v*2, FOVCircle) end)

-- Visuals
AddToggle(pVisuals, "Master Render Status", "Activer la boucle de rendu des joueurs", "EspPlayers", function() end)
AddToggle(pVisuals, "Bounding Box 2D", "Tracé de rectangles sur les cibles", "EspBoxes", function() end)
AddToggle(pVisuals, "Target Direct Tracers", "Vecteurs au sol depuis le centre de l'écran", "EspTracers", function() end)
AddToggle(pVisuals, "Identification Tags", "Affiche le nom complet et la distance", "EspNames", function() end)
AddToggle(pVisuals, "Wallhack Silhouette Chams", "Rendu en surbrillance à travers les surfaces", "EspChams", function() end)

-- Physics
AddToggle(pLocal, "Override WalkSpeed", "Forcer la vitesse de déplacement au sol", "SpeedEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = originalWalkSpeed end end)
AddSlider(pLocal, "Velocity Amplitude", 16, 250, 16, "SpeedValue", function() end)
AddToggle(pLocal, "Override JumpPower", "Forcer la puissance de saut vertical", "JumpEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = originalJumpPower end end)
AddSlider(pLocal, "Propulsion Amplitude", 50, 300, 50, "JumpValue", function() end)
AddToggle(pLocal, "Quantum Flight Mode", "Annuler la force gravitationnelle", "FlyEnabled", function(v) if not v then Workspace.Gravity = originalGravity if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end end end)
AddSlider(pLocal, "Flight Axis Speed", 1, 15, 3, "FlySpeed", function() end)
AddToggle(pLocal, "Phase Matrix (NoClip)", "Désactiver les collisions globales", "NoClip", function() end)
AddToggle(pLocal, "Hitbox Volumetric Expander", "Agrandit la zone d'impact de la cible", "HitboxExpanded", function() end)
AddSlider(pLocal, "Hitbox Scale Factor", 2, 20, 2, "HitboxSize", function() end)
AddToggle(pLocal, "Blink Forward Dash", "Active la propulsion en avant via la touche X", "BlinkDashEnabled", function() end)

-- Fun / Utility
AddToggle(pFun, "Velocity Spinbot", "Rotation angulaire continue et rapide", "SpinBot", function() end)
AddSlider(pFun, "Spin Angular Rate", 10, 150, 30, "SpinSpeed", function() end)
AddToggle(pFun, "Physics Fling Aura", "Éjecte les entités à proximité immédiate", "FlingAura", function() end)
AddToggle(pFun, "Infinite Air Jump", "Permet l'activation du saut sans appui au sol", "InfiniteJump", function() end)
AddSlider(pFun, "Global World Gravity", 0, 196, 196, "GravitySlider", function(v) Workspace.Gravity = v end)
AddToggle(pFun, "Click Map Teleport", "Pressez CTRL + Clic gauche pour vous téléporter", "ClickTeleport", function() end)
AddToggle(pFun, "View Spy Target", "Clône la caméra sur le joueur ciblé", "ViewSpy", function() end)

-- Murder Master (MM2)
AddToggle(pGameMod, "Role Wallhack Chams", "Coloration stricte (Rouge: Murder, Bleu: Sheriff)", "Mm2ShowRoles", function() end)
AddToggle(pGameMod, "Murderer Proximity Alert", "Alerte dynamique à l'écran si le Meurtrier approche", "Mm2MurderAlert", function() end)
AddToggle(pGameMod, "Sheriff Weapon Lock", "Restreint l'aimbot uniquement sur le Meurtrier", "Mm2SheriffLock", function() end)
AddToggle(pGameMod, "Coin Geometric Grabber", "Attire instantanément toutes les pièces sur vous", "Mm2AutoCollect", function() end)
AddToggle(pGameMod, "Auto Grab Dropped Gun", "Se téléporte sur l'arme au sol à la mort du Shérif", "Mm2GrabGun", function() end)
AddToggle(pGameMod, "Instant Kill Murderer", "Tire automatiquement sur le Meurtrier si vous tenez l'arme", "Mm2KillMurderer", function() end)

-- Personnalisation Zenty Style
AddSlider(pSettings, "Opacité de l'image de fond", 0, 100, 50, "BgTransparency", function(v)
    BackgroundImage.ImageTransparency = (100 - v) / 100
end)

-- ══════════════════════════════════════════════
--  FONCTIONS TECHNIQUES DE CAPTURE
-- ══════════════════════════════════════════════
local function isAlive(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if isAlive(p) and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            return p
        end
    end
    return nil
end

local function getClosestPlayer()
    local closest, maxDist = nil, Hub.Config.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and isAlive(p) then
            local head = p.Character:FindFirstChild(Hub.Config.AimbotPart)
            if head then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < maxDist then maxDist = dist; closest = p end
                end
            end
        end
    end
    return closest
end

-- ══════════════════════════════════════════════
--  BOUCLES DE RENDU VECTORIEL (RENDERSTEPPED)
-- ══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not isAlive(player) then return end
    
    FOVCircle.Position = UDim2.new(0, UIS:GetMouseLocation().X, 0, UIS:GetMouseLocation().Y)
    
    local target = nil
    if Hub.Config.Mm2SheriffLock then
        target = getMurderer()
    elseif Hub.Config.Aimbot then
        target = getClosestPlayer()
    end

    if target and isAlive(target) then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Hub.Config.AimbotPart].Position)
        if Hub.Config.Mm2KillMurderer and player.Character:FindFirstChild("Gun") then
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), Camera.CFrame)
        end
    end

    if Hub.Config.Mm2MurderAlert then
        local m = getMurderer()
        if m and m ~= player and isAlive(m) then
            local dist = (m.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < 50 then
                AlertLabel.Text = "⚠️ ALERTE : MEURTRIER PROCHE [" .. math.floor(dist) .. " STUDS] ⚠️"
                AlertLabel.Visible = true
            else AlertLabel.Visible = false end
        else AlertLabel.Visible = false end
    else AlertLabel.Visible = false end

    if Hub.Config.ViewSpy then
        local spyTarget = getMurderer() or getClosestPlayer()
        if spyTarget and isAlive(spyTarget) then
            Camera.CameraSubject = spyTarget.Character.Humanoid
        end
    else
        if Camera.CameraSubject ~= player.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        end
    end

    -- Dessin du Wallhack (Boxes, Tracers, Noms et Chams)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        local cache = Hub.Cache[p]
        if not cache then
            cache = { 
                Box = Instance.new("Frame"), Tracer = Instance.new("Frame"), Name = Instance.new("TextLabel"), Chams = Instance.new("Highlight")
            }
            cache.Box.BackgroundTransparency = 1; cache.Box.Parent = ScreenGui; line(Hub.Themes.Accent, 1.5, cache.Box)
            cache.Tracer.BorderSizePixel = 0; cache.Tracer.BackgroundColor3 = Hub.Themes.Accent; cache.Tracer.Parent = ScreenGui
            cache.Name.BackgroundTransparency = 1; cache.Name.Font = Hub.Font; cache.Name.TextSize = 11; cache.Name.TextColor3 = Hub.Themes.Text; cache.Name.Parent = ScreenGui
            cache.Chams.FillTransparency = 0.5; cache.Chams.OutlineTransparency = 0
            Hub.Cache[p] = cache
        end

        if not Hub.Config.EspPlayers or not isAlive(p) then
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false; cache.Chams.Parent = nil
            continue
        end

        if Hub.Config.Mm2ShowRoles then
            cache.Chams.Parent = p.Character
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                cache.Chams.FillColor = Color3.fromRGB(255, 45, 45)
                cache.Chams.OutlineColor = Color3.fromRGB(255, 0, 0)
            elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                cache.Chams.FillColor = Color3.fromRGB(45, 45, 255)
                cache.Chams.OutlineColor = Color3.fromRGB(0, 0, 255)
            else
                cache.Chams.FillColor = Color3.fromRGB(45, 255, 45)
                cache.Chams.OutlineColor = Color3.fromRGB(0, 255, 0)
            end
        elseif Hub.Config.EspChams then
            cache.Chams.Parent = p.Character
            cache.Chams.FillColor = Hub.Themes.Main
            cache.Chams.OutlineColor = Hub.Themes.Accent
        else
            cache.Chams.Parent = nil
        end

        local root = p.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)

        if onScreen then
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            local scale = (5 * Camera.ViewportSize.Y) / (2 * dist * math.tan(math.rad(Camera.FieldOfView / 2)))
            local w, h = scale * 0.85, scale * 1.15

            if Hub.Config.EspBoxes then
                cache.Box.Size = UDim2.new(0, w, 0, h)
                cache.Box.Position = UDim2.new(0, screenPos.X - (w / 2), 0, screenPos.Y - (h / 2))
                cache.Box.Visible = true
            else cache.Box.Visible = false end

            if Hub.Config.EspTracers then
                cache.Tracer.Size = UDim2.new(0, math.sqrt((screenPos.X - Camera.ViewportSize.X/2)^2 + (screenPos.Y - Camera.ViewportSize.Y)^2), 0, 1.5)
                cache.Tracer.Position = UDim2.new(0, Camera.ViewportSize.X/2 + (screenPos.X - Camera.ViewportSize.X/2)/2, 0, Camera.ViewportSize.Y + (screenPos.Y - Camera.ViewportSize.Y)/2)
                cache.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                cache.Tracer.Rotation = math.deg(math.atan2(screenPos.Y - Camera.ViewportSize.Y, screenPos.X - Camera.ViewportSize.X/2))
                cache.Tracer.Visible = true
            else cache.Tracer.Visible = false end

            if Hub.Config.EspNames then
                local tag = "[INNOCENT]"
                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then tag = "[MURDER]"
                elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then tag = "[SHERIFF]" end
                
                cache.Name.Text = tag .. " " .. p.Name:upper() .. " • [" .. math.floor(dist) .. "M]"
                cache.Name.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 16)
                cache.Name.Size = UDim2.new(0, 200, 0, 12)
                cache.Name.Visible = true
            else cache.Name.Visible = false end
        else
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false
        end
    end
end)

-- ══════════════════════════════════════════════
--  BOUCLE D'AUTOMATION PHYSIQUE (HEARTBEAT)
-- ══════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not isAlive(player) then return end
    local root = player.Character.HumanoidRootPart
    local hum = player.Character.Humanoid

    if Hub.Config.SpeedEnabled then hum.WalkSpeed = Hub.Config.SpeedValue end
    if Hub.Config.JumpEnabled then hum.JumpPower = Hub.Config.JumpValue end

    if Hub.Config.HitboxExpanded then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and isAlive(p) then
                p.Character.HumanoidRootPart.Size = Vector3.new(Hub.Config.HitboxSize, Hub.Config.HitboxSize, Hub.Config.HitboxSize)
                p.Character.HumanoidRootPart.Transparency = 0.6
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    if Hub.Config.Mm2AutoCollect then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Coin" and obj:IsA("BasePart") then
                obj.CFrame = root.CFrame
            end
        end
    end

    if Hub.Config.Mm2GrabGun then
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop and gunDrop:IsA("BasePart") then
            root.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
        end
    end

    if Hub.Config.SpinBot then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Hub.Config.SpinSpeed), 0) end
    if Hub.Config.FlingAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and isAlive(p) and (p.Character.HumanoidRootPart.Position - root.Position).Magnitude < 12 then
                p.Character.HumanoidRootPart.Velocity = Vector3.new(9999, 9999, 9999)
            end
        end
    end
end)

-- ══════════════════════════════════════════════
--  GESTION DES INPUTS ET ÉVÉNEMENTS
-- ══════════════════════════════════════════════
UIS.InputBegan:Connect(function(i, proc)
    if proc then return end
    if Hub.Config.ClickTeleport and i.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        if isAlive(player) then player.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0)) end
    end
    if Hub.Config.BlinkDashEnabled and i.KeyCode == Enum.KeyCode.X and isAlive(player) then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
    end
end)

UIS.JumpRequest:Connect(function()
    if Hub.Config.InfiniteJump and isAlive(player) then player.Character.Humanoid:ChangeState("Jumping") end
end)

RunService.Stepped:Connect(function()
    if Hub.Config.NoClip and isAlive(player) then
        for _, part in ipairs(player.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end)

-- Initialisation forcée du premier onglet actif
if firstPage then
    Pages[firstPage].Visible = true
    Buttons[firstPage].Btn.TextColor3 = Hub.Themes.Text
    Buttons[firstPage].Btn.BackgroundTransparency = 0.1
    Buttons[firstPage].Btn.BackgroundColor3 = Hub.Themes.Row
    Buttons[firstPage].Ind.BackgroundTransparency = 0
end
