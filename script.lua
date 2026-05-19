local TITRE_MENU = "Mon Serveur Discord"
local TEXTE_BOUTON = "Rejoindre le Discord (Copier le lien)"
local LIEN_DISCORD = "https://discord.gg/7mevSZ33A" -- Met ton lien d'invitation Discord ici !

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local DiscordButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
local CloseButton = Instance.new("TextButton")

ScreenGui.Name = "DiscordPromptGui"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 15)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = TITRE_MENU
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18

DiscordButton.Name = "DiscordButton"
DiscordButton.Parent = MainFrame
DiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
DiscordButton.Position = UDim2.new(0.05, 0, 0.5, -5)
DiscordButton.Size = UDim2.new(0.9, 0, 0, 45)
DiscordButton.Font = Enum.Font.GothamSemibold
DiscordButton.Text = TEXTE_BOUTON
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextSize = 14

ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = DiscordButton

CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseButton.TextSize = 16

DiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LIEN_DISCORD)
        DiscordButton.Text = "Lien copié ! (Ctrl + V)"
        DiscordButton.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
        task.wait(2)
        DiscordButton.Text = TEXTE_BOUTON
        DiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    else
        DiscordButton.Text = "Erreur : Impossible de copier"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
