-- FlyScript LocalScript
-- Place inside StarterPlayerScripts ou StarterCharacterScripts
-- Compatible PC (WASD + Espace + Ctrl) et Mobile (boutons à l'écran)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ════════════════════════════════════════════
--  VARIABLES FLY
-- ════════════════════════════════════════════
local flyEnabled = false
local flySpeed = 50
local boostUp = false
local boostDown = false
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil

-- ════════════════════════════════════════════
--  GUI SETUP
-- ════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AetherMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Fenêtre principale
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 100, 255)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Titre
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 20, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ Aether Hub"
titleLabel.TextColor3 = Color3.fromRGB(120, 160, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Bouton fermer
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Bouton minimiser (toggle affichage)
local minimized = false
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -66, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = mainFrame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Zone onglets
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 36)
tabBar.Position = UDim2.new(0, 8, 0, 46)
tabBar.BackgroundColor3 = Color3.fromRGB(18, 20, 38)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

-- Contenu
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -16, 1, -96)
contentFrame.Position = UDim2.new(0, 8, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- ════════════════════════════════════════════
--  HELPER FUNCTIONS
-- ════════════════════════════════════════════
local function makeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 180, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function makeSection(title)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = contentFrame

    if title ~= "" then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 22)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(80, 120, 255)
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
    end

    return frame
end

local function makeToggleButton(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(22, 26, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 210, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(40, 60, 140)
    return btn
end

local function makeLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.Position = UDim2.new(0, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(180, 190, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- ════════════════════════════════════════════
--  FLY LOGIC
-- ════════════════════════════════════════════
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function stopFly()
    flyEnabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then
            if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        end
        if hum then
            hum.PlatformStand = false
        end
    end
end

local function startFly()
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.D = 100
    bodyGyro.P = 1000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    flyEnabled = true

    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local char2 = player.Character
        if not char2 then stopFly() return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then stopFly() return end

        local cam = workspace.CurrentCamera
        local camCF = cam.CFrame
        local move = Vector3.zero

        -- WASD (PC)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move = move + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move = move - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move = move - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move = move + camCF.RightVector
        end

        -- Vertical
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or boostUp then
            move = move + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or boostDown then
            move = move - Vector3.new(0, 1, 0)
        end

        if move.Magnitude > 0 then
            move = move.Unit * flySpeed
        end

        bodyVelocity.Velocity = move
        bodyGyro.CFrame = camCF
    end)
end

-- ════════════════════════════════════════════
--  ONGLETS
-- ════════════════════════════════════════════
local tabAccueil = makeTab("🏠 Accueil")
local tabMulti = makeTab("🎮 Multigame")

-- ─── PAGE ACCUEIL ───
local pageAccueil = makeSection("")
pageAccueil.Visible = true

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, 0, 0, 60)
welcomeLabel.Position = UDim2.new(0, 0, 0, 10)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "⚡ Aether Hub"
welcomeLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
welcomeLabel.TextSize = 22
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.Parent = pageAccueil

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 40)
subLabel.Position = UDim2.new(0, 0, 0, 65)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Script multi-jeux · PC & Mobile"
subLabel.TextColor3 = Color3.fromRGB(120, 140, 220)
subLabel.TextSize = 13
subLabel.Font = Enum.Font.Gotham
subLabel.TextWrapped = true
subLabel.Parent = pageAccueil

local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1, 0, 0, 130)
infoBox.Position = UDim2.new(0, 0, 0, 110)
infoBox.BackgroundColor3 = Color3.fromRGB(16, 20, 40)
infoBox.BorderSizePixel = 0
infoBox.Parent = pageAccueil
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", infoBox).Color = Color3.fromRGB(40, 60, 140)

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -16, 1, -12)
infoText.Position = UDim2.new(0, 8, 0, 6)
infoText.BackgroundTransparency = 1
infoText.Text = "🎮 PC : WASD pour voler\n⬆️  Espace = monter · Ctrl = descendre\n📱 Mobile : boutons à l'écran\n⚙️  Règle ta vitesse dans Multigame"
infoText.TextColor3 = Color3.fromRGB(160, 180, 255)
infoText.TextSize = 12
infoText.Font = Enum.Font.Gotham
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextWrapped = true
infoText.Parent = infoBox

-- ─── PAGE MULTIGAME ───
local pageMulti = makeSection("")

-- Toggle Fly
local flyBtn = makeToggleButton(pageMulti, "🚀 Fly  [ OFF ]", 10)

-- Speed label
local speedLabel = makeLabel(pageMulti, "Vitesse : 50", 62, Color3.fromRGB(160, 200, 255))

-- Speed controls
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 44)
speedFrame.Position = UDim2.new(0, 0, 0, 84)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = pageMulti

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 60, 1, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 80)
minusBtn.Text = "−"
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.TextSize = 22
minusBtn.Font = Enum.Font.GothamBold
minusBtn.BorderSizePixel = 0
minusBtn.Parent = speedFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 8)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 60, 1, 0)
plusBtn.Position = UDim2.new(1, -60, 0, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 80)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.TextSize = 22
plusBtn.Font = Enum.Font.GothamBold
plusBtn.BorderSizePixel = 0
plusBtn.Parent = speedFrame
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 8)

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1, -140, 1, -10)
speedBar.Position = UDim2.new(0, 70, 0, 5)
speedBar.BackgroundColor3 = Color3.fromRGB(20, 24, 50)
speedBar.BorderSizePixel = 0
speedBar.Parent = speedFrame
Instance.new("UICorner", speedBar).CornerRadius = UDim.new(0, 6)

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.5, 0, 1, 0) -- 50/100
speedFill.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedBar
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0, 6)

-- Mobile vertical buttons
local mobileLabel = makeLabel(pageMulti, "📱 Mobile — vol vertical :", 138, Color3.fromRGB(120, 140, 220))

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0.47, 0, 0, 42)
upBtn.Position = UDim2.new(0, 0, 0, 160)
upBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
upBtn.Text = "▲ Monter"
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.TextSize = 13
upBtn.Font = Enum.Font.GothamSemibold
upBtn.BorderSizePixel = 0
upBtn.Parent = pageMulti
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 8)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0.47, 0, 0, 42)
downBtn.Position = UDim2.new(0.53, 0, 0, 160)
downBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 130)
downBtn.Text = "▼ Descendre"
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.TextSize = 13
downBtn.Font = Enum.Font.GothamSemibold
downBtn.BorderSizePixel = 0
downBtn.Parent = pageMulti
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 8)

-- Note WASD mobile
local wasdNote = makeLabel(pageMulti, "ℹ️ WASD fonctionne via le joystick Roblox", 210, Color3.fromRGB(90, 110, 180))
wasdNote.TextSize = 11
wasdNote.TextWrapped = true
wasdNote.Size = UDim2.new(1, 0, 0, 30)

-- ════════════════════════════════════════════
--  LOGIQUE ONGLETS
-- ════════════════════════════════════════════
local function setTab(page, activeTab)
    pageAccueil.Visible = false
    pageMulti.Visible = false
    page.Visible = true

    tabAccueil.BackgroundColor3 = Color3.fromRGB(25, 28, 50)
    tabMulti.BackgroundColor3 = Color3.fromRGB(25, 28, 50)
    tabAccueil.TextColor3 = Color3.fromRGB(160, 180, 255)
    tabMulti.TextColor3 = Color3.fromRGB(160, 180, 255)

    activeTab.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
    activeTab.TextColor3 = Color3.new(1,1,1)
end

setTab(pageAccueil, tabAccueil)

tabAccueil.MouseButton1Click:Connect(function()
    setTab(pageAccueil, tabAccueil)
end)
tabMulti.MouseButton1Click:Connect(function()
    setTab(pageMulti, tabMulti)
end)

-- ════════════════════════════════════════════
--  BOUTONS ACTIONS
-- ════════════════════════════════════════════

-- Fly toggle
flyBtn.MouseButton1Click:Connect(function()
    if flyEnabled then
        stopFly()
        flyBtn.Text = "🚀 Fly  [ OFF ]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 50)
    else
        startFly()
        flyBtn.Text = "✅ Fly  [ ON ]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
    end
end)

-- Speed
local function updateSpeed()
    flySpeed = math.clamp(flySpeed, 5, 200)
    speedLabel.Text = "Vitesse : " .. flySpeed
    speedFill.Size = UDim2.new(flySpeed / 200, 0, 1, 0)
end

plusBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 10
    updateSpeed()
end)
minusBtn.MouseButton1Click:Connect(function()
    flySpeed = flySpeed - 10
    updateSpeed()
end)

-- Mobile monter / descendre
upBtn.MouseButton1Down:Connect(function() boostUp = true end)
upBtn.MouseButton1Up:Connect(function() boostUp = false end)
downBtn.MouseButton1Down:Connect(function() boostDown = true end)
downBtn.MouseButton1Up:Connect(function() boostDown = false end)

-- Close / minimize
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    stopFly()
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tabBar.Visible = not minimized
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 300, 0, 46) or UDim2.new(0, 300, 0, 380)
    minBtn.Text = minimized and "□" or "—"
end)

-- ════════════════════════════════════════════
--  RESPAWN : réactive le fly si actif
-- ════════════════════════════════════════════
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    bodyVelocity = nil
    bodyGyro = nil
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyEnabled then
        startFly()
    end
end)
