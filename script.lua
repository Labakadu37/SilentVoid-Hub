```lua
-- ZentyHub.lua
-- Unified script with premium UI, ESP, and Lock-on Aim system
-- Style: Phantom Violet | Transparent Black/Violet | Glow | Smooth Animations

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--[[
	CONFIGURATION & STATE
--]]

local Config = {
	ESP = {
		Enabled = true,
		Color = Color3.fromRGB(170, 0, 255), -- Violet
		OutlineThickness = 1.5,
		DistanceEnabled = true,
		ShowName = true,
		Font = Enum.Font.GothamBold,
		FontSize = Enum.FontSize.Size18,
	},
	Aimbot = {
		Enabled = false,
		FOVRadius = 120,
		FOVColor = Color3.fromRGB(170, 0, 255),
		FOVTransparency = 0.6,
		Smoothness = 0.15,
		TargetLine = true,
		TargetLineColor = Color3.fromRGB(170, 0, 255),
		TargetLineTransparency = 0.5,
	},
	UI = {
		Theme = {
			Background = Color3.fromRGB(15, 0, 30),
			BackgroundTransparency = 0.3,
			Accent = Color3.fromRGB(170, 0, 255),
			Glow = Color3.fromRGB(170, 0, 255),
			TextColor = Color3.fromRGB(230, 230, 230),
			ToggleOn = Color3.fromRGB(170, 0, 255),
			ToggleOff = Color3.fromRGB(70, 0, 100),
		},
		AnimationTime = 0.3,
	},
}

local State = {
	AimbotTarget = nil,
	AimbotLocked = false,
}

--[[
	UTILS
--]]

local function Create(className, props)
	local obj = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			if k == "Parent" then
				obj.Parent = v
			elseif k == "Children" then
				for _, child in ipairs(v) do
					child.Parent = obj
				end
			elseif k == "AnchorPoint" and typeof(v) == "Vector2" then
				obj.AnchorPoint = v
			elseif k == "Position" and typeof(v) == "UDim2" then
				obj.Position = v
			elseif k == "Size" and typeof(v) == "UDim2" then
				obj.Size = v
			elseif k == "Font" then
				obj.Font = v
			elseif k == "TextSize" then
				obj.TextSize = v
			elseif k == "TextColor3" then
				obj.TextColor3 = v
			elseif k == "BackgroundColor3" then
				obj.BackgroundColor3 = v
			elseif k == "BackgroundTransparency" then
				obj.BackgroundTransparency = v
			elseif k == "BorderSizePixel" then
				obj.BorderSizePixel = v
			elseif k == "Visible" then
				obj.Visible = v
			elseif k == "ZIndex" then
				obj.ZIndex = v
			elseif k == "Text" then
				obj.Text = v
			elseif k == "TextWrapped" then
				obj.TextWrapped = v
			elseif k == "TextXAlignment" then
				obj.TextXAlignment = v
			elseif k == "TextYAlignment" then
				obj.TextYAlignment = v
			elseif k == "AutoButtonColor" then
				obj.AutoButtonColor = v
			elseif k == "Image" then
				obj.Image = v
			elseif k == "ImageColor3" then
				obj.ImageColor3 = v
			elseif k == "ImageTransparency" then
				obj.ImageTransparency = v
			elseif k == "ClipsDescendants" then
				obj.ClipsDescendants = v
			elseif k == "Selectable" then
				obj.Selectable = v
			elseif k == "MultiLine" then
				obj.MultiLine = v
			elseif k == "ClearTextOnFocus" then
				obj.ClearTextOnFocus = v
			elseif k == "PlaceholderText" then
				obj.PlaceholderText = v
			elseif k == "TextEditable" then
				obj.TextEditable = v
			elseif k == "TextStrokeTransparency" then
				obj.TextStrokeTransparency = v
			elseif k == "TextStrokeColor3" then
				obj.TextStrokeColor3 = v
			elseif k == "ZIndexBehavior" then
				obj.ZIndexBehavior = v
			elseif k == "LayoutOrder" then
				obj.LayoutOrder = v
			elseif k == "Name" then
				obj.Name = v
			elseif k == "Rotation" then
				obj.Rotation = v
			elseif k == "AnchorPoint" then
				obj.AnchorPoint = v
			elseif k == "TextScaled" then
				obj.TextScaled = v
			elseif k == "RichText" then
				obj.RichText = v
			elseif k == "Selectable" then
				obj.Selectable = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			elseif k == "Modal" then
				obj.Modal = v
			else
				pcall(function() obj[k] = v end)
			end
		end
	end
	return obj
end

local function Tween(obj, props, time, style, direction)
	style = style or Enum.EasingStyle.Quad
	direction = direction or Enum.EasingDirection.Out
	local tweenInfo = TweenInfo.new(time, style, direction)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

local function RoundCorners(frame, radius)
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = radius or UDim.new(0, 8)
	uicorner.Parent = frame
	return uicorner
end

local function GlowEffect(frame, color, intensity)
	local glow = Instance.new("ImageLabel")
	glow.Name = "GlowEffect"
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://3570695787" -- glow image
	glow.ImageColor3 = color
	glow.ImageTransparency = 1 - intensity
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(100, 100, 100, 100)
	glow.Size = UDim2.new(1, 20, 1, 20)
	glow.Position = UDim2.new(0, -10, 0, -10)
	glow.ZIndex = frame.ZIndex - 1
	glow.Parent = frame
	return glow
end

local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

--[[
	ESP SYSTEM
--]]

local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "ZentyHubESP"

local ESPBoxes = {}

local function CreateESPBox(player)
	local box = Instance.new("Frame")
	box.Name = "ESPBox"
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.ZIndex = 10
	box.Visible = false

	local outline = Instance.new("UIStroke", box)
	outline.Thickness = Config.ESP.OutlineThickness
	outline.Color = Config.ESP.Color
	outline.Transparency = 0
	outline.LineJoinMode = Enum.LineJoinMode.Round

	local border = Instance.new("Frame", box)
	border.Name = "Border"
	border.AnchorPoint = Vector2.new(0.5, 0.5)
	border.BackgroundTransparency = 1
	border.BorderColor3 = Config.ESP.Color
	border.BorderSizePixel = 2
	border.Size = UDim2.new(1, 0, 1, 0)
	border.Position = UDim2.new(0.5, 0, 0.5, 0)
	border.ZIndex = 11

	local nameLabel = Instance.new("TextLabel", box)
	nameLabel.Name = "NameLabel"
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Config.ESP.Color
	nameLabel.Font = Config.ESP.Font
	nameLabel.TextSize = 16
	nameLabel.TextStrokeTransparency = 0.75
	nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.Position = UDim2.new(0.5, 0, 0, -20)
	nameLabel.AnchorPoint = Vector2.new(0.5, 0)
	nameLabel.ZIndex = 12
	nameLabel.Text = ""

	local distanceLabel = Instance.new("TextLabel", box)
	distanceLabel.Name = "DistanceLabel"
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextColor3 = Config.ESP.Color
	distanceLabel.Font = Config.ESP.Font
	distanceLabel.TextSize = 14
	distanceLabel.TextStrokeTransparency = 0.75
	distanceLabel.TextStrokeColor3 = Color3.new(0,0,0)
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	distanceLabel.Position = UDim2.new(0.5, 0, 1, 2)
	distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
	distanceLabel.ZIndex = 12
	distanceLabel.Text = ""

	box.Parent = ZentyHubUI.ESPContainer
	return {
		Box = box,
		NameLabel = nameLabel,
		DistanceLabel = distanceLabel,
	}
end

local function UpdateESP()
	if not Config.ESP.Enabled then
		for _, esp in pairs(ESPBoxes) do
			esp.Box.Visible = false
		end
		return
	end

	for player, esp in pairs(ESPBoxes) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player ~= LocalPlayer then
			local rootPart = player.Character.HumanoidRootPart
			local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
			if onScreen then
				local sizeFactor = 300 / (pos.Z)
				local boxSize = Vector2.new(100, 150) * sizeFactor
				esp.Box.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
				esp.Box.Position = UDim2.new(0, pos.X, 0, pos.Y)
				esp.Box.Visible = true

				esp.NameLabel.Text = Config.ESP.ShowName and player.Name or ""
				if Config.ESP.DistanceEnabled then
					local dist = (rootPart.Position - Camera.CFrame.Position).Magnitude
					esp.DistanceLabel.Text = string.format("%.0f studs", dist)
				else
					esp.DistanceLabel.Text = ""
				end
			else
				esp.Box.Visible = false
			end
		else
			esp.Box.Visible = false
		end
	end
end

--[[
	AIMBOT LOCK-ON SYSTEM
--]]

local AimCircle = nil
local TargetLine = nil

local function CreateAimCircle()
	local circle = Instance.new("Frame")
	circle.Name = "AimFOVCircle"
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.BackgroundTransparency = 1
	circle.Size = UDim2.new(0, Config.Aimbot.FOVRadius * 2, 0, Config.Aimbot.FOVRadius * 2)
	circle.Position = UDim2.new(0.5, 0, 0.5, 0)
	circle.ZIndex = 20
	circle.Parent = ZentyHubUI.AimbotContainer

	local circleImage = Instance.new("ImageLabel", circle)
	circleImage.Name = "CircleImage"
	circleImage.BackgroundTransparency = 1
	circleImage.Size = UDim2.new(1, 0, 1, 0)
	circleImage.Image = "rbxassetid://3570695787" -- glow circle
	circleImage.ImageColor3 = Config.Aimbot.FOVColor
	circleImage.ImageTransparency = Config.Aimbot.FOVTransparency
	circleImage.ScaleType = Enum.ScaleType.Slice
	circleImage.SliceCenter = Rect.new(100, 100, 100, 100)
	circleImage.ZIndex = 21

	return circle
end

local function CreateTargetLine()
	local line = Instance.new("Frame")
	line.Name = "TargetLine"
	line.AnchorPoint = Vector2.new(0.5, 0)
	line.BackgroundColor3 = Config.Aimbot.TargetLineColor
	line.BackgroundTransparency = Config.Aimbot.TargetLineTransparency
	line.Size = UDim2.new(0, 2, 0, 0)
	line.Position = UDim2.new(0.5, 0, 0.5, 0)
	line.ZIndex = 22
	line.Parent = ZentyHubUI.AimbotContainer
	return line
end

local function GetClosestTarget()
	local closestPlayer = nil
	local closestDistance = math.huge
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
			if onScreen then
				local screenPos = Vector2.new(rootPos.X, rootPos.Y)
				local dist = (screenPos - mousePos).Magnitude
				if dist < Config.Aimbot.FOVRadius and dist < closestDistance then
					closestDistance = dist
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

local function AimAt(target)
	if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
	local rootPart = target.Character.HumanoidRootPart
	local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
	if not onScreen then return end

	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	local targetPos = Vector2.new(rootPos.X, rootPos.Y)
	local newPos = mousePos:Lerp(targetPos, Config.Aimbot.Smoothness)
	mousemoverel(newPos.X - mousePos.X, newPos.Y - mousePos.Y)
end

--[[
	UI SYSTEM
--]]

local ZentyHubUI = {}

local function CreateMainUI()
	local screenGui = Create("ScreenGui", {
		Name = "ZentyHub",
		Parent = game:GetService("CoreGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	-- Main Frame
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		Size = UDim2.new(0, 480, 0, 360),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Config.UI.Theme.Background,
		BackgroundTransparency = Config.UI.Theme.BackgroundTransparency,
		BorderSizePixel = 0,
		ZIndex = 50,
	})
	RoundCorners(mainFrame, UDim.new(0, 16))
	GlowEffect(mainFrame, Config.UI.Theme.Glow, 0.3)

	-- Title Bar
	local titleBar = Create("Frame", {
		Name = "TitleBar",
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		ZIndex = 51,
	})
	local titleLabel = Create("TextLabel", {
		Name = "TitleLabel",
		Parent = titleBar,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		BackgroundTransparency = 1,
		Text = "ZentyHub",
		Font = Enum.Font.GothamBlack,
		TextSize = 24,
		TextColor3 = Config.UI.Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 52,
	})
	local closeButton = Create("TextButton", {
		Name = "CloseButton",
		Parent = titleBar,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -40, 0, 5),
		BackgroundColor3 = Config.UI.Theme.ToggleOff,
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Config.UI.Theme.TextColor,
		AutoButtonColor = false,
		ZIndex = 52,
	})
	RoundCorners(closeButton, UDim.new(0, 6))
	GlowEffect(closeButton, Config.UI.Theme.Accent, 0.5)

	closeButton.MouseEnter:Connect(function()
		Tween(closeButton, {BackgroundColor3 = Config.UI.Theme.Accent}, 0.2)
		Tween(closeButton, {TextColor3 = Color3.new(1,1,1)}, 0.2)
	end)
	closeButton.MouseLeave:Connect(function()
		Tween(closeButton, {BackgroundColor3 = Config.UI.Theme.ToggleOff}, 0.2)
		Tween(closeButton, {TextColor3 = Config.UI.Theme.TextColor}, 0.2)
	end)
	closeButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)

	-- Categories List
	local categoriesFrame = Create("Frame", {
		Name = "CategoriesFrame",
		Parent = mainFrame,
		Size = UDim2.new(0, 120, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundTransparency = 1,
		ZIndex = 51,
	})
	local categoriesList = Create("UIListLayout", {
		Parent = categoriesFrame,
		Padding = UDim.new(0, 8),
	})
	categoriesList.SortOrder = Enum.SortOrder.LayoutOrder

	-- Content Frame
	local contentFrame = Create("Frame", {
		Name = "ContentFrame",
		Parent = mainFrame,
		Size = UDim2.new(1, -120, 1, -40),
		Position = UDim2.new(0, 120, 0, 40),
		BackgroundTransparency = 1,
		ZIndex = 51,
	})

	-- Glow behind content
	local contentGlow = Create("ImageLabel", {
		Name = "ContentGlow",
		Parent = contentFrame,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(0, -20, 0, -20),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Config.UI.Theme.Glow,
		ImageTransparency = 0.85,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		ZIndex = 50,
	})

	-- Scroll for content
	local contentScrollingFrame = Create("ScrollingFrame", {
		Name = "ContentScrolling",
		Parent = contentFrame,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(0, 0, 1, 0),
		ZIndex = 52,
	})
	local contentLayout = Create("UIListLayout", {
		Parent = contentScrollingFrame,
		Padding = UDim.new(0, 12),
	})
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Store references
	ZentyHubUI.ScreenGui = screenGui
	ZentyHubUI.MainFrame = mainFrame
	ZentyHubUI.CategoriesFrame = categoriesFrame
	ZentyHubUI.ContentFrame = contentFrame
	ZentyHubUI.ContentScrolling = contentScrollingFrame
	ZentyHubUI.ContentLayout = contentLayout

	return screenGui
end

local function CreateCategoryButton(name, parent, order)
	local btn = Create("TextButton", {
		Name = name .. "Button",
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Config.UI.Theme.ToggleOff,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Config.UI.Theme.TextColor,
		AutoButtonColor = false,
		LayoutOrder = order,
		ZIndex = 52,
	})
	RoundCorners(btn, UDim.new(0, 10))
	GlowEffect(btn, Config.UI.Theme.Accent, 0.4)

	btn.MouseEnter:Connect(function()
		Tween(btn, {BackgroundColor3 = Config.UI.Theme.Accent}, 0.2)
		Tween(btn, {TextColor3 = Color3.new(1,1,1)}, 0.2)
	end)
	btn.MouseLeave:Connect(function()
		Tween(btn, {BackgroundColor3 = Config.UI.Theme.ToggleOff}, 0.2)
		Tween(btn, {TextColor3 = Config.UI.Theme.TextColor}, 0.2)
	end)

	return btn
end

local function CreateToggle(name, parent, default, callback)
	local container = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		ZIndex = 52,
	})
	local label = Create("TextLabel", {
		Parent = container,
		Size = UDim2.new(0.7, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Config.UI.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 53,
	})
	local toggleBtn = Create("TextButton", {
		Parent = container,
		Size = UDim2.new(0, 50, 0, 24),
		Position = UDim2.new(1, -60, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = default and Config.UI.Theme.ToggleOn or Config.UI.Theme.ToggleOff,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 53,
	})
	RoundCorners(toggleBtn, UDim.new(0, 12))

	local circle = Create("Frame", {
		Parent = toggleBtn,
		Size = UDim2.new(0, 20, 0, 20),
		Position = default and UDim2.new(1, -20, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
		BackgroundColor3 = Color3.new(1,1,1),
		ZIndex = 54,
	})
	RoundCorners(circle, UDim.new(0, 10))

	local toggled = default

	local function SetToggle(state)
		toggled = state
		if toggled then
			Tween(toggleBtn, {BackgroundColor3 = Config.UI.Theme.ToggleOn}, Config.UI.AnimationTime)
			Tween(circle, {Position = UDim2.new(1, -20, 0.5, -10)}, Config.UI.AnimationTime)
		else
			Tween(toggleBtn, {BackgroundColor3 = Config.UI.Theme.ToggleOff}, Config.UI.AnimationTime)
			Tween(circle, {Position = UDim2.new(0, 4, 0.5, -10)}, Config.UI.AnimationTime)
		end
		if callback then
			callback(toggled)
		end
	end

	toggleBtn.MouseButton1Click:Connect(function()
		SetToggle(not toggled)
	end)

	return container, SetToggle
end

local function CreateSlider(name, parent, min, max, default, callback)
	local container = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		ZIndex = 52,
	})
	local label = Create("TextLabel", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Config.UI.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 53,
	})

	local sliderBar = Create("Frame", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = Config.UI.Theme.ToggleOff,
		ZIndex = 53,
	})
	RoundCorners(sliderBar, UDim.new(0, 6))

	local fillBar = Create("Frame", {
		Parent = sliderBar,
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Config.UI.Theme.ToggleOn,
		ZIndex = 54,
	})
	RoundCorners(fillBar, UDim.new(0, 6))

	local dragging = false

	local function UpdateSlider(inputPosX)
		local relativeX = math.clamp(inputPosX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
		local percent = relativeX / sliderBar.AbsoluteSize.X
		fillBar.Size = UDim2.new(percent, 0, 1, 0)
		local value = min + (max - min) * percent
		if callback then
			callback(value)
		end
	end

	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			UpdateSlider(input.Position.X)
		end
	end)
	sliderBar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateSlider(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return container
end

--[[
	BUILD UI CONTENT
--]]

local Categories = {
	"Aimbot",
	"Visual",
	"Player",
	"Movement",
	"Fun",
	"Settings",
}

local CategoryButtons = {}
local CurrentCategory = nil

local function ClearContent()
	for _, child in pairs(ZentyHubUI.ContentScrolling:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function BuildAimbotTab()
	ClearContent()
	local container = ZentyHubUI.ContentScrolling

	-- Enable Aimbot Toggle
	local toggle, setToggle = CreateToggle("Enable Aimbot", container, Config.Aimbot.Enabled, function(state)
		Config.Aimbot.Enabled = state
	end)
	toggle.Parent = container

	-- FOV Radius Slider
	local slider = CreateSlider("FOV Radius", container, 50, 300, Config.Aimbot.FOVRadius, function(value)
		Config.Aimbot.FOVRadius = value
		if AimCircle then
			AimCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
		end
	end)
	slider.Parent = container

	-- Smoothness Slider
	local smoothSlider = CreateSlider("Smoothness", container, 0.01, 0.5, Config.Aimbot.Smoothness, function(value)
		Config.Aimbot.Smoothness = value
	end)
	smoothSlider.Parent = container

	-- Target Line Toggle
	local targetLineToggle, setTargetLine = CreateToggle("Show Target Line", container, Config.Aimbot.TargetLine, function(state)
		Config.Aimbot.TargetLine = state
		if TargetLine then
			TargetLine.Visible = state
		end
	end)
	targetLineToggle.Parent = container
end

local function BuildVisualTab()
	ClearContent()
	local container = ZentyHubUI.ContentScrolling

	-- ESP Toggle
	local toggle, setToggle = CreateToggle("Enable ESP", container, Config.ESP.Enabled, function(state)
		Config.ESP.Enabled = state
	end)
	toggle.Parent = container

	-- Show Names Toggle
	local nameToggle, setNameToggle = CreateToggle("Show Names", container, Config.ESP.ShowName, function(state)
		Config.ESP.ShowName = state
	end)
	nameToggle.Parent = container

	-- Show Distance Toggle
	local distToggle, setDistToggle = CreateToggle("Show Distance", container, Config.ESP.DistanceEnabled, function(state)
		Config.ESP.DistanceEnabled = state
	end)
	distToggle.Parent = container
end

local function BuildPlayerTab()
	ClearContent()
	local container = ZentyHubUI.ContentScrolling

	local label = Create("TextLabel", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = "Player options coming soon...",
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Config.UI.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 53,
	})
end

local function BuildMovementTab()
	ClearContent()
	local container = ZentyHubUI.ContentScrolling

	local label = Create("TextLabel", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = "Movement options coming soon...",
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Config.UI.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 53,
	})
end

local function BuildFunTab()
	ClearContent()
	local container = ZentyHubUI.ContentScrolling

	local label = Create("TextLabel", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = "Fun options coming soon...",
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Config.UI.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 53,
	})
end

local function BuildSettingsTab()
	ClearContent()
	local container = ZentyHubUI.ContentScrolling

	-- UI Toggle (show/hide)
	local toggle, setToggle = CreateToggle("Show ZentyHub UI", container, true, function(state)
		ZentyHubUI.ScreenGui.Enabled = state
	end)
	toggle.Parent = container

	-- Reset Button
	local resetBtn = Create("TextButton", {
		Parent = container,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Config.UI.Theme.ToggleOff,
		Text = "Reset Settings",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Config.UI.Theme.TextColor,
		AutoButtonColor = false,
		ZIndex = 53,
	})
	RoundCorners(resetBtn, UDim.new(0, 10))
	GlowEffect(resetBtn, Config.UI.Theme.Accent, 0.4)

	resetBtn.MouseEnter:Connect(function()
		Tween(resetBtn, {BackgroundColor3 = Config.UI.Theme.Accent}, 0.2)
		Tween(resetBtn, {TextColor3 = Color3.new(1,1,1)}, 0.2)
	end)
	resetBtn.MouseLeave:Connect(function()
		Tween(resetBtn, {BackgroundColor3 = Config.UI.Theme.ToggleOff}, 0.2)
		Tween(resetBtn, {TextColor3 = Config.UI.Theme.TextColor}, 0.2)
	end)
	resetBtn.MouseButton1Click:Connect(function()
		-- Reset config to defaults
		Config.Aimbot.Enabled = false
		Config.Aimbot.FOVRadius = 120
		Config.Aimbot.Smoothness = 0.15
		Config.Aimbot.TargetLine = true
		Config.ESP.Enabled = true
		Config.ESP.ShowName = true
		Config.ESP.DistanceEnabled = true
		ZentyHubUI.ScreenGui.Enabled = true
		-- Rebuild current tab to reflect changes
		if CurrentCategory then
			if CurrentCategory == "Aimbot" then BuildAimbotTab()
			elseif CurrentCategory == "Visual" then BuildVisualTab()
			elseif CurrentCategory == "Settings" then BuildSettingsTab()
			end
		end
	end)
end

local function BuildCategoryContent(name)
	CurrentCategory = name
	if name == "Aimbot" then
		BuildAimbotTab()
	elseif name == "Visual" then
		BuildVisualTab()
	elseif name == "Player" then
		BuildPlayerTab()
	elseif name == "Movement" then
		BuildMovementTab()
	elseif name == "Fun" then
		BuildFunTab()
	elseif name == "Settings" then
		BuildSettingsTab()
	end
end

local function BuildCategories()
	for i, cat in ipairs(Categories) do
		local btn = CreateCategoryButton(cat, ZentyHubUI.CategoriesFrame, i)
		btn.MouseButton1Click:Connect(function()
			for _, b in pairs(CategoryButtons) do
				Tween(b, {BackgroundColor3 = Config.UI.Theme.ToggleOff}, 0.3)
				b.TextColor3 = Config.UI.Theme.TextColor
			end
			Tween(btn, {BackgroundColor3 = Config.UI.Theme.Accent}, 0.3)
			btn.TextColor3 = Color3.new(1,1,1)
			BuildCategoryContent(cat)
		end)
		CategoryButtons[cat] = btn
	end
	-- Select first category by default
	if #Categories > 0 then
		CategoryButtons[Categories[1]].BackgroundColor3 = Config.UI.Theme.Accent
		CategoryButtons[Categories[1]].TextColor3 = Color3.new(1,1,1)
		BuildCategoryContent(Categories[1])
	end
end

--[[
	INITIALIZATION
--]]

local function Init()
	ZentyHubUI.ScreenGui = CreateMainUI()
	BuildCategories()

	-- Create ESP boxes for all players
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
