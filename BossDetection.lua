return function(workspace, Players, S)
local function uniqueHumanoid(model)
    local found
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("Humanoid") then
            if found then return nil, true end
            found = item
        end
    end
    return found, false
end
local function bossRoot(model)
    if not model then return nil end
    local hum, ambiguous = uniqueHumanoid(model)
    if ambiguous then return nil end
    local rig = hum and hum.Parent or model
    for _, name in ipairs({"HumanoidRootPart", "UpperTorso", "Torso", "Head"}) do
        local part = rig:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    local part = model.PrimaryPart
    if part and part:IsA("BasePart") then return part end
    return model:FindFirstChildWhichIsA("BasePart")
end

local function bossHumanoid(model)
    if not model then return nil end
    local humanoid, ambiguous = uniqueHumanoid(model)
    if ambiguous then return nil end
    if humanoid then return humanoid end
    -- Some NPCs expose numeric health instead of a Humanoid.
    for _, owner in ipairs({model, model:FindFirstChild("Stats") or model}) do
        for _, name in ipairs({"Health", "health", "HP", "CurrentHealth"}) do
            local health = owner:GetAttribute(name)
            local value = owner:FindFirstChild(name)
            if type(health) ~= "number" and value and (value:IsA("NumberValue") or value:IsA("IntValue")) then health = value.Value end
            if type(health) == "number" and health == health then
                local maximum = owner:GetAttribute("MaxHealth")
                local maxValue = owner:FindFirstChild("MaxHealth")
                if type(maximum) ~= "number" and maxValue and (maxValue:IsA("NumberValue") or maxValue:IsA("IntValue")) then maximum = maxValue.Value end
                return {Health = health, MaxHealth = type(maximum) == "number" and maximum or health}
            end
        end
    end
end

local function modelHasBossMarker(model)
    if not model or not model:IsA("Model") then return false end
    local ancestor = model
    while ancestor and ancestor ~= workspace do
        local name = string.lower(ancestor.Name)
        if name:find("pet", 1, true) or name:find("mascote", 1, true) or ancestor:GetAttribute("IsPet") == true then return false end
        for _, tag in ipairs(ancestor:GetTags()) do
            local lower = string.lower(tag)
            if lower:find("pet", 1, true) or lower:find("mascote", 1, true) then return false end
        end
        ancestor = ancestor.Parent
    end
    -- Never classify a player, a part of their character, or an enclosing arena as a boss.
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and (model == character or model:IsDescendantOf(character) or character:IsDescendantOf(model)) then return false end
    end
    local humanoid, root = bossHumanoid(model), bossRoot(model)
    if not humanoid or humanoid.Health <= 0 or not root then return false end
    local function marked(text)
        local lower = string.lower(tostring(text or ""))
        return lower:find("boss", 1, true) ~= nil or lower:find("chefe", 1, true) ~= nil
    end
    local parent = model
    while parent and parent ~= workspace do
        if marked(parent.Name) then return true end
        for _, key in ipairs({"Boss", "IsBoss", "isBoss", "Chefe", "BossType"}) do
            local value = parent:GetAttribute(key)
            if value == true or (type(value) == "string" and #value > 0) then return true end
        end
        for _, tag in ipairs(parent:GetTags()) do if marked(tag) then return true end end
        parent = parent.Parent
    end
    local realHumanoid = model:FindFirstChildWhichIsA("Humanoid", true)
    if realHumanoid and marked(realHumanoid.DisplayName) then return true end
    for _, obj in ipairs(model:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and marked(obj.Text) then return true end
    end
    return false
end

local priorities = {["Arco-iris"]=6, Mitico=5, Lendario=4, Epico=3, Raro=2, Comum=1, Desconhecido=0}
local rarityKeys = {"Rarity", "rarity", "BossRarity", "bossRarity", "BossType", "bossType", "Tier", "tier", "Raridade", "raridade"}
local function bossInfo(model, classify)
    if not model then return "Desconhecido", 0 end
    local function known(value)
        if type(value) ~= "string" or value == "" then return nil end
        local rarity = classify(value)
        return priorities[rarity] and priorities[rarity] > 0 and rarity or nil
    end
    -- Explicit metadata wins over names and reward text in a billboard.
    local ancestor = model
    while ancestor and ancestor ~= workspace do
        for _, key in ipairs(rarityKeys) do
            local rarity = known(ancestor:GetAttribute(key))
            local field = ancestor:FindFirstChild(key)
            if not rarity and field and field:IsA("StringValue") then rarity = known(field.Value) end
            if rarity then return rarity, priorities[rarity] end
        end
        ancestor = ancestor.Parent
    end
    for _, item in ipairs(model:GetDescendants()) do
        local node, excluded = item, false
        while node and node ~= model do
            local name = string.lower(node.Name)
            for _, word in ipairs({"pet", "mascote", "loot", "drop", "reward", "recompensa"}) do
                if name:find(word,1,true) then excluded = true; break end
            end
            node = node.Parent
        end
        if not excluded and (item:IsA("Model") or item:IsA("Humanoid") or item:IsA("Folder")) then
            for _, key in ipairs(rarityKeys) do
                local rarity = known(item:GetAttribute(key))
                local field = item:FindFirstChild(key)
                if not rarity and field and field:IsA("StringValue") then rarity = known(field.Value) end
                if rarity then return rarity, priorities[rarity] end
            end
        end
    end
    local texts = {model.Name}
    local humanoid = model:FindFirstChildWhichIsA("Humanoid", true)
    if humanoid and type(humanoid.DisplayName) == "string" then texts[#texts+1] = humanoid.DisplayName end
    ancestor = model.Parent
    while ancestor and ancestor ~= workspace do texts[#texts+1] = ancestor.Name; ancestor = ancestor.Parent end
    local named = known(table.concat(texts, " "))
    if named then return named, priorities[named] end
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("TextLabel") or item:IsA("TextButton") then
            local node, excluded = item, false
            while node and node ~= model do
                local name = string.lower(node.Name)
                for _, word in ipairs({"drop", "loot", "reward", "recompensa", "pet", "mascote"}) do
                    if name:find(word,1,true) then excluded = true; break end
                end
                node = node.Parent
            end
            if not excluded then texts[#texts+1] = item.Text end
        end
    end
    local rarity = classify(table.concat(texts, " "))
    return rarity, priorities[rarity] or 0
end

local function chooseBoss(candidates, classify, distance, current)
    local best, bestRank, bestPreferred, bestCurrent, bestDistance
    local preference = string.lower(tostring(S.BossPreference or "Qualquer"))
    for _, model in ipairs(candidates) do
        if model.Parent and modelHasBossMarker(model) then
            local _, rank = bossInfo(model, classify)
            local preferred = preference ~= "qualquer" and string.lower(model.Name) == preference and 1 or 0
            local selected = model == current and 1 or 0
            local range = distance and distance(model) or math.huge
            if not best or rank > bestRank
                or rank == bestRank and preferred > bestPreferred
                or rank == bestRank and preferred == bestPreferred and selected > bestCurrent
                or rank == bestRank and preferred == bestPreferred and selected == bestCurrent and range < bestDistance then
                best, bestRank, bestPreferred, bestCurrent, bestDistance = model, rank, preferred, selected, range
            end
        end
    end
    return best
end

local function shouldSwitch(current, candidate, classify)
    if not candidate or candidate == current then return false end
    if not current or not current.Parent or not modelHasBossMarker(current) then return true end
    local _, oldRank = bossInfo(current, classify)
    local _, newRank = bossInfo(candidate, classify)
    return newRank > oldRank
end

return {root = bossRoot, health = bossHumanoid, matches = modelHasBossMarker,
    info = bossInfo, choose = chooseBoss, shouldSwitch = shouldSwitch, priorities = priorities}
end
