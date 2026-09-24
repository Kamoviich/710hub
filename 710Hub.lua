-- 710Hub - Muscle Legends (2026)
-- Script único para Muscle Legends.
-- Features: Auto Train, Auto Rebirth, Auto Chests, Auto Hatch, Pet Manager,
-- Equip Best owned pets, teleport browser, Anti-AFK, Stop All.

if game.GameId ~= 1268927906 then
    warn("[710Hub] Este script é apenas para Muscle Legends.")
    return
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
local rEvents = RS:WaitForChild("rEvents")
local Backpack = LP:WaitForChild("Backpack")

local function getMuscleEvent()
    return LP:FindFirstChild("muscleEvent")
        or (LP.Character and LP.Character:FindFirstChild("muscleEvent"))
        or rEvents:FindFirstChild("muscleEvent")
end

local R = {
    Rebirth = rEvents:FindFirstChild("rebirthRemote"),
    Crystal = rEvents:FindFirstChild("openCrystalRemote"),
    Chest = rEvents:FindFirstChild("checkChestRemote"),
    EquipPet = rEvents:FindFirstChild("equipPetEvent"),
    EvolvePet = rEvents:FindFirstChild("petEvolveEvent"),
    Brawl = rEvents:FindFirstChild("brawlEvent"),
}

local S = {
    Train=false, Rebirth=false, Chests=false, Hatch=false, Brawl=false,
    HatchCrystal="Blue Crystal", RepDelay=.065, HatchDelay=.45,
}

local old = game:GetService("CoreGui"):FindFirstChild("710Hub_MuscleLegends")
if old then old:Destroy() end

LP.Idled:Connect(function()
    pcall(function()
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(.2)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

local function safeInvoke(remote, ...)
    if not remote then return nil end
    local args = table.pack(...)
    local ok, a, b = pcall(function()
        return remote:InvokeServer(table.unpack(args, 1, args.n))
    end)
    if ok then return a, b end
end

local function safeFire(remote, ...)
    if not remote then return end
    local args = table.pack(...)
    pcall(function()
        remote:FireServer(table.unpack(args, 1, args.n))
    end)
end

local CHESTS = {"Golden Chest","Enchanted Chest","Magma Chest","Mythical Chest","Legends Chest","Jungle Chest"}

-- Uses the actual equipped training tool whenever possible so the character
-- plays the normal lifting/punching animation instead of only changing stats.
local TRAINING_KEYWORDS = {
    "weight","dumbbell","barbell","bench","push","lift","muscle","handstand","situp","fist"
}
local IGNORE_TOOL_KEYWORDS = {
    "protein","shake","energy","boost","chocolate","food","drink"
}

local function hasKeyword(name, words)
    name = string.lower(name)
    for _, word in ipairs(words) do
        if string.find(name, word, 1, true) then
            return true
        end
    end
    return false
end

local function currentTool()
    local character = LP.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Tool")
end

local function findTrainingTool()
    local equipped = currentTool()
    if equipped and not hasKeyword(equipped.Name, IGNORE_TOOL_KEYWORDS) then
        return equipped
    end

    local fallback
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and not hasKeyword(tool.Name, IGNORE_TOOL_KEYWORDS) then
            if hasKeyword(tool.Name, TRAINING_KEYWORDS) then
                return tool
            end
            fallback = fallback or tool
        end
    end
    return fallback
end

local function activateTrainingTool()
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local tool = findTrainingTool()
    if not tool then return false end

    if tool.Parent == Backpack then
        pcall(function()
            humanoid:EquipTool(tool)
        end)
        task.wait(.05)
    end

    if tool.Parent == character then
        local ok = pcall(function()
            tool:Activate()
        end)
        return ok
    end

    return false
end

local function allOwnedPets()
    local out = {}
    local folder = LP:FindFirstChild("petsFolder")
    if not folder then return out end
    for _, rarity in ipairs(folder:GetChildren()) do
        for _, pet in ipairs(rarity:GetChildren()) do
            out[#out+1] = {pet=pet, rarity=rarity.Name}
        end
    end
    return out
end

local rarityRank = {Basic=1,Rare=2,Epic=3,Unique=4,Advanced=5}
local function petPower(p)
    local score = (rarityRank[p.rarity] or 0) * 1e12
    local level = p.pet:FindFirstChild("level")
    score += (level and tonumber(level.Value) or 1) * 1e6
    for _, key in ipairs({"strength","agility","durability"}) do
        local v = p.pet:FindFirstChild(key)
        if v then score += tonumber(v.Value) or 0 end
        local perks = p.pet:FindFirstChild("perksFolder")
        local pv = perks and perks:FindFirstChild(key)
        if pv then score += tonumber(pv.Value) or 0 end
    end
    return score
end

local function equippedPets()
    local set, slots = {}, 0
    local folder = LP:FindFirstChild("equippedPets")
    if not folder then return set, slots end
    for _, slot in ipairs(folder:GetChildren()) do
        slots += 1
        local ref = slot:FindFirstChild("petReference")
        if ref and ref.Value then set[ref.Value] = true end
    end
    return set, slots
end

local function equipBestOwned()
    if not R.EquipPet then return end
    local pets = allOwnedPets()
    table.sort(pets, function(a,b) return petPower(a) > petPower(b) end)
    local equipped, slots = equippedPets()
    if slots <= 0 then slots = 3 end

    for pet in pairs(equipped) do
        safeFire(R.EquipPet, "unequipPet", pet)
        task.wait(.12)
    end
    for i=1, math.min(slots, #pets) do
        safeFire(R.EquipPet, "equipPet", pets[i].pet)
        task.wait(.18)
    end
end

local function evolveReadyOwned()
    if not R.EvolvePet then return end
    local counts = {}
    for _, entry in ipairs(allOwnedPets()) do
        counts[entry.pet.Name] = (counts[entry.pet.Name] or 0) + 1
    end
    for name,count in pairs(counts) do
        local tries = math.floor(count/5)
        for _=1,tries do
            safeFire(R.EvolvePet, "evolvePet", name)
            task.wait(.35)
        end
    end
end

task.spawn(function()
    while task.wait(math.max(S.RepDelay, 0.12)) do
        if S.Train then
            -- Prefer the game's normal Tool activation: this keeps the
            -- character animation visible and lets the tool's own LocalScript
            -- handle the training event. Fallback only if no usable tool exists.
            local animated = activateTrainingTool()
            if not animated then
                safeFire(getMuscleEvent(), "rep")
            end
        end
    end
end)

task.spawn(function()
    while task.wait(.15) do
        if S.Rebirth then safeInvoke(R.Rebirth, "rebirthRequest") end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if S.Chests then
            for _,name in ipairs(CHESTS) do
                safeInvoke(R.Chest, name)
                task.wait(.12)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(.1) do
        if S.Hatch then
            safeInvoke(R.Crystal, "openCrystal", S.HatchCrystal)
            task.wait(S.HatchDelay)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if S.Brawl then safeFire(R.Brawl, "joinBrawl") end
    end
end)

local TweenService = game:GetService("TweenService")

-- 710Hub UI • Jamaica theme ---------------------------------------------------
local COLORS = {
    Black = Color3.fromRGB(10, 12, 10),
    Panel = Color3.fromRGB(18, 21, 18),
    Panel2 = Color3.fromRGB(25, 29, 25),
    Green = Color3.fromRGB(0, 155, 58),
    GreenDark = Color3.fromRGB(0, 92, 35),
    Yellow = Color3.fromRGB(254, 209, 0),
    YellowSoft = Color3.fromRGB(255, 222, 64),
    White = Color3.fromRGB(245, 247, 245),
    Muted = Color3.fromRGB(155, 165, 155),
    Off = Color3.fromRGB(80, 86, 80),
}

local gui = Instance.new("ScreenGui")
gui.Name = "710Hub_MuscleLegends"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local shadow = Instance.new("Frame", gui)
shadow.Size = UDim2.fromOffset(466, 566)
shadow.Position = UDim2.new(.5, -225, .5, -274)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = .45
shadow.BorderSizePixel = 0
local shadowCorner = Instance.new("UICorner", shadow)
shadowCorner.CornerRadius = UDim.new(0, 16)

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(450, 550)
main.Position = UDim2.new(.5, -225, .5, -275)
main.BackgroundColor3 = COLORS.Black
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 15)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = COLORS.Green
mainStroke.Thickness = 2
mainStroke.Transparency = .05

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 64)
top.BackgroundColor3 = COLORS.Panel
top.BorderSizePixel = 0
local topCorner = Instance.new("UICorner", top)
topCorner.CornerRadius = UDim.new(0, 15)

local topMask = Instance.new("Frame", top)
topMask.Position = UDim2.new(0,0,1,-15)
topMask.Size = UDim2.new(1,0,0,15)
topMask.BackgroundColor3 = COLORS.Panel
topMask.BorderSizePixel = 0

local flagGreen = Instance.new("Frame", top)
flagGreen.Size = UDim2.new(.34,0,0,4)
flagGreen.Position = UDim2.new(0,0,1,-4)
flagGreen.BackgroundColor3 = COLORS.Green
flagGreen.BorderSizePixel = 0

local flagYellow = Instance.new("Frame", top)
flagYellow.Size = UDim2.new(.32,0,0,4)
flagYellow.Position = UDim2.new(.34,0,1,-4)
flagYellow.BackgroundColor3 = COLORS.Yellow
flagYellow.BorderSizePixel = 0

local flagGreen2 = Instance.new("Frame", top)
flagGreen2.Size = UDim2.new(.34,0,0,4)
flagGreen2.Position = UDim2.new(.66,0,1,-4)
flagGreen2.BackgroundColor3 = COLORS.Green
flagGreen2.BorderSizePixel = 0

local logo = Instance.new("TextLabel", top)
logo.Size = UDim2.fromOffset(52, 52)
logo.Position = UDim2.fromOffset(10, 5)
logo.BackgroundColor3 = COLORS.Green
logo.Text = "710"
logo.TextColor3 = COLORS.Yellow
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 17
logo.BorderSizePixel = 0
local logoCorner = Instance.new("UICorner", logo)
logoCorner.CornerRadius = UDim.new(0, 12)
local logoStroke = Instance.new("UIStroke", logo)
logoStroke.Color = COLORS.Yellow
logoStroke.Thickness = 1.5

local title = Instance.new("TextLabel", top)
title.Position = UDim2.fromOffset(74, 8)
title.Size = UDim2.new(1, -128, 0, 26)
title.BackgroundTransparency = 1
title.Text = "710Hub"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = COLORS.White
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local subtitle = Instance.new("TextLabel", top)
subtitle.Position = UDim2.fromOffset(74, 33)
subtitle.Size = UDim2.new(1, -128, 0, 18)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MUSCLE LEGENDS  •  JAMAICA EDITION"
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextColor3 = COLORS.Yellow
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 10

local hideMenu
local showMenu

local close = Instance.new("TextButton", top)
close.Size = UDim2.fromOffset(34, 34)
close.Position = UDim2.new(1, -44, 0, 14)
close.BackgroundColor3 = COLORS.Panel2
close.Text = "×"
close.TextColor3 = COLORS.Yellow
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", close)
closeCorner.CornerRadius = UDim.new(0, 9)
close.MouseButton1Click:Connect(function()
    if hideMenu then
        hideMenu()
    end
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.fromOffset(12, 76)
scroll.Size = UDim2.new(1, -24, 1, -88)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = COLORS.Yellow
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function addCorner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 9)
    return c
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke", obj)
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

local miniButton = Instance.new("TextButton", gui)
miniButton.Name = "710Hub_MiniButton"
miniButton.Size = UDim2.fromOffset(60, 60)
miniButton.Position = UDim2.new(0, 18, .5, -30)
miniButton.BackgroundColor3 = COLORS.Green
miniButton.BorderSizePixel = 0
miniButton.Text = "710"
miniButton.TextColor3 = COLORS.Yellow
miniButton.Font = Enum.Font.GothamBlack
miniButton.TextSize = 18
miniButton.Visible = false
miniButton.Active = true
miniButton.Draggable = true
miniButton.AutoButtonColor = false
addCorner(miniButton, 15)
addStroke(miniButton, COLORS.Yellow, 2, 0)

hideMenu = function()
    main.Visible = false
    shadow.Visible = false
    miniButton.Visible = true
end

showMenu = function()
    main.Visible = true
    shadow.Visible = true
    miniButton.Visible = false
end

miniButton.MouseButton1Click:Connect(function()
    showMenu()
end)

local function section(text)
    local holder = Instance.new("Frame", scroll)
    holder.Size = UDim2.new(1, -6, 0, 30)
    holder.BackgroundTransparency = 1

    local accent = Instance.new("Frame", holder)
    accent.Size = UDim2.fromOffset(4, 20)
    accent.Position = UDim2.fromOffset(1, 5)
    accent.BackgroundColor3 = COLORS.Green
    accent.BorderSizePixel = 0
    addCorner(accent, 3)

    local label = Instance.new("TextLabel", holder)
    label.Position = UDim2.fromOffset(14, 0)
    label.Size = UDim2.new(1, -14, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = COLORS.Yellow
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
end

local function button(text, callback, accentColor)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -6, 0, 42)
    b.BackgroundColor3 = COLORS.Panel2
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = ""
    addCorner(b, 10)
    addStroke(b, Color3.fromRGB(47, 55, 47), 1, .15)

    local accent = Instance.new("Frame", b)
    accent.Size = UDim2.fromOffset(4, 24)
    accent.Position = UDim2.fromOffset(8, 9)
    accent.BackgroundColor3 = accentColor or COLORS.Green
    accent.BorderSizePixel = 0
    addCorner(accent, 3)

    local label = Instance.new("TextLabel", b)
    label.Position = UDim2.fromOffset(23, 0)
    label.Size = UDim2.new(1, -34, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = COLORS.White
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = Color3.fromRGB(32, 38, 32)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = COLORS.Panel2}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        task.spawn(callback, b, label)
    end)

    return b, label
end

local function toggle(labelText, key)
    local b, label = button(labelText, function() end, COLORS.Green)

    local pill = Instance.new("Frame", b)
    pill.Size = UDim2.fromOffset(58, 24)
    pill.Position = UDim2.new(1, -68, .5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(35, 39, 35)
    pill.BorderSizePixel = 0
    addCorner(pill, 12)

    local dot = Instance.new("Frame", pill)
    dot.Size = UDim2.fromOffset(18, 18)
    dot.Position = UDim2.fromOffset(3, 3)
    dot.BackgroundColor3 = COLORS.Off
    dot.BorderSizePixel = 0
    addCorner(dot, 9)

    local status = Instance.new("TextLabel", pill)
    status.Size = UDim2.new(1, -25, 1, 0)
    status.Position = UDim2.fromOffset(23, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = COLORS.Muted
    status.Font = Enum.Font.GothamBold
    status.TextSize = 9

    label.Size = UDim2.new(1, -102, 1, 0)

    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        status.Text = on and "ON" or "OFF"
        status.TextColor3 = on and COLORS.Black or COLORS.Muted
        TweenService:Create(pill, TweenInfo.new(.16), {
            BackgroundColor3 = on and COLORS.Yellow or Color3.fromRGB(35,39,35)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(.16), {
            Position = on and UDim2.fromOffset(37,3) or UDim2.fromOffset(3,3),
            BackgroundColor3 = on and COLORS.Green or COLORS.Off
        }):Play()
    end)
end

section("FARM")
toggle("Auto Train", "Train")
toggle("Auto Rebirth", "Rebirth")
toggle("Auto Chests", "Chests")
toggle("Auto Join Brawl", "Brawl")

section("PETS & CRYSTALS")
toggle("Auto Hatch", "Hatch")

local crystals = {"Blue Crystal","Green Crystal","Mythical Crystal","Frost Crystal","Inferno Crystal","Legends Crystal","Muscle Elite Crystal"}
local crystalIndex = 1
local _, crystalLabel = button("Crystal  •  "..crystals[crystalIndex], function(_, label)
    crystalIndex = crystalIndex % #crystals + 1
    S.HatchCrystal = crystals[crystalIndex]
    label.Text = "Crystal  •  "..S.HatchCrystal
end, COLORS.Yellow)

button("Hatch x1", function()
    safeInvoke(R.Crystal, "openCrystal", S.HatchCrystal)
end, COLORS.Yellow)

button("Equip Best Owned Pets", equipBestOwned, COLORS.Green)
button("Evolve Ready Owned Pets", evolveReadyOwned, COLORS.Green)

section("TELEPORTS")
local tpNames = {}
local tpParts = {}
local area = workspace:FindFirstChild("areaTeleportParts")
if area then
    for _, obj in ipairs(area:GetDescendants()) do
        if obj:IsA("BasePart") then
            tpNames[#tpNames+1] = obj.Name
            tpParts[obj.Name] = obj
        end
    end
    table.sort(tpNames)
end

local tpIndex = 1
button("Teleport  •  "..(tpNames[1] or "none found"), function(_, label)
    if #tpNames == 0 then return end
    tpIndex = tpIndex % #tpNames + 1
    label.Text = "Teleport  •  "..tpNames[tpIndex]
end, COLORS.Yellow)

button("Go To Selected Teleport", function()
    local p = tpParts[tpNames[tpIndex]]
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if p and root then
        root.CFrame = p.CFrame + Vector3.new(0, 4, 0)
    end
end, COLORS.Green)

section("UTILITY")
button("Stop All Automations", function()
    S.Train = false
    S.Rebirth = false
    S.Chests = false
    S.Hatch = false
    S.Brawl = false
end, COLORS.Yellow)

button("Minimize 710Hub", function()
    hideMenu()
end, COLORS.Green)

print("[710Hub] Muscle Legends loaded • Jamaica UI")
