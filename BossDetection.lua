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

return {root = bossRoot, health = bossHumanoid, matches = modelHasBossMarker}
end
