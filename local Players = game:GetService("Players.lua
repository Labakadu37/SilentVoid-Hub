local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- =============================================================================
-- CONFIGURATION
-- =============================================================================

local CONFIG = {
    FovRadius = 400,
    FovMaxRadius = 800,
    FovMinRadius = 100,
    FovColor = Color3.fromRGB(100, 255, 150),
    EspBoxThickness = 2,
    EspBoxColor = Color3.fromRGB(0, 255, 100),
    AimbotEnabled = false,
    EspEnabled = false,
    FovEnabled = false,
    EspUpdateSpeed = 0.016
}

-- =============================================================================
-- INTERFACE GRAPHIQUE (UI STYLE SOMBRE & VIOLET)
-- =============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExpertDeveloperMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui -- Utiliser player:WaitForChild("PlayerGui") si testé hors Studio

-- Fenêtre Principale
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 420)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -210)
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
Title.Text = "🖤 ADVANCED AIMBOT SUITE 🖤"
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Conteneur principal
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -30, 1, -70)
Container.Position = UDim2.new(0, 15, 0, 60)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- =============================================================================
-- LOGIQUE DU FLY & VARIABLES DE CONTROLE
-- =============================================================================

local flying = false
local flySpeed = 50
local currentWalkspeed = 16

local bodyGyro, bodyVelocity
local keysDown = {}

-- =============================================================================
-- SYSTEME ESP (BOITES DE DETECTION)
-- =============================================================================

local espFrames = {}

local function getPlayerBoundingBox(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local humanoidRootSize = root.Size
    local minPos = root.Position - (humanoidRootSize / 2)
    local maxPos = root.Position + (humanoidRootSize / 2)
    
    return minPos, maxPos
end

local function worldToScreenPoint(worldPos)
    local screenSize = ScreenGui.AbsoluteSize
    local viewport = camera.ViewportSize
    local unitRay = camera:ScreenPointToRay(0, 0)
    
    local camPos = camera.CFrame.Position
    local offset = worldPos - camPos
    local dist = offset:Dot(camera.CFrame.LookVector)
    
    if dist <= 0 then return nil end
    
    local projected = camera:WorldToScreenPoint(worldPos)
    return Vector2.new(projected.X, projected.Y)
end

local function createOrUpdateEspBox(character, plr)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local key = plr.UserId
    local minPos, maxPos = getPlayerBoundingBox(character)
    if not minPos then return end
    
    -- Créer ou récupérer le frame ESP
    if not espFrames[key] then
        local frame = Instance.new("Frame")
        frame.Name = "EspBox_" .. plr.Name
        frame.BackgroundTransparency = 0.8
        frame.BackgroundColor3 = CONFIG.EspBoxColor
        frame.BorderSizePixel = CONFIG.EspBoxThickness
        frame.BorderColor3 = CONFIG.EspBoxColor
        frame.Parent = ScreenGui
        espFrames[key] = frame
    end
    
    local topLeft = worldToScreenPoint(minPos)
    local bottomRight = worldToScreenPoint(maxPos)
    
    if topLeft and bottomRight then
        local frame = espFrames[key]
        local width = math.abs(bottomRight.X - topLeft.X)
        local height = math.abs(bottomRight.Y - topLeft.Y)
        
        frame.Position = UDim2.new(0, math.min(topLeft.X, bottomRight.X), 0, math.min(topLeft.Y, bottomRight.Y))
        frame.Size = UDim2.new(0, width, 0, height)
        frame.Visible = true
    else
        espFrames[key].Visible = false
    end
end

local function clearEspBoxes()
    for _, frame in pairs(espFrames) do
        if frame then frame:Destroy() end
    end
    espFrames = {}
end

-- =============================================================================
-- SYSTEME FOV CIRCULAIRE
-- =============================================================================

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FovCircle"
fovCircle.BackgroundTransparency = 0.7
fovCircle.BackgroundColor3 = CONFIG.FovColor
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = CONFIG.FovColor
fovCircle.Parent = ScreenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0.5, 0)
fovCorner.Parent = fovCircle

fovCircle.Visible = false

local function updateFovCircle()
    if not CONFIG.FovEnabled then
        fovCircle.Visible = false
        return
    end
    
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local size = CONFIG.FovRadius * 2
    
    fovCircle.Size = UDim2.new(0, size, 0, size)
    fovCircle.Position = UDim2.new(0, mousePos.X - CONFIG.FovRadius, 0, mousePos.Y - CONFIG.FovRadius)
    fovCircle.Visible = true
end

-- =============================================================================
-- SYSTEME AIMBOT / VISEUR LOCK
-- =============================================================================

local function isPlayerInFov(playerChar)
    local root = playerChar:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local screenPos = camera:WorldToScreenPoint(root.Position)
    
    local distance = math.sqrt((screenPos.X - mousePos.X)^2 + (screenPos.Y - mousePos.Y)^2)
    return distance <= CONFIG.FovRadius
end

local function lockOnToHead(playerChar)
    local head = playerChar:FindFirstChild("Head")
    if not head then return end
    
    -- Utiliser CFrame pour orienter la caméra vers la tête
    local targetPos = head.Position + head.CFrame.LookVector * 5
    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
end

-- =============================================================================
-- BOUCLE DE MISE À JOUR
-- =============================================================================

task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        
        -- Mise à jour ESP
        if CONFIG.EspEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    createOrUpdateEspBox(plr.Character, plr)
                end
            end
        else
            clearEspBoxes()
        end
        
        -- Mise à jour FOV
        updateFovCircle()
        
        -- Mise à jour Aimbot
        if CONFIG.AimbotEnabled and CONFIG.FovEnabled then
            local targetPlayer = nil
            local closestDistance = math.huge
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and isPlayerInFov(plr.Character) then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local screenPos = camera:WorldToScreenPoint(head.Position)
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            local dist = math.sqrt((screenPos.X - mousePos.X)^2 + (screenPos.Y - mousePos.Y)^2)
                            
                            if dist < closestDistance then
                                closestDistance = dist
                                targetPlayer = plr
                            end
                        end
                    end
                end
            end
            
            if targetPlayer and targetPlayer.Character then
                lockOnToHead(targetPlayer.Character)
            end
        end
    end
end)

local function startFly()
	local character = player.Character
    	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        	local root = character.HumanoidRootPart
            	local humanoid = character:FindFirstChildOfClass("Humanoid")
                	if humanoid then humanoid.PlatformStand = true end

                    	bodyGyro = Instance.new("BodyGyro")
                        	bodyGyro.P = 9e4
                            	bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                                	bodyGyro.cframe = root.CFrame
                                    	bodyGyro.Parent = root

                                        	bodyVelocity = Instance.new("BodyVelocity")
                                            	bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
                                                	bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
                                                    	bodyVelocity.Parent = root

                                                        	flying = true

                                                            	task.spawn(function()
                                                                		while flying and root and bodyVelocity and bodyGyro do
                                                                        			RunService.RenderStepped:Wait()
                                                                                    			local camCFrame = camera.CFrame
                                                                                                			local direction = Vector3.new(0, 0, 0)
                                                                                                            
                                                                                                            			-- Déplacements WASD / ZQSD (Prend en compte la configuration clavier)
                                                                                                                        			if keysDown[Enum.KeyCode.W] or keysDown[Enum.KeyCode.Z] then
                                                                                                                                    				direction = direction + camCFrame.LookVector
                                                                                                                                                    			end
                                                                                                                                                                			if keysDown[Enum.KeyCode.S] then
                                                                                                                                                                            				direction = direction - camCFrame.LookVector
                                                                                                                                                                                            			end
                                                                                                                                                                                                        			if keysDown[Enum.KeyCode.A] or keysDown[Enum.KeyCode.Q] then
                                                                                                                                                                                                                    				direction = direction - camCFrame.RightVector
                                                                                                                                                                                                                                    			end
                                                                                                                                                                                                                                                			if keysDown[Enum.KeyCode.D] then
                                                                                                                                                                                                                                                            				direction = direction + camCFrame.RightVector
                                                                                                                                                                                                                                                                            			end
                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                        			-- Élévation (Espace / Ctrl)
                                                                                                                                                                                                                                                                                                    			if keysDown[Enum.KeyCode.Space] then
                                                                                                                                                                                                                                                                                                                				direction = direction + Vector3.new(0, 1, 0)
                                                                                                                                                                                                                                                                                                                                			end
                                                                                                                                                                                                                                                                                                                                            			if keysDown[Enum.KeyCode.LeftControl] then
                                                                                                                                                                                                                                                                                                                                                        				direction = direction - Vector3.new(0, 1, 0)
                                                                                                                                                                                                                                                                                                                                                                        			end
                                                                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                    			bodyGyro.cframe = camCFrame
                                                                                                                                                                                                                                                                                                                                                                                                			if direction.Magnitude > 0 then
                                                                                                                                                                                                                                                                                                                                                                                                            				bodyVelocity.velocity = direction.Unit * flySpeed
                                                                                                                                                                                                                                                                                                                                                                                                                            			else
                                                                                                                                                                                                                                                                                                                                                                                                                                        				bodyVelocity.velocity = Vector3.new(0, 0, 0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                        			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                    		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                local function stopFly()
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	flying = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    	if bodyGyro then bodyGyro:Destroy() end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        	if bodyVelocity then bodyVelocity:Destroy() end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	local character = player.Character
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	if character then
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    		local humanoid = character:FindFirstChildOfClass("Humanoid")
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            		if humanoid then humanoid.PlatformStand = false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        	if gameProcessed then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            	keysDown[input.KeyCode] = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                UserInputService.InputEnded:Connect(function(input)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	keysDown[input.KeyCode] = nil
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    -- =============================================================================
-- ÉLÉMENTS DE L'INTERFACE (BOUTONS & CONTROLES)
-- =============================================================================

-- Fonction utilitaire pour créer un bouton
local function createButton(name, position, size, text, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Parent = button
    
    return button
end

-- Bouton Principal: Activer Tout
local MasterToggle = createButton("MasterToggle", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 50), 
    "🔴 ACTIVER TOUT", Color3.fromRGB(40, 40, 50))

local featureActive = false

MasterToggle.MouseButton1Click:Connect(function()
    featureActive = not featureActive
    CONFIG.EspEnabled = featureActive
    CONFIG.FovEnabled = featureActive
    CONFIG.AimbotEnabled = featureActive
    
    if featureActive then
        MasterToggle.Text = "🟢 TOUT ACTIF"
        MasterToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        MasterToggle.Text = "🔴 ACTIVER TOUT"
        MasterToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        clearEspBoxes()
        fovCircle.Visible = false
    end
end)

-- Section ESP
local EspLabel = Instance.new("TextLabel")
EspLabel.Name = "EspLabel"
EspLabel.Size = UDim2.new(1, 0, 0, 20)
EspLabel.Position = UDim2.new(0, 0, 0, 60)
EspLabel.BackgroundTransparency = 1
EspLabel.Text = "📦 ESP Box"
EspLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
EspLabel.Font = Enum.Font.GothamSemibold
EspLabel.TextSize = 12
EspLabel.TextXAlignment = Enum.TextXAlignment.Left
EspLabel.Parent = Container

-- Section FOV
local FovLabel = Instance.new("TextLabel")
FovLabel.Name = "FovLabel"
FovLabel.Size = UDim2.new(1, 0, 0, 20)
FovLabel.Position = UDim2.new(0, 0, 0, 85)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "⭕ FOV Radius: " .. CONFIG.FovRadius
FovLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
FovLabel.Font = Enum.Font.GothamSemibold
FovLabel.TextSize = 12
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.Parent = Container

-- Boutons FOV
local FovMinusBtn = createButton("FovMinus", UDim2.new(0, 0, 0, 110), UDim2.new(0.3, -5, 0, 35), 
    "FOV -", Color3.fromRGB(50, 50, 60))

local FovPlusBtn = createButton("FovPlus", UDim2.new(0.7, 5, 0, 110), UDim2.new(0.3, -5, 0, 35), 
    "FOV +", Color3.fromRGB(50, 50, 60))

FovMinusBtn.MouseButton1Click:Connect(function()
    CONFIG.FovRadius = math.max(CONFIG.FovRadius - 50, CONFIG.FovMinRadius)
    FovLabel.Text = "⭕ FOV Radius: " .. CONFIG.FovRadius
end)

FovPlusBtn.MouseButton1Click:Connect(function()
    CONFIG.FovRadius = math.min(CONFIG.FovRadius + 50, CONFIG.FovMaxRadius)
    FovLabel.Text = "⭕ FOV Radius: " .. CONFIG.FovRadius
end)

-- Section Vitesse
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 155)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ Fly Speed: " .. flySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = Container

-- Boutons Vitesse
local SpeedMinusBtn = createButton("SpeedMinus", UDim2.new(0, 0, 0, 180), UDim2.new(0.3, -5, 0, 35), 
    "SPEED -", Color3.fromRGB(50, 50, 60))

local SpeedPlusBtn = createButton("SpeedPlus", UDim2.new(0.7, 5, 0, 180), UDim2.new(0.3, -5, 0, 35), 
    "SPEED +", Color3.fromRGB(50, 50, 60))

SpeedMinusBtn.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 10, 10)
    SpeedLabel.Text = "⚡ Fly Speed: " .. flySpeed
end)

SpeedPlusBtn.MouseButton1Click:Connect(function()
    flySpeed = math.min(flySpeed + 10, 250)
    SpeedLabel.Text = "⚡ Fly Speed: " .. flySpeed
end)

-- Bouton Fly
local FlyBtn = createButton("FlyToggle", UDim2.new(0, 0, 0, 225), UDim2.new(1, 0, 0, 40), 
    "✈️ Fly: OFF", Color3.fromRGB(40, 40, 50))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    FlyBtn.MouseButton1Click:Connect(function()
    if not flying then
        startFly()
        FlyBtn.Text = "✈️ Fly: ON"
        FlyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        stopFly()
        FlyBtn.Text = "✈️ Fly: OFF"
        FlyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end

-- Gestion de la vitesse fly
local function updateFlySpeed()
    if flying and bodyVelocity then
        bodyVelocity.velocity = bodyVelocity.velocity.Unit * flySpeed
    end
end

-- Nettoyage des ressources
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if flying then stopFly() end
    end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        