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
local muscleEvent = LP:WaitForChild("muscleEvent")

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
    while task.wait(S.RepDelay) do
        if S.Train then safeFire(muscleEvent, "rep") end
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

local gui = Instance.new("ScreenGui")
gui.Name = "710Hub_MuscleLegends"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(430, 520)
main.Position = UDim2.new(.5,-215,.5,-260)
main.BackgroundColor3 = Color3.fromRGB(20,22,28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner",main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel",main)
title.Size = UDim2.new(1,0,0,48)
title.BackgroundTransparency = 1
title.Text = "710Hub  •  Muscle Legends"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local scroll = Instance.new("ScrollingFrame",main)
scroll.Position = UDim2.fromOffset(12,52)
scroll.Size = UDim2.new(1,-24,1,-64)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
local layout = Instance.new("UIListLayout",scroll)
layout.Padding = UDim.new(0,7)

local function button(text, cb)
    local b=Instance.new("TextButton",scroll)
    b.Size=UDim2.new(1,-6,0,38)
    b.BackgroundColor3=Color3.fromRGB(35,39,49)
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamMedium
    b.TextSize=14
    b.Text=text
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(function() task.spawn(cb,b) end)
    return b
end

local function toggle(label,key)
    local b
    b=button(label..": OFF",function()
        S[key]=not S[key]
        b.Text=label..(S[key] and ": ON" or ": OFF")
    end)
end

local function section(t)
    local l=Instance.new("TextLabel",scroll)
    l.Size=UDim2.new(1,-6,0,28)
    l.BackgroundTransparency=1
    l.Text=t
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextColor3=Color3.fromRGB(170,180,255)
    l.Font=Enum.Font.GothamBold
    l.TextSize=14
end

section("FARM")
toggle("Auto Train", "Train")
toggle("Auto Rebirth", "Rebirth")
toggle("Auto Chests", "Chests")
toggle("Auto Join Brawl", "Brawl")

section("PETS / CRYSTALS")
toggle("Auto Hatch", "Hatch")

local crystals={"Blue Crystal","Green Crystal","Mythical Crystal","Frost Crystal","Inferno Crystal","Legends Crystal","Muscle Elite Crystal"}
local crystalIndex=1
button("Crystal: "..crystals[crystalIndex],function(b)
    crystalIndex = crystalIndex % #crystals + 1
    S.HatchCrystal=crystals[crystalIndex]
    b.Text="Crystal: "..S.HatchCrystal
end)
button("Hatch x1",function()
    safeInvoke(R.Crystal,"openCrystal",S.HatchCrystal)
end)
button("Equip Best Owned Pets",equipBestOwned)
button("Evolve Ready Owned Pets",evolveReadyOwned)

section("TELEPORTS")
local tpNames={}
local tpParts={}
local area=workspace:FindFirstChild("areaTeleportParts")
if area then
    for _,obj in ipairs(area:GetDescendants()) do
        if obj:IsA("BasePart") then
            tpNames[#tpNames+1]=obj.Name
            tpParts[obj.Name]=obj
        end
    end
    table.sort(tpNames)
end
local tpIndex=1
button("Teleport: "..(tpNames[1] or "none found"),function(b)
    if #tpNames==0 then return end
    tpIndex=tpIndex%#tpNames+1
    b.Text="Teleport: "..tpNames[tpIndex]
end)
button("Go To Selected Teleport",function()
    local p=tpParts[tpNames[tpIndex]]
    local c=LP.Character
    if p and c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame=p.CFrame+Vector3.new(0,4,0)
    end
end)

section("UTILITY")
button("Stop All",function()
    S.Train=false
    S.Rebirth=false
    S.Chests=false
    S.Hatch=false
    S.Brawl=false
end)
button("Close UI",function() gui:Destroy() end)

print("[710Hub] Muscle Legends loaded")
