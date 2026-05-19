--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                   ESP SYSTEM — Competitive Shooter               ║
    ║              Clean • Neon Style • Optimized • Toggleable         ║
    ╚══════════════════════════════════════════════════════════════════╝

    FEATURES:
        • 2D bounding boxes fitted to player characters
        • Tracers from top-center of screen to enemy boxes
        • Team check  — skips teammates
        • Visibility check — color changes when enemy is visible
        • Distance check  — hides targets beyond max range
        • Toggle system   — keybind to enable/disable ESP
        • Custom neon colors per state (visible / hidden)
        • Optimized render loop (RunService.RenderStepped)
        • All drawing objects pooled per player (no leaks)

    USAGE:
        Paste into a LocalScript inside StarterPlayerScripts.
        Press [RightShift] to toggle the ESP on/off.

    API USED:
        Drawing  — Roblox's built-in immediate-mode 2D drawing library.
        Camera   — Workspace.CurrentCamera
        RunService.RenderStepped — fires every frame, synced to render.
]]

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────────────────────────────────
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInputSvc = game:GetService("UserInputService")

-- ─────────────────────────────────────────────────────────────────────────────
-- REFERENCES
-- ─────────────────────────────────────────────────────────────────────────────
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ─────────────────────────────────────────────────────────────────────────────
-- CONFIGURATION  — edit these values to customise behaviour
-- ─────────────────────────────────────────────────────────────────────────────
local CONFIG = {

    -- Toggle keybind (Enum.KeyCode)
    ToggleKey = Enum.KeyCode.RightShift,

    -- Maximum distance (studs) at which ESP is drawn; set to math.huge to disable
    MaxDistance = 500,

    -- Box settings
    Box = {
        Thickness   = 1.5,   -- line width in pixels
        Transparency = 1,    -- 1 = fully opaque
    },

    -- Tracer settings
    Tracer = {
        Thickness    = 1,
        Transparency = 0.85,
    },

    -- Neon colours
    Colors = {
        -- Enemy is visible (clear line-of-sight)
        Visible   = Color3.fromRGB(0, 255, 180),   -- cyan-green neon
        -- Enemy is occluded / behind a wall
        Hidden    = Color3.fromRGB(255, 60,  60),  -- red neon
        -- Tracer tint (usually matches box)
        Tracer    = Color3.fromRGB(255, 220,  0),  -- yellow neon
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- STATE
-- ─────────────────────────────────────────────────────────────────────────────
local espEnabled = true   -- toggled by ToggleKey

--[[
    drawPool stores all Drawing objects for each player so we can
    update or remove them cleanly without creating new objects every frame.

    Structure:
        drawPool[player] = {
            box    = { top, bottom, left, right },  -- 4 Line objects
            tracer = Line object,
        }
]]
local drawPool = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- DRAWING HELPERS
-- ─────────────────────────────────────────────────────────────────────────────

--- Creates a Drawing.Line with sensible defaults.
-- @return Drawing  the new line object
local function newLine()
    local line          = Drawing.new("Line")
    line.Visible        = false
    line.Thickness      = 1
    line.Transparency   = 1
    line.Color          = Color3.new(1, 1, 1)
    line.ZIndex         = 5
    return line
end

--- Allocates the full set of Drawing objects for one player.
-- @param  player  Player  the target
local function createDrawingsForPlayer(player)
    drawPool[player] = {
        -- Box is drawn as four separate lines (top, bottom, left, right)
        box = {
            top    = newLine(),
            bottom = newLine(),
            left   = newLine(),
            right  = newLine(),
        },
        tracer = newLine(),
    }
end

--- Destroys and removes all Drawing objects belonging to a player.
-- @param  player  Player  the target
local function removeDrawingsForPlayer(player)
    local data = drawPool[player]
    if not data then return end

    -- Remove box lines
    for _, line in pairs(data.box) do
        line:Remove()
    end
    data.tracer:Remove()

    drawPool[player] = nil
end

--- Hides (but keeps allocated) all drawings for a player.
-- Called when the player is out of range, on the same team, etc.
-- @param  data  table  the pool entry for this player
local function hideDrawings(data)
    for _, line in pairs(data.box) do
        line.Visible = false
    end
    data.tracer.Visible = false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- GEOMETRY HELPERS
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    Computes a 2-D screen-space bounding box for a humanoid character.

    We sample six attachment points on the character:
        HumanoidRootPart (centre), Head top, and four limb extremities.
    This gives a tight box that follows the character reliably.

    Returns: minX, minY, maxX, maxY in screen pixels  (or nil on failure)
]]
local function getCharacterBounds(character)
    local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
    local head         = character:FindFirstChild("Head")
    if not humanoidRoot or not head then return nil end

    -- Sample world-space positions we want to project
    local positions = {
        humanoidRoot.Position,
        head.Position + Vector3.new(0, head.Size.Y / 2, 0),  -- top of head
    }

    -- Also sample limb tips when available for a tighter box
    local limbs = { "LeftFoot", "RightFoot", "LeftHand", "RightHand",
                    "LeftLowerLeg", "RightLowerLeg" }
    for _, limbName in ipairs(limbs) do
        local part = character:FindFirstChild(limbName)
        if part then
            table.insert(positions, part.Position)
        end
    end

    local minX, minY =  math.huge,  math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false

    for _, worldPos in ipairs(positions) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        if onScreen then
            anyOnScreen = true
            if screenPos.X < minX then minX = screenPos.X end
            if screenPos.Y < minY then minY = screenPos.Y end
            if screenPos.X > maxX then maxX = screenPos.X end
            if screenPos.Y > maxY then maxY = screenPos.Y end
        end
    end

    if not anyOnScreen then return nil end

    -- Add a small padding so the box doesn't clip the model edges
    local pad = 4
    return minX - pad, minY - pad, maxX + pad, maxY + pad
end

--- Returns true if there is a clear line-of-sight from the local camera to
---  the target's HumanoidRootPart (simple raycast, ignores teammates).
-- @param  targetRoot  BasePart
-- @return boolean
local function isVisible(targetRoot)
    local origin    = Camera.CFrame.Position
    local direction = (targetRoot.Position - origin)
    local distance  = direction.Magnitude

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, targetRoot.Parent }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(origin, direction.Unit * distance, rayParams)
    -- If nothing was hit the path is clear
    return result == nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TEAM CHECK
-- ─────────────────────────────────────────────────────────────────────────────

--- Returns true if 'other' is on the same team as the local player.
-- @param  other  Player
-- @return boolean
local function isSameTeam(other)
    -- If the game uses Teams service, compare Team objects
    if LocalPlayer.Team and other.Team then
        return LocalPlayer.Team == other.Team
    end
    -- Fallback: compare TeamColor
    return LocalPlayer.TeamColor == other.TeamColor
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CORE RENDER FUNCTION
-- ─────────────────────────────────────────────────────────────────────────────

--- Updates ESP visuals for a single target player.
-- @param  player  Player   the enemy to draw
local function renderPlayer(player)
    local data = drawPool[player]
    if not data then return end

    -- ── Guard: character & humanoid must be alive ─────────────────────────
    local character = player.Character
    if not character then
        hideDrawings(data)
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        hideDrawings(data)
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        hideDrawings(data)
        return
    end

    -- ── Guard: distance check ─────────────────────────────────────────────
    local localRoot = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot then
        local dist = (rootPart.Position - localRoot.Position).Magnitude
        if dist > CONFIG.MaxDistance then
            hideDrawings(data)
            return
        end
    end

    -- ── Compute screen-space bounding box ─────────────────────────────────
    local minX, minY, maxX, maxY = getCharacterBounds(character)
    if not minX then
        hideDrawings(data)
        return
    end

    -- ── Visibility check → choose colour ──────────────────────────────────
    local visible  = isVisible(rootPart)
    local boxColor = visible and CONFIG.Colors.Visible or CONFIG.Colors.Hidden

    -- ── Draw the four box edges ────────────────────────────────────────────
    local box = data.box
    local th  = CONFIG.Box.Thickness
    local tr  = CONFIG.Box.Transparency

    -- Top edge
    box.top.From         = Vector2.new(minX, minY)
    box.top.To           = Vector2.new(maxX, minY)
    box.top.Color        = boxColor
    box.top.Thickness    = th
    box.top.Transparency = tr
    box.top.Visible      = true

    -- Bottom edge
    box.bottom.From         = Vector2.new(minX, maxY)
    box.bottom.To           = Vector2.new(maxX, maxY)
    box.bottom.Color        = boxColor
    box.bottom.Thickness    = th
    box.bottom.Transparency = tr
    box.bottom.Visible      = true

    -- Left edge
    box.left.From         = Vector2.new(minX, minY)
    box.left.To           = Vector2.new(minX, maxY)
    box.left.Color        = boxColor
    box.left.Thickness    = th
    box.left.Transparency = tr
    box.left.Visible      = true

    -- Right edge
    box.right.From         = Vector2.new(maxX, minY)
    box.right.To           = Vector2.new(maxX, maxY)
    box.right.Color        = boxColor
    box.right.Thickness    = th
    box.right.Transparency = tr
    box.right.Visible      = true

    -- ── Draw the tracer ───────────────────────────────────────────────────
    local vp          = Camera.ViewportSize
    local tracerStart = Vector2.new(vp.X / 2, 0)      -- top-centre of screen
    local tracerEnd   = Vector2.new(                   -- bottom-centre of the box
        (minX + maxX) / 2,
        maxY
    )

    data.tracer.From         = tracerStart
    data.tracer.To           = tracerEnd
    data.tracer.Color        = CONFIG.Colors.Tracer
    data.tracer.Thickness    = CONFIG.Tracer.Thickness
    data.tracer.Transparency = CONFIG.Tracer.Transparency
    data.tracer.Visible      = true
end

-- ─────────────────────────────────────────────────────────────────────────────
-- PLAYER LIFECYCLE — add / remove drawing pools automatically
-- ─────────────────────────────────────────────────────────────────────────────

local function onPlayerAdded(player)
    -- Skip the local player — we never draw ESP on ourselves
    if player == LocalPlayer then return end
    createDrawingsForPlayer(player)
end

local function onPlayerRemoving(player)
    removeDrawingsForPlayer(player)
end

-- Hook existing players
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- ─────────────────────────────────────────────────────────────────────────────
-- TOGGLE KEYBIND
-- ─────────────────────────────────────────────────────────────────────────────

UserInputSvc.InputBegan:Connect(function(input, gameProcessed)
    -- Ignore inputs that the game already consumed (e.g. chat)
    if gameProcessed then return end

    if input.KeyCode == CONFIG.ToggleKey then
        espEnabled = not espEnabled

        -- When disabling, immediately hide all active drawings
        if not espEnabled then
            for _, data in pairs(drawPool) do
                hideDrawings(data)
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- RENDER LOOP  — RenderStepped fires before the frame is drawn
-- ─────────────────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip local player
        if player == LocalPlayer then continue end

        -- Skip teammates
        if isSameTeam(player) then
            local data = drawPool[player]
            if data then hideDrawings(data) end
            continue
        end

        renderPlayer(player)
    end
end)
