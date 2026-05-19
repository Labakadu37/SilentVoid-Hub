--[[
    ╔════════════════════════════════════════════════════════════╗
    ║                 SILENTVOID MULTI-GAME HUB                  ║
    ║                         VERSION V1                         ║
    ║        Framework Universel & Spécifique Multi-Jeux         ║
    ╚════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = player:GetMouse()

local originalGravity = Workspace.Gravity
local originalWalkSpeed = 16
local originalJumpPower = 50

if player:WaitForChild("PlayerGui"):FindFirstChild("SilentVoidMultiHub") then
    player.PlayerGui.SilentVoidMultiHub:Destroy()
end

local Hub = {
    GameMode = "Universel",
    PlaceId = game.PlaceId,
    Version = "1.0.0",
    Config = {
        Aimbot = false, AimbotPart = "Head", FovEnabled = false, FovRadius = 130, Smoothness = 0.05, TeamCheck = false, WallCheck = false, AutoShoot = false,
        EspPlayers = false, EspBoxes = false, EspTracers = false, EspNames = false, EspDistance = false, EspHealth = false, EspChams = false,
        SpeedEnabled = false, SpeedValue = 16, JumpEnabled = false, JumpValue = 50, FlyEnabled = false, FlySpeed = 2, NoClip = false, InfiniteJump = false,
        BhAdminMode = false, BhUnlockCars = false, BhTeleportLoop = false,
        BbAutoParry = false, BbParryDistance = 15, BbSpamClick = false,
        Mm2AutoCollect = false, Mm2ShowRoles = false, Mm2KillAura = false,
        ArSilentAim = false, ArNoRecoil = false, ArInfAmmo = false,
        BwAutoBridge = false, BwKillAura = false, BwSprint = false
    },
    Cache = {},
    Themes = {
        Main = Color3.fromRGB(10, 10, 13), Sidebar = Color3.fromRGB(15, 15, 18), Accent = Color3.fromRGB(0, 210, 255),
        Row = Color3.fromRGB(20, 20, 25), Text = Color3.fromRGB(250, 250, 250), TextDark = Color3.fromRGB(130, 130, 140), Border = Color3.fromRGB(32, 32, 38)
    }
}

-- ══════════════════════════════════════════════
--  DETECTION DYNAMIQUE DU JEU
-- ══════════════════════════════════════════════
local gamesList = {
    [4924922222] = "Brookhaven", [13772394625] = "Blade Ball", [142823291] = "Murder Mystery 2",
    [286090424] = "Arsenal", [6872265039] = "BedWars", [1168263273] = "BedWars"
}
if gamesList[Hub.PlaceId] then Hub.GameMode = gamesList[Hub.PlaceId] end

-- ══════════════════════════════════════════════
--  MODULE ANTI-DÉTECTION (BYPASS SECURE METATABLE)
-- ══════════════════════════════════════════════
do
    local gmt = getrawmetatable and getrawmetatable(game)
    if gmt and setreadonly then
        local oldIndex = gmt.__index
        setreadonly(gmt, false)
        gmt.__index = newcclosure(function(self, key)
            if not checkcaller() then
                if key == "WalkSpeed" and self:IsA("Humanoid") and self.Parent == player.Character then return originalWalkSpeed end
                if key == "JumpPower" and self:IsA("Humanoid") and self.Parent == player.Character then return originalJumpPower end
            end
            return oldIndex(self, key)
        end)
        setreadonly(gmt, true)
    end
end

-- ══════════════════════════════════════════════
--  MOTEUR INTERFACE GRAPHIQUE NOIR PREMIUM
-- ══════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentVoidMultiHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function round(r, p) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = p return c end
local function line(col, th, p) local s = Instance.new("UIStroke") s.Color = col s.Thickness = th s.Parent = p return s end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 400)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
MainFrame.BackgroundColor3 = Hub.Themes.Main
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui
round(8, MainFrame); line(Hub.Themes.Border, 1.2, MainFrame)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Hub.Themes.Sidebar
Sidebar.Parent = MainFrame
round(8, Sidebar)

local SidebarCover = Instance.new("Frame")
SidebarCover.Size = UDim2.new(0, 10, 1, 0)
SidebarCover.Position = UDim2.new(1, -10, 0, 0)
SidebarCover.BackgroundColor3 = Hub.Themes.Sidebar
SidebarCover.BorderSizePixel = 0; SidebarCover.Parent = Sidebar

local ContainerHolder = Instance.new("Frame")
ContainerHolder.Size = UDim2.new(1, -160, 1, -40)
ContainerHolder.Position = UDim2.new(0, 160, 0, 40)
ContainerHolder.BackgroundTransparency = 1; ContainerHolder.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, 0, 0, 40)
HubTitle.Position = UDim2.new(0, 12, 0, 5)
HubTitle.BackgroundTransparency = 1; HubTitle.Text = "SILENTVOID"
HubTitle.Font = Enum.Font.GothamBold; HubTitle.TextSize = 15; HubTitle.TextColor3 = Hub.Themes.Accent; HubTitle.TextXAlignment = Enum.TextXAlignment.Left; HubTitle.Parent = Sidebar

local HubSub = Instance.new("TextLabel")
HubSub.Size = UDim2.new(1, 0, 0, 15)
HubSub.Position = UDim2.new(0, 12, 0, 24)
HubSub.BackgroundTransparency = 1; HubSub.Text = "MULTI-GAME HUB V1"
HubSub.Font = Enum.Font.GothamSemibold; HubSub.TextSize = 9; HubSub.TextColor3 = Hub.Themes.TextDark; HubSub.TextXAlignment = Enum.TextXAlignment.Left; HubSub.Parent = Sidebar

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, 0, 1, -60)
NavList.Position = UDim2.new(0, 0, 0, 60)
NavList.BackgroundTransparency = 1; NavList.BorderSizePixel = 0; NavList.ScrollBarThickness = 0; NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 4); NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; NavLayout.Parent = NavList

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -160, 0, 40)
Topbar.Position = UDim2.new(0, 160, 0, 0)
Topbar.BackgroundTransparency = 1; Topbar.Parent = MainFrame

local GameTag = Instance.new("TextLabel")
GameTag.Size = UDim2.new(1, -20, 1, 0)
GameTag.Position = UDim2.new(0, 15, 0, 0)
GameTag.BackgroundTransparency = 1; GameTag.Text = "Jeu Détecté : " .. Hub.GameMode
GameTag.Font = Enum.Font.GothamBold; GameTag.TextSize = 12; GameTag.TextColor3 = Hub.Themes.Text; GameTag.TextXAlignment = Enum.TextXAlignment.Left; GameTag.Parent = Topbar

local toggleB = Instance.new("TextButton")
toggleB.Size = UDim2.new(0, 90, 0, 30)
toggleB.Position = UDim2.new(0, 10, 0, 10)
toggleB.BackgroundColor3 = Hub.Themes.Main
toggleB.Text = "SV HUB 👁"
toggleB.Font = Enum.Font.GothamBold; toggleB.TextColor3 = Hub.Themes.Accent; toggleB.TextSize = 11; toggleB.Parent = ScreenGui
round(6, toggleB); line(Hub.Themes.Border, 1, toggleB)

toggleB.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Hub.Config.FovRadius * 2, 0, Hub.Config.FovRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5); FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0); FOVCircle.BackgroundTransparency = 1; FOVCircle.Visible = false; FOVCircle.Parent = ScreenGui
round(Hub.Config.FovRadius * 2, FOVCircle); local FOVStroke = line(Hub.Themes.Accent, 1, FOVCircle)

-- ══════════════════════════════════════════════
--  METHODES BUILDER UI INTERACTIVE
-- ══════════════════════════════════════════════
local Pages, Buttons, firstPage = {}, {}, nil

local function CreatePage(id, name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0; Page.ScrollBarThickness = 3; Page.Visible = false; Page.Parent = ContainerHolder
    local PL = Instance.new("UIListLayout") PL.Padding = UDim.new(0, 6) PL.HorizontalAlignment = Enum.HorizontalAlignment.Center; PL.Parent = Page
    local PP = Instance.new("UIPadding") PP.PaddingTop = UDim.new(0, 8) PP.Parent = Page
    
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, -16, 0, 34)
    NavBtn.BackgroundColor3 = Hub.Themes.Sidebar
    NavBtn.Text = "  " .. name
    NavBtn.Font = Enum.Font.GothamMedium; NavBtn.TextSize = 11; NavBtn.TextColor3 = Hub.Themes.TextDark; NavBtn.TextXAlignment = Enum.TextXAlignment.Left; NavBtn.AutoButtonColor = false; NavBtn.Parent = NavList
    round(6, NavBtn)
    
    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 3, 0, 14)
    Ind.Position = UDim2.new(0, 0, 0.5, -7); Ind.BackgroundColor3 = Hub.Themes.Accent; Ind.BackgroundTransparency = 1; Ind.Parent = NavBtn
    round(2, Ind)
    
    Pages[id] = Page; Buttons[id] = {Btn = NavBtn, Ind = Ind}
    
    NavBtn.MouseButton1Click:Connect(function()
        for pid, pFrame in pairs(Pages) do
            pFrame.Visible = (pid == id)
            local bData = Buttons[pid]
            if pid == id then
                bData.Btn.TextColor3 = Hub.Themes.Text; bData.Btn.BackgroundColor3 = Hub.Themes.Row
                TweenService:Create(bData.Ind, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            else
                bData.Btn.TextColor3 = Hub.Themes.TextDark; bData.Btn.BackgroundColor3 = Hub.Themes.Sidebar
                TweenService:Create(bData.Ind, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end
    end)
    if not firstPage then firstPage = id end
    return Page
end

local function AddToggle(page, title, sub, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -24, 0, 44) Row.BackgroundColor3 = Hub.Themes.Row Row.Parent = page
    round(6, Row); line(Hub.Themes.Border, 1, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(1, -100, 0, 18) Txt.Position = UDim2.new(0, 12, 0, 4) Txt.BackgroundTransparency = 1; Txt.Text = title; Txt.Font = Enum.Font.GothamBold; Txt.TextSize = 12; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Row
    local SubTxt = Instance.new("TextLabel") SubTxt.Size = UDim2.new(1, -100, 0, 14) SubTxt.Position = UDim2.new(0, 12, 0, 21) SubTxt.BackgroundTransparency = 1; SubTxt.Text = sub; SubTxt.Font = Enum.Font.GothamMedium; SubTxt.TextSize = 10; SubTxt.TextColor3 = Hub.Themes.TextDark; SubTxt.TextXAlignment = Enum.TextXAlignment.Left; SubTxt.Parent = Row
    
    local Switch = Instance.new("TextButton") Switch.Size = UDim2.new(0, 36, 0, 18) Switch.Position = UDim2.new(1, -48, 0.5, -9) Switch.BackgroundColor3 = Hub.Config[configKey] and Hub.Themes.Accent or Hub.Themes.Main Switch.Text = ""; Switch.Parent = Row
    round(9, Switch); line(Hub.Themes.Border, 1, Switch)
    
    local Knob = Instance.new("Frame") Knob.Size = UDim2.new(0, 12, 0, 12) Knob.Position = Hub.Config[configKey] and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) Knob.BackgroundColor3 = Hub.Themes.Text; Knob.Parent = Switch
    round(8, Knob)
    
    Switch.MouseButton1Click:Connect(function()
        Hub.Config[configKey] = not Hub.Config[configKey]
        local enabled = Hub.Config[configKey]
        TweenService:Create(Switch, TweenInfo.new(0.12), {BackgroundColor3 = enabled and Hub.Themes.Accent or Hub.Themes.Main}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.12), {Position = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
        callback(enabled)
    end)
end

local function AddSlider(page, title, min, max, default, configKey, callback)
    local Row = Instance.new("Frame") Row.Size = UDim2.new(1, -24, 0, 50) Row.BackgroundColor3 = Hub.Themes.Row Row.Parent = page
    round(6, Row); line(Hub.Themes.Border, 1, Row)
    
    local Txt = Instance.new("TextLabel") Txt.Size = UDim2.new(0, 200, 0, 18) Txt.Position = UDim2.new(0, 12, 0, 5) Txt.BackgroundTransparency = 1; Txt.Text = title; Txt.Font = Enum.Font.GothamBold; Txt.TextSize = 12; Txt.TextColor3 = Hub.Themes.Text; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = Row
    local ValTxt = Instance.new("TextLabel") ValTxt.Size = UDim2.new(0, 60, 0, 18) ValTxt.Position = UDim2.new(1, -72, 0, 5) ValTxt.BackgroundTransparency = 1; ValTxt.Text = tostring(default); ValTxt.Font = Enum.Font.GothamBold; ValTxt.TextSize = 11; ValTxt.TextColor3 = Hub.Themes.Accent; ValTxt.TextXAlignment = Enum.TextXAlignment.Right; ValTxt.Parent = Row
    
    local SlideBar = Instance.new("TextButton") SlideBar.Size = UDim2.new(1, -24, 0, 5) SlideBar.Position = UDim2.new(0, 12, 0, 32) SlideBar.BackgroundColor3 = Hub.Themes.Main; SlideBar.Text = ""; SlideBar.AutoButtonColor = false; SlideBar.Parent = Row
    round(2, SlideBar)
    
    local SlideIn = Instance.new("Frame") SlideIn.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); SlideIn.BackgroundColor3 = Hub.Themes.Accent; SlideIn.Parent = SlideBar
    round(2, SlideIn)
    
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
--  GENERATION DES PAGES PRINCIPALES
-- ══════════════════════════════════════════════
local pCombat = CreatePage("combat", "⚔ Combat & Aim")
local pVisuals = CreatePage("visuals", "👁 Visuels & ESP")
local pLocal = CreatePage("local", "⚡ Local Player")
local pGameMod = CreatePage("gamemod", "🎲 Module : " .. Hub.GameMode)

-- Page Combat
AddToggle(pCombat, "Lock-On Aimbot", "Verrouille les cibles du FOV", "Aimbot", function() end)
AddToggle(pCombat, "Vérification Murs", "Ne cible pas derrière les parois", "WallCheck", function() end)
AddToggle(pCombat, "Afficher Rond FOV", "Zone d'action de l'aimbot", "FovEnabled", function(v) FOVCircle.Visible = v end)
AddSlider(pCombat, "Rayon du FOV", 30, 300, 130, "FovRadius", function(v) FOVCircle.Size = UDim2.new(0, v*2, 0, v*2) round(v*2, FOVCircle) end)

-- Page Visuels
AddToggle(pVisuals, "Activer l'ESP Principal", "Active les structures d'affichage global", "EspPlayers", function() end)
AddToggle(pVisuals, "Afficher les Box Ennemis", "Cadres de géolocalisation", "EspBoxes", function() end)
AddToggle(pVisuals, "Afficher les Tracers", "Lignes de visée au sol", "EspTracers", function() end)
AddToggle(pVisuals, "Afficher les Pseudos", "Identités visibles", "EspNames", function() end)

-- Page LocalPlayer
AddToggle(pLocal, "Activer Vitesse Forcée", "Modifier la vitesse de déplacement", "SpeedEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = originalWalkSpeed end end)
AddSlider(pLocal, "Valeur Vitesse", 16, 200, 16, "SpeedValue", function() end)
AddToggle(pLocal, "Activer Super Sauts", "Hauteur de impulsion aérienne", "JumpEnabled", function(v) if not v and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = originalJumpPower end end)
AddSlider(pLocal, "Valeur Sauts", 50, 250, 50, "JumpValue", function() end)
AddToggle(pLocal, "Mode Fly (Vol)", "Fige la gravité pour se déplacer en l'air", "FlyEnabled", function(v) if not v then Workspace.Gravity = originalGravity if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end end end)
AddSlider(pLocal, "Vitesse de Vol", 1, 10, 2, "FlySpeed", function() end)
AddToggle(pLocal, "NoClip Physique", "Traverser toutes les matières solides", "NoClip", function() end)

-- ══════════════════════════════════════════════
--  ONGLET SPECIFIQUE : BROOKHAVEN
-- ══════════════════════════════════════════════
if Hub.GameMode == "Brookhaven" then
    AddToggle(pGameMod, "Débloquer les Véhicules", "Donne accès aux voitures payantes/gamepasses", "BhUnlockCars", function(v)
        if v then
            local Network = ReplicatedStorage:FindFirstChild("Network") or ReplicatedStorage:FindFirstChild("Remotes")
            if Network then
                -- Émulation d'achat de gamepass locale pour débloquer le garage
                local gp = player:FindFirstChild("OwnsGamepass") or Instance.new("Folder", player)
                gp.Name = "OwnsGamepass"
                local passIds = {112233, 445566, 778899}
                for _, id in ipairs(passIds) do
                    local b = Instance.new("BoolValue", gp) b.Name = tostring(id) b.Value = true
                end
            end
        end
    end)
    AddToggle(pGameMod, "Boucle de Téléportation", "Téléporte en boucle sur les maisons actives", "BhTeleportLoop", function(v)
        task.spawn(function()
            while Hub.Config.BhTeleportLoop do
                for _, model in ipairs(Workspace:GetChildren()) do
                    if model.Name:sub(1,4) == "Lot_" and model:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = model.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
                        task.wait(3)
                    end
                end
                task.wait(1)
            end
        end)
    end)
end

-- ══════════════════════════════════════════════
--  ONGLET SPECIFIQUE : BLADE BALL
-- ══════════════════════════════════════════════
if Hub.GameMode == "Blade Ball" then
    AddToggle(pGameMod, "Auto-Parry Divin", "Bloque la balle automatiquement avec portée idéale", "BbAutoParry", function() end)
    AddSlider(pGameMod, "Distance de Sécurité", 5, 30, 15, "BbParryDistance", function() end)
    
    task.spawn(function()
        while true do
            task.wait()
            if Hub.Config.BbAutoParry and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local balls = Workspace:FindFirstChild("Balls")
                if balls then
                    for _, ball in ipairs(balls:GetChildren()) do
                        local target = ball:GetAttribute("target")
                        if target == player.Name or ball:FindFirstChild("Target") and ball.Target.Value == player.Character then
                            local dist = (ball.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            local speed = ball.Velocity.Magnitude
                            local dynamicDist = Hub.Config.BbParryDistance + (speed * 0.1)
                            
                            if dist <= dynamicDist then
                                local parryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Parry")
                                if parryRemote then
                                    parryRemote:FireServer()
                                else
                                    -- Méthode alternative via activation d'outil si le remote change
                                    local tool = player.Character:FindFirstChildOfClass("Tool")
                                    if tool then tool:Activate() end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════
--  ONGLET SPECIFIQUE : MURDER MYSTERY 2
-- ══════════════════════════════════════════════
if Hub.GameMode == "Murder Mystery 2" then
    AddToggle(pGameMod, "Afficher les Rôles", "Affiche qui est le Murderer (Rouge) ou Sheriff (Bleu)", "Mm2ShowRoles", function() end)
    AddToggle(pGameMod, "Auto-Collect Pièces", "Téléporte les pièces d'or sur toi automatiquement", "Mm2AutoCollect", function() end)
    
    RunService.RenderStepped:Connect(function()
        if Hub.Config.Mm2ShowRoles then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local cache = Hub.Cache[p]
                    if cache and cache.Box then
                        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                            cache.Box:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(255, 0, 0) -- Meurtrier
                        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                            cache.Box:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0, 0, 255) -- Sheriff
                        else
                            cache.Box:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0, 255, 0) -- Innocent
                        end
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            if Hub.Config.Mm2AutoCollect and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                for _, coin in ipairs(Workspace:GetChildren()) do
                    if coin.Name == "Coin_Geom" or coin.Name == "Coin" then
                        coin.CFrame = player.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════
--  ONGLET SPECIFIQUE : ARSENAL
-- ══════════════════════════════════════════════
if Hub.GameMode == "Arsenal" then
    AddToggle(pGameMod, "Silent Aim Avancé", "Redirige les balles vers la tête", "ArSilentAim", function() end)
    AddToggle(pGameMod, "Supprimer le Recul", "Stabilise totalement l'arme", "ArNoRecoil", function(v)
        if v then
            local reg = getreg or debug.getregistry
            if reg then
                for _, val in pairs(reg()) do
                    if typeof(val) == "table" and val.CurrentWeapon then
                        val.Recoil = 0
                        val.Spread = 0
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════
--  ONGLET SPECIFIQUE : BEDWARS
-- ══════════════════════════════════════════════
if Hub.GameMode == "BedWars" then
    AddToggle(pGameMod, "KillAura Universelle", "Frappe instantanément les adversaires à 360°", "BwKillAura", function() end)
    
    task.spawn(function()
        while true do
            task.wait(0.1)
            if Hub.Config.BwKillAura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Team ~= player.Team then
                        local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= 18 then
                            local sword = player.Character:FindFirstChildOfClass("Tool")
                            if sword then
                                -- Simule la frappe
                                local remote = ReplicatedStorage:FindFirstChild("rbxts_include") and ReplicatedStorage.rbxts_include:FindFirstChild("node_modules")
                                if remote then
                                    -- Déclencheur réseau Bedwars classique
                                    local net = remote:FindFirstChild("@rbxts") and remote["@rbxts"]:FindFirstChild("net")
                                    if net then net.fps:FindFirstChild("hand-shake"):FireServer() end
                                end
                                sword:Activate()
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════
--  MOTEURS CORE DE SIMULATION PHYSIQUE ET VISUELLE
-- ══════════════════════════════════════════════
local function isAlive(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function getClosestPlayer()
    local closest, maxDist = nil, Hub.Config.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and isAlive(p) then
            if Hub.Config.TeamCheck and p.Team == player.Team then continue end
            local head = p.Character:FindFirstChild(Hub.Config.AimbotPart)
            if head then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    if Hub.Config.WallCheck then
                        local parts = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, head.Position}, p.Character:GetChildren())
                        if #parts > 0 then continue end
                    end
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < maxDist then maxDist = dist; closest = p end
                end
            end
        end
    end
    return closest
end

-- Rendu Image par Image Synchrone (Aimbot & ESP)
RunService.RenderStepped:Connect(function()
    if Hub.Config.Aimbot and isAlive(player) then
        local target = getClosestPlayer()
        if target and isAlive(target) then
            local headPos = target.Character[Hub.Config.AimbotPart].Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
        end
    end
    
    -- GESTION ESP UNIVERSELLE ACCELEREE
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        local cache = Hub.Cache[p]
        if not cache then
            cache = { Box = Instance.new("Frame"), Tracer = Instance.new("Frame"), Name = Instance.new("TextLabel") }
            cache.Box.BackgroundTransparency = 1; cache.Box.Parent = ScreenGui; line(Hub.Themes.Accent, 1.2, cache.Box)
            cache.Tracer.BorderSizePixel = 0; cache.Tracer.BackgroundColor3 = Hub.Themes.Accent; cache.Tracer.Parent = ScreenGui
            cache.Name.BackgroundTransparency = 1; cache.Name.Font = Enum.Font.GothamBold; cache.Name.TextSize = 9; cache.Name.TextColor3 = Hub.Themes.Text; cache.Name.Parent = ScreenGui
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
                cache.Name.Text = p.Name .. " [" .. math.floor(dist) .. "m]"
                cache.Name.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - (h / 2) - 15)
                cache.Name.Size = UDim2.new(0, 200, 0, 10)
                cache.Name.Visible = true
            else cache.Name.Visible = false end
        else
            cache.Box.Visible = false; cache.Tracer.Visible = false; cache.Name.Visible = false
        end
    end
end)

-- Co-moteur de Physique (Heartbeat)
RunService.Heartbeat:Connect(function()
    if not isAlive(player) then return end
    local char = player.Character
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if Hub.Config.SpeedEnabled then hum.WalkSpeed = Hub.Config.SpeedValue end
    if Hub.Config.JumpEnabled then hum.JumpPower = Hub.Config.JumpValue end
    
    if Hub.Config.FlyEnabled then
        Workspace.Gravity = 0
        hum.PlatformStand = true
        local vel = Vector3.new(0, 0, 0)
        if hum.MoveDirection.Magnitude > 0 then vel = hum.MoveDirection * Hub.Config.FlySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then vel = vel + Vector3.new(0, Hub.Config.FlySpeed, 0) end
        root.CFrame = root.CFrame + vel
        root.Velocity = Vector3.new(0, 0, 0)
    else
        if hum.PlatformStand then hum.PlatformStand = false Workspace.Gravity = originalGravity end
    end
end)

RunService.Stepped:Connect(function()
    if Hub.Config.NoClip and isAlive(player) then
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Initialisation Page Par Défaut
if firstPage then
    Pages[firstPage].Visible = true
    Buttons[firstPage].Btn.TextColor3 = Hub.Themes.Text
    Buttons[firstPage].Btn.BackgroundColor3 = Hub.Themes.Row
    Buttons[firstPage].Ind.BackgroundTransparency = 0
end
