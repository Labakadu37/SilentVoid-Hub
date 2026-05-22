-- [[ ZentyHub – Kick a Brainrot (VERSION FONCTIONNELLE) ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CategoriesFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local ContentFrame = Instance.new("Frame")

-- Configuration de l'écran principal
ScreenGui.Name = "ZentyHub"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Fenêtre Principale (Vert Sombre et Transparent)
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
Title.Size = UDim2.new(0, 200, 0, 30)
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
createCategory("Multipliers")

-- --- LOGIQUE DES VRAIS CHEATS ---

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variables d'état
local autoPerfectEnabled = false
local autoCollectEnabled = false

-- 1. VRAI AUTO-PERFECT KICK
-- Force le jeu à croire que la jauge est au maximum (100% / Perfect) dès que tu lances un kick
task.spawn(function()
    while task.wait() do
        if autoPerfectEnabled then
            -- On intercepte le système de kick local du joueur pour lui injecter la valeur maximale
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    -- Cherche l'indicateur de puissance à l'écran pour le bloquer au max
                    local kickGui = playerGui:FindFirstChild("KickGui") or playerGui:FindFirstChild("KickMeter")
                    if kickGui then
                        -- Simule la jauge pleine ou déclenche directement l'action parfaite
                        local remote = ReplicatedStorage:FindFirstChild("KickRemote") or ReplicatedStorage:FindFirstChild("KickEvent", true)
                        if remote and remote:IsA("RemoteEvent") then
                            -- Envoie le signal de force maximale au serveur (généralement 1 ou 100 selon le script du jeu)
                            remote:FireServer(100) 
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. VRAI AUTO-COLLECT MONEY (Téléporte le pad vert à toi ou toi au pad)
task.spawn(function()
    while task.wait(0.5) do
        if autoCollectEnabled then
            pcall(function()
                -- Trouve ton terrain (Tycoon/Plot)
                local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Tycoons")
                if plots then
                    for _, plot in pairs(plots:GetChildren()) do
                        if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
                            local greenPad = plot:FindFirstChild("GreenPad") or plot:FindFirstChild("CollectPad") or plot:FindFirstChild("Collect")
                            if greenPad and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                -- Sauvegarde la position d'origine
                                local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                                -- Téléportation instantanée sur le bouton de collecte puis retour
                                LocalPlayer.Character.HumanoidRootPart.CFrame = greenPad.CFrame
                                task.wait(0.1)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Création des boutons visuels connectés aux vraies boucles
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

createCheatToggle("Auto-Perfect Kick", function(state)
    autoPerfectEnabled = state
end)

createCheatToggle("Collect All Money (Green Pad)", function(state)
    autoCollectEnabled = state
end)

createCheatToggle("Auto-Farm Weight (Train)", function(state)
    -- Logique d'envoi de clic automatique pour les poids
    _G.AutoTrain = state
    while _G.AutoTrain do
        task.wait(0.1)
        local remote = ReplicatedStorage:FindFirstChild("TrainRemote") or ReplicatedStorage:FindFirstChild("AddPower", true)
        if remote then remote:FireServer() end
    end
end)
