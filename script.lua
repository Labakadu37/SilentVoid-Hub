--[[
    Professional Competitive Visual Framework
    Style: Neon, High Performance
    Engine: Roblox (Client-Side / LocalScript)
    API: Drawing API
--]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Configuration Framework
local Config = {
    Enabled = true,
    TeamCheck = true,
    VisibilityCheck = true,
    DistanceCheck = true,
    MaxDistance = 500, -- Studs
    
    Visuals = {
        BoxColor = Color3.fromRGB(0, 255, 137),       -- Neon Emerald
        HiddenColor = Color3.fromRGB(255, 30, 70),    -- Neon Red (If visibility check enabled)
        TracerColor = Color3.fromRGB(0, 180, 255),    -- Neon Cyan
        Thickness = 1.5,
        Transparency = 0.9,
    }
}

--// Cache & Storage
local RenderCache = {}
local RaycastParamsInstance = RaycastParams.new()
RaycastParamsInstance.FilterType = Enum.RaycastFilterType.Exclude

--// Helper Functions
local function IsAlive(player)
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function CheckVisibility(character, origin)
    local targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    if not targetPart then return false end
    
    -- Exclude local player character and target character from blocking the ray
    RaycastParamsInstance.FilterDescendantsInstances = {LocalPlayer.Character, character}
    
    local direction = targetPart.Position - origin
    local raycastResult = Workspace:Raycast(origin, direction, RaycastParamsInstance)
    
    -- If nothing intersected, the target is completely visible
    return raycastResult == nil
end

--// Object-Oriented Player Visual Class
local PlayerVisual = {}
PlayerVisual.__index = PlayerVisual

function PlayerVisual.new(player)
    local self = setmetatable({}, PlayerVisual)
    self.Player = player
    
    -- Instantiating Drawing Objects
    self.Box = Drawing.new("Square")
    self.Box.Visible = false
    self.Box.Thickness = Config.Visuals.Thickness
    self.Box.Color = Config.Visuals.BoxColor
    self.Box.Filled = false
    self.Box.Transparency = Config.Visuals.Transparency
    
    self.Tracer = Drawing.new("Line")
    self.Tracer.Visible = false
    self.Tracer.Thickness = Config.Visuals.Thickness
    self.Tracer.Color = Config.Visuals.TracerColor
    self.Tracer.Transparency = Config.Visuals.Transparency
    
    return self
end

function PlayerVisual:Update()
    -- Fail-safe validation checks
    if not Config.Enabled or not IsAlive(self.Player) or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        self:Hide()
        return
    end
    
    -- Team Check Logic
    if Config.TeamCheck and self.Player.Team == LocalPlayer.Team then
        self:Hide()
        return
    end
    
    local character = self.Player.Character
    local rootPart = character.HumanoidRootPart
    local cameraPos = Camera.CFrame.Position
    
    -- Distance Check Logic
    local distance = (rootPart.Position - cameraPos).Magnitude
    if Config.DistanceCheck and distance > Config.MaxDistance then
        self:Hide()
        return
    end
    
    -- Transform 3D Position into 2D Screen Space
    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        self:Hide()
        return
    end
    
    -- Calculate precise scale boundary fields bounding the character model
    -- Bounding heuristics approximate 3D Extents cleanly over distances
    local extentsHeight = 5
    local scaleFactor = (extentsHeight * Camera.ViewportSize.Y) / (2 * distance * math.tan(math.rad(Camera.FieldOfView / 2)))
    local boxWidth = scaleFactor * 0.85
    local boxHeight = scaleFactor * 1.15
    
    -- Dynamic Vector Positioning
    local screenX = rootPos.X - (boxWidth / 2)
    local screenY = rootPos.Y - (boxHeight / 2)
    
    -- Visibility Raycasting Calculations
    local isVisible = true
    if Config.VisibilityCheck then
        isVisible = CheckVisibility(character, cameraPos)
    end
    
    -- Updating Properties on Render Loop Thread
    self.Box.Size = Vector2.new(boxWidth, boxHeight)
    self.Box.Position = Vector2.new(screenX, screenY)
    self.Box.Color = isVisible and Config.Visuals.BoxColor or Config.Visuals.HiddenColor
    self.Box.Visible = true
    
    -- Screen Top-Center Line Tracers
    self.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
    self.Tracer.To = Vector2.new(rootPos.X, screenY)
    self.Tracer.Color = Config.Visuals.TracerColor
    self.Tracer.Visible = true
end

function PlayerVisual:Hide()
    self.Box.Visible = false
    self.Tracer.Visible = false
end

function PlayerVisual:Destroy()
    self:Hide()
    self.Box:Remove()
    self.Tracer:Remove()
end

--// Driver Tracking Initialization
local function CharacterAdded(player)
    if player == LocalPlayer then return end
    if not RenderCache[player] then
        RenderCache[player] = PlayerVisual.new(player)
    end
end

local function PlayerAdded(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5) -- Acknowledge character components building completely
        CharacterAdded(player)
    end)
    if player.Character then
        CharacterAdded(player)
    end
end

local function PlayerRemoving(player)
    if RenderCache[player] then
        RenderCache[player]:Destroy()
        RenderCache[player] = nil
    end
end

--// Process Setup Execution Loops
for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

-- Main Optimized Frame Synchronization Update Node
local RenderConnection
RenderConnection = RunService.RenderStepped:Connect(function()
    for player, visualObject in pairs(RenderCache) do
        -- Safe environment verification error protection
        local success, err = pcall(function()
            visualObject:Update()
        end)
        if not success then
            warn("Rendering system validation exception caught: " .. tostring(err))
        end
    end
end)

--// Public External API Handle Interface
local FrameworkManager = {}

function FrameworkManager:Toggle(state)
    Config.Enabled = state
    if not state then
        for _, visualObject in pairs(RenderCache) do
            visualObject:Hide()
        end
    end
end

function FrameworkManager:UpdateConfig(newConfig)
    for index, value in pairs(newConfig) do
        if type(value) == "table" then
            for subIndex, subValue in pairs(value) do
                Config[index][subIndex] = subValue
            end
        else
            Config[index] = value
        end
    end
end

return FrameworkManager
