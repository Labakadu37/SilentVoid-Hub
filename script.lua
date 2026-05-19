-- LocalScript: Phantom Mode (UI + Fly)
-- Place this code in a LocalScript under StarterPlayerScripts or StarterGui

-- ============== CONFIGURATION ==============
local TITRE_MENU = "🖤 PHANTOM MODE 🖤"
local TEXTE_BOUTON = "📢 Rejoindre le Discord"
local LIEN_DISCORD = "https://discord.gg/7mevSZ33A"

local FLY_CONFIG = {
    DefaultSpeed = 60,
    MaxSpeed = 250,
    MinSpeed = 10,
    SpeedIncrement = 10,
    MaxVerticalBoost = 220,
    BoostDecayPerSecond = 100
}

-- ============== SERVICES ==============
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- ============== UI CREATION ==============
local function makeUi()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PhantomGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 260)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BackgroundTransparency = 0
    MainFrame.AnchorPoint = Vector2.new(0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    MainFrame.Draggable = true

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -20, 0, 36)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(210, 210, 240)
    Title.Text = TITRE_MENU

    -- Tabs
    local AccueilBtn = Instance.new("TextButton", MainFrame)
    AccueilBtn.Size = UDim2.new(0.47, -10, 0, 32)
    AccueilBtn.Position = UDim2.new(0.05, 0, 0, 54)
    AccueilBtn.Text = "Accueil"
    AccueilBtn.Font = Enum.Font.GothamSemibold
    AccueilBtn.TextSize = 14
    AccueilBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    AccueilBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
    AccueilBtn.BorderSizePixel = 0
    local ACorner = Instance.new("UICorner", AccueilBtn)
    ACorner.CornerRadius = UDim.new(0, 8)

    local MultiBtn = Instance.new("TextButton", MainFrame)
    MultiBtn.Size = UDim2.new(0.47, -10, 0, 32)
    MultiBtn.Position = UDim2.new(0.48, 0, 0, 54)
    MultiBtn.Text = "Multigame"
    MultiBtn.Font = Enum.Font.GothamSemibold
    MultiBtn.TextSize = 14
    MultiBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    MultiBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
    MultiBtn.BorderSizePixel = 0
    local MCorner = Instance.new("UICorner", MultiBtn)
    MCorner.CornerRadius = UDim.new(0, 8)

    local InfoLabel = Instance.new("TextLabel", MainFrame)
    InfoLabel.Position = UDim2.new(0.05, 0, 0, 96)
    InfoLabel.Size = UDim2.new(0.9, 0, 0, 42)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 13
    InfoLabel.TextColor3 = Color3.fromRGB(190, 190, 220)
    InfoLabel.TextWrapped = true
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Text = "Bienvenue dans Phantom Mode. Va dans Multigame pour activer le fly et régler la vitesse."

    -- Discord button (shown on Accueil)
    local DiscordBtn = Instance.new("TextButton", MainFrame)
    DiscordBtn.Size = UDim2.new(0.9, 0, 0, 38)
    DiscordBtn.Position = UDim2.new(0.05, 0, 0, 148)
    DiscordBtn.Font = Enum.Font.GothamSemibold
    DiscordBtn.TextSize = 14
    DiscordBtn.Text = TEXTE_BOUTON
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DiscordBtn.TextColor3 = Color3.fromRGB(160, 200, 255)
    DiscordBtn.BorderSizePixel = 0
    local DCorner = Instance.new("UICorner", DiscordBtn)
    DCorner.CornerRadius = UDim.new(0, 10)

    -- Multigame elements (hidden by default)
    local FlyToggle = Instance.new("TextButton", MainFrame)
    FlyToggle.Size = UDim2.new(0.9, 0, 0, 38)
    FlyToggle.Position = UDim2.new(0.05, 0, 0, 148)
    FlyToggle.Font = Enum.Font.GothamSemibold
    FlyToggle.TextSize = 14
    FlyToggle.Text = "☐ Activer Fly"
    FlyToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    FlyToggle.TextColor3 = Color3.fromRGB(150, 255, 150)
    FlyToggle.BorderSizePixel = 0
    local TCorner = Instance.new("UICorner", FlyToggle)
    TCorner.CornerRadius = UDim.new(0, 10)
    FlyToggle.Visible = false

    local SpeedMinus = Instance.new("TextButton", MainFrame)
    SpeedMinus.Size = UDim2.new(0.16, 0, 0, 30)
    SpeedMinus.Position = UDim2.new(0.05, 0, 0, 196)
    SpeedMinus.Text = "-"
    SpeedMinus.Font = Enum.Font.GothamSemibold
    SpeedMinus.TextSize = 18
    SpeedMinus.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SpeedMinus.TextColor3 = Color3.fromRGB(160, 255, 160)
    SpeedMinus.BorderSizePixel = 0
    local SMCorner = Instance.new("UICorner", SpeedMinus)
    SMCorner.CornerRadius = UDim.new(0, 8)
    SpeedMinus.Visible = false

    local SpeedLabel = Instance.new("TextLabel", MainFrame)
    SpeedLabel.Size = UDim2.new(0.56, 0, 0, 30)
    SpeedLabel.Position = UDim2.new(0.23, 0, 0, 196)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Font = Enum.Font.GothamSemibold
    SpeedLabel.TextSize = 14
    SpeedLabel.TextColor3 = Color3.fromRGB(190, 190, 230)
    SpeedLabel.Text = "Vitesse: " .. FLY_CONFIG.DefaultSpeed
    SpeedLabel.TextWrapped = true
    SpeedLabel.Visible = false

    local SpeedPlus = Instance.new("TextButton", MainFrame)
    SpeedPlus.Size = UDim2.new(0.16, 0, 0, 30)
    SpeedPlus.Position = UDim2.new(0.8, 0, 0, 196)
    SpeedPlus.Text = "+"
    SpeedPlus.Font = Enum.Font.GothamSemibold
    SpeedPlus.TextSize = 18
    SpeedPlus.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SpeedPlus.TextColor3 = Color3.fromRGB(160, 255, 160)
    SpeedPlus.BorderSizePixel = 0
    local SPCorner = Instance.new("UICorner", SpeedPlus)
    SPCorner.CornerRadius = UDim.new(0, 8)
    SpeedPlus.Visible = false

    local FlyInfo = Instance.new("TextLabel", MainFrame)
    FlyInfo.Size = UDim2.new(0.9, 0, 0, 44)
    FlyInfo.Position = UDim2.new(0.05, 0, 0, 232)
    FlyInfo.BackgroundTransparency = 1
    FlyInfo.Font = Enum.Font.Gotham
    FlyInfo.TextSize = 12
    FlyInfo.TextColor3 = Color3.fromRGB(180, 180, 230)
    FlyInfo.Text = "Espace = boost. Ctrl = descendre. Répète Espace pour monter plus haut. Déplace-toi avec WASD."
    FlyInfo.TextWrapped = true
    FlyInfo.Visible = false

    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -36, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.Text = "✕"

    ScreenGui.Parent = playerGui

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        AccueilBtn = AccueilBtn,
        MultiBtn = MultiBtn,
        InfoLabel = InfoLabel,
        DiscordBtn = DiscordBtn,
        FlyToggle = FlyToggle,
        SpeedMinus = SpeedMinus,
        SpeedLabel = SpeedLabel,
        SpeedPlus = SpeedPlus,
        FlyInfo = FlyInfo,
        CloseBtn = CloseBtn
    }
end

-- ============== BEHAVIOR & FLY ==============
local ui = makeUi()

local isFlying = false
local currentSpeed = FLY_CONFIG.DefaultSpeed
local flyBoost = 0
local flyDescending = false
local inputConnections = {}
local hvConnections = {}
local bodyVelocity, bodyGyro

local function updateSpeedLabel()
    ui.SpeedLabel.Text = "Vitesse: " .. currentSpeed
end

local function clearConnections(list)
    for _, c in ipairs(list) do
        if c and c.Connected then
            c:Disconnect()
        end
    end
    for k in pairs(list) do list[k] = nil end
end

local function getGroundDistance(rootPart)
    if not rootPart then return 300 end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local from = rootPart.Position
    local res = Workspace:Raycast(from, Vector3.new(0, -500, 0), rayParams)
    if res and res.Position then
        return from.Y - res.Position.Y
    end
    return 300
end

local function stopFly()
    if not isFlying then return end
    isFlying = false
    clearConnections(inputConnections)

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    -- Rétablir PlatformStand
    local char = player.Character
    if char then
        local h = char:FindFirstChild("Humanoid")
        if h then h.PlatformStand = false end
    end

    ui.FlyToggle.Text = "☐ Activer Fly"
    ui.FlyToggle.TextColor3 = Color3.fromRGB(150, 255, 150)
    flyBoost = 0
    flyDescending = false
end

local function startFly()
    if isFlying then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    isFlying = true
    flyBoost = 0
    flyDescending = false

    -- Désactive l'animation physique du Humanoid pour prendre le contrôle
    humanoid.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    ui.FlyToggle.Text = "☑ Fly activé"
    ui.FlyToggle.TextColor3 = Color3.fromRGB(255, 200, 100)

    local cam = Workspace.CurrentCamera

    inputConnections[#inputConnections + 1] = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Space then
            local dist = getGroundDistance(root)
            local add = (dist < 6) and 90 or 40
            flyBoost = math.clamp(flyBoost + add, 0, FLY_CONFIG.MaxVerticalBoost)
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            flyDescending = true
        end
    end)

    inputConnections[#inputConnections + 1] = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            flyDescending = false
        end
    end)

    -- Update loop
    local last = tick()
    task.spawn(function()
        while isFlying do
            local now = tick()
            local dt = math.clamp(now - last, 0, 0.1)
            last = now

            if not char or not root or not root.Parent then
                break
            end

            -- Movement relative to camera
            local fwd = 0
            local right = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then fwd = fwd + 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then fwd = fwd - 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then right = right + 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then right = right - 1 end

            local move = Vector3.new(0, 0, 0)
            if fwd ~= 0 or right ~= 0 then
                local camC = cam and cam.CFrame or root.CFrame
                local look = Vector3.new(camC.LookVector.X, 0, camC.LookVector.Z)
                local rgt = Vector3.new(camC.RightVector.X, 0, camC.RightVector.Z)
                if look.Magnitude > 0 then look = look.Unit end
                if rgt.Magnitude > 0 then rgt = rgt.Unit end
                move = (look * fwd + rgt * right)
                if move.Magnitude > 0 then move = move.Unit end
            end

            local horiz = move * currentSpeed
            local vert = 0
            if flyDescending then
                vert = -80
            else
                vert = math.min(flyBoost, FLY_CONFIG.MaxVerticalBoost)
            end

            bodyVelocity.Velocity = horiz + Vector3.new(0, vert, 0)

            if cam then
                bodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
            else
                bodyGyro.CFrame = root.CFrame
            end

            flyBoost = math.max(flyBoost - FLY_CONFIG.BoostDecayPerSecond * dt, 0)

            RunService.RenderStepped:Wait()
        end

        -- cleanup
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = false
        end
        stopFly()
    end)
end

-- ============== UI EVENTS ==============
local function setTab(isMulti)
    ui.AccueilBtn.BackgroundColor3 = isMulti and Color3.fromRGB(55,55,65) or Color3.fromRGB(70,70,85)
    ui.MultiBtn.BackgroundColor3 = isMulti and Color3.fromRGB(70,70,85) or Color3.fromRGB(55,55,65)
    ui.DiscordBtn.Visible = not isMulti
    ui.FlyToggle.Visible = isMulti
    ui.SpeedMinus.Visible = isMulti
    ui.SpeedPlus.Visible = isMulti
    ui.SpeedLabel.Visible = isMulti
    ui.FlyInfo.Visible = isMulti
    ui.InfoLabel.Text = isMulti and "Multigame - Fly activable ici.\nEspace pour monter, Ctrl pour descendre." or "Bienvenue dans Phantom Mode. Va dans Multigame pour activer le fly et régler la vitesse."
end

ui.AccueilBtn.MouseButton1Click:Connect(function() setTab(false) end)
ui.MultiBtn.MouseButton1Click:Connect(function() setTab(true) end)

ui.DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LIEN_DISCORD)
        ui.DiscordBtn.Text = "✓ Lien copié !"
        ui.DiscordBtn.TextColor3 = Color3.fromRGB(160,255,180)
        task.wait(1.6)
        ui.DiscordBtn.Text = TEXTE_BOUTON
        ui.DiscordBtn.TextColor3 = Color3.fromRGB(160,200,255)
    else
        ui.DiscordBtn.Text = "✕ Impossible de copier"
    end
end)

ui.FlyToggle.MouseButton1Click:Connect(function()
    if isFlying then stopFly() else startFly() end
end)

ui.SpeedMinus.MouseButton1Click:Connect(function()
    currentSpeed = math.max(currentSpeed - FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MinSpeed)
    updateSpeedLabel()
end)
ui.SpeedPlus.MouseButton1Click:Connect(function()
    currentSpeed = math.min(currentSpeed + FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MaxSpeed)
    updateSpeedLabel()
end)

-- Mouse wheel controls
local success, mouse = pcall(function() return player:GetMouse() end)
if success and mouse then
    mouse.WheelForward:Connect(function()
        currentSpeed = math.min(currentSpeed + FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MaxSpeed)
        updateSpeedLabel()
    end)
    mouse.WheelBackward:Connect(function()
        currentSpeed = math.max(currentSpeed - FLY_CONFIG.SpeedIncrement, FLY_CONFIG.MinSpeed)
        updateSpeedLabel()
    end)
end

ui.CloseBtn.MouseButton1Click:Connect(function()
    stopFly()
    if ui.ScreenGui then ui.ScreenGui:Destroy() end
end)

-- Cleanup on character death / removal
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(function() stopFly() end)
    end
end

if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)

-- Initial state
setTab(false)
updateSpeedLabel()

-- Helpful note for testers
print("Phantom Mode LocalScript chargé pour ", player.Name)
