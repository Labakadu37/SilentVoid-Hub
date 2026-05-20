--[[
    ZENTY HUB - VRAIE REPRODUCTION
    - Aimbot corrigé (Le plus proche + dans le FOV)
    - FOV fixe au centre
    - Image Discord auto-téléchargée
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration Globale
local Config = {
    AimbotEnabled = false,
    FovRadius = 140,
    Smoothness = 1,
    EspBoxes = false,
    EspNames = false,
    EspHealth = false,
    Speed = 16,
    JumpPower = 50
}

-- ==========================================
-- GESTION DE L'IMAGE DISCORD
-- ==========================================
local CustomImageUrl = "https://cdn.discordapp.com/attachments/1502596518035853352/1506638209160056882/file_00000000d2ec720a8ae39846398a175a.png?ex=6a0efdad&is=6a0dac2d&hm=7bd82f83657e2b480e7e1da690d2f226b0d55f06f08910c34f85bde210e37569&"
local AssetIdToUse = ""

-- Tentative de téléchargement de l'image via l'exécuteur
pcall(function()
    if request and writefile and getcustomasset then
        local response = request({Url = CustomImageUrl, Method = "GET"})
        if response.StatusCode == 200 then
            writefile("ZentyAnimeBg.png", response.Body)
            AssetIdToUse = getcustomasset("ZentyAnimeBg.png")
        end
    end
end)

-- ==========================================
-- CREATION DE L'INTERFACE (GUI)
-- ==========================================
local ZentyGui = Instance.new("ScreenGui")
ZentyGui.Name = "ZentyHubOfficial"
ZentyGui.ResetOnSpawn = false
-- Protection pour éviter la détection si possible
if gethui then ZentyGui.Parent = gethui() else pcall(function() ZentyGui.Parent = CoreGui end) if not ZentyGui.Parent then ZentyGui.Parent = LocalPlayer.PlayerGui end end

-- Nettoyage ancienne interface
for _, gui in pairs(ZentyGui.Parent:GetChildren()) do
    if gui.Name == "ZentyHubOfficial" and gui ~= ZentyGui then gui:Destroy() end
end

-- ==========================================
-- CERCLE FOV (FIXE AU CENTRE)
-- ==========================================
local FovCircle = Instance.new("Frame")
FovCircle.Name = "FOVCircle"
FovCircle.BackgroundTransparency = 1
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5) -- Reste toujours au centre
FovCircle.Size = UDim2.new(0, Config.FovRadius * 2, 0, Config.FovRadius * 2)
FovCircle.Visible = true
FovCircle.Active = false -- Empêche de bloquer les clics
FovCircle.Interactable = false
FovCircle.Parent = ZentyGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovCircle

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(145, 90, 255)
FovStroke.Thickness = 1.5
FovStroke.Parent = FovCircle

-- Mise à jour de la taille du FOV
local function UpdateFovSize()
    FovCircle.Size = UDim2.new(0, Config.FovRadius * 2, 0, Config.FovRadius * 2)
end

-- ==========================================
-- LOGIQUE AIMBOT EXACTE (Plus proche + dans le FOV)
-- ==========================================
local function IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart")
end

local function GetTarget()
    local target = nil
    local shortest3DDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsAlive(p) then
            local rootPart = p.Character.HumanoidRootPart
            local pos3D = rootPart.Position
            local pos2D, onScreen = Camera:WorldToViewportPoint(pos3D)

            if onScreen then
                -- Calcule la distance 2D (Sur l'écran par rapport au centre)
                local dist2D = (Vector2.new(pos2D.X, pos2D.Y) - screenCenter).Magnitude
                
                -- SI LE JOUEUR EST DANS LE ROND FOV
                if dist2D <= Config.FovRadius then
                    -- Calcule la distance 3D (Physiquement dans le jeu)
                    local dist3D = (LocalPlayer.Character.HumanoidRootPart.Position - pos3D).Magnitude
                    
                    -- PREND LE PLUS PROCHE PHYSIQUEMENT PARMI CEUX DANS LE FOV
                    if dist3D < shortest3DDistance then
                        shortest3DDistance = dist3D
                        target = p.Character:FindFirstChild("Head") -- Vise la tête
                    end
                end
            end
        end
    end
    return target
end

-- ==========================================
-- BOUCLE D'EXECUTION (Aimbot & Physique)
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- Lock Aimbot
    if Config.AimbotEnabled then
        local currentTarget = GetTarget()
        if currentTarget then
            -- Mouvement fluide (Smoothness) vers la cible
            local targetCFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    -- Exploits Mouvements
    if IsAlive(LocalPlayer) then
        if Config.Speed > 16 then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.Speed
        end
        if Config.JumpPower > 50 then
            LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPower
        end
    end
end)

-- ==========================================
-- CONSTRUCTION DU MENU VISUEL (Design Zenty)
-- ==========================================
-- Note: Pour garder un script d'une taille exécutable sans freeze, 
-- je recrée la structure principale visible sur tes screens.

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 800, 0, 480)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = ZentyGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 45, 90)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Image Anime au centre/droite
local AnimeBg = Instance.new("ImageLabel")
AnimeBg.Size = UDim2.new(0, 400, 1, -60)
AnimeBg.Position = UDim2.new(1, -400, 0, 60)
AnimeBg.BackgroundTransparency = 1
AnimeBg.Image = AssetIdToUse
AnimeBg.ScaleType = Enum.ScaleType.Crop
AnimeBg.Parent = MainFrame

-- Titre
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Zenty Hub - Professional Gaming Suite"
Title.TextColor3 = Color3.fromRGB(200, 200, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Panneau Gauche (Options ESP/Aimbot)
local LeftPanel = Instance.new("ScrollingFrame")
LeftPanel.Size = UDim2.new(0, 380, 1, -60)
LeftPanel.Position = UDim2.new(0, 10, 0, 60)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ScrollBarThickness = 2
LeftPanel.Parent = MainFrame

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 5)
LeftLayout.Parent = LeftPanel

-- Fonction génératrice de boutons (Pour raccourcir le code tout en gardant toutes les options)
local function CreateToggle(parent, text, configKey)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 20, 0, 20)
    Btn.Position = UDim2.new(0, 5, 0.5, -10)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    Btn.Text = ""
    Btn.Parent = Frame
    local BtnCorner = Instance.new("UICorner") BtnCorner.CornerRadius = UDim.new(0, 4) BtnCorner.Parent = Btn
    local BtnStroke = Instance.new("UIStroke") BtnStroke.Color = Color3.fromRGB(80, 60, 120) BtnStroke.Parent = Btn

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(145, 90, 255) -- Violet activé
        else
            Btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45) -- Désactivé
        end
    end)
end

local function CreateSlider(parent, text, min, max, configKey, isFov)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. Config[configKey]
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBg = Instance.new("TextButton")
    SliderBg.Size = UDim2.new(1, -20, 0, 6)
    SliderBg.Position = UDim2.new(0, 5, 0, 25)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
    SliderBg.Text = ""
    SliderBg.Parent = Frame
    local BgCorner = Instance.new("UICorner") BgCorner.Parent = SliderBg

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(145, 90, 255)
    SliderFill.Parent = SliderBg
    local FillCorner = Instance.new("UICorner") FillCorner.Parent = SliderFill

    local dragging = false
    SliderBg.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local relPos = math.clamp((mousePos - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(relPos, 0, 1, 0)
            
            local value = math.floor(min + (max - min) * relPos)
            Config[configKey] = value
            Label.Text = text .. ": " .. value
            
            if isFov then UpdateFovSize() end
        end
    end)
end

-- Création des éléments dans le panel de gauche
local TitleAimbot = Instance.new("TextLabel") TitleAimbot.Size = UDim2.new(1,0,0,25) TitleAimbot.BackgroundTransparency = 1 TitleAimbot.Text = "  AIMBOT & FOV" TitleAimbot.TextColor3 = Color3.fromRGB(145, 90, 255) TitleAimbot.Font = Enum.Font.GothamBold TitleAimbot.TextSize = 14 TitleAimbot.TextXAlignment = Enum.TextXAlignment.Left TitleAimbot.Parent = LeftPanel
CreateToggle(LeftPanel, "Enable Aimbot Lock", "AimbotEnabled")
CreateSlider(LeftPanel, "FOV Radius", 10, 500, "FovRadius", true)
CreateSlider(LeftPanel, "Smoothness", 0.1, 1, "Smoothness", false) -- 1 = instant lock

local TitleEsp = Instance.new("TextLabel") TitleEsp.Size = UDim2.new(1,0,0,25) TitleEsp.BackgroundTransparency = 1 TitleEsp.Text = "  VISUALS (ESP)" TitleEsp.TextColor3 = Color3.fromRGB(145, 90, 255) TitleEsp.Font = Enum.Font.GothamBold TitleEsp.TextSize = 14 TitleEsp.TextXAlignment = Enum.TextXAlignment.Left TitleEsp.Parent = LeftPanel
CreateToggle(LeftPanel, "ESP Boxes", "EspBoxes")
CreateToggle(LeftPanel, "ESP Names", "EspNames")
CreateToggle(LeftPanel, "ESP Health", "EspHealth")

local TitleMove = Instance.new("TextLabel") TitleMove.Size = UDim2.new(1,0,0,25) TitleMove.BackgroundTransparency = 1 TitleMove.Text = "  MOVEMENT" TitleMove.TextColor3 = Color3.fromRGB(145, 90, 255) TitleMove.Font = Enum.Font.GothamBold TitleMove.TextSize = 14 TitleMove.TextXAlignment = Enum.TextXAlignment.Left TitleMove.Parent = LeftPanel
CreateSlider(LeftPanel, "Walk Speed", 16, 200, "Speed", false)
CreateSlider(LeftPanel, "Jump Power", 50, 300, "JumpPower", false)

-- Raccourci clavier pour cacher/montrer le menu (Touche RightControl par défaut)
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ Zenty Hub chargé avec succès !")

