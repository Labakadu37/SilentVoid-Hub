-- ============================================================================
-- ADVANCED MULTI-GAME HUB - COMPLETE VERSION
-- ============================================================================

-- ============== CONFIGURATION ==============
local CONFIG = {
    -- Aimbot
    FovRadius = 300,
    FovMaxRadius = 800,
    FovMinRadius = 100,
    
    -- Fly
    FlySpeed = 50,
    FlyMaxSpeed = 250,
    FlyMinSpeed = 10,
    
    -- Fun Features
    SpinSpeed = 50,
    MaxSpinSpeed = 200,
    JumpHeight = 50,
    MaxJumpHeight = 200,
    
    -- States
    EspEnabled = false,
    FovEnabled = false,
    AimbotEnabled = false,
    ViserEnabled = false,
    FlyEnabled = false,
    SpinEnabled = false,
    InfiniteJumpEnabled = false,
    NoclipEnabled = false
}

-- ============== SERVICES ==============
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = Workspace.CurrentCamera

-- ============== UI CREATION ==============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 550)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(150, 80, 200)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Titre
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "🖤 ADVANCED HUB 🖤"
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- ScrollFrame pour les catégories
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -30, 1, -70)
ScrollFrame.Position = UDim2.new(0, 15, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollFrame

-- ============== SYSTEME ESP ==============
local espFrames = {}

local function createOrUpdateEsp(character, plr)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local key = plr.UserId
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if not espFrames[key] then
        local frame = Instance.new("Frame")
        frame.Name = "EspBox_" .. plr.Name
        frame.BackgroundTransparency = 0.7
        frame.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 255, 100)
        frame.Parent = ScreenGui
        espFrames[key] = frame
    end
    
    local screenPos = camera:WorldToScreenPoint(root.Position)
    local frame = espFrames[key]
    
    frame.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 25)
    frame.Size = UDim2.new(0, 50, 0, 50)
    frame.Visible = true
end

local function clearEsp()
    for _, frame in pairs(espFrames) do
        if frame then frame:Destroy() end
    end
    espFrames = {}
end

-- ============== SYSTEME FOV ==============
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FovCircle"
fovCircle.BackgroundTransparency = 0.7
fovCircle.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = Color3.fromRGB(100, 255, 150)
fovCircle.Parent = ScreenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0.5, 0)
fovCorner.Parent = fovCircle
fovCircle.Visible = false

local function updateFov()
    if not CONFIG.FovEnabled then
        fovCircle.Visible = false
        return
    end
    
    local mouse = player:GetMouse()
    local size = CONFIG.FovRadius * 2
    fovCircle.Size = UDim2.new(0, size, 0, size)
    fovCircle.Position = UDim2.new(0, mouse.X - CONFIG.FovRadius, 0, mouse.Y - CONFIG.FovRadius)
    fovCircle.Visible = true
end

-- ============== SYSTEME AIMBOT ==============
local function isPlayerInFov(playerChar)
    local root = playerChar:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local mouse = player:GetMouse()
    local screenPos = camera:WorldToScreenPoint(root.Position)
    local distance = math.sqrt((screenPos.X - mouse.X)^2 + (screenPos.Y - mouse.Y)^2)
    return distance <= CONFIG.FovRadius
end

local function lockOnHead(playerChar)
    local head = playerChar:FindFirstChild("Head")
    if not head then return end
    
    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
end

-- ============== SYSTEME FLY ==============
local bodyVelocity, bodyGyro

local function startFly()
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    CONFIG.FlyEnabled = true
    humanoid.PlatformStand = true
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    
    task.spawn(function()
        while CONFIG.FlyEnabled do
            RunService.RenderStepped:Wait()
            
            if not root or not root.Parent then break end
            
            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            
            bodyVelocity.Velocity = move.Unit * CONFIG.FlySpeed
            bodyGyro.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
        end
    end)
end

local function stopFly()
    CONFIG.FlyEnabled = false
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    
    local char = player.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end
end

-- ============== SYSTEME SPIN ==============
local spinConnection
local function startSpin()
    stopSpin()
    CONFIG.SpinEnabled = true
    
    local char = player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    spinConnection = RunService.RenderStepped:Connect(function()
        if CONFIG.SpinEnabled and root and root.Parent then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(CONFIG.SpinSpeed), 0)
        end
    end)
end

local function stopSpin()
    CONFIG.SpinEnabled = false
    if spinConnection then spinConnection:Disconnect() end
end

-- ============== SYSTEME INFINITE JUMP ==============
local function enableInfiniteJump()
    CONFIG.InfiniteJumpEnabled = true
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local jumpConnection
    jumpConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        if CONFIG.InfiniteJumpEnabled and newState == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif not CONFIG.InfiniteJumpEnabled then
            jumpConnection:Disconnect()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Space and CONFIG.InfiniteJumpEnabled then
            humanoid.JumpHeight = CONFIG.JumpHeight
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function disableInfiniteJump()
    CONFIG.InfiniteJumpEnabled = false
end

-- ============== SYSTEME NOCLIP ==============
local noclipConnection
local function enableNoclip()
    CONFIG.NoclipEnabled = true
    local char = player.Character
    if not char then return end
    
    noclipConnection = RunService.RenderStepped:Connect(function()
        if CONFIG.NoclipEnabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    CONFIG.NoclipEnabled = false
    if noclipConnection then noclipConnection:Disconnect() end
    
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ============== BOUCLE PRINCIPALE ==============
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        
        updateFov()
        
        if CONFIG.EspEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    createOrUpdateEsp(plr.Character, plr)
                end
            end
        else
            clearEsp()
        end
        
        if CONFIG.AimbotEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and isPlayerInFov(plr.Character) then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            lockOnHead(plr.Character)
                        end
                    end
                end
            end
        end
    end
end)

-- ============== FONCTION UTILITAIRES ==============
local function createButton(name, parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 150, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

local function createLabel(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createCategory(parent, categoryName, categoryColor)
    local category = Instance.new("Frame")
    category.Size = UDim2.new(1, 0, 0, 250)
    category.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    category.Parent = parent
    
    local catCorner = Instance.new("UICorner")
    catCorner.CornerRadius = UDim.new(0, 10)
    catCorner.Parent = category
    
    local catStroke = Instance.new("UIStroke")
    catStroke.Color = categoryColor
    catStroke.Thickness = 1.5
    catStroke.Parent = category
    
    local catLabel = createLabel(category, categoryName, categoryColor)
    catLabel.Size = UDim2.new(1, -10, 0, 25)
    catLabel.Position = UDim2.new(0, 5, 0, 5)
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -10, 1, -40)
    buttonContainer.Position = UDim2.new(0, 5, 0, 35)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = category
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.48, 0, 0, 35)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gridLayout.Parent = buttonContainer
    
    return category, buttonContainer
end

-- ============== CATEGORIE AIMBOT ==============
local aimbotCat, aimbotContainer = createCategory(ScrollFrame, "⚡ AIMBOT", Color3.fromRGB(0, 255, 100))

local espBtn = createButton("Esp", aimbotContainer, "ESP OFF", Color3.fromRGB(50, 50, 60))
espBtn.MouseButton1Click:Connect(function()
    CONFIG.EspEnabled = not CONFIG.EspEnabled
    espBtn.Text = CONFIG.EspEnabled and "ESP ON" or "ESP OFF"
    espBtn.TextColor3 = CONFIG.EspEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if not CONFIG.EspEnabled then clearEsp() end
end)

local fovBtn = createButton("Fov", aimbotContainer, "FOV OFF", Color3.fromRGB(50, 50, 60))
fovBtn.MouseButton1Click:Connect(function()
    CONFIG.FovEnabled = not CONFIG.FovEnabled
    fovBtn.Text = CONFIG.FovEnabled and "FOV ON" or "FOV OFF"
    fovBtn.TextColor3 = CONFIG.FovEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if not CONFIG.FovEnabled then fovCircle.Visible = false end
end)

local aimbotBtn = createButton("Aimbot", aimbotContainer, "AIMBOT OFF", Color3.fromRGB(50, 50, 60))
aimbotBtn.MouseButton1Click:Connect(function()
    CONFIG.AimbotEnabled = not CONFIG.AimbotEnabled
    aimbotBtn.Text = CONFIG.AimbotEnabled and "AIMBOT ON" or "AIMBOT OFF"
    aimbotBtn.TextColor3 = CONFIG.AimbotEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

local viserBtn = createButton("Viser", aimbotContainer, "VISER OFF", Color3.fromRGB(50, 50, 60))
viserBtn.MouseButton1Click:Connect(function()
    CONFIG.ViserEnabled = not CONFIG.ViserEnabled
    viserBtn.Text = CONFIG.ViserEnabled and "VISER ON" or "VISER OFF"
    viserBtn.TextColor3 = CONFIG.ViserEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 20)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. CONFIG.FovRadius
fovLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
fovLabel.Font = Enum.Font.GothamSemibold
fovLabel.TextSize = 11
fovLabel.Parent = aimbotContainer

local fovMinusBtn = createButton("FovMinus", aimbotContainer, "FOV -", Color3.fromRGB(60, 40, 80))
fovMinusBtn.MouseButton1Click:Connect(function()
    CONFIG.FovRadius = math.max(CONFIG.FovRadius - 50, CONFIG.FovMinRadius)
    fovLabel.Text = "FOV: " .. CONFIG.FovRadius
end)

local fovPlusBtn = createButton("FovPlus", aimbotContainer, "FOV +", Color3.fromRGB(60, 40, 80))
fovPlusBtn.MouseButton1Click:Connect(function()
    CONFIG.FovRadius = math.min(CONFIG.FovRadius + 50, CONFIG.FovMaxRadius)
    fovLabel.Text = "FOV: " .. CONFIG.FovRadius
end)

-- ============== CATEGORIE FUN ==============
local funCat, funContainer = createCategory(ScrollFrame, "🎮 FUN", Color3.fromRGB(255, 150, 50))

local flyBtn = createButton("Fly", funContainer, "FLY OFF", Color3.fromRGB(50, 50, 60))
flyBtn.MouseButton1Click:Connect(function()
    if CONFIG.FlyEnabled then
        stopFly()
        flyBtn.Text = "FLY OFF"
        flyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        startFly()
        flyBtn.Text = "FLY ON"
        flyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

local spinBtn = createButton("Spin", funContainer, "SPIN OFF", Color3.fromRGB(50, 50, 60))
spinBtn.MouseButton1Click:Connect(function()
    if CONFIG.SpinEnabled then
        stopSpin()
        spinBtn.Text = "SPIN OFF"
        spinBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        startSpin()
        spinBtn.Text = "SPIN ON"
        spinBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

local jumpBtn = createButton("InfJump", funContainer, "JUMP OFF", Color3.fromRGB(50, 50, 60))
jumpBtn.MouseButton1Click:Connect(function()
    if CONFIG.InfiniteJumpEnabled then
        disableInfiniteJump()
        jumpBtn.Text = "JUMP OFF"
        jumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        enableInfiniteJump()
        jumpBtn.Text = "JUMP ON"
        jumpBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

local noclipBtn = createButton("Noclip", funContainer, "NOCLIP OFF", Color3.fromRGB(50, 50, 60))
noclipBtn.MouseButton1Click:Connect(function()
    if CONFIG.NoclipEnabled then
        disableNoclip()
        noclipBtn.Text = "NOCLIP OFF"
        noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        enableNoclip()
        noclipBtn.Text = "NOCLIP ON"
        noclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. CONFIG.FlySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextSize = 11
speedLabel.Parent = funContainer

local speedMinusBtn = createButton("SpeedMinus", funContainer, "SPEED -", Color3.fromRGB(60, 40, 80))
speedMinusBtn.MouseButton1Click:Connect(function()
    CONFIG.FlySpeed = math.max(CONFIG.FlySpeed - 10, CONFIG.FlyMinSpeed)
    speedLabel.Text = "Speed: " .. CONFIG.FlySpeed
end)

local speedPlusBtn = createButton("SpeedPlus", funContainer, "SPEED +", Color3.fromRGB(60, 40, 80))
speedPlusBtn.MouseButton1Click:Connect(function()
    CONFIG.FlySpeed = math.min(CONFIG.FlySpeed + 10, CONFIG.FlyMaxSpeed)
    speedLabel.Text = "Speed: " .. CONFIG.FlySpeed
end)

-- ============== DETECTION DE JEU ==============
local GAME_CONFIG = {}
local CURRENT_GAME = "UNKNOWN"

local GAME_SIGNATURES = {
    MERDER = {
        name = "MERDER",
        detectors = function()
            if Workspace:FindFirstChild("Merder") or Workspace:FindFirstChild("MerderTeam") then return true end
            if player:FindFirstChild("TeamValue") and player.TeamValue.Value == "Merder" then return true end
            return false
        end,
        color = Color3.fromRGB(255, 50, 50),
        features = {"🔴 Merder RED", "Team RED"}
    },
    
    SHERIFF = {
        name = "SHERIFF",
        detectors = function()
            if Workspace:FindFirstChild("Sheriff") or Workspace:FindFirstChild("SheriffTeam") then return true end
            if player:FindFirstChild("TeamValue") and player.TeamValue.Value == "Sheriff" then return true end
            return false
        end,
        color = Color3.fromRGB(100, 150, 255),
        features = {"🔵 Sheriff BLUE", "Team BLUE"}
    },
    
    BROOKHAVEN = {
        name = "BROOKHAVEN",
        detectors = function()
            if Workspace:FindFirstChild("House") or game.PlaceId == 4923722337 then return true end
            return false
        end,
        color = Color3.fromRGB(100, 255, 200),
        features = {"🏠 Props Finder", "🚗 Speed Up"}
    },
    
    ADOPT_ME = {
        name = "ADOPT ME",
        detectors = function()
            if Workspace:FindFirstChild("Eggs") or game.PlaceId == 1623736147 then return true end
            return false
        end,
        color = Color3.fromRGB(255, 150, 200),
        features = {"🐣 Egg Finder", "💰 Coins"}
    },
    
    ARSENAL = {
        name = "ARSENAL",
        detectors = function()
            if Workspace:FindFirstChild("Map") and Workspace:FindFirstChild("Guns") or game.PlaceId == 286090429 then return true end
            return false
        end,
        color = Color3.fromRGB(200, 100, 255),
        features = {"🔫 Gun Finder", "⚡ Combat"}
    }
}

local function detectGame()
    for gameName, gameConfig in pairs(GAME_SIGNATURES) do
        if gameConfig.detectors() then
            CURRENT_GAME = gameName
            GAME_CONFIG = gameConfig
            return gameConfig
        end
    end
    return nil
end

-- ============== CATEGORIE GAME-SPECIFIC ==============
local function createGameCategory()
    local gameConfig = detectGame()
    if gameConfig and gameConfig.name then
        local gameCat, gameContainer = createCategory(ScrollFrame, "🎯 " .. gameConfig.name .. " 🎯", gameConfig.color)
        
        for _, featureName in ipairs(gameConfig.features) do
            local featureBtn = createButton(featureName, gameContainer, featureName, Color3.fromRGB(50, 50, 60))
            featureBtn.MouseButton1Click:Connect(function()
                featureBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(0.3)
                featureBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end
        
        return gameCat
    end
end

createGameCategory()

-- ============== CLEANUP ==============
player.CharacterAdded:Connect(function(char)
    if CONFIG.FlyEnabled then stopFly() end
    if CONFIG.SpinEnabled then stopSpin() end
    if CONFIG.NoclipEnabled then disableNoclip() end
end)

print("✅ Advanced Hub chargé avec succès!")
