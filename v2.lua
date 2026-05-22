-- [[ ZentyHub – Kick a Brainrot UI Template ]] --

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

-- Fenêtre Principale (Style Vert Sombre et Transparent / Vitre)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 30, 15)
MainFrame.BackgroundTransparency = 0.25 -- Transparence style vitre
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Permet de déplacer la fenêtre

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Titre du Hub
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.04, 0, 0.03, 0)
Title.Size = UDim2.new(0, 200, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "ZentyHub – Kick a Brainrot"
Title.TextColor3 = Color3.fromRGB(0, 255, 100) -- Vert Néon
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Cadre des Catégories (À DROITE comme demandé)
CategoriesFrame.Name = "CategoriesFrame"
CategoriesFrame.Parent = MainFrame
CategoriesFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 10)
CategoriesFrame.BackgroundTransparency = 0.5
CategoriesFrame.Position = UDim2.new(0.72, 0, 0.15, 0)
CategoriesFrame.Size = UDim2.new(0, 140, 0, 280)

UIListLayout.Parent = CategoriesFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Cadre du Contenu principal (À gauche des catégories)
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
ContentFrame.BackgroundTransparency = 0.6
ContentFrame.Position = UDim2.new(0.04, 0, 0.15, 0)
ContentFrame.Size = UDim2.new(0, 350, 0, 280)

-- FONCTION POUR AJOUTER LES BOUTONS DE TRICHE (Exemples requis)
local function createCheatToggle(name, callback)
    local ToggleButton = Instance.new("TextButton")
    local ToggleCorner = Instance.new("UICorner")
    
    ToggleButton.Name = name
    ToggleButton.Parent = ContentFrame
    -- Placement automatique simple pour l'exemple (à adapter avec un ListLayout si besoin)
    local existingToggles = #ContentFrame:GetChildren()
    ToggleButton.Position = UDim2.new(0.05, 0, 0.05 + (existingToggles * 0.13), 0)
    ToggleButton.Size = UDim2.new(0, 310, 0, 30)
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

-- FONCTION POUR CRÉER LES ONGLETS À DROITE
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

-- --- INITIALISATION DES CATÉGORIES (À droite) ---
createCategory("Main Farm")
createCategory("Multipliers")
createCategory("Teleports")

-- --- INITIALISATION DES FONCTIONS (Demandes spécifiques) ---
createCheatToggle("Auto-Perfect Kick", function(state)
    if state then
        print("Auto-Perfect activé")
        -- Insérer ici la logique ou le remote pour bloquer le curseur du Kick Meter au maximum
    else
        print("Auto-Perfect désactivé")
    end
end)

createCheatToggle("Collect All Money (Green Pad)", function(state)
    _G.CollectMoney = state
    while _G.CollectMoney do
        task.wait(1)
        print("Simulation de récolte sur le bouton vert...")
        -- Logique : Déplacer brièvement le HumanoidRootPart sur le pad vert du plot du joueur
    end
end)

createCheatToggle("Auto-Farm Weight & Train", function(state)
    if state then
        print("Auto-Farm d'entraînement activé")
    end
end)

createCheatToggle("Multiplier x2 Violet Stuff", function(state)
    if state then
        print("Recherche des bonus violets x2...")
    end
end)

print("ZentyHub chargé avec succès !")

