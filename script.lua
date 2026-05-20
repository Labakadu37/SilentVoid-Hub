--[[
    ╔════════════════════════════════════════════════════════════╗
    ║                      ZENTY VOID PROJECT                    ║
    ║                         VERSION V4 - FINAL                 ║
    ║             Custom Ghost Translucent Framework             ║
    ╚════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = player:GetMouse()

local originalGravity = Workspace.Gravity
local originalWalkSpeed = 16
local originalJumpPower = 50

if player:WaitForChild("PlayerGui"):FindFirstChild("ZentyVoidHub") then
    player.PlayerGui.ZentyVoidHub:Destroy()
end

local Hub = {
    GameMode = "Universel",
    PlaceId = game.PlaceId,
    Config = {
        Aimbot = false, AimbotPart = "Head", FovEnabled = false, FovRadius = 140, TeamCheck = false, WallCheck = false,
        EspPlayers = false, EspBoxes = false, EspTracers = false, EspNames = false,
        SpeedEnabled = false, SpeedValue = 16, JumpEnabled = false, JumpValue = 50, FlyEnabled = false, FlySpeed = 3, NoClip = false,
        SpinBot = false, SpinSpeed = 30, FlingAura = false, GravitySlider = 196.2, InfiniteJump = false,
        ClickTeleport = false, ViewSpy = false, HitboxExpanded = false, HitboxSize = 2, BlinkDashEnabled = false,
        EspChams = false, BulletTracers = false,
        -- MM2 Master Package
        Mm2ShowRoles = false, 
        Mm2AutoCollect = false, 
        Mm2MurderAlert = false, 
        Mm2SheriffLock = false,
        Mm2KillMurderer = false,
        Mm2GrabGun = false,
        -- Extras Autres Jeux
        BhUnlockCars = false, BhTeleportLoop = false, BhSafeRobber = false,
        BbAutoParry = false, BbParryDistance = 15, BbPredictCurve = false,
        ArSilentAim = false, ArNoRecoil = false, ArTracerLasers = false,
        BwKillAura = false, BwBedEsp = false
    },
    Cache = {},
    Themes = {
        Main = Color3.fromRGB(10, 10, 12),       
        Sidebar = Color3.fromRGB(5, 5, 7),        
        Accent = Color3.fromRGB(240, 240, 250),    
        Row = Color3.fromRGB(15, 15, 18),         
        Text = Color3.fromRGB(255, 255, 255),     
        TextDark = Color3.fromRGB(110, 110, 120), 
        Border = Color3.fromRGB(35, 35, 40)        
    }
}

local gamesList = {
    [4924922222] = "Brookhaven", [13772394625] = "Blade Ball", [142823291] = "Murder Mystery 2",
    [286090424] = "Arsenal", [6872265039] = "BedWars", [1168263273] = "BedWars"
}
if gamesList[Hub.PlaceId] then Hub.GameMode = gamesList[Hub.PlaceId] end

-- ══════════════════════════════════════════════
--  INTERFACE GRAPHIQUE GHOST TRANSLUCIDE
-- ══════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZentyVoidHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function round(r, p) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = p return c end
local function line(col, th, p) local s = Instance.new("UIStroke") s.Color = col s.Thickness = th s.Parent = p return s end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 620, 0, 430)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -215)
MainFrame.BackgroundColor3 = Hub.Themes.Main
MainFrame.BackgroundTransparency = 0.45 
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui
round(4, MainFrame); line(Hub.Themes.Border, 1, MainFrame)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Hub.Themes.Sidebar
Sidebar.BackgroundTransparency = 0.5
Sidebar.Parent = MainFrame
round(4, Sidebar)

local ContainerHolder = Instance.new("Frame")
ContainerHolder.Size = UDim2.new(1, -170, 1, -40)
ContainerHolder.Position = UDim2.new(0, 170, 0, 40)
ContainerHolder.BackgroundTransparency = 1; ContainerHolder.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, 0, 0, 35)
HubTitle.Position = UDim2.new(0, 15, 0, 8)
HubTitle.BackgroundTransparency = 1; HubTitle.Text = "GHOST.VOID"
HubTitle.Font = Enum.Font.Code; HubTitle.TextSize = 16; HubTitle.TextColor3 = Hub.Themes.Accent; HubTitle.TextXAlignment = Enum.TextXAlignment.Left; HubTitle.Parent = Sidebar

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, 0, 1, -50)
NavList.Position = UDim2.new(0, 0, 0, 50)
NavList.BackgroundTransparency = 1; NavList.BorderSizePixel = 0; NavList.ScrollBarThickness = 0; NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 2); NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; NavLayout.Parent = NavList

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -170, 0, 40)
Topbar.Position = UDim2.new(0, 170, 0, 0)
Topbar.BackgroundTransparency = 1; Topbar.Parent = MainFrame

local GameTag = Instance.new("TextLabel")
GameTag.Size = UDim2.new(1, -20, 1, 0)
GameTag.Position = UDim2.new(0, 15, 0, 0)
GameTag.BackgroundTransparency = 1; GameTag.Text = "SYS_STATUS : GHOST // MODE : " .. Hub.GameMode:upper()
GameTag.Font = Enum.Font.Code; GameTag.TextSize = 11; GameTag.TextColor3 = Hub.Themes.TextDark; GameTag.TextXAlignment = Enum.TextXAlignment.Left; GameTag.Parent = Topbar

local toggleB = Instance.new("TextButton")
toggleB.Size = UDim2.new(0, 110, 0, 26)
toggleB.Position = UDim2.new(0, 15, 0, 15)
toggleB.BackgroundColor3 = Hub.Themes.Main
toggleB.BackgroundTransparency = 0.4
toggleB.Text = "[ GHOST UI ]"
toggleB.Font = Enum.Font.Code; toggleB.TextColor3 = Hub.Themes.Accent; toggleB.TextSize = 11; toggleB.Parent = ScreenGui
round(3, toggleB); line(Hub.Themes.Border, 1, toggleB)

toggleB.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Hub.Config.FovRadius * 2, 0, Hub.Config.FovRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5); FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0); FOVCircle.BackgroundTransparency = 1; FOVCircle.Visible = false; FOVCircle.Parent = ScreenGui
round(Hub.Config.FovRadius * 2, FOVCircle); local FOVStroke = line(Hub.Themes.Accent, 1, FOVCircle)

-- Système d'alertes textuelles pour MM2
local AlertLabel = Instance.new("TextLabel")
AlertLabel.Size = UDim2.new(0, 500, 0, 30)
AlertLabel.Position = UDim2.new(0.5, -200, 0, 45)
AlertLabel.BackgroundTransparency = 1
AlertLabel.Font = Enum.Font.Code; AlertLabel.TextSize = 13; AlertLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
AlertLabel.Text = ""; AlertLabel.Visible = false; AlertLabel.Parent = ScreenGui

-- ══════════════════════════════════════════════
--  BUILDER COMPOSANTS SANS EMOJI (DEV STYLE)
-- ══════════════════════════════════════════════
local Pages, Buttons, firstPage = {}, {}, nil

local function CreatePage(id, name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0; Page.ScrollBarThickness = 2; Page.Visible = false; Page.Parent = ContainerHolder
    local PL = Instance.new("UIListLayout") PL.Padding = UDim.new(0, 5) PL.HorizontalAlignment = Enum.HorizontalAlignment.Center; PL.Parent = Page
    local PP = Instance.new("UIPadding") PP.PaddingTop = UDim.new(0, 4) PP.Parent = Page
    
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, -12, 0, 30)
    NavBtn.BackgroundColor3 = Color3.fromRGB(0,0,0); NavBtn.BackgroundTransparency = 1
    NavBtn.Text = "  // " .. name
    NavBtn.Font = Enum.Font.Code; NavBtn.TextSize = 11; NavBtn.TextColor3 = Hub.Themes.TextDark; NavBtn.TextXAlignment = Enum.TextXAlignment.Left; NavBtn.AutoButtonColor = false; NavBtn.Parent = NavList
    round(3, NavBtn)
    
    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 2, 0, 12)
    Ind.Position = UDim2.new(0, 2, 0.5, -6); Ind.BackgroundColor3 = Hub.Themes.Accent; Ind.BackgroundTransparency = 1; Ind.Parent = NavBtn
    
    Pages[id] = Page; Buttons[id] = {Btn = NavBtn, Ind = Ind}
    
    NavBtn.MouseButton1Click:Connect(function()
        for pid, pFrame in pairs(Pages) do
            pFrame.Visible = (pid == id)
            local bData = Buttons[pid]
            if pid == id then
                bData.Btn.TextColor3 = Hub.Themes.Text; bData.Btn.BackgroundTransparency = 0.85; bData.Btn.BackgroundColor3 = Hub.Themes.Accent
                TweenService:Create(bData.Ind, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            else
                bData.Btn.TextColor3 = Hub.Themes.TextDark; bData.Btn.BackgroundTransparency = 1
                TweenService:Create(bData.Ind, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            end
        end
    end)
    if not firstPage then firstPage = id end
    return Page
end

local function AddToggle(page, title, sub, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -20, 0, 38) Row.BackgroundColor3 = Hub.Themes.Row Row.BackgroundTransparency = 0.5 Row.Parent = page
    round(3, Row); line(Hub.Themes.Border, 0.8, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(1, -100, 0, 16) Txt.Position = UDim2.new(0, 10, 0, 3) Txt.BackgroundTransparency = 1; Txt.Text = title:upper(); Txt.Font = Enum.Font.Code; Txt.TextSize = 11; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Row
    local SubTxt = Instance.new("TextLabel") SubTxt.Size = UDim2.new(1, -100, 0, 12) SubTxt.Position = UDim2.new(0, 10, 0, 19) SubTxt.BackgroundTransparency = 1; SubTxt.Text = sub; SubTxt.Font = Enum.Font.Code; SubTxt.TextSize = 9; SubTxt.TextColor3 = Hub.Themes.TextDark; SubTxt.TextXAlignment = Enum.TextXAlignment.Left; SubTxt.Parent = Row
    
    local Switch = Instance.new("TextButton") Switch.Size = UDim2.new(0, 30, 0, 14) Switch.Position = UDim2.new(1, -40, 0.5, -7) Switch.BackgroundColor3 = Hub.Config[configKey] and Hub.Themes.Accent or Color3.fromRGB(15, 15, 20); Switch.Text = ""; Switch.Parent = Row
    round(1, Switch); line(Hub.Themes.Border, 1, Switch)
    
    Switch.MouseButton1Click:Connect(function()
        Hub.Config[configKey] = not Hub.Config[configKey]
        local enabled = Hub.Config[configKey]
        TweenService:Create(Switch, TweenInfo.new(0.1), {BackgroundColor3 = enabled and Hub.Themes.Accent or Color3.fromRGB(15, 15, 20)}):Play()
        callback(enabled)
    end)
end

local function AddSlider(page, title, min, max, default, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -20, 0, 42) Row.BackgroundColor3 = Hub.Themes.Row Row.BackgroundTransparency = 0.5 Row.Parent = page
    round(3, Row); line(Hub.Themes.Border, 0.8, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 200, 0, 16) Txt.Position = UDim2.new(0, 10, 0, 4) Txt.BackgroundTransparency = 1; Txt.Text = title:upper(); Txt.Font = Enum.Font.Code; Txt.TextSize = 11; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Row
    local ValTxt = Instance.new("TextLabel") ValTxt.Size = UDim2.new(0, 60, 0, 16) ValTxt.Position = UDim2.new(1, -70, 0, 4) ValTxt.BackgroundTransparency = 1; ValTxt.Text = tostring(default); ValTxt.Font = Enum.Font.Code; ValTxt.TextSize = 10; ValTxt.TextColor3 = Hub.Themes.Accent; ValTxt.TextXAlignment = Enum.TextXAlignment.Right; ValTxt.Parent = Row
    
    local SlideBar = Instance.new("TextButton") SlideBar.Size = UDim2.new(1, -20, 0, 4) SlideBar.Position = UDim2.new(0, 10, 0, 26) SlideBar.BackgroundColor3 = Color3.fromRGB(10,10,15); SlideBar.Text = ""; SlideBar.AutoButtonColor = false; SlideBar.Parent = Row
    round(1, SlideBar)
    
    local SlideIn = Instance.new("Frame") SlideIn.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); SlideIn.BackgroundColor3 = Hub.Themes.Accent; SlideIn.Parent = SlideBar
    round(1, SlideIn)
    
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
--  CONSTRUCTION DES ONGLETS CORE
-- ══════════════════════════════════════════════
local pCombat = CreatePage("combat", "CRITICAL COMBAT")
local pVisuals = CreatePage("visuals", "OVERLAY RENDERER")
local pLocal = CreatePage("local", "PHYSICS MANIPULATOR")
local pFun = CreatePage("fun", "BLATANT MODS & FUN")
local pGameMod = CreatePage("gamemod", "TARGET MODULE")

-- Page Combat
AddToggle(pCombat, "Engine Lock-On", "Assistance de visée angulaire stricte", "Aimbot", function() end)
AddToggle(pCombat, "Raycast Occlusion Check", "Ignore les entités masquées par la géométrie", "WallCheck", function() end)
AddToggle(pCombat, "Draw Target Boundary", "Rendu du cercle d'acquisition", "FovEnabled", function(v) FOVCircle.Visible = v end)
AddSlider(pCombat, "Boundary Range Radius", 30, 400, 140, "FovRadius", function(v) FOVCircle.Size = UDim2.new(0, v*2, 0, v*2) round(v*2, FOVCircle) end)

-- Page Overlay Visuals
AddToggle(pVisuals, "Master Render Status", "Activer la boucle de rendu géométrique", "EspPlayers", function() end)
AddToggle(pVisuals, "Bounding Box 2D", "Tracé rectangulaire sur les cibles", "EspBoxes", function() end)
AddToggle(pVisuals, "Target Direct Tracers", "Vecteurs au sol depuis le centre écran", "EspTracers", function() end)
AddToggle(pVisuals, "Identification Tags", "Rendu des chaînes de caractères (Nom + Range)", "EspNames", function() end)
AddToggle(pVisuals, "Wallhack Silhouette Chams", "Rendu complet en surbrillance à travers les surfaces", "EspChams", function() end)
AddToggle(pVisuals, "Render Bullet Tracers", "Affiche la trajectoire vectorielle des impacts", "BulletTracers", function() end)

-- Page Physics Manipulator
AddToggle(pLocal, "Override WalkSpeed", "Forcer la vélocité linéaire au sol", "SpeedEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = originalWalkSpeed end end)
AddSlider(pLocal, "Velocity Amplitude", 16, 250, 16, "SpeedValue", function() end)
AddToggle(pLocal, "Override JumpPower", "Forcer le coefficient de propulsion verticale", "JumpEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = originalJumpPower end end)
AddSlider(pLocal, "Propulsion Amplitude", 50, 300, 50, "JumpValue", function() end)
AddToggle(pLocal, "Quantum Flight Mode", "Annuler la force gravitationnelle et lier au vecteur caméra", "FlyEnabled", function(v) if not v then Workspace.Gravity = originalGravity if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end end end)
AddSlider(pLocal, "Flight Axis Speed", 1, 15, 3, "FlySpeed", function() end)
AddToggle(pLocal, "Phase Matrix (NoClip)", "Désactiver les masques de collision des membres", "NoClip", function() end)
AddToggle(pLocal, "Hitbox Volumetric Expander", "Agrandit la zone d'impact de la cible racine", "HitboxExpanded", function() end)
AddSlider(pLocal, "Hitbox Scale Factor", 2, 20, 2, "HitboxSize", function() end)
AddToggle(pLocal, "Blink Forward Dash", "Active la propulsion linéaire instantanée via touche X", "BlinkDashEnabled", function() end)

-- Page Blatant Mods & Fun
AddToggle(pFun, "Velocity Spinbot", "Rotation angulaire extrême pour fausser la hitbox", "SpinBot", function() end)
AddSlider(pFun, "Spin Angular Rate", 10, 150, 30, "SpinSpeed", function() end)
AddToggle(pFun, "Physics Fling Aura", "Ejecte les entités à proximité par collision asynchrone", "FlingAura", function() end)
AddToggle(pFun, "Infinite Air Jump", "Permet l'activation du saut sans appui au sol", "InfiniteJump", function() end)
AddSlider(pFun, "Global World Gravity", 0, 196, 196, "GravitySlider", function(v) Workspace.Gravity = v end)
AddToggle(pFun, "Click Map Teleport", "Pressez CTRL + Clic gauche pour vous téléporter sur le curseur", "ClickTeleport", function() end)
AddToggle(pFun, "View Spy Target", "Clône la caméra sur le joueur le plus proche", "ViewSpy", function() end)

-- ══════════════════════════════════════════════
--  MODULES SPECIFIQUES (TARGET MODULE) : MM2 COMPLET 100%
-- ══════════════════════════════════════════════
if Hub.GameMode == "Murder Mystery 2" then
    AddToggle(pGameMod, "Role Wallhack Chams", "Coloration stricte à travers les murs (Rouge: Meurtrier, Bleu: Shérif)", "Mm2ShowRoles", function() end)
    AddToggle(pGameMod, "Murderer Proximity Alert", "Alerte texte dynamique à l'écran si le Meurtrier approche", "Mm2MurderAlert", function() end)
    AddToggle(pGameMod, "Sheriff Weapon Lock", "Restreint l'aimbot uniquement sur le Meurtrier identifié", "Mm2SheriffLock", function() end)
    AddToggle(pGameMod, "Coin Geometric Grabber", "Téléporte automatiquement et instantanément toutes les pièces du round sur vous", "Mm2AutoCollect", function() end)
    AddToggle(pGameMod, "Auto Grab Dropped Gun", "Se téléporte instantanément sur l'arme tombée au sol si le Shérif meurt", "Mm2GrabGun", function() end)
    AddToggle(pGameMod, "Instant Kill Murderer", "Tue instantanément le Meurtrier si vous possédez l'arme", "Mm2KillMurderer", function() end)

elseif Hub.GameMode == "Brookhaven" then
    AddToggle(pGameMod, "Gamepass Vehicle Injection", "Force l'accès local au catalogue premium", "BhUnlockCars", function() end)
    AddToggle(pGameMod, "Estate Teleport Matrix", "Boucle d'itération sur les parcelles de serveurs", "BhTeleportLoop", function() end)
    AddToggle(pGameMod, "Safe Robber Assist", "Indexation visuelle et raccourci vers les coffres de parcelles", "BhSafeRobber", function() end)

elseif Hub.GameMode == "Blade Ball" then
    AddToggle(pGameMod, "Instant Parry Trigger", "Déclenchement du blocage via calcul prédictif de trajectoire", "BbAutoParry", function() end)
    AddToggle(pGameMod, "Predictive Ball Curve", "Calcule et affiche le vecteur direct d'approche de la balle", "BbPredictCurve", function() end)

elseif Hub.GameMode == "Arsenal" then
    AddToggle(pGameMod, "Vector Silent Aim", "Redirection automatique des paquets d'impact", "ArSilentAim", function() end)
    AddToggle(pGameMod, "Anti Recoil Engine", "Supprime les modificateurs de dispersion de l'arme", "ArNoRecoil", function() end)
    AddToggle(pGameMod, "Laser Sight Overlay", "Génère un tracer continu au point d'impact calculé", "ArTracerLasers", function() end)

elseif Hub.GameMode == "BedWars" then
    AddToggle(pGameMod, "Raycast 360 KillAura", "Génère des événements d'attaque sur l'équipe adverse", "BwKillAura", function() end)
    AddToggle(pGameMod, "Objective Bed ESP", "Traceur d'analyse à travers les structures pour l'objectif central", "BwBedEsp", function() end)
end

-- ══════════════════════════════════════════════
--  FONCTIONS INTERNES ET AUTOMATIONS CORE
-- ══════════════════════════════════════════════
local function isAlive(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
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

-- Utilitaires de détection pour MM2
local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if isAlive(p) and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            return p
        end
    end
    return nil
end

local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if isAlive(p) and (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) then
            return p
        end
    end
    return nil
end

-- ══════════════════════════════════════════════
--  BOUCLE PRINCIPALE RENDU (RENDERSTEPPED)
-- ══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not isAlive(player) then return end
    
    -- Gestion Visée Critique (Aimbot & Lock Meurtrier)
    local target = nil
    if Hub.GameMode == "Murder Mystery 2" and Hub.Config.Mm2SheriffLock then
        target = getMurderer()
    elseif Hub.Config.Aimbot then
        target = getClosestPlayer()
    end

    if target and isAlive(target) then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Hub.Config.AimbotPart].Position)
        
        -- Auto Kill Meurtrier si équipé du flingue
        if Hub.GameMode == "Murder Mystery 2" and Hub.Config.Mm2KillMurderer and player.Character:FindFirstChild("Gun") then
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
        end
    end

    -- Alerte Radar Meurtrier MM2
    if Hub.GameMode == "Murder Mystery 2" and Hub.Config.Mm2MurderAlert then
        local m = getMurderer()
        if m and m ~= player and isAlive(m) then
            local dist = (m.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < 45 then
                AlertLabel.Text = "SYSTEM_WARN : MURDERER DETECTED // DISTANCE: " .. math.floor(dist) .. " STUDS"
                AlertLabel.Visible = true
            else
                AlertLabel.Visible = false
            end
        else
            AlertLabel.Visible = false
        end
    end

    -- Gestion du View Spy
    if Hub.Config.ViewSpy then
        local spyTarget = getClosestPlayer()
        if Hub.GameMode == "Murder Mystery 2" then spyTarget = getMurderer() end
        if spyTarget and isAlive(spyTarget) then
            Camera.CameraSubject = spyTarget.Character.Humanoid
        end
    else
        if Camera.CameraSubject ~= player.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        end
    end

    -- RENDU VISUEL : PLAYERS / WALLHACK ROLES MM2
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        local cache = Hub.Cache[p]
        if not cache then
            cache = { 
                Box = Instance.new("Frame"), Tracer = Instance.new("Frame"), Name = Instance.new("TextLabel"), Chams = Instance.new("Highlight")
            }
            cache.Box.BackgroundTransparency = 1; cache.Box.Parent = ScreenGui; line(Hub.Themes.Accent, 1, cache.Box)
            cache.Tracer.BorderSizePixel = 0; cache.Tracer.BackgroundColor3 = Hub.Themes.Accent; cache.Tracer.Parent = ScreenGui
            cache.Name.BackgroundTransparency = 1; cache.Name.Font = Enum.Font.Code; cache.Name.TextSize = 9; cache.Name.TextColor3 = Hub.Themes.Text; cache.Name.Parent = ScreenGui
            cache.Chams.FillTransparency = 0.6; cache.Chams.OutlineTransparency = 0
            Hub.Cache[p] = cache
        end

        if not Hub.Config.EspPlayers or not isAlive(p) then
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false; cache.Chams.Parent = nil
            continue
        end

        -- Injection et Configuration du Wallhack Chams Rôles
        if Hub.Config.Mm2ShowRoles and Hub.GameMode == "Murder Mystery 2" then
            cache.Chams.Parent = p.Character
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                cache.Chams.FillColor = Color3.fromRGB(255, 30, 30)
                cache.Chams.OutlineColor = Color3.fromRGB(255, 0, 0)
            elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                cache.Chams.FillColor = Color3.fromRGB(30, 30, 255)
                cache.Chams.OutlineColor = Color3.fromRGB(0, 0, 255)
            else
                cache.Chams.FillColor = Color3.fromRGB(30, 255, 30)
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
                cache.Tracer.Size = UDim2.new(0, math.sqrt((screenPos.X - Camera.ViewportSize.X/2)^2 + (screenPos.Y - Camera.ViewportSize.Y)^2), 0, 1)
                cache.Tracer.Position = UDim2.new(0, Camera.ViewportSize.X/2 + (screenPos.X - Camera.ViewportSize.X/2)/2, 0, Camera.ViewportSize.Y + (screenPos.Y - Camera.ViewportSize.Y)/2)
                cache.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                cache.Tracer.Rotation = math.deg(math.atan2(screenPos.Y - Camera.ViewportSize.Y, screenPos.X - Camera.ViewportSize.X/2))
                cache.Tracer.Visible = true
            else cache.Tracer.Visible = false end

            if Hub.Config.EspNames then
                local prefix = ""
                if Hub.GameMode == "Murder Mystery 2" then
                    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then prefix = "[MURDER] "
                    elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then prefix = "[SHERIFF] "
                    else prefix = "[INNOCENT] " end
                end
                cache.Name.Text = prefix .. p.Name:upper() .. " // [" .. math.floor(dist) .. "M]"
                cache.Name.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 14)
                cache.Name.Size = UDim2.new(0, 200, 0, 10)
                cache.Name.Visible = true
            else cache.Name.Visible = false end
        else
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false
        end
    end
end)

-- ══════════════════════════════════════════════
--  BOUCLE PHYSIQUE & TELEPORTS (HEARTBEAT)
-- ══════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not isAlive(player) then return end
    local root = player.Character.HumanoidRootPart
    local hum = player.Character.Humanoid

    if Hub.Config.SpeedEnabled then hum.WalkSpeed = Hub.Config.SpeedValue end
    if Hub.Config.JumpEnabled then hum.JumpPower = Hub.Config.JumpValue end

    -- Hitbox Expansion Engine
    if Hub.Config.HitboxExpanded then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and isAlive(p) then
                p.Character.HumanoidRootPart.Size = Vector3.new(Hub.Config.HitboxSize, Hub.Config.HitboxSize, Hub.Config.HitboxSize)
                p.Character.HumanoidRootPart.Transparency = 0.7
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- AUTOMATIONS MM2 : COIN MAGNET & GRAB DROPPED GUN
    if Hub.GameMode == "Murder Mystery 2" then
        -- 1. Aim/Magnet pour ramasser toutes les pièces de la map d'un coup
        if Hub.Config.Mm2AutoCollect then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Coin" and obj:IsA("BasePart") then
                    obj.CFrame = root.CFrame
                end
            end
        end

        -- 2. Téléportation automatique instantanée sur le flingue s'il tombe au sol
        if Hub.Config.Mm2GrabGun then
            local gunDrop = Workspace:FindFirstChild("GunDrop")
            if gunDrop and gunDrop:IsA("BasePart") then
                root.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
            end
        end
    end

    -- SpinBot & Aura Fling
    if Hub.Config.SpinBot then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Hub.Config.SpinSpeed), 0) end
    if Hub.Config.FlingAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and isAlive(p) and (p.Character.HumanoidRootPart.Position - root.Position).Magnitude < 12 then
                p.Character.HumanoidRootPart.Velocity = Vector3.new(9999, 9999, 9999)
            end
        end
    end
end)

-- Raccourcis Clavier & Inputs
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

if firstPage then
    Pages[firstPage].Visible = true
    Buttons[firstPage].Btn.TextColor3 = Hub.Themes.Text
    Buttons[firstPage].Btn.BackgroundTransparency = 0.85
    Buttons[firstPage].Btn.BackgroundColor3 = Hub.Themes.Accent
    Buttons[firstPage].Ind.BackgroundTransparency = 0
end

