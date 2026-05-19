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
local AccueilButton = Instance.new("TextButton")
local MultiGameButton = Instance.new("TextButton")
local InfoLabel = Instance.new("TextLabel")
local DiscordButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
local FlyButton = Instance.new("TextButton")
local FlyButtonCorner = Instance.new("UICorner")
local SpeedLabel = Instance.new("TextLabel")
local SpeedMinusButton = Instance.new("TextButton")
local SpeedPlusButton = Instance.new("TextButton")
local SpeedCorner = Instance.new("UICorner")
local FlyInfoLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabCorner1 = Instance.new("UICorner")
local TabCorner2 = Instance.new("UICorner")

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

-- Tabs Accueil / Multigame
AccueilButton.Name = "AccueilButton"
AccueilButton.Parent = MainFrame
AccueilButton.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
AccueilButton.BackgroundTransparency = 0.2
AccueilButton.Position = UDim2.new(0.05, 0, 0.12, 0)
AccueilButton.Size = UDim2.new(0.43, 0, 0, 30)
AccueilButton.Font = Enum.Font.GothamSemibold
AccueilButton.Text = "Accueil"
AccueilButton.TextColor3 = Color3.fromRGB(200, 200, 255)
AccueilButton.TextSize = 13
AccueilButton.BorderSizePixel = 0
TabCorner1.CornerRadius = UDim.new(0, 10)
TabCorner1.Parent = AccueilButton

MultiGameButton.Name = "MultiGameButton"
MultiGameButton.Parent = MainFrame
MultiGameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MultiGameButton.BackgroundTransparency = 0.2
MultiGameButton.Position = UDim2.new(0.52, 0, 0.12, 0)
MultiGameButton.Size = UDim2.new(0.43, 0, 0, 30)
MultiGameButton.Font = Enum.Font.GothamSemibold
MultiGameButton.Text = "Multigame"
MultiGameButton.TextColor3 = Color3.fromRGB(200, 200, 255)
MultiGameButton.TextSize = 13
MultiGameButton.BorderSizePixel = 0
TabCorner2.CornerRadius = UDim.new(0, 10)
TabCorner2.Parent = MultiGameButton

InfoLabel.Name = "InfoLabel"
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0.05, 0, 0.22, 0)
InfoLabel.Size = UDim2.new(0.9, 0, 0.18, 0)
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.Text = "Bienvenue dans Phantom Mode. Va dans Multigame pour activer le fly et régler la vitesse."
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
InfoLabel.TextSize = 12
InfoLabel.TextWrapped = true
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Bouton Discord (Stylé)
DiscordButton.Name = "DiscordButton"
DiscordButton.Parent = MainFrame
DiscordButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DiscordButton.BackgroundTransparency = 0.2
DiscordButton.Position = UDim2.new(0.05, 0, 0.44, 0)
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
FlyButton.Position = UDim2.new(0.05, 0, 0.44, 0)
FlyButton.Size = UDim2.new(0.9, 0, 0, 40)
FlyButton.Font = Enum.Font.GothamSemibold
FlyButton.Text = "☐ Activer Fly"
FlyButton.TextColor3 = Color3.fromRGB(150, 255, 150)
FlyButton.TextSize = 13
FlyButton.BorderSizePixel = 0
FlyButton.Visible = false
FlyButtonCorner.CornerRadius = UDim.new(0, 10)
FlyButtonCorner.Parent = FlyButton

-- Contrôles de vitesse
SpeedMinusButton.Name = "SpeedMinusButton"
SpeedMinusButton.Parent = MainFrame
SpeedMinusButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SpeedMinusButton.BackgroundTransparency = 0.2
SpeedMinusButton.Position = UDim2.new(0.05, 0, 0.62, 0)
SpeedMinusButton.Size = UDim2.new(0.15, 0, 0, 30)
SpeedMinusButton.Font = Enum.Font.GothamSemibold
SpeedMinusButton.Text = "-"
SpeedMinusButton.TextColor3 = Color3.fromRGB(150, 255, 150)
SpeedMinusButton.TextSize = 18
SpeedMinusButton.BorderSizePixel = 0
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedMinusButton

SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = MainFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0.23, 0, 0.62, 0)
SpeedLabel.Size = UDim2.new(0.52, 0, 0, 30)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.Text = "Vitesse: " .. FLY_CONFIG.DefaultSpeed .. ""
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 230)
SpeedLabel.TextSize = 13
SpeedLabel.TextWrapped = true
SpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
SpeedLabel.Visible = false

SpeedPlusButton.Name = "SpeedPlusButton"
SpeedPlusButton.Parent = MainFrame
SpeedPlusButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SpeedPlusButton.BackgroundTransparency = 0.2
SpeedPlusButton.Position = UDim2.new(0.8, 0, 0.62, 0)
SpeedPlusButton.Size = UDim2.new(0.15, 0, 0, 30)
SpeedPlusButton.Font = Enum.Font.GothamSemibold
SpeedPlusButton.Text = "+"
SpeedPlusButton.TextColor3 = Color3.fromRGB(150, 255, 150)
SpeedPlusButton.TextSize = 18
SpeedPlusButton.BorderSizePixel = 0
SpeedPlusButton.Visible = false

FlyInfoLabel.Name = "FlyInfoLabel"
FlyInfoLabel.Parent = MainFrame
FlyInfoLabel.BackgroundTransparency = 1
FlyInfoLabel.Position = UDim2.new(0.05, 0, 0.72, 0)
FlyInfoLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
FlyInfoLabel.Font = Enum.Font.GothamSemibold
FlyInfoLabel.Text = "Espace = boost. Ctrl = descendre. Répète les sauts pour monter plus haut."
FlyInfoLabel.TextColor3 = Color3.fromRGB(180, 180, 230)
FlyInfoLabel.TextSize = 12
FlyInfoLabel.TextWrapped = true
FlyInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
FlyInfoLabel.Visible = false

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
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")
ScreenGui.Parent = playerGui

local isFlying = false
local currentSpeed = FLY_CONFIG.DefaultSpeed
local flyBoost = 0
local flyDescending = false
local inputConnections = {}

local bodyVelocity
local bodyGyro

local function updateSpeedLabel()
    SpeedLabel.Text = "Vitesse: " .. currentSpeed
end

local function setTab(isMultiGame)
    AccueilButton.BackgroundColor3 = isMultiGame and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(90, 90, 110)
    MultiGameButton.BackgroundColor3 = isMultiGame and Color3.fromRGB(90, 90, 110) or Color3.fromRGB(60, 60, 70)
    DiscordButton.Visible = not isMultiGame
    FlyButton.Visible = isMultiGame
    SpeedMinusButton.Visible = isMultiGame
    SpeedPlusButton.Visible = isMultiGame
    SpeedLabel.Visible = isMultiGame
    FlyInfoLabel.Visible = isMultiGame
    if isMultiGame then
        InfoLabel.Text = "Multigame - Fly activable ici.\nEspace pour monter, Ctrl pour descendre."
    else
        InfoLabel.Text = "Bienvenue dans Phantom Mode.\nVa dans Multigame pour activer le fly et régler la vitesse."
    end
end

local function getGroundDistance(origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = Workspace:Raycast(origin.Position, Vector3.new(0, -500, 0), rayParams)
    if ray then
        return origin.Position.Y - ray.Position.Y
    end
    return 300
end

local function clearInputConnections()
    for _, conn in ipairs(inputConnections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    inputConnections = {}
end

local function stopFly()
    if not isFlying then return end
    isFlying = false
    clearInputConnections()

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    FlyButton.Text = "☐ Activer Fly"
    FlyButton.TextColor3 = Color3.fromRGB(150, 255, 150)
    flyBoost = 0
    flyDescending = false
end

local function startFly()
    if isFlying then return end

    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    isFlying = true
    flyBoost = 0
    flyDescending = false

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    FlyButton.Text = "☑ Fly activé"
    FlyButton.TextColor3 = Color3.fromRGB(255, 200, 100)

    inputConnections[#inputConnections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Space then
            local groundDistance = getGroundDistance(humanoidRootPart)
            local boost = groundDistance < 6 and 70 or 35
            flyBoost = math.clamp(flyBoost + boost, 0, 220)
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            flyDescending = true
        end
    end)

    inputConnections[#inputConnections + 1] = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            flyDescending = false
        end
    end)

    local lastTime = tick()
    task.spawn(function()
        while isFlying do
            if not character or not humanoidRootPart or not humanoidRootPart.Parent then
                isFlying = false
                break
            end

            local now = tick()
            local dt = math.clamp(now - lastTime, 0, 0.1)
            lastTime = now

            local moveDirection = Vector3.new(0, 0, 0)
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
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end

            if flyDescending then
                bodyVelocity.Velocity = moveDirection * currentSpeed - Vector3.new(0, 50, 0)
            else
                local verticalBoost = Vector3.new(0, math.min(flyBoost, 220), 0)
                bodyVelocity.Velocity = moveDirection * currentSpeed + verticalBoost
            end

            bodyGyro.CFrame = humanoidRootPart.CFrame * CFrame.Angles(
                math.rad(-mouse.Y / 4),
                math.rad(-mouse.X / 4),
                0
            )

            flyBoost = math.max(flyBoost - 100 * dt, 0)
            RunService.RenderStepped:Wait()
        end
        stopFly()
    end)
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

AccueilButton.MouseButton1Click:Connect(function()
    setTab(false)
end)

MultiGameButton.MouseButton1Click:Connect(function()
    setTab(true)
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

SpeedMinusButton.MouseButton1Click:Connect(function()
    currentSpeed = math.max(currentSpeed - FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MinSpeed)
    updateSpeedLabel()
end)

SpeedPlusButton.MouseButton1Click:Connect(function()
    currentSpeed = math.min(currentSpeed + FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MaxSpeed)
    updateSpeedLabel()
end)

-- Contrôle de la vitesse avec la molette souris
mouse.WheelForward:Connect(function()
    currentSpeed = math.min(currentSpeed + FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MaxSpeed)
    updateSpeedLabel()
end)

mouse.WheelBackward:Connect(function()
    currentSpeed = math.max(currentSpeed - FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MinSpeed)
    updateSpeedLabel()
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

setTab(false)
updateSpeedLabel()
