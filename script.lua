--[[
    ╔════════════════════════════════════════════════════════════╗
    ║                      ZENTY VOID PROJECT                    ║
    ║                         VERSION V2                         ║
    ║        Custom Translucent & Hyper-Blatant Framework        ║
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
        -- Fun & Blatant Features
        SpinBot = false, SpinSpeed = 30, FlingAura = false, GravitySlider = 196.2, InfiniteJump = false,
        CarFly = false, ClickTeleport = false, ViewSpy = false, NakedAvatars = false,
        -- Game Specifics
        BhUnlockCars = false, BhTeleportLoop = false,
        BbAutoParry = false, BbParryDistance = 15,
        Mm2ShowRoles = false, Mm2AutoCollect = false,
        ArSilentAim = false, ArNoRecoil = false,
        BwKillAura = false
    },
    Cache = {},
        Themes = {
        Main = Color3.fromRGB(10, 10, 12),       -- Base noire
        Sidebar = Color3.fromRGB(5, 5, 7),        -- Sidebar plus sombre
        Accent = Color3.fromRGB(240, 240, 250),    -- Blanc fantôme épuré pour la sélection
        Row = Color3.fromRGB(15, 15, 18),         -- Lignes de menu très discrètes
        Text = Color3.fromRGB(255, 255, 255),     -- Texte principal blanc clair
        TextDark = Color3.fromRGB(100, 100, 110), -- Texte secondaire grisé (effet estompé)
        Border = Color3.fromRGB(35, 35, 40)        -- Bordures très fines et sombres
    }


local gamesList = {
    [4924922222] = "Brookhaven", [13772394625] = "Blade Ball", [142823291] = "Murder Mystery 2",
    [286090424] = "Arsenal", [6872265039] = "BedWars", [1168263273] = "BedWars"
}
if gamesList[Hub.PlaceId] then Hub.GameMode = gamesList[Hub.PlaceId] end

-- ══════════════════════════════════════════════
--  INTERFACE GRAPHIQUE TRANSLUCIDE (STYLE ZENTY)
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
MainFrame.BackgroundTransparency = 0.25 -- Fond transparent demandé
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui
round(6, MainFrame); line(Hub.Themes.Border, 1.4, MainFrame)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Hub.Themes.Sidebar
Sidebar.BackgroundTransparency = 0.3
Sidebar.Parent = MainFrame
round(6, Sidebar)

local ContainerHolder = Instance.new("Frame")
ContainerHolder.Size = UDim2.new(1, -170, 1, -40)
ContainerHolder.Position = UDim2.new(0, 170, 0, 40)
ContainerHolder.BackgroundTransparency = 1; ContainerHolder.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, 0, 0, 35)
HubTitle.Position = UDim2.new(0, 15, 0, 8)
HubTitle.BackgroundTransparency = 1; HubTitle.Text = "ZENTY.VOID"
HubTitle.Font = Enum.Font.Code; HubTitle.TextSize = 18; HubTitle.TextColor3 = Hub.Themes.Accent; HubTitle.TextXAlignment = Enum.TextXAlignment.Left; HubTitle.Parent = Sidebar

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
GameTag.BackgroundTransparency = 1; GameTag.Text = "SYS_STATUS : ACTIVE // MODE : " .. Hub.GameMode:upper()
GameTag.Font = Enum.Font.Code; GameTag.TextSize = 11; GameTag.TextColor3 = Hub.Themes.TextDark; GameTag.TextXAlignment = Enum.TextXAlignment.Left; GameTag.Parent = Topbar

local toggleB = Instance.new("TextButton")
toggleB.Size = UDim2.new(0, 100, 0, 28)
toggleB.Position = UDim2.new(0, 15, 0, 15)
toggleB.BackgroundColor3 = Hub.Themes.Main
toggleB.BackgroundTransparency = 0.2
toggleB.Text = "[ ZENTY UI ]"
toggleB.Font = Enum.Font.Code; toggleB.TextColor3 = Hub.Themes.Accent; toggleB.TextSize = 12; toggleB.Parent = ScreenGui
round(4, toggleB); line(Hub.Themes.Border, 1, toggleB)

toggleB.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Hub.Config.FovRadius * 2, 0, Hub.Config.FovRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5); FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0); FOVCircle.BackgroundTransparency = 1; FOVCircle.Visible = false; FOVCircle.Parent = ScreenGui
round(Hub.Config.FovRadius * 2, FOVCircle); local FOVStroke = line(Hub.Themes.Accent, 1, FOVCircle)

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
    round(4, NavBtn)
    
    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 2, 0, 12)
    Ind.Position = UDim2.new(0, 2, 0.5, -6); Ind.BackgroundColor3 = Hub.Themes.Accent; Ind.BackgroundTransparency = 1; Ind.Parent = NavBtn
    
    Pages[id] = Page; Buttons[id] = {Btn = NavBtn, Ind = Ind}
    
    NavBtn.MouseButton1Click:Connect(function()
        for pid, pFrame in pairs(Pages) do
            pFrame.Visible = (pid == id)
            local bData = Buttons[pid]
            if pid == id then
                bData.Btn.TextColor3 = Hub.Themes.Text; bData.Btn.BackgroundTransparency = 0.8; bData.Btn.BackgroundColor3 = Hub.Themes.Accent
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
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -20, 0, 38) Row.BackgroundColor3 = Hub.Themes.Row Row.BackgroundTransparency = 0.4 Row.Parent = page
    round(4, Row); line(Hub.Themes.Border, 0.8, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(1, -100, 0, 16) Txt.Position = UDim2.new(0, 10, 0, 3) Txt.BackgroundTransparency = 1; Txt.Text = title:upper(); Txt.Font = Enum.Font.Code; Txt.TextSize = 11; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Row
    local SubTxt = Instance.new("TextLabel") SubTxt.Size = UDim2.new(1, -100, 0, 12) SubTxt.Position = UDim2.new(0, 10, 0, 19) SubTxt.BackgroundTransparency = 1; SubTxt.Text = sub; SubTxt.Font = Enum.Font.Code; SubTxt.TextSize = 9; SubTxt.TextColor3 = Hub.Themes.TextDark; SubTxt.TextXAlignment = Enum.TextXAlignment.Left; SubTxt.Parent = Row
    
    local Switch = Instance.new("TextButton") Switch.Size = UDim2.new(0, 30, 0, 14) Switch.Position = UDim2.new(1, -40, 0.5, -7) Switch.BackgroundColor3 = Hub.Config[configKey] and Hub.Themes.Accent or Color3.fromRGB(20, 20, 30); Switch.Text = ""; Switch.Parent = Row
    round(2, Switch); line(Hub.Themes.Border, 1, Switch)
    
    Switch.MouseButton1Click:Connect(function()
        Hub.Config[configKey] = not Hub.Config[configKey]
        local enabled = Hub.Config[configKey]
        TweenService:Create(Switch, TweenInfo.new(0.1), {BackgroundColor3 = enabled and Hub.Themes.Accent or Color3.fromRGB(20, 20, 30)}):Play()
        callback(enabled)
    end)
end

local function AddSlider(page, title, min, max, default, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -20, 0, 42) Row.BackgroundColor3 = Hub.Themes.Row Row.BackgroundTransparency = 0.4 Row.Parent = page
    round(4, Row); line(Hub.Themes.Border, 0.8, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 200, 0, 16) Txt.Position = UDim2.new(0, 10, 0, 4) Txt.BackgroundTransparency = 1; Txt.Text = title:upper(); Txt.Font = Enum.Font.Code; Txt.TextSize = 11; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Row
    local ValTxt = Instance.new("TextLabel") ValTxt.Size = UDim2.new(0, 60, 0, 16) ValTxt.Position = UDim2.new(1, -70, 0, 4) ValTxt.BackgroundTransparency = 1; ValTxt.Text = tostring(default); ValTxt.Font = Enum.Font.Code; ValTxt.TextSize = 10; ValTxt.TextColor3 = Hub.Themes.Accent; ValTxt.TextXAlignment = Enum.TextXAlignment.Right; ValTxt.Parent = Row
    
    local SlideBar = Instance.new("TextButton") SlideBar.Size = UDim2.new(1, -20, 0, 4) SlideBar.Position = UDim2.new(0, 10, 0, 26) SlideBar.BackgroundColor3 = Color3.fromRGB(15,15,25); SlideBar.Text = ""; SlideBar.AutoButtonColor = false; SlideBar.Parent = Row
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
--  STRUCTURE DES PAGES DE MENUS (MASSIVE CONFIG)
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

-- Page Physics Manipulator
AddToggle(pLocal, "Override WalkSpeed", "Forcer la vélocité linéaire au sol", "SpeedEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = originalWalkSpeed end end)
AddSlider(pLocal, "Velocity Amplitude", 16, 250, 16, "SpeedValue", function() end)
AddToggle(pLocal, "Override JumpPower", "Forcer le coefficient de propulsion verticale", "JumpEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = originalJumpPower end end)
AddSlider(pLocal, "Propulsion Amplitude", 50, 300, 50, "JumpValue", function() end)
AddToggle(pLocal, "Quantum Flight Mode", "Annuler la force gravitationnelle et lier au vecteur caméra", "FlyEnabled", function(v) if not v then Workspace.Gravity = originalGravity if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end end end)
AddSlider(pLocal, "Flight Axis Speed", 1, 15, 3, "FlySpeed", function() end)
AddToggle(pLocal, "Phase Matrix (NoClip)", "Désactiver les masques de collision des membres", "NoClip", function() end)

-- ══════════════════════════════════════════════
--  SECTION MASSIVE : BLATANT MODS & FUN
-- ══════════════════════════════════════════════
AddToggle(pFun, "Velocity Spinbot", "Rotation angulaire extrême pour fausser la hitbox", "SpinBot", function() end)
AddSlider(pFun, "Spin Angular Rate", 10, 150, 30, "SpinSpeed", function() end)
AddToggle(pFun, "Physics Fling Aura", "Ejecte les entités à proximité par collision asynchrone", "FlingAura", function() end)
AddToggle(pFun, "Infinite Air Jump", "Permet l'activation du saut sans appui au sol", "InfiniteJump", function() end)
AddSlider(pFun, "Global World Gravity", 0, 196, 196, "GravitySlider", function(v) Workspace.Gravity = v end)
AddToggle(pFun, "Click Map Teleport", "Pressez CTRL + Clic gauche pour vous téléporter sur le curseur", "ClickTeleport", function() end)
AddToggle(pFun, "View Spy Target", "Clône la caméra sur le joueur le plus proche", "ViewSpy", function() end)

-- Gestionnaire Click Teleport
UIS.InputBegan:Connect(function(input, processed)
    if not processed and Hub.Config.ClickTeleport and input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = Mouse.Hit.p
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end
end)

-- Gestionnaire Infinite Jump
UIS.JumpRequest:Connect(function()
    if Hub.Config.InfiniteJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ══════════════════════════════════════════════
--  MODULES SPECIFIQUES AUX JEUX (TARGET MODULE)
-- ══════════════════════════════════════════════
if Hub.GameMode == "Brookhaven" then
    AddToggle(pGameMod, "Gamepass Vehicle Injection", "Force l'accès local au catalogue premium", "BhUnlockCars", function() end)
    AddToggle(pGameMod, "Estate Teleport Matrix", "Boucle d'itération sur les parcelles de serveurs", "BhTeleportLoop", function() end)
elseif Hub.GameMode == "Blade Ball" then
    AddToggle(pGameMod, "Instant Parry Trigger", "Déclenchement du blocage via calcul prédictif de trajectoire", "BbAutoParry", function() end)
elseif Hub.GameMode == "Murder Mystery 2" then
    AddToggle(pGameMod, "Role Analyzer ESP", "Structure visuelle dédiée à l'inventaire des cibles", "Mm2ShowRoles", function() end)
    AddToggle(pGameMod, "Coin Geometric Grabber", "Visualise et indexe les coordonnées des collectables", "Mm2AutoCollect", function() end)
elseif Hub.GameMode == "Arsenal" then
    AddToggle(pGameMod, "Vector Silent Aim", "Redirection automatique des paquets d'impact", "ArSilentAim", function() end)
    AddToggle(pGameMod, "Anti Recoil Engine", "Supprime les modificateurs de dispersion de l'arme", "ArNoRecoil", function() end)
elseif Hub.GameMode == "BedWars" then
    AddToggle(pGameMod, "Raycast 360 KillAura", "Génère des événements d'attaque sur l'équipe adverse", "BwKillAura", function() end)
end

-- ══════════════════════════════════════════════
--  MOTEURS CORE SYNCHRONES (ENGINE RUNNER)
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

-- RenderStepped Runner (Visuals, Aim & Camera Spy)
RunService.RenderStepped:Connect(function()
    if Hub.Config.Aimbot and isAlive(player) then
        local target = getClosestPlayer()
        if target and isAlive(target) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Hub.Config.AimbotPart].Position)
        end
    end
    
    if Hub.Config.ViewSpy and not Hub.Config.Aimbot then
        local target = getClosestPlayer()
        if target and isAlive(target) then
            Camera.CameraSubject = target.Character.Humanoid
        else
            Camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        end
    else
        if Camera.CameraSubject ~= (player.Character and player.Character:FindFirstChildOfClass("Humanoid")) and not Hub.Config.ViewSpy then
            Camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        end
    end
    
    -- GESTION ESP UNIVERSELLE OPTIMISÉE
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        local cache = Hub.Cache[p]
        if not cache then
            cache = { Box = Instance.new("Frame"), Tracer = Instance.new("Frame"), Name = Instance.new("TextLabel") }
            cache.Box.BackgroundTransparency = 1; cache.Box.Parent = ScreenGui; line(Hub.Themes.Accent, 1, cache.Box)
            cache.Tracer.BorderSizePixel = 0; cache.Tracer.BackgroundColor3 = Hub.Themes.Accent; cache.Tracer.Parent = ScreenGui
            cache.Name.BackgroundTransparency = 1; cache.Name.Font = Enum.Font.Code; cache.Name.TextSize = 9; cache.Name.TextColor3 = Hub.Themes.Text; cache.Name.Parent = ScreenGui
            Hub.Cache[p] = cache
        end
        
        if not Hub.Config.EspPlayers or not isAlive(p) or not isAlive(player) then
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false
            continue
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
                local startX, startY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y
                local dx, dy = screenPos.X - startX, screenPos.Y - startY
                local len = math.sqrt(dx^2 + dy^2)
                cache.Tracer.Size = UDim2.new(0, len, 0, 1)
                cache.Tracer.Position = UDim2.new(0, startX + dx/2, 0, startY + dy/2)
                cache.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                cache.Tracer.Rotation = math.deg(math.atan2(dy, dx))
                cache.Tracer.Visible = true
            else cache.Tracer.Visible = false end
            
            if Hub.Config.EspNames then
                cache.Name.Text = p.Name:upper() .. " // [" .. math.floor(dist) .. "M]"
                cache.Name.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 14)
                cache.Name.Size = UDim2.new(0, 200, 0, 10)
                cache.Name.Visible = true
            else cache.Name.Visible = false end
        else
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false
        end
    end
end)

-- Heartbeat Runner (Physics Loops)
RunService.Heartbeat:Connect(function()
    if not isAlive(player) then return end
    local char = player.Character
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if Hub.Config.SpeedEnabled then hum.WalkSpeed = Hub.Config.SpeedValue end
    if Hub.Config.JumpEnabled then hum.JumpPower = Hub.Config.JumpValue end
    
    -- Moteur Spinbot
    if Hub.Config.SpinBot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Hub.Config.SpinSpeed), 0)
    end
    
    -- Moteur Fling Aura (Blatant)
    if Hub.Config.FlingAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and isAlive(p) then
                local tRoot = p.Character.HumanoidRootPart
                local distance = (tRoot.Position - root.Position).Magnitude
                if distance < 12 then
                    -- Vélocité rotative extrême simulant un Fling physique local
                    tRoot.Velocity = Vector3.new(9999, 9999, 9999)
                    tRoot.RotVelocity = Vector3.new(9999, 9999, 9999)
                end
            end
        end
    end
    
    -- Moteur Fly standard lié à la caméra
    if Hub.Config.FlyEnabled then
        hum.PlatformStand = true
        local vel = Vector3.new(0, 0, 0)
        if hum.MoveDirection.Magnitude > 0 then vel = hum.MoveDirection * Hub.Config.FlySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, Hub.Config.FlySpeed, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, Hub.Config.FlySpeed, 0) end
        root.CFrame = root.CFrame + vel
        root.Velocity = Vector3.new(0, 0, 0)
    else
        if hum.PlatformStand and not Hub.Config.SpinBot then hum.PlatformStand = false end
    end
end)

RunService.Stepped:Connect(function()
    if Hub.Config.NoClip and isAlive(player) then
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

if firstPage then
    Pages[firstPage].Visible = true
    Buttons[firstPage].Btn.TextColor3 = Hub.Themes.Text
    Buttons[firstPage].Btn.BackgroundTransparency = 0.8
    Buttons[firstPage].Btn.BackgroundColor3 = Hub.Themes.Accent
    Buttons[firstPage].Ind.BackgroundTransparency = 0
end

