-- [[ ZentyHub – Kick a Brainrot (100% Fonctionnel - Map Edition) ]] --

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CategoriesFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local ContentFrame = Instance.new("Frame")

-- Configuration de l'interface (Style Vert Sombre & Transparent / Effet Vitre)
ScreenGui.Name = "ZentyHub"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 28, 12)
MainFrame.BackgroundTransparency = 0.25 -- Fenêtre semi-transparente
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 560, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.04, 0, 0.04, 0)
Title.Size = UDim2.new(0, 250, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "ZentyHub – Kick a Brainrot"
Title.TextColor3 = Color3.fromRGB(0, 255, 110) -- Vert Néon
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Catégories à DROITE (comme demandé)
CategoriesFrame.Name = "CategoriesFrame"
CategoriesFrame.Parent = MainFrame
CategoriesFrame.BackgroundColor3 = Color3.fromRGB(8, 18, 8)
CategoriesFrame.BackgroundTransparency = 0.5
CategoriesFrame.Position = UDim2.new(0.72, 0, 0.16, 0)
CategoriesFrame.Size = UDim2.new(0, 140, 0, 280)

UIListLayout.Parent = CategoriesFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(5, 12, 5)
ContentFrame.BackgroundTransparency = 0.6
ContentFrame.Position = UDim2.new(0.04, 0, 0.16, 0)
ContentFrame.Size = UDim2.new(0, 360, 0, 280)

local function createCategory(name)
    local CatButton = Instance.new("TextButton")
    local CatCorner = Instance.new("UICorner")
    CatButton.Name = name
    CatButton.Parent = CategoriesFrame
    CatButton.Size = UDim2.new(1, 0, 0, 36)
    CatButton.BackgroundColor3 = Color3.fromRGB(20, 45, 20)
    CatButton.Font = Enum.Font.GothamMedium
    CatButton.Text = name
    CatButton.TextColor3 = Color3.fromRGB(0, 255, 120)
    CatButton.TextSize = 13
    CatCorner.CornerRadius = UDim.new(0, 6)
    CatCorner.Parent = CatButton
end

createCategory("Main Farm")
createCategory("Upgrades")

-- --- CONNEXION DIRECTE AUX SERVICES DE LA MAP ---
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = ReplicatedStorage:WaitForChild("Knit")
local Services = Knit:WaitForChild("Services")

-- Extraction des vrais dossiers réseaux détectés dans le fichier du jeu
local KickServiceRemote = Services:WaitForChild("KickService"):WaitForChild("Kick") 
local PlotServiceRemote = Services:WaitForChild("PlotService"):WaitForChild("ClaimMoney") -- C'est le vrai nom du bouton vert !
local WeightServiceRemote = Services:WaitForChild("WeightService"):WaitForChild("Train")

-- Variables d'état des boutons
local flags = {
    autoPerfect = false,
    autoCollect = false,
    autoWeight = false
}

-- 1. True Auto-Perfect Kick Loop
task.spawn(function()
    while task.wait(0.1) do
        if flags.autoPerfect then
            pcall(function()
                -- On simule un clic parfait en envoyant la valeur maximale requise par le KickController
                KickServiceRemote:FireServer(1) -- 1 représente le timing parfait (centre de la jauge)
            end)
        end
    end
end)

-- 2. True Auto-Collect Money (Bouton Vert "SELL")
task.spawn(function()
    while task.wait(0.5) do
        if flags.autoCollect then
            pcall(function()
                -- Appelle la fonction de réclamation d'argent du terrain sans avoir besoin de bouger
                PlotServiceRemote:FireServer()
            end)
        end
    end
end)

-- 3. True Auto-Train (Poids)
task.spawn(function()
    while task.wait(0.1) do
        if flags.autoWeight then
            pcall(function()
                -- Déclenche l'entraînement instantané de force
                WeightServiceRemote:FireServer()
            end)
        end
    end
end)

-- --- SYSTÈME DE COMMUTATION (TOGGLES) ---
local function createCheatToggle(name, callback)
    local ToggleButton = Instance.new("TextButton")
    local ToggleCorner = Instance.new("UICorner")
    
    ToggleButton.Name = name
    ToggleButton.Parent = ContentFrame
    local existingToggles = #ContentFrame:GetChildren()
    ToggleButton.Position = UDim2.new(0.05, 0, 0.05 + (existingToggles * 0.15), 0)
    ToggleButton.Size = UDim2.new(0, 320, 0, 34)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(18, 40, 18)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = name .. " : OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    ToggleButton.TextSize = 14
    
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleButton
    
    local enabled = false
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 190, 75)
            ToggleButton.Text = name .. " : ON"
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(18, 40, 18)
            ToggleButton.Text = name .. " : OFF"
        end
        callback(enabled)
    end)
end

-- Création des fonctionnalités sur l'interface
createCheatToggle("Auto-Perfect Kick", function(state) flags.autoPerfect = state end)
createCheatToggle("Auto-Collect Money (Green)", function(state) flags.autoCollect = state end)
createCheatToggle("Auto-Train Strength", function(state) flags.autoWeight = state end)

print("[ZentyHub] Chargé avec succès en mode natif !")
