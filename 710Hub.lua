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
    Machine = rEvents:FindFirstChild("machineInteractRemote"),
}

local S = {
    Train=false, Rebirth=false, Chests=false, Hatch=false, Brawl=false,
    AutoPunch=false, SmartRock=false, LockPosition=false,
    AutoMachine=false, StrengthRebirth=false,
    HatchCrystal="Blue Crystal", RepDelay=.065, HatchDelay=.45,
    RebirthTarget=nil, SelectedMachine=nil,
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

local function numberStat(name)
    local direct = LP:FindFirstChild(name)
    if direct and tonumber(direct.Value) then return tonumber(direct.Value) end
    local leaderstats = LP:FindFirstChild("leaderstats")
    local stat = leaderstats and leaderstats:FindFirstChild(name)
    if stat and tonumber(stat.Value) then return tonumber(stat.Value) end
    return 0
end

local function currentRebirths()
    return numberStat("Rebirths")
end

local lockedCFrame = nil

local function captureLockPosition()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        lockedCFrame = root.CFrame
        return true
    end
    return false
end

LP.CharacterAdded:Connect(function()
    lockedCFrame = nil
    S.LockPosition = false
end)

task.spawn(function()
    while task.wait(.08) do
        if S.LockPosition then
            local character = LP.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not lockedCFrame then
                captureLockPosition()
            end
            if root and lockedCFrame then
                pcall(function()
                    root.CFrame = lockedCFrame
                    root.AssemblyLinearVelocity = Vector3.zero
                end)
            end
        end
    end
end)

local function findPunchTool()
    local character = LP.Character
    local equipped = character and character:FindFirstChild("Punch")
    if equipped and equipped:IsA("Tool") then return equipped end
    local tool = Backpack:FindFirstChild("Punch")
    if tool and tool:IsA("Tool") then return tool end
end

local function doAnimatedPunch()
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local tool = findPunchTool()
    if not tool or not humanoid then return false end

    if tool.Parent == Backpack then
        pcall(function() humanoid:EquipTool(tool) end)
        task.wait(.04)
    end

    local event = getMuscleEvent()
    if event then
        safeFire(event, "punch", "rightHand")
        task.wait(.035)
        safeFire(event, "punch", "leftHand")
    end

    pcall(function() tool:Activate() end)
    return true
end

local function bestAvailableRock()
    local machines = workspace:FindFirstChild("machinesFolder")
    if not machines then return nil end

    local durability = numberStat("Durability")
    local bestRock, bestNeed = nil, -1

    for _, node in ipairs(machines:GetDescendants()) do
        if node.Name == "neededDurability" and tonumber(node.Value) then
            local need = tonumber(node.Value)
            local parent = node.Parent
            local rock = parent and (parent:FindFirstChild("Rock") or parent.Parent and parent.Parent:FindFirstChild("Rock"))
            if rock and rock:IsA("BasePart") and need <= durability and need > bestNeed then
                bestRock, bestNeed = rock, need
            end
        end
    end

    return bestRock, bestNeed
end

local function farmBestRock()
    local rock = bestAvailableRock()
    if not rock then return false end

    local character = LP.Character
    local left = character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"))
    local right = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))

    if firetouchinterest and (left or right) then
        pcall(function()
            if right then
                firetouchinterest(rock, right, 0)
                firetouchinterest(rock, right, 1)
            end
            if left then
                firetouchinterest(rock, left, 0)
                firetouchinterest(rock, left, 1)
            end
        end)
        return true
    end

    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        pcall(function()
            root.CFrame = rock.CFrame + Vector3.new(0,3,2)
        end)
        doAnimatedPunch()
        return true
    end

    return false
end

local CHESTS = {"Golden Chest","Enchanted Chest","Magma Chest","Mythical Chest","Legends Chest","Jungle Chest"}

local function scanMachines()
    local folder = workspace:FindFirstChild("machinesFolder")
    local list = {}
    if not folder then return list end

    for _, machine in ipairs(folder:GetChildren()) do
        local seat = machine:FindFirstChild("interactSeat")
        if seat and seat:IsA("BasePart") then
            list[#list+1] = {
                name = machine.Name,
                machine = machine,
                seat = seat,
            }
        end
    end

    table.sort(list, function(a,b)
        return string.lower(a.name) < string.lower(b.name)
    end)

    return list
end

local function getSelectedMachine()
    local machines = scanMachines()
    if #machines == 0 then return nil end

    if S.SelectedMachine then
        for _, info in ipairs(machines) do
            if info.name == S.SelectedMachine then
                return info
            end
        end
    end

    S.SelectedMachine = machines[1].name
    return machines[1]
end

local function useSelectedMachine(moveCharacter)
    local info = getSelectedMachine()
    if not info then return false end

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if moveCharacter and root then
        pcall(function()
            root.CFrame = info.seat.CFrame * CFrame.new(0, 3, 0)
        end)
        task.wait(.12)
    end

    if R.Machine then
        safeInvoke(R.Machine, "useMachine", info.seat)
    end

    local event = getMuscleEvent()
    if event then
        safeFire(event, "rep", info.seat)
    end

    return true
end

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
    while task.wait(.18) do
        if S.Rebirth then
            if S.RebirthTarget and currentRebirths() >= S.RebirthTarget then
                S.Rebirth = false
            else
                safeInvoke(R.Rebirth, "rebirthRequest")
            end
        end
    end
end)

task.spawn(function()
    while task.wait(.16) do
        if S.AutoPunch then
            doAnimatedPunch()
        end
    end
end)

task.spawn(function()
    while task.wait(.18) do
        if S.SmartRock then
            farmBestRock()
        end
    end
end)

task.spawn(function()
    while task.wait(.22) do
        if S.AutoMachine then
            useSelectedMachine(false)
        end
    end
end)

task.spawn(function()
    while task.wait(.25) do
        if S.StrengthRebirth then
            if not S.AutoMachine then
                local animated = activateTrainingTool()
                if not animated then
                    safeFire(getMuscleEvent(), "rep")
                end
            end
            safeInvoke(R.Rebirth, "rebirthRequest")
        end
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
local UIS = game:GetService("UserInputService")

-- 710Hub UI • Jamaica Green ---------------------------------------------------
local COLORS = {
    Black = Color3.fromRGB(7, 9, 7),
    Black2 = Color3.fromRGB(12, 15, 12),
    Panel = Color3.fromRGB(18, 23, 18),
    Panel2 = Color3.fromRGB(25, 31, 25),
    Panel3 = Color3.fromRGB(31, 38, 31),
    Green = Color3.fromRGB(0, 155, 58),
    GreenBright = Color3.fromRGB(35, 205, 90),
    GreenDark = Color3.fromRGB(0, 82, 31),
    Yellow = Color3.fromRGB(254, 209, 0),
    YellowSoft = Color3.fromRGB(255, 225, 85),
    White = Color3.fromRGB(245, 248, 245),
    Muted = Color3.fromRGB(150, 164, 150),
    Off = Color3.fromRGB(74, 82, 74),
    Red = Color3.fromRGB(190, 32, 42),
}

local function addCorner(obj, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 10)
    x.Parent = obj
    return x
end

local function addStroke(obj, color, thickness, transparency)
    local x = Instance.new("UIStroke")
    x.Color = color
    x.Thickness = thickness or 1
    x.Transparency = transparency or 0
    x.Parent = obj
    return x
end

local function tween(obj, time, goal)
    TweenService:Create(
        obj,
        TweenInfo.new(time or .15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        goal
    ):Play()
end

local guiParent = game:GetService("CoreGui")
pcall(function()
    if gethui then
        guiParent = gethui()
    end
end)

local oldGui = guiParent:FindFirstChild("710Hub_MuscleLegends")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "710Hub_MuscleLegends"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = false
gui.Parent = guiParent

-- sombra
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.fromOffset(486, 596)
shadow.Position = UDim2.new(.5, -243, .5, -298)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = .48
shadow.BorderSizePixel = 0
shadow.Parent = gui
addCorner(shadow, 19)

-- painel
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(470, 580)
main.Position = UDim2.new(.5, -235, .5, -290)
main.BackgroundColor3 = COLORS.Black
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
addCorner(main, 17)
addStroke(main, COLORS.Green, 2, .02)

-- faixa superior
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,78)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = main
addCorner(header,17)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1,0,0,18)
headerFix.Position = UDim2.new(0,0,1,-18)
headerFix.BackgroundColor3 = COLORS.Panel
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- faixa Jamaica
local g1 = Instance.new("Frame", header)
g1.Size = UDim2.new(.34,0,0,5)
g1.Position = UDim2.new(0,0,1,-5)
g1.BackgroundColor3 = COLORS.Green
g1.BorderSizePixel = 0

local y1 = Instance.new("Frame", header)
y1.Size = UDim2.new(.32,0,0,5)
y1.Position = UDim2.new(.34,0,1,-5)
y1.BackgroundColor3 = COLORS.Yellow
y1.BorderSizePixel = 0

local g2 = Instance.new("Frame", header)
g2.Size = UDim2.new(.34,0,0,5)
g2.Position = UDim2.new(.66,0,1,-5)
g2.BackgroundColor3 = COLORS.Green
g2.BorderSizePixel = 0

-- logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.fromOffset(58,58)
logo.Position = UDim2.fromOffset(10,8)
logo.BackgroundColor3 = COLORS.GreenDark
logo.Text = "710"
logo.TextColor3 = COLORS.Yellow
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 20
logo.BorderSizePixel = 0
logo.Parent = header
addCorner(logo,15)
addStroke(logo,COLORS.Yellow,2,.05)

-- detalhes botânicos / folhas estilizadas
local leafLeft = Instance.new("TextLabel")
leafLeft.Position = UDim2.new(1,-154,0,4)
leafLeft.Size = UDim2.fromOffset(52,30)
leafLeft.BackgroundTransparency = 1
leafLeft.Text = "🌿"
leafLeft.TextColor3 = COLORS.GreenBright
leafLeft.TextTransparency = .1
leafLeft.Font = Enum.Font.GothamBold
leafLeft.TextSize = 24
leafLeft.Rotation = -18
leafLeft.Parent = header

local leafRight = leafLeft:Clone()
leafRight.Position = UDim2.new(1,-115,0,34)
leafRight.Rotation = 18
leafRight.TextTransparency = .22
leafRight.Parent = header

local leafMark = Instance.new("TextLabel")
leafMark.Size = UDim2.fromOffset(36,36)
leafMark.Position = UDim2.new(1,-92,0,18)
leafMark.BackgroundColor3 = COLORS.Black2
leafMark.Text = "🌿"
leafMark.TextSize = 19
leafMark.BorderSizePixel = 0
leafMark.Parent = header
addCorner(leafMark,10)
addStroke(leafMark,COLORS.Green,1,.25)

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(82,10)
title.Size = UDim2.new(1,-210,0,28)
title.BackgroundTransparency = 1
title.Text = "710Hub"
title.TextColor3 = COLORS.White
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(82,38)
subtitle.Size = UDim2.new(1,-210,0,20)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MUSCLE LEGENDS • JAMAICA EDITION"
subtitle.TextColor3 = COLORS.Yellow
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 10
subtitle.Parent = header

local version = Instance.new("TextLabel")
version.Position = UDim2.fromOffset(82,55)
version.Size = UDim2.new(1,-210,0,14)
version.BackgroundTransparency = 1
version.Text = "Farm • Pets • Teleportes • Utilidades"
version.TextColor3 = COLORS.Muted
version.TextXAlignment = Enum.TextXAlignment.Left
version.Font = Enum.Font.Gotham
version.TextSize = 9
version.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(34,34)
minimize.Position = UDim2.new(1,-44,0,20)
minimize.BackgroundColor3 = COLORS.Panel2
minimize.Text = "—"
minimize.TextColor3 = COLORS.Yellow
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 22
minimize.BorderSizePixel = 0
minimize.Parent = header
addCorner(minimize,10)

-- padrão de folhas no fundo
for i=1,7 do
    local leaf = Instance.new("TextLabel")
    leaf.BackgroundTransparency = 1
    leaf.Text = "🌿"
    leaf.TextColor3 = COLORS.Green
    leaf.TextTransparency = .84
    leaf.Font = Enum.Font.GothamBold
    leaf.TextSize = 28 + (i%3)*4
    leaf.Rotation = -28 + i*9
    leaf.Position = UDim2.new((i%2==0) and .82 or .02, 0, 0, 78 + i*62)
    leaf.Size = UDim2.fromOffset(48,48)
    leaf.ZIndex = 0
    leaf.Parent = main
end

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Conteudo"
scroll.Position = UDim2.fromOffset(13,91)
scroll.Size = UDim2.new(1,-26,1,-104)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = COLORS.Yellow
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,9)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function section(name, desc)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,-6,0,46)
    holder.BackgroundColor3 = COLORS.Black2
    holder.BorderSizePixel = 0
    holder.Parent = scroll
    addCorner(holder,11)
    addStroke(holder,Color3.fromRGB(35,48,35),1,.28)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(5,28)
    bar.Position = UDim2.fromOffset(8,9)
    bar.BackgroundColor3 = COLORS.Green
    bar.BorderSizePixel = 0
    bar.Parent = holder
    addCorner(bar,3)

    local t = Instance.new("TextLabel")
    t.Position = UDim2.fromOffset(22,5)
    t.Size = UDim2.new(1,-28,0,20)
    t.BackgroundTransparency = 1
    t.Text = name
    t.TextColor3 = COLORS.Yellow
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.Parent = holder

    local d = Instance.new("TextLabel")
    d.Position = UDim2.fromOffset(22,24)
    d.Size = UDim2.new(1,-28,0,16)
    d.BackgroundTransparency = 1
    d.Text = desc or ""
    d.TextColor3 = COLORS.Muted
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Font = Enum.Font.Gotham
    d.TextSize = 9
    d.TextTruncate = Enum.TextTruncate.AtEnd
    d.Parent = holder
end

local function card(titleText, description, callback, accentColor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-6,0,58)
    b.BackgroundColor3 = COLORS.Panel2
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = ""
    b.Parent = scroll
    addCorner(b,12)
    addStroke(b,Color3.fromRGB(47,58,47),1,.18)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(4,36)
    accent.Position = UDim2.fromOffset(8,11)
    accent.BackgroundColor3 = accentColor or COLORS.Green
    accent.BorderSizePixel = 0
    accent.Parent = b
    addCorner(accent,3)

    local t = Instance.new("TextLabel")
    t.Position = UDim2.fromOffset(23,8)
    t.Size = UDim2.new(1,-34,0,20)
    t.BackgroundTransparency = 1
    t.Text = titleText
    t.TextColor3 = COLORS.White
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 13
    t.Parent = b

    local d = Instance.new("TextLabel")
    d.Position = UDim2.fromOffset(23,29)
    d.Size = UDim2.new(1,-34,0,18)
    d.BackgroundTransparency = 1
    d.Text = description or ""
    d.TextColor3 = COLORS.Muted
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Font = Enum.Font.Gotham
    d.TextSize = 9
    d.TextTruncate = Enum.TextTruncate.AtEnd
    d.Parent = b

    b.MouseEnter:Connect(function()
        tween(b,.12,{BackgroundColor3=COLORS.Panel3})
    end)
    b.MouseLeave:Connect(function()
        tween(b,.12,{BackgroundColor3=COLORS.Panel2})
    end)
    b.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback,b,t,d) end
    end)

    return b,t,d
end

local toggleRefs = {}
local function toggle(titleText, description, key)
    local b,t,d = card(titleText, description, nil, COLORS.Green)

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(62,26)
    pill.Position = UDim2.new(1,-73,.5,-13)
    pill.BackgroundColor3 = Color3.fromRGB(38,44,38)
    pill.BorderSizePixel = 0
    pill.Parent = b
    addCorner(pill,13)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(20,20)
    dot.Position = UDim2.fromOffset(3,3)
    dot.BackgroundColor3 = COLORS.Off
    dot.BorderSizePixel = 0
    dot.Parent = pill
    addCorner(dot,10)

    local state = Instance.new("TextLabel")
    state.Size = UDim2.new(1,-26,1,0)
    state.Position = UDim2.fromOffset(25,0)
    state.BackgroundTransparency = 1
    state.Text = "OFF"
    state.TextColor3 = COLORS.Muted
    state.Font = Enum.Font.GothamBold
    state.TextSize = 9
    state.Parent = pill

    t.Size = UDim2.new(1,-112,0,20)
    d.Size = UDim2.new(1,-112,0,18)

    local function render()
        local on = S[key]
        state.Text = on and "ON" or "OFF"
        state.TextColor3 = on and COLORS.Black or COLORS.Muted
        tween(pill,.15,{BackgroundColor3=on and COLORS.Yellow or Color3.fromRGB(38,44,38)})
        tween(dot,.15,{
            Position=on and UDim2.fromOffset(39,3) or UDim2.fromOffset(3,3),
            BackgroundColor3=on and COLORS.Green or COLORS.Off
        })
    end

    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        render()
    end)

    toggleRefs[key] = render
    return b
end

-- ícone permanente / reabrir
local mini = Instance.new("TextButton")
mini.Name = "710Hub_Mini"
mini.Size = UDim2.fromOffset(66,66)
mini.Position = UDim2.new(0,20,.5,-33)
mini.BackgroundColor3 = COLORS.GreenDark
mini.BorderSizePixel = 0
mini.Text = ""
mini.Visible = false
mini.Active = true
mini.Draggable = true
mini.Parent = gui
addCorner(mini,18)
addStroke(mini,COLORS.Yellow,2,.02)

local miniLogo = Instance.new("TextLabel")
miniLogo.Size = UDim2.new(1,0,.62,0)
miniLogo.BackgroundTransparency = 1
miniLogo.Text = "710"
miniLogo.TextColor3 = COLORS.Yellow
miniLogo.Font = Enum.Font.GothamBlack
miniLogo.TextSize = 19
miniLogo.Parent = mini

local miniLeaf = Instance.new("TextLabel")
miniLeaf.Size = UDim2.new(1,0,.38,0)
miniLeaf.Position = UDim2.new(0,0,.58,0)
miniLeaf.BackgroundTransparency = 1
miniLeaf.Text = "🌿"
miniLeaf.TextColor3 = COLORS.GreenBright
miniLeaf.Font = Enum.Font.GothamBold
miniLeaf.TextSize = 17
miniLeaf.Parent = mini

local menuOpen = true
local function hideMenu()
    if not menuOpen then return end
    menuOpen = false
    tween(main,.13,{Size=UDim2.fromOffset(440,540),BackgroundTransparency=.05})
    task.wait(.13)
    main.Visible = false
    shadow.Visible = false
    mini.Visible = true
end

local function showMenu()
    if menuOpen then return end
    menuOpen = true
    mini.Visible = false
    main.Visible = true
    shadow.Visible = true
    main.Size = UDim2.fromOffset(440,540)
    tween(main,.18,{Size=UDim2.fromOffset(470,580),BackgroundTransparency=0})
end

minimize.MouseButton1Click:Connect(hideMenu)
mini.MouseButton1Click:Connect(showMenu)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if menuOpen then hideMenu() else showMenu() end
    end
end)

-- conteúdo em português --------------------------------------------------------
section("FARM", "Automatizações principais para evoluir sua conta.")

toggle(
    "Treino automático",
    "Equipa uma ferramenta de treino e ativa repetidamente para ganhar força.",
    "Train"
)

toggle(
    "Rebirth automático",
    "Faz rebirth automaticamente. Pode ser usado junto da meta de rebirth abaixo.",
    "Rebirth"
)

local rebirthSteps = {0,10,50,100,500}
local rebirthStepIndex = 1
card(
    "Meta de rebirth: sem limite",
    "Define até quantos rebirths a automação deve continuar a partir de agora.",
    function(_,titleLabel)
        rebirthStepIndex = rebirthStepIndex % #rebirthSteps + 1
        local add = rebirthSteps[rebirthStepIndex]
        if add == 0 then
            S.RebirthTarget = nil
            titleLabel.Text = "Meta de rebirth: sem limite"
        else
            S.RebirthTarget = currentRebirths() + add
            titleLabel.Text = "Meta de rebirth: +"..add.." (até "..math.floor(S.RebirthTarget)..")"
        end
    end,
    COLORS.Yellow
)

toggle(
    "Soco automático animado",
    "Usa a ferramenta Punch e alterna as duas mãos mantendo a animação do personagem.",
    "AutoPunch"
)

toggle(
    "Farm inteligente de pedras",
    "Procura automaticamente a pedra mais forte que sua Durability atual consegue usar.",
    "SmartRock"
)

toggle(
    "Coletar baús automaticamente",
    "Tenta resgatar os baús conhecidos do mapa em intervalos regulares.",
    "Chests"
)

toggle(
    "Entrar no Brawl automaticamente",
    "Tenta entrar no evento Brawl sempre que ele estiver disponível.",
    "Brawl"
)

section("MÁQUINAS", "Treino usando as máquinas detectadas diretamente no mapa atual.")

local machineIndex = 1
local function machineNames()
    local infos = scanMachines()
    local names = {}
    for _,info in ipairs(infos) do
        names[#names+1] = info.name
    end
    return names
end

local namesAtLoad = machineNames()
if #namesAtLoad > 0 then
    S.SelectedMachine = namesAtLoad[1]
end

local _, machineTitle = card(
    "Máquina: "..(S.SelectedMachine or "nenhuma encontrada"),
    "Clique para alternar entre Bench, Squat, Press, Throw e outras máquinas detectadas.",
    function(_,titleLabel)
        local names = machineNames()
        if #names == 0 then
            titleLabel.Text = "Máquina: nenhuma encontrada"
            S.SelectedMachine = nil
            return
        end
        machineIndex = machineIndex % #names + 1
        S.SelectedMachine = names[machineIndex]
        titleLabel.Text = "Máquina: "..S.SelectedMachine
    end,
    COLORS.Yellow
)

card(
    "Ir até a máquina selecionada",
    "Teleporta seu personagem para perto do assento da máquina escolhida.",
    function()
        useSelectedMachine(true)
    end,
    COLORS.Green
)

toggle(
    "Treino automático na máquina",
    "Usa repetidamente a máquina selecionada e envia o treino ligado ao interactSeat dela.",
    "AutoMachine"
)

toggle(
    "Ciclo Força + Rebirth",
    "Mantém o treino ativo e tenta rebirth continuamente para acelerar o ciclo de evolução.",
    "StrengthRebirth"
)

card(
    "Atualizar lista de máquinas",
    "Reescaneia o machinesFolder caso o servidor tenha carregado novas máquinas.",
    function(_,titleLabel)
        local names = machineNames()
        machineIndex = 1
        S.SelectedMachine = names[1]
        machineTitle.Text = "Máquina: "..(S.SelectedMachine or "nenhuma encontrada")
    end,
    COLORS.Yellow
)

section("PETS E CRISTAIS", "Funções para abrir cristais e organizar os pets que você já possui.")

toggle(
    "Abrir cristal automaticamente",
    "Abre repetidamente o cristal selecionado abaixo.",
    "Hatch"
)

local crystals = {
    "Blue Crystal","Green Crystal","Mythical Crystal","Frost Crystal",
    "Inferno Crystal","Legends Crystal","Muscle Elite Crystal","Galaxy Oracle Crystal","Jungle Crystal"
}
local crystalIndex = 1
card(
    "Cristal selecionado: "..crystals[crystalIndex],
    "Clique para alternar entre os cristais disponíveis.",
    function(_,titleLabel)
        crystalIndex = crystalIndex % #crystals + 1
        S.HatchCrystal = crystals[crystalIndex]
        titleLabel.Text = "Cristal selecionado: "..S.HatchCrystal
    end,
    COLORS.Yellow
)

card(
    "Abrir 1 cristal",
    "Abre uma vez o cristal atualmente selecionado.",
    function()
        safeInvoke(R.Crystal,"openCrystal",S.HatchCrystal)
    end,
    COLORS.Yellow
)

card(
    "Equipar melhores pets",
    "Ordena seus pets e tenta equipar os mais fortes que você já possui.",
    equipBestOwned,
    COLORS.Green
)

card(
    "Evoluir pets prontos",
    "Procura grupos de pets repetidos e tenta evoluir quando houver quantidade suficiente.",
    evolveReadyOwned,
    COLORS.Green
)

section("TELEPORTES", "Navegação rápida usando os pontos de teleporte encontrados no mapa.")

local tpNames = {}
local tpParts = {}
local area = workspace:FindFirstChild("areaTeleportParts")
if area then
    for _,obj in ipairs(area:GetDescendants()) do
        if obj:IsA("BasePart") then
            tpNames[#tpNames+1] = obj.Name
            tpParts[obj.Name] = obj
        end
    end
    table.sort(tpNames)
end

local tpIndex = 1
card(
    "Destino: "..(tpNames[1] or "nenhum encontrado"),
    "Clique para trocar o destino do teleporte.",
    function(_,titleLabel)
        if #tpNames == 0 then return end
        tpIndex = tpIndex % #tpNames + 1
        titleLabel.Text = "Destino: "..tpNames[tpIndex]
    end,
    COLORS.Yellow
)

card(
    "Ir para o destino",
    "Move seu personagem até o ponto selecionado acima.",
    function()
        local part = tpParts[tpNames[tpIndex]]
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if part and root then
            root.CFrame = part.CFrame + Vector3.new(0,4,0)
        end
    end,
    COLORS.Green
)

section("PERFIS RÁPIDOS", "Atalhos que combinam várias funções para objetivos diferentes.")

card(
    "Perfil: Força",
    "Ativa treino automático e soco animado; desliga farm de pets.",
    function()
        S.Train = true
        S.AutoPunch = true
        S.SmartRock = false
        S.Hatch = false
        for _,render in pairs(toggleRefs) do render() end
    end,
    COLORS.Green
)

card(
    "Perfil: Durabilidade",
    "Ativa o farm inteligente de pedras e soco animado.",
    function()
        S.Train = false
        S.AutoPunch = true
        S.SmartRock = true
        for _,render in pairs(toggleRefs) do render() end
    end,
    COLORS.Green
)

card(
    "Perfil: Pets",
    "Ativa abertura automática do cristal selecionado e desliga farms de combate.",
    function()
        S.Train = false
        S.AutoPunch = false
        S.SmartRock = false
        S.Hatch = true
        for _,render in pairs(toggleRefs) do render() end
    end,
    COLORS.Yellow
)

section("SESSÃO", "Informações úteis sobre seu progresso desde que o 710Hub foi iniciado.")

local startTime = os.clock()
local startRebirths = currentRebirths()
local startStrength = numberStat("Strength")
local _, sessionTitle, sessionDesc = card(
    "Sessão: iniciando...",
    "Calculando seus ganhos.",
    function() end,
    COLORS.Green
)

task.spawn(function()
    while task.wait(1) do
        local elapsed = math.max(1, os.clock() - startTime)
        local rebirthGain = currentRebirths() - startRebirths
        local strengthGain = numberStat("Strength") - startStrength
        sessionTitle.Text = string.format(
            "Sessão: %02d:%02d:%02d",
            math.floor(elapsed/3600),
            math.floor((elapsed%3600)/60),
            math.floor(elapsed%60)
        )
        sessionDesc.Text = string.format(
            "Força ganha: %s  •  Rebirths ganhos: %s  •  Rebirths/min: %.2f",
            tostring(math.floor(strengthGain)),
            tostring(math.floor(rebirthGain)),
            rebirthGain / (elapsed/60)
        )
    end
end)

section("UTILIDADES", "Controles gerais do 710Hub.")

local lockButton = toggle(
    "Travar posição",
    "Mantém seu personagem parado exatamente no ponto atual até você desligar.",
    "LockPosition"
)

lockButton.MouseButton1Click:Connect(function()
    if S.LockPosition then
        captureLockPosition()
    else
        lockedCFrame = nil
    end
end)

card(
    "Atualizar posição travada",
    "Salva sua posição atual como o novo ponto fixo quando o Travar posição estiver ligado.",
    function()
        if S.LockPosition then
            captureLockPosition()
        end
    end,
    COLORS.Yellow
)

card(
    "Parar todas as automações",
    "Desliga treino, rebirth, baús, cristais e Brawl de uma vez.",
    function()
        S.Train = false
        S.Rebirth = false
        S.Chests = false
        S.Hatch = false
        S.Brawl = false
        S.AutoPunch = false
        S.SmartRock = false
        S.AutoMachine = false
        S.StrengthRebirth = false
        S.LockPosition = false
        lockedCFrame = nil
        for _,render in pairs(toggleRefs) do
            render()
        end
    end,
    COLORS.Red
)

card(
    "Minimizar 710Hub",
    "Esconde o painel e mantém o ícone 710 na tela para reabrir.",
    hideMenu,
    COLORS.Yellow
)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,-6,0,36)
footer.BackgroundTransparency = 1
footer.Text = "RightShift abre/fecha • O ícone 710 permanece na tela"
footer.TextColor3 = COLORS.Muted
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.Parent = scroll

print("[710Hub] Muscle Legends carregado • Jamaica Edition")
