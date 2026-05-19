-- ============== CONFIGURATION DU MENU DISCORD ==============
local TITRE_MENU = "🖤 PHANTOM MODE 🖤"
local TEXTE_BOUTON = "📢 Rejoindre le Discord"
local LIEN_DISCORD = "https://discord.gg/7mevSZ33A"

-- ============== CONFIGURATION DU SYSTÈME DE VOL ==============
local FLY_CONFIG = {
    DefaultSpeed = 50,
    MaxSpeed = 150,
    MinSpeed = 10,
    SpeedIncrement = 10
}

-- ============== GUI - MENU DISCORD ==============
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIGradient = Instance.new("UIGradient")
local UICorner = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local DiscordButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
local CloseButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local FlyButtonCorner = Instance.new("UICorner")
local SpeedLabel = Instance.new("TextLabel")

ScreenGui.Name = "PhantomGui"
ScreenGui.ResetOnSpawn = false

-- Frame avec style noir transparent phantom
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -120)
MainFrame.Size = UDim2.new(0, 350, 0, 240)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

-- Gradient noir transparent phantom
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
UIGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(1, 0.3)
})
UIGradient.Parent = MainFrame

-- Coins arrondis
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- Titre
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 10)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = TITRE_MENU
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.TextSize = 20
TitleLabel.TextStrokeTransparency = 0.7

-- Bouton Discord (Stylé)
DiscordButton.Name = "DiscordButton"
DiscordButton.Parent = MainFrame
DiscordButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DiscordButton.BackgroundTransparency = 0.2
DiscordButton.Position = UDim2.new(0.05, 0, 0.35, 0)
DiscordButton.Size = UDim2.new(0.9, 0, 0, 40)
DiscordButton.Font = Enum.Font.GothamSemibold
DiscordButton.Text = TEXTE_BOUTON
DiscordButton.TextColor3 = Color3.fromRGB(150, 200, 255)
DiscordButton.TextSize = 13
DiscordButton.BorderSizePixel = 0

ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = DiscordButton

-- Bouton Fly (Stylé)
FlyButton.Name = "FlyButton"
FlyButton.Parent = MainFrame
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FlyButton.BackgroundTransparency = 0.2
FlyButton.Position = UDim2.new(0.05, 0, 0.6, 0)
FlyButton.Size = UDim2.new(0.9, 0, 0, 40)
FlyButton.Font = Enum.Font.GothamSemibold
FlyButton.Text = "✈️ ACTIVER LE VOL"
FlyButton.TextColor3 = Color3.fromRGB(150, 255, 150)
FlyButton.TextSize = 13
FlyButton.BorderSizePixel = 0

FlyButtonCorner.CornerRadius = UDim.new(0, 10)
FlyButtonCorner.Parent = FlyButton

-- Label Vitesse
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = MainFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 10, 0.85, 0)
SpeedLabel.Size = UDim2.new(1, -20, 0, 25)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.Text = "Vitesse: " .. FLY_CONFIG.DefaultSpeed .. " (Molette souris)"
SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
SpeedLabel.TextSize = 11

-- Bouton Fermer (X)
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -35, 0, 8)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 18

-- ============== SYSTÈME DE VOL ==============
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")
ScreenGui.Parent = playerGui

local isFlying = false
local currentSpeed = FLY_CONFIG.DefaultSpeed

local bodyVelocity
local bodyGyro

local function startFly()
    if isFlying then return end
    isFlying = true
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Créer les objets physiques pour le vol
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart
    
    FlyButton.Text = "✈️ VOL ACTIF (Appuie sur E)"
    FlyButton.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Boucle de vol dans un thread séparé pour ne pas bloquer les événements
    task.spawn(function()
        while isFlying do
            if not character or not humanoidRootPart or not humanoidRootPart.Parent then
                isFlying = false
                break
            end
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Contrôles directionnels
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + humanoidRootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - humanoidRootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - humanoidRootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + humanoidRootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            bodyVelocity.Velocity = moveDirection * currentSpeed
            bodyGyro.CFrame = humanoidRootPart.CFrame * CFrame.Angles(
                math.rad(-mouse.Y / 4),
                math.rad(-mouse.X / 4),
                0
            )
            
            RunService.RenderStepped:Wait()
        end
    end)
end

local function stopFly()
    if not isFlying then return end
    isFlying = false
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    FlyButton.Text = "✈️ ACTIVER LE VOL"
    FlyButton.TextColor3 = Color3.fromRGB(150, 255, 150)
end

-- ============== EVENT HANDLERS ==============
DiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LIEN_DISCORD)
        DiscordButton.Text = "✓ Lien copié !"
        DiscordButton.TextColor3 = Color3.fromRGB(150, 255, 150)
        task.wait(2)
        DiscordButton.Text = TEXTE_BOUTON
        DiscordButton.TextColor3 = Color3.fromRGB(150, 200, 255)
    else
        DiscordButton.Text = "✕ Erreur: Impossible de copier"
        DiscordButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

FlyButton.MouseButton1Click:Connect(function()
    if isFlying then
        stopFly()
    else
        startFly()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    stopFly()
    ScreenGui:Destroy()
end)

-- Contrôle de la vitesse avec la molette souris
mouse.WheelForward:Connect(function()
    currentSpeed = math.min(currentSpeed + FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MaxSpeed)
    SpeedLabel.Text = "Vitesse: " .. currentSpeed .. " (Molette souris)"
end)

mouse.WheelBackward:Connect(function()
    currentSpeed = math.max(currentSpeed - FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MinSpeed)
    SpeedLabel.Text = "Vitesse: " .. currentSpeed .. " (Molette souris)"
end)

local function connectHumanoidDeath(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(stopFly)
    end
end

if player.Character then
    connectHumanoidDeath(player.Character)
end
player.CharacterAdded:Connect(connectHumanoidDeath)
