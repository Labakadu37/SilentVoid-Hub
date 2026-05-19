-- ╔══════════════════════════════════════════════╗
-- ║        AETHER HUB  —  LocalScript            ║
-- ║  Style : dark hub vert/noir type Lucky Block  ║
-- ║  Fly full options + touches natives gardées   ║
-- ╚══════════════════════════════════════════════╝

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ══════════════════════════════════════════════
--  CONSTANTES DESIGN  (inspiré screenshot)
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(14, 16, 14),
    SIDEBAR     = Color3.fromRGB(18, 22, 18),
    PANEL       = Color3.fromRGB(22, 28, 22),
    ROW         = Color3.fromRGB(26, 34, 26),
    ROW_HOVER   = Color3.fromRGB(32, 42, 32),
    GREEN       = Color3.fromRGB(80, 220, 60),
    GREEN_DIM   = Color3.fromRGB(40, 120, 30),
    GREEN_DARK  = Color3.fromRGB(20, 60, 15),
    ACCENT      = Color3.fromRGB(100, 255, 70),
    TEXT        = Color3.fromRGB(220, 235, 220),
    TEXT_DIM    = Color3.fromRGB(120, 150, 110),
    TEXT_BRIGHT = Color3.fromRGB(255, 255, 255),
    RED         = Color3.fromRGB(220, 60, 60),
    YELLOW      = Color3.fromRGB(255, 200, 40),
    BORDER      = Color3.fromRGB(50, 100, 40),
}

-- ══════════════════════════════════════════════
--  ÉTAT FLY
-- ══════════════════════════════════════════════
local fly = {
    enabled     = false,
    speed       = 60,
    upKey       = true,    -- Espace monte
    downKey     = true,    -- Ctrl descend
    mobileUp    = false,
    mobileDown  = false,
    noclip      = false,
    connection  = nil,
    bv          = nil,
    bg          = nil,
}

-- ══════════════════════════════════════════════
--  HELPERS GUI
-- ══════════════════════════════════════════════
local function corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end
local function stroke(col, thick, p)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BORDER
    s.Thickness = thick or 1
    s.Parent = p
    return s
end
local function lbl(props, parent)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextColor3 = C.TEXT
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    for k,v in pairs(props) do l[k]=v end
    l.Parent = parent
    return l
end
local function frame(props, parent)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k]=v end
    f.Parent = parent
    return f
end
local function btn(props, parent)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = C.TEXT_BRIGHT
    b.TextSize = 13
    b.AutoButtonColor = false
    for k,v in pairs(props) do b[k]=v end
    b.Parent = parent
    return b
end

-- ══════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "AetherHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = player.PlayerGui

-- Fenêtre principale
local win = frame({
    Size = UDim2.new(0, 560, 0, 400),
    Position = UDim2.new(0.5, -280, 0.5, -200),
    BackgroundColor3 = C.BG,
    Active = true,
    Draggable = true,
}, sg)
corner(10, win)
stroke(C.GREEN_DIM, 1.5, win)

-- ── Barre titre ──────────────────────────────
local titleBar = frame({
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = C.SIDEBAR,
}, win)
corner(10, titleBar)

-- fix coin bas de titleBar visible
local titleFix = frame({
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = C.SIDEBAR,
}, titleBar)

lbl({
    Text = "⬡  Aether Hub",
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    TextColor3 = C.GREEN,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
}, titleBar)

-- Badge version
local verBadge = btn({
    Size = UDim2.new(0, 52, 0, 22),
    Position = UDim2.new(1, -170, 0, 8),
    BackgroundColor3 = C.PANEL,
    Text = "v2.0",
    TextSize = 11,
    TextColor3 = C.TEXT_DIM,
}, titleBar)
corner(20, verBadge)
stroke(C.BORDER, 1, verBadge)

-- Badge jeu
local gameBadge = btn({
    Size = UDim2.new(0, 100, 0, 22),
    Position = UDim2.new(1, -110, 0, 8),
    BackgroundColor3 = C.GREEN_DARK,
    Text = "✦ MultiGame",
    TextSize = 11,
    TextColor3 = C.GREEN,
}, titleBar)
corner(20, gameBadge)
stroke(C.GREEN_DIM, 1, gameBadge)

-- Bouton X
local closeB = btn({
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -36, 0, 5),
    BackgroundColor3 = Color3.fromRGB(40, 20, 20),
    Text = "✕",
    TextSize = 14,
    TextColor3 = C.RED,
}, titleBar)
corner(6, closeB)

-- Bouton —
local minB = btn({
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -68, 0, 5),
    BackgroundColor3 = C.PANEL,
    Text = "—",
    TextSize = 14,
    TextColor3 = C.TEXT_DIM,
}, titleBar)
corner(6, minB)

-- ── Sidebar ──────────────────────────────────
local sidebar = frame({
    Size = UDim2.new(0, 160, 1, -38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = C.SIDEBAR,
}, win)

-- Séparateur vertical
frame({
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = C.BORDER,
}, sidebar)

-- Search bar
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = C.PANEL
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "🔍 Search..."
searchBox.PlaceholderColor3 = C.TEXT_DIM
searchBox.Text = ""
searchBox.TextColor3 = C.TEXT
searchBox.TextSize = 12
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.Parent = sidebar
corner(6, searchBox)
stroke(C.BORDER, 1, searchBox)

-- Nav items
local navItems = {
    { icon = "⌂", label = "Home",     id = "home" },
    { icon = "⚙", label = "Fly",      id = "fly"  },
    { icon = "⬆", label = "Speed",    id = "speed"},
    { icon = "✦", label = "Options",  id = "opts" },
}

local navBtns = {}
local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 2)
navLayout.Parent = Instance.new("Frame", sidebar) -- container
local navContainer = sidebar:FindFirstChildOfClass("Frame")
navContainer.Size = UDim2.new(1, 0, 1, -50)
navContainer.Position = UDim2.new(0, 0, 0, 50)
navContainer.BackgroundTransparency = 1

for _, item in ipairs(navItems) do
    local nb = btn({
        Size = UDim2.new(1, -16, 0, 40),
        BackgroundColor3 = C.SIDEBAR,
        Text = "",
    }, navContainer)
    nb.LayoutOrder = _
    corner(6, nb)

    local iconL = lbl({
        Text = item.icon,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = C.TEXT_DIM,
        TextSize = 16,
    }, nb)
    local textL = lbl({
        Text = "| " .. item.label,
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        TextColor3 = C.TEXT_DIM,
        TextSize = 13,
    }, nb)

    navBtns[item.id] = { btn = nb, icon = iconL, text = textL }
end

-- Layout fix
navLayout.Parent = navContainer
local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 8)
navPad.PaddingRight = UDim.new(0, 8)
navPad.PaddingTop = UDim.new(0, 4)
navPad.Parent = navContainer

-- Avatar + pseudo
local avatarRow = frame({
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 1, -44),
    BackgroundColor3 = C.PANEL,
}, sidebar)
lbl({
    Text = "👤  " .. player.Name,
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    TextColor3 = C.TEXT_DIM,
    TextSize = 12,
}, avatarRow)

-- ── Zone contenu ─────────────────────────────
local content = frame({
    Size = UDim2.new(1, -160, 1, -38),
    Position = UDim2.new(0, 160, 0, 38),
    BackgroundTransparency = 1,
}, win)

-- ══════════════════════════════════════════════
--  PAGES
-- ══════════════════════════════════════════════
local pages = {}

local function newPage(id)
    local p = frame({
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    }, content)
    pages[id] = p
    return p
end

-- ── Titre de section ──
local function sectionTitle(text, parent)
    lbl({
        Text = text,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 14, 0, 10),
        TextColor3 = C.ACCENT,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
    }, parent)
end

-- ── Row toggle ──
local function makeRow(parent, yOff, title, sub, rightWidget)
    local row = frame({
        Size = UDim2.new(1, -20, 0, 52),
        Position = UDim2.new(0, 10, 0, yOff),
        BackgroundColor3 = C.ROW,
    }, parent)
    corner(8, row)
    stroke(Color3.fromRGB(35, 50, 30), 1, row)

    lbl({ Text = title, Size = UDim2.new(1, -110, 0, 24),
        Position = UDim2.new(0, 14, 0, 6),
        TextColor3 = C.TEXT_BRIGHT, TextSize = 13,
        Font = Enum.Font.GothamBold }, row)

    lbl({ Text = sub, Size = UDim2.new(1, -110, 0, 20),
        Position = UDim2.new(0, 14, 0, 28),
        TextColor3 = C.TEXT_DIM, TextSize = 11 }, row)

    -- Flèche droite
    lbl({ Text = "›", Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = C.GREEN, TextSize = 20 }, row)

    if rightWidget then rightWidget(row) end
    return row
end

-- ── Toggle switch ──
local function makeToggle(parent, initVal, onChange)
    local state = initVal or false
    local track = frame({
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -68, 0.5, -12),
        BackgroundColor3 = state and C.GREEN or C.PANEL,
    }, parent)
    corner(20, track)
    stroke(C.BORDER, 1, track)

    local knob = frame({
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = C.TEXT_BRIGHT,
    }, track)
    corner(20, knob)

    local function refresh()
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = state and C.GREEN or C.PANEL
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        }):Play()
    end

    local clickZone = btn({
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
    }, track)
    clickZone.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if onChange then onChange(state) end
    end)

    return {
        getState = function() return state end,
        setState = function(v)
            state = v
            refresh()
            if onChange then onChange(state) end
        end,
    }
end

-- ══════════════════════════════════════════════
--  PAGE HOME
-- ══════════════════════════════════════════════
local pHome = newPage("home")
sectionTitle("Home", pHome)

local welcomeBox = frame({
    Size = UDim2.new(1, -20, 0, 80),
    Position = UDim2.new(0, 10, 0, 40),
    BackgroundColor3 = C.GREEN_DARK,
}, pHome)
corner(10, welcomeBox)
stroke(C.GREEN_DIM, 1, welcomeBox)

lbl({ Text = "⚡  Bienvenue dans Aether Hub",
    Size = UDim2.new(1,-20,0,28), Position = UDim2.new(0,12,0,8),
    TextColor3 = C.GREEN, TextSize = 14, Font = Enum.Font.GothamBold }, welcomeBox)
lbl({ Text = "Script multi-jeux · Fly · Speed · Options\nPC & Mobile compatible",
    Size = UDim2.new(1,-20,0,40), Position = UDim2.new(0,12,0,36),
    TextColor3 = C.TEXT_DIM, TextSize = 11 }, welcomeBox)

local controlBox = frame({
    Size = UDim2.new(1,-20,0,110),
    Position = UDim2.new(0,10,0,130),
    BackgroundColor3 = C.ROW,
}, pHome)
corner(10, controlBox)
stroke(Color3.fromRGB(35,50,30),1,controlBox)
lbl({ Text = "Contrôles",
    Size=UDim2.new(1,-16,0,22), Position=UDim2.new(0,12,0,6),
    TextColor3=C.ACCENT, Font=Enum.Font.GothamBold, TextSize=13 }, controlBox)
lbl({ Text = "PC  ·  WASD = direction   |   Espace = monter   |   Ctrl = descendre\nMobile  ·  Boutons ▲▼ dans l'onglet Fly\n\nLes touches de saut/course native sont conservées !",
    Size=UDim2.new(1,-20,0,80), Position=UDim2.new(0,12,0,30),
    TextColor3=C.TEXT_DIM, TextSize=11 }, controlBox)

-- ══════════════════════════════════════════════
--  PAGE FLY
-- ══════════════════════════════════════════════
local pFly = newPage("fly")
sectionTitle("Fly", pFly)

-- Scroll
local flyScroll = Instance.new("ScrollingFrame")
flyScroll.Size = UDim2.new(1, 0, 1, -40)
flyScroll.Position = UDim2.new(0, 0, 0, 38)
flyScroll.BackgroundTransparency = 1
flyScroll.BorderSizePixel = 0
flyScroll.ScrollBarThickness = 4
flyScroll.ScrollBarImageColor3 = C.GREEN_DIM
flyScroll.CanvasSize = UDim2.new(0, 0, 0, 520)
flyScroll.Parent = pFly

local flyTog, noclipTog, upTog, downTog, boostTog

-- Row : Activer Fly
local r1 = makeRow(flyScroll, 4, "🚀 Activer le Fly", "Vole dans tous les jeux")
flyTog = makeToggle(r1, false, function(v)
    if v then startFly() else stopFly() end
end)

-- Row : NoClip pendant le fly
local r2 = makeRow(flyScroll, 62, "🧱 NoClip", "Traverse les murs en volant")
noclipTog = makeToggle(r2, false, function(v)
    fly.noclip = v
end)

-- Row : Espace monte
local r3 = makeRow(flyScroll, 120, "⬆  Espace = Monter", "La touche Saut fait monter en vol")
upTog = makeToggle(r3, true, function(v)
    fly.upKey = v
end)

-- Row : Ctrl descend
local r4 = makeRow(flyScroll, 178, "⬇  Ctrl = Descendre", "Ctrl gauche fait descendre en vol")
downTog = makeToggle(r4, true, function(v)
    fly.downKey = v
end)

-- Row : Boost vitesse espace
local r5 = makeRow(flyScroll, 236, "⚡ Boost Vertical ×2", "Espace/Ctrl applique un boost ×2")
boostTog = makeToggle(r5, false, function(v)
    fly.boost = v
end)

-- Boutons mobile monter/descendre
local mobileLabel = lbl({
    Text = "📱 Contrôles Mobile",
    Size=UDim2.new(1,-20,0,22), Position=UDim2.new(0,14,0,300),
    TextColor3=C.ACCENT, TextSize=13, Font=Enum.Font.GothamBold,
}, flyScroll)

local upMob = btn({
    Size=UDim2.new(0.44,0,0,44),
    Position=UDim2.new(0,10,0,326),
    BackgroundColor3=C.GREEN_DARK,
    Text="▲  Monter",
    TextColor3=C.GREEN,
    TextSize=13,
}, flyScroll)
corner(8, upMob)
stroke(C.GREEN_DIM,1,upMob)

local downMob = btn({
    Size=UDim2.new(0.44,0,0,44),
    Position=UDim2.new(0.5,4,0,326),
    BackgroundColor3=Color3.fromRGB(20,10,30),
    Text="▼  Descendre",
    TextColor3=Color3.fromRGB(180,120,255),
    TextSize=13,
}, flyScroll)
corner(8, downMob)
stroke(Color3.fromRGB(80,40,140),1,downMob)

-- Mobile hold
upMob.MouseButton1Down:Connect(function() fly.mobileUp = true end)
upMob.MouseButton1Up:Connect(function() fly.mobileUp = false end)
downMob.MouseButton1Down:Connect(function() fly.mobileDown = true end)
downMob.MouseButton1Up:Connect(function() fly.mobileDown = false end)

-- Statut fly en haut
local flyStatus = lbl({
    Text = "● Fly : OFF",
    Size=UDim2.new(1,-20,0,22), Position=UDim2.new(0,14,0,6),
    TextColor3=C.RED, TextSize=12, Font=Enum.Font.GothamBold,
}, pFly)

-- ══════════════════════════════════════════════
--  PAGE SPEED
-- ══════════════════════════════════════════════
local pSpeed = newPage("speed")
sectionTitle("Speed", pSpeed)

-- Vitesse affichée
local speedDisp = lbl({
    Text = "Vitesse actuelle : 60",
    Size=UDim2.new(1,-20,0,24), Position=UDim2.new(0,14,0,40),
    TextColor3=C.TEXT, TextSize=13, Font=Enum.Font.Gotham,
}, pSpeed)

-- Barre
local barBg = frame({
    Size=UDim2.new(1,-20,0,12),
    Position=UDim2.new(0,10,0,70),
    BackgroundColor3=C.PANEL,
}, pSpeed)
corner(6, barBg)
stroke(C.BORDER,1,barBg)
local barFill = frame({
    Size=UDim2.new(fly.speed/200,0,1,0),
    BackgroundColor3=C.GREEN,
}, barBg)
corner(6,barFill)

local function updateSpeed()
    fly.speed = math.clamp(fly.speed, 5, 200)
    speedDisp.Text = "Vitesse actuelle : " .. fly.speed
    TweenService:Create(barFill, TweenInfo.new(0.1), {
        Size = UDim2.new(fly.speed/200, 0, 1, 0)
    }):Play()
end

-- Presets
local presets = {
    { label="Lent\n20",    v=20  },
    { label="Normal\n60",  v=60  },
    { label="Rapide\n120", v=120 },
    { label="Max\n200",    v=200 },
}
for i, pr in ipairs(presets) do
    local pb = btn({
        Size=UDim2.new(0,74,0,44),
        Position=UDim2.new(0, 10+(i-1)*78, 0, 92),
        BackgroundColor3=C.ROW,
        Text=pr.label,
        TextSize=11,
        TextColor3=C.TEXT,
    }, pSpeed)
    corner(8,pb)
    stroke(C.BORDER,1,pb)
    pb.MouseButton1Click:Connect(function()
        fly.speed = pr.v
        updateSpeed()
    end)
end

-- +/-
local minusB = btn({
    Size=UDim2.new(0,52,0,38),
    Position=UDim2.new(0,10,0,148),
    BackgroundColor3=C.PANEL,
    Text="−10",
    TextSize=14,
    TextColor3=C.RED,
}, pSpeed)
corner(8,minusB)

local plus10 = btn({
    Size=UDim2.new(0,52,0,38),
    Position=UDim2.new(0,68,0,148),
    BackgroundColor3=C.PANEL,
    Text="+10",
    TextSize=14,
    TextColor3=C.GREEN,
}, pSpeed)
corner(8,plus10)

local plus50 = btn({
    Size=UDim2.new(0,52,0,38),
    Position=UDim2.new(0,126,0,148),
    BackgroundColor3=C.PANEL,
    Text="+50",
    TextSize=14,
    TextColor3=C.ACCENT,
}, pSpeed)
corner(8,plus50)

minusB.MouseButton1Click:Connect(function() fly.speed = fly.speed - 10 updateSpeed() end)
plus10.MouseButton1Click:Connect(function() fly.speed = fly.speed + 10 updateSpeed() end)
plus50.MouseButton1Click:Connect(function() fly.speed = fly.speed + 50 updateSpeed() end)

-- WalkSpeed
lbl({ Text = "──── WalkSpeed (sol) ────",
    Size=UDim2.new(1,-20,0,22), Position=UDim2.new(0,14,0,200),
    TextColor3=C.ACCENT, TextSize=12, Font=Enum.Font.GothamBold }, pSpeed)

local wsDisp = lbl({ Text = "WalkSpeed : 16",
    Size=UDim2.new(1,-20,0,20), Position=UDim2.new(0,14,0,226),
    TextColor3=C.TEXT_DIM, TextSize=12 }, pSpeed)

local wsBar = frame({ Size=UDim2.new(1,-20,0,8), Position=UDim2.new(0,10,0,250),
    BackgroundColor3=C.PANEL }, pSpeed)
corner(4,wsBar)
local wsFill = frame({ Size=UDim2.new(16/500,0,1,0), BackgroundColor3=C.YELLOW }, wsBar)
corner(4,wsFill)

local walkSpeed = 16
local function updateWS()
    walkSpeed = math.clamp(walkSpeed,1,500)
    wsDisp.Text = "WalkSpeed : " .. walkSpeed
    TweenService:Create(wsFill,TweenInfo.new(0.1),{Size=UDim2.new(walkSpeed/500,0,1,0)}):Play()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = walkSpeed end
    end
end

local wsMinus = btn({ Size=UDim2.new(0,52,0,34), Position=UDim2.new(0,10,0,264),
    BackgroundColor3=C.PANEL, Text="−", TextSize=18, TextColor3=C.RED }, pSpeed)
corner(8,wsMinus)
local wsPlus = btn({ Size=UDim2.new(0,52,0,34), Position=UDim2.new(0,68,0,264),
    BackgroundColor3=C.PANEL, Text="+", TextSize=18, TextColor3=C.GREEN }, pSpeed)
corner(8,wsPlus)
local wsReset = btn({ Size=UDim2.new(0,80,0,34), Position=UDim2.new(0,126,0,264),
    BackgroundColor3=C.GREEN_DARK, Text="Reset", TextSize=13, TextColor3=C.GREEN }, pSpeed)
corner(8,wsReset)

wsMinus.MouseButton1Click:Connect(function() walkSpeed=walkSpeed-4 updateWS() end)
wsPlus.MouseButton1Click:Connect(function() walkSpeed=walkSpeed+4 updateWS() end)
wsReset.MouseButton1Click:Connect(function() walkSpeed=16 updateWS() end)

-- ══════════════════════════════════════════════
--  PAGE OPTIONS
-- ══════════════════════════════════════════════
local pOpts = newPage("opts")
sectionTitle("Options", pOpts)

local optsScroll = Instance.new("ScrollingFrame")
optsScroll.Size = UDim2.new(1,0,1,-40)
optsScroll.Position = UDim2.new(0,0,0,38)
optsScroll.BackgroundTransparency = 1
optsScroll.BorderSizePixel = 0
optsScroll.ScrollBarThickness = 4
optsScroll.ScrollBarImageColor3 = C.GREEN_DIM
optsScroll.CanvasSize = UDim2.new(0,0,0,380)
optsScroll.Parent = pOpts

-- Infinite Jump
local r_ij = makeRow(optsScroll, 4, "🌀 Infinite Jump", "Saute à l'infini")
local ijState = false
local ijTog = makeToggle(r_ij, false, function(v) ijState = v end)

UIS.JumpRequest:Connect(function()
    if ijState then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- Anti-AFK
local r_afk = makeRow(optsScroll, 62, "💤 Anti-AFK", "Évite le kick inactivité")
local afkLoop
makeToggle(r_afk, false, function(v)
    if v then
        afkLoop = RunService.Heartbeat:Connect(function()
            local vjs = game:GetService("VirtualInputManager")
            -- Simulate movement silently (compatible Roblox)
        end)
        player.Idled:Connect(function()
            -- jump trick
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Jump = true end
            end
        end)
    else
        if afkLoop then afkLoop:Disconnect() afkLoop = nil end
    end
end)

-- BrightSkin (fullbright)
local r_fb = makeRow(optsScroll, 120, "☀ FullBright", "Éclaire toute la map")
local fbConn
makeToggle(r_fb, false, function(v)
    if v then
        fbConn = RunService.RenderStepped:Connect(function()
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
        end)
    else
        if fbConn then fbConn:Disconnect() fbConn = nil end
        game:GetService("Lighting").Brightness = 1
    end
end)

-- FOV
lbl({ Text = "──── FOV ────",
    Size=UDim2.new(1,-20,0,22), Position=UDim2.new(0,14,0,172),
    TextColor3=C.ACCENT, TextSize=12, Font=Enum.Font.GothamBold }, optsScroll)

local fovDisp = lbl({ Text = "FOV : 70",
    Size=UDim2.new(1,-20,0,20), Position=UDim2.new(0,14,0,196),
    TextColor3=C.TEXT_DIM, TextSize=12 }, optsScroll)

local fov = 70
local fovMinus = btn({ Size=UDim2.new(0,52,0,34), Position=UDim2.new(0,10,0,220),
    BackgroundColor3=C.PANEL, Text="−5", TextSize=14, TextColor3=C.RED }, optsScroll)
corner(8,fovMinus)
local fovPlus = btn({ Size=UDim2.new(0,52,0,34), Position=UDim2.new(0,68,0,220),
    BackgroundColor3=C.PANEL, Text="+5", TextSize=14, TextColor3=C.GREEN }, optsScroll)
corner(8,fovPlus)
local fovReset = btn({ Size=UDim2.new(0,80,0,34), Position=UDim2.new(0,126,0,220),
    BackgroundColor3=C.GREEN_DARK, Text="Reset", TextSize=13, TextColor3=C.GREEN }, optsScroll)
corner(8,fovReset)

local function applyFOV()
    fov = math.clamp(fov,40,120)
    fovDisp.Text = "FOV : " .. fov
    workspace.CurrentCamera.FieldOfView = fov
end
fovMinus.MouseButton1Click:Connect(function() fov=fov-5 applyFOV() end)
fovPlus.MouseButton1Click:Connect(function() fov=fov+5 applyFOV() end)
fovReset.MouseButton1Click:Connect(function() fov=70 applyFOV() end)

-- Reset Stats
local resetBtn = btn({
    Size=UDim2.new(1,-20,0,40), Position=UDim2.new(0,10,0,270),
    BackgroundColor3=Color3.fromRGB(40,16,16),
    Text="🔄  Reset toutes les options",
    TextSize=13, TextColor3=C.RED,
}, optsScroll)
corner(8,resetBtn)
stroke(C.RED,1,resetBtn)
resetBtn.MouseButton1Click:Connect(function()
    fly.speed = 60
    updateSpeed()
    walkSpeed = 16
    updateWS()
    fov = 70
    applyFOV()
end)

-- ══════════════════════════════════════════════
--  FLY ENGINE
-- ══════════════════════════════════════════════
function stopFly()
    fly.enabled = false
    if fly.connection then fly.connection:Disconnect() fly.connection = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand = false end
        if fly.bv then fly.bv:Destroy() fly.bv = nil end
        if fly.bg then fly.bg:Destroy() fly.bg = nil end
    end
    flyStatus.Text = "● Fly : OFF"
    flyStatus.TextColor3 = C.RED
end

function startFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    fly.bv = Instance.new("BodyVelocity")
    fly.bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    fly.bv.Velocity = Vector3.zero
    fly.bv.Parent = hrp

    fly.bg = Instance.new("BodyGyro")
    fly.bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    fly.bg.D = 100
    fly.bg.P = 1000
    fly.bg.CFrame = hrp.CFrame
    fly.bg.Parent = hrp

    fly.enabled = true
    flyStatus.Text = "● Fly : ON"
    flyStatus.TextColor3 = C.GREEN

    fly.connection = RunService.Heartbeat:Connect(function()
        if not fly.enabled then return end
        local char2 = player.Character
        if not char2 then stopFly() return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then stopFly() return end

        -- NoClip
        if fly.noclip then
            for _, p in ipairs(char2:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end

        local cam = workspace.CurrentCamera
        local cf  = cam.CFrame
        local dir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end

        -- Vertical : touches si activées
        local vMult = fly.boost and 2 or 1
        if (fly.upKey and UIS:IsKeyDown(Enum.KeyCode.Space)) or fly.mobileUp then
            dir = dir + Vector3.new(0, vMult, 0)
        end
        if (fly.downKey and UIS:IsKeyDown(Enum.KeyCode.LeftControl)) or fly.mobileDown then
            dir = dir - Vector3.new(0, vMult, 0)
        end

        if dir.Magnitude > 0 then
            dir = dir.Unit * fly.speed
        end

        fly.bv.Velocity = dir
        fly.bg.CFrame = cf
    end)
end

-- ══════════════════════════════════════════════
--  NAVIGATION
-- ══════════════════════════════════════════════
local currentPage = "home"

local function switchPage(id)
    for pid, p in pairs(pages) do
        p.Visible = (pid == id)
    end
    for nid, nb in pairs(navBtns) do
        local active = (nid == id)
        TweenService:Create(nb.btn, TweenInfo.new(0.12), {
            BackgroundColor3 = active and C.GREEN_DARK or C.SIDEBAR
        }):Play()
        nb.icon.TextColor3 = active and C.GREEN or C.TEXT_DIM
        nb.text.TextColor3 = active and C.GREEN or C.TEXT_DIM
    end
    currentPage = id
end

switchPage("home")

for id, nb in pairs(navBtns) do
    nb.btn.MouseButton1Click:Connect(function()
        switchPage(id)
    end)
end

-- ══════════════════════════════════════════════
--  CLOSE / MINIMIZE
-- ══════════════════════════════════════════════
closeB.MouseButton1Click:Connect(function()
    stopFly()
    sg:Destroy()
end)

local minimized = false
minB.MouseButton1Click:Connect(function()
    minimized = not minimized
    sidebar.Visible = not minimized
    content.Visible = not minimized
    win.Size = minimized
        and UDim2.new(0, 560, 0, 38)
        or  UDim2.new(0, 560, 0, 400)
    minB.Text = minimized and "□" or "—"
end)

-- ══════════════════════════════════════════════
--  RESPAWN
-- ══════════════════════════════════════════════
player.CharacterAdded:Connect(function()
    task.wait(0.6)
    fly.bv = nil
    fly.bg = nil
    if fly.connection then fly.connection:Disconnect() fly.connection = nil end
    if fly.enabled then
        startFly()
    end
    -- Réappliquer walkspeed
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = walkSpeed end
    end
end)
