-- [[ ZentyHub – Kick a Brainrot (Knit Architecture Edition) ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CategoriesFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local ContentFrame = Instance.new("Frame")

-- GUI Setup (Style Vert Transparent)
ScreenGui.Name = "ZentyHub"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 30, 15)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.04, 0, 0.03, 0)
Title.Size = UDim2.new(0, 250, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "ZentyHub – Kick a Brainrot"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

CategoriesFrame.Name = "CategoriesFrame"
CategoriesFrame.Parent = MainFrame
CategoriesFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 10)
CategoriesFrame.BackgroundTransparency = 0.5
CategoriesFrame.Position = UDim2.new(0.72, 0, 0.15, 0)
CategoriesFrame.Size = UDim2.new(0, 140, 0, 280)

UIListLayout.Parent = CategoriesFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
ContentFrame.BackgroundTransparency = 0.6
ContentFrame.Position = UDim2.new(0.04, 0, 0.15, 0)
ContentFrame.Size = UDim2.new(0, 350, 0, 280)

local function createCategory(name)
    local CatButton = Instance.new("TextButton")
    local CatCorner = Instance.new("UICorner")
    CatButton.Name = name
    CatButton.Parent = CategoriesFrame
    CatButton.Size = UDim2.new(1, 0, 0, 35)
    CatButton.BackgroundColor3 = Color3.fromRGB(25, 60, 25)
    CatButton.Font = Enum.Font.GothamMedium
    CatButton.Text = name
    CatButton.TextColor3 = Color3.fromRGB(0, 255, 120)
    CatButton.TextSize = 14
    CatCorner.CornerRadius = UDim.new(0, 6)
    CatCorner.Parent = CatButton
end

createCategory("Main Farm")

-- --- RECHERCHE DES SERVICES DU JEU ---
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KnitEvents = ReplicatedStorage:FindFirstChild("Knit") and ReplicatedStorage.Knit:FindFirstChild("Services")

-- Variables d'activation
local autoPerfect = false
local autoCollect = false
local autoWeight = false

-- 1. BOUCLE AUTO-PERFECT FORCÉ via les Remotes générés par Knit
task.spawn(function()
    while task.wait(0.1) do
        if autoPerfect and KnitEvents then
            pcall(function()
                -- Knit génère les services côté client ici. On cherche le service lié au Kick.
                local kickService = KnitEvents:FindFirstChild("KickService")
                if kickService then
                    -- On déclenche le Remote du kick parfait. 
                    -- Souvent nommé 'Kick' ou 'Release', on cherche l'événement à l'intérieur
                    local remote = kickService:FindFirstChild("Kick") or kickService:FindFirstChild("RF") or kickService:FindFirstChild("RE")
                    if remote then
                        -- Envoi du signal parfait (1 ou 100 selon l'argument attendu par le KickController)
                        remote:FireServer(100)
                    end
                end
            end)
        end
    end
end)

-- 2. BOUCLE AUTO-COLLECT (SELL)
task.spawn(function()
    while task.wait(0.5) do
        if autoCollect then
            pcall(function()
                -- On cherche le PlotService généré par Knit pour forcer la vente à distance
                if KnitEvents and KnitEvents:FindFirstChild("PlotService") then
                    local sellRemote = KnitEvents.PlotService:FindFirstChild("Sell") or KnitEvents.PlotService:FindFirstChild("Claim")
                    if sellRemote then
                        sellRemote:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 3. BOUCLE AUTO-WEIGHT (TRAIN)
task.spawn(function()
    while task.wait(0.2) do
        if autoWeight then
            pcall(function()
                if KnitEvents and KnitEvents:FindFirstChild("WeightService") then
                    local trainRemote = KnitEvents.WeightService:FindFirstChild("Train") or KnitEvents.WeightService:FindFirstChild("AddPower")
                    if trainRemote then
                        trainRemote:FireServer()
                    end
                end
            end)
        end
    end
end)

-- --- CRÉATION DES UTILS / BOUTONS ---
local function createCheatToggle(name, callback)
    local ToggleButton = Instance.new("TextButton")
    local ToggleCorner = Instance.new("UICorner")
    
    ToggleButton.Name = name
    ToggleButton.Parent = ContentFrame
    local existingToggles = #ContentFrame:GetChildren()
    ToggleButton.Position = UDim2.new(0.05, 0, 0.05 + (existingToggles * 0.14), 0)
    ToggleButton.Size = UDim2.new(0, 310, 0, 32)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = name .. " : OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleButton
    
    local enabled = false
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 70)
            ToggleButton.Text = name .. " : ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
            ToggleButton.Text = name .. " : OFF"
        end
        callback(enabled)
    end)
end

createCheatToggle("Auto-Perfect Kick", function(state) autoPerfect = state end)
createCheatToggle("Auto-Collect Money", function(state) autoCollect = state end)
createCheatToggle("Auto-Train Weight", function(state) autoWeight = state end)
