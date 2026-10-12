-- 710Hub bootstrap: mostra falhas antes da inicializacao do menu.
local startupGui
local startupLabel
local function startupStatus(message)
    warn("[710Hub] " .. message)
    if startupLabel then startupLabel.Text = "710Hub\n\n" .. message end
end

local startupOK, startupError = xpcall(function()
    local players = game:GetService("Players")
    local deadline = os.clock() + 30
    while not players.LocalPlayer and os.clock() < deadline do task.wait(0.1) end
    local player = assert(players.LocalPlayer, "Jogador local indisponivel.")
    local parent = assert(player:WaitForChild("PlayerGui", 15), "PlayerGui indisponivel.")
    local old = parent:FindFirstChild("710Hub_Startup")
    if old then old:Destroy() end
    startupGui = Instance.new("ScreenGui")
    startupGui.Name = "710Hub_Startup"
    startupGui.ResetOnSpawn = false
    startupGui.DisplayOrder = 100
    startupGui.Parent = parent
    startupLabel = Instance.new("TextLabel")
    startupLabel.Size = UDim2.new(0.8, 0, 0, 180)
    startupLabel.Position = UDim2.new(0.1, 0, 0.15, 0)
    startupLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 10)
    startupLabel.TextColor3 = Color3.new(1, 1, 1)
    startupLabel.TextSize = 16
    startupLabel.TextWrapped = true
    startupLabel.Parent = startupGui
    local close = Instance.new("TextButton")
    close.Text = "Fechar aviso"
    close.Size = UDim2.new(0, 120, 0, 28)
    close.Position = UDim2.new(0.5, -60, 1, 0)
    close.Parent = startupLabel
    close.Activated:Connect(function()
        startupGui:Destroy()
        startupLabel = nil
    end)
    startupStatus("Carregando...")
    deadline = os.clock() + 30
    while not game:IsLoaded() and os.clock() < deadline do task.wait(0.1) end
    assert(game:IsLoaded(), "O jogo nao carregou em 30 segundos.")
-- 710Hub - Muscle Legends (2026)
-- Script único para Muscle Legends.
-- Features: Auto Train, Auto Rebirth, Auto Chests, Auto Hatch, Pet Manager,
-- Equip Best owned pets, teleport browser, Anti-AFK, Stop All.

if game.GameId ~= 1268927906 then
    error("Abra Muscle Legends antes de executar o 710Hub. GameId atual: " .. tostring(game.GameId))
end

local ENV = (getgenv and getgenv()) or _G
-- Replace an older licensed loader without leaving its renewal loop running.
local previousKeySession = ENV.__710HubKeySession
if previousKeySession then previousKeySession.Alive = false end
ENV.__710HubKeySession = nil
local oldKeyGui = parent:FindFirstChild("710Hub_Key")
if oldKeyGui then oldKeyGui:Destroy() end
local previousSession = ENV.__710HubSession
if previousSession then
    previousSession.Alive = false
    if previousSession.Cleanup then
        pcall(previousSession.Cleanup)
    end
end

local SESSION = {
    Alive = true,
    Version = "2026.10-boss-hover.35",
    Connections = {},
}

local function trackConnection(connection)
    if connection then
        SESSION.Connections[#SESSION.Connections+1] = connection
    end
    return connection
end

ENV.__710HubSession = SESSION

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local rEvents = RS:WaitForChild("rEvents", 20)
assert(rEvents, "rEvents nao apareceu em 20 segundos. Aguarde o jogo carregar e tente novamente.")
local Backpack = LP:WaitForChild("Backpack", 10)

local function getBackpack()
    local current = LP:FindFirstChildOfClass("Backpack")
    if current then
        Backpack = current
        return current
    end
    local ok, found = pcall(function()
        return LP:WaitForChild("Backpack", 5)
    end)
    if ok and found then
        Backpack = found
        return found
    end
    return Backpack
end

local function getMuscleEvent()
    return LP:FindFirstChild("muscleEvent")
        or (LP.Character and LP.Character:FindFirstChild("muscleEvent"))
        or rEvents:FindFirstChild("muscleEvent")
end

local REMOTE_NAMES = {
    Rebirth = "rebirthRemote",
    Crystal = "openCrystalRemote",
    Chest = "checkChestRemote",
    EquipPet = "equipPetEvent",
    EvolvePet = "petEvolveEvent",
    Brawl = "brawlEvent",
    Machine = "machineInteractRemote",
    PetShop = "cPetShopRemote",
}

local R = {}
local function refreshRemotes()
    for key, name in pairs(REMOTE_NAMES) do
        local current = R[key]
        if not current or not current.Parent then
            R[key] = rEvents:FindFirstChild(name)
        end
    end
end
refreshRemotes()

local S = {
    AutoWheel=false, AutoEggs=false, AutoBoosts=false, AutoBestPetObjective=false, AutoEvolveOwned=false,
    SetSpeed=false, SetSize=false, SetFOV=false, InfiniteJump=false, AntiFling=false,
    HideName=false, HideStats=false, Spectate=false, PlayerESP=false,
    PvpProtectFriends=false, PvpOnlySelected=false, WorldTime="Original",
    CharacterSpeed=120, CharacterSize=1, CameraFOV=70, ShopCount=1,
    PvpAny=false, PvpGood=false, PvpEvil=false, PvpRadius=150, PvpAttackRange=2.5,
    TrainWeight=false, TrainPushups=false, TrainSitups=false, TrainHandstands=false,
    Train=false, Rebirth=false, Chests=false, Hatch=false, AutoNovaPhoenix=false, Brawl=false,
    AutoPunch=false, SmartRock=false, LockPosition=false,
    AutoMachine=false, AutoBestMachine=false, StrengthRebirth=false,
    TurboStrength=false, MaxStrengthF2P=false, AutoBoss=false,
    AutoAgility=false, SmartFarm=false,
    AutoEquipAfterHatch=false, AutoEvolveAfterHatch=false,
    PerformanceMode=false, StabilityMode=false, GoalEnabled=false,
    SmartObjective="Força", GoalStat="Strength", GoalValue=nil,
    HatchCrystal="Blue Crystal", NovaCrystal="Charged Crystal", NovaMaxOpens=100, FarmSpeed=2, PreserveFarmPets=false, FarmCustom=false, FarmIntervalMs=100, FarmReps=4, RepDelay=.065, HatchDelay=.45,
    RebirthTarget=nil, SelectedMachine=nil,
    LastRebirthAttempt=0,
    RebirthGuard=false, RebirthFloor=0, RebirthInterval=1,
    BreakEnabled=false, BreakEvery=30, BreakMinutes=5,
    BossAutoLoot=true, BossDefense=true, BossAbove=true, BossDistance=2, BossReturn=true, BossPreference="Qualquer",
    ResumeAfterDeath=true, HealthGuard=true, HealthLow=55, HealthResume=85,
    StallAlerts=true, StallSeconds=60,
    StopAt=nil, ProgressionTarget=nil,
}

local HubRuntime = {
    NovaAttempts = 0, NovaStatus = "Desligado", NovaCrystalVerified = false,
    Status = "Inicializando...",
    LastError = "Nenhum",
    RemoteCalls = 0,
    StartedAt = os.clock(),
    Respawns = 0,
    RemoteRefreshes = 1,
    BossActive = false,
    BossModel = nil, BossDeathsObserved = 0,
    BossTarget = "Aguardando spawn",
    BossReturnCFrame = nil,
    RemoteWindowStarted = os.clock(),
    RemoteWindowCalls = 0,
    SkippedRemoteCalls = 0,
    AvgFPS = 60,
    LowFPSWindows = 0,
    StabilityTrips = 0,
    StabilityPrevious = nil,
}

-- BEGIN MAINTENANCE CORE
local M = (function()
-- Pure controller, embedded into 710Hub.lua by build.ps1. No Roblox dependencies.
return function(settings, clock)
    local M = {
        Reasons = {}, History = {}, Capabilities = {}, Alerts = {},
        BenchmarkToken = 0, Comparing = false, ProfileSlot = 1,
        Totals = {Strength = 0, Rebirths = 0, Deaths = 0},
        Started = clock(), LastProgress = clock(), LastAlert = 0,
        Stalled = false, WasTraining = false, Samples = {}, ActiveSeconds = 0,
        BossCounts = {}, BossObservations = 0, BossRecent = {},
    }
    M.AutoKeys = {"Train", "Rebirth", "Chests", "Hatch", "AutoNovaPhoenix", "Brawl", "AutoPunch",
        "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "PvpAny", "PvpGood", "PvpEvil",
        "SmartRock", "LockPosition", "AutoMachine", "AutoBestMachine", "StrengthRebirth",
        "TurboStrength", "MaxStrengthF2P", "AutoBoss", "AutoAgility", "SmartFarm",
        "AutoEquipAfterHatch", "AutoEvolveAfterHatch", "GoalEnabled",
        "AutoWheel", "AutoEggs", "AutoBoosts", "AutoBestPetObjective", "AutoEvolveOwned",
        "SetSpeed", "SetSize", "SetFOV", "InfiniteJump", "AntiFling", "HideName", "HideStats", "Spectate", "PlayerESP"}
    local booleans = {"PreserveFarmPets", "FarmCustom", "BossAutoLoot", "BossReturn", "BossDefense", "BossAbove", "ResumeAfterDeath", "HealthGuard", "StallAlerts", "PerformanceMode", "StabilityMode", "RebirthGuard", "BreakEnabled", "PvpProtectFriends", "PvpOnlySelected"}
    local numbers = {
        CharacterSpeed = {1, 500}, CharacterSize = {1, 100}, CameraFOV = {30, 120}, ShopCount = {1, 20},
        FarmIntervalMs = {1, 5000}, FarmReps = {1, 160}, FarmSpeed = {1, 3}, NovaMaxOpens = {1, 1000}, PvpRadius = {10, 500}, PvpAttackRange = {1.5, 5}, RepDelay = {.05, 5}, HatchDelay = {.1, 30}, BossDistance = {2, 12},
        HealthLow = {5, 60}, HealthResume = {65, 100}, StallSeconds = {30, 600},
        GoalValue = {1, 1e15}, RebirthTarget = {1, 1e15}, ProgressionTarget = {1, 1e15},
        RebirthFloor = {0, 1e15}, RebirthInterval = {.5, 30}, BreakEvery = {1, 240}, BreakMinutes = {1, 60},
    }
    local choices = {WorldTime = {"Original", "Dia", "Noite"}, SmartObjective = {"Força", "Durabilidade", "Agilidade", "Rebirths"},
        GoalStat = {"Strength", "Agility", "Durability", "Rebirths"}}
    local strings = {"HatchCrystal", "NovaCrystal", "SelectedMachine", "BossPreference"}

    function M:log(kind, message)
        self.History[#self.History + 1] = {Time = math.floor(clock() - self.Started), Kind = kind, Message = tostring(message)}
        if #self.History > 150 then table.remove(self.History, 1) end
    end
    function M:farmPace()
        local levels = {{.2, 1}, {.1, 4}, {.06, 8}}
        local index = math.clamp(math.floor(tonumber(settings.FarmSpeed) or 2), 1, 3)
        local pace = levels[index]
        local delay, burst = pace[1], pace[2]
        if settings.FarmCustom then
            delay = math.clamp(settings.FarmIntervalMs or 100, 1, 5000) / 1000
            burst = math.clamp(math.floor(settings.FarmReps or 4), 1, 160)
        end
        if settings.StabilityMode then delay, burst = math.max(delay, .14), math.min(burst, 3) end
        return delay, burst
    end
    function M:setFarmTiming(key, value)
        if self.Comparing then return false, "Aguarde a comparacao terminar" end
        if key ~= "FarmIntervalMs" and key ~= "FarmReps" then return false, "Campo invalido" end
        local n = tonumber(value)
        local upper = key == "FarmReps" and 160 or 5000
        if not n or n ~= n or n % 1 ~= 0 or n < 1 or n > upper then
            return false, "Use um inteiro de 1 a " .. upper
        end
        settings[key], settings.FarmCustom = n, true
        self.BestTraining = nil
        return true, "Ritmo personalizado aplicado; ative Forca Rapida para usar"
    end
    function M:canAct()
        return next(self.Reasons) == nil
    end
    M.Movements = {{"TrainWeight", "Weight"}, {"TrainPushups", "Pushups"}, {"TrainSitups", "Situps"}, {"TrainHandstands", "Handstands"}}
    M.Conflicts = {}
    local function conflict(a, b)
        M.Conflicts[a] = M.Conflicts[a] or {}
        M.Conflicts[b] = M.Conflicts[b] or {}
        M.Conflicts[a][b], M.Conflicts[b][a] = true, true
    end
    -- Only competing tool/position owners. Selection and passive helpers stay on.
    local trainers = {"Train", "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "TurboStrength", "MaxStrengthF2P", "AutoMachine", "AutoAgility"}
    for i, a in ipairs(trainers) do
        for j = i + 1, #trainers do conflict(a, trainers[j]) end
        conflict(a, "AutoPunch"); conflict(a, "SmartRock")
    end
    for _, key in ipairs({"AutoMachine", "AutoAgility", "SmartRock"}) do conflict(key, "LockPosition") end
    for _, key in ipairs({"TurboStrength", "MaxStrengthF2P", "AutoAgility", "SmartRock", "AutoPunch"}) do conflict(key, "StrengthRebirth") end
    for _, key in ipairs({"Train", "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "TurboStrength", "MaxStrengthF2P", "AutoMachine", "AutoBestMachine", "AutoAgility", "SmartRock", "AutoPunch", "StrengthRebirth", "Rebirth", "LockPosition"}) do conflict("SmartFarm", key) end
    conflict("AutoBestPetObjective", "AutoEquipAfterHatch")
    conflict("AutoEvolveOwned", "AutoEvolveAfterHatch")
    for _, mode in ipairs({"PvpAny", "PvpGood", "PvpEvil"}) do
        for _, key in ipairs(trainers) do conflict(mode, key) end
        for _, key in ipairs({"AutoBoss", "Brawl", "SmartRock", "AutoPunch", "LockPosition", "SmartFarm", "Rebirth", "StrengthRebirth"}) do conflict(mode, key) end
    end
    conflict("Hatch", "AutoNovaPhoenix")
    conflict("PvpGood", "PvpEvil")
    conflict("PvpAny", "PvpGood"); conflict("PvpAny", "PvpEvil")
    function M:pvpEligible(good, evil)
        if settings.PvpAny then return true end
        if type(good) ~= "number" or type(evil) ~= "number" or good ~= good or evil ~= evil or good < 0 or evil < 0 then return false end
        if settings.PvpGood then return evil > good end
        if settings.PvpEvil then return good > evil end
        return false
    end
    function M:trainingMovement()
        for _, pair in ipairs(self.Movements) do if settings[pair[1]] then return pair[2] end end
    end
    function M:clearMovements()
        for _, pair in ipairs(self.Movements) do settings[pair[1]] = false end
    end
    function M:resetBossDefense()
        self.BossLastHealth, self.BossRetreatUntil, self.BossRecovering = nil, nil, false
        self.BossRetreatCFrame = nil
        self:pause("Vida baixa", false)
    end
    function M:bossMayMove()
        for reason in pairs(self.Reasons) do if reason ~= "Vida baixa" then return false end end
        return true
    end
    function M:bossRetreat(health, maxHealth)
        local previous = self.BossLastHealth
        self.BossLastHealth = health
        if settings.HealthGuard and maxHealth > 0 then
            local percent = health * 100 / maxHealth
            if percent <= (settings.HealthLow or 55) then self.BossRecovering = true
            elseif percent >= (settings.HealthResume or 85) then self.BossRecovering = false end
        else self.BossRecovering = false end
        self:pause("Vida baixa", self.BossRecovering == true)
        if not settings.BossDefense then self.BossRetreatUntil = nil
        elseif previous and health < previous then self.BossRetreatUntil = clock() + 2.5 end
        local retreat = self.BossRecovering or (self.BossRetreatUntil ~= nil and clock() < self.BossRetreatUntil)
        if not retreat then self.BossRetreatCFrame = nil end
        return retreat == true
    end
    function M:resolveConflicts(key)
        local disabled = {}
        if not settings[key] then return disabled end
        for other in pairs(self.Conflicts[key] or {}) do
            if settings[other] then settings[other] = false; disabled[#disabled + 1] = other end
        end
        table.sort(disabled)
        return disabled
    end
    function M:resolveMovement(key) return self:resolveConflicts(key) end
    function M:normalizeConflicts()
        -- SmartFarm owns its generated child flags; its next tick rebuilds them.
        if settings.SmartFarm then self:resolveConflicts("SmartFarm") end
        for _, pair in ipairs(self.Movements) do
            if settings[pair[1]] then self:resolveConflicts(pair[1]); break end
        end
        for _, key in ipairs(self.AutoKeys) do
            if key ~= "SmartFarm" then self:resolveConflicts(key) end
        end
    end
    function M:pause(reason, enabled)
        if (self.Reasons[reason] == true) == enabled then return end
        self.Reasons[reason] = enabled and true or nil
        self.LastProgress = clock()
        self:log(enabled and "Pausa" or "Retomada", reason)
    end
    function M:reasonText()
        local result = {}
        for reason in pairs(self.Reasons) do result[#result + 1] = reason end
        table.sort(result)
        return #result > 0 and table.concat(result, ", ") or "Ativo"
    end
    function M:automationSnapshot()
        local result = {}
        for _, key in ipairs(self.AutoKeys) do result[key] = settings[key] == true end
        return result
    end
    function M:clearAutomation()
        for _, key in ipairs(self.AutoKeys) do settings[key] = false end
    end
    function M:restoreAutomation(snapshot)
        for _, key in ipairs(self.AutoKeys) do settings[key] = snapshot[key] == true end
    end
    function M:cancelComparison()
        self.BenchmarkToken += 1
        self.Comparing = false
    end
    function M:profile()
        local result = self:automationSnapshot()
        for _, key in ipairs(booleans) do result[key] = settings[key] end
        for key in pairs(numbers) do result[key] = settings[key] end
        for key in pairs(choices) do result[key] = settings[key] end
        for _, key in ipairs(strings) do result[key] = settings[key] end
        return {Schema = 1, Settings = result}
    end
    function M:validateProfile(profile)
        if type(profile) ~= "table" or profile.Schema ~= 1 or type(profile.Settings) ~= "table" then
            return nil, "Formato de perfil invalido"
        end
        local source, result = profile.Settings, {}
        local function checkBoolean(key)
            if source[key] ~= nil and type(source[key]) ~= "boolean" then return false end
            result[key] = source[key]
            return true
        end
        for _, key in ipairs(self.AutoKeys) do if not checkBoolean(key) then return nil, key end end
        for _, key in ipairs(booleans) do if not checkBoolean(key) then return nil, key end end
        for key, bounds in pairs(numbers) do
            local value = source[key]
            if value ~= nil then
                if type(value) ~= "number" or value ~= value or value < bounds[1] or value > bounds[2]
                    or (key == "ShopCount" and value % 1 ~= 0) then return nil, key end
                result[key] = value
            end
        end
        for key, options in pairs(choices) do
            if source[key] ~= nil then
                if not table.find(options, source[key]) then return nil, key end
                result[key] = source[key]
            end
        end
        for _, key in ipairs(strings) do
            if source[key] ~= nil then
                if type(source[key]) ~= "string" or #source[key] > 150 then return nil, key end
                result[key] = source[key]
            end
        end
        return result
    end
    function M:applyProfile(profile)
        local validated, problem = self:validateProfile(profile)
        if not validated then return false, "Perfil rejeitado: " .. problem end
        self:cancelComparison()
        self:clearAutomation()
        settings.GoalValue, settings.RebirthTarget, settings.ProgressionTarget, settings.SelectedMachine = nil, nil, nil, nil
        settings.StopAt = nil
        for key, value in pairs(validated) do settings[key] = value end
        settings.PvpAny, settings.PvpGood, settings.PvpEvil = false, false, false
        self:normalizeConflicts()
        self:pause("Manual", true)
        self:resetBreak()
        self:log("Perfil", "Configuracao restaurada; use Retomar para iniciar")
        return true
    end
    function M:setGoal(text)
        local value = tonumber(text)
        if not value or value ~= value or value < 1 or value > 1e15 or value % 1 ~= 0 then
            return false, "Digite um inteiro entre 1 e 1000000000000000"
        end
        settings.GoalValue = value
        self:log("Meta", settings.GoalStat .. " = " .. tostring(value))
        return true
    end
    function M:sample(strength, rebirths, training)
        local now = clock()
        if self.LastSampleAt and (now - self.LastSampleAt > 5 or strength < self.LastStrength or rebirths ~= self.LastRebirths) then
            self.Samples = {}
        end
        if not training or not self:canAct() then self.Samples = {} end
        if training and self:canAct() then
            self.Samples[#self.Samples + 1] = {Time = now, Strength = strength}
            while #self.Samples > 1 and self.Samples[1].Time < now - 60 do table.remove(self.Samples, 1) end
            while #self.Samples > 120 do table.remove(self.Samples, 1) end
        end
        self.LastSampleAt = now
        if self.LastStrength then
            local gained = math.max(0, strength - self.LastStrength)
            local rebirthGain = math.max(0, rebirths - self.LastRebirths)
            self.Totals.Strength += gained
            self.Totals.Rebirths += rebirthGain
            if rebirthGain > 0 then self:log("Rebirth", "+" .. rebirthGain) end
            if gained > 0 or rebirthGain > 0 then self.LastProgress = now; self.Stalled = false end
        end
        self.LastStrength, self.LastRebirths = strength, rebirths
        if not training or not self:canAct() or not self.WasTraining then self.LastProgress = now end
        self.WasTraining = training
        if settings.StallAlerts and training and self:canAct() and now - self.LastProgress >= settings.StallSeconds
            and now - self.LastAlert >= settings.StallSeconds then
            self.LastAlert = now
            self.Stalled = true
            self:log("Alerta", "Sem ganho de forca ou rebirth por " .. settings.StallSeconds .. "s")
            return true
        end
        return false
    end
    function M:strengthRate()
        local first, last = self.Samples[1], self.Samples[#self.Samples]
        if not self:canAct() or not first or not last or clock() - last.Time > 5 or last.Time - first.Time < 10 then return nil end
        return math.max(0, last.Strength - first.Strength) * 60 / (last.Time - first.Time)
    end
    function M:eta(current, target)
        if not target then return nil end
        if current >= target then return 0 end
        local rate = self:strengthRate()
        if not rate or rate <= 0 then return nil end
        return (target - current) * 60 / rate
    end
    function M:canRequestRebirth(strength, rebirths)
        if not self:canAct() or self.Comparing or self.RebirthInFlight then return false end
        if settings.RebirthTarget and rebirths >= settings.RebirthTarget then return false end
        if settings.RebirthGuard and strength < (settings.RebirthFloor or 0) then return false end
        return clock() - (self.LastRebirthRequest or -math.huge) >= (settings.RebirthInterval or 1)
    end
    function M:resetBreak()
        self.ActiveSeconds, self.BreakUntil = 0, nil
        self:pause("Descanso", false)
    end
    function M:tickBreak(elapsed, active)
        if not settings.BreakEnabled then self:resetBreak(); return end
        if self.BreakUntil then
            if clock() >= self.BreakUntil then self:resetBreak() end
            return
        end
        if not active or not self:canAct() or self.Comparing then return end
        self.ActiveSeconds += math.max(0, math.min(elapsed, 2))
        if self.ActiveSeconds >= (settings.BreakEvery or 30) * 60 then
            self.BreakUntil = clock() + (settings.BreakMinutes or 5) * 60
            self:pause("Descanso", true)
        end
    end
    function M:bossRarity(text)
        local value = string.lower(tostring(text or ""))
        for a, b in pairs({["é"]="e", ["É"]="e", ["í"]="i", ["Í"]="i", ["á"]="a", ["Á"]="a"}) do value = value:gsub(a, b) end
        value = value:gsub("[%s_%-]", "")
        for _, group in ipairs({
            {"Arco-iris", "rainbow", "arcoiris"}, {"Mitico", "mythic", "mitico"},
            {"Lendario", "legendary", "lendario"}, {"Epico", "epic", "epico"},
            {"Raro", "rare", "raro"}, {"Comum", "common", "comum"},
        }) do
            for i = 2, #group do if value:find(group[i], 1, true) then return group[1] end end
        end
        return "Desconhecido"
    end
    function M:recordBoss(rarity, name)
        self.BossObservations += 1
        self.BossCounts[rarity] = (self.BossCounts[rarity] or 0) + 1
        self.BossRecent[#self.BossRecent + 1] = {Time = math.floor(clock() - self.Started), Rarity = rarity, Name = name}
        if #self.BossRecent > 30 then table.remove(self.BossRecent, 1) end
        self:log("Boss observado", rarity .. " - " .. name)
    end
    function M:bossOddsReport()
        local lines = {"CHANCES EXIBIDAS PELO JOGO (print fornecido)",
            "Comum: 50% | Raro: 30% | Epico: 15% | Lendario: 4% | Mitico: 1%",
            "Arco-iris: apenas administradores; fora do sorteio normal.",
            "Mais provavel no proximo sorteio: Comum (50%). Epico ou melhor: 20%. Lendario ou Mitico: 5%.",
            "Se os sorteios forem independentes e as taxas permanecerem iguais, a chance de pelo menos um Lendario/Mitico e:",
            string.format("10 sorteios: %.1f%% | 20: %.1f%% | 50: %.1f%%", (1-.95^10)*100, (1-.95^20)*100, (1-.95^50)*100),
            "Isso nao preve o proximo boss, nem um horario. Uma sequencia de comuns nao aumenta automaticamente a chance seguinte.",
            "", "OBSERVACOES DESTA SESSAO: " .. self.BossObservations,
            "Contamos aparicoes detectadas. Streaming, entrada no servidor e modelos reutilizados podem afetar a amostra; nao e um registro completo dos sorteios."}
        for _, name in ipairs({"Comum", "Raro", "Epico", "Lendario", "Mitico", "Arco-iris", "Desconhecido"}) do
            local count = self.BossCounts[name] or 0
            lines[#lines + 1] = string.format("%s: %d observados", name, count)
        end
        lines[#lines + 1] = "\nULTIMAS APARICOES (nao comprovam padrao):"
        for _, item in ipairs(self.BossRecent) do lines[#lines + 1] = string.format("%ds | %s | %s", item.Time, item.Rarity, item.Name) end
        return table.concat(lines, "\n")
    end
    function M:updateCapabilities(current)
        for name, available in pairs(current) do
            if self.Capabilities[name] ~= nil and self.Capabilities[name] ~= available then
                self:log("Compatibilidade", name .. (available and ": disponivel novamente" or ": indisponivel"))
            end
        end
        self.Capabilities = current
    end
    function M:report()
        local lines = {"710Hub - historico da sessao", "Estado: " .. self:reasonText(),
            string.format("Tempo: %ds | Forca observada: %.0f | Rebirths: %.0f | Mortes: %d", clock() - self.Started,
                self.Totals.Strength, self.Totals.Rebirths, self.Totals.Deaths), ""}
        for _, entry in ipairs(self.History) do
            lines[#lines + 1] = string.format("[%ds] %s: %s", entry.Time, entry.Kind, entry.Message)
        end
        return table.concat(lines, "\n")
    end
    return M
end
end)()(S, os.clock)
M:pause("Respawn", true)
-- END MAINTENANCE CORE

local function setHubStatus(text)
    HubRuntime.Status = tostring(text or "")
end

local function setHubError(text)
    HubRuntime.LastError = tostring(text or "Desconhecido")
end

task.spawn(function()
    while SESSION.Alive and task.wait(3) do
        refreshRemotes()
        HubRuntime.RemoteRefreshes += 1
    end
end)

-- A interface anterior e removida pelo controlador de sessao.

trackConnection(LP.Idled:Connect(function()
    if not SESSION.Alive then return end
    pcall(function()
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(.2)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end))

local function remoteBudgetPermit()
    local now = os.clock()
    if now - HubRuntime.RemoteWindowStarted >= 1 then
        HubRuntime.RemoteWindowStarted = now
        HubRuntime.RemoteWindowCalls = 0
    end

    local limit = S.StabilityMode and 45 or 160
    if HubRuntime.RemoteWindowCalls >= limit then
        HubRuntime.SkippedRemoteCalls += 1
        return false
    end

    HubRuntime.RemoteWindowCalls += 1
    return true
end

local function safeInvoke(remote, ...)
    if S.BlockAllRebirths and remote and remote.Name == "rebirthRemote" then return false end
    if not M:canAct() then return nil end
    if not SESSION.Alive then return nil end
    if not remote then
        setHubError("RemoteFunction não encontrada")
        return nil
    end
    if not remoteBudgetPermit() then
        return nil
    end
    local args = table.pack(...)
    local ok, a, b = pcall(function()
        HubRuntime.RemoteCalls += 1
        return remote:InvokeServer(table.unpack(args, 1, args.n))
    end)
    if ok then return a, b end
    setHubError(a)
    return nil
end

local function safeFire(remote, ...)
    if not M:canAct() then return false end
    if not SESSION.Alive then return false end
    if not remote then
        setHubError("RemoteEvent não encontrado")
        return false
    end
    if not remoteBudgetPermit() then
        return false
    end
    local args = table.pack(...)
    local ok, err = pcall(function()
        HubRuntime.RemoteCalls += 1
        remote:FireServer(table.unpack(args, 1, args.n))
    end)
    if not ok then
        setHubError(err)
        return false
    end
    return true
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
local agilityOriginalWalkSpeed = nil
local agilityLastTeleport = 0

local function captureLockPosition()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        lockedCFrame = root.CFrame
        return true
    end
    return false
end


task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .14 or .08) do
        if M:canAct() and S.LockPosition and not HubRuntime.BossActive then
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

local function stopAllAutomations()
    if HubRuntime.SourceBridge then HubRuntime.SourceBridge:stop() end
    if HubRuntime.Extras then HubRuntime.Extras:stop() end
    M:cancelComparison()
    if HubRuntime.StopBoss then HubRuntime.StopBoss() end
    if M.stopPvp then M:stopPvp() end
    M:pause("Manual", false)
    M:log("Controle", "Todas as automacoes paradas")
    S.StopAt = nil
    M:resetBreak()
    S.ProgressionTarget = nil
    S.Train = false
    S.PvpAny, S.PvpGood, S.PvpEvil = false, false, false
    M:clearMovements()
    S.Rebirth = false
    S.Chests = false
    S.Hatch = false
    S.AutoNovaPhoenix = false
    HubRuntime.NovaStatus = "Parado pelo usuario"
    S.Brawl = false
    S.AutoPunch = false
    S.SmartRock = false
    S.AutoMachine = false
    S.AutoBestMachine = false
    S.StrengthRebirth = false
    S.TurboStrength = false
    S.MaxStrengthF2P = false
    S.AutoBoss = false
    S.AutoAgility = false
    S.SmartFarm = false
    S.AutoEquipAfterHatch = false
    S.AutoEvolveAfterHatch = false
    S.GoalEnabled = false
    S.LockPosition = false
    lockedCFrame = nil
    setHubStatus("Automações paradas")
    if HubRuntime.RenderToggles then
        task.defer(HubRuntime.RenderToggles)
    end
end

local function findPunchTool()
    local character = LP.Character
    local equipped = character and character:FindFirstChild("Punch")
    if equipped and equipped:IsA("Tool") then return equipped end
    local backpack = getBackpack()
    local tool = backpack and backpack:FindFirstChild("Punch")
    if tool and tool:IsA("Tool") then return tool end
end

local function doAnimatedPunch(allowed)
    local function ready()
        return SESSION.Alive and M:canAct() and (not allowed or allowed())
    end
    if not ready() then return false, "Acao cancelada" end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local tool = findPunchTool()
    if not tool or not humanoid or humanoid.Health <= 0 then return false, "Punch ou personagem indisponivel" end
    if tool.Parent ~= character then
        local equipped = pcall(function() humanoid:EquipTool(tool) end)
        if not equipped then return false, "Falha ao equipar Punch" end
        task.wait(.04)
    end
    if not ready() or LP.Character ~= character or tool.Parent ~= character then return false, "Equipamento ou alvo mudou" end
    if not tool.Enabled then return false, "Aguardando intervalo do Punch" end
    if tool.RequiresHandle and not tool:FindFirstChild("Handle") then return false, "Punch sem Handle" end
    local ok, err = pcall(function() tool:Activate() end)
    if not ok then return false, "Falha no Punch: " .. tostring(err) end
    return true
end

-- BEGIN MAINTENANCE DETECTOR
local BossDetector = (function()
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
end)()(workspace, Players, S)
-- END MAINTENANCE DETECTOR
local bossRoot, bossHumanoid, modelHasBossMarker = BossDetector.root, BossDetector.health, BossDetector.matches

function M:scanBosses(force)
    local interval = S.AutoBoss and .5 or 2
    if not force and self.BossScanAt and os.clock() - self.BossScanAt < interval then return self.BossScanCache end
    local candidates = {}

    local seen = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and modelHasBossMarker(item) then
            local root = bossRoot(item)
            if root and not seen[root] then
                seen[root] = true
                candidates[#candidates + 1] = item
            end
        end
    end

    self.BossScanAt, self.BossScanCache = os.clock(), candidates
    return candidates
end

function M:bossInfo(model)
    return BossDetector.info(model, function(text) return self:bossRarity(text) end)
end

trackConnection(workspace.DescendantAdded:Connect(function(item)
    if item:IsA("Model") or item:IsA("Humanoid") or item:IsA("TextLabel") or item:IsA("StringValue") then
        M.BossScanAt = nil
    end
end))

local function findAliveBoss(current)
    local candidates = {}
    for _, candidate in ipairs(M:scanBosses()) do
        if candidate.Parent and modelHasBossMarker(candidate)
            and os.clock() >= ((M.BossBlocked or {})[candidate] or 0) then candidates[#candidates + 1] = candidate end
    end
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return BossDetector.choose(candidates, function(text) return M:bossRarity(text) end, function(model)
        local targetRoot = bossRoot(model)
        return root and targetRoot and (targetRoot.Position-root.Position).Magnitude or math.huge
    end, current)
end

-- BEGIN MAINTENANCE LOOT
local BossLoot = (function()
-- Select only newly spawned, explicitly labelled loot near the defeated boss.
return function(workspace, players)
    local Loot = {}
    function Loot:snapshot()
        local seen = setmetatable({}, {__mode = "k"})
        for _, item in ipairs(workspace:GetDescendants()) do seen[item] = true end
        return seen
    end
    function Loot:candidates(origin, baseline, attempted)
        local result, grouped = {}, {}
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and not baseline[item] and not attempted[item]
                and (item.Position - origin).Magnitude <= 35 then
                local excluded, marked, ancestor, owner = false, false, item, item
                for _, player in ipairs(players:GetPlayers()) do
                    if player.Character and item:IsDescendantOf(player.Character) then excluded = true end
                end
                while ancestor and ancestor ~= workspace do
                    local name = string.lower(ancestor.Name)
                    if ancestor:GetAttribute("BossReward") == true or ancestor:GetAttribute("IsLoot") == true
                        or name:find("reward", 1, true) or name:find("recompensa", 1, true)
                        or name:find("drop", 1, true) or name:find("loot", 1, true)
                        or name:find("chest", 1, true) or name:find("bau", 1, true) then
                        marked = true
                        if ancestor:IsA("Model") then owner = ancestor end
                        if ancestor:IsA("Model") and baseline[ancestor] then excluded = true end
                    end
                    if ancestor:FindFirstChildOfClass("Humanoid") or ancestor:GetAttribute("IsPet") == true then excluded = true end
                    ancestor = ancestor.Parent
                end
                if marked and not excluded and not attempted[owner] then
                    local previous = grouped[owner]
                    if not previous or (item.Position - origin).Magnitude < (previous.Position - origin).Magnitude then
                        grouped[owner] = item
                    end
                end
            end
        end
        self.Owners = {}
        for owner, item in pairs(grouped) do result[#result + 1] = item; self.Owners[item] = owner end
        table.sort(result, function(a, b) return (a.Position - origin).Magnitude < (b.Position - origin).Magnitude end)
        return result
    end
    function Loot:prompt(owner)
        local prompts = {}
        for _, item in ipairs(owner:GetDescendants()) do
            if item:IsA("ProximityPrompt") and item.Enabled then prompts[#prompts + 1] = item end
        end
        -- Ambiguous interactions need identification instead of choosing randomly.
        if #prompts ~= 1 then return nil end
        local prompt = prompts[1]
        local text = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
        if text:find("buy",1,true) or text:find("purchase",1,true) or text:find("compr",1,true)
            or text:find("robux",1,true) then return nil end
        if text:find("open",1,true) or text:find("claim",1,true) or text:find("collect",1,true)
            or text:find("abrir",1,true) or text:find("colet",1,true) or text:find("resgat",1,true) then return prompt end
    end
    function Loot:rewardText(playerGui)
        if not playerGui then return nil end
        for _, item in ipairs(playerGui:GetDescendants()) do
            if item:IsA("TextLabel") or item:IsA("TextButton") then
                local text = string.upper(item.Text:gsub("<[^>]+>", ""))
                if text:find("CHEST REWARDS", 1, true) or text:find("RECOMPENSAS DO BA", 1, true) then
                    local current, visible = item, true
                    while current and current ~= playerGui do
                        if current.Name:find("710", 1, true) then visible = false; break end
                        if current:IsA("GuiObject") and not current.Visible then visible = false; break end
                        if current:IsA("ScreenGui") and not current.Enabled then visible = false; break end
                        current = current.Parent
                    end
                    if visible then return item.Text end
                end
            end
        end
    end
    return Loot
end
end)()(workspace, Players)
-- END MAINTENANCE LOOT
local function beginBossFight(target)
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not target then return false end

    if not HubRuntime.BossActive then
        HubRuntime.BossReturnCFrame = root.CFrame
        HubRuntime.BossReturnCharacter = character
    end
    M:resetBossDefense()
    M.BossGeneration = (M.BossGeneration or 0) + 1
    M.BossDamageModel, M.BossObservedHealth, M.BossLastDamageAt = nil, nil, nil

    M.BossLootBaseline = BossLoot:snapshot()
    M.BossRewardWasVisible = BossLoot:rewardText(LP:FindFirstChildOfClass("PlayerGui")) ~= nil
    M.BossLootResult = "Aguardando fim do combate"
    M.BossLastPosition = bossRoot(target) and bossRoot(target).Position
    HubRuntime.BossActive = true
    HubRuntime.BossModel = target
    local rarity = M:bossInfo(target)
    HubRuntime.BossTarget = rarity .. " • " .. target.Name
    return true
end

local function finishBossFight(returnToStart)
    if M.releaseBossHover then M:releaseBossHover() end
    M.BossGeneration = (M.BossGeneration or 0) + 1
    M.BossLootUntil, M.BossLootAttempted = nil, nil
    M:resetBossDefense()
    HubRuntime.BossModel = nil
    local wasActive = HubRuntime.BossActive
    HubRuntime.BossActive = false
    HubRuntime.BossTarget = "Aguardando spawn"

    if wasActive and returnToStart and S.BossReturn and HubRuntime.BossReturnCFrame then
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and character == HubRuntime.BossReturnCharacter then
            pcall(function()
                root.CFrame = HubRuntime.BossReturnCFrame
                root.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end

    HubRuntime.BossReturnCFrame = nil
    HubRuntime.BossReturnCharacter = nil
end
HubRuntime.StopBoss = function() finishBossFight(false) end


function M:setBossState(value)
    self.BossState = value
end
function M:requestBossArea(target)
    local root = bossRoot(target)
    if not root or not workspace.StreamingEnabled or self.BossStreamPending then return end
    if self.BossStreamRoot == root and os.clock() < (self.BossStreamRetryAt or 0) then return end
    self.BossStreamRoot, self.BossStreamRetryAt, self.BossStreamPending = root, os.clock()+5, true
    local position = root.Position
    task.spawn(function()
        if SESSION.Alive then pcall(function() LP:RequestStreamAroundAsync(position, 1.5) end) end
        self.BossStreamPending = false
        self.BossScanAt = nil
    end)
end
function M:bossPosition(root, humanoid, target, character, distance, lateral)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, target}
    params.RespectCanCollide = true
    local targetRoot = bossRoot(target)
    if not targetRoot then return nil end
    local desired = targetRoot.Position - targetRoot.CFrame.LookVector * distance + targetRoot.CFrame.RightVector * lateral
    local hit = workspace:Raycast(desired + Vector3.new(0, 20, 0), Vector3.new(0, -512, 0), params)
    if not hit or hit.Normal.Y < .65 or hit.Material == Enum.Material.Water then return nil end
    local position = hit.Position + Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
    return CFrame.lookAt(position, Vector3.new(targetRoot.Position.X, position.Y, targetRoot.Position.Z))
end

-- BEGIN BOSS HOVER
-- Native Auto Kill Boss: inverted character above the loaded boss.
function M:bossHoverFrame(target)
    local targetRoot=bossRoot(target)
    if not targetRoot then return nil end
    local top=targetRoot.Position.Y+targetRoot.Size.Y/2
    local head=target:FindFirstChild("Head",true)
    if head and head:IsA("BasePart") then top=math.max(top,head.Position.Y+head.Size.Y/2) end
    local position=Vector3.new(targetRoot.Position.X,top+math.clamp(S.BossDistance or 3,2,12),targetRoot.Position.Z)
    local look=targetRoot.CFrame.LookVector
    local flat=Vector3.new(look.X,0,look.Z)
    if flat.Magnitude<.01 then flat=Vector3.new(0,0,-1) end
    -- A horizontal yaw followed by 180 degrees on X keeps UpVector pointing
    -- down, with the character's head toward the boss below.
    return CFrame.lookAt(position,position+flat.Unit)*CFrame.Angles(math.pi,0,0)
end
function M:releaseBossHover()
    local saved=self.BossHoverSaved
    self.BossHoverSaved=nil
    self.BossHoverCheckedAt=nil
    if not saved then return end
    pcall(function()
        if saved.Humanoid.Parent then
            saved.Humanoid.AutoRotate=saved.AutoRotate
            if saved.Humanoid.Health>0 then saved.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
        local root=saved.Root
        if LP.Character==saved.Character and root.Parent then
            local look=root.CFrame.LookVector
            local flat=Vector3.new(look.X,0,look.Z)
            if flat.Magnitude<.01 then flat=Vector3.new(0,0,-1) end
            root.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit)
            root.AssemblyAngularVelocity=Vector3.zero
        end
    end)
end
function M:applyBossHover(root,humanoid,character,frame)
    local saved=self.BossHoverSaved
    if saved and (saved.Character~=character or saved.Root~=root) then self:releaseBossHover(); saved=nil end
    if not saved then
        self.BossHoverSaved={Character=character,Root=root,Humanoid=humanoid,AutoRotate=humanoid.AutoRotate}
        humanoid.AutoRotate=false
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
    root.CFrame=frame
    root.AssemblyLinearVelocity=Vector3.zero
    root.AssemblyAngularVelocity=Vector3.zero
end
function M:bossAttackPosition(root,humanoid,target,character)
    local ground=self:bossPosition(root,humanoid,target,character,S.BossDistance,0)
    if not ground then self:releaseBossHover(); return nil end
    if not S.BossAbove then self:releaseBossHover(); return ground end
    self.BossHoverCheckedAt=os.clock()
    return self:bossHoverFrame(target)
end
trackConnection(RunService.Heartbeat:Connect(function()
    local saved=M.BossHoverSaved
    if not saved then return end
    local boss=HubRuntime.BossModel
    local health=boss and bossHumanoid(boss)
    local character=LP.Character
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local low=humanoid and S.HealthGuard and humanoid.MaxHealth>0 and humanoid.Health*100/humanoid.MaxHealth<=(S.HealthLow or 55)
    if not SESSION.Alive or not S.AutoBoss or not S.BossAbove or not HubRuntime.BossActive
        or not M:canAct() or M.BossRecovering or M.BossRetreatCFrame or low
        or not health or health.Health<=0 or not root or not humanoid or humanoid.Health<=0
        or not M.BossHoverCheckedAt or os.clock()-M.BossHoverCheckedAt>.5 then
        M:releaseBossHover(); return
    end
    local frame=M:bossHoverFrame(boss)
    if frame then M:applyBossHover(root,humanoid,character,frame) else M:releaseBossHover() end
end))
-- END BOSS HOVER

task.spawn(function()
    local currentBoss, nextScan, blockedSince = nil, 0, nil
    while SESSION.Alive and task.wait(.2) do
        local ok, failure = pcall(function()
            -- Always process stop, even during manual pause or recovery.
            if not S.AutoBoss then
                if HubRuntime.BossActive then finishBossFight(false) else M:resetBossDefense() end
                currentBoss, blockedSince, nextScan = nil, nil, 0
                M:setBossState("Desligado")
                return
            end
            if not M:bossMayMove() then M:releaseBossHover(); M:setBossState("Pausado: " .. M:reasonText()); return end
            if not findPunchTool() then
                if HubRuntime.BossActive then finishBossFight(true) end
                currentBoss, blockedSince = nil, nil
                M:setBossState("Aguardando ferramenta Punch • retoma automaticamente")
                return
            end
            if os.clock() >= nextScan then
                nextScan = os.clock()+.5
                local candidate = findAliveBoss(currentBoss)
                local currentHealth = currentBoss and bossHumanoid(currentBoss)
                local _, candidateRank = M:bossInfo(candidate)
                local interruptLoot = M.BossLootUntil and candidate
                    and (candidateRank >= 3 or candidate == currentBoss)
                local upgrade = currentHealth and currentHealth.Health > 0 and BossDetector.shouldSwitch(currentBoss, candidate,
                    function(text) return M:bossRarity(text) end)
                if candidate and (interruptLoot or upgrade or not currentBoss and not M.BossLootUntil) then
                    if upgrade then M:log("Prioridade", "Trocando "..currentBoss.Name.." por "..candidate.Name) end
                    M.BossLootUntil, M.BossLootAttempted = nil, nil
                    currentBoss, blockedSince = candidate, nil
                    beginBossFight(candidate)
                    M:requestBossArea(candidate)
                end
            end
            if M.BossLootUntil then
                if not S.BossAutoLoot or os.clock() >= M.BossLootUntil then
                    M.BossLootResult = "Coleta encerrada sem nova tela de recompensa observada"
                    finishBossFight(true); currentBoss, blockedSince = nil, nil
                    return
                end
                if not M:canAct() then M:setBossState("Coleta pausada: " .. M:reasonText()); return end
                local character = LP.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then finishBossFight(false); currentBoss = nil; return end
                if os.clock() < (M.BossLootNextScan or 0) then return end
                M.BossLootNextScan = os.clock() + .5
                local reward = BossLoot:rewardText(LP:FindFirstChildOfClass("PlayerGui"))
                if reward and not M.BossRewardWasVisible then
                    M.BossLootResult = "Nova tela de recompensa observada"
                    M:log("Recompensa", M.BossLootResult)
                    finishBossFight(true); currentBoss, blockedSince = nil, nil
                    return
                end
                M.BossRewardWasVisible = reward ~= nil
                local drops = BossLoot:candidates(M.BossLastPosition, M.BossLootBaseline or {}, M.BossLootAttempted)
                local drop = drops[1]
                if drop and drop.Parent then
                    local owner = BossLoot.Owners[drop] or drop
                    M.BossLootAttempted[owner] = true
                    M:setBossState("Tentando coletar: " .. owner.Name)
                    root.CFrame = CFrame.new(drop.Position + Vector3.new(0, 1, 0))
                    root.AssemblyLinearVelocity = Vector3.zero
                    local prompt = BossLoot:prompt(owner)
                    if prompt then
                        local anchor = prompt.Parent
                        local position = anchor:IsA("Attachment") and anchor.WorldPosition
                            or anchor:IsA("BasePart") and anchor.Position or drop.Position
                        if (root.Position - position).Magnitude <= prompt.MaxActivationDistance then
                            local begun = pcall(function() prompt:InputHoldBegin() end)
                            if begun then
                                local deadline = os.clock() + math.min(prompt.HoldDuration, 5) + .1
                                repeat task.wait(.05) until os.clock() >= deadline or not SESSION.Alive
                                    or not S.AutoBoss or not S.BossAutoLoot or not M:canAct()
                                    or LP.Character ~= character or not prompt.Parent or hum.Health <= 0
                                pcall(function() prompt:InputHoldEnd() end)
                            end
                        end
                    end
                    M:log("Drop", "Interacao tentada: " .. owner.Name .. "; aguardando resposta do jogo")
                else M:setBossState("Aguardando drops reconhecidos (ate 10s)") end
                return
            end
            if currentBoss and not HubRuntime.BossActive then currentBoss = nil end
            local health = currentBoss and bossHumanoid(currentBoss)
            if currentBoss and (not currentBoss.Parent or not health or health.Health <= 0 or not bossRoot(currentBoss)) then
                if health and health.Health <= 0 then
                    HubRuntime.BossDeathsObserved += 1
                    M:log("Boss", "Morte observada: " .. currentBoss.Name)
                end
                if S.BossAutoLoot and M.BossLastPosition then
                    M:resetBossDefense()
                    M.BossLootUntil, M.BossLootAttempted, M.BossLootNextScan = os.clock() + 10, {}, 0
                    M:setBossState("Procurando recompensas no local do boss")
                    return
                end
                finishBossFight(true)
                currentBoss, blockedSince = nil, nil
                nextScan = 0
            end
            if not currentBoss and os.clock() >= nextScan then
                nextScan = os.clock() + .5
                currentBoss = findAliveBoss()
                if currentBoss then beginBossFight(currentBoss); M:requestBossArea(currentBoss) end
            end
            if not currentBoss then M:setBossState("Aguardando boss reconhecido"); return end
            health = bossHumanoid(currentBoss)
            if not health or health.Health <= 0 then
                finishBossFight(true); currentBoss, blockedSince, nextScan = nil, nil, 0
                return
            end
            local character = LP.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid or humanoid.Health <= 0 then
                finishBossFight(false); currentBoss = nil; M:setBossState("Aguardando personagem"); return
            end
            M.BossLastPosition = bossRoot(currentBoss).Position
            local retreat = M:bossRetreat(humanoid.Health, humanoid.MaxHealth)
            if retreat then
                M:releaseBossHover()
                if not M.BossRetreatCFrame then
                    for _, distance in ipairs({20, 28, 36}) do
                        for _, lateral in ipairs({0, 10, -10}) do
                            M.BossRetreatCFrame = M:bossPosition(root, humanoid, currentBoss, character, distance, lateral)
                            if M.BossRetreatCFrame then break end
                        end
                        if M.BossRetreatCFrame then break end
                    end
                    if M.BossRetreatCFrame then
                        root.CFrame = M.BossRetreatCFrame
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                end
                if not M.BossRetreatCFrame then
                    blockedSince = blockedSince or os.clock()
                    M:setBossState("Sem piso seguro para recuar")
                    if os.clock() - blockedSince >= 5 then
                        M.BossBlocked = M.BossBlocked or setmetatable({}, {__mode="k"})
                        M.BossBlocked[currentBoss] = os.clock()+5
                        finishBossFight(true); currentBoss, blockedSince, nextScan = nil, nil, 0
                        M:setBossState("Aguardando piso seguro • nova tentativa automática")
                    end
                else
                    blockedSince = nil
                    M:setBossState(M.BossRecovering and ("Recuperando vida ate " .. S.HealthResume .. "%") or "Recuo apos dano")
                end
                return -- no punches while recovering; hold the chosen retreat location.
            end
            local position = M:bossAttackPosition(root, humanoid, currentBoss, character)
            if not position then
                blockedSince = blockedSince or os.clock()
                M:setBossState("Sem piso seguro para atacar")
                if os.clock() - blockedSince >= 5 then
                    M.BossBlocked = M.BossBlocked or setmetatable({}, {__mode="k"})
                    M.BossBlocked[currentBoss] = os.clock()+5
                    finishBossFight(true); currentBoss, blockedSince, nextScan = nil, nil, 0
                    M:setBossState("Aguardando piso seguro • nova tentativa automática")
                end
                if currentBoss then M:requestBossArea(currentBoss) end
                return
            end
            blockedSince = nil
            if S.BossAbove then M:applyBossHover(root, humanoid, character, position) end
            root.CFrame = position
            root.AssemblyLinearVelocity = Vector3.zero
            if not findPunchTool() then
                finishBossFight(true); currentBoss, blockedSince = nil, nil
                M:setBossState("Aguardando ferramenta Punch • retoma automaticamente")
                return
            end
            if M:canAct() and S.AutoBoss then
                if M.BossDamageModel ~= currentBoss then
                    M.BossDamageModel, M.BossObservedHealth, M.BossLastDamageAt = currentBoss, health.Health, os.clock()
                elseif health.Health < (M.BossObservedHealth or health.Health) then M.BossLastDamageAt = os.clock() end
                M.BossObservedHealth = health.Health
                local target = currentBoss
                local generation = M.BossGeneration
                local punched, reason = doAnimatedPunch(function()
                    local hp = bossHumanoid(target)
                    return S.AutoBoss and M:canAct() and LP.Character == character and target.Parent ~= nil
                        and M.BossGeneration == generation
                        and HubRuntime.BossModel == target and hp and hp.Health > 0
                end)
                if not punched then M:setBossState(reason or "Soco indisponivel")
                elseif os.clock() - M.BossLastDamageAt >= 8 then M:setBossState("Sem queda de vida há 8s; reduza a altura / distância para alcançar")
                else M:setBossState("Punch ativo: " .. currentBoss.Name) end
            end
        end)
        if not ok then
            finishBossFight(false); currentBoss, blockedSince, nextScan = nil, nil, os.clock()+2
            M:setBossState("Falha temporária • nova tentativa em 2s; veja o diagnóstico")
            if M.BossLastError ~= tostring(failure) or os.clock() >= (M.BossErrorLogAt or 0) then
                M.BossLastError, M.BossErrorLogAt = tostring(failure), os.clock()+10
                M:log("Erro no boss", tostring(failure)); setHubError("Auto Boss: " .. tostring(failure))
            end
        end
    end
end)

local function bestAvailableRock()
    local machines = workspace:FindFirstChild("machinesFolder")
    if not machines then return nil end

    local durability = numberStat("Durability")
    local bestRock, bestNeed = nil, -1

    for _, node in ipairs(machines:GetDescendants()) do
        if node.Name == "neededDurability"
            and (node:IsA("IntValue") or node:IsA("NumberValue"))
            and tonumber(node.Value) then
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
    if not SESSION.Alive or not M:canAct() then return false end
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

local MACHINE_TIERS = {
    {"jungle", 10000},
    {"muscle king", 9000},
    {"legends", 8000},
    {"eternal", 7000},
    {"mythical", 6000},
    {"inferno", 5500},
    {"frost", 5000},
    {"frozen", 5000},
    {"golden", 4000},
}

local MACHINE_TYPES = {
    {"bar lift", 90},
    {"squat", 80},
    {"press", 70},
    {"throw", 60},
    {"bench", 50},
    {"pullup", 40},
    {"lift", 30},
}

local function machineScore(name)
    local lower = string.lower(name)
    local score = 0

    for _, entry in ipairs(MACHINE_TIERS) do
        if string.find(lower, entry[1], 1, true) then
            score += entry[2]
            break
        end
    end

    for _, entry in ipairs(MACHINE_TYPES) do
        if string.find(lower, entry[1], 1, true) then
            score += entry[2]
            break
        end
    end

    return score
end

local function selectBestMachine()
    local machines = scanMachines()
    if #machines == 0 then
        S.SelectedMachine = nil
        return nil
    end

    table.sort(machines, function(a,b)
        local sa, sb = machineScore(a.name), machineScore(b.name)
        if sa == sb then
            return string.lower(a.name) < string.lower(b.name)
        end
        return sa > sb
    end)

    S.SelectedMachine = machines[1].name
    return machines[1]
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
    if not SESSION.Alive or not M:canAct() then return false end
    local info = S.AutoBestMachine and selectBestMachine() or getSelectedMachine()
    if not info or not info.seat or not info.seat.Parent then return false end

    refreshRemotes()

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local distance = (root.Position - info.seat.Position).Magnitude
    if moveCharacter or distance > 14 then
        pcall(function()
            root.CFrame = info.seat.CFrame * CFrame.new(0, 3, 0)
        end)
        task.wait(.15)
    end

    if not R.Machine or not getMuscleEvent() then
        return false
    end

    safeInvoke(R.Machine, "useMachine", info.seat)
    safeFire(getMuscleEvent(), "rep", info.seat)
    return true
end

local TREADMILLS = {
    {
        name = "Praia",
        minAgility = 0,
        priority = 1,
        cf = CFrame.new(238.671112, 5.40315914, 387.713165, -0.0160072874, -2.90710176e-08, -0.99987185, -3.3434191e-09, 1, -2.90212157e-08, 0.99987185, 2.87843993e-09, -0.0160072874)
    },
    {
        name = "Frost Gym",
        minAgility = 2000,
        priority = 2,
        cf = CFrame.new(-3005.37866, 14.3221855, -464.697876, -0.015773816, -1.38508964e-08, 0.999875605, -5.13225586e-08, 1, 1.30429667e-08, -0.999875605, -5.11104332e-08, -0.015773816)
    },
    {
        name = "Mythical Gym",
        minAgility = 2000,
        priority = 3,
        cf = CFrame.new(2571.23706, 15.6896839, 898.650391, 0.999968231, 2.23868635e-09, -0.00797206629, -1.73198844e-09, 1, 6.35660768e-08, 0.00797206629, -6.3550246e-08, 0.999968231)
    },
    {
        name = "Legends Gym",
        minAgility = 3000,
        priority = 4,
        cf = CFrame.new(4370.82812, 999.358704, -3621.42773, -0.960604727, -8.41949266e-09, -0.27791819, -6.12478646e-09, 1, -9.12496567e-09, 0.27791819, -7.06329528e-09, -0.960604727)
    },
    {
        name = "Eternal Gym",
        minAgility = 3500,
        priority = 5,
        cf = CFrame.new(-7077.79102, 29.6702118, -1457.59961, -0.0322036594, -3.31122768e-10, 0.99948132, -6.44344267e-09, 1, 1.23684493e-10, -0.99948132, -6.43611742e-09, -0.0322036594)
    },
    {
        name = "Jungle Gym",
        minAgility = 20000,
        priority = 6,
        cf = CFrame.new(-8138.67919921875, 28.270538330078125, 2833.511474609375, -0.960604727, -8.41949266e-09, -0.27791819, -6.12478646e-09, 1, -9.12496567e-09, 0.27791819, -7.06329528e-09, -0.960604727)
    },
}

local function bestTreadmill()
    local agility = numberStat("Agility")
    local best = TREADMILLS[1]

    for _, tm in ipairs(TREADMILLS) do
        if agility >= tm.minAgility and tm.priority >= best.priority then
            best = tm
        end
    end

    return best
end

task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .10 or .05) do
        if M:canAct() and S.AutoAgility and not HubRuntime.BossActive then
            if S.LockPosition then
                S.LockPosition = false
                lockedCFrame = nil
            end

            local character = LP.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local tm = bestTreadmill()

            if humanoid and root and tm then
                if not agilityOriginalWalkSpeed then
                    agilityOriginalWalkSpeed = humanoid.WalkSpeed
                end

                humanoid.WalkSpeed = 10

                if os.clock() - agilityLastTeleport > 1.2 then
                    pcall(function()
                        root.CFrame = tm.cf
                    end)
                    agilityLastTeleport = os.clock()
                end

                pcall(function()
                    humanoid:Move(Vector3.new(10000, 0, -1), true)
                end)
            end
        elseif agilityOriginalWalkSpeed then
            local character = LP.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = agilityOriginalWalkSpeed
            end
            agilityOriginalWalkSpeed = nil
        end
    end
end)

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

local function findTrainingTool(movement)
    if movement then
        for _, container in ipairs({LP.Character or false, getBackpack() or false}) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and string.lower(tool.Name) == string.lower(movement) then return tool end
                end
            end
        end
        return nil
    end
    local equipped = currentTool()
    if equipped and not hasKeyword(equipped.Name, IGNORE_TOOL_KEYWORDS) then
        return equipped
    end

    local fallback
    local backpack = getBackpack()
    if not backpack then return equipped end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and not hasKeyword(tool.Name, IGNORE_TOOL_KEYWORDS) then
            if hasKeyword(tool.Name, TRAINING_KEYWORDS) then
                return tool
            end
            fallback = fallback or tool
        end
    end
    return fallback
end

local function activateTrainingTool(movement)
    if not SESSION.Alive or not M:canAct() then return false end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local tool = findTrainingTool(movement)
    if not tool then return false end

    local backpack = getBackpack()
    if backpack and tool.Parent == backpack then
        pcall(function()
            humanoid:EquipTool(tool)
        end)
        task.wait(.05)
    end

    if not SESSION.Alive or not M:canAct() then return false end
    if movement and M:trainingMovement() ~= movement then return false end
    if tool.Parent == character then
        local ok = pcall(function()
            tool:Activate()
        end)
        return ok
    end

    return false
end


local function equipStrengthTool()
    if not SESSION.Alive or not M:canAct() then return false end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = getBackpack()
    if not humanoid or not backpack then return nil end

    local preferred = {
        "Weight",
        "Pushups",
        "Situps",
        "Handstands",
    }

    for _, name in ipairs(preferred) do
        local tool = character:FindFirstChild(name) or backpack:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            if tool.Parent == backpack then
                pcall(function()
                    humanoid:EquipTool(tool)
                end)
                task.wait(.03)
            end
            return tool
        end
    end

    local tool = findTrainingTool()
    if tool and tool.Parent == backpack then
        pcall(function()
            humanoid:EquipTool(tool)
        end)
        task.wait(.03)
    end
    return tool
end

local function fastStrengthBurst()
    if not SESSION.Alive or not M:canAct() or HubRuntime.BossActive then return false end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local event = getMuscleEvent()
    if not event then return false end

    local tool = equipStrengthTool()
    if not SESSION.Alive or not M:canAct() or HubRuntime.BossActive or LP.Character ~= character
        or not (S.TurboStrength or S.MaxStrengthF2P) then return false end
    if tool and tool.Parent == character then
        pcall(function()
            tool:Activate()
        end)
    end

    -- Muscle Legends aceita "rep" como a ação de treino. Em vez de depender
    -- de uma máquina específica, enviamos uma rajada curta e limitada.
    local _, burst = M:farmPace()
    for _ = 1, burst do
        if not SESSION.Alive or not M:canAct() or HubRuntime.BossActive or not (S.TurboStrength or S.MaxStrengthF2P) then break end
        safeFire(event, "rep")
    end

    return true
end

task.spawn(function()
    local failures = 0
    local windowStart = os.clock()
    local windowStrength = numberStat("Strength")
    local noGainWindows = 0
    local windowRebirths = currentRebirths()

    while SESSION.Alive and task.wait((M:farmPace())) do
        if M:canAct() and S.TurboStrength and not HubRuntime.BossActive then
            if fastStrengthBurst() then
                failures = 0
            else
                failures += 1
            end

            if os.clock() - windowStart >= 2.5 then
                local now = numberStat("Strength")
                local gained = math.max(0, now - windowStrength)

                local rebirths = currentRebirths()
                if rebirths ~= windowRebirths then
                    noGainWindows = 0
                elseif gained > 0 then
                    noGainWindows = 0
                    setHubStatus("Força Rápida • +"..math.floor(gained).." em 2.5s")
                else
                    noGainWindows += 1
                    setHubStatus("Força Rápida • aguardando ganho...")
                end

                windowRebirths = rebirths
                windowStrength = now
                windowStart = os.clock()

                if noGainWindows >= 6 or failures >= 20 then
                    S.TurboStrength = false
                    noGainWindows = 0
                    failures = 0
                    setHubStatus("Força Rápida desligada: nenhum ganho detectado")
                    if HubRuntime.RenderToggles then
                        task.defer(HubRuntime.RenderToggles)
                    end
                end
            end
        else
            failures = 0
            noGainWindows = 0
            windowStart = os.clock()
            windowStrength = numberStat("Strength")
        end
    end
end)

local function getPetShopFolder()
    local shared = RS:FindFirstChild("shared")
    local runtime = shared and shared:FindFirstChild("runtime")
    return runtime and runtime:FindFirstChild("cPetShopFolder")
end

local function findShopPetByNamePart(part)
    local folder = getPetShopFolder()
    if not folder then return nil end

    part = string.lower(part or "")
    for _, item in ipairs(folder:GetChildren()) do
        if item:GetAttribute("IsPowerUp") ~= true
            and string.find(string.lower(item.Name), part, 1, true) then
            return item
        end
    end

    return nil
end

local function buyShopPet(item)
    if not item or not item.Parent then
        setHubError("Pet não encontrado no catálogo atual")
        return false
    end

    local remote = R.PetShop or rEvents:FindFirstChild("cPetShopRemote")
    if not remote then
        setHubError("cPetShopRemote não encontrado")
        return false
    end

    local result = safeInvoke(remote, item)
    if result == nil and HubRuntime.LastError ~= "Nenhum" then
        return false
    end

    setHubStatus("Compra solicitada: "..item.Name)
    return true
end

local function buyApexPet()
    local apex = findShopPetByNamePart("apex")
    if not apex then
        setHubError("Apex não está disponível no catálogo deste servidor")
        setHubStatus("Apex indisponível")
        return false
    end
    return buyShopPet(apex)
end

local function detectNovaCrystalTitle()
    local playerGui = LP:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    for _, widget in ipairs(playerGui:GetDescendants()) do
        if (widget:IsA("TextLabel") or widget:IsA("TextButton"))
            and string.find(string.lower(widget.Text), "nova phoenix", 1, true)
            and not widget:FindFirstAncestor("710Hub_MuscleLegends") then
            local parent = widget.Parent
            while parent and parent ~= playerGui do
                for _, label in ipairs(parent:GetDescendants()) do
                    if label ~= widget and (label:IsA("TextLabel") or label:IsA("TextButton")) then
                        local plain = string.gsub(label.Text, "<.->", "")
                        local title = string.match(plain, "^%s*(.-)%s*$")
                        if #title >= 8 and #title <= 60 and string.match(string.lower(title), "crystal$") then
                            return title
                        end
                    end
                end
                parent = parent.Parent
            end
        end
    end
end

local function novaInventoryCount()
    local folder = LP:FindFirstChild("petsFolder")
    if not folder then return nil end
    local total = 0
    for _, group in ipairs(folder:GetChildren()) do total += #group:GetChildren() end
    return total
end

local function novaGems()
    local stats = LP:FindFirstChild("leaderstats")
    for _, container in ipairs({LP, stats or LP}) do
        for _, name in ipairs({"Gems", "gems"}) do
            local value = container:FindFirstChild(name)
            if value and (value:IsA("NumberValue") or value:IsA("IntValue")) then return value.Value end
        end
    end
end

local function ownsNovaPhoenix()
    local folder = LP:FindFirstChild("petsFolder")
    if not folder then return false end
    for _, pet in ipairs(folder:GetDescendants()) do
        if string.lower(pet.Name) == "nova phoenix" then return true end
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
    local score = 0
    local foundStat = false

    local function addNumeric(container, key)
        local value = container and container:FindFirstChild(key)
        if value and tonumber(value.Value) then
            score += tonumber(value.Value)
            foundStat = true
        end
    end

    for _, key in ipairs({"strength","Strength","agility","Agility","durability","Durability"}) do
        addNumeric(p.pet, key)
    end

    local perks = p.pet:FindFirstChild("perksFolder")
    if perks then
        for _, key in ipairs({"strength","Strength","agility","Agility","durability","Durability"}) do
            addNumeric(perks, key)
        end
    end

    local level = p.pet:FindFirstChild("level") or p.pet:FindFirstChild("Level")
    if level and tonumber(level.Value) then
        score += tonumber(level.Value) * 0.001
    end

    if not foundStat then
        score += (rarityRank[p.rarity] or 0)
    end

    return score
end

local function petStrengthScore(p)
    local score = 0
    local found = false

    local function add(container, key)
        local value = container and container:FindFirstChild(key)
        if value and tonumber(value.Value) then
            score += tonumber(value.Value)
            found = true
        end
    end

    for _, key in ipairs({"strength","Strength"}) do
        add(p.pet, key)
    end

    local perks = p.pet:FindFirstChild("perksFolder")
    if perks then
        for _, key in ipairs({"strength","Strength"}) do
            add(perks, key)
        end
    end

    if not found then
        score = petPower(p)
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
    if not SESSION.Alive or not M:canAct() then return false end
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

local function equipBestStrengthOwned()
    if not SESSION.Alive or not M:canAct() or M.PetEquipBusy then return false end
    refreshRemotes()
    if not R.EquipPet then return false end
    local pets = allOwnedPets()
    if #pets == 0 then return false end
    local equipped, slots = equippedPets()
    if slots <= 0 then return false end
    table.sort(pets, function(a,b)
        local sa, sb = petStrengthScore(a), petStrengthScore(b)
        if sa ~= sb then return sa > sb end
        if equipped[a.pet] ~= equipped[b.pet] then return equipped[a.pet] == true end
        return tostring(a.pet) < tostring(b.pet)
    end)
    local desired = {}
    for i = 1, math.min(slots, #pets) do desired[pets[i].pet] = true end
    M.PetEquipBusy = true
    local ok, result = pcall(function()
        for pet in pairs(equipped) do
            if not desired[pet] then
                if not SESSION.Alive or not M:canAct() then return false end
                if not safeFire(R.EquipPet, "unequipPet", pet) then return false end
                task.wait(S.StabilityMode and .18 or .10)
            end
        end
        for i = 1, math.min(slots, #pets) do
            local pet = pets[i].pet
            if not equipped[pet] then
                if not SESSION.Alive or not M:canAct() then return false end
                if not safeFire(R.EquipPet, "equipPet", pet) then return false end
                task.wait(S.StabilityMode and .22 or .12)
            end
        end
        return true
    end)
    M.PetEquipBusy = false
    if not ok then setHubError(tostring(result)); return false end
    return result
end

local function evolveReadyOwned()
    local token = HubRuntime.Extras and HubRuntime.Extras.Token
    if not SESSION.Alive or not M:canAct() then return false end
    if not R.EvolvePet then return end
    local counts = {}
    for _, entry in ipairs(allOwnedPets()) do
        counts[entry.pet.Name] = (counts[entry.pet.Name] or 0) + 1
    end
    for name,count in pairs(counts) do
        local tries = math.floor(count/5)
        for _=1,tries do
            if not SESSION.Alive or not M:canAct() or (HubRuntime.Extras and HubRuntime.Extras.Token ~= token) then return false end
            safeFire(R.EvolvePet, "evolvePet", name)
            task.wait(.35)
        end
    end
end

task.spawn(function()
    while SESSION.Alive and task.wait(math.max(S.RepDelay, S.StabilityMode and 0.18 or 0.12)) do
        if M:canAct() and (S.Train or M:trainingMovement()) and not HubRuntime.BossActive then
            -- Prefer the game's normal Tool activation: this keeps the
            -- character animation visible and lets the tool's own LocalScript
            -- handle the training event. Fallback only if no usable tool exists.
            local movement = M:trainingMovement()
            local animated = activateTrainingTool(movement)
            if not animated and not movement then
                safeFire(getMuscleEvent(), "rep")
            end
        end
    end
end)

function M:attemptRebirth()
    if not self:canRequestRebirth(numberStat("Strength"), currentRebirths()) then return end
    self.LastRebirthRequest, self.RebirthInFlight = os.clock(), true
    local ok, err = pcall(safeInvoke, R.Rebirth, "rebirthRequest")
    self.RebirthInFlight = false
    if not ok then setHubError(tostring(err)) end
end

task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .14 or .06) do
        if M:canAct() and S.Rebirth and not HubRuntime.BossActive then
            if S.RebirthTarget and currentRebirths() >= S.RebirthTarget then
                S.Rebirth = false
            else
                M:attemptRebirth()
            end
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .24 or .16) do
        if M:canAct() and S.AutoPunch and not HubRuntime.BossActive then
            doAnimatedPunch()
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .30 or .18) do
        if M:canAct() and S.SmartRock and not HubRuntime.BossActive then
            farmBestRock()
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        if M:canAct() and S.AutoBestMachine and not HubRuntime.BossActive then
            selectBestMachine()
        end
    end
end)

task.spawn(function()
    local failures = 0
    while SESSION.Alive and task.wait(S.StabilityMode and .42 or .28) do
        if M:canAct() and S.AutoMachine and not HubRuntime.BossActive then
            if useSelectedMachine(false) then
                failures = 0
            else
                failures += 1
                if failures >= 6 then
                    S.AutoMachine = false
                    failures = 0
                    setHubStatus("Treino em máquina desativado: recurso indisponível")
                    if HubRuntime.RenderToggles then task.defer(HubRuntime.RenderToggles) end
                end
            end
        else
            failures = 0
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .45 or .25) do
        if S.StrengthRebirth and S.RebirthTarget and currentRebirths() >= S.RebirthTarget then
            S.StrengthRebirth = false
            if S.SmartObjective == "Rebirths" then S.SmartFarm = false end
        end
        if M:canAct() and S.StrengthRebirth and not HubRuntime.BossActive then
            if not S.AutoMachine and not S.Train and not M:trainingMovement() then
                local animated = activateTrainingTool()
                if not animated then
                    safeFire(getMuscleEvent(), "rep")
                end
            end
            M:attemptRebirth()
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        if M:canAct() and S.Chests and not HubRuntime.BossActive then
            for _,name in ipairs(CHESTS) do
                if not SESSION.Alive or not M:canAct() or not S.Chests or HubRuntime.BossActive then break end
                safeInvoke(R.Chest, name)
                task.wait(.12)
            end
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(.1) do
        if M:canAct() and S.Hatch then
            safeInvoke(R.Crystal, "openCrystal", S.HatchCrystal)
            task.wait(S.StabilityMode and math.max(S.HatchDelay, .70) or S.HatchDelay)
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(.2) do
        if S.AutoNovaPhoenix then
            if not M:canAct() then
                HubRuntime.NovaStatus = "Pausado: " .. M:reasonText()
            elseif ownsNovaPhoenix() then
                S.AutoNovaPhoenix = false
                HubRuntime.NovaStatus = "Nova Phoenix encontrada no inventario; abertura parada"
                M:log("Pets", HubRuntime.NovaStatus)
            elseif HubRuntime.NovaAttempts >= S.NovaMaxOpens then
                S.AutoNovaPhoenix = false
                HubRuntime.NovaStatus = "Limite de " .. S.NovaMaxOpens .. " tentativas atingido; confira inventario e Gems"
                M:log("Pets", HubRuntime.NovaStatus)
            else
                if not HubRuntime.NovaCrystalVerified then
                    local observedTitle = detectNovaCrystalTitle()
                    if observedTitle then
                        S.NovaCrystal = observedTitle
                        HubRuntime.NovaCrystalVerified = true
                        M:log("Pets", "Cristal identificado na interface: " .. observedTitle)
                    end
                end
                if not HubRuntime.NovaCrystalVerified then
                    HubRuntime.NovaStatus = "Abra a janela do cristal Overcharged ou confirme o nome no campo abaixo"
                else
                    refreshRemotes()
                    if not R.Crystal then
                        S.AutoNovaPhoenix = false
                        HubRuntime.NovaStatus = "Remote de cristal indisponivel neste servidor"
                    elseif not novaInventoryCount() then
                        HubRuntime.NovaStatus = "Aguardando inventario de pets carregar"
                    else
                        local crystal = string.match(S.NovaCrystal or "", "^%s*(.-)%s*$")
                        local beforeCalls = HubRuntime.RemoteCalls
                        local beforePets, beforeGems = novaInventoryCount(), novaGems()
                        local result = safeInvoke(R.Crystal, "openCrystal", crystal)
                        if HubRuntime.RemoteCalls == beforeCalls then
                            HubRuntime.NovaStatus = "Abertura nao enviada: " .. tostring(HubRuntime.LastError)
                        elseif result == false then
                            S.AutoNovaPhoenix = false
                            HubRuntime.NovaStatus = "Cristal recusado pelo jogo; confira nome, Gems e espaco"
                        else
                            HubRuntime.NovaAttempts += 1
                            task.wait(math.max(S.HatchDelay, S.StabilityMode and .7 or .5))
                            local afterPets, afterGems = novaInventoryCount(), novaGems()
                            if (afterPets and beforePets and afterPets > beforePets)
                                or (afterGems and beforeGems and afterGems < beforeGems) then
                                HubRuntime.NovaNoProgress = 0
                                HubRuntime.NovaStatus = "Abertura observada: " .. HubRuntime.NovaAttempts .. "/" .. S.NovaMaxOpens .. " em " .. crystal
                            else
                                HubRuntime.NovaNoProgress = (HubRuntime.NovaNoProgress or 0) + 1
                                HubRuntime.NovaStatus = "Sem confirmacao da abertura " .. HubRuntime.NovaAttempts .. "/" .. S.NovaMaxOpens .. " em " .. crystal
                                if HubRuntime.NovaNoProgress >= 6 then
                                    S.AutoNovaPhoenix = false
                                    HubRuntime.NovaStatus = "Parado: seis solicitacoes sem mudanca em pets/Gems. Confira nome do cristal e recursos."
                                    M:log("Pets", HubRuntime.NovaStatus)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    local lastEquip = 0
    local lastEvolve = 0
    while SESSION.Alive and task.wait(1) do
        if M:canAct() and S.Hatch and S.AutoEquipAfterHatch and os.clock() - lastEquip >= 8 then
            equipBestOwned()
            lastEquip = os.clock()
            setHubStatus("Melhores pets equipados automaticamente")
        end
        if M:canAct() and S.Hatch and S.AutoEvolveAfterHatch and os.clock() - lastEvolve >= 25 then
            evolveReadyOwned()
            lastEvolve = os.clock()
            setHubStatus("Verificação de evolução concluída")
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        if M:canAct() and S.Brawl and not HubRuntime.BossActive then safeFire(R.Brawl, "joinBrawl") end
    end
end)

local function hasCharacter()
    local character = LP.Character
    return character
        and character:FindFirstChild("HumanoidRootPart") ~= nil
        and character:FindFirstChildOfClass("Humanoid") ~= nil
end

local function canTrain()
    return getMuscleEvent() ~= nil or findTrainingTool() ~= nil
end

local function canRebirth()
    refreshRemotes()
    return R.Rebirth ~= nil
end

local function canPunch()
    return getMuscleEvent() ~= nil and findPunchTool() ~= nil
end

local function canAutoBoss()
    return hasCharacter() and findPunchTool() ~= nil
end

local function canRockFarm()
    return type(firetouchinterest) == "function"
        and hasCharacter()
        and bestAvailableRock() ~= nil
end

local function canMachineFarm()
    refreshRemotes()
    return R.Machine ~= nil
        and getMuscleEvent() ~= nil
        and #scanMachines() > 0
end

local function canAgilityFarm()
    return hasCharacter() and LP:FindFirstChild("Agility") ~= nil
end

local function canChestFarm()
    refreshRemotes()
    return R.Chest ~= nil
end

local function canBrawl()
    refreshRemotes()
    return R.Brawl ~= nil
end

local function canHatch()
    refreshRemotes()
    return R.Crystal ~= nil
end

local function canPetManager()
    refreshRemotes()
    return R.EquipPet ~= nil and LP:FindFirstChild("petsFolder") ~= nil
end

local function canPetShop()
    refreshRemotes()
    return R.PetShop ~= nil and getPetShopFolder() ~= nil
end

local function maxStrengthF2PTick()
    if not SESSION.Alive or not M:canAct() then return false end
    if not S.MaxStrengthF2P then return false end
    if HubRuntime.BossActive then return false end

    local trained = false

    if canMachineFarm() then
        selectBestMachine()
        trained = useSelectedMachine(false) == true
    end

    if not trained then
        trained = fastStrengthBurst()
    end

    return trained
end

task.spawn(function()
    local lastPetRefresh = 0
    local lastStrength = numberStat("Strength")
    local lastMeasure = os.clock()
    local failures = 0

    while SESSION.Alive and task.wait((M:farmPace())) do
        if M:canAct() and S.MaxStrengthF2P then
            if not S.PreserveFarmPets and os.clock() - lastPetRefresh >= 10 and not HubRuntime.BossActive then
                pcall(equipBestStrengthOwned)
                lastPetRefresh = os.clock()
            end

            if maxStrengthF2PTick() then
                failures = 0
            else
                failures += 1
            end

            if os.clock() - lastMeasure >= 3 then
                local nowStrength = numberStat("Strength")
                local gained = math.max(0, nowStrength - lastStrength)

                if gained > 0 then
                    setHubStatus("Força F2P Máxima • +"..math.floor(gained).." em 3s")
                else
                    setHubStatus("Força F2P Máxima • procurando melhor treino...")
                end

                lastStrength = nowStrength
                lastMeasure = os.clock()

                if failures >= 20 then
                    S.MaxStrengthF2P = false
                    failures = 0
                    setHubStatus("Força F2P Máxima desligada: treino indisponível")
                    if HubRuntime.RenderToggles then
                        task.defer(HubRuntime.RenderToggles)
                    end
                end
            end
        else
            failures = 0
            lastStrength = numberStat("Strength")
            lastMeasure = os.clock()
        end
    end
end)

local function runSelfTest()
    refreshRemotes()

    local results = {}
    local passed, failed = 0, 0

    local function check(name, fn)
        local ok, value = pcall(fn)
        local success = ok and value == true
        if success then passed += 1 else failed += 1 end
        results[#results+1] = (success and "OK  " or "OFF ") .. name
        if not ok then
            results[#results+1] = "    erro: "..tostring(value)
        end
        return success
    end

    check("Jogo correto", function() return game.GameId == 1268927906 end)
    check("LocalPlayer disponível", function() return LP ~= nil end)
    check("Personagem/Humanoid/HRP", hasCharacter)
    check("Backpack disponível", function()
        local bp = getBackpack and getBackpack() or Backpack
        return bp ~= nil and bp.Parent ~= nil
    end)
    check("muscleEvent disponível", function() return getMuscleEvent() ~= nil end)
    check("Treino disponível", canTrain)
    check("Força F2P Máxima", function() return canTrain() or canMachineFarm() end)
    check("Rebirth disponível", canRebirth)
    check("Punch disponível", canPunch)
    check("Auto Boss disponível", canAutoBoss)
    check("Farm de pedra disponível", canRockFarm)
    check("Máquinas disponíveis", canMachineFarm)
    check("Agilidade disponível", canAgilityFarm)
    check("Baús disponíveis", canChestFarm)
    check("Brawl disponível", canBrawl)
    check("Cristais disponíveis", canHatch)
    check("Gerenciador de pets", canPetManager)
    check("Pet Shop disponível", canPetShop)
    check("Teleportes disponíveis", function()
        local folder = workspace:FindFirstChild("areaTeleportParts")
        return folder ~= nil and #folder:GetDescendants() > 0
    end)
    check("Lock Position disponível", hasCharacter)
    check("Modo desempenho disponível", function() return Lighting ~= nil end)
    check("Esteira recomendada encontrada", function() return bestTreadmill() ~= nil end)
    check("Máquina recomendada encontrada", function() return selectBestMachine() ~= nil end)
    check("Apex no catálogo", function() return findShopPetByNamePart("apex") ~= nil end)

    local lines = {
        "710Hub "..SESSION.Version,
        "Autoteste seguro - não compra pets, não abre cristal e não faz rebirth",
        "Resultado: "..passed.." OK / "..failed.." indisponíveis",
        "",
    }

    for _, line in ipairs(results) do
        lines[#lines+1] = line
    end

    lines[#lines+1] = ""
    lines[#lines+1] = "Executor gethui: "..(type(gethui) == "function" and "OK" or "N/A")
    lines[#lines+1] = "Executor firetouchinterest: "..(type(firetouchinterest) == "function" and "OK" or "N/A")
    lines[#lines+1] = "Executor setclipboard: "..(type(setclipboard) == "function" and "OK" or "N/A")
    lines[#lines+1] = "Máquinas detectadas: "..#scanMachines()

    local remoteCount = 0
    for _, remote in pairs(R) do
        if remote then remoteCount += 1 end
    end
    lines[#lines+1] = "Remotes encontrados: "..remoteCount.."/8"

    HubRuntime.SelfTestPassed = passed
    HubRuntime.SelfTestFailed = failed
    HubRuntime.SelfTestReport = table.concat(lines, "\n")
    setHubStatus("Autoteste: "..passed.." OK / "..failed.." indisponíveis")

    print("========== 710Hub AUTOTESTE ==========")
    print(HubRuntime.SelfTestReport)
    print("======================================")

    return passed, failed, HubRuntime.SelfTestReport
end

local function applySmartObjective()
    if not S.SmartFarm then return end

    S.Train = false
    S.Rebirth = false
    S.AutoPunch = false
    S.SmartRock = false
    S.AutoMachine = false
    S.AutoBestMachine = false
    S.StrengthRebirth = false
    S.TurboStrength = false
    S.MaxStrengthF2P = false
    S.AutoAgility = false

    local ok = true

    if S.SmartObjective == "Força" then
        if canMachineFarm() or canTrain() then
            S.MaxStrengthF2P = true
        else
            ok = false
        end
    elseif S.SmartObjective == "Durabilidade" then
        if canRockFarm() and canPunch() then
            S.AutoPunch = true
            S.SmartRock = true
        else
            ok = false
        end
    elseif S.SmartObjective == "Agilidade" then
        if canAgilityFarm() then
            S.AutoAgility = true
        else
            ok = false
        end
    elseif S.SmartObjective == "Rebirths" then
        if canRebirth() then
            if canMachineFarm() then
                S.AutoBestMachine = true
                selectBestMachine()
                S.AutoMachine = true
            elseif canTrain() then
                S.Train = true
            else
                ok = false
            end
            if ok then
                S.StrengthRebirth = true
            end
        else
            ok = false
        end
    end

    if not ok then
        S.SmartFarm = false
        setHubStatus("Farm inteligente indisponível para este objetivo")
    end
end

task.spawn(function()
    while SESSION.Alive and task.wait(.8) do
        if M:canAct() and S.SmartFarm and not HubRuntime.BossActive then
            applySmartObjective()
        end
    end
end)

local function goalCurrentValue()
    if S.GoalStat == "Rebirths" then return currentRebirths() end
    return numberStat(S.GoalStat)
end

task.spawn(function()
    while SESSION.Alive and task.wait(.5) do
        if M:canAct() and not M.Comparing and S.GoalEnabled and S.GoalValue and goalCurrentValue() >= S.GoalValue then
            stopAllAutomations()
            S.GoalEnabled = false
            setHubStatus("Meta atingida: "..S.GoalStat)
        end
    end
end)

local performanceSaved = {}
local performanceDescendantConnection = nil

local function savePerformanceValue(obj, key, value)
    local bucket = performanceSaved[obj]
    if not bucket then
        bucket = {}
        performanceSaved[obj] = bucket
    end
    if bucket[key] == nil then
        bucket[key] = value
    end
end

local function optimizeVisualObject(obj)
    if not S.PerformanceMode or not obj then return end

    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        savePerformanceValue(obj, "Enabled", obj.Enabled)
        obj.Enabled = false
    elseif obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect")
        or obj:IsA("DepthOfFieldEffect") or obj:IsA("BlurEffect") then
        savePerformanceValue(obj, "Enabled", obj.Enabled)
        obj.Enabled = false
    end
end

local function setPerformanceMode(enabled)
    if S.PerformanceMode == enabled then return end
    S.PerformanceMode = enabled

    if enabled then
        performanceSaved.__GlobalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false

        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            performanceSaved.__Terrain = {
                WaterWaveSize = terrain.WaterWaveSize,
                WaterWaveSpeed = terrain.WaterWaveSpeed,
                WaterReflectance = terrain.WaterReflectance,
            }
            pcall(function()
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
            end)
        end

        pcall(function()
            local rendering = settings().Rendering
            performanceSaved.__QualityLevel = rendering.QualityLevel
            rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        local descendants = game:GetDescendants()
        for i, obj in ipairs(descendants) do
            pcall(optimizeVisualObject, obj)
            if i % 250 == 0 then
                task.wait()
            end
        end

        if not performanceDescendantConnection then
            performanceDescendantConnection = trackConnection(game.DescendantAdded:Connect(function(obj)
                if S.PerformanceMode then
                    task.defer(function()
                        pcall(optimizeVisualObject, obj)
                    end)
                end
            end))
        end

        setHubStatus("Otimização gráfica ativada")
    else
        if performanceSaved.__GlobalShadows ~= nil then
            Lighting.GlobalShadows = performanceSaved.__GlobalShadows
        end

        local terrain = workspace:FindFirstChildOfClass("Terrain")
        local terrainSaved = performanceSaved.__Terrain
        if terrain and terrainSaved then
            pcall(function()
                terrain.WaterWaveSize = terrainSaved.WaterWaveSize
                terrain.WaterWaveSpeed = terrainSaved.WaterWaveSpeed
                terrain.WaterReflectance = terrainSaved.WaterReflectance
            end)
        end

        if performanceSaved.__QualityLevel ~= nil then
            pcall(function()
                settings().Rendering.QualityLevel = performanceSaved.__QualityLevel
            end)
        end

        for obj, values in pairs(performanceSaved) do
            if typeof(obj) == "Instance" and obj.Parent and type(values) == "table" then
                for key, value in pairs(values) do
                    pcall(function()
                        obj[key] = value
                    end)
                end
            end
        end

        performanceSaved = {}
        setHubStatus("Otimização gráfica desativada")
    end
end

local function reduceHeavyLoad(reason)
    local changed = false
    for _, key in ipairs({
        "TurboStrength",
        "MaxStrengthF2P",
        "AutoAgility",
        "AutoBoss",
        "AutoMachine",
        "SmartRock",
        "StrengthRebirth",
    }) do
        if S[key] then
            S[key] = false
            changed = true
        end
    end

    HubRuntime.BossActive = false
    HubRuntime.BossTarget = "Aguardando spawn"
    if changed then
        HubRuntime.StabilityTrips += 1
        setHubStatus("Proteção de estabilidade ativada • "..tostring(reason or "carga alta"))
        if HubRuntime.RenderToggles then
            task.defer(HubRuntime.RenderToggles)
        end
    end
end

local function setStabilityMode(enabled)
    if S.StabilityMode == enabled then return end

    if enabled then
        HubRuntime.StabilityPrevious = {
            RepDelay = S.RepDelay,
            HatchDelay = S.HatchDelay,
            PerformanceMode = S.PerformanceMode,
            FPSCap = nil,
        }

        if type(getfpscap) == "function" then
            pcall(function()
                HubRuntime.StabilityPrevious.FPSCap = getfpscap()
            end)
        end

        S.StabilityMode = true
        S.RepDelay = math.max(S.RepDelay, .12)
        S.HatchDelay = math.max(S.HatchDelay, .65)

        if not S.PerformanceMode then
            setPerformanceMode(true)
        end

        if type(setfpscap) == "function" then
            pcall(function()
                setfpscap(60)
            end)
        end

        setHubStatus("Modo Estável ativado • carga limitada")
    else
        local previous = HubRuntime.StabilityPrevious
        S.StabilityMode = false

        if previous then
            S.RepDelay = previous.RepDelay or S.RepDelay
            S.HatchDelay = previous.HatchDelay or S.HatchDelay

            if previous.PerformanceMode == false and S.PerformanceMode then
                setPerformanceMode(false)
            end

            if previous.FPSCap and type(setfpscap) == "function" then
                pcall(function()
                    setfpscap(previous.FPSCap)
                end)
            end
        end

        HubRuntime.StabilityPrevious = nil
        HubRuntime.LowFPSWindows = 0
        setHubStatus("Modo Estável desativado")
    end
end

-- Mede FPS localmente e reduz apenas funções pesadas se o cliente entrar
-- numa queda sustentada de desempenho enquanto o Modo Estável estiver ligado.
local fpsFrames = 0
local fpsWindowStarted = os.clock()
trackConnection(RunService.Heartbeat:Connect(function()
    fpsFrames += 1
end))

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        local now = os.clock()
        local elapsed = math.max(.1, now - fpsWindowStarted)
        HubRuntime.AvgFPS = fpsFrames / elapsed
        fpsFrames = 0
        fpsWindowStarted = now

        if S.StabilityMode then
            if HubRuntime.AvgFPS < 15 then
                HubRuntime.LowFPSWindows += 1
            else
                HubRuntime.LowFPSWindows = math.max(0, HubRuntime.LowFPSWindows - 1)
            end

            if HubRuntime.LowFPSWindows >= 3 then
                if not S.PerformanceMode then
                    setPerformanceMode(true)
                end
                reduceHeavyLoad("FPS baixo ("..math.floor(HubRuntime.AvgFPS)..")")
                HubRuntime.LowFPSWindows = 0
            end
        else
            HubRuntime.LowFPSWindows = 0
        end
    end
end)

SESSION.Cleanup = function()
    if M.releaseBossHover then M:releaseBossHover() end
    if HubRuntime.SourceBridge then HubRuntime.SourceBridge:cleanup() end
    if HubRuntime.Extras then HubRuntime.Extras:stop() end
    M:cancelComparison()
    M:pause("Encerrado", true)
    if S.StabilityMode then
        pcall(function()
            setStabilityMode(false)
        end)
    end

    SESSION.Alive = false

    for _, connection in ipairs(SESSION.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(SESSION.Connections)

    if S.PerformanceMode and setPerformanceMode then
        pcall(function()
            setPerformanceMode(false)
        end)
    end
end

local function initializeMaintenance()
-- BEGIN MAINTENANCE RUNTIME
-- Inserted into initializeMaintenance by build.ps1.
M:log("Sessao", "710Hub " .. SESSION.Version)
M.ProfileData = {Schema = 1, Slots = {}, LastSlot = 1}
M.ProfilePath = "710hub_profiles_v1.json"
M.BenchmarkResults = {}
M.BossSeen = setmetatable({}, {__mode = "k"})

function M:observeBosses()
    local bosses = self:scanBosses()
    local current = {}
    for _, boss in ipairs(bosses) do
        local root = bossRoot(boss)
        local rarity = self:bossInfo(boss)
        current[#current + 1] = rarity .. " - " .. boss.Name
        if not self.BossSeen[root] then
            self.BossSeen[root] = true
            self:recordBoss(rarity, boss.Name)
            if rarity == "Lendario" or rarity == "Mitico" or rarity == "Arco-iris" then
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "710Hub - Boss encontrado", Text = rarity .. ": " .. boss.Name, Duration = 8})
                end)
            end
        end
    end
    self.VisibleBossText = #current > 0 and table.concat(current, "\n") or "Nenhum boss reconhecido. Use Diagnosticar boss proximo."
end

function M:saveProfile()
    if self.Comparing then return false, "Finalize a comparacao antes de salvar" end
    self.ProfileData.Slots[tostring(self.ProfileSlot)] = self:profile()
    self.ProfileData.LastSlot = self.ProfileSlot
    self.ProfileData.Baseline = self.Capabilities
    ENV.__710HubProfiles = self.ProfileData
    if type(writefile) ~= "function" then
        return true, "Perfil salvo apenas nesta sessao: gravacao em disco indisponivel"
    end
    local ok, err = pcall(function()
        writefile(self.ProfilePath, game:GetService("HttpService"):JSONEncode(self.ProfileData))
    end)
    self:log("Perfil", "Salvo no slot " .. self.ProfileSlot)
    return ok, ok and "Perfil salvo em disco" or ("Salvo na sessao; falha no disco: " .. tostring(err))
end

function M:loadProfile()
    local profile = self.ProfileData.Slots[tostring(self.ProfileSlot)]
    if not profile then return false, "Este slot ainda esta vazio" end
    local oldPerformance, oldStability = S.PerformanceMode, S.StabilityMode
    local ok, err = self:applyProfile(profile)
    if ok then
        local desiredPerformance, desiredStability = S.PerformanceMode, S.StabilityMode
        local desiredRepDelay, desiredHatchDelay = S.RepDelay, S.HatchDelay
        S.PerformanceMode, S.StabilityMode = oldPerformance, oldStability
        setStabilityMode(false)
        S.RepDelay, S.HatchDelay = desiredRepDelay, desiredHatchDelay
        setPerformanceMode(desiredPerformance == true)
        setStabilityMode(desiredStability == true)
        finishBossFight(true)
        lockedCFrame = nil
        return true, "Perfil restaurado em pausa. Clique em Retomar."
    end
    return false, err
end

do
    local data = ENV.__710HubProfiles
    if type(readfile) == "function" then
        local ok, saved = pcall(function()
            local raw = readfile(M.ProfilePath)
            assert(#raw <= 100000, "Arquivo de perfis grande demais")
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if ok then data = saved end
    end
    if type(data) == "table" and data.Schema == 1 and type(data.Slots) == "table" then
        M.ProfileData = data
        M.ProfileSlot = table.find({1, 2, 3}, data.LastSlot) and data.LastSlot or 1
        if type(data.Baseline) == "table" then
            for name, available in pairs(data.Baseline) do
                if type(name) == "string" and type(available) == "boolean" then M.Capabilities[name] = available end
            end
        end
        if data.Slots[tostring(M.ProfileSlot)] then
            local ok, message = M:loadProfile()
            setHubStatus(message)
            if not ok then M:log("Perfil", message) end
        end
    end
end

function M:checkCompatibility()
    local checks = {Treino = canTrain, Rebirth = canRebirth, Boss = canAutoBoss,
        Maquinas = canMachineFarm, Pedras = canRockFarm, Agilidade = canAgilityFarm,
        Baus = canChestFarm, Cristais = canHatch, Pets = canPetManager}
    local current, lines = {}, {"Compatibilidade observada nesta sessao:"}
    for name, check in pairs(checks) do
        local ok, available = pcall(check)
        current[name] = ok and available == true
        lines[#lines + 1] = name .. ": " .. (current[name] and "disponivel" or "indisponivel")
    end
    self:updateCapabilities(current)
    table.sort(lines)
    self.CompatibilityReport = table.concat(lines, "\n")
    return self.CompatibilityReport
end

function M:bossNames()
    local names, seen = {"Qualquer"}, {}
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Model") and modelHasBossMarker(object) and not seen[object.Name] then
            seen[object.Name] = true
            names[#names + 1] = object.Name
        end
    end
    table.sort(names, function(a, b)
        if a == b then return false end
        if a == "Qualquer" then return true end
        if b == "Qualquer" then return false end
        return a < b
    end)
    return names
end

function M:bossDiagnostic()
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local rows = {}
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Model") then
            local root, health = bossRoot(object), bossHumanoid(object)
            if root and health then
                local distance = myRoot and (myRoot.Position - root.Position).Magnitude or 0
                if distance <= 150 then
                    local isPlayer = false
                    for _, player in ipairs(Players:GetPlayers()) do
                        local character = player.Character
                        if character and (object == character or object:IsDescendantOf(character) or character:IsDescendantOf(object)) then isPlayer = true; break end
                    end
                    if not isPlayer then
                        rows[#rows + 1] = {Distance = distance, Text = string.format("%s\nNome: %s | distancia: %.0f | vida: %.0f\nDetectado: %s | tags: %s",
                            object:GetFullName(), object.Name, distance, health.Health,
                            modelHasBossMarker(object) and "sim" or "nao", table.concat(object:GetTags(), ", "))}
                    end
                end
            end
        end
    end
    table.sort(rows, function(a, b) return a.Distance < b.Distance end)
    local lines = {"710Hub " .. SESSION.Version .. " | NPCs com vida legivel ate 150 studs", "Preferencia por nome nao transforma pets ou NPCs comuns em bosses. Envie este diagnostico se o alvo nao for reconhecido."}
    for i = 1, math.min(20, #rows) do lines[#lines + 1] = rows[i].Text end
    if #rows == 0 then lines[#lines + 1] = "Nenhum NPC com vida e raiz legiveis. A estrutura deste boss ainda precisa ser identificada." end
    return table.concat(lines, "\n\n")
end

function M:beginComparison()
    if self.Comparing then return false, "Comparacao ja em andamento" end
    if not self:canAct() then return false, "Retome a sessao antes de comparar" end
    local methods = {}
    if canTrain() then
        methods[#methods + 1] = {Name = "Ferramenta", Key = "Train"}
        methods[#methods + 1] = {Name = "Rajada", Key = "TurboStrength"}
    end
    if canMachineFarm() then methods[#methods + 1] = {Name = "Maquina", Key = "AutoMachine"} end
    if #methods < 2 then return false, "Sao necessarios dois metodos disponiveis" end
    local snapshot = self:automationSnapshot()
    self:clearAutomation()
    finishBossFight(true)
    self.BenchmarkToken += 1
    local token = self.BenchmarkToken
    self.Comparing = true
    self.BestTraining = nil
    self.BenchmarkResults = {}
    task.spawn(function()
        local ok, err = pcall(function()
            for _, method in ipairs(methods) do
                if not SESSION.Alive or self.BenchmarkToken ~= token or not self:canAct() then break end
                self:clearAutomation()
                S[method.Key] = true
                if method.Key == "AutoMachine" then selectBestMachine() end
                self.ComparisonStatus = "Medindo " .. method.Name .. " por 20 segundos"
                local startTime, startStrength, startRebirths = os.clock(), numberStat("Strength"), currentRebirths()
                local valid = true
                while os.clock() - startTime < 20 do
                    task.wait(.25)
                    if not SESSION.Alive or self.BenchmarkToken ~= token or not self:canAct() then return end
                    if currentRebirths() ~= startRebirths or numberStat("Strength") < startStrength or not S[method.Key] then
                        valid = false
                        break
                    end
                end
                local elapsed = math.max(.1, os.clock() - startTime)
                self.BenchmarkResults[#self.BenchmarkResults + 1] = {Name = method.Name, Valid = valid,
                    Rate = math.max(0, numberStat("Strength") - startStrength) * 60 / elapsed}
            end
        end)
        if self.BenchmarkToken == token then
            self:restoreAutomation(snapshot)
            self.Comparing = false
            if not ok then
                self.ComparisonStatus = "Comparacao interrompida: " .. tostring(err)
            elseif not self:canAct() then
                self.ComparisonStatus = "Comparacao interrompida por pausa; repita quando o personagem estiver pronto"
            else
                local best, validCount = nil, 0
                for _, result in ipairs(self.BenchmarkResults) do
                    if result.Valid then validCount += 1 end
                    if result.Valid and result.Rate > 0 and (not best or result.Rate > best.Rate) then best = result end
                end
                self.BestTraining = validCount >= 2 and best and best.Name or nil
                self.ComparisonStatus = validCount >= 2 and best and ("Melhor observado: " .. best.Name .. " (" .. math.floor(best.Rate) .. "/min)")
                    or "Menos de duas amostras validas ou nenhum ganho; comparacao inconclusiva"
            end
            self:log("Comparacao", self.ComparisonStatus)
            if HubRuntime.RenderToggles then HubRuntime.RenderToggles() end
        end
    end)
    return true, "Comparacao iniciada; as rotinas anteriores serao restauradas"
end

do
    local generation, deathConnection = 0, nil
    local function bindCharacter(character)
        generation += 1
        local ownGeneration = generation
        if deathConnection then
            deathConnection:Disconnect()
            local index = table.find(SESSION.Connections, deathConnection)
            if index then table.remove(SESSION.Connections, index) end
            deathConnection = nil
        end
        M:pause("Respawn", true)
        M:pause("Vida baixa", false)
        HubRuntime.BossActive, HubRuntime.BossModel, HubRuntime.BossReturnCFrame = false, nil, nil
        M:resetBossDefense()
        lockedCFrame = nil
        agilityOriginalWalkSpeed, agilityLastTeleport = nil, 0
        task.spawn(function()
            local humanoid = character:WaitForChild("Humanoid", 15)
            local root = character:WaitForChild("HumanoidRootPart", 15)
            if not SESSION.Alive or ownGeneration ~= generation or LP.Character ~= character then return end
            if not humanoid or not root then
                M:log("Respawn", "Personagem incompleto; aguardando componentes")
            end
            -- Continue esperando com cancelamento, sem retomar num personagem incompleto.
            while SESSION.Alive and ownGeneration == generation and LP.Character == character and (not humanoid or not root) do
                task.wait(1)
                humanoid = character:FindFirstChildOfClass("Humanoid")
                root = character:FindFirstChild("HumanoidRootPart")
            end
            if not SESSION.Alive or ownGeneration ~= generation or LP.Character ~= character then return end
            local function died()
                M.Totals.Deaths += 1
                M:log("Morte", "Aguardando novo personagem")
                M:pause("Respawn", true)
                if not S.ResumeAfterDeath then M:pause("Manual", true) end
            end
            deathConnection = trackConnection(humanoid.Died:Connect(died))
            if humanoid.Health <= 0 then died(); return end
            task.wait(.75)
            if SESSION.Alive and ownGeneration == generation and LP.Character == character and humanoid.Health > 0 then
                refreshRemotes()
                M:pause("Respawn", false)
                M:log("Respawn", "Personagem pronto; configuracao preservada")
            end
        end)
    end
    trackConnection(LP.CharacterRemoving:Connect(function()
        M:pause("Respawn", true)
        if not S.ResumeAfterDeath then M:pause("Manual", true) end
    end))
    trackConnection(LP.CharacterAdded:Connect(function(character)
        HubRuntime.Respawns += 1
        bindCharacter(character)
    end))
    if LP.Character then bindCharacter(LP.Character) end
end

task.spawn(function()
    local lastTick, lastScan, lastSample, lastBossScan = os.clock(), 0, 0, 0
    while SESSION.Alive do
        task.wait(.25)
        if not SESSION.Alive then break end
        local now = os.clock()
        if now - lastBossScan >= 5 then
            lastBossScan = now
            local ok, err = pcall(function() M:observeBosses() end)
            if not ok then M.VisibleBossText = "Diagnostico necessario: " .. tostring(err) end
        end
        local elapsed = now - lastTick
        lastTick = now
        local active = false
        for _, key in ipairs(M.AutoKeys) do
            if key ~= "GoalEnabled" and S[key] then active = true; break end
        end
        M:tickBreak(elapsed, active)
        if (not M:canAct() or M.Comparing) and S.StopAt then S.StopAt += elapsed end
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if now - lastSample >= 1 then
            lastSample = now
            local training = not HubRuntime.BossActive and (S.Train or M:trainingMovement() ~= nil or S.Rebirth or S.StrengthRebirth
                or S.MaxStrengthF2P or S.TurboStrength or S.AutoMachine)
            if M:sample(numberStat("Strength"), currentRebirths(), training == true) then
                setHubError("Farm sem progresso; consulte o diagnostico")
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "710Hub", Text = "Farm sem progresso. Confira o diagnostico.", Duration = 8})
                end)
            end
        end
        if now - lastScan >= 15 and not M.Reasons.Respawn then
            lastScan = now
            local ok, err = pcall(function() M:checkCompatibility() end)
            if not ok then setHubError("Diagnostico: " .. tostring(err)) end
        end
    end
end)

-- Separate opt-in PvP loop. No boss targeting, remote damage spoofing or hidden mode.
function M:stopPvp()
    if self.PvpTarget then
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if root and hum then hum:MoveTo(root.Position) end
    end
    self.PvpTarget = nil
end
function M:playerKarma(player, names)
    local wanted = {}
    for _, name in ipairs(names) do wanted[string.lower(name)] = true end
    local containers = {player}
    local folders = {leaderstats=true, stats=true, data=true, playerstats=true}
    for _, child in ipairs(player:GetChildren()) do
        if folders[string.lower(child.Name)] then containers[#containers + 1] = child end
    end
    for _, container in ipairs(containers) do
        for _, child in ipairs(container:GetChildren()) do
            if wanted[string.lower(child.Name)] and (child:IsA("IntValue") or child:IsA("NumberValue")) then return child.Value end
        end
        for name, value in pairs(container:GetAttributes()) do
            if wanted[string.lower(name)] and type(value) == "number" then return value end
        end
    end
end
function M:pvpTick()
            if not (S.PvpAny or S.PvpGood or S.PvpEvil) then M:stopPvp(); M.PvpDiagnostic = ""; M.PvpStatus = M.PvpStopReason or "Desligado"; return end
            M.PvpStopReason = nil
            if not M:canAct() or HubRuntime.BossActive then M:stopPvp(); M.PvpStatus = "Pausado: " .. (HubRuntime.BossActive and "combate com boss" or M:reasonText()); return end
            local character = LP.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            if not root or not hum or hum.Health <= 0 then M:stopPvp(); M.PvpStatus = "Aguardando personagem"; return end
            if S.HealthGuard and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth <= ((S.HealthLow or 55) / 100) then
                S.PvpAny, S.PvpGood, S.PvpEvil = false, false, false; M:stopPvp()
                M.PvpStopReason = "Parado por vida baixa; recupere antes de ligar novamente"; M.PvpStatus = M.PvpStopReason; return
            end
            local target, targetRoot, targetHum, distance = nil, nil, nil, S.PvpRadius
            local counts = {missing=0, protected=0, unknown=0, karma=0, far=0, blocked=0}
            local details = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP then
                    local model = player.Character
                    local otherRoot = model and model:FindFirstChild("HumanoidRootPart")
                    local otherHum = model and model:FindFirstChildOfClass("Humanoid")
                    local good = M:playerKarma(player, {"goodKarma", "LightKarma"})
                    local evil = M:playerKarma(player, {"evilKarma", "DarkKarma"})
                    local reason
                    if HubRuntime.Extras and not HubRuntime.Extras:pvpAllowed(player) then reason = "protected"
                    elseif not otherRoot or not otherHum or otherHum.Health <= 0 then reason = "missing"
                    elseif model:FindFirstChildOfClass("ForceField") then reason = "protected"
                    elseif not S.PvpAny and (good == nil or evil == nil) then reason = "unknown"
                    elseif not M:pvpEligible(good, evil) then reason = "karma"
                    else
                        local d = (root.Position - otherRoot.Position).Magnitude
                        if d > S.PvpRadius then reason = "far"
                        else
                            local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = {character, model}; params.RespectCanCollide = true
                            if workspace:Raycast(root.Position, otherRoot.Position - root.Position, params) then reason = "blocked"
                            elseif d <= distance then target, targetRoot, targetHum, distance = player, otherRoot, otherHum, d end
                        end
                    end
                    if reason then counts[reason] += 1 end
                    details[#details + 1] = player.Name .. ": bom=" .. tostring(good) .. ", ruim=" .. tostring(evil) .. ", " .. (reason or "elegivel")
                end
            end
            local summary = string.format("Karma ilegivel: %d | outro karma/neutro: %d | longe: %d | obstaculo: %d | protegidos: %d | sem personagem vivo: %d", counts.unknown, counts.karma, counts.far, counts.blocked, counts.protected, counts.missing)
            M.PvpDiagnostic = summary .. "\n\n" .. table.concat(details, "\n")
            if not target then M:stopPvp(); M.PvpStatus = "Sem alvo. " .. summary; return end
            if not findPunchTool() then M:stopPvp(); M.PvpStatus = "Ferramenta Punch indisponivel"; return end
            if M.PvpTarget ~= target or M.PvpTargetModel ~= target.Character then
                M.PvpDamageObserved = 0
                M.PvpTargetModel = target.Character
                M.PvpObservedHealth, M.PvpLastDamageAt = targetHum.Health, os.clock()
            elseif targetHum.Health < (M.PvpObservedHealth or targetHum.Health) then
                M.PvpDamageObserved = (M.PvpDamageObserved or 0) + M.PvpObservedHealth - targetHum.Health
                M.PvpLastDamageAt = os.clock()
            end
            M.PvpObservedHealth = targetHum.Health
            M.PvpTarget = target
            local attackRange = S.PvpAttackRange or 2.5
            if distance > attackRange then
                hum:MoveTo(targetRoot.Position)
                M.PvpStatus = string.format("Aproximando: %s (%.1f studs)", target.Name, distance)
            else
                hum:MoveTo(root.Position)
                local face = Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z)
                if (face - root.Position).Magnitude > .01 then root.CFrame = CFrame.lookAt(root.Position, face) end
                local function allowed()
                    return (S.PvpAny or S.PvpGood or S.PvpEvil) and M.PvpTarget == target and not HubRuntime.BossActive
                        and (not HubRuntime.Extras or HubRuntime.Extras:pvpAllowed(target))
                        and target.Character == targetRoot.Parent and targetHum.Health > 0
                        and not targetRoot.Parent:FindFirstChildOfClass("ForceField")
                        and (root.Position - targetRoot.Position).Magnitude <= attackRange
                end
                local punched, reason = doAnimatedPunch(allowed)
                if not punched then M.PvpStatus = reason
                elseif os.clock() - M.PvpLastDamageAt >= 8 then
                    M.PvpStatus = "Punch ativado, mas sem queda de vida observada: " .. target.Name .. ". Confira alcance ou protecao do jogo."
                else M.PvpStatus = "Punch ativado: " .. target.Name .. " | queda de vida observada: " .. math.ceil(M.PvpDamageObserved or 0) .. " | vida: " .. math.ceil(targetHum.Health) end
            end
end
task.spawn(function()
    while SESSION.Alive and task.wait(.35) do
        local ok, failure = pcall(function() M:pvpTick() end)
        if not ok then S.PvpAny, S.PvpGood, S.PvpEvil = false, false, false; M:stopPvp(); M.PvpStopReason = "Erro: " .. tostring(failure); M.PvpStatus = M.PvpStopReason; M:log("PvP", M.PvpStatus) end
    end
    M:stopPvp()
end)
-- END MAINTENANCE RUNTIME
end
initializeMaintenance()

-- BEGIN EXTRA RUNTIME
-- Integrated options; never loads a third-party script at runtime.
local function initializeEnhancements()
    local X = {Token = 0, Saved = setmetatable({}, {__mode = "k"}), Highlights = {},
        Whitelist = {}, FriendCache = {}, FriendChecked = {}, Next = {}, Status = "Pronto", SelectedUserId = 0,
        ShopName = "", PetObjective = "strength", ReturnPoint = nil}
    HubRuntime.Extras = X
    local UIS = game:GetService("UserInputService")

    function X:remember(object, key, value)
        if not object then return end
        local saved = self.Saved[object]
        if not saved then saved = {}; self.Saved[object] = saved end
        if saved[key] == nil then saved[key] = {Value = object[key]} end
        object[key] = value
    end
    function X:restore(object, key)
        local saved = self.Saved[object]
        if saved and saved[key] then
            pcall(function() object[key] = saved[key].Value end)
            saved[key] = nil
        end
    end
    function X:selectedPlayer()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == self.SelectedUserId then return player end
        end
    end
    function X:playerOptions()
        local out = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then out[#out+1] = {Label = (player.DisplayName or player.Name) .. " (@" .. player.Name .. ")", Value = player.UserId} end
        end
        table.sort(out, function(a,b) return a.Label < b.Label end)
        return out
    end
    function X:pvpAllowed(player)
        if self.Whitelist[player.UserId] then return false end
        if S.PvpOnlySelected and player.UserId ~= self.SelectedUserId then return false end
        -- Friendship lookups are asynchronous and cached, never inside the attack loop.
        if S.PvpProtectFriends and self.FriendCache[player.UserId] ~= false then return false end
        return true
    end
    function X:refreshFriends()
        for _, player in ipairs(Players:GetPlayers()) do
            if not SESSION.Alive or not S.PvpProtectFriends then return end
            if player ~= LP and (self.FriendCache[player.UserId] == nil or os.clock()-(self.FriendChecked[player.UserId] or 0) >= 30) then
                local ok, friend = pcall(function() return LP:IsFriendsWith(player.UserId) end)
                if ok then self.FriendCache[player.UserId] = friend == true; self.FriendChecked[player.UserId] = os.clock() end
                task.wait(.1)
            end
        end
    end
    function X:fortuneCatalog()
        local shared = RS:FindFirstChild("shared")
        local catalogs = shared and shared:FindFirstChild("catalogs")
        local chances = catalogs and catalogs:FindFirstChild("fortuneWheelChances")
        return chances and chances:FindFirstChild("Fortune Wheel")
    end
    function X:spin()
        local remote, catalog = rEvents:FindFirstChild("openFortuneWheelRemote"), self:fortuneCatalog()
        if not remote or not remote:IsA("RemoteFunction") or not catalog then return false end
        local before = HubRuntime.RemoteCalls
        local result = safeInvoke(remote, "openFortuneWheel", catalog)
        if HubRuntime.RemoteCalls == before then self.Status = "Giro aguardando sessão e limite de chamadas"; return false end
        self.Status = result == false and "Roleta recusada; confira seus giros" or "Giro solicitado ao jogo"
        if result == false then S.AutoWheel = false end
        return result ~= false
    end
    local consumables = {
        ["Protein Egg"] = "proteinEgg", ["Tropical Shake"] = "tropicalShake",
        ["Energy Shake"] = "energyShake", ["Protein Bar"] = "proteinBar",
        ["TOUGH Bar"] = "toughBar", ["Protein Shake"] = "proteinShake",
        ["ULTRA Shake"] = "ultraShake", ["Energy Bar"] = "energyBar",
    }
    function X:consume()
        local remote = getMuscleEvent()
        if not remote or not remote:IsA("RemoteEvent") then return false end
        for _, container in ipairs({LP.Character, getBackpack()}) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    local command = consumables[item.Name]
                    local enabled = item.Name == "Protein Egg" and S.AutoEggs or item.Name ~= "Protein Egg" and S.AutoBoosts
                    if command and enabled and item:IsA("Tool") and (self.Next[item] or 0) <= os.clock() then
                        self.Next[item] = os.clock() + 3
                        self.Status = "Uso solicitado: " .. item.Name
                        return safeFire(remote, command, item)
                    end
                end
            end
        end
        return false
    end
    function X:shopOptions()
        local out, folder = {}, getPetShopFolder()
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                out[#out+1] = {Label = (item:GetAttribute("IsPowerUp") == true and "Aura: " or "Pet: ") .. item.Name, Value = item.Name}
            end
        end
        table.sort(out, function(a,b) return a.Label < b.Label end)
        return out
    end
    function X:buyBatch()
        if self.Buying then setHubStatus("Aguarde a compra atual terminar"); return end
        local folder, remote = getPetShopFolder(), rEvents:FindFirstChild("cPetShopRemote")
        local item = folder and folder:FindFirstChild(self.ShopName)
        if not item or not remote or not remote:IsA("RemoteFunction") then setHubStatus("Selecione um item disponível na loja"); return end
        self.Buying = true
        local token, count, sent = self.Token, S.ShopCount, 0
        local ok, err = pcall(function()
            for _ = 1, count do
                if not SESSION.Alive or token ~= self.Token or not M:canAct() or not item.Parent then break end
                local before = HubRuntime.RemoteCalls
                local response = safeInvoke(remote, item)
                if response == false or token ~= self.Token or not SESSION.Alive then break end
                if HubRuntime.RemoteCalls > before then sent += 1 end
                task.wait(.75)
            end
        end)
        self.Buying = false
        if not ok then setHubError(err) end
        self.Status = string.format("Lote encerrado: %d/%d solicitações; confira o inventário", sent, count)
        if SESSION.Alive then setHubStatus(self.Status) end
    end
    function X:petScore(entry, objective)
        local score, found = 0, false
        for _, container in ipairs({entry.pet, entry.pet:FindFirstChild("perksFolder")}) do
            if container then
                for _, child in ipairs(container:GetChildren()) do
                    if string.lower(child.Name) == objective and (child:IsA("NumberValue") or child:IsA("IntValue")) then
                        score += child.Value; found = true
                    end
                end
                local value = container:GetAttribute(objective)
                if type(value) == "number" then score += value; found = true end
            end
        end
        return found and score or nil
    end
    function X:equipObjective()
        if not SESSION.Alive or not M:canAct() or M.PetEquipBusy then return false end
        refreshRemotes()
        local candidates, equipped, slots = {}, equippedPets()
        if not R.EquipPet or slots <= 0 then return false end
        for _, entry in ipairs(allOwnedPets()) do
            local score = self:petScore(entry, self.PetObjective)
            if score then candidates[#candidates+1] = {Pet = entry.pet, Score = score} end
        end
        table.sort(candidates, function(a,b)
            if a.Score ~= b.Score then return a.Score > b.Score end
            if equipped[a.Pet] ~= equipped[b.Pet] then return equipped[a.Pet] == true end
            return tostring(a.Pet) < tostring(b.Pet)
        end)
        if #candidates == 0 then self.Status = "Atributo dos pets indisponível: " .. self.PetObjective; return false end
        -- Never remove pets when fewer readable candidates exist than occupied slots.
        local occupied = 0; for _ in pairs(equipped) do occupied += 1 end
        if #candidates < math.min(occupied, slots) then self.Status = "Atributos incompletos; confira seus pets"; return false end
        local desired = {}
        for index = 1, math.min(slots,#candidates) do desired[candidates[index].Pet] = true end
        M.PetEquipBusy = true
        local token = self.Token
        local function active() return SESSION.Alive and token == self.Token and M:canAct() end
        local ok, result = pcall(function()
            for pet in pairs(equipped) do
                if not desired[pet] then
                    if not active() or not safeFire(R.EquipPet,"unequipPet",pet) then return false end
                    task.wait(.15)
                end
            end
            for index = 1, math.min(slots,#candidates) do
                local pet = candidates[index].Pet
                if not equipped[pet] then
                    if not active() or not safeFire(R.EquipPet,"equipPet",pet) then return false end
                    task.wait(.15)
                end
            end
            return true
        end)
        M.PetEquipBusy = false
        if not ok then setHubError(result); return false end
        return result
    end
    function X:localEffects()
        local character, camera = LP.Character, workspace.CurrentCamera
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if camera then
            if S.SetFOV then self:remember(camera,"FieldOfView",S.CameraFOV) else self:restore(camera,"FieldOfView") end
            local target = S.Spectate and self:selectedPlayer()
            local targetHum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if targetHum and targetHum.Health > 0 then self:remember(camera,"CameraSubject",targetHum)
            else
                self:restore(camera,"CameraSubject")
                -- A saved humanoid may have been destroyed during a respawn.
                if hum and camera.CameraSubject and not camera.CameraSubject.Parent then camera.CameraSubject = hum end
            end
        end
        for object, saved in pairs(self.Saved) do
            if object ~= camera then
                if saved.FieldOfView then self:restore(object,"FieldOfView") end
                if saved.CameraSubject then self:restore(object,"CameraSubject") end
            end
        end
        if hum then
            if S.HideName then self:remember(hum,"DisplayDistanceType",Enum.HumanoidDisplayDistanceType.None)
            else self:restore(hum,"DisplayDistanceType") end
        end
        if character then
            for _, object in ipairs(character:GetDescendants()) do
                if object:IsA("BillboardGui") then
                    if S.HideStats then self:remember(object,"Enabled",false) else self:restore(object,"Enabled") end
                end
            end
        end
        if S.WorldTime == "Original" then self:restore(Lighting,"ClockTime")
        else self:remember(Lighting,"ClockTime",S.WorldTime == "Dia" and 12 or 0) end
        local present = {}
        if S.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    present[player.UserId] = true
                    local item = self.Highlights[player.UserId]
                    if not item or item.Adornee ~= player.Character then
                        if item then item:Destroy() end
                        item = Instance.new("Highlight")
                        item.Name = "710Hub_PlayerHighlight"; item.Adornee = player.Character
                        item.FillTransparency = .85; item.OutlineTransparency = .15
                        item.FillColor = Color3.fromRGB(230,189,110); item.OutlineColor = item.FillColor
                        item.DepthMode = Enum.HighlightDepthMode.Occluded; item.Parent = player.Character
                        self.Highlights[player.UserId] = item
                    end
                end
            end
        end
        for id,item in pairs(self.Highlights) do if not present[id] then item:Destroy(); self.Highlights[id] = nil end end
    end
    function X:stop()
        self.Token += 1
        for _, key in ipairs({"AutoWheel","AutoEggs","AutoBoosts","AutoBestPetObjective","AutoEvolveOwned", "SetSpeed","SetSize","SetFOV","InfiniteJump","AntiFling","HideName","HideStats","Spectate","PlayerESP"}) do S[key] = false end
        S.WorldTime = "Original"
        self.LastSafe = nil
        for object, saved in pairs(self.Saved) do
            local keys = {}; for key in pairs(saved) do keys[#keys+1] = key end
            for _,key in ipairs(keys) do self:restore(object,key) end
        end
        for id,item in pairs(self.Highlights) do item:Destroy(); self.Highlights[id] = nil end
        local camera = workspace.CurrentCamera
        if camera and camera.CameraSubject and not camera.CameraSubject.Parent then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then camera.CameraSubject = hum end
        end
    end
    function X:travel(frame)
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then setHubStatus("Aguarde seu personagem"); return end
        self.Token += 1
        local token = self.Token
        M:pause("Manual",true)
        if HubRuntime.StopBoss then HubRuntime.StopBoss() end
        M:stopPvp()
        setHubStatus("Carregando destino...")
        if workspace.StreamingEnabled then pcall(function() LP:RequestStreamAroundAsync(frame.Position,3) end) end
        if not SESSION.Alive or self.Token ~= token or LP.Character ~= character then return end
        local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}; params.RespectCanCollide = true
        local floor = workspace:Raycast(frame.Position+Vector3.new(0,20,0),Vector3.new(0,-160,0),params)
        if not floor then setHubStatus("Piso do destino indisponível; tente novamente após carregar"); return end
        root.CFrame = frame
        setHubStatus("Destino aplicado; use Retomar para continuar o farm")
    end
    function X:tick()
        self:localEffects()
        if not M:canAct() or M.Comparing then return end
        local now, character = os.clock(), LP.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not root then return end
        local remote = rEvents:FindFirstChild("changeSpeedSizeRemote")
        if remote and remote:IsA("RemoteFunction") and now >= (self.Next.Character or 0) then
            self.Next.Character = now + 2
            if S.SetSize then safeInvoke(remote,"changeSize",S.CharacterSize) end
            if S.SetSpeed and SESSION.Alive and M:canAct() then safeInvoke(remote,"changeSpeed",S.CharacterSpeed) end
        end
        if S.AntiFling then
            local velocity, angular = root.AssemblyLinearVelocity, root.AssemblyAngularVelocity
            if velocity and angular and (velocity.Magnitude > 160 or angular.Magnitude > 100) then
                root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
                if self.LastSafe and self.LastSafe.Root == root and now-self.LastSafe.Time < 2
                    and not HubRuntime.BossActive and not M.PvpTarget then root.CFrame = self.LastSafe.Frame end
            else self.LastSafe = {Root=root,Frame=root.CFrame,Time=now} end
        else self.LastSafe = nil end
        if S.AutoWheel and now >= (self.Next.Wheel or 0) then self.Next.Wheel = now+5; self:spin() end
        if not SESSION.Alive or not M:canAct() then return end
        if S.AutoEggs or S.AutoBoosts then self:consume() end
        if S.AutoBestPetObjective and now >= (self.Next.Pets or 0) and not HubRuntime.BossActive then
            self.Next.Pets = now+10; self:equipObjective()
        end
        if S.AutoEvolveOwned and now >= (self.Next.Evolve or 0) then self.Next.Evolve = now+5; evolveReadyOwned() end
    end
    if UIS.JumpRequest then
        trackConnection(UIS.JumpRequest:Connect(function()
            if not SESSION.Alive or not S.InfiniteJump or not M:canAct() then return end
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end))
    end
    task.spawn(function()
        while SESSION.Alive do
            local ok, err = pcall(function() X:tick() end)
            if not ok then setHubError("Opções extras: " .. tostring(err)) end
            task.wait(.5)
        end
    end)
    task.spawn(function()
        while SESSION.Alive do
            if S.PvpProtectFriends then X:refreshFriends() end
            task.wait(5)
        end
    end)
end
initializeEnhancements()
-- END EXTRA RUNTIME

local function initializeUI()
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- BEGIN MAINTENANCE MENU
-- Obsidian/gold interface. Legacy color keys keep existing widgets compatible.
local COLORS = {
    Black = Color3.fromRGB(15, 17, 22), Black2 = Color3.fromRGB(19, 22, 29),
    Panel = Color3.fromRGB(22, 26, 35), Panel2 = Color3.fromRGB(27, 31, 41),
    Panel3 = Color3.fromRGB(35, 40, 52), Green = Color3.fromRGB(230, 189, 110),
    GreenBright = Color3.fromRGB(255, 225, 169), GreenDark = Color3.fromRGB(48, 43, 33),
    Yellow = Color3.fromRGB(239, 195, 116), YellowSoft = Color3.fromRGB(219, 209, 187),
    White = Color3.fromRGB(238, 241, 248), Muted = Color3.fromRGB(149, 157, 177),
    Off = Color3.fromRGB(78, 87, 106), Red = Color3.fromRGB(244, 107, 122),
    NeonDim = Color3.fromRGB(58, 65, 81), Cyan = Color3.fromRGB(230, 189, 110),
    Success = Color3.fromRGB(113, 220, 175), Border = Color3.fromRGB(54, 61, 77),
}
local function addCorner(obj, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius or 10); item.Parent = obj; return item
end
local function addStroke(obj, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color; item.Thickness = thickness or 1
    item.Transparency = transparency or 0; item.Parent = obj; return item
end
local function addGradient(obj, first, second, rotation)
    local item = Instance.new("UIGradient")
    item.Color = ColorSequence.new(first, second); item.Rotation = rotation or 0
    item.Parent = obj; return item
end
-- Small line illustrations drawn with native UI, without external image assets.
local function drawIcon(parent, category, size, color)
    local canvas = Instance.new("Frame")
    canvas.Name = "CategoryIcon"; canvas.Size = UDim2.fromOffset(size, size)
    canvas.BackgroundTransparency = 1; canvas.Parent = parent
    local function line(x1, y1, x2, y2)
        local dx, dy = x2-x1, y2-y1
        local part = Instance.new("Frame")
        part.AnchorPoint = Vector2.new(.5, .5)
        part.Position = UDim2.fromScale((x1+x2)/48, (y1+y2)/48)
        part.Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)*size/24, 1.5)
        part.Rotation = math.deg(math.atan2(dy, dx))
        part.BackgroundColor3 = color; part.BorderSizePixel = 0; part.Parent = canvas
        addCorner(part, 2)
    end
    local paths = {
        Farm = {{3,8,3,16},{6,5,6,19},{6,12,18,12},{18,5,18,19},{21,8,21,16}},
        Bosses = {{3,7,6,18},{6,18,18,18},{18,18,21,7},{21,7,16,11},{16,11,12,4},{12,4,8,11},{8,11,3,7}},
        Pets = {{4,9,8,5},{8,5,12,9},{12,9,16,5},{16,5,20,9},{20,9,20,17},{20,17,12,21},{12,21,4,17},{4,17,4,9}},
        Metas = {{4,19,19,4},{11,4,19,4},{19,4,19,12},{4,12,4,20},{4,20,12,20}},
        Perfis = {{5,4,19,4},{19,4,19,20},{19,20,5,20},{5,20,5,4},{9,9,15,9},{9,14,15,14}},
        ["PvP"] = {{5,3,17,19},{3,5,19,17},{4,16,8,20},{16,4,20,8}},
        ["Sessão"] = {{4,19,4,13},{9,19,9,8},{14,19,14,11},{19,19,19,4}},
        Ajustes = {{4,6,20,6},{4,12,20,12},{4,18,20,18},{8,3,8,9},{16,9,16,15},{10,15,10,21}},
    }
    local segments = paths[category] or {{4,19,4,13},{9,19,9,8},{14,19,14,11},{19,19,19,4}}
    for _, points in ipairs(segments) do line(table.unpack(points)) end
    return canvas
end
local function tween(obj, duration, goal)
    TweenService:Create(obj, TweenInfo.new(duration or .16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end
local guiParent = assert(LP:WaitForChild("PlayerGui", 10), "PlayerGui indisponivel")
local oldGui = guiParent:FindFirstChild("710Hub_MuscleLegends")
if oldGui then oldGui:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "710Hub_MuscleLegends"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = guiParent
local baseCleanup = SESSION.Cleanup
SESSION.Cleanup = function()
    pcall(baseCleanup)
    if gui then gui:Destroy() end
end
local shadow = Instance.new("Frame")
shadow.Name = "PanelShadow"
shadow.BackgroundColor3 = Color3.new(0, 0, 0); shadow.BackgroundTransparency = .5
shadow.BorderSizePixel = 0; shadow.Parent = gui; addCorner(shadow, 22)
local main = Instance.new("Frame")
main.Name = "Main"; main.BackgroundColor3 = Color3.new(1,1,1); main.BorderSizePixel = 0
main.Active = true; main.Parent = gui; addCorner(main, 18)
addStroke(main, COLORS.Border, 1, .18)
addGradient(main, Color3.fromRGB(22, 25, 33), COLORS.Black, 90)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -40, 0, 58); header.Position = UDim2.fromOffset(20, 16)
header.BackgroundTransparency = 1; header.Active = true; header.Parent = main
local minimize = Instance.new("TextButton")
minimize.Name = "Minimizar"; minimize.Size = UDim2.fromOffset(42, 40)
minimize.Position = UDim2.new(1, 0, 0, 7); minimize.AnchorPoint = Vector2.new(1, 0)
minimize.Text = "−"; minimize.TextSize = 26; minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = COLORS.Muted; minimize.BackgroundColor3 = COLORS.Panel2
minimize.BorderSizePixel = 0; minimize.Parent = header; addCorner(minimize, 10)
-- Shared image source for the header and reopen button.
local brandViews, brandAsset, brandLoading = {}, nil, false
local function attachBrandLogo(holder)
    local artwork = Instance.new("ImageLabel")
    artwork.Name = "710HubLogo"
    artwork.Size = UDim2.new(1, -4, 1, -4)
    artwork.Position = UDim2.fromOffset(2, 2)
    artwork.BackgroundTransparency = 1
    artwork.ScaleType = Enum.ScaleType.Fit
    -- Display the image while fetching: fully transparent images may not load.
    artwork.ImageTransparency = 0
    artwork.ImageRectOffset = Vector2.new(40, 170)
    artwork.ImageRectSize = Vector2.new(1170, 875)
    artwork.Parent = holder
    brandViews[#brandViews + 1] = {Holder = holder, Image = artwork}
    local function loaded()
        if artwork.IsLoaded and holder.Parent then
            holder.TextTransparency = 1
            holder.BackgroundColor3 = COLORS.Black2
            M.LogoStatus = "Logo neon carregada"
        end
    end
    artwork:GetPropertyChangedSignal("IsLoaded"):Connect(loaded)
    if brandAsset then artwork.Image = brandAsset; loaded(); return end
    if brandLoading then return end
    brandLoading = true
    M.LogoStatus = "Carregando logo neon..."
    task.defer(function()
        local asset = type(getcustomasset) == "function" and getcustomasset
            or (type(getsynasset) == "function" and getsynasset)
            or (type(ENV.getcustomasset) == "function" and ENV.getcustomasset)
        if not asset or type(writefile) ~= "function" then
            M.LogoStatus = "Imagem indisponivel: ambiente sem getcustomasset/writefile"
            M:log("Logo", M.LogoStatus)
            return
        end
        local path = "710hub_logo_neon_v2.png"
        local signature = string.char(137, 80, 78, 71, 13, 10, 26, 10)
        local function valid(bytes)
            return type(bytes) == "string" and #bytes == 899743 and bytes:sub(1, 8) == signature
        end
        local ok, err = pcall(function()
            local cached = false
            if type(readfile) == "function" then
                local readOK, bytes = pcall(readfile, path)
                cached = readOK and valid(bytes)
            end
            if not cached then
                local bytes
                for _, url in ipairs({
                    "https://710hub-keys.710hub-key-server.workers.dev/icon.png",
                    "https://raw.githubusercontent.com/Kamoviich/710hub/main/assets/710hub-neon-yellow.png",
                }) do
                    local fetched, data = pcall(function() return game:HttpGet(url, true) end)
                    if fetched and valid(data) then bytes = data; break end
                    if not SESSION.Alive then return end
                end
                assert(bytes, "Nao foi possivel baixar o PNG")
                if not SESSION.Alive then return end
                writefile(path, bytes)
            end
            if not SESSION.Alive then return end
            brandAsset = asset(path)
            assert(type(brandAsset) == "string" and #brandAsset > 0, "Endereco de imagem local invalido")
            for _, view in ipairs(brandViews) do
                if view.Image.Parent then view.Image.Image = brandAsset end
            end
            task.delay(15, function()
                if not SESSION.Alive then return end
                local anyLoaded = false
                for _, view in ipairs(brandViews) do
                    if view.Image.Parent and view.Image.IsLoaded then
                        view.Holder.TextTransparency = 1
                        anyLoaded = true
                    end
                end
                M.LogoStatus = anyLoaded and "Logo neon carregada" or "PNG baixado; o ambiente nao renderizou a imagem local"
                M:log("Logo", M.LogoStatus)
            end)
        end)
        if not ok then
            M.LogoStatus = "Falha na logo: " .. tostring(err)
            M:log("Logo", M.LogoStatus)
        end
    end)
end
do
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(56, 56); logo.Position = UDim2.fromOffset(0, 0)
    logo.Text = "710"; logo.Font = Enum.Font.GothamBlack; logo.TextSize = 18
    logo.TextColor3 = COLORS.Green; logo.BackgroundColor3 = COLORS.Black2
    logo.BorderSizePixel = 0; logo.Parent = header; addCorner(logo, 12)
    addStroke(logo, COLORS.Green, 1, .3)
    attachBrandLogo(logo)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(68, 4); title.Size = UDim2.new(1, -122, 0, 29)
    title.BackgroundTransparency = 1; title.Text = "710 HUB"; title.TextSize = 26
    title.Font = Enum.Font.GothamBlack; title.TextColor3 = COLORS.White
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "BrandSubtitle"
    subtitle.Position = UDim2.fromOffset(69, 34); subtitle.Size = UDim2.new(1, -123, 0, 19)
    subtitle.BackgroundTransparency = 1; subtitle.Text = "MUSCLE LEGENDS  /  CONTROLE DE EVOLUÇÃO"; subtitle.TextSize = 10
    subtitle.Font = Enum.Font.GothamMedium; subtitle.TextColor3 = COLORS.Muted
    subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = header
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -40, 0, 1); line.Position = UDim2.fromOffset(20, 78)
    line.BackgroundColor3 = Color3.new(1, 1, 1); line.BorderSizePixel = 0; line.Parent = main
    addGradient(line, COLORS.GreenDark, COLORS.Border, 0)
end
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Conteudo"; scroll.Position = UDim2.fromOffset(16, 169)
scroll.Size = UDim2.new(1, -32, 1, -229); scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = COLORS.Green; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(); scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ClipsDescendants = true; scroll.Parent = main
do
    local ornament = Instance.new("Frame")
    ornament.Name = "HeaderArt"; ornament.BackgroundTransparency = 1
    ornament.Size = UDim2.fromOffset(64, 40); ornament.Position = UDim2.new(1, -116, 0, 6)
    ornament.Parent = header
    local emblem = drawIcon(ornament, "Farm", 36, COLORS.NeonDim)
    emblem.Position = UDim2.fromOffset(13, 2); emblem.Rotation = -18
    for i = 1, 3 do
        local dash = Instance.new("Frame")
        dash.Size = UDim2.fromOffset(2, 3+i*3); dash.Position = UDim2.fromOffset(i*5, 25)
        dash.BackgroundColor3 = COLORS.NeonDim; dash.BackgroundTransparency = .5
        dash.BorderSizePixel = 0; dash.Rotation = 25; dash.Parent = ornament
    end
end
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 12); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll
local searchQuery, currentSection = "", ""
local searchEntries = {}
local UI = {Category = "Farm", CurrentCategory = "Farm", Order = 0, Tabs = {}, Width = 980,
    ContentWidth = 730, LargeText = false, Stats = {}, TabBadges = {}, TabLabels = {}, DailyTitles = {}}
UI.Descriptions = {
    Farm = "Treino, equipamentos e ganho de força.", Bosses = "Encontros, defesa e recompensas.",
    PvP = "Jogadores, combate e filtros de karma.", Pets = "Sua coleção, cristais e evolução.",
    Metas = "Planejamento e progresso da conta.", Perfis = "Configurações para cada objetivo.",
    ["Sessão"] = "Rendimento, histórico e diagnóstico.", Ajustes = "Seu painel, atalhos e preferências.",
}
function UI:compact(value)
    value = tonumber(value) or 0
    for _, unit in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
        if math.abs(value) >= unit[1] then return string.format("%.2f%s", value/unit[1], unit[2]) end
    end
    return string.format("%.0f", value)
end
function UI:label(parent, text, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Text = text; label.TextSize = size
    label.TextColor3 = color or COLORS.White; label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left; label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = parent; return label
end
do
    UI.Metrics = Instance.new("Frame")
    UI.Metrics.Name = "ResumoDaConta"; UI.Metrics.BackgroundTransparency = 1; UI.Metrics.Parent = main
    for index, data in ipairs({{"REBIRTHS", "Progresso da sua conta"}, {"FORÇA / MIN", "Rendimento observado"}, {"RITMO DO FARM", "Solicitações de treino"}}) do
        local tile = Instance.new("Frame")
        tile.Name = "Metrica"..index; tile.BackgroundColor3 = COLORS.Panel; tile.BorderSizePixel = 0
        tile.Position = UDim2.new((index-1)/3, (index-1)*4, 0, 0)
        tile.Size = UDim2.new(1/3,-8,1,0); tile.Parent = UI.Metrics
        addCorner(tile,12); addStroke(tile,COLORS.Border,1,.45)
        local heading = UI:label(tile,data[1],10,COLORS.Muted)
        heading.Position = UDim2.fromOffset(14,10); heading.Size = UDim2.new(1,-28,0,14)
        local value = UI:label(tile,"—",25,index == 1 and COLORS.GreenBright or COLORS.White)
        value.Font = Enum.Font.GothamBold; value.Position = UDim2.fromOffset(14,27); value.Size = UDim2.new(1,-28,0,29)
        local hint = UI:label(tile,data[2],10,COLORS.Muted)
        hint.Position = UDim2.fromOffset(14,59); hint.Size = UDim2.new(1,-28,0,15)
        UI.Stats[index] = {Frame=tile,Heading=heading,Value=value,Hint=hint}
    end
    UI.PageTitle = UI:label(main,"Farm",24,COLORS.White)
    UI.PageTitle.Font = Enum.Font.GothamBold
    UI.PageHint = UI:label(main,UI.Descriptions.Farm,11,COLORS.Muted)
    UI.Sidebar = Instance.new("Frame")
    UI.Sidebar.Name = "SidebarSurface"; UI.Sidebar.BackgroundColor3 = COLORS.Black2
    UI.Sidebar.BorderSizePixel = 0; UI.Sidebar.Parent = main
    addCorner(UI.Sidebar,12); addStroke(UI.Sidebar,COLORS.Border,1,.6)
    UI.NavCaption = UI:label(main,"ESPAÇO DE TRABALHO",9,COLORS.Muted)
    UI.VersionBadge = UI:label(main,"710 HUB  •  ML",10,COLORS.Off)
    task.spawn(function()
        while SESSION.Alive do
            UI.Stats[1].Value.Text = UI:compact(currentRebirths())
            local rate = M:strengthRate()
            UI.Stats[2].Value.Text = rate and (UI:compact(rate).." / min") or "Coletando..."
            local interval,reps = M:farmPace()
            UI.Stats[3].Value.Text = string.format("%.0f rep/s",reps/math.max(.001,interval))
            UI.Stats[3].Hint.Text = S.FarmCustom and "Velocidade personalizada" or "Perfil de velocidade ativo"
            task.wait(1)
        end
    end)
end
UI.Groups = {
    ["PVP E KARMA"] = "PvP",
    ["RENDIMENTO E PLANEJAMENTO"] = "Metas", ["BONUS OFICIAIS"] = "Farm",
    ["FARM"] = "Farm", ["MÁQUINAS"] = "Farm", ["AGILIDADE"] = "Farm", ["FARM INTELIGENTE"] = "Farm",
    ["BOSSES"] = "Bosses", ["PROTECAO E BOSSES"] = "Bosses", ["PETS E CRISTAIS"] = "Pets",
    ["METAS"] = "Metas", ["PROGRESSAO"] = "Metas", ["METAS E COMPARACAO"] = "Metas",
    ["PERFIS RÁPIDOS"] = "Perfis", ["CONTROLE E PERFIS"] = "Perfis",
    ["SESSÃO"] = "Sessão", ["DIAGNÓSTICO"] = "Sessão", ["HISTORICO E COMPATIBILIDADE"] = "Sessão",
    ["UTILIDADES"] = "Ajustes", ["TELEPORTES"] = "Ajustes",
}
function UI:normalize(text)
    text = string.lower(text)
    for accented, plain in pairs({["á"]="a",["à"]="a",["ã"]="a",["â"]="a",["é"]="e",["ê"]="e",["í"]="i",["ó"]="o",["ô"]="o",["õ"]="o",["ú"]="u",["ç"]="c",["Á"]="a",["Ã"]="a",["É"]="e",["Í"]="i",["Ó"]="o",["Ú"]="u",["Ç"]="c",["Õ"]="o"}) do
        text = string.gsub(text, accented, plain)
    end
    return text
end
function UI:addEntry(object, text, heading)
    self.Order += 1; object.LayoutOrder = self.Order
    local entry = {Object = object, Text = self:normalize(text), Category = self.CurrentCategory,
        Section = currentSection, Heading = heading == true, Available = true}
    searchEntries[#searchEntries + 1] = entry
    return entry
end
function UI:matches(entry)
    if searchQuery ~= "" then return string.find(entry.Text, searchQuery, 1, true) ~= nil end
    return entry.Category == self.Category
end
function UI:refresh(resetScroll, animate)
    local count, sections, totals = 0, {}, {}
    for _, entry in ipairs(searchEntries) do
        if not entry.Heading then
            if entry.Available ~= false then totals[entry.Category] = (totals[entry.Category] or 0) + 1 end
            local visible = entry.Available ~= false and self:matches(entry)
            entry.Object.Visible = visible
            if visible then count += 1; sections[entry.Section] = true end
            if visible and animate then
                entry.Object.BackgroundTransparency = .45
                tween(entry.Object, .2, {BackgroundTransparency = 0})
            end
        end
    end
    for _, entry in ipairs(searchEntries) do
        if entry.Heading then entry.Object.Visible = sections[entry.Section] == true end
    end
    for category, tab in pairs(self.Tabs) do
        local selected = searchQuery == "" and category == self.Category
        if tab:FindFirstChild("SelectedLine") then tab.SelectedLine.Visible = selected end
        tween(tab, .14, {BackgroundColor3 = selected and COLORS.GreenDark or COLORS.Panel2,
            TextColor3 = selected and COLORS.GreenBright or COLORS.Muted})
        if self.TabBadges[category] then self.TabBadges[category].Text = tostring(totals[category] or 0) end
        if self.TabLabels[category] then
            tween(self.TabLabels[category],.14,{TextColor3=selected and COLORS.GreenBright or COLORS.Muted})
        end
    end
    self.PageTitle.Text = searchQuery ~= "" and "Resultados da busca" or self.Category
    self.PageHint.Text = searchQuery ~= "" and (count.." funções encontradas em todas as categorias")
        or (self.Descriptions[self.Category] or "")
    if self.Empty then self.Empty.Visible = count == 0 end
    if resetScroll then scroll.CanvasPosition = Vector2.new() end
end
function UI:resize()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 700)
    if self.Mini then
        local position = self.Mini.Position
        self.Mini.Position = UDim2.fromOffset(
            math.clamp(position.X.Scale*viewport.X+position.X.Offset,0,math.max(0,viewport.X-58)),
            math.clamp(position.Y.Scale*viewport.Y+position.Y.Offset,0,math.max(0,viewport.Y-48)))
    end
    self.Width = math.min(980, math.max(1, viewport.X - 28))
    local height = math.min(760, math.max(1, viewport.Y - 24))
    self.Compact = self.Width < 680 or (UIS.TouchEnabled and height < 560)
    self.Short = height < 560
    local left = self.Compact and 20 or 224
    self.ContentWidth = self.Width - left - 20
    main.Size = UDim2.fromOffset(self.Width, height)
    if header:FindFirstChild("HeaderArt") then header.HeaderArt.Visible = self.Width >= 500 end
    if header:FindFirstChild("BrandSubtitle") then
        header.BrandSubtitle.Text = self.Compact and "MUSCLE LEGENDS" or "MUSCLE LEGENDS  /  CONTROLE DE EVOLUÇÃO"
    end
    main.Position = UDim2.new(.5, -self.Width / 2, .5, -height / 2)
    shadow.Size = UDim2.fromOffset(self.Width + 12, height + 12)
    shadow.Position = UDim2.new(.5, -self.Width / 2 - 6, .5, -height / 2 + 3)
    self.Metrics.Position = UDim2.fromOffset(20,92)
    self.Metrics.Size = UDim2.new(1,-40,0,84)
    self.Metrics.Visible = not self.Short
    self.Sidebar.Visible = not self.Compact
    self.Sidebar.Position = UDim2.fromOffset(20,190); self.Sidebar.Size = UDim2.new(0,184,1,-264)
    self.NavCaption.Visible = not self.Compact
    self.NavCaption.Position = UDim2.fromOffset(34,205); self.NavCaption.Size = UDim2.fromOffset(160,16)
    self.VersionBadge.Visible = not self.Compact
    self.VersionBadge.Position = UDim2.new(0,34,1,-101); self.VersionBadge.Size = UDim2.fromOffset(156,16)
    self.PageTitle.Position = UDim2.fromOffset(left,self.Compact and 283 or 190)
    self.PageTitle.Size = UDim2.new(0,self.ContentWidth,0,30)
    self.PageHint.Position = UDim2.fromOffset(left,self.Compact and 313 or 220)
    self.PageHint.Size = UDim2.new(0,self.ContentWidth,0,18)
    scroll.Position = UDim2.fromOffset(left,self.Compact and 344 or 298)
    scroll.Size = UDim2.new(0,self.ContentWidth,1,self.Compact and -412 or -366)
    if self.Nav then
        self.Nav.Position = UDim2.fromOffset(self.Compact and 20 or 28,self.Compact and 190 or 234)
        self.Nav.Size = self.Compact and UDim2.new(1,-40,0,44) or UDim2.new(0,168,1,-349)
        self.Nav.ScrollingDirection = self.Compact and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
        self.Nav.AutomaticCanvasSize = self.Compact and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
        self.NavLayout.FillDirection = self.Compact and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        for category,tab in pairs(self.Tabs) do
            tab.Size = UDim2.fromOffset(self.Compact and 108 or 168,44)
            if self.TabBadges[category] then self.TabBadges[category].Visible = not self.Compact end
            if self.TabLabels[category] then self.TabLabels[category].Size = UDim2.new(1,self.Compact and -42 or -72,0,16) end
        end
    end
    if self.Search then
        self.Search.Position = UDim2.fromOffset(left,self.Compact and 236 or 249)
        self.Search.Size = UDim2.new(0,self.ContentWidth-50,0,44)
    end
    if self.Larger then self.Larger.Position = UDim2.new(1,-60,0,self.Compact and 236 or 249) end
    for _, stat in ipairs(self.Stats) do
        stat.Value.TextSize = self.Compact and 19 or 25
        stat.Heading.TextSize = self.Compact and 8 or 10
        stat.Hint.TextSize = self.Compact and 8 or 10
        stat.Heading.Position = UDim2.fromOffset(self.Compact and 9 or 14,10)
        stat.Value.Position = UDim2.fromOffset(self.Compact and 9 or 14,27)
        stat.Hint.Position = UDim2.fromOffset(self.Compact and 9 or 14,59)
    end
    self.PageTitle.Visible = not (self.Short and self.Compact)
    self.PageHint.Visible = not (self.Short and self.Compact)
    if self.Short then
        self.Sidebar.Position = UDim2.fromOffset(20,96); self.Sidebar.Size = UDim2.new(0,184,1,-170)
        self.NavCaption.Position = UDim2.fromOffset(34,108)
        self.PageTitle.Position = UDim2.fromOffset(left,94)
        self.PageHint.Position = UDim2.fromOffset(left,124)
        scroll.Position = UDim2.fromOffset(left,self.Compact and 196 or 208)
        scroll.Size = UDim2.new(0,self.ContentWidth,1,self.Compact and -264 or -276)
        if self.Nav then
            self.Nav.Position = UDim2.fromOffset(self.Compact and 20 or 28,self.Compact and 88 or 136)
            self.Nav.Size = self.Compact and UDim2.new(1,-40,0,44) or UDim2.new(0,168,1,-253)
        end
        if self.Search then self.Search.Position = UDim2.fromOffset(left,self.Compact and 140 or 154) end
        if self.Larger then self.Larger.Position = UDim2.new(1,-60,0,self.Compact and 140 or 154) end
    end
    if height < 300 then
        self.PageTitle.Visible = false; self.PageHint.Visible = false
        if self.Compact then
            if self.Nav then self.Nav.Position = UDim2.fromOffset(20,64) end
            if self.Search then self.Search.Position = UDim2.fromOffset(left,112) end
            if self.Larger then self.Larger.Position = UDim2.new(1,-60,0,112) end
            scroll.Position = UDim2.fromOffset(left,160)
            scroll.Size = UDim2.new(0,self.ContentWidth,1,-228)
        end
    end
    for _, entry in ipairs(searchEntries) do if entry.Resize then entry.Resize() end end
end
do
    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Categorias"; nav.Position = UDim2.fromOffset(16, 122)
    nav.Size = UDim2.new(1, -32, 0, 39); nav.BackgroundTransparency = 1; nav.BorderSizePixel = 0
    nav.ScrollBarThickness = 2; nav.ScrollBarImageColor3 = COLORS.Cyan
    nav.ScrollingDirection = Enum.ScrollingDirection.X; nav.AutomaticCanvasSize = Enum.AutomaticSize.X
    nav.CanvasSize = UDim2.new(); nav.Parent = main
    UI.Nav = nav
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = nav
    UI.NavLayout = layout
    for index, category in ipairs({"Farm", "Bosses", "PvP", "Pets", "Metas", "Perfis", "Sessão", "Ajustes"}) do
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.fromOffset(94, 36); tab.Text = ""; tab.Font = Enum.Font.GothamBold
        tab.TextSize = 12; tab.TextColor3 = COLORS.Muted; tab.BackgroundColor3 = COLORS.Panel2
        tab.BorderSizePixel = 0; tab.LayoutOrder = index; tab.Parent = nav; addCorner(tab, 9)
        local icon = drawIcon(tab, category, 17, COLORS.YellowSoft)
        icon.Position = UDim2.fromOffset(10, 12)
        local name = UI:label(tab,category,12,COLORS.Muted)
        name.Position = UDim2.new(0,36,.5,-8); name.Size = UDim2.new(1,-72,0,16)
        UI.TabLabels[category] = name
        local badge = UI:label(tab,"0",10,COLORS.Muted)
        badge.TextXAlignment = Enum.TextXAlignment.Right
        badge.Position = UDim2.new(1,-32,0,13); badge.Size = UDim2.fromOffset(23,16)
        UI.TabBadges[category] = badge
        local indicator = Instance.new("Frame")
        indicator.Name = "SelectedLine"; indicator.Size = UDim2.new(1, -24, 0, 2)
        indicator.Position = UDim2.new(0, 12, 1, -2); indicator.BorderSizePixel = 0
        indicator.BackgroundColor3 = COLORS.Green; indicator.Visible = false; indicator.Parent = tab; addCorner(indicator, 2)
        addStroke(tab, COLORS.NeonDim, 1, .85)
        UI.Tabs[category] = tab
        tab.Activated:Connect(function()
            UI.Category = category
            if UI.Search then UI.Search.Text = "" end
            searchQuery = ""
            UI:refresh(true, true)
        end)
    end
    local empty = Instance.new("TextLabel")
    empty.Size = UDim2.new(1, -16, 0, 90); empty.Text = "Nenhuma função encontrada.\nTente outra busca ou categoria."
    empty.TextSize = 16; empty.TextColor3 = COLORS.Muted; empty.TextWrapped = true
    empty.BackgroundTransparency = 1; empty.Visible = false; empty.Parent = scroll; UI.Empty = empty
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, -40, 0, 52); bottom.Position = UDim2.new(0, 20, 1, -60)
    bottom.BackgroundColor3 = COLORS.Panel; bottom.BorderSizePixel = 0; bottom.Parent = main; addCorner(bottom, 10)
    local pause = Instance.new("TextButton")
    pause.Size = UDim2.fromOffset(90, 44); pause.Position = UDim2.new(1, -198, 0, 5)
    pause.TextSize = 13; pause.Font = Enum.Font.GothamBold; pause.BackgroundColor3 = COLORS.GreenDark
    pause.TextColor3 = COLORS.Green; pause.BorderSizePixel = 0; pause.Parent = bottom; addCorner(pause, 8)
    pause.Activated:Connect(function() M:pause("Manual", not M.Reasons.Manual) end)
    local stop = Instance.new("TextButton")
    stop.Size = UDim2.fromOffset(96, 44); stop.Position = UDim2.new(1, -102, 0, 5)
    stop.Text = "Parar tudo"; stop.TextSize = 13; stop.Font = Enum.Font.GothamBold
    stop.TextColor3 = COLORS.Red; stop.BackgroundColor3 = Color3.fromRGB(47, 27, 36)
    stop.BorderSizePixel = 0; stop.Parent = bottom; addCorner(stop, 8)
    stop.Activated:Connect(stopAllAutomations)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -214, 1, 0); status.Position = UDim2.fromOffset(10, 0)
    status.BackgroundTransparency = 1; status.TextColor3 = COLORS.Green; status.TextSize = 13
    status.Font = Enum.Font.GothamMedium; status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd; status.Parent = bottom
    task.spawn(function()
        while SESSION.Alive do
            pause.Text = M.Reasons.Manual and "Retomar" or "Pausar"
            status.Text = M:canAct() and "●  Pronto para treinar" or "●  Sessão em pausa"
            status.TextColor3 = M:canAct() and COLORS.Success or COLORS.Yellow
            task.wait(.5)
        end
    end)
    local dragging, origin, position, touch = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; origin = input.Position; position = main.Position; touch = input
        end
    end)
    trackConnection(UIS.InputEnded:Connect(function(input)
        if input == touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    trackConnection(UIS.InputChanged:Connect(function(input)
        if not dragging or not (input.UserInputType == Enum.UserInputType.MouseMovement or input == touch) then return end
        local delta = input.Position - origin
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 700)
        local x = position.X.Scale * viewport.X + position.X.Offset + delta.X
        local y = position.Y.Scale * viewport.Y + position.Y.Offset + delta.Y
        main.Position = UDim2.fromOffset(math.clamp(x, 0, math.max(0, viewport.X - main.Size.X.Offset)),
            math.clamp(y, 0, math.max(0, viewport.Y - main.Size.Y.Offset - 40)))
        shadow.Position = main.Position + UDim2.fromOffset(-5, 1)
    end))
    local cameraConnection
    local function watchViewport()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then
            cameraConnection = trackConnection(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() UI:resize() end))
        end
        UI:resize()
    end
    trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport))
    watchViewport()
end
local function section(name, desc)
    currentSection = name .. " " .. (desc or "")
    UI.CurrentCategory = UI.Groups[name] or "Ajustes"
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -9, 0, 64); holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0; holder.Parent = scroll
    local entry = UI:addEntry(holder, currentSection, true)
    local badge = Instance.new("Frame")
    badge.Size = UDim2.fromOffset(32, 32); badge.Position = UDim2.fromOffset(0, 6)
    badge.BackgroundColor3 = COLORS.Panel2; badge.BorderSizePixel = 0; badge.Parent = holder
    addCorner(badge, 9); addStroke(badge, COLORS.Border, 1, .6)
    local symbol = drawIcon(badge, UI.CurrentCategory, 22, COLORS.Green)
    symbol.Position = UDim2.fromOffset(5, 5)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(44, 8); title.Size = UDim2.new(1, -4, 0, 24)
    title.BackgroundTransparency = 1; title.Text = name; title.TextSize = 12
    title.TextColor3 = COLORS.YellowSoft; title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left; title.TextWrapped = true; title.Parent = holder
    local detail = Instance.new("TextLabel")
    detail.Position = UDim2.fromOffset(2, 36); detail.Size = UDim2.new(1, -4, 0, 32)
    detail.Text = desc or ""; detail.TextSize = 14; detail.TextColor3 = COLORS.Muted
    detail.Font = Enum.Font.Gotham; detail.BackgroundTransparency = 1; detail.TextWrapped = true
    detail.TextXAlignment = Enum.TextXAlignment.Left; detail.TextYAlignment = Enum.TextYAlignment.Top; detail.Parent = holder
    entry.Resize = function()
        local width = math.max(80, UI.ContentWidth - 58)
        title.TextSize = UI.LargeText and 15 or 12; detail.TextSize = UI.LargeText and 13 or 11
        local service = game:GetService("TextService")
        local th = service:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(detail.Text, detail.TextSize, detail.Font, Vector2.new(width, 10000)).Y + 4
        title.Size = UDim2.new(1, -48, 0, th); detail.Position = UDim2.fromOffset(44, th + 12)
        detail.Size = UDim2.new(1, -48, 0, dh); holder.Size = UDim2.new(1, -9, 0, th + dh + 20)
    end
    entry.Resize()
end
local availabilityRefs = {}
local function card(titleText, description, callback, accentColor, availableFn)
    local accentColorFinal = accentColor or COLORS.Green
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = COLORS.Panel2; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Text = ""; b.Parent = scroll; addCorner(b, 11)
    local entry = UI:addEntry(b, currentSection .. " " .. titleText .. " " .. (description or ""))
    local stroke = addStroke(b, COLORS.Border, 1, .5)
    addGradient(b, Color3.fromRGB(255,255,255), Color3.fromRGB(217,223,239), 90)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(2, 18); accent.Position = UDim2.fromOffset(0, 16)
    accent.BackgroundColor3 = accentColorFinal; accent.BorderSizePixel = 0; accent.Parent = b; addCorner(accent, 2)
    local t = Instance.new("TextLabel")
    t.Name = "Titre"; t.Position = UDim2.fromOffset(16, 13); t.BackgroundTransparency = 1
    t.Text = titleText; t.TextColor3 = COLORS.White; t.Font = Enum.Font.GothamBold; t.TextSize = 16
    t.TextWrapped = true; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top; t.Parent = b
    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1; d.Text = description or ""; d.TextColor3 = COLORS.Muted
    d.Font = Enum.Font.Gotham; d.TextSize = 14; d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left; d.TextYAlignment = Enum.TextYAlignment.Top; d.Parent = b
    local action = UI:label(b,callback and "→" or "INFO",callback and 18 or 8,COLORS.Muted)
    action.Name = "CardAction"; action.Position = UDim2.new(1,-47,0,14)
    action.Size = UDim2.fromOffset(32,20); action.TextXAlignment = Enum.TextXAlignment.Center
    entry.Resize = function()
        local isToggle = b:GetAttribute("IsToggle") == true
        local reserve = isToggle and 108 or 36
        action.Visible = not isToggle
        local width = math.max(1, UI.ContentWidth - 43 - reserve)
        t.TextSize = UI.LargeText and 16 or 14; d.TextSize = UI.LargeText and 13 or 11
        local service = game:GetService("TextService")
        local th = service:GetTextSize(t.Text, t.TextSize, t.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(width, 10000)).Y + 4
        t.Size = UDim2.new(1, -32 - reserve, 0, th)
        d.Position = UDim2.fromOffset(16, 18 + th); d.Size = UDim2.new(1, -32, 0, dh)
        -- Descriptions use the full width below the toggle for easier reading.
        if reserve > 0 then
            dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(math.max(80, UI.ContentWidth - 43), 10000)).Y + 4
            d.Size = UDim2.new(1, -32, 0, dh)
        end
        b.Size = UDim2.new(1, -9, 0, math.max(72, 32 + th + dh))
    end
    entry.Resize()
    t:GetPropertyChangedSignal("Text"):Connect(entry.Resize)
    d:GetPropertyChangedSignal("Text"):Connect(entry.Resize)
    b:GetAttributeChangedSignal("IsToggle"):Connect(entry.Resize)
    local function isAvailable()
        if not availableFn then return true end
        local ok, available = pcall(availableFn); return ok and available == true
    end
    local function renderAvailability()
        entry.Available = isAvailable(); b.Visible = entry.Available and UI:matches(entry)
    end
    if availableFn then availabilityRefs[#availabilityRefs + 1] = renderAvailability end
    b.MouseEnter:Connect(function() tween(b, .16, {BackgroundColor3 = COLORS.Panel3}); tween(stroke, .16, {Transparency = .15}) end)
    b.MouseLeave:Connect(function() tween(b, .2, {BackgroundColor3 = COLORS.Panel2}); tween(stroke, .2, {Transparency = .5}) end)
    b.Activated:Connect(function()
        if not isAvailable() then setHubStatus(titleText .. " indisponível nesta sessão"); return end
        tween(stroke, .1, {Transparency = 0})
        task.delay(.2, function() if b.Parent then tween(stroke, .2, {Transparency = .5}) end end)
        if callback then task.spawn(callback, b, t, d) end
    end)
    return b, t, d, stroke, renderAvailability
end
-- END MAINTENANCE MENU

local toggleRefs = {}

local function renderAllToggles()
    if HubRuntime.SourceBridge then HubRuntime.SourceBridge:sync() end
    for _, render in pairs(toggleRefs) do
        pcall(render)
    end
end
HubRuntime.RenderToggles = renderAllToggles

local toggleTitles = {}
local function resolveToggleConflicts(key)
    if key == "AutoBestPetObjective" and S.AutoBestPetObjective then S.PreserveFarmPets = true end
    if key == "AutoNovaPhoenix" and S.AutoNovaPhoenix then
        HubRuntime.NovaAttempts = 0
        HubRuntime.NovaNoProgress = 0
        HubRuntime.NovaStatus = "Aguardando identificacao do cristal Overcharged"
    elseif key == "AutoNovaPhoenix" then
        HubRuntime.NovaStatus = "Parado pelo usuario"
    end
    local disabled = M:resolveConflicts(key)
    local names = {}
    for _, other in ipairs(disabled) do
        if other == "AutoBoss" and HubRuntime.StopBoss then HubRuntime.StopBoss() end
        if other == "AutoNovaPhoenix" then HubRuntime.NovaStatus = "Parado: outra abertura de cristal foi ligada" end
        if (other == "PvpGood" or other == "PvpEvil") and M.stopPvp then M:stopPvp() end
        if other == "LockPosition" then lockedCFrame = nil end
        names[#names + 1] = toggleTitles[other] or other
    end
    if #names > 0 then
        local message = (toggleTitles[key] or key) .. ": desligado por conflito: " .. table.concat(names, ", ")
        setHubStatus(message)
        M:log("Conflitos", message)
    end
end

local function toggle(titleText, description, key, availableFn)
    toggleTitles[key] = titleText
    local b, t, d = card(titleText, description, nil, COLORS.Green)
    b:SetAttribute("IsToggle", true)
    b:SetAttribute("ToggleKey", key)
    local pill = Instance.new("TextLabel")
    pill.Size = UDim2.fromOffset(92, 28); pill.Position = UDim2.new(1, -108, 0, 11)
    pill.BorderSizePixel = 0; pill.Font = Enum.Font.GothamMedium; pill.TextSize = 11
    pill.Parent = b; addCorner(pill, 14)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(6,6); indicator.Position = UDim2.fromOffset(10,11)
    indicator.BorderSizePixel = 0; indicator.Parent = pill; addCorner(indicator,3)
    local function isAvailable()
        if not availableFn then return true end
        local ok, available = pcall(availableFn); return ok and available == true
    end
    local function render()
        local available = isAvailable()
        for _, entry in ipairs(searchEntries) do
            if entry.Object == b then
                entry.Available = available
                b.Visible = available and UI:matches(entry)
                break
            end
        end
        local enabled = S[key] == true
        pill.Text = enabled and "  Ativo" or "  Inativo"
        indicator.BackgroundColor3 = enabled and COLORS.Success or COLORS.Off
        tween(pill, .18, {
            BackgroundColor3 = enabled and Color3.fromRGB(24,44,39) or COLORS.Black2,
            TextColor3 = enabled and COLORS.Success or COLORS.Muted,
        })
    end
    b.Activated:Connect(function()
        if not isAvailable() then setHubStatus(titleText .. " indisponível nesta sessão"); return end
        if M.Comparing then M:cancelComparison(); M:clearAutomation(); M.ComparisonStatus = "Comparação cancelada por alteração manual" end
        S[key] = not S[key]
        resolveToggleConflicts(key)
        renderAllToggles()
    end)
    toggleRefs[key] = render
    render()
    return b
end

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        renderAllToggles()
        for _, render in ipairs(availabilityRefs) do
            pcall(render)
        end
        UI:refresh(false, false)
    end
end)

-- Botão compacto para reabrir o painel.
local mini = Instance.new("TextButton")
mini.Name = "710Hub_Mini"; mini.Size = UDim2.fromOffset(58, 48)
mini.Position = UDim2.new(0, 16, .5, -24); mini.BackgroundColor3 = COLORS.Black2
mini.BorderSizePixel = 0; mini.Text = "710"; mini.TextColor3 = COLORS.Green
mini.TextSize = 18; mini.Font = Enum.Font.GothamBlack; mini.Visible = false; mini.Parent = gui
addCorner(mini, 13); addStroke(mini, COLORS.Cyan, 1.5, .15)
attachBrandLogo(mini)
UI.Mini = mini
local miniDragged = false
do
    local pointer, origin, position
    mini.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pointer, origin, position = input, input.Position, mini.Position
            miniDragged = false
        end
    end)
    trackConnection(UIS.InputChanged:Connect(function(input)
        if not pointer or not (input == pointer or input.UserInputType == Enum.UserInputType.MouseMovement) then return end
        local delta = input.Position - origin
        if delta.Magnitude < 6 and not miniDragged then return end
        miniDragged = true
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,700)
        mini.Position = UDim2.fromOffset(
            math.clamp(position.X.Scale*viewport.X+position.X.Offset+delta.X,0,math.max(0,viewport.X-58)),
            math.clamp(position.Y.Scale*viewport.Y+position.Y.Offset+delta.Y,0,math.max(0,viewport.Y-48)))
    end))
    trackConnection(UIS.InputEnded:Connect(function(input)
        if input == pointer or input.UserInputType == Enum.UserInputType.MouseButton1 then pointer = nil end
    end))
end
local menuOpen = true
local function hideMenu()
    menuOpen = false; main.Visible = false; shadow.Visible = false; mini.Visible = true
end
local function showMenu()
    menuOpen = true; mini.Visible = false; main.Visible = true; shadow.Visible = true
    UI:refresh(false, true)
end
minimize.Activated:Connect(hideMenu)
mini.Activated:Connect(function() if not miniDragged then showMenu() end end)

trackConnection(UIS.InputBegan:Connect(function(input, processed)
    if not SESSION.Alive or processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        if menuOpen then hideMenu() else showMenu() end
    elseif input.KeyCode == Enum.KeyCode.End then
        stopAllAutomations()
        renderAllToggles()
    end
end))

-- conteúdo em português --------------------------------------------------------
section("FARM", "Automatizações principais para evoluir sua conta.")

for _, movement in ipairs({
    {"Peso automatico", "Weight", "TrainWeight"},
    {"Flexoes automaticas", "Pushups", "TrainPushups"},
    {"Abdominais automaticos", "Situps", "TrainSitups"},
    {"Parada de maos automatica", "Handstands", "TrainHandstands"},
}) do
    toggle(movement[1], "Usa somente " .. movement[2] .. ". Desliga treinos conflitantes; se a ferramenta faltar, aguarda sem trocar de movimento.", movement[3])
end

toggle(
    "Força Rápida",
    "Equipa Weight/Pushups/Situps/Handstands e envia rajadas curtas de treino; desliga sozinho se a Strength não subir.",
    "TurboStrength",
    canTrain
)

toggle(
    "Força F2P Máxima",
    "Equipa automaticamente os melhores pets de Strength que você já possui e usa o melhor treino disponível sem precisar de pacote pago.",
    "MaxStrengthF2P",
    function() return canTrain() or canMachineFarm() end
)

toggle(
    "Rebirth automático",
    "Tenta rebirth imediatamente sempre que possível, sem delay artificial do 710Hub. O servidor ainda controla o momento válido.",
    "Rebirth",
    canRebirth
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
    "AutoPunch",
    canPunch
)

toggle(
    "Farm inteligente de pedras",
    "Procura automaticamente a pedra mais forte que sua Durability atual consegue usar.",
    "SmartRock",
    canRockFarm
)

toggle(
    "Coletar baús automaticamente",
    "Tenta resgatar os baús conhecidos do mapa em intervalos regulares.",
    "Chests",
    canChestFarm
)

toggle(
    "Entrar no Brawl automaticamente",
    "Tenta entrar no evento Brawl sempre que ele estiver disponível.",
    "Brawl",
    canBrawl
)

section("BOSSES", "Espera um boss aparecer, vai até ele automaticamente, ataca e depois retorna ao ponto anterior.")

toggle(
    "Auto Kill Boss / farm de boss",
    "Monitora spawns e prioriza Rainbow > Mítico > Lendário > Épico > Raro > Comum. Troca de alvo quando surgir um mais raro.",
    "AutoBoss",
    canAutoBoss
)

toggle("Atacar acima do boss de cabeça para baixo", "Mantém o personagem invertido sobre a cabeça do boss e usa Punch; a altura define o alcance. Não garante invulnerabilidade.", "BossAbove")

toggle("Coletar drops do boss", "Procura novos baus e drops perto do boss; tenta contato ou interacao de coleta disponivel, e observa a tela de recompensa antes de retornar.", "BossAutoLoot")

local _, bossStatusTitle, bossStatusDesc = card(
    "Boss: aguardando spawn",
    "O scanner procura bosses por nome, pasta, atributos e indicadores visuais.",
    function() end,
    COLORS.Red
)

task.spawn(function()
    while SESSION.Alive and task.wait(.5) do
        if HubRuntime.BossActive then
            local boss = HubRuntime.BossModel
            local hum = boss and bossHumanoid(boss)
            bossStatusTitle.Text = "Boss: "..HubRuntime.BossTarget
            bossStatusDesc.Text = (M.BossState or "") .. " | " .. (hum
                and ("Vida atual: "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth))
                or "Vida indisponivel")
        elseif S.AutoBoss then
            bossStatusTitle.Text = "Boss: " .. (M.BossState or "aguardando spawn")
            bossStatusDesc.Text = "Mortes observadas: " .. HubRuntime.BossDeathsObserved .. " | " .. (M.BossLootResult or "Aguardando spawn")
        else
            bossStatusTitle.Text = "Boss: Auto Boss desligado"
            bossStatusDesc.Text = "Ative a opção acima para começar a monitorar os spawns."
        end
    end
end)


do
    card("Altura / distância do boss: " .. S.BossDistance, "Alterna 2, 3, 5 e 7 studs: altura sobre a cabeça no modo invertido, distância lateral no modo normal.", function(_, titleLabel)
        S.BossDistance = S.BossDistance == 2 and 3 or (S.BossDistance == 3 and 5 or (S.BossDistance == 5 and 7 or 2))
        titleLabel.Text = "Altura / distância do boss: " .. S.BossDistance
    end, COLORS.Yellow)
    toggle("Retornar depois do boss", "Volta ao ponto anterior quando o combate termina.", "BossReturn")
end

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
if #namesAtLoad > 0 and not S.SelectedMachine then
    S.SelectedMachine = namesAtLoad[1]
end

local _, machineTitle = card(
    "Máquina: "..(S.SelectedMachine or "nenhuma encontrada"),
    "Abra a lista pesquisável de máquinas detectadas no servidor.",
    function(_,titleLabel)
        local names = machineNames()
        if #names == 0 then
            titleLabel.Text = "Máquina: nenhuma encontrada"
            S.SelectedMachine = nil
            return
        end
        local options = {}
        for _, name in ipairs(names) do options[#options+1] = {Label=name,Value=name} end
        UI.Choose("Máquinas carregadas",options,function(name)
            S.SelectedMachine = name
            titleLabel.Text = "Máquina: "..name
        end)
    end,
    COLORS.Yellow,
    function() return #scanMachines() > 0 end
)

card(
    "Ir até a máquina selecionada",
    "Teleporta seu personagem para perto do assento da máquina escolhida.",
    function()
        useSelectedMachine(true)
    end,
    COLORS.Green,
    canMachineFarm
)

toggle(
    "Treino automático na máquina",
    "Usa repetidamente a máquina selecionada e envia o treino ligado ao interactSeat dela.",
    "AutoMachine",
    canMachineFarm
)

toggle(
    "Selecionar melhor máquina",
    "Escolhe automaticamente a máquina de maior nível detectada no servidor.",
    "AutoBestMachine",
    canMachineFarm
)

card(
    "Escolher melhor máquina agora",
    "Analisa os nomes e níveis das máquinas carregadas e seleciona a melhor opção encontrada.",
    function()
        local info = selectBestMachine()
        machineTitle.Text = "Máquina: "..(info and info.name or "nenhuma encontrada")
    end,
    COLORS.Yellow,
    canMachineFarm
)

toggle(
    "Ciclo Força + Rebirth",
    "Mantém o treino ativo e tenta rebirth continuamente para acelerar o ciclo de evolução.",
    "StrengthRebirth",
    function() return canRebirth() and (canMachineFarm() or canTrain()) end
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
    COLORS.Yellow,
    function() return #scanMachines() > 0 end
)

task.spawn(function()
    while SESSION.Alive and task.wait(1) do
        if S.SelectedMachine then
            machineTitle.Text = "Máquina: "..S.SelectedMachine
        end
    end
end)

section("AGILIDADE", "Farm automático de Agility usando a melhor esteira disponível para sua estatística atual.")

toggle(
    "Auto Agilidade / Esteira",
    "Vai para a melhor esteira liberada pela sua Agility e mantém o personagem correndo nela.",
    "AutoAgility",
    canAgilityFarm
)

local _, treadmillTitle, treadmillDesc = card(
    "Esteira recomendada: calculando...",
    "O 710Hub troca automaticamente para uma esteira melhor quando sua Agility aumenta.",
    function() end,
    COLORS.Green,
    canAgilityFarm
)

task.spawn(function()
    while SESSION.Alive and task.wait(1) do
        local tm = bestTreadmill()
        if tm then
            treadmillTitle.Text = "Esteira recomendada: "..tm.name
            treadmillDesc.Text = "Agility atual: "..math.floor(numberStat("Agility")).." • Requisito usado: "..tm.minAgility
        end
    end
end)

section("FARM INTELIGENTE", "Escolha um objetivo e o hub configura automaticamente o método adequado.")

local smartObjectives = {"Força","Durabilidade","Agilidade","Rebirths"}
local smartObjectiveIndex = 1
local _, smartObjectiveTitle = card(
    "Objetivo: "..S.SmartObjective,
    "Clique para alternar entre Força, Durabilidade, Agilidade e Rebirths.",
    function(_,titleLabel)
        smartObjectiveIndex = smartObjectiveIndex % #smartObjectives + 1
        S.SmartObjective = smartObjectives[smartObjectiveIndex]
        titleLabel.Text = "Objetivo: "..S.SmartObjective
        if S.SmartFarm then
            applySmartObjective()
            renderAllToggles()
        end
    end,
    COLORS.Yellow
)

local smartFarmButton = toggle(
    "Farm inteligente automático",
    "Ativa apenas as funções necessárias para o objetivo selecionado e ajusta o método automaticamente.",
    "SmartFarm",
    function() return canTrain() or canMachineFarm() or canRockFarm() or canAgilityFarm() or canRebirth() end
)

smartFarmButton.Activated:Connect(function()
    if S.SmartFarm then
        applySmartObjective()
        renderAllToggles()
    end
end)

local function field(title, value, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 68)
    frame.BackgroundColor3 = COLORS.Panel2
    frame.Parent = scroll
    addCorner(frame, 10)
    local entry = UI:addEntry(frame, currentSection .. " " .. title)
    entry.Daily = (UI.DailyTitles and UI.DailyTitles[title]) == true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.fromOffset(10, 0)
    label.Text = title
    label.TextColor3 = COLORS.White
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.fromOffset(10, 29)
    input.Text = tostring(value or "")
    input.ClearTextOnFocus = false
    input.TextSize = 16
    input.Font = Enum.Font.Gotham
    input.BorderSizePixel = 0
    input.TextColor3 = COLORS.White
    input.BackgroundColor3 = COLORS.Black2
    input.Parent = frame
    addCorner(input, 8)
    entry.Resize = function()
        label.TextSize = UI.LargeText and 16 or 14
        local height = game:GetService("TextService"):GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(math.max(100, UI.ContentWidth - 43), 10000)).Y + 8
        label.Position = UDim2.fromOffset(12, 9)
        label.Size = UDim2.new(1, -24, 0, height)
        input.Position = UDim2.fromOffset(12, height + 15)
        input.Size = UDim2.new(1, -24, 0, 44)
        frame.Size = UDim2.new(1, -9, 0, height + 71)
    end
    entry.Resize()
    input.FocusLost:Connect(function()
        local ok, message = callback(input.Text)
        input.TextColor3 = ok and COLORS.White or COLORS.Red
        setHubStatus(message or (ok and "Configurado" or "Valor invalido"))
    end)
    return input
end
section("PETS E CRISTAIS", "Funções para abrir cristais, comprar pets disponíveis e organizar sua coleção.")

local _, apexTitle, apexDesc = card(
    "Comprar pet Apex",
    "Procura Apex no catálogo atual do Pet Shop e solicita uma compra usando o sistema normal da loja.",
    function(_,titleLabel,descLabel)
        local apex = findShopPetByNamePart("apex")
        if not apex then
            titleLabel.Text = "Apex indisponível neste servidor"
            descLabel.Text = "Nenhum pet com 'Apex' foi encontrado em cPetShopFolder."
            setHubStatus("Apex indisponível")
            return
        end

        titleLabel.Text = "Comprar "..apex.Name
        descLabel.Text = "Compra solicitada. É necessário ter Gems e espaço no inventário."
        buyShopPet(apex)
    end,
    COLORS.Yellow,
    function() return canPetShop() and findShopPetByNamePart("apex") ~= nil end
)

card("Obter Nova Phoenix", "Se estiver no Pet Shop, solicita compra como Apex. Caso contrario, inicia a abertura do cristal Overcharged com limite de tentativas.", function()
    local item = findShopPetByNamePart("nova phoenix")
    if item then
        buyShopPet(item)
        return
    end
    if not canHatch() then setHubStatus("Cristal indisponivel neste servidor"); return end
    S.AutoNovaPhoenix = true
    resolveToggleConflicts("AutoNovaPhoenix")
    renderAllToggles()
    setHubStatus("Nova Phoenix nao esta no Pet Shop; abra a janela do cristal Overcharged")
end, COLORS.Yellow)

toggle(
    "Abrir Overcharged ate Nova Phoenix",
    "Abre o cristal do evento e para ao obter Nova Phoenix ou chegar ao limite. Cada abertura pode gastar Gems; 1% nao garante o pet.",
    "AutoNovaPhoenix",
    canHatch
)

local novaCrystalInput = field("Nome exato do cristal Overcharged", S.NovaCrystal, function(value)
    local name = string.match(value or "", "^%s*(.-)%s*$")
    if #name < 3 or #name > 60 then return false, "Digite o nome exato mostrado no cristal (3 a 60 caracteres)" end
    if S.AutoNovaPhoenix then return false, "Pare a abertura antes de trocar o cristal" end
    S.NovaCrystal = name
    HubRuntime.NovaCrystalVerified = true
    return true
end)
local novaMaxInput = field("Maximo de aberturas da Nova Phoenix", S.NovaMaxOpens, function(value)
    local count = tonumber(value)
    if not count or count % 1 ~= 0 or count < 1 or count > 1000 then return false, "Use um inteiro entre 1 e 1000" end
    S.NovaMaxOpens = count
    return true
end)
local _, _, novaStatusDesc = card("Estado da Nova Phoenix", "Desligado", function()
    setHubStatus(HubRuntime.NovaStatus)
end, COLORS.Yellow)
task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        novaStatusDesc.Text = HubRuntime.NovaStatus
        if not novaCrystalInput:IsFocused() then novaCrystalInput.Text = S.NovaCrystal end
        if not novaMaxInput:IsFocused() then novaMaxInput.Text = tostring(S.NovaMaxOpens) end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        local apex = findShopPetByNamePart("apex")
        if apex then
            apexTitle.Text = "Comprar "..apex.Name
            apexDesc.Text = "Disponível no Pet Shop atual • requer Gems e espaço no inventário."
        else
            apexTitle.Text = "Comprar pet Apex"
            apexDesc.Text = "Apex não foi encontrado no catálogo atual."
        end
    end
end)

toggle(
    "Abrir cristal automaticamente",
    "Abre repetidamente o cristal selecionado abaixo.",
    "Hatch",
    canHatch
)

local crystals = {
    "Blue Crystal","Green Crystal","Mythical Crystal","Frost Crystal",
    "Inferno Crystal","Legends Crystal","Muscle Elite Crystal","Galaxy Oracle Crystal","Jungle Crystal"
}
local crystalIndex = 1
card(
    "Cristal selecionado: "..crystals[crystalIndex],
    "Abra a lista pesquisável dos cristais conhecidos pelo 710Hub.",
    function(_,titleLabel)
        local options = {}
        for _, name in ipairs(crystals) do options[#options+1] = {Label=name,Value=name} end
        UI.Choose("Cristais conhecidos",options,function(name)
            S.HatchCrystal = name
            titleLabel.Text = "Cristal selecionado: "..name
        end)
    end,
    COLORS.Yellow,
    canHatch
)

card(
    "Abrir 1 cristal",
    "Abre uma vez o cristal atualmente selecionado.",
    function()
        safeInvoke(R.Crystal,"openCrystal",S.HatchCrystal)
    end,
    COLORS.Yellow,
    canHatch
)

card(
    "Equipar melhores pets de Força",
    "Ordena seus pets pelo bônus de Strength e equipa os melhores disponíveis para o farm F2P.",
    function()
        if equipBestStrengthOwned() then
            setHubStatus("Melhores pets de Força equipados")
        else
            setHubStatus("Não foi possível equipar pets de Força")
        end
    end,
    COLORS.Yellow,
    canPetManager
)

card(
    "Equipar melhores pets",
    "Ordena seus pets e tenta equipar os mais fortes que você já possui.",
    equipBestOwned,
    COLORS.Green,
    canPetManager
)

card(
    "Evoluir pets prontos",
    "Procura grupos de pets repetidos e tenta evoluir quando houver quantidade suficiente.",
    evolveReadyOwned,
    COLORS.Green,
    function() refreshRemotes(); return R.EvolvePet ~= nil and LP:FindFirstChild("petsFolder") ~= nil end
)

toggle(
    "Auto-equip após hatch",
    "Enquanto o Auto Hatch estiver ligado, atualiza periodicamente os melhores pets equipados.",
    "AutoEquipAfterHatch",
    function() return canHatch() and canPetManager() end
)

toggle(
    "Auto-evoluir após hatch",
    "Verifica periodicamente pets repetidos enquanto estiver abrindo cristais.",
    "AutoEvolveAfterHatch",
    function() refreshRemotes(); return canHatch() and R.EvolvePet ~= nil and LP:FindFirstChild("petsFolder") ~= nil end
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
    "Abra a lista pesquisável dos destinos carregados no mapa.",
    function(_,titleLabel)
        if #tpNames == 0 then return end
        local options = {}
        for index, name in ipairs(tpNames) do options[#options+1] = {Label=name,Value=index} end
        UI.Choose("Destinos carregados",options,function(index)
            tpIndex = index
            titleLabel.Text = "Destino: "..tpNames[index]
        end)
    end,
    COLORS.Yellow,
    function() return #tpNames > 0 end
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
    COLORS.Green,
    function() return #tpNames > 0 end
)

section("PERFIS RÁPIDOS", "Atalhos que combinam várias funções para objetivos diferentes.")

card(
    "Perfil: Força",
    "Ativa automaticamente o método de força disponível mais consistente nesta sessão.",
    function()
        stopAllAutomations()
        if canMachineFarm() or canTrain() then
            S.MaxStrengthF2P = true
            pcall(equipBestStrengthOwned)
        end
        renderAllToggles()
        setHubStatus("Perfil de Força ativado • F2P Máxima")
    end,
    COLORS.Green,
    function() return canMachineFarm() or canTrain() end
)

card(
    "Perfil: Durabilidade",
    "Ativa soco + melhor pedra compatível com sua Durability atual.",
    function()
        stopAllAutomations()
        S.AutoPunch = true
        S.SmartRock = true
        renderAllToggles()
        setHubStatus("Perfil de Durabilidade ativado")
    end,
    COLORS.Green,
    function() return canRockFarm() and canPunch() end
)

card(
    "Perfil: Pets",
    "Ativa Auto Hatch e, quando disponível, atualização automática dos melhores pets.",
    function()
        stopAllAutomations()
        S.Hatch = true
        if canPetManager() then
            S.AutoEquipAfterHatch = true
        end
        renderAllToggles()
        setHubStatus("Perfil de Pets ativado")
    end,
    COLORS.Yellow,
    canHatch
)

card(
    "Perfil: Rebirths",
    "Combina treino disponível com tentativas de rebirth e mantém o ciclo automaticamente.",
    function()
        stopAllAutomations()
        if canMachineFarm() then
            S.AutoBestMachine = true
            selectBestMachine()
            S.AutoMachine = true
        else
            S.Train = true
        end
        S.StrengthRebirth = true
        renderAllToggles()
        setHubStatus("Perfil de Rebirths ativado")
    end,
    COLORS.Yellow,
    function() return canRebirth() and (canMachineFarm() or canTrain()) end
)

card(
    "Perfil: Rebirth F2P Máximo",
    "Equipa melhores pets de Strength, ativa Força F2P Máxima e tenta rebirth assim que o servidor permitir.",
    function()
        stopAllAutomations()
        pcall(equipBestStrengthOwned)
        S.MaxStrengthF2P = true
        S.Rebirth = true
        renderAllToggles()
        setHubStatus("Rebirth F2P Máximo ativado")
    end,
    COLORS.Yellow,
    function() return canRebirth() and (canTrain() or canMachineFarm()) end
)

section("METAS", "Defina um objetivo e o hub para automaticamente quando alcançar o valor.")

local goalStats = {"Strength","Agility","Durability","Rebirths"}
local goalStatIndex = 1
local goalAdds = {
    Strength = {10000,100000,1000000,10000000},
    Agility = {1000,5000,20000,50000},
    Durability = {10000,100000,1000000,10000000},
    Rebirths = {10,50,100,500},
}
local goalAddIndex = 0

local _, goalStatTitle = card(
    "Estatística da meta: Strength",
    "Clique para alternar entre Strength, Agility, Durability e Rebirths.",
    function(_,titleLabel)
        goalStatIndex = goalStatIndex % #goalStats + 1
        S.GoalStat = goalStats[goalStatIndex]
        goalAddIndex = 0
        S.GoalValue = nil
        titleLabel.Text = "Estatística da meta: "..S.GoalStat
    end,
    COLORS.Yellow
)

local _, goalValueTitle = card(
    "Definir meta: clique para escolher",
    "Cria uma meta relativa ao seu valor atual.",
    function(_,titleLabel)
        local choices = goalAdds[S.GoalStat]
        goalAddIndex = goalAddIndex % #choices + 1
        local add = choices[goalAddIndex]
        S.GoalValue = goalCurrentValue() + add
        titleLabel.Text = "Meta: "..S.GoalStat.." = "..math.floor(S.GoalValue)
        setHubStatus("Meta configurada: +"..add.." em "..S.GoalStat)
    end,
    COLORS.Green
)

toggle(
    "Parar ao atingir a meta",
    "Quando o valor definido for alcançado, todas as automações são desligadas.",
    "GoalEnabled"
)

section("SESSÃO", "Informações úteis sobre seu progresso desde que o 710Hub foi iniciado.")

local startTime = os.clock()
local startRebirths = currentRebirths()
local startAgility = numberStat("Agility")
local startDurability = numberStat("Durability")
local lastStrength = numberStat("Strength")
local totalStrength = 0

local _, sessionTitle, sessionDesc = card(
    "Sessão: iniciando...",
    "Calculando seus ganhos.",
    function() end,
    COLORS.Green
)

local _, efficiencyTitle, efficiencyDesc = card(
    "Eficiência: calculando...",
    "Mede os ganhos por minuto da sessão atual.",
    function() end,
    COLORS.Yellow
)

local function compactNumber(n)
    n = tonumber(n) or 0
    local a = math.abs(n)
    if a >= 1e12 then return string.format("%.2fT", n/1e12) end
    if a >= 1e9 then return string.format("%.2fB", n/1e9) end
    if a >= 1e6 then return string.format("%.2fM", n/1e6) end
    if a >= 1e3 then return string.format("%.1fK", n/1e3) end
    return tostring(math.floor(n))
end

task.spawn(function()
    while SESSION.Alive and task.wait(1) do
        local elapsed = math.max(1, os.clock() - startTime)
        local minutes = math.max(1/60, elapsed/60)

        local strengthNow = numberStat("Strength")
        if strengthNow >= lastStrength then
            totalStrength += (strengthNow - lastStrength)
        end
        lastStrength = strengthNow

        local rebirthGain = math.max(0, currentRebirths() - startRebirths)
        local agilityGain = math.max(0, numberStat("Agility") - startAgility)
        local durabilityGain = math.max(0, numberStat("Durability") - startDurability)

        local strengthPerMin = totalStrength / minutes
        local agilityPerMin = agilityGain / minutes
        local durabilityPerMin = durabilityGain / minutes
        local rebirthPerMin = rebirthGain / minutes

        sessionTitle.Text = string.format(
            "Sessão: %02d:%02d:%02d",
            math.floor(elapsed/3600),
            math.floor((elapsed%3600)/60),
            math.floor(elapsed%60)
        )

        sessionDesc.Text = "Força: +"..compactNumber(totalStrength)
            .." • Agility: +"..compactNumber(agilityGain)
            .." • Rebirths: +"..compactNumber(rebirthGain)

        efficiencyTitle.Text = "Eficiência • Força/min: "..compactNumber(strengthPerMin)
            .." • Reb/min: "..string.format("%.2f", rebirthPerMin)

        efficiencyDesc.Text = "Agility/min: "..compactNumber(agilityPerMin)
            .." • Durability/min: "..compactNumber(durabilityPerMin)
            .." • Objetivo: "..S.SmartObjective
    end
end)

section("DIAGNÓSTICO", "Mostra o estado das partes principais do 710Hub em tempo real.")

local _, diagTitle, diagDesc = card(
    "Status: verificando...",
    "Inicializando diagnóstico.",
    function() end,
    COLORS.Green
)

task.spawn(function()
    while SESSION.Alive and task.wait(1) do
        local remoteCount = 0
        for _, remote in pairs(R) do
            if remote then remoteCount += 1 end
        end

        local muscleOK = getMuscleEvent() ~= nil
        local machineCount = #scanMachines()

        diagTitle.Text = "Status: "..HubRuntime.Status
        local selfTest = HubRuntime.SelfTestPassed
            and (" • Teste: "..HubRuntime.SelfTestPassed.." OK/"..HubRuntime.SelfTestFailed.." OFF")
            or ""
        diagDesc.Text = "Remotes: "..remoteCount.."/8"
            .." • muscleEvent: "..(muscleOK and "OK" or "AUSENTE")
            .." • Máquinas: "..machineCount
            .." • Respawns: "..HubRuntime.Respawns
            .." • FPS: "..math.floor(HubRuntime.AvgFPS)
            .." • Chamadas: "..HubRuntime.RemoteCalls
            .." • Cortadas: "..HubRuntime.SkippedRemoteCalls
            ..selfTest
    end
end)

local _, selfTestTitle, selfTestDesc = card(
    "Executar autoteste do 710Hub",
    "Verifica funções e dependências sem gastar Gems, abrir cristais ou fazer rebirth.",
    function(_,titleLabel,descLabel)
        titleLabel.Text = "Autoteste em andamento..."
        descLabel.Text = "Verificando personagem, remotes, máquinas, pets e executor."
        local passed, failed = runSelfTest()
        titleLabel.Text = "Autoteste: "..passed.." OK • "..failed.." indisponíveis"
        descLabel.Text = failed == 0
            and "Todas as dependências verificáveis estão disponíveis nesta sessão."
            or "Abra o console ou use Copiar relatório para ver quais itens falharam."
    end,
    COLORS.Green
)

card(
    "Copiar relatório do autoteste",
    "Copia o diagnóstico completo para você colar aqui caso alguma função não esteja funcionando.",
    function(_,titleLabel,descLabel)
        if not HubRuntime.SelfTestReport then
            runSelfTest()
        end

        if type(setclipboard) == "function" then
            local ok = pcall(function()
                setclipboard(HubRuntime.SelfTestReport)
            end)
            titleLabel.Text = ok and "Relatório copiado" or "Falha ao copiar relatório"
            descLabel.Text = ok
                and "Cole o relatório na conversa para eu analisar."
                or "O executor não permitiu acesso à área de transferência."
        else
            titleLabel.Text = "Clipboard indisponível"
            descLabel.Text = "O relatório completo foi enviado ao console do executor."
        end
    end,
    COLORS.Yellow
)

card(
    "Último erro",
    "Exibe o último erro capturado pelas chamadas protegidas do hub.",
    function(_,titleLabel,descLabel)
        titleLabel.Text = "Último erro capturado"
        descLabel.Text = HubRuntime.LastError
    end,
    COLORS.Yellow
)

section("UTILIDADES", "Controles gerais do 710Hub.")

local lockButton = toggle(
    "Travar posição",
    "Mantém seu personagem parado exatamente no ponto atual até você desligar.",
    "LockPosition",
    hasCharacter
)

lockButton.Activated:Connect(function()
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

local stabilityButton = toggle(
    "Modo Estável / Anti-Travamento",
    "Limita chamadas, desacelera loops pesados, otimiza gráficos e reage automaticamente a quedas fortes de FPS.",
    "StabilityMode"
)

stabilityButton.Activated:Connect(function()
    -- O toggle altera S.StabilityMode antes deste callback. Reaplicamos pelo
    -- controlador para salvar/restaurar os valores corretamente.
    local desired = S.StabilityMode
    S.StabilityMode = not desired
    setStabilityMode(desired)
    renderAllToggles()
end)

local _, stabilityInfoTitle, stabilityInfoDesc = card(
    "Estabilidade: monitorando",
    "Mostra FPS médio e quantas chamadas foram cortadas pelo limitador de carga.",
    function() end,
    COLORS.Yellow
)

task.spawn(function()
    while SESSION.Alive and task.wait(1) do
        stabilityInfoTitle.Text = "Estabilidade • FPS: "..math.floor(HubRuntime.AvgFPS)
        stabilityInfoDesc.Text = "Chamadas cortadas: "..HubRuntime.SkippedRemoteCalls
            .." • Proteções acionadas: "..HubRuntime.StabilityTrips
            .." • Modo: "..(S.StabilityMode and "ESTÁVEL" or "NORMAL")
    end
end)

local performanceButton, performanceTitle, performanceDesc = card(
    "Modo desempenho: OFF",
    "Reduz partículas, pós-processamento, sombras, água e qualidade gráfica local para aliviar GPU/CPU.",
    function(_,titleLabel)
        setPerformanceMode(not S.PerformanceMode)
        titleLabel.Text = "Modo desempenho: "..(S.PerformanceMode and "ON" or "OFF")
    end,
    COLORS.Green
)

task.spawn(function()
    while SESSION.Alive and task.wait(1) do
        performanceTitle.Text = "Modo desempenho: "..(S.PerformanceMode and "ON" or "OFF")
        performanceDesc.Text = S.PerformanceMode
            and "Otimização gráfica local ativa • efeitos pesados reduzidos."
            or "Reduz partículas, pós-processamento, sombras, água e qualidade gráfica local para aliviar GPU/CPU."
    end
end)

card(
    "Reentrar no servidor",
    "Reconecta sua conta ao mesmo jogo caso a sessão fique travada.",
    function()
        stopAllAutomations()
        setHubStatus("Reconectando...")
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LP)
        end)
    end,
    COLORS.Yellow
)

card(
    "Parar todas as automações",
    "Desliga treino, rebirth, baús, cristais e Brawl de uma vez.",
    function()
        stopAllAutomations()
        renderAllToggles()
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
footer.Text = "Modo Estável reduz carga • RightShift abre/fecha • END para tudo"
footer.TextColor3 = COLORS.Muted
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.Parent = scroll
footer.Visible = false

setHubStatus("Pronto • "..SESSION.Version)
print("[710Hub] Muscle Legends carregado • stability build • "..SESSION.Version)


-- Controles de progressao reaproveitam os metodos de treino existentes.
section("PROGRESSAO", "Rebirths por objetivo, treino posterior e parada por tempo.")
do
    local targetAdds = {10, 25, 50, 100}
    local targetIndex = 1
    card("Ciclo: +10 rebirths, depois forca", "Clique para escolher a quantidade antes de iniciar o ciclo.", function(_, titleLabel)
        targetIndex = targetIndex % #targetAdds + 1
        titleLabel.Text = "Ciclo: +" .. targetAdds[targetIndex] .. " rebirths, depois forca"
    end, COLORS.Yellow)
    card("Iniciar ciclo de progressao", "Treina e tenta rebirth ate a meta; depois continua somente o treino de forca.", function()
        stopAllAutomations()
        S.ProgressionTarget = currentRebirths() + targetAdds[targetIndex]
        S.RebirthTarget = S.ProgressionTarget
        S.MaxStrengthF2P = true
        S.Rebirth = true
        setHubStatus("Ciclo iniciado: meta de " .. S.ProgressionTarget .. " rebirths")
        renderAllToggles()
    end, COLORS.Green, function() return canRebirth() and (canTrain() or canMachineFarm()) end)
    card("Otimizar pets para forca agora", "Equipa os melhores pets de forca que voce ja possui.", function()
        local equipped = equipBestStrengthOwned()
        setHubStatus(equipped and "Pets de forca equipados" or "Pets de forca indisponiveis")
    end, COLORS.Green, canPetManager)

    local durations = {0, 15, 30, 60, 120}
    local durationIndex = 1
    local _, timerTitle, timerDescription = card("Parada automatica: desligada", "Clique para escolher 15, 30, 60 ou 120 minutos; clique novamente para desligar.", function()
        durationIndex = durationIndex % #durations + 1
        local minutes = durations[durationIndex]
        S.StopAt = minutes > 0 and (os.clock() + minutes * 60) or nil
    end, COLORS.Yellow)
    local _, rateTitle, rateDescription = card("Rendimento: medindo", "Estimativa baseada na variacao observada; nao cria multiplicadores.", function() end, COLORS.Green)
    task.spawn(function()
        local lastStrength, lastRebirths = numberStat("Strength"), currentRebirths()
        local lastSample, sampleStarted = os.clock(), os.clock()
        local strengthGain, rebirthGain = 0, 0
        while SESSION.Alive and task.wait(1) do
            local now = os.clock()
            local strength, rebirths = numberStat("Strength"), currentRebirths()
            -- Ignora a queda de forca causada pelo rebirth.
            strengthGain += math.max(0, strength - lastStrength)
            rebirthGain += math.max(0, rebirths - lastRebirths)
            lastStrength, lastRebirths = strength, rebirths
            if now - lastSample >= 10 then
                local elapsed = math.max(1, now - sampleStarted)
                rateTitle.Text = string.format("Forca/min: %.0f | Rebirths/h: %.1f", strengthGain * 60 / elapsed, rebirthGain * 3600 / elapsed)
                rateDescription.Text = "Media observada desde a abertura. Mortes de bosses observadas: " .. HubRuntime.BossDeathsObserved
                lastSample = now
            end
            if S.StopAt and M:canAct() and not M.Comparing then
                local remaining = math.max(0, math.ceil(S.StopAt - now))
                timerTitle.Text = string.format("Parada em %02d:%02d", math.floor(remaining / 60), remaining % 60)
                if remaining == 0 then
                    stopAllAutomations()
                    setHubStatus("Tempo configurado encerrado")
                end
            else
                timerTitle.Text = S.StopAt and "Parada automatica: pausada" or "Parada automatica: desligada"
            end
            timerDescription.Text = "Iniciar um novo perfil cancela o temporizador; configure o tempo depois do perfil."
            if M:canAct() and not M.Comparing and S.ProgressionTarget and rebirths >= S.ProgressionTarget then
                S.ProgressionTarget = nil
                S.Rebirth = false
                S.StrengthRebirth = false
                S.SmartFarm = false
                S.MaxStrengthF2P = true
                setHubStatus("Meta de rebirth atingida: continuando treino de forca")
                renderAllToggles()
            end
        end
    end)
end

-- BEGIN MAINTENANCE UI
-- Inserted inside initializeUI; isolated function keeps Luau register use bounded.
local function maintenanceUI()
    local function showReport(title, body)
        local old = gui:FindFirstChild("MaintenanceReport")
        if old then old:Destroy() end
        local frame = Instance.new("Frame")
        frame.Name = "MaintenanceReport"
        frame.Size = UDim2.new(.85, 0, .75, 0)
        frame.Position = UDim2.new(.075, 0, .125, 0)
        frame.BackgroundColor3 = COLORS.Panel
        frame.ZIndex = 20
        frame.Parent = gui
        addCorner(frame, 12)
        local close = Instance.new("TextButton")
        close.Text = title .. "  |  Fechar"
        close.TextSize = 15
        close.Font = Enum.Font.GothamBold
        close.Size = UDim2.new(1, 0, 0, 36)
        close.TextColor3 = COLORS.White
        close.BackgroundColor3 = COLORS.GreenDark
        close.ZIndex = 21
        close.Parent = frame
        close.Activated:Connect(function() frame:Destroy() end)
        local reportScroll = Instance.new("ScrollingFrame")
        reportScroll.Position = UDim2.fromOffset(8, 42)
        reportScroll.Size = UDim2.new(1, -16, 1, -50)
        reportScroll.BackgroundTransparency = 1
        reportScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        reportScroll.CanvasSize = UDim2.new()
        reportScroll.ZIndex = 21
        reportScroll.Parent = frame
        local text = Instance.new("TextBox")
        text.Size = UDim2.new(1, -12, 0, 0)
        text.AutomaticSize = Enum.AutomaticSize.Y
        text.Text = type(body) == "function" and body() or body
        if type(body) == "function" then
            task.spawn(function()
                while SESSION.Alive and frame.Parent do
                    local ok, value = pcall(body)
                    if ok then text.Text = value end
                    task.wait(.5)
                end
            end)
        end
        text.TextEditable = false
        text.ClearTextOnFocus = false
        text.MultiLine = true
        text.TextWrapped = true
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextYAlignment = Enum.TextYAlignment.Top
        text.TextColor3 = COLORS.White
        text.BackgroundTransparency = 1
        text.TextSize = 16
        text.Font = Enum.Font.Code
        text.ZIndex = 22
        text.Parent = reportScroll
    end
    section("CONTROLE E PERFIS", "Salve configuracoes e suspenda o farm sem perder suas escolhas.")
    local _, stateTitle, stateDesc = card("Estado da sessao", "", function() end, COLORS.Yellow)
    card("Pausar / Retomar", "Mantem as opcoes. Pausas por morte ou vida baixa terminam quando o personagem estiver pronto.", function()
        M:pause("Manual", not M.Reasons.Manual)
        renderAllToggles()
    end, COLORS.Yellow)
    local _, profileTitle = card("Perfil: slot " .. M.ProfileSlot, "Clique para alternar entre os tres slots.", function(_, title)
        M.ProfileSlot = M.ProfileSlot % 3 + 1
        title.Text = "Perfil: slot " .. M.ProfileSlot
    end, COLORS.Yellow)
    card("Salvar perfil", "O ultimo perfil salvo sera restaurado em pausa ao abrir. Disco quando disponivel; senao, memoria da sessao.", function()
        local _, message = M:saveProfile()
        setHubStatus(message)
        showReport("Perfil", message)
    end, COLORS.Green)
    card("Carregar perfil", "Restaura este slot em pausa. Clique em Retomar para iniciar as rotinas salvas.", function()
        local _, message = M:loadProfile()
        setHubStatus(message)
        renderAllToggles()
    end, COLORS.Green)
    toggle("Retomar depois de morrer", "Espera Humanoid e personagem prontos; desligado exige Retomar manualmente.", "ResumeAfterDeath")

    section("PROTECAO E BOSSES", "Prioridade de alvo e espera por recuperacao de vida.")
    toggle("Movimentacao defensiva no boss", "Recua apos perder vida e aguarda no ponto escolhido. Vida baixa usa os limites configurados abaixo. Nao preve ataques.", "BossDefense")
    card("Chances e historico dos bosses", "Comum 50%, Raro 30%, Epico 15%, Lendario 4%, Mitico 1%. Mostra historico observado; nao preve o sorteio.", function()
        showReport("Chances dos bosses", M:bossOddsReport())
    end, COLORS.Yellow)
    local _, _, observedBossDesc = card("Bosses observados agora", "Procurando...", function()
        M:observeBosses()
        showReport("Bosses no mapa", M.VisibleBossText)
    end, COLORS.Yellow)
    card("Diagnosticar boss proximo", "Mostra nomes, vida e motivo de reconhecimento dos NPCs ate 150 studs. Abra perto do boss.", function()
        showReport("Diagnostico de bosses", M:bossDiagnostic())
    end, COLORS.Yellow)
    field("Boss preferido (desempate por nome)", S.BossPreference, function(value)
        value = value:match("^%s*(.-)%s*$")
        if #value < 1 or #value > 150 then return false, "Nome precisa ter entre 1 e 150 caracteres" end
        S.BossPreference = value
        M:log("Boss", "Preferencia: " .. value)
        return true, "Preferencia aplicada somente aos bosses reconhecidos"
    end)
    toggle("Protecao de vida baixa", "Pausa o combate abaixo do limite e espera recuperar. Retorna ao ponto inicial se o retorno estiver ligado.", "HealthGuard")
    field("Pausar boss abaixo de vida (%)", S.HealthLow, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 5 or n > 60 then return false, "Use de 5 a 60%" end
        S.HealthLow = n; return true
    end)
    field("Retomar boss acima de vida (%)", S.HealthResume, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 65 or n > 100 then return false, "Use de 65 a 100%" end
        S.HealthResume = n; return true
    end)
    toggle("Alertar farm sem progresso", "Observa forca e rebirth; ignora pausas e combate com boss.", "StallAlerts")
    field("Tempo sem progresso para alertar (segundos)", S.StallSeconds, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 30 or n > 600 then return false, "Use de 30 a 600 segundos" end
        S.StallSeconds = n; return true
    end)

    section("PVP E KARMA", "Combate contra jogadores proximos; o jogo decide o dano e os ganhos.")
    toggle("PvP: qualquer jogador", "Aproxima e usa Punch no jogador vivo mais proximo, sem filtro de karma. Ignora protecao de spawn.", "PvpAny")
    toggle("PvP: karma bom", "Busca jogadores com mais karma ruim que bom. Desliga apenas rotinas incompativeis; ignora karma desconhecido e neutros.", "PvpGood")
    toggle("PvP: karma ruim", "Busca jogadores com mais karma bom que ruim. Desliga apenas rotinas incompativeis; ignora karma desconhecido e neutros.", "PvpEvil")
    field("Raio de busca PvP (studs)", S.PvpRadius, function(value)
        local number = tonumber(value)
        if not number or number ~= number or number < 10 or number > 500 then return false, "Use de 10 a 500 studs" end
        S.PvpRadius = number; return true
    end)
    field("Distancia do soco (studs)", S.PvpAttackRange, function(value)
        local number = tonumber(value)
        if not number or number ~= number or number < 1.5 or number > 5 then return false, "Use de 1.5 a 5 studs" end
        S.PvpAttackRange = number; return true
    end)
    local _, _, pvpStatus = card("Estado do PvP", "Desligado", function()
        showReport("PvP ao vivo", function() return (M.PvpStatus or "Desligado") .. "\n\n" .. (M.PvpDiagnostic or "Ligue um modo para analisar os jogadores.") .. "\n\nNao garante kills ou karma. Use Parar tudo para encerrar. Perfis carregados nao iniciam PvP automaticamente." end)
    end, COLORS.Yellow)

    section("METAS E COMPARACAO", "Metas digitadas e recomendacao baseada em treino observado.")
    field("Meta absoluta da estatistica selecionada em METAS", S.GoalValue, function(value)
        local ok, message = M:setGoal(value)
        return ok, message or ("Meta definida para " .. S.GoalStat .. "; ative a parada por meta em METAS")
    end)
    field("Rebirths adicionais no ciclo personalizado", 25, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n % 1 ~= 0 or n < 1 or n > 1000000 then return false, "Use um inteiro de 1 a 1000000" end
        M.CustomRebirths = n; return true
    end)
    card("Iniciar ciclo personalizado", "Faz a quantidade digitada de rebirths e depois continua o treino de forca.", function()
        stopAllAutomations()
        S.ProgressionTarget = currentRebirths() + (M.CustomRebirths or 25)
        S.RebirthTarget = S.ProgressionTarget
        S.MaxStrengthF2P, S.Rebirth = true, true
        renderAllToggles()
    end, COLORS.Green, function() return canRebirth() and (canTrain() or canMachineFarm()) end)
    card("Comparar metodos de treino", "Mede ate tres metodos por 20s cada. Suspende rebirth e outras rotinas durante a medicao.", function()
        local _, message = M:beginComparison()
        setHubStatus(message)
    end, COLORS.Green)
    card("Resultado da comparacao", "Mostra taxas observadas; amostras interrompidas nao contam como recomendacao.", function()
        local lines = {M.ComparisonStatus or "Nenhuma comparacao realizada"}
        for _, result in ipairs(M.BenchmarkResults) do
            lines[#lines + 1] = result.Name .. ": " .. (result.Valid and (math.floor(result.Rate) .. " forca/min") or "amostra invalida")
        end
        showReport("Comparacao", table.concat(lines, "\n"))
    end, COLORS.Yellow)
    toggle("Preservar meus pets no F2P", "Impede a troca periodica de pets pelo farm F2P Maximo. Equipar pets manualmente pelo menu continua disponivel.", "PreserveFarmPets")
    section("RENDIMENTO E PLANEJAMENTO", "Acompanhe ganhos reais e organize os ciclos de treino.")
    card("Velocidade do farm", "Clique: Normal / Rapido / Turbo. Ajusta Forca Rapida e o treino em rajada do F2P; nao multiplica a forca concedida pelo servidor.", function(_, title, detail)
        if M.Comparing then setHubStatus("Aguarde a comparacao terminar"); return end
        S.FarmCustom, M.BestTraining = false, nil
        S.FarmSpeed = math.floor(S.FarmSpeed or 2) % 3 + 1
        local names = {"Normal", "Rapido", "Turbo"}
        local delay, burst = M:farmPace()
        title.Text = "Velocidade do farm: " .. names[S.FarmSpeed]
        detail.Text = string.format("Ate %d tentativas de rep por ciclo de %.2fs. Modo Estavel reduz o ritmo. Compare o rendimento real abaixo.", burst, delay)
        setHubStatus("Velocidade: " .. names[S.FarmSpeed])
    end, COLORS.Green)

    field("Intervalo do farm (ms)", S.FarmIntervalMs, function(value)
        return M:setFarmTiming("FarmIntervalMs", value)
    end)
    field("Repeticoes por ciclo", S.FarmReps, function(value)
        return M:setFarmTiming("FarmReps", value)
    end)
    local _, paceTitle, paceDesc = card("Ritmo aplicado", "", function() end, COLORS.Yellow)

    local _, rateTitle, rateDesc = card("Rendimento recente", "Aguardando pelo menos 10 segundos de treino.", function()
        showReport("Rendimento", "A taxa usa ate 60 segundos de observacoes. Pausas, rebirth e quedas de forca reiniciam a janela.\nA previsao depende de manter o mesmo ritmo; nao e garantia de ganho.")
    end, COLORS.Yellow)
    field("Forca desejada para a previsao (nao para o treino)", 1000000, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 1 or n > 1e15 then return false, "Use um numero entre 1 e 1e15" end
        M.PlanningTarget = n
        return true, "Previsao atualizada"
    end)
    toggle("Esperar forca minima antes do rebirth", "O valor abaixo e um limite escolhido por voce, nao o requisito oficial do jogo.", "RebirthGuard")
    field("Forca minima para tentar rebirth", S.RebirthFloor, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 0 or n > 1e15 then return false, "Use de 0 a 1e15" end
        S.RebirthFloor = n; return true
    end)
    field("Intervalo entre tentativas de rebirth (segundos)", S.RebirthInterval, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < .5 or n > 30 then return false, "Use de 0.5 a 30 segundos" end
        S.RebirthInterval = n; return true
    end)
    card("Aplicar melhor treino medido", "Usa o resultado da ultima comparacao concluida. Desliga somente rotinas incompativeis com o treino escolhido.", function()
        local key = ({Ferramenta = "Train", Rajada = "TurboStrength", Maquina = "AutoMachine"})[M.BestTraining]
        if not key or M.Comparing then setHubStatus("Conclua uma comparacao valida primeiro"); return end
        if not (key == "AutoMachine" and canMachineFarm() or key ~= "AutoMachine" and canTrain()) then
            setHubStatus("O metodo medido nao esta disponivel agora"); return
        end
        if key == "AutoMachine" then selectBestMachine() end
        S[key] = true
        resolveToggleConflicts(key)
        renderAllToggles()
        setHubStatus("Treino aplicado: " .. M.BestTraining)
    end, COLORS.Green)
    toggle("Pausas programadas", "Conta apenas tempo ativo. Preserva suas opcoes e retoma depois do descanso; outras pausas continuam valendo.", "BreakEnabled")
    field("Descansar a cada quantos minutos ativos", S.BreakEvery, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 1 or n > 240 then return false, "Use de 1 a 240 minutos" end
        S.BreakEvery = n; M:resetBreak(); return true
    end)
    field("Duracao do descanso (minutos)", S.BreakMinutes, function(value)
        local n = tonumber(value)
        if not n or n ~= n or n < 1 or n > 60 then return false, "Use de 1 a 60 minutos" end
        S.BreakMinutes = n; M:resetBreak(); return true
    end)
    card("Terminar descanso atual", "Reinicia o contador de descanso. Nao remove pausa manual, respawn ou protecao de vida.", function()
        M:resetBreak()
        setHubStatus("Contador de descanso reiniciado")
    end, COLORS.Yellow)
    section("BONUS OFICIAIS", "Codigos e beneficios publicados na pagina do Muscle Legends.")
    for _, code in ipairs({"megalift50", "speedy50", "spacegems50", "ultimate250"}) do
        card("Codigo: " .. code, "Clique para copiar e resgate na tela de codigos do jogo. A validade depende do servidor.", function()
            local copied = type(setclipboard) == "function" and pcall(setclipboard, code)
            if copied then setHubStatus("Codigo copiado: " .. code) else showReport("Codigo para copiar", code) end
        end, COLORS.Yellow)
    end
    card("Como obter bonus oficiais", "Consulte os beneficios antes de escolher seu treino.", function()
        showReport("Bonus oficiais", "A pagina do jogo informa:\n\nPremium: 2x forca no treino, +2 giros diarios, 2x recompensas de bau e +1 espaco de pet.\nGrupo Scriptbloxian Studios: bau do grupo e +1 giro diario.\n\nO 710Hub nao compra beneficios nem altera multiplicadores. Confira a elegibilidade dentro do jogo.\nFonte: https://www.roblox.com/games/3623096087/Muscle-Legends\nConsultado em 27/09/2026.")
    end, COLORS.Yellow)
    section("HISTORICO E COMPATIBILIDADE", "Eventos recentes e recursos disponiveis nesta sessao.")
    card("Diagnostico da logo", "Confira se a imagem foi baixada e se o ambiente oferece imagens locais.", function()
        showReport("Logo neon", (M.LogoStatus or "Aguardando carregamento") .. "\nVersao: " .. SESSION.Version)
    end, COLORS.Yellow)
    card("Abrir historico da sessao", "Ganhos observados, mortes, pausas e ultimos 150 eventos.", function()
        showReport("Historico", M:report())
    end, COLORS.Green)
    card("Exportar historico", "Grava 710hub_historico.txt quando permitido. O relatorio tambem pode ser selecionado e copiado.", function()
        local report = M:report()
        if type(writefile) == "function" then
            local ok = pcall(writefile, "710hub_historico.txt", report)
            setHubStatus(ok and "Historico exportado" or "Falha ao gravar historico")
        end
        showReport("Historico", report)
    end, COLORS.Yellow)
    card("Verificar compatibilidade agora", "Inspeciona objetos e recursos; nao confirma que o servidor aceitara as acoes.", function()
        showReport("Compatibilidade", M:checkCompatibility())
    end, COLORS.Green)
    task.spawn(function()
        while SESSION.Alive do
            task.wait(.5)
            if not SESSION.Alive then break end
            stateTitle.Text = M.Comparing and "Comparando treinos" or ("Sessao: " .. M:reasonText())
            stateDesc.Text = M.Comparing and (M.ComparisonStatus or "Medindo...")
                or (M.Stalled and "ALERTA: farm sem progresso. Abra o diagnostico." or HubRuntime.Status)
            profileTitle.Text = "Perfil: slot " .. M.ProfileSlot
            pvpStatus.Text = M.PvpStatus or "Desligado"
            local interval, reps = M:farmPace()
            paceTitle.Text = string.format("%d reps por ciclo | intervalo %.0f ms", reps, interval * 1000)
            paceDesc.Text = (S.FarmCustom and "Personalizado" or "Preset")
                .. string.format(" | teto geral: %d chamadas/s | chamadas cortadas: %d", S.StabilityMode and 45 or 160, HubRuntime.SkippedRemoteCalls)
                .. "\nAplica-se a Forca Rapida e a rajada F2P. Modo Estavel pode reduzir os valores. Intervalos dependem dos frames; reps aceitas dependem do servidor."
            observedBossDesc.Text = M.VisibleBossText or "Procurando..."
            local rate = M:strengthRate()
            local target = M.PlanningTarget or 1000000
            local eta = M:eta(numberStat("Strength"), target)
            rateTitle.Text = rate and string.format("Forca recente: %.0f / minuto", rate) or "Rendimento: coletando amostras"
            local estimate = eta == 0 and "atingida" or (eta and string.format("aprox. %.1f min", eta / 60) or "aguardando ritmo de treino")
            rateDesc.Text = string.format("Meta: %.0f | %s", target, estimate)
            if M.BreakUntil then
                rateDesc.Text ..= string.format("\nDescanso: %.0fs restantes", math.max(0, M.BreakUntil - os.clock()))
            end
        end
    end)
end
maintenanceUI()
-- END MAINTENANCE UI

-- BEGIN EXTRA UI
-- Integrated into initializeUI, using the 710Hub controls on mouse and touch.
local function enhancementsUI()
    local X = HubRuntime.Extras
    local function modal(title)
        local old = main:FindFirstChild("710Hub_Choice")
        if old then old:Destroy() end
        local overlay = Instance.new("Frame")
        overlay.Name = "710Hub_Choice"; overlay.Size = UDim2.fromScale(1,1)
        overlay.BackgroundColor3 = COLORS.Black; overlay.BackgroundTransparency = .08
        overlay.BorderSizePixel = 0; overlay.ZIndex = 20; overlay.Active = true; overlay.Parent = main; addCorner(overlay,14)
        local heading = Instance.new("TextLabel")
        heading.Position = UDim2.fromOffset(16,12); heading.Size = UDim2.new(1,-86,0,44)
        heading.Text = title; heading.TextColor3 = COLORS.White; heading.TextSize = 16
        heading.Font = Enum.Font.GothamBold; heading.TextWrapped = true; heading.BackgroundTransparency = 1
        heading.ZIndex = 21; heading.Parent = overlay
        local close = Instance.new("TextButton")
        close.Size = UDim2.fromOffset(48,44); close.Position = UDim2.new(1,-62,0,12)
        close.Text = "×"; close.TextSize = 24; close.TextColor3 = COLORS.White
        close.BackgroundColor3 = COLORS.Panel2; close.ZIndex = 22; close.Parent = overlay; addCorner(close,8)
        close.Activated:Connect(function() overlay:Destroy() end)
        return overlay
    end
    local function report(title, text)
        local overlay = modal(title)
        local body = Instance.new("ScrollingFrame")
        body.Position = UDim2.fromOffset(16,70); body.Size = UDim2.new(1,-32,1,-86)
        body.AutomaticCanvasSize = Enum.AutomaticSize.Y; body.CanvasSize = UDim2.new()
        body.BackgroundTransparency = 1; body.BorderSizePixel = 0; body.ScrollBarThickness = 5
        body.ZIndex = 21; body.Parent = overlay
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1,-12,0,0); box.AutomaticSize = Enum.AutomaticSize.Y
        box.Text = text; box.MultiLine = true; box.ClearTextOnFocus = false; box.TextEditable = false
        box.TextSize = 14; box.Font = Enum.Font.Gotham; box.TextColor3 = COLORS.White
        box.TextWrapped = true; box.TextXAlignment = Enum.TextXAlignment.Left; box.TextYAlignment = Enum.TextYAlignment.Top
        box.BackgroundTransparency = 1; box.ZIndex = 22; box.Parent = body
    end
    local function choose(title, options, callback)
        local overlay = modal(title)
        local search = Instance.new("TextBox")
        search.Position = UDim2.fromOffset(16,64); search.Size = UDim2.new(1,-32,0,44)
        search.Text = ""; search.PlaceholderText = "Pesquisar opção..."; search.ClearTextOnFocus = false
        search.TextSize = 16; search.TextColor3 = COLORS.White; search.BackgroundColor3 = COLORS.Panel2
        search.ZIndex = 22; search.Parent = overlay; addCorner(search,8)
        local list = Instance.new("ScrollingFrame")
        list.Position = UDim2.fromOffset(16,116); list.Size = UDim2.new(1,-32,1,-132)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.CanvasSize = UDim2.new()
        list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.ScrollBarThickness = 5
        list.ZIndex = 21; list.Parent = overlay
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,6); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = list
        local rows = {}
        for index, option in ipairs(options) do
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1,-10,0,52); row.Text = option.Label; row.TextWrapped = true
            row.TextSize = 14; row.Font = Enum.Font.GothamMedium; row.TextColor3 = COLORS.White
            row.BackgroundColor3 = COLORS.Panel2; row.LayoutOrder = index; row.ZIndex = 22
            row.Parent = list; addCorner(row,8)
            rows[#rows+1] = {Object=row,Text=UI:normalize(option.Label)}
            row.Activated:Connect(function() overlay:Destroy(); callback(option.Value) end)
        end
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1,-10,0,52); empty.Text = "Nenhuma opção disponível"
        empty.TextColor3 = COLORS.Muted; empty.TextSize = 14; empty.TextWrapped = true
        empty.BackgroundTransparency = 1; empty.ZIndex = 22; empty.Parent = list
        local function filter()
            local count, query = 0, UI:normalize(search.Text)
            for _, row in ipairs(rows) do
                row.Object.Visible = string.find(row.Text,query,1,true) ~= nil
                if row.Object.Visible then count += 1 end
            end
            empty.Visible = count == 0; list.CanvasPosition = Vector2.new()
        end
        search:GetPropertyChangedSignal("Text"):Connect(filter); filter()
    end
    UI.Choose = choose
    local function numeric(title, key, low, high, integer)
        field(title,S[key],function(text)
            local value = tonumber((text:gsub(",",".")))
            if not value or value ~= value or value < low or value > high or (integer and value%1 ~= 0) then
                return false, string.format("Use %s a %s%s",low,high,integer and " (inteiro)" or "")
            end
            S[key] = value; return true
        end)
    end
    UI.Groups["PERSONAGEM E CAMERA"] = "Ajustes"
    UI.Groups["ROLETA E CONSUMIVEIS"] = "Farm"
    UI.Groups["JOGADORES E LISTAS"] = "PvP"
    UI.Groups["PETS POR ATRIBUTO E LOJA"] = "Pets"
    UI.Groups["PONTOS PESSOAIS"] = "Ajustes"
    section("PERSONAGEM E CAMERA", "Controles locais e solicitações limitadas; use toque ou clique.")
    numeric("Velocidade do personagem (1 a 500)","CharacterSpeed",1,500)
    toggle("Aplicar velocidade do personagem","Solicita changeSpeed a cada 2 segundos; o servidor valida o limite.","SetSpeed",function() return rEvents:FindFirstChild("changeSpeedSizeRemote") ~= nil end)
    numeric("Tamanho do personagem (1 a 100)","CharacterSize",1,100)
    toggle("Aplicar tamanho do personagem","Solicita changeSize no canal conhecido do jogo.","SetSize",function() return rEvents:FindFirstChild("changeSpeedSizeRemote") ~= nil end)
    numeric("Campo de visão (30 a 120)","CameraFOV",30,120)
    toggle("Aplicar campo de visão","Atualiza a câmera atual e restaura o valor anterior ao desligar.","SetFOV")
    toggle("Pulo contínuo","Pula ao pressionar o comando de salto, inclusive no botão de celular.","InfiniteJump")
    toggle("Proteção contra arremesso","Limita velocidades anormais; evita retornar a posições antigas durante combate.","AntiFling")
    toggle("Ocultar meu nome localmente","Oculta a identificação do seu Humanoid nesta tela.","HideName")
    toggle("Ocultar meus painéis de estatísticas","Oculta os BillboardGuis do seu personagem e restaura ao desligar.","HideStats")
    card("Iluminação: dia / noite / original","Escolha o horário visual local; o original é restaurado ao encerrar.",function()
        choose("Iluminação local",{{Label="Original",Value="Original"},{Label="Dia",Value="Dia"},{Label="Noite",Value="Noite"}},function(value) S.WorldTime=value end)
    end)

    section("ROLETA E CONSUMIVEIS", "Usa giros e itens já disponíveis na conta.")
    card("Girar roleta agora","Solicita um giro usando o catálogo carregado do jogo.",function() X:spin(); setHubStatus(X.Status) end,COLORS.Yellow,function() return X:fortuneCatalog() ~= nil and rEvents:FindFirstChild("openFortuneWheelRemote") ~= nil end)
    toggle("Roleta automática","Solicita no máximo um giro a cada 5 segundos; para se o jogo responder false.","AutoWheel",function() return X:fortuneCatalog() ~= nil and rEvents:FindFirstChild("openFortuneWheelRemote") ~= nil end)
    toggle("Consumir Protein Eggs","Usa somente ovos que você já possui; envia um item por vez.","AutoEggs")
    toggle("Consumir shakes e barras","Usa os consumíveis conhecidos do inventário, com intervalo por item.","AutoBoosts")
    local _, _, status = card("Estado das opções extras","Pronto",nil,COLORS.Yellow)
    task.spawn(function() while SESSION.Alive do status.Text=X.Status; task.wait(1) end end)

    section("JOGADORES E LISTAS", "Seleciona pela conta e atualiza a lista quando você abre o seletor.")
    card("Selecionar jogador","Lista pesquisável com nome de exibição e @usuário.",function()
        choose("Jogadores do servidor",X:playerOptions(),function(id) X.SelectedUserId=id; setHubStatus("Jogador selecionado") end)
    end)
    toggle("Observar jogador selecionado","Acompanha a câmera do jogador; restaura ao desligar ou se ele sair.","Spectate")
    toggle("Destacar jogadores visíveis","Contornos locais para personagens carregados, com remoção ao desligar.","PlayerESP")
    toggle("PvP: proteger amigos","Confere amizade fora do combate; ignora contas enquanto a consulta estiver pendente.","PvpProtectFriends")
    toggle("PvP: somente jogador selecionado","Restringe os modos de PvP ao UserId escolhido; não inicia o combate sozinho.","PvpOnlySelected")
    card("Proteger jogador selecionado","Adiciona a conta à lista de proteção do PvP desta sessão.",function()
        local player=X:selectedPlayer(); if player then X.Whitelist[player.UserId]=true; setHubStatus("Protegido: @"..player.Name) else setHubStatus("Selecione um jogador presente") end
    end)
    card("Remover proteção do jogador","Remove somente a conta selecionada da lista de proteção.",function() X.Whitelist[X.SelectedUserId]=nil end)
    card("Ver lista de proteção","Mostra os UserIds protegidos; a lista não depende do nome de exibição.",function()
        local lines={}; for id in pairs(X.Whitelist) do lines[#lines+1]=tostring(id) end; table.sort(lines)
        report("Proteção no PvP",#lines>0 and table.concat(lines,"\n") or "Lista vazia")
    end)
    card("Estatísticas do jogador selecionado","Mostra valores replicados e vida atual, sem estimar atributos invisíveis.",function()
        local player=X:selectedPlayer(); if not player then setHubStatus("Jogador ausente; escolha novamente"); return end
        local lines={"@"..player.Name.." | UserId: "..player.UserId}
        for _, name in ipairs({"Strength","Durability","Agility","Rebirths","goodKarma","evilKarma"}) do
            lines[#lines+1]=name..": "..tostring(M:playerKarma(player,{name}) or "indisponível")
        end
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        lines[#lines+1]=hum and string.format("Vida: %.0f / %.0f",hum.Health,hum.MaxHealth) or "Personagem ausente"
        report("Estatísticas replicadas",table.concat(lines,"\n"))
    end)

    section("PETS POR ATRIBUTO E LOJA", "Seleção por atributos observados; compras com quantidade limitada.")
    card("Atributo dos pets","Escolha força, durabilidade, agilidade ou dano; pets sem atributo legível são ignorados.",function()
        choose("Prioridade dos pets",{{Label="Força",Value="strength"},{Label="Durabilidade / vida",Value="durability"},{Label="Agilidade",Value="agility"},{Label="Dano",Value="damage"}},function(value) X.PetObjective=value; setHubStatus("Prioridade: "..value) end)
    end)
    card("Equipar pets pelo atributo","Usa os slots detectados e preserva os pets que já estão corretos.",function() X:equipObjective() end,COLORS.Green,canPetManager)
    toggle("Atualizar pets pelo atributo","Reavalia a cada 10 segundos; ativa Preservar meus pets no F2P para manter sua prioridade.","AutoBestPetObjective",canPetManager)
    toggle("Evoluir pets prontos continuamente","Usa a evolução existente do 710Hub a cada 5 segundos, mesmo sem abrir cristais.","AutoEvolveOwned",function() return R.EvolvePet ~= nil end)
    card("Selecionar pet ou aura da loja","Catálogo pesquisável; auras são identificadas por IsPowerUp.",function()
        choose("Catálogo atual",X:shopOptions(),function(name) X.ShopName=name; setHubStatus("Selecionado: "..name) end)
    end,COLORS.Yellow,canPetShop)
    numeric("Quantidade de compras (1 a 20)","ShopCount",1,20,true)
    card("Comprar lote selecionado","Gasta a moeda exigida pelo jogo. Envia uma compra por vez; Parar tudo cancela as restantes.",function() X:buyBatch() end,COLORS.Yellow,canPetShop)
    card("Ver coleção de pets","Mostra os atributos replicados dos pets que você possui.",function()
        local lines={}
        for _, entry in ipairs(allOwnedPets()) do
            lines[#lines+1]=string.format("%s [%s] | força=%s | durabilidade=%s | agilidade=%s | dano=%s",entry.pet.Name,entry.rarity,
                tostring(X:petScore(entry,"strength") or "?"),tostring(X:petScore(entry,"durability") or "?"),tostring(X:petScore(entry,"agility") or "?"),tostring(X:petScore(entry,"damage") or "?"))
        end
        report("Pets possuídos",#lines>0 and table.concat(lines,"\n") or "Nenhum pet carregado")
    end)
    section("PONTOS PESSOAIS", "Guarda um ponto da sessão atual.")
    card("Ilhas e academias conhecidas","Escolha uma referência do Silence; carrega a região e verifica piso antes de mover.",function()
        choose("Ilhas e academias",{
            {Label="Tiny Island",Value=CFrame.new(-37.1,9.2,1919)},
            {Label="Main Island",Value=CFrame.new(16.07,9.08,133.8)},
            {Label="Beach",Value=CFrame.new(-8,9,-169.2)},
            {Label="Overcharged Gym",Value=CFrame.new(-2941.766,151.797,4994.552)},
            {Label="Industrial Gym",Value=CFrame.new(-5254.681641,58.342850,4931.850586)},
            {Label="Jungle Gym",Value=CFrame.new(-8543,6.8,2400)},
            {Label="Muscle King Gym",Value=CFrame.new(-8665.4,17.21,-5792.9)},
            {Label="Legends Gym",Value=CFrame.new(4516,991.5,-3856)},
            {Label="Infernal Gym",Value=CFrame.new(-6759,7.36,-1284)},
            {Label="Mythical Gym",Value=CFrame.new(2250,7.37,1073.2)},
            {Label="Frost Gym",Value=CFrame.new(-2623,7.36,-409)},
        },function(frame) task.spawn(function() X:travel(frame) end) end)
    end)
    card("Salvar posição atual","Guarda o CFrame para voltar depois; não altera o perfil de farm.",function()
        local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then X.ReturnPoint=root.CFrame; setHubStatus("Posição salva nesta sessão") end
    end)
    card("Voltar à posição salva","Pausa as automações antes de mover o personagem; use Retomar para continuar.",function()
        local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root or not X.ReturnPoint then setHubStatus("Salve uma posição primeiro"); return end
        X:travel(X.ReturnPoint)
    end)
end
enhancementsUI()
-- END EXTRA UI

-- BEGIN SOURCE BRIDGE
-- Source compatibility layer. Sources are pinned locally by build_sources.py.
-- UI libraries are replaced with 710Hub controls; no loader/key system runs.
local function initializeSourceBridge()
    local B={Engines={},Catalog={},Epoch=0,Jobs=setmetatable({}, {__mode="k"}),Alive=true,Reports={},Stopping=false}
    HubRuntime.SourceBridge=B
    local CANCEL="710Hub: source task cancelled"
    local nativeTypeof=typeof
    local compileSource=loadstring
    local setSourceEnvironment=setfenv
    local instanceNew=Instance.new
    local nativeEnvironment=getfenv()
    local proxyToNative=setmetatable({}, {__mode="k"})
    local nativeToProxy=setmetatable({}, {__mode="k"})
    local overrides={
        ["Anti Rebirth"]="rebirth",
        ["Infinite Yield"]="external",
        ["All Emotes"]="external",
    }
    local externalURLs={
        ["Infinite Yield"]="https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
        ["All Emotes"]="https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua",
    }
    function B:report(engine,message)
        engine.Status=tostring(message)
        self.Reports[#self.Reports+1]=engine.Name..": "..engine.Status
        if #self.Reports>60 then table.remove(self.Reports,1) end
        setHubStatus(engine.Name..": "..engine.Status)
    end
    local function currentJob() return B.Jobs[coroutine.running()] end
    local function unwrap(value)
        return proxyToNative[value] or value
    end
    local function arguments(...)
        local args=table.pack(...)
        for index=1,args.n do args[index]=unwrap(args[index]) end
        return args
    end
    function B:active(engine)
        if not self.Alive or not SESSION.Alive then return false end
        local job=currentJob()
        if job and job.Cleanup then return true end
        if engine.Building then return false end
        if not M:canAct() or M.Comparing then return false end
        if job and job.Key then return S[job.Key]==true and job.Epoch==self.Epoch end
        for _,control in ipairs(engine.Controls) do
            if control.Kind=="Toggle" and S[control.Key] then return true end
        end
        return job and not job.Baseline and job.Action==true and job.Epoch==self.Epoch
    end
    function B:remember(engine,object,key)
        if key=="CFrame" or key=="Position" or key=="AssemblyLinearVelocity" or key=="AssemblyAngularVelocity" then return end
        local saved=engine.Saved[object]
        if not saved then saved={}; engine.Saved[object]=saved end
        if saved[key]==nil then
            local ok,value=pcall(function() return object[key] end)
            if ok then saved[key]={Value=value} end
        end
    end
    function B:restore(engine)
        for object,keys in pairs(engine.Saved) do
            for key,saved in pairs(keys) do pcall(function() object[key]=saved.Value end) end
        end
        table.clear(engine.Saved)
        for object in pairs(engine.Created) do pcall(function() object:Destroy() end) end
        table.clear(engine.Created)
    end
    function B:run(engine,fn,key,cleanup,...)
        if type(fn)~="function" then return false end
        local thread=coroutine.running()
        local prior=self.Jobs[thread]
        self.Jobs[thread]={Engine=engine,Key=key,Action=key==nil,Epoch=self.Epoch,Generation=engine.Generation,
            Baseline=engine.BaselineFunctions and engine.BaselineFunctions[fn]==true,Cleanup=cleanup}
        local args=table.pack(...)
        local ok,result=pcall(function() return fn(table.unpack(args,1,args.n)) end)
        self.Jobs[thread]=prior
        if not ok and not tostring(result):find(CANCEL,1,true) then
            self:report(engine,"Falha: "..tostring(result))
            return false,result
        end
        return ok,result
    end
    local wrap
    wrap=function(engine,value)
        if nativeTypeof(value)=="Instance" then
            engine.Proxies=engine.Proxies or setmetatable({}, {__mode="k"})
            if engine.Proxies[value] then return engine.Proxies[value] end
            local proxy={}
            proxyToNative[proxy]=value; nativeToProxy[value]=proxy; engine.Proxies[value]=proxy
            return setmetatable(proxy,{
                __tostring=function() return tostring(value) end,
                __index=function(_,key)
                    if key=="HttpGet" and value==game then
                        return function(_,url)
                            if url:find("elerium",1,true) or url:find("/WindUI",1,true) then return "710HUB_UI_ADAPTER" end
                            if url:match("^https://games%.roblox%.com/v1/games/%d+/servers/Public%?") then
                                if not B:active(engine) then return '{"data":[]}' end
                                return game:HttpGet(url)
                            end
                            error("Dependência externa não incorporada: "..tostring(url))
                        end
                    end
                    local actual=value[key]
                    if type(actual)=="function" then
                        return function(_,...)
                            local args=arguments(...)
                            if key=="WaitForChild" then
                                args[2]=math.min(tonumber(args[2]) or 5,20); args.n=2
                            end
                            if key=="FireServer" or key=="InvokeServer" then
                                if not B:active(engine) then return nil end
                                if S.BlockAllRebirths and value.Name=="rebirthRemote" then return false end
                                if key=="FireServer" then return safeFire(value,table.unpack(args,1,args.n)) end
                                return safeInvoke(value,table.unpack(args,1,args.n))
                            end
                            if key=="Destroy" or key=="Remove" then
                                if engine.Created[value] then value:Destroy(); engine.Created[value]=nil; return end
                                if not B:active(engine) then return end
                                B:remember(engine,value,"Parent"); value.Parent=nil; return
                            end
                            if key=="Activate" or key=="EquipTool" or key=="MoveTo" or key=="Move"
                                or key=="PivotTo" or key=="ChangeState" or key:find("Teleport",1,true) then
                                if not B:active(engine) then return end
                            end
                            local out=table.pack(actual(value,table.unpack(args,1,args.n)))
                            for index=1,out.n do
                                if type(out[index])=="table" and nativeTypeof(out[index])~="Instance" then
                                    local copy={}
                                    for k,item in pairs(out[index]) do copy[k]=wrap(engine,item) end
                                    out[index]=copy
                                else out[index]=wrap(engine,out[index]) end
                            end
                            return table.unpack(out,1,out.n)
                        end
                    end
                    if nativeTypeof(actual)=="RBXScriptSignal" or (type(actual)=="table" and type(actual.Connect)=="function") then
                        return {
                            Connect=function(_,fn)
                                local connection=actual:Connect(function(...)
                                    if not SESSION.Alive or not B.Alive then return end
                                    if not B:active(engine) and key~="CharacterAdded" then return end
                                    local args=table.pack(...)
                                    for index=1,args.n do args[index]=wrap(engine,args[index]) end
                                    B:run(engine,fn,nil,false,table.unpack(args,1,args.n))
                                end)
                                engine.Connections[#engine.Connections+1]=connection
                                return trackConnection(connection)
                            end,
                            Wait=function() error("Aguarde pelo controlador de sessão do 710Hub") end,
                        }
                    end
                    return wrap(engine,actual)
                end,
                __newindex=function(_,key,item)
                    if not B:active(engine) and not engine.Created[value] then return end
                    B:remember(engine,value,key)
                    value[key]=unwrap(item)
                end,
            })
        end
        return value
    end
    function B:environment(engine,library)
        local env={}
        for _,key in ipairs({"assert","error","pairs","ipairs","next","select","tostring","tonumber","type",
            "pcall","xpcall","setmetatable","getmetatable","unpack","table","math","string","bit32","coroutine","utf8","os",
            "Vector2","Vector3","CFrame","UDim","UDim2","Color3","ColorSequence","ColorSequenceKeypoint",
            "NumberSequence","NumberSequenceKeypoint","Enum","TweenInfo","RaycastParams","DateTime","tick","time"}) do env[key]=nativeEnvironment[key] end
        env.game=wrap(engine,game); env.workspace=wrap(engine,workspace)
        env.Vector2=Vector2; env.Vector3=Vector3; env.CFrame=CFrame; env.UDim=UDim; env.UDim2=UDim2
        env.Color3=Color3; env.ColorSequence=ColorSequence; env.Enum=Enum; env.TweenInfo=TweenInfo
        env.RaycastParams=RaycastParams
        env.tick=env.tick or os.clock; env.time=env.time or os.clock
        env._G=env; env.getgenv=function() return env end; env.getfenv=function() return env end
        env.typeof=function(value) return nativeTypeof(unwrap(value)) end
        env.gethui=function() return wrap(engine,gui.Parent) end
        env.settings=function() return settings() end
        env.print=function() end; env.warn=function(message) B:report(engine,message) end
        env.identifyexecutor=identifyexecutor or function() return "710Hub" end
        env.setclipboard=setclipboard
        env.require=function(module) return require(unwrap(module)) end
        local function sourcePath(path)
            local name=tostring(path):gsub("\\","/"):match("([^/]+)$") or "config.json"
            name=name:gsub("[^%w_.%-]","_")
            assert(name~="." and name~="..","Nome de arquivo inválido")
            return "710hub_sources/"..engine.Id.."_"..name
        end
        env.isfile=function(path) return type(isfile)=="function" and isfile(sourcePath(path)) end
        env.isfolder=function() return type(isfolder)=="function" and isfolder("710hub_sources") end
        env.makefolder=function()
            if type(makefolder)=="function" and not env.isfolder() then pcall(makefolder,"710hub_sources") end
        end
        env.writefile=type(writefile)=="function" and function(path,body)
            if not SESSION.Alive or not B.Alive then return end
            env.makefolder(); return writefile(sourcePath(path),body)
        end or nil
        env.readfile=type(readfile)=="function" and function(path) return readfile(sourcePath(path)) end or nil
        env.loadstring=function(data)
            assert(data=="710HUB_UI_ADAPTER","A biblioteca auxiliar precisa ser incorporada e verificada")
            return function() return library end
        end
        env.Instance={new=function(class,parent)
            local object=instanceNew(class,unwrap(parent)); engine.Created[object]=true
            return wrap(engine,object)
        end}
        env.firetouchinterest=type(firetouchinterest)=="function" and function(a,b,state)
            if B:active(engine) then return firetouchinterest(unwrap(a),unwrap(b),state) end
        end or nil
        env.fireproximityprompt=type(fireproximityprompt)=="function" and function(prompt,...)
            if B:active(engine) then return fireproximityprompt(unwrap(prompt),...) end
        end or nil
        env.fireclickdetector=type(fireclickdetector)=="function" and function(detector,...)
            if B:active(engine) then return fireclickdetector(unwrap(detector),...) end
        end or nil
        local sourceTask={}
        function sourceTask.wait(delay)
            if engine.Building then return 0 end
            local job=currentJob()
            if job and job.Baseline then job.Epoch=B.Epoch end
            if job and not job.Cleanup and (job.Epoch~=B.Epoch or job.Generation~=engine.Generation or job.Key and not S[job.Key]) then error(CANCEL,0) end
            if not SESSION.Alive or not B.Alive then error(CANCEL,0) end
            local elapsed=task.wait(math.max(.05,tonumber(delay) or .05))
            while not B:active(engine) and not (job and job.Cleanup) do
                if job and job.Baseline then job.Epoch=B.Epoch end
                if not SESSION.Alive or not B.Alive or job and (job.Epoch~=B.Epoch or job.Generation~=engine.Generation) then error(CANCEL,0) end
                task.wait(.5)
            end
            if job and not job.Cleanup and (job.Epoch~=B.Epoch or job.Key and not S[job.Key]) then error(CANCEL,0) end
            return elapsed
        end
        function sourceTask.spawn(fn,...)
            local args=table.pack(...)
            local owner=currentJob()
            local key=owner and owner.Key
            local epoch=B.Epoch
            local baseline=engine.Building
            if baseline then
                engine.BaselineFunctions=engine.BaselineFunctions or setmetatable({}, {__mode="k"})
                engine.BaselineFunctions[fn]=true
            end
            local generation=engine.Generation
            return task.spawn(function()
                while engine.Building do task.wait(.05) end
                if not SESSION.Alive or not B.Alive or generation~=engine.Generation or not baseline and epoch~=B.Epoch then return end
                if baseline then
                    while not B:active(engine) do
                        if not SESSION.Alive or not B.Alive or generation~=engine.Generation then return end
                        task.wait(.5)
                    end
                end
                B:run(engine,fn,key,false,table.unpack(args,1,args.n))
            end)
        end
        sourceTask.defer=sourceTask.spawn
        function sourceTask.delay(delay,fn,...)
            local args=table.pack(...); local epoch=B.Epoch
            return task.delay(delay,function() if epoch==B.Epoch and SESSION.Alive then sourceTask.spawn(fn,table.unpack(args,1,args.n)) end end)
        end
        sourceTask.cancel=task.cancel
        env.task=sourceTask; env.wait=sourceTask.wait; env.spawn=sourceTask.spawn; env.delay=sourceTask.delay
        return env
    end
    function B:owner(control)
        local text=string.lower(control.Title)
        if control.Kind~="Toggle" then return false end
        for _,word in ipairs({"auto farm","auto use tool","auto tool","auto king","auto strength","fast rep","fast rebirth",
            "autokill","kill everyone","kill list","kill trd","kill thereal","kill 44","kill empi","kill slh","kill kta",
            "matar blacklist","death ring","attack boss","auto boss","auto win brawl"}) do
            if text:find(word,1,true) then return true end
        end
        return text=="start" or text=="start exercising" or text=="auto rock" or text=="auto squat" or text=="auto lift"
    end
    function B:invoke(control,...)
        local args=table.pack(...)
        local desired=control.Kind=="Toggle" and S[control.Key]
        local engine=control.Engine
        if overrides[control.Title]=="external" then
            local epoch=self.Epoch
            local ok,result=pcall(function()
                assert(type(compileSource)=="function","Executor sem loadstring")
                local body=game:HttpGet(assert(externalURLs[control.Title]))
                if not SESSION.Alive or not self.Alive or epoch~=self.Epoch then error(CANCEL,0) end
                local fn,err=compileSource(body,"710Hub-tool-"..control.Title)
                assert(fn,err)
                return fn()
            end)
            self:report(engine,ok and (control.Title.." aberto na interface própria") or ("Ferramenta externa: "..tostring(result)))
            return ok,result
        end
        if not engine.Ready and not self:boot(engine) then S[control.Key]=false; return false end
        if control.Kind=="Toggle" then S[control.Key]=desired end
        if self:owner(control) and desired then
            self.Activating=true; stopAllAutomations(); self.Activating=false
            S[control.Key]=true
            for _,other in ipairs(self.Catalog) do
                if other~=control and self:owner(other) and other.Value then self:set(other,false) end
            end
        end
        if overrides[control.Title]=="rebirth" then
            S.BlockAllRebirths=true; S.Rebirth=false; S.StrengthRebirth=false
            self:report(engine,"Rebirth bloqueado para as rotinas integradas; reversível no menu")
            return true
        end
        local widget=engine.Widgets[control.Index]
        if not widget or not widget.Callback then self:report(engine,"Controle sem callback disponível"); return false end
        control.Value=desired
        local ok,err=self:run(engine,widget.Callback,control.Kind=="Toggle" and control.Key or nil,
            control.Kind=="Toggle" and not desired,table.unpack(args,1,args.n))
        if not ok then S[control.Key]=false end
        return ok,err
    end
    function B:set(control,value)
        control.Value=value
        if control.Kind=="Toggle" then S[control.Key]=value==true end
        local widget=control.Engine.Widgets[control.Index]
        if widget and widget.Callback then return self:run(control.Engine,widget.Callback,nil,value==false,value) end
    end
    function B:stop()
        if self.Stopping or self.Activating then return end
        self.Stopping=true; self.Epoch+=1
        local stopEpoch=self.Epoch
        for _,control in ipairs(self.Catalog) do
            if control.Kind=="Toggle" and (control.Value or S[control.Key]) then
                control.Value=false; S[control.Key]=false
                local widget=control.Engine.Widgets[control.Index]
                if widget and widget.Callback then
                    task.spawn(function()
                        if self.Epoch~=stopEpoch or S[control.Key] then return end
                        self:run(control.Engine,widget.Callback,nil,true,false)
                        local any=false
                        for _,item in ipairs(control.Engine.Controls) do if item.Kind=="Toggle" and S[item.Key] then any=true end end
                        if self.Epoch==stopEpoch and not any then self:restore(control.Engine) end
                    end)
                end
            end
        end
        for _,engine in ipairs(self.Engines) do self:restore(engine) end
        self.Stopping=false
    end
    function B:sync()
        if self.Syncing then return end
        self.Syncing=true
        for _,control in ipairs(self.Catalog) do
            if control.Kind=="Toggle" and control.Value and not S[control.Key] then self:set(control,false) end
        end
        self.Syncing=false
    end
    function B:cleanup()
        self:stop(); self.Alive=false
        for _,engine in ipairs(self.Engines) do
            for _,connection in ipairs(engine.Connections) do pcall(function() connection:Disconnect() end) end
            self:restore(engine)
        end
    end
    function B:library(engine)
        local methods={}
        local meta={
            __index=function(self,key)
                if key=="Text" then return self._Text or self.Title or "" end
                if key=="Parent" then return true end
                return methods[key]
            end,
            __newindex=function(self,key,value)
                if key=="Text" then
                    rawset(self,"_Text",tostring(value))
                    if self.Control and self.Control.DescLabel then self.Control.DescLabel.Text=tostring(value) end
                else rawset(self,key,value) end
            end,
        }
        local function widget(path)
            return setmetatable({Path=path,Config={},Values={}},meta)
        end
        local function control(parent,kind,title,callback,config)
            local result=widget(parent.Path.."/"..title)
            result.Kind=kind; result.Callback=callback; result.Config=config or {}; result.Title=title
            result.OnText={Visible=false,Parent=true}; result.Button={Parent=true}
            result.Values=result.Config.Values or {}
            engine.Widgets[#engine.Widgets+1]=result
            local item=engine.Controls[#engine.Widgets]
            result.Control=item
            return result
        end
        function methods:AddWindow() return widget(engine.Name) end
        methods.CreateWindow=methods.AddWindow
        function methods:AddTab(title) return widget(self.Path.."/"..title) end
        function methods:Tab(config) return self:AddTab(config.Title) end
        function methods:Section(config) return widget(self.Path.."/"..(type(config)=="table" and config.Title or tostring(config))) end
        function methods:AddLabel(title) return control(self,"Paragraph",title,nil) end
        function methods:AddSwitch(title,callback) return control(self,"Toggle",title,callback) end
        function methods:AddButton(title,callback) return control(self,"Button",title,callback) end
        function methods:AddTextBox(title,callback,config) return control(self,"Input",title,callback,config) end
        function methods:AddDropdown(title,callback) return control(self,"Dropdown",title,callback) end
        for _,kind in ipairs({"Toggle","Button","Dropdown","Slider","Input","Paragraph"}) do
            methods[kind]=function(self,config) return control(self,kind,config.Title or "",config.Callback,config) end
        end
        function methods:Add(value) self.Values[#self.Values+1]=value end
        function methods:Clear() self.Values={} end
        function methods:Remove(value) local index=table.find(self.Values,value); if index then table.remove(self.Values,index) end end
        function methods:Set(value)
            if self.Control and self.Kind=="Toggle" then
                if engine.Building then return end
                S[self.Control.Key]=value==true; self.Control.Value=value==true
            end
            if self.OnText then self.OnText.Visible=value==true end
            if self.Callback and not engine.Building then return self.Callback(value) end
        end
        methods.SetValue=methods.Set; methods.Select=methods.Set
        function methods:SetTitle(title) if self.Control and self.Control.TitleLabel then self.Control.TitleLabel.Text=engine.Name..": "..title end end
        function methods:SetDesc(desc) if self.Control and self.Control.DescLabel then self.Control.DescLabel.Text=desc end end
        function methods:Edit(config) if config.Title then self:SetTitle(config.Title) end; if config.Desc then self:SetDesc(config.Desc) end end
        function methods:Refresh(values) self.Values=values or {} end
        function methods:Notify(config) B:report(engine,type(config)=="table" and (config.Content or config.Title) or config) end
        function methods:Show() end
        function methods:Destroy() end
        function methods:Divider() end
        function methods:SetTheme() end
        function methods:CreateTheme() end
        function methods:SetTransparency() end
        function methods:Close() end
        function methods:Open() end
        return widget(engine.Name)
    end
    function B:boot(engine)
        if engine.Ready then return true end
        if engine.Building then self:report(engine,"Inicialização em andamento"); return false end
        if type(compileSource)~="function" or type(setSourceEnvironment)~="function" then
            self:report(engine,"O executor precisa de loadstring e setfenv"); return false
        end
        for _,connection in ipairs(engine.Connections) do pcall(function() connection:Disconnect() end) end
        table.clear(engine.Connections); self:restore(engine)
        engine.Generation=(engine.Generation or 0)+1
        engine.Building=true; engine.Widgets={}
        local fn,err=compileSource(engine.Source,"710Hub-"..engine.Name)
        if not fn then engine.Building=false; self:report(engine,err); return false end
        engine.Environment=self:environment(engine,self:library(engine))
        setSourceEnvironment(fn,engine.Environment)
        local ok,result=pcall(fn)
        engine.Building=false
        engine.Ready=ok
        if not ok then engine.Generation+=1; self:report(engine,"Dependência de inicialização: "..tostring(result)); return false end
        if #engine.Widgets~=#engine.Controls then
            engine.Ready=false
            self:report(engine,"Catálogo mudou: "..#engine.Widgets.." controles; esperado "..#engine.Controls)
            return false
        end
        for index,widget in ipairs(engine.Widgets) do
            local expected=engine.Controls[index]
            if widget.Kind~=expected.Kind or widget.Title~=expected.Title then
                -- Empty labels are populated later; all interactive identities are checked.
                if widget.Kind~="Paragraph" then engine.Ready=false; self:report(engine,"Controle divergente: "..widget.Title); return false end
            end
        end
        self:report(engine,"Todas as rotinas carregadas: "..#engine.Controls.." controles")
        return true
    end
--[====[
Third-party notice: Silence modules
MIT License

Copyright (c) 2026 xyzhenrik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]====]
B.Engines[#B.Engines+1]={Name=[====[
Mystery]====],Id=[====[
mystery]====],Source=[====[
return({function(B)local u,d_,c_,n_,f,y,m,s_,o,j,e,v,w,h_,l,q,r,g,x,A,k,C_,t_,i,z v=B v={[0b11]=0b10,[0b10]=v}v[1]=v j=B._[B.O[0x47c3]or B:P(B.q")!fm*",B.q"rJ(",0x47c3)]j={[0b11]=0b10,[0b10]=j}j[1]=j C_=B._[B.O[-0x1ffa]or B:P(B.q"O~72wQ2",B.q"qdf",-0x1ffa)]C_={[0b11]=0b10,[0b10]=C_}C_[1]=C_ w=B._[B.O[-0x9d7]or B:P(B.q")QQ8C!v",B.q"`>_",-0x9d7)]w={[0b11]=0b10,[0b10]=w}w[1]=w z=B._[B.O[-0xaea]or B:P(B.q"dt%V=VsG2`",B.q"g}x0B",-0xaea)]z={[0b11]=0b10,[0b10]=z}z[1]=z e=B._[B.O[-0x19e9]or B:P(B.q"tRuBBuK",B.q"Lfi",-0x19e9)]e={[0b11]=0b10,[0b10]=e}e[1]=e q=B._[B.O[-0x14ae]or B:P(B.q"A~b|FGMo",B.q"=uuG",-0x14ae)]q={[0b11]=0b10,[0b10]=q}q[1]=q c_=B._[B.O[0x3a54]or B:P(B.q"ZHv6xHw1s0sntFe",B.q"a8kF(?j8",0x3a54)]c_={[0b11]=0b10,[0b10]=c_}c_[1]=c_ t_=B._[B.O[-0x5a12]or B:P(B.q"Tl!o^Qk-4uNl9Cc",B.q"=r=1UpF9",-0x5a12)]t_={[0b11]=0b10,[0b10]=t_}t_[1]=t_ l,h_=B.O[-0x679b]or B:P(B.q"?CA",B.q"ng",-0x679b),{}h_[B.O[-0x40cb]or B:P(B.q"-AM-Rat;",B.q"YZih",-0x40cb)]=l n_=h_ n_={[0b11]=0b10,[0b10]=n_}n_[1]=n_ l=B._[B.O[-0x6861]or B:P(B.q";w3=%KUD",B.q"GEtE",-0x6861)]h_=l[B.O[0x1269]or B:P(B.q"CBD5ev!(",B.q"&CpN",0x1269)]h_={[0b11]=0b10,[0b10]=h_}h_[1]=h_ f=l l=f[B.O[-0x352a]or B:P(B.q"?78}-",B.q"z>W",-0x352a)]l={[0b11]=0b10,[0b10]=l}l[1]=l i=f f,s_=i[B.O[-0x58e]or B:P(B.q"9zh&i",B.q"DSZ",-0x58e)],i i=s_[B.O[0x5e12]or B:P(B.q"q%c&sK3x",B.q"HC@9",0x5e12)]i={[0b11]=0b10,[0b10]=i}i[1]=i y=B._[B.O[0x3536]or B:P(B.q"l~jXSga",B.q"HQ@",0x3536)]s_=y[B.O[0x175a]or B:P(B.q"w^^)H",B.q"Hrf",0x175a)]s_={[0b11]=0b10,[0b10]=s_}s_[1]=s_ r=y y=r[B.O[0x5b85]or B:P(B.q"g4L1V",B.q"wDJ",0x5b85)]y={[0b11]=0b10,[0b10]=y}y[1]=y g=r r=g[B.O[0x36ce]or B:P(B.q"r^{8P%~b",B.q"FuBA",0x36ce)]r={[0b11]=0b10,[0b10]=r}r[1]=r m=g g=m[B.O[0x368e]or B:P(B.q")wLYisT%",B.q"Z`-^",0x368e)]g={[0b11]=0b10,[0b10]=g}g[1]=g x=B._[B.O[-0x3b20]or B:P(B.q"v81Q|;Q",B.q"&C>",-0x3b20)]m=x[B.O[0x7d94]or B:P(B.q"#>>_",B.q"qy",0x7d94)]m={[0b11]=0b10,[0b10]=m}m[1]=m o=x x,A=o[B.O[-0xe31]or B:P(B.q"=y2tF",B.q"2#N",-0xe31)],o o=A[B.O[0x3c42]or B:P(B.q";&SeH",B.q"6Mz",0x3c42)]o={[0b11]=0b10,[0b10]=o}o[1]=o u=A A=u[B.O[-0x2201]or B:P(B.q"?~Le+`2",B.q"_>B",-0x2201)]A={[0b11]=0b10,[0b10]=A}A[1]=A k=u u=k[B.O[0x141c]or B:P(B.q"r~#y{6u1",B.q"%yPs",0x141c)]u={[0b11]=0b10,[0b10]=u}u[1]=u k={[0b11]=0b10,[0b10]=k}k[1]=k k[1][k[0b11]]=B:H{h_,m,r,o,v,u,A,g}d_=B:G{k,C_,o,c_,z,y,e,t_,j,r,l,w,i,n_,q,s_}return d_ end,function(a_,b_)return function(...)local d_,o,e,k,g,m,n_,h_,_,i,j,c_ i=0x6a repeat if i<0x75 then if i<0x58 then if i>=0x32 then if i<=0b110010 then i,d_=0x1b26/i,d_(a_.i(j))_,j=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]]_=_[0x810f]else m=a_.h(m(c_,g))return a_.i(m)end else m,g,i,c_,e=o,k,i+0b1101011,0b10,b_[0b1000][1][b_[0b1000][0b11]]end elseif i<=0b1101010 then if i<=0x58 then o,k=o(a_.i(k))e=o[1]i=e and 0b10101 or 0b100101111-i else i,j,d_=0b110010,a_.h(...),b_[1][1][b_[1][0b11]]end else e=b_[0b110][1][b_[0b110][0b11]]k,e=e[0x7846],1 e,o,c_=d_.n,k+e,b_[0b110][1][b_[0b110][0b11]]m=c_[0x7846]i,k=0xa3,e-m _[0x78d]=k e,c_,m,n_,h_=b_[0b100][1][b_[0b100][0b11]],o,d_,o+k,1 n_,g,h_=h_,n_-h_,_[0xb505]end elseif i<=0x92 then if i>=0b10001011 then if i>0b10001011 then o(k,e,m,c_,g)k=b_[0b110][1][b_[0b110][0b11]]k,o=d_.n,k[0x7846]i=o<k and 0x72 or 0x6584/i else j=j(_)o,e={},{}k=e o[0xb505]=k k=0 o[0x78d]=k e,c_,o,k,i,_=1,b_[0b110][1][b_[0b110][0b11]],b_[0b100][1][b_[0b100][0b11]],d_,0b10010010,o c_,m,g=e,c_[0x7846],j end elseif i<=0x75 then i,k=0x2838/i,a_.h(k(e,m,c_))else e=a_.h(e(m,c_,g))return a_.i(e)end elseif i<=0b10110010 then if i>0b10100011 then m,e,o,c_,i,k=j,b_[0b101][1][b_[0b101][0b11]],b_[0b111][1][b_[0b111][0b11]],_,0b1110101,b_[0b1001][1][b_[0b1001][0b11]]else i=i+0b1111 e(m,c_,g,n_,h_)end else e,m=o[0b10],b_[0b11][1][b_[0b11][0b11]]i,c_,g=0b100101010-i,e,0 end until false end end,function(a_,b_)return function(d_)local e,f,j,_,c_,h_,i,k i=0xb5 repeat if i<=0b10001011 then if i>=0x77 then if i>0b1110111 then i=e and 0xc7d/i or 0x14 else k,_=0b101,"~"_,i,k,f=_.rep,0b10010100,k-j,_ _=_(f,k)d_=d_.._ end elseif i<=0b10100 then i,e=0x17,-1 else f,_=_,_.sub _=a_.h(_(f,k,e))return a_.i(_)end elseif i<=0xb5 then if i<=0x94 then _,f,e,k=b_[1][1][b_[1][0b11]],d_,a_:s{b_[0b10],b_[0b11],b_[0b100]},"....."_=_(f,k,e)e,k=0,1 e=j>e i=e and 0xd6 or i+-0b1001 else f,_=0b101,#d_ j,_=_%f,0 i=j>_ and 0b1110111 or 0b10010100 end else i,c_=0x7432/i,0b101 h_=c_-j e,h_=-h_,1 e=e-h_ end until false end end,function(a_,b_,c_,d_,e)a_.O[e]=a_.a(a_.d(a_.a(a_.c(b_,0xa145),0xffff)),a_.a(d_,0xffff))*a_.a(a_.d(a_.a(0xffff,d_)),a_.a(0xffff,a_.c(b_,0xa145)))+a_.b(a_.a(a_.c(b_,0xa145),0xffff),a_.a(0xffff,d_))*a_.a(a_.a(d_,0xffff),a_.a(0xffff,a_.c(b_,0xa145)))-a_.a(0xffff,a_.c(b_,0xa145))*a_.a(0xffff,d_)+a_.d(a_.a(a_.d(a_.c(b_,0xa145)),a_.d(a_.a(d_+c_,4294967295))))return a_.O[e]end,function(a_,b_)return function(d_,j)local g,e,f,_ d_={[0b11]=0b10,[0b10]=d_}d_[1]=d_ j={[0b11]=0b10,[0b10]=j}j[1]=j _=a_:J{b_[1]}_={[0b11]=0b10,[0b10]=_}_[1]=_ f=nil f={[0b11]=0b10,[0b10]=f}f[1]=f f[1][f[0b11]]=a_:L{f}g={[0b11]=0b10,[0b10]=g}g[1]=g g[1][g[0b11]]=a_:K{b_[0b1111],b_[0b110],b_[0b1110],b_[0b111],b_[0b1001],d_,f,b_[0b101],b_[0b1011],b_[0b1100],b_[0x11],b_[0b1000],b_[0b1101],_,b_[0b11],b_[0b100],j}e=a_:M{b_[0b10],b_[0x11],b_[0b1010],b_[0b1011],g,d_,_,f,b_[0x10]}return e end end,function(a_,b_,c_)a_.O[c_]=b_ return a_.O[c_]end,function(a_,b_)return function(d_,j)local h_,n_,l,e,i,k,_,o,q,g,f,p_,c_ p_=0xb9 while true do if p_>=0b10010100 then if p_<0xe2 then if p_<0b10111001 then if p_>0b10010100 then c_,q,h_,n_,g=b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],1,d_,b_[0b11][1][b_[0b11][0b11]]p_,h_=0x181-p_,o+h_ else p_,c_=0b101101110-p_,a_.h(c_(g,a_.i(n_)))end elseif p_>0b10111001 then p_,q=0xc4b6/p_,q(a_.i(c_))_=_..q else c_,o,q,_=1,0,#d_,""k,e=q-c_,c_ p_=k~=k and 0xe2 or 0x8a end elseif p_<0xe7 then if p_>0xe2 then g=g(n_,h_)n_,p_,i,h_,l=b_[0b11][1][b_[0b11][0b11]],0b11101010-p_,#j,j,#j f=o%i l=l-f else return _ end elseif p_>=0b11111000 then if p_<=0b11111000 then p_=e~=e and 0x7c00/p_ or 0b111110110-p_ else p_=e<=0 and 0x7f00/p_ or 0b10011101 end else o=o+e p_=e>0 and 0b11100 or 0xec-p_ end elseif p_<0x55 then if p_<0b11100 then if p_<=0b101 then p_=e<=0 and 0x7d or p_+0b1010000 else p_,n_=0x9a-p_,a_.h(n_(h_,l))end elseif p_<=0b11100 then p_=o>k and 0b11100010 or 0b101 else p_=o>k and 0b11100010 or 0x46b8/p_ end elseif p_<0b10000000 then if p_<=0b1010101 then p_=e~=e and 0x137-p_ or 0xf2-p_ else p_=o<k and p_+0b1100101 or 0x2981/p_ end elseif p_>0b10000000 then p_=e>0 and 0b11010011-p_ or 0x85b0/p_ else p_=o<k and 0b11100010 or p_+0b11101 end end end end,function(B,b_)return function()local P,H_,_,I,O,a_,F,e,z,j,c_,M,d_,f,D_,C_,m,x,o,k,R_,T_,i,N,K,q,G,y,r,w,v,p_,t_,h_,E,g,u,Q,L,l,n_,A,J,s_ p_=B.O[0x53e5]or B:R(2164714518,2158119729,2175159243,0x53e5)repeat if p_>=0x2e6 then if p_<=0x6c0 then if p_>=0x393 then if p_<0x3f9 then if p_>=0x3c1 then if p_<=0x3e0 then if p_<0x3ce then if p_<=0x3c4 then if p_<0x3c3 then if p_<=0x3c1 then i=0b10110011 p_=H_<=i and p_+-0b10001011 or p_+-0x117 else M=0b101001 p_=J>M and(B.O[0x4067]or B:S(0b100,0x21e,0x4067))or 0x533-p_ end elseif p_>0x3c3 then i,J=0b11110100,0b11110111 p_=H_>i and(B.O[0x72f2]or B:S(0b100000100,0b110000001,0x72f2))or 0x578d0/p_ else p_,M=0x56c13/p_,0b11100001 end elseif p_<=0x3ca then p_,M=0x53b-p_,0b10111011 else R_,g,P,p_,N=b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],"B",0x621-p_,b_[0b110][1][b_[0b110][0b11]]end elseif p_<0x3d7 then if p_<=0x3cf then if p_>0x3ce then i=0b1110 p_=H_>i and(B.O[0x7ac4]or B:T(0x32b,0x7ac4))or(B.O[-0x51d6]or B:R(0x4111a317,0x4644c528,0x4755cc59,-0x51d6))else i=0b111000 p_=H_<=i and(B.O[-0x5fba]or B:T(0b111001111,-0x5fba))or 0x526-p_ end else p_,M=B.O[-0x24aa]or B:R(2706488322,0x210052ac,2706461645,-0x24aa),0b101001 end elseif p_<=0x3dc then if p_<0x3d8 then i=0b10011001 p_=H_>i and(B.O[0x310a]or B:R(2417667202,2834513938,3103474045,0x310a))or(B.O[0x5762]or B:R(0x6810a490,2875769181,3950561861,0x5762))elseif p_<=0x3d8 then p_=Q>H_ and p_+-0x3af or 0xd0d-p_ else p_,M=B.O[-0x24aa]or B:R(2554367382,4196401170,4200603747,-0x24aa),0xbb end else i=0b1100100 p_=H_<i and(B.O[0b11000111]or B:S(0b11101000,0b10000001,0xc7))or 0x52d-p_ end elseif p_>=0x3e9 then if p_<=0x3ef then if p_<=0x3ec then if p_>0x3ea then p_=P<g and 0x488-p_ or 0x27d8cc/p_ elseif p_<=0x3e9 then p_,M=B.O[-0x24aa]or B:R(0x434024ac,0x12a19d5b,0x53e19c0a,-0x24aa),0x50 else M=1 p_=J<=M and(B.O[-0xabb]or B:T(0b11001011,-0xabb))or(B.O[-0x24aa]or B:R(0x668fa3a,0x1e2b6028,0x1e6b77dd,-0x24aa))end else M=0x84 p_=f<=M and 0xe3e71/p_ or 0x5ab7f/p_ end elseif p_>0x3f0 then M=1 p_=q>=M and 0x567-p_ or p_+-0x247 else M=0b101001 p_=J<=M and(B.O[-0x319b]or B:R(0x400aeb4,0x4500252d,0x450027f2,-0x319b))or(B.O[-0x24aa]or B:R(2754610646,2286144000,2893277745,-0x24aa))end elseif p_>0x3e4 then if p_<=0x3e5 then i[0x59a2]=G g,P,R_,p_,N=b_[0b10][1][b_[0b10][0b11]],"B",b_[1][1][b_[1][0b11]],B.O[-0x6b07]or B:R(0x6064acb6,2255789344,3866398892,-0x6b07),b_[0b110][1][b_[0b110][0b11]]else i=0xa3 p_=H_<i and(B.O[0x47a4]or B:R(0x42402594,2152336522,3259666143,0x47a4))or(B.O[0x15b8]or B:S(0x12c,0x220,0x15b8))end elseif p_<0x3e3 then p_,M=B.O[-0x24aa]or B:R(0x1895a9b4,0x10800be3,0x18950e92,-0x24aa),0b101001 elseif p_<=0x3e3 then p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0x29 else M=0b11101110 p_=t_<=M and(B.O[0x2d9b]or B:S(0x209,0b11101000,0x2d9b))or 0x59ba4/p_ end elseif p_<0x3a6 then if p_>=0x39e then if p_>0x3a1 then if p_<=0x3a3 then p_,i[0xa0e2]=0xb40-p_,G g,N,P,R_=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],"B",b_[1][1][b_[1][0b11]]else p_,M=B.O[-0x24aa]or B:Q(0xa055,0x111,0b1100000,-0x24aa),0b10000100 end elseif p_<0x3a0 then if p_<=0x39e then H_=H_(M,i)Q=not H_ p_=Q and p_+-0x2f7 or(B.O[0x2584]or B:R(0xd008cb6,0x612510a6,0x6d25308d,0x2584))else i=0b10000000 p_=H_<i and 0x7b1e0/p_ or(B.O[-0x476e]or B:R(3573851191,2623174856,3713956624,-0x476e))end elseif p_>0x3a0 then M=0xb0 p_=J<=M and(B.O[-0x24aa]or B:S(0b101000001,0x30,-0x24aa))or(B.O[0x67b7]or B:Q(0xa145,0x68c,0x195,0x67b7))else p_,M=0x539a0/p_,0b1011011 end elseif p_>0x397 then if p_<=0x39a then G=G+P p_=P>0 and(B.O[-0xddc]or B:R(0x2c502696,0x28e71b60,0x2cf792df,-0xddc))or p_+0x326 else N,P,g,p_,R_=b_[0b110][1][b_[0b110][0b11]],"B",b_[0b10][1][b_[0b10][0b11]],B.O[0x212d]or B:S(0x100,0x51d,0x212d),b_[1][1][b_[1][0b11]]end elseif p_>0x396 then p_,M=0x52ca7/p_,0x29 elseif p_<=0x394 then if p_>0x393 then M=0xbb p_=J<M and(B.O[-0x24aa]or B:R(0x410ae44,0x5311cd2,0x5311fa3,-0x24aa))or(B.O[0x1cbc]or B:T(0b110111111,0x1cbc))else M=0x84 p_=J<=M and p_+-0x2a2 or(B.O[-0x24aa]or B:Q(0xa075,0b1111,0b110010,-0x24aa))end else i=0b101000111 p_=H_>i and(B.O[-0x5fee]or B:S(0x105,0x2d0,-0x5fee))or 0x4ff-p_ end elseif p_>=0x3b9 then if p_<=0x3be then if p_<=0x3bd then if p_>0x3bc then M=0xaa p_=J<M and 0x5636d/p_ or p_+-0xcc elseif p_>0x3b9 then i,J=0b1000111,0x9b p_=H_<=i and(B.O[-0x6ebf]or B:Q(0xa141,0x247,0b111010,-0x6ebf))or(B.O[-0x386d]or B:T(0x1c9,-0x386d))else r,G=0x46,0x29 p_=M>=G and 0x4c1-p_ or(B.O[-0x5374]or B:Q(0xa145,0b1100100,0b111000000,-0x5374))end else i=0b110000 p_=H_>i and 0x41b8e/p_ or(B.O[0x7328]or B:Q(0xa041,0,0,0x7328))end elseif p_<=0x3bf then r,G,J=0b1010,0b10110000,0x82 p_=M>=G and(B.O[0x6622]or B:Q(0xa15f,0x6f,0x14,0x6622))or 0xc68b0/p_ else i=0x108 p_=H_<=i and(B.O[-0x51a3]or B:Q(0xa311,0b101011000,0b10111100,-0x51a3))or(B.O[-0x5fe6]or B:S(0x84,0x82,-0x5fe6))end elseif p_>0x3ac then if p_>0x3af then i=0b1010100 p_=H_>i and(B.O[-0x2174]or B:Q(0xa315,0b111010,0x20f,-0x2174))or(B.O[0x51c8]or B:R(0x2072e6c6,2507227176,3044231275,0x51c8))else p_,M=p_+-0x23e,1 end elseif p_<0x3ab then if p_<=0x3a6 then p_,i[0xf69c]=0x1f6cce/p_,G N,g,R_,P=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],"B"else M=0x29 p_=J>=M and(B.O[-0x24aa]or B:S(0x171,0,-0x24aa))or(B.O[-0x419d]or B:S(0x3a0,0x146,-0x419d))end elseif p_>0x3ab then R_,J,P,g,p_,N=b_[1][1][b_[1][0b11]],0b10111011,"B",b_[0b10][1][b_[0b10][0b11]],B.O[-0x59ae]or B:R(0x1c31bcbc,0x1709421a,0x1f395c8d,-0x59ae),b_[0b110][1][b_[0b110][0b11]]else p_,M=p_+-0x23a,0b101001 end elseif p_<=0x58c then if p_<=0x494 then if p_>0x41e then if p_>0x476 then if p_>0x48d then p_=G<=0 and(B.O[-0x7726]or B:R(2232069398,0x5910ed4,2241530761,-0x7726))or(B.O[-0x2976]or B:S(0xa18,0x487,-0x2976))else p_=M>i and(B.O[0x2716]or B:R(2181084294,2455820825,2455820579,0x2716))or(B.O[-0x2a9f]or B:Q(0xabed,0x859,0b110110000,-0x2a9f))end elseif p_<=0x45d then if p_<0x437 then M=M(i,G)i=0b111 p_,i=B.O[0x6897]or B:T(0x552,0x6897),e*i elseif p_>0x437 then p_=M<i and(B.O[0x25db]or B:R(3896774114,0x2304c8a0,3947161996,0x25db))or(B.O[-0x2976]or B:Q(0xa5db,0x650,0x437,-0x2976))else p_=e<L and 0x39b0d/p_ or 0x36a0da/p_ end else z=z(e,L,c_)e=c_ e=e+C_ b_[0b110][1][b_[0b110][0b11]],j=e,z p_=_<y and(B.O[-0x56d5]or B:S(0b10,0b10101000,-0x56d5))or(B.O[-0x5073]or B:R(0x344ac17,0x4e505c40,0x4f545cc0,-0x5073))end elseif p_<=0x3ff then if p_>0x3fe then p_,M=0x5c28f/p_,0b10000100 elseif p_<=0x3fc then if p_>0x3f9 then p_,i[0x5332]=B.O[-0x24c1]or B:Q(0xab45,0b111011,0b11101101,-0x24c1),G g,N,R_,P=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]],"B"else i=0x80 p_=H_<=i and(B.O[-0x31e7]or B:T(0xfa,-0x31e7))or 0x740-p_ end else i=0xef p_=H_<=i and p_+-0x1f4 or(B.O[0x34b7]or B:T(0x20b,0x34b7))end elseif p_<=0x416 then if p_<=0x404 then p_,Q=B.O[0x4385]or B:Q(0xa94d,0x5c8,0x594,0x4385),B.h(Q(H_,M))else p_=K<n_ and 0x4bc-p_ or 0xdbb-p_ end else R_=R_(P,g,N)p_,g,P=p_+0x403,0b10,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_>=0x51d then if p_<0x54f then if p_>=0x538 then if p_>0x538 then p_,i=0x3a5ce/p_,i(G,R_,P)G=P G=G+H_ Q,b_[0b110][1][b_[0b110][0b11]]=i,G else p_=K~=K and 0xda2-p_ or 0xc18-p_ end else R_=R_(P,g,N)g,P=1,N p_,P=B.O[-0x774e]or B:R(0x12a4b4be,0x7244108a,0x72e41aeb,-0x774e),P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end elseif p_<=0x552 then if p_>0x54f then p_,H_=B.O[0x4d40]or B:T(0x2c5,0x4d40),B.h(H_(M,i))else R_=R_()p_,H_[M]=0x6b4-p_,R_ end else p_=K>n_ and 0x632-p_ or(B.O[-0x4288]or B:S(0x840,0xc19,-0x4288))end elseif p_<=0x4ec then if p_<=0x4dc then if p_<0x4d4 then p_=L~=L and(B.O[-0x42ba]or B:Q(0xa4c1,0x3d0,0x150,-0x42ba))or(B.O[-0x3229]or B:S(0x405,0x83b,-0x3229))elseif p_>0x4d4 then R_=R_(P,g,N)P,g=N,0b10 P=P+g p_,G,b_[0b110][1][b_[0b110][0b11]]=p_+-0b1000,R_,P else p_,i[0xf0e]=B.O[-0x254e]or B:Q(0xa545,0b110010001,0xd13,-0x254e),G end else p_=K<=0 and(B.O[0x4c2b]or B:Q(0xad45,0b101000011,0x43f,0x4c2b))or p_+0x72a end elseif p_<=0x4ed then p_=K<n_ and(B.O[0x753b]or B:T(0xa6,0x753b))or(B.O[-0x1dc4]or B:T(0b1001,-0x1dc4))else n_=n_(Q)H_,Q=K,1 M=Q p_=H_~=H_ and(B.O[0x700c]or B:R(0x420add6,3456145473,3458243054,0x700c))or(B.O[0x49e9]or B:R(0x4204b7b5,3264227618,3264492505,0x49e9))end elseif p_<=0x65f then if p_<0x5df then if p_>=0x5b9 then if p_>0x5c3 then p_,R_=0xfe7-p_,R_(P,g,N)g,P=1,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P elseif p_<=0x5b9 then p_=e<L and(B.O[-0x1132]or B:T(0b11110011,-0x1132))or(B.O[-0x46a8]or B:S(0b1000001,0x12,-0x46a8))else p_,R_=0x92ec8/p_,R_(P,g,N)P,g=N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end elseif p_>=0x5a3 then if p_>0x5a3 then p_=z<e and 0x23410/p_ or(B.O[-0x523a]or B:S(0x80,0b11000110,-0x523a))else R_=R_(P,g,N)P,g=N,1 p_,P=0x122a4b/p_,P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end else n_=n_(Q,H_)K=not n_ p_=K and p_+-0x52d or 0x68c-p_ end elseif p_<=0x636 then if p_<=0x61f then if p_>0x610 then p_,i[0x5332]=B.O[-0x398b]or B:Q(0xa14d,0b100000101,0x319,-0x398b),G N,g,R_,P=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],B.O[0xe3f]or B:P(B.q"Z5U$",B.q"Q2",0xe3f)elseif p_>0x5df then p_=G~=G and(B.O[-0x2b65]or B:Q(0xa9e6,0x5fa,0x4fb,-0x2b65))or p_+0x737 else p_,R_=0x81e-p_,R_(P,g,N)P,g=N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end else p_=Q<H_ and p_+-0x5ee or 0x6da-p_ end elseif p_<=0x644 then p_=M<i and p_+-0x30a or 0x796-p_ else R_=R_(P,g)P=0b111 p_,P=0xd0a-p_,K*P end elseif p_<=0x68f then if p_<=0x686 then if p_<=0x684 then if p_<0x67c then p_=z>e and 0x6d6-p_ or 0xb3d-p_ elseif p_>0x67c then p_=N>0 and 0x515e74/p_ or(B.O[0x6c73]or B:T(0xffd,0x6c73))else p_=Q>H_ and(B.O[-0b1101000]or B:T(0x29,-0b1101000))or(B.O[-0x668c]or B:Q(0xa145,0xcfe,0x1d4,-0x668c))end else p_,i[0xf0e]=0xc29-p_,G N,g,R_,P=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],"B"end elseif p_<=0x68d then O=O(o,A)N=not O p_=N and 0x4602f/p_ or(B.O[0x6cd4]or B:S(0x8a,0x398,0x6cd4))else O=O(o,A)p_,o=B.O[0x57a6]or B:S(0b11000,0x2c0,0x57a6),0b111 o=M*o end elseif p_<=0x6ab then if p_<0x6a3 then N=N(O,B.i(o))O,i,p_,A,o=b_[0b101][1][b_[0b101][0b11]],N,B.O[0x5636]or B:T(0x68d,0x5636),0b10000000,g elseif p_>0x6a3 then p_,G=0x69bff4/p_,B.h(G(R_,P))else p_=L<=0 and 0x31134f/p_ or(B.O[0x3e96]or B:T(0x720,0x3e96))end elseif p_<=0x6bc then p_=c_>0 and 0xe5a-p_ or 0xdd9-p_ else p_=P<=0 and(B.O[0x1da4]or B:T(0xb3a,0x1da4))or 0x33bb80/p_ end elseif p_<=0x333 then if p_>0x309 then if p_<=0x325 then if p_<0x31b then if p_>=0x312 then if p_>=0x317 then if p_>0x317 then i=0x97 p_=H_>i and(B.O[0x45d4]or B:Q(0xa142,0b100000011,0x7e,0x45d4))or 0x61e4a/p_ else p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),1 end else p_,i[0xf69c]=B.O[0x3408]or B:R(0x4048e94,3255496788,3322870632,0x3408),G P,g,R_,N="B",b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_>0x30c then i=0b1011101 p_=H_<=i and(B.O[0x3ac]or B:S(0x2e2,0x3e2,0x3ac))or 0xab100/p_ elseif p_>0x30b then M=0x29 p_=r>=M and(B.O[-0x319b]or B:R(0x81028d4,0x57048c0a,0x5f148c97,-0x319b))or 0x47d-p_ else p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0xee end elseif p_>0x321 then if p_>=0x324 then if p_<=0x324 then p_=Q<H_ and 0x3d3-p_ or(B.O[-0x40f5]or B:T(0xbe1,-0x40f5))else p_,M=p_+-0b110110100,0b11100001 end else J,i=0xb2,0x4e p_=H_<=i and p_+-0xbc or(B.O[-0x24b8]or B:R(0x402b8e7,0x1b0e0989,0x1f0e1ec5,-0x24b8))end elseif p_<=0x31e then if p_<=0x31d then if p_>0x31b then M=0xbb p_=x<=M and(B.O[-0x79cf]or B:Q(0xa019,0b100010001,0x8a,-0x79cf))or 0x48e-p_ else i=0b11001011 p_=H_<i and(B.O[0xec]or B:S(0b100000,0x2a5,0xec))or(B.O[0x4063]or B:Q(0xa04f,0b1000,0x12,0x4063))end else p_,M=B.O[-0x24aa]or B:Q(0xa074,0b1111,0x32,-0x24aa),0b10111011 end else M=0x50 p_=J>M and(B.O[-0x24aa]or B:T(0b101110001,-0x24aa))or(B.O[0x2e68]or B:T(0x286,0x2e68))end elseif p_<0x32c then if p_<0x329 then if p_<=0x326 then p_,M=0x489c6/p_,0b10000100 else i=0b1000 p_=H_<i and p_+0b110000 or(B.O[-0x3b09]or B:T(0x35a,-0x3b09))end elseif p_<0x32a then r,G,J=0b1100,0xe1,0b11110000 p_=M<=G and(B.O[0x1f38]or B:T(0b101111101,0x1f38))or(B.O[-0x1db6]or B:T(0x2d5,-0x1db6))elseif p_<=0x32a then i=0b100010110 p_=H_<=i and(B.O[-0x7951]or B:S(0x25c,0b111,-0x7951))or(B.O[-0xc3d]or B:R(0x2132c97,0xd504207,0xf53c168,-0xc3d))else p_,M=B.O[-0x24aa]or B:Q(0xa125,0x55,0xbc,-0x24aa),0b10111011 end elseif p_>=0x331 then if p_>0x332 then i=0b111010 p_=H_<=i and 0x7b5eb/p_ or(B.O[-0x5710]or B:T(0x2e4,-0x5710))elseif p_<=0x331 then M=0b1011011 p_=J<=M and(B.O[-0x24aa]or B:T(0x171,-0x24aa))or 0xc0153/p_ else p_,M=p_+-0x1c1,0x84 end elseif p_>0x32d then p_,M=B.O[-0x24aa]or B:S(0,0x171,-0x24aa),0b11101110 elseif p_>0x32c then p_,M=p_+-0x1bc,0b101001 else i=0b10100011 p_=H_<=i and(B.O[-0x697e]or B:T(0b110101100,-0x697e))or(B.O[0x5aac]or B:Q(0xa14f,0b100,0x307,0x5aac))end elseif p_>0x2f9 then if p_>0x302 then if p_>0x307 then if p_>0x308 then p_,i[0xa0e2]=B.O[-0x254e]or B:S(0x800,0xea4,-0x254e),G else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0b10111011 end elseif p_<=0x304 then if p_<=0x303 then i[0xa0e2]=G N,g,p_,R_,P=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],0x19f9e0/p_,b_[1][1][b_[1][0b11]],B.O[-0x38e2]or B:P(B.q"pURN",B.q"qW",-0x38e2)else i=0x10 p_=H_>i and(B.O[0x7c52]or B:R(0x400a516,3266932876,3334043672,0x7c52))or 0x667-p_ end else M=0b10000100 p_=J<=M and(B.O[-0x6bea]or B:T(0x200,-0x6bea))or p_+-0b110010110 end elseif p_<0x2fe then if p_<0x2fb then p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0x29 elseif p_<=0x2fb then i=0x23 p_=H_>=i and 0x4b2-p_ or(B.O[-0x916]or B:T(0x253,-0x916))else M=M+G p_=G>0 and(B.O[-0x57ca]or B:Q(0xaf45,0x30e,0x828,-0x57ca))or(B.O[0x7c3c]or B:Q(0xa1c1,0b110001010,0x30a,0x7c3c))end elseif p_>0x301 then i=0x35 p_=H_<=i and(B.O[-0x5d80]or B:R(0x60801c94,0x20019000,0x6081b2f5,-0x5d80))or 0x56c-p_ elseif p_>0x300 then J,i=0xfc,0xcb p_=H_<=i and 0x6a8-p_ or 0x4e1-p_ elseif p_<=0x2fe then p_=Q>0 and p_+0x690 or 0xa3a-p_ else p_,N,R_,g,P=0x8c3-p_,b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],"B"end elseif p_<=0x2f0 then if p_<=0x2ea then if p_<=0x2e9 then if p_<0x2e7 then i,J=0x10a,0b1111010 p_=H_<=i and(B.O[0x4136]or B:S(0b11000000,0x300,0x4136))or(B.O[0x2959]or B:S(0x116,0x9e,0x2959))elseif p_>0x2e7 then p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),1 else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0b10111011 end else p_,M=0x4334a/p_,0x29 end elseif p_>=0x2ed then if p_<=0x2ed then i=0x86 p_=H_<i and(B.O[0x7207]or B:T(0b100100010,0x7207))or 0x6d2b1/p_ else p_,M=p_+-0b101111111,0xbf end else p_,M=B.O[-0x24aa]or B:Q(0xa135,0b1000000,0b11010001,-0x24aa),0xbb end elseif p_<=0x2f5 then if p_<0x2f4 then if p_<=0x2f1 then i,r=0b11110100,0x1b p_=H_>=i and 0x487-p_ or p_+0b100001101 else p_,i[0x5332]=0x194989/p_,G R_,N,P,g=b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],"B",b_[0b10][1][b_[0b10][0b11]]end elseif p_<=0x2f4 then i=0b100110 p_=H_>i and 0x596-p_ or p_+0xac else p_,M=0x44325/p_,0b10101010 end elseif p_<=0x2f7 then M=0x29 p_=r<M and(B.O[-0x6c49]or B:Q(0xa161,0x73,0x99,-0x6c49))or(B.O[-0x24aa]or B:R(0x1c29e794,0x79790603,0x7d794e72,-0x24aa))else p_,i[0xfa7d]=0x26fb35/p_,G g,N,R_,P=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]],"B"end elseif p_<0x358 then if p_<=0x342 then if p_<0x33c then if p_>0x339 then if p_<=0x33a then i={}i[0x810f]=w i[0x7846]=j i[0x235e]=C_ i[0xf888]=c_ i[0xec9d]=H_ i[0x2b3e]=n_ G=0 i[0xcd6c]=G i[0xcb47]=G M=i return M else p_,g,N,P,R_=B.O[-0x4abc]or B:S(0x28d,0b1000,-0x4abc),b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],"B",b_[1][1][b_[1][0b11]]end elseif p_<=0x336 then if p_<=0x335 then if p_<=0x334 then p_,M=0x4a5-p_,0x84 else J,G=0b11110,0x9e p_=M<=G and 0xb0fcf/p_ or 0x494-p_ end else i=0xb0 p_=H_<=i and p_+-0b10000110 or 0xb86da/p_ end else p_,i[0xe648]=p_+0xb6b,G end elseif p_>0x340 then if p_>0x341 then i=0x66 p_=H_>i and(B.O[-0x1e14]or B:S(0b1010,0b10011110,-0x1e14))or(B.O[-0x377f]or B:T(0b101011110,-0x377f))else i=0b100011110 p_=H_<=i and 0x3f6-p_ or(B.O[0x4d41]or B:Q(0xa325,0b11111110,0b1100010,0x4d41))end elseif p_<0x33f then if p_<=0x33c then p_,M=p_+-0b111001011,0b101001 else i=0x11 p_=H_>i and p_+-0b110101100 or(B.O[0x524d]or B:R(2150935638,0x15252264,2503287264,0x524d))end elseif p_>0x33f then p_,M=B.O[-0x24aa]or B:Q(0xa065,0x3f,0b10010,-0x24aa),0b1011011 else p_,i[0x95df]=0x11d5-p_,G g,R_,P,N=b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],B.O[-0x38e2]or B:P(B.q"rSPi",B.q"nE",-0x38e2),b_[0b110][1][b_[0b110][0b11]]end elseif p_<0x350 then if p_<0x34b then if p_<=0x346 then i=0b11000010 p_=H_>=i and(B.O[0x7cfe]or B:Q(0xa00c,0b11100,0x26,0x7cfe))or(B.O[0x22c2]or B:S(0,0b11000001,0x22c2))else p_,M=0x4b8-p_,0b10111011 end elseif p_>0x34e then p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0x29 elseif p_<=0x34b then p_,M=0x4bf1b/p_,0x84 else i=0b1101000 p_=H_<i and 0x690-p_ or 0x41796/p_ end elseif p_>=0x355 then if p_>0x356 then p_=G and 0x99d77/p_ or 0x3d8-p_ elseif p_>0x355 then p_,M=B.O[-0x24aa]or B:R(0x2256e8b9,0x24f218c3,0x26f65d9e,-0x24aa),0b100 else p_,M=0x4c6-p_,0b101001 end elseif p_<0x352 then G=0b10101010 p_=M>G and(B.O[0x45c3]or B:R(0x40a8bc80,0x4a010ae,0x44a81312,0x45c3))or(B.O[-0xd4b]or B:T(0x39b,-0xd4b))elseif p_>0x352 then i[0x5332]=G N,g,P,p_,R_=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],B.O[0xe3f]or B:P(B.q"r_!k",B.q"n*",0xe3f),0x188b80/p_,b_[1][1][b_[1][0b11]]else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0xbb end elseif p_>0x36f then if p_<0x37a then if p_>=0x376 then if p_<=0x377 then if p_<=0x376 then i=0b11100110 p_=H_>i and 0x99cba/p_ or(B.O[0x3d6]or B:S(0x20,0x37f,0x3d6))else p_,i[0x5332]=B.O[0x61da]or B:Q(0xafed,0x1eb,0b100110101,0x61da),G P,N,g,R_="B",b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]]end else p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0xaa end elseif p_>0x371 then G=0x84 p_=M>=G and(B.O[-0x4888]or B:T(0x129,-0x4888))or(B.O[-0x2a2]or B:Q(0xa3c5,1,0xb3,-0x2a2))else P,R_,p_,N,g="B",b_[1][1][b_[1][0b11]],0x21ee1c/p_,b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]]end elseif p_<=0x386 then if p_>=0x380 then if p_>0x380 then i=0b10111 p_=H_>i and 0x73648/p_ or(B.O[0x7ec8]or B:R(0x114c9c94,0xa200861,0x1b6c3b19,0x7ec8))else p_,M=0x50b80/p_,0xab end elseif p_<=0x37a then i=0b10110 p_=H_>i and(B.O[-0x370]or B:R(0x83a6f3,0x48809a05,0x48839808,-0x370))or(B.O[-0x3338]or B:R(0xa748c13,0x20651386,0x2a753160,-0x3338))else M=0b10111011 p_=J>=M and(B.O[-0x24aa]or B:T(0b101110001,-0x24aa))or 0x50c-p_ end elseif p_<=0x388 then i=0b10101000 p_=H_<=i and(B.O[0x551b]or B:T(0x356,0x551b))or(B.O[0x2527]or B:T(0x234,0x2527))else i[0xc252]=G P,R_=0,i[0xb54d]G=R_~=P p_=G and(B.O[-0x28b4]or B:T(0x19a,-0x28b4))or 0xbec9e/p_ end elseif p_>=0x363 then if p_>0x36b then if p_>=0x36e then if p_>0x36e then p_,M=p_+-0x1fe,0b101001 else G=0b10111111 p_=M<=G and(B.O[-0xcaa]or B:Q(0xa365,0b10,0b111,-0xcaa))or 0x5f9-p_ end else J,i=0x51,0b11011110 p_=H_<=i and p_+0x27 or(B.O[0x548c]or B:R(3062296214,2869770418,3213850795,0x548c))end elseif p_>0x36a then p_,M=B.O[-0x24aa]or B:S(0x61,0x111,-0x24aa),0b11101110 elseif p_>0x367 then i=0x1a p_=H_<=i and 0x1f5de/p_ or 0x6de3e/p_ elseif p_<=0x363 then p_,M=0x4d4-p_,0x9e else M=0b100 p_=J>M and(B.O[-0x24aa]or B:R(0x2189bc02,0x30acd858,0x31add9ad,-0x24aa))or 0x9dff1/p_ end elseif p_>0x35e then if p_>0x35f then i=0b100101010 p_=H_>i and(B.O[0x2128]or B:T(0x2a7,0x2128))or p_+-0b111110110 else p_,M=0x4dbef/p_,0b100 end elseif p_<0x35b then if p_<=0x358 then M=0b11101110 p_=J>=M and(B.O[-0x5fee]or B:S(0x344,0x2d1,-0x5fee))or 0x4c9-p_ else i=0b1000 p_=H_<=i and 0x743-p_ or(B.O[-0x5444]or B:S(0,0x340,-0x5444))end elseif p_<=0x35b then p_,i[0x5332]=p_+0x98a,G g,N,P,R_=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[0xe3f]or B:P(B.q"kma5",B.q"tN",0xe3f),b_[1][1][b_[1][0b11]]else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0b10000100 end elseif p_<0xb89 then if p_<0x920 then if p_>0x7aa then if p_>=0x84b then if p_<=0x8cc then if p_<0x893 then if p_<=0x854 then if p_>0x84b then p_=G>0 and(B.O[-0x35f5]or B:T(0x48d,-0x35f5))or(B.O[-0x2a9f]or B:T(0xaa9,-0x2a9f))else R_=R_(P,g,N)g,p_,P=0b100,p_+-0x4a5,N P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end else p_=L<c_ and 0x5ea88/p_ or(B.O[0x5ca7]or B:Q(0xa17d,0b1000,0b101010,0x5ca7))end elseif p_>=0x8a0 then if p_<=0x8a0 then R_=R_(P,g,N)P,g=N,0b10 p_,P=p_+-0x5cf,P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else p_=K<n_ and p_+-0x881 or p_+0x3b6 end elseif p_<=0x893 then R_=R_(P,g,N)P,g=N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],p_,G=P,B.O[0x192d]or B:S(0x58,0x238,0x192d),R_ else R_=R_(P,g,N)P,g=N,1 P=P+g p_,b_[0b110][1][b_[0b110][0b11]],G=0xebc-p_,P,R_ end elseif p_>=0x8ea then if p_<=0x8fa then if p_>0x8ea then p_=M>0 and(B.O[-0x4303]or B:T(0xe73,-0x4303))or 0x82dc88/p_ else R_=R_(P,g,N)P,g=N,1 P=P+g p_,b_[0b110][1][b_[0b110][0b11]],G=p_+-0x596,P,R_ end else p_=N<=0 and(B.O[0x4346]or B:T(0xf5f,0x4346))or(B.O[-0x1664]or B:R(0x6112ef6,0x4610c5c3,0x4611c7b8,-0x1664))end elseif p_<=0x8d4 then p_=Q<=0 and(B.O[-0x7c7d]or B:S(0x80c,0x8c0,-0x7c7d))or 0x6e6ba8/p_ else R_=R_(P,g,N)p_,P,g=B.O[-0x470b]or B:T(0b111001010,-0x470b),N,1 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_>0x7e0 then if p_>0x814 then if p_>0x821 then p_=c_<=0 and(B.O[-0x5b3e]or B:S(0x31,0x598,-0x5b3e))or(B.O[-0x46a8]or B:T(0b1010011,-0x46a8))else p_,i[0xf0e]=B.O[-0x254e]or B:T(0xea4,-0x254e),G end elseif p_<0x810 then p_=M<i and(B.O[0x2716]or B:R(3760253062,0x28bca022,3904694024,0x2716))or(B.O[0x65af]or B:S(0x864,0xa9c,0x65af))elseif p_>0x810 then e=e(L)c_,L=z,1 K=L p_=c_~=c_ and p_+-0x760 or(B.O[-0x74f1]or B:Q(0xa565,0x6b3,0b100001101,-0x74f1))else M=M(i,G,R_)i,G=R_,0b10 i=i+G H_,b_[0b110][1][b_[0b110][0b11]]=M,i p_=_<=G and(B.O[-0x5fdc]or B:R(0x41aa92,0x2bc28e20,0x2bc38f66,-0x5fdc))or 0x7efc0/p_ end elseif p_<0x7c4 then if p_>=0x7b3 then if p_>0x7b3 then p_,u=p_+0x82a,B.h(u(k,F))else R_=R_(P,g,N)g,P=0b10,N P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ p_=J<g and 0x885-p_ or 0xa68-p_ end else Q=Q(H_,M,i)M,H_=1,i H_=H_+M b_[0b110][1][b_[0b110][0b11]],n_=H_,Q p_=y>=M and 0x1cc8c/p_ or 0xa51-p_ end elseif p_<0x7d0 then j=j(C_,w,z)C_,w=z,1 p_,C_=p_+-0x6e6,C_+w b_[0b110][1][b_[0b110][0b11]],E=C_,j elseif p_<=0x7d0 then p_=P>0 and(B.O[-0x2c92]or B:S(0x880,0x7db,-0x2c92))or(B.O[-0x5c07]or B:T(0x986,-0x5c07))else p_=K>0 and 0x3a23c0/p_ or(B.O[0x3c25]or B:Q(0xa175,0x4fb,0x2d,0x3c25))end elseif p_<0x732 then if p_>0x708 then if p_>0x720 then if p_>0x72c then p_=L<c_ and(B.O[-0x6f7f]or B:S(0xb4,0b10100000,-0x6f7f))or 0x15b9-p_ else p_=Q<H_ and 0x7db-p_ or 0x7bc-p_ end elseif p_>0x71d then p_=L~=L and(B.O[0x2528]or B:T(0x64,0x2528))or(B.O[-0x523a]or B:S(0b10,0b11000100,-0x523a))elseif p_<=0x70d then p_,C_=0x70f-p_,C_(w,z,e)z,w=1,e w=w+z b_[0b110][1][b_[0b110][0b11]],j=w,C_ else p_=c_~=c_ and p_+-0b101100100 or(B.O[0x5788]or B:R(3230838021,2729455942,3803330961,0x5788))end elseif p_>=0x6ea then if p_>=0x702 then if p_<=0x702 then R_=R_(P,g,N)P,p_,g=N,0x8c1-p_,0b100 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ else n_=n_(Q,H_,M)H_,Q=1,M Q=Q+H_ p_,K,b_[0b110][1][b_[0b110][0b11]]=B.O[0x52cc]or B:R(0x128405a6,3315110680,3617373120,0x52cc),n_,Q end elseif p_<=0x6ea then p_=Q~=Q and(B.O[0x4c91]or B:R(0x406998,0xe981523,0xed8d1c2,0x4c91))or 0x6455be/p_ else p_=M<=0 and 0x2b7a00/p_ or(B.O[-0x6c99]or B:R(0x2a80ee07,3331543281,4002632277,-0x6c99))end elseif p_>=0x6dd then if p_>0x6dd then p_=K<=0 and 0xf4a-p_ or(B.O[0x5ca7]or B:S(0x2a,0b10000,0x5ca7))else p_=G<=0 and p_+0x12a or 0x4b638c/p_ end else p_=M>i and(B.O[0x25db]or B:R(2281883846,0x4a24c84,2359454892,0x25db))or 0x295920/p_ end elseif p_>0x760 then if p_>=0x79d then if p_>=0x79e then if p_>0x79e then p_=P~=P and p_+-0x6ff or 0x6ea66/p_ else p_=e>L and(B.O[-0x1132]or B:S(0x51,0xb3,-0x1132))or(B.O[-0x8ee]or B:R(0x280b515,3330858474,3330857718,-0x8ee))end else R_=R_(P,g,N)P,g=N,1 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P p_=I<g and 0x8fa-p_ or 0x14a1-p_ end elseif p_<=0x762 then p_=L>c_ and 0x816-p_ or(B.O[0x3c25]or B:R(0x58202e80,3307290645,3709978415,0x3c25))else p_=z<e and(B.O[0x2528]or B:T(0b1100100,0x2528))or 0xe85-p_ end elseif p_>=0x745 then if p_>0x757 then p_,R_=0x8a9-p_,R_(P,g,N)P,g=N,0b10 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ elseif p_>=0x754 then if p_>0x754 then R_=R_(P,g,N)P,g=N,0b10 p_,P=B.O[-0x57ff]or B:T(0x3e5,-0x57ff),P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ else p_=L>c_ and(B.O[-0x6f7f]or B:T(0xb4,-0x6f7f))or p_+-0x50b end else p_=e>L and(B.O[-0x1132]or B:R(0x1008aa86,0x300a221b,0x300a26e8,-0x1132))or 0x1451-p_ end elseif p_<0x734 then p_=M>0 and 0x6726cc/p_ or(B.O[-0xcf4]or B:S(0x846,0x246,-0xcf4))elseif p_<=0x734 then p_=M~=M and(B.O[-0x68]or B:T(0x29,-0x68))or(B.O[0x5ad6]or B:R(0x6fe2cd06,0x6e7daa91,0x6fffeb42,0x5ad6))else p_=Q~=Q and(B.O[-0x3210]or B:T(0xb31,-0x3210))or(B.O[-0x2e4c]or B:S(0x95,0xd1b,-0x2e4c))end elseif p_<0xa25 then if p_<=0x986 then if p_>0x94c then if p_<=0x97e then if p_>=0x972 then if p_>0x972 then p_=K>0 and 0x7ebc4c/p_ or(B.O[-0xbb5]or B:S(0b1010,0xca2,-0xbb5))else R_=R_(P,g,N)p_,g,P=B.O[0x813]or B:R(0x2000be1e,0x22440c25,0x22441c5e,0x813),1,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_>0x94e then H_=H_(M)i,M=Q,1 G=M p_=i~=i and(B.O[0x2716]or B:R(0x1068ac16,0x10d01780,0x10f814ba,0x2716))or p_+-0b100011100 else p_=G>0 and(B.O[0x1a55]or B:T(0x6d2,0x1a55))or(B.O[0x2008]or B:S(0x600,0x610,0x2008))end elseif p_<=0x981 then p_=L<c_ and(B.O[-0x6332]or B:S(0x24,0b10000111,-0x6332))or 0xa3a-p_ else p_=P~=P and(B.O[0x37cd]or B:Q(0xab43,0b100110010,0x76b,0x37cd))or(B.O[-0x2166]or B:S(0x9c4,0x8c1,-0x2166))end elseif p_<=0x93c then if p_<0x935 then if p_>0x920 then R_=R_(P,g,N)P,p_,g=N,p_+-0x525,1 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else p_=M<=0 and(B.O[0x6a0]or B:Q(0xa245,0x2c3,0x369,0x6a0))or(B.O[-0xd8b]or B:T(0x90,-0xd8b))end elseif p_>0x935 then p_=Q<H_ and 0x298e0/p_ or 0x1771-p_ else p_=M<=0 and 0x854942/p_ or(B.O[-0x3019]or B:S(0x20,0x734,-0x3019))end elseif p_<0x943 then R_=R_(P,g,N)P,g=N,1 P=P+g p_,G,b_[0b110][1][b_[0b110][0b11]]=B.O[-0x5af]or B:S(0b110010,0x375,-0x5af),R_,P elseif p_>0x943 then p_=e>L and p_+-0x871 or(B.O[0x1de7]or B:S(0xb1a,0b110011011,0x1de7))else M=M(i,G)p_,i=B.O[-0x7a97]or B:S(0x455,0xa00,-0x7a97),0b111 i=e*i end elseif p_<0x9bf then if p_<=0x98e then if p_>0x98a then p_=K>n_ and 0x2cc9a/p_ or(B.O[0x5d94]or B:T(0x73c,0x5d94))elseif p_>0x989 then G=G(R_,P,g)P,R_=1,g p_,R_=B.O[0x32a5]or B:R(0x2740c496,0x44882e01,0x67c86e3e,0x32a5),R_+P b_[0b110][1][b_[0b110][0b11]],i=R_,G else p_,i[0xc252]=B.O[-0x254e]or B:S(0xc04,0xea4,-0x254e),G end elseif p_>0x9a4 then p_=Q~=Q and p_+-0x8ff or(B.O[-0x1dc4]or B:Q(0xa145,0b11,0b110,-0x1dc4))else p_,o=B.O[-0x1fb2]or B:Q(0xa7cd,0x64e,0x42,-0x1fb2),B.h(o(A,u))end elseif p_>0x9df then if p_<=0xa05 then G(R_,P)G=0xaa p_=M>=G and(B.O[0x1954]or B:S(0xe0,0b1000000,0x1954))or(B.O[-0x651]or B:S(0x220,0x281,-0x651))else p_,i[0xa0e2]=B.O[-0x254e]or B:T(0xea4,-0x254e),G end elseif p_>=0x9dc then if p_<=0x9dc then p_,R_=0xb9c-p_,R_(P,g,N)g,P=1,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else p_,n_=p_+0x49d,n_(Q,B.i(H_))M,Q,z,H_=0x80,b_[0b101][1][b_[0b101][0b11]],n_,K end elseif p_<=0x9bf then p_=G>R_ and p_+-0x914 or 0x41c940/p_ else p_=P<=0 and p_+0b11011010 or(B.O[0x4a5]or B:R(0x1053dbe,0x424ad024,0x434fd1cb,0x4a5))end elseif p_>=0xafb then if p_<0xb38 then if p_<=0xb11 then if p_>=0xb0e then if p_<=0xb0e then p_=G<=0 and 0x1152-p_ or 0xc60-p_ else p_,P=p_+0b11001101,P(g,B.i(N))g,H_,O,N=b_[0b101][1][b_[0b101][0b11]],P,0x80,R_ end elseif p_>0xafb then p_=G~=G and(B.O[0x2716]or B:S(0x322,0b100111000,0x2716))or 0xe80b8/p_ else R_=R_(P,g,N)P,p_,g=N,B.O[-0x67db]or B:S(0x110,0x212,-0x67db),0b100 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end elseif p_>0xb28 then p_=K<n_ and 0xb7c-p_ or(B.O[-0x5ec2]or B:R(0x4618cf0,2267500556,2271703292,-0x5ec2))else R_=R_(P,g,N)g,P=1,N P=P+g p_,G,b_[0b110][1][b_[0b110][0b11]]=0xd19-p_,R_,P end elseif p_>=0xb47 then if p_<0xb59 then p_=L>0 and(B.O[0x5de1]or B:Q(0xa365,0x508,0b101001010,0x5de1))or 0x360d4d/p_ elseif p_>0xb59 then p_,K=p_+-0x5cb,K(n_,B.i(Q))H_,n_,Q,w=0x80,b_[0b101][1][b_[0b101][0b11]],c_,K else p_=c_<=0 and p_+0x72 or p_+-0xacf end elseif p_<0xb3a then K=K(n_,Q,H_)Q,n_=1,H_ p_,n_=B.O[0x9cd]or B:T(0xae,0x9cd),n_+Q c_,b_[0b110][1][b_[0b110][0b11]]=K,n_ elseif p_<=0xb3a then p_=G<R_ and(B.O[-0x4c9a]or B:T(0b10101011,-0x4c9a))or(B.O[0x94f]or B:S(0b10001010,0x720,0x94f))else N=N(O,o,A)O,o=A,1 O=O+o g,b_[0b110][1][b_[0b110][0b11]]=N,O p_=v<=o and 0x1845-p_ or(B.O[0x728e]or B:R(0x981ac92,0x2884c940,0x2985cb46,0x728e))end elseif p_<=0xa9f then if p_>=0xa46 then if p_<0xa95 then if p_<=0xa46 then p_=M~=M and p_+-0x410 or 0x1146-p_ else k=k(F,a_)p_,F=0x506017/p_,0b111 F=P*F end elseif p_>0xa95 then p_=G<R_ and(B.O[-0x4c9a]or B:T(0b10101011,-0x4c9a))or p_+-0x9b8 else R_=R_(P,g,N)P,g=N,0b10 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P p_=D_>g and(B.O[0x3214]or B:Q(0xa1c4,0b101010001,0x7b7,0x3214))or 0xb31-p_ end elseif p_<0xa29 then p_=N<=0 and 0xe11-p_ or 0x144e-p_ elseif p_<=0xa29 then p_=N~=N and p_+-0x98d or 0x39c93/p_ else p_,R_=B.O[0x2298]or B:Q(0xa104,0x1c6,0x6a,0x2298),R_(P,g,N)g,P=0b10,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_<=0xab1 then if p_<=0xaa9 then if p_<=0xaa5 then p_=M<=0 and(B.O[-0x47e8]or B:S(0x818,0x934,-0x47e8))or p_+0x390 else p_=G~=G and(B.O[-0x5e34]or B:T(0x644,-0x5e34))or 0x15b7-p_ end else R_=R_(P,g,N)P,g=N,1 p_,P=0xe0c-p_,P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_<=0xad6 then p_=c_<=0 and(B.O[0x10c5]or B:S(0x402,0x435,0x10c5))or 0x8c71a4/p_ else p_=M<i and 0x523c8/p_ or 0x22f35/p_ end elseif p_>=0xd9f then if p_>0xed2 then if p_>0xf72 then if p_>=0xfd6 then if p_>0xfe7 then if p_<=0xff7 then R_=R_(P,g,N)P,g=N,1 p_,P=p_+-0xc54,P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else p_=N~=N and(B.O[0x4346]or B:R(0x28a015,0x422868c3,0x4228639c,0x4346))or(B.O[0x491]or B:Q(0xa155,0x528,0x3e4,0x491))end elseif p_>=0xfdc then if p_<=0xfdc then p_,M=B.O[0x4a0e]or B:Q(0xa175,0xbaa,0xef,0x4a0e),M(i,B.i(G))i,c_,G,R_=b_[0b101][1][b_[0b101][0b11]],M,H_,0b10000000 else p_,o=p_+-0x1d0,o(A,B.i(u))R_,k,A,u=o,0x80,b_[0b101][1][b_[0b101][0b11]],O end elseif p_>0xfd6 then p_=G>R_ and p_+-0xf30 or(B.O[-0x5c07]or B:Q(0xa047,0x107,0x77f,-0x5c07))else H_=H_(M,i)M=0b111 p_,M=B.O[-0x4c3e]or B:T(0x404,-0x4c3e),z*M end elseif p_>0xfab then if p_>0xfbe then R_=R_(P,g,N)g,p_,P=0b100,0x287db7/p_,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else R_=R_(P,g,N)g,P=0b10,N p_,P=p_+-0xeb1,P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_>0xfa8 then p_,P=B.O[-0x4f21]or B:R(0x8432db2,0x1cd261a6,0x1cd3e3b6,-0x4f21),P(g,N,O)g,N=O,1 g=g+N R_,b_[0b110][1][b_[0b110][0b11]]=P,g elseif p_<=0xf89 then p_=c_>0 and(B.O[-0x5985]or B:R(0x102319c,0x3b021e12,0x3b029656,-0x5985))or 0xb44af3/p_ else R_=R_(P,g,N)p_,P,g=B.O[0x7624]or B:S(0,0x309,0x7624),N,1 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_<0xf39 then if p_>=0xf22 then if p_>=0xf36 then if p_<=0xf36 then p_=M>i and p_+-0xebe or p_+-0xaa2 else R_=R_(P,g,N)P,p_,g=N,0x20bf61/p_,1 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end else H_=H_(M,i,G)p_,M,i=0xfd4-p_,G,0b1000 M=M+i b_[0b110][1][b_[0b110][0b11]],Q=M,H_ end elseif p_<=0xef6 then if p_>0xed3 then c_=c_(K)n_,K=L,1 Q=K p_=n_~=n_ and(B.O[0x753b]or B:Q(0xa1e3,1,1,0x753b))or 0x1b05-p_ else p_,Q=B.O[0x191f]or B:Q(0xa3d1,0b111100000,0b110111010,0x191f),Q(H_,B.i(M))M,H_,i,e=n_,b_[0b101][1][b_[0b101][0b11]],0x80,Q end else p_=P>g and 0x93474/p_ or(B.O[-0x65a6]or B:S(0x221,0xa25,-0x65a6))end elseif p_>0xf67 then if p_<=0xf6e then p_=L>c_ and 0xa10c2/p_ or(B.O[0x3341]or B:R(0x20aa417,3356493825,3390704749,0x3341))else n_=n_(Q,H_,M)Q,H_=M,1 Q=Q+H_ b_[0b110][1][b_[0b110][0b11]],K=Q,n_ p_=_>H_ and 0xfe9-p_ or(B.O[0x249f]or B:S(0x345,0b1100110,0x249f))end elseif p_<0xf5f then if p_>0xf39 then p_=M<=0 and(B.O[0x3cdc]or B:Q(0xa0c4,0x6f6,0x68e,0x3cdc))or 0x100e-p_ else R_=R_(P,g,N)p_,g,P=0x14fd99/p_,1,N P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end elseif p_<=0xf5f then p_=P<g and(B.O[-0x5834]or B:R(0x880ac96,2290434951,2290434843,-0x5834))or 0x576c5/p_ else i=i(G,R_)G=0b111 p_,G=B.O[0x30ec]or B:T(0xbfe,0x30ec),L*G end elseif p_<0xe56 then if p_<=0xe27 then if p_<=0xe09 then if p_<0xddc then if p_<=0xd9f then p_=Q<=0 and(B.O[-0x3210]or B:R(0x834068f,2900361862,2901713326,-0x3210))or(B.O[-0x5ec2]or B:R(2390802102,3364939074,3465607152,-0x5ec2))else R_=R_(P,g,N)g,P=0b10,N p_,P=B.O[-0x183e]or B:S(0b100100000,0b100100110,-0x183e),P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end elseif p_>0xddc then R_=R_(P,g,N)p_,g,P=0x148f-p_,0b10,N P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ else p_,P=p_+-0b111110100,B.h(P(g,N))end elseif p_<0xe17 then w=w(z,e,L)z,e=L,1 z=z+e p_,b_[0b110][1][b_[0b110][0b11]],C_=p_+-0xd28,z,w elseif p_>0xe17 then p_,R_=0x10b3-p_,R_(P,g,N)P,g=N,1 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else A=A(u,k)o=not A p_=o and p_+-0xd7b or p_+-0xb54 end elseif p_<=0xe36 then if p_>=0xe35 then if p_<=0xe35 then p_=M~=M and(B.O[-0x6d54]or B:T(0x48,-0x6d54))or(B.O[-0x6c99]or B:T(0b10100100,-0x6c99))else p_=e>L and 0xf11-p_ or 0x99fd24/p_ end else Q=Q(H_,M,i)M,H_=1,i p_,H_=0x4b59b/p_,H_+M n_,b_[0b110][1][b_[0b110][0b11]]=Q,H_ end elseif p_<=0xe48 then p_,R_=0x1187-p_,R_(P,g,N)g,P=0b10,N P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ else p_,H_=B.O[-0x644b]or B:S(0x85d,0x1c7,-0x644b),B.h(H_(M,i))end elseif p_>=0xe8c then if p_<0xe9f then if p_<0xe94 then p_=z>e and 0x5aeb0/p_ or 0x608b24/p_ elseif p_>0xe94 then R_=R_(P,g,N)P,g=N,0b10 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P p_=J>g and(B.O[0x676b]or B:Q(0xa335,0b1101100,0b111100111,0x676b))or(B.O[0x2df2]or B:T(0b1101011,0x2df2))else p_=M~=M and(B.O[0x6a0]or B:T(0x72c,0x6a0))or(B.O[-0x54f3]or B:R(2185538692,0x2d86829,2195480859,-0x54f3))end elseif p_>0xeb7 then p_=M~=M and p_+-0x14d or(B.O[-0x7120]or B:S(0x209,0xf32,-0x7120))elseif p_>0xea4 then R_=R_(P,g,N)g,P=1,N p_,P=B.O[-0x49aa]or B:Q(0xa004,0b1110011,0x76,-0x49aa),P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ elseif p_>0xe9f then K=K+Q p_=Q>0 and 0x1430-p_ or(B.O[-0x4288]or B:T(0xc59,-0x4288))else p_=G~=G and 0x6da88/p_ or p_+-0xe6c end elseif p_<=0xe7c then if p_>=0xe7a then if p_>0xe7a then Q=Q(H_,M)n_=not Q p_=n_ and(B.O[0x70ae]or B:T(0xdb,0x70ae))or p_+-0xdc9 else p_=Q<H_ and(B.O[-0x68]or B:Q(0xa16d,0x14,0x15,-0x68))or 0x6846c8/p_ end elseif p_<=0xe56 then p_=Q>H_ and 0x40830/p_ or 0x934784/p_ else p_=Q>H_ and 0xf22-p_ or 0xd2a47c/p_ end elseif p_>0xe83 then p_=K~=K and(B.O[-0x6f7f]or B:Q(0xa1d5,0b100101,0b1111,-0x6f7f))or p_+-0xe4f else p_=Q<=0 and 0x477b47/p_ or 0xe8c-p_ end elseif p_>=0xc87 then if p_>=0xd04 then if p_>=0xd57 then if p_>=0xd82 then if p_>0xd85 then p_,R_=0x9ef6d0/p_,R_(P,g,N)g,P=1,N P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P elseif p_>0xd82 then p_=Q<H_ and p_+-0xd5c or(B.O[0x5ad6]or B:T(0b11010011,0x5ad6))else p_=L<c_ and 0xe29-p_ or(B.O[0x4777]or B:S(0x802,0x416,0x4777))end elseif p_<0xd5a then o=o(A,u,k)A,u=k,1 A=A+u p_,O,b_[0b110][1][b_[0b110][0b11]]=p_+-0xc3b,o,A elseif p_<=0xd5a then p_=L>c_ and(B.O[-0x6332]or B:S(0b110,0b10100001,-0x6332))or 0x1a04-p_ else R_=R_(P,g,N)P,g=N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ p_=J<g and(B.O[0x7ac4]or B:T(0x32b,0x7ac4))or p_+-0xb7e end elseif p_>0xd1b then if p_>0xd1d then p_=G<=0 and(B.O[-0x2b65]or B:Q(0xa1a3,0x40e,0x665,-0x2b65))or(B.O[-0x29ae]or B:S(0x20,0b10011,-0x29ae))else R_=R_(P,g,N)P,g=N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ p_=r<g and(B.O[0x4496]or B:R(3355481114,3742190284,3742202601,0x4496))or 0xf7b-p_ end elseif p_<0xd0c then if p_>0xd04 then R_=R_(P,g)G=not R_ p_=G and 0xd34-p_ or(B.O[-0x38b1]or B:R(0x1051be9e,0x12c52068,0x12d532e0,-0x38b1))else p_,i[0xe648]=0x3f3f70/p_,G R_,g,N,P=b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[0xe3f]or B:P(B.q"pX!k",B.q"qW",0xe3f)end elseif p_>0xd0c then p_=e<L and 0xc70a1/p_ or 0x199a-p_ else p_=c_<=0 and 0xaafc44/p_ or(B.O[0x1b0b]or B:T(0xc7f,0x1b0b))end elseif p_<0xcd0 then if p_<0xcb9 then if p_<=0xcaa then if p_>0xc87 then p_=K~=K and(B.O[-0xd81]or B:R(2818809758,0x3016326a,3088530155,-0xd81))or p_+-0xde else P=P(g,N,O)g=O g=g+G b_[0b110][1][b_[0b110][0b11]],i=g,P p_=_<=l and(B.O[0x488e]or B:T(0b11111100,0x488e))or 0x13abfe/p_ end else p_=Q>H_ and 0x8b119/p_ or(B.O[0x3eb0]or B:S(0x400,0x878,0x3eb0))end elseif p_<=0xcbd then if p_<=0xcb9 then i=i(G,R_)M=not i p_=M and 0xd04-p_ or(B.O[-0x4203]or B:Q(0xa115,0,0b1011110,-0x4203))else g=g(N,O)p_,N=B.O[-0x66c8]or B:Q(0xa049,0x43c,0x998,-0x66c8),0b111 N=Q*N end else M=M(i,G,R_)p_,i,G=0x558d9/p_,R_,1 i=i+G H_,b_[0b110][1][b_[0b110][0b11]]=M,i end elseif p_>=0xce8 then if p_<=0xcf6 then if p_>0xce8 then p_=c_~=c_ and(B.O[0x70ae]or B:S(0b11010011,0b1001010,0x70ae))or(B.O[-0x678a]or B:T(0b10001010,-0x678a))else p_=K>n_ and(B.O[-0x7bb1]or B:Q(0xa107,0b1010,1,-0x7bb1))or(B.O[-0x1475]or B:T(0x8d4,-0x1475))end else p_=M>0 and(B.O[-0x1c83]or B:R(2215160982,2164288080,2231921708,-0x1c83))or(B.O[-0x668c]or B:S(0x892,0x640,-0x668c))end elseif p_>=0xce5 then if p_<=0xce5 then R_=R_(P,g,N)g,P=0b10,N p_,P=0xe4d-p_,P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P else p_=Q>H_ and(B.O[-0x6d54]or B:R(0x40ae07,0x3419c0c7,0x3459c29f,-0x6d54))or(B.O[0x2092]or B:Q(0xa940,0x612,0x48e,0x2092))end else e=e(L,c_,K)L=K L=L+w p_,b_[0b110][1][b_[0b110][0b11]],C_=0xd6d-p_,L,e end elseif p_>0xc11 then if p_<=0xc6f then if p_<=0xc55 then if p_<=0xc54 then if p_>0xc3f then p_=K>n_ and(B.O[0x753b]or B:S(0b10000000,0x26,0x753b))or p_+-0x56a elseif p_>0xc16 then p_=L<=0 and(B.O[-0x42ba]or B:Q(0xa0e5,0xa9,0x35b,-0x42ba))or(B.O[-0x523a]or B:T(0xc6,-0x523a))else p_=K~=K and(B.O[-0x6332]or B:S(0b100,0xa3,-0x6332))or 0x8bbe6/p_ end else p_,R_=0xd26a5/p_,R_(P,g,N)P,g=N,0b10 P=P+g G,b_[0b110][1][b_[0b110][0b11]]=R_,P end elseif p_<=0xc59 then p_=Q<=0 and 0x106f-p_ or(B.O[-0x53a4]or B:Q(0xa961,0x25f,0x742,-0x53a4))else M=M(i,G,R_)G,i=1,R_ i=i+G H_,b_[0b110][1][b_[0b110][0b11]]=M,i p_=_>G and(B.O[0x44b9]or B:S(1,0b10110000,0x44b9))or(B.O[0x45c3]or B:S(0b10000100,0x328,0x45c3))end elseif p_<=0xc7f then if p_<=0xc7d then if p_<=0xc78 then p_=M<=0 and(B.O[0x3b74]or B:R(0x422e8696,0x6eae431d,0x6eae6839,0x3b74))or(B.O[-0x40f5]or B:R(0x610de492,0x309dc7cc,0x719dc42d,-0x40f5))else p_=P>g and(B.O[-0x5834]or B:T(0b10011100,-0x5834))or(B.O[0x6c73]or B:T(0xffd,0x6c73))end else p_=c_~=c_ and 0xd72-p_ or p_+-0xc2c end elseif p_>0xc81 then p_=Q~=Q and p_+-0xc37 or p_+-0xbf0 else p_,i[0xf0e]=0x1b25-p_,G end elseif p_>=0xbde then if p_>0xbfe then if p_>0xc0f then p_=M>i and 0x26eeda/p_ or(B.O[-0x63b9]or B:R(0x804bcd4,0x5c03678,0xdc430a7,-0x63b9))else p_=Q>0 and(B.O[-0x6467]or B:R(0x2100ac96,0x3e081996,0x3f0815c2,-0x6467))or 0x535fb6/p_ end elseif p_>0xbe8 then p_,M=B.O[0x4924]or B:R(0x848ac92,0x6868c005,0x6868ced6,0x4924),B.h(M(i,G))elseif p_<0xbe1 then g=g(N,O)P=not g p_=P and p_+-0xb66 or(B.O[0x4e29]or B:Q(0xa149,0b11101010,0x212,0x4e29))elseif p_>0xbe1 then G=G(R_,B.i(P))g,p_,R_,P,n_=0b10000000,0x9b4af8/p_,b_[0b101][1][b_[0b101][0b11]],i,G else p_=M~=M and(B.O[0x700c]or B:R(0x209eac86,0xdae0d6a,0x2dbe0dd5,0x700c))or 0xc71-p_ end elseif p_>=0xbbc then if p_<0xbcb then p_,i[0xa0e2]=B.O[-0x254e]or B:S(0x480,0xaa4,-0x254e),G elseif p_<=0xbcb then p_=e<L and p_+-0xaf0 or 0x65b6e/p_ else p_=K<=0 and(B.O[-0xd81]or B:T(0x981,-0xd81))or 0x8866c/p_ end elseif p_<0xb8b then R_=R_(P,g,N)p_,P,g=B.O[0x7cbf]or B:S(0x300,0x303,0x7cbf),N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ elseif p_>0xb8b then p_=c_~=c_ and 0x1766-p_ or(B.O[0x4d79]or B:S(0x219,0xb58,0x4d79))else R_=R_(P,g,N)p_,P,g=0xc55-p_,N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end elseif p_<0x14b then if p_>=0xae then if p_<=0xf2 then if p_<=0xd3 then if p_<0xc3 then if p_<=0b10110101 then if p_>=0b10110010 then if p_<=0b10110100 then if p_<=0b10110011 then if p_<=0b10110010 then p_,e[L]=B.O[0x4538]or B:S(0b10001100,0b10,0x4538),Q else e=e+c_ p_=c_>0 and 0xee9-p_ or(B.O[0x7967]or B:S(0b1000010,0xad6,0x7967))end else h_,x,c_,m=0xb7,0xd1,0,0x2e K,n_,Q=c_,0b100,1 p_=n_~=n_ and(B.O[-0x7bb1]or B:R(3759403159,2558594476,4170407398,-0x7bb1))or(B.O[0x788e]or B:S(0x298,0x66,0x788e))end else i=0x11a p_=H_>i and p_+0x79 or(B.O[0x356d]or B:R(3269504214,3509059988,3555197127,0x356d))end elseif p_<0xaf then n_,Q,i,M,p_,K,H_=w,b_[0b111][1][b_[0b111][0b11]],0x7f,c_,B.O[-0x6975]or B:Q(0xa507,0xa1f,0b110110111,-0x6975),b_[0b100][1][b_[0b100][0b11]],b_[0b1001][1][b_[0b1001][0b11]]elseif p_<=0xaf then Q,H_=1,L M=Q p_=H_~=H_ and 0x3138/p_ or 0x4eb2e/p_ else G,g,p_,R_,i,M,P=b_[0b111][1][b_[0b111][0b11]],0b1111111,B.O[-0x44f7]or B:S(0x45b,0x614,-0x44f7),b_[0b1001][1][b_[0b1001][0b11]],c_,b_[0b100][1][b_[0b100][0b11]],H_ end elseif p_<0b10111010 then if p_<=0xb7 then i=0x7b p_=H_>i and p_+0x294 or p_+0x2f4 else p_,M,H_,i,Q=0xee8-p_,b_[0b10][1][b_[0b10][0b11]],"B",b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]]end elseif p_<0b10111011 then J,i=0x33,0b111011 p_=H_>i and(B.O[0x640c]or B:R(0x4509ac92,0x5c860025,0x5d8f002e,0x640c))or p_+-0b10001110 elseif p_<=0b10111011 then i=0x59 p_=H_>=i and 0x7ab8/p_ or(B.O[-0x4caa]or B:S(0b11100001,0xc3,-0x4caa))else p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0xee end elseif p_<0xcb then if p_>0xc6 then if p_<=0xc8 then H_=0b100 p_=n_==H_ and p_+-0x6b or p_+-0xaa else p_,i[0x5332]=p_+0x638,G N,g,P,R_=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],B.O[-0x2af6]or B:P(B.q"oye5",B.q"p#",-0x2af6),b_[1][1][b_[1][0b11]]end elseif p_>0xc5 then p_,K,Q,H_,n_=p_+0xa72,b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],"B"elseif p_>0xc4 then p_,M=B.O[-0x24aa]or B:Q(0xa015,0b11100,0b101,-0x24aa),1 elseif p_<=0b11000011 then i=0b1001 p_=H_<=i and 0x26778/p_ or(B.O[-0xd17]or B:Q(0xa04c,0x1c,0b10100,-0xd17))else J,i=0xaa,0b1101 p_=H_>i and(B.O[0x155a]or B:S(0x3cf,0xc3,0x155a))or 0x314-p_ end elseif p_<=0b11001111 then if p_<=0xce then if p_>0b11001101 then K,p_,c_=L,p_+0xe28,b_[0b1011][1][b_[0b1011][0b11]]elseif p_<=0xcb then i=0b10011010 p_=H_<=i and(B.O[0b110100]or B:R(0x453a00e,3260419119,3327593523,0x34))or(B.O[-0x394a]or B:S(0b1001001,0x29,-0x394a))else i=0b111111 p_=H_<i and p_+0x86 or 0x242f7/p_ end else i=0b10101011 p_=H_>i and 0x1079a/p_ or(B.O[-0x1b0]or B:Q(0xa355,0b11001000,0x16f,-0b110110000))end elseif p_>0xd2 then p_,P,G,R_,g=p_+0x8b7,b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],"B",b_[0b110][1][b_[0b110][0b11]]elseif p_<=0b11010001 then z=0 p_=w==z and 0x5c41/p_ or(B.O[0x339f]or B:S(0b1000000,0b100001,0x339f))else i=0xad p_=H_<i and 0xa9ce/p_ or p_+0xde end elseif p_>0b11100001 then if p_>0xea then if p_<0xf0 then if p_>0xec then p_,Q=0x1a1-p_,1/-0 else z,_=0,0b1001001 c_,L,e=1,0b100,z p_=L~=L and(B.O[0x70ae]or B:S(0b11001000,0b11011,0x70ae))or 0x1075-p_ end elseif p_<=0xf1 then if p_>0b11110000 then i=0b100010100 p_=H_<i and(B.O[0x3a7e]or B:Q(0xa141,0x9f,0b110111,0x3a7e))or(B.O[-0x6599]or B:R(0x210a994,0x2175338,0x217572c,-0x6599))else M=0b101001 p_=J<M and(B.O[0x2cdc]or B:R(0x1019e916,2595815888,2595833172,0x2cdc))or 0x159f0/p_ end else i=0b10111001 p_=H_<=i and(B.O[0x7ad1]or B:S(0b10011,0x381,0x7ad1))or(B.O[-0x2d1e]or B:R(3237849215,2703697156,3791595400,-0x2d1e))end elseif p_>0xe7 then if p_<=0b11101001 then p_,M=B.O[-0x24aa]or B:R(2287905943,0xc485151,2354991136,-0x24aa),0b100 else i=0x22 p_=H_<i and p_+-0b1011111 or p_+-0xa4 end elseif p_<=0b11100101 then if p_>=0b11100100 then if p_<=0b11100100 then i=0xea p_=H_<i and(B.O[0x3958]or B:R(0x4104d06,0x6467bcb,0x656fb2f,0x3958))or p_+0b1101 else p_,M=p_+0x8c,0b101001 end else i=0x52 p_=H_<=i and(B.O[-0x319b]or B:Q(0xa1c5,0x30,0b101101,-0x319b))or(B.O[0x4c37]or B:R(0x2086a32,0x8b906ac,0xab9c62c,0x4c37))end else O,p_,N,o,A="B",B.O[-0x5c90]or B:Q(0xaa44,0x6b4,0x18d,-0x5c90),b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_<0xdb then if p_<0xd8 then if p_<=0xd6 then if p_>0xd4 then i=0xf8 p_=H_>i and p_+0x210 or(B.O[-0x2d75]or B:S(0x281,0x271,-0x2d75))else i=0b1000100 p_=H_<=i and(B.O[-0x5906]or B:R(0x2a012cc7,0x8511661,0x2a519541,-0x5906))or 0x169e4/p_ end else p_,w,C_,z,e=B.O[-0x68f3]or B:Q(0xa249,0x44,0x6c1,-0x68f3),"B",b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_>=0xd9 then if p_<=0xd9 then i=0x4c p_=H_<=i and p_+0b11011111 or(B.O[0x5fd8]or B:R(0x426825a6,3272619571,3279469613,0x5fd8))else J,i,r=0x4a,0xaf,0x1b p_=H_<i and p_+-0xb6 or(B.O[0x3fe]or B:R(0x40f0b0b6,2355663914,3438845134,0x3fe))end else M,p_,G,i,R_=b_[1][1][b_[1][0b11]],0xacb48/p_,b_[0b10][1][b_[0b10][0b11]],"B",b_[0b110][1][b_[0b110][0b11]]end elseif p_<=0b11011111 then if p_>=0xde then if p_<=0xde then t_,v,y,j=0b11111101,0b11101,0b111110,0b1010101 p_=E~=j and(B.O[0x5559]or B:R(0x63995c86,4272521344,4290375903,0x5559))or(B.O[-0x16b5]or B:R(0x6e28494,0x448dc8d9,0x46efe80c,-0x16b5))else i=0b1011011 p_=H_>i and(B.O[0x2d9b]or B:R(0x4d2aefb7,0x4b885029,0x4faa51c0,0x2d9b))or 0x226-p_ end elseif p_<=0xdb then T_,_,p_,w=0x6d,0x15,B.O[-0x7f0d]or B:S(0x88,0x91,-0x7f0d),z else i=0b1001110 p_=H_<i and(B.O[-0x1014]or B:R(0x4bec8e97,0x71b92423,0x7bfd26fa,-0x1014))or p_+0b101110100 end elseif p_<=0xe0 then G=0b10111111 p_=M<G and 0x49f-p_ or p_+0x249 else i=0b10110 p_=H_<i and(B.O[0x7fc9]or B:R(0x2000c56,0x9a799d,0x29af947,0x7fc9))or 0x1cb-p_ end elseif p_>0x11a then if p_<0x12c then if p_>0b100100010 then if p_<0x126 then if p_<=0x123 then i=0xb5 p_=H_>i and(B.O[-0x3d72]or B:S(0x120,0x140,-0x3d72))or(B.O[-0x7e9c]or B:R(0x804ac9d,0xd27300a,0xd2733ca,-0x7e9c))else i=0b10100000 p_=H_>=i and 0x2d47d/p_ or p_+0b100001110 end elseif p_<=0b100101000 then if p_<=0x126 then p_,i[0xc252]=0x10d058/p_,G else p_,M=0x299-p_,0x50 end else G=0x84 p_=M>G and(B.O[-0x250d]or B:S(0x249,0x20b,-0x250d))or p_+0x248 end elseif p_>=0x120 then if p_>=0b100100001 then if p_<=0x121 then p_,M=0x1a091/p_,0x29 else M=0b101001 p_=J<=M and 0x36dee/p_ or 0x293-p_ end else J,i=0x61,0b10 p_=H_<i and 0x18540/p_ or(B.O[0x729c]or B:R(0x54e0b4cf,0x18ec133b,0x5cec196a,0x729c))end elseif p_<0b100011101 then u,o,k,A,F,p_,a_=b_[0b111][1][b_[0b111][0b11]],b_[0b100][1][b_[0b100][0b11]],b_[0b1001][1][b_[0b1001][0b11]],R_,O,B.O[0x2fc1]or B:R(0xc0085a7,2690130088,2891457498,0x2fc1),0x7f elseif p_<=0b100011101 then p_,M=0x28e-p_,0x29 else P="c"P,p_,R_=b_[1][1][b_[1][0b11]],B.O[-0x15fc]or B:S(0xc85,0xc83,-0x15fc),P..G g,O,N=R_,b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]]end elseif p_<0b101000010 then if p_>=0x13b then if p_<=0b100111101 then if p_>0b100111011 then i,J=0x69,0b1101 p_=H_>i and p_+0b110101101 or 0x30b-p_ else M=0x9e p_=J>M and 0x3bb-p_ or 0x1c60b/p_ end else p_,M=B.O[-0x24aa]or B:S(0b100110000,0b101010001,-0x24aa),0xaa end elseif p_>=0x12e then if p_>0x12e then p_,M=0x2aa-p_,1 else M=1 p_=J<M and(B.O[-0x27a2]or B:S(0,0x103,-0x27a2))or p_+0x43 end else p_,M=0x1b06c/p_,0b100 end elseif p_>0b101001000 then if p_<=0x149 then i[0xf0e]=G N,p_,R_,P,g=b_[0b110][1][b_[0b110][0b11]],0xd997d/p_,b_[1][1][b_[1][0b11]],B.O[0xe3f]or B:P(B.q"^M?H",B.q"&j",0xe3f),b_[0b10][1][b_[0b10][0b11]]else i=0x87 p_=H_<=i and(B.O[-0x3d62]or B:R(0x48002c99,2316746762,3390489314,-0x3d62))or 0x3c2ee/p_ end elseif p_>0b101000111 then p_,H_,M=0xab8-p_,b_[0b1011][1][b_[0b1011][0b11]],Q elseif p_<0b101000110 then i=0b101001001 p_=H_<=i and p_+0x254 or p_+0b101100010 elseif p_<=0x146 then p_,M=0x1d5e6/p_,0b100 else M=0b10111011 p_=J<=M and 0x221-p_ or(B.O[-0x24aa]or B:T(0b101110001,-0x24aa))end elseif p_<0x104 then if p_>=0xfa then if p_>0xfd then if p_<=0x102 then p_,M=p_+0b1101111,0b11101110 else i=0x1f p_=H_>i and(B.O[0x4f4f]or B:R(0x1612a986,0x31946114,0x3796675a,0x4f4f))or(B.O[-0x3bdf]or B:R(2424350855,2149064849,2425890224,-0x3bdf))end elseif p_<=0b11111100 then if p_<0b11111011 then p_,M=0x26b-p_,0b10111111 elseif p_<=0xfb then z=z+L p_=L>0 and(B.O[0x56a8]or B:T(0xe8c,0x56a8))or(B.O[-0x2f2d]or B:R(0x64a0ae87,0x308a2413,0x74aa20b0,-0x2f2d))else i=0b1100110 p_=H_<i and 0b111111001-p_ or(B.O[0x4c5f]or B:Q(0xa147,0b10101110,0x2c,0x4c5f))end else i=0b101110 p_=H_>=i and 0x3c49/p_ or(B.O[-0x2535]or B:T(0xe1,-0x2535))end elseif p_>=0xf6 then if p_<=0xf7 then if p_>0xf6 then p_,M=0x268-p_,0b10111011 else i=0b1111101 p_=H_<i and 0b110101101-p_ or(B.O[-0x3a83]or B:S(0x282,0x31f,-0x3a83))end else H_,M,Q,i,p_,n_,G=b_[0b111][1][b_[0b111][0b11]],b_[0b1001][1][b_[0b1001][0b11]],z,K,B.O[0x6c22]or B:S(0x430,0b10,0x6c22),b_[0b100][1][b_[0b100][0b11]],0b1111111 end elseif p_>0xf4 then i=0b110 p_=H_>i and(B.O[-0x465d]or B:Q(0xa187,0x2c,0b10111,-0x465d))or 0x111-p_ elseif p_<=0b11110011 then p_,w=B.O[0x6398]or B:Q(0xa154,0x3a,0x97,0x6398),z else i=0xc6 p_=H_>i and p_+-0b11000111 or(B.O[-0x1221]or B:T(0b10011000,-0x1221))end elseif p_<0x113 then if p_>0x10a then if p_<=0x10d then i[0x95df]=G N,g,p_,P,R_=b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],B.O[0x5828]or B:Q(0xa752,0x35a,0b111111100,0x5828),B.O[-0x38e2]or B:P(B.q"pURN",B.q"qW",-0x38e2),b_[1][1][b_[1][0b11]]else p_,i[0xc252]=B.O[-0x254e]or B:R(0x201186d6,0x3788b020,0x3799b4c4,-0x254e),G end elseif p_<=0x108 then if p_<0b100000111 then p_,M=B.O[-0x24aa]or B:Q(0xa155,0x15,0x15c,-0x24aa),1 elseif p_>0b100000111 then G,r=0b101001,0b11101100 p_=M<=G and(B.O[0x42d2]or B:T(0x33b,0x42d2))or 0x30e-p_ else p_,M=p_+0x6a,1 end else J,i=0b11000000,0x30 p_=H_>=i and 0x3e36c/p_ or 0x386-p_ end elseif p_>=0x117 then if p_<=0x119 then if p_<=0x117 then p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0b1010000 else p_,M=0x28a-p_,0b10111011 end else i=0b11010001 p_=H_>i and 0x4d7-p_ or 0x41b-p_ end elseif p_<=0x114 then if p_>0b100010011 then p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),1 else i=0b100010110 p_=H_<i and p_+0x21a or(B.O[-0x49ab]or B:S(0b100100010,0x32a,-0x49ab))end else M=0xee p_=h_>M and(B.O[0x9cd]or B:S(0b1110,0xa2,0x9cd))or(B.O[-0x24aa]or B:T(0b101110001,-0x24aa))end elseif p_<=0b1100110 then if p_<0b111010 then if p_>=0b11110 then if p_>0b101010 then if p_<=0b101101 then if p_<=0x2c then if p_>0b101011 then i=0b110101 p_=H_>=i and p_+0b10000000 or 0x53-p_ else L=L+K p_=K>0 and 0xf99-p_ or(B.O[0x3341]or B:R(0x348f8c96,0x529bb1d2,0x769fb53e,0x3341))end else J,i=0x41,0xde p_=H_<i and 0x348-p_ or(B.O[-0x6e6e]or B:T(0x2df,-0x6e6e))end elseif p_<=0x32 then i=0x5c p_=H_>i and 0x340-p_ or(B.O[0x43ea]or B:R(0x5230f8d4,0x474dc500,0x577dd736,0x43ea))else P,p_,g,N,O=b_[1][1][b_[1][0b11]],0xfde-p_,"B",b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_<=0b100101 then if p_>=0x24 then if p_<=0b100100 then i=0b10010011 p_=H_>=i and(B.O[-0x332a]or B:Q(0xa165,0,1,-0x332a))or 0x16ec/p_ else p_,Q=p_+0x8d,1/0 end elseif p_<=0b11110 then H_=0b101 p_=n_==H_ and(B.O[0x4006]or B:S(0b11011000,0x40,0x4006))or 0x1086/p_ else i,J=0b10100001,0b100100 p_=H_<=i and p_+0xaa or(B.O[-0x56d5]or B:T(0xaa,-0x56d5))end elseif p_<=0x29 then if p_>0x27 then p_,K=p_+0x43,n_ else i=0b110001 p_=H_<=i and(B.O[0x7d82]or B:S(0x102,0x108,0x7d82))or 0x63c9/p_ end else e=e+c_ p_=c_>0 and 0x13152/p_ or 0xd36-p_ end elseif p_>0b1011 then if p_>=0x16 then if p_<=0b11001 then if p_<=0x16 then i=0x137 p_=H_<=i and(B.O[-0x6689]or B:T(0x341,-0x6689))or(B.O[-0x5fdc]or B:S(0x102,0b101000010,-0x5fdc))else i=0b11001 p_=H_>=i and(B.O[0x37df]or B:R(2150405698,0x4c2913dd,3425515703,0x37df))or 0x39f-p_ end else i=0b11 p_=H_<=i and 0x1f80/p_ or p_+0b101000000 end elseif p_<=0b1100 then R_=0 p_=G==R_ and p_+0x2ab or 0xd74/p_ else i=0x75 p_=H_>=i and(B.O[0x1439]or B:S(0b100010001,0x1b9,0x1439))or 0x296-p_ end elseif p_<=0b101 then if p_<=0b100 then if p_<0b10 then z=0 e,c_,L=z,1,0b100 p_=L~=L and 0b11110011/p_ or(B.O[0x6ca4]or B:S(0x630,0x49c,0x6ca4))elseif p_>0b10 then J,i=0b100,0b10000 p_=H_>=i and 0xa6-p_ or 0x310/p_ else L,z,p_,e,w=b_[0b110][1][b_[0b110][0b11]],"B",B.O[0x5977]or B:T(0xe14,0x5977),b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]]end else i,H_=0,b_[0b1100][1][b_[0b1100][0b11]]R_,G,P=0b100,i,1 p_=R_~=R_ and 0x357/p_ or p_+0x7cb end elseif p_>=0b1001 then if p_<=0b1001 then J,G,M,p_,i,r,R_=0b1110,b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],0x4890/p_,B.O[0xe3f]or B:P(B.q"U=?l",B.q"Tm",0xe3f),0x51,b_[0b110][1][b_[0b110][0b11]]else i=0b1000011 p_=H_>=i and(B.O[-0x38c3]or B:R(0x841ac94,3898164658,3898164709,-0x38c3))or p_+0xc2 end else i=0x63 p_=H_>=i and(B.O[-0x789b]or B:R(0xd42acd6,3512111520,3713438208,-0x789b))or p_+0x2b4 end elseif p_>0b1010011 then if p_>=0b1011101 then if p_>0x63 then if p_>0b1100100 then i=0b1101110 p_=H_>=i and 0x76-p_ or 0x3b4-p_ else p_,_,C_,y=0b100000100-p_,0b1000111,w,0x35 end elseif p_>=0x61 then if p_<=0b1100001 then e="c"p_,z,e=0x4dad0/p_,e..w,b_[1][1][b_[1][0b11]]c_,L,K=b_[0b10][1][b_[0b10][0b11]],z,b_[0b110][1][b_[0b110][0b11]]else e,p_,L,q=b_[0b1011][1][b_[0b1011][0b11]],B.O[-0x2047]or B:T(0x814,-0x2047),z,0x55 end elseif p_>0b1011101 then K=K+Q p_=Q>0 and p_+0xc8a or(B.O[-0x1475]or B:Q(0xa981,0x842,0b1001110,-0x1475))else H_,i,M,p_,G=b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],B.O[-0x6dd5]or B:P(B.q")r|",B.q"=>",-0x6dd5),B.O[0x4ba9]or B:R(0x27636df6,2572444508,3212307550,0x4ba9),b_[0b110][1][b_[0b110][0b11]]end elseif p_<=0x57 then if p_<=0x55 then if p_<=0x54 then R_=i[0xc252]G=e[R_]p_=y<v and(B.O[-0x5b50]or B:Q(0xa106,0x26,0b11101,-0x5b50))or p_+0b11111111 else R_,M,p_,G,Q,i,H_=0x7f,b_[0b111][1][b_[0b111][0b11]],B.O[0x30f8]or B:S(0xe00,0xf67,0x30f8),n_,b_[0b100][1][b_[0b100][0b11]],b_[0b1001][1][b_[0b1001][0b11]],e end else i=0b1000110 p_=H_<i and(B.O[0x5858]or B:R(0x4cf948e,2287964165,2363472360,0x5858))or(B.O[-0x2f80]or B:T(0x3bc,-0x2f80))end elseif p_>0b1011010 then p_,k,o,u,A=B.O[0x43bb]or B:R(0x2ad97,3386053467,3386056204,0x43bb),b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],"B"else i,J=0b10100111,0b10011101 p_=H_>i and 0x3e2-p_ or 0xb23e/p_ end elseif p_<=0x44 then if p_>0x3d then if p_<=0x43 then if p_<=0b111111 then O,N,g,p_,G,P,R_=0x7f,i,b_[0b1001][1][b_[0b1001][0b11]],B.O[0x4124]or B:T(0xcbd,0x4124),b_[0b100][1][b_[0b100][0b11]],b_[0b111][1][b_[0b111][0b11]],n_ else l,_=0x90,0b10001000 p_=G and(B.O[-0x6746]or B:Q(0xa2d7,0b11011100,0b100100100,-0x6746))or p_+0x28d end else p_,j=0b1000101-p_,""end elseif p_>=0x3c then if p_>0b111100 then i=0b1001001 p_=H_>i and(B.O[-0x5f34]or B:R(0x41882944,0xb6e847d,0x4bee8544,-0x5f34))or 0xf7-p_ else H_,Q=0b110,nil p_=n_==H_ and 0b100101011-p_ or(B.O[-0x7e9e]or B:Q(0xa1e5,0b10011,0b11010,-0x7e9e))end elseif p_>0b111010 then p_,Q=0xed-p_,H_[M]else H_,M,p_,Q,i="B",b_[0b10][1][b_[0b10][0b11]],0x7e7-p_,b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_<=0b1001111 then if p_<=0x4b then if p_>0b1001000 then y,_,L,p_,v=0x4e,0xb0,c_,B.O[-0x290c]or B:S(0b11000000,0b10001110,-0x290c),0xa9 elseif p_<=0x46 then i,r=0x28,0xd7 p_=H_>=i and p_+0x4e or 0x21a2/p_ else H_=0 i,M,G=0b100,H_,1 p_=i~=i and p_+0x30 or p_+0x906 end else w=0 z,L,e=w,1,0b100 p_=e~=e and(B.O[0x2528]or B:R(0xf6c0,2187578240,2187582386,0x2528))or 0x37ae9/p_ end elseif p_>0x50 then n_,p_,M,Q,H_=b_[1][1][b_[1][0b11]],B.O[-0xe37]or B:S(0x208,0x500,-0xe37),b_[0b110][1][b_[0b110][0b11]],"B",b_[0b10][1][b_[0b10][0b11]]else i,J=0b11111,0xf5 p_=H_>=i and 0x227-p_ or 0x93d0/p_ end elseif p_>=0b10010000 then if p_>0xa1 then if p_<=0b10101000 then if p_>=0xa6 then if p_>0xa7 then i,J=0x5e,0b11010100 p_=H_<=i and 0x20d0/p_ or(B.O[-0x734b]or B:T(0b110,-0x734b))elseif p_<=0b10100110 then n_=0 Q,M,H_=n_,1,0b100 p_=H_~=H_ and(B.O[-0x68]or B:S(0,0b101001,-0b1101000))or(B.O[0x5d88]or B:R(0x44aba49f,0x281b2ba9,0x6cbb2757,0x5d88))else z,p_,d_,s_=e,p_+-0x44,0xf2,0b1110101 end elseif p_>0xa3 then J,i,t_=0x65,c_[Q],0b11101011 P,R_=0,i[0xc252]G=R_~=P p_=G and(B.O[0x2bc9]or B:Q(0xa141,0b111,0b1001001,0x2bc9))or p_+-0x61 elseif p_<=0xa2 then i=0b10011 p_=H_<=i and p_+0b11101011 or 0x2a2-p_ else i,J=0x7b,0x41 p_=H_>=i and(B.O[0x2d7e]or B:S(0x80,0b100001,0x2d7e))or(B.O[0x73d]or B:T(0b1100110,0x73d))end elseif p_>0xab then if p_>0xac then H_=1 p_=n_==H_ and(B.O[0x7226]or B:S(0b10000001,0x87,0x7226))or(B.O[0x39e5]or B:T(0xc8,0x39e5))else i=0x39 p_=H_<=i and 0x47a-p_ or(B.O[0x4f8]or B:S(0x201,0x332,0x4f8))end elseif p_<=0xaa then if p_>0b10101001 then i=0xa9 p_=H_<=i and p_+-0b1010000 or(B.O[0x38f]or B:R(0x909bcb6,0x4d651f23,0x4d6d1ff1,0x38f))else p_,M=p_+0xc8,1 end else p_,M=p_+-0x70,i end elseif p_<0x9a then if p_>0b10010100 then if p_<=0x98 then J,i=0b11001,0xc0 p_=H_<=i and p_+0b10001011 or 0x11c68/p_ else I,e,D_,l=0x2c,0,0b10000010,0xc4 c_,L,K=0b100,e,1 p_=c_~=c_ and(B.O[-0x6332]or B:Q(0xa1e4,0b111000,0x6e,-0x6332))or(B.O[-0x40cf]or B:Q(0xa80b,0x136,0x40,-0x40cf))end elseif p_>0x93 then J,i=0b1001011,0b101011 p_=H_<=i and 0x2d6-p_ or(B.O[0x3464]or B:S(0,0x208,0x3464))elseif p_>=0b10010010 then if p_>0b10010010 then i=0b11001 p_=H_>i and(B.O[0x2962]or B:T(0x1c6,0x2962))or 0x1c9a7/p_ else p_,R_,i,M,G=B.O[-0x435e]or B:Q(0xa12d,0xb12,0b100110101,-0x435e),b_[0b110][1][b_[0b110][0b11]],"B",b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]]end else R_=0 g,P,N=0b100,R_,1 p_=g~=g and(B.O[-0x5834]or B:Q(0xa159,0b1110101,0x1b,-0x5834))or(B.O[0x301b]or B:R(0x2088ec93,0x3113a036,0x319be6b3,0x301b))end elseif p_<0b10011101 then if p_>=0b10011011 then if p_<=0b10011011 then G=0b10110000 p_=M<=G and(B.O[0x2c1]or B:S(0x200,0x201,0x2c1))or(B.O[-0x3218]or B:S(0xad,0x298,-0x3218))else G,_,p_,l=R_,0xd7,B.O[0x63eb]or B:R(0x34088c86,0x28014c48,0x3c096c54,0x63eb),0x1b end else i=0b1011 p_=H_>=i and 0b10011110-p_ or(B.O[0x2a49]or B:S(0b11100100,0b11010001,0x2a49))end elseif p_<=0b10100000 then if p_<0x9e then z,e={},0 z[0x810f]=e z[0x7846]=e z[0x235e]=e L={}e=L z[0xf888]=e L={}e=L z[0xec9d]=e L={}e=L z[0x2b3e]=e z[0xcd6c]=j z[0xcb47]=C_ w=z return w elseif p_<=0b10011110 then p_,M=B.O[-0x24aa]or B:S(0x51,0x120,-0x24aa),0x29 else w=0 p_=C_==w and(B.O[0x3529]or B:Q(0xa145,0b110,0x3e,0x3529))or(B.O[0x13d4]or B:R(0x4422c82,4026794316,4098261302,0x13d4))end else i=0x84 p_=H_>=i and 0b100100011-p_ or 0b110010111-p_ end elseif p_<0x81 then if p_<0x73 then if p_<0x6b then if p_<=0b1101001 then i=0x9f p_=H_<i and(B.O[-0x563c]or B:S(0xa2,0x1a3,-0x563c))or(B.O[-0x231b]or B:Q(0xa065,0b100,1,-0x231b))else z="c"z,w=b_[1][1][b_[1][0b11]],z..C_ c_,e,p_,L=b_[0b110][1][b_[0b110][0b11]],w,B.O[0x7799]or B:R(2202504446,2436153091,2474097437,0x7799),b_[0b10][1][b_[0b10][0b11]]end elseif p_<0b1101100 then p_,i=0x5aa-p_,B.O[-0x3a2]or B:P(B.q"WiS",B.q"Sp",-0x3a2)M,i=i..H_,b_[1][1][b_[1][0b11]]G,P,R_=M,b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]]elseif p_<=0x6c then n_,p_,Q=b_[0b1011][1][b_[0b1011][0b11]],B.O[-0x5488]or B:T(0x515,-0x5488),K else p_,C_=0x454d/p_,""end elseif p_>0x7a then if p_<=0b1111011 then i=0b100101 p_=H_<=i and(B.O[-0x29c3]or B:R(2705368230,0x38041865,3108248206,-0x29c3))or(B.O[0x4dcc]or B:S(0,0x2f4,0x4dcc))else i=0b1010110 p_=H_>i and 0x17a80/p_ or 0b111100110-p_ end elseif p_<=0x78 then if p_>0x77 then Q=H_ p_=d_>s_ and(B.O[0x2cf4]or B:R(0x4153ac94,2551558273,3646403019,0x2cf4))or 0x4470/p_ elseif p_<=0b1110011 then H_=0b11 p_=n_==H_ and(B.O[0x4496]or B:T(0x25,0x4496))or(B.O[0x4b5d]or B:R(0x13008d74,0x7f0831d3,0x7f083141,0x4b5d))else n_,p_,H_,i,G,M,Q=b_[0b100][1][b_[0b100][0b11]],B.O[0x557b]or B:S(0,0x943,0x557b),b_[0b111][1][b_[0b111][0b11]],K,0b1111111,b_[0b1001][1][b_[0b1001][0b11]],z end else C_,w,j,f,p_,z="B",b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],0b11000011,B.O[0x5b2e]or B:Q(0xa505,0x72c,0x58,0x5b2e),b_[0b110][1][b_[0b110][0b11]]end elseif p_<0x89 then if p_>=0x86 then if p_>=0b10000111 then if p_<=0x87 then p_,Q=B.O[0x4b5d]or B:T(0xb2,0x4b5d),0/0 else Q=Q+M p_=M>0 and(B.O[0x2df5]or B:Q(0xa29d,0x12f,0b11001,0x2df5))or(B.O[0x6e8a]or B:T(0x935,0x6e8a))end else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0x84 end elseif p_>0b10000010 then i=0b10010011 p_=H_<=i and(B.O[-0x58ba]or B:T(0x280,-0x58ba))or 0x186-p_ elseif p_<=0b10000001 then p_,G=B.O[0x3d4b]or B:R(2203561254,3813754937,3814148952,0x3d4b),0 else i=0b10001001 p_=H_<=i and(B.O[0x5801]or B:T(0x14a,0x5801))or(B.O[-0x7d01]or B:R(2281877149,2282931080,2282930898,-0x7d01))end elseif p_<=0b10001100 then if p_<=0b10001011 then if p_<=0x8a then if p_>0x89 then Q,M,p_,n_,H_="B",b_[0b110][1][b_[0b110][0b11]],B.O[0x7da5]or B:Q(0xa975,0x86b,0x707,0x7da5),b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]]else i=0b1100 p_=H_>i and 0xdbf3/p_ or p_+0x216 end else i,J=0x1b,0x26 p_=H_>i and p_+-0x3b or(B.O[0x2906]or B:R(0x1add5,0xaf93040,0xaf9315a,0x2906))end else J,i=0b110011,0x96 p_=H_>i and(B.O[-0x4d70]or B:S(0x41,0x396,-0x4d70))or(B.O[0x63]or B:Q(0xa364,0b100,0b1101,0x63))end elseif p_>0x8d then L=L+K p_=K>0 and 0x41098/p_ or 0x2d7-p_ else H_=0b10 p_=n_==H_ and(B.O[0x7ae4]or B:R(0x1450cb6,0x6c110a2,0x7c5b0a7,0x7ae4))or(B.O[-0xd77]or B:S(0,0b1110011,-0xd77))end elseif p_>0x21d then if p_>=0x27c then if p_<=0x2b5 then if p_>0x29f then if p_>0x2aa then if p_<=0x2b0 then if p_>0x2ac then i=0xaf p_=H_<=i and(B.O[0x4067]or B:R(3758239282,2584986787,4195599545,0x4067))or 0x582-p_ elseif p_<=0x2ab then M=0x84 p_=J<M and(B.O[-0x24aa]or B:S(0x21,0b101110000,-0x24aa))or 0x91e79/p_ else p_,M=0x3d9ec/p_,0x29 end elseif p_>0x2b4 then p_,i[0xc252]=B.O[-0x15a3]or B:T(0xab1,-0x15a3),G g,R_,P,N=b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],"B",b_[0b110][1][b_[0b110][0b11]]else p_,P,N,g,R_=0x893-p_,"B",b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]]end elseif p_>=0x2a5 then if p_<=0x2a8 then if p_>0x2a7 then p_,M=B.O[-0x24aa]or B:Q(0xa004,0x126,0b1001011,-0x24aa),0b10111011 elseif p_<=0x2a5 then i=0b11001000 p_=H_<=i and(B.O[-0x74a8]or B:R(0x205da8f6,0x21575781,0x215f5624,-0x74a8))or p_+-0x62 else p_,M=0x3d2b7/p_,0x29 end else p_,M=0x41b-p_,0x29 end elseif p_>0x2a2 then i=0x14c p_=H_<=i and(B.O[0x3425]or B:S(0x316,0x3f2,0x3425))or(B.O[-0x5616]or B:T(0x3ef,-0x5616))elseif p_<=0x2a1 then G=0x5b p_=M>=G and(B.O[-0x1f07]or B:Q(0xa175,0xfa,0x20b,-0x1f07))or(B.O[-0x2bb8]or B:R(0x60816f16,2242114890,3852727411,-0x2bb8))else p_,M=B.O[-0x24aa]or B:Q(0xa044,0b1101111,0b10,-0x24aa),0b10000100 end elseif p_<=0x28c then if p_<0x285 then if p_<0x27d then i=0b101110 p_=H_<=i and(B.O[-0x2668]or B:Q(0xa31c,0b100001010,0xfb,-0x2668))or 0x61338/p_ elseif p_<=0x27d then p_,M=p_+-0b100001100,0x5b else p_,M=p_+-0x10f,0b10111011 end elseif p_>0x28b then p_,i[0x5332]=0x1130-p_,G elseif p_<=0x286 then if p_<=0x285 then i=0x46 p_=H_>i and(B.O[0x1bb6]or B:T(0x332,0x1bb6))or 0x319a7/p_ else J,i=0b10001110,0x71 p_=H_>=i and 0x370ae/p_ or 0x541-p_ end else P,N,g,p_,R_=B.O[-0x38e2]or B:P(B.q"gwcu",B.q"xB",-0x38e2),b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]],0x19f4c7/p_,b_[1][1][b_[1][0b11]]end elseif p_<0x291 then if p_<=0x28f then if p_>0x28d then J,i=0xea,0x33 p_=H_>i and p_+0x78 or 0x673-p_ else R_=R_(P,g,N)P,p_,g=N,B.O[0x7e51]or B:T(0x2f9,0x7e51),1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ end else p_,M=0x3b190/p_,0b11011000 end elseif p_<0x298 then i[0xf69c]=G p_=J<=r and 0x49c-p_ or 0x2592e4/p_ elseif p_>0x298 then p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0xbb else Q=Q+M p_=M>0 and 0x217490/p_ or p_+0x80d end elseif p_>0x2d1 then if p_>=0x2d8 then if p_<=0x2e0 then if p_<0x2df then if p_<=0x2d8 then p_,N=p_+0x839,B.h(N(O,o))else A=A(u,k)u=0b111 p_,u=B.O[-0x6d33]or B:S(0x984,0x820,-0x6d33),G*u end elseif p_>0x2df then p_,M=0x424e0/p_,1 else J,i=0xc0,0xe3 p_=H_<=i and 0x4292d/p_ or(B.O[0x602b]or B:Q(0xa211,0xdc,0b1000110,0x602b))end elseif p_>0x2e1 then p_,M=0x42aa4/p_,0xaa else i[0xb54d]=G p_=J>t_ and(B.O[0x760d]or B:Q(0xa3c0,0b1011,0b100,0x760d))or(B.O[-0x49af]or B:T(0x298,-0x49af))end elseif p_>0x2d5 then if p_>0x2d6 then M=0b100 p_=J<=M and p_+-0b1011110 or 0x448-p_ else p_,M=p_+-0x165,0xab end elseif p_>=0x2d3 then if p_<=0x2d3 then i,J=0x40,0b1111110 p_=H_>i and 0x343f8/p_ or 0x52f62/p_ else P,p_,g,R_,N="B",0xbf6-p_,b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]]end else p_,M=p_+-0b101100001,0b10100110 end elseif p_<0x2c5 then if p_<0x2bb then if p_<0x2b8 then p_,i=B.O[-0x11ad]or B:S(0b10000,0x192,-0x11ad),""elseif p_>0x2b8 then i=0b1011111 p_=H_>i and(B.O[-0x3d32]or B:S(0x300,0b101010010,-0x3d32))or(B.O[-0x6a1d]or B:Q(0xa145,0x18,0xfc,-0x6a1d))else M=1 p_=r>M and(B.O[-0x24aa]or B:S(0b101110001,0b1000001,-0x24aa))or(B.O[-0x27a1]or B:T(0x153,-0x27a1))end elseif p_>=0x2bd then if p_<=0x2bd then p_,R_,N,P,g=p_+0xc7c,b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],"B",b_[0b10][1][b_[0b10][0b11]]else P=P+N p_=N>0 and(B.O[-0x2297]or B:T(0xf1b,-0x2297))or(B.O[-0x65a6]or B:T(0xa25,-0x65a6))end else p_,M=0x3ef8b/p_,0b101001 end elseif p_<0x2cc then if p_<0x2c7 then n_=n_(Q,B.i(H_))M,H_,z,p_,Q=0x80,K,n_,0x50f-p_,b_[0b101][1][b_[0b101][0b11]]elseif p_<=0x2c7 then p_,M=B.O[-0x24aa]or B:S(0x150,0x61,-0x24aa),0b10111011 else p_,M=0x40248/p_,0b10111011 end elseif p_>0x2d0 then p_,i[0x735e]=0x293be4/p_,G elseif p_>0x2cc then p_,G=0x662-p_,0 else p_,M=0x4080c/p_,0xbb end elseif p_>=0x250 then if p_>=0x265 then if p_<=0x271 then if p_<0x26a then if p_>=0x267 then if p_<=0x267 then M=0b10000100 p_=J>=M and(B.O[-0x24aa]or B:T(0b101110001,-0x24aa))or(B.O[-0x183e]or B:Q(0xa045,0b11110,0b1000,-0x183e))else p_,M=0x37959/p_,0x84 end else p_,M=0x37395/p_,1 end elseif p_<0x26e then if p_>0x26a then p_,M=B.O[-0x24aa]or B:S(0b100100001,0x50,-0x24aa),0xee else p_,M=0x37aca/p_,0x5b end elseif p_>0x26e then i[0x96d4]=G p_=J>r and(B.O[-0x254e]or B:T(0xea4,-0x254e))or 0x5d4-p_ else M=0b10000100 p_=J>=M and 0x7cac6/p_ or p_+-0b11111101 end elseif p_>=0x274 then if p_>0x278 then i=0xa0 p_=H_>i and(B.O[0x72b4]or B:S(0b100010101,0b100011100,0x72b4))or(B.O[-0x1e27]or B:T(0x30c,-0x1e27))elseif p_>0x274 then i[0xa0e2]=G N,P,R_,p_,g=b_[0b110][1][b_[0b110][0b11]],B.O[0xe3f]or B:P(B.q"uiBv",B.q"lK",0xe3f),b_[1][1][b_[1][0b11]],B.O[0x5c34]or B:S(0x228,0x218,0x5c34),b_[0b10][1][b_[0b10][0b11]]else i=0b1011011 p_=H_<i and 0x4b1-p_ or(B.O[-0xe1c]or B:T(0xdf,-0xe1c))end elseif p_<=0x272 then M=0xbb p_=m<M and 0x38652/p_ or p_+0x26 else p_,i[0x59a2]=B.O[-0x254e]or B:R(0x4118ecdf,0x26194084,0x67194e69,-0x254e),G end elseif p_<0x259 then if p_<0x254 then if p_>=0x251 then if p_<=0x251 then i=0x50 p_=H_>i and(B.O[-0x1cdb]or B:T(0x1e3,-0x1cdb))or(B.O[0x6a0d]or B:T(0x323,0x6a0d))else p_,M=0x359a3/p_,1 end else i=0b1100 p_=H_>=i and(B.O[0x44d7]or B:Q(0xa144,0b1010,0x7e,0x44d7))or(B.O[0x7b25]or B:S(0x2d6,0x216,0x7b25))end elseif p_<0x255 then i=0b100000111 p_=H_>i and(B.O[-0x42a0]or B:S(0b1001000,0x26e,-0x42a0))or 0x4b0-p_ elseif p_<=0x255 then i=0b10000110 p_=H_<=i and(B.O[-0x53f8]or B:T(0x3ff,-0x53f8))or(B.O[0x7a71]or B:R(0x1209b690,0x70cd0f21,0x72cd1c88,0x7a71))else R_=R_(P,g,N)P,g=N,1 P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ p_=r<=g and(B.O[-0x5f09]or B:R(0x20480c6e,0x3808049c,0x3848a62f,-0x5f09))or p_+-0x51 end elseif p_<0x25e then if p_>=0x25c then if p_>0x25c then M=0b10101010 p_=J>=M and(B.O[-0x24aa]or B:R(2240298199,0x140817d9,2508756648,-0x24aa))or 0x371-p_ else p_,M=B.O[-0x24aa]or B:S(0b1000000,0x171,-0x24aa),0xaa end else p_,M=B.O[-0x24aa]or B:Q(0xa145,0b101011000,0b11001,-0x24aa),0xbb end elseif p_>=0x25f then if p_>0x25f then p_,M=B.O[-0x24aa]or B:Q(0xa034,0b11101111,0x82,-0x24aa),0b10111011 else p_,M=0x3d0-p_,0b100 end else i[0x5332]=G g,p_,N,P,R_=b_[0b10][1][b_[0b10][0b11]],0x1255-p_,b_[0b110][1][b_[0b110][0b11]],"B",b_[1][1][b_[1][0b11]]end elseif p_<0x237 then if p_>=0x227 then if p_>0x231 then if p_>0x233 then M=0b10000100 p_=J<M and 0x2436c/p_ or(B.O[-0x24aa]or B:Q(0xa115,0x9d,0x84,-0x24aa))else M=0x29 p_=J>=M and 0xadbd/p_ or(B.O[-0x24aa]or B:T(0x171,-0x24aa))end elseif p_>=0x22b then if p_<=0x22b then p_,M=0x31ffb/p_,0xbb else i=0b10010101 p_=H_<i and 0x12144/p_ or 0x3c89a/p_ end elseif p_<=0x227 then p_,i[0xa0e2]=B.O[0x2781]or B:T(0xfc7,0x2781),G g,N,R_,P=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]],B.O[-0x2af6]or B:P(B.q"6hRy",B.q"C;",-0x2af6)else R_,p_,g,P,N=b_[1][1][b_[1][0b11]],B.O[-0x4018]or B:Q(0xa3af,0x2dc,0x61d,-0x4018),b_[0b10][1][b_[0b10][0b11]],B.O[-0x2af6]or B:P(B.q"vgf)",B.q"js",-0x2af6),b_[0b110][1][b_[0b110][0b11]]end elseif p_<=0x222 then if p_>0x220 then M=0x29 p_=r>M and 0x31302/p_ or 0x37962/p_ elseif p_<=0x21e then p_,M=B.O[-0x24aa]or B:R(0x21d2bc92,0x1d29284,0x21d293f5,-0x24aa),1 else p_,M=p_+-0xaf,0x29 end elseif p_>0x223 then G=1 p_=M>G and 0x81e8c/p_ or(B.O[-0x1a89]or B:R(0x30a4fc16,0x8101060,0x38b452de,-0x1a89))else p_,M=B.O[-0x24aa]or B:Q(0xa055,0xfb,0b1100110,-0x24aa),0x50 end elseif p_>0x242 then if p_>0x24a then if p_>0x24b then p_,M=0x3bf-p_,0b101001 else g,p_,R_,P,N=b_[0b10][1][b_[0b10][0b11]],B.O[-0x7635]or B:S(0xc00,0b101101010,-0x7635),b_[1][1][b_[1][0b11]],"B",b_[0b110][1][b_[0b110][0b11]]end elseif p_>=0x249 then if p_>0x249 then Q=Q(H_,M)n_=not Q p_=n_ and(B.O[-0x1132]or B:Q(0xa134,0x73,0x10,-0x1132))or 0x274-p_ else p_=K<=0 and 0x106cb0/p_ or 0x10d2-p_ end else p_,M=p_+-0xd2,0x50 end elseif p_<0x23e then if p_<=0x238 then if p_>0x237 then p_,R_=0x1bbe38/p_,R_(P,g,N)g,P=0b10,N P=P+g b_[0b110][1][b_[0b110][0b11]],G=P,R_ else p_,M=0x33147/p_,0b11101110 end else i=0b1011001 p_=H_<=i and(B.O[0x5249]or B:Q(0xa008,0b1000100,0x302,0x5249))or(B.O[0x5ebe]or B:R(0x22842c96,0x215503d4,0x23d58258,0x5ebe))end elseif p_<0x241 then if p_<=0x23e then R_,g,N,p_,P=b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],p_+0x734,"B"else i[0xa0e2]=G R_,N,p_,g,P=b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],0x1066-p_,b_[0b10][1][b_[0b10][0b11]],"B"end elseif p_>0x241 then i=0x2a p_=H_>i and p_+0b110000001 or(B.O[-0x4b2b]or B:S(0b10010000,0x100,-0x4b2b))else i[0x5332]=G P,R_,N,p_,g=B.O[-0x38e2]or B:P(B.q"3SR^",B.q"HU",-0x38e2),b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[-0x78ea]or B:T(0xfbe,-0x78ea),b_[0b10][1][b_[0b10][0b11]]end elseif p_>=0x1b0 then if p_>=0b111101100 then if p_>=0x206 then if p_<=0x211 then if p_>0x20b then if p_>0x210 then i=0b10 p_=H_<=i and(B.O[-0x4afe]or B:T(0x290,-0x4afe))or p_+0x6c elseif p_>0x20c then P,O,p_,N,A,g,o=b_[0b100][1][b_[0b100][0b11]],b_[0b1001][1][b_[0b1001][0b11]],B.O[-0x6a7c]or B:Q(0xa34d,0xb5,0x5d2,-0x6a7c),b_[0b111][1][b_[0b111][0b11]],0b1111111,H_,R_ else p_,M=0x2f34c/p_,0b10111011 end elseif p_<=0x20a then if p_>0x208 then i=0xea p_=H_<=i and(B.O[-0x5812]or B:T(0x3dc,-0x5812))or(B.O[-0x10d7]or B:T(0b100010101,-0x10d7))elseif p_>0x206 then i=0b101100 p_=H_>i and 0x4d918/p_ or(B.O[-0x61c0]or B:Q(0xa171,0b100110,0xa1,-0x61c0))else R_,p_,P,N,g=b_[1][1][b_[1][0b11]],0xf9432/p_,B.O[0xe3f]or B:P(B.q"@`wB",B.q"&H",0xe3f),b_[0b110][1][b_[0b110][0b11]],b_[0b10][1][b_[0b10][0b11]]end else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0xee end elseif p_>0x219 then if p_<=0x21b then i=0x28 p_=H_<=i and(B.O[-0x2b58]or B:R(0x4a4aa87a,0x23f1668,0x4a7f14ce,-0x2b58))or 0x74fc3/p_ else p_,M=0x30bcd/p_,0xee end elseif p_>=0x216 then if p_>0x216 then p_,M=B.O[-0x24aa]or B:Q(0xa174,0b100011010,0x47,-0x24aa),0b10000100 else p_,M=p_+-0xa5,0b101001 end else p_,M=0x2fd63/p_,1 end elseif p_<=0x200 then if p_<0b111111001 then if p_>=0b111110001 then if p_<=0x1f1 then p_,i[0xa0e2]=0x1aa047/p_,G R_,N,P,g=b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[0xe3f]or B:P(B.q"xy-i",B.q"g#",0xe3f),b_[0b10][1][b_[0b10][0b11]]else i=0x44 p_=H_>=i and(B.O[-0x4f3]or B:S(0x50,0b10010100,-0x4f3))or(B.O[-0x5ace]or B:Q(0xa047,0b100,1,-0x5ace))end else p_,i[0xa0e2]=B.O[0x4172]or B:S(0x405,0xc54,0x4172),G R_,N,P,g=b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[0xe3f]or B:P(B.q"LN`n",B.q"eg",0xe3f),b_[0b10][1][b_[0b10][0b11]]end elseif p_>=0x1fc then if p_>0b111111100 then i,J=0b10100,0b10000 p_=H_<=i and 0x62e00/p_ or(B.O[-0x7e37]or B:R(0x1052493,0x6849c0c6,0x694dc946,-0x7e37))else p_,M=0x2dc3c/p_,0b11101110 end elseif p_<=0x1f9 then M=1 p_=J>M and(B.O[-0x24aa]or B:R(3305696800,3590497792,3607816135,-0x24aa))or(B.O[-0x6663]or B:R(0x4c4c2dd4,0x2823916a,0x6c6f90bc,-0x6663))else J,i=0x83,0xa4 p_=H_<=i and 0x5e1-p_ or(B.O[-0x7371]or B:T(0x2d7,-0x7371))end elseif p_<0x203 then if p_<=0x201 then p_,g,N,P,R_=B.O[-0x5288]or B:T(0xf37,-0x5288),b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],"B",b_[1][1][b_[1][0b11]]else A,N,O,u,p_,o,k=b_[0b1001][1][b_[0b1001][0b11]],b_[0b100][1][b_[0b100][0b11]],i,g,0x4db-p_,b_[0b111][1][b_[0b111][0b11]],0x7f end elseif p_>=0x204 then if p_<=0x204 then p_,M=B.O[-0x24aa]or B:Q(0xa155,0b10001101,0xe4,-0x24aa),0x50 else i[0xa0e2]=G g,N,p_,P,R_=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[0x19a4]or B:Q(0xa14c,0x28d,0x5b5,0x19a4),B.O[-0x2af6]or B:P(B.q">%QX",B.q"*8",-0x2af6),b_[1][1][b_[1][0b11]]end else p_,M=0x2e653/p_,0x84 end elseif p_>0x1ca then if p_<0x1d8 then if p_<=0x1d2 then if p_<=0b111001111 then if p_>0x1ce then i=0b110110 p_=H_<=i and(B.O[0x647]or B:R(0x200a4b4,2285965616,2319522352,0x647))or 0x278-p_ else i=0b1101000 p_=H_<=i and p_+0b111110100 or(B.O[-0x15a]or B:Q(0xa3c9,0b11000,0x234,-0x15a))end else i=0b11000101 p_=H_>i and 0x3e3b6/p_ or p_+-0x54 end elseif p_<=0x1d6 then i=0x3f p_=H_>i and p_+0x20d or(B.O[0x249f]or B:S(0x41,0x367,0x249f))else i=0b100000 p_=H_>i and(B.O[-0x7bec]or B:S(0,0x321,-0x7bec))or p_+-0b11010100 end elseif p_>=0x1e0 then if p_<0x1e3 then p_,M=0x2b3e0/p_,0b10000100 elseif p_<=0x1e3 then M=1 p_=l<M and 0x6e415/p_ or(B.O[-0x24aa]or B:S(0b100110000,0x71,-0x24aa))else p_,i[0xa0e2]=B.O[-0x907]or B:Q(0xad45,0xb65,0x2e3,-0x907),G R_,P,g,N=b_[1][1][b_[1][0b11]],B.O[-0x38e2]or B:P(B.q"GiE&",B.q"4*",-0x38e2),b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_<0b111011001 then p_,M=0x2a858/p_,0b1010000 elseif p_>0x1d9 then i=0b11000011 p_=H_>i and(B.O[0x93e]or B:Q(0xa097,0x40,0b10000,0x93e))or(B.O[-0x395a]or B:T(0x346,-0x395a))else i=0x1c p_=H_<=i and 0x40173/p_ or 0x3aa9c/p_ end elseif p_>=0b110111101 then if p_>0x1c5 then if p_<=0b111001001 then if p_>0b111000110 then p_,M=0x33a-p_,0b1011011 else M=0b10101010 p_=J<=M and p_+-0x55 or p_+0x175 end else p_,i[0xa0e2]=B.O[-0x3af]or B:T(0xe09,-0x3af),G R_,g,N,P=b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],B.O[0xe3f]or B:P(B.q"pw+G",B.q"oB",0xe3f)end elseif p_>=0x1c0 then if p_>0b111000000 then p_,M=B.O[-0x24aa]or B:Q(0xa154,0xf4,0x7d,-0x24aa),0x84 else i[0x5332]=G p_,P,g,R_,N=B.O[0x2bca]or B:T(0x8df,0x2bca),"B",b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_>0x1bd then i[0xf69c]=G p_,N,R_,P,g=0xd48-p_,b_[0b110][1][b_[0b110][0b11]],b_[1][1][b_[1][0b11]],"B",b_[0b10][1][b_[0b10][0b11]]else p_,M=B.O[-0x24aa]or B:T(0b101110001,-0x24aa),0xee end elseif p_>=0b110111000 then if p_>0b110111001 then i=0b10010101 p_=H_<=i and 0x5d04c/p_ or p_+0b11110010 elseif p_<=0x1b8 then i=0x4b p_=H_<=i and 0x4c0-p_ or 0x3ce-p_ else i,r,J=0b1110110,0x37,0b11001111 p_=H_<=i and(B.O[-0x46a4]or B:S(0x111,0b10001100,-0x46a4))or 0x32f-p_ end elseif p_>0x1b5 then i=0x23 p_=H_>i and(B.O[0x4dc]or B:S(0xc0,0b100101,0x4dc))or 0x1de71/p_ elseif p_>0b110110000 then p_,M=0x275e5/p_,0b101001 else i=0xad p_=H_>i and 0x567c0/p_ or p_+0b11111000 end elseif p_<=0b101110100 then if p_<=0x15f then if p_<=0b101011000 then if p_>0b101010010 then if p_<0x156 then i=0x3d p_=H_<=i and(B.O[-0x1de2]or B:T(0x331,-0x1de2))or 0x293-p_ elseif p_>0b101010110 then p_,M=0x1efd8/p_,1 else p_,M=B.O[-0x24aa]or B:S(0x60,0b101010001,-0x24aa),0xe1 end elseif p_<0x14d then if p_<=0x14b then i=0b11000010 p_=H_>i and 0x308-p_ or p_+0b1011 else p_,M=B.O[-0x24aa]or B:S(1,0x171,-0x24aa),1 end elseif p_<=0b101001101 then i=0x64 p_=H_<=i and(B.O[-0x3d14]or B:R(0x53a02d56,0x48c11591,0x5be197cc,-0x3d14))or(B.O[0xefe]or B:S(0x210,0xf0,0xefe))else p_,R_=B.O[0x20c3]or B:Q(0xa448,0x94,0x4ae,0x20c3),b_[0b11][1][b_[0b11][0b11]]end elseif p_>=0b101011101 then if p_<0x15e then i=0b1110001 p_=H_>i and(B.O[-0x6c49]or B:R(0x10899c87,0x11c45204,0x11cd7339,-0x6c49))or 0x55602/p_ elseif p_>0b101011110 then P,N,p_,g,R_="B",b_[0b110][1][b_[0b110][0b11]],0xcea-p_,b_[0b10][1][b_[0b10][0b11]],b_[1][1][b_[1][0b11]]else p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0x5b end elseif p_>0x15a then i=0b100 p_=H_<=i and 0x281a0/p_ or 0x2c3-p_ elseif p_<=0b101011001 then i=0x8e p_=H_<=i and 0x2a5-p_ or(B.O[-0x16ed]or B:R(2415977621,0x1003d49,2432728963,-0x16ed))else i=0 p_=H_>i and(B.O[0x1404]or B:Q(0xa0c5,0,0x13,0x1404))or(B.O[0x3c5d]or B:Q(0xa040,0b1001000,0x2dc,0x3c5d))end elseif p_>=0x169 then if p_>0x171 then if p_<=0x173 then i=0xdf p_=H_>i and(B.O[-0x2e33]or B:Q(0xa135,0b10101101,0x23d,-0x2e33))or p_+0b111111010 else M=0b10000100 p_=r<M and 0x21834/p_ or(B.O[0x2087]or B:S(0x158,0b101011010,0x2087))end elseif p_>=0x16b then if p_<=0b101101011 then p_,M=B.O[-0x24aa]or B:R(0x2b00b896,0x22451021,0x2b451550,-0x24aa),0xbb else G,J={},0b10010110 G[0xcfc8]=H_ R_=0 G[0xa0e2]=R_ G[0x5332]=R_ G[0xf0e]=R_ G[0xe648]=R_ G[0xfa7d]=R_ G[0xc252]=R_ G[0xb54d]=R_ p_,G[0xf69c]=0xe7135/p_,R_ G[0x735e]=R_ G[0x59a2]=R_ G[0x95df]=R_ G[0x96d4]=R_ i,G,R_=G,b_[0b1010][1][b_[0b1010][0b11]],c_ P=i end elseif p_<=0x169 then i=0x13b p_=H_>i and 0x50d-p_ or 0x40de0/p_ else p_,M=0x2db-p_,0b100 end elseif p_>=0x166 then if p_<=0x167 then if p_<=0b101100110 then i=0x55 p_=H_>i and 0x46724/p_ or(B.O[-0x72b2]or B:T(0x3b3,-0x72b2))else p_,M=0x2d8-p_,1 end else p_,i[0xb54d]=0x73f-p_,G P,R_,g,N="B",b_[1][1][b_[1][0b11]],b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]]end elseif p_>0b101100001 then M=M+G p_=G>0 and(B.O[-0x3c38]or B:Q(0xa155,0x3aa,0x857,-0x3c38))or(B.O[-0x63b9]or B:S(0x215,0x4d8,-0x63b9))elseif p_<=0x160 then i,J=0b10111010,0xdc p_=H_<=i and 0x252-p_ or(B.O[-0x3b57]or B:Q(0xa140,0x63,0x5e,-0x3b57))else p_,i[0xa0e2]=B.O[-0x70f0]or B:R(0x60c4ae86,0x709a4740,0x70de4fba,-0x70f0),G R_,N,P,g=b_[1][1][b_[1][0b11]],b_[0b110][1][b_[0b110][0b11]],"B",b_[0b10][1][b_[0b10][0b11]]end elseif p_>0x193 then if p_<=0b110011101 then if p_<=0b110011010 then if p_<=0b110011000 then if p_>0x196 then p_,i[0xa0e2]=p_+0xd0c,G elseif p_<=0b110010100 then p_,M=B.O[-0x24aa]or B:R(0x6801bdd6,2449557664,4194392209,-0x24aa),0xab else i=0b11110101 p_=H_>i and p_+0x1d5 or 0x5f8d8/p_ end else R_=i[0xb54d]G=e[R_]p_=_<=l and(B.O[-0x3816]or B:S(0x252,0x155,-0x3816))or p_+-0xeb end elseif p_<=0x19b then p_,M=B.O[-0x24aa]or B:T(0x171,-0x24aa),0x50 else i=0b1110101 p_=H_<=i and 0x462d8/p_ or 0x3a1-p_ end elseif p_<=0b110100011 then if p_>0b110100001 then i=0x9b p_=H_<=i and 0x5847d/p_ or(B.O[-0x43b6]or B:S(0b11001010,0x3c0,-0x43b6))elseif p_>0b110011110 then M=0b101001 p_=T_<=M and(B.O[0x4dcc]or B:R(2172676828,2177144735,2177160491,0x4dcc))or 0x312-p_ else J,i=0b1011101,0b100001100 p_=H_>i and(B.O[-0x4fb6]or B:Q(0xa3c6,0b101100,0b111111110,-0x4fb6))or(B.O[-0x5424]or B:R(0x2074ed96,0x6504418,0x267444b9,-0x5424))end elseif p_<=0x1ac then p_,M=B.O[-0x24aa]or B:S(0x71,0x160,-0x24aa),0x29 else Q=Q+M p_=M>0 and(B.O[-0x2ebd]or B:T(0xcb7,-0x2ebd))or(B.O[0x3eb0]or B:Q(0xa105,0x49b,0x79d,0x3eb0))end elseif p_>=0x18c then if p_>=0x191 then if p_<0x192 then p_,M=B.O[-0x24aa]or B:R(0x8310cf6,0x3190c300,0x39b1e211,-0x24aa),0x5b elseif p_<=0x192 then R_=b_[0b1000][1][b_[0b1000][0b11]]p_,G=0x341-p_,R_[i]n_[Q]=G else M=0b10011110 p_=J<M and(B.O[-0x24aa]or B:S(0b100010000,0x171,-0x24aa))or(B.O[-0x5ace]or B:S(0x107,0b100000001,-0x5ace))end elseif p_>=0b110001101 then if p_<=0x18d then i=0x12 p_=H_>i and 0x52e-p_ or(B.O[0x59f0]or B:T(0x33d,0x59f0))else i=0b101001 p_=H_<=i and p_+0x8b or(B.O[0x6095]or B:T(0b11110000,0x6095))end else p_,M=B.O[-0x24aa]or B:S(0b110001,0b101110000,-0x24aa),0x29 end elseif p_>=0x181 then if p_<=0x185 then if p_>0x181 then M=0b10111011 p_=J>M and 0x2f6-p_ or(B.O[-0xd4b]or B:T(0x39b,-0xd4b))else M=0b1011011 p_=J>M and(B.O[0x1413]or B:S(0b100000000,0b1000,0x1413))or(B.O[-0x24aa]or B:Q(0xa155,0b10000000,0b11100001,-0x24aa))end else p_,M=B.O[-0x24aa]or B:R(0x1068acae,0x63680d9b,0x73680cca,-0x24aa),0x29 end elseif p_>=0b101111101 then if p_>0x17d then M=0xbb p_=J<M and(B.O[-0x24aa]or B:S(0x110,0x171,-0x24aa))or(B.O[0x2e68]or B:S(0x86,0x202,0x2e68))else G=0xd8 p_=M<=G and 0x4eb-p_ or(B.O[-0x7d76]or B:S(0,0x300,-0x7d76))end else M=1 p_=J>M and(B.O[-0x24aa]or B:S(0x61,0x130,-0x24aa))or 0x3c6-p_ end until false end end,function(a_,...)a_.q,a_.o,a_.t=a_:q(),a_:o(),a_:t()a_.F=a_:F()return a_:k()(...)end,function(a_,b_,c_,d_)a_.O[d_]=a_.o(b_,c_)return a_.O[d_]end,function(a_,b_)return function(...)local d_,f,h_,c_,_ h_=a_.O[-0x678a]or a_:Q(0xa14f,0x68,0x22,-0x678a)while true do if h_<=0b10001010 then f,_=a_.h(...),{}a_.j(_,1,a_.i(f))d_,f,c_,h_,_=_,a_.h(...),b_[1][1][b_[1][0b11]],a_.O[-0xeb5]or a_:Q(0xa151,0x69,0b1100011,-0xeb5),"#"else c_=a_.h(c_(_,a_.i(f)))return d_,a_.i(c_)end end end end,bit32.bnot,function(a_)local j,_,h_,k,e,c_,f,d_ c_=string d_,j,_,c_=c_.unpack,c_.sub,c_.byte,bit32 c_,k,f=table,c_.band,c_.rshift c_,e={},c_.concat h_=c_ d_={[0b11]=0b10,[0b10]=d_}d_[1]=d_ j={[0b11]=0b10,[0b10]=j}j[1]=j _={[0b11]=0b10,[0b10]=_}_[1]=_ f={[0b11]=0b10,[0b10]=f}f[1]=f k={[0b11]=0b10,[0b10]=k}k[1]=k e={[0b11]=0b10,[0b10]=e}e[1]=e h_={[0b11]=0b10,[0b10]=h_}h_[1]=h_ c_=a_:u{h_,_,f,j,e,k,d_}return c_ end,bit32.bor,function(a_,b_)return function(v)local i,_,m,c_,s_,w,r,o,d_,p_,j,f,n_,e,x,q,t_,l,k,h_,y,g p_=0b10010001 while true do if p_>0b1110111 then if p_>0xb6 then if p_<=0xcd then if p_>=0b11000100 then if p_>0xc8 then l=0 f,i,s_=l,0b100,1 p_=i~=i and p_+0b10 or 0x39a8/p_ elseif p_>0b11000111 then p_,w=0b101,{[0b11]=0b10,[0b10]=w}w[1]=w k=nil k={[0b11]=0b10,[0b10]=k}k[1]=k k[1][k[0b11]]=a_:N{b_[1],j,k,b_[0b10],b_[0b111],_,b_[0b110],b_[0b101],b_[0b100],b_[0b1000],b_[0b11],w}e=k[1][k[0b11]]elseif p_>0b11000100 then p_=s_~=s_ and 0xa0e9/p_ or 0x13 else p_,e,q=0b101100,b_[0b11][1][b_[0b11][0b11]],k end elseif p_>=0xbe then if p_>0b10111110 then p_=t_~=t_ and p_+-0b10011001 or 0x99c0/p_ else p_=q>c_ and 0x1db0/p_ or 0x2a end else h_,f,l,y,i,p_,s_=b_[0b10][1][b_[0b10][0b11]],b_[0b110][1][b_[0b110][0b11]],e,0b1111111,b_[0b100][1][b_[0b100][0b11]],0b11110001,n_ end elseif p_<=0b11110001 then if p_>0b11011101 then i=i(s_,y)s_=0b111 p_,s_=p_+-0x7a,q*s_ elseif p_<=0xcf then if p_>0b11001110 then p_,h_=0b1110,l else f="c"l,p_,f=f..h_,0x36b8/p_,b_[1][1][b_[1][0b11]]y,i,s_=_[1][_[0b11]],l,j[1][j[0b11]]end else p_=t_~=t_ and 0x2288/p_ or 0x2f end elseif p_<=0xf7 then p_=q>c_ and 0b100111 or 0x195-p_ else h_=h_(l,f,i)l=1 _[1][_[0b11]],p_,n_=_[1][_[0b11]]+l,0x1b4-p_,h_ end elseif p_<0x9a then if p_>0x8d then if p_<=0b10010100 then if p_>0b10010001 then p_=q>c_ and 0x1720/p_ or 0x95 else j=v j={[0b11]=0b10,[0b10]=j}j[1]=j _=1 _={[0b11]=0b10,[0b10]=_}_[1]=_ e=0 c_,q,t_=0b100,e,1 p_=c_~=c_ and 0b101000 or 0x4d end else p_=t_~=t_ and 0x14b-p_ or 0b11101010-p_ end elseif p_<0b10000101 then if p_>0x82 then p_,r=0x6a7/p_,r(g,a_.i(m))m,x,g,l=y,0x80,b_[0b111][1][b_[0b111][0b11]],r else p_,x=p_+0b101110,x(o,d_)o=0b111 o=f*o end elseif p_>0b10000101 then p_=f<i and 0x15c-p_ or 0b11000111 else q=q+t_ p_=t_>0 and 0x5bf5/p_ or p_+-0x3c end elseif p_<=0xac then if p_<=0x9e then if p_<0x9b then p_=q<c_ and 0x28 or 0b11011101 elseif p_<=0x9b then l=l(f,i)h_=not l p_=h_ and p_+-0x73 or p_+-0x79 else p_=t_~=t_ and 0xac or 0x246a/p_ end elseif p_<=0xab then f=f+s_ p_=s_>0 and 0b1101101 or p_+-0x61 else p_=q<c_ and 0x1a34/p_ or 0x89bc/p_ end elseif p_<=0xb1 then if p_>0xb0 then p_=q>c_ and 0x1af7/p_ or 0xfa-p_ else p_,m=0x83,a_.h(m(x,o))end else p_=q<c_ and p_+-0x8e or p_+-0x87 end elseif p_<=0x3b then if p_>=0x24 then if p_<=0b101100 then if p_<0x28 then if p_<=0x24 then p_=s_~=s_ and p_+0x1f or 0x64 else p_,w=0b11001000,e end elseif p_<=0x2a then if p_<=0b101000 then p_,k=0b11000100,e else p_=t_<=0 and 0x9a or p_+0b10110011 end else e=e(q)c_,q=k,1 t_=q p_=c_~=c_ and 0b100111 or 0x46 end elseif p_>0x2f then p_=t_<=0 and 0xac or 0xcd elseif p_>0x2e then f,h_,p_,i,l=j[1][j[0b11]],b_[1][1][b_[1][0b11]],0xfd,_[1][_[0b11]],"B"else p_=q<c_ and 0x27 or 0b11000000 end elseif p_>0b10011 then if p_<=0b100010 then if p_<=0x18 then p_,e[q]=0b10011101-p_,n_ else q=q+t_ p_=t_>0 and p_+0x9c or 0x2a end else x,g,d_,r,o,p_,m=b_[0b100][1][b_[0b100][0b11]],l,0b1111111,b_[0b10][1][b_[0b10][0b11]],y,0x11c6/p_,b_[0b110][1][b_[0b110][0b11]]end elseif p_>0b1101 then if p_<=0b1110 then l=0 p_=h_==l and 0b111 or 0xb44/p_ else g,x,r,p_,m="B",_[1][_[0b11]],b_[1][1][b_[1][0b11]],0x71,j[1][j[0b11]]end elseif p_>0b111 then g=g(m,x)r=not g p_=r and 0b11001111 or 0xb8-p_ elseif p_<=0b101 then e=e()return e else p_,n_=0x18,""end elseif p_>=0x52 then if p_<=0b1101101 then if p_>=0x64 then if p_>0b1100100 then p_=f>i and 0xcf or 0b10110111-p_ else p_=s_<=0 and p_+-0b100001 or p_+-0b1010001 end elseif p_<=0x52 then p_=f>i and 0b11001111 or 0b100100 else p_=t_<=0 and 0b10110110 or p_+-0b100110 end elseif p_<=0x71 then if p_>0x6e then p_,r=p_+-0x4e,r(g,m,x)g=1 _[1][_[0b11]],y=_[1][_[0b11]]+g,r else p_,h_=p_+0x2d,h_(l,a_.i(f))i,e,f,l=0x80,h_,n_,b_[0b111][1][b_[0b111][0b11]]end else p_,f=0x6e,a_.h(f(i,s_))end elseif p_>=0x48 then if p_<0b1001010 then if p_<=0x48 then p_=s_>0 and 0x1710/p_ or 0x24 else p_=t_<=0 and 0x2e or 0b11000000 end elseif p_<=0x4a then p_=s_<=0 and p_+0x43 or 0xc7 else p_=t_>0 and 0xe1-p_ or 0b11100010-p_ end elseif p_>0b1000100 then p_=t_>0 and 0x13d-p_ or 0x9e elseif p_<=0b1000011 then p_=f<i and 0b100010010-p_ or 0x13 else p_,f=0x18,f(i,s_,y)_[1][_[0b11]],n_=_[1][_[0b11]]+h_,f end end end end,function(a_,b_)return a_.F(a_.t(a_.q"|BDU_N_A~;QvYRfb!BsO1XKTXZ*UJ&WpqLRb#!l6X>LMt|6zA*2TD&#PX9?xM+!z^a&7-0Qg35xa}ZPiWo%_*bY)~y|7dS;L3MIr2KR4bY61WWMsjceb95j_d2J4M|7mk|VQfKgaQ|$1X>Ml_L}l+`bZAlmAVqFrUt(-!WDX1=APhkLAPiz83Q}caY5#I`XmcP(VQ&9nWN&jiATSEQMRRmvbaeqhLH}cPX?AZ2RC2drV`~YZ40H%#U;kroZew9|6(IL~AX5b7M@dFh{uLlDE-nd1VRQd<RBvx=a|lB(VQg$-2LKQZL<NBVa&%N_ZDj~T|6y}wP+@X(6aEB1V|8p{bY)2YX>@Z`Z%b)x`)mgwphItRWfS@aq)Z;*P;YZ-bpL5@ZVyRrWOe^@baH87Y#>bkX=Zd0aA9?GKV@V^Y+-N!zzact32Adub#87SApZw&Y+-q2a&zArMqz7Z6#{c0e<)LLY;Pb|BqHBsb14LJDqsOEe+gl9bY*RDDxg~lX9|E*ZXJLR6TyFJV{BzbZD|9b`*H{-!BcQ)ZXfzEB4ZJNVIXyGApK!5U?6Z|a$z9<V{dJ6a$#}|@;5?EAb>c)3r=-y|6*lwR$**)W&aIEb!==;a%ul(X>MU`a|CC<VQpnaRA~<2Z~iVIWFRnTATVu5ATV<=<}l$idPx-E{xhOOd2DHJWM%(y13`0R15-@@NDNSNZ**m8|85{fXJ>N<Lw|2>bY*UI2|7XlOkrYWYzjtc|8iwhWpZ|9a{UWT;z@3EX=G*mOGZ6_WMxogbP)ebQe|y#c4b2TGJs-lVRB>>R9|vsVPtJIU?4Jp{b4cza|u#uXK4R)NMUYd7e{6PbXRY3Yj1UQ{sX2=X>)W1aASTz;0p>xcx7W-fd6tjAOd4%4?_2Eb8}k3Lu_SXe{OYf6isz=Er8=7OE&;mp<SX0Q)B;fWo2$hb!iLlNOW{?7C~uaWj_#eWpqPmE+AmQ|8i4ldSwk$aQ|gxWFSvwAX2YoaB~McplMwI68}?UVRB_-a&Px{AVWTYb8~fb`wU_vz({p%VQznKX=Dp$Wpn{$wot-JZcIR7Y+=O*?@ncOcNxGBLUqq+Y-CVLVi~~%a{5)E3pb%~VRLgy?__fgLpdOFVN-2&aRLx@bO3N~T;T6-RAF)qU<hSx`(<)IU}rQ<Z)Cq|W@%$#Aao;belmb%AZ%fCAb;S$VPwOtb94iMbMqi`d?8EXWMOj<|5bBka!GD*b^UZ7qz7ScbZJcgVP_mgY-ML@<WL|`pkfMuQUM@jW&a>!X>N3397XqWb!k$7AZ=lD$764F3_w&OYoTRw{{&-YX>1ciZ{KivAVg^cz;a~&AZc!PX>?@-zj|eIZv<pEKoI_uAs|q1cV%)Q_E%yAXgmN3ZDDx-NM&JcbZ8P)yKrQ7U{i2;cz|KQXL4b1Xb^^N4(<)3RAFa?VPzC={$C_gZ*O!#Zex9Dd>~{8L}_+UApdd?O?h-^X=8ODLV+MpAPsD9i{Lta;Bzh^3`1xzAW>s;WD|&j65vU5Y)*hOMC52ZpqybEFD1ZQ;Qw<kP<3K#X=B?zb1@)Ka${gU4!Em;e*<8G4pV4?z(@XwU_)<pZgdJ$^L20vfF9ukPA@_K4sd03MRsp&uXbfcc4uG+Ug2hsX>4T_n}L$#A4UtcRtF+yr+{)1hQM<fWenqgV+(S;AZ`FX!QTr*b#ihE;2=$3VQ>j|Xf9xEWC7ly;tNe-croB~Vb5-3WedGw65?fYtq~%DLuf=`MM(q;b4hJX0YLy|Ap{iw|8oUKP*XY}4)RGrbTb32VFy=1N&d1y4M}rGa%pA%Ze(*;X>@1^{ZP38Q*dEz1yo;YbZlh`!GTglAb)ga3r=q!R99rL3vX;>!o>s>K@9$(p<h*SOl4+t-(Lw$VP|Dvb!01L2!x;@(IE`d!)+k{ZDMa1UL|uXuP81pDFDDP0Y@Zd4mV2-3?$294pI~#-(_-8a%n{1bb0*^0mD;tWpHq1!(<YwLYjcIV0)w#WB!03bS-XgEn#^7WpgcKZ)|mKzitOYZ*^=vU=98($T}beN^fFG$7Bw3J>e>1HvtM%_hoo=g5h#A4^zK%a&K#8R8RnG|88Y-a|&j1Z!c|6W@e1Q5GlhjA$r{d5+o%cbZ;O~Bl{6#z#w92Y-x1+c}QnKZ*qAGLEmg_AVqDkKyw6*cZXmPV)=muqlh63eCFWoVqrQU3Spu^e??(*Ffnr#8bHTxXJwg!n!#QHbY)crc7qLfV?lp|419ojW%59RfMIkJNUOlsbwFiq6yZ*hfO89vZ*XO9;=os7tsrEFc}Qinp`su@Kz@R5ziwq?bQVJTpl7vmU*Kf?0B&>Gz-8ZVV|fcgiy&@7?&5%KWgCWLO<{BoVRAxj`CwK7>;%RDy>v(6N^fay-hvBRON=3<Lj-8WKpmgpek-75ZfA68QeeaHWJYgt`veh7RG)8WXKZD60rEozW~oC6XwksX0CNi`BK%k2tRM_Uc4=%N?@M8FZ6?42a$&n<3TNPRRBsMJBE4wCz;ik;FY1AF|1NTGVr*}CE^hJwFLp5kV=oZ*;=y!ppb=ot0UV%^pde6{ay~!~p#WjVV1i&|-*0zw3`6-tAVISGfEGm|L_~67B!&mMaKa$ffCgb>@L*;63a%oTVRH*XZfSjO<AO<K1#@fufcFJ(a<ZTfVQ_HkY<V~#M)kmF3SxXLqC-I&P+@Fg9YCnRVYLCi;2?Y;AQ%8)^9w->;-f+XASgip2UTusZf|#P^$AjeK^eed3QunDY<W#@P(Wo0Z*Og7XJLl|4@0BCb}_+4ZW|$F5Mlkm`C&`IIRJEJWI=R21>>M@VGVPqKrKOpoZ~fx2mioTL50BCAbBrvWe;>NAZ6gFOySWJex!54VZ;o%Lt$)I_@M|yK!9wlU=0N$du3!RAYyL@R&~MaWeVG2Zs&kHAT(P=bJ*!_Z{lJg(O{QwZ*KXaAlL%s0A+t5Wol(|V`<&soeXp!ZDn**K>ff5s`Mij#KRzXVIWop6#U;KSO!;ba%6KOp6DZVX>f1n0Sd+-_jw?7>Lm(tb#57MJfL&H5>oWQ)__$b{@P)43PfdNZ*u-ULJv%DV{1@v`*TB*z(a3tZVW#{Z)AB^W!T_?;J*cCY;SLJ&;fM131D*-BN$I`_F-lHa}R=SX>Dn4VgF-k!?SJzPEXYjYQZ3C;UFtw4o`P=bYuuXL2Y8WApdj<LTq(%MP~hGct8apZF33={8k2LfevzIVrg=0ZUe@k3Ph9U2}a&Pvhu-mxIp<t2yY1Ba{dP30#Qi;DGWycZ)|LDcT{0=Zg(ICL2h%Pa|(UH|5Ighc4=c}2O^5VWFf$;1$Dy`X2Xa{yANr^0BK=t$b|@(Np5r7A`iZaD*y*R@}NXzb7KirL2csG2y!VPq`?YNg*qU=1aNO}Yz+1yAbUY=_2CC%Z*zZu|8NW-FCbH8ZI@wgVXA-)Cc;XfAZ1hq;1f0q{(^HEx8?m*`XOy;Y-~hw`)_c5U~UabZf09$a!&w6awLEetpWCw#7J+$pkxhANd9+5LRJq+Ze(>=b98bXKp^#D1$W^0Wo!#f0CRLwVZUT)b#n!D%3yBa3Rh)fXb0d`QvXa9N_A&pWN&+NAX|ZMV{dM1A%AZPbZ|j#WOU*C3R6GeYeH{tbN_S&MsH(va}4(A$Rr1wAxCv-5&vdsa%FUHbz^C0z(PCV4TPX#Zyo_E%V8L81y`e>Wwn7~<I8gkK*eOIAp2!HAZ-aUz;tucp$SmIfIlEpaA9o(qrvbXf=HquT_g8I5Flx7D*^{r;bU_L_9O_sfpAKp|7dU#R%LP^R=;UvVIV|hGXP|_Z*vF81POCWz-9k(NN;ckX>eh`X>xN4aB}9LY5#6TXJ-~hX>L1YMgm}TLulw=8NfedXi0NH2(m%wfuAT&Zy<AlfGH$$!*6Z@z*K-NAZkHrbH;}Ra|ixn9Uy5ULUl)Tc@LJvc0jbk4(%g%Ms;qvKyPjkz5(u8i3bW$fIvDR4XSZsN#i69$bleS25x6%cy#aK`T|mKlA!-(5>0t?bY*g1c_2u2VpM=~umJN3bW;HILJd=6a`$O)bR%GMX>V@*3`FEZZ)|UJ3h!)hVPs2zZf6GVW%xmJ6aS-AaCy9uU?+qMLt$<Oz-+qZKod5gcWzK8VPn3#U{!8(X>1d~Yx!m7LFOV5RB3K`{In!i0th82C@w9ZDJ3ZjM$`brWE;0ZXL85jav)VjVfi3P#&{rfR$**)<7E!IV2gke0by=uV`U4RK%WAhfDcWvV0m(`!^fc$L2hG};TQ?vi6Lbo5kcUg{lju&eFsz^V`WKX1KPmP2_P>>svvn_17lxra|>y6*nngu;`azhb$p<2X=DetQe|fLU}yzbAaeb5z+q!-X>ek1k706T1yy4`1M8s(|5RyZZE$ZoAn6Q(0ewXo2qZylZ2V(`fMs(LQ(<Oh%~WflNp3eFr=SCK-)U|aNMWLZWo7?vM`d(KWnpX!bZCj96SSdeM2DcBLH}hCc4>2UVQl_pfk|#~b#!wLL<V5SM-lR&`Xj7kbG<@;MPYPCVRLj|z&~>YX>Mk3R3Js6l^|mvAT!|+dZNX_VecSJVIaJq2ux}FXK2Zx4^UxpbiZFrWoC3z0wG`f23Ka_RY?X*PycfuEg%qXWo5TyWn{od3SK_KbN4DGC=Vh+b$L_wXm4<8p$$cFY4c+sSYZqS1ygZ#?_qQbWAngrVN@@9aAgseKyxr)?O^?L#Gqtlat2gypKwB9at$NKVj%_oe<Bo8Z(?k3c<)AUa(6P|P;YYobYX0B5lm%g|7C7uAVOtfWBq8R!V6bnY->;VZdYL~fC*t_WX>XE3T|&YLFmB~MgMYgZ*om#b93imXJzYPP5@*LVf<+T0l-Lab#iQZ{{&ZIX><-mX%%zvAY^Q$5NlxA;1ghSTLcd2;XpxDZ)e&--wkhaX=m-gY*7Dcc5ieBB`z}mW>G;4Wo~6{eR(^>2S;*YcJ}~L4nHId03o3daKlpgfc|v?22O8uX=Zu91SKvoW(@X0LYrY^ZNd&qMIiBELe+U!fdqb`1>~S`Wi17|fg}Z(p>qa8-s694Yy)R?X%0Z({UAVqATux^O=){>4$O#0d2M^PrF$Sjq`-JOATZxx9A%^dK}5r?;DG|6;wJO~fhV8}gJ5lCWN86!utC3v2p<e$2moC|orU!vG{X{-gH~x}clzjs6VIk^a%*pO{d7j*3TAI|ZDID}pmb%zqi|(p3I9oRP;Yl-a#hQ41uub1&4o(i0WkduYavr(VQgg-uswv&;;n|~Kx1p6KnnkGVRdt5WK?O#ZDkBV;Z5Mhq6TUIb7pC5We06<^>ujQWZOV;VP|sxVQ^>$Ms;O!zj|Q{AUz;?13Ld82V-?|a%FDabT(pCVP|sW1WZq5a&QlFp+@0zM+3J8MR*TDa|ux(a;;&lKyn45LIxGUXm4+F1a4)33rMm6{~%CraCLBV2|i83OJ#WwQ(pi@qWfuM&SD2<a&K+_Qb$4rV`yP=^%A0DLAJn5VP{YOVrpe$bO%9aJ85iCAOR%|&Y}{e_P&5^WpU#YO?7jhV{Bz0OTs|ABnHPrMsjuF)Z;avXLavvVR8wA;vhkCPi+lKb+E$qV-Ku={`+Bdb2=bNL`?lfu)%p{a&rS!=Sfov+hMb#3<^&C+aQ9%Iv@~laAo~&dVq9wZe>?!Z)Ig{4k0E%WQ^cV3*P`%Wx^mAAPhle`t~6RKp<#eZDDv{3sz}zbff@P|3Lo+Q*L2nYjX~dQg35x3V=j_IROceYISXJ%_D8coPh|+n4xs#fD4pj7h?)y-*RDhY(?au1Y+2=;7}&`0Ayvm!wOLCZ>wNtW-7oEQ*>TEU}tn_P)7y?-~oRHOH^`cZ3pbZ8X>?0lpt*y?q<g2973X!p$RsDKjJ#zYzn|2|5S2iVPtJ-Y&&cUIH4d$Z1muJ!k<%RbW?D!U@9PU+jJmFLJduofMsmH+aP6cb#o7(NK~(3b88D-B15ji4F5xKa&BdEQen?zX?1gAVj7|ZPycRXWdThHLvsCj;9zWX3sYrd_i|-)JV0e(M^Jtk;AL`eAWv`s0rwz9Y`P$HZ*CwzC{$%^WpJ?oMgsRKAX$Mxb8vNK9dn7HX=QZF05HH;0K;=>EMaNFOCfilAP(JEdB7k{Z&yQe1m8w!a%BTKfk<!PZDm1YV{D-XZJ&8ZWo`;HL3pDHolmTUa|mYAKsI3oO=unfWe$P^Ii(bc!|oHsb5m{YpbSTEw{K)1sbV@H1SCZ7Wnpw^uVGMiZtr7g1a#714^(p9Z`OceY#^(EYi0X$3;#kxZ*5{>pL7pPRc_H@{J~{d@c;v2Wh8S7PJvS=;3s8m3{T-aWerK<jiPQiKn_b&&45B|RKP!MX>)W5N>f0W0&x#70O0_D<_KkM${>0IAO-^fbaitI7w7RK8{-IuNu^R{ZEtOM$s%rU=tgZIy#W6PZgp*9WpWTjMdF}t8(;!J<)RjK!QFFFt_DbD{~-cY(@+Y01PEXXDx_g&V{;P$Lnp>qAqHzzVE1KY3&P-ZWod4`Amu;-VgzzlpacI_Nlg!RY;<YrwqRxb1P(0A4o7dVY-D9_!Nm>T08`g!Z*aGR2Gd||aPxE)cV}@RZgX&9-mG9_c??1h;9_r2VRB?g-N1w+AWNbC#ef}XbaZfYI`=OxWch<GXJ;?}M>TGCSadT{|2Sj>VRdq00`E;o3Qv$gLUnY0T3`)NZbNKow?IOF!WUcx3B-1#|6(9;;Qb(R0t7B}cyt2SaA^#VBTg+s0#E-#5prc?Z*Fd=d4SJhBw+~c<pz<WbAJ#;c5iHTV~_y%VR9h*ffsUOcz<DYb7gdCWEP<RGd43gH#Rpke=;{NMo?2aWx)P+z;0(QE-ngC{DGhX2_S8A3PpJTWn*=8Z*n>yQ465L|3HRd2Onezvn90;7XWmLfO8<3V+`4Im;^y#1ayV~6H-5AW^!e7XhVVogZpy}<s?jRZ*UK<O?h-^&Y)~xL=m__!_A}}0!3$MOF?CQ3;_T~X=ZdodI9qaX8|BofpldKOFu(wWnpeiOu?G~>jqA20CMY~VQ?+~aA|H6RB2^x|8Q?QATVSgF#l*EFl`_(a|Qo%V{dY05Nu%+b953z?V}BNKu$yrK=l#CB}RRKNpxjxTXO@_U=j-SV;}_p&uwL7X$t^~qCsQdbZK^F45<TBW$r~FAO}cBAV+0%a~MX90Fr=nbU~va-E%6SPi8|8U~?45Rc>MfLG5Ai0A+IjQ*>o;0%T|j{YUj6AW3d!ZwmQK{6UH$10^vm3GY*BdSyMr2Xl2g@d6JYL2_4NabVDa|8omYWp_nvW&LeVz;g_3VPj}tX>MgnZrQ*Jk7EB&Xkl|@2|;e}Z*F;QyPy$vY3Xy_pmzaMOW<;3bNo@l-XT<PXJ>3>cN14(t>A8FAgtjYIKXgWcWzcA@IijU{|R$&c}8hvZ2x3)2xxU}VQ$ZFX=EeoVo^dMb<b{LAaK8+Y#?DEMP*b+5(H?#pzxs&RbUB72t+HOa6v^-;DlkN0QnQB0w94&Zgy{L|7AjTb9o3zX<X?bs2~ywMVq5KCqVw+z-e}G3R7cp?`d#!PSwB(L~`$8XJ=uepbJE4-*a$mVR-_f3{yvCa&|7@ts^cWawdQuX~VN_AENA7#O#JU6-dC~Z+B&l0R7_jNFx$UJz+y^Z*%PZfL)^pR`4Kiax>P!fN5f-z)ua}Y;WgsWC@Dlj{sw33BOB4adl~Ml;8>NXH1|*auvV_L1RC1d2DH83XuR5VgG4kWerAhZ+do`;7N1yU}P3=jR5|HfOK_kWmjlr+huHFV+?d0L0@VAZgXXFbO}>%%WrgI!U|nMT!RO2KE=RcXJrv@-~_~`^9o^pAbkKcFl_|?RB3Hx1XV<7H*FPGL`Fnq<sk3EKXU_ZX>J;kA*`V0lH?#LlOeLeX=5qz1e5_zAin`_Wpi`+2m?XdK@me?aCG-|a%BVHbaHQO?`&mq1r`DXVsH0za}8b~X>MtB>t!I>0R=`NbaMguYt}%&0%dt+3SR#xE-fh~b1Eg@EevO6bQcB$WUpa#VGF0?AY-BqzeR3kZFwLb13Ld826AC;WN&R<N0y~dZy<HUApXJrcfvX#PH%2y3ho9aFfT9xXC(?w=Vf?w1!4rjcLpWDE-+>#a}J_lAo{yta+m>bX9;R=>uGNM0u6p(L1SaSl%YXqWd>K@;urf0M8qIsX>4g^Q(<I>hzWo(34jn_0rb?t!sQ1X0B2=xcK-%^ASf;?DFwe|WoBh^4HqCo-*0VYav-5Va}xIFBTjDtflO~<WG`i81XL9u59%X^qHe4~3`2680A*K@pnGq3pFm-3We#5BZy-o-aKRvV61JdsVPtLJfKYF9JR^Au(m=3;25)9&$iRICLBTQ#O<{Pr#L*ZW;B?_lAbCiDZfE~xWK(HpZeeV}A!lrE1VVvfVALRU3Hx_)Jm6+&Y-JVv|HI>@b5mtwa%CTM6-!lcI)GasLBRiPX>)W;VPa)FYy`rg3v+H*0L{exQJ0`;ba_l=cBf@*2~py4fele1Q~bYRV*&*wE;4395e!>_0%6X96Pdtg1{Xp9V`Xy$bZKL2{|X>4AVkBhVXD0V4W<H0I)GF7U=8VYdLUB4P<~)?247!aZEs{{hoEeGfU9L>TR{VypbOC8Wcy`ukil~aWp-(IY)fH@;16_iZb1CxpyGgXbY)}`Q@Z4YNnL<xVQc}w2LEzpZEtpE4?_5Z0Fl7FpipUeWo&s6wt|X4X>({)o#2~p3T|Rlay?)~0aE{OZ*&YyZ)0nIHpK%+Wo`;X+Q9!)Xklb;cL#7+WpZN|pa|E&Oenzr2~tH<R8LY#uTDn~OUj}|-au$=QurVlOZ5aoY=hwZE<sTx1#@9`Wn^y*PjFPpfM;{R0e1y;a0?&-SPp3``3(1D;X(yxY;R(}WeIn0a%-HT45l{da|cx6fZz{?VMX@Bpmt?o0doOk3I31(LT_(#baN2@O-W8)NJ&&*|4B|%MN(ElOf1g>)d6m9F2D~&WEY_>!a)d0b6|rIQG=HUOBho|L36R=q~UfkfRdC!7cwFR15n$*Jpf_hbW`Bqq7uWhpmPvHcBVjQa(Vz{LvOcW|1%6oP+vkxOn*#5PeD>d8)U)%AV_I+AShH&`zau^!5~m&adn?%!?9ryl*!iN7bqk{u|r}A3`AgLL_mq)e{OUTMqz7Z@_~1AMQ+w1WD85lW12WY6FWd_Wy@nUMFVecWp@r=AyQ##;C|a82u)#hWpYcPi3puS0e}(KCe&eM;T1naVQgb{Yy)7`Lwdvm4kYUbQ*>`Vpz~x2*~8J`3qo~t|8#F|b5wb7WpN5f06oDA;ZkLA)*$i?AY=wW?Vx1>Qd7|r{K8&<7N`g&0!(2yXAfkeM09!Hg0Uis)T0QF0CZ+R$3sqG6aPYWX>4RuaCyf>WpnzXG~jRsRBu;rY!NMBZv7x*^8o*CWprq7WCu&PWqCt%;1EKeKveH<Qe|#)fKzm3({K+T0dJ&7?m!7elX!6UU_T%gMM?dJ3wcE;V4DCSM|o|vAa`_cAPxZ_D<IloKLvAeWo2ZKqmF^Q3JRm-Iv@o_!URe`0Tv+!aE3rGMi1Tret=_TZfA683)<lCLS=Jw<$(rMY43D(aC6PTGG;{oLl9mlTP0*A|1MoCDJUgjDrYGq8cy)1qhScC#cK~kk|1(nCk_hJ1l=IhAUYrt1m#q3_=qKPBFtc7Z&Yt*e`joE0w5>~dcl7nLu_Gga|?}t+hJ_K;{{VKAY~4=Nr6Ubo?t_0GvEZCGocnud2>&I@BnqaVyPfkWo%>CfFQvamx3CCCqR$FC;|v={^dboX>JNhV{iX%RA^;wWn>D!Q)z8*Y-Nps6zoK&o1kTKbRq>)aPMJvZW-+%baZlGX<~JBWzb3#Eyce^Z)|LDch(~c|0Zl{ZE18pG5;_y4R3O3XK6G#Ky1Pecc611I>49#zd9fWP+@YuU=i?rfV<&>0Oi4HV`U3}ATLv8ZDDT1;kycKtiVBZbb~+%{6V3q!Vhy{W@U8yc~lF4XJv9_Wa|iYnILk%Kmkw)|8iwwX>xREbGrv&27+@3a)f|sopNYGbZ8*3f*Igc(Di`vLM=g&fpfP30$%GZ3+Lz(SO`I9X&r3fU;%UwwBT;R%f;OdNnvkub9%!EM!Xf^bU+SCZe~t_W&a>qX=Q9=3THcIZYpF5WNBx>hM;W(AK-Kxxr0+>P+)ICZfR{U!a{7#fd1Ja5k+xzX>cI<S3V#BfO=taWC!l>VlXiUH{uOOZ`E?_0U+=q4ky87avvZ>X>()T0H9>e4xbTWZggpaz@o<sE(B&eAPS;^Aflp*hP?Dbt^saj4N@z^RI_1nXh0o+a&0cbOW_aFV;_Ou0(9b2Y+?6pa}i4CQgv=_Ui07sB~vT@!%gvk^=<yZ3Lzn1Q)y&>WnTjzEg%g6!v9rpQfX&sbYH&^PjF>!AYEt&?@D!TaQxs9NpAOKb#qd{VQe5%zj1Y8bPi+4z*Bc<Z*b3nbY%~*CN3Glb#oQw<50|?TEP8n5u_GDb8}^F|6*);OlfXqVJC7{WiMbn;1ukHC19LZpv?kqVF;q&31MaZ3zG-}AYBnfXZ>fzOABpvb7O4vWz6CY%;86GZ)CqqVRCI@4k#ob{wPF5WoBV@Y;?Z}Wnpwlbfka{{?>$OVQyz-WCQ<6b3p}DZEtJyWd|()Z@_a23QAvZVjxLGp1^VhLCGbEp=>}PDBx+pVQu|sDgbXFc_3tA&%?2AAR}O>p#dz<3`uTw2*5;R6IVZFVrXw~YdFJ=1Mdt~b7d<bP;YnlWpWEnXbWLuWB+AvbX0O-WM%Ic3Q%&4fMjWJ?;u2FAVGw4Iw06T<d>mzA__=3fKYF}aH{|UL_-L;0aX8KZDj**Y-9mnWD8?;a(^LE&maux;_<>mXtDsJ;%Gy7!n+PjU_wD|WD3FrW)xs@2!cT_Aae+r0sj5L1!8Y_WpfR_6F_ujX>K6*LI&>6Avz!tp`k@~Z|7`wWkVrE0197U{@3LXZ+C8GWJh*!z;IzepmPRt`vQ9rOroG^VR9g6V*Y~R4<%$|ASGnAXaHbs0N`^5G=mC#bYQ|#Z*O!Gj^qNjAZxsUYk@8xfI}*wu7W>OVPt7_b7Nw^V*d<qY+-q2azp=UZ*ygC4?$$Vc42N~Wn^!o3Ka;r;X;c55Ai|jfOg>g<wBYuc4cyNWfZQz<Vba5e1>1gKzIK~a$#_2X=8I|5OZj<U@(GDaGYWP4o_`mXJH^u`Uk*lgdhz^Y;R)wVQeM9WN&wK1m8(SOhpGJ!e?jy0&jB&Y-MJ2zer(jWC%iLAaMR>pa@1uM@UpjzfMOQQFUn_Kp_8BY;<XDZy;nvWhEydY=e%j{Dv6jh2F0PL~?I%58!SFp3<OZX=fen;$($+`(YsTz+qxxAYtEQbZK^PEWmSg_iu7#?PqfiQ*?iCa71--VPdob?*><CZW+K2WMvg|zMy381q^V3RppqVdI+LI#9(Y?1V~yS{{l2L2W4zwa8Gk(WD@TKh=F#nfa;{-4cy}(@<Rh4FZ&<~fj~@QVr6Xea|km)q#_Dvb!7ieWp_<wZgmHqTR~25cM%RGkN|S)bVKjq2Hl`<ax?uS5k(+kY;SRO|7BrhZ*w4UW%7gIZlU1wKyGwp4E~}4LSb@OX=HTgXb(+_0xQ67XCUuKd2J0tAx&X;`h}wq6@q0&cyMg<Z*%DYSs-O?Z*+ZSQ~+XZWnXi|z&{IAX>NHSxTHLxZ%S`zZo47{My%n_3}t6$6e6#HVH5vyWoB|^b7)ifZl!=B!*dB%VQl|(WkO+dWerUAW!b=F3559pPH%r8Q)M7fb!9;S^-@d#Y-d1IX&^<vb97;IAV!{mWj;utZwd-SbpYW7VEX;QV-%oeb0AD%`yfNn;bdWCAW^GzWdLAl<iK-_AZP7i2*Ful1;Al$AohL1AWwTEb0A1zcX}X94uENAb)BKVWeN&VZ*B>0R{9U1K?x-a3PfRS_hleOD&TS;L2S4V$fw{5K_EtT4<I0YRn0(UZgXL33V{DXaB^v7bYURBMQk8KZ*&YGQ#5d(5kfDFLUR-2C|Je)3p*w)AOloVM0Er;0T#)mb#!mgf%iddY?;CcATLD!X<;CIAP6up?K%KJFfh)`Q)Oelau5Ika}jX;0AY=6QbJ*DQX#Gc`=$baTObEeXnAvf!0z;5bais=As}>byC4QvLlRSTu0Uu1bZAL#X>@5}*=%M2qe4<;ZoqD3`(t!MK?!qkVR!v*wE+etE;43Omq`X=lR^wj!@wYEKWuXXQ*;nV;dtfsOSqs1u%RF`FcAMpb!}m8Z)s%wqCxnf3v*$1Wn|YwMsloR6%A$}Q}hAAK;Uwi;0Z@%boW$YXWd`|G%yhRLvrBYWmjQzW&Lso!E+U7WpqbI#(-sRcVuXT>f&>9rQTYD26AO^=zs}KcVTmM$zWq^4*lcbMrmwiP7UA+aIa-_b4Ceaa-5@K{d63nQ&<XSZ*uQNVPj~+fD2Vj_f%3r$RiSSVP=nIL3DIrL296=0T$edB)p|)VRD1P1aS7*AO&Y7U~~vnW&3z^(qda)EL|(k{h)1cc4L4y;&ThuF@t4f4L}mMhB_esC}nMMba^QR|7dk*Wd>d-CErskDGpSuKyGROb!{L>d1P{7cMNl7W}tLsWPaiO1lwT>MRsXyAgxPlz+nt{;!q#}VYhN+7c&J^Z<zpN=VeK5aNx?|OlWlfbZ~PzFE4Uo|938DX>@3HVy|^`Wpb{dbdEqS|6^}$FE@E)H+3(`z%PHmb1!I;p!;(#gg|a%XfH?KRY_AXMT%i_F0X8LVF_VI2jF9K{|R?tY->|+WiMr91$Ko252&NQ<}C?<pmcMife((N-~s<(bWCq=a0YGakKuV3gCO02WpZ@?6IN+*bai2D|4D9eb#zT(Za-mXWpW8u3?);d-%mpsO<~VLc_4pMVP;`vY#`NOzW-ola(Q78N`O=GWlO<Xfw2GtNK{n+P!mXLWMxocw{B%@+979hvEXFC3{-D#Y(qHY4gXnhb#fp?VQuaWz&aptR-kTcW&dtsa&>fNAU*vctwTB>PA@?UFGq4|ZIpmvwm<_c|4?;paBFF9AnZ5718h@cGvH%#Z+mwjz@c+<b#n)c`3}^9*+&aOY<FS*d2>&0RBvz+b}K+*bYkFCVRB+%GSY%_cV*N;5OdJrbRh3!Wm09z0CRK*ewHA0ZDM6|20Wm){vZf*fFuQGaiIgZMo?4YfOB-MU}8=!fM^dvM1TZfc_E<nZgId45eHLjZ*>0zXJu`36-!lPaAXjGS4QAM3QL)yemP+YVQ_G4d1Jv{7@kg2b#9V@1p@)^AO~_~4x$T3Y5Qh$y5t3PZ**b*Yz1R%Wnpp-y<>5pQ)q8+b|Vq*Q)P5?Y=Co5a{p;(X>MU`a}RiFMFfF&AO}TmVclTIWDIG%K~O-L!3|^Eb#k7-bVH5ca$(;SaB^>Ioj_$|)*D9$a*1OE_8|#Kx=|o(QK1N9VG%%Y|7UXtRAq8<VOwc#B|vLssAUG`;>&Xg*F_0_fgwT;V&89cbZ>3_;B-v?X>)W2ba`-PyKiQxqE1f{31md}HsEq$iQx!OZfxs$NpL_9aKL71a`|l&Ku@9xMsIR$e_?b|VRsEnqyWZL0bygJfH;60p+R(|6AVFf^Fz-?5Ax(kJ$X}LZ)0l<mxI@Ue{*vKOH@G+z-5<GWpH&O3jgBg0Cw+T1#oqIzz0xuziezERd5Zw0Y_JFZ)A(Y4Rv8}WQFw$UuX-#0YY_oLH~7fVFMs-a~S@^0U%Iyb7*yNvmh%00199rQV~E5`V}J}7NQGNV{&Q#aC9I^Zf0);zh`rGVi8Bd;Bc>Db8{dE;Y>mx4*a@f8zlyFcW-iJ|8oc^C1fRJC6{C=5z3%)f?!lf0$(yP3Q%u9U`#i{F>)Wk&*4pia|sP0Sb_g@3qovfZ*4`ZW@g?X3YDT(m4OOBOH^<{Ze&(LPr&{sKn+K7VRmVB+j$@Z!VYc2plNRHWyi!EP`RRIb0GeYz*28wY;SlV`*LNx;Av!Ua}57WNpnGNc|l|UbZK^F6is<^;@LoXs$jO^P{R&Jb-!hDdSM_zQNVcrIv@p2Z)9a`EeF6v4|Qw;M!LXjV*dtIZ)az0Wd=K8ZIz&O3P#(2D#P5#L_2~7AY_E#4+{T8X>)LFVR<0_-N8B_8bN1rW#4CEav(vh0B>{uAYmX^XlZn1Qc~dyV&oEm18YDF#Uh1h<AN7!1$Y5ifj2{Q(+NtOAR)pPdqi$&e{D@~ZfSIH;DY}WL}hSvXisL}MrmbiWGo{FY29wjAapefLcnNm_i{QQwiXIiNg)4BX<~9=a(O!cAXjN_WK~HJc<p3DfF%PAQ*e1YV1Hp}a$#_23mHJ|Nqr;=bAyB}G6>{lfHpz|+hGBrP-%8QZ*&=UX>-Y-<RILnps1i}Z*GyK2UdQ90B>?K3JMA`!~Z%U4r6F#V{86yMg?qdcV%)BzBl4%Wpi{zgaB#!jUWlZ;Bs_gWnp`C1@XXPa|>p6LjIA!a&!k|WpinNa%E%)WOZ^8!(TydZgdZ$f>sei_F(}IQ_a9*Wm93-ZgWB}Kna^bXmr&`*q{cUg9h**Y;^x<1ygByWpf1oMQ(L%6i8ug))B#FZqb87Qs89@&P<01MR<gOqrnDu{bgYR1WjpkV+a31ZggouMoSG^szg#%V02}@;AxCN{2@SdVq^q#X>DbF5NzOUZ*_E3mf+cQMIz(jb5mHsZ4ft2b#t?TAWN|T+u-kQWd{mcp*kQC{bQ@*Q)pppWk`>2Z)<aFLDiwQAPPTWbaY{3Yq6oyAPaA7qQMp4!A5|yU}V7iZ*FnqATJ<DZ=Z5uAbcPS;)P*#|8oaLPC-IUMY}`~kbrG(Ze8Laju`+GQe{5C;-$O;2`y6KU}bU+pb)^NNQHj|ATLd2a|=Vj-$i(3V|7+w3`4(cX=7_bb+zDb|1uCmVQgb{Y{_9+V0R-3;h<JPWn{k(VsCSELq7pfe{yeaaC8P|CV+oqXa;U&Wn=@O&H{jVX>Eld1EU3DJ#KZN4n}fs>j1FjzY0icWMxL~fpeJ&{2`!%2vbKOltB?~My_E`a4*1Vdcva53Tbm}K%mG05owNV;AvrO@n^V({a|DLYaKupbY*O1aJ-Trm;hCCWlfbs2(M6Yb7{;$5cOs{`ygc(;CT;7Z*5OyP-Sve!u~)EA_aDap$TWcg$YA!s9^Hwf>aCyKLP_zZ+G1c=jS>g7z4(1Z+Rff1Gj??Lv?fEVD%uWL=!}VMsH(vrE?R73!1~{LI~K!0qa%|#KKjfB1~^@J8%wz0C#LkyTI&%y9-NmfNp1HV&MgUNp5g;bOmnw0QYkW3LoHdAW1~;Iv@sTnPF}VYPJSoWn>bf2}JrpAb$M86hd`rY-H#N`t?B+JmybuWo~8vWJPvmZgdDi|8QYvVPs)*6YQQtf`LI~KHx)dZo6&^9fCt>Z;D_CI!xpQ`GE*lWhY?ApnnBxX>4qB6(kA2RB~luWNiY#7o9`80XiTsUBF!<I^Gu`OhpA|Bmom<V28lN;Y(u008bzb3R#8!Iv@;bZf0e2TW)U%f(2s<K?He#lV}bEMRp?y&Y{U+4DxOuY~Em50tr-4RewiFAVOhs5Gw+_?PEW|a}9HJXTe{>nPUysfgu9dp_zbfV!vW#Y-|-qv;aoGX>xOPLue@gPnTvxZ1-Rl<b<-KVasE5jH3+tAyq(RWiLT&Y#hr%V~#-5pu0+SD<E%jAi6;yZ&qb;2G>Dlax}pIb7*33VRB>@?v2DuWoLT8b0AiKF)lGKFb_*q;YUqjbhM!D0ev85WP!<L)4?*q3KD`eq82FsTP0*AE?p}r|0r8aYfWuJV*gZhT|X%ZW_2xYj^Ye&u0Uy}z^oxV257OMY<US@z;L3ka|=*%qyTcxVRU;EONSwGb!l*@U~Z@525ey=fO836LgrIp5=OuRyW>uEZT(`#p>kn&Y(inbb7gF4Ze`lwbMFFaWCm2BNn{JYcmQs5aA9&x;08Y>E;43QP^1EI!Tkp*WDHbjWm09nf52sSX>0`dfNil1Q3K&XoS+V9t$=O&WpuBgbZBp67ym(Xb7gH}Y<X8fZfBWba!|z-24mRDfZ0H7r3P%Z06}!y4@>Gmb7h2v1yKGYU}ym#4RU2-k7;srXgH*L;#9zLuXJT(5<S3fil$fpZ*pXF2Tfsk{wQK&Z*F5@bRO~)gIDxm9{_W7MsjIsvjArX4}_vgZl*vVXL4n8b3|hPfQN!P3{}C*1rTy&E@0^ZOH*_tz-QrL`oVJ`f_`)Wa(QoVWe&GN`AMY11i%DRWoC1&3fe$pWq~3N2qAF%SK%8X2Xkd|c4hZ+a}wEYIv@l||72`s2ux*WbYCDra%~X)22dAZ{>nfGR%vf+Wpv6@;zCp53_74{KxJh9rvV0aZfS9KW%&snW_5sWWMy(wzjS4A6i;woVP#))AYo)_U!rW$K;FS2L1$@f$6y0u*I{xA^npf1z-I*YbGd*H)gVM=b7TJ60AX%)a|~5(^cdptq77<cAX8;@^&p@j3IKs1R$*-ab!7on#R61m`n;fTir{1*FlZqEFl`_(a|%Xbe$k*(WpHykAesf~3ZVgyp>3wXMs;O(a(ZC{U~+GGk|BLB@We16FGOka;XVNXQ)O*oZUJQJARP+QC1hb_2OkFs4TP@c;bmlL6(JxE|8qzU>IZ)nYYH3#t%FAxz@ubguK*ZH156ll;CJ#<;dG{8mB2`8XJ{>K0AO?sogj2h0pkHX26y%Va%2W@Aa9^|0SXB@#5y1f{i6Q7A_s73V{2h}8)Xn-taBJ-glFJshVI+K5KBYEfOKU-WW=DM0ujYRj{tK;kRgw7Wn>VlA_5?Jr5A5SVRRs3B6MhHf&VB@Zy-fyXDO2tOJTrlU}%N_e<cXtVr6r5Qu}}lZvSO>V`FS@b9F~@WejA(3qTCP5sZfNg{2T|h>#(33{z<TZ+BE-VpM5#uWV%mNZNoC|6)x1O+ZqiNp5y;Yh~<@B(<Pna)u@jVPwB{VQyn(WF4Y&T?!Q7AVF>6p&6`zT6Z9Mf51U*uV8d9Kpv!^V{3B}$0Cn_1%U1ZA!TwLV1h_tZg*sJbO3=MD<FIV{U9454Mb^kVPbb|WmD{6WOEKZD<KeJ!6o1h;10tR3x)9E{c{V$6jN|vcW(b6X>K4TWFT$-X>N6NWhHY1|7&G=3qxpOZu@6t_CaL~MQ&yPa%XuUQ)ppp=Vb|UWFXNXZf6nXc}4|ba?)a_<#c5g>_?%qpmb#z<3wR??_p<U7UaTZY-ROue_%@=;6inDbpLN|1Z8Jua~oPdq9DOQAVN1FAT%M*AXIN4r2%_Da&6@xQGs%n0tur?X>?CwZ+HvuL8+t)D<J(-pCD;tWei7hLt%D~fQBNciFzOi%c0*)X>)W5rGiXv|8H=?0Z?^iWZz|OAXRhrfJJO@4#0_m!=jJ?AVqGoVEz%{WN&jIQ+0FuAV;L2ZF3+)Z@X=9rNCisAO>JDKQJ&QAVg*S!0VuKX@)@ofRX?pMQW9xzie+h3NbJT1x4&;00}@nAO?b2AVL3ZAV^_jWpW_-Qqm&{;ZtLBX>j~r0P+E0AXIW`Vy|IrAWypBY-yk%`EMcsLSSiiZ6HX$d1P{72350S2F+5hz;$!HB1Yj5Z2w_-Z*_DnWMO-AXl&vSNMUT`ASY#IZskC?U<fauYG6NZbOAyKVYMSFV&tzNTtN#)!yiCzYzO~Pb#rKSaB~j%ZQ0;C;4Ncma%2B&We#I+ZDMb%wt>W9a|XsE1Z-gm)j<tmPS^kxsc`~Ke^3NPO;AY+>L8VFkb?sezz5f1k^mE|fCCsHWper@2f+e2`!EcDU`SzkAVmLRbZ>JCL1Sb7Ye7M0Wd$WJGWTXp8hd1DZ*^?zWI{2(Yi&jdQgz*KHo#(U4DH2JY@cs*0WS}R0`Vhl|7C7;5O;5KYu+ayP;YZ-bU||ve`8^7WpZIs{D7-va^ayFY9&;eAY{F5nE*_0V_|v08}CtdX>>^dN_A)dVPtP|AY^4AzM}>Qa&>NQe_#*(eTYqOWMv6cb^mZ>a!Pe=a0Kvsfp_9TgcJdD6G3M;a%E=<fMFo1B3J?a1%E;gVRUq1WA$ql1r3&gL}g)g`)E>(KomuGZ*0wV@#1nImf&jw3t{*yAaVe^;SXnJbY=f|Wn*=8Z*p$#93Tf}Zi<0q2TT7{a86}mauQ7YWoPr@a(N&^Z_9IYa{(2nBY*)+VYO%UKy;a4a}M^wM!#utWleQ+LZA)&EP|^=3wCL9bz!}1k75X9Wo8q=Wv65aONe23;0hkWNcCmUVG&>iP+@g*+ht_X0SHEp;74WuZF3M(VQFq+`)_v;<_Zc{Wpe#<*C09|0#jH7|4wCZZV+R2a^G@gZew}VVn=m9X#sEnSqaJ_6Tz(sRls3#vf&CE!yx}hd2I`4X=Zf!Qa>QZAOqrvo(ug_pI~nwF)cAP|1c9vRd8fsbm3(wK`aI)Ac(+WVrl(sj35hAWo>VCb!BKm3eW**b8uE5{Rz8f0aFl2X=LwZP;YQ&KvQ>V&vavG219@@zzK5v)8J-e0#i^FQe}^1bz@~q!@D4RU}L*w3-KXAbaaQ{bh!zepe+Gaa1EYeQaxp6gbrkNauH-J!N&_wauL9~K+YfoVTWRKA~l2WrsYHyp>~weK(_%GQAJl?Ls-QGzjtA2bPZ5aKx^Cy;NXB^ZV~7rP;w_}Z*m`C=)ngFA$MS13b6q~b$RvRDZ@cNnI>*;AaifNAz?thAip3Wbafz31r7QmAyZ7CV`xHQayJ1;6H6s&ZFZsyVd)R`fLcIsNk(sMWcnt7W0>FtaA9e3zjF{_Zggo;AW#2tX=iC}VQh2V4-sTlY;^1aWe@yT18`;rZ*XO9W&dOiS7B^xAWwI0AXhvfatcyU;p<aqL4XY<pmTIkJ#w7Db#i4Nbs}g&{~&d4VIXj2bn75+NT48|;Bazb`*I1YCJ%0JPju&KWpd#HQ$PkFFaID-WpfHfZ*u=*WkzXbY-9_*)IdXMX>4RvfDL9TV`X$lV(TDbY}LZo8%<${fog|?Wpn=^b7g14x^5u<bYW+60a^of*KBkJ^8yK$AyZ@jZ*pY@MsH_D_ikhmPryuJVrBPib3>9KbY)~2{B;BUgF$3uWn@<D(%?1$4ow|_c_2-HZ*FsRWpV?XVD}46c>zIrAV_s{VioG4I3`JMX8u6AbSTAKfK*{}SK%f9b08=sWF;jj*9}Ht<>zyJ0AXbRY-w&~4NFL2|8qfObZK^FRNrA|2yk*P;Bs^;c??781to$9ULYAD>tqRPfNa#_3{!P$a%SQ{OcenMWtgB#c4bRo2ajQ=zyn3#`45=H=45jRL2Y7XX}3TMyW;zT1yG|P|8o~|Vt8S5bN^*@X=FMtFEjr(GdMRgIWRSUGXrRHa1&_Z<^G$&NM&JcbZ7<Zb98=S2?t_EVRBn-3T#IRVy!@M0ASw;b7*gOU;zbh{cC}s5lc^QLum4gU}Gu3EkXukW^($*AP&6cNpoyrZp&l@;eiVCAq-${WY=>AVKTu6)}c{p*4Khm4B4b0F5qtu`*U<fKxcGlNNLS;v><s7uVKGoO=X{SXm4Z*i$S_#5w=jIWFToEAWT@G3;%LuaC1;)a#Y`GV`~O?qM>LCZdYJ)LV1p13uZPz|59aeOmA;+6ndlrAVO;lNoQ_LV1GeuWpZ?L4XWxt3Po;Za%aK-!@#`aqq_iNY-K~Pq6yX;AaZoeVHIa6MQo)Y;lvFZMYLiA@!%6K6rgQkZtkEUZ{qd=V+&L500F?ifO8DFp#N@bWo}|}b#!B84r`*EqAg%#5Nm+<ZDDk;CjbLfZ+~zOB``8%Isk&k0U;4fL85}e*I_|ye{4l)baZfYL7@L~VRtTPX>@3-bz;r{a;ji-|9~$3dq6K!VPsEwIR7tGbaiHCb1(aHWdML^WnpA<yDx3f;4edRK>!&f!^EcmWUMA|LI>6$_Tj$*Z)*WV3b?^j{b(6M4RU2-X>#{;Xmce(22O8duWV^>3v?(596)YAb7^dI2UDt`+km|a65vf?V`ypM8QACI>See|6AEC3AV>RQZml45Iv@jQ|7C3ia&K>R0e@ivVs;93ZjI$_3Z3FmVLIRjaA{!wPiqBKa$#v~@f8SU459<TVP|q-PjF}vMQ>&Kg%M>T|5I>bcWzE)c>FyA;DUB#LS<oXr*i>BxTLm#ca7mxUvFe@a|{LIAkyG}C1i6BZFO_;Ah}BqVEiEsQ*9KWX#SMIb98BA4@*L6b)*2bh7HlcYas81(GlNcC}NPK2gBqKAnSY}7a?^YKtxYYn?(=EB1K{5Vc}qN`v-I8A!Ks|VqyPtWe!V2Y-M5lZb_e@VQyn(5Z-nmAarja<faHn?{95oM|Z#qV`%?jZf9jvX?kV93rJ;bY#?~U4)1VpcV$JOa%Dr`Z*^{TL`lCzWWQ%+Nm(yxsbqP0!J$bYuc0q<Z*{}~sRwo7A;A%(;A-k1WqV{(e`FR#ZgbH9a=Xn6$$-0Ka|UMOpl@Yz6jB^uZEa^Dzhz_~Q*dPfpfuYs1h=4M3LXGqZu(%NQWc+VZ**ZYe>gKZI5RIzHA2rVOl4<r;9$>JY2R*SRY?YbqXcvQub>5EY+-G14*KjMWJ_RIVRKVuJ7sR10wr@F@dKp`Z2W;;LvskNp;B*^;P+v4bgcjrRAp?RWpHnDbTff$fNM{0b#xB<giFA1ui*U&ZsrSAZ*Oc>Zd{`gNOg(;Z)qq%{<$Djd2nR`QVZ_?<~kq<&_Y2*OW6qxp~XXGcE?}>WVv&sg4UsLZVRWtX1i~4lVD?I3?M@w?p%OlXb4%ra%*h*`(SxDU_@bUVQ2Sc2Xa9mX>DZ%{c_ep4J9olb1H8rE-fhlz$6THg8yYiWn*D%a}3_Fpi*UKWwJqK2K#Vfya03tQ)P1Bc4cx23eY1uAh{97<!{CkQf0tFW%D3LqF`M@a|A?be`RC?b9G`73*-GkCZa)ZX>D^0*JW;J5`biNVFyk7X>M2{5lm@qaPMhhav&il9YbOC=3oLKbQnOxv2P&%WMyn1aAk6H?{98lYWLu2Y;3wFpllZaVPp~~=uSR6Ky_|!1#^I*+(7OZVIV_q3xH&A5#LRDbZBWE03b)#d2Jvo;RPPz5L4e}VRB<=_W(t1O<~2LWD4Lw#-LJvfR6%ha}1*;kHH0CY~El(Rcv%=yTD}wuO)LU3M>F_N?<cDFl`M|CZHgY;opJZ3R84%a2X(Fa<^dwZjwL`P;;dqjYxCAWDGok^Px>a1|4t{Kx|(O$imNn3L)HQz&wC-2Sh9&a&Ien3QR#DNx^f_z!3rd7{U~GX>)a9Y`srA;Aw7QY`o%gtrG6!Wp1LOL$v^9j|fd+c+#LoK&rrQ%p^cP0eJ{k;Z#8pRr_vfJwS6|Y#>wrV{&P5baOjXpJ-)rd13GX`9O02a$z7vZXiQt|7>q8AWUT-Q15ADZy@KONN;)nZy<RfM{;R&-(es`WgznaXL6%yVK0Cxp>04QRUjb$0tyNTP-%8=&vaC84#GrYL>y6lbq64FAWUH(L;+J_W6NL&fFOcm2;YI<En{zI3nIcsY2R*Xb7&920CIHyM0IjuVrgt?e{^{RRAFKXY=Qqpadl~M4O4ahZc<@+b46xmIyE2!Sip1ybELt6V}Da&c4cG+Pk_MpWn=~P0Apw#QlDjKa%FQ*zz|X${DWip0dj9}WN&xnZrlk9B|}Ex188;sZ4^UcZggp6>tSS803hE*0xTf;3Sc84p$bY<Pfq@B0B>Yv4O4e%zh-nGQ(<ixU}<(7LrQPz0AvblTp()kV+tQ4MSy_@MtC9Pa}*LKQ6Pw+Z)a!6Y-JDMfdrzK;AUz6XB16ua%CV-<8X8-!9JjKpmJ>i|5OW8baiBNPrqhnb7gc0SO94MUu|h_3Upy|M`vYpQ6b9Ud7w=bfQM`ob0t8y<8*-#A_f0KZ*OyS26JfMgMefKUj}!fATqB4b7%>}fOKOb2LD2JbaZcS3`yT^RB3K`(!(c3|7>MvX&`lOAb)CgXJKS-az+5(b#7rGV<n|<a{iP6a&G}>0#QNJ4oi@LG5~0uVRmKj3S)J0ks(cCaLoygAZdCnV$xs@Lw$9Q;B7~8VRk@(`v`Kgz(iqmVF&*8<OX(OY;|RGd}-vALk>u3WM%T;{c|q>bYo})cWL)-a|uf#b094se3=0E=t*vHb#w!RzR7@d3UXy;5`it}V|NVO;F=(EX=49%bY%oaZ*Fwq5#l9NBISW3L2G4m?IG|5aAE2oVrg#wE@N+PFLGgb|1U#oPIGQkMEiLa&qG9IVRUHqQqurbIie*nATQfUZ*CxbAORpmX`5jn0RmHHzCZzFP4{JU6NVsTb!=g7JYh+0bhRL1Y(s=(qGo}j9=3vOAz>h?0M;;vY+<UPbV>ziZ#j1mN3wutXmsU3iskcj55Z%g;d4oJW%F$iDS%y|W_e|J|7Bx!bZ>GAaQAO>X-)xi3t?&7ZBPM(5^Nt}RdAVPRX}1T4NL++IsikzMsi_oWf+>mS50MGfgme?1GC~0p<~}=bairW1w#RD{SV3`P+@X(X=C=?00wmnA_YlgY=32B6i#n#VqU=iZy-czb8u{7>v>KKzy%C~3rkabWpvGfPi|!epWtU?We@&?j)6jK`(ghjE;43OVF*e4ZbJN^Y-JT!Vf$%xXCP8#VPtuhV_{)qEI<$cMInJ{zhh++Lt$_e;AQDnuwt)c7CLM~b#wiB2>?|904IhD{{kigv;zX;3jYF20y_eY1_J-M0RpHE0*eLz0*wg*k^};{{{;f#0|Mv;0{`g+0*MX+{{#O5g$M%f0Ro`^3<9+S0^9-u|GfhO%mM;{2>$|y1Ok@=0^|P#0-go}w+jOQ`U(QZ1p@E^{{p800*V0w!~X&T#t8z+4Fdn_3j);y0`Cd`0<i)DlL!K-{|Ex}1OlcE0{^T90__F@@df_^rVRoR0?q;d0)+<xzy<=#{|o}u0s_(p0{^xN0_zO|u?7DE%Lf9;0|Ku90Rp}V0*(s;|MUR@5(29S0{^260`dj|kqiF<tO^3R1p=`D2?C=90)qzv|Lg(+u?zyi1pfl@3If&$0@42i0__L_j|&3-<O%}b4FbOl`vS}aU<U%b0|Nh)4Fbjk0x$yq$qNF-2m;az{{qtm0?7pe*Z%_o>j?s^1OoqJ0@Dftkp}|*;RgcP0s^%J{{pB90-6c}<^Ku-#|i?h1_J-}1p-0>g$)A#iVXtJ3<7ro|CtH`yb1!40{;TS2m<{A0_Oh;0(t_G3<B)`2m+c30{;a9|H1(R3Idf20{^}O0+|K^>;eA*#0CP?3If{y1p=)I0*VL%|DOi}=K%tw3;zPD3IezS0@(is0*3+u<pu)(vH}8%0|LYg{{o8(0*MR)zyAgTt_%XY3IhF-65t2|-UkBF{|5rZ3<9SL0{`m_0+0#<*8=|n%nJfF0-O!|0{Szc4Fcu~0{`^{0`Ld|<^=x&k_rM20<8-F0<#AK;0Xfn{{#Zd4Fcc;0{^@N0<sDM?Fs(^n+gKa0s?{m2?C1)0{jR9|40If0s`&~0{^ZB0;L23l>_?%lO})x0>BFb|C|H@*9HRS0sjK-3IgB<0;tXrAPWMHBfvYL1p@E00s`O^fCK{G{{jM$1_IXv0{_qr0;>oDxd#6Ncmjh60-^)o0*DC$>@+|L0{`{~0+a><ga`ium<0lk0RsO21p@jA0^J1ye}@eMkqQE%A%On|0)Pqv;sgTu+yWpWAOr&H3Iz9NW@Z3D=05`Q{{aH72Lj6r0{`;@0)_|znGF8|iwOer1p?Op3j(DB0{#O6{n`}31p?;+0;K;40>=ab5d!r7Ouz;L?F0hW1OEbz0Rq+p0>F0x0<}w^1_F~LApZpdod*K$2?GDO4Fa?b0;CH60-*;2<^uxA{|W-J4Fbvs0{^c90`dX^kOuz(m;(a31_Dt30`v+3)eQn#{{qPf0;UTB@%IP<hFYKr0=o(S0;mcC$^inN{#$?n0>}#jj|~3;&;bJH2m;LhLI4Q@hz0`T1OEc`3<9780=mBm0=@(SoGD-i{{s940^1A%hyM!#nFRvV3<CeA1Oki=0>K8~0+j*+yGS4g0{`#~0-*x};t2l&kqH9o2m;gp1On>@0+I{@|Kkk;qyqxD3;zP&1Onv+0<7l<0_hOIX}|#j`Tqn0s|5n&0|Ngg0;>iB^bG><q6h-(G~fvW1^WV%3Lpal_W=U`x(fo(3j(<U{{mhD>jDC=3I76)4FdcF0=xeR0yzS~0s@2I0t5g6002PnKmP*10|Ms?0`dP00_O|@;0gl&>;wYB2Lf*b|Dg>6odg1q4gUi83IfFm0`dO?0?Pyf$pixbpbY}(2?CZ0{{ox|0<Z!ChyMiv*bD;m3IhLv1_Fx=0*nf`0-FgsB-TF+hqC_-0_+R|oeKi}p*A200`dw1&%Xi!{Q&~>gdhX|0-gf`)CL0LzXk%20s{4NfC&EtEkhjZ;x-y@KLU~l0cX$(0cZ334Fcv2r~C^7h4%{rfHdF>0{I310*VF#tO5e){|y4+2?E&$0{^`Y0_z9@qXz#1$_WDI4Fasc4FaeH0*HiQ3;P1uQXm5Y$_xVk76QHr0^JG%fAR|gwFd%~p&<O6Ktw<X0__6=!v75dsRaVm2?GE92?G2L0>=jb0wV&_1Omzm^8%er06jno0>lmb0)ZjG3j!|!tG@yQ=M4gefZz<@0)q|$tUSOC0{!$(fDHou2LjFi0s{L90-^x|ewUyG0*?v;m}g-B3IeVO0?h~l|KI@v3j&A-0)Mmt0<s1IhOa>P1OoLVKnVg_0=ct70IFaO0>dys4D$k+6~K;Q3j$06|IrHqyaoi<qyKO{3fI#=0`&e^U<LxV2m-|hp8}Q!0-`Jc7a#=h0zm?{MW71;<^KZ$uLc4<0@wazpb7%10|J%>-vXEo0@Zoo4g&vy1_GQ10<aDH0-(kK2Lj^>0{^xL0-^;1w*mhG;{yW20|J8o1p=Q50*?U#|2P7p3<B{70^gtt0`~(Cr=1M{0_Xw)#0Ub${|f>?0-FH>qrVLTj0pmu0$>CG0`>#~v<(8eKMMkc0s`S<AaKC{2?AXL*$V>b{w)9s0^0-vi3tA!&jteJ2m-u*us{m}=>!6T9f1D?0=EbP?*#(?;|l_?1_BKN|C9^@83OPI0{^N90^JM(Jp%vO2LhK20&N2Ss{{fV0<Z-F|Bws<kpTkm4gUgw1_HGS0<`}G0)+ztAp-0F1Ok=;0+tN|f7by5r3C`}8sNVP0?h^j`QV@j-vZwX0+y=43IhGMV;}<p;Rphh{+OT#0*?a%^bG$3+6Mxq0RqSW3j%Qh=n4X7?*b<RmSCU*0>JkS0+gzN0|N2^?*eoJ`7_`F0+ROw0)wi+3j!Acf0GOX(*pwTCZPU=;0OZ94FZ)6{{p}T0?-2jr2hm0t_=d+0RsQA3IebS0?-8S0zd-)6d(iwQ~v^E0@(-x!U>-Orwszds$lP62LA$~3<8n?0{8z00+0y;_XGm{y+D8q0>cCX+5ZOu)e8da2Lk>7$AAa|*aQO2{`kNI0-pi`lm-6++5!UB2Ljsuihv9P_X+~c4BrBT4g$wA-~s~wqX+^90)Y(z-HWC`2?F_&KnMc;ptk@E0?q~kjsF7z=?wyZ0@%L`0^0%t&hNkh{{n&o0wMy>1m6OR1p=|6fCK`6&IAI%3<8#BfWHL-@(lvX0)Pzv0{;pEzzPDs{{sTE3<A3c0{_Pa0-yx~9|Gqq0@|`5D4+)d*8c_q%?bjq2m=522Lhf50_+3d0*e6x+{T~*0{@~60=NeP_XXbqvJ3*zJ^%#*{m=8@0s@Hy0@(iw0)zwt<Ou@*_yz*x2LhW6p8~-P0=ums!GHxH0)zzup%I{J0BT^r0Rn*p0@L*X2mb<u3Id`B0{fo|0xAN%QlKSZ0e=Em0>lLZi$-9-1Ond&0=WCY3;zO<1p=7}0`va{0;2%}*9Zdn+@64<-~<A-0Rrbv0=C6KoPY)b;P(px@aG@{0^bb(0-Oi}sR{!5=LrJt)POBu0s=AL0=^0Yhn?U80`J8P0_Lkg3j(12ZNLKr4DI(H^#3zZzy!H!;6MMw8z4Xgn;`1{KEUywKm_W_{|vyZy8J%``rlOJ-$oh(K-~=gH{jDYpFjkV|B3G(W<No|1mCi+>Hj1Kp%=IR(EuKso<IWV_X7f*9v}+>)&>6p(gp&B1_Hys2Lg@-0-V2~1OEc91Om|v0;>N60{#sG&<6tl!wdqk2Lk*I^8(1VAbY?80=x_V0?`Tri3b9i?%N;^0)#jq1_G`8b6`QB4Fd5E0-pZ`0=xnOfer%yj0*y<1On&?-vW~g0*Jz(3j*)n0RqwP00#o8{+s{<0_+O{><Rk<#&@6v0>TOc{mtq?4FYHaxe5OQm;wTr2m+G+G=K&Iz6Ao82m1o~W#9q=!v+HVzc~O10+t5?{{IF7_5lK@1_J-V0|KlE0;dCe0{YZt;6DP5OhE8WVA_D1fTDm40_p?*0=)$S?hOK8y8`n=00{z#PQVHO0@4iv(+2{8_X`5bNni>B^8^0^@CgFi4FcT%2m<W~0=)_X@2d;~(ow(x0@VKj0>cXe+5`gsn*{=g0Rqzo{{or?0<{YQrS5Pb2?Dx~paTMs{{sS%2m+S~0{`#|0;L85gAD%y*a-s13<6}I0^1D&uOlFE00RF4_zVK90Rp!F3<9SF0;dN8am>e{93YZ_0|L2VK>rB>p9%u10Rr#o0|NMhKmr2O{|Exh0|Lwh0{!rEpbP?~3<6gF0>26Z;spZS{|W*W0>=pg#s3Qen+5`(3j%M*1OlS6Kmr1C!2bvWy#fN=1_JNa3Idt&fC&PC_Xz^k1z-&Vkplk$?gRqX0s?9O0{jUAVFHQ{`vSu1-~|Hy0Rqp51_IFZKs%rb0{@!_0viJR1OorD2?D+b0!jk+Bm#oe00siE1or}!3H4+EKmuI<0<QrA<N^ZCe*pr)2m*)!_^1Dg3j%@x0`?650tf=k0Rs31;{vWifGxlW-~|Lk|3?=<oewd<1pf$mxnFRD3PAq^Qpc4*YuW?<zyy%?KfqdLe|<m%uO%j+1494(_I2Rg5Ol!*1TaUB-+PLu|G)%z*q<MvoBu;V1oWl1KbQUR13=&{kf3;n`=UStM*|6pA4C6nlRyN#BKY6`>JP9$1mRsS|Khvjk3a-YDE~yj@vp7G1P1>q<KG9zz`z9mFM0BxBmzf3{{$x#BH&n?xBtKd9iT-3fp7gt6evL(Z{aV*{U;PUct!BP_3Hnozyy1>NPpD-qdh<bTYL(D|B)Ypzy!Z5g8%<*a-%>5(S-k+-#BUwKm<DflFNT+h>Ac2{~_u=05J%>!2bk<ocI56vPS+CBSA@#zyyVv@3w#a&=-L8sQCZCqu!1{1miZ}8o)aouor_5cK^Y^1pIWD9~1vnDnJB#W=VhtB15(ppDWWBpBJAOpZ*t~rhv5n0jEF!FF!`XLuMDBFFzNb7oQiO;9C$cKStjdpBJ41v<d$NDCPg3)Z9P+zy#Q>ufH}t{}@07Yw;-n#{W;CKm;6k9l-w%`|rO5=wB)Sz!~F2z6511{}sSF$e}+3B>(%UAJlw2z6AfMGXsF*@OM7`14X|CWYy4LT>ss7J_57{1pNQxC_ofQY(NCRiHq(3El$>;zW*-6f4XaHKm`AJZ~q_N2ZF!<1p0cdKO#J1|2_mNpaQ_I|NafY)LzEl->+x?z658M;lH+V{sTup1Qg!CzjpuIXFdd^aj4(_#oTtl1iWKs_rMQ9Xdsy>t-t@}S%1I;Gd(B&ASM2RKLlex{{kRxpgO(;#Q!oJAg}-LKLr2A%u?XG5B|OX1YTv^KkKAA{XPRlzXU9bLxA5N=K#J0GgweI?*U*QtslU<_`Lrh&Zc|51f4VQ2jCt13m_oOy#HTQA4Wa|?5V$Qo|2M#J_AL+{{$vnF`(W2JpVofsiaOo1IPcQKm<1;bHEAzoHalMipd*b|AsY<Km@tN9Q(lk6d{(3CjjdI$Z9?W&1xrr|Bre=KLn_5VE>?k#A?0-BZ<E!fN2|Xz5_+S{{-2^_dl>1as57t`Jrd}zyA~d6d+b0en9wnB>%nyF1{K7r-1*?KLj=6onOuSR~RXPzCxfnDf==$14X|C3_A(`fCn%zz68Qd|J%RnUa>#~7oVR3V7z0gV3Yxc{~xcw1by~6;Qlq@gLdhR2{={%z65(@4#499|AIdR5Ge)e_5aUQz69X`+%WT_C^g^%M85>s%Kzv_I1y()0+jy&0+$8?qXPo}Hv-!O0^|e)|7g(AKLJprz@G%g8c%?w;v>N(|2}!Z1We=GAOBWewm$?HYcc<TZ2}TL1mmIa_usAHF94Mj-v8e&eqcTXz(LOmfHoHvKm$a-1pm5)3g88sU_So>sRRPm3<A3U2Li4G0<r@F|AqquGcz+YGyl7_zywI)dKCYzCrv;EJqp+Vqi{~MKmz&${{&o*!u2S&wf{f_!}Ta!kMjRiKm>*BQMg|J&bB}T#{vSs{|EyA2LiAI0{`U+0*M9!Gy>zP2H=L_rUEYl-UIsrkLh3p0;d83|Ck2?=?nrg0{_ng0{;O5*$MvwnF0db2LjB$2m+7+0`K?$0sjKL2Lizf0?_XQ0{aK-XQT(w|0p2<0RTY)0RJ`}00}Sy00!Rx9t$@B0%1Y~zW_HK017bzVhsKQV?zZ1I2`~B{W1jN4L1M>01^8$1_hu807M7?zd8m09S=4MpdVcc2*4Z<HvvE)0Yd!|1tAwT3IGcL|0p^D3IG=XL8}J}1E3%U0uTeC7Vk6)00;x%5DNhR6g>bQ2?qce`!);#;3<Is3;_Re06H2&00IF2BLEWsIt~B;zW`JKBN-+L!VLNd!3z-p7Bmb15B~rkIw$}Q0IUB15H|q;5C9!#4gehiKoz1AHx9t}LkSNXVn`4GJ*opO5d$Ly11}N=V-u<dZxjim1OqP>9DqEl2?7J-76&gD2O}4%3U3z!BNziO7zSe*ss?Ww38NbnFB=0R9Lg7O90p?@8m|IC033Y_G=UxfJpddrV0RWY9yWkK2Olj0bsjqbATD4RH6b}-sUk3k17ZOKVk11_BfbM^2LKl}BtOC=KL8m34kAQ8AOd0aB|{-NJs=YRISpPr-~s^N|3rZ$1giZe1fksku>hn1*DVhxIl?GBpc^UjJ0dDWfd_#X07D7=D?NfN00RILE2;tEEd=2%Kq4;$=`gAS=P?C_GDRXY14lGU2<9~mi8cbpOJg_&;#D~SqB;c$J5NG9Py$swP{KY6CO=wXAs%3=6v03d$3YHeLJ3JjDp;aKSz<*J#ztcW9br{R6{bjDLP=i&N&uo&O95g`0wPTU;!X>pRSys3PatMc4uRDY#8puvMp6-BKNX}?CMH!>0>RN3gjE8@Ru3XoR}bP?8%J3Z0$LG5Ra+7QToS@v3FclD!c|`tf?yUxVHW~o7s6Fz0HS0f$z=lqW&^_YXA;I}1;S|nlK|flDJ%eLS%4l5sw}~41SV`NX>ALlZmJAoZw(@F4dQVQqH?MorgIRYbP-~85+Zi065@9a1b7Vwc_b!!suv=A7vg+8p?w8}eyS3te<{X*Qm26|W`e38VuK(eghq*lSZ9W+GA4&5B8US=i8Y3bswWAHDk6+3;*CRsj;cgLk3|BIMZ%Frf|6<s$CF5+ln{ZB07^qul@N!POk$T!BA89$^_fnhnu&o60sw;QdqO6F3Y&ldJ^&JX0A-9I0028bVWI7u#6TmR0st8|o}|hlxI~`_<d0*U2<o7?i3P?*guy`vpbd(lQVoGS%IE}xp_r$kI3bk^&|#sR!lDK(n1iCK1~;PyGouDKqy{sjQVe&c9gV9)r7J3?9f5US9ge29Nj(4^9e~#tH6>R83m(Hg0Dm702LKs2Ccr>{APolq8aSH)Ab%ka2LKy6rUGDpA`b@u96F%#VE-NfD<uFqBLM%Q04*i}J0k%1n*c8a0Pp}gJawSO0jG{YLI|k+z`G);$G{jissaM5ssaJ50s^f90<Hssuc`xrumu9K1p=}MA+xFnBD4o0wFsiN2%@+D0O|k_Lqq_$`p_XB)1n^$2mrbN01&zW6bk?+{YE^f0suw;6}rCwFaR?ua@GN+uAyK+2)hCT?gL@GY6D_B0YSY1LPY@vAl1GCq9p>MzXSpd0ahDeHoy-g!C2(F;o^P5Pv<!qLI46>fU4Nx!UT%LPvJavpaHu8Ar@g5H6M6E!oL6=01h?8T_7G)5H|-v=i|c%O2r3AUJfM?02{^!QpFCcRmTTY$PTi{77EE06IIF<63HEE%Lh}*77}&KB+ASVp*a8zNP+4rqsb}&CfFcB2h6G}3e6Mq%p$VQF>21L8%__Y!ObcX&N#}?sxfZOu_4Yea?c{F(5eSh&p6W1DhkmtVMVA%gCe62qR>Dx(I=qNUjQQk024%j(?o)G)Jx(uOrRSNH>#oj0H6o})c_E|0RI$Z05lcV00jR4)&NQ#022rA03ACYb|4%&*LFYPE$DW@0RSRa0oxchB!L{*PM{AqwpIcWH_(6_*#ZsGz5)sd02ejdI6xD>0ABzwKrVp5M5_wh2I1TRLfrvD3Mv6Y-U6ZD0;1sEK#G9%00cte@L&@x7XY_J3gQC64FCee<MxYyB;<>L8aU+u|F8fU<^li!AAcGG1^^xtHw!{l<^%!f1On&;0a^qBwFU$T=>!aX0|+2$st73R5+Umeg6t56?Wzlc?hHcj0HW{#V)3dLVI32M@)=?C1Y-268DZ5Hg!LI=D;Z(-sv4&E0%rIMg88PPCEfa_pc^^+8^Zhmf0F<bDlGv0BA~lHK?x#84E{l&9=-pnphgS;0k+@{z64_d0RsRPC4ffr3<3cm4M0W=0|EY@z%Vxf7XU^K{R9PQ1pyEM9tLy*!ZINqFJVRu;I@EgCI<n%0Vcs3D;GfPAreRd6)NFI3<zHV697FA5X1=$=&B3h3J#_V3jz!Ufex|-gbft}AE6Ebp1}|C0X3kWz@?!O0T}@Q4kAPV!2nAD-v~w(01y*^91&O(fJMYZ1p@#<V-g4=wG#*^6bqmo2?wJTst2JJ2d5SRLf|fD7wQM17!T+bBLEx;2k!tDG!+XV4Kx|f6JQ+=Hs&D`K?g;*6aW<xKpPq*;6tqmCE*(z0YV%F!X1<m0R_+=1;-x+#J4~o+6N-w&p|C>;~+x`r34OwAqc4vXCe`FBi;*y0RSW=VFD-se}Vu#ED8W5H^BEEJSv6&AteD{?*KDHF>jzTK`)MQU@t!{4gwa-<Ka}=<L4$uAu25!;6MnaCo=*?!Jv6TClnwYel|oX0RaFYoA2VgDFN=_I{*&;04Mz0p@@Yl0RjMk|Goss9RLk9D;dNBy8tb{0Gj|Mj^Y?=HWcZiEDvEVsM~@SEi?!z4WYsPqBJ8SrR+xQG=Us0M&twlFWUi2nxY;&nxP##|0)3l05Abh9=`w=2LK{KogpFnKi8k2F#%H^0N)!20478NVI@QTG6di=0ac~|AKwQ6C`Kk8p&>W!m_R&CI+*}EN;vMBz&J=Ynt(P&H13-~G(<9-05U=_Oq|F=Ar3V|B3y(tOpJOMSTz_%HUUWsvjImOIw(0{sAUU}Hw&M%YTzT{I17e30luXqzDHm{FAV@XM_?iQKO+I4L^KfqJMKv!CPV_dKpjLp{{cw>FcU3DGrj|0NH-AxJxrh}J4XVrKqy8&6F?(>)WAm<&p$iiKvw`3G>t(|!7D^wq=MziArNkufI$aBD8L&FgyU60eIY}ACq#WdMTF=@MTFr-A*72yvqDE-p>r-uydrYp4mC)H2(?K#W=X6d5iD9EO8$1_8~`8<FaRYk!(c%NOBF&)n#>LYkxdQ<+Tsoa1s5U?4^E;+hE5I+rfV6ZPYaT|su{FUQYKItt|90EMb{PpIvgPbzyS|8Jpck>Mo|Gfx4{Bp{97Od;Yb1iJskks5H|v15;yX|7&dhV`T<h3;14#$2f^DBH~b(SQ?~&(RQ~}-0X-f*05bH|z|?{Q)528&WB~s;8dd?X03JQ=z+eC&S2@5*4_NfI0nfx)1Y45;6fCzd09r&KArJv$Tk-*DTmfR?0bKz%0l$X}NCZg$ykH66FaR_#PyrzdFrNT8F-rjgVFKU<>H}a11K<k)U<NP%_ck&R11c~8H8asy2jT@`2w*e`r8qTJgaYLb2;>J0;132MyEdB!CIJ8~-N6*MQXv3Q0VrNqU{Gro+ti>RB4AJ!Q32OAI<yoa3>2UZ7q<XV7R3P?K~e%7RMVjdD_;mQ7Z#xq1)zNq2rn4`8!u7rqPG=OA`rqUU}!*5try%uDPaLZ;IV)k?LzHh9XDHmP84Ev^`Hjfp?`oRLSw(6uQfUV3Ijr8GvGk~A)x?004W$3{{T)DWC0BTW&Z&(p#UHU044qfKn4IE9610Q{{RLz07w8AX8!<5Ll6KeW&!^b07?x2001Z703R?G06*X-Mr|KQz$<41084QL0=pnF0|F>VAOip_-Dm><OqCM`At5qu0|F^XAqF5VX#)UnP5ns%2|yw<1|qjANg@eAE@}xtPPdI31`J>$Gy?)F+e#x0U@vP7U{Af>ao8XLBsBv9EKBVq4}dUi4}efjLhTO{pd~g2A}vfM_7b2mZ36&NO-oF66~HDp2|_MSCKbSYGHwF^QjM0F7~s1nI1-{SPA3@PGyQJ{AX80veE}!;04O;Xz&!voBflpA9WEXKQ=lo27y<zK<e(&g&7oxeRsb;^2LLNcWZwZl07C^Ipfnu608{`qD>$uSCjUrq0bBr79v+_n0st@oH^cv-B-=tS^k6kN^#CpazbP~T2mnhj!7sW5N-YFIH~<VQKqgf#2mmKJqAdu@FbKgtU<6<T039nR!3e?KFb!ZcHz)hxEv9apz)cl#^uagp0b>7h0XhIhIywNqFb4o6LUPvtPX82h0Z;%m6-i4dss(~{_h3~9Vy<9&D0N*#5CAAHrNA3d7TMt%LFIy4;8LrW1|cbSQm1!PqTnGL$wKSGQlxkc!N@@)K~~5@I98UR9SPHU3B-2+05MpBCq-le0(E)_Kr$)8C`K<&;eRdwjsP1oAR<7!I5#3d697e2p#tjw|24od1mPz|FYGY@D&aU&U?Nc$N4mn`AiDrj7kdnXe6}S)JK4gZQ5Sc?8xul($>C{4erZI3A#g#G9fE%orwoHF2cpv=JJERwDAOVdB!Ha&Di*6t0C@(1CP#vK6ocw{3WRw9JU>9f03%fbdE|t7?1g#ig!F;#dE+AhG<oAf0EYhoFNXm<697x~4thivdPPD2hyi~vhXFkk089g8^B^$;VtS!M0Eq#AF^2&@697#H<MSah2I6}GLI8>Ze=>&wKNA2>3S;vkGYVpRVL||l0sk|M0YDG{Fpc(W;3G5*pgjOD9!hKB8EfSY*??>0g=^+jg=_MTYxFT|@iA~pRWfVxG6ZTfYvEIC?4>hn;z3veYvYe=;zF)CAWapJ0b<Z;LXoO%WG`)Jl544hYoU`qYoss$GdeSEBF4k9Ax`08?gl|Alws|Kl40#JVeo`Q3@cz^gfU8Cg<WBq7*ir)kCkDJsuMz%VU03jh^b+em-JzX90HhOga-g8MI|!`2v8A7X{njB0coHV^Pwt&nwCeKDq@yV;saHjXzBp0f}G;)o#N`{oM`7Ctw7@9LI9rs0WXLFJVF3(UjZ?n0Y2kl7-<K;paC$60X+kOGJl}~KPLbnF$02rX(OTmF^T~`2O<A6qX9rC03kB`2O?=hqyaL90YCl<!8D}-K_>trJu?G<Jpe8pW+4GWs?s45W+$D}CY@$7rmE63G}19NW-2w!p+-v5Ej4PSrrrR`MW@O{RW`~(s6{cUx{aN>jj1$PmW3byScEjXC0VMvI#{|is#uY$SdBHRScw0+G_1NUt-2?!YPvM9257JCKq;`mr**Ny0<z@5FtY(+09!^j{a`tMz6Av3!K)xQ69~l|NVL|7wW^b%wW?q(mBY4`!X%QF!nYsn5Tdvr?F`9Pp4v1w06hTOB^hG5s(6SvC<uiJ6gUU~DJ*z|A%Q5mc!#@qmhnYO4nn+!=)LL!@T2AybY;CS?Y{7&v4A_IMo6Twg7-wfjffQDz_=(R_Fe!`7Puuf06RZdF+(0BAsfJ9!S-S8IA{VYF0Y{B{}-<SP87jVWF=?<!c+uhwc{s}0>T7J!vs<F!w9Ox4JRhW0RmM32*bn;D#i%W#u18D#|<&Z73#<lk;ocK)yWm{$sVf88b!hYRUj3m$|CB^1Tf1dDpkw~aLg-e%?z;3FRE3}D^bog3ePXG&p2fDo1lWwFQpRzMGaE`06ict<In`E(J%2;(Lsc|2?Ejy6w(B$-P71XGyxX-KrSBo5CRXUKq%M%9RSxGLd1mt9#=pR09Po~0Rjxw0tx~J;HpvK(}UtTh6mP$0%xkZV%LX)Lb~GE0b*OKykgk`;(Wd0+5uv@s=s2}kD>#Og4~fJtg6Cd-IAhB!{XkQB0#FeV&9dbBgW$3mm+<t$YSA`qFu@2;tFDoQp;lF3*yY<<fVWvCj;Hnra&V><qv^5W^N$h8bK|hK^!(3p>700BSF%x04L@mK-U^U=L2Fl`G7MymA?hJ=moA%0wN1#8D9V!FHr!JMMb(HRq47X>cF(=iU{ezpt~sRiUa`wFoIzwGep6k!kJ<^JfT92BY8*~XQ1H}QXv2c0)6ZV1P1^nM8XGXomvNKH2^x3qKyHQ{{S2`HURAb1OEUXD;EGy74Gi=697h6K`j6yUld3H?*Rbg@Brjh@d4!W0_5`p<n#pORrLkr_6Fql2jut&<X!n8Ku;C=Fd_Q^LjC*?Cj9|q074^wRspX7Cq^Dvz`H6}Ccsh{SRFwgt2Y1<<NgMM|2QE4O#&6+0Rk1|7l8r-LaPG;8HEG`i3I}22LA%;031+J00;j94FIM9Fb4wdAhDqb0>6MaEC8=Y03rwhLiPbc39163f&oDa0YcFNp$k?4LS6v{U<?AH839364Fm$52Eh&mVjlznRSy9|Z3%%80;2L@;#Cm@A|_+v5(T1uW8zg42O{TXViX9XS!iNa6$&DM2*DN$g3W2dRTm8c&TB##4uYj@!c`d%0#0s18WDmB2*Onx69OIzLL3x=Gz-G%O3`FkY8@;<Q5V}*ieM=o0Yc!5A`?%c-r|HG0zCltg&zXijbI=$z)%(jVJIO=0YV&QA{}icE1)7HV*S31$0Gs(04+dTcLG6%p*Y-^Kpl2Npj*WYViDmBVPod)TxfRe@F-*FESr0QI6(lST>~UQhFu0;q3?o0B}D>EV<rIPUVml*_GSgFP#+_}Cnr{-C;>q!stx1;Spq6jgey{mEBgW<b3-cvLI5TI0xT>7IYIy}{{k*90y`%F9Pcd{00CHIF9LD@07fQH0Pp}t>q9VF<S__9G6FFFF9IM20394T{{R{Q1{DA$0M{1*0K}=y#H}*|{=}&Q051Pz07d^MFalcuRv|9y05kyPH2~x`0xEw1OEgD5C;$YZbuk32Hv^^u0E{pp>o@CQ0XSm98vzLa06794AOIl;ZvZ1fI%PpQt+j1kAnE`kK|2G2DXogybipOQAT29^AWapjU?aw0C^=>bz+tE;l3}Qc(Sl*4l+yxXqt{Z@f=Ua)Pf9#m$2|c;_F+L9L1981HvkC#06qd8J^~@6uK+q6KLtlXU@!>l06_&tLJFh-056p<1wwkj!6gg=zN0bvTBv=#q+|d<AwIfoVM7vx0{|blfKVkC#REiP5^M@i$KY%P^_wi>B$ePaIZ^@o<iHZZ!6X71037=;QrbcmR3iXFw&q|eM6MuG7=ghm{Y3#n-~a;vAuQh)08$ti;lLb2X&AL+$pJ>7AviSdz`HJ{{{T)FM*;#7?wNp27D#>}2>@Nc04o<x9T@-MPx}=~0zpaw3jj6$HvkI&E&wUm|NpE1O9%i;0^c4=0wO&HAO`^VB|}RD05&)P4F3Re07oZK00L_OCkKK{6~syc1c7}_1c71z5&&f~;Qs&sNlh03Q5SVhzrY|Qpivi2#z5&v+(81tPnX~-83HQ+ArOL06k=UJpcaI+P!#|!lR+dxlR`PQ?2|zqB)|YJrA0>8p1>(lrAIDHKv5T_p1~VJp27vtQmZFZngK$xp8-3D2SWT|8>>RJtfDrT!Y)hzRR01W!2lvl02S9$A^;9TRS0AQ01O)AMglvo2uPs951=_?x+8;DC?Qn<9wUGU)c_-fDiOk0Btnw_-yb(R09Yd6EE`e*V_5-WD1llhK^F$V+5v%Ew!kvFbigP^-NSW&Cq+lq08tlRTrglLM#lmuT`Xj)@&7{sRzTt@8X#VZ8ZBQMG9wDYB7+(+VE#S9r2!EDOaVEoCloJ&VJpI70HR~60HS0(<QF{RU{PWsDk`95Dy?P^avBhDkl-sgoihMuGYx16L<9hfI};a(Avz?m;74j{q6O%lH^>F$4FOlCU~0-G?Q0DP#|ID%0tWz>Btk~JLLz>lQIKrX{Kst<LRV=ww%{Xfs&`_%0YPtg!gEppaGwGnKmj5P!DB<riepr9V@GlULWaR{LlRboz#BrSf*lP4bA*DwJ^@AmBXou0N2(5Cb%#Pq0-<(@qT~Ky;CBKZa{?lyuK+t8cnk-57w`yE0D1*R5omh_TznSCm3<1bev=|))Zl2#f2xfpfMh4dWGI1<34&B*!UM^Jlj(#5&V^YbN~}SKlZ~-3CzfgGGX!5`06`*im4SzB@+t6#Fa}15T4-ubPz461iC>8KQgF)a5X#|-vdZU+%Irh|97F7)9`!f0LW&>2D;G-uTGFA4;D9QO(x;8mzEz9|sEh}pj@oCB4`&v{;8GY5Z;*(A4`8rC6_6<bktq^QmJohu2O=fBnu6Qt0Jn)lomS0(RPg~8f|BtElNO$o7Krtf7J-!(gbe_*0sk~503-(hCq}hTcVQqbAyF66LkUo>sL@3jhzTN=AJRIdbXAIn!Iy`^3z?vpzo@Db;+YcgQ4;P(68|ZsnljS<<1iX6n<H>jS`cm^BY!EJLsD=Me=8}SGw@X)?%TcSGxepOQ_>VnpK9Tsa;KoGOrD`*D4}B^qTp!ArqfkR0BIow;-lthDi#I*DWnDHQH<VZqKwE@r5YZl8VII+L8pCE>90BPoFk#W03}1H{{jmDHmU#*0AEZ2IVTh#;;DvWy-v8I0sy@Jxgn_5>VjVYQNX4pfKC<_s_deZ0b;AX!GGb7!AcQgtd7!`OM4iiPBB7Kj?F!m8z17WGzjD_AF4<puDa*1NItMG2(U^n0kNxc)Et`!BC@iwl@*fIN0DH&k!TNsv{F&XGgsRcg0)x3D8I;mApr&e9vwD20hBl;1>&|{$gt$U<e|4J<fpjgzPIG4w|SulxPKP`9RM6d7!@Jb>}0tDSZTUgVK@N)3;=NeNGMSNuL1zL|5jnT1d6-<1c5yO5ddZYO8-PX04y7m03Yu+Ism*}z$_aVuK-aOy<P+&_@cWi2ZSYLqP`3vJ7k~-h5iNs0suV#Dj5Q+03`mxz6J`v5=9VK04FXIASVQ3zY2;qzyxx@4+>lWbHE!xrU>d>03X8>gIxr2T~q{Qe8a&Fa=|Fd!YIMFOaKymfH58(z$d#!4*;MhMA#rg!&Y8F!~!uP#NJ>YF(6k003jN}!hhkc1|ZiYLd5|<FAhVx0{;g9BtyIc1^{^-OXCD32LL5Q1B30o1BNX!1)wEE!P*Pr#sa|}HR~W79sfB18UO|l03+W37y$q<5}_tU{t}@jL(KpX04deS5$qI{05cIGDM#(C1K=*m1K=M>$?gom9wRp-z&lF-l^<P6xp?8q*~AIp%R1X498KUGLLFlyO(Wi8ffiIF00to{%x;F{0RS^A!6`=>!8a&Iyoh3Y0Rq5A!S^Xgz6-!CE&z^i030+SG=MoeNFcWX05vi}D@g`nD!)j*0s;Un6CpY401g*`GELzqM!xm}q&Z<$00#gkNi8aL!6G(WU|SqO2rBiw2p}d)z)~1T0sjL4AuJaFQW*Vv|KL&>d;u^3S2H{z0b&GbVtr_6Db2R2Ap*{l(lM`lC_<&rC`ZsJU-yC0C{w-qC{4d8OgI1y0K)$OBmw{f04@OkDd_*d|4ab@x+bK*CZ$>c3L+TsR0Con57HtI)3ov~A|DGW)FKDfN`KK|N`FdYMZijIH=f`k1R(~%N5xfJAsVV76xKs7*VYm(4j~^Y*h44TYmig``#25T;MxKn!2o|EJpd~gO8{)f?b}3VG1`d093eMEHzI5ZTzr6R2_c38X=fQ+W`JxVIY=RzXhUSrQQWcQfFFPmT@&>ceP>l&6XnV^n&DQo-8GJ0E=2<XAS>GeM}WbrJCgW_NSjiMP{H1k_=n&4jPTFi=0P?f6|Ykw0N$xVc!1~NUOlh@04~AA!rr#v#~VT-nt;P$K!N%IUq%2U;Q~S7!2v=2;sHYQ00;o%0)HN$03rbZFR(?H4IwJz6zAox!nT1NkwdnE(?I{><~J+`;^$IIXW>d}r%`Awbm$)KRq3DS>K@{<E@HPXXj!z$#2{iz047H3r$m+?AUpd7=phB^=^#SXCTj@I?64>8FE9-NKcE0I!2ls^qbMS-1i?}m+vLD1C^ha<C_eylrzkN8&y?>+Ev4`%Gf1syC^hjYC_AjPXecN^0Vp9sGJ!d-p#TN|PNmXI;PT%BADaLo1L5-mZwml5IjQB7|5d=1n^nT|Rl+M(#P$IV{{Wi+GadjT2k!tTL;_ksB}4T7S7AGA0384vL!~Y3$n#`k55e^d!8f$BAPVO73jag)3gQw}_reP4^;@K&52E)MK)W_Jy`oPQ_XA4!{sTcm02Bab080NvLIC*!F!}=jJwgEc0y6vp|35+i{Q@-p0{=lm0RI9u00aL+CjcNZ8~_3DJpe2lhd}`YJ-+}d83F(wkAP3>75H<)wsK$s10MY)wZjJhB|`%P?+XAnPYgT|05Plo0t>+#3(p-3!UM?zgWxqOFEu1xZ3F}A6JguDKr!NBCq)DF0s@@l0`sah06RZVGDIE#%OMp(1r<U4T|7Vo03Is>0F@XI0tF8Z50eCJjRxuu4FwMfKjE+$037!)QUJ$A5CISX(<%bE;%>qR7~oPEQ{VuPMLdHOM~DI!0!rdT0(Bt>20{m-9<$z42m=q}L_-NQp*SB#t`Ol*6$u1N3ONBi{{RsHqyRe|3;zQ`01N{!4Fmr?LI4f}F%JX(J`eyd5CbOwryegFL?J@qA}8Vs`V8t34CQeENGMUN+khu5f)Npl5(JYHTm*zV!6icz1d|g9B$c3U;uKGTL3V%*%M||uApj)+QxyaINC9;L2LLHYAMVdUC`KwUfGZXQ|6c$-O*;Tz0QWmfIY43;0}TN0G6FN9dO|}91O9|zIRF{}1_%IG9sn2%WghmxG!udUDo7Ipd;l6H|1SV0SO8PB0KHc|001*MviiU-y{1ZlP8Jvg*<p+R0b&^g8~`pGFjNu%(%~8dB0dF28v+7VbOk~j1A?Fi!W{zQT^*W0P8J>nV$})4RUZZ7<qJX}2V&w3!to(k;Z1?@;Rpi|0Fx;qWh4PWBW8l+p&Ly?<f0um6@dlHBx?ks(P5*}b=PAH!X*XhE0nJ@5y~bJ$0rfcCIKR;0f2xgBPb%mTOYzH>Lfx`0b(jORTTgr^8gq<z%&6VM-u~o;{Y{0MKCK+K=p7o;4>p38dxU)b|WD#D?lJZQaXR&>sB0zAvZdqElU$W19bpQCsG2!iQ(@wKs*2>;1?GFcUBw(uwWoZNV{SCA~p(uVgSPc9Hk@6NsN{cFv6zWhb*cd^khdTEkVMFM<On&LqZlHVlPOlb~mmt5~9s^I6|Vs-8sk@LO;ODQ~}9WCoxdMA7M@wRWedSCl2B>O3pMy<X;B>Cq*@&NI;-g?&#qqLpH?$Isgs-04@M2um6bu?@TKIK><Jk0MD!cOk*K7aD$t0gEne#hX-(pChTAzNAaR+Fyc5EL9F!x#RB$a=nY`}!+OCo^&%xh0^0MUJiDPDHOqh-9jtspeP93>5<o1?;7tC7$SD9mr~nH9H7xb!H{Ad=Ime(M0DDI`-k>^;0AVNr{u{w0LN@~)02{eN69Q|10st)?Ae(-Vp&<tVCPV`D0_F7i!pac>`N=l}WN!dLBB9!0IRh%;|L6ch06GINJHG=w5CAMZAwVB%AU6#_G6SI~MgyV$Jp(X413eG`t1UkRp&<jIGXtS1y+;ROKm##Bwn9QK2Vo*L0Ji}Xw*xI<{X-59umB~&2LS&7EENC~083Q!7y$3U4veq>CZ?JMAT0zTOd$j#4-2r@04MJVU@in9O)pdkV-Jr+o+3F<XGKhI6-NAxM@<OYS+MnppJLTWRESAbh-C+VDN6oa1OosdD;EG!^%rPknFlI006RbTGDIHqAsYt(B}+p~TY*kfV2~iD%|JIPM>9DANI1!1h64F5kfB9EDMvN~J^uhQ9R~m`N;dxkKLA7p00030H5~v{05&W+uGF9>Nlb2FHVC0C+e<S_pdv{{Vk9@e09*i7A0Ll^Ev{%`$^WBg153?<Ix2Z*P0yms&!SFu;Z!62Pgns(02lyF0arOE6(Ispd16s|B2`j);!}H~RD5DpeIm71ed1SsqF4hWg;~BBU@92`02W{;Pj+B3G9c=qB|}=`L9IKe!5l+hX-|v}UUbQVvf(l9p(jOKjHuo8Fwz469yLHu6;)jB;ws3;UGV~A@dDLenNDBcNZ{UIDPZ~q=nCFY82}tGQr!UXffiIF%|a@o{uSU-7~23404i-^rvOqI@PQmd@PfM@HyMCW6=M6MZ>q6pW3Fyw=VxWF!m^bC^ugXCh_ur|`p{--?#E{bNY)2mDQL=VrFhC{HEA<VLupMxH>&^&qsM8Z-$SFr22|}JL`!MVZfZ9OTsI%<DQh5yZ18X#04}c^FaRYnqHWv2PqP(n@WQTPE~ZC<Z=&Gta3ie;A%&&=g}QOF;Xz9yz~13;14htt{{xc%AUHb!+y0CoEgTmBQW$z)0RsRbECC^VW8gPZ7<@n>Jn2iqYNM%rKp{$GbNRvmVFz^T`{IXT0(Fx>Btmu4!$2HH1B2ss+yxK-D<>|Dpc31Mb~mo##^rZCPIo<DJwO2fFixcbCPj5aAc9MFEnrhH9-%<y<@V;{S?2DQcQTH6w{rPaaCLB_s&!|1b#!_t!k=|#dr~*Cd^f*0qP;h?eKmqr>VhYJHX?pDEq^a=m47uCfHe+)a(^`mexfxFe>D#}#s#l{XikAr?J|&yFmx$`Swc3vhgE}fZiJUDg2+fLw<y&}rnH5_D7eEvDTZ3fC|b!sDTlJBh>{BbH2^z5GDIE#|62f18z=yY1Ak!v92`3Uia+50B}0n?V*oBR{{a91NJs!E0Pit8HV?3YPZf++19l*dmg0_l!bQnvRgaeLkPk<Z$!JKz5LV1!I4>;cl89m)C%~^x7Lx-qNrTw}l!}aEmDvZCW04)<;voUs05bc*C`Jc?QW(KUVj=-!nd38J<YbluzdZme7fS%@=9fBj0^5XuC`N>!f(Qetd!h&k377}~DhL1-TT>$Q0x6j=Cz`@gsvkjd@<*G$&YVOjJ=V})DV+uAfCc|4o=OYoFjgobRwOfFQDA4)pS$8-)ncF(fGwx}05_mHjsOM#9aOx4IU%Q(r=h{3?FFJ$qQfGZ2O^`yqDBE?sid1Rq)4TtRHn@$Zt4w(r<a1K&Bwt2OH}|c=BQyOsZq$!QP5P*U<XR72UAIV=(Kz1s@#LC)y}KicdXlPtgfbCL-qoohNIhVtE#3=^xI-n+it90A_wmPB}1+9;5Ih^{R(Vitpg1JG6H`yn*bpP044)K{yV`r02%-W2LS&b02pxqNGMUd_dq5Iz#m5|n}8jwA~yLzI5DBD>L4V`Ld6rHE+JwEq&5I{3L!Ec3Lzy!0ucgjJO?2jHAjFO9Sfp<NT2{1E&wSk0zmIf0RS`ep(#fnUjQipK4uMIEHglVKmi8;Btk)W!Q(lWPQ*4K{DCAwqx{!I?yCX-5CAF|`tGN$?xNrT0{|iaEEfP$7#9H@&j1`l7_?!4<QM?D_T!*`03}1OBOyh&0zeWVJHaVOt%Tq*{~ZSaEK02dKmPzk1poj5H66bIQ~)+CISpVh?bjmVNwDbP9wax~R3J7Jp)5-@!6HfdEx};|z+3=TA0MP9fUASA`~(gou`yv!{{RmFqyRe|F8Y4LvWp=Z0stid{v+TE0OkKo7XVjJ6|rEVU|^@SY0Rw{A7SSL9KqXVU^4CzAt*+({6Qf%02eI)CY6AC)gYrGA>~zj0pfh6B4M2feIzI;w3Q)UW3^YoN<lysfmOEPBDdh;xZ$F?;$l_0<08A`;=JUdy~)5!DZb_czX3r9Bf#h)Rlx&i!s<f9>jK0eWO)L9p$~-}02@M3LZXl00vaGefN*2QYR<(}YR=C={D^19Ucj49!KPlpL;^peXCtC#F16}xP4;X;OKeJ$03H7|Hvq*0>Hr=8QBnZM191RH|0hrY@Bl|d$o~VR06ZSa1491*xC1cC13f4I03R?H00FN6|0hNt073xE1OG6&13eG`EzI8oCjcNZ10pC#{U8G%$^bFD13qsM04~h~AR#gXBL68!Apn8^OgY;c04kv`&IVv2GwudrDoG*(AWb?O+W^2UfH2Pqpd&Qy38E`XBL-kjI~;8QEuk^c10W<d4C41JOC%5=#sD?9{{up;06a?=0Nv3Bz$G>q6TvM^{UsB?$N)CF14DnU06k0?0MZIzyCydSf-X%a6d=?812?<_M6CcmZ%r5g)D8eAI0JzHJpeNzCjcETR~-NWA%oSp0<*XWRo1#9Q~u)Dxq{cZgsSABKgS~2zM}QWqS>mzBBshB+QFhQ0b<*#!y-ch;@rfd(*$DO>Q+bIRzWzOU>pE0FB>obo1S9c?}3ZMk>3vlN#O)RF$7PLBUSvLVNU=d0J#8D!ao2=697mOfq+tB{luEUA00OU2mt@W03J#LB0T`BD;KQc;Co><tmNR<-=s<cutDK|!8ib`3;?VJC$WOz1d8IS1e4+kD&qu`;|<E>`UxREqkv=pLL*kHPeLB0L05s|Sbd}dTL2@%LgWJ_gGz~jcTW}NcwkQz=76AoEy4f`05v%lsJ$h<LNUSsA*$iV`2xD2yomw;ApjWm%fT_Z1T+c&AOLk3Uts6j;2%fmsNs7eHw>UUssMo%!1XNx?yFy*WB@@T{h_7+Js-vZlK}rAIXnRA162UuHzp|n>S4kb0RI6!04^OD08`%?>jSR<X@L*`|18M^lK>(*Jw63uI43Fq>|_E3Vm~h)7XVZm1z~H!x^Y0r3g9C<J__PF&nPPZ?Pfv>;xHeN7XVco3gK=6bAayd3g9F>KM-Jo08jrs8vyA65CAg290Df*B{q3rJ%0c(AQu2u91#KDaN!UDFVhhKB|ZH>5db{^G$1Dc_a-+L76CFL7Xb5D9R%TWp%4Ht%I+J0CO$zH0z4}&^8oK`0vm!eA{PMHSRU*8ATbC49xtsL2mvY?#NqH};*qMIC-DLTb!UR|1A@e=0b=t70xJUI^ag@8s&WGL2m*lx;`RYzkE#b^_X6Tv1Y-CEV!NseV)+H)Rs!Ps2V!_y4PyJ;;!^-#1Num!UHpB3B}4m4BK_C#mHzeu+f!lx_hj}V6TZ>t00cb%D%oHa|5G9W00a;KDZc>(7XVQg24N|60s%rC{Gb~`9a^FM#UNflA~FJ`06za9#sED4FdZki03k9&Ag=(aN64Q5CjcTd0)nWg)7C@fuK+gzLOTF7?mq)TCjcZh1tO<oKkoxI$^b$=fd|5Vreo{_Hpv4+J0a##LNXz~K{Q|}05ktRGYvEV8UP0W5dbCt7z+S8d2sxIzhDCd9ROeFcLD$?U}0<kFJNK*18?{MMM*LO0e1j4q1NCmN${tD_Z=fS3c)7;J^;NQ;^4smO8_JW1neXP;6OWRK;Tgq1o|W*AtWRj030w<eE<eQ7E~hu0)qjq1t|bh7%<`n0Yc#a00RIaEEfP$yBHS-U>rjjGAIT41PCJ$p(R5H1PgZnHbxPE0RS^UVfQIV;69)yNGbvU2LLBYM*&;_msKAh44^?&Km-~*?i+wDP3Z@LP6!0ASO8gBli(sIU{I?77?k1%4(bUG;Zpu8z@z{>9SQ_O{{RaFFAM}cLjM2_1ThW-J}1ur9xoYW!<^wR0KX}C|62b{0N{l0|6Tt~h5#V~0CgS`U^G?%DoEs2K-VZq>7KwgBOx7I*(yz-7$8j#O~6?n_EbSJE^2^TAF=`eFaR_|-vBlMzX2E*09hX^fg}4$w5ow6Hvn7!_f{Yv9l$LBD*&%T0suM}A_*oc5bh=+KmZh)Ksy}~-WMPe1TPa8Aru7vF%<+pLI4&7Z!;GJK!QLR1Q@~f92mtRM}R2`0Ob4sQW(JG|GfW9>VP2-G0GV+!6yOxUjSwRN<=b1IdDMtDM#r3z#0TG8~X%4m>?Vk1^^%IuE3@N5d;Kk9RxAe9t2_^1ZWZjYaj%xF(CwEA_Qm?2<szP1TiEC;w1>^6b);yCIm4j2;wLa=oVfG>nQ{=Dh*;Q1ZehIzyLEE<*)!JJ^$eU|1MGh697+5cLxCTVH;!^hamqf8<PMZH#z{l3JU8i1TifbVlG}GcP|7nFdX7BA$PAb1TixR;xr+5HP-|&HVtAoA$K?gt1&qd;yNm56(MUo*90*<7Ggam_dWz`F+UpOKqdH!-zDI!G$r9n3nldn4{Jf!1TjJ-;zK3(L<H+GMJi%OCHF@JG4)73Vo4?UN(3=WdP3q%M|VvGF-}Kfy-y|gPy{hiOX5;qOZQU*F;q}uRZHsYJpe}K3|i|}1TpnjR$^F2_gMrnT6$XITWEJ&1TkG-V!d8Q_g@4tU}NH8ULf~k1TkZ1Vq_rquVn-=W^CeTZ1-r_1TkrGVrp#oP~O%?<s%42^$jKKYXs{tY<yyECHHOwG4*eN;&6_4aRf1PdMaXbCHHg$F?BBDy>=z{cLXtbGh%sOM)!IIF?%=Sd?oj<eFQOnJYs((_<i;z=7|by?-u}37yS;DASxLG0672Zxd9pK>VWFuivVBW0IL8WMYy3SMc%lffdnst#bJX4dohH?VTA-UhQ(t4hXfM<P!0e9{=FcG1UHEUM1sEnQ$QL3iaG!&yC65{08tl<S%5L#2}g_sFOAN@js$x#kIuo61T&G&!o89SN0S6MlnF(ZcnL_x;R#5V1TU8fLGPFZF`3vQnglcTo7f_p2}hj-H=g1WrJo5%%fSgqpad_yp%S5@1TmxGfuz?2Go=!urU^%<1dBJQ90jQosL-JaNUHY)FRL5@tOPNwUh3hl1T(K30<Z~3FR=tSvK$4o90=8c-V&&^1TVEEVYUQ&F}L(VxCAq~C1Sn05~sTaH@qcfy?7;PxZxZKz63A7F2V1>1Tn$=p~3_+^}{a0#0f{m1UJUwF2%<#$m78!X0QMyZDHR)EH1e~OA)z4s68a#K}!MDO9FsP3dsIT0ipnQ0A>J6|3nY~E6D^G0H;$K%AE=7fGkNME_E8jfq+V21^^%Gg#XI~uK*}VAOLR=04&T008|<W0sS;n;VMYz0I&etD8=w#FBHq5PCT_3%c3Jsfm9j?0V&%^AqN00iw+=F8(Iz_H3tDJNe2NbieR?@Fd5RoPki{pBz6Y@RT~EZDoG*^AX_fY6+l)T6+t!*A^R*!Vj<21G|vS8K|%n~1UAtG|3g9m(gZlu1YboE05#MzKviNR|J4LM)&xm{0AE-|9{|@W;Ux=UyH*?$fh$TQ8K5t%*b87+9U#Fs8KEt$OBtan`4XTq5`j@`JOt%pCK;hu9U#HCEK4K@05I7SfLOI22LU)B!7fZ7!7Sgp<^TUP2LVzB*ZcqfC*UUs0azYxC*dtjB@Q4l+8Lm0SsxA|IVa&SO()_1EhZ8G05tIfUlRaR-tY$kC=MaJSsyO}E=?vCKr*e{Ai!E66+t=`K`?DjF99xOjleY{C*apqqv;MJDHTClAZ`Z%FHR>MU^CnY0Bc(z4k0@nVKGlOA=@ukl;AcPF920twFx#NDjZ>3Ar2uh+fOJXfHd6>AY3Ba6+t{Bfih5$LEZ%aI^P6G5CAve+Qxw^BLQ3@6u~i2Z7C`sHQ^M%T_YRe?L8_XGf|h};siT?;{-?$0665$A>Aw~p<N@(px`zo|0e(*FCPE_JyigrLA|0v$X6=mS0UF{04Y}`=2tSI5pMthE{RtmiQO+E`d2UKS2F4Y001veC;?6<<2FK9FX&e?zw!A0|1c(3Ax?ScJz`fTJpe8p8o_lJ8pR5+08bU=ZGitTp#TQ}B}3)!1U~>hOF#fF7XJWP08TOh7y$nlaR5jtQ2+w}044wp05SqI|DgaO2LL8Rfd2D99UVCU8UP0W0stQX7#RQ@S1?il2&3tGVL)eK`vCw2zy|;+N9BIYKr$T%04z!jA^SuH!vHlM08{|?HY_;~;3rAS1YcYLRUaP=pfnOfb?FjE=@Lsb02vZV|1JP2Bme{eO!^Z^$P-B>02nX;|1&t40096lrrrx+P8R9}0s%|`Ul#yQ7V80GG6LfD?2_aqAtIIl3jm8YKNxB07-kYd7<o0K7-E(cAR=K2<Ch8HJL>=s5a2K^VJ1We{RA!{?F0e<B>=t{z#ISr08H-zm%0Y(m<HiG01gJ{2~q~)?grxZ0hkQxnGERNraE9IMC`U893NFTJL2yRpd>6JnG>p2nhc@c45{S|qVNo+{hBBN!2nAD6;uBr00jgP04ecqe&A6T+m)axF8Tuh9045w8$ulcp9TOP9X20?1|b&PR3io=D)Ox$QW$mHAV4xr!6-%t0s`N90RaFqB%vrq{gyN!QW!@80|0*^D;EG#7<)9JZ&Db10XRTBcLQQw1Pp*2LwyW^9-o2tPZje^U@I3(0CEh*^bE%!At*-cAR(<Gr9n~{4TzTwhb*WKgAT<G1FH@c^;v)_WDWo!CiWpD6relUAwrH6p&LRWAw*9=Co1<ACqGgECo1?FO*(=aPgR&2T=*z-`5I078b~cNFo01P8e988pBhY6{6UT7L5-OioJ>L#)%`Q={xj$S8J{WtOj|!0i~t2yp<5{FTP-!3Gd#juv;hUsAWeyp0u4ZJ!A*gBO^}_TSgdLwoumT=PoSH-fFyrH1O*EKH9LHX{ppE91qA{Cg8$S6$aujkY#<$Yzybj2EvG>UBL)Z|HvkI!0x1QJ4FH<}Gak0Yf<yw!g7gAo0WH4(9RM6dEq4e6rV~Ig9+YAQ1NH?1IQ)Df1qG1+P$Uol?*;`40L_5C0#*M200s;K;|l`+Ap)5T0yP4g{|W--1Ons+0{^%J0;UB5rUbtN#R~!%78au&?E%_=6EP5>5-<bSsQ@EB7hny=;2{Nn01pQM6fy<`0{I8uU;$wS00;m={{;XI2LKf`3BLda03ZuCA7C8a3gbW$Fbnu#G!CxU00saZ0^kA}zyZ4e91I~6Faoz=3|^K1Jp&8?6#@Vh;Qs>z0<H`Koel01fs73b1&9j(Bl$BZfEqy@02~Q1zAOM206hZ&4S@r;4T1y!iC`xp>i|E0I~xQc0003W0RIUc0>%jfl?wj??E?bL3j(bF0|NL50)qqs`=A012gM5nnwkHZnVFfXKLYLl2?Dtb1T!-;{s2J3KLVfw0;vB30>}aa=?Mb=ybS`>2Lg`<{{p!T0)PhsFaH9o0s^EA0*NC6Up?a*<`qCSJ>mi+RRi=uEh!;70;2>YV*LdrfE)`q02Tn(Eiob|00>Rs3<&E05F`KwDBv9nIbQ%800s#ezy=-x=`bXK9svp^f&l;`{xsnjHUa<=01)3M3jioL(E=O`YA)goBB2N1pd>lxpiTpzIRFJxAO>Uu24c4Y04UJF6%7-FBzHFe4F_NqH4ZuezYhQr4*(Sg;tr}2Vm1Vz1_i+o0RSm>TYw=C4FDH45eK5J2oQh~5(WY`T>v5e5@1FX06QH34!boJ2f!W>Hw45LRR9Fd76ii=1j-l>#f>y(!XOnCWE_BK!6Mxi9Do=$8B2gV4L(bNA^;5v7z9NIM05e>ZzCZtVHY(T7bBoipb|tU0&_tG1RDevBJMV!7&aUz!4Ci>KL9fXK0_}O=~$ra3^6aD4R&B84*<0kci=5L;T{ktfi3?4E&wU;|H=RDI#R*|2~x^00=MrA0{RL{A-M}7<X)>uQ#eUWMuG<b5<@WuHNq|9P~Zg02tuKVccBE%lfxWS1yDeFK^=fopqW8g-~<W?;sgnDfI9sEcfkb+0*49$^TY~_fOx=x0s<!g0{aF6&kGnBj{pQQ7NTHyqzWPo)c^vc0z-f*rQjO_Ab1QAz!D{DMg)W-e5Qee%>?*hJp+)yuHYXAdjJm^AwdEF45)xxDkNAT4mDWd8*RY72wT7m0{{?(VI}H?X9T2y2{6Hz0s{Z00|M#`0(b)d$_oOJ1p>kY_W~6QGH5dZE;4oq000;cfj|ZYV!*o?1`pss1_zzMH+>LNAQu2Y1_-xcn+Y&?;Xgf*!kgg+rVLG*2Mk{fUjPh70sjC63<B~60=K>}VXX`TqXWGGF8>1h1Ona+0{xE&0-Xpk;D>;dU<U6191J&opaK95{{sLKFaR_tB6$F}fY^ZyH~=HQK<_9805&k93jidhYXckwh2@+<A$s6K{{{d!H~=y?H%N`av_S=6K8auhVh00d>jD6Vp&guo6EO*&06hR22gzY?K^|_QAsr1jDBu?hg~7NIfKI~>VkQ6_%K#q#IvD^99zXyL{{Te*0xdo<EAEWoH6skXf&l{o{{qSZ0~G)hI!0hXFagQIQR6Mntu5dBIzJyR$p;bw{0R8OfyF?>!+{3^;0fOXfdvAX*?<WG|55_o1OnX!0{_MW0@4Bkmj!<UuLA<O2|j#+J}@H>030_Xq#!JW4+j7dF~&u*py?q30dEih7X(T`3Na<YwH_p72(zFL0;-`5=^`{>FT^z@z!(4p{W7Yd0stxiP5}QsKt2E_0RSKV_MsIs2mmzzDX%>vHy_1-7WSYyZvZe26ZJqg4_9FSIRGyV5&%X3lM)K|fV=<z1cD6#9P1A^`QSKQ0XYCM{|*!YQ~)0pB7Vid3jhub01;oHQ!x#1;S7Tg0YM6HV$C-Kp$h;E#<qb009_yvffh6m)nFh5;#dp70-yxpF%QP!A5)^!5C9wj3xNdMpdJy{+yE3Z4B;S|K^8Q15(nWB5nv$~B!8oK2LKfUpauXQN?>0X06qi}AOJof0r-?)W8g7B2?C4-0{^%T0;UWC#sk$2OCtg0z$Mqg5CG#C0(W72fCys?03|e9;{(79RG=0FmLdy5tp)L-5C8%~DSseU?*RY^1#O|84Fdb93_$_h0TBTJ-5vFz6EOm6U;_YeLIeN|6ksz2g~9(F4gdgB01PK;V1f=MAt1297BmB)eK`Z66aWtxFfm|zIZ2BkQUDPsykh7vV*)_~;V+@!K0X}#1t1Va69SwE0{8s{0#YN$0s`s(2?FW_0`&p{dw>VCfb|IiJkCV_lm`Ng3IbUI|Aq|$<p)(A0M`jI0sbKjfdBv;eF8-QCOsiEA0ucD15kl71p482V8h{gfNus10467683j~<qcaBn;TgaK;~N9uC-jB^TVOSUU;r^XIePX4C-wn702>F*BP;>J1fVns1MCO`<P4$ahafcxA|d~y3<($7357Z0!XFCBAT}$dBblKBnjrvS1O9*y1o0ya!3&k34@C=K1%VF%T4*2)VZaeJl;Ir-#A;Sx4P;^tm>?PtAHcT_Gz2FBKO}4*3tIpvN`o5^BLOuh0{sy513ds83JU<ODIg;q3GHJk_G2Md7-2OnvLXf--~|`peGwPqTL41|8*-pl0OJS%0pkk*<PiYm{SpD>697p73q9QQKrSFv00O08od*2_4nQab023Dg>pcUd!a4WB0|W^6L?NpUmLX9B(FQvLh(jT%2@wUsRiOIY;4)cY00}Sx0DnLL2RkW0FK>Vw9Rq|Q6EW~bbt4NQ`vw5AKszh|B?Y}Oh+ruIC_aT?7FRR?49dV0g`o%bqWC={6awTy1P}u43Ecvzpr``^Q-GBN{{n;z0>KLckN*Y&xdQ_60s{a23Id%50-Fl|0`3X|p#lOfy(RN#3jiZK!ypKM00RIF0RRwl0`gj5Fs5Svq6PpA29g5;2lL{n0UiSY2LL(&0FgoB;K+d`;2gl0!ULf70&BnsK!6Pk01)pI01F`uz&8L6djKH}z(EH9HVh$72?YWGCW2z-zzZIrw-PW6li(Z!-@qvKJs-ghNnjrX01x6XK@3*H1t3S^5-<*a?jR2UK??v37D4$CdO-Td000C80{^oD0wx0O4FY$%1O}|)0ss%ffLL+jFQA>^3^jK^8yTS9)F3(=1R;Te0|5UB2LiAN0^J7x0^<t;q74F&{{;f60s^uD8&47d4j^{G_CqEa;r9>#8au)?0stky05JtTK`;B@D7c(L_5plk0RSOBAs7BxKn?&bBPa_P_HU#nJa3}|080R821FAXpm_i`1w4Q^LI?$B!8Qf~Vz%MC5jH=8LI?-bz&H;fG$|D!LQ&zWLs8*(00aY+grEZisA&59fdl-90|Wx51pfkz4Fb#y0?;D@1wp6*KvQ87BcLK6{W~Hg000II0*mhj0`CPPA+QDl-|z+klne-A#S8vQ!Pf=?-3<aRlAnMrH$kDn9PPkDp#p}103$byVqT^K;kh9+|HTUc06qX7K<@xC02OV)696;VyI|5m5P=mly1^7N{{{d(02u`l0M8=}02~X!;DHh_s_ViFd%+plVF_j6727ikiQpLvslW^~`3$MTf5Tn?K>Yvu^&wS4pbP@y0|M`o1Om9)qRRyW|Jw!v#0&z@4fg`O1sX#HnwgnDnVFfnKN7WJ=K}mk0QG?b09XJ#FDC#N048D1ff8ikXdp>Aoxp|R4Z#5PfDZ*>jR;v`F$u##6v87y3anfLVqgFj6agI=0vzVhLj?qQVb3Gz0TO>b02l=e03@A3NV}lSV8;U)!vOAy3hsuI%LE6@00x5-C;+4*CjRlE2>>8E696{yz##%iVEaM@2LkB-0s`>|0<-}F<LU?>%<!OlU>5*9O9TQiK?Wcr5@0<!;NKho9Sbm-VE_sgX++=Q9af<eHbDFU?t;YPpamf@1uWo!m*xrt-vWFB&<il3l?C4oaR4<Hp1}bCe+&Wu5CH%lQUU!G3}PJ%IRF{}`vnI;;07504<tQBLBKx%G6npgLxBHO03;eG09*j~Lk$UVfGz+p0M{x3EJgq>$>9zF{W@d<0s#V_0s_w*02~Pyfm~<-0RIOO0*?p+9RmO02?D|k1ONd4G$!?H3_}8@{|o~91OlE70`v9)0)_zq0HTx{-)%wyjtl{3qy_&1g9`$V0|NY?0zer63tHe|Asu*OASPh>VRHZ#13h4`G8_PRS|B>)U?f*I01WcLG%|xI;lRrk0`nv!W}_d&G6eqsC;%}iBMl^ez5pH(5dZ}MwxE4K#DFjm02Ky~fcYk7!DB%cGY9}eUVUK-04h?)AO>Lq|2F_`03ReH5?1aZ77GV~JqTbh^T6H)XAA%x4F+=)0ADo?%9=aH06qq+FAxA24j2G91HlckP6r@OLJt*z2QUu@AtVFA2Q>91pbm2o4q*eq{0?y%h=Kq&Bmn^V5g<%oLIVQ=#tA<Hyb1y}2%rL7<JS@Z47@-jW#b(=zM<kU05d2e%V9h99K<03h@cG;0-(JDtwFQ{0^39Y3jV1<o&^H`2?BQi0?Gjbiv|MM{{#Z-0Rq_q0^jun0^ST;fzu0>EQyO9XJj4F#9N^Ty#`yM0RSQbnjjdy!C;O62_p|hKq%`w0Fgl)!C?|G2iy_i)*=A_BLzVjH*Rl17&i!?pba&S!M7d|H%UY&Nw5G1*8mkZqv0IvffYLa45dIH4FF#NF}~JdUjQ#ZEdgLH^F1r>AUXgK02K#s02nq9t>7aOt3cNoHxdCs4&0zK1y?>pFA?Jk1Hd5z!S@$6610FI3kLvC8aNUFa!nb44szoC4O>Dk04Wv#@4f$V;Q;^z5ip^Z{|W-G3<9(T0{`s;0;U22!VUidsRaVm2?CJs2Li?f)S==H0^Kj$B+UXNiX}JzS1>p?<N!XD0veP6uM{!@060J*lz>CR&Vn4-!e_vrAj@G?0M{QDA_hVP$)Fty-k3ob06qlnVLk-@?V&yd2LLSq64L`WAs_=G2_*m)3hD+z3z(q{%^(vo4gUaL04x_h3m2y9pdLEyKmx-KoZ$~91R*jIzaf8PHs9k1Bl1y!9HPL>VNL)(K<7RHCig?p;?V>G`@jbtA(;pW835@Dh+@wn0v2FB0|RK^;m+m600-<qF#}UV`1M38Ajra~0|NRDuL9`}4am|6j9?D`0ss+502MkV(*Pg3K#hSRk03(>-vBrr01J)a8vy?}2NnP^jsOR{9}JR02>>3bVFR-O2o)kW0G<NIA&mPC6SSZK0H6R1k2NPh5SpOP!qC7s_W%w63V}rf06PC)04Y5x0CfP@H4s6Z04P!bG$j2E1ENF&06A*_-y;SiLqWHoK@0jUp&uN96*C0@Fkb*QDk1>OKm!0^{{oc&8$3J!1>DCXaKHiz5O`s?3&#Tb3g=-SfD)tB2fqT31_HSZbb+S-1Omki1pKM-|I$rjP(K2%19|~wCi}sf03R5qVPACsG7UbmAS15BWgTz96DwdWATR`CfWHL*3<UrX{a`w-8i1Mr9tMC0Lm(Ib2LNjTA_gEp|33hs03<gfDg8JeAO!$H2mm&(9RLY1aN-Ma;|RiVfDCXT2w=g12w)c{Qouk4=>UHM0wrJukwC6Y0TM6`!C?+aVGI2>!XOg>ngAsp{=9(>04^me4IsL3Au`240RSLVfk3ke4{?D9VHY(AVHz4w;t&U6EdXvnE+ODU>j)Vpft>B&2LhSz0RoH%nMB+I0{`6$0@Vlt-3I>xumJ*(2LinR3j(tZ0_6(=|Lz3>qX`0w3I7721p>DQ0`LC_0-Xs0;sFBZqzFW(VkChA01saP8#p8Y^}!SMzz-4t3n3-IsUZNsK|yq6paX*ibYKf10@^@&IUx;Y03Zhd4_v|Km!S$Vm!YC>5C9wH3Y&rp+98{O3jio_JkMYdAl~5;FbI{P`sKt7fT9-wJp&C^lK>b96afx9p*$3zZU*2)02_M18xINU{1O2Ph!X%b0RjM`ZsHK~VjVztgExRc674XeAs!QfpcFC`DuQAabYc|mVL20EU!hVKU=|E+17{ZlaXDt7`Uc<_6K(?l5Gxn&06_;CsKp8Z<Nm0`5e5Q}2m*os2?E6e0>K9Y|DOf|r3oDw0MQGF;!Gfr<4VB5VF0%Z2PsMdHXWh>Iqv{14ic3i4L1P&1UFzr0ssyZ0N*-|Q2_u0KoS<Zn1K-kK?DFut3VUq06vX62?IeE8v2{z6$YUN089b^e-;w}LJf^413}vw9s@xcH>Ut22JXxtHAOSb;4?!p{>`vo04qBw0B+v^A0;9Y&fowv=M4Y=6QcBC0R#lv^kG=*f!_>cU>yPeuYv*qeE>W_4)Y8<vEfbS9{@i(+VkQ7^WXyl@&U;SNd!~KIp7ZqfCS(>rH0lF1Ca%o;|W=U7XS%7$>7MKAjqIs!HvOJW*r2QKr<*Ju3`<skl<qg1d!qgz>!Ie3Xp;Szz71A2Lhc2-lZYM3j&*HU;_e&-~}(g!Dnb>Lh0chbQ$GpVFix>1^^6=0BQr`3rj*FF91OYi{nuUVL^-FZ2&a<U<d>NISkeSZs0ut5hJN|A=dw)76(ee31vVA0F@q+;v~vJ30eZ%!5sev04V?{K>!T902Yx*1^^t8q7Qoj4G=&d1^^FhLA49Q!XXlXK@Jhi2qwP(3=XBj-(wp)W^!SL4{5|3xd5bq<su8>8NM^%RRI7CD_NoX{{#Y_4FdcE0{@B!0?r5mzy#j{$_N6gDF6%v|D4H2BIBmWM)v}P1_5RS>WrZOIaxj_MgqqN{{prI0@Vfrv;7DHh6DnH{^W7L*@;C0f(QX-1pl<1*?B{F>O}VffeHa;1W@nd|JLLhOGE<V2mS$O1OUiRXKlgXt3v|L2LWaT0RI3qCiQC!Ljv>m0s&?L005$t8sBX~0*(v;XQT!H0)q<zjspUt{{{l!2?E>!dGd3PLUV}zAp-z{0LL{V0dk-<KzHCB0H+Eu1#V$^U_x(T9H$2WDFR_YK_3I|3HJaT3IpXE067N#7633102d1YFFODWKWJbuVSsHT^&6&uAKif!GXntqLO$Rf4FD=q0RIdq1^_hxC_h&tG#|`>FWn&y2Z8NF&fqXYy+9uj0N*MQ038u~;3+^|EdZb{J}d!XDExrld7vjG6A%jv5&)|m6AKR^=s^?`p*`&Y{eS@g5l9sP9hDXaFBt|Q7X~w?KpE-`ZxIF|8U`~P03Ep;1}|tJ02dt$a~@X!9UlfS0TQ7g60>h1039L>Z~6Z*;JqUl^CSQrB@(ak|Nj#JHVw*}J9;=^J|(OW02n6WK<PLG!8eWQ2H{OY4@4j#2Jj~a;RC@2?cWCB7xe=G2J|Qf;RC@9?f2II4TxYPDgYAS2LKi{EBv4@DAy$oCP~3ONyE|q-n*ax00a!Xp{4@=0>%UakOu;;{|o}O1p<Zw0{^@P0__6=)CuykgB-6wzQqy%3nBQWCjz75pa2#G0632TF*Y`e;-O%+ryE@b#vl<f1{{Dj-N3&9Q~(|oA@t$~UjRJ-7zLu?2CSg>2LKE>U=RQm2>SSf1K~gnD=h#KV*)mtz@34!VH^vj;>8TWK_|dN$s)i(1|R<dk_Q6V2m<fT3)W$k3K=09L(B{J0xtr?Bby2W+kXlIlnMgr4Z;Kbg~8H*&_4p_4Fdn<4FdfM0wV(T;sbyJAYsA{0;xF#At58c#so?sD6$})eqa*-H5}SN8h{kPApk}I5d*6P990Ar0tIz|Bd`Gt^<e)Y2LKQU02DHX2qjB6#=zu&z#|-oF$oO&!Nejh2%!YS@8%D~KH`FR02%~3F9ivtxeX-ZzyJUi56$8b{{US8EEzlt80yQRJ=&la5<wsb0F@7&K?nk&K+9mxVG)`vViJ776%!C*I-v>V-y#&|6rbVVzz6^p{Q#_>5JUhG3>CisjsOQA3?4uv{?20_1OO}mCkKZz02Tuz?m_xMA_Eow03rkc5eEPj|1%Z<A^-^n6x7mUJs}t3Cm0OkHUOU-02~Q0u^>SK8CpaF8brby07OF^MuJrx7GWL&L?1}v7WN|gU84wHp@;_p;tBr(v;hLL1_GS_2Lhl60+t03Y74^wPa*=b;2Q%_f}%Kq5x!tNpjS%;Dq;p!BcuTU1>ha%;0Gnd<`tj{FjxQrVF&;p_W(aURH6V?008>~3sD5F1p<!-zXF8>0<H+{VWBSr0{sosBN;)UYazE1FaoVW76Uip1bWW^9xeg}01O5D28|(*z(EH8V+2Jkp$OQMzy!!a!5;-ZVG=Pa)xjM~<OpkE46T5AMzq#oasdl4BL)Bk1qt^69Xf_U0RRjM{Q?&w#sLDM0|ft?nVFfHnYlmx0&GCP3IdY>0*AH=9D2b##NI%Mpa91SF#;Fi<bXgyJpdmW1`7ZsV&SI18{yjuG6UibH;3X90N)NG3jijFVW<GxJtT9WGX{u&6E*z=&p;Xl0673M>kk#CfH^XO0RSZK1A!Vi2P?oQ4;kKDKo9^Q3H0C}6YV#vAUqHU;8Fk-`zi{LKqDC@0B64dA`mPYGYX(p{`+780_Xw)>Igpr82}3(K=B~_f!zW&LL3Ak1YrOG{RKwi!2<%m0s{ZD1_Ip#0^J3E9|Xxi0{#UPHRw{KU^RK-bp!)pp*?`0>L>s?g@6wkfH?pzI|~tTAOrvn)}Wu^%1%KYq~Q~!;D;eW1b+YE05K~h4<n(X)d;HKBE-Nn5<vn0{u2ZQ0|J>10@1$*0>lLb4HsY_{6*k-pfUph8vr-|1{MG?djK{N_ZB`C7{dbx0`2b!0*C}o!Qu-7---kR%?UU_5+N2Ipg{siLjz2v5CAQpG`&DHp&@S|K?MX$OruW*01O6Ef*zwBF+ukdFbBZQIuighT@4=~0sty5!v<br`{4$10pJM&;|y#oVYHym1vmf;9x(xUPhhLy9{~*l01<|ul{}>24Z@%yK%l6>1^zXl9s&Tc023?bDu5cEJ|Rc|7XUuX1O_<)2S!0%q8tqP(&I2;Sb+fr1Oht$0^J4zB?6=f@e%hRR6<ZdB>*o4=Q=+xHeuKW6#x}|I<|oW0DJ%hOQ7EnSO7gSng9kBy8sje0246-+rcuw1OQwBJqa|yE%es{l;H%AMF9W?2EOZofDQtl0e{5EQwtU9$fAHZM#%zxU{MMSKp=tYW;!4O0j9y$$lw(->j4yJ05AZzGb$p4fD1B`0UkOaWCHO(FaSg|fSSR}J_G^bEfOQ;p#=v15dpme0`vp|`aK9*AOfce3t0%6!OlUU9Sb&rVUgtl0GPUfFQec94K<+ToIp9eoJ1Xf2Lj3gQo+-I1_GrD0;UXuf&Zrj4F>=bF#)zVfFA<*fE6<*0TkdT04fE9-~$0FArJr-T?M)TJ_H2m#2tU)>oEtZVLEdJ0RRKt0!QJA3<DP87XW!Y9DqDz000IfOM&C20+S*8Ao{?!3j+W83Id=50;mJF`#~=P`-ap9v0=IY3<7lm$N~cC{|N%T4Fbjl0{;X8uLA=74Fdmx2m<*B0(k=et^xw)1_G)D{{qJb0`vm{z~2J`q6<tos1g8c3n8f>J2d1V1M7o=vf&(AVAo+*ff<H>K?rj3Knbd#Xo5xn8r>o(F<U_0Ap%Ke3X?%iL6Z|Pvtc3QGR@)(Bn-4p;^CtW;i3)ztpEko`@!;JI;Vgkz2HF)(tTqPePnq95fEiL0QC*%p%QpRBs%~R9*y7$06`Of<NqPi0ni4+|Dc#)FW?cK0XYD@4(^B$02LQE;3=xAp%HO{82m;V44?s@03Q_q4_`ng0jtjd4Ko!&;`;$V1-TmmV*0^91swrm9?twgKLsBFWW(S$0JRMMq98<o`2Pu_2d@AXGa-+JCb0n*?*KmqA|T)x2Le+7Bu`-sV<Sr7C%_~B1snpL2Lk;B?*h&P0zl^K1Ongn0s^ZIy@62z|Ir2lhzbH(0{`_10;vfCJOcZe4S0l<2Lgl){{oB(0>B6Yo&N>`h7AI<1Of-;2T5muT_AUZBVgNMnm_>vm!J&;nS!dL1783_1OPYAK?UQ;@bm!$$migUVlxK-I41xyH{?Tx05paIt{@;d0RiM}L6Cz406hc)2ZN~yiX!5{9-*KO4ZtD03IK?}6fz5KA`JX3-~nX~04x9|1YI#XfGGeej-eNKLB$U|Av!!DJ)m*H5i*WFfj$HfDPllEd>}F<4;dgGt^^?A5&`67;58GnA{6+57Znl09;N9BssJMm7b6iE01e3)!Ga%z7F4C~feiq^7yuv^01&_-89s*sTL3-@78?Kn<Esb&0pkw<<PHGj8cG4=8vx`Sw&lA(5w*ndhM+^>JYdv-oeKip?t|b30@~Q11_B)a0_zF_lLrEj{|f@q0s^uPGPeN$Af>?;G@RuK{^!6D1OO8f01lBPR^ZD)SHceVVg11tcQge61AzhnD8^#MSzw+46+S@Iph4js4*fQ8qC^S+IUNAE3^NNw;SM*4fC?V~4+;PiVZikPYQW<mK|a6)NqgfA01uuJAP@i<4YoiB=?-TA4-5z5N#h<4XT_fX0}KE}4-QLB!zPtEOQIhX;}97kNI@3=G!Fn701qNUj)5Qs03Q~hi@_P@5xyJ%FeoGqCF4c`?*<V96Y*iW1p@!y1p<o+0^kk*0*?&>$OQtW-wgsF0>8(g0|Niw0|MR#0{0B}0>=aPKuiz-7s~cRF>4_npa6)3h5+9sI|~3Q1Hc0Se_a4889fUZp(1AVVlf1N;pTxAGcJKi6y?BM;7f?13IGS$K?Vv75&#MZxPfOO-~jI9PB!5aF$S$7)WI@i!6!Wc4_l#afe8s_I;A`bhj7Ic05lGepu+)`36dZt2Vn{j?M1^R2{)@?9^eZD%0>Z!Km%l<3<G#R!4gXb=MDz=4@wGg4H07y4elIA5ikn<5v}0={{R400RI341Ol@H0w(_g_6GvG1O^R`vS9)M4>m%f0W9M+?xDaN3pf438w4T#wIKok2rdH23hM%uKp+A7fiVK}zX1Z>1p<z>U<>~O)dd2|0Rouc1q3rQGXOyIKbHdj1-GCCE5Ixu4F5m^$_)aG2m<|XwBdpd0+I*<->e4$)CB|N;6MKYp8*211p=%83IeAC0<Z`I--H4Ji~&)>>J7gFh6w`c2L&gx{{aH73<B5%0{@-?0{;yH+y?&w$O{644FcHr1Bn53zySag0Mj@U4uBcJGE@N{4gPfD0{{;L01^_v01YDx040Dy3ReI$BOk#YQG*3zL02gw4b-6?tKk&;!1z7@f1(H?2>=cW02LBIU<%<P3nxKtVT8f&umBS<9N-!f0N;WDIVJ|{pauZ3AcNrF;f%o_59#6u_7h+?4I%)705~P71yw+FVK?gn5z~MUwJZhU5*PqB)l%X=TLlyMpdJJ7LKFc(@)IZ(y&)T7761+w>i`n)AQudz1^^tY4}=(D;TiWr8Ws#I{uTo|05>l#03%Kn=@S4p6oD6k8xP^V2@m`n01g}v=pFq4A;2jC000_9zN!E*EhY~o2m%<S5FZT!4j=&#3KkF&9)2JO9{>&?01_6!hIzw31s#7bqcdVArDL}M9yV2gI5-xeEb11eAgf^^^S~A~BC0roBO#(9G@&0fq$K2yp&WxIHUSmo82}8gAVL5q2Er)!;3mm8wxBA(C^2CI<#hnJG!H!cpd~t?U~!KCI2b{Zg0`RpD;=)@3o<D_f;Pm0F#iBFC?Wth00I922mmSo4<`V>5(fYjGAQl<5vwyR!XYZnVl35UT<-uq3JC*&GA#h+2S6$#2SN&gE&w(E04hHsG#&tz{{R|0JOBg<0RJ6100LD20SNsNb^(9~0-OQ@z2L)O0|Mv)bb**2dw>N3;|zSEbwKi<@0kPwrtp9TBo+Sv6FLU~5-<UVvH&Ae)Sv<dh#*{G4fg~95Cg#l02Kha6a@gdVG{r~u;B*#03MED2ml2D4A%z$5X>M5E#MO|=?P###v=-A00RIcKLr32QUDNaz;3|hDsI6OVL*JrumBQv0pS@FPT?yh5H&&fJp&7IzzhH(4dVb0BjNs`Y9Iyx9qMOb1jYbFslW#S7v2y+0RSNdYJm_pzW`qVD?2Fwpec(vC(J?+^1>qGsGtG+1Okv_2>}2c0ge=)5-<WC!8^eMC`11MCnqETTmU}%2nYws0RROB0$<kz0-6P=;o9whBMS=ZPTc_J!4&0Svf<Pc;osvO>7f(ppdSF&KRO(<g8&L4qXz#1w+jOL3Ic*}3j*c{yFwuXErF{PG6q62=wTi8pb-B676kxq03RglArO&aRT1C`0>=Ld0?P~n)B*zk?hFFz2m-(ce!O9<4FaeHEgB*(7XUm29AY(CKr>)29-$L41MZ<d<3RG@yaFK&K@tEABI1BZ{{R*M8~_~(Fus@|7XUs41DPNl>h_}ponb2)$pQc^jGX}pLk0i{MC#!UKnJWq!m$Ay3|}EL4uL=P{QwSz28Jbv06`X}H9;o;SV0fT0uRRmqz}j_fIKLH48{p#U^94Xz(e2-f*=3@0p`F<0|F!?13SoMpgQVe{{;;KrUU}T3;zO=1Om7P0^)rG1!4090__GVp?z;DA-@9x^#L)!TpYnhCKCWOUgI6@V6O`RBQ`5S96SLM`!EC|02~DXDF8nxI{*j(7IHyLK(5mv5-<l%fjEg^8BYKTA3(t1TLB1?AwCJ=Q~)0pB37bK!(37ze&G@@3I@R(41;t6B{u*IY`_#U49muKGu~r0hoA{C4GW<28w)PMMPmX50Rq4D4GI+i6?~u+|1tppd;kOw8NUD!SO7gSJ|G7EdZhsXvj8X#KbtlWU*J6nU+gKP&fx(mqf0|;WMhB^0?K^>EuriS0;UX5!T-Vv3I_lYF#%dcK>`(m0{{)+FAd>6A#(sh1OPWoLrCM}9R-I1>wsiQ1Ox)##0&z)2U`J{2=4}D056PSJpdRV2NwW614F?t25TYh8*3#532MaU1p@z%1_Fcw0*wOy0>}vhstW=>2^f8dYM=uqB5c8#2K<2fI|Lz`;6VleHXVZi2|Hk&V_w0X;sneG{shqo01XHL5JztS6gecN001L#105Wsff6tYljTw)9b;S53wVK^1s#7OsG#;-pad0Mp|uABsrr*bFNy@h4Fa1A{{q_z0+b2@>HiG^j|u{&0s{Z^2Lgi*0t5p8#smU20+k8^*RKseg2n=PAPXV-S|Bq`fKC8CKRuHGCZgtsVIu<zyP*;@Fa=&ATmmr%+`(dlzK!7=02~Q1h~ho}0|)@A03j+Rr2xzT99V^#APZHZ4F3RK04y0i3mE8T<`1U@hz$jdSO7d#EtS9p1%@4)!wwkb6mujL;}32C9AZLwq8Ec{5CVi1NduH%6%ohc^%8lZ6N_Xe04@Z_IX*AOB^#lnqdfzw0{~JW1?S-u$^#2e08RitC*&l<6%WYt8>Ey&1T>+<4FZLa1p+PwQ!|~xTO<Lu01OCX0o4I)q3Z7k0;>tWLCOOH|NRIbWB@P`0cH_E83=0OIl&Adx?tosp#Z=(>HuBBH~=uEH?koqt-{z~1cqTTe$|6H02%-V3BX|Q2LS*gmf;vS2j24GEGG>pi$D)H{|Epz04qKwHf<ldKpF#`AT2|-z;zm(BO=Mc7&ZbBfd3&32LKy60s!wn05b*spd<_c-&6o48z}1lL=OE5^5QN4C@ug5`v5z!q6Y^8paTAVLA?wD^#lT-{|Ew|1_GZA5{V7WAmRWIrC`?J|KJO@6d?u#)Sw1EOaKcX04O;C53Zq6$c@425(U8RfIEUg2LKi0H3kl11;A559RLmWHC3Vz(?Kl&E&!7$ERUeW0}T;E@}RVD0|MI&n!(8i{~*5-aR4<HJ}7_z-2n6_9RLgTBMmj`u0aeFf(s|XKL9dz9^o4c9^fPzC!1i~7C43g03N}C7CV0j0ABzxK`#KHcP~FJt)N2)4WeMhF5n?L5ujH=BLM*b>jnp@;r!HK4Fb{s2LjUu0;LK9hl~OoP9Zv=8KIbf0lxr_00kcl9AqS^ImN&`00KJ#1I<7l(+oHDL3TkD65u@mKN<!L046&pBKzdF6M+^1Uf@0iC1EnQ^*|X12mlH*2m%hxHz))qHQ3<W0T%#kKLskGD*AvI0lFalDUss_3<8h@0^gzp0?PuhftLdR0;U53^a}!b{{oE-0+0m)!rub|6%oeQ06zky0I^^ji$XG?4g5eKhXMc(JfSk<;DC&!Gj9McG6oW07zcAeyFdo2fB+Z?0YVBy=s?LJ00QEQB|ktt!KV8N6VoAu4g#(WzXHt*0-gcGgrI)|0;mH5$O6Pcz0FR50s_to*Fl8;3j&h~0>}#jLjo?Nv-;%zWyOFu^aH2@CB@-t0UeGe9X{a`+@xTH!3Y2dW`GO{djJs3<_Q2n3e4m23pL@Wz|7+e01XUJ01y%YvnK9A4S8Vy9}EBw9RLb3B@V8k3{S#iV+LbkRDj(N>EIVN5O<;`4ZSBepeQ^55rCir`v4#ZU<UvbF%dSKVJRX!p)nFf#Onb`1cO3kp%c1cWT!1jV7)q*009651uA6Bn+pOZ-~tRKD2<{Dx_2NQA>k7-1Q1~;ry>m_Q{`}D365eN!3;fP8sULL3m|WR=>@+6s0aey3o~E_$O}j(p|l|umV(cq9{?XdJR1Zc;X!49;3E5>3#37v1p>ndJ_ku*01O5zOhAF4+cN}7Aq4<Lp&SG}=;Fs<9Rl(LMFHsG|E2^2jRgYE3F!jppya^1t-t~Tb>`;5h6h9;=-|x)0{_|z0`>|5&j<ekvIqk60RpJrbHD)t-3CjfuMPhKs{#Vl31Seh02KiM)u1!gp&U;D9SSg?;Iu&lBtiOI0TUr0FaR?sB2+nIUturMp#}z_G+p5KvLGEf2P*>r4J@j>!3Vwp204KUa^NJpH~>YU02K)bAvSb>z{)@#p}`a~3gW=43?jh*KI7maupmLZ3jk)oJ_HQ0pd9Qqfu_L|F$lsQ02O)=0SyoVJpdyB(;yoi4wzsQG3eqpL>XZ<F&ShBh2Rzohr$X0fet^R1|#f(Jc2?&5u^yr5v9_^5dhM|6W~1n`4msWe}EDIrvN6ZGr=AsAsd*02z`JJ?*af34FrH9699P<g<z8)5C9kz2mtppI5?AFB{~2Ot|3AF{}K{m77HW-devYdg+N0W064b6wHTto4VtATIlCeq?jUIL{|{w=696Os82}Oo02VYFR;*wMAhf|P452&>pyXa)BBLAo!C3<2{{h<o9wk8(GAe-{8BV_-6f+uhfenW=g`!Ix6VhZQ0pa#x9peC>*#E)+5EX%JzyQ|(0|b{rwN8Tj3AqTO0PH~$FaofEBf!L=q(F{^e*lfdX=DKa`30JwoPviA0_hET4aS5I!3O{lF}8u-Es;P101hfZM*uGsIwb(efFzlLL?Qb_10_QQ09^nqZy7!f7%4z9H^BqP2>>4D!GQo~VxR@@0?!Hr^`RgF0RIpu05K>d4J5M3f&+<S{DK1ltD)Fa0RtGwwE#M`1_fte{|N%G0|MOz1pj7cW@ct{wZQ)bnwgoInIy8eKmr%!U;zLN;14{PVSuC)05(W}fIuJ;t>GWs;Nidqdm)0rdm`>AfCmDS=l}%*;@blPdmzON3S*hMFFyjf2bTaGDrG5x$aN*ph<G3dI3c;90RZzG2R(r;D*^!r0)GPJ0|GS`6)2$J2LKc@0dn9R2>wRl0RVLXH4r@d=Ab6Tp-ccAKL*<p3qrsZGXp_15C1#>d;kOy8UX(iSO7mX02lzj2yp;77(wa)Ci?ba0<>T?Dk1<jmjD3)0AK=MAzZ;G{W9?23IH@C4FKO<06q!|@Bk_R-bP^p1ONg|04W9k025gND+~t<eHQZL1Qi1P1l|GjK?2=?tU&q-0+js+-(iFd0*nd*|G)?WodyCm0{^TF0-y{6{|NsA@d5&y2?DvD2bw{l13e!gtRMiD9MeDu{h$o6z)m4Ie%W9I01X8I5ZfVk^g$K}j{pfU2-xHZ-9kcu-9`f4Mg&FOLFj<2V!@BW3=87~49H*`RS8`|E_1>g8$bYWp^GCsd|)ByVCIDhCnC(w;VZ!tF$ckVAdUbx1|AE~L?b-)0O!F6AOrwN!j%C7phh4&f>Rv@oTT)@5E$YSKP1%g;Xj}YZzUl*AVCt~_G1|dn?jF3`$iG~K|WNV9RLY16#Ga6#F|Oq5|W@a4cH*>K@~m~0xtk60W3x!;sXB&3Igs70=)|N0=)*?0o4Hl;Qt5$^#KC)1OmU33Ie_j6lur={@egW1ON;N02hBX1pq$)F9hQtJ0J*m05mx{P(hDDuMhwi1|j4o@j+j&04X{r9byM(1_2iU9|%-p2{2$KfS@5xJYWDB3Od2AU;@IxwiCh%4(-9y3lxFz?+pTr4HIFl1_J+}0s^`M0=Ny=0`CkJMkM)2KL9N&6M-BA+@Ue!VVP+1cz^{jqIpMg05ui;K23lJ01OBK5ZtVwcA*q80&@a60RF5%2>=`b1{nbN4<tpdfIk2-1^$BoBMSgj03;f9C)vOqqQC$RHy8q&5;t++Dm}sAs0al1bYMaZCxI0+4FG*1w;)6g06GS_;PW>CBxj3<TmVB2+QH#3ePA95%mFR{<tcE00HY(XfW`>|e~$|SKmzmw@c_Pzz!v~K1Of{n1OEU)1OPX402u8xmtZj-E}=af1b&sm0RRI50yPE0?=S!~D1RfB02}W*JOBi{0s&P3{Q;#R3j*l{0;vB80+#^-)C>Zb<OT;KWir^K!sW$Z02?JT04c~lt_1%B00sgAjsgPzH4zd34j>Bvb0#xmfB?WX01WfMUk)Jx04kQDHUYq&7yt(}8F8QjLAq}M8yPS3Kp;8}0Me7eHj~JdKm!$kJUez3fgm`N0RsdB457ZSA`hAX9v7P7oBIGX`vEsA06+kr2Rtc1FMOd<ft&jPGXnuQDgYt?;|K-hMcrld;Sw+d{{UzJ1Qk6PC4^;y3P>WsKng(0fE;BB{{S@;0=5GJ&i?`e=K}({1Oor60s`X!0^SJ!0{IF8w*&%+{{;g32m*l#0{@i(0^<t;4Fdmw1_IIw0<{VDSfDQ<kKjrI06(7@02eAiYap*+82>i_LI4B+Dh2ldHA0*KF9!fSeL|ohH3<MfLW@BEI|~3t82~Rr*+(W|1)wlD1z-&Tw`U9h?SMxPi(ozbTMvvNJX#O{m#+XEUQf!QGz5VW-vDb205#_TFi!goPX>Z+3;;Pje*j7`2LME324QzYVG;&l9c5P0A>BJtAy#HoQs7i%-BJLcQesd6U{GM)P68lKUQ7buOkCYc1E5M;NCaRlS=~kjAV*h40H7>Z-9rIjL{vfoAS+YdKmy=FQ9lEqDp1`$1YkZ+JOv;;Ol>+|Axk(0pgBojp?4@qH3%R!Ml=ZEcQiyY37|4VFr(nt5;+rwVkB3i001`x3<Aqzpaac;%K*cV2Fqd1K+C|&0HFg<0^kKFfe5WZ1IVK53<SRf3U8nU06~cbtE2B>9?rnTMu0#EPQ*ez01>^xfguxtAdI$wgJ1v_hh=wQ)xZMV03-yU90$8V5-_}(;f`P_04P4k;1)`1Aq~D@AHm?S;R&zeXn$eLMGvJ2JHQMI6b3@!zzVks%p>H0-=hr1ru`i6!2tjX9s<ID1_Idw0`Cg4VgI6(8f`)X$qoJiU^FK6YYamI{n-Iv$WCW%!K?p60_p(-Q19aZ*5n#XL;|M^{{*z1*?B{F>i<Lny9)#Yg#Q2JaoLGQ0-6N>1nP{SIaxj_|3(7e0R)`MM*kw?rpQJD><0e=qXq)O1p<}-4FaYN0?G&i`-BFt!H)<6;0fmf+yM`v5<uWTLH}g{?*jk;H#_GS06&w!)L>0Q5A^^6fdbMXHVw*}90MZ!-~bl{0^+~{$3R>JK`-C{7YG8P39Ddp7YYOd_W%GF3<Y8p4FaJK2Eq>n0nUI7!1WOUK@tgq698cV-wOyS02HU78U?bBz&|ViY#<Fc?!XJvG8OK@0boMIARQO~04f~-3o;l0e>DInKq4|93IOXE8S|kszQ6z;4gWX*82}C;LI8am1OO>MBs3qF;GYj73jimXLEXR?dg`DayPzjF01fS+eK_r*cK{m*J?)@5DFWf1L5=_i20)x4{;a_e02vnmjsWKfA`S!L=D~FUGRqM^=Hw>=0sMd@3wr=4rNI*bHx4}Dyue|!VF3Uk9DKkR|1})|IRGya6Luf~8y?XBBN`^XV4praAPFEsqr_u~{|5r%2?FW}59s+K#DiUcHclWM03P!UF^@nW!2|#$0QWBiI;CPHIRFms-M}3SFav@LF$C7~;S4qt;4lK=3NY?t02cs0&A<WxE%sd?9Xa)&0RROK{Q}Z}iUR`73j*&n0{02_p_m5(`^f_IVcrY^#0$3q$_GS5@IOcZEa(zw_n^vw6AgkK3^)GqpalR91^^KUdjJ!Z;0pjGJ!F8w{9p#0U;-h;0QkWQF{ua>r2pUv17Zq4pbYy7DtDj<02DI|Oc#RkVI(^6fG9&92&laMVg$e)017c{K_0>#A|*MXEkIJh2!JvTCilQ4H*}yL!3%=tQi0DF4ge|hVN}2n0Hy(e0szo~3_lcifdKaa2n@r42?EdyzXHev0-p;fq5l5?0{jXBo&f^;2LhV_H6$DW9J>iIE`mJ+0!+XIp8z2N01q3WGeR9#3poH)U;{H?22$YtL|(wd00|KR0RM3SHWohslK}S%BPR4<JpdR7T9Cm6I-m?Ik^usjL9QVo5-<m?Av*Vg2QL5>H3;)yC`3U4gQpz;4$y$qAP_)dEv_tp6*US3K{xlnE586QE&wScksvxo1)w$xQ(~4QSO6?Gg8v{405AYFEF$Fq_&@~+<>~+dRRH|~_#g)Y-wOhv-vb5}022sc5-_a+cEA}1KLG-RU_ILd159TI4NPJ41U~|<3<8@CBtgO>@3{j4$R|Sa3<5u<1Oki=9!qmb;E_2<<4vVL!3BZ=TmVG6zaRq+Kt2Qnae@+;01O}oATzVTxq|~=03rqe5FFq$z9DxMG6)*rGb$sBqLB$?p^P9zK?KJ^Awd(HF$)AiC?pId(_jp0RDulx!XhrgI~?2r0|Qmu0%#x`pxntoAZh^p=NjV03j})<u0KcNdW1h1Z((Qxirj$$HXtKZ0chyofdx+AfCc~z7Jz<&3n?OCZoodJ2!Y>V2O}H^*vH1xK^+S{;|1V4!4fd4UBMO4#}<tQ1~O#G?*amq124hF3k{_3h$tXC+yJFu1Ec^qT^H7X9RLYeLLZ8tDg__~cH#yDpf#OAO(49DqKjq#00ROHV*~UaDC^)lj{pDw2?_rKpaKHK3<8vI0Rp1~1p&VXXu-dU1_Cz^4fvoTB?4um1Lq=Tq6TH5U19n)K_U<V7&Zm~SeF1nGEP7Wtpq%Q7ieLiTLC-49bf_{0A2ujG4?<Yp#cB{1P&o>m3IQB0o|Y+0al=SJfom7XdeJSIy}PL09B;`5CS|2w*vnH=?wzZ4Fc=;0|NUOzy$(?2>$}y3j*m00<`}M0*?j))(tGgQ7BRXH?#ns;FlsY0^a~Q05CUmAt(U<P5?eYJ^&^M?*I`o13w@H01hVv01;TA)!-ypp#$XqApisbLInUf^j~2;0UoX52LKKTO#p_#9tY#(+n@;xfGaXLr=mD!;|l0Ps-f8(>A(=62LRo`1v?biqzujs48sku#}NS-glZ824g@0)1SA3g80Ov-;X@DrIMg8q0RLS8EEzrx7yy5k00td8FcPQ3tpv`3l?tZ8FDk^Q{{jN^2Li$k0{`s;0+j~>#st3t)CmIp2ZBHyZYDt!F#`Bt3nAdZ#t}m!IsSlW2vQ|72EO8;E(AF~FM*&YJ}ZDdKRo~@TPAMcVE_oC>49os*WnT{(ZQ)4X9TwC37J9)4ImXA3+A8^0yd|Bu%T1|^&AId4jf?@JPH@+o&igvo&Yr(!JrHR|GWeOiVFh91^)u@0RrI+0=EAR0>1?U!wCYvoD2e)2^d`ABDn&SgXtj@G6b~&Gsfzn5j313ZG_)NMgZLsec=%?34~w@0BH?BV4YwzwgMaqImPlDWC4}Lb4ObMJ_%VC6yN~k3jhJ*3;^W04YotP000FI6`_m22?DJH0=pJsi2n=%uLA<x2?F1X0s_JW+(AbIm*oN(btp2kr6d6Zkg0)$MFIh@VH5t~1Az&q#b6i*ph40hBQZlAV2T5lg`9*m!GWP51?ORV6EXGx06hZ?y&}>A=?%_{i{KV6q1p)kabesH0<#MOgZ~Ty!wLf62?F2l2Lgx-kD=WQ{{r9w0;~xFkpBw;90C&p-3Ippj|kd;0%`(-_X;~9_kckH05-aw;4qMZ9t$^f!VS*^01y&LgUp2i0QDQu!5jo2lmI6%(FV8xa{|tw6E#3h0M|G-9yDML^gtg3vj7j*!LlL@HD}-(^$VMV3!8zh03|fH7yu1*zzsE@0Uz%WHvq|p02>bgT^X?eEFAy>=Llc`w-F8iQy?fc|6nig04f12!C(OZAk`3h<S1N$A!Oi25q|(X9RLnB5_Q4s3P8vsC_EBk696Rt4geGf02ekC?CL=dAPWEoA_xE#zW@>y02Kk~0f%n@MH&<gz$iEqz;6=(I1R!e0syMQza#+o|2ho?fF=J502Lwt4GI|Q59KXW0CotVHVOd$BAoyaEG_^RdMbb-lwbfu2@pV_{T^n(LkR`|>Hv2TL`B&E0stU{L)^z;=m5zH1jlF-0JAhJ(BQJbI~(tz0RHcw4iEy+3j*W+3j)Xl0{RI8`}zmSVf+aK#SOm#<qZPU2t2{xe*yxW1OmMWR)OnbFw1lVFTp(k903U*fGNSrq0K`jglvHV0o4T?g*|SfA@ZRYHP+6d6*hJu9X3D^0IM1Z(%~;1;0OVL3BLee04+T!t-vt$mY^C617S1(8vu0((tsuFKso^cn;_N=z&8XiK@ma%{r^`X01O9!3<riL2Z8+!3jrel7yt-8e*hv63ji)RG63ofU=9SvAM+p^I}g;mgahCTSs*8fK^;5)5CA#=JvB4{Un2$p9v08xE#m?8Ao*ZG^1=fI0{wpk0;mH5)Cbt0r3qUA0lYw40SLu_40x4bupmmq0suh+W1}Dzfn%X1A^ZdepbYwfykh^o1p=-N0)hm;0*ej;o&lpI|KA7#$O|Jo!WRH+?=1ZQ3^rO|BQ@9KWQhgPAT}MKy=5^5Uf}a2Nb3MKp&0-RAALb~U<UvcG6!M+k0n9?5s<0p0lfhoz6(G^01yiWhCn{61O^(wH~}IDDBuO>03r#o!;s+=G7F}tK`J8W!ge7Z=fD^J00yHk0C4~}7qvhlz#^vy3?5JcvhNE5xCkhw0=W#|0?7;lY>q*<3;P1JsK5*Y`U(R7$^ioX2m;px{3PKcAfN*R%nbtnfd>M}0s_1Z{{nyq0=NkRe*Xf#0s^K40*nI<VqqvF;MJh00h0kUqvr$w43hverUU>%g$0*m2J~T<U|8YDfepn6m+&0yf#C(5;Ryig4Bp`E01Jv>6EO^ql0XVE4O5|(i8TNK`38gF1c4Yf4gij?00|=xgrPZ-APUz2G$-653EF`;4{n;E5jYTB0TVYiU|%jJDh(ioB{<kZ%rAg$U^o#4Irjr260Qnh88;IM<Q$GAJ9ObdcEJ?m;1vK7m!KM%gdv%LMg^e5A|jx~=?IcQ1jIP|fGYqmzH(q00P_Dj1|k=p1~C`_5f-lE?*ky}o#r<fqZl3F7&aL<022VBzyJWEN)!Qi0RSY0;Tkv^%s~4k7Incn8UU97mmNDU2O=BKARGi7lDi-(yTKU17hM3b!vd=SDhq)juwp6H;357Y!51|X0OJ57uRSv!83I8aE}$3tH6B<XG%O+jHh%yC1qJ{e5Po5I1pom2fB^&qrGe|C0Z-!xtte;!1g{f47$x8U9QuJ0|1bmqLjWfyB>w=R03<gfDL8(#Vg(Bh0=oj};s3n}0`dd``wRa9;Q<1V2Lk2q3j#F)>tL$}0{ij_e1HPU11c4l024a?0ReiU=Ebgm03<&v06iD_ApZdXWB@P_0s#L)00RIW1OO`kLI4E-9|iy{{X$1TAqW62Cjk2m9wneC05dBge+?o48UO|bwgG>J046^V04*B@t{i{>8wnmECmtaHc>@CgWdNE09v82Hx_}`HSWg`Q20maeUiN@Gh5#uE={eV6dKTjg0U#7T2LNFq-!K3+DI+QX00A#H000C4U<HdoV_|n53^$5^Jp&Gc0(uI7D;U5!00LDnfcppnB*Ux+0;dDsC5aWA05UltHYu71VgWlKG!ES0BEbUum;o?B6EOq;V*uM6V&C94Ha}oDPOjk~1^^!p1O)`_Q)&d}It1zlE5HmZ3n9K4KmasNLJt+<2!5CY096441OqyOevTlG1q~Gd6gGfs6EQY{Bv%6+0)fI!11w-SC@f+ifB_)^!2%(GE#a%6<{^K8BMmrA;!MCq;hhEyK#ItL`V0U&Dq#WuqW}lv3_#Ri?SsDJGyn}xC<Fi#I77=sIn;pf0RROEra{yK0{_bl0`3d~>Igpmfv5xmtPPmJnILe<<Do#u#G7FgF$2Yc-9Bhw0RSEXArvyd0{{{L3?j;aLp~s&8~_~(FkT?L!Sw^i;RGEd0{{*y#K&R#fgT&AqTuP_6EPtN!~r1y6rdjhF$W<7L*mV093iCB;cj670|L?)Lj!H7=0*kXU<d;L{S5-+3j(kP{{r9%0^9)tlp72Z+aMl55<m=rvtd6101W~F5#fUSLC!K@696_XfQ=vt1`QOUL?k-rV@IVPpy<Ij6fy=IfF1(5A=!la2d9D*LI70&00s30DuKrLBHIN5$%6t6gD5J13ggBEQ~@6Dgkcmi1PVYL4K)_GU<oiKVH?yyHpmtr`3Hr8g8+yL0^J5agkUZLybKo1Kmb6u017h_LJl<(02}iSIea0@fd~))9qxi401r0{!5$Jf!lB_k%pfWu&j1HO4>+m^LK6o<5(h#DgMbZp0RSf+ArU<W8o>7~4<68<C;%`sw=fVc#h@+#eqb!BjG#OK;5MruK}$da{{RI70^$h*<9`VQ82}6*K|sO(01Gk#03QH8&paIlAfDkAzy|`@_`vu8_8`gy^}*>0e*)MI4*>ulO(E?S86XD$OQ8q=1pfdI1OO5X044fep&<dlLj?dh9S{mY@`5km@`VohfCRu+1V0A=TmU@^GU`}h{S#clxCjEM0|I&vAk;;G1_FTxM8W@o1p-n6m;?g<x(ou{1OnX!{{qGW0@4Bkm;VI<uLA<O2|n;FVr>H|fQDcX030`QBY|LFVAx>?01=De@^51#*nt8A5C9hiaQ@=v0tUbprUL*GXGHY5VF;i#=U^BB1v2>;{Xo;9P5?bXKED7a696?4mOue_03Zkh02VX}L}A+xH`jnT5Sc(Z0RJ%#6aZ8J9~J!~ub>J55C{Mf{`a6W2>>+!DLwZiHy;Lq3jjF)w=fM8-XJy)27)hp3=*|~3;+%d1;Kw4F%AGd02?L1w-qxFcK{y@TVW36HvvHk2S;P!2LKieG!T1WAOu1X;1d7@LB}x<6k*`0fe-)y4(J=8lA)@B9_s-VG7ek@f%ah*G!p?q5f*@_Ar~YKp#q^50-y%_03K=N5&%vBK71dcN+19L0|^4Dp#Q}S1e%$dnVJ8YxjzDu1Om9P1p?v&Il=JdU=zGA0c>ax02Kps!3!c?fg_~h1AvjC5^CTC;J*d{DF7%tARrc+V1pbJ0TM8c;s#?Rq<=!;A~WG2s6`w8;sE;z1@?i=3j&-2y#f#5*9Z{}8^Hpz01vTY4?!FZX<`fVaK;90K))dvHUt2FB>*!6K0`05pxr3>1pxpd!r>P+zXbqc01ygm;Rl-l7<NMtHj)BupfJ?ppwYlpxBw2Ip|uBJ0;vT8m5l-~YDE9S4FaYD0+0v)0>%Uah5-Wm>j@;X;0vmuH~=u+IP0N41Oh$48V1U2K?1l1IGtd)3q1f>1VeAYykkB9KOr8VXzn@T6f+1K051eOJwF-&Bs~BThakZR?Fr++J_J($02T|v0YVI`qC4c5K#TzsF(UtA9Ao6N#{**yUP0o7zC!5)2m+P^!GYiX2YTU)3Ib*VoEHTGrlKJm?jb)SGa;oPGa?e$0O4UbyW}I~IlJN<Lj@3FAOZkE5c>ez0MX$%V=uuk+2C6n2jAc$GN(ihbl_YCpgtrJ02bAu9=0NBC!C>H-~`aY`3P5`=Zp;sz-vDR8~_}>2{VBg06hc2K^)G(K@u<o;-OCf9{}G!I~xQcPQwHX{t5w&3j&!90-w(d0to^OU{HX<0ytyjf#8Bb;6E8*%+5d}r=bm%z^mX?U=o#JAu4KQLmm9X1^R#sA=KcvIRFhgU>phhgFPDq22a2pIc(r%$y0;cZ-5Dx01_}gAr%YsZ-N6M6(K<Z00aj9_JPX^0<H`Kp>Y8s1HGW&Ko<Z!QNR+RKp?3gp+q(g;6otp<<SClpw)p>!7&(M7XYU|1O&?gL&F9oK`7lK%pgBI93@2q2wDyVHHT`+KM*4iBrgW?gBt@c1b!oi$ckXNfz=)IVj?2s2U<Wq18oQ*;s62vKnWFtA#cPC0>*Fv2?8D<|L+F^xD5iM1O9Wtv;zW<1_G-23(uj@V8{XjybZkq(7?G20)SXz*CPlwRpEhPi69hJ<cMnan4uUpG(iw13jpqi<`4iITR;E}HQfjQpdJu6yPyaFZxRUr6%-&f3MGJ>A_&mn4mC3&1H%lj01*rTH6SSFBOzT3&fpg{4UIww`JnR=4g;d@!wvvO56=KQ9RLUi?!yoOiUiFO1kn-=W#vKHKoE*>Bq#yo5&`AsA*BEi*5F_mHr3%e&VeETM-2)X21S(trJxiQ!ub_Iz!xAe05dHjd>;a(MhO7o|2i^4ivt2dLj%MJNx-P%3hf6q;jRTT;q3_m|GfeN-39_ADIXaC3m!mBK!Aa`LUjb1fCsdK3jir%;r;|J3;-ek2N?kO5F|ylpdA1YHuk{59ubX$JpdjHe+vLAI{*&=1Vi}*F`xuNH2^C=CYw1QieM@{tH4~r5Z3@51p}csO~D=#lGs5iv!MszLHHm8*gd)f!v_bd0std+z$5WG3cv#s%HS0M@c(@~%itjZ`u{ubU|Mzn1SWyk19d|Q>tYCXLxSKmqaAbQFQ9M0rQwKyV|8I+gBl2g^&s{`#%>A#3<5A=XSoZPWA_3z1ec`(`U(R7;0FS70_h3@-=+!z;|OXY-3x95=gI+LoEISkxB>qZG6euQ05LY`lY<sVoC5~g02T)TUyc9<9t*lbIJ!iH(V(Cs2m}dTAs&E(;~cb{r3Ga&ZovsKYT^riZov!y3=9AeB%pCJJ%ESc#NiS!4l_V=G!Gm=isJ$R49WpT4~>E&rKAOjjermWr;f705-<W4LAd1{)E<=DBNT%X7@-nP029d*=Ku^76T*7~697S<6aY3I02n8G0Y=vV5fv5yGjD+i08bVG3>5}KbD<6Rfd3yA01q7i3Nhsv7Xb|9gOq{}03<5_1{lj38-^PlqXZ!R0H}lg{|5jSHTfEofgB+iHV6P%{{TTc02lxYE5`sY0=fW&Kn8&{EWaWEHUI$y_ka*?0N?;17Ac@P4n_dqQ~)9wC7oav0RIsd02LDeITQX!pgRB#IRFI!(KQH!0Ki*7D8>Lf0P_P?2*FRm=>-C){|Exv1p?^-0(CBXARa7%6fy$XfbA2m;0FNkVZ{I&QzbG9KqKJ>%mF>|V(kFE00jpKs*VT(^jSa&76b@@K?VQ}YApc=2@D1i%IF3W*S8P=7K0%PFcD%r{t;#rC<4q20>l3V0<{eS-2?*r-34W2BftX60{;Tw2?9?7p9r@C-wB}M>;lvQ$o~cc-2wuA0?K^`YQ*qA0?`ctWWNAF0@exw*kHZC3<C230<_j5{`Lxm@IM5{xCsKOzX<}i0s^H6WeER30?Gjb#svcFod)j%e6FYl033ejpc4Qy4F~|#0ILH44j>RMAq8Wh3qF7Vf&eul0=WPj0H$ez2LJ^?1VRaD0bTpU0RG_v08#)Ar6jB29d1BXfC^QI3;zHQ3IGrj05|?a!Gr)7GAkrI9{>>mBM(Zz&mi2P{}wb201^NWB+m-~CNpK=u3-}Z(KcOS%HRn>ItODJHMcG&J_leXBL`w5(&Ql-^WfQ_C%~XG0RJ8UWB@i64glYA06`x;LVzn0{=VP<Cjb>D7XbeOuK*o96#&uy05?oZ06h=@+anMI02U_$0v<j8764WN0wWy&-x3f2BoPAu7byM%0v|pX0LTCX|4JSJLl6KZ67~il7%2k)Jpd#V|0e(wBp3hzDE|O6F((Zu02=oI1`)_W3|;_0f9U`7{{a9f_u=~<JR2bvEDHcG+cE&;Asak>fB+)?0YX0&0ABz#Mcp$1pff`;W`Y_Q>i`>3z&#5904Wx}{(v+qFcT)CKra1fqTpTtL-+sgb_-x98DgLvI|bAL-5?JD038;c0UH3X7aIT@4<H0)U>^HC1#AE)0{~+H+bA}<AVNVnpdS~#H-(@`4jcfWfi1r1U<UvoJ_QB98~Z>Vao{Wi0675HJsKdRU_*^T2LRU_K^_9&Edt>_9Q`2(K^ZpyQ~)abAT0?39{>XY7r!hQ07woX0pcOzs-QnT0RlnqzyKRP?IY-*BorKAH%BLS9Uv!09pN-YG6&+VBo2TlB?&?%0YMkK8sZoez!m^28Gu}G07(-Q696U)3kBa)04N_Ti~tJ&{}>AZ8xsIPAwJZ=6aX6@Hv}Q0;qO=gM=+#75CH&dCnpKQC>FpR7SAKT>R<u@(f>f|U;^I&7Doc0X}|#j|KSA!@dpB+2mb<`2Lgr-0_Fb)0{sL6wgm$DLE&R^M9@D1fCv8q$^-)U0|M&*1OoK}0`&<3^;rXlop)v6KLW`w2Ljy#14s%1XLMjks|x~m#sz?a0N@3M{0Cr$A_Bq%0^tk)1e%$dnVFfn|33nL1bY;&M}OgZ#6JR^0|8|J)IS2R0|JT){{pKG0#O3d2LA$x3IdV`0@(iu0`v$1H3H}V1p?p&0-Ff}`;P_(grq+LzYVhjxf5U&NTCC-$JhS`0<;SPrUuI20zCj62GF200sjCc05AnRKrhNq;3adXHPIpQ0S5r<5i{WdCgA}A03O`~Phb%=1O}l5JDWr?R-h?0>tG2%1)i+oJ01if0)=+qB$omJDg<FU1YiNcCHw)w1z<J?02=@|{|glWG%WxT2mL!);1>Ww0|)@O0su5rz#$1bAraL#)d31Sff4~hBMaURfHMO?M-@RVI<AD^0RSS4!5E1^5Vrsu4*H=HHWT4D)dG#+5r$zlVIT_tdn`Kv;1U27ClA5+kHL=M83H#105t&rD?TPQApkl6|2i!!044$eFdiCUEI0rU2td5x7r@XUKne!~0SW*_l)wi7*BLqwX+S>qp@#sMNgfy%;3y&?TYvzsJpdgDmViNDfDpF;9S~q(MFWT-3B5TVVh$AmHy>aMSw4AS0OJw>0OJz?<RugV<P`@(BVjTUK_I}BEJ35-3*ZSf0SsUt>i`^kfF-R#8#xWuao`>nAz>8vK_m&j93U<|DL5a0;3U-w0fRXKf(rv9Iv=_gz&0L%J^&SqAQXE#7au_?0stu~YosWF8lVcr;UZu<EP)gWDl4QcfIXlfEPy^jEP;PI05&Qx03Sm@y*EsuGzC9IH$f@%yg>!P5~;vF03Zv}2OvKW00;m;g#ZTt=@k#?JS!MHBmw}sxBn9WR7A`F2!IR(AtOSd5E%hI#7&|VDn_A71;7mj#2B_<7XVBS;<*+c=tN-<03NWx5xYACxBxLhFE}Iua{xiFz&|J=01>VL8v+2ep&lA0K?W>iV2(a-7XU?F;3D8Qs2grJqyhku%m5@Dn&C?nH!~quwjc#-9Xuy`azZ*;Auc{CGg%?MJy{?r0sv0L;1+8<9<E{^0bxEM#~`;KJs(6sA|b&*Iy)B~y?`hlE40D6!Pgx-Be4M!u3!fM+ZaCu!5}^b!6PJY1;9HP9s{635d)x>#6Te}#lRlZAmLyo+R`E>(%=<74dEX>T_?z(Cn72WAwLiyV<11Y!PEh1z&;3b;NKW73ji>40RaGQCjB8CI#)p-DIkGO6}h2g|2J+1AUzZS{&FBd2mqG=Aw%6Y3;-ZLDi(l3IzASFA^;T<AaJ1SL2oSm|1)r)AO<`j;XHxh*r1Fegd#l%0Dn~gEgK&IEBb&}7CkKAAsFX@NsywMFb4r^#4IFX0|r0`y8sp$fB^t39pNHtKqe(%MCjudL?vPSB|{})C@lcB0AC|HFGL>c;T!4US1ckg?7=P}z#~Z@|2hCbJ30U?2JZkK95oN%4?i&0?;sl*b>S-uK_Ne#G3H=P3Nk0a0cA7R_uwlu0s=MO0U9^<AOIvp;6V{VHUR%S02xI93IIUPa|%NM8W{n0ApZY<VE_yjHvl&>0RI|6H~=UBFfqF_4h!KLK{)}Y5O)A3Iw9Z^Ks$p#_ccE-8NdqwG(^~qpdMf}VIn|_!6iIePk|fmAszo^L_J>+*F69u%walzp*IEfLbn4vs~`{nCq8a2;2A+bNI@Jorr=F2$sja5x`LSrKw?J8EmHu}qzHeYF5(ve_e~Q)2Z8|rEkfEWf<vFcCqz1c8bQ7ofi^!eL?6_EHQv|35CAAe10g~?`d1+x4#PbFDi;ge05${TDMkk%8$;R>!X6UEHa9B(0RVe0H^V?QIwAn7z+V#v039A5;Vq;=+e1fYfJY8u!Z0WQGXRkQJ|rFh{YSx|_5T0?RRI411Ox)W2m+J;2LdhvhY1HUPXG!lK-|E>U;-5Y{|PVy06+i*Jl`olF91T{pc@4904V9e0-zrNKRxvu>A(P0U;qRK0{_Md0ty1^0|Nid3j&!42pItT3LXf-2LKZ>0&c`$Jp%*hU>pQ)K=%?b1<&9Z2L}M>5-|hvq6o$b7XtsL1Omki1e%%unVFfHxjzDuzXSrf1p?v<!rcD|0=EkS`U(R7paTM^0|L+s{{qnm0>lLZo&N>`$N~b71_J-Q4Fc2$0=W!-0)Phs*9b$<0j~i7903ku0?!~76$6st3zmT+E<po;5(WAM;0DS-C_4ZM04)~qgB%A30to%V24n3cEkYd$3IG!^3i=Ad3kBc|01ONOUl0obBOft94f<gJAr1f!2LKc?bq@`~Ib7fc>;I+z{KfzZVHh?D03`tLGXp+D&LJo=0N?Nb5&#hAKqxbwIbaI_C^-mV2jDi95Zyo!{(vdtpbB6t?*J+aHB<mx06=RE4Edls;o&t4<ACERJqG{=AOV0702}W40S+}1paBp!08d5$783;o17H+SfO-RG2-`pr695$sVEr}hU@ibC1pxW2|6)KO6<(w$OT!}02tgP&7O&u;0001AA^;5v7z9NqP$K;yCBYXp7XV=Z(+~-XVYFa3CxIRid~ss7pj80?1qej}f9wJRt_%XyI-<M71U_Mm4HPv(7jFPO1OolQBQ-5!ZpXnBF$83QBsph*uK@rZ1uvoo&%q4WHULB~00Z+NJ_PLq5x_J6<6#W|1GNAVpb#iPG6-V8GfOEV(culKAq3+s1mbRAp#TE}Rw3C35(B*kMd$_q919Eq4_yij0X+i*27>??qxexNPJmCK{|f@I1Md$303J>O6fy$(M4|&p-~<2-1OV?53jid1!65(y{{TV-05=@~3av31fgTKu0|->04Is~;1i&9dPrxC82rQx+!L)4vC*TAX0gnYHV-L?g02l=e1P=%j0MiU2Ux5i=IZ7ZL0Cyb<G3bC706r^VJSadag)jg!C?i5C0QhBr45ETS00IF5HQxgP02=`(p(i5vbcX|hh2XOS0ww}~stf|U1O^TBpsybS01t)W1DgN}lr><-APm5v8*LzjpgR70#|r}W1OlK4_IBi;0(s%I0|MJQ40@r50PqPKb_jA{>Oa8}3PK$*U=08TcK{#;Yhe>H2MvN!bAcTVglypkHh=&)fcqi_et;M@2>_0d00|=xWFdZmdgCGbcOe&M;3xnwEGE+pCs@UTBOy*97d8I`0OJ57Ju@CX885;v04Xiy!1#dwRR9793j(_W{{pK90?7jcp0xpx!6h2R^bL_=HUBoQ03<&v06g~>06i#xJpdU6(4eE90I8sa;5vN36#&x|Is(b6fdtzCCqDlmGadje03`+KFh3v&K?6V{ngAYS873d#is44#9Sa@edjtTA;5`5w2!_BNJ<x!|0195<4Iz7BMH37_5=_D;!3aqSlSV5B46tAZhk*)u1%^Pj`QRW6KcF@&%0U2?0?NPy0AK~nKzYJAwEzt<3Ax4r00+V~^DHCMAqPq?04o61E-D}^$-p`RLlywP@&7si0#$LK0RICt017As026<G06szv3p#Fve*gjl0Rp551EuUMV`9bz6T?C21p@o12*Clg0s@x-{{pfH0^kV(<Npi-+yMfQ2n77#AOJw%KLWH10`J`h0yW*>)C>YYr~(4y1}=)=cA@muVOb0}cmM?e4Fz6!2n7H_26zJm^+CdT2o87vZ-ID#xj{|<pFKc604A1zd!ZBSF$vz_8s6X(G73Kc82}9+KvMwqVC@dl0VX@YU=RQpe+&Rr03a75mIQCG01_(};2Cy9Ab%!6Au=BTA=#kILJbeY4iCf)z&HRc3_qYY4;+93v!TSm{-8w=0D=HFBmw&X5$#|;J{$!gQV3%b2yWs*4F?Dl2M%}|1pYvqpcMk`3Gqbc?x2+epP=`u$v*<`#svb}G6I7N0{^)K0`UR@n+pCkLFx$twG0B9^#LzHA*Kim03||tAfO1h;0^--5+R_S1bm<iG6gKbx57M#PynnT^C1+wV2*%U0u6RkzyKb4;S@3pEP#I-1|0wkG7JX9y$I>R4h;Yj3&20bBH*+p4hw?xg2P|}0CgCdK@k3c6*Cd*LHjZiwO|tfLk$3SI^Y&H=RpfH6=wkX9}VE8<^WXy00r*{0=Eet;oSuU|KWNRt_RGrK>q|i3fH4>%~bzD1kKFM%nZ-Jwm<^;0tcnRAl#+Ee?bEPLcxF=1=9d19U#GBA4xzE0P7Y9t>HYTrUwcF|LzO|m;wUC4F3Yg2LibX0`>0!0=))~VUh|0$-d_Vi-7_d0p=kUGv5RNKL9OWK^_KQ05||LI7~q$YamAGU={^@<N@N2;RX%{{RB&)2mlNR02OmH34mem;TALm??Cez3NWEnU|#?!I@+dzBl;r*3+Ms32zLUg13{t84FciA|A7Yr>k0x?0^>CxYl!M#9AFOs90NBaJb+}t5<zBw#-J(zNeH|EZBz$sN;*ITawxJXAPI6K1j`BlNZ=84awzMf3_TzPG8gk8w*mkv!(b#eXMh+900KdvK`M?y(BPlp<N<!zU^^THApij1qF)FCjsgN3fK*+C|9cd!N8x&eKQ<tt^9D@d0RZ9Q?7|Nd05%PBAS>Y4pxYp>E5Q;l1u%dWxMMcRQ$Pjd1wal3NnAk^F!>1YLFfkq2m<v6_X4jB4?_Zy1OorK1p?v&0yPn@696*|e_$gvU?!&m05wyg=fyCofB?ZXgCUJz@<7l4-9sD&?ulR$Fa`!-90vfeDF7%tonRK^gBz&`|3n61Hp2iPAHxWJ6s-aJ3IgT=tpWes3<BN?0_+X_0{LLw3j)dk0=>cfU<Lw-1pHyQeFqg`r2+!816E<Divd9Us9gX9_+San6Tk)l9unX`gb)(P01F`$V5k8RVPgQh8a0}rG&BIBfhX?=05uJ=KpzDF&kr2{3aUV;01P$C*`OQZ0|nv%SHLw2{w$yx3jkOEK{IxHAPNn3;S2x|9KfkYV1d*C2Bsi6E`d~E03sPB0N$Vm;2^0<fB^@i4F{n`>>vugcICh^3;-P}U=CU)f)BSqBQmOB4YA<+9}o)SOaK-D7F6E=`oI7R>j&!~J1oKS2ZaQ&pvZs>5C9o}5&&NSD?2FwprmTSalsRv!A1ZABfxf6y}&UL4+s<w0}SHgzUZJ70Pg=f62=t1iU1J+LI(f~JtE$BfdBvl0(XI@1knRC2wlKVC<A+;-~?|1=LQ5fiWLL>X5PWT000XQLj<4${DC2WW4R0h-2?)k-30>B48x)Epn=~71T!-;06^0}=m7@rshGh7?mz?p4D^nGRYW1Az(EB7HgJ_=MWcno9RLRa5Cp*SROg@|pzPriFbM#EumBKl-v9sT;GSyWj_LpZa6$P&3QC({5RxDZ=-~1p4er2iA_xExo+Tp;>;StNH$}l55;y8#JHF~+IRG>f7Xg4ezI0)i02?_hOQ8<G0673M4;2J}I4*p_0RSWiff@mToZxj62Z1~XgEbNu2_bF=gB&_7Pyibb2Y}}@5f;h8s(@4gAM+L>{(-<i7XUp2@e8zKabfL(1|0&1{|y3&4g$^t0=_DM%>)9S2J4}?{{#Z*4Fc)}0{!@dAOZr{1p@W|2?D7J0$BpK{|Ex61_Gi60{?&q0<#1H<p<va)dK=N^a|lWzXCx5unk17;4<w2T|hi7SO5o30RKKgKL92Z05@3`L|`sJG6L_yId9;<0{|%m05`Ou4}Svy6cPXpBlbWzbpZgtsDlPG7&U;Z<B=r-N6ta5K_#96)j%^#1^@@40*;{apg8iN{UI*EL<j&m9RU3d&mdg@EEzuze;5Fc00<xrkD#9?08Ris62Yp%7cT%l0}A(o3noGLfJy=(44+^fHsS&V4xxa(9<D(YG7kU*ArPtnpgmnc6Nq5|0zwg50|FA!fDJ1MffEK{{-WU&G86zU01+<(Hvkm}ViuKQ#(=P>VE>@nKsq5d61$=ub^;<E8Al)#G8&7Zs}~y*;x-Z?9Ol3rJQP4Cp$-KA5*^^L!^s{D#TS7U@?tHa9RS`RfEYdu7tp{TI{rVP0{{;R0>ujat--9L{R{%51_J+~0|NaB0=NzTDm?%i1q%QsIJ#kp!0mtl2{SfA^<b`Kp%MTOG{7e`!KjA-J|wAOpCMd8+8_X3Ah3Z9HUt&{5vbz75IF!E00#9S0N)D`03ZdlU=lih%0K`wKPo*R<-ofxIRJnO03nW`ChZ1gfEzsSfgKh%j=7)|I|v^k0bq0CJ?j7?b6_vcp*;X4zXlxu6g&w@VHd489ij^W14Rb|P&Mvz022T|v*RHcD|{pZo&X^L`u{(ULT>^A0yUQa8v)fs`t;!&^yLN!0-Oc^0>%jf-v<Kq{{#Y(3IfCo0{_(k0^<e^0RYqnK#M>;3?L2W03ZTe01vicF#|>C1?b>y9~*%cGmGE=7#g9I9u3UH;h`<B!Vsbb{|Exf4Fb9f0{@Z+0@w%w!~*vM-UklhlL!|X?*IxPK=L3502EkgfczwVAQd7}0s`*==>y5aFTot(XaN8o{Q*g$1^|};7BuxIkl-|rK|25mKW_j905Hy>AORM`y#iXI2mo^cvS0ug05cm4hXn&d+MyN(?*RY?5+cE-4FdnJ3<8G;0-gc>ydmri0`Ua`rhg0qj0ysw2DwE4xdQ^o3j(qY?uMa^4LQVO7XUnU1Q!7v7XcG71VR9#Bss5w0w(g|1({+tYXC&EpaXA#1O!|n{}KQUAPWE_H=G6|EFlvy2X_G-!4pd|2+D#SIDjA~2!$XM3?c?#jN>GQfdhzoV800fH~=y?N?|8hGQxyl38FCw{Q(O2fJ;3%^FRiNU=9NdMgi+6Bossqe}Ezk0J#vrA^D*cG7babDpezlA`hQ}HyB1Y6@gL~;}90<g5V5&;t|UN@e&L|x+6vi162S3GXxPY<Sqb$3g)M~K;|#tj|T1mE?}Jt0{z`DBE<^?nwgnDnVFfnKO^3u^++`1;4fnw9sv?C=Oc`ub{T*ZF<0RdFbC<NCkOxxAz<mE3nW77B7X@0H;w=X9?e6_?L-X)pds%dIAIC^e<c7e1vx%1b)>Z;HlrNpK@u>n!5pH7!V4S&65s<P4WJ+uQ4XLX10WTk4_rbJ0-<FQ0;B>)z-OQV0B4}^bYM|{PoPgg$N~bDg#*-s6F9~Nfkq@^qys9fVFW(LEl`0wh2TMe4FzRDHy76<ARzwWGQ$-I{o)8|05$kwHN%vFbnIj@-~=+~j0y=X%V<^vO5+c~77xKOHaliswIKlj1Oo_Rfo32-3<enh3m$)=+yLP;nPAjFX8;YM5C9hS17UzE$6!?f00RvI4#C6=nIJfzYr_&}eHKIKr~?Aj2f(4<xeNlb2o+)c4gUhK0|GSy-30#vQ3BBh0*DIz0w@6K2?D$g0$=L`0>=iQAT=n+#P0w^L<~GYJ|sax1ptjU{U9&~U4f9mBH;*7kKhEv7r~~02SDXGrvmQ?03Zowp%XF+3TYxYZJ`TsU?QbTKr(?!t-uVlA|pS9mx2wKgINxjf<z$`F#%%`gyN*MV2eQ`+M!i~5fmd5-V`bm01Ok1001K@5+f86CKVDV77{D(WAPgjBXi<c#6$oO3iS#8K?3O^7XUp2H5I&r0(M{p3o2n%ApR;~`3C}l2m-GE0s?sgss#eT{{sT_0|KH878=PRA;}^XGNWY(q5PxzrK1KNq6Yvy02zr0&Lc8G2v@*sVhB$O8Y99Ar$90Q1GRVKSjjj=AZma^psNi8+z1lDsyu-NtYJLm0sv3o2LA^FqYVPe0RsQ_1Ol`T0=Wx+0*na)gaQz6#Qza90swUYGY<JbY+)lITL3=_7p$g00OJGz0pkTWq#kzWfe|zYVKfgwa^QU>_~BasKnoZKV)y{zNaI{&0RRaU0{@Ez0`CO^;|u=+4Fa$Q0;dK40-X#3n+gJ@{{#Y|0|I~s0{_4Z0<{SOkPQC<kpTj*1_BxD0vOUmNugo}034wVv;orrn83?pAJgF#>oWxCq6NrhQveR^{DIeD6fy&06EOwOhk<PXEYN}4Wdi_<4J>ux1p<l3!VO>zxWR+gqTq!A03T)H6)Q6d_M!^jA`1tp%c1cM1Bf!==wM3#1VV=q00crJ4j~i40?-fCVuTu`5D5Yi8l_7BT^bEb5;77OARl?bYa9>OAtDt47&alH{}(j}0G9w6H-9PsQ~)0qA{8Rl5)a`FQXvF8APp-fA7cUl+5#M75CZ`sf>jYBffK316x_1`W+0yf1Ok@~Izctz2daml0qFo7!UF=r0s}fofD8>lJp%-715u*=39x~K2LjOt0^jio0-gcm;k5%l0s#WZ3l`rZq$3=|fG=eW03_gpDZm&*D%XJp`=msJ-~;!j#UXnmI+wx&03rtdgRa9t6fy|@f+GHc39|l-ErBB%;RFj51h@YS0{RL9paTN?$_1{Z*bM^A1_uJy3fCa<<kunQq!WfZuz>~gU<LpT58zeeUh-uI06_<_0|=bTrwITItswLuD;FRkmXe@B3bo@4p`!1>BHqb?000ICCE@=AzXHPo0*V0?0rmR_3fU+<02&4d9RQR8Jpdb!Kx6>{Ag%&n6*L7OKncJ=ANK%1K7*tH01_E&@uPBq!~$}GlMQl#`<nxG!Gi$;lLPkxlmm6)qXz<K{{qee0_Ot)-Tw&!%nJgy2m=4N3<B~20#^b*^#KCZ1WoOs5okvf05tI=&LG8S14QCIHzXhg01gGr0{Gy%*Fgs+pa=jC&Vw<P3P^$rr(sn8;O0RA(*PcC<*T6#ra%M$|0D?j5(fYmHSPuB7BmfCU>G(j?q6UY6d^F64gd_-4*(G1pa5{d3<0MAAP(7KW?%${Ku5mIfCm5?I23@uB<?an9TPWoU=;vM{}TWd2LK*C6wd%*02c*-exV^h?h+v&J{D`BB0)3y;z1YUK_M3aUjTPALoooLF+nc?pm#4nEdZb`Ju3j9cPl$70bnUQCof`67&*rM|BaxDVG|tWVGI?2B|#N`N1z7)6?S<U6@L|O;r{>tegN?VPeNit&;Zm20*_k;4akHOF@8k|C*Y9`Ex@$k`$h#`W0j#ENI^hE!MMOQbfAX71j_>Y+n_oOqEH|L_yP9<qXvWFwF?4~{|ExO3Ih2C0{@o?0=WtT@Cx4ok^%yy#sCQd|APzy%L4+~3I7703IfLr0*U_t0^1D&ssRH3uLT0>0|LAW{{pHF0*40zfd2&o_W}Zl2m=533<8`60;~axXav51L3bcQfV;sK`81}XW5EUh9S%49077nH9|r&{4gTIBDFXl)2LK$cI;!CtIz%EA1S2K)2>>w!Auj^}9`6SLB0#SpAwUXxLZKQ6V=D^)Hwa<>H3I-72LLEWF0)}LMhr&bAPl1j0R24#Av*&ADhB{tE=&X=ElgAbCJ1BiHxB?q2w_130N*eN05nnvVKY+o5C~x`45K{}07?D?Ax8rMHU|JYU04jEIam@5p)wHT??V#+PY7X60|4JV2LM1`1R+0O^%M}{I0Pd}6#!NK453p4073@<MqOkGVMSyX6(K$$<L^%w09ynhSpxvyNCyB+Y7C)EYW7*d9YiJ}830up{{UeG02=^*0<{44fL`X|RB{o4Q|odZ9zjei16>^e{b>zBX9ECM2LQWTcmyF?cpf5wQr-k3V;=x-5rJ$2zW`eY0AGCwVP4yPAOs;-H&>u?g57Wcpm2b00bp)^-E0CNY<y}0;A(o^Xak^VcxD7(W_I0V0H9=aVgX=ca@}A8AYgD_0^nY5-CP5pTx?ndU|MS3SOp+hXjTQ_R%YE)0H9Q4QUPF6V%<;zAW&dV0H97@-An;sOk7F=AWB-@NCMzUSVjdPMpoTK1>i(fLI$8hQr$oYU_ekl2p~RA-8=~3JWM(XpgKz3I0|4mNHz-~Hb&hv3*a<FG7O+HLftS8U@$-~4j?W*-7F5^EIcX?pej25C;)B%A0#0VeGR=q0RjR524tjvXaEEgJr^cX;0rGR0bmpXW7cGILFb_RH3RTMFaR?rA_V}vAUnJw+5)t|*+q8X|HuLY=?Mb74etW43J`a{1OP$Wcd!Wi;0y=v001K-e1ZRf2g_opLJQTw6NY~Q01p!apaRyR{^_HS1_J*A0+jy;0{8?1#s&ias|f=21Oo5~{{sC80)!0$!T$vUk_rOy3<Cex1_CZh82}6O9zb=Va{vrE02=<^pa2{I2LS*hc8#GKH+P{JHUz{V^C>#SCIf6e03Qn99RLqD1?eFXH_nZM3jisPf$(7x20H*20l-NB5rTjRO8W-@2TvpbaR58-8$<xf%K#h+0N)xN01h^OK^_ri6QKnO6QImMCkxjgw;ekSjKC)dBH$8ie1I4r7&ZBT8y5M2zcK(5067mlz=`hwA}2r8pc4Q)-sM3N04W<Bz%Bs)DHQ<j|2r-K`zSI4fIt}l6Da*j0RVLXJs3g&Z({%_HbfvnK`uaj6b8Ts03Q}N0b>6T05t$EJ}W<e9{_a#J{dv`fW1KsfgJ!9Jc@xH_SL{&08imu07DVg5FtP{6hI;sp%^yt5CK6q;v|4Z02dM80I&cRD-7Tq9Qq*v3ll)|{}}*YUjRn_|Nqy3CNM#}96G208#xm301<ZpDh47U5;+s70ofElqXppR{~JM70p9=x1Oksd;0*%5#t8zf1PwchH~t*J0ssvH01*pY03=F79Re5NHeq4kA^-^n6gLDUHU7q+4FCfGAOZki5ElSG1joiX)P>)~3<AanN`bNke*(-40+<L6)QImt04oF<fdl~D{{S32051R{0owo^7=aQn!oeH?LN`DX*?>+USl|O-1p)!}FxNpGTMGaH1`odilnDaF0vX}b{{#Zc3IsDVGxh*L!#`c2=>-C){Rreh0<;1GmjV9*vIhdD1Okk^4J35J1^^u400>4=pbZ21!4IK*fHNC_?tWl701zqw0stca0{{^R02MO@zW|p27d0pXpca1y0CxZy1Ugv2ttR~d9XS`E2NWU*oCBfgpa2OlQX&h&3)cV)3v{L-WI#a-=<!1YMe#uh4PXro0G|*N01F`yWbvRm-y8rO2{A1I7XVv510zBL00BV-MnKyf4kCgN0FAH%1B(JRA_E4J2r0t~K`>NsAPC_D7s3FP0s|wVf7A>D<OT#G^JA|z696`10Ua5@1FD(9J(<D)NTCV~!Rze?ENadThGC5d0_!doIp6^mAUp&Dx?6x9Q{fXa1S5bK?FE!T3Nbk$9t<~jg}@{^Nk9Pr9#}y;6f)I86EOt^0hwW_1qUQUB!CE0h9Po*LVpPWHyr>9F@M7S44zC24g%u~0{_Sa0-p;4{0jd9o&f>}0-Xl@BLJZQ`UwJ}4Fdm=1p=u80<r=5JP-g*VH7d~01m$ZDIg^Z7?~g?{;H!M0RSujCkOp9FreQ6D>ozn-99q`2LKWkpbG%J1cCvB9RLe5oB<t)4G{wZp#})yWuXK>Gu;MQpcFC(pQI%>_8%f02si*VDIx%mHUI$vtUw2Z!hi`DUV$?T2p}e<0Rv&L!v6>W9sme&065NzU;+Rshk#k22LSsTI85LH3NIc&%?J))D?6!T7ie4nXFUoDjUXAu0stAxOBXm31uL?_uD}dZ;qMCoD?ELG2LKqmI1EofL<tNMpctz-4FO^e0b&jTVh%nL11tb74LBZvn}G8W54_^2;2;3`|J^)Hp#cN~Fo53+{{o={1{DAkI`$_3Faet&83qRc@e_UkQfN$}2?he-{|N%%0|MLu0{{910-g;5{|4P3<;W8NHT1y&0Q>@gbU_0EC;%@g_aqG^us|j}Au{P7Pk~Bh1it`60RZmiAQdwMvY<DOQNIBIQUDAmHewF7H?W`}K!FxC1ED#-1ECZE4;V1Sp&h=$;8Fk)C<n)Y9kmYyK_Nxq7c~VzI&1@>1wa`wy<j>?!k}+b01_$iq7XOCVe|q)1K}`eU_L(_1^FNZKxkkI69T3T{{s6A0=NwVqwNEgp|k^)L8=P^|H=UZiv|MM1iu370Rq_qsKMUz3<9b{se&*P01TlZw1AaEwP1%J0B(Rd*8ng#V4*2`;t&8k7Xod-2{8li!EM052mk~C4FqT+I3!Pls{s>nz;GZ0b0Qoe)N>(j3_*0G2v{Ns0AGRtHzou^!#0~>{{R~d0ABztJ>4q+pes8m0H7&3y(i{i4FC@gr-2mPG7sEf9}rpq6*K<)VIK_uB>*o47dk&LfI%{3fSrL}VD1D#6EP9pfE))0{{R*=5dc2`F8u{6KpzJHQ~)6R79&_84FFsKKWzzFfgKWLU=uOjVfh??!Ye`m02?a;|HcIZxC8>}4d(*10Z4@2!0iPB|A`3#um=KF0{`9x0{sR8!VJFx%?ARC3``;8`3%y5H^AUO0=fnN0>23YtpWm{{|N%41OkKz0{__x0=xkN-v-|T&kO>X0)Pere}D}FhYJF$Hz0ol0`&m`!v$1i_0^+b3_C%@2b%%*sX;;ll%oRxT>$?q89fXb05|}LF*Y`r;4#3RfMB5p;zwXKS%GR{OMnp&0P7hDrC<zIU<LplTMji(AR7&)AtiC)TmnGXLJ0s32p9?o6X!Yr3{@a!LIMCG{6k^X<pBT?5C9fM3`T)4MuOwu;vhW+2`MEz0%*Vx8)6O{WfY(}3>2d3Vh;cfLjZIH-y#4A1rwnlBSKyY01yBa5Q6|B*g@#}<2}KEBNFZ)2>>I13jh;R01zf3Vf#06Y2Y~kFbxwrYk)R=p#}gSSwIxPEfYc@9u*hi9r(bNgS{h{VF&;e06Aa~%K2b67a}u+p`~HQ0RI&LKNbKO0sy3SVFJR*;6M@p6z~BI)erRIKoFoI?BGEdYXCNjU<4N+CqeGu*!;j212u>b05yRf0Ot%d8G~Vnz?T3Q`!*;lh8h428UXhY697A6+yER#uK+XvA`r(N-9Q*U8^R<fUjQ2-sSV(n8Z`lmLk%P{Ass;o(*PVk#%ZA(1f~=KM-UV&lwm`H5}+IpY1dc)PY-DcfuJ4$|3)7G5CH%r4fdNM6E^}tAOK4RzW@{m03JLGVJP(po<SD_0U-cS1-}3o2LK{K4uLH73!z~f1|w1w033fp03rY|BLL}OyEGPnAU{t%fZ#p5O*?_0J4-o&U^%-<H-jKIM>T`sHM>PKgrGA+F@<0;yFo98ATK{Hh;2IcCs6_<rocZu8w6z`C1EAXV2OboCgY*|FeeybC;&hl0B;L(02p_{GahSz8#6i3K_)sYfHq(SC+8^uK=goTV@3cGtrpYZ-~XhbDlh~lQ1u~8;A=nw#MuMEE7;)uD7Ik$00a&K#{UTdl?noz3Id<o3IdM`j3Kf>FaEc|`U(P+3Ifgl0s^K20<R4v9@PjE01F{eptZrB18W=u7s3QTz!n8<!u<w=f;<Zt09XLOJTd?l00m9J2WlLG2tt7g0YNbeJA`TpfI<8s9SH#wF$n?V7Yn!|2?LCwjsON*9t&>4IRNva90{W>4A@{C3&f!@3gOt{ml7}yP(&lKX9dI#`~}7!LIMB?5(0+*4FZS`0-Xi||LOz+_y_{^0{;Tn1p@U60;&HA0$Bp(2LiVL2m+=C0z3ky{{#ZX3j~^(ng5xYnc+VIunoU02LKT=0URMM{v03&P5?eZKLFn*696|H=Aaz_=Ls?b!s9~V3jiqg+oLEokDw9&5F@7o04f=P0mUQ%%OP?Dq&A2kso*vP00uz)CVpW~06j!P0N*AT06qiUK?^l}{o?Z=7XU#62L7S4-eDX91l%Gu34fsje+mFC01*N@&Ol5BL6U#~IEeuU;S2-<)eQ%s4*Wq9{-6c`w;d2R)8HWwHlP<9H4uA18WC}U0-zgUdo>a~As9gq7mgtRB02y7RRI76)d>IRj7H!LNWruN{{oK&9z6gU1>*c5HtzsbAmcy)2{G9M_~e~qBscPa2moIL01X2G#lRQ%1GEHX2Vgj@q7?-@U?%R(fCB&y1p@^Dj?VxG9}Mq7!9frJS_DET>p&d_>EZ|Mq2&Wfq6iL4SR)=f!m|JmE&&*V0|H`Uzv~7ARsaDa;5-BZwyIzqIRk<U8${vj{$)T00+R;<GXnpI2?B!*0?-S;0>lgg_W|xC@clmsL97J=H3Eij3<84*0>l77_`!eL2m-DO0?PQn{{jM`0|Jl>0{7Ag0&ZZ@0#*_y01O}<07U~NKVwV*q5|L|z2R+vd*A}v0WtL20>?nfp5PY+02O#m-~whG!43of5eET$3I|Ui7ytz_7pg$;PoW9HxkN<a4F~`c?8D%5Ar&%nA`CeI?-~FG2D9J?2LQJgHVbzEBMd4)8Cy3EUVuV5w*U)zz<&+^FaR?sBDDek3^)KI01p5tmk<Cp4I>XS!5JeKe>M>SMgSKFb6`~@0--l}zzs^EA!wlAcK{m&J9dC60Ix0pDJnpKI~`#mx?Z3{X}}!-3L8ihrvMHU8%iR<4fwzyw-W#mq5v`!#z75i_ktKJHx&)Q92TlTH#a;yi6ALAiNGp>mK&fq7aO4m17z>RDXBYBKp!Ci1%nDnz!qNUU=RQt7`b2%a=`Ylpb<BXq6h#P0Dlr002T`XDUPA~7~m+K06PHyA{y>cpcpnA@W2@WCPxMU76xH!Ap;8p0|os8C_n%KRR915O$4yS<^e?@r~n?Dp`8?ppa%dGKj4D^F!=;iVQ-@p9s-XD{{o-_1f0o6BLCy2$VLL}1_b}=jG#GLJ}E~30^b1y0)+nL|8d!gMFN@x1pl<1*?B{F>O}tny9)$R@8Z_~<Qhvv0;dZE{{YBNXKlf&L;C{iS%EYr^=l08Lju_iTLGe!8vkuV0?7>m?+U*H*#iQ?23@E6e*^-a4FdcEU+4RS1zv~c3<8M-KS~(@3m!nfK#Jh>R-jU#TYcbR015|vD7AoQ06H{6KEVGV1OP2301zSn761XS02ntA{{TV&1ppxi0N*Yr01+Yrf*CmZ5dwhrzz6^@Cjh$=BLadNIT8gR32y)+3IOO}6C?#9=Nmc`2fz&g3;;3jCjb;B2f`dX6#fce4FDw$05T_c02L+*VjVmc4FLZS045LsGbaGM7AFk?9z7Nhpb`H7ClUZOCjb}SC=a3^J{P0lLJj}QnmZ5xBohGdCjb~J62c%q7~ZD<Lrp>tS|BA9b^`zzDiz`(Kp6u7Z$$M209`;P6$1eK8Y>w9Jpd*ZC;tErA0Ge#C;;CxEFujfZ9^Ua<p**^0@z?rVHN;8R{#!0JisvUAQzefe;5FQ05u{3P5^%&06sh%1t3!4e>WNcQUDAo>!EEU1i=|M5+OWs{UG1K02T>G=O8OIrmw;r8{@<Q;0ta6DZYq6I|~3SIL)9F*8n^h21zb?z&!xFAPZo?IvfBE;5}C&3m|C09qeEzY2l?F?SLW%K)?Y6P(l4&4X7c&1`R$-2=ahW4FUiWz{DA#0wW-OHqc=r00{;Z_GIfMHA3JGL16*_5Qf~q1O)klpJB{{@Sp~_0+t5x!Hf;SU<{8e7XUrApz(mpKoj=>H4YcxQ~(|oT_LxiJp%&3U=afV?*RZF1Hr%)G6Y_gz%?l%0B}G70AT+Dl>i$%JOBmH3IH@C;oxro0u8?(0<-}F#SEhT{{#ZI1p+|=fV~I*>bXAxfnWvD?>_<@0>Wc60-^s30-Xv1u>%CZnwgoInVAIOxBm+Q=>-C)2m=4t1_HDT0^J7w!oc7K0*(R%dw&$JN8x&;KLG^yv_E~0;S~TAIz)Rxj)5Z~fdU0WAuX1`og?U>6#x_jpn$=nzW@gdKqm$|WFx&fYQO;i8wA}T92*Na`am270YPqHN8tYk03`q|13E$NFQ1?$G@qmk045&8K@tECA;Q4{$IgJ!Dg^;h0O<iVj=%soJ~iQo07DoOKjOv!uE${&GYPpM7{;Ow)ix183GQJF4WKXs>pMaXp(p#n0RSMj1)&x+1)&)XwBZl51)-YaG{J!z4%>k>l@Ijc5VOH39f7U@5TXL%HUi?V0IYyH$G{Mm02>hn>H-cRt{@U#0KhT>KSmD$E6m|KwjdJ-3IYHoVgVlGdlM!e<10A;49-Bi6DJ_S0RSW$AsXE{6=59|07Sq+Jih=40s!Lw13(pSA^;jV7T3TY7ZxD@5jYP3H2^I?S13Cl3cxHDV;{tU>k&B?Vid%KJpdtZ4hsM+1LGhW9bkhJI_yAIfXIUbU?k%utsClqG%-}73Z_66@+yHXDu4q32LKp5{~Q1)05C5s4mm6WLEeA>Eki!y2I5yXF(X@{2V5Wp0ARZKARPzb0RSc%0UV7w8UY_3FM$H021F#N22kL^2Fo8H;X@$evH$-7162S41O)#Azz7192Ldkt0*46)F#rlH-n^j@02cx|Aut2~06+i*JSjgfytzP9!YCa82?C%WzW_fy8w4SS;Q;po1OZ{d1)2aJyB8)I;F|z60^v7(D+fRaJSjjggvH<ndyruUYk>g_=>QEG{{rm^0-yr|x&H$K@d5&t3<Ce-2LhW40^kS#0)PSn-U$N1KLG;P3<8V<0Cs?X0s@W)0-6o#K>q^44FX#Nn+yK}r3(V%0s@zx4FaJFUa`RO;S>IjfD!-;AqxN_id;h+^q~?T0388v!5#ezH-m8iH5EPpy$ISM3<dxY2fzn9xuOU?ATuZ=ULgelstTY50>TMX;3Q^&=5GKrAP#zh916)mzMH~005LW;fkO<x0C4~|7C*6|CPvKwGZ43cHo+0VGwcA85~2=(p$B3QyFdqKEi}781i(Dg0096CV+WyMzyJ{eKMP?kVPU%fGbo_~03jCu3!eZD3IGtSBnZYhUU2{u05cK~0w)k*u7p7X03HEB6%o!)(01Sr#Sy^`$R#6y3;^OIkRv0648V`UMgS3|4GV!8)c^rt4k!U8T_Oj74*(4B-~{D>e?STV3kColDgf;S?%+TR0jCiFKz$4YWn=&_5EA^L{)>PU04hQN6afDp6#y(k02ToMAr}BHLI4;5|05XyFed;F9=#m&;wvEyBJ|-1uK*wb1|DD(9%2&W9RU^rLL?yQU?dIz)fA>+I6WXW*5Mfd*AF5@=->?>Kqd`;02Y@396K$XB3?rSE&wSpk03f};O_ze3Jy}?`2hm|;0Xfn1OmAW_EEv#2~@$}3j&)}0&L)>;6Mw^1|i!Ze*pk>05lIgnn3d<J-^`XK@S4}68i@L-N9i14F@c~^`PDWG8Z5cU;+OCAqD`K02(>{E3g0`4L1Nr0QnQUK}#YT01Y5Q?&d)NB^(_<aR4`~7eM_WAdKK4hrt)>8XyGBKt}l>bpScOS^ymY4mAr2ArNkj-~b^ESD+U)xnZ*!4!i*Zq96t&U^%Yy10oqE4j>lR0WN+uARReg073;NKv?^uapD~SybK)<32rEVf&exn0RRKVfLjVNY+)Y^4}l$LL*8qk02T)Tj6gdaa*RU(w*Y;?$^j8iVE%Lg5i$Y*JpdcO1_uBUH3BD~HTw`j-9rihTmV1y3D@Br1mZIS01V#&1}PXl3t<s9{{jG+02n<cI`uIc05=)~AQmG4f1v;*I3y`HabV{-7(wG8k%3hJ0RE$ZvjPGp0@n=R0=fhS4YhzD0&@TlqktDD9t<_$;Hew+K%zi8qC^1)A=Uo{0*?j)?gj$?pA8K?02l=eYXBt60~e1#011xZ=v*NB;C;aeAz%#y01*)cWNZK<XB{J8f<aM1{w#tA2m-eY0{VXn0<H`K<_w{M|I7;lhYSM93wR@-9-^9oDF7%(asbs9oZthJA_OJ?90&gg02VX^06zfxE(M8T9|r(b0E{2uD8MrX(O^9Q1OPSN2l${2GYDK^4mbQN1Q1Id0>%jfng0O-oC^ZP2Lk{84FVtn-39{xqzD4g2Litg{{q7d0?Y#fvHu4G_5}jh3j+Uz0s{OD0*?*f0>}jdr2wD|0{;^N-vt7T2?GD93j)y!0^AFK0+R~@&jD#+Vj5n-0+)acA|b$_p&udowZ;P)fCK;z1ON>YUVt$LtidY8?BFWE(Fb!OD#R(kHEG}j0KW_?7XUp2YT+=J9H1Qpv`GtCqTV11iryhH2mB-l=aQg0Mhvb8e*yp*2WJfy=nk9?@fu+h05qlH7eNn202l!ffWT0p7z7arh>;Q(iYEj~z&W+x`JfX@8*C_g05t3YBH<K^pi}<;;s7G!6$;1}B5_$blwd|6G8aZ67~R147Bm;$fE6<t0Pl_f2OqQG03<tfsQ?Nl8sULG01=Y`at5y(2BhBOB<ugcfENH491k((17M}#4q>Sj55Pbn6(b@SqyXHt|0W0>rXbn>l7ImJ017+;rv(DF{|W-{4FcH=0{^E70<H!E&j{}V=LZ6@NvS^q|B?g(xCH{@1NQ>N0=5CA1OlP|0|Jo<0>BFb|APzyH3Gg20{id=yCK{G0^<w+0u2JN1p*iX|D6m1qXz=@1pfl?2m+7{0+jy=0{RC6kpTifiv<Gj1qAj$_MrRlKLG{;@C^dt{|Ex)1p?9u0{yZC5z`F<y#xY#o&pDOMFNWh0?_|}1_HGS@c{u>02=|efE<ya$sgeV6axShBLD;d?<NHRHSl332LNd`@Mp}SEq-7e3B}-75-<ww02RRj9hqRq3jiZ(f&Bo%;Sw+|PJtW_0E%EcieYjCdJSd><A4qj01$EkZaiTUFcQ*$5ff~p^%M)D5|Ka^01Os?01z+$GbbX;A@2(~03$bGCl~-VH5T9(PJkmc-+%#NMHn|=Edk+80ij?S2tp+q6=4_$BHm#Ud7~Ncs~sB-;v5Eo9SXru+6uxS0^t=i0^t-g?H-+g9uJ?O9~B~WS3&~AAL{@XG$*Fu?;rpTAsQhPFe3KN02&GLVH^NU0LKJE5Ej7pU~(Zp1$KeK9urVNKLsU^0Zj|o;T$0kVh0Z<4x{5200#tDVFw2S05YP40Vg;i`oNpPD4@U##UU}EJuE<@fEz&+GOiV26EPzk0x28;L*#2f1FRnQAo#!l03z=I2n7==1x5fB-g4j%03{oz!5B8uB!L%0V8Wp)AmStde}n)TF)JoIBB<Rf2#ZSq8+(8(08b$s01qO=u^}E!0Dmn2K?nd04FMqEBLx5x4dVbM2iE`<4UJ$Y9Y6*E-6bQy0szB}KpQNakO7;a1OP4uzZc-U<OZNC1TQGTAxjegHK>`P>L3h4{R}`J1SuveL8350p*&204OSo^Ypw(V7Bn#+e*jY=I>c2X5%nf7ff4C0qaXs;01%h&;3pUDD**pH00}_=1pqLeb`t<G0s#1+Sjr>nY2h+j=qCF>GXM>LG5`=i04oNJV0#<{2w_qH3;=b2|11C>AOH^p0QodA|3e^z{}})d`yxb7pc(-<Kt8)4Bn;pbG9_NX9Ijr#7Bn?v0wqHL82>RVCprN101N*YLI5>&05%c*LPlgg038em0M{2aHo<}<XrLH2zbODx01YGc!8cz33^)J~c>p(er~L#{LWuwxAU6OdGtq$$7=R$4OCX^U<0~@&5$+3B0XY%>5#ZSh5#d;&7Bmt601@d0WI~YuAX5e00384Q|1SU{4FEX*03Z_p4*>umc8ehvG>ah>GdqPq*B3P?`avKaAtVDblSBxVKpo>96(Pa}<MliR^+s_)0s!X!{{R71000IC0{^!Q0?YyeLjwQx4Fb;z0`>@B2LS*d0hEFQGa|VIK;rdb5-<h&;V}OO03QH8I~xT3AVC0C0RRL70{_JZ0+t2`0|1i@EBpZmp%F^JWTaGY03H<~=E4F1xj}T~pay^i27>~!2I9fjj13J3pezTx2LOHw!3Y2Y01gC-A^Q_CSYQA&C?Wv<px^<O02?|y0Qm$ALK|QK1SkTu{Q(T8{R9He0|NiH1p>JY0zm@r%>)8~@(Z~?0^flK0^beY<j_C=0vrPC3IdM?{{oW-0y6@k3jYF!2?Cu80>J+W0<i-GnwgpBnVFdeU?;%o1p@!52m-VM0@nt=0<;SP-3Iqy;Qs{zjsgUG6t3S#;d-P$0R*%^_ksZedLR`56FOf901_|(#lba%0IC870;eT60)i9-pcCsc1GK>eLclRLHp;6dJJ&-6@5DfY2LRU)1_1Ga2z8(g3H|}63IGiT01y&I0J}mo)IcOb?qD@{z~2}E1ThwSpaK9bDiMPW00Kh_xPSsetvtbE9SVWM3%uorPXIs_54_-ufgJXwPY?hV4(1{h;RU9^I~xxa1`q%Z_Fxc%s2joks0QE>2Il*(ArS8P#u5Mw7l04|7L^lEViexOHx*$dVF>ihAOqwU1MNEi4gmcjW1vA705%-}y9qD{MFIdMnZOwL01O!>2O0nk6-p#VHwOh92M;F77$jw-IVmO@Cc+zQ93p1dS{q><^}-$i8ekt5YX1lTAOH*?01#?3KsLspApyWaAs21EEwMl$01P1n$RQH|L0}*pK_eriOo0fbevDuw05AYECj(*i9pWM_@_-}&AR5l;;S(_>Dk5kA02?JHD#1NVLk5E)7epEhRVM<b8wA57940O0fO<jcC?965{{RDyAkzc{V*qJE9BSYP4YuoG9|E1B9Rr~tHqi7zi@^5)C_n@PB_9CaKRp`+A&tQR0HXv2Y~gUAa=<PL00{jd^WZ@O05%W+D;EPmVgwFgAOBzj2m+S_1eX8_DG^%y0|?;}Mg0Cj5l8_51`7hF{|o}m3j&J@0{`^{0+I>>#0>ue)d2$I1_JZ{0|KiI0@@84K3Cu%3jicDIsgE`X*MrFKHvd)pfERip`9tBLID6Bt$}@G9yYCE6f$Sw9|qncdmuXi7<^$K4L3%>0YLv>04qBr0AB!0DLOG?3^&0DL<xdnz5)OT0246^0cZ>MAAvd?D8m8(1Oe9qH3kmg0YiW_DJrNU0;r@rsHg%p;G97F`U;zYE)f*~5>+}&06CAs9lZe)y#V@|VFUlb3n~Tx5`=9*FeL&4fDB?0fyu!VTQCE5AQU?Ug&tA_p2Fk+00Rfo0S&<B{Q<8*gA4+X2m<S&1L43N4WSY+0^DZdJm($@H(~$<0ILiIX66k)!3A4^62mbE<fLK*FrmZXIupYHGfg3$fzhB!U<LyJ#{~j>0`3d~|JDWq$pQl01+w5^8$2MY1Ofol;1Gfw;RKICbHOKI<4bOYIJzTZ9Ol6iFa-7i0w9wjwP78_gWv<>1_`b{A>{1=39$wVvnPZC00#dA0<a4L;0XesPXgcr6Ys!j!3X~V5D@?-05xgv03kOLZNLEl9^U%}QUDAl2A}{P-b%m|05?DR;35Dw2?!Odpe8g{0BRuh0n#KUCqp1Q0RaAW;0FK|GXwy0+W;BmfioY7Ar3eE!J_+u1_%Pi2?GDW3j)yx0*wg%IsxMZ0`CF>$omTrqaXnQ7XUo_1One>82}3(LEid62LKc@D}g07zSJZa06qi+sl*?-1z`eV!4xtFnc*r;BE8@XGGe8=fdKxXHvj_z4`ek64PsMa3=Lv7V;cjZf|})}0Vl%t2SEk~PhtN90>j?|0*V0wP=NIZy$J}2JpdX86rlr;06hR30U#h@As{r|i-VTH06#vI!~p>N3>1T5{RjfZ1HS^~3j&}5TH&<s0|MI&3jxXj0{_<p0{smF?*{(@-V6eg4FdD;3<87=H(}rd0(Y_mUxwcR9XV}4{%@c)046>mG9UW@fZd<~024bS?kRvM1OTaE1ppy*{{R+22PK9b4K-q5{~HWB02%-W1%Ch>00#j8B8<WR7&Zw2DF7`~#MwY!03EM_u0cW|1{B`y;3Pl*7S|vaHf;*+01q}s;t@9jA=@_#??4bYNg@(AdjKQhfGrIGJL|xH24D;TtN=17OCYN#D+b~Yav&fE;0y4VV9?-UBGtnrIsg&B0NwyL5+&)NTE74&GZHEu!eBdnaR-1o05lO7QAGPGJo^AH04W{-|M>qq2>>2C!utRZc_9b@4*(M14FDE%02hD&0R1r_;T0?$01q}?4ruiu6974Xqa_W*s|^4R**CX92=$;6e+&Q?Dgh!a8DPs7AsJ#3%>f`_SOC8}GXNL>3kwD&=4{|14;O)IVN?Jle;OwMMgSKNX@Xw?03i(k2^KLdpw$a9KoAG65C^0p67Dd-7&a65pbr2h?#ZAA03I;_2mln{01^}c7CFEK0RP+oA_D*~04V)-0)RIJ03${K+ZF?PAp8Gw;tL9xQ)E)0)*#ahP+`~rvYiFlfu02&)}K$V4X$`VA_M@WU=`Ou2I~MFOd|+PAsqk?{zc$503|*qIv+|w>;^&SJAVWiAO{>m^$3-~BjKSLHw6HHC;%`lC=MtqA(aUr0t(s!A=&^zfG*Df1pqs_V9bCF0{^lG0<-}Foecj1pb7%_0|KD`2Lh4@0@w%w|EUcE@dpB?1pfkz4IUr>D;#$jGA3Fe5i$WaApS&v002|~9~L6!lfXU$+d%^X7XUr~0|EdN01hDw`v4}pL0bSo2^h2;V549JnE*cnf1)%01^`_EEEqoxT^Ib|HzN+L;2#)a>lHKh!5pK27XUwV0|WPg7l9Eq3ip7gD?2F&B&vW5oB|Ax@u8bQ@gV?U0}6|r0RpoJ3>$$QK;Z=$p}&0%96`1R0^I`}A^*h-1e%$dnVHv_**_lODc<1~0P7Pv^dSMwWfcGv`~m>?0iys13qU9J2E1e=+QFIt9v3YpvBDBD_`x0Q0RAB9KW<<N1p@d$6FXS<06as600l7s3%e^pFQ7dD9HXEXyEFtFASya2D4_&>2Bjbx1swni@dCFV3^vK26aWSz2yg>n1~Ka3Bta7~3jHBz3-|#B;tCF+5;~qhGcXMLf(c<Q0N-TzK=lXCVTvGt3<AUp{{pxH0@eWnHR8?S9XUZAfn^{A0632TF*Y{tf!X02;5opCfcYQ<V^_dr;RIs>0R1Pb00jU*1^_ni9{@i)yCDGp8^+IqCn8T_0z%G$1`16AXyAzp5JV5)H)$a|i3Ski(E$?fU<@J06fy!s0sleg;S2$<2q_pl+aVNYKy_aLG7UZeMZpZVfUqt=j^WRsNWl^?VL=?$Wnmo)D1k5&KnVbkKneghZ6E?7Aw~hW00RQ=!K?*XfE;A)g(TzwzF-p}p$irPzvu%3(gp?}#sWV8VE_yUD?ft!;cpNC7zJ!$JsfOcKKlX%1Okr;*1`M0H{=Qp_dp&%T|j-I{Wljt0ssvH01-C}03_{W9Rh0MtwG<w01^T~x5OkhJY+zHp&$YP5d3912yX)h0yQUrj{#Zg*SS9l^??m*Ap!u64_W{*13={TK!kx3t1ty?;1wi?CC;E#?*RY=1|h+B0<NzN0?-D3qYwI`7dHSr1bbl&AQnJD<5U+Q3?UsfK@(r#0$d<ICqWzl9SSj=AQj`>CLlJU6EOyLz%wZPL4zcM0aXA12pInTLHY^;;0FSaUj_nl0_m;53PIsd`3VBDRKgL3?sjDV0{#L5=nDe={|5r#2?Fl~0w0?K0xn1tVs`-~;HbC3UqNyq9&#WEoxltz9l&!Sc7Y+Epg~mN1W8IIp$PT>4cA}@p$R3R-5du(3IGiyAQAx83z}dfVB|IKU>E=+1Tp+U>49TH4BCJKL3Ii@Kq|Qa90@RIK-!`~44eQP4SZld1Cb7JVk!WbArf<d5@1HSpr9;355W>J5B$IiLjWK%fYkt1U@u@0xByEMFz3M>0s{pj5^ey$2LM4605=68H#X)#5fn&3GY&Zbq(HS5q(T--fHxEZAc^k)9wj^5;57g!uRkL*A5CC21pyHs03#9r8x^D!OFZCT2LKi{47uSXx!|f)!yFN-0vtdgxS&M$7XUf+KokIV0CzVNJpJGdGZ_8hZ4R?w03R436*Cwj`~m<|AzlDL`Tqp=PD2Y0>;cRR0^I)u0;&rF$^ioZiv|MM1On>;?*iEZ0`94v1un4dpY4EjfZIR-6JCHQzW^~PA`K&jKm=a^4g>%Z^?)K+1n_*JjbP?Mia~+^HzvMDAqM~$HV4mO8{G)bpe;Qs&tzW!_bE9i2*3#d4GPNu5zu8atHSrF0RY`3@L?J_1@}r0HpLD1M?S(ph~U_P6EXD+yCDZHBR>Ex1$;N4;eb>CAQmIy;Qt;809*h+2?-SBK!gAX8bA*D0*rx_q4N2FD}_M$fdK&o0`92c&;<mPh=u?quRII@DY9TZlLP>_00j-6L4^*kp|$M>eL?OBaG{_K0{{OA0>}#j(+T|oav-?_9vlE1!wE6-!21J$;C(?7Fr;e%QDYr@MPvjzmBIzL03ipCp%gM|VG~<134b9eB0|6l)c{6SzzjEGqUmFV1`AC<bZo*1tqfow6EO`4qNO7Ut_!7NwqgQ`ArAH%q_+zgp`Zf-sBZ%T$O4O@%>+roea?%*gbM-!9wi8nd?-T$n#PKu1<h%Qg9aY}K?eXf>_O1MjNyKWg9!i(2>=k%L_G~5;2#M95Bj0=qy06DAR7xg02%<R1_BvC22i6R96=ZNH4Ok&;4CH$Cpv1tD8E4+01b5D*1)L{_#-{wFN7dE%m4uK0Kb6CKsey01Oml{3pt|<p$MJeG2u4I6T<*BgTdg#y1?nd5-_m9fjPm(LElCM1LEN@dUHSq*Ch)8B{VzWiqOFVnBowvA-<vA;t>5AxlIKEs0aey`3tz=c);BY0*DFw0^Q1@#R~+QnZKEtnVHEyz9i$l2-zSm0=x`>0h`?d1H`#MOj(E!0D~6;Kf=2rNPxQ`)4&m*2LKc@21J5)As0Oe1dIs)4h4TofFKUIV+Ar7vLLu&X`wZtUavtN01GlTq75~o`g_9$x?l$o02~b55FmNO9uYU6z$s4Ds=#g_4iDlFhaeUZ_U&N|Hnac*074P-05?CO7Do~Q4iavW1~>o@!=NDw3W3!(L?RLnVi80l4*;zsNueD%HvkQ~;0VmQz>mWn5)i-?unGY0A^-;s5+ExH0RI{X03JLQ0D`{&K`sjb7LVZ;_DG>I07#%40QCR;JC2|>7XVlQJ5@c`U<--lGrB-P2qFI_2>=xb02w##2q8Qv1_VF`03fXqx&a~+5a2sWAyoGOBpRZj695tuzW^2!06G=VpgaEn4>th$|26^J03srR7&an-8yS!yfd|09!4Lo@;((UH0KWhT2LkO0|K^On1HM7y2O1&fph4vVY$F5l!1*Ht01bBp01$PI696+KqyGf}3<dxY9s&O~1PlNt01Y1h6954y05dBgYYif8;RW)b1_A4VZxaAH85IH!I{g6uH3|SUCk+5A%K$Gy0S)cIxL_18UjQ^MA^_Lm1?%AGZ^Q&ZCtxnXz&Zc{KUDz%1qK2Y;MO4fn+javn*stZ6Yj5q696_00e1i!>jgXHKqPr#2LKWOG6Ddj00;^}lPCw4V$lFR|ALKXf<FK@BLM&fT!M1J*&j%tdLk15_2N_jw;mNC{Xh}{o`(Sbo`DSl&<g@40{gBCXTj<M0?`Nm0>uXcpA7<@?*Rgd2fBf{0RnH^2pkP6pdSK~1Li8B9So8PBmxHj72P!~KmZyALm)vv&j1+!3W{KBp%O5S2mQb!I*<U8;hw=AOp@XufB+l>C88k-Jz*gWmP6kH4j|Wo3c(1W!L=U21P5h63;<4`Hr~|$I~xQcR6!&Fi~j#C!T^zAEMOX-pIr^*AQ3SEY=Ht3zym!mTH&x@{UDlvC4iV{e*gdp3IeSLzCr)Q3<A>&0^tJx0=NwV{S5-T{{jN<1_J#E9N%#OH5EQNpaB4X3<3ZU0RSG`;j0uei@_bVV+uxL5bQX>GC&PAr6C>=H+uldePA0102#Bv@&aWDqCk-V6$=0;eK>-^F90e5ELcGLE&(Ky;2i)DHVXd$T>vZ?LJ=5F`hY_X4M1X1;0e8<{Ws?#0RSWk02JH>b#~w?0RJL@09Drk00#J?7Cj+?2mU<4t_%X^2LhUC`9k-=-vGJa01GO@A|Dq3JOl!2AWbHqK&d%TYm}h{mn1~kAOkM+U_Jx{6r>%i<p&4kt|bQz1_uIMLofg{`zIo0;0OQ@2>{Bp;tHhV3u2)jV+a5NA?5(MK?6dsBRNFaL`Y%nA_RgJGX#MYG7RQPAu1!Ff=nSE4L8&dsMw+cB!L<KLFozq0=x|Z)CU5O&jtdy3??V%pcVrEfd~Th0|I#h|BDF%?F<6Q2mb=s3IeYK0@Zy7*`c5e0{;kSp%=ajM5KTPAAtX%(EuLOzyJv`0+RvJ0Gfe+4*(oDBLD*%0U88k1bE;HF)CqQ0iOX@W?>Ek(RT(dpepNP3Jc%|$|49QAvHt-CCULPY+@w9H9-d-VhA-wEJ!U#i{cyu#{f0RA@_l`3?(8B6+jIu`GF3)f?*HWz!ftP0H73$GZByC5*uQ@;Xh;(?w;Tj01cSn0RSJx6$RoJ1>xvmJisa<g3=-wwLvk25&?r^55fm40RS{Y3=v^J#NZEMN)Vzf5V9E%s(S_joxpbl4+1x0w+jMYBm1ZWJICDw0#O3**9ii;ID)SO8H}<bkHG=}#|$`tejyXSejo<`5-<h300wBtLQdd3;UU&wK?l%ds5e2-VK~DH^5GCu#tB~lAPN8voIwjv!1p}^3|xd406hcNfFT?X0>TfrsR01{1O*twrUU}T3&M9G3l%7H@4!Ty;~4<w3m!nl0G_S^01EdO0+@qf1p@E^{{rC*0<8lA<-Y;~M*_kGTEU3_3<8S+0^11!+qMl}A-fG+q>2mw0)znqrvU<?p92E)1tqFMj6eXb9naz&0#PCZ-rxl101gCK%I9Ds4FF%O01Yz)LLvol!0A8cK*+!|Qo%n32(m>Y2?FALAr&(uVL#Ue3;=2%2P7k50G|sAD*z4%B!OWMa(Ti9mO)a16EP7^0QV6y5(a=D2?qdo88;J902nqD20+&rH5E!gIZ8oP0JkC-CCq>{EB8VH{$&9c0F?k9Iz00L1cIXW!3h-t!}SRufyN|)rU(Lt-3@+WiV6ZpfZYZE0)hzwoD2fs{|N%)3<P@=uK!2jdZa%DDO~@L!u2T3KLVZc1BHPq;3uGq0zDPi02DggfdQPr0s#Dbq1{0Q0QCSBD``FXV4EQZPaq5;r$G5Lyuhd+H2@3%7)t;JXCMN8A_7VUfRX;ip(6<Z5(fYle>4gJumBV)Xdv4gG#>yuJpmvF0RJBkHvm)sAQsIdyr3WnDIf&t4FG>A05L5m4<-abvlk<lq!b`2J&V9S*8my@ui*@hKqWm+(Et?y6&gUSp$(6rw+#Rjj36}*4S^B<4S+cSEfE#~LVo}c03Z+mEe}8|5H){d5r1GCe_-%|PYVDgK-xf!;|(Cd&ms~45JG`A;S@4W6t$ug01YRBp$F6;ogSXS6fz0{L94+XDv5*@qQwi+ARQh+fZ+EgAp&P(;|l_V{{aG%0|KW70{_GU0-Fi~lMVh^L7M{tbONOa{{s090;CB7_WcPuVc-J-!vO;SmkR=t0|NRB{{rv=0>BIc^8W||%nJgy2m=3}2?D4E0{j900^17$=>`JzM*)Tbej(_Bgkb_MAiFddE+QQZH?v?P$b|uk4u}9Lw*XE-0RYPz1|t9*1)yO;4hVK2;S(`5K@u<uMt~&?s$meSV3A=JXyV)f^_M*$CrV%q01XSgCqrx@6fzC~10zP401*#Az%#nR3Sa<#3=IGf696;;!T;O<96bOp03vq*03K$+6fzP-;K?=x0SurIv?K$74FKO#01hMsvH=|q{{R3v04@s=0BQ>05dMM<alj%24@pfE4@3w6z~B;!6%vO%77~XS01OlopU=Tn77~XP5|kGbf+1$$|3Mi5HUR)28me4^8(rZL2f!U*00iFv8~{feO#vD>zZ(E^03I7-U^d+(8z43m83bVyH~j$ep-UP76bArX9y|nLBC7;pC<I{FIv5=UVHX5p9svJO8UPpv03tyC2;nBv0ssIuEOrRsJ{-b<9UC`a;Qt>0EFb_l0RW9M5g{l>5h3AVvOppJ2q7E*SsDN$2iE{BN(dn^5g|x6t`Q(eCMyh~B@rWCe;NQL2LLcm1Yzwo5g|xA6`)KiFZvN7DG?)K8UQK>*8nt92;n#pAxJ*%8X!<EGZmpNHvs<-05=~1UjRwFSw{e%M^{AwU`4xCLjoW}Q$YgYLAy~u1E4=oJp^DqyG=U<AUjJr1>iZmNjC<dH%B!GU^Tl%GYB9vLoo>8F}p!837{`OEec>QyFDulAS*j53*af+IwyR<2{7WJ9t(9gbzmIlp%O3z0YRX>f!_gTAOfi2!wz;psDJ+e096411>R!+`wRlO4FaYNF9Pff4cS8hk74d%Zx8?&0t~@2142aXi6Ew<B{rs@5C9fQ1f$}MAq9eB0z@f-W4;Uk?hFFE26^Gz9|Z!*0t|O(_5=bbTx38PffO<XbYTsd0S5^%1(^XHApK#+q8B0m2@e9J4FdKA?*g3$0>=Qf4FdnU3j&V@0^bP#0^J4z;R*uy{|N%W2Lj0o0^bt?q5@y}VhjOa1t}Oh0;=IOzaZ*}05ZM-E!dzM2Me<RCWm3gpfm$mfdoGQH~=&`Id5VEW_J=Z1>&F*GzJDhzZ?h)04O=Gz!|Rq4Iw~T0u1bcHNOBTKO;0B%s>t}%s>iYcL5YN0|^8MB5n;}Isg$xAQ}j@LH{%f03`r11w48^AOgccJpddDwuANsgd{x$fUN){GMyL}pdA1U44}Ng4o02fCOZuP`=ATw8V?|!TL3@`7_$HX;{}BP0pkW4VkjXUVu}G1ZvUVH04lkFA3PF(2{-<L4C4&QK@8>+p%!5EI0MEF1I`iv4<nZg04E414g^A*!5_{QAOZj<umA(X5CH8P17Qp`9-%S?J*z@5$UrDZWEu|wG{Fau0q8&qAoODk1SB)V7yu7q1S0H#6GJCBs8N77LD9h~D*zl1!3}*j3_&vmK0`0Rpgky70X+a42oYfb<8>|G;sW2GKLiEfVCO&t1|dRYU;qFE{S4W}k^};{1p@ox1JYrt2Li1O?*ius0^DG*1_B501{%@tw_uk6(dlzZzXbp(04O`nAQslq;~WM`K`<Uc91Hh203*;~CkX&GDt90X0|E<sK?wgLR)K1I00~lLBv^qL0DQrF0sy?>H1q=i@xc6VLU<qw0?Gjb{eK7o{S5-w1be~%?*;;(0s_Pg{{qzk0^STJ62AZpAPWE_ECEh$06joHpFt5Ze?i+MH%$TxG5$gfH@eWE5^~`YF$56dJC=VU6$Sr5CP4rM#|WOr;0*@=5!&GEfff5Q3AiB)IRF{}y#~Ah00$5N2BIYXUqBlL0FD3(B+U@=;3+usfDl9(0QV3iMbE&j05T|c`rs%lO&||83eo_}AQAilDM8}~Ko0=s1!DsM1#>*XP5?gtMMD54E&wSi`g8z0o?{OL0LV`NXKlf&Ljtl2zXIk70*wp;CItTg05m4`YYao@0)`F&W&(f!qLg16Z9)Q$1t0(cWdEcE0)q<zjsx!kqXsV;-~j+Te*g(Q00jUrjbPmZHy{%+1Ja-b0R9~SC{h3nCIkR~9{@f)90eeL;Hwn|1+xcJzyJlW3C;_13IH3BKnrUV0ADl>%9=Y7U_B9RKDA&B022T<1HlGvCrv^R3}FUv4F+KY!4d{;^-Z7*^9~H*1HlaI%FAO9AmKY8;W5Gl0*-9Kj12~~La)G1fH2<xG$<kf+F${dzW^ILJOBi~!U6wP009IJ0=EnQ0{RL9paTM^?*jsi3cg{$2m<?*2f+cR1Omki{{ou{0-*x};QIwGsDWqz1rt1r7bU)6BU*tBh`+!vEdy<U1OPw45Yb>u!TQVLA-P~d1pqc34*&@;29W`IBW<Btp+^h{00p74VF|1Vx*&5F1@fW><pKaC@x!VOp$P#&1b@Ln=U^7Dd?*G09NYpBo1h1u03QSZ4|?H!10mLcpg{}~%LoVH3=G^5;?{uy02@0&G!3NgfPw)H)}jKS2N8k}>XE`WtiT!ap#cCB*CGOonji|8p@RYc0+Ry*rv(DUe*yxV3IdZ2CxQQ)0|K240+a*)0`dU@bOQMe{{q7S0+Is)XTJim1OnX&`GL3p2m%ZO^#KCF?+gNm12`iBqX+*2&H@7G0|K`n3<A^yaQz}1Acx=|7XUm20^&f90v03b9{mMAK?R$^cmP1;C1EE)90p*BArA-uPZ0+I6o}wM0SYysFAD$;0|H?akw8Wul?S*Y3@l(BlmP;v6T1L4Amcs+4Fc%{KL8CZ7XUuJ00!Wc1%&}X3&4U72uTYD57Yvz1!E8eauEe`5&-=nZh%4*05=2x{}lj6761<i0QVU;7yQ66Dku&8Db+z30ABzuKHV$;pe#Hp0H7*6wJ55h8BbvhHV6P3{{TW805=@~3h6NdWf(vljA9)CF#7;AWq=<5KRX;#1R)^_TmUj4As;Ft?&+Wb03x`d7&ZjH%K#TO3;>rAKq|igQ~)0qBH<zpj{rRY8C&2hfhE8zq$R`LBObaTF)I%-A{5;+3BeOF4Ktt~0PhVG01=%bLm&X(4FLcl9>4(*H{P#+6#z&UHvt<ttrub-B@4qL6axVv-vCS&02N-KJr{ofVE`BqH~<uZyCOgep&>sG6o4b!LNv(X7&oUNA|mc2AT&fWB;YbaFpedlFhDLR|0n1r06e-S0RV}>00|#q1f~B00+$K`^b7*;ybJ=zx}XOF!T${cTLPO40;RtT0^<S#mtw#P_G96t1Y_aX1_IsZ4FWEgA&vm>2Lk)v1ZN?80*(p-|K$M!<OT$qnSYs?nVGpiQzxUN90B7%TA_}i0+FFUr0hU+AOiy7i~tDJ;0z}P01(L_hhZIoz<&Y%KnMUfLI4Q>-x~@5C_?XG9SrvXDnf*S9}WO4uMhwn5AFaYhaxV11b`hm0RSElJ7CuoG7&?95@O*503UY%8U#8HVTEH6Z1kj|pP)7VK(GK0EB1sS792p~1rY!v=M?}Pm%$f~MgSDLn!q0oVHGnI+5j0{6pbJZGZj`r4visoKc2xBOyCkQ7aT(RkHHaHU<Cj`1^{<91^^r;7yvfYKyY1x86b0D7$Fle8V6#(5&%X35gVDnGX4qi^8a1{K=l7}{r{;z2B8u#9I!zt9iF03K^_Vs91!IzfW;r7W-YS-C8P~u6EXfJq8k7r00;#WawVZNA|N9GAprCX;LRO40u48Af|)@JA@>3RC#k~(0|Lf>2?7QJrVIw$LnQ$%fF;G@jo|__A{;>V1G1ngumJ)92owJTOak!>0w4na-39``3<Asp{{r6w0^SA!_x}t6(Fg+P1Oor|3j(SL0;C9k0uutc1p?9DVE+dKHB<)x5i@-OsNfAF3jie(<GUp_$zT!y4H3X9{y0E1Bn<$;03Dk$0wDkx1Bl^szy@;w9v2`6M>hZt1HlT_K?(!L0+L_~paWzy01*HKb;_Xz^#~413Tx|tstR@r2KWmDcnk*dIO-eY4GM0?9{@oD0IwPX05Ko|4<qd|Sn}XdAansGIP_q~Nx=FA<0(<V5i}71eE$Fj5gGszH~^<JI5_O0F#tVhKug~M1wax2z+oT){;6O=2Lb?}050!CDHu5cq7ncq-vBotGb(1m9TWbxU^FQr05$*tl>%V^4f7!_H)N8*0s902Lx2P504F>B0&KwJ03SRr8{HIq0ssJ2<zNQ_|F{7H*9`)t0{a3F@PVcT0*np+8WI2yA`1X0c2>hEIE0`R06F17pN9ZI8WT@~!{J5$0suRe02@9$`v3$o067Z)COG;R;6kpTAp`&|UvB^?KrN~PKP-A7OEm?0ArKTJx!?xJB25R*fH*7|0~mk-0AQ5^0N@1yU<3<DtU(3u4iEyjSD*?4=Klf$j|KwV3<7`R3<8A;0yP(*Uxy0<%?ubJ52-`%1T!-;06@b(KGJ$10e~V|0Tx*S2{5??5n-ib1pp1DU=qgw3n7;v9swC469D-${{e;o1^^ZT4edIaAPpm#B@qA^e*l^QAsZ(EUZL9zGYMi2H`ZVW0RIpN022}b4kWxGKz4x@01`f;07umI;HlsUHGwKMfdB(&mY|z}0)PhkU^fn>K;KjVAQvMDfCd2l5CUKn0Wu^LJ9!8Lfe|5C06$2cAioGP017WaxPT%4DPTnk06H-M5_>C0vEW|-FF!3|cP%|DE+8vADK6j_DLN;Yq6{5kF5?@4w-o>t5`ZQ=O+Yd401Yog3B*VW0KYvk02M1r!eCzw0OBw`DzgF!!m|RN!M?|!2LKf_4}gIXc%lIVB&nd?|K|TtV*3RLHsR?70;mYT0<8oBuM0MT<dX&nB0w_%6pSDyz%lyuVG=VS#Q+;6GHxqi0RSI|K?yMW0KWh~J{trfq+<#F2&7?|0Rqem0{^ZA0-yo{#sz-@t_lLt3=us-uNMG31mfa4;^G~43gHtmG@%>}Hr@dD1ppu{U>yJpGVKSrAq_QB;2R7%UjP~a1_Hgn2S5RL0RSQq!5B6OnLyt#Ehh~qbRsSQ>nSqAz&mGP0{{vCBLdL}0`mw0f2Rimkq83#5&-`S0`~#}i2(xtfCU2E4FakG{{n~z0<{YQqwNM2VekcP0j~uD|LFq)_zVJ^2LA%Q2?F^B0<8Z50+$E^xe5aR@CpLJ2?B!*{{o*10>=yjlK%n%r3M1a0|LL;2~Gh3ASFQ-@ifKZOTtw}_y96B-X|dzGz0)dpe_J^761hh02l=Uf#Wd%;a~?qZ9x_^2eJd<G917I;1>iL;3(3!AqWKq2A~N9K{Ei?8vq7*U`NBC5CE$e3I!k`ykQFm;XtY(;06Mq2M6FL0-+3a0;UvZ4GzE$B0|F;{x{$dHvn7!Knzg}kDwSvE1(bZU>NnFUj_gi5jE_94Wa-~1^^omRL2iM5)^=?3k-o17ex<26c<1cN&=x39AOPM;S|6Y8UU381z{H-Aux1c6u}tU0-y*8AQu?}!2SPH96%Z*r5K?b27vhjp;a6LsT~PG^#Y+D0;yFW3;^*0p&$aOAr8Rx?FC^XE&=NQ7694~!6OlX>HkEa009331Ooj80;mK30>}aa=?Mt|a{wFv!jEDC01WGZ@`M03abO7{K?49bI~@R%#{vK?wPBCo_f-G@Xu$~ruLJ)A-30_vxE_W7D{Qtv1jF?x|6GsqR6qpmQUACe1rNDE0+V+P2MsNO0ss$cqyItx1OOWa04Ta2fCjKY9}G7tKo;t1f;?)518ATL0*gZn187L0AsAp4;16yg`-Tc_0q_9==?ng_<e&ort_%XTaRM7*vH-_o0!JbUNdFQ53?K^tBsqd{D+s3`uAp_md?1Ix2X3?A6fy{z03|%lfV$@32?8J!F$w}8B*8mS;DKTVDOG^^VGA;ro1zUj=mk6H0JtF>?*JVNG2Gx606tp;3f~|d4GIDd<>3D_C?WtK06#m)9Etz~!4KiWu|fv`<rIQ|0)AlUfdB;*J|5)k3j(GL9c0izJG2AO;i?M)AOJeRue=Qc`XgmW&!n3FnVFfHnYlkRNH{^zD8ZmNlEa@t6P|$o5C9eg0FD3#>mCaqz#|{Q8~_|U2{6lm7XUrP;E}_f93(*!FbEkz2O=`k*#imL1Ps9lx*!Y+YXA_=AT<nP917mzg$pBuBlDpVU;?ENAPh{zA_$8O00@Lqp$$_Z4%*@rG7c2P8bR8i+yT;Azzqwf8si*$ArdfM5H4UG4FDKH5d;EiAYc;kq7!-m6%?-_^$UH0`((om3IZDRxj`$V+xZ{_0`Lg`0@nlr$p!+-e*qM605ugp>_G7WW<o>&x}_Ze3Nh6MxZw=A;tROq3;@3z00sd7A)f&kYc&Ty;33T+6*qxl-5pC|6*>y!KrldEE&!k|KP)Jr5RYMhE&wk8Dgi7;Ao9InHse5VV+RKUANK;m3(o<p1Om_8&4Aiq2MHldAV32105<!85#bav1OP8R02>J6AqAcRuLVyN05}r-Ku(}P*u?&Mzy$*C3<A0ce%Qg#2?EIi3`EPi*P|TdArdeGSU?^i3`M43)_{cJ9|0RE!i3_rId!50<Koc-<Kd|`R-&5-QlX3u<LM|!e<c7d135n~ZDCN#p>^Qo!Ek^DW?}}bAn7S&Vrqj0I-ouT2ApbvcHt8-2x^RHVhZ^lC4ms5$qWK)0%3#oLObS%020H+3umD11ZCr?KRsXq{RkNZ{UH5-;6FeCjG(8*?E-B;)CX^YxeNlofCmEC2vTeBJ<MNYL;(^o{=%(*764Z*F(Qt@2xZ_5S>U3KKnQ{&{h&x73P>#pDuh4=aRUojq6~zjo1pIp02ns#;SeSZ;{YhPL3`kf!4fbIie8}xDFHa&pxnR=VHmqM4}0JVBM*DvC_Ouyzz_fx5N3p%fOQd*pdu|H6*v*$0ND{mAm+dmH|M}EB{wP!AZx@ZJn7?Rf<**qVG}aq>0k$g6bG5vJC0ydpfwd}Ko$V+5f%Uy7epZd7XJW77XUjQ01lHi7+|8QLkRd_1jILdlHg&05diA{It9Y@8U@1}1<D)%5gE)1qJqO992VuB!y*}e{sJ8U69765VL-1U01XQBfh{6|A|96k00|5+FrapzdqMvfH68#r0X+scMgvE4W)}cUBGp41(FD~)2LNNCIH2T#?*RY=1Wv*O0zmHqfd~cBC?Nm?{{TS*05>QAFwZC>4kJ0D+ky%e_Ija(2iZZx2m+q}0Rqqq0>lgg-;V+U&H+&b@ISu4;mivH><j`V0GB`l{NTm8`+&p%1P=m?4L9Ftl!)L@md95%07SMx18RZ<sbXB_gs;N}03xr#730AALf{OW;tBvD00-QTfXHDKG701W3?jDdz&HS}ffhF20VDp);Tbmx09XJ*<w#243;Ch(Ks^8y{E1-)B@h4?3jjD*05Uh|AtzBm3^f9-<-ry=4r0L(qTwOBU&I{)!4okL=;9>&W}=0G0{|ir01#@P;Su>l671nBA`aoBG85E6^dRv;1o1%>%JD)K@j@f<My=o*0RQy=I{*V!0RXcF1~P=}z?B2)V+}-hVCI7YY#~}f7oY=5An7+lAlU&ieW4!=Haz{|mt_+GH4aVSCqX<I;iTpO00|QeWRhTf_u%<p&I1CS2KWPPK!!jk&H=SSg$qC?b^!zkKmsHXKq&pM((Yp&)x}l81=!#Q0RIgJ01y%Y3n5bJA`4OC>VP_i;vLrka}zOJU<3dH04V8!R*69pF!ezk=K>muAo~gc2fz;p02DE?4C(?yg2TW727Q4I+&RHL0T?z8K)^vaj{q6~3RD0IEta7nZbu;(H4t>56*f3wTNO9;!4)_+p&#Qyiy{CtKrE<W;zMx5h5ZL`&;S4p2m-C~2KnmwKlwKq01qU+MLK{#05S!KU?YDE08{`Z8YdND?Kmi)03Oic6*~y-`XDhuFZ$pwKP^81TmVB24UmBPH1i1w6Ty7ov<U*E?E_7ri45^Ui3S3@HxDNvAp!s^A_KT9Fj&F1Vi-0CD<Lvs#6Svc0hgc=VHY*O0jm`@HK83Rf+r_|G1$`}l*5=~%LONc7XbG>1Ok#J000LNzXJFN0*nk`LGA4W_`xp%RAZ|G0`Kht0@N2mv;zYF+YAEr1OlxJ|0{6-H5EPp@c#fcG64YU01LxEKpx<a$V|lhgCjZM$AJ5Y;UM_Ji{K>yE-wT*J})MKCfHyF3;7BC<^>Ed04f12zHT5e05c{dTObOb01OHM5TM}j0x@|DQv!rx3;-YpDnYjsF%8_{3Ned<4DB`VAR7ysq6GjP8vq79U?N2LAmCt5qPa6)VVc1bFc4tD0se-<A^<f2CO;snG9I|$I)^|p?tnV~00LD400smC^X&<Tp(MbG2@MB(01+a90RSHYTS4111EJtPE#80!PCo!XK|cT{$KV6?-8}>25i<nWU=lR{1OUqb7!fZUnHbl=lt2g+GK4h%|6K_*p`;7~h=8cUp#K5_=?Mb74Fdnv2Lg`<0=W!70)PhsF9J89I^a$dfQbn~yks&%B>jO}xyAyq;4n9?fhe5e_yc2z0udo~05c9h_*%dNX`N*#05K>cLk%MXqEVqAV2EG{jlfS02mlekfXYE3kD#wY2>>_HAqwkZ3{w6j3wFQ+%M1j=4Ft;14gd`c1j73x9t-NeA`kl@Hv1z91{5a$gd{XMAmTs{0p;3Zl22w3n*bICExJJisuA)7tv(53sUZ<E1OWfz03bau92EfH82}3)LEs=i0R1k5fgc9|xd0q*1u+0YYM=)b!9c#OAO`>!H4k)PLH`F704e}CATzTo6YU~)K>z^F=9z5)%^{5iZb8uur9j~w&FHxd@1V><6fy=Lv%oMYBMvUX%cj^M?F-l;(*$=R=>-D&s0cwJ#Q_5H4F3YC0Rk=pg$#upWMBb@0Dob1h}vKUQe)x<E~GZ#IVi#&$bo$nA3z5H6EOvNpo13&1q#oBJ%}%1BY+=0Kt2Eq046nLARXZn=3ogk!~$Rn4MITU{Nbf03c(9VA|nC>qe8sT3Ia6=@5?`f90OkXpfo5V0PbJ`>}T%^05l^(U;$MC=K%;0mt<sMb^^-Z0RoE#0>NPG0e1q~0+*rQ3<9u#`_l`Y!JY*o=m66vJFB7EU@~?g6EbxJ`ynv<As!1ilEJ+}A%GPC6gnWIf~NpBCA2|2K?fIr8t%ZMEIcZ~U@AH&?!q7_I3^$f2>=c>lAtF63z+~O3|3;~0hb;L0G_}Fp26?HGWaBfm%s!;5-<$_J^KI~>7g?X06zfjEziLo2G77B6(YK#0SU~&J_rc&;SMH*fiMr5!1LoEgu^HUzn}#I>IDSy0U&n*01$NHBMl_RfcHKG1HR<~01ik00_y_;+zA5oe+dHA3j+KKM{57H0s_$q0-OQ=0<;SP-39`b{{#Za3j&e{0{z%aAP55Q3j*Z-3<4eky$b@ge*pr`4FZe=+u`q?1_JRd;0FSp_W=T`qM!u=+Xw#w`U(R62m<N<4FdK90-_26|L*|;-v|P`1pfkX0!ad`2?GE91Om<j0=5Odmf@WS0{#qQfyMs|1e%$dnVFgYxjzCE0<QxC|J?-w;0XfY1AhYk1p=!J1fpR6qQKxk0;>%I-TwpvQ3BBh0*L<#1h^iB>ruG>zCQw_2n5Z{|IEzH%-lZ$HEa6;>;w@;Kn*ueLB9h4DF7-vRUjDqP5`dr3;+fTE<XSS0Kotq{(z%^*#<U3JV6);LO=^L%Ikq12cQUJfIEN^3;O^io8t-qLkj@sI2`~4M`I%l01kT$00hSj07DG~!$8p?2_Xc*2%v4GL}L%l;max_4k8e8Ar2r$08<kMXhO=s5z4|6KEXQ<H<5r2Awi)a8sPO0Re>jlp;Q1M7X2g6Krb^Q02BcKBLEcuC>8)WrxO4*rNIec7w!NrmZ!is8OtC7QNY$=7|M0PC5~es3~LU66aZg$02~H9c*G^Fqq`jh20=Ce4D}%eA^~AR4M44;8h}Nm04ZVp87d+g01W^e0RJKe01*cO6*KJ|et;PrY~Tzt9_k!H4)THx@`4foCsP0jwn8caANipT(_x7%U%?I{Kk1+Z66_?czW^sT7yux6zz^LwHenwUH<BP40RIyj02d1YDo_6a4*(bd1~VAz02&wJJORK703Y=_q97I-;Yk1=0PjWs7a7`sCIBIy03iTFB0Fn8$Vuw}9D9HtMIjY4Bl;SFBpQMx09^nq?-@T180#Q2I5?aSpq#)401_Wz1i~j?1k@-14k$(<KPe;i6)q(g9$+p2DH`7Z^8Y*`vw%Y&zW_J`01zxrg&#ap;7)@Y01g@mLNS4MT7V2LKi~oYJcpse90Ef#06IVxh!L%h0Cxx=4f=rp{~;t`3qvVZgDO#kR)I)>Bmp@Cl0o6%03|v*;L2d`73M7f5hs8d07QQ)068513^O7vDivca6=gU`h&waj4&sF^Wt0z1<3r6qq}w1SQdI0HR_Q-OELlZ5-6HcHE@|O=VlMy=Fy8<Y1^^rZqA>vJ4=JF-fig&7GXM^yFEhe96kvovG`gZSTG&B0RR*E|>wqz3OnEbBMTR3Y07Ex{QvFfy01W^y03$PQWg!+cI7{FmILCn37d1J2z&Us!0RX!rIszaWH#>g-JG~L0zySa!GX!8AyE{AuARIb9>R=zgJ^(oYHxyo=0Q)@<r65!QCLJl<iNRrj69791;RXPA9}qVLpfL{=o8t99jiNR=ATa<UKst3JLB?P|1wxKu0b^-H*})$OM06@18r=eEMS~$LLm-v`7BrRu{**ug03a6tmjL$}H!A-C7)AiV?*J16K_i9t{|Zdyft*1UGMqv(LKoE_YXA~bAtGBq1^}l)D5k)Wp_!l-D?sTkVF3aEDF6TgRR912eF5453;+ZSEOY?>2>=~A00311{{RI90*?p+{r?RD#t8z!1P!KFARa(?0K$L_gh2xT01W~F5eon$)Vjfe-~ub)HZCC|0JjMS6gVU#H8es4eE{nL7XUs41Oo!z3}gTR0|yJCg$}<0t_%Xr3*h1I{|Exp2_YN+9Qz3{g`gJzJp%$#_u&Kg;+i2NzylltCEpzY2`~kp0Sh+207L)}3Iq25JuL$a;{gB!#0IZ`2MeUzU<VQg$3zR{2L}!Z^p=1QF$Wtd0{{sOzXH(*0`Ua<VbJ{q9HD^-0@eru`?m}HA-Mwr$P3>B?FcC$qCiCg{{T8)04F^v0N-^0H4s4+KqfnA=AZ*ngP{Ywp$;~!!2baNL;?Ug2m${tBo6=|TmV7y3kxpAGGQ424IuqM^k5+X1pr0{e*il;05Ci|AmGy}H6eiM07sCZ5CA<I7UK&5DMFH<24#OJ05B>g4kb9C9Xt|%HWEV50uE;tz}q}2xu7BlZJ-!7^$Bib3h{t6Eg}H_HUI$u9RLnB(F^hcW`GkVFMmK94BA5=9*Dp+BXghuRqp`-2?-;F(E|eij|&3G0s@r-_X5}rC1LFd9-8j}AQ~pdzz_f#odUz)G&wmV!C8S2*8mp-Or$1Tfpq{kGY&sIz$7`NzypA4O(7|bfdw`JF$Q_TPFDg401fy+R{%0XfWA>7ngAadCWK)C*A5~=4PqM&VKzHjC7~z{V;KlqBq&-TzBJ=p06z%{T>v5U^Z@|@D2G5*0ssg95CW$K0-X#3|DXc`)CU5O2Hyhw2m;PNAOZsa=?MbO1Ok8u{{lz?H3Fst0{_Je1e%$dnVBz{sXsgFU;(QHbpX8rXd*oT83uQRC_ex(DIyFcwW$N3(FMa{1SA@uG9pDKH#{t00s{~L7zCC=WT8lbp$0@~;~x%Ujbj3hWbYFIHxr<scK{p<20XDvJikLI!M%YLAf*RCKoJfA3*ZO~;tBlTWd30f2LKWh0GkaX7lI1_egRHEHB{Fi%0mi-04kp0H&dXh>;MX;f(x`@H@2aNuK+?95r|+X@4yVxA3)v!b>Iz40014G4NRajDI%!^%HR%asDcm5;Sj6F_Wzqg`veDW1lI-vzzF{WhY12M0+R>53@t(j0247afB@eTFarQWWZ)YGlK?1*fgC{}iGT!?2mS<w9{@i+8w4T#K0yEg3=0Ap0{fr>4S}=+0^1D!d|~wj0`Ld|*Z%|pwgdvo0T<tK05ugp;=lm_&kO<p5IumJK@%~yGeHV5m;wwndmtPC3poH900spBzZ?Jt0RSPM;TL~31^_7lEJY}w9~v(JDgm^i13)j~*B3Pi-eCbJp*IQoAV3`{0y+x-UjTP7KrR5FE<Y@A!d*79A}#<a0l_-F0__Bn!ukeL0gMd^I;DUC*Z@2P0;PdR;a(JoFaR?sE@BJ`1I)N0$AJY4cfkmN;sgHzk^};{1p<MO4FaYNTgK_206^d)KNn7+3_?R7FbqPJf&UEv0{|fe01)2?02DF>d;l>vt`!3d03*ud92;R0+b{+@z!e7|z$ia@Nq`o}0RaFT2ti@tCqZI101PCNff6tZR0aW%AsquE7u`bzumb<-1p=rD0%Zc3_ZMOn;4TPA;0*y3tujI(6EV%j1gBs@*9HI#6TmaS0|)@lKMDj40v`tC;GqQn0^0@x#0&z8?*an51$-*GKN7-k0S%de;ecb{453&6zdSDh761h!00gSsA_dg}IFkeoy&xbn2LJ_PtpO4-Y(W|Wxh>+MJ%JK13nO6+vfxAlM*#Q000UA$q<;tks|Es}1<+#O3j*W=0#ab02>vr*q6h+=1~;z103<&v06gr00nq@7fnrH8AUd?*6#(-TIs(b<!2|#`0RJaGATu5SEC9zP1u*?!^x?6ingB;0879skCLpe29a-c31X<xd02~Ml06Qo|TmZuW3O-;#L0<>}6#x?qKoSMSR(ydQ34DMyI{-E|z)ApM0s!Cx_8@Yi9A5z|5-<km3Nk@EabYyT?9QN@<0wANpcw!UQzAs);QgQwYT^lM;BN~703{3pF(cJsRRj(o2>@UU1b`J!q2Dn8D*!X3fhz!gE@l810P_Dj0wDSUKr(mWKL7$%0Qmz+04QLg1p@8`{{o{40*?m*<^Kx;v<L#(0U>r7#4rIPpe6({=wPoY04YERAQygu2GIbg;VmIPArVdh7XVp4ZeX&ZEC2=p1%04ZDTP572|zozfdz8lhdu-a-NFQ8f*}NJ29g9~2I4{n;5^&_)j=%p04D@8^ni{42ZbN+VJ+lAZy^L>!~qBB3u4>DdZGXuzytsT{@&my1OO9#06xz`4huTCB8H*|4gUh81_Iy-0^I)r0*?p+gbf1k9RkD$enE-{0`JZU0>GW12m-201}j}5A)P>bK?AtpXAK}gte`A_4mbE=^h<%dfi+2hCOjcB-yZ;D03JQy066(L_5p#Q1^^!oH`=<v2LB*3HwK|3HtxYd696{EVFCanAcBD&Bl*A@fn=c$`=I~e(+B__L;V0a27nL%H5K?lC(Ix=50Zdb;I6Ks9t=0!L?lK5VNU=G2Px5D1HdzFg8CJJLg_#r3jiw}7XS=1Y{4HG00ChG=kE;w9tZ>LZU7&zB_a_HYM>bOKp)1$qXP$|M5SQ=iMc=10=UwFon!)gK?4ASgJ3g*Y#4y>0h&Rdpa=5Zpd6m$HzfcC1_J-L2?DPJ0^J4u1g~L$W3<2o&Hv2I%*-pbKmvEo1_+P~5C9fDfJXo}NVMSj0MOwdA|TuXz%QTxKRnzd0Ra021-#+j4FbjmKLX?m0{8;xfU{ux7XZcK82}3&KvcOP{6Y$xAReiM1S>@GB}sr-L`*>w05#FF!r%hhpwR*b3dmv1e+L552LhV}_9S1G2m;6p(?b>0OZvkD9<*T;G6Vn;*8mJ6U4T2Lh64b*A_dAJ6*C5^U=-Uj2gIQ&B1)hOGJy!;fl8omVH2bAAjTmR8!-yWfhZ%W;oO2YfWHD&0ssXA6NEKi3labgAskHt97R^u!yN+%p(*7;4dqPz1~Whl0{;U7!~X&TiU9)p3Ig}_2MXdyJpdX8?q!2L02=`y6*B~kN8kY>GzDT|;GoZdKH@TD0Fa<2<Vk`8H4X6WZ)~9qK-uLJ05lRT@*t^28wKbLB7Ecf0e=Pv0ww~_1u>!e7E2EnLLC4KF#`VpB>*l2IX*9<)`2{&zzrxFg#{Qv2-^n$F@qH}=%oe#{UBFM0sssI0<HfB0-yo{-3tPL$^j2?05=z=!M_0j4gvrYasdN2Ghq%j0H7NUxuVLUt_xrnHw0y&GNhmk-!A|x11#)d834BtCP(dHKL96S0RI3b4FFUCCLBL009*h?51`|@;Po+ypgd4P0s;UA{N4am!Ds*k6FnELCaB;q00CeW0b?z8pa%m2VIlDa15&7%Z^k@eqd?#Tqd{dL?N0>)=?!Hg-C+Wcp!GDDVGU(~Ap`&s*AM_1J0T2JAO-;09veiX!6h>(z#jlrK5zgamOwS011gB&{{a972Lj^@0>2>wnF|6LWFrDAr3GYw9d4l$GQe`7sRNH<V*ocZ0v`im6)@VsOd)22<l`heHv$J{PXhoAEMuc%AO&aukrVjfWPpvK9b*C^XbJBN0*ncQL5~Ik|Mmm|gaQJc2LA$p3<CKJ0)YPq0<Z`I-3BxMYybfObpSICJgUHe48VW_aUugpfG^htIzdN)Ce<NZ04G2S7{nj|;{{P7CV)FM1izp(IX1>&h`|~t;4|SP3jhY<1Ys26^nJnqLnZ|02>>8E+$?}jp$jtu%|IwW*CRF`Rp2M!VGsb@8VC`93^Yq29uNM(BRv2d2@3!yx&z}I;y?fmH3Q-h`~%~MLp=Z;3JU=3DFmY&3K~ETHVcZ2ff32&DG;Fq!4iWhPVu1^07Ce{79cho;r}B#!T=Nk04VmuqX`VGA;ALz%>N4lxCjEM0|K|y2LdYKxeU3%?F|9$VXFbFAjHO2AUlKo9DC&k02~W90G|i|1po}7Km+0ndU`@30zg3q05;yhr7*_f9t6OJp$G+l43`K15CuRhcmqgb5>YVFVcKAk!3k)fAEZH-6*CI-VKq>I^k4yf0Ir}102nq5>OjjnXNsc{bAsdGIRJMr3=(nRJp&18ApI9s;Q{~$4FadX1p>+f0-zgZ$oT?9;T`~*3j(77{=K2a3j~^(nVBD%nW;ZJM<N<Pwcr;<028evJ!T-VU_2uS5i$d>#ayBP00IEmz)1v5BH4i+y<kFvB?KxipdbJXG6XC*m_P_%-aViP02VaIffY0L2XCM^c0nQl3J1j%4W&71WfP!AzySdNAOZlF02wzb`URmAbf9+t90okl->JuBdcnv*IgbD+0ADdFA`B#r04nAo^$68s2|=JRC?gFOB&NU_l0YS1;ftXKp|>LpCEcJ6BN_xUmO5Yo05qfu2L=K_3w{Y=3;+-S7Y(Li_R%8t|D7NL01Hk30-yl`uLc6>e*^-c1_HDJc0u-)K)3{zKmz3h0{`g<0<;YRxeNaSpbG;11Om?A0|K@M0#JZK0{_hf0-Xv1zz9DA;|T(w2R9+l0{H}zppyX5KLWD^{{o^00-Of|mj49;xCsKQ3j%xo1p}nuKLYz$Li^wY0w=8t0^J1v0^J1y!UY21{|f@12Lj~>0{?yldlarm;d=kXKLVWt0+b8>0mRfl0{9IA!|e$H#I!$Rp^6Fu|EmoGQ3BBh0{@5#0+I&;*a-gu!~z2J2m&?#0_Oz+-~|GkeF<n`i3tL^2a$mH0=5VV#H2q0p}zwHrUvu@ec%Rq%b@|;pfCkHK#~Elufi_DpkTv5031+51EjG<QNRRGB2GaC-@ql-jzlsBQVAhCU_=Q2068513^NG;e_a4989xpfnZThlXW&w#PGPM83fn*&`r3da31BG<05=H#01W^S3jh?3?*IrO3Jc*l01qhu3DX2Y4G=*$24G8IeLPTL7yt${7))UI0sty}01f~S4vPR1140r_K^h`-fD?THTOx-5LKhL;;4LNygZlpmqYYCc90P7>L_q)*>OdV26@q?@;Sc~05dac&L+uDtU=9-jrxXAV{S^ae761<r01_%-pd(+x5M==w*}(eX(=r#P;Z$NR!$1i#{}=!t06#k&1SKIW0X1bn8N(710tdkI0!I`AMI*rh03Q@iXn++n8FpnGB_}i?RBmA+;}&jZ8g616WZ|tGWai@kh~XU}g9<pGfeNLAU^E>7drIelw&o-Q9{PX{E5pD8?)qT~G9Nx5D;Pd&4i_4NARLC`|8zj^6(JNd8Kgiy10A+1fFKQj;1)DSAr)IQBKKe(3af!5f}r;oH6j!s8YBQY{{S)%6#!HKAo~_0w!kF-4<-PW60{*Fj-WP<p|W5S)`-9uHU`Kj2E-Ep`#2G|AXES$7$m$c;y2+b01qk%V=L+qVGIyxEKndN03`n@02EXJA{Zsw6hI*Z!51|YK^8UDEkIx&Vxukwpb;~1FOxz$fSg1;01+C&b_0SoFQcFuI4d)v#W18{I>>;kB@1C4E@~knFS)=o3BfWiU7)`%07NkWIx!$J(J~FBD}e-IEd*o;0PiyZ5Dg%q6*D2KD4{ACA}g@KIJSWS+W;gg;Tkw7;TbpnDB&D50JQ)YEr%mG5*Q)3fGOk505#|j0<HnYW;PI@H2_3OHxR2~q(;TSJ)t&rV80LmBRBvN#=$xM0iZJgBsBmO2Co1f4>i#uIt@S@+^~QZAOIpN1mP7kojX53KLtEi0s&(^>cGK1z`{RlCO`lW*FXRgTR;RTKo~atDJ^0_06PE+MCv5qGUPxt>;iTGK>q+U1OOim07BOQA{GooLu%v)0RI&;L;y7aDL=O&G#*Jn7)9gaMqWV1MF0*(gaSK^pnjf62mnU_4o45cza9esJ^&yHffxTF07U>pNB}r;GT})GM1$l)02Vib{YoMr0{|mO0299AgH!+?79w3jN_zF;b_(D#0{|b@Kx%MEOVvhAWFQ?yTA{u;ffoQj1x&4`O_E)K4p|}!g-w@$0wGmj000FF0@ULHzQO&Iz(5HC;|v1a`2oG4&gK~b02=}Nm|+W;VFCaQ0svnS3jiZFIp86n;BP?#05+1qFa#Tc^aMbkfe7tj4F&)Z-v<B^FbDHu2LLA%F$kfdzrr;^VDA7)1^9%e<Tpeh@L&pdVE!Nh1^^ulHvq7=01+z}z!-L%pgylX8w4QAfe#u00{Z|a8o*Tn00jpB0*?p+{S5-f{|N%^2m;Uq0{`>_5E%dq9zgV5KnQ~fwcrf`01@X403;T{)WQ=0HohgnzyJ~gK+vQl%FDqGlHed5KviG_1b%A31pq+?05=t&&f6g#3^vvx-GKlA_78vr0}jEX2m+?V3<eHmwm{qA2mt~BUIif#02TufASo5$e*gdn0|L+s2BCLY2n~ec0ss$^!22-+IpGUA02%=I1_J=A;0pjJH2&p4P5?bWJpd;EP5?ecLI5T%#{elcg&=|84`2oc{{rI+0;>c9>;D7-mJI@?1OnHL4HfV}0fImiG2H^CfII{PqhJ^Xa30_*fxbWkVHGn1X2LB5kYEfV)q^CnK?i8?w4@*)0)RB(6EOw=pD+M3C?Zb5AgKYiNZ<qq5ht_+5h2Az3lcyP;Q<PWLBRw6!0RJ9KjIrkK^zM<x{)9p3_%hw2D3mkClv<(Awn%7A_HL-Vb>Bc0y5wX#o#>ysRt^8FT(;J!v+^fF!KO36rc*A0hIt7&pJE+1T}&bzySsK4gxh3g9MtHnctb2nW;ZFq0|EZ0<8=Jn*##C{{{lf3<B;90{`j=0?Z2ntPPqDfGzld5;|SrIzec^00k2~7bQi+BUL>Z!vP}!C&a-W8Gv>qfF~sw1OWgXEkU;uFay#+6$Fle1^+rJKra9#04@&$IX*8TLBHWip)AM`5&#P!4ggVsZ$b(o?k>U$H~`!sCkOy_HF97F2f;c34!Ho-bKnlaBPQk!tbhmr`ymBzK@>6x0Kl&R5dl9I#VN5M9Pa=e2{3e^7XUr&1NNaD3&`LSFbc%-f_cFVdBQVd?O_ry(GGw@U%`if1c!hI1^)uK3j+EI0<I4Q0-OYfATWTGV5h+<OXCAj;sgr<1vX(;!TOGX1_t5j1p=rD{{oH*0_6b$<g*3`fuK`C6fz~@6SQG~hd~7S02T$Wpb7p%ARhofJR1Zd_Gn`S4i99Y0|Kb;0|Jx>m*IpA0{_SY0_h0?ybb>XhXn$U2?Cwp1_G=LD^M;E08bk?B>)oxnScNcW}MJqoPq}c3=d$Oh6GmtK?t0K37m=w1jQ(Q!7?JdBO?Li3PlB_V@e3X3#DTQ2*f;~H9&xViJ=Gp3;+xat0L7qI$$CCz(ED90s!SFs38n0!iPZ}1OQ)-00tfl48<kvKs^oYz#t3&4>(~qLFFD&Kmv*2WxxOc1pYQf*9HRJ4FWDGX32Adl|Te80tKz$E(ZSr00aU8#RdYOmIem{0C0ne0TJ$ufD-^U%flWOA?Ea8Jp-OY4Zs2b3jY!UOai<H0-kjNo*~hmfCU2EHA4Ti0s_AQ0>lBnG$Eh@0<H>k0IB~20*MC#$O}Y&AOI{J8Zsx~B5(}CLV&7Z!@&mt5dnby>0tu^8vr*46~h29wBQb4&Y=T<GXch$U=1U%AiU%}fe|xl1?6I^VhOrH2qEzR>q7_fg9!TO2>=fH3Hst{fjs~o3JdoDDm~}mI{`FB-3}{2HX{zf;0XZpLkb5g-XjYD4-2mV5)uFpqB#0M2X6otHw-`|DnJt8eyU(AkpMmu4AS7A2>>5D4gTPL01@vU01Pv0p&br2)=R(}4Zva#gn$SE_W&XfuAnt8A^@tSpa!KN2igD<&|@s`04xMIctBhLLTe8WO&~hGKp+cuU=ueGRG|c-I1NBU;LG5<G7-1HG%6zr0Ri$T0TLeMC*!&R92k8sbYLGkD*!OepkE9C=l?ta;4Fk-|2zN!RR9770^0)deZU6=+h8aKYXB4aAps6R8V3uZ{{jG^03<gfDP=hFVgW_K(ZG!bdf?q1(Zw(THL~IW0sgaa0s{d8sRIL`3uKT1)qs8{{GbQz0mZ(2LX`so%>=X|zIzH0hX@h?3?lp>-l`=K02c!{pf?iq?!Y3TG0mYL3^xG12%f+V1ppD^h8_I|Y9a>!82}6)@j#-0fWZ9g00063F9M$e0;ZucH=vPV{X3Cl0RRRE0;B&80?Gjb_5=d|v<(8e3j&M@uL6Vu80n-D?Vt?50R<@-It9JpCHXaUVBp|00{}Px*E2XYgd`<|AzJ`vKMEJzpaA0p0086h1&D&9;1r<|Gy(vB3;_lz89N5YfNdrTgA+6ffiyV@g+2npTL3@{7zu&^;n@d~BH;o6RVjcB0{^xP0=5AH{t5mU0sRO9qXPo|{|f@21OmVa0{^%T0_Y3^`V6HcDgYoV1OUJ`T4E9XGHgK%A_4#@0Dn#ZJwQGHCUSwUJcUL8628F^EubCe017d00xn_(01oE^01+}^ZomLCH>Ee<U?epm3j`tiph6D_05~`UVhe#Y!fpY-1^_|{05=Jt3S6(D37`T1C<nneq~dx5zzYM<2>>2Ce4(>K3<GbWLIVT*LExVR0_Y0_^uQP45}y6Q5C9bepCLQP1nmS*0mB9b!M_9rJ_TYI06YW&v0>ar_S1km9Mgpc2m-$S0V*O20`?68nEwj`rVIj&3Ie~Q1|IJKH4UI6mcrmC1Nedj_<@yU8{$*}9Q<OvAOpYx0544YVMf6tGQ+^kAOi)#={f#mnt>eEz(xQO`2q?7lVAe?K?VTTH^OQ-P2eHW;6ewN05=U^U?XB+h+q$YHvnG%Dmo|tpeHCeCe-C;L^|1E3PE)$d4d2SBjN%AdO!z^4GAD9<RG%4T_F8s$1nghe1MdIXbAyT^8TO?D8UGT;sXMbzXSrf1p)>l!NhM20*eIqfsq6Y!T-ez1e%$dnVCPCxjzCmAG(1vXiD+q4Mjj9^T3Y51!$mSF*c#&^~44S1^_vLEeBM<C_|e77VLo+K%EHZpb{_%H-T1SGR~?100}TlLjPh50J{te@WL_x4?I8|j_tt`FbxTTw1Vm46Pz;vvq3W_BFkX{f+V{D039I%1OghMk{byE8bIU*Mg!}CMg-EEVFc@mBVZX!L6r;t0>J|UpA7=@{{aHs1p>4N0{?~t0*eU($N~QXC<1^30^bGu0;sS60s{R70{@K!0;LTCsR_RVwgLjV1ye!JF9ia|1?j*vCJTfi<S0f*qB?lM0xMhqEhHTQU_%4{qESH|8iE5t;RPmwDg@9VB?1Tl4A%$%5R(82r@$04wF;<$3-+Kr114b<t1=A&A`Su~4K4;TRSyJ05Ceh{1;P@4fPV}u7XUp269FOhD*+)C2?7-WVF0HJ2q;$I0$~F&;TFm`0vF{V94??*K_3{a01pGf8SQ{H88t+&01pZQ3StAHX#lqX0|I*?$q9g|6UP8FQ`rE#%3!1F48mZ)1ol8+x(I+^rlSZpV9KopVBY{Eh5=yTz&Zn9-!#Es-!8&n-vR(=V9gppVBY|QKm-P@A^nS`!ngqfO#(Ij59nkQF#-S*0J94rd_cxyBRO+|9Zt^05C9h7VSz&@p&&m506+x*HuUAEAfW~_fpviQMv{UDbwQQZXFv%84&XOIA&Ca@4GySVz}evxG6VqMbpSFAKByoC0MiTwgaV&K9P;53FyRM<Vco)J#O;It01E#O0?-Qrw+jM)=>-Bt0^JLH<lnsl0{RE<p`io60{RL9{04V`7anB6Ap!son_;R&=;!@4UVs}5IRF{}{{|2M8~_FZ0No)EffqFglb{+1_K^V)H@sj801*j)02K!S6*dZ9AlpI+b3qk0b3sA~Z41`GBLX>q88@3DR~R-81VRqPKrW=f{~b9l04X*A1@izp<e&t=8UnHg{{plD0-y&1mhA-?gwPGP0htE^|HlmiH3F>+0{`I+0_y_;^#tDnpa}xt06+r-|JS2%Jqp*;KmP)c2m;In1bhD!u1Dc|gg*lP^j)9?0*nm=Gy5|$06^0}O&|c@D;yazCQG0ZGQR-;696_2&VW>J03Q}2b$~ttJONGv0Y(55ccVc84M70;B`=|=U@`*$T>zge7(NacmjN`uUB3V<89odb-oQ4iBM$Un9+!a>Ti_7402l`ZU<)!O0UrGgB?Ar#01^uT^(ATnAs@g)2>>{g9RLJJ&>;vSzy!?-t_0Kz021IJDZ*k6_c#C}_Mj;Z05=~P00uJ{_#h1+SL5p?ILm+y_~0T90PPaxpbj_7;1~}8pN;?sAPxC~1wcId{Nf*|!4)$Q0HVJD87e^<KQ#a-`la9vq@X?n0suXi02>D&!2}?|9|!~Y01qqz;|2g84Rtml0THy~5&#4&z~@2~09?QgU<Uve`!yBVK@T?o3jq5kJSN}}02vklpHu)L7$gGVB>@+&06qg32q72<A{kz3Kr|^M01AKsEuiTbEvGC%8WZ3l007+r{y+i(0z`nP29{Ld8vzS|Bhi5yp&y3<01wEc{2}uIO@RRC0R#<AAx+@r0|NW@1lhs31On*|zE5Gc2Lgr-qbk{ZKPU%*6#x@D>wz2#;&K5M02BfMh5>k>F9HBK0D@yJ58*ta@_|4D$6{px1ON;K;{9SfEkFrH^x+%=0B=|TJT`2A1tDR8uR;a@H*moRO<*jq89fXb3hO&LfEC985<2@qaH4=n=l~}tI|D9217Qg%;e*0|4FE#`Cnh7&;?)X=Aq%U*3_ze24b(BAh=K;tU{zkgC<5Q@2?FH>ZlR3={{pEC0{jO8n*R&}lL7*<2m=492Lh)I0@Miq0>%LX@&^K+{|o}e2?Cr10{`Iz0>upih711!gb4zy3<A^t2m<2^0>}gc|F8@KsR07R4f6u#dZ3VC2?8ww|Dp{7>;(dl1-}BR0s^uDc_H3^3<8!2%K;%1VEaM>AA<t`H2@}$KOr<9IY4FtJ)i{AZh#7KKulpb>f#ar9}Xf504B7-pdm?MRRwN=GcJK1T*4Y%;P(IvGzq~dKO{HG3Bf3D;SgCM1wafn_yt0l07HQ~05~ixsQ?Nf1Vso5pbZ2{J+A;A2@95i3MZf(u1TN(4K@v;5fUR1*8m*~5J5K%AuK;@Cps7bD-I(b3lo6r5I6<G6Bq+J06V`hF90PA00c!0{sd0102(<G05`t@Jqt(#NnpVV`4DViMj%Bl02ToM1v&scGco`pPYVDpIDg;+Kn?>z|26;~00j^LA*Bx?zz#w{CO{Sx1t5J8D_|}^Dm)%};Kd@eU@l5Q2;<&>E<xJ>6+<8&5l+A`KutesKrKVSfC+>Q37RDg5Wqqbpap;uE1?CRehpy@04+oS8xBF;6AnZI04Y;oAr!bFVHb^u!5$ShKfpMu1Ys5gdodTmM7<yocK{z33#b7ACX2!M96A{wU?dO+0Cyfd8SY>`7(9nSz91r`05TLB!k|c74iRMFAR7Tf69GZh905WX)_^`QASXR;FMtaGFD9cN9WSB(8vrH%1zZ3<{}K@Z82}U~Nc1s)uD})PViW)>0RIqX075)H03^Q?7XV2QA26X2cLD$;58yi+JQ?6?4?IdD7d8bUAbCN>79L>?<v=~<fdK&k-7TcSBS9gzz&J0rG#4fp;4(!X017VvG%F1#p&~$EHlX!MDBuCxKmbbs5^qo+03oknA3}yf*G?280b(Q|08SLuBmrV20b(T?AVe*9KsO<ALID6Q>fzTSKqrhKFSlVOL+&a;L?1l3;3GjF`v54TpfV0J01|%y8ZZk0GED&hz)FA<!AhS>fgNTwAwnJY3c(>iC!s7C2LRh9L^t6@APs>eLcbpXKL9)hngA{R70X~QBryP709Q>H6oz0lO93cGoA=NEE>Hjf+5bd;00C730S5!2VgIlQ0^J4^JpfY~1^6W4U<Te{0oLT6hyyh#DFA%nmPG>MQ@{z9N(Z3FA%*}Ye>@HVD?b1)6v5jd2;e~%Box3v3fTsmLYd(J0NVfq1m6P83j&$0KnVhW!v+Nb02~3g!n(&I0|7xX1OOfYJM$X^;Xno<3=RU`{{jN^1_F2jxBm+Q`U(Qq1OorP0RqYa0_y?)0xSae2m;m#{{q4T0{a3KWN!d35COp87Xn-0w?72~!=NDq?%)@@H3a~m7BmLQfCqa3NY>y702?_1VfPw12nFCB2>@U3053l+0H7^BE6xC*D?2F&BBH?;3)%rf3~s<S5Xztz0JlE{4Iu$A4iy1B{uKlP00k5R#tHudnh65`1p=o33<CQM0=NwV+oJ>TL5vL^q0j>N0*nF|0qzU}#{Ufh>Ied^3<Cd*2m+n~0-_0VKki^5LGQr}03`9@*8u<?BY_mefDi!x7X$!~00$ooti>V(0675PfgJ`z16&?~#eoVj1~>r>^dUb701XEK5d}bNLpvP^As`bm3Fbh$fL{jy6EX`e0vs&>hGYRk4D|yD1wbJT;5D!e;0GZIVF|!84YB||{~rJt00s~M6?FvG;3)kd9SSh<Am0}NJ_G_Uz!n6yi@-hvFTouS4uTKjkl-ZM0UAI8ArvwX$`OJP8KpQGqXne{0DlfE9RLb35E+6hqroi}!4ViD5($AH#Pk9s1%VU)febbPL@xjk3lR_^5_x1D<LfaL37{MV00IF1{r^#b0sssW0+Rm+0@w%wj|c+)v;hMB1On6tzGI=t0s`p?O{B&D1OlN00<sAL`+x^IA;k*>nwkHZnVFfnKScpM03S2q6*B@00rUXB82}C;K>+9h9or8#uRtd>8o*Ql*B}-n9N;gu;5QstNC3g%GXOILvw$W%<INyE;TALq;s+pi0GAyHIwM3TFaajO1zz01C_N)K{$VEzf$nNS5C9snKmZIhaR(&<2Ou_qJpdfwz^?v@3^fTU0TAY60e1i*3Sxj5HVgiN?({(qHU|r!D?cXnISZjGK0z!1Eef|d01ZxH4J9bU3p)TR8NodO9}A%T04)sd;2sJBpe_W!0-((aMguE10l){K2{_icV2%I>qa*WR9}0W~1VG^j02Vn9*#P@J4Qe1F01youdO;*B3}F%g6DI|P{WB;a2>>8G0RY=15P2XPIM?AF66!rc6GGwgIUxZ61g!*bVetxWg9(bl7rOvFQNRlTBWYtD`ir3xi=Z$7GbkdcMPyuolVSmrVFn0<HKIK%4PjxGND5#&RstJq0{{u2CkdhpHef(q9F4&eFa=<s6=?yz9Ri>N03rYkW(EBSn4#$f0;mWA@0S4r)PW!g0>NJd0^|k=eZ~S@!uFwpFa(xB1pq+?e*g>z02DI^j^gzQcHupw1_uWMANvA{AOd0n>IDLS(FX#H0SO@ypwB=805(TJ2_Y0R{RA*z8wdvg6*J8R13(}Kq9TC6061wEnxM>JKba;30+qq{q5%YwXea<MDEA@_BN-zARRI9o2@x(qu?!92?gIRnfwRD%3<8=00{zIe;-CWp$^`;{&<g_H3j!0(zz+hp0w^;G3t%!Ona7j@C4YehdFTUq;*G&A>SmxLFQE->03rqebr2dM2fTn3G6*q&Z7T3V3o>2;4L1hHwK5^V9v)#7GGBoc|1k>y2mlNK4W$gEA~FhqG(inlU?Bet01zDj3o;J&55WyJX8;=vIRO6}00#X38~_Ke5C9wxFn|uhKnB+U9ua(@DWpLI0DloI7XU&C5t<_E?jR}&Ks)Xr000Q|iA5q16D%kP01_~r0}`MF01VV1R^$zT00jUa1ON{r0ZK{&3=$#>5+d>827u$;8$&@2H3)p<3jqBn5~C0+7XU#A)d>=%FB||mpJD|G-vaFk0^ptEasprD2LikdUaS;IK~F;h05~C`nt>iE;Qa{bKo0}}5)uIO4I}@6bHNG#G$ZyW0R;f<fDteNHPkRbVPFAa-~uFI4K{khK?cUbF#r|-{y-5PHO1PXlK~wBK+T~E1AZo80RjaE0-NPRf13&d-U|XQ6QI8qF#rrJL0X_VmjE(1F5x6D;nG0@{{W)^2n#_d2Ykt_OT~f!HX{MY;q=NNN`W81VlMzO0QU<kK%)Ry06i>V{9q{}Qm6*QtKkYU2FKYZWq@Cx0|Jf#p#-r5jYxcgV?hcJk)g%!3<976eWA1i0`=PgU<3WZ*aZUmwF+yYF=HWz4F7;P9+jvP01P1efZ@Sg;cO}ZTi_Hj`#}pbiUR6VDGG}q2L%5H3jp~10Iop1zzYB=M*z7J>4Exz6EO+tfk5j36osH8mth$<3Ua<+3ax+zAU^;Vmm;dhAPdGK42FR>&4C^D5wD>&W#A0}A_x?4qHbaxWn%&kA)bK_qvpRODL`%@V?ZJR{k#7=R3JJ450ro+R0~7@K^6;0G;E>|fMNO#LM;VB2mmYqEB>tj2>@IGK@JV}#$YZ03IH1b^#9d63jieCpga2@0RZy_4fn*5fX)K~lsfvtgj^sD0{@fX`{KXN1OluJEUvB(&j1`aCS0JSKrsT^S3nmpfeJA%fgTL~H-?}G01gBI5u`OB7a%0l;g`TQ8z30(00lA^kpKb!D$pu{0zo;!0mL?oKo9_b76<@105CV#A$=*rf*Ak{A3z3xoO|UALkR#43_xSR3PQdB3YB1J;16P!APJTtr13%0APinb>VX+YfI$3n;FqBW03`q~1=l)1F9Zn<FW?~wPMg6BF%5+wVFE3>XZZ$|NG8Ch3<8e^93}xL;GG5;B~F2XA#+L}4+S3*1RLTjX$^WHG%5i0VGSvOA_2T3;$fb=Ar}BX1ev34rUumw|6#Y^0>9A$t_&Xn+5rNZ?Luv!(Etm%1JZyd&%Zu_5@XM`+~PpU!4okDXCXNNkqV0e0wvbX2G+uo<1p_4GbbX>fCvB$mk0n6DPRfKg3+QfaSPpKzM$J<1^^;809^H<)xi`p4BKKO|KLLlGB-loWS(P>A_9`Y?*<tH$XkNg4FXNnUV{G%^Z_E{#?c`E1p<Kx0`vm{_jv+~z#t3)$Or!d*9ro!0|Gbfl|lF5{|NWtz6(VUJpdR5TR=-8Q6QrL!vG0l08t~g!DRq9BM9(-1ZO#+38i9K!MZ`w;VBN|U}d!i<-jT^V8|gHuR!?W6EO%YC;}y8;e5qnw_rp75DNz@BB2QFqPAfAWf5RWGC~|b0{{~MH4U|ZMj`181)`-P4dLKE1P*qcz#k8FU==eEFriB`5p3cTVq`pK6E)y_6aZ2|0RSHr1>%(!Hli0Xz%<<C<G~on2O%;<5`j9Y;1ELx0hIt1LJSe%KM~{+A}r)tVG%AF5h~)!009Ky4w}b1!#v<Rqum4ozfl6$2?Dw~A+M_g8`%H>k$@AJU<daA5-=ga0Tvt>a{xa~AcbKu01Dq=x;6qZ+kqYnHz{KE4*(P>Js`kQ0PDeKAVxA_5-=?zQ^1b{8#e*<EyrLZRmC6)01w)xK?)t9Jp;wT6EP|QV+<i-4FbXrHR9yv`ve7dB&Gxc#S4OV01FnVO2BKR_~kkP4sbdE@*qHfrvM&60Cc5%O<@Ye000mb0ty5Fk^};{1p?v&{{l4vtqcO^2mXZN;0XfU0RpN22m<a50=fwTzjFeU2m-44fC&ErHUhf|0`&n=FIM4&A|~MiNWe4>q;MoaC!~o05`hvh1RG($1pp}kC_8&V7RKHo0RSU_eS;Ms3pm>VBf?-O2vLCv01qDr01um_R;V7JWdZ3Oyg=n6B)P#C06nP#CuBGw4lSV=xF8cd05n?R0sto~0|SG-1nGc72>=ZIz%>650D=HHC<Xw15z(L;I1B(n{vdxO696y)04Wy1{~tXR0ABzzL)|d|pfN!&0H7~F-7Ns1Ej=p%U@JS_DFPrVIw#LS2{8E;VnOa80s#O20KWlM000IC>mkhl0s=z<^$h~guL%P72wXrPO<@(`Gqj^M<xb(}feA1M{{SBVK06x(AY^gi2w(&VVzVQt1C;~W4OR}zp$r6lU;rcf+o2)yU_k`{HXWe=3E|=ZRwPnq1WTnl`v3r;U<C#Oj|lq${llWx2m;Uq%AX(*M#BNE!uf#$07DG|>H_EiPoO>FHY>qjzyJ~gK<9-xyujXeVITqk5O$#i0KFkkKtTooH{xIdzUeUo0RlAz&Ehcs05m8f05$*te*u*M8#+7y*TB0SIVnK_4Hqdvh5rZwCIYPi0>l3T0$>7=1_GM@1_HVS0>BLd|DFm0#RCE<0{{L50?-Qr{t15qiU9)u0|MFr|Mdp~xB&vB0<QwI0ZvsYA+dl%{{#RyJpdjC2mb&VHU$9103quvGI^pccHs~J9^TPo3ji%X8bA;Ln;!^3b37@{BCa7Gs|__lA_}8`8!lj!?*Jz-3)tWc01TxIGlDl#U<)7(dte_-eL;U=5-@#3W#kQ0fV&|JgaH&W4liK~|2Y5}00sg89xDI_W#9~n0YU^|-Qeps5QV@amq8gf5x)SA01G1!jKC=8LI4<u!J0u5FcR+oJpdXUKol|s%DDjyxdc6LAP68d6RKAt6uE#PS0XbtpcP*LKo$Ttasf7wU~Mo4AvG5}#3(hH0KRuY7yt=28*Cs8rvNB3J|F<VJZ<0=*8mqf0w6g7Kt=#-6%3d_GY7#o7Zm~i4`CTM7XTsv4eJUR3FR|ofGz+j{}BN2|2hf*KN}MluE8iINPrvx2I^mT03QiIqM#aMA#VWy1q4=SVhvTF`x5|Ff+7G31{CmBg|^{Ui=(Ik01XZQ0;UWC>IVX={|N%j3j)dm0{{I80`mg`s|^1F+6@B43<A~v0Rr^|0<r}v;`V?b`+y-sl0Xdr5dQ!c0RT7vFgNxnfhho;!4Lo!0_KGwF$3p<I^hKg0Gk{Df`B3fEWl8~D8B$PEGG>piU1G(FhDf`D?TPRA36zu8j=72ElNXx0U%u+1)&o$2k>AV{DAPuVWNQnWv5^OKRO)i1R*Y<CH=u0ISbzaKL9ZW{6HiM_Ozfo4E=x+04WdZMIt5yK^!*VbpShm7D51606#PE!2b>|04OH_{r~Sf0RSa8Asaaj{5XIGW+(tKE-McGE7XEs07n1+3jUSj2MPk43Idb=4FaJ90;L85|Jnxv%?Sd~4F3e0nVFfHnYoic0?LA*U>)vDm?8z=01yTM9F>4Z0KX9i0I&cNs~`aX7uE>@03QSZ|2Y6K4HE!V0QVjgA;;hc01XEF01({7zyJ{eKWywFlOr4k(I7Pv9AF=Z06-NFS48i^&LGzBAOJPg!6BO<L<s)?IynF_4io_2mjD+vC=7rt3!@MK55RwelAsA+;1cUF3iAO6vq}XC3-<z~2<70Q0s@c!2Lj~_0-^{4|E>xGs|Esz2mb=d3j&`7K@}GO6FSlX0sp~d;ohNtt^g!ID*!##Vch{@;2Qz}p5P}X_MYGX0dAvY05A~!1JOVP038JYD*q<{4IUN%0VqEJGb<qtB7uP<fL{Ox6#y9vU>J1(|9k)l6CD5)SbqRPK>!;73LIec3PY(u0J9(mIw?POFXBNxi(nN17zV)q7c~X|vj8j(|3f+x09*h;4Z3wfI1z<4CnOPqHunGk1AxUX0Ga@I9v3I3z#RYzPa?-13^km>lfs3d00#be;35F~|2l>MUnoBh04<0h5MP0nG6zB`2VF9U;0H}OwE!q32mv4zK3yRRE+xP<DI*jm1QFq`0e2n@H&(zs0}E|p`Vn9(*C09o1XTd50RuE71usK9FGCYw05nZP4+dfabK>sdK>`E=I-#Zn0>6y~3>5$rC14YcF*m^^I@<u=qHVzgnl@lI)nWhv)!`*T0(hn%ae#;c3IH@C;{eYARR9AIKtzC@22l$^N{-<hAUi{00#oJwk%2S-3@8Ku6UZ*7tzi=2021L#;MoC>0<;JSO2-r+2!Ip&F#;b#0{~M22G1@m01``K8fE|i{QJODVD1G1qX`24p#=hq2?DnUxeo}3^8_3YH@#pKyD|g5AQLeJDS`x~Ug7qk94nw%Ap^M}9?1m+;*f&|1mqP301CYdqale40><#b1AhYd4FZ)31dZT+jzI7~0$c)o^g!VpDFA=v51<Yq6fy+*R6r$oA$0&U4L<ICU<CjTf*=wA3!dTNBRK#L*a6+46;m??6$11DCEZ5|IDy|faR4<H2Z0FyuM7$R5dJ^~=!OOT2d#hx82}F?MfL?iKLFxD001Kk?uuX}8Yf`DLk$W3+`ujXF90e5EYt)bpddC5pgKa~00!O~0;~!GuD^f^0{@-?0=WSKw+sIQ`U(P|0|L461AZX0AR7P|06YXG0^Q&pDCNT7H%DVDCHQDT62e8~FaR?rBB~w$2AY8pF~A2g0tjX?0Wt{};ROH-0GJ|P)xjbM01*G+GXw#56fz2j;4>;C`5@N|G7HNg4PgO31o;H^Vlv_aRRI77{}KY!2Lg`<0{{OD0)hepyA0<7pA9r&8bI>_0)O2F0^0!s$^iiX1OlWD0#O3j{|N%51_GT1D-S&Y7zNuvt3lWRHvpRe2~EHT0Bzyrp$J}k01g8H5#T@~;6!>sVIh6sLIeOeg~2RH0dv6!06Ibu3B)sk!im8K97OMdLm(fa6EV#QLBJ$NZiBFa6EPM!-~bjJAstbG31#fyu2n%k1PoIl4JQH${>NYv%7y^|84|q!>HsSx4<y<kKIH^RAsz%ne&Id@5c<Ud?^B=`06qi})HZ_wK@ulN04G2M1uP{5g22TKKL86?=pJD4IXlbJq=DlZ01F;*Kpx<Or)4G+6#~a#f13dU(*goy$pHKdqGd$jKLU^i0{?*l0=NwV^#s2H@CX8$1LtD``{N7*XZi#Jo(*pT?F&9gKqe#cqQ7wfHWohs^?@PH0_edV4YVR(VF(%P01+xc11-T4HvsQr03tQ^pgcSPHxK|GZ=otc=Kym+RRz)^DaXM9nxPGxAoBnoZe>7#2mqA;zZ*L|00jcg;0JF27&{3FAR!7+ApaCQ3jj3$Fh6%IKOlLaFgpM$f%_*6S->4T4FFZ|04fk2c;H_EHUC8}0ABztMKStS;TFW9FaSLOBs~$Qp$h;oIDtU8Apai#_y0UP05ktKH2^6!05U$WEjk|n0mCW*!aLm`r(zQTK&_wv-1h(|Aa`IZ0RSo84`<*XJrD{&CKLY$03bdQ08#+A6f+7NphR&VAUUr9JsKb#Ktl$>25$f#88;W;BNBlCw<{tpQDGQ2{opEH6L6p)J`@9C6><P~7(fY0p*1lN6=Am_69SY#00PUv1@8p{&jvK1k_rO9xC#RG0R}Im5BmoIslhP-4J$(H00eVFHFUrUFa`er9{@i&8w4TzFThLS2Mz+`1_J-43<Ams0+kJS0`mzzp^pdxJD~r;1p>kb0@(xi0`Cewp`w%;ZNEYS$qgbxvjZu~9dV#J;UBZ$3}GAs-2eh$3NZsPz$QSqAu=BuAQuG=fieDUp&kr402u%c`yfG#05t$8J|n*~9{>^n4y*tsJu_`Ur~o}A5<siqcL4w&i=h=W2`GR+8wU#jCp~dM215Td9{^<l?*jmT069Gu06_;Tq4hZF13?7f69703*UFkZ10f6#U>Obm@_<1H4gjA3DsMt28acdRC^h{c_YeRW-vJ;1X8_+K4J{foPXIU$?hil$04gG3000F23CIDJ3Idx70{`0z0+b2@=?(t^rUC-Y3j(im4HSn!!66bb0>*%%!(a-o36#JdAqpNKUH<?q89fXb0FI9U1|AFT2?z$rfi18IfzKh5AReI-Fs^|d)eBPLEy|%ez(NWY^4eh#*WlbCoCyN@O$ERtln2}=tRVsc#Onw^0^|Sz20#L#O#{Xu&I1NU1aCVV;)KZ~z5)ck0@eVEfqCKtp4ngrJpdiEU}Inl&J>~(06AJAXoD#_`lnzBs~{8y02T+g02wzq;TSflK^AQ|bzu)S#i9{6?Lcn~01^zVVJSH?U{(d-HVtbaBdQ=FcVSHyGe8{x1?LO|IJ1KNA_OB30CfO36YWH>fFcGyKtl--PIF=b03+Ff52X?Mz|Rr@5)ut!;-euFPThbOI1^N03@Zo`K<E;r1tbk46a_8|04eejY84T4iXa65;QxI)`Qiiu0*nHyp#1~dh#vqxJRAl6AW#AU0|El*0{;T)2nQSh916`a`T+n5O~AQeJ1OfwFGe9W(|~9I1n(0(7bV5%000yJCIZn10_F<>|LzO|%mM<)2>SwfR^jjk0+0s#0+>I*0s@f;0{_MV0+$E^@(2F{@CpK|0|KT01_GP}0)q?!|K<S#*a-sD2>$}d3<8%40^9!$0&4=V1p@Q`2Lika0{8<0{ijWc%nAbc0s{Z|3<9hH0`mxAKVr*zA<cmp00}YUpx+k&Jp%%U;R67lO8^5w5RyP;LKm+9KLrK@;2$+172PvNVH^%OcHln+^wnS<pbE613pW5{djK)_V59&o4|_rX91Q>`01zP-{{R8602ntA0R2L{AR!L`E++uH5h4PD88{IFfDr!xA`t*DCjb)NBLyNFIT8YZ5&-`r696zL023tc2f`aV69Rw~03?4E05K;36eS8`_Z&ME1t1mxB^SQ{GA95PCIW&T`#co~z!(4~835liCjb^F1tK0j{T2#f8UQC705tC>02e3+!XG{t{tW;e04N;*H79of7%2*3AU_xnp#L5KDIWkfCjk2yDh&WV03{SB{{Rjj9smI-0RJ;AA`K$|8UT9+25Z3q03je#f&Vul09*h>4hHJYpfo4pBAQ@41S6^dq9g#KB?7?#0YWB3aYEOiFaZEfVVPhBnPL8yAn*$U>IMRty9f#M!5{(v!~he}wLlGkx4<*O1g)SL2WJNW62w59WibTBq5V6>qyPXAFaoac3<AdqOkvXo0;{D8$04AjAOw-2w37n@kRT0URz(MorU>sq0+0hrA&CJ3+hhVqgMbA`;fM(SNI{$i0<HxDrvC&2#R~+QnVH|2nVGpim?RKD{{rF#0^AA$`uNcT#GnePhyntm2L78Nr3?ZT0)Y!Wn|7iv2td98{=vFSmV;v*1JvLXAOIpG5dQ!b1^`$9JTP!BU{gVzp!=W*01%?4{}BKp00#j89qyc=6EO<cU>XG-=Ku;Zog(Bw3jic1S^zARftH~doWPU-bq<gLIhX-C6h)DOZ4l<59TBHs9}&P|Sx?KMoWT<@`yn0%0s9m(Sm6@@925Y*DFy%^3^oL86_yDA6f#ob7X*A#AsOlfd>Uq88wltE05`V#02myhKngOr!VUK~01Xa6A_xEydLf_=#9|EqB>+u8zXt#z2mlczU=6;<A|wDc00>jy6}JHC|IGj$9V}uV*7blEAH~2O89)L6f9n4S02nwRoWOf4XHsAg02vYuVYxHLLW6(-03g2NH2)z0C;%}jB@LY>#f29&A^|}#As5>=BMJc!H!ctvH-8cUf&e=x1pgqv3ji!z055AGBi6}b88<9}Br>5FI^86>KspshDS#I_ttB#`9wsuO5;CDqT5&)g&w&&&1_2)i0eclQGNT<P04g$|u?;ez1Zgs%6*DrU9l;a?c`~B}dorU4=K=t~^Zz{n9|z;(E4?~MpaB3RCqW@P%_t!u6gT369pF*``lTQMl7Q;}JUsxrAPpcuRRAe1ARl7}0s!C_U{4?c0PBL>RK!Xl88;TTpceprNcI2+02?_eFQ8v9EGi8v{NNh~G*uV|AQ=WLEe1Op3}F2m3}z|-Isi8_|1tn01^^xuHU13*0szbZ5C9!@EBt^ET_6}cEb^e!5jjJ`9H&0yAOQfaCNzN@Iy#{zG=UhqJuUPAJs3#`0X%gssvs#i!5=*-W?(BCJ|!X;4FVN!p=%*(2v08vNH8q`ArwOab_N110I#6H|C=#jzW`MN00|kBVS)Jr{ebYHhXw-H3jYGa0s?6Q)&k!G%LxJpmf_zE{{s340{RI8<Npf+2?C!B0?7Xa0*Vd-ngs&?$O{7e3Ia6(|I!6c5&#V$3)284>fr#uKs&%007ncTLBc?5fpQ`Oav*05G6UuTav%Z#V!`Vk1c71&f*=ty2KZtjQsV-{2LP1-8gDy100i|x0RRProd{~eBMl_-;ROK|-7}hD5i|;VU@rvMJ3=pWKqnC+CpG;5LBIeHBLV;_W-b6UBg>)-p%yd_g8wxJ07n5l8$H_qF8x3V3zH!>4F1;OLI@22lK>EVBrEqIJpdgH<^cZ)4*+2R4ht+^S3m;*5i9~B5r5!+9SR2k7c~+XAv-n(;ebO82z}u{L6;Xb69UKzfWaF97qc}K1*9Wj5H?{z8=VZ5pbRw?BVmF-Fkb*SEh7LsfB`%J<pex{13dt>fDSblz62x}06_;A3E&`q7yvK;H7p_pfjk8Q3L_i<Ar3zw6l0Y2U=G6vK;Rq>02Tomek)-<JOBm?03xA(00LD20s{d(;7<cI01A&m?qLD;0)GGiRR9DA2tVU<jSE0QM8Kf~0z)7(H6qiCF2f@?Ccw>L{Q=Zs0{{{L3n9G%p`Z%@BRPK}9{vL%6fy(=6#y2$ItKt1GX(|!DX$<U2peXgCJv$%*8mec{h<Z~U=uw4d7wuC2mlr|0RIgr1ppHV02BK$2HikC0|x*cPXHVVF)Lse0Rk*w>l+9nVJ9MC00K6*0009}APY7G!Z6qb#*pDkp#T9M`T_v|4g><A0s`F&e*%aJ0^J4_8iHRP00}b!x4{m6Vyeeu1`Hqwe&7So01w+Y1UW$xH^hJ{J9q$qSOX<s9RLqF2SU{og~Aff!UYq64LWZCG&MBl0Ua0X0i`Z=AudtifS@TvVL|>d!2k*k0;U84zr_m#00000K;Yd!cHu+<d=!E14F3Yw1_Im#0*QYE0*ML&$pS2(T^ua|5-<X-;1zE{aUCHbHXv)^5-<fp;rk0WD&PhH3<m(e5UT(VGzk2mG_?s^1`6Cj9t++eHu(#%K?J}VHw*wL{{Rgh7ytn%0RJ;9Aq^q`8UWh{1S|jsJuyHF0JA7H9wa*eH4VDNC^a^o0wOVh01X15rXVO^K*7P1ATM)ZI!wSSfd3o<k_Q6V2m=3)2m<d50`&v`0+9^@xd;NZ{{aI11Om<j0{_$p0*?j)xeWgT$N~cC2?EXc1Om5{;0gl81or}i3YEc^0|K(|2?BrzB;=Zzng5xYnW;Yn3fKRma6JmgKWPE003RZO6*xj1_5c}Q01hER03)IgHX-{bI1#{903a44PXLqvDO7*}p#=eA*9HJaPk{pRKobD#Hx)2I0*-(O01=Ba2t7b02LTJt0ssWR0CxZ!20Yv(C8i-m9SL#4p+E>9pbke001~I*55b**AtC_(Lkj>n9RLe5H4LUEEj1tw00l${f$9Xp4g|vw1j-Nq5C0JW5(fYjG7{$PKo}FRVhJS(02Jo{4ipXo5knso0N*SCC<rrcK#l;52p~3PC4oS0feuFuwwPcY5FJ4-0M>yW+66{9ej*<b2?Q4aG6@AD21EY?B{$x}1i;pQffxWNfDKsSA^_(K2Nffw4uKc|2Cp+102U?%H3py!o&aDX1ppEh10`Y(zW~7i9Wn&~q6Vq~Vh1chF%!W-j$jSA6hKYj1|$LiDX;(@wHeL=8n}QL8_nbb&j8~8b_^hpfFE`s24K+uL?DzzeBm54fIj5$A<ltE%RT@H0G9x_7&a*ifgAvR;3V$=1pqP@0U-?lKM^kgE(0#cfT+N40RRL7?EwP>qlUhs!7wNy4I`~a0G|&J0<8vm0b3xn{{sTs3<CNJ0{zNh00;v84FcEy1Oo2{0?-Qr|HcUdSOVS*E#GkfH5EQIzyScM41B<p00XX~1U^6ttucH-9SoGh3yo$5^uiznffwJPDF7@;ey!jdF90e5EYu)6c3}rapbj+%Bf-(2cSZmf>){nO3IfW0UI7sd02KiM>VTgI02ww81>%|l13s;w3kv`&K%d}y!2Ky}fI1xj5jqI}05t$FJ}NpN-vAi^6eteitN`0KC_n%#D+^!~I@VZWAQf<7E%)OsH!SU-1!D^U1#<$CfDB@{1pq$<ASp`hz(4l@Hw8+-C=dWt?*J(uEb^d85(@fnpczeIRR9173jQbI;|l_!4Fb~t0Rs610;>fA|D6T`kOcy%0#5?60UKLE)&LJ@;L$OrqqO3jWeA*LI{^I=OTYpE9|Qmo|8W2}7eD}{0Cy@31=3(Z1_t=yOAI&D;se=&2>>-yVZ|-N04Qpqr6FQNC^@uSfG(j32Vg-4ui+JgH3<P?F2((z^uVQLBliIQ|D|C700IGj0yP5x02=|_;Qce*;2!`!I~xSMAOPB700su50nGmb0z(4z4Fb;}2?F*A2a`yHAw=bR?4boaU<oh=00?I8{$KzJ5KyF^1_Iyb2?Ey#B!S@y{;&b~2?D<d0?Gdh0<;YR69S^_<RG$u3qdCVAOZloCjb*C01yBdP^TW`P^rbW2F0Z!fvo@~OEef+U>(K)QGp*(fXFW(LnF!H4P4+QK>`3(D&>JJUcfptAUBa91P4P_0S#E<2SIHiHvp9Z@(UviS>OZ92mlNK6k1_B;5rDV4Ftklp$Mb*CjcP?z(x%KJC7Xz4mGaAWS}{O94?h05C9twCmt4x6KA9kj}Cx258!YC2_V2K{;wbq01^-Y6%e}s91vj-HV@5UGp_|cLoZ07HU(e-cK{#^CLksNb_W3OHV^<JN<m=&4|@tN2>>quF$Rv~"),b_)end,function(B,b_)return function(E,j)local e,D_,l,R_,A,k,O,z,q,N,J,C_,i,T_,H_,P,d_,c_,h_,Q,G,s_,m,M,K,a_,g,p_,u,t_,_,I,w,r,L,f,y,x,o,F,n_,v p_=0xff while true do if p_>=0x2ba then if p_<=0x584 then if p_<=0x374 then if p_<0x314 then if p_<=0x2ec then if p_>0x2d8 then if p_>=0x2e3 then if p_>=0x2e8 then if p_<=0x2e9 then if p_<=0x2e8 then p_,H_,M=0b10000101,K[0xa0e2],0x1d M,i,Q=b_[0b101][1][b_[0b101][0b11]],K[0xc252],H_-M H_=M[i]E[Q]=H_ G,i,H_=0x25,K[0xf0e],b_[0b10001][1][b_[0x11][0b11]]M=i-G i,M,Q=0x15,K[0x5332],H_[M]i,G,H_=Q[1],Q[0b11],M-i M=i[G]E[H_]=M else g,N=Q+P,1 C_=g-N p_=h_<N and 0x257 or 0x10ab-p_ end else p_,G,R_=0x39f,C_-H_,1 M=G+R_ end elseif p_>=0x2e4 then if p_<=0x2e4 then p_,i,R_,M,P,g,G=0x4f8,j[0xb505],H_,b_[0b1001][1][b_[0b1001][0b11]],Q,E,1 else H_,M=K[0xa0e2],0x3a G,Q,i=0x2d,H_-M,K[0x5332]M,i=i-G,1 M,H_=-1,M-i p_=H_==M and 0x136 or 0x401-p_ end else k,p_,o=0x25,0xa0c11/p_,b_[0b11][1][b_[0b11][0b11]]u,F,k=G*k,N,b_[0b100][1][b_[0b100][0b11]]end elseif p_>=0x2de then if p_>0x2e0 then Q=0b101110 p_=n_<=Q and 0x62d-p_ or 0x96444/p_ elseif p_<=0x2de then H_,M=K[0xa0e2],0x28 G,Q,i=0x32,H_-M,K[0x5332]M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],0x26 p_,i,Q,G=0x85,K[0xe648],H_-M,0x1d M=i-G H_=E[M]E[Q]=H_ else M,i,x,q=K[0xa0e2],0b111101,0xf3,0b10101011 H_=M-i R_,H_,Q,G=0b10000,K[0xc252],E[H_],K[0x5332]i=G-R_ M=E[i]Q[H_]=M H_,M=K[0xf0e],0b1011 H_,i,M,Q=z,nil,nil,H_-M H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0x365-p_ or p_+-0x60 end elseif p_<=0x2db then p_=i and 0x3e7 or p_+0b11010011 else p_=R_~=R_ and 0x894-p_ or p_+-0x8b end elseif p_<0x2c7 then if p_<=0x2be then if p_<0x2bc then if p_>0x2ba then i,G=K[0xa0e2],0x38 i,Q,G=K[0x5332],i-G,0x19 i,H_,G=K[0xf0e],i-G,0b111011 G,M=0,i-G i=H_==G p_=i and p_+-0b111111001 or 0x39e else H_,M=K[0xa0e2],0x39 Q,H_=H_-M,nil E[Q]=H_ M,p_,H_=0b10000,0x33f-p_,K[0x5332]Q,M,i=H_-M,K[0xf69c],0x21 H_=M-i E[Q]=H_ end elseif p_>0x2bc then G,R_=E[Q],b_[0b1110][1][b_[0b1110][0b11]]g,P,N,o=b_[0b111][1][b_[0b111][0b11]],G,E,1 O,p_,o=Q+o,0x9ff,Q+i else q,M,H_=0b111001,0b111110,K[0xa0e2]Q,i,G=H_-M,K[0x5332],0x3d M,i=i-G,1 H_=M==i E[Q]=H_ H_,M=K[0xf0e],0x3c i,Q,M=0b100100,H_-M,K[0xe648]i,H_=1,M-i G,M,i=-1,H_-i,nil p_=M==G and 0x3b5 or 0x424f0/p_ end elseif p_>0x2c1 then H_,M=K[0xa0e2],0b11 Q,H_=H_-M,K[0xc252]E[Q]=H_ H_,M=K[0x5332],0x33 Q,H_=H_-M,nil E[Q]=H_ p_=q<=M and 0x1124-p_ or p_+-0x23e else M,H_=0x2d,K[0xa0e2]Q,G,i=H_-M,0b11,K[0x5332]M=i-G H_=E[M]p_,E[Q]=0x85,H_ H_,M=K[0xf0e],0b101010 Q,i,G=H_-M,K[0xe648],0x12 M,i=i-G,1 H_=M==i E[Q]=H_ end elseif p_<0x2d0 then if p_<0x2c8 then Q=0x69 p_=n_>Q and 0x3ba or 0x256 elseif p_<=0x2c8 then Q=0 p_=n_<=Q and 0x171e8/p_ or 0x4b2-p_ else N,g=R_[0b11],R_[1]p_,P=0x2b6,g[N]R_[0b10]=P R_[1]=R_ P=0b10 R_[0b11]=P P=nil z[G]=P end elseif p_<=0x2d4 then if p_>=0x2d1 then if p_<=0x2d1 then G,R_=C_-Q,1 i=G+R_ p_=q<R_ and 0x316-p_ or 0xa22 else Q=0x29 p_=n_>Q and 0x611-p_ or 0x64d-p_ end else p_,i=p_+-0b110101,C_-Q end else M,H_=0x18,K[0xa0e2]Q,p_,H_=H_-M,0x85,K[0xc252]E[Q]=H_ i,G,H_=K[0xf0e],0b110001,b_[0b10001][1][b_[0x11][0b11]]M=i-G i,Q,M=0x21,H_[M],K[0x5332]H_,G,i=M-i,Q[0b11],Q[1]M=i[G]E[H_]=M end elseif p_<=0x2fe then if p_<=0x2f8 then if p_>=0x2f2 then if p_>=0x2f7 then if p_<=0x2f7 then p_,G=0xa22,1 i=H_-G else N=P[0x5332]o,O=nil,z[N]p_=O==o and p_+-0b1010001 or p_+-0b111010111 end elseif p_<=0x2f2 then M,H_=0x1d,K[0xa0e2]G,Q,i=0b1110,H_-M,K[0x5332]M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],G H_,Q=K[0xc252],H_-M p_,E[Q]=0x187ba/p_,H_ else H_,M=K[0xa0e2],0x23 Q,R_,G=H_-M,0b11101,K[0x5332]i=G-R_ R_,p_,M,P=K[0xf0e],0x37b-p_,E[i],0x17 G=R_-P i=E[G]H_=M[i]E[Q]=H_ H_,M=K[0xe648],0b111 G,R_,Q=K[0xfa7d],0x27,H_-M i=G-R_ M=E[i]H_=not M E[Q]=H_ end elseif p_<0x2ee then H_,M=K[0xa0e2],0x23 Q,i,M=H_-M,0b100000,K[0xf69c]H_=M-i E[Q]=H_ H_,M=K[0x5332],0x1a i,Q,G=K[0xf0e],H_-M,0b100010 i,M=1,i-G M,H_=-1,M-i p_=H_==M and 0x42ed6/p_ or 0x3f4 elseif p_>0x2ee then M,H_=0b101111,K[0xa0e2]G,R_,Q=K[0x5332],0b10000,H_-M i=G-R_ i,M=K[0xc252],E[i]p_,H_=0b10000101,M[i]E[Q]=H_ else G=G(R_,P)E[i]=G G,i=H_,1 R_=i p_=G~=G and 0x373-p_ or 0x23aec4/p_ end elseif p_<=0x2fc then if p_>=0x2fb then if p_<=0x2fb then H_,M=K[0xa0e2],0x19 Q,M,i=H_-M,K[0xf69c],0x2b H_=M-i E[Q]=H_ M,H_=0b1101,K[0x5332]R_,Q,G=0x20,H_-M,K[0xf0e]i=G-R_ M=E[i]H_=#M p_,E[Q]=0x85,H_ else p_,w=0b10000101,w+H_ end else H_,i,G=b_[0b10001][1][b_[0x11][0b11]],K[0x5332],0x35 M=i-G p_,i,M,Q=0x18be2/p_,0x31,K[0xa0e2],H_[M]G,H_,i=Q[0b11],M-i,Q[1]M=i[G]E[H_]=M i,M=0b100111,K[0xf0e]i,G,H_=K[0xf69c],0x21,M-i M=i-G E[H_]=M end elseif p_<=0x2fd then Q=0b1001101 p_=n_>Q and 0x2bc or 0b10010101 else p_,G=0x3939c/p_,1 i=H_-G end elseif p_<=0x30a then if p_>0x306 then if p_>0x309 then o=o(A)u=nil A=o~=u p_=A and 0xa39 or p_+0x527 else R_,G=b_[0b1110][1][b_[0b1110][0b11]],E[Q]o,P,g,N=1,G,b_[0b111][1][b_[0b111][0b11]],E p_,O,o=p_+0x825,Q+o,Q+i end elseif p_<=0x305 then if p_>=0x301 then if p_>0x301 then g,p_,A,o,u,O,N=b_[0b1001][1][b_[0b1001][0b11]],p_+0x757,Q,P,E,1,R_ else p_,G=p_+0b1000,1 i=H_-G end else p_,g=0xcaa-p_,1 P=M-g end else H_,G,R_,Q=K[0xc252],K[0xa0e2],0x13,b_[0b101][1][b_[0b101][0b11]]i=G-R_ M=E[i]Q[H_]=M G,i,H_=0x3c,K[0xf0e],b_[0b10001][1][b_[0x11][0b11]]M=i-G Q,M,i=H_[M],K[0x5332],0x27 i,G,p_,H_=Q[1],Q[0b11],0x38b-p_,M-i M=i[G]E[H_]=M end elseif p_>=0x311 then if p_>0x312 then R_,P=M(i,G)G=R_ p_=G==nil and 0x85 or 0x239 elseif p_>0x311 then M,H_=0x18,K[0xa0e2]i,Q,M=K[0xc252],H_-M,b_[0b101][1][b_[0b101][0b11]]H_=M[i]E[Q]=H_ H_,p_,M=K[0x5332],0x397-p_,0b11111 R_,G,Q=0x35,K[0xf0e],H_-M i=G-R_ M=E[i]H_=#M E[Q]=H_ else G,R_=H_(M,i)i=G p_=i==nil and 0x396-p_ or 0x295 end elseif p_<=0x30b then Q=0b10010001 p_=n_<=Q and p_+-0x2b or 0x203 else M,H_=0b100010,K[0xa0e2]i,G,Q=K[0x5332],0b111101,H_-M M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],0b110011 Q,R_,G=H_-M,0b10110,K[0xe648]p_,i=p_+-0x289,G-R_ R_,P,M=K[0xfa7d],0b100111,E[i]G=R_-P i=E[G]H_=M[i]E[Q]=H_ end elseif p_>=0x342 then if p_<=0x358 then if p_>=0x34b then if p_<=0x34f then if p_<=0x34e then if p_>=0x34c then if p_>0x34c then G,R_=C_-Q,1 p_,i=0x281,G+R_ else M,H_=0b101101,K[0xa0e2]Q,R_,G=H_-M,0x11,K[0x5332]i=G-R_ M=E[i]H_=#M E[Q]=H_ M,H_=0b11010,K[0xf0e]M,Q,i=b_[0b101][1][b_[0b101][0b11]],H_-M,K[0xc252]H_=M[i]E[Q]=H_ p_=x<=R_ and 0x80e or 0x85 end else M,H_=0b111001,K[0xa0e2]M,i,Q=K[0x5332],0b100111,H_-M i,P,M,H_=E[Q],1,b_[0b1110][1][b_[0b1110][0b11]],M-i R_=Q+P G,P=E[R_],0b10 p_,R_=0xc20,Q+P R_=E[R_]end else M,H_=0b10,K[0xa0e2]G,Q,R_=K[0x5332],H_-M,0b111111 i=G-R_ M,i=E[i],K[0xc252]H_=M[i]E[Q]=H_ M,H_=0b1101,K[0xf0e]Q,M=H_-M,{}p_,H_=p_+-0x2ca,M E[Q]=H_ end elseif p_<=0x357 then if p_<=0x356 then p_,w=0x85,w+M else M,H_=0b11,K[0xa0e2]R_,G,Q=0b11000,K[0x5332],H_-M i=G-R_ P,M,R_=0x37,E[i],K[0xf0e]p_,G=0x85,R_-P i=E[G]H_=M<i E[Q]=H_ end else G,R_=E[Q],b_[0b1110][1][b_[0b1110][0b11]]P,g,N,o=G,b_[0b111][1][b_[0b111][0b11]],E,1 p_,o,O=0x224,Q+i,Q+o end elseif p_>=0x345 then if p_<0x346 then Q,H_,R_,G=b_[0b101][1][b_[0b101][0b11]],K[0xc252],0b10000,K[0xa0e2]p_,i=0b10000101,G-R_ M=E[i]Q[H_]=M elseif p_<=0x346 then M,i=K[0x5332],0b110001 H_,R_,G=M-i,0b1101,K[0xf0e]i,G=G-R_,1 M=i==G p_,E[H_]=0x85,M else g=1 P=M-g p_=r>g and 0xcb1 or 0x3f2-p_ end elseif p_>=0x343 then if p_<=0x343 then p_,H_,M=0x85,K[0xa0e2],0x14 Q,G,i=H_-M,0x30,K[0x5332]M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],0b11001 M,Q,i=K[0xf69c],H_-M,0b11 H_=M-i E[Q]=H_ else p_,M,H_=0x85,0b101111,K[0xa0e2]H_,Q=K[0xc252],H_-M E[Q]=H_ H_,M=K[0x5332],0x2a M,Q={},H_-M H_=M E[Q]=H_ end else H_,M=K[0xa0e2],0x29 M,Q,i=b_[0b101][1][b_[0b101][0b11]],H_-M,K[0xc252]H_=M[i]E[Q]=H_ i,Q,M=0b101010,K[0x5332],K[0xf0e]i,H_=1,M-i G,M,i=-1,H_-i,nil p_=M==G and p_+-0b101110111 or p_+-0x297 end elseif p_<0x364 then if p_>0x361 then if p_<=0x362 then M,H_=0b100010,K[0xa0e2]M,Q,i=K[0x59a2],H_-M,0b1010 G,i,H_=0b110010,K[0x95df],M-i i,M=E[Q],i-G p_=i and 0xa1878/p_ or 0b101111001 else G,R_=H_(M,i)i=G p_=i==nil and 0x261 or 0x26d end elseif p_>=0x35c then if p_<=0x35c then M,H_=0b110,K[0xa0e2]Q,R_,G=H_-M,0b1010,K[0x5332]i=G-R_ M,P,R_=E[i],0x13,K[0xf0e]G=R_-P i=E[G]H_=M[i]E[Q]=H_ M,H_=0b1010,K[0xe648]Q,M,i=H_-M,K[0xfa7d],0b101001 H_,i=M-i,1 i,M,G=nil,H_-i,-1 p_=M==G and 0x8f9d0/p_ or 0x3d3 else H_,p_,M=K[0xa0e2],0b10000101,0x32 M,i,Q=K[0xf69c],0b1101,H_-M H_=M-i E[Q]=H_ end else M,i=K[0xa0e2],0b10 H_=M-i H_,Q,R_,G=K[0xc252],E[H_],0x3b,K[0x5332]i=G-R_ M=E[i]p_,Q[H_]=0b10000101,M end elseif p_<0x369 then if p_>=0x365 then if p_<=0x365 then M,H_=0b111000,K[0xa0e2]p_,M,Q=0x85,{},H_-M H_=M E[Q]=H_ H_,M=K[0x5332],0x33 i,M,Q=0b111,K[0xf69c],H_-M H_=M-i E[Q]=H_ else p_,R_,P=p_+-0x2e1,K[0x59a2],0b10101 G=R_-P w=w+G end else G,R_,Q=K[0x5332],0b1111,K[0xa0e2]i=G-R_ p_,M,P,R_=0x3e9-p_,E[i],0x3c,K[0xf0e]G=R_-P i=E[G]H_=M>=i E[Q]=H_ end elseif p_<0x36b then p_,G=0xfec,1 i=H_-G elseif p_<=0x36b then Q=0b100010 p_=n_>Q and p_+0b1001101 or 0x72132/p_ else p_,a_=0xfd9-p_,a_(_)k,F=F+a_,4294967295 end elseif p_<0x32a then if p_<0x31c then if p_>=0x318 then if p_<0x319 then g,N=R_[1],R_[0b11]P=g[N]R_[0b10]=P R_[1]=R_ P=0b10 R_[0b11]=P P=nil p_,z[G]=0xc0e,P elseif p_<=0x319 then H_,G,i=b_[0x11][1][b_[0x11][0b11]],0x20,K[0x5332]M=i-G M,i,Q=K[0xa0e2],0b1101,H_[M]i,H_,G=Q[1],M-i,Q[0b11]M=i[G]E[H_]=M i,M=0b100,K[0xf0e]R_,P,H_=K[0xe648],0x36,M-i G=R_-P i,P,g=E[G],K[0xfa7d],0x2c R_=P-g G=E[R_]M=i%G E[H_]=M p_=r>g and 0x5279a/p_ or 0x39e-p_ else p_=i and 0x132 or 0x2fe end elseif p_<=0x315 then if p_>0x314 then G,P,g,R_,N=b_[0b111][1][b_[0b111][0b11]],Q,Q+i,E,1 p_,g=p_+0xc26,g-N else A=0x755cfa75 p_=o~=A and 0x935 or 0xe61 end else M=M(i)E[Q]=M p_,H_=0x11d3b3/p_,M end elseif p_<=0x321 then if p_<0x320 then if p_>0x31c then Q=0b10010110 p_=n_>Q and 0xbb9da/p_ or 0x298 else Q=0x26 p_=n_>Q and 0x2b9 or 0b11001000 end elseif p_<=0x320 then Q,x,q=0b10101011,0x2a,0x3a p_=n_>Q and 0x29c or 0x254e0/p_ else p_,R_=p_+0xa5,1 G=M-R_ end elseif p_<=0x322 then z=z(e,L)L=b_[0b110][1][b_[0b110][0b11]]c_,p_,e=L,0x85,L[0xec9d]K,L=c_,c_[0x2b3e]K,n_,c_=nil,nil,K[0xf888]else M,H_=0x17,K[0xa0e2]H_,Q=K[0xc252],H_-M E[Q]=H_ H_,G,R_,Q=K[0xb54d],K[0x5332],0b111110,b_[0b101][1][b_[0b101][0b11]]i=G-R_ p_,M=0x1a343/p_,E[i]Q[H_]=M end elseif p_>=0x336 then if p_>=0x33d then if p_>=0x33e then if p_<=0x33e then p_,G=0x791-p_,1 i=H_-G else Q=0b10 p_=n_>Q and 0x2a9 or p_+-0x11 end else H_,M=K[0xa0e2],0x2f i,Q,G=K[0x5332],H_-M,0x1b M=i-G H_=E[M]p_,E[Q]=p_+-0x2b8,H_ i,M=0b10001,K[0xf0e]H_=M-i Q,G,i=E[H_],0x28,K[0xe648]M=i-G R_,H_,G=0b110011,E[M],K[0xfa7d]i=G-R_ M=E[i]Q[H_]=M end elseif p_<0x338 then g=1 P=M-g p_=q>g and 0x512 or 0x3d3-p_ elseif p_>0x338 then w=w+i p_=q<r and 0x3c1-p_ or 0x56c-p_ else H_,M=K[0xa0e2],0b1001 M,i,Q=b_[0b101][1][b_[0b101][0b11]],K[0xc252],H_-M H_=M[i]E[Q]=H_ H_,M=K[0x5332],0x1b i,G,Q=K[0xf0e],0x3f,H_-M p_,M=0x85,i-G H_=E[M]E[Q]=H_ end elseif p_<0x32d then if p_>0x32b then i=0x5425a8ce p_=M~=i and 0x4e5 or 0x5c5 elseif p_>0x32a then H_,M=K[0xa0e2],0x20 G,R_,Q=K[0x5332],0x22,H_-M i=G-R_ M,R_,P=E[i],K[0xf0e],0b1010 G=R_-P i=E[G]H_=M..i E[Q]=H_ H_,M=K[0xe648],0b1111 i,M,Q=0x1d,K[0xfa7d],H_-M H_,i=M-i,1 i,M,G=nil,H_-i,-1 p_=M==G and p_+-0x171 or 0b101001010 else R_,G=b_[0b1110][1][b_[0b1110][0b11]],E[Q]g,p_,N,P,o=b_[0b111][1][b_[0b111][0b11]],0x58e,E,G,1 o,O=Q+i,Q+o end elseif p_>0x330 then Q=0b10000 p_=n_>Q and 0x1e3 or 0x3f9 elseif p_>0x32d then H_,M=K[0x96d4],0x2d Q=H_-M w=w+Q p_=q<M and 0xe61 or 0x1a7f0/p_ else H_,M=K[0xa0e2],0b10100 R_,G,Q=1,K[0x5332],H_-M i=G-R_ M=E[i]H_=-M E[Q]=H_ H_,M=K[0xf0e],0b1101 G,Q,R_=K[0xe648],H_-M,0b1110 i=G-R_ M=E[i]H_=-M E[Q]=H_ p_=x<=R_ and 0x3a6 or 0b10000101 end elseif p_>=0x3d3 then if p_>=0x436 then if p_>=0x4fb then if p_<0x541 then if p_>=0x511 then if p_<=0x512 then if p_>0x511 then u,O,N,g,p_,A,o=E,1,R_,b_[0b1001][1][b_[0b1001][0b11]],0xd16,Q,P else O,p_,N=1,0xa06,H_+g C_=N-O end else p_=R_<=0 and 0xc99 or p_+0x90f end elseif p_>0x507 then G=B.h(G(R_,P,g))return B.i(G)elseif p_>0x4fb then p_,g=0xb22,B.h(g(N,O,o))else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>0x55f then if p_>0x565 then p_,N=0x22314c/p_,B.h(N(B.i(O)))else p_,u,o,N,A,g,O=p_+-0b11001111,E,P,R_,Q,b_[0b1001][1][b_[0b1001][0b11]],1 end elseif p_>=0x551 then if p_<=0x551 then p_,P=0x6ce,B.h(P(B.i(g)))else p_,u=0xd2b,o.__call end elseif p_>0x541 then p_,P=0xb2d,B.h(P(B.i(g)))else o=o(A,u)p_,G=0b101110000,o end elseif p_>=0x49e then if p_>0x4e5 then if p_>0x4e8 then p_=0x85 M(i,G,R_,P,g)else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>=0x4b9 then if p_>0x4b9 then p_,M,i=0x317,b_[0b10][1][b_[0b10][0b11]],H_ else p_=R_~=R_ and p_+0x28e or 0xdc9 end elseif p_<=0x49e then G,R_=E[Q],b_[0b1110][1][b_[0b1110][0b11]]o,p_,g,N,P=1,0x9a5-p_,b_[0b111][1][b_[0b111][0b11]],E,G o,O=Q+i,Q+o else u,F,p_,O,k,A,o=N,E,p_+0x6da,b_[0b1001][1][b_[0b1001][0b11]],M,1,g end elseif p_>=0x468 then if p_>=0x496 then if p_<=0x496 then g(N,O,o,A,u)N,O=K[0xe648],0b11 N,O,g,o=z,nil,N-O,nil N,O,o=B.g(N,O,o)A,u=N(O,o)o=A p_=o==nil and 0x85 or 0xd96 else p_,P=0x342c72/p_,B.h(P(B.i(g)))end else F,p_,k,q=g,0x607,b_[0b1000][1][b_[0b1000][0b11]],0x30 end elseif p_<=0x452 then if p_>0x436 then G=B.h(G(R_,P,g))return B.i(G)else p_,g=0x565,1 P=M-g end else g,G,N,p_,P,R_=Q+i,b_[0b111][1][b_[0b111][0b11]],1,0xb9f-p_,Q,E g=g-N end elseif p_<=0x3f1 then if p_<0x3e6 then if p_>=0x3de then if p_<=0x3df then if p_<=0x3de then H_,G,i=b_[0x11][1][b_[0x11][0b11]],0b1100,K[0x5332]M=i-G i,Q,M=0b111011,H_[M],K[0xa0e2]H_,G,i=M-i,Q[0b11],Q[1]M=i[G]E[H_]=M M,i=K[0xf0e],0b1100 P,R_,H_=0x32,K[0xe648],M-i G=R_-P g,i,P=0x27,E[G],K[0xfa7d]p_,R_=0b10000101,P-g G=E[R_]M=i[G]E[H_]=M else p_,i=0x55b-p_,C_-Q end else o,O=P[0x5332],b_[0b10001][1][b_[0x11][0b11]]p_,N=0xa66-p_,O[o]M[i]=N end elseif p_>0x3d4 then p_,w=0x85,w+M elseif p_<=0x3d3 then p_,G=0x315,1 i=H_-G else p_,w=p_+-0x34f,w+M end elseif p_>=0x3ee then if p_<0x3f0 then R_,G=b_[0b1110][1][b_[0b1110][0b11]],E[Q]o,p_,N,P,g=1,0xda1,E,G,b_[0b111][1][b_[0b111][0b11]]o,O=Q+i,Q+o elseif p_>0x3f0 then P=R_[0b11]p_=P>=Q and 0x2c9 or 0x2b6 else Q=0b10000111 p_=n_<=Q and 0x102 or 0xc16e0/p_ end elseif p_<=0x3e7 then if p_<=0x3e6 then M,H_=0b1101,K[0xa0e2]R_,Q,G=1,H_-M,K[0x5332]i=G-R_ P,M,R_=0x18,E[i],K[0xf0e]G=R_-P i=E[G]H_=M[i]E[Q]=H_ H_,M=K[0xe648],0b1101 Q,H_=H_-M,nil E[Q]=H_ p_=q<M and p_+-0xa5 or 0b10000101 else G,R_,q=E[Q],b_[0b1110][1][b_[0b1110][0b11]],0b1111111 o,N,p_,P,g=1,E,p_+0x2c5,G,b_[0b111][1][b_[0b111][0b11]]O,o=Q+o,Q+i end else p_,g=0x74e,B.h(g(N,O,o))end elseif p_>=0x3fc then if p_>0x423 then if p_<=0x42b then p_=i<G and 0x27b or p_+0x57a else p_,i=p_+0x9ff,B.h(i(G,R_))end elseif p_>0x3ff then N,g=R_[0b11],R_[1]P=g[N]R_[0b10]=P R_[1]=R_ P=0b10 R_[0b11]=P P=nil z[G]=P p_=q<x and 0x279f3c/p_ or 0b1010011 elseif p_>=0x3fe then if p_<=0x3fe then H_,p_,M=K[0xa0e2],0x483-p_,0b1001 H_,Q=K[0xc252],H_-M E[Q]=H_ H_,M=K[0x5332],0x3d M,i,Q=b_[0b101][1][b_[0b101][0b11]],K[0xb54d],H_-M H_=M[i]E[Q]=H_ else G,R_,Q,H_=K[0xa0e2],0x2f,b_[0b101][1][b_[0b101][0b11]],K[0xc252]i=G-R_ M=E[i]p_,Q[H_]=0x2137b/p_,M M,H_=0x26,K[0x5332]H_,Q=nil,H_-M E[Q]=H_ end else R_=H_<=i G=not R_ p_=G and p_+-0x2c4 or 0xeb6-p_ end elseif p_<0x3f5 then if p_>0x3f3 then M,P,G,R_,i,p_,g=b_[0b1001][1][b_[0b1001][0b11]],Q,1,H_,j[0xb505],0x658,E else G,i,H_=0x3e,K[0x5332],b_[0b10001][1][b_[0b10001][0b11]]M=i-G M,Q,i=K[0xa0e2],H_[M],0b1100 G,H_,i=Q[0b11],M-i,Q[1]p_,M=0b10000101,i[G]E[H_]=M i,M=0x11,K[0xf0e]H_,P,R_=M-i,0x38,K[0xe648]G=R_-P i=E[G]M=not i E[H_]=M end elseif p_>=0x3f6 then if p_<=0x3f6 then M,Q={},K[0xa0e2]H_=M E[Q]=H_ H_,M=K[0x5332],0x30 i,Q,G=K[0xf0e],H_-M,0b1100 M,i=i-G,1 M,H_=-1,M-i p_=H_==M and p_+-0x2dc or 0x2e4 else p_,M,H_=0x2105d/p_,0x13,K[0xa0e2]Q,H_=H_-M,K[0xc252]E[Q]=H_ end else g,N=R_[1],R_[0b11]P=g[N]R_[0b10]=P R_[1]=R_ p_,P=0x363,0b10 R_[0b11]=P P=nil z[G]=P end elseif p_>=0x3ad then if p_<=0x3bd then if p_<0x3b6 then if p_<=0x3b2 then if p_<0x3af then if p_<=0x3ad then H_,M=K[0xa0e2],0x16 G,i,Q=0x1b,K[0x5332],H_-M i,M=1,i-G H_=M==i E[Q]=H_ M,H_=0x24,K[0xf0e]G,Q,R_=K[0xe648],H_-M,0x30 i=G-R_ M,R_,P=E[i],K[0xfa7d],0b101000 G=R_-P p_,i=p_+-0x328,E[G]H_=M==i E[Q]=H_ else G=1 i=H_-G p_=q>=G and p_+0x39 or p_+0b1001110 end elseif p_>0x3af then G,i=0x18,K[0xa0e2]G,i,Q=0b10001,K[0x5332],i-G H_,i,G=i-G,K[0xf0e],0x31 G,M=0,i-G i=H_==G p_=i and 0x2d0 or 0x29b else M,H_=0b1100,K[0xa0e2]Q,M,i=H_-M,K[0xf69c],0x39 H_=M-i E[Q]=H_ G,H_,i=0b100010,b_[0b10001][1][b_[0x11][0b11]],K[0xf0e]M=i-G Q,M,i=H_[M],K[0x5332],0b1011 i,G,H_=Q[1],Q[0b11],M-i M=i[G]E[H_]=M p_=q>x and p_+-0b10101110 or 0x1e9eb/p_ end elseif p_<=0x3b4 then p_,H_,M=0x85,K[0xa0e2],0b1010 Q,i,G=H_-M,K[0x5332],0b111101 M=i-G H_=E[M]E[Q]=H_ Q,H_,G,R_=b_[0b101][1][b_[0b101][0b11]],K[0xc252],K[0xf0e],0x3f i=G-R_ M=E[i]Q[H_]=M else G,R_=C_-Q,1 i=G+R_ p_=q<=R_ and 0x34f or 0x5e6-p_ end elseif p_<=0x3ba then if p_<0x3b8 then if p_<=0x3b6 then G,H_,i=0x39,b_[0b10001][1][b_[0b10001][0b11]],K[0x5332]M=i-G M,Q,i=K[0xa0e2],H_[M],0x11 G,i,H_=Q[0b11],Q[1],M-i M=i[G]E[H_]=M p_=f>m and 0x85 or 0x42cc/p_ else Q=0b1000 p_=n_>Q and 0x13e or p_+-0x158 end elseif p_>0x3b8 then M,H_=0x1e,K[0xa0e2]R_,Q,p_,G=0b11,H_-M,0b10000101,K[0x5332]i=G-R_ R_,M,P=K[0xf0e],E[i],0b111011 G=R_-P i=E[G]H_=M..i E[Q]=H_ H_,M=K[0xe648],0x3d G,Q,i=0b100010,H_-M,K[0xfa7d]i,M=1,i-G H_=M==i E[Q]=H_ else H_,G,R_,Q=K[0xc252],K[0xa0e2],0x34,b_[0b101][1][b_[0b101][0b11]]i=G-R_ M=E[i]Q[H_]=M H_,G,R_=K[0xb54d],K[0x5332],0b100101 p_,i=0x43d-p_,G-R_ M=E[i]Q[H_]=M end elseif p_<0x3bc then P=R_[0b11]p_=P>=Q and 0x6d3-p_ or p_+0x853 elseif p_<=0x3bc then H_,M=K[0xa0e2],0b110110 Q,H_=H_-M,nil E[Q]=H_ H_,M=K[0x5332],0x13 Q,R_,G=H_-M,0x22,K[0xf0e]i=G-R_ P,M,R_=0b11011,E[i],K[0xe648]G=R_-P i=E[G]p_,H_=p_+-0x337,M~=i E[Q]=H_ else M,H_=0b1111,K[0xa0e2]p_,i,Q,G=0x85,K[0x5332],H_-M,0b100 M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],0x3b R_,G,Q=0b101101,K[0xe648],H_-M i=G-R_ M=E[i]H_=#M E[Q]=H_ end elseif p_<0x3c6 then if p_>=0x3c2 then if p_>=0x3c3 then if p_>0x3c3 then i,G,H_=K[0x5332],0b100100,b_[0x11][1][b_[0x11][0b11]]M=i-G Q,i,M=H_[M],0x39,K[0xa0e2]H_,i,G=M-i,Q[1],Q[0b11]M=i[G]E[H_]=M M,i=K[0xf0e],0b1000 H_,R_,G=M-i,0b101000,K[0xe648]i=G-R_ p_,M=0x44a-p_,E[i]E[H_]=M else M,H_=0b110011,K[0xa0e2]G,R_,Q=K[0x5332],0x14,H_-M p_,i=0b10000101,G-R_ P,M,R_=0x24,E[i],K[0xf0e]G=R_-P i=E[G]H_=M-i E[Q]=H_ end else H_,i,G=b_[0x11][1][b_[0x11][0b11]],K[0x5332],0b1001 M=i-G Q,i,M=H_[M],0b111101,K[0xa0e2]G,i,H_=Q[0b11],Q[1],M-i M=i[G]E[H_]=M M,i=K[0xf0e],0b101 H_,R_,P=M-i,K[0xe648],0x25 G=R_-P g,i,P=0b100,E[G],K[0xfa7d]R_=P-g p_,G=0x1f3ca/p_,E[R_]M=i==G E[H_]=M end elseif p_<=0x3bf then O,g,A,p_,u,N,o=1,b_[0b1001][1][b_[0b1001][0b11]],Q,0x3a48b1/p_,E,R_,P else G,p_,R_=C_-Q,0x453,1 i=G+R_ end elseif p_>0x3cc then if p_<=0x3d1 then p_,G=0x2be,1 i=H_-G else p_=i<G and 0b10000101 or 0x1ff end elseif p_>0x3cb then N=P[0x5332]O,o=z[N],nil p_=O==o and 0xd4 or 0x257 elseif p_>=0x3c7 then if p_>0x3c7 then p_,P=0xfbe-p_,B.h(P(B.i(g)))else M,H_=0b1010,K[0xa0e2]Q,R_,G=H_-M,0x1f,K[0x5332]i=G-R_ M=E[i]H_=not M p_,E[Q]=0x85,H_ end else P,R_=b_[0b1110][1][b_[0b1110][0b11]],E[H_]N,O,A,g=b_[0b111][1][b_[0b111][0b11]],E,1,R_ p_,A,o=0xd4d,H_+G,H_+A end elseif p_>=0x391 then if p_>0x3a2 then if p_>=0x3a7 then if p_<0x3a9 then p_,R_,G=0x634-p_,1,C_-Q i=G+R_ elseif p_<=0x3a9 then H_,G,i=b_[0x11][1][b_[0b10001][0b11]],0x26,K[0x5332]p_,M=0x85,i-G Q,i,M=H_[M],0x25,K[0xa0e2]H_,G,i=M-i,Q[0b11],Q[1]M=i[G]E[H_]=M i,M=0b100001,K[0xf0e]M,H_=nil,M-i E[H_]=M else G=1 p_,i=0x2b82c/p_,H_-G end elseif p_>0x3a3 then M,H_=0x2a,K[0xa0e2]G,Q,R_=K[0x5332],H_-M,0b11010 i=G-R_ M=E[i]H_=#M E[Q]=H_ H_,M=K[0xf0e],0b10 Q,i,M=H_-M,0b100,K[0xf69c]H_=M-i E[Q]=H_ p_=q<=R_ and 0x783-p_ or 0b10000101 else q=0xaa p_=i and 0x3ee or 0x259 end elseif p_>0x39b then if p_>0x39f then H_,G,i=b_[0x11][1][b_[0b10001][0b11]],0b1001,K[0x5332]M=i-G i,Q,M=0x27,H_[M],K[0xa0e2]i,H_,p_,G=Q[1],M-i,0x85,Q[0b11]M=i[G]E[H_]=M M,R_,G=b_[0x11][1][b_[0x11][0b11]],0b10001,K[0xe648]i=G-R_ i,H_,G=K[0xf0e],M[i],0b10 R_,G,M=H_[0b11],H_[1],i-G i=G[R_]E[M]=i elseif p_>0x39e then O,p_,R_,G,P,N=1,0xfe6,E,b_[0b1001][1][b_[0b1001][0b11]],H_,H_+M g,O,N=N-O,E[Q],i else p_=i and p_+0b100000000 or 0xdde-p_ end elseif p_>0x39a then H_,M=K[0xa0e2],0x1b i,M,Q=K[0xc252],b_[0b101][1][b_[0b101][0b11]],H_-M H_=M[i]E[Q]=H_ M,H_=0b111,K[0x5332]G,i,Q=0b110000,K[0xf0e],H_-M i,p_,M=1,0x1df87/p_,i-G H_=M==i E[Q]=H_ elseif p_>0x398 then R_=1 p_,G=0x288,M-R_ elseif p_>0x391 then H_,M=K[0xa0e2],0b11111 i,Q,G=K[0x5332],H_-M,0b100111 M=i-G H_=E[M]E[Q]=H_ G,i=0b100001,K[0xf0e]G,Q,i=0b1011,i-G,K[0xe648]H_,G,i=i-G,0x2f,K[0xfa7d]G,M=0,i-G i=H_==G p_=i and 0x153 or p_+-0x26d else M,H_=0x29,K[0xa0e2]i,G,Q=K[0x5332],0b11111,H_-M M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],0x24 Q,i,M=H_-M,0b101110,K[0xe648]i,H_=1,M-i i,M,G=nil,H_-i,-1 p_=M==G and 0x58b-p_ or 0x49b-p_ end elseif p_>=0x380 then if p_>=0x384 then if p_>=0x38d then if p_<=0x38d then M,H_=0b101111,K[0xa0e2]Q,H_=H_-M,nil E[Q]=H_ G,H_,Q,R_=K[0x5332],K[0xc252],b_[0b101][1][b_[0b101][0b11]],0b11010 i=G-R_ M=E[i]Q[H_]=M p_=r<R_ and 0x144024/p_ or 0b10000101 else O,o=b_[0x11][1][b_[0b10001][0b11]],P[0x5332]N=O[o]M[i]=N p_=q<x and 0xde0 or p_+-0x16e end else M,H_=0b10,K[0xa0e2]i,M,Q=K[0xc252],b_[0b101][1][b_[0b101][0b11]],H_-M H_=M[i]E[Q]=H_ p_,H_,M=0b10000101,K[0x5332],0x30 Q,G,R_=H_-M,K[0xf0e],0b10100 i=G-R_ M=E[i]H_=not M E[Q]=H_ end elseif p_<=0x381 then if p_>0x380 then p_,M,H_=0x85,0b110101,K[0xa0e2]R_,G,Q=0x2f,K[0x5332],H_-M i=G-R_ R_,P,M=K[0xf0e],0x33,E[i]G=R_-P i=E[G]H_=M==i E[Q]=H_ else H_,M=K[0xa0e2],0x13 G,R_,Q=K[0x5332],0b11100,H_-M i=G-R_ R_,M,P=K[0xf0e],E[i],0b11110 G=R_-P i=E[G]H_=M+i E[Q]=H_ p_=q>P and 0x74c-p_ or 0x405-p_ end else p_,i,M=0x1cb98a/p_,0b100001,K[0xf0e]H_=M-i Q,i,M=e[H_],0x33,K[0x5332]H_,M=M-i,b_[0b1011][1][b_[0b1011][0b11]]i=H_ end elseif p_<0x379 then if p_>0x375 then q,x,D_,p_,I,o=0b11001101,0b1001100,0b1000100,0x314,0b10000101,u else M,H_=0x21,K[0xa0e2]G,R_,Q=K[0x5332],0b110111,H_-M i=G-R_ M,R_,P=E[i],K[0xf0e],0x2a G=R_-P i=E[G]H_=M[i]E[Q]=H_ H_,M=K[0xe648],0b110110 Q,G,R_=H_-M,K[0xfa7d],0b10011 i=G-R_ p_,M=0x3fa-p_,E[i]H_=#M E[Q]=H_ end elseif p_<0x37b then M,H_=0b10101,K[0xa0e2]i,Q,M=0x26,H_-M,K[0x5332]H_,i,G=M-i,K[0x59a2],0b1000 M,R_,G=i-G,0b111010,K[0x95df]i,R_,G=G-R_,E[H_],E[Q]p_=G~=R_ and 0xc4 or 0x63d6c/p_ elseif p_<=0x37b then p_,k=0x541,k(F)u,A=4294967295,u+k else G=1 i=H_-G p_=q>=G and 0x6a8-p_ or 0x314 end elseif p_<=0xaf5 then if p_>0x809 then if p_>0xa06 then if p_>0xa57 then if p_<0xaba then if p_<0xa78 then if p_>0xa5c then N,g=R_[0b11],R_[1]P=g[N]p_,R_[0b10]=0x311,P R_[1]=R_ P=0b10 R_[0b11]=P P=nil z[G]=P else p_=0x561cc/p_ g(N,O,o,A,u)end elseif p_>0xab1 then A,F,a_,k,u=b_[0b111][1][b_[0b111][0b11]],g+o,1,g,E p_,F=0xc23,F-a_ elseif p_<=0xa78 then p_,A=p_+-0x83e,A(u,k)R_=A else p_=R_<=0 and 0xec9 or 0xf7e end elseif p_>=0xadf then if p_<0xaea then p_,g=p_+-0x590,B.h(g(N,O,o))elseif p_>0xaea then p_,G=0xd8b,P else o=g(N,O)O=o p_=O==nil and 0x7795f2/p_ or p_+0x1d0 end elseif p_>0xaba then F,a_=u[1],u[0b11]k=F[a_]u[0b10]=k u[1]=u k=0b10 u[0b11]=k p_,k=0x80e,nil z[A]=k else P,R_=0x16,K[0x59a2]G=R_-P w=w+G p_=h_>=P and 0x85 or 0b101001011 end elseif p_>=0xa39 then if p_<=0xa51 then if p_<0xa4f then if p_>0xa39 then G=1 i=H_-G p_=q>G and 0x49e or 0xe33-p_ else k,u=nil,o.__iter p_,A=0x831,u~=k end elseif p_>0xa4f then t_=t_(T_)p_,l,J=0x7a5,J+t_,4294967295 else g=1 p_,P=0x3bf,M-g end elseif p_<=0xa55 then R_,P=K[0x95df],0b10 G=R_-P w=w+G p_=r<=P and 0x1eb or 0xada-p_ else g=1 p_,P=0x18fd-p_,M-g end elseif p_<=0xa22 then if p_>=0xa15 then if p_>0xa15 then G,P,R_,N,g=b_[0b111][1][b_[0b111][0b11]],Q,E,1,Q+i p_,g=0x4e8,g-N else P,g,p_,G,N,R_=Q,Q+i,0x508,b_[0b111][1][b_[0b111][0b11]],1,E g=g-N end elseif p_<=0xa0a then u,p_,A=g,0x5a0,b_[0x10][1][b_[0x10][0b11]]else R_,P=R_(B.i(P))g=0 p_=M==g and 0x145 or 0x2ff end elseif p_>0xa2b then p_,P=p_+0x235,B.h(P(B.i(g)))else G,R_=H_(M,i)i=G p_=i==nil and 0x220 or 0b100000111 end elseif p_<0x935 then if p_<=0x853 then if p_<0x831 then if p_>=0x80e then if p_>0x80e then p_,M=0xdf2,M(i)R_,G=0x25,K[0xa0e2]G,i,R_,P=b_[0b1100][1][b_[0b1100][0b11]],G-R_,Q,M else A,u=N(O,o)o=A p_=o==nil and p_+-0x789 or p_+0x588 end else R_,P=K[0x59a2],0x1c G=R_-P p_,w=0x42ec1/p_,w+G end elseif p_>=0x847 then if p_<=0x847 then p_=0xec8-p_ M,i=M(B.i(i))g,R_,G,O,P=H_,M,b_[0b1001][1][b_[0b1001][0b11]],0b11,1 O,N=E,Q+O else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>0x831 then G=B.h(G(R_,P,g))return B.i(G)else h_=0xb1 p_=A and 0x70e348/p_ or 0x98d end elseif p_<0x91a then if p_<=0x881 then M=M(i)p_,G,R_=0x18e9ee/p_,K[0xf0e],0b111111 P,i,G,R_=M,G-R_,b_[0b1100][1][b_[0b1100][0b11]],Q else R_,P=K[0x95df],0b1011 p_,G=p_+-0x824,R_-P w=w+G end elseif p_<=0x921 then if p_<=0x91a then v=v(d_,s_)p_,u=0xf2544/p_,v else p_=i>G and 0b10000101 or p_+0b110010000 end else p_,R_,P=p_+-0x8a3,K[0x59a2],0b11000 G=R_-P w=w+G end elseif p_>0x9a5 then if p_<=0x9ba then if p_>0x9b0 then R_=R_(P)p_,O,N,P,g=0x184a-p_,".",R_,0x1505,b_[0b1101][1][b_[0b1101][0b11]]elseif p_<=0x9ab then p_,g,A,u,N,o,O=0xbfc-p_,b_[0b1001][1][b_[0b1001][0b11]],Q,E,R_,P,1 else p_=R_<=0 and 0x3d2 or 0b111111111 end elseif p_>0x9ff then o,N,k,p_,u,A,O=1,b_[0b1001][1][b_[0b1001][0b11]],E,0x15d1-p_,H_,g,P else p_,g=0xf50-p_,B.h(g(N,O,o))end elseif p_>=0x994 then if p_>=0x99e then if p_<=0x99e then g(N,O,o,A,u)O,N=0b1001,K[0xe648]g,o,A=N-O,K[0xfa7d],0x2b O,o=o-A,1 N=O==o E[g]=N p_=x>=A and 0xa23-p_ or 0x1e5112/p_ else p_=R_~=R_ and 0x27b or 0xdf07a/p_ end elseif p_>0x994 then p_,P=0x795,B.h(P(B.i(g)))else G,R_=H_(M,i)i=G p_=i==nil and p_+-0x90f or 0x17f200/p_ end elseif p_<0x938 then p_,o,A=0x1bfb12/p_,b_[0b1010][1][b_[0b1010][0b11]],g elseif p_>0x938 then u=o p_=u and 0x55f or 0xd2b else p_=i>G and 0b10000101 or 0x2f6d18/p_ end elseif p_>0x6a6 then if p_<0x766 then if p_>=0x711 then if p_>=0x747 then if p_>0x74c then p_,P=0x691,B.h(P(B.i(g)))elseif p_>0x747 then G=B.h(G(R_,P,g))return B.i(G)else p_=i<G and p_+-0x6c2 or 0b101101000 end elseif p_>0x71f then p_,N=0xa06,1 g=i-N elseif p_>0x711 then N,g=1,Q+P C_=g-N p_=q>=N and 0x305 or 0x3ad else R_=H_<=M G=not R_ p_=G and 0x7b5 or 0x928 end elseif p_<0x6ce then if p_<=0x6ac then p_,g=0xb38,B.h(g(N,O,o))else R_,P=R_(B.i(P))g=0 p_=M==g and 0x5e9 or 0x436 end elseif p_<0x6e4 then R_,P=R_(B.i(P))g=0 p_=M==g and p_+-0x42 or 0xead-p_ elseif p_>0x6e4 then g,N=R_[1],R_[0b11]P=g[N]R_[0b10]=P R_[1]=R_ P=0b10 R_[0b11]=P P=nil z[G]=P p_=q>x and 0xeed-p_ or p_+-0x25b else E[Q]=G E[M]=R_ E[i]=P M,P,i=b_[0b1110][1][b_[0b1110][0b11]],1,E[Q]R_=Q+P P,G=0b10,E[R_]R_=Q+P p_,R_=0x42c,E[R_]end elseif p_<0x7a4 then if p_>0x77a then if p_>0x795 then k=2957081383 A=u==k p_=q<=k and p_+0x404 or p_+0x62d else R_,P=R_(B.i(P))g=0 p_=M==g and 0x71f or 0xb99 end elseif p_>0x779 then u,p_,A=1,0x5023b0/p_,C_-g o=A+u elseif p_>=0x771 then if p_>0x771 then g(N,O,o,A,u)p_=q>=O and 0x7fe-p_ or 0x4251e/p_ else p_,P=p_+0x462,1 R_=i-P end else G(R_,P,g,N,O)R_=0b10 G,g=Q+R_,0b11 P=Q+g R_=E[P]E[G]=R_ P=0b10 R_=Q+P G,R_=E[R_],nil p_=G==R_ and 0x4c70de/p_ or 0x80d end elseif p_>0x7df then if p_<=0x7f4 then G,R_=H_(M,i)i=G p_=i==nil and 0b10000101 or 0x2b4 else p_=i>G and p_+-0x58e or 0x2dd end elseif p_<=0x7b5 then if p_>=0x7a5 then if p_<=0x7a5 then s_=s_(l,J)F=s_ p_=h_>=J and 0x258 or 0x117fb2/p_ else R_,P=K[0x95df],0b1011 p_,G=p_+-0x730,R_-P w=w+G end else p_,g=0xc3e,B.h(g(B.i(N)))end else p_,g=0xc9e,1 P=M-g end elseif p_>=0x64c then if p_<=0x678 then if p_>=0x65c then if p_<0x671 then if p_<=0x65c then g,N=Q+P,1 p_,C_=0x3bf,g-N else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>0x671 then p_=i>G and p_+-0x5f3 or 0xbf9 else p_,o,O=0x4b5,1,M+N C_=O-o end elseif p_>=0x650 then if p_>0x650 then p_=p_+-0x5d3 M(i,G,R_,P,g)else g=1 p_,P=0x56d8a0/p_,M-g end else A=A(u)u,k,a_,p_,F=0x1003f,b_[0b1101][1][b_[0b1101][0b11]],".",0x24b,A end elseif p_<0x68c then if p_>=0x681 then if p_<=0x681 then G(R_,P,g,N,O)R_=0b10 g,G=0b11,Q+R_ P=Q+g R_=E[P]E[G]=R_ P=0b10 R_=Q+P G,R_=E[R_],nil p_=G==R_ and 0x8cf-p_ or 0x161a66/p_ else i=i+R_ p_=R_>0 and 0x938 or 0x525 end else R_,G=b_[0b1110][1][b_[0b1110][0b11]],E[Q]P,p_,N,g,o=G,p_+0x463,E,b_[0b111][1][b_[0b111][0b11]],1 O,o=Q+o,Q+i end elseif p_<0x691 then N,p_,g=1,0x529a68/p_,Q+P C_=g-N elseif p_<=0x691 then R_,P=R_(B.i(P))g=0 p_=M==g and 0xc3 or 0x349 else A,o,g,N,u,p_,O=Q,P,b_[0b1001][1][b_[0b1001][0b11]],R_,E,0xdcc,1 end elseif p_<0x5c5 then if p_<0x5b4 then if p_>=0x58e then if p_<=0x58e then p_,g=0x480f1e/p_,B.h(g(N,O,o))else A,u,k=A(u)R_,G,P=u,A,k p_=D_>=I and 0x9a560/p_ or 0xc84-p_ end else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>=0x5b7 then if p_>0x5b7 then G=B.h(G(R_,P,g))return B.i(G)else p_=i<G and p_+-0x33c or 0b101110010 end else G,R_=H_(M,i)i=G p_=i==nil and 0x639-p_ or 0x242 end elseif p_>=0x607 then if p_>=0x633 then if p_<=0x633 then g,N=g(B.i(N))O=0 p_=G==O and 0x27ee83/p_ or 0x1562-p_ else R_,P,g=R_(P,g)R_,P,g=B.g(R_,P,g)N=R_(P,g)g=N p_=g==nil and 0b111100101 or 0x2e3 end else k=k(F)y,a_,p_,_,F=".",b_[0b1101][1][b_[0b1101][0b11]],0x1280-p_,k,0x1003f end elseif p_<0x5e9 then q,p_,G=0x9f,0x2a8,1 i=Q+G G,M=b_[0b1000][1][b_[0b1000][0b11]],E[i]R_=M elseif p_>0x5e9 then i=i(G)R_=1 G=Q+R_ E[G]=i M=i p_=q<R_ and 0x366 or 0xb70 else N,p_,g=1,0xb4e-p_,Q+P C_=g-N end elseif p_<=0xd54 then if p_<0xc20 then if p_<=0xb8f then if p_>0xb5b then if p_<0xb70 then if p_<=0xb5e then R_,P=R_(B.i(P))g=0 p_=M==g and 0x21148e/p_ or 0x47c160/p_ else A,u,k=A(u)G,R_,P=A,u,k p_=q<x and 0b101101110 or 0x6e4 end elseif p_<0xb89 then p_,R_=0x9ba,0b10 G=Q+R_ i,R_=E[G],b_[0b1000][1][b_[0b1000][0b11]]P=i elseif p_>0xb89 then p_=0xc14-p_ O(o,A,u,k,F)else p_=i>G and 0x5fe2d/p_ or 0x367a01/p_ end elseif p_<0xb2e then if p_>=0xb22 then if p_>0xb22 then R_,P=R_(B.i(P))g=0 p_=M==g and 0xa5a0ea/p_ or 0xc91 else p_,P=0x6bd,B.h(P(B.i(g)))end else p_=R_>0 and 0x809 or 0x1fa716/p_ end elseif p_<0xb3e then if p_<=0xb2e then p_,g=0x3cb,B.h(g(N,O,o))else p_,P=0xbd9,B.h(P(B.i(g)))end elseif p_<=0xb3e then G=G(R_,P)E[i]=G G,i=H_,1 R_=i p_=G~=G and 0xdb9-p_ or 0x7c4764/p_ else g(N,O,o,A,u)O,N=0b11,K[0xe648]g,O,o=N-O,K[0xfa7d],0x3e N,o=O-o,1 O,A,o=N-o,-1,nil p_=O==A and 0x77a or 0xe82 end elseif p_>0xbd7 then if p_<0xbf9 then if p_>0xbd9 then R_,P=R_(B.i(P))g=0 p_=M==g and 0x10b or 0x263 else R_,P=R_(B.i(P))g=0 p_=M==g and 0x65c or p_+-0b110001010 end elseif p_>0xc0e then P,N,G,R_,g=Q,1,b_[0b111][1][b_[0b111][0b11]],E,Q+i p_,g=0x843,g-N elseif p_<=0xbf9 then p_=R_~=R_ and 0xfcb-p_ or 0x15a9-p_ else G,R_=H_(M,i)i=G p_=i==nil and 0x2775d4/p_ or 0xfc9-p_ end elseif p_<=0xbcb then if p_>0xba7 then N(O,o,A,u,k)p_=h_<=o and 0x16e or 0b10000101 elseif p_<=0xb9f then if p_>0xb99 then p_=A and 0x15a9-p_ or 0xe61 else g=1 p_,P=0x305,M-g end else p_,O=0x584,B.h(O(o,A,u))end elseif p_<=0xbd3 then P,g=E[M],b_[0b1110][1][b_[0b1110][0b11]]u,O,p_,o,N=1,b_[0b111][1][b_[0b111][0b11]],0xba7,E,P A,u=M+u,M+R_ else p_,F=p_+-0x15f,F(a_)u,k=k+F,4294967295 end elseif p_>=0xc9e then if p_>0xcf9 then if p_<=0xd2b then if p_<=0xd16 then if p_<=0xd01 then p_,i=0xc4af20/p_,R_ else g(N,O,o,A,u)O,p_,N=0x2d,0b10000101,K[0xe648]N,g=nil,N-O E[g]=N end else k=nil A=u==k p_=A and 0x468 or 0xb9f end elseif p_>0xd4d then G=0 p_=i>G and 0x711 or 0xc3a718/p_ else p_,N=0x14f1-p_,B.h(N(O,o,A))end elseif p_<=0xcba then if p_>=0xcb4 then if p_<=0xcb4 then p_,G=0xd54,G(R_)P=0b10 R_=Q+P E[R_]=G i=G else p_,a_,u=0x374,0x25,b_[0b11][1][b_[0b11][0b11]]_,a_,F=o,b_[0b100][1][b_[0b100][0b11]],P*a_ end elseif p_<=0xc9e then g,o,p_,O,A,u,N=b_[0b1001][1][b_[0b1001][0b11]],P,0x8f462a/p_,1,Q,E,R_ else o,O,p_,g,A,N,u=P,1,p_+-0x538,b_[0b1001][1][b_[0b1001][0b11]],Q,R_,E end elseif p_<=0xcd7 then if p_<=0xccb then p_,R_,G=0xcb4,i,b_[0b10][1][b_[0b10][0b11]]else A,F=b_[0b11][1][b_[0b11][0b11]],0x25 p_,k,F,a_=0xbd7,R_*F,b_[0b100][1][b_[0b100][0b11]],O end else p_,P=0xd6d,B.h(P(B.i(g)))end elseif p_<=0xc65 then if p_<=0xc2e then if p_<0xc24 then if p_>0xc20 then A=B.h(A(u,k,F))return B.i(A)else p_,i=0x1467-p_,B.h(i(G,R_))end elseif p_>0xc24 then p_=R_>0 and 0x12a6-p_ or 0x91d2be/p_ else p_,M=0x887cb8/p_,M(i)R_,G=0x37,K[0xa0e2]i,G,P,R_=G-R_,b_[0b1100][1][b_[0b1100][0b11]],M,Q end elseif p_>0xc3e then u=u(k,F)p_,P=0xaea,u elseif p_>0xc32 then P,g=P(B.i(g))N=0 p_=i==N and p_+-0x72d or 0x738 else p_,l=0x91a,l(J)s_,d_=4294967295,s_+l end elseif p_>0xc79 then if p_>0xc91 then p_=i<G and p_+-0xc14 or 0xe34 else g=1 p_,P=0x6a6,M-g end elseif p_>0xc6d then a_,_,y=a_(_,y)a_,_,y=B.g(a_,_,y)v=a_(_,y)y=v p_=y==nil and 0xf82 or 0xf38 elseif p_>0xc69 then R_,P=R_(B.i(P))g=0 p_=M==g and 0x185151/p_ or 0xfa3-p_ else i=i+R_ p_=R_>0 and 0x20d or 0xd6a end elseif p_<0xe90 then if p_<0xdd2 then if p_>=0xd96 then if p_>=0xdc8 then if p_>=0xdc9 then if p_>0xdc9 then p_=0x72afc/p_ g(N,O,o,A,u)N,O=K[0xe648],0x33 g,u,A=N-O,0b11011,K[0xfa7d]o=A-u O=E[o]N=#O E[g]=N else p_=R_<=0 and p_+-0x682 or 0x168 end else p_,A,u=p_+-0x267,o.__iter,g end elseif p_<=0xda1 then if p_>0xd96 then p_,g=0x3e8df7/p_,B.h(g(N,O,o))else k=u[0b11]p_=k>=g and 0xace or 0x80e end else O,o,N,A,u,p_,g=1,P,R_,Q,E,0xedb,b_[0b1001][1][b_[0b1001][0b11]]end elseif p_<=0xd6d then if p_>0xd6a then R_,P=R_(B.i(P))g=0 p_=M==g and p_+0b111010011 or 0xa57 elseif p_>0xd68 then p_=R_<=0 and 0x37e8ce/p_ or 0x9a5 else O,o,g,u,N,p_,A=1,P,b_[0b1001][1][b_[0b1001][0b11]],E,R_,0xd3d448/p_,Q end elseif p_<=0xd81 then p_,g=0x171a-p_,B.h(g(N,O,o))else R_=0x5425a8ce p_=G~=R_ and 0xad4139/p_ or 0xd54 end elseif p_>=0xe2b then if p_>=0xe61 then if p_<0xe7e then R_,p_,P,G=N,0x631464/p_,O,g elseif p_>0xe7e then p_,A=0xab8,1 o=N-A else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>0xe34 then g,G,P,N,R_=Q+i,b_[0b111][1][b_[0b111][0b11]],Q,1,E p_,g=0x4fb,g-N elseif p_>0xe2b then p_=R_~=R_ and 0b10000101 or 0x168 else M,i=M(B.i(i))G,R_,g,O,P=b_[0b1001][1][b_[0b1001][0b11]],M,H_,0b11,1 p_,O,N=0x68d222/p_,E,Q+O end elseif p_<0xdf2 then if p_<0xde0 then R_=B.h(R_(P,g,N))return B.i(R_)elseif p_<=0xde0 then i=i+R_ p_=R_>0 and 0x921 or 0xab1 else p_,P=0x17f5-p_,B.h(P(B.i(g)))end elseif p_<=0xe0e then if p_>0xdf2 then p_,G,i=0x602,M,b_[0b10][1][b_[0b10][0b11]]else G=G(R_,P)E[i]=G G,i=H_,1 R_=i p_=G~=G and 0xe77-p_ or 0xfa5 end else p_,i=p_+-0x7e4,i(G)g,G,R_,P=".",0x1505,b_[0b1101][1][b_[0b1101][0b11]],i end elseif p_<0xf3b then if p_>0xedb then if p_>=0xf20 then if p_>0xf2f then p_,s_,t_=0xa51,b_[0b11][1][b_[0b11][0b11]],0b10001 J,t_,T_=F*t_,b_[0b100][1][b_[0b100][0b11]],v elseif p_<=0xf20 then G=0x5425a8ce p_=i~=G and 0xe0e or p_+-0x3b0 else p_,O=0x47783b/p_,1 N=G-O end elseif p_>0xf0d then P,g,N=P(g,N)P,g,N=B.g(P,g,N)O=P(g,N)N=O p_=N==nil and 0xd01 or 0x1bef-p_ else G=1 i=H_-G p_=x<G and 0x20e or 0x67c end elseif p_>=0xec9 then if p_<=0xed2 then if p_<=0xec9 then p_=i<G and p_+-0xe44 or 0xf7e else g,p_,N=Q+P,0x1578-p_,1 C_=g-N end else p_=0xf60-p_ g(N,O,o,A,u)N,O=K[0xe648],0x28 O,g={},N-O N=O E[g]=N end elseif p_>=0xea6 then if p_>0xea6 then R_=M<=H_ G=not R_ p_=G and 0x8a9 or p_+-0x586 else N,p_,o,A,u,O,g=R_,0x8ce074/p_,P,Q,E,1,b_[0b1001][1][b_[0b1001][0b11]]end else g,N,O=g(N,O)g,N,O=B.g(g,N,O)o=g(N,O)O=o p_=O==nil and 0xaf5 or 0xcba end elseif p_>0xf90 then if p_<0xfce then if p_<=0xfa5 then p_=R_>0 and 0xb4764d/p_ or p_+-0xaec else p_=0x1052-p_ g(N,O,o,A,u)N,O=K[0xe648],0x3d A,g,u=K[0xfa7d],N-O,0b101100 o=A-u O=E[o]N=not O E[g]=N end elseif p_>=0xfe6 then if p_<=0xfe6 then p_=0x8427e/p_ G(R_,P,g,N,O)else N,G,R_,g,P=1,b_[0b111][1][b_[0b111][0b11]],E,Q+i,Q p_,g=0x66e,g-N end else G=B.h(G(R_,P,g))return B.i(G)end elseif p_>=0xf7e then if p_>0xf8f then M(i,G,R_,P,g)P,R_=0b101001,K[0xf0e]M,R_,P=R_-P,K[0xe648],0x31 i,R_,P=R_-P,K[0xfa7d],0b10 G,P=R_-P,0 R_=i==P p_=R_ and 0x1112-p_ or 0x116 elseif p_<=0xf82 then if p_>0xf7e then p_,u=0x79b,F else p_=R_~=R_ and 0x85 or p_+-0xd7f end else g(N,O,o,A,u)O,N=0b110001,K[0xe648]g,A,o=N-O,0x24,K[0xfa7d]O=o-A N=E[O]E[g]=N p_=q<A and 0x336 or 0x85 end elseif p_>=0xf40 then if p_<=0xf40 then N,g=1,Q+P p_,C_=p_+-0b10011010,g-N else P,g,R_,N,G=Q,Q+i,E,1,b_[0b111][1][b_[0b111][0b11]]p_,g=0xfce,g-N end else G=B.h(G(R_,P,g))return B.i(G)end elseif p_<=0b101000010 then if p_<0b10101010 then if p_>0b1011111 then if p_>=0x8d then if p_<0x99 then if p_<0b10010011 then if p_<0b10010000 then if p_<=0b10001101 then Q=0x80 p_=n_>Q and 0x6d or 0x6f42/p_ else Q=0b1100100 p_=n_<=Q and 0b101100010 or 0x1e206/p_ end elseif p_<=0x91 then if p_>0x90 then q,Q=0b100100,0b1000000 p_=n_<=Q and 0x31 or 0x5a0f/p_ else Q=0xab p_=n_<Q and 0x11e or 0x320 end else Q=0x50 p_=n_>Q and p_+0x40 or 0x127fe/p_ end elseif p_>0b10010110 then if p_<=0b10010111 then Q=0x76 p_=n_<=Q and 0x24d or p_+0x2c0 else Q=0b10101 p_=n_>Q and 0b110000001 or 0x44e-p_ end elseif p_>0x95 then Q=0x13 p_=n_>Q and 0x25e or 0x1fad6/p_ elseif p_<0x94 then Q=0b111 p_=n_<=Q and 0x10e-p_ or 0b10 elseif p_>0x94 then M,H_=0b110111,K[0xa0e2]G,R_,Q=K[0x5332],0x35,H_-M i=G-R_ M=E[i]p_,H_=0x85,-M E[Q]=H_ G,Q,H_,R_=K[0xf0e],b_[0b101][1][b_[0b101][0b11]],K[0xc252],0b11101 i=G-R_ M=E[i]Q[H_]=M else Q=0b100111011 p_=n_<=Q and 0b111000101 or 0b101100100-p_ end elseif p_<=0xa3 then if p_<=0x9c then if p_>=0b10011011 then if p_<=0b10011011 then Q=0b10101101 p_=n_<=Q and 0b10000001 or 0x1b7 else Q=0b11110100 p_=n_>Q and p_+0x26a or 0x3bd end elseif p_>0x99 then Q=0b110100 p_=n_<Q and 0x267 or 0b101010100 else Q=0x35 p_=n_>Q and 0b1111111 or 0b11000111 end elseif p_>0x9f then q,Q=0xc4,0b10 p_=n_<Q and 0x36b-p_ or 0x341 elseif p_<=0b10011101 then Q=0b1100110 p_=n_>Q and 0xa6d0/p_ or 0x272-p_ else Q=0b1000010 p_=n_<=Q and 0x1c3 or p_+0x30a end elseif p_>0b10100110 then if p_>0b10100111 then Q=0xcb p_=n_>Q and 0b10000110 or 0b1010011 else M,H_=0b101100,K[0xa0e2]R_,G,Q=0b1101,K[0x5332],H_-M i=G-R_ M,R_,P=E[i],K[0xf0e],0x13 G=R_-P i=E[G]H_=M<i E[Q]=H_ H_,M=K[0xe648],0b11000 Q,i,M=H_-M,0x16,K[0xfa7d]i,H_=1,M-i G,i,M=-1,nil,H_-i p_=M==G and 0x3f5-p_ or 0x1a2 end elseif p_>=0b10100101 then if p_>0b10100101 then Q,q=0xc6,0b11100010 p_=n_>Q and 0x189-p_ or 0b10111100 else Q=0b111010 p_=n_>Q and 0x260 or 0x383-p_ end else r,Q=0x42,0b11001 p_=n_<Q and 0xd740/p_ or 0x1a7 end elseif p_>=0x79 then if p_<0x84 then if p_<0b10000000 then if p_>0x7b then Q=0x39 p_=n_<=Q and 0b10110 or 0xa5 elseif p_>0b1111001 then Q=0b11 p_=n_<=Q and p_+0x28 or 0x6561/p_ else Q=0b1011000 p_=n_<=Q and 0x209-p_ or 0x1967c/p_ end elseif p_>=0x81 then if p_>0x81 then Q=0x86 p_=n_>=Q and 0b10000111 or 0x479a/p_ else M,H_=0b11101,K[0xa0e2]Q,H_=H_-M,K[0xc252]E[Q]=H_ H_,M=K[0x5332],0b101011 i,G,Q=K[0xf0e],0x17,H_-M M,i=i-G,1 H_=M==i E[Q]=H_ p_=q<=G and 0x220 or 0b10000101 end else o={}o[0b11]=N o[1]=E O=o z[N]=O p_=q>=x and 0b101001110 or 0x9f-p_ end elseif p_>=0b10000111 then if p_>0b10001000 then G,H_,i=0b101010,b_[0x11][1][b_[0b10001][0b11]],K[0x5332]M=i-G M,Q,i=K[0xa0e2],H_[M],0b1001 H_,i,G=M-i,Q[1],Q[0b11]M=i[G]E[H_]=M p_,i,M=0b10000101,0x3d,K[0xf0e]H_,M=M-i,K[0xc252]E[H_]=M elseif p_>0b10000111 then Q=0b10000 p_=n_<Q and 0b100110110-p_ or 0b11010111 else Q=0x8e p_=n_<Q and 0x5c49/p_ or p_+0x2f end elseif p_>0b10000101 then Q=0xd1 p_=n_<=Q and 0x273 or 0x13a10/p_ elseif p_>0x84 then q,r,K=0b11000,0xf1,c_[w]Q,n_=1,K[0xcfc8]Q,w=0b1100110,w+Q p_=n_<Q and 0x19 or p_+-0x3a else Q=0x56 p_=n_>Q and 0b1111001 or 0x30fc/p_ end elseif p_<0b1101100 then if p_>=0x67 then if p_<=0x69 then if p_>0b1100111 then q,Q=0b1110100,0x75 p_=n_>Q and 0x3def/p_ or 0b101010001-p_ else Q=0x43 p_=n_>Q and 0x39 or 0b10010001 end else Q,q=0b1100,0b1110 p_=n_>Q and 0b101011 or 0b10010011 end elseif p_>0x60 then Q=0x2b p_=n_>Q and 0x3b or 0b11101110 else Q=0x5a p_=n_>Q and 0xf720/p_ or 0b101100100 end elseif p_<0x74 then if p_>=0x6d then if p_<=0b1101101 then Q=0x82 p_=n_>Q and p_+0x136 or 0x26a else Q=0x27 p_=n_>Q and p_+0x329 or p_+0x2ad end else Q=0b1001 p_=n_<=Q and p_+0x34b or 0b111100111 end elseif p_>0x75 then x,Q=0x8f,0b1001001 p_=n_>Q and 0b101100010-p_ or p_+-0x1e elseif p_<=0b1110100 then r,h_,Q=0b11111101,0x9e,0x93 p_=n_>Q and p_+-0b11011 or 0xf4 else Q=0x97 p_=n_<=Q and 0xcc or 0x140-p_ end elseif p_<=0x35 then if p_>=0b11110 then if p_<=0b101010 then if p_>0x21 then if p_>=0x27 then if p_<=0x27 then Q=0xa4 p_=n_>Q and 0x721b/p_ or 0b100101111 else Q=0b100001100 p_=n_<Q and 0x3f3 or 0b110000011 end else Q=0b1011 p_=n_>Q and 0x205 or 0x362 end elseif p_<0x20 then if p_>0x1e then Q=0x61 p_=n_<Q and 0x232 or 0x28b else Q=0x52 p_=n_<=Q and p_+-1 or 0b10000100 end elseif p_>0b100000 then q,x,Q=0b100100,0b10100100,0b11000101 p_=n_>=Q and 0x270 or 0x1ad else Q,q=0b10011010,0b11001 p_=n_<=Q and 0x75 or 0x3a end elseif p_>0x32 then if p_>0x33 then Q=0xba p_=n_>=Q and p_+0x198 or 0x211 else Q=0b11010 p_=n_>Q and 0x47 or 0xa4 end elseif p_<=0b110001 then if p_>0x2c then Q,x=0b111111,0b101 p_=n_<=Q and 0b100001000 or p_+0b111110100 elseif p_>0b101011 then Q=0b1101000 p_=n_>=Q and 0b10110101 or 0x9d else Q=0x12 p_=n_<=Q and 0x88 or 0x40 end else Q=0xac p_=n_>Q and 0x1e46/p_ or p_+0x5e end elseif p_<0b10001 then if p_>=0b111 then if p_>=0b1100 then if p_<=0b1100 then Q=0b1000111 p_=n_>Q and 0b110101001 or 0x3bc else Q=0x2f p_=n_>Q and p_+0x376 or 0x2e2 end else x,Q=0xf6,0x114 p_=n_<Q and 0xaa or 0b11111111-p_ end elseif p_>=0b10 then if p_<=0b10 then Q=0b1010 p_=n_<=Q and 0xd8/p_ or 0x27-p_ else Q=0b1000101 p_=n_<Q and 0x1f4 or 0b101100111 end else Q=0x11e p_=n_>Q and 0x2fb-p_ or p_+0x1e1 end elseif p_>0b10110 then if p_>0b11001 then Q=0b1001110 p_=n_>Q and 0x92 or 0b101111-p_ else r,x,Q,h_=0xb6,0xb3,0b101110,0b11000110 p_=n_>=Q and 0xb86/p_ or 0x11f8/p_ end elseif p_>0b10100 then Q=0b111000 p_=n_>Q and p_+0b101010011 or p_+0x27e elseif p_<=0b10010 then if p_>0x11 then Q=0x4d p_=n_<Q and 0x130 or p_+0x2eb else Q=0xc1 p_=n_<=Q and 0x38d or 0b101011110 end else Q=0x23 p_=n_<=Q and 0x37f-p_ or p_+0x203 end elseif p_>0b1001000 then if p_>0b1010011 then if p_<0b1011001 then if p_>0b1010101 then Q,r,q=0b111011,0b10010111,0b11001000 p_=n_>Q and 0b1100111 or 0b10011001 else Q=0b101001001 p_=n_<Q and p_+0xa4 or 0b100110011-p_ end elseif p_<=0x5e then if p_>0b1011001 then Q=0b100010100 p_=n_>Q and 0x15a42/p_ or 0x377-p_ else x,Q=0x50,0xa1 p_=n_<Q and p_+-0x39 or 0xb1 end else Q=0b1010101 p_=n_<Q and p_+0x321 or 0x26e end elseif p_>0x4e then if p_<=0b1010001 then Q=0xf5 p_=n_>Q and 0x264-p_ or p_+0b1001011 else Q=0xc9 p_=n_>Q and 0b10100111 or 0x2bc-p_ end elseif p_>=0x4d then if p_>0x4d then Q=0b100010 p_=n_<Q and 0b100101110-p_ or 0x48 else Q,q=0b11100011,0xe1 p_=n_>=Q and 0x236 or p_+0b110101110 end elseif p_<=0b1001011 then x,Q=0x18,0b10101111 p_=n_>=Q and 0b10001110-p_ or p_+0b101001 else M,H_=0x35,K[0xa0e2]i,Q,M=K[0xc252],H_-M,b_[0b101][1][b_[0b101][0b11]]H_=M[i]E[Q]=H_ H_,M=K[0x5332],0b111110 H_,Q=K[0xb54d],H_-M p_,E[Q]=0x85,H_ end elseif p_<0x42 then if p_<=0b111010 then if p_>=0x39 then if p_>0b111001 then Q=0b10011111 p_=n_>=Q and 0x121-p_ or 0xf2 else Q=0x46 p_=n_<=Q and 0x3d-p_ or 0b1100 end elseif p_>0b110110 then q,x,Q=0b1000100,0x9f,0b1011100 p_=n_>=Q and 0x12c-p_ or 0b10010111-p_ else Q=0x10a p_=n_>=Q and 0x60-p_ or 0x105-p_ end elseif p_<=0b111011 then Q=0b101100 p_=n_>Q and 0b111101110 or 0x4c84/p_ else Q=0b10101 p_=n_>=Q and 0b10011000 or 0x2580/p_ end elseif p_<=0b1000101 then if p_<=0x44 then if p_>0x43 then Q,q,x=0b100011010,0b1111010,0b10111001 p_=n_<Q and 0x5e or p_+-0b1000100 elseif p_<=0x42 then x,Q,q=0x2a,0b100110,0b11101011 p_=n_>=Q and 0b1101111 or 0b1010110-p_ else q,Q=0b10100101,0b11101010 p_=n_>Q and 0b111010101/p_ or 0x2b72/p_ end else M,i=K[0xa0e2],0b111 H_=M-i Q,G,i=E[H_],0x3c,K[0x5332]M=i-G G,H_,R_=K[0xf0e],E[M],0b101 i=G-R_ M=E[i]Q[H_]=M p_=q>R_ and 0x85 or 0b111000111 end elseif p_>0b1000111 then Q=0x28 p_=n_<=Q and 0x1290/p_ or 0x1c68/p_ else Q=0b11011 p_=n_>Q and p_+0x354 or 0b100011111 end elseif p_>0b11110010 then if p_>=0b100011100 then if p_<0b100110010 then if p_>0b100100101 then if p_>0b100101101 then if p_<=0x12f then M,H_=0b1000,K[0xa0e2]Q,M=H_-M,{}H_=M E[Q]=H_ M,H_=0x25,K[0x5332]H_,Q=K[0xc252],H_-M p_,E[Q]=0b10000101,H_ else Q=0b1001011 p_=n_>Q and p_+-0b100011 or 0x34f end elseif p_>=0x12b then if p_>0x12b then p_,w=0x9c61/p_,w+i else p_=i and 0b111101001-p_ or 0x3aa end else H_,i,G=b_[0b10001][1][b_[0b10001][0b11]],K[0x5332],0x15 M=i-G Q=H_[M]R_,M,H_,P=K[0xa0e2],Q[0b11],Q[1],0x1b G=R_-P i=E[G]H_[M]=i R_,M,G=0x3e,b_[0b10001][1][b_[0b10001][0b11]],K[0xe648]p_,i=0b10000101,G-R_ i,H_,G=K[0xf0e],M[i],0x17 M,G,R_=i-G,H_[1],H_[0b11]i=G[R_]E[M]=i end elseif p_>0b100011111 then if p_<=0b100100001 then p_,M[i]=0x685,O else H_,M=K[0xa0e2],0x15 R_,Q,G=0b1110,H_-M,K[0x5332]i=G-R_ R_,M,P=K[0xf0e],E[i],0b10010 G=R_-P i=E[G]H_=M~=i E[Q]=H_ M,H_=0x3d,K[0xe648]Q,M,i=H_-M,K[0xfa7d],0b110100 H_,i=M-i,1 G,M,i=-1,H_-i,nil p_=M==G and 0x2ff-p_ or 0x3aa-p_ end elseif p_>0x11e then q,G,i=0b10111010,0b100,K[0xa0e2]i,G,Q=K[0x5332],0b110101,i-G G,H_,i=0b10100,i-G,K[0xf0e]M,G=i-G,0 i=H_==G p_=i and 0x45701/p_ or 0x29b-p_ elseif p_>0b100011101 then Q=0b10101000 p_=n_<=Q and 0x2b5 or 0x391 elseif p_>0b100011100 then p_,i=p_+0x1be,C_-Q else R_,M,i,p_,g,G,P=H_,b_[0b1001][1][b_[0b1001][0b11]],j[0xb505],0x10ac-p_,E,1,Q end elseif p_<0b100111001 then if p_>0b100110101 then if p_>0x136 then P,R_=0b111,K[0x95df]p_,G=0x85,R_-P w=w+G else H_=j[0x78d]i,M=1,Q+H_ C_=M-i p_=q<i and 0xae or 0b100011100 end elseif p_>0b100110100 then R_=i<=H_ G=not R_ p_=G and 0x2badf/p_ or 0xaba elseif p_>=0x133 then if p_<=0b100110011 then Q=0b10101111 p_=n_<=Q and 0b111000111 or 0x27f else M,H_=0b110011,K[0xa0e2]M,Q,i=K[0x5332],H_-M,0b1101 i,H_,G=K[0x59a2],M-i,0b100110 M,R_,G=i-G,0b10000,K[0x95df]i,G,R_=G-R_,E[Q],E[H_]p_=G<=R_ and 0x4a5e4/p_ or 0x1a4 end else G,p_,q,R_=E[Q],p_+0xc4f,0xe9,b_[0b1110][1][b_[0b1110][0b11]]P,o,N,g=G,1,E,b_[0b111][1][b_[0b111][0b11]]o,O=Q+i,Q+o end elseif p_<=0b100111110 then if p_<0x13d then if p_<=0b100111001 then M,H_=0b11101,K[0xa0e2]G,R_,Q=K[0x5332],0b100,H_-M i=G-R_ p_,M,R_,P=0x85,E[i],K[0xf0e],0b1000 G=R_-P i=E[G]H_=M~=i E[Q]=H_ else i,G=K[0xa0e2],0b11010 G,i,Q=0b111001,K[0x5332],i-G G,i,H_=0b100000,K[0xf0e],i-G M,G=i-G,0 i=H_==G p_=i and p_+-0b1110110 or 0x3bf-p_ end elseif p_>0x13d then H_,M=K[0xa0e2],0x1c M,i,Q=K[0x5332],0x38,H_-M i,H_=1,M-i i,M,G=nil,H_-i,-1 p_=M==G and 0x244 or 0x32f-p_ else p_,i=0x159,C_-Q end elseif p_>0b100111111 then H_,M=K[0xa0e2],0x3a G,Q,i=0b10,H_-M,K[0x5332]M=i-G H_=E[M]E[Q]=H_ M,H_=0b1101,K[0xf0e]Q,R_,G=H_-M,0x3f,K[0xe648]i=G-R_ p_,M=0x85,E[i]H_=-M E[Q]=H_ else H_,M=K[0xa0e2],0x13 M,Q={},H_-M H_=M E[Q]=H_ H_,M=K[0x5332],0x34 G,i,Q=0x3c,K[0xf0e],H_-M p_,M=0xa5bb/p_,i-G H_=E[M]E[Q]=H_ end elseif p_>=0x102 then if p_<=0x10d then if p_<=0x108 then if p_<=0b100000111 then if p_<0b100000100 then M,H_=0b10100,K[0xa0e2]R_,G,Q=0x3e,K[0x5332],H_-M i=G-R_ P,R_,M=0b1100,K[0xf0e],E[i]G=R_-P i=E[G]H_=M<=i E[Q]=H_ p_=q<P and 0b10110101 or 0b10000101 elseif p_<=0b100000100 then Q=0b10100001 p_=n_<=Q and 0x2b0 or 0x29c-p_ else P=R_[0b11]p_=P>=Q and 0x16cb5/p_ or p_+0x924 end else Q=0b111110 p_=n_<=Q and 0x202 or 0x4ae-p_ end elseif p_>0x10b then i,M=0b11,K[0xa0e2]H_=M-i i,G,Q=K[0x5332],0x3e,E[H_]M=i-G R_,G,H_=0b111,K[0xf0e],E[M]i=G-R_ M=E[i]Q[H_]=M H_,i,G=b_[0b10001][1][b_[0x11][0b11]],K[0xfa7d],0b11011 M=i-G M,Q,i=K[0xe648],H_[M],0b1101 G,H_,p_,i=Q[0b11],M-i,0b110010010-p_,Q[1]M=i[G]E[H_]=M elseif p_>0b100001010 then N,g=1,Q+P C_=g-N p_=q>=N and 0xdfb78/p_ or 0xa2b else G=1 p_,i=0xf4e-p_,H_-G end elseif p_<=0x116 then if p_<=0x115 then if p_<=0b100010000 then H_,M=K[0xa0e2],0b101000 R_,Q,G=0b1011,H_-M,K[0x5332]i=G-R_ R_,M,P=K[0xf0e],E[i],0b101101 G=R_-P i=E[G]H_=M*i E[Q]=H_ H_,M=K[0xe648],0x15 Q,M,i=H_-M,K[0xfa7d],0x20 i,H_=1,M-i M,i,G=H_-i,nil,-1 p_=M==G and 0x3a7 or 0b110011010 else H_,G,i=b_[0b10001][1][b_[0b10001][0b11]],0b111010,K[0x5332]M=i-G Q,i,M=H_[M],0x26,K[0xa0e2]i,H_,G=Q[1],M-i,Q[0b11]M=i[G]E[H_]=M H_,G,i=K[0xf0e],K[0xc252],b_[0b101][1][b_[0b101][0b11]]p_,M=0x85,i[G]E[H_]=M end else p_=R_ and 0xbd3 or 0x814b6/p_ end elseif p_<=0x118 then G,R_=H_(M,i)i=G p_=i==nil and 0x85 or 0x37c-p_ else H_=j[0x78d]i,M=1,Q+H_ p_,C_=0x2e4,M-i end elseif p_<=0b11111000 then if p_>0xf6 then if p_>0b11110111 then r,q,h_,Q=0b1110,0xc0,0b10011001,0b100110111 p_=n_<Q and 0b100111100-p_ or 0b1010101 else x,Q=0x66,0b11101111 p_=n_<=Q and 0x2c3 or 0b110110101 end elseif p_<0b11110101 then if p_>0b11110011 then Q,x,r,q=0x7b,0b10110,0x85,0xc9 p_=n_<Q and 0b10110011 or p_+-0b1110010 else Q,x=0xe6,0x84 p_=n_<=Q and 0b1001101 or 0xba end elseif p_<=0b11110101 then Q=0x5d p_=n_<Q and 0b1000101 or 0x100 else p_=i and 0x44e-p_ or 0x365-p_ end elseif p_>0xfe then if p_>0xff then Q=0b1011101 p_=n_<=Q and 0x230 or 0x1ab else z,p_,L,C_,m,w,f=b_[1][1][b_[1][0b11]],0x322,{},-1,0b100,1,0b11010100 L,e=b_[0b1111][1][b_[0b1111][0b11]],L end elseif p_>0b11111101 then H_,M=K[0xa0e2],0x16 Q,i,G=H_-M,K[0x5332],0b100 M=i-G H_=E[M]E[Q]=H_ p_=x>=G and p_+-0b1111001 or p_+0x4e elseif p_>0b11111001 then Q=0x5f p_=n_<Q and 0x134-p_ or p_+-0x24 else Q=0b100111011 p_=n_<Q and 0x339-p_ or 0x8ff4/p_ end elseif p_>=0b11001000 then if p_>0b11011001 then if p_>0xe7 then if p_<0xec then if p_>0b11101000 then Q=0b10110101 p_=n_>Q and 0x11f-p_ or 0xb7ba/p_ else Q=0x73 p_=n_<Q and 0b111001110 or 0b101111110 end elseif p_<=0b11101110 then if p_>0xec then Q=0x2a p_=n_<=Q and 0x2d4 or 0b10110100 else Q=0b1011001 p_=n_>Q and p_+0b10001 or 0x1e end else Q=0x9b p_=n_>Q and 0b110001110 or 0x2fa end elseif p_>0b11100100 then if p_>0b11100110 then Q=0x9f p_=n_>Q and 0x160 or 0x30e else Q=0b10010100 p_=n_<=Q and 0x3ff or 0x2bb end elseif p_>=0b11100011 then if p_<=0b11100011 then Q=0b11011110 p_=n_>=Q and p_+0x10 or 0x95db/p_ else Q=0xc3 p_=n_>=Q and 0x21 or 0xf24/p_ end elseif p_>0xde then Q=0x1c p_=n_>Q and 0x9a00/p_ or 0x33 else Q=0x14c p_=n_<=Q and 0x278 or 0x39f-p_ end elseif p_>0xd0 then if p_>=0b11010111 then if p_>=0xd8 then if p_<=0b11011000 then Q=0b10100010 p_=n_>Q and 0x49a-p_ or p_+0x2c else Q=0b1100011 p_=n_<=Q and p_+-0xba or p_+-0b1001011 end else Q=0x11 p_=n_>Q and 0x3c7 or 0x408-p_ end elseif p_<=0xd3 then if p_>0xd2 then Q=0b110 p_=n_>Q and 0x2ef or 0x1a6 else M,H_=0x22,K[0xa0e2]R_,G,Q=0b1011,K[0x5332],H_-M i=G-R_ G,p_,M=K[0xf0e],0x6d1a/p_,E[i]i=E[G]H_=M/i E[Q]=H_ end else o={}o[0b11]=N o[1]=E O=o p_,z[N]=0x257,O end elseif p_>0xcb then if p_<=0xcf then if p_<=0b11001100 then Q=0b10010110 p_=n_>=Q and 0x31e or 0xe6 else Q=0x107 p_=n_<=Q and 0b100110100 or p_+0x176 end else G,i=0x16,K[0xa0e2]G,i,Q=0x3a,K[0x5332],i-G G,i,H_=0b111100,K[0xf0e],i-G G,M=0,i-G i=H_==G p_=i and 0x271 or p_+0x2d3 end elseif p_<=0b11001010 then if p_<=0xc9 then if p_>0b11001000 then Q=0xb3 p_=n_>=Q and 0x1eb82/p_ or p_+0b1101010 else H_,M=K[0xa0e2],0x1a H_,Q=nil,H_-M E[Q]=H_ H_,M=K[0x5332],0x33 i,H_,M,Q=nil,z,nil,H_-M H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0b101001101-p_ or 0x242 end else Q=0b1111101 p_=n_>=Q and 0x2001a/p_ or 0x29d end else Q=0b10011001 p_=n_>Q and p_+0x21d or 0x375 end elseif p_<0xb8 then if p_>0xb2 then if p_<=0b10110101 then if p_<=0b10110100 then if p_>0xb3 then H_,M=K[0xa0e2],0b101010 Q,i,M,H_=H_-M,nil,nil,z H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0b10000101 or 0x264 else Q=0x6e p_=n_<Q and 0b101100 or 0x496b/p_ end else Q=0b1101001 p_=n_>=Q and 0x2c7 or 0x1e4 end elseif p_>0xb6 then H_,M=K[0xa0e2],0b1100 G,Q,R_=K[0x5332],H_-M,0b110000 i=G-R_ P,M,R_=0x3b,E[i],K[0xf0e]G=R_-P i=E[G]H_=M[i]E[Q]=H_ p_=q<=P and 0b11100000 or 0x85 else Q=0x91 p_=n_<Q and 0xde86/p_ or 0x30b end elseif p_<=0xaf then if p_>0xae then q,Q=0xc6,0b10000111 p_=n_>=Q and 0x3f0 or 0x474-p_ elseif p_<=0xab then if p_>0xaa then p_,G=0x247,1 i=H_-G else Q=0x107 p_=n_<Q and 0x7f80/p_ or 0b110110 end else Q=0b1110 p_=n_<=Q and 0x206 or 0x1bf end elseif p_>=0b10110001 then if p_>0xb1 then Q=0b10100011 p_=n_<=Q and p_+0b100110 or 0x27 else q,Q=0x9f,0b10101000 p_=n_<Q and 0b10110010 or 0x32 end else Q=0b100000 p_=n_>Q and 0x4c or p_+0b10101 end elseif p_<0xc2 then if p_>0xbe then if p_<=0b10111111 then H_,M=K[0xa0e2],0b110000 M,Q={},H_-M H_=M E[Q]=H_ H_,M=K[0x5332],0b1000 Q,i,M=H_-M,K[0xc252],b_[0b101][1][b_[0b101][0b11]]H_=M[i]E[Q]=H_ p_=q>=x and 0b10000101 or 0x18635/p_ else Q=0b11110100 p_=n_>=Q and 0b1010001 or 0xf7 end elseif p_>=0b10111100 then if p_<=0b10111100 then Q=0xc0 p_=n_<=Q and 0b11101010 or 0b110100000-p_ else q,G,R_=0x68,E[Q],b_[0b1110][1][b_[0b1110][0b11]]P,g,p_,N,o=G,b_[0b111][1][b_[0b111][0b11]],0x4a6-p_,E,1 O,o=Q+o,Q+i end elseif p_<=0b10111000 then q,Q=0x31,0x16 p_=n_<=Q and 0x6a or 0x4e else Q=0xe8 p_=n_<=Q and 0xc942/p_ or 0x3b4 end elseif p_>0xc5 then if p_>0b11000110 then Q=0x31 p_=n_<Q and 0b1101 or 0b10011010 else p_,i=p_+0x1bd,C_-Q end elseif p_>=0b11000100 then if p_<=0xc4 then p_,w=0b10000101,w+M else Q=0b11111 p_=n_<=Q and 0x2d5-p_ or 0x472-p_ end elseif p_<=0xc2 then p_,i=0x460-p_,C_-Q else p_,g,N=0xcb1,Q+P,1 C_=g-N end elseif p_<=0x212 then if p_<=0b110110010 then if p_<0x179 then if p_<0b101011110 then if p_<0x150 then if p_>0b101001100 then if p_<=0x14d then M,H_=0x2c,K[0xa0e2]i,G,Q=K[0x5332],0b111100,H_-M M,i=i-G,1 H_=M==i E[Q]=H_ M,i=K[0xf0e],0b10011 H_=M-i G,Q,i=0b11001,E[H_],K[0xe648]M=i-G G,R_,H_=K[0xfa7d],0b11100,E[M]i=G-R_ M=E[i]Q[H_]=M p_=q<=R_ and p_+0x1de or 0x1d2-p_ else M[i]=O p_=r>h_ and 0x1b3c4/p_ or 0xf2e-p_ end elseif p_<=0b101001011 then if p_>0x14a then N,g=R_[0b11],R_[1]P=g[N]p_,R_[0b10]=0b100011000,P R_[1]=R_ P=0b10 R_[0b11]=P P=nil z[G]=P elseif p_<=0b101000101 then N,g=1,Q+P C_=g-N p_=r<N and 0x359 or 0xc4617/p_ else G=1 i=H_-G p_=q<G and p_+-0b100011000 or 0x13dc10/p_ end else M,H_=0b100100,K[0xa0e2]G,Q,R_=K[0x5332],H_-M,0b11 i=G-R_ M,i=E[i],K[0xc252]H_=M[i]E[Q]=H_ H_,M=K[0xf0e],0x2e Q,H_=H_-M,nil E[Q]=H_ p_=q<R_ and p_+-0x13b or 0b10000101 end elseif p_>0x158 then if p_<=0x159 then p_=i and 0x32a or 0x37e else M,i=K[0x5332],0b111100 i,H_,G,M=nil,M-i,nil,z M,i,G=B.g(M,i,G)R_,P=M(i,G)G=R_ p_=G==nil and 0x85 or 0x239 end elseif p_>0b101010100 then g,N=R_[1],R_[0b11]P=g[N]R_[0b10]=P R_[1]=R_ P=0b10 R_[0b11]=P P=nil z[G]=P p_=q>x and p_+0x45c or 0x965-p_ elseif p_<=0x153 then if p_>0x150 then p_,i=0x12b,C_-Q else Q=0b10111 p_=n_>Q and p_+0x234 or 0x464d0/p_ end else Q=0x34 p_=n_>Q and 0x401-p_ or 0x4f6-p_ end elseif p_>=0b101101000 then if p_>0x16e then if p_<=0b101110000 then N=R_(P,g)g=N p_=g==nil and 0x1e5 or 0x2e3 else g,P=1,c_[w]w,g,N=w+g,P[0xa0e2],1 p_=g==N and 0x53e-p_ or 0x21d end elseif p_<0x16a then if p_>0x168 then H_,M=K[0xa0e2],0b1010 Q,G,R_=H_-M,K[0x5332],0b101100 i=G-R_ R_,M,P=K[0xf0e],E[i],0b1110 G=R_-P i=E[G]H_=M*i p_,E[Q]=0x85,H_ else P,g=c_[w],1 w,N,g=w+g,1,P[0xa0e2]p_=g==N and 0x2f8 or 0x3e1 end elseif p_<=0x16a then H_,M=K[0xa0e2],0b10100 Q,M,i=H_-M,K[0x5332],0x1c H_,G,i=M-i,0x30,K[0x59a2]G,M,R_=K[0x95df],i-G,0x39 G,R_,i=E[Q],E[H_],G-R_ p_=G<R_ and p_+0b10000011 or 0x4a6-p_ else H_=j[0x78d]p_,i,M=0x5a6d8/p_,1,Q+H_ C_=M-i end elseif p_>=0x163 then if p_>=0x164 then if p_>0x164 then Q=0b1000101 p_=n_<=Q and p_+0x17e or p_+0b111011110 else H_,M=K[0xa0e2],0b1000 R_,G,Q=0b101000,K[0x5332],H_-M i=G-R_ M=E[i]p_,H_=p_+-0b11011111,#M E[Q]=H_ H_,M=K[0xf0e],0x16 R_,G,Q=0x21,K[0xe648],H_-M i=G-R_ M,R_,P=E[i],K[0xfa7d],0x1e G=R_-P i=E[G]H_=M/i E[Q]=H_ end else g,N=R_[1],R_[0b11]P=g[N]R_[0b10]=P R_[1]=R_ p_,P=0xa2b,0b10 R_[0b11]=P P=nil z[G]=P end elseif p_<0b101100000 then M,H_=0b1101,K[0xa0e2]H_,p_,Q=nil,0b10000101,H_-M E[Q]=H_ elseif p_>0b101100000 then M,H_=0b1111,K[0xa0e2]Q,i,M=H_-M,K[0xc252],b_[0b101][1][b_[0b101][0b11]]p_,H_=0xb7ea/p_,M[i]E[Q]=H_ H_,M=K[0x5332],0x2c Q,M=H_-M,{}H_=M E[Q]=H_ else M,i=K[0xa0e2],0b100011 H_=M-i G,i,Q=0b110010,K[0x5332],E[H_]M=i-G G,R_,H_=K[0xf0e],0b1111,E[M]i=G-R_ M=E[i]Q[H_]=M H_,M=K[0xe648],0b111011 Q,R_,G=H_-M,0b1010,K[0xfa7d]i=G-R_ p_,M=0x85,E[i]H_=not M E[Q]=H_ end elseif p_>0b110011010 then if p_>=0x1a9 then if p_<0b110101101 then if p_>=0b110101010 then if p_>0b110101010 then H_,M=K[0xa0e2],0x3f i,Q=1,H_-M M=Q+i H_,G=E[M],0b10 i=Q+G G,M=E[Q],E[i]i=G+M E[Q]=i G=0 p_=M>G and 0x20367/p_ or 0x3fc else _=k(F,a_)a_=_ p_=a_==nil and 0x378 or 0x212 end else H_,M=K[0xa0e2],0b1001 i,H_,Q,M=nil,z,H_-M,nil H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and p_+-0x4c or p_+0x248 end elseif p_>=0x1af then if p_<=0b110101111 then M,H_=0b101,K[0xa0e2]M,Q,i=K[0x5332],H_-M,0b100 i,H_=1,M-i G,M=0b10,Q+i i,p_,o,g=Q+G,0x64c,1,E[Q]O=Q+o A,N=G,E[O]o=Q+A O,A,u=E[o],b_[0b1000][1][b_[0b1000][0b11]],g else i,H_,G=K[0x5332],b_[0b10001][1][b_[0b10001][0b11]],0b111111 M=i-G M,Q,i=K[0xa0e2],H_[M],0b1011 G,H_,i=Q[0b11],M-i,Q[1]M=i[G]E[H_]=M i,G=K[0xf0e],0x39 M=i-G R_,G,H_=0b1001,K[0xe648],E[M]i=G-R_ P,M,R_=0b111011,E[i],K[0xfa7d]G=R_-P i=E[G]H_[M]=i p_=q<=P and p_+-0x12d or 0x258 end else M,H_=0b1100,K[0xa0e2]Q,M,i,H_=H_-M,nil,nil,z H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0x220 or p_+-0b10100110 end elseif p_<0x1a4 then if p_<=0b110100010 then p_,G=0x281,1 i=H_-G else H_,M=K[0xa0e2],0b101001 R_,Q,G=0b101110,H_-M,K[0x5332]i=G-R_ P,R_,M=0x36,K[0xf0e],E[i]G=R_-P i=E[G]p_,H_=0b10000101,M-i E[Q]=H_ M,H_=0b100001,K[0xe648]G,Q,i=0b10001,H_-M,K[0xfa7d]M=i-G H_=E[M]E[Q]=H_ end elseif p_<0b110100110 then p_,w=0xda34/p_,w+i elseif p_>0x1a6 then Q=0b11001 p_=n_<=Q and 0x338 or 0x1af else Q=0b100 p_=n_<=Q and 0x5a4-p_ or 0x191 end elseif p_>=0b110000100 then if p_>=0b110010000 then if p_<=0x198 then if p_>=0b110010001 then if p_<=0x191 then i,G=K[0xa0e2],0b1010 G,Q,i=0b11011,i-G,K[0x5332]H_,G,i=i-G,0b110101,K[0xf0e]G,M=0,i-G i=H_==G p_=i and 0x248 or 0x4dd4b/p_ else H_,M=K[0xa0e2],0x3c i,G,Q=K[0x5332],0b101001,H_-M i,M=1,i-G H_=M==i E[Q]=H_ M,H_=0x3c,K[0xf0e]Q,G,R_=H_-M,K[0xe648],0b10110 i=G-R_ p_,P,M,R_=0b10000101,0b10100,E[i],K[0xfa7d]G=R_-P i=E[G]H_=M~=i E[Q]=H_ end else H_,M=K[0xa0e2],0b100 M,i,Q=K[0x5332],0b111010,H_-M H_,G,i=M-i,0x16,K[0x59a2]G,M,R_=K[0x95df],i-G,0x2c R_,G,i=E[H_],E[Q],G-R_ p_=G==R_ and 0x356 or 0x38d60/p_ end else G=1 i=H_-G p_=r<=G and p_+-0b101100011 or 0x28d end elseif p_>0b110001100 then H_,M=K[0xa0e2],0b1000 Q,M=H_-M,{}H_=M E[Q]=H_ i,p_,M=0x25,0xcec6/p_,K[0x5332]H_=M-i G,Q,H_,R_=K[0xf0e],E[H_],K[0xc252],0b101001 i=G-R_ M=E[i]Q[H_]=M elseif p_>0x184 then H_,G,R_,Q=K[0xc252],K[0xa0e2],0b10011,b_[0b101][1][b_[0b101][0b11]]i=G-R_ M=E[i]Q[H_]=M H_,M=K[0x5332],R_ p_,H_,Q=0b10000101,K[0xb54d],H_-M E[Q]=H_ else p_,G=p_+0b10101101,1 i=H_-G end elseif p_<0x181 then if p_<=0b101111100 then if p_<=0b101111001 then p_,w=p_+-0xf4,w+M else p_=i and 0b111110000 or 0x3a8a4/p_ end else Q,q=0x73,0xed p_=n_<=Q and 0x343 or 0xb7 end elseif p_>=0b110000010 then if p_>0x182 then Q=0b100001100 p_=n_>Q and p_+-0x5c or 0x33f-p_ else p_,R_=0x298-p_,C_-M end else G,Q,H_,R_=K[0xa0e2],b_[0b101][1][b_[0b101][0b11]],K[0xc252],0x2c i=G-R_ M=E[i]Q[H_]=M M,H_=0b110000,K[0x5332]Q,i,G=H_-M,K[0xf0e],0b100010 M,i=i-G,1 H_=M==i E[Q]=H_ p_=q<R_ and 0b10000101 or p_+0x234 end elseif p_>=0b111101010 then if p_>=0b111111111 then if p_<=0x20b then if p_>=0x205 then if p_<0x207 then if p_>0x205 then Q=0b1101 p_=n_>Q and 0x2f6 or 0x43a-p_ else H_,M=K[0xa0e2],0b11 Q,G,i=H_-M,0b1011,K[0x5332]i,M=1,i-G H_=M==i p_,E[Q]=p_+-0b110000000,H_ H_,R_,Q,G=K[0xc252],0b101011,b_[0b101][1][b_[0b101][0b11]],K[0xf0e]i=G-R_ M=E[i]Q[H_]=M end elseif p_>0x207 then p_,w=p_+-0x186,w+M else p_,i,M=0xc24,0b1000,K[0xf0e]H_=M-i M,Q,i=K[0x5332],e[H_],0b10101 H_,M=M-i,b_[0b1011][1][b_[0b1011][0b11]]i=H_ end elseif p_<0x202 then P,g,q,x=c_[w],1,0x52,0x70 w,g,N=w+g,P[0xa0e2],1 p_=g==N and 0x28e or 0x38e elseif p_>0x202 then i,p_,M=0b1010,0x85,K[0xa0e2]H_=M-i H_,Q,R_,G=K[0xc252],E[H_],0x21,K[0x5332]i=G-R_ M=E[i]Q[H_]=M H_,M=K[0xf0e],0b100011 Q,M=H_-M,{}H_=M E[Q]=H_ else Q,q,r=0x3d,0b1110000,0xd3 p_=n_<=Q and p_+-0b100000100 or 0x2d6d4/p_ end elseif p_<0x210 then if p_>0x20d then p_,i=0x423-p_,C_-Q else p_=i>G and 0x5163f/p_ or p_+0xb5d end elseif p_>0x211 then v,l=b_[0b11][1][b_[0b11][0b11]],0x31 p_,s_,l,J=p_+0xa20,u*l,b_[0b100][1][b_[0b100][0b11]],_ elseif p_<=0x210 then Q=0x1d p_=n_<=Q and 0x4c2-p_ or 0x13c else H_,M=K[0xa0e2],0b10 G,Q,R_=K[0x5332],H_-M,0x18 i=G-R_ R_,P,M=K[0xf0e],0x2c,E[i]G=R_-P i=E[G]H_=M+i E[Q]=H_ M,H_=0x3c,K[0xe648]M,Q={},H_-M H_=M p_,E[Q]=0b10000101,H_ end elseif p_<=0x1f1 then if p_>=0b111101110 then if p_<0b111110000 then i,M=0x10,K[0xa0e2]H_=M-i i,H_,p_,Q=K[0x5332],K[0xc252],0x273-p_,E[H_]M=E[i]Q[H_]=M M,H_=0b110100,K[0xf0e]H_,Q=nil,H_-M E[Q]=H_ elseif p_<=0b111110000 then R_,G=b_[0b1110][1][b_[0b1110][0b11]],E[Q]o,N,g,P=1,E,b_[0b111][1][b_[0b111][0b11]],G O,p_,o=Q+o,0x43920/p_,Q+i else p_,G=0x2ab,1 i=H_-G end elseif p_<0x1eb then p_,M,H_=0x85,0x1a,K[0xa0e2]Q,i,M=H_-M,K[0xc252],b_[0b101][1][b_[0b101][0b11]]H_=M[i]E[Q]=H_ elseif p_>0x1eb then p_,w=p_+-0b101101000,w+M else G=1 p_,i=p_+0x82a,H_-G end elseif p_>=0b111110111 then if p_<=0x1fa then if p_<=0x1f7 then M,H_=0x12,K[0xa0e2]M,Q={},H_-M H_=M E[Q]=H_ H_,M=K[0x5332],0b100011 Q,G,i=H_-M,0b10100,K[0xf0e]M,i=i-G,1 H_=M==i E[Q]=H_ p_=q<i and 0x230 or 0b10000101 else p_,R_,G=0xe44,1,C_-Q i=G+R_ end else Q=0b11011110 p_=n_>Q and 0x3b9-p_ or 0x34c end elseif p_<=0x1f4 then M,H_=0b1001,K[0xa0e2]i,Q,M=K[0xc252],H_-M,b_[0b101][1][b_[0b101][0b11]]H_=M[i]E[Q]=H_ M,H_=0b1101,K[0x5332]Q,H_=H_-M,nil p_,E[Q]=0x103c4/p_,H_ else g,N=Q+P,1 p_,C_=0x512,g-N end elseif p_>0x1cb then if p_<0x1df then if p_>0x1ce then if p_<=0b111010101 then H_,M=K[0xa0e2],0b110101 M,Q={},H_-M H_=M E[Q]=H_ M,H_=0x2d,K[0x5332]Q,M=H_-M,{}H_=M E[Q]=H_ p_=q>x and 0xf3a9/p_ or 0x846-p_ else R_,G=1,C_-Q p_,i=p_+0xa36,G+R_ end elseif p_>0b111001101 then Q=0x6e p_=n_>Q and 0b100111111 or p_+0x15d elseif p_<=0x1cc then p_,w=0xeefc/p_,w+i else Q=0b10111010 p_=n_>Q and p_+0x197 or 0x25b end elseif p_>=0x1e4 then if p_<0x1e5 then H_,i,G=b_[0b10001][1][b_[0b10001][0b11]],K[0x5332],0x12 M=i-G M,i,Q=K[0xa0e2],0x3b,H_[M]G,H_,i=Q[0b11],M-i,Q[1]M=i[G]E[H_]=M G,R_=K[0xf0e],0b100100 R_,H_,G=0x16,G-R_,K[0xe648]R_,G,M=0b11,K[0xfa7d],G-R_ i,R_=G-R_,0 G=M==R_ p_=G and p_+0xcb or 0x254 elseif p_<=0x1e5 then p_,M=0x32c,G else M,H_=0b100010,K[0xa0e2]M,Q,H_,i=nil,H_-M,z,nil H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and p_+0b1111010 or 0x454-p_ end elseif p_>=0x1e1 then if p_<=0b111100001 then Q=0b100011010 p_=n_<=Q and 0x49bf4/p_ or 0x3f6 else H_,M=K[0xa0e2],0b100010 p_,Q=p_+0xc42,H_-M i,H_=b_[0b1000][1][b_[0b1000][0b11]],E[Q]G=H_ end else p_,i=0b11110110,C_-Q end elseif p_<=0x1bf then if p_>=0b110111010 then if p_<=0b110111110 then if p_<0x1bc then R_,p_,G=1,0xf68,C_-Q i=G+R_ elseif p_>0b110111100 then M,q,x,i=K[0xa0e2],0b1011000,0b1100,0b110100 H_=M-i G,i,Q=0x2a,K[0x5332],E[H_]M=i-G G,H_,R_=K[0xf0e],E[M],0x20 i=G-R_ M=E[i]Q[H_]=M M,H_=0x3c,K[0xe648]i,Q,M,H_=nil,H_-M,nil,z H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0xe7b6/p_ or p_+0xf6 else M,H_=0b10110,K[0xa0e2]G,R_,p_,Q=K[0x5332],0b100110,0xe6ac/p_,H_-M i=G-R_ R_,M,P=K[0xf0e],E[i],1 G=R_-P i=E[G]H_=M[i]E[Q]=H_ H_,M=K[0xe648],0b110111 Q,i,G=H_-M,K[0xfa7d],0b11 M=i-G H_=E[M]E[Q]=H_ end else Q,R_,H_,G=b_[0b101][1][b_[0b101][0b11]],0b11010,K[0xc252],K[0xa0e2]i=G-R_ M=E[i]Q[H_]=M H_,M=K[0x5332],0x35 Q,G,i=H_-M,0x22,K[0xf0e]M=i-G H_=E[M]p_,E[Q]=0x85,H_ end elseif p_>0b110110101 then G,H_,i=0b100011,b_[0b10001][1][b_[0b10001][0b11]],K[0x5332]M=i-G i,Q,M=0b111110,H_[M],K[0xa0e2]H_,i,G=M-i,Q[1],Q[0b11]M=i[G]E[H_]=M M,i=K[0xf0e],0x29 G,R_,H_=K[0xe648],0b111100,M-i i,G=G-R_,1 M=i==G E[H_]=M p_=x>=G and 0x23c-p_ or p_+-0b111110 elseif p_>0b110110100 then Q,H_,G,R_=b_[0b101][1][b_[0b101][0b11]],K[0xc252],K[0xa0e2],0x31 i=G-R_ M=E[i]Q[H_]=M M,H_=0x33,K[0x5332]M,Q={},H_-M H_=M E[Q]=H_ p_=x>R_ and 0xe309/p_ or 0x39e else M,H_=0b110011,K[0xa0e2]R_,Q,G=0x1e,H_-M,K[0x5332]i=G-R_ M=E[i]H_=#M p_,E[Q]=0b10000101,H_ G,Q,H_,R_=K[0xf0e],b_[0b101][1][b_[0b101][0b11]],K[0xc252],0b1101 i=G-R_ M=E[i]Q[H_]=M end elseif p_<=0x1c5 then if p_<0x1c3 then O,N=P[0b11],P[1]g=N[O]P[0b10]=g P[1]=P g=0b10 P[0b11]=g p_,g=0x56140/p_,nil z[R_]=g elseif p_>0x1c3 then M,H_=0b111111,K[0xa0e2]M,Q,H_,i=nil,H_-M,z,nil H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0x346 or 0x3bb else M,H_=0x25,K[0xa0e2]Q,H_=H_-M,K[0xc252]E[Q]=H_ H_,M=K[0x5332],0x17 Q,H_=H_-M,K[0xb54d]p_,E[Q]=0b10000101,H_ end elseif p_>0x1c7 then G,R_=C_-Q,1 p_,i=0x412-p_,G+R_ else M,H_=0x31,K[0xa0e2]G,Q,i=0b10001,H_-M,K[0x5332]M=i-G H_=E[M]E[Q]=H_ H_,M=K[0xf0e],0b1000 Q,M=H_-M,{}H_=M E[Q]=H_ p_=q>=G and 0x85 or 0x4f3-p_ end elseif p_>=0x267 then if p_<0x28d then if p_>=0x277 then if p_>0x281 then if p_<=0x288 then if p_<=0x285 then if p_>0x283 then G=1 p_,i=0xc10,H_-G else p_=i and 0x2be or 0x3d1 end else O,R_,P,N,g=1,b_[0b111][1][b_[0b111][0b11]],E,H_+G,H_ p_,N=0xdd2,N-O end elseif p_<=0x289 then Q,q=0x7d,0b11 p_=n_<=Q and 0x43b-p_ or 0x2ba else Q=0x61 p_=n_>Q and 0x219 or 0x292 end elseif p_>=0x27b then if p_<=0x280 then if p_>0x27f then P=R_[0b11]p_=P>=Q and 0xa5780/p_ or 0x17f200/p_ elseif p_>0x27b then H_,M=K[0xa0e2],0b10101 M,i,Q=K[0xf69c],0x2a,H_-M H_=M-i E[Q]=H_ M,p_,H_=0b1101,0x85,K[0x5332]Q,M,i=H_-M,K[0x735e],0b10010 H_=M-i E[Q]=H_ else R_,G=0b10101,K[0xe648]P,g,i=K[0xfa7d],0b100000,G-R_ p_,R_=p_+-0b111110110,P-g G=E[R_]E[i]=G end else P,G,p_,g,N,R_=Q,b_[0b111][1][b_[0b111][0b11]],0x585,Q+i,1,E g=g-N end elseif p_<=0x278 then if p_>0x277 then Q=0x149 p_=n_>Q and 0x4d9c8/p_ or 0x62a-p_ else p_,G=p_+-0x87,1 i=H_-G end else P,R_=1,C_-H_ G=R_+P p_=x>=P and 0x288 or 0x398 end elseif p_<=0x26f then if p_>=0x26d then if p_>0x26e then G=1 p_,i=0x358,H_-G elseif p_<=0x26d then P=R_[0b11]p_=P>=Q and 0x99951/p_ or 0x363 else Q=0x55 p_=n_>Q and 0x7b756/p_ or 0x2f2 end elseif p_>0x269 then H_,M=K[0xa0e2],0b110010 H_,p_,Q=K[0xc252],0b10000101,H_-M E[Q]=H_ H_,M=K[0x5332],0b11110 Q,M=H_-M,K[0xf0e]H_=E[M]E[Q]=H_ elseif p_>0x267 then Q=0b11001000 p_=n_>Q and 0x3f5-p_ or 0x3ab-p_ else Q=0b110001 p_=n_>Q and 0x7d85c/p_ or 0x15054/p_ end elseif p_>0x272 then if p_>0x273 then H_,M=K[0xa0e2],0b111000 R_,Q,p_,G=0b111001,H_-M,0x85,K[0x5332]i=G-R_ M=E[i]H_=#M E[Q]=H_ H_,M=K[0xf0e],0x20 Q,R_,G=H_-M,0b11010,K[0xe648]i=G-R_ R_,P,M=K[0xfa7d],0x32,E[i]G=R_-P i=E[G]H_=M[i]E[Q]=H_ else M,H_=0x3e,K[0xa0e2]G,Q,R_=K[0x5332],H_-M,0b110110 i=G-R_ M=E[i]H_=-M E[Q]=H_ M,H_=0b111011,K[0xf0e]G,Q,i=0b111001,H_-M,K[0xe648]M=i-G H_=E[M]E[Q]=H_ p_=x<G and 0b10000101 or 0x671-p_ end elseif p_>0x271 then Q=0b10110011 p_=n_>Q and 0x5aef6/p_ or 0x3de elseif p_<=0x270 then Q=0xc5 p_=n_<=Q and 0x2d8 or p_+0xb7 else p_,i=0x3a3,C_-Q end elseif p_<=0x2a9 then if p_<0x298 then if p_<=0x293 then if p_<0x292 then if p_<=0x28d then g,P,R_,G,N=Q+i,Q,E,b_[0b111][1][b_[0b111][0b11]],1 p_,g=p_+0xbf1,g-N else x,N,q=0x41,P[0x5332],0x5d O,o=z[N],nil p_=O==o and p_+-0x20e or 0x3dc-p_ end elseif p_>0x292 then M,H_=0b111100,K[0xa0e2]Q,H_=H_-M,nil E[Q]=H_ M,i=K[0x5332],0b1000 p_,H_=0x85,M-i H_,R_,G,Q=K[0xc252],0x14,K[0xf0e],E[H_]i=G-R_ M=E[i]Q[H_]=M else H_,M=K[0xa0e2],0b1001 G,i,Q=0b101,K[0x5332],H_-M M=i-G H_=E[M]E[Q]=H_ p_,H_,M=0b10000101,K[0xf0e],0b100110 Q,M,i=H_-M,b_[0b101][1][b_[0b101][0b11]],K[0xc252]H_=M[i]E[Q]=H_ end elseif p_<=0x294 then Q=0b110110 p_=n_<=Q and 0b10000101 or 0x381 else P=R_[0b11]p_=P>=Q and 0xa62 or 0x311 end elseif p_<0x29d then if p_<=0x29b then if p_>0x298 then p_=i and 0x67c or 0xf0d else H_,M=K[0xa0e2],0b111000 R_,Q,G=0b11010,H_-M,K[0x5332]i=G-R_ M,R_,P=E[i],K[0xf0e],0b1110 G=R_-P i=E[G]H_=M==i E[Q]=H_ M,H_=0b101110,K[0xe648]M,Q,i=K[0xfa7d],H_-M,0b100 i,H_=1,M-i i,M,G=nil,H_-i,-1 p_=M==G and 0x9bc98/p_ or 0x5d6-p_ end else M,H_=0x28,K[0xa0e2]Q,i,M=H_-M,0x27,K[0xf69c]H_=M-i E[Q]=H_ H_,M=K[0x5332],0b11101 Q,i,G=H_-M,K[0xf0e],0b101010 i,M=1,i-G H_=M==i E[Q]=H_ p_=r<=G and 0x831 or 0b10000101 end elseif p_>=0x2a8 then if p_>0x2a8 then M,H_=0b1010,K[0xa0e2]G,p_,Q,i=0x2b,0x85,H_-M,K[0x5332]M,i=i-G,1 H_=M==i E[Q]=H_ else G=G(R_)R_,g,p_,N,P=0x1505,G,0xf18,".",b_[0b1101][1][b_[0b1101][0b11]]end elseif p_>0x29d then o={}o[0b11]=N o[1]=E O=o p_,z[N]=p_+-0x186,O else q,Q=0xc0,0b1111011 p_=n_>Q and 0x3e6 or 0b100100101 end elseif p_>=0x2b1 then if p_<=0x2b5 then if p_>=0x2b4 then if p_<=0x2b4 then P=R_[0b11]p_=P>=Q and 0x12d914/p_ or 0x7f4 else M,H_=0b111001,K[0xa0e2]i,Q,M=0x24,H_-M,K[0xf69c]H_=M-i E[Q]=H_ H_,M=K[0x5332],0x2f i,Q,M=0b100,H_-M,K[0xf0e]i,H_=1,M-i G,i,M=-1,nil,H_-i p_=M==G and 0x214 or 0x93b3d/p_ end elseif p_>0x2b1 then H_,M=K[0xa0e2],0b101111 Q,M,i=H_-M,K[0x5332],0b1000 M,p_,H_=K[0xc252],p_+-0x22d,M-i R_,i=1,E[H_]G=Q+R_ E[G]=i G=i[M]E[Q]=G else p_,w=p_+-0x22c,w+i end elseif p_<=0x2b6 then G,R_=H_(M,i)i=G p_=i==nil and 0x413-p_ or p_+0b100111011 else M,H_=0b11010,K[0xa0e2]Q,M,i=H_-M,K[0x5332],0b1000 G,R_,H_=K[0xf0e],0b10011,M-i i,G=G-R_,1 G,M,i=-1,i-G,K[0xe648]p_=M==G and 0x2ec or 0x39f end elseif p_>=0x2ad then if p_>0x2af then i,M=0x22,K[0xa0e2]H_=M-i i,G,Q=K[0x5332],0b110101,E[H_]M=i-G H_,G,R_=E[M],K[0xf0e],0x35 i=G-R_ M=E[i]Q[H_]=M H_,M=K[0xe648],0b101000 i,Q,M=0x23,H_-M,K[0xfa7d]i,H_=1,M-i M,G,i=H_-i,-1,nil p_=M==G and 0x22b or p_+-0xc5 elseif p_>0x2ad then p_,G=0x254,C_-H_ else q,i,G=0b11011,K[0xa0e2],0x1f Q,i,G=i-G,K[0x5332],0b111100 H_,G,i=i-G,0x1d,K[0xf0e]M,G=i-G,0 i=H_==G p_=i and 0x3ca-p_ or p_+0b101110 end elseif p_<=0x2ab then g,N,R_,G,P=Q+i,1,E,b_[0b111][1][b_[0b111][0b11]],Q p_,g=0x853,g-N else G,R_=C_-Q,1 p_,i=0x315,G+R_ end elseif p_>0x245 then if p_<=0x256 then if p_<=0x24e then if p_<0x24a then if p_<0x247 then p_,w=0x85,w+i elseif p_>0x247 then p_,i=0x31b,C_-Q else R_,N,g,P,G=E,1,Q+i,Q,b_[0b111][1][b_[0b111][0b11]]p_,g=0x452,g-N end elseif p_<=0x24d then if p_<=0x24b then if p_>0x24a then k,F,a_=k(F,a_)k,F,a_=B.g(k,F,a_)_=k(F,a_)a_=_ p_=a_==nil and 0x378 or 0x212 else v=a_(_,y)y=v p_=y==nil and p_+0xd38 or 0xf38 end else H_,M=K[0xa0e2],0b11100 i,Q,M=K[0xc252],H_-M,b_[0b101][1][b_[0b101][0b11]]H_=M[i]p_,E[Q]=0x2d2-p_,H_ R_,H_,Q,G=0b110000,K[0xb54d],M,K[0x5332]i=G-R_ M=E[i]Q[H_]=M end else P,R_=0b111000,K[0x95df]p_,G=0x13286/p_,R_-P w=w+G end elseif p_>0x253 then if p_<=0x254 then p_=G and 0x61a-p_ or 0x575-p_ else H_,M,q=K[0xa0e2],0x1e,0b100110 H_,Q=K[0xc252],H_-M E[Q]=H_ M,H_=0b110100,K[0x5332]i,Q,M=0x10,H_-M,K[0xf0e]H_,i=M-i,1 i,M,G=nil,H_-i,-1 p_=M==G and 0x69436/p_ or p_+0b10100001 end elseif p_>=0x252 then if p_>0x252 then H_,M=K[0xa0e2],0b11100 R_,Q,G=0x25,H_-M,K[0x5332]i=G-R_ R_,M,P=K[0xf0e],E[i],0b1001 G=R_-P i=E[G]H_=M*i p_,E[Q]=0b10000101,H_ M,H_=0b110000,K[0xe648]G,Q,i=0b10001,H_-M,K[0xfa7d]M=i-G H_=E[M]E[Q]=H_ else p_=R_<=0 and 0x5b7 or 0b101110010 end else g(N,O,o,A,u)p_,N,o,A=0x13415/p_,b_[0x11][1][b_[0x11][0b11]],K[0xfa7d],0b100 O=o-A O,o,g=K[0xe648],0b111110,N[O]N,A,o=O-o,g[0b11],g[1]O=o[A]E[N]=O end elseif p_<0x25f then if p_<=0x259 then if p_>0x258 then G=1 i=H_-G p_=q>G and p_+0x195 or 0x80d elseif p_>0x257 then M,H_=0x21,K[0xa0e2]Q,M,i=H_-M,K[0x5332],0b11010 H_,i,G=M-i,K[0x59a2],0b101111 R_,M,G=0b110010,i-G,K[0x95df]G,i,R_=E[Q],G-R_,E[H_]p_=G>R_ and 0x463-p_ or 0b100101101 else p_,M[i]=0x1d09af/p_,O end elseif p_>0x25b then H_,M=K[0xa0e2],0b10010 Q,G,R_=H_-M,K[0x5332],0b1110 i=G-R_ M,R_,P=E[i],K[0xf0e],0x29 p_,G=0x85,R_-P i=E[G]H_=M%i E[Q]=H_ else M,H_=0x15,K[0xa0e2]i,Q,G=K[0x5332],H_-M,0x1b i,M=1,i-G H_=M==i E[Q]=H_ M,H_=0x2e,K[0xf0e]Q,i,H_,M=H_-M,nil,z,nil H_,M,i=B.g(H_,M,i)G,R_=H_(M,i)i=G p_=i==nil and 0x85 or 0x295 end elseif p_<0x261 then if p_<=0x25f then G,Q,R_,H_=K[0xa0e2],b_[0b101][1][b_[0b101][0b11]],0b1111,K[0xc252]i=G-R_ M=E[i]Q[H_]=M M,H_=0b1011,K[0x5332]M,i,Q=b_[0b101][1][b_[0b101][0b11]],K[0xb54d],H_-M H_=M[i]p_,E[Q]=0x13b5b/p_,H_ else H_,M=K[0xa0e2],0b101111 Q,M,i=H_-M,K[0x5332],0b111 H_,G,i=M-i,0b101,K[0x59a2]M,G,R_=i-G,K[0x95df],0x37 G,R_,i=E[Q],E[H_],G-R_ p_=G>=R_ and 0x634-p_ or p_+0x51 end elseif p_<=0x263 then if p_<=0x261 then i,M=0x33,K[0x5332]G,i,H_=0b1100,K[0xf0e],M-i M,G=i-G,1 G,i,R_=nil,M-G,-1 p_=i==R_ and 0x27a or 0x39a else g=1 p_,P=0xd68,M-g end else P=R_[0b11]p_=P>=Q and p_+-0x119 or 0x118 end elseif p_<0x230 then if p_>=0x21d then if p_>0x225 then if p_<=0x22b then p_,R_,G=0x15db87/p_,1,C_-Q i=G+R_ else p_,g=0xa38,B.h(g(N,O,o))end elseif p_<0x224 then if p_>0x21d then i,M=0b1000,K[0x5332]i,G,H_=b_[0b101][1][b_[0b101][0b11]],K[0xc252],M-i M=i[G]E[H_]=M p_=q<=x and p_+-0x19b or 0x320 else O,o=b_[0x11][1][b_[0x11][0b11]],P[0x5332]N=O[o]p_,M[i]=p_+0xa4c,N end elseif p_<=0x224 then p_,g=0xde5,B.h(g(N,O,o))else i,G=K[0xa0e2],0b101000 G,i,Q=0b111000,K[0x5332],i-G H_,i,G=i-G,K[0xf0e],0x2e G,M=0,i-G i=H_==G p_=i and 0x4033b/p_ or p_+-0b100101111 end elseif p_>0x216 then if p_<=0x217 then i,G,q=K[0xa0e2],0x37,0x89 G,i,Q=0b10,K[0x5332],i-G H_,i,G=i-G,K[0xf0e],0b101101 G,M=0,i-G i=H_==G p_=i and p_+-0b1001 or 0x215 else M,H_=0b11001,K[0xa0e2]Q,i,p_,M=H_-M,0b110101,0x85,K[0xf69c]H_=M-i E[Q]=H_ M,H_=0b110010,K[0x5332]G,Q,i=0b110011,H_-M,K[0xf0e]M=i-G H_=E[M]E[Q]=H_ end elseif p_<=0x215 then if p_<=0x214 then if p_>0x213 then G,R_=C_-Q,1 p_,i=0x211670/p_,G+R_ else M,H_=0b110001,K[0xa0e2]Q,H_=H_-M,nil p_,E[Q]=0b10000101,H_ M,H_=0x2c,K[0x5332]Q,i,M=H_-M,K[0xc252],b_[0b101][1][b_[0b101][0b11]]H_=M[i]E[Q]=H_ end else p_=i and 0x309 or p_+0b11101100 end else M,H_=0b100,K[0xa0e2]G,Q,R_=K[0x5332],H_-M,0b110 i=G-R_ M,R_,P=E[i],K[0xf0e],0x10 G=R_-P i=E[G]p_,H_=0x85,M>i E[Q]=H_ end elseif p_<0x23a then if p_>0x234 then if p_>0x236 then g=P[0b11]p_=g>=H_ and p_+-0b1111001 or 0x313 else Q=0b11100011 p_=n_>Q and 0x3ea-p_ or 0x383-p_ end elseif p_>0x232 then H_,p_,M=K[0xa0e2],0b10000101,0b1110 M,i,Q=b_[0b101][1][b_[0b101][0b11]],K[0xc252],H_-M H_=M[i]E[Q]=H_ H_,M=K[0x5332],0b11101 M,Q,i=b_[0b101][1][b_[0b101][0b11]],H_-M,K[0xb54d]H_=M[i]E[Q]=H_ elseif p_<0x231 then G,q,i=0x3b,0b11100000,K[0xa0e2]Q,G,i=i-G,0x16,K[0x5332]H_,i=i-G,K[0xf0e]G,M=0,i-G i=H_==G p_=i and 0b100111101 or 0x159 elseif p_>0x231 then M,H_=0x37,K[0xa0e2]R_,G,Q=0b100110,K[0x5332],H_-M p_,i=0x85,G-R_ R_,M,P=K[0xf0e],E[i],0x23 G=R_-P i=E[G]H_=M..i E[Q]=H_ else G,g,P,R_,N=b_[0b111][1][b_[0b111][0b11]],Q+i,Q,E,1 p_,g=0x5c4,g-N end elseif p_>0x243 then if p_>0x244 then H_,M=K[0xa0e2],0b11111 Q,G,R_=H_-M,K[0x5332],0b101101 i=G-R_ M,R_,P=E[i],K[0xf0e],0b1001 G=R_-P i=E[G]H_=M..i E[Q]=H_ H_,M=K[0xe648],0x19 H_,Q=nil,H_-M p_,E[Q]=0x85,H_ else R_,G=1,C_-Q p_,i=0x2ab,G+R_ end elseif p_<=0x242 then if p_>=0x240 then if p_<=0x240 then r,M,h_,H_=0b1100111,0x3f,0b10101001,K[0xa0e2]i,Q,G=K[0x5332],H_-M,1 M=i-G H_=E[M]p_,E[Q]=0x881,H_ i,M=0x3c,K[0xfa7d]H_=M-i M,Q,i=K[0xe648],e[H_],0b11 M,H_=b_[0b1011][1][b_[0b1011][0b11]],M-i i=H_ else P=R_[0b11]p_=P>=Q and 0x39a-p_ or 0x7f6-p_ end else O=P(g,N)N=O p_=N==nil and 0xd01 or 0xcd7 end else P,p_,R_=0b111,p_+-0x1be,K[0x95df]G=R_-P w=w+G end end end end,function(a_,b_,c_,d_,e)a_.O[e]=-a_.c(a_.c(4294967295,a_.c(b_,0xac96)),d_)+(-a_.c(a_.b(a_.c(b_,0xac96),d_),a_.c(c_,c_))+(a_.a(a_.a(c_,0xffff),a_.a(0xffff,c_))*a_.b(a_.a(0xffff,c_),a_.a(c_,0xffff))+a_.a(a_.d(a_.a(0xffff,c_)),a_.a(c_,0xffff))*a_.a(a_.a(0xffff,c_),a_.d(a_.a(c_,0xffff)))-a_.a(0xffff,c_)*a_.a(c_,0xffff)+a_.c(a_.d(d_),a_.d(a_.b(c_,a_.c(b_,0xac96))))+a_.b(a_.d(a_.c(b_,0xac96)),d_)+a_.c(b_,0xac96)))return a_.O[e]end,bit32.band,function(e,f,...)local h_={...}local d_=select("#",...)for i=1,d_ do e[f+i-1]=h_[i]end end,function(a_,b_)return function(d_,j,_)local e,i,f,c_,h_,k i=a_.O[-0x685]or a_:Q(0xa175,0b110000,0b1100,-0x685)while true do if i>0x99 then return elseif i>=0b1111101 then if i<=0x7d then k=a_.h(k(e,h_,c_))return f,a_.i(k)else f,e,i,c_,k=d_[j],d_,a_.O[0x3ff0]or a_:Q(0xa161,0b111,0b1010110,0x3ff0),1,b_[1][1][b_[1][0b11]]c_,h_=_,j+c_ end else i=j>_ and(a_.O[-0x3a2e]or a_:Q(0xa155,0xa5,0b100,-0x3a2e))or(a_.O[-0x7f0d]or a_:Q(0xa1d4,0b1101101,0b11011,-0x7f0d))end end end end,function(a_)local c_,_,d_,g,f _=string c_,d_=_.gsub,_.char d_={[0b11]=0b10,[0b10]=d_}d_[1]=d_ c_={[0b11]=0b10,[0b10]=c_}c_[1]=c_ g=bit32 _,f=g.rshift,g.band _={[0b11]=0b10,[0b10]=_}_[1]=_ f={[0b11]=0b10,[0b10]=f}f[1]=f g=a_:r{c_,d_,_,f}return g end,h=function(...)return{[1]={...},[0b10]=select("#",...)}end,function(a_,b_)return function(d_,j)local g,_,e,f,h_,i i=0b11 repeat if i>0b101 then _=_(f)d_,_=_,a_._ _={[0b11]=0b10,[0b10]=_}_[1]=_ f={[0b11]=0b10,[0b10]=f}f[1]=f f[1][f[0b11]]=a_:I{b_[0b1111],b_[0b110],b_[0b1110],b_[0b111],b_[0b1001],b_[0b101],b_[0b1011],f,_,b_[0b1100],b_[0b10000],b_[0b1000],b_[0b1101],b_[0b11],b_[0b100],b_[0b10],b_[0b1010]}e,i,g,h_=d_,0b101010-i,f[1][f[0b11]],j elseif i<=0b11 then i,f,_=0x25,d_,b_[1][1][b_[1][0b11]]else g=g(e,h_)return g end until false end end,{},l=function(a_,j,_,...)local f,q,l,n_,k,h_,g,e,p_,c_,d_,o p_=0b1000 while true do if p_>0xa2 then if p_>=0xf4 then if p_>=0b11110101 then if p_<=0b11110101 then p_=k>e and p_+-0b10101111 or 0b11011101 else p_,f=0x2760/p_,0x1875d l,f=f*k,0x5bad h_=l+f n_,h_=h_%o,1 g=n_+h_ c_,n_=j[g],k+h_ g=d_[n_]d_[c_]=g end else p_=k<e and 0b1000110 or 0b111110000-p_ end elseif p_>=0b10110100 then if p_<=0b10110100 then p_=q<=0 and 0x4d58/p_ or 0x110-p_ else p_=q~=q and 0x1d1-p_ or 0b101010110-p_ end else p_=k>e and 0b1000110 or 0x729c/p_ end elseif p_<=0b1101110 then if p_<=0b1000110 then if p_>=0b101000 then if p_<=0b101000 then k=k+q p_=q>0 and 0xa3 or 0xdc-p_ else e,p_,q,k=d_,0x2c4c/p_,a_.h(...),d_[_]end else o,k,d_,c_=#j,0,a_,1 q,e=c_,o-c_ p_=e~=e and 0b1000110 or 0b1110110 end elseif p_>0x5c then p_=k<e and 0x1e14/p_ or 0b1011100 else p_=q~=q and 0xa2-p_ or p_+0xa0 end elseif p_>0b1111001 then k=a_.h(k(e,a_.i(q)))return a_.i(k)elseif p_>0x76 then p_=q<=0 and 0x7354/p_ or 0xfc else p_=q>0 and 0b11110101 or p_+0x67 end end end,i=(function()local function m(i,j,k)if j>k then return end return i[j],m(i,j+1,k)end return function(o)return m(o[1],1,o[0b10])end end)(),function(a_,b_,c_,d_)a_.O[d_]=a_.c(a_.c(c_,b_),a_.d(c_))+(-a_.b(a_.a(b_,b_),a_.d(c_))+(b_*0b10+(a_.a(a_.d(a_.a(c_,0xffff)),a_.a(c_,0xffff))*a_.a(a_.a(0xffff,c_),a_.d(a_.a(0xffff,c_)))+a_.b(a_.a(c_,0xffff),a_.a(0xffff,c_))*a_.a(a_.a(c_,0xffff),a_.a(c_,0xffff))-a_.a(0xffff,c_)*a_.a(0xffff,c_))))return a_.O[d_]end,function(a_)local c_,d_,_,f f=string c_,f,d_=f.byte,bit32,f.char _=f.bxor d_={[0b11]=0b10,[0b10]=d_}d_[1]=d_ c_={[0b11]=0b10,[0b10]=c_}c_[1]=c_ _={[0b11]=0b10,[0b10]=_}_[1]=_ f=a_:p{d_,_,c_}return f end,function(a_,b_)return function(d_)local j,e,o,m,f,p_,k,_,c_,l,n_,h_,g p_=0b100 while true do if p_<0xcd then if p_>0b100 then c_=0b1010101 h_,n_,f,l,m,c_=d_,d_.sub,_,_,j*c_,"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~"n_=n_(h_,l,f)h_,g,l,c_=1,c_,true,c_.find c_=c_(g,n_,h_,l)m,e=1,m+c_ p_,j=0xcd,e-m else o,j,_=0b101,0,1 k=_ p_=(o~=o or(k>0 and _>o or(k<=0 or k~=k)and _<o))and 0xf6 or 0b11101 end elseif p_<=0b11001101 then _=_+k p_=(k>0 and _>o or k<=0 and _<o or k~=k)and p_+0x29 or p_+-0xb0 else o,k,e,_=b_[0b10][1][b_[0b10][0b11]],j,0x18,b_[1][1][b_[1][0b11]]o=o(k,e)e,k,m,c_=b_[0b10][1][b_[0b10][0b11]],b_[0b11][1][b_[0b11][0b11]],j,0x10 e=e(m,c_)m=0b11111111 k=k(e,m)e,g,c_,m=b_[0b11][1][b_[0b11][0b11]],0b1000,j,b_[0b10][1][b_[0b10][0b11]]m=m(c_,g)c_=0b11111111 e=e(m,c_)c_,g,m=j,0xff,b_[0b11][1][b_[0b11][0b11]]m=a_.h(m(c_,g))_=a_.h(_(o,k,e,a_.i(m)))return a_.i(_)end end end end,function(a_,b_)return function(v)local s_,l,n_,k,u,g,f,q,j,e,p_,i,_,o,t_,c_,h_,r p_=0xbd repeat if p_<=0b1110100 then if p_>=0x46 then if p_<=0x6d then if p_<=0x5c then if p_<=0b1000110 then q=q+t_ p_=(t_>0 and q>c_ or t_<=0 and q<c_ or t_~=t_)and p_+-0x23 or 0b11000101 else h_=#v p_=_<=h_ and p_+0x11 or 0x100-p_ end else p_,h_,i,l,f=p_+0b110111,b_[0b100][1][b_[0b100][0b11]],_,v,_ h_=h_(l,f,i)n_,h_=h_,1 _=_+h_ end else q,e=o,b_[0b101][1][b_[0b101][0b11]]e=e(q)q=b_[1][1][b_[1][0b11]]q[v]=e return e end elseif p_<0x27 then if p_<=0b111 then l=1 l,h_=#v,_+l p_=h_<=l and p_+0b1110101 or p_+0x9d else e=#v p_=_<=e and 0x1252/p_ or 0b10010111-p_ end elseif p_<=0b100111 then l,f=#o,1 h_=l+f o[h_]=n_ h_,f,l=b_[0b100][1][b_[0b100][0b11]],-0x800,k..n_ h_=h_(l,f)p_,k=0x46,h_ else p_,k,_=0x7a8/p_,{},1 k,o="",k end elseif p_>0b10111101 then if p_>0b11000101 then return j else n_,l,f,h_=nil,e,1,b_[0b110][1][b_[0b110][0b11]]h_=h_(l,f)l=0 p_=h_~=l and 0b1011100 or p_+-0xbe end elseif p_>0b10100100 then _=b_[1][1][b_[1][0b11]]j=_[v]p_=j and 0xfb or 0b111000 elseif p_<0x86 then l,f,h_,i=">I2",v,b_[0b111][1][b_[0b111][0b11]],_ h_=h_(l,f,i)l=0b10 s_,i,f,_,u=h_,b_[0b11][1][b_[0b11][0b11]],#k,_+l,0b101 i=i(s_,u)l,i,s_,u=f-i,b_[0b110][1][b_[0b110][0b11]],h_,0x1f i=i(s_,u)s_=0b11 i,u,s_,f=b_[0b100][1][b_[0b100][0b11]],l,k,i+s_ p_,r,g=0b10100100,l+f,1 r=r-g i=i(s_,u,r)n_=i elseif p_>0x86 then l,f,h_=e,1,b_[0b11][1][b_[0b11][0b11]]h_=h_(l,f)e=h_ p_=n_ and 0x18fc/p_ or 0x46 else e,q,c_=b_[0b10][1][b_[0b10][0b11]],v,_ e=e(q,c_)q=1 t_,c_,_=q,0b1000,_+q p_=(c_~=c_ or(t_>0 and q>c_ or(t_<=0 or t_~=t_)and q<c_))and 0x23 or 0x14b-p_ end until false end end,(function()local q,i,s_=type,getmetatable,pairs return function(u,v,w)if q(u)~="function"then local p_=i(u)if p_~=nil and p_.__iter~=nil then return p_.__iter(u)elseif(p_ and p_.__call)==nil and q(u)=="table"then return s_(u)end end return u,v,w end end)(),bit32.bxor,getfenv()}):l({"d","q","F","J","L","_","P","j","c","U","a","g","N","R","u","p","K","s","T","k","o","I","H","S","Q","b","O","r","t","G","M"},"U",...)                          
]====],Controls={
{Kind=[====[
Paragraph]====],Title=[====[
Mystery Hub Server]====],Desc=[====[
Discord Server]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Dashboard/Home/Mystery Hub Server]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Server Discord]====],Desc=[====[
Copy Discord invite]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Dashboard/Home/Server Discord]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Script Info]====],Desc=[====[
Mystery Hub
Version: Muscle Legends V1.1.0
Author: Made By Rafael and Sherya
UI Library: WindUI]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Dashboard/Home/Script Info]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Account Info]====],Desc=[====[
Username: Tester
Display Name: Tester
User ID: 1
Account Age: 100 days]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Dashboard/Home/Account Info]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Performance]====],Desc=[====[
FPS: Loading...
Ping: Loading... ms
Executor: Offline Audit]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Dashboard/Home/Performance]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Game Info]====],Desc=[====[
Place ID: 3623096087
Job ID: offline-test
Players: 2/12]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Dashboard/Home/Game Info]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Anti AFK]====],Desc=[====[
Finalidade: Game Info
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Anti AFK]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Anti AFK]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Hide Pets]====],Desc=[====[
Finalidade: Game Info
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Hide Pets]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Hide Pets]====],Default=true},
{Kind=[====[
Toggle]====],Title=[====[
Hide Popups]====],Desc=[====[
Finalidade: Game Info
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Hide Popups]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Hide Popups]====],Default=true},
{Kind=[====[
Toggle]====],Title=[====[
Anti Lag]====],Desc=[====[
Finalidade: Game Info
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Anti Lag]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Anti Lag]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Full Optimization]====],Desc=[====[
Finalidade: Game Info
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Full Optimization]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Full Optimization]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Farm Timer]====],Desc=[====[
Finalidade: Farm Timer
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Farm Timer]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Farm Timer]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Time]====],Desc=[====[
00:00:00]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Time]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Rock]====],Desc=[====[
Finalidade: Time
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Select Rock]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Select Rock]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Farm Rock]====],Desc=[====[
Finalidade: Time
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Auto Farm Rock]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rocks/Auto Farm Rock]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Gamepass AutoLift]====],Desc=[====[
Finalidade: Time
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Gamepass AutoLift]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Gamepass AutoLift]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Tool]====],Desc=[====[
Finalidade: Time
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Select Tool]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Select Tool]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Use Tool]====],Desc=[====[
Finalidade: Time
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Auto Use Tool]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Auto Use Tool]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Fast Tools]====],Desc=[====[
Finalidade: Time
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Fast Tools]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Fast Tools]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Tool + Rock]====],Desc=[====[
Combina entrenamiento y daño al Rock]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Tool + Rock]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Combo]====],Desc=[====[
Finalidade: Tool + Rock
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Select Combo]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Select Combo]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Tool + Rock]====],Desc=[====[
Finalidade: Tool + Rock
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Auto Tool + Rock]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Tools/Auto Tool + Rock]====],Default=false},
{Kind=[====[
Input]====],Title=[====[
Rebirth Target]====],Desc=[====[
Finalidade: Tool + Rock
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Rebirth Target]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Rebirth Target]====],Default=[====[
0]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Rebirth Target]====],Desc=[====[
Finalidade: Tool + Rock
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Auto Rebirth Target]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Auto Rebirth Target]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Auto Rebirth Infinite]====],Desc=[====[
Finalidade: Tool + Rock
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Auto Rebirth Infinite]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Auto Rebirth Infinite]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Información]====],Desc=[====[
Primero Oprime El Boton (Teleport King) Y Despues Aprieta Lock Position]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Información]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Lock Position]====],Desc=[====[
Finalidade: Información
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Lock Position]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Lock Position]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Teleport King]====],Desc=[====[
Finalidade: Información
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Teleport King]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Teleport King]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Anti Rebirth]====],Desc=[====[
Finalidade: Información
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Anti Rebirth]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Farm Rebirths/Anti Rebirth]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Join Brawl]====],Desc=[====[
Finalidade: Información
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Brawls/Auto Join Brawl]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Brawls/Auto Join Brawl]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Auto Win Brawl]====],Desc=[====[
Finalidade: Información
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Brawls/Auto Win Brawl]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Brawls/Auto Win Brawl]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Boss Status]====],Desc=[====[
Status: No Active Boss
Boss: None
Health: 0/0
Health: 0%
Next Boss: Now]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Boss Status]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Boss]====],Desc=[====[
Finalidade: Boss Status
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Auto Boss]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Auto Boss]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Halloween Boss Health]====],Desc=[====[
Frankenbrute = Health: N/A
Grim Reaper = Health: N/A
Pumpkin Titan = Health: N/A
Scarecrow Colossus = Health: N/A]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Halloween/Halloween Boss Health]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Boss]====],Desc=[====[
Finalidade: Halloween Boss Health
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Halloween/Select Boss]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Halloween/Select Boss]====],Default=[====[
Frankenbrute]====]},
{Kind=[====[
Toggle]====],Title=[====[
Attack Boss]====],Desc=[====[
Finalidade: Halloween Boss Health
Origem: Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Halloween/Attack Boss]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Farm/Auto Boss/Halloween/Attack Boss]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Recommended Speed 40]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Recommended Speed 40]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Recommended Speed 40]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Speed Of Reps]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Speed Of Reps]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Speed Of Reps]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Start]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Start]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Start]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Eat Egg 30 Min]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Eat Egg 30 Min]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Eat Egg 30 Min]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Auto Spin]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Auto Spin]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Auto Spin]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Industrial Squat]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Industrial Squat]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Industrial Squat]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Hallowed Squat]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Hallowed Squat]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Hallowed Squat]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Equip The Best Pets To Farm]====],Desc=[====[
Finalidade: Recommended Speed 40
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Equip The Best Pets To Farm]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Equip The Best Pets To Farm]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Farming Time]====],Desc=[====[
Tiempo: 0d 0h 0m 0s
Fast Reps: Apagadas
Ping: 0 ms

Fuerza Aprox: 0 /Hora | 0 /Dia | 0 /Semana | 0 /Mes
Durabilidad Aprox: 0 /Hora | 0 /Dia | 0 /Semana | 0 /Mes
Fuerza Promedio: 0 /Hora | 0 /Dia | 0 /Semana | 0 /Mes
Durabilidad Promedio: 0 /Hora | 0 /Dia | 0 /Semana | 0 /Mes

Fuerza: 0 | Ganada: 0
Durabilidad: 0 | Ganada: 0]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Farming Time]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Importante!]====],Desc=[====[
Pueden Usar El Fast Rebirth Si Entre Todos Sus Golems Completan El 100% De Velocidad De Rep Ejemplo:
10 Golems Epicos = 100% Y Al Hacer Rebirth El Script Equipa Tribal Overlord o Titanium Hydra]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Importante!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Fast Rebirth]====],Desc=[====[
Tiempo: 0d 0h 0m 0s
Rebirths: 0
Rebirths Ganados: 0
Estatus: Inactivo]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Fast Rebirth]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Rebirth Stats]====],Desc=[====[
Rebirths Aprox: 0 / Hora | 0 / Día | 0 / Semana | 0 / Mes
Promedio De Rebirths: 0 / Hora | 0 / Día | 0 / Semana | 0 / Mes]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Rebirth Stats]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Fast Rebirths]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Fast Rebirths]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Fast Rebirths]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Industrial Lift]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Industrial Lift]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Industrial Lift]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Hallowed Bar Lift]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Hallowed Bar Lift]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Packs/Fast Rebirth/Hallowed Bar Lift]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Anti Fling]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/More Option For Farm/Anti Fling]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/More Option For Farm/Anti Fling]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Lock Position]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/More Option For Farm/Lock Position]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/More Option For Farm/Lock Position]====],Default=false},
{Kind=[====[
Input]====],Title=[====[
Size Value]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Size Value]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Size Value]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Set Size]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Auto Set Size]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Auto Set Size]====],Default=false},
{Kind=[====[
Input]====],Title=[====[
Speed Value]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Speed Value]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Speed Value]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Set Speed]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Auto Set Speed]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Auto Set Speed]====],Default=false},
{Kind=[====[
Input]====],Title=[====[
Jump Power Value]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Jump Power Value]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Jump Power Value]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Super Jump]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Super Jump]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Super Jump]====],Default=false},
{Kind=[====[
Input]====],Title=[====[
Gravity Value]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Gravity Value]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Gravity Value]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Custom Gravity]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Custom Gravity]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Settings Player/Custom Gravity]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Infinite Yield]====],Desc=[====[
Abre a ferramenta externa referenciada pelo Mystery na interface própria.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Universal Scripts/Infinite Yield]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Permanent Shiftlock]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Universal Scripts/Permanent Shiftlock]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Universal Scripts/Permanent Shiftlock]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
All Emotes]====],Desc=[====[
Abre a ferramenta externa referenciada pelo Mystery na interface própria.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Universal Scripts/All Emotes]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Infinite Jump]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Infinite Jump]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Infinite Jump]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Walk On Water]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Walk On Water]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Walk On Water]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Noclip]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Noclip]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Noclip]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Remove Portals]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Remove Portals]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Miscellaneous/Remove Portals]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Reconnect]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Auto Reconnect]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Auto Reconnect]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Auto Reconnect (Automatic)]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Auto Reconnect (Automatic)]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Auto Reconnect (Automatic)]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Server Hop Low]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Server Hop Low]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Server Hop Low]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Server Hop Full]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Server Hop Full]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Server Hop Full]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Reconnect Same Server]====],Desc=[====[
Finalidade: Rebirth Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Reconnect Same Server]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Extras/Server/Reconnect Same Server]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Pet Shop]====],Desc=[====[
Selecciona una pet para comprar]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Pet Shop]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Selecciona La Pet]====],Desc=[====[
Finalidade: Pet Shop
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona La Pet]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona La Pet]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Comprar Pets]====],Desc=[====[
Finalidade: Pet Shop
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Comprar Pets]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Comprar Pets]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Auras]====],Desc=[====[
Selecciona un aura para comprar]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Auras]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Selecciona El Aura]====],Desc=[====[
Finalidade: Auras
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona El Aura]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona El Aura]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Comprar Aura]====],Desc=[====[
Finalidade: Auras
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Comprar Aura]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Comprar Aura]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Evolucionar Pets]====],Desc=[====[
Selecciona una pet para evolucionar]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Evolucionar Pets]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Selecciona La Pet]====],Desc=[====[
Finalidade: Evolucionar Pets
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona La Pet]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona La Pet]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Evolucionar Las Pets]====],Desc=[====[
Finalidade: Evolucionar Pets
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Evolucionar Las Pets]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Evolucionar Las Pets]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Auto Trade]====],Desc=[====[
Selecciona el jugador y la pet]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Auto Trade]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Selecciona El Jugador]====],Desc=[====[
Finalidade: Auto Trade
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona El Jugador]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona El Jugador]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Selecciona La Pet]====],Desc=[====[
Finalidade: Auto Trade
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona La Pet]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Selecciona La Pet]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Trade]====],Desc=[====[
Finalidade: Auto Trade
Origem: Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Auto Trade]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Crystals/Crystals/Auto Trade]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Importante!]====],Desc=[====[
No Se Puede Regalar Si Estas Farmeando

Cuando Selecciones La Cantidad Que Quieras Regalar Ya Sean Eggs O Shakes Haz Lo Siguiente

Pon La Cantidad Que Vas A Regalar

Dale Enter Ala Cantidad Como Si Fuera Un Mensaje

Aprieta El Boton Send Eggs/Shakes]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Importante!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Protein Eggs]====],Desc=[====[
Count: 0 | Status: IDLE]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Protein Eggs]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Player]====],Desc=[====[
Finalidade: Protein Eggs
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Select Player]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Select Player]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Egg Amount]====],Desc=[====[
Finalidade: Protein Eggs
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Egg Amount]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Egg Amount]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Send Eggs]====],Desc=[====[
Finalidade: Protein Eggs
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Send Eggs]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Send Eggs]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Gift Shakes]====],Desc=[====[
Tropical Shakes]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Gift Shakes]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Tropical Shakes]====],Desc=[====[
Count: 0 | Status: IDLE]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Tropical Shakes]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Player]====],Desc=[====[
Finalidade: Tropical Shakes
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Select Player]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Select Player]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Shake Amount]====],Desc=[====[
Finalidade: Tropical Shakes
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Shake Amount]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Shake Amount]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Send Shakes]====],Desc=[====[
Finalidade: Tropical Shakes
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Send Shakes]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Send Shakes]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Eat Everything]====],Desc=[====[
Finalidade: Tropical Shakes
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Eat Everything]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Eat Everything]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Eat Everything (No Egg)]====],Desc=[====[
Finalidade: Tropical Shakes
Origem: Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Eat Everything (No Egg)]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Miscellaneous/Snacks/Eat Everything (No Egg)]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Equip Pets]====],Desc=[====[
Equipar mascotas para Killer]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Equip Pets]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Equip Wild Wizard]====],Desc=[====[
Finalidade: Equip Pets
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Equip Wild Wizard]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Equip Wild Wizard]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Equip Mighty Monster]====],Desc=[====[
Finalidade: Equip Pets
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Equip Mighty Monster]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Equip Mighty Monster]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Kill Clans]====],Desc=[====[
Matar jugadores según tags]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill Clans]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Kill TRD]====],Desc=[====[
Finalidade: Kill Clans
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill TRD]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill TRD]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Kill TheRealDevil]====],Desc=[====[
Finalidade: Kill Clans
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill TheRealDevil]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill TheRealDevil]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Kill 44]====],Desc=[====[
Finalidade: Kill Clans
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill 44]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill 44]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Kill EMPI]====],Desc=[====[
Finalidade: Kill Clans
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill EMPI]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill EMPI]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Kill SLH]====],Desc=[====[
Finalidade: Kill Clans
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill SLH]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill SLH]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Kill KTA]====],Desc=[====[
Finalidade: Kill Clans
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill KTA]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill KTA]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Misc]====],Desc=[====[
Opciones adicionales]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Misc]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Pack Spam]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Pack Spam]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Pack Spam]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Ver Vida De Todos]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Ver Vida De Todos]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Ver Vida De Todos]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Anti Hit (TP) Isla Pequeña]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Anti Hit (TP) Isla Pequeña]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Anti Hit (TP) Isla Pequeña]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Anti Hit (TP) Isla Secreta]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Anti Hit (TP) Isla Secreta]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Anti Hit (TP) Isla Secreta]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
No Comer Eggs]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/No Comer Eggs]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/No Comer Eggs]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Anti Lag]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Anti Lag]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Anti Lag]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Quitar La Animacion Al Punch]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Quitar La Animacion Al Punch]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Quitar La Animacion Al Punch]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Regresar La Animacion Al Punch]====],Desc=[====[
Finalidade: Misc
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Regresar La Animacion Al Punch]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Regresar La Animacion Al Punch]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Whitelist]====],Desc=[====[
Whitelist: Ninguno]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Agregar Jugador a Whitelist]====],Desc=[====[
Finalidade: Whitelist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Agregar Jugador a Whitelist]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Agregar Jugador a Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Quitar Jugador de Whitelist]====],Desc=[====[
Finalidade: Whitelist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Quitar Jugador de Whitelist]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Quitar Jugador de Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Agregar Amigos a WhiteList]====],Desc=[====[
Finalidade: Whitelist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Agregar Amigos a WhiteList]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Agregar Amigos a WhiteList]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Limpiar Whitelist]====],Desc=[====[
Finalidade: Whitelist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Limpiar Whitelist]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Limpiar Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Killing]====],Desc=[====[
Opciones de eliminación]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Killing]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
AutoKill All]====],Desc=[====[
Finalidade: Killing
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/AutoKill All]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/AutoKill All]====],Default=false},
{Kind=[====[
Dropdown]====],Title=[====[
Seleccionar Jugador Para Ver]====],Desc=[====[
Finalidade: Killing
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Seleccionar Jugador Para Ver]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Seleccionar Jugador Para Ver]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Ver Jugador]====],Desc=[====[
Finalidade: Killing
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Ver Jugador]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Ver Jugador]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Blacklist]====],Desc=[====[
Blacklist: empty]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Blacklist]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Agregar a BlackList]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Agregar a BlackList]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Agregar a BlackList]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Matar BlackList]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Matar BlackList]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Matar BlackList]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Fast Punch]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Fast Punch]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Fast Punch]====],Default=false},
{Kind=[====[
Button]====],Title=[====[
Quitar Ultimo de BlackList]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Quitar Ultimo de BlackList]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Quitar Ultimo de BlackList]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Limpiar BlackList]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Limpiar BlackList]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Limpiar BlackList]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Kill Aura]====],Desc=[====[
Death Ring]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Kill Aura]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Rango 1-140]====],Desc=[====[
Finalidade: Kill Aura
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Rango 1-140]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Rango 1-140]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Death Ring]====],Desc=[====[
Finalidade: Kill Aura
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Death Ring]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Death Ring]====],Default=false},
{Kind=[====[
Toggle]====],Title=[====[
Show Ring]====],Desc=[====[
Finalidade: Kill Aura
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Show Ring]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Show Ring]====],Default=false},
{Kind=[====[
Paragraph]====],Title=[====[
Sizes]====],Desc=[====[
Cambiar tamaño del personaje]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Sizes]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Size 2]====],Desc=[====[
Finalidade: Sizes
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Size 2]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Size 2]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Size 30]====],Desc=[====[
Finalidade: Sizes
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Size 30]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Size 30]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Size 70]====],Desc=[====[
Finalidade: Sizes
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Size 70]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Size 70]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Blacklist]====],Desc=[====[
Blacklist: (empty)]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Blacklist]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Add to Blacklist]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Add to Blacklist]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Add to Blacklist]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Remove from Blacklist]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Killer/Remove from Blacklist]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Killer/Remove from Blacklist]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Player]====],Desc=[====[
Finalidade: Blacklist
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Stats/Select Player]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Select Player]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Player Stats]====],Desc=[====[
Strength: 0
Gems: 0
Agility: 0
Rebirths: 0
Durability: 0
Kills: 0
Muscle King Time: 0
Current Map: N/A
Evil Karma: 0
Good Karma: 0

Advanced Stats
Enemy Health: N/A
Your Damage: N/A
Hits to Kill: N/A]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Player Stats]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Fake Stats]====],Desc=[====[
Modifica visualmente las estadísticas seleccionadas]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Fake Stats]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Strength]====],Desc=[====[
Apenas aparência local dos números no HUD; não aumenta atributos, moeda, kills ou rebirths.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Strength]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Rebirths]====],Desc=[====[
Apenas aparência local dos números no HUD; não aumenta atributos, moeda, kills ou rebirths.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Rebirths]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Kills]====],Desc=[====[
Apenas aparência local dos números no HUD; não aumenta atributos, moeda, kills ou rebirths.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Kills]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Brawls]====],Desc=[====[
Apenas aparência local dos números no HUD; não aumenta atributos, moeda, kills ou rebirths.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Brawls]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Durabilidad]====],Desc=[====[
Apenas aparência local dos números no HUD; não aumenta atributos, moeda, kills ou rebirths.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Durabilidad]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Gemas]====],Desc=[====[
Apenas aparência local dos números no HUD; não aumenta atributos, moeda, kills ou rebirths.]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Gemas]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Restore Fake Stats]====],Desc=[====[
Finalidade: Fake Stats
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Restore Fake Stats]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Stats/Fake Stats (Solo Visuales)/Restore Fake Stats]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Work Locations]====],Desc=[====[
Finalidade: Work Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Work Locations]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Work Locations]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Workout]====],Desc=[====[
Finalidade: Work Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Workout]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Workout]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Location]====],Desc=[====[
Finalidade: Work Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Location]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Location]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Teleport to Workout]====],Desc=[====[
Finalidade: Work Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Workout]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Workout]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Treadmill Locations]====],Desc=[====[
Finalidade: Treadmill Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Treadmill Locations]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Treadmill Locations]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Treadmill]====],Desc=[====[
Finalidade: Treadmill Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Treadmill]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Treadmill]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Teleport to Treadmill]====],Desc=[====[
Finalidade: Treadmill Locations
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Treadmill]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Treadmill]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Islands]====],Desc=[====[
Finalidade: Islands
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Islands]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Islands]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Island]====],Desc=[====[
Finalidade: Islands
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Island]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Island]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Teleport to Island]====],Desc=[====[
Finalidade: Islands
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Island]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Island]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Brawl Islands]====],Desc=[====[
Finalidade: Brawl Islands
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Brawl Islands]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Brawl Islands]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Brawl Island]====],Desc=[====[
Finalidade: Brawl Islands
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Brawl Island]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Select Brawl Island]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Teleport to Brawl Island]====],Desc=[====[
Finalidade: Brawl Islands
Origem: Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Brawl Island]====],Path=[====[
Mystery/Mystery Hub | Welcome Tester/Players/Teleport/Teleport to Brawl Island]====],Default=[====[
]====]}
},Saved=setmetatable({}, {__mode="k"}),Created={},Connections={},Widgets={},Status="Carrega ao usar"}
B.Engines[#B.Engines+1]={Name=[====[
Silence Main]====],Id=[====[
silence_main]====],Source=[====[
--[[
    Silence - Ml Main
    by Henrik @xyzhenrik
]]

local services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	VirtualUser = game:GetService("VirtualUser"),
	Workspace = workspace,
	Lighting = game:GetService("Lighting"),
	UserInputService = game:GetService("UserInputService"),
	VirtualInputManager = game:GetService("VirtualInputManager"),
	RunService = game:GetService("RunService"),
	CollectionService = game:GetService("CollectionService"),
	HttpService = game:GetService("HttpService"),
	StarterGui = game:GetService("StarterGui")
}

local utils = {}
utils.runtime = {}

utils.touchParts = function(part, hand, state)
	if type(firetouchinterest) ~= "function" or not part or not hand then return false end
	return pcall(firetouchinterest, part, hand, state)
end

utils.playerData = {
	Player = services.Players.LocalPlayer,
	DisplayName = services.Players.LocalPlayer.DisplayName,
	Character = services.Players.LocalPlayer.Character,
	Humanoid = nil,
	Camera = services.Workspace.CurrentCamera,
	Backpack = services.Players.LocalPlayer:WaitForChild("Backpack")
}

utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")

utils.remotes = {
	ChangeSpeedSize = services.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote"),
	MuscleEvent = utils.playerData.Player:WaitForChild("muscleEvent")
}

function utils.formatNumber(n)
	if n >= 1e18 then return string.format("%.1fqi", n / 1e18)
	elseif n >= 1e15 then return string.format("%.1fqa", n / 1e15)
	elseif n >= 1e12 then return string.format("%.1ft", n / 1e12)
	elseif n >= 1e9 then return string.format("%.1fb", n / 1e9)
	elseif n >= 1e6 then return string.format("%.1fm", n / 1e6)
	elseif n >= 1e3 then return string.format("%.1fk", n / 1e3)
	else return tostring(n) end
end

function utils.formatWithCommas(n, formatted, separatorCount)
	formatted = tostring(math.floor(n))
	while true do
		formatted, separatorCount = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
		if separatorCount == 0 then break end
	end
	return formatted
end

function utils.greeting(hour)
	hour = hour or os.date("*t").hour
	if hour >= 6 and hour < 12 then return "Good Morning!"
	elseif hour >= 12 and hour < 13 then return "Good Noon!"
	elseif hour >= 13 and hour < 19 then return "Good Afternoon!"
	elseif hour >= 19 and hour < 22 then return "Good Evening!"
	else return "Good Night!" end
end

function utils.toggleSelection(selected, selectedList, value, label, prefix)
	if selected[value] then
		selected[value] = nil
		for index = #selectedList, 1, -1 do
			if selectedList[index] == value then table.remove(selectedList, index) end
		end
	else
		selected[value] = true
		table.insert(selectedList, value)
	end
	label.Text = prefix .. (#selectedList > 0 and table.concat(selectedList, ", ") or "None")
end

function utils.deleteAds()
	for _, portal in pairs(game:GetDescendants()) do
		if portal.Name == "RobloxForwardPortals" then
			portal:Destroy()
		end
	end
	if _G.ads then
		_G.ads:Disconnect()
	end

	_G.ads = game.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "RobloxForwardPortals" then
			descendant:Destroy()
		end
	end)
end
utils.deleteAds()

utils.library = loadstring(game:HttpGet("https://raw.githubusercontent.com/silencedevs/SilenceScripts/refs/heads/main/libraries/eleriumv2.luau?cache=" .. tostring(os.time()), true))()

utils.silence = utils.library:AddWindow("Silence | Main - " .. utils.greeting(), {
	main_color = Color3.fromRGB(138, 0, 0),
	min_size = Vector2.new(566, 750),
	can_resize = true,
})

task.spawn(function()
	while true do
		task.wait(60)
		utils.silence:SetTitle("Silence | Main - " .. utils.greeting())
	end
end)

utils.playerData.Player.Idled:Connect(function()
	pcall(function()
		services.VirtualUser:CaptureController()
		services.VirtualUser:ClickButton2(Vector2.new())
	end)
end)

utils.playerData.Player.CharacterAdded:Connect(function(character)
	utils.playerData.Character = character
	utils.playerData.Humanoid = character:WaitForChild("Humanoid", 10)
	utils.playerData.Backpack = utils.playerData.Player:WaitForChild("Backpack")
end)

local tabs = {
	main = utils.silence:AddTab("Main"),
	killing = utils.silence:AddTab("Killing"),
	specs = utils.silence:AddTab("Specs"),
	farming = utils.silence:AddTab("Farming"),
	boss = utils.silence:AddTab("Boss"),
	inventory = utils.silence:AddTab("Pets"),
	boosts = utils.silence:AddTab("Boosts"),
	teleport = utils.silence:AddTab("Teleports"),
	stats = utils.silence:AddTab("Stats"),
	info = utils.silence:AddTab("Info")
}

for _, tab in pairs(tabs) do
	tab.runtime = {}
end

tabs.main:AddLabel("User Settings:")

tabs.main.Settings = {
	Size = {Value = 2, Enabled = false},
	Speed = {Value = 120, Enabled = false},
	FOV = {Value = 70, Enabled = false}
}

tabs.main:AddTextBox("Size:", function(text)
	text = string.gsub(text, "%s+", "")
	if tonumber(text) and tonumber(text) > 0 then
		tabs.main.Settings.Size.Value = tonumber(text)
	end
end, {clear = false})

tabs.main:AddSwitch("Set Size", function(bool)
	tabs.main.Settings.Size.Enabled = bool
end)

task.spawn(function()
	while true do
		if tabs.main.Settings.Size.Enabled and utils.playerData.Character and utils.playerData.Humanoid then
			utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", tabs.main.Settings.Size.Value)
		end
		task.wait(0.01)
	end
end)

tabs.main:AddTextBox("Speed:", function(text)
	text = string.gsub(text, "%s+", "")
	if tonumber(text) and tonumber(text) > 0 then
		tabs.main.Settings.Speed.Value = tonumber(text)
	end
end, {clear = false})

tabs.main:AddSwitch("Set Speed", function(bool)
	tabs.main.Settings.Speed.Enabled = bool
end)

task.spawn(function()
	while true do
		if tabs.main.Settings.Speed.Enabled and utils.playerData.Character and utils.playerData.Humanoid then
			utils.remotes.ChangeSpeedSize:InvokeServer("changeSpeed", tabs.main.Settings.Speed.Value)
		end
		task.wait(0.01)
	end
end)

if utils.playerData.Camera then
	tabs.main:AddTextBox("FOV:", function(text)
		text = string.gsub(text, "%s+", "")
		if tonumber(text) and tonumber(text) >= 1 and tonumber(text) <= 120 then
			tabs.main.Settings.FOV.Value = tonumber(text)
		end
	end, {clear = false})

	tabs.main:AddSwitch("Set FOV", function(bool)
		tabs.main.Settings.FOV.Enabled = bool
		utils.playerData.Camera.FieldOfView = bool and tabs.main.Settings.FOV.Value or 70
	end)

	task.spawn(function()
		while true do
			if tabs.main.Settings.FOV.Enabled and utils.playerData.Camera then
				utils.playerData.Camera.FieldOfView = tabs.main.Settings.FOV.Value
			end
			task.wait(0.01)
		end
	end)
end

tabs.main:AddLabel("Protection and Visuals:")

tabs.main.Protection = {
	AntiFling = {Enabled = false},
	PositionLock = {Enabled = false, Position = nil}
}

tabs.main.enableAntiFling = function()
	if not tabs.main.Protection.AntiFling.Enabled or not utils.playerData.Player.Character then return end
	if not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") and
	   utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
		utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
	end
	tabs.main.runtime.bv = Instance.new("BodyVelocity")
	tabs.main.runtime.bv.MaxForce = Vector3.new(100000, 0, 100000)
	tabs.main.runtime.bv.Velocity = Vector3.new(0, 0, 0)
	tabs.main.runtime.bv.P = 1250
	tabs.main.runtime.bv.Parent = utils.playerData.Player.Character.HumanoidRootPart
end

tabs.main.disableAntiFling = function()
	if not utils.playerData.Player.Character or not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") and
	   utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
		utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
	end
end

tabs.main:AddSwitch("Anti Fling", function(bool)
	tabs.main.Protection.AntiFling.Enabled = bool
	if bool then tabs.main.enableAntiFling() else tabs.main.disableAntiFling() end
end):Set(true)

utils.playerData.Player.CharacterAdded:Connect(function(newChar)
	newChar:WaitForChild("HumanoidRootPart", 5)
	if tabs.main.Protection.AntiFling.Enabled then tabs.main.enableAntiFling() end
end)

tabs.main.lockPosition = function()
	tabs.main.enableAntiFling()
	if not tabs.main.Protection.PositionLock.Enabled or not tabs.main.Protection.PositionLock.Position or not utils.playerData.Player.Character then return end
	if not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("PositionLocker") then
		utils.playerData.Player.Character.HumanoidRootPart.PositionLocker.Position = tabs.main.Protection.PositionLock.Position
	else
		tabs.main.disableAntiFling()
		tabs.main.runtime.bp = Instance.new("BodyPosition")
		tabs.main.runtime.bp.Name = "PositionLocker"
		tabs.main.runtime.bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		tabs.main.runtime.bp.Position = tabs.main.Protection.PositionLock.Position
		tabs.main.runtime.bp.P = 100000
		tabs.main.runtime.bp.Parent = utils.playerData.Player.Character.HumanoidRootPart
	end
end

tabs.main.unlockPosition = function()
	if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
		if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("PositionLocker") then
			utils.playerData.Player.Character.HumanoidRootPart.PositionLocker:Destroy()
		end
	end
	tabs.main.Protection.PositionLock.Position = nil
end

tabs.main:AddSwitch("Lock Position", function(bool)
	tabs.main.Protection.PositionLock.Enabled = bool
	if bool then
		if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			tabs.main.Protection.PositionLock.Position = utils.playerData.Player.Character.HumanoidRootPart.Position
		end
		tabs.main.lockPosition()
	else
		tabs.main.unlockPosition()
	end
end)

tabs.main.VisibilitySettings = {
	{Name = "Show Pets", GuiName = "MyPetsBase", Enabled = false},
	{Name = "Show Other Pets", GuiName = "OtherPets", Enabled = false},
	{Name = "Show PopUps", GuiName = "PopUps", Enabled = false}
}

tabs.main.syncVisibilitySetting = function(setting, success, connections)
	if not setting.OnText or not setting.OnText.Parent or not setting.Button or not setting.Button.Parent
		or setting.Pending or setting.OnText.Visible == setting.Enabled then return end
	if type(firesignal) ~= "function" or type(getconnections) ~= "function" then return end
	for _, button in ipairs({setting.Button, setting.Button:FindFirstChild(setting.OnText.Visible and "OnButton" or "OffButton")}) do
		for _, eventName in ipairs({"MouseButton1Click", "Activated"}) do
			success, connections = pcall(getconnections, button[eventName])
			if success and type(connections) == "table" then
				for _, connection in ipairs(connections) do
					if connection.Enabled ~= false then
						setting.Pending = true
						if pcall(firesignal, button[eventName]) then return end
						setting.Pending = false
					end
				end
			end
		end
	end
end

tabs.main.bindVisibilitySetting = function(setting, node, onText, button)
	node = utils.playerData.Player
	for _, childName in ipairs({"PlayerGui", "gameGui", "settingsNewMenu", "Content", "ListLayout", "ScrollingFrame", setting.GuiName}) do
		node = node:WaitForChild(childName, 10)
		if not node then return end
	end
	onText = node:WaitForChild("OnText", 10)
	button = node:WaitForChild("Switch", 10)
	if not onText or not button then return end
	if setting.OnText ~= onText or setting.Button ~= button then
		if setting.Connection then setting.Connection:Disconnect() end
		setting.OnText = onText
		setting.Button = button
		setting.Pending = false
		setting.Connection = onText:GetPropertyChangedSignal("Visible"):Connect(function()
			setting.Pending = false
			task.defer(tabs.main.syncVisibilitySetting, setting)
		end)
	end
	tabs.main.syncVisibilitySetting(setting)
end

for _, setting in ipairs(tabs.main.VisibilitySettings) do
	setting.Switch = tabs.main:AddSwitch(setting.Name, function(state)
		setting.Enabled = state
		tabs.main.syncVisibilitySetting(setting)
	end)
	setting.Switch:Set(false)
	task.spawn(tabs.main.bindVisibilitySetting, setting)
end
utils.playerData.Player.CharacterAdded:Connect(function()
	for _, setting in ipairs(tabs.main.VisibilitySettings) do
		task.spawn(tabs.main.bindVisibilitySetting, setting)
	end
end)

tabs.main.RedactConfigPath = "Silence/MuscleLegendsMainConfig.json"
tabs.main.RedactConfig = {
	RedactName = false,
	RedactStats = false,
}

tabs.main.loadRedactConfig = function()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
	pcall(function()
		if not isfile(tabs.main.RedactConfigPath) then return end
		tabs.main.runtime.savedRedactConfig = services.HttpService:JSONDecode(readfile(tabs.main.RedactConfigPath))
		if typeof(tabs.main.runtime.savedRedactConfig) == "table" then
			tabs.main.RedactConfig.RedactName = tabs.main.runtime.savedRedactConfig.RedactName == true
			tabs.main.RedactConfig.RedactStats = tabs.main.runtime.savedRedactConfig.RedactStats == true
		end
	end)
end

tabs.main.saveRedactConfig = function()
	if type(writefile) ~= "function" then return end
	pcall(function()
		if type(makefolder) == "function"
			and (type(isfolder) ~= "function" or not isfolder("Silence")) then
			pcall(makefolder, "Silence")
		end
		writefile(tabs.main.RedactConfigPath, services.HttpService:JSONEncode(tabs.main.RedactConfig))
	end)
end

tabs.main.applyNameVisibility = function()
	pcall(function()
		services.Workspace.HenneZocktTV.Head.nameGui.Enabled = not tabs.main.RedactConfig.RedactName
	end)
end

tabs.main.applyStatsVisibility = function()
	pcall(function()
		utils.playerData.Player.PlayerGui.gameGui.hudNewMenu.Top.InfoSlots.Visible = not tabs.main.RedactConfig.RedactStats
	end)
	pcall(function() services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not tabs.main.RedactConfig.RedactStats) end)
end

tabs.main.loadRedactConfig()
tabs.main.HideNameSwitch = tabs.main:AddSwitch("Hide Name", function(state)
	tabs.main.RedactConfig.RedactName = state
	tabs.main.applyNameVisibility()
	tabs.main.saveRedactConfig()
end)
tabs.main.HideNameSwitch:Set(tabs.main.RedactConfig.RedactName)
tabs.main.RedactStatsSwitch = tabs.main:AddSwitch("Hide Stats", function(state)
	tabs.main.RedactConfig.RedactStats = state
	tabs.main.applyStatsVisibility()
	tabs.main.saveRedactConfig()
end)
tabs.main.RedactStatsSwitch:Set(tabs.main.RedactConfig.RedactStats)

utils.playerData.Player.CharacterAdded:Connect(function(character, head)
	task.defer(tabs.main.applyStatsVisibility)
	if character.Name ~= "HenneZocktTV" then return end
	head = character:WaitForChild("Head", 10)
	if head and head:WaitForChild("nameGui", 10) and utils.playerData.Player.Character == character then
		tabs.main.applyNameVisibility()
	end
end)

utils.playerData.Player.CharacterAdded:Connect(function(newChar)
	if tabs.main.Protection.PositionLock.Enabled and newChar:WaitForChild("HumanoidRootPart", 5) then
		tabs.main.Protection.PositionLock.Position = newChar.HumanoidRootPart.Position
		tabs.main.lockPosition()
	end
end)

task.spawn(function()
	while true do
		if tabs.main.Protection.PositionLock.Enabled then tabs.main.lockPosition() end
		task.wait(0.1)
	end
end)



tabs.main.WaterParts = {
	Parts = {},
	PartSize = 2048,
	TotalDistance = 50000,
	StartPosition = Vector3.new(-2, -9.5, -2)
}

task.spawn(function()
	for x = 0, math.ceil(tabs.main.WaterParts.TotalDistance / tabs.main.WaterParts.PartSize) - 1 do
		for z = 0, math.ceil(tabs.main.WaterParts.TotalDistance / tabs.main.WaterParts.PartSize) - 1 do
			for i, offset in ipairs({
				{x * tabs.main.WaterParts.PartSize, z * tabs.main.WaterParts.PartSize, "Side_" .. x .. "_" .. z},
				{-x * tabs.main.WaterParts.PartSize, z * tabs.main.WaterParts.PartSize, "LeftRight_" .. x .. "_" .. z},
				{-x * tabs.main.WaterParts.PartSize, -z * tabs.main.WaterParts.PartSize, "UpLeft_" .. x .. "_" .. z},
				{x * tabs.main.WaterParts.PartSize, -z * tabs.main.WaterParts.PartSize, "UpRight_" .. x .. "_" .. z}
			}) do
				tabs.main.runtime.part = Instance.new("Part")
				tabs.main.runtime.part.Size = Vector3.new(tabs.main.WaterParts.PartSize, 1, tabs.main.WaterParts.PartSize)
				tabs.main.runtime.part.Position = tabs.main.WaterParts.StartPosition + Vector3.new(offset[1], 0, offset[2])
				tabs.main.runtime.part.Anchored = true
				tabs.main.runtime.part.Transparency = 1
				tabs.main.runtime.part.CanCollide = true
				tabs.main.runtime.part.Name = "Part_" .. offset[3]
				tabs.main.runtime.part.Parent = services.Workspace
				table.insert(tabs.main.WaterParts.Parts, tabs.main.runtime.part)
			end
		end
	end
end)

tabs.main.WalkOnWaterSwitch = tabs.main:AddSwitch("Walk on Water", function(bool)
	for _, part in ipairs(tabs.main.WaterParts.Parts) do
		if part and part.Parent then part.CanCollide = bool end
	end
end)
tabs.main.WalkOnWaterSwitch:Set(true)

tabs.main:AddLabel("Other:")

tabs.main:AddSwitch("Infinite Jump", function(bool)
	tabs.main.InfiniteJump = bool
end)
services.UserInputService.JumpRequest:Connect(function(character, humanoid)
	character = utils.playerData.Player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if tabs.main.InfiniteJump and humanoid and humanoid.Health > 0 then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

tabs.main.FortuneWheelData = {
	Running = false,
	Generation = 0,
	Remote = services.ReplicatedStorage.rEvents:WaitForChild("openFortuneWheelRemote"),
	Chances = services.ReplicatedStorage
		:WaitForChild("shared")
		:WaitForChild("catalogs")
		:WaitForChild("fortuneWheelChances")
		:WaitForChild("Fortune Wheel")
}

tabs.main.spinFortuneWheel = function()
	pcall(function()
		tabs.main.FortuneWheelData.Remote:InvokeServer(
			"openFortuneWheel",
			tabs.main.FortuneWheelData.Chances
		)
	end)
end

tabs.main:AddSwitch("Spin Fortune Wheel", function(state)
	tabs.main.FortuneWheelData.Running = state
	tabs.main.FortuneWheelData.Generation += 1
	tabs.main.runtime.generation = tabs.main.FortuneWheelData.Generation

	if not state then return end

	task.spawn(function(generation)
		while tabs.main.FortuneWheelData.Running and tabs.main.FortuneWheelData.Generation == generation do
			tabs.main.spinFortuneWheel()
			task.wait(1)
		end
	end, tabs.main.FortuneWheelData.Generation)
end)

tabs.main.TimeDropdown = tabs.main:AddDropdown("Change Time", function(selection)
	services.Lighting.ClockTime = selection == "Night" and 0 or 9
end)
tabs.main.TimeDropdown:Add("Night")
tabs.main.TimeDropdown:Add("Day")

-- Kill Tab (i never know where it stars)


tabs.killing.getTool = function()
	if not services.Players.LocalPlayer.Character then return end
	for _, v in pairs(services.Players.LocalPlayer.Backpack:GetChildren()) do
		if v.Name == "Punch" and services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			services.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
		end
	end
	services.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
	services.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end

tabs.killing.isPlayerAlive = function(player)
	return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
		player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

tabs.killing.isSpawnProtected = function(player)
	if not player or not player.Character then return false end
	if player.Character:FindFirstChildOfClass("ForceField")
		or player.Character:FindFirstChild("spawnProtectionHighlight") then
		return true
	end
	tabs.killing.runtime.protectedUntil = player.Character:GetAttribute("SpawnProtectedUntil")
	return typeof(tabs.killing.runtime.protectedUntil) == "number" and services.Workspace:GetServerTimeNow() < tabs.killing.runtime.protectedUntil
end

tabs.killing.getLocalCombatCharacter = function()
	tabs.killing.runtime.character_416 = services.Players.LocalPlayer.Character
	tabs.killing.runtime.humanoid_417 = tabs.killing.runtime.character_416 and tabs.killing.runtime.character_416:FindFirstChildOfClass("Humanoid")
	tabs.killing.runtime.humanoidRootPart = tabs.killing.runtime.character_416 and tabs.killing.runtime.character_416:FindFirstChild("HumanoidRootPart")
	if not tabs.killing.runtime.character_416 or not tabs.killing.runtime.humanoid_417 or tabs.killing.runtime.humanoid_417.Health <= 0 or not tabs.killing.runtime.humanoidRootPart then return end
	return tabs.killing.runtime.character_416, tabs.killing.runtime.humanoid_417, tabs.killing.runtime.humanoidRootPart
end

tabs.killing.positionNearTarget = function(target, heightOffset)
	if not tabs.killing.isPlayerAlive(target)
		or tabs.killing.isSpawnProtected(target)
		or tabs.killing.isSpawnProtected(services.Players.LocalPlayer) then
		return false
	end
	tabs.killing.runtime.discardCharacter_localRoot_429, tabs.killing.runtime.discardHumanoid_localRoot_429, tabs.killing.runtime.localRoot_429 = tabs.killing.getLocalCombatCharacter()
	tabs.killing.runtime.targetRoot_430 = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not tabs.killing.runtime.localRoot_429 or not tabs.killing.runtime.targetRoot_430 then return false end

	tabs.killing.runtime.localRoot_429.CFrame = tabs.killing.runtime.targetRoot_430.CFrame * CFrame.new(0, heightOffset, 0)
	tabs.killing.runtime.localRoot_429.AssemblyLinearVelocity = Vector3.zero
	tabs.killing.runtime.localRoot_429.AssemblyAngularVelocity = Vector3.zero
	return true
end

tabs.killing.touchAndPunchTarget = function(target, heightOffset)
	if not tabs.killing.positionNearTarget(target, heightOffset) then return false, false end
	services.RunService.Heartbeat:Wait()
	if not tabs.killing.positionNearTarget(target, heightOffset) then return false, false end

	tabs.killing.runtime.character_444 = tabs.killing.getLocalCombatCharacter()
	tabs.killing.runtime.targetRoot_445 = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	tabs.killing.runtime.targetHumanoid_446 = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if not tabs.killing.runtime.character_444 or not tabs.killing.runtime.targetRoot_445 or not tabs.killing.runtime.targetHumanoid_446 or tabs.killing.isSpawnProtected(target) then return false, false end

	tabs.killing.runtime.hand = tabs.killing.runtime.character_444:FindFirstChild("LeftHand") or tabs.killing.runtime.character_444:FindFirstChild("RightHand")
	if not tabs.killing.runtime.hand then return false, false end

	tabs.killing.runtime.punchTool = tabs.killing.runtime.character_444:FindFirstChild("Punch") or services.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
	tabs.killing.runtime.humanoid_453 = tabs.killing.runtime.character_444:FindFirstChildOfClass("Humanoid")
	if tabs.killing.runtime.punchTool and tabs.killing.runtime.punchTool.Parent ~= tabs.killing.runtime.character_444 and tabs.killing.runtime.humanoid_453 then
		tabs.killing.runtime.humanoid_453:EquipTool(tabs.killing.runtime.punchTool)
	end

	tabs.killing.runtime.healthBefore = tabs.killing.runtime.targetHumanoid_446.Health
	tabs.killing.runtime.attempted_459 = pcall(function()
		utils.touchParts(tabs.killing.runtime.targetRoot_445, tabs.killing.runtime.hand, 0)
		utils.touchParts(tabs.killing.runtime.targetRoot_445, tabs.killing.runtime.hand, 1)
		services.Players.LocalPlayer.muscleEvent:FireServer("punch", tabs.killing.runtime.hand.Name == "LeftHand" and "leftHand" or "rightHand")
	end)
	if not tabs.killing.runtime.attempted_459 then return false, false end

	for _ = 1, 4 do
		services.RunService.Heartbeat:Wait()
		if not tabs.killing.isPlayerAlive(target) or tabs.killing.runtime.targetHumanoid_446.Health < tabs.killing.runtime.healthBefore then
			return true, true
		end
		if tabs.killing.isSpawnProtected(target) then
			return false, false
		end
	end

	return false, true
end

tabs.killing.attackPlayerWithLimit = function(target, hitLimit, shouldContinue, heightOffset, countAttempts, hits, hitRegistered, attempted)
	hits = 0
	while hits < hitLimit and shouldContinue() and tabs.killing.isPlayerAlive(target) and not tabs.killing.isSpawnProtected(target) do
		hitRegistered, attempted = tabs.killing.touchAndPunchTarget(target, heightOffset)
		if countAttempts or hitRegistered then hits = hits + 1 end
		if not attempted and not countAttempts then break end
		if not hitRegistered then task.wait(0.05) end
	end
	return hits
end

tabs.killing.attackPlayerForDuration = function(target, duration, shouldContinue, heightOffset, startedAt, character, targetRoot, leftHand, rightHand, punchTool, humanoid)
	startedAt = os.clock()
	while os.clock() - startedAt < duration
		and shouldContinue()
		and tabs.killing.isPlayerAlive(target)
		and not tabs.killing.isSpawnProtected(target) do
		if tabs.killing.positionNearTarget(target, heightOffset) then
			character = services.Players.LocalPlayer.Character
			targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			leftHand = character and character:FindFirstChild("LeftHand")
			rightHand = character and character:FindFirstChild("RightHand")
			punchTool = character and character:FindFirstChild("Punch") or services.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
			humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if punchTool and humanoid and punchTool.Parent ~= character then humanoid:EquipTool(punchTool) end

			if targetRoot and leftHand and rightHand then
				pcall(function()
					utils.touchParts(targetRoot, leftHand, 0)
					utils.touchParts(targetRoot, leftHand, 1)
					utils.touchParts(targetRoot, rightHand, 0)
					utils.touchParts(targetRoot, rightHand, 1)
					services.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
					services.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
				end)
			end
		end
		services.RunService.Heartbeat:Wait()
	end
end

tabs.killing:AddLabel("Misc:")

tabs.killing.equipBestStatPets = function(priority)
	for _, folder in pairs(services.Players.LocalPlayer.petsFolder:GetChildren()) do
		if folder:IsA("Folder") then
			for _, pet in pairs(folder:GetChildren()) do
				services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
			end
		end
	end

	task.wait(0.2)
	tabs.killing.runtime.petsByName = {}
	for _, petName in ipairs(priority) do tabs.killing.runtime.petsByName[petName] = {} end

	for _, pet in pairs(services.Players.LocalPlayer.petsFolder.Unique:GetChildren()) do
		if tabs.killing.runtime.petsByName[pet.Name] then table.insert(tabs.killing.runtime.petsByName[pet.Name], pet) end
	end

	tabs.killing.runtime.equippedCount = 0
	for _, petName in ipairs(priority) do
		for _, pet in ipairs(tabs.killing.runtime.petsByName[petName]) do
			if tabs.killing.runtime.equippedCount >= 9 then return end
			services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
			tabs.killing.runtime.equippedCount += 1
			task.wait(0.1)
		end
	end
end

tabs.killing:AddButton("Equip Best Damage", function()
	tabs.killing.equipBestStatPets({"Wild Wizard", "Chaos Sorcerer", "Mighty Monster", "Small Fry"})
end)

tabs.killing:AddButton("Equip Best Health", function()
	tabs.killing.equipBestStatPets({"Mighty Monster", "Small Fry", "Wild Wizard", "Chaos Sorcerer"})
end)

tabs.killing:AddSwitch("Remove Attack Animations", function(bool)
	if bool then
		tabs.killing.runtime.blockedAnimations = {
			["3638729053"] = true,
			["3638767427"] = true,
			["507768375"] = true,
			["522635514"] = true,
			["522638767"] = true,
			["182393478"] = true,
			["129967390"] = true,
			["129967478"] = true
		}

		tabs.killing.runtime.shouldBlockAnimation = function(track)
			if not track or not track.Animation then return false end
			tabs.killing.runtime.animationId = tostring(track.Animation.AnimationId):match("%d+")
			tabs.killing.runtime.animationName = string.lower((track.Name or "") .. " " .. (track.Animation.Name or ""))
			return tabs.killing.runtime.blockedAnimations[tabs.killing.runtime.animationId] == true
				or string.find(tabs.killing.runtime.animationName, "punch", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "attack", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "right", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "equip", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "tool", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "hold", 1, true) ~= nil
		end

		tabs.killing.runtime.isAttackTool = function(tool)
			if not tool or not tool:IsA("Tool") then return false end
			tabs.killing.runtime.name = string.lower(tool.Name)
			return string.find(tabs.killing.runtime.name, "punch", 1, true) ~= nil
				or string.find(tabs.killing.runtime.name, "attack", 1, true) ~= nil
				or string.find(tabs.killing.runtime.name, "right", 1, true) ~= nil
		end

		tabs.killing.runtime.hasAttackToolEquipped = function(character)
			if not character then return false end
			for _, child in ipairs(character:GetChildren()) do
				if tabs.killing.runtime.isAttackTool(child) then return true end
			end
			return false
		end

		tabs.killing.runtime.isMovementAnimation = function(track, character)
			tabs.killing.runtime.animation = track and track.Animation
			tabs.killing.runtime.animate = character and character:FindFirstChild("Animate")
			if not tabs.killing.runtime.animation or not tabs.killing.runtime.animate or not tabs.killing.runtime.animation:IsDescendantOf(tabs.killing.runtime.animate) then
				return false
			end

			tabs.killing.runtime.path = ""
			tabs.killing.runtime.current = tabs.killing.runtime.animation
			while tabs.killing.runtime.current and tabs.killing.runtime.current ~= tabs.killing.runtime.animate.Parent do
				tabs.killing.runtime.path = tabs.killing.runtime.path .. " " .. string.lower(tabs.killing.runtime.current.Name)
				if tabs.killing.runtime.current == tabs.killing.runtime.animate then break end
				tabs.killing.runtime.current = tabs.killing.runtime.current.Parent
			end

			if string.find(tabs.killing.runtime.path, "tool", 1, true)
				or string.find(tabs.killing.runtime.path, "punch", 1, true)
				or string.find(tabs.killing.runtime.path, "attack", 1, true)
				or string.find(tabs.killing.runtime.path, "equip", 1, true)
				or string.find(tabs.killing.runtime.path, "hold", 1, true) then
				return false
			end

			for _, movementName in ipairs({"idle", "walk", "run", "jump", "fall", "climb", "swim", "sit"}) do
				if string.find(tabs.killing.runtime.path, movementName, 1, true) then return true end
			end
			return false
		end

		tabs.killing.runtime.stopBlockedAnimations = function(character)
			tabs.killing.runtime.humanoid_603 = character and character:FindFirstChildOfClass("Humanoid")
			if not tabs.killing.runtime.humanoid_603 then return end
			for _, track in ipairs(tabs.killing.runtime.humanoid_603:GetPlayingAnimationTracks()) do
				if tabs.killing.runtime.shouldBlockAnimation(track) then track:Stop(0) end
			end
		end

		tabs.killing.runtime.stopEquipAnimations = function(character)
			tabs.killing.runtime.humanoid_611 = character and character:FindFirstChildOfClass("Humanoid")
			if not tabs.killing.runtime.humanoid_611 then return end
			for _, track in ipairs(tabs.killing.runtime.humanoid_611:GetPlayingAnimationTracks()) do
				tabs.killing.runtime.priority = track.Priority
				if tabs.killing.runtime.shouldBlockAnimation(track)
					or not tabs.killing.runtime.isMovementAnimation(track, character)
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action2
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action3
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action4 then
					track:Stop(0)
				end
			end
		end

		tabs.killing.runtime.setupAnimationBlocking = function()
			tabs.killing.runtime.char_627 = services.Players.LocalPlayer.Character
			tabs.killing.runtime.humanoid_628 = tabs.killing.runtime.char_627 and tabs.killing.runtime.char_627:FindFirstChildOfClass("Humanoid")
			if not tabs.killing.runtime.humanoid_628 then return end

			tabs.killing.runtime.stopBlockedAnimations(tabs.killing.runtime.char_627)
			if _G.AnimBlockConnection then _G.AnimBlockConnection:Disconnect() end
			_G.AnimBlockConnection = tabs.killing.runtime.humanoid_628.AnimationPlayed:Connect(function(track)
				if tabs.killing.runtime.shouldBlockAnimation(track)
					or (tabs.killing.runtime.hasAttackToolEquipped(tabs.killing.runtime.char_627) and not tabs.killing.runtime.isMovementAnimation(track, tabs.killing.runtime.char_627)) then
					track:Stop(0)
				end
			end)
		end

		tabs.killing.runtime.processTool = function(tool)
			if tabs.killing.runtime.isAttackTool(tool) then
				if not tool:GetAttribute("ActivatedOverride") then
					tool:SetAttribute("ActivatedOverride", true)

					_G.ToolConnections = _G.ToolConnections or {}
					_G.ToolConnections[tool] = tool.Activated:Connect(function()
						task.wait(0.05)
						tabs.killing.runtime.stopBlockedAnimations(services.Players.LocalPlayer.Character)
					end)

					_G.ToolEquipConnections = _G.ToolEquipConnections or {}
					_G.ToolEquipConnections[tool] = tool.Equipped:Connect(function()
						for _, delayTime in ipairs({0, 0.03, 0.08, 0.15, 0.25}) do
							task.delay(delayTime, function()
								tabs.killing.runtime.stopEquipAnimations(services.Players.LocalPlayer.Character)
							end)
						end
					end)
				end

				if tool.Parent == services.Players.LocalPlayer.Character then
					tabs.killing.runtime.stopEquipAnimations(services.Players.LocalPlayer.Character)
				end
			end
		end

		tabs.killing.runtime.overrideToolActivation = function()
			for _, tool in pairs(services.Players.LocalPlayer.Backpack:GetChildren()) do
				tabs.killing.runtime.processTool(tool)
			end

			tabs.killing.runtime.char_673 = services.Players.LocalPlayer.Character
			if tabs.killing.runtime.char_673 then
				for _, tool in pairs(tabs.killing.runtime.char_673:GetChildren()) do
					if tool:IsA("Tool") then
						tabs.killing.runtime.processTool(tool)
					end
				end
			end

			_G.BackpackAddedConnection = services.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
				if child:IsA("Tool") then
					task.wait(0.1)
					tabs.killing.runtime.processTool(child)
				end
			end)

			if tabs.killing.runtime.char_673 then
				_G.CharacterToolAddedConnection = tabs.killing.runtime.char_673.ChildAdded:Connect(function(child)
					if child:IsA("Tool") then
						task.wait(0.1)
						tabs.killing.runtime.processTool(child)
					end
				end)
			end
		end

		_G.AnimMonitorConnection = services.RunService.RenderStepped:Connect(function()
			tabs.killing.runtime.character_700 = services.Players.LocalPlayer.Character
			if tabs.killing.runtime.hasAttackToolEquipped(tabs.killing.runtime.character_700) then
				tabs.killing.runtime.stopEquipAnimations(tabs.killing.runtime.character_700)
			else
				tabs.killing.runtime.stopBlockedAnimations(tabs.killing.runtime.character_700)
			end
		end)

		_G.CharacterAddedConnection = services.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
			task.wait(1)
			tabs.killing.runtime.setupAnimationBlocking()
			tabs.killing.runtime.overrideToolActivation()

			if _G.CharacterToolAddedConnection then
				_G.CharacterToolAddedConnection:Disconnect()
			end

			_G.CharacterToolAddedConnection = newChar.ChildAdded:Connect(function(child)
				if child:IsA("Tool") then
					task.wait(0.1)
					tabs.killing.runtime.processTool(child)
				end
			end)
		end)

		tabs.killing.runtime.setupAnimationBlocking()
		tabs.killing.runtime.overrideToolActivation()
	else
		if _G.AnimBlockConnection then
			_G.AnimBlockConnection:Disconnect()
			_G.AnimBlockConnection = nil
		end

		if _G.AnimMonitorConnection then
			_G.AnimMonitorConnection:Disconnect()
			_G.AnimMonitorConnection = nil
		end

		if _G.CharacterAddedConnection then
			_G.CharacterAddedConnection:Disconnect()
			_G.CharacterAddedConnection = nil
		end

		if _G.BackpackAddedConnection then
			_G.BackpackAddedConnection:Disconnect()
			_G.BackpackAddedConnection = nil
		end

		if _G.CharacterToolAddedConnection then
			_G.CharacterToolAddedConnection:Disconnect()
			_G.CharacterToolAddedConnection = nil
		end

		if _G.ToolConnections then
			for tool, connection in pairs(_G.ToolConnections) do
				if connection then
					connection:Disconnect()
				end
				if tool and tool:GetAttribute("ActivatedOverride") then
					tool:SetAttribute("ActivatedOverride", nil)
				end
			end
			_G.ToolConnections = nil
		end

		if _G.ToolEquipConnections then
			for _, connection in pairs(_G.ToolEquipConnections) do
				if connection then connection:Disconnect() end
			end
			_G.ToolEquipConnections = nil
		end
	end
end)

tabs.killing:AddLabel("Auto Kill:")

_G.whitelistedPlayers = _G.whitelistedPlayers or {}
_G.blacklistedPlayers = _G.blacklistedPlayers or {}

for _, connectionName in ipairs({
	"killAllConnection",
	"farmBadKarmaConnection",
	"farmGoodKarmaConnection",
	"blacklistKillConnection",
	"deathRingConnection"
}) do
	tabs.killing.runtime.connection = _G[connectionName]
	if tabs.killing.runtime.connection then
		pcall(function() tabs.killing.runtime.connection:Disconnect() end)
		_G[connectionName] = nil
	end
end

_G.killAll = false
_G.killBlacklistedOnly = false
_G.farmBadKarma = false
_G.farmGoodKarma = false
_G.deathRingEnabled = false
_G.killAllGeneration = (_G.killAllGeneration or 0) + 1
_G.killListGeneration = (_G.killListGeneration or 0) + 1

tabs.killing.isWhitelisted = function(player)
	for _, name in ipairs(_G.whitelistedPlayers) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

tabs.killing.isBlacklisted = function(player)
	for _, name in ipairs(_G.blacklistedPlayers) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

tabs.killing.RemoveWhitelistDropdown = nil
tabs.killing.WhitelistDisplayNames = {}

tabs.killing.getWhitelistDisplayName = function(username)
	local cached = tabs.killing.WhitelistDisplayNames[username]
	if cached then return cached end
	local player = services.Players:FindFirstChild(username)
	if player then
		tabs.killing.WhitelistDisplayNames[username] = player.DisplayName
		return player.DisplayName
	end
	return username
end

tabs.killing.WhitelistDropdown = tabs.killing:AddDropdown("Add to Whitelist", function(selectedText)
	tabs.killing.runtime.playerName_817 = selectedText:match("| (.+)$")
	if tabs.killing.runtime.playerName_817 then
		tabs.killing.runtime.playerName_817 = tabs.killing.runtime.playerName_817:gsub("^%s*(.-)%s*$", "%1")
		local selectedPlayer = services.Players:FindFirstChild(tabs.killing.runtime.playerName_817)
		if selectedPlayer then tabs.killing.WhitelistDisplayNames[selectedPlayer.Name] = selectedPlayer.DisplayName end
		for _, name in ipairs(_G.whitelistedPlayers) do
			if name:lower() == tabs.killing.runtime.playerName_817:lower() then return end
		end
		table.insert(_G.whitelistedPlayers, tabs.killing.runtime.playerName_817)
		if tabs.killing.RemoveWhitelistDropdown then
			tabs.killing.RemoveWhitelistDropdown:Add(tabs.killing.getWhitelistDisplayName(tabs.killing.runtime.playerName_817))
		end
	end
end)

tabs.killing:AddSwitch("Kill Everyone", function(bool)
	_G.killAll = bool
	_G.killAllGeneration = (_G.killAllGeneration or 0) + 1
	tabs.killing.runtime.generation_831 = _G.killAllGeneration
	if not bool then return end

	task.spawn(function(generation, foundTarget)
		while _G.killAll and _G.killAllGeneration == generation do
			foundTarget = false
			for _, player in ipairs(services.Players:GetPlayers()) do
				if not _G.killAll or _G.killAllGeneration ~= generation then break end
				if player ~= services.Players.LocalPlayer
					and not tabs.killing.isWhitelisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player) then
					foundTarget = true
					tabs.killing.attackPlayerForDuration(player, 4, function()
						return _G.killAll and _G.killAllGeneration == generation and not tabs.killing.isWhitelisted(player)
					end, 3.5)
				end
			end
			if foundTarget then
				services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end, tabs.killing.runtime.generation_831)
end)

tabs.killing:AddSwitch("Whitelist Friends", function(bool)
	_G.whitelistFriends = bool

	if bool then
		for _, player in pairs(services.Players:GetPlayers()) do
			if player ~= services.Players.LocalPlayer and player:IsFriendsWith(services.Players.LocalPlayer.UserId) then
				if not tabs.killing.isWhitelisted(player) then
					table.insert(_G.whitelistedPlayers, player.Name)
				end
			end
		end

		_G.friendWhitelistConnection = services.Players.PlayerAdded:Connect(function(player)
			if _G.whitelistFriends and player:IsFriendsWith(services.Players.LocalPlayer.UserId) then
				if not tabs.killing.isWhitelisted(player) then
					table.insert(_G.whitelistedPlayers, player.Name)
				end
			end
		end)

		_G.friendCheckLoop = task.spawn(function()
			while _G.whitelistFriends do
				task.wait(3)
				for _, player in pairs(services.Players:GetPlayers()) do
					if player ~= services.Players.LocalPlayer and player:IsFriendsWith(services.Players.LocalPlayer.UserId) then
						if not tabs.killing.isWhitelisted(player) then
							table.insert(_G.whitelistedPlayers, player.Name)
						end
					end
				end
			end
		end)
	else
		if _G.friendWhitelistConnection then
			_G.friendWhitelistConnection:Disconnect()
			_G.friendWhitelistConnection = nil
		end
		if _G.friendCheckLoop then
			task.cancel(_G.friendCheckLoop)
			_G.friendCheckLoop = nil
		end
	end
end)

tabs.killing:AddLabel("Karma Killing:")

tabs.killing.KarmaData = {FarmEvil = false, FarmGood = false, Generation = 0}

tabs.killing.matchesKarmaMode = function(player)
	tabs.killing.runtime.goodKarma = player:FindFirstChild("goodKarma")
	tabs.killing.runtime.evilKarma = player:FindFirstChild("evilKarma")
	if not tabs.killing.runtime.goodKarma or not tabs.killing.runtime.evilKarma then return false end

	tabs.killing.runtime.goodValue = tabs.killing.runtime.goodKarma.Value or 0
	tabs.killing.runtime.evilValue = tabs.killing.runtime.evilKarma.Value or 0
	if tabs.killing.runtime.goodValue + tabs.killing.runtime.evilValue < 5 then return false end
	return (tabs.killing.KarmaData.FarmEvil and tabs.killing.runtime.goodValue > tabs.killing.runtime.evilValue)
		or (tabs.killing.KarmaData.FarmGood and tabs.killing.runtime.evilValue > tabs.killing.runtime.goodValue)
end

tabs.killing.restartKarmaWorker = function()
	tabs.killing.KarmaData.Generation += 1
	tabs.killing.runtime.generation_921 = tabs.killing.KarmaData.Generation
	if not tabs.killing.KarmaData.FarmEvil and not tabs.killing.KarmaData.FarmGood then return end

	task.spawn(function(generation)
		while (tabs.killing.KarmaData.FarmEvil or tabs.killing.KarmaData.FarmGood) and tabs.killing.KarmaData.Generation == generation do
			tabs.killing.runtime.foundTarget_926 = false
			for _, player in ipairs(services.Players:GetPlayers()) do
				if tabs.killing.KarmaData.Generation ~= generation then break end
				if player ~= services.Players.LocalPlayer
					and not tabs.killing.isWhitelisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player)
					and tabs.killing.matchesKarmaMode(player) then
					tabs.killing.runtime.foundTarget_926 = true
					tabs.killing.attackPlayerWithLimit(player, 4, function()
						return tabs.killing.KarmaData.Generation == generation
							and not tabs.killing.isWhitelisted(player)
							and tabs.killing.matchesKarmaMode(player)
					end, 3.5)
				end
			end
			if tabs.killing.runtime.foundTarget_926 then
				services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end, tabs.killing.KarmaData.Generation)
end

tabs.killing:AddSwitch("Farm Evil Karma", function(state)
	tabs.killing.KarmaData.FarmEvil = state
	tabs.killing.restartKarmaWorker()
end)

tabs.killing:AddSwitch("Farm Good Karma", function(state)
	tabs.killing.KarmaData.FarmGood = state
	tabs.killing.restartKarmaWorker()
end)



tabs.killing:AddLabel("Target Killing:")

tabs.killing.RemoveKilllistDropdown = nil
tabs.killing.KilllistDisplayNames = {}

tabs.killing.getKilllistDisplayName = function(username)
	local cached = tabs.killing.KilllistDisplayNames[username]
	if cached then return cached end
	local player = services.Players:FindFirstChild(username)
	if player then
		tabs.killing.KilllistDisplayNames[username] = player.DisplayName
		return player.DisplayName
	end
	return username
end

tabs.killing.BlacklistDropdown = tabs.killing:AddDropdown("Add to Killlist", function(selectedText)
	local selectedUsername = selectedText:match("| (.+)$")
	local selectedPlayer = selectedUsername and services.Players:FindFirstChild(selectedUsername:gsub("^%s*(.-)%s*$", "%1"))
	if selectedPlayer then
		tabs.killing.runtime.playerName_967 = selectedPlayer.Name
		tabs.killing.KilllistDisplayNames[selectedPlayer.Name] = selectedPlayer.DisplayName
		if not tabs.killing.isBlacklisted({Name = tabs.killing.runtime.playerName_967}) then
			table.insert(_G.blacklistedPlayers, tabs.killing.runtime.playerName_967)
			if tabs.killing.RemoveKilllistDropdown then
				tabs.killing.RemoveKilllistDropdown:Add(selectedPlayer.DisplayName)
			end
		end
	end
end)

for _, player in ipairs(services.Players:GetPlayers()) do
	if player ~= services.Players.LocalPlayer then
		tabs.killing.WhitelistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
		tabs.killing.KilllistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.BlacklistDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end

services.Players.PlayerAdded:Connect(function(player)
	if player ~= services.Players.LocalPlayer then
		tabs.killing.WhitelistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
		tabs.killing.KilllistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.BlacklistDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end)

services.Players.PlayerRemoving:Connect(function(player)
	tabs.killing.WhitelistDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	tabs.killing.BlacklistDropdown:Remove(player.DisplayName .. " | " .. player.Name)
end)

tabs.killing.TargetKillAntiGravityName = "SilenceTargetKillAntiGravity"
tabs.killing.TargetKillHeightOffset = 10
tabs.killing.TargetKillGravityState = {
	Active = false,
	OriginalGravity = nil,
	Connection = nil
}

tabs.killing.setTargetKillAntiGravity = function(enabled)
	tabs.killing.runtime.character_1000 = services.Players.LocalPlayer.Character
	tabs.killing.runtime.root = tabs.killing.runtime.character_1000 and tabs.killing.runtime.character_1000:FindFirstChild("HumanoidRootPart")
	if enabled then
		if not tabs.killing.TargetKillGravityState.Active then
			tabs.killing.TargetKillGravityState.Active = true
			tabs.killing.TargetKillGravityState.OriginalGravity = services.Workspace.Gravity
			services.Workspace.Gravity = 0

			tabs.killing.TargetKillGravityState.Connection = services.RunService.Heartbeat:Connect(function()
				services.Workspace.Gravity = 0
				tabs.killing.runtime.currentCharacter = services.Players.LocalPlayer.Character
				tabs.killing.runtime.currentRoot = tabs.killing.runtime.currentCharacter and tabs.killing.runtime.currentCharacter:FindFirstChild("HumanoidRootPart")
				if tabs.killing.runtime.currentRoot then
					tabs.killing.runtime.velocity_1013 = tabs.killing.runtime.currentRoot.AssemblyLinearVelocity
					tabs.killing.runtime.currentRoot.AssemblyLinearVelocity = Vector3.new(tabs.killing.runtime.velocity_1013.X, 0, tabs.killing.runtime.velocity_1013.Z)
				end
			end)
		end

		if tabs.killing.runtime.root then
			tabs.killing.runtime.oldAntiGravity = tabs.killing.runtime.root:FindFirstChild(tabs.killing.TargetKillAntiGravityName)
			if tabs.killing.runtime.oldAntiGravity then tabs.killing.runtime.oldAntiGravity:Destroy() end
			tabs.killing.runtime.velocity_1022 = tabs.killing.runtime.root.AssemblyLinearVelocity
			tabs.killing.runtime.root.AssemblyLinearVelocity = Vector3.new(tabs.killing.runtime.velocity_1022.X, 0, tabs.killing.runtime.velocity_1022.Z)
			tabs.killing.runtime.root.AssemblyAngularVelocity = Vector3.zero
		end
	else
		if tabs.killing.TargetKillGravityState.Connection then
			tabs.killing.TargetKillGravityState.Connection:Disconnect()
			tabs.killing.TargetKillGravityState.Connection = nil
		end
		if tabs.killing.TargetKillGravityState.Active then
			services.Workspace.Gravity = tabs.killing.TargetKillGravityState.OriginalGravity or 196.2
		end
		tabs.killing.TargetKillGravityState.Active = false
		tabs.killing.TargetKillGravityState.OriginalGravity = nil
	end
end

tabs.killing:AddSwitch("Kill List", function(bool)
	_G.killBlacklistedOnly = bool
	_G.killListGeneration = (_G.killListGeneration or 0) + 1
	tabs.killing.runtime.generation_1042 = _G.killListGeneration
	if not bool then
		tabs.killing.setTargetKillAntiGravity(false)
		return
	end
	tabs.killing.setTargetKillAntiGravity(true)

	task.spawn(function(generation, target)
		while _G.killBlacklistedOnly and _G.killListGeneration == generation do
			target = nil
			for _, player in ipairs(services.Players:GetPlayers()) do
				if not _G.killBlacklistedOnly or _G.killListGeneration ~= generation then break end
				if player ~= services.Players.LocalPlayer
					and tabs.killing.isBlacklisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player) then
					target = player
					break
				end
			end

			if target then
				pcall(function()
					while _G.killBlacklistedOnly
						and _G.killListGeneration == generation
						and target.Parent == services.Players
						and tabs.killing.isBlacklisted(target)
						and tabs.killing.isPlayerAlive(target)
						and not tabs.killing.isSpawnProtected(target) do
						tabs.killing.runtime.discardHit_attempted, tabs.killing.runtime.attempted_1071 = tabs.killing.touchAndPunchTarget(target, tabs.killing.TargetKillHeightOffset)
						if not tabs.killing.runtime.attempted_1071 then task.wait(0.1) end
					end
				end)
				services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end, tabs.killing.runtime.generation_1042)
end)

tabs.killing.SpectateData = {
	SelectedPlayer = nil,
	SelectedPlayerUserId = nil,
	Spectating = false,
	CurrentTargetConnection = nil,
	LocalPlayerRespawnConnection = nil,
	CameraMonitorLoop = nil
}

tabs.killing.SpectateState = tabs.killing.SpectateState or {
	SavedUserId = nil,
	IsSpectating = false
}

tabs.killing.stopSpectating = function()
	if tabs.killing.SpectateData.CurrentTargetConnection then
		tabs.killing.SpectateData.CurrentTargetConnection:Disconnect()
		tabs.killing.SpectateData.CurrentTargetConnection = nil
	end

	if tabs.killing.SpectateData.CameraMonitorLoop then
		tabs.killing.SpectateData.CameraMonitorLoop = false
	end

	tabs.killing.runtime.localPlayer_1110 = services.Players.LocalPlayer
	if tabs.killing.runtime.localPlayer_1110.Character then
		tabs.killing.runtime.humanoid_1112 = tabs.killing.runtime.localPlayer_1110.Character:FindFirstChildOfClass("Humanoid")
		if tabs.killing.runtime.humanoid_1112 then
			utils.playerData.Camera.CameraSubject = tabs.killing.runtime.humanoid_1112
			utils.playerData.Camera.CameraType = Enum.CameraType.Custom
		end
	end

	if utils.playerData.Humanoid then
		utils.playerData.Camera.CameraSubject = utils.playerData.Humanoid
	end
end

tabs.killing.startCameraMonitor = function()
	if tabs.killing.SpectateData.CameraMonitorLoop then
		tabs.killing.SpectateData.CameraMonitorLoop = false
		task.wait(0.3)
	end

	tabs.killing.SpectateData.CameraMonitorLoop = true

	task.spawn(function()
		while tabs.killing.SpectateData.CameraMonitorLoop do
			task.wait(0.2)
			if tabs.killing.SpectateData.Spectating and tabs.killing.SpectateData.SelectedPlayer then
				tabs.killing.runtime.targetChar = tabs.killing.SpectateData.SelectedPlayer.Character
				if tabs.killing.runtime.targetChar then
					tabs.killing.runtime.targetHumanoid_1138 = tabs.killing.runtime.targetChar:FindFirstChildOfClass("Humanoid")
					if tabs.killing.runtime.targetHumanoid_1138 then
						if utils.playerData.Camera.CameraSubject ~= tabs.killing.runtime.targetHumanoid_1138 then
							utils.playerData.Camera.CameraSubject = tabs.killing.runtime.targetHumanoid_1138
						end
					end
				end
			else
				break
			end
		end
	end)
end

tabs.killing.updateSpectateTarget = function(player)
	if not player then
		if tabs.killing.SpectateData.SelectedPlayerUserId then
			for _, p in ipairs(services.Players:GetPlayers()) do
				if p.UserId == tabs.killing.SpectateData.SelectedPlayerUserId then
					player = p
					tabs.killing.SpectateData.SelectedPlayer = player
					break
				end
			end
		end

		if not player and tabs.killing.SpectateState.SavedUserId then
			for _, p in ipairs(services.Players:GetPlayers()) do
				if p.UserId == tabs.killing.SpectateState.SavedUserId then
					player = p
					tabs.killing.SpectateData.SelectedPlayer = player
					tabs.killing.SpectateData.SelectedPlayerUserId = p.UserId
					break
				end
			end
		end

		if not player then
			tabs.killing.stopSpectating()
			return
		end
	end

	tabs.killing.SpectateData.SelectedPlayerUserId = player.UserId
	tabs.killing.SpectateData.SelectedPlayer = player

	if tabs.killing.SpectateData.CurrentTargetConnection then
		tabs.killing.SpectateData.CurrentTargetConnection:Disconnect()
		tabs.killing.SpectateData.CurrentTargetConnection = nil
	end

	tabs.killing.runtime.setCamera = function(char)
		if not tabs.killing.SpectateData.Spectating or tabs.killing.SpectateData.SelectedPlayerUserId ~= player.UserId then
			return
		end
		tabs.killing.runtime.humanoid_1193 = char:WaitForChild("Humanoid", 3)
		if tabs.killing.runtime.humanoid_1193 and tabs.killing.SpectateData.Spectating and tabs.killing.SpectateData.SelectedPlayerUserId == player.UserId then
			utils.playerData.Camera.CameraSubject = tabs.killing.runtime.humanoid_1193
		end
	end

	if player.Character then
		tabs.killing.runtime.setCamera(player.Character)
	end

	tabs.killing.SpectateData.CurrentTargetConnection = player.CharacterAdded:Connect(function(newChar)
		if tabs.killing.SpectateData.Spectating and tabs.killing.SpectateData.SelectedPlayerUserId == player.UserId then
			tabs.killing.runtime.setCamera(newChar)
		end
	end)
end

tabs.killing.getPlayers = function()
	return services.Players:GetPlayers()
end

tabs.killing.SpectateDropdown = tabs.killing:AddDropdown("Choose Player", function(text)
	for _, player in ipairs(tabs.killing.getPlayers()) do
		tabs.killing.runtime.optionText = player.DisplayName .. " | " .. player.Name
		if text == tabs.killing.runtime.optionText then
			tabs.killing.SpectateData.SelectedPlayer = player
			tabs.killing.SpectateData.SelectedPlayerUserId = player.UserId
			tabs.killing.SpectateState.SavedUserId = player.UserId
			if tabs.killing.SpectateData.Spectating then
				tabs.killing.updateSpectateTarget(player)
			end
			break
		end
	end
end)

tabs.killing:AddSwitch("Spectate", function(bool)
	tabs.killing.SpectateData.Spectating = bool
	tabs.killing.SpectateState.IsSpectating = bool

	if tabs.killing.SpectateData.Spectating then
		if tabs.killing.SpectateData.SelectedPlayerUserId then
			tabs.killing.SpectateState.SavedUserId = tabs.killing.SpectateData.SelectedPlayerUserId
		end
		tabs.killing.updateSpectateTarget()
		tabs.killing.startCameraMonitor()
	else
		tabs.killing.stopSpectating()
		task.wait(0.1)
		tabs.killing.runtime.localPlayer_1242 = services.Players.LocalPlayer
		if tabs.killing.runtime.localPlayer_1242.Character then
			tabs.killing.runtime.humanoid_1244 = tabs.killing.runtime.localPlayer_1242.Character:FindFirstChildOfClass("Humanoid")
			if tabs.killing.runtime.humanoid_1244 then
				utils.playerData.Camera.CameraSubject = tabs.killing.runtime.humanoid_1244
			end
		end
		tabs.killing.SpectateState.IsSpectating = false
	end
end)

for _, player in ipairs(tabs.killing.getPlayers()) do
	tabs.killing.SpectateDropdown:Add(player.DisplayName .. " | " .. player.Name)
end

services.Players.PlayerAdded:Connect(function(player)
	tabs.killing.SpectateDropdown:Add(player.DisplayName .. " | " .. player.Name)
	if tabs.killing.SpectateState.IsSpectating and tabs.killing.SpectateState.SavedUserId == player.UserId then
		tabs.killing.SpectateData.Spectating = true
		tabs.killing.SpectateData.SelectedPlayer = player
		tabs.killing.SpectateData.SelectedPlayerUserId = player.UserId
		tabs.killing.updateSpectateTarget(player)
	end
end)

services.Players.PlayerRemoving:Connect(function(player)
	tabs.killing.SpectateDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	if player.UserId == tabs.killing.SpectateData.SelectedPlayerUserId then
		if tabs.killing.SpectateData.Spectating then
			tabs.killing.stopSpectating()

			tabs.killing.SpectateData.SelectedPlayer = nil
			tabs.killing.SpectateData.CurrentTargetConnection = nil

			tabs.killing.runtime.localPlayer_1275 = services.Players.LocalPlayer
			if tabs.killing.runtime.localPlayer_1275.Character and utils.playerData.Humanoid then
				utils.playerData.Camera.CameraSubject = utils.playerData.Humanoid
			end
		end
	end
end)

if tabs.killing.SpectateData.LocalPlayerRespawnConnection then
	tabs.killing.SpectateData.LocalPlayerRespawnConnection:Disconnect()
end

tabs.killing.SpectateData.LocalPlayerRespawnConnection = services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	tabs.killing.runtime.humanoid_1288 = char:WaitForChild("Humanoid", 3)
	if tabs.killing.runtime.humanoid_1288 then
		utils.playerData.Humanoid = tabs.killing.runtime.humanoid_1288
	end

	task.wait(0.5)

	if tabs.killing.SpectateState.IsSpectating then
		tabs.killing.SpectateData.Spectating = true
		tabs.killing.updateSpectateTarget()
		tabs.killing.startCameraMonitor()
	else
		if utils.playerData.Humanoid then
			utils.playerData.Camera.CameraSubject = utils.playerData.Humanoid
		end
	end
end)

tabs.killing:AddLabel("Kill Aura:")

tabs.killing.KillAura = {
	RingPart = nil,
	RingColor = Color3.fromRGB(138, 0, 0),
	RingTransparency = 0.6,
	CenterCFrame = nil,
	Frozen = false,
	Generation = 0
}
_G.showDeathRing = false
_G.deathRingRange = 20

tabs.killing.StaleRing = services.Workspace:FindFirstChild("SilenceKillAuraRing")
if tabs.killing.StaleRing then tabs.killing.StaleRing:Destroy() end

tabs.killing:AddTextBox("Range (1-140):", function(text)
	if tonumber(text) then
		_G.deathRingRange = math.clamp(tonumber(text), 1, 140)
		if tabs.killing.KillAura.RingPart then
			tabs.killing.KillAura.RingPart.Size = Vector3.new(0.2, _G.deathRingRange * 2, _G.deathRingRange * 2)
		end
	end
end, {clear = false})

tabs.killing.RingColors = {
	{Name = "Silence", Color = Color3.fromRGB(138, 0, 0)},
	{Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
	{Name = "Orange", Color = Color3.fromRGB(255, 128, 0)},
	{Name = "Yellow", Color = Color3.fromRGB(255, 230, 0)},
	{Name = "Lime", Color = Color3.fromRGB(128, 255, 0)},
	{Name = "Green", Color = Color3.fromRGB(0, 200, 70)},
	{Name = "Cyan", Color = Color3.fromRGB(0, 220, 255)},
	{Name = "Blue", Color = Color3.fromRGB(0, 100, 255)},
	{Name = "Purple", Color = Color3.fromRGB(145, 70, 255)},
	{Name = "Pink", Color = Color3.fromRGB(255, 80, 180)},
	{Name = "White", Color = Color3.fromRGB(255, 255, 255)},
	{Name = "Black", Color = Color3.fromRGB(0, 0, 0)}
}

tabs.killing.RingColorDropdown = tabs.killing:AddDropdown("Ring Color", function(selection)
	for _, colorData in ipairs(tabs.killing.RingColors) do
		if colorData.Name == selection then
			tabs.killing.KillAura.RingColor = colorData.Color
			if tabs.killing.KillAura.RingPart then tabs.killing.KillAura.RingPart.Color = colorData.Color end
			break
		end
	end
end)
for _, colorData in ipairs(tabs.killing.RingColors) do
	tabs.killing.RingColorDropdown:Add(colorData.Name)
end

tabs.killing.destroyKillAuraRing = function()
	if tabs.killing.KillAura.RingPart then
		tabs.killing.KillAura.RingPart:Destroy()
		tabs.killing.KillAura.RingPart = nil
	end
end

tabs.killing.createKillAuraRing = function()
	tabs.killing.destroyKillAuraRing()
	tabs.killing.runtime.oldRing = services.Workspace:FindFirstChild("SilenceKillAuraRing")
	if tabs.killing.runtime.oldRing then tabs.killing.runtime.oldRing:Destroy() end

	tabs.killing.KillAura.RingPart = Instance.new("Part")
	tabs.killing.KillAura.RingPart.Name = "SilenceKillAuraRing"
	tabs.killing.KillAura.RingPart.Shape = Enum.PartType.Cylinder
	tabs.killing.KillAura.RingPart.Material = Enum.Material.Neon
	tabs.killing.KillAura.RingPart.Color = tabs.killing.KillAura.RingColor
	tabs.killing.KillAura.RingPart.Transparency = tabs.killing.KillAura.RingTransparency
	tabs.killing.KillAura.RingPart.Anchored = true
	tabs.killing.KillAura.RingPart.CanCollide = false
	tabs.killing.KillAura.RingPart.CanTouch = false
	tabs.killing.KillAura.RingPart.CanQuery = false
	tabs.killing.KillAura.RingPart.CastShadow = false
	tabs.killing.KillAura.RingPart.Size = Vector3.new(0.2, _G.deathRingRange * 2, _G.deathRingRange * 2)
	if tabs.killing.KillAura.CenterCFrame then
		tabs.killing.KillAura.RingPart.CFrame = tabs.killing.KillAura.CenterCFrame * CFrame.Angles(0, 0, math.rad(90))
	end
	tabs.killing.KillAura.RingPart.Parent = services.Workspace
end

tabs.killing.ShowRingSwitch = nil
tabs.killing.ShowRingSwitch = tabs.killing:AddSwitch("Show Ring", function(bool)
	if bool and not _G.deathRingEnabled then
		_G.showDeathRing = false
		tabs.killing.ShowRingSwitch:Set(false)
		return
	end

	_G.showDeathRing = bool
	if bool then
		tabs.killing.createKillAuraRing()
	else
		tabs.killing.destroyKillAuraRing()
	end
end)

if _G.deathRingConnection then
	_G.deathRingConnection:Disconnect()
	_G.deathRingConnection = nil
end

tabs.killing.updateKillAuraRing = function()
	if tabs.killing.KillAura.RingPart and tabs.killing.KillAura.CenterCFrame then
		tabs.killing.KillAura.RingPart.CFrame = tabs.killing.KillAura.CenterCFrame * CFrame.Angles(0, 0, math.rad(90))
	end
end

tabs.killing:AddSwitch("Toggle Ring", function(bool)
	_G.deathRingEnabled = bool
	tabs.killing.KillAura.Generation += 1
	tabs.killing.runtime.generation_1419 = tabs.killing.KillAura.Generation
	tabs.killing.KillAura.Frozen = false
	if not bool then
		if tabs.killing.ShowRingSwitch and _G.showDeathRing then tabs.killing.ShowRingSwitch:Set(false) end
		return
	end

	tabs.killing.runtime.discardCharacter_initialRoot, tabs.killing.runtime.discardHumanoid_initialRoot, tabs.killing.runtime.initialRoot = tabs.killing.getLocalCombatCharacter()
	if tabs.killing.runtime.initialRoot then tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.initialRoot.CFrame end

	task.spawn(function(generation)
		while _G.deathRingEnabled and tabs.killing.KillAura.Generation == generation do
			tabs.killing.runtime.discardCharacter_localRoot_1430, tabs.killing.runtime.discardHumanoid_localRoot_1430, tabs.killing.runtime.localRoot_1430 = tabs.killing.getLocalCombatCharacter()
			if tabs.killing.runtime.localRoot_1430 and not tabs.killing.KillAura.Frozen then
				tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.localRoot_1430.CFrame
			end
			tabs.killing.updateKillAuraRing()
			services.RunService.RenderStepped:Wait()
		end
	end, tabs.killing.KillAura.Generation)

	task.spawn(function(generation)
		while _G.deathRingEnabled and tabs.killing.KillAura.Generation == generation do
			if tabs.killing.KillAura.Frozen or not tabs.killing.KillAura.CenterCFrame then
				task.wait(0.05)
				continue
			end

			tabs.killing.runtime.centerCFrame = tabs.killing.KillAura.CenterCFrame
			tabs.killing.runtime.attackedPlayer = false
			for _, player in ipairs(services.Players:GetPlayers()) do
				if not _G.deathRingEnabled or tabs.killing.KillAura.Generation ~= generation then break end
				tabs.killing.runtime.targetRoot_1450 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if player ~= services.Players.LocalPlayer
					and not tabs.killing.isWhitelisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player)
					and tabs.killing.runtime.targetRoot_1450
					and (tabs.killing.runtime.centerCFrame.Position - tabs.killing.runtime.targetRoot_1450.Position).Magnitude <= _G.deathRingRange then
					tabs.killing.runtime.attackedPlayer = true
					tabs.killing.KillAura.Frozen = true
					tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.centerCFrame
					tabs.killing.updateKillAuraRing()

					tabs.killing.attackPlayerWithLimit(player, 4, function()
						tabs.killing.runtime.currentTargetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						return _G.deathRingEnabled
							and tabs.killing.KillAura.Generation == generation
							and not tabs.killing.isWhitelisted(player)
							and tabs.killing.runtime.currentTargetRoot
							and (tabs.killing.runtime.centerCFrame.Position - tabs.killing.runtime.currentTargetRoot.Position).Magnitude <= _G.deathRingRange
					end, 3.5)

					for _ = 1, 4 do
						if not _G.deathRingEnabled or tabs.killing.KillAura.Generation ~= generation then return end
						tabs.killing.runtime.discardCharacter_currentLocalRoot, tabs.killing.runtime.discardHumanoid_currentLocalRoot, tabs.killing.runtime.currentLocalRoot = tabs.killing.getLocalCombatCharacter()
						if tabs.killing.runtime.currentLocalRoot then
							tabs.killing.runtime.currentLocalRoot.CFrame = tabs.killing.runtime.centerCFrame
							tabs.killing.runtime.currentLocalRoot.AssemblyLinearVelocity = Vector3.zero
							tabs.killing.runtime.currentLocalRoot.AssemblyAngularVelocity = Vector3.zero
						end
						tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.centerCFrame
						tabs.killing.updateKillAuraRing()
						services.RunService.Heartbeat:Wait()
					end
					tabs.killing.KillAura.Frozen = false
				end
			end

			if not tabs.killing.runtime.attackedPlayer then task.wait(0.05) end
		end
		if tabs.killing.KillAura.Generation == generation then tabs.killing.KillAura.Frozen = false end
	end, tabs.killing.KillAura.Generation)
end)

tabs.killing.WhitelistLabel = tabs.killing:AddLabel("Whitelist: None")
tabs.killing.RemoveWhitelistDropdown = tabs.killing:AddDropdown("Remove from Whitelist", function(selectedDisplayName)
	for index = #_G.whitelistedPlayers, 1, -1 do
		if tabs.killing.getWhitelistDisplayName(_G.whitelistedPlayers[index]) == selectedDisplayName then
			table.remove(_G.whitelistedPlayers, index)
			break
		end
	end
	tabs.killing.RemoveWhitelistDropdown:Remove(selectedDisplayName)
end)

for _, playerName in ipairs(_G.whitelistedPlayers) do
	tabs.killing.RemoveWhitelistDropdown:Add(tabs.killing.getWhitelistDisplayName(playerName))
end

tabs.killing:AddButton("Clear Whitelist", function()
	_G.whitelistedPlayers = {}
	tabs.killing.RemoveWhitelistDropdown:Clear()
end)

tabs.killing.BlacklistLabel = tabs.killing:AddLabel("Killlist: None")
tabs.killing.RemoveKilllistDropdown = tabs.killing:AddDropdown("Remove from Killlist", function(selectedDisplayName)
	for index = #_G.blacklistedPlayers, 1, -1 do
		if tabs.killing.getKilllistDisplayName(_G.blacklistedPlayers[index]) == selectedDisplayName then
			table.remove(_G.blacklistedPlayers, index)
			break
		end
	end
	tabs.killing.RemoveKilllistDropdown:Remove(selectedDisplayName)
end)

for _, playerName in ipairs(_G.blacklistedPlayers) do
	tabs.killing.RemoveKilllistDropdown:Add(tabs.killing.getKilllistDisplayName(playerName))
end

tabs.killing:AddButton("Clear Killlist", function()
	_G.blacklistedPlayers = {}
	tabs.killing.RemoveKilllistDropdown:Clear()
end)

task.spawn(function()
	while true do
		local displayedWhitelist = {}
		for _, username in ipairs(_G.whitelistedPlayers) do
			table.insert(displayedWhitelist, tabs.killing.getWhitelistDisplayName(username))
		end
		tabs.killing.WhitelistLabel.Text = #displayedWhitelist == 0 and "Whitelist: None" or "Whitelist: " .. table.concat(displayedWhitelist, ", ")
		local displayedKilllist = {}
		for _, username in ipairs(_G.blacklistedPlayers) do
			table.insert(displayedKilllist, tabs.killing.getKilllistDisplayName(username))
		end
		tabs.killing.BlacklistLabel.Text = #displayedKilllist == 0 and "Killlist: None" or "Killlist: " .. table.concat(displayedKilllist, ", ")
		task.wait(0.01)
	end
end)

tabs.specs:AddLabel("Player Stats:")

tabs.specs.Data = {
	PlayerToInspect = nil,
	EmojiMap = {
		["Time"] = utf8.char(0x1F55B), ["Stats"] = utf8.char(0x1F4CA), ["Strength"] = utf8.char(0x1F4AA),
		["Rebirths"] = utf8.char(0x1F504), ["Durability"] = utf8.char(0x1F6E1), ["Kills"] = utf8.char(0x1F480),
		["Agility"] = "⚡", ["Evil Karma"] = utf8.char(0x1F608), ["Good Karma"] = utf8.char(0x1F607),
		["Brawls"] = utf8.char(0x1F94A)
	},
	StatDefinitions = {
		{name = "Strength", statName = "Strength"}, {name = "Rebirths", statName = "Rebirths"},
		{name = "Durability", statName = "Durability"}, {name = "Agility", statName = "Agility"},
		{name = "Kills", statName = "Kills"}, {name = "Evil Karma", statName = "evilKarma"},
		{name = "Good Karma", statName = "goodKarma"}, {name = "Brawls", statName = "Brawls"}
	},
	StatLabels = {}
}

tabs.specs.PlayerDropdown = tabs.specs:AddDropdown("Choose Player", function(text)
	for _, player in ipairs(services.Players:GetPlayers()) do
		if text == player.DisplayName .. " | " .. player.Name then
			tabs.specs.Data.PlayerToInspect = player
			break
		end
	end
end)

for _, player in ipairs(services.Players:GetPlayers()) do
	tabs.specs.PlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
end

services.Players.PlayerAdded:Connect(function(player)
	tabs.specs.PlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
end)

services.Players.PlayerRemoving:Connect(function(player)
	tabs.specs.PlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	if tabs.specs.Data.PlayerToInspect == player then tabs.specs.Data.PlayerToInspect = nil end
end)

tabs.specs.PlayerNameLabel = tabs.specs:AddLabel("👤 Name: N/A")
tabs.specs.PlayerUsernameLabel = tabs.specs:AddLabel("🎫 Username: N/A")

for _, info in ipairs(tabs.specs.Data.StatDefinitions) do
	tabs.specs.Data.StatLabels[info.name] = tabs.specs:AddLabel(tabs.specs.Data.EmojiMap[info.name] .. " " .. info.name .. ": N/A")
end

tabs.specs.updateStatLabels = function(targetPlayer)
	if not targetPlayer then return end
	tabs.specs.PlayerNameLabel.Text = "👤 Name: " .. targetPlayer.DisplayName
	tabs.specs.PlayerUsernameLabel.Text = "🎫 Username: " .. targetPlayer.Name
	if not targetPlayer:FindFirstChild("leaderstats") then return end
	for _, info in ipairs(tabs.specs.Data.StatDefinitions) do
		tabs.specs.runtime.statObject = targetPlayer.leaderstats:FindFirstChild(info.statName) or targetPlayer:FindFirstChild(info.statName)
		if tabs.specs.runtime.statObject then
			tabs.specs.Data.StatLabels[info.name].Text = string.format("%s %s: %s (%s)", tabs.specs.Data.EmojiMap[info.name] or "", info.name,
				utils.formatNumber(tabs.specs.runtime.statObject.Value), utils.formatWithCommas(tabs.specs.runtime.statObject.Value))
		else
			tabs.specs.Data.StatLabels[info.name].Text = tabs.specs.Data.EmojiMap[info.name] .. " " .. info.name .. ": 0 (0)"
		end
	end
end

task.spawn(function()
	while true do
		if tabs.specs.Data.PlayerToInspect then tabs.specs.updateStatLabels(tabs.specs.Data.PlayerToInspect) end
		task.wait(0.1)
	end
end)

tabs.specs:AddLabel("———————————————————————————————————")
tabs.specs:AddLabel("Advanced Stats:")

tabs.specs.AdvancedStats = {
	HealthLabel = tabs.specs:AddLabel("🛡️ Enemy Health: N/A"),
	EnemyDamageLabel = tabs.specs:AddLabel("💥 Enemy Damage: N/A"),
	PlayerHealthLabel = tabs.specs:AddLabel("🛡️ Your Health: N/A"),
	PlayerDamageLabel = tabs.specs:AddLabel("💥 Your Damage: N/A"),
	HitsToKillLabel = tabs.specs:AddLabel("👊 Hits to Kill: N/A")
}

tabs.specs.StatsCache = {
	health = 0,
	enemyDamage = 0,
	playerHealth = 0,
	playerDamage = 0,
	hitsToKill = "N/A"
}

tabs.specs.calculatePlayerHealth = function(targetPlayer)
	if not targetPlayer then return 0 end
	tabs.specs.runtime.durabilityStat = targetPlayer:FindFirstChild("Durability") or
		(targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Durability"))
	if not tabs.specs.runtime.durabilityStat then return 0 end
	tabs.specs.runtime.totalMultiplier_1635 = 1
	if targetPlayer:FindFirstChild("ultimatesFolder") and targetPlayer.ultimatesFolder:FindFirstChild("Infernal Health") then
		tabs.specs.runtime.totalMultiplier_1635 = tabs.specs.runtime.totalMultiplier_1635 + 0.15 * (targetPlayer.ultimatesFolder["Infernal Health"].Value or 0)
	end
	if targetPlayer:FindFirstChild("equippedPets") then
		for _, petValue in ipairs(targetPlayer.equippedPets:GetChildren()) do
			if petValue:IsA("ObjectValue") and petValue.Value then
				if string.lower(petValue.Value.Name):match("mighty") and string.lower(petValue.Value.Name):match("monster") then
					tabs.specs.runtime.totalMultiplier_1635 = tabs.specs.runtime.totalMultiplier_1635 + 0.5
				end
				if string.lower(petValue.Value.Name):match("small") and string.lower(petValue.Value.Name):match("fry") then
					tabs.specs.runtime.totalMultiplier_1635 = tabs.specs.runtime.totalMultiplier_1635 + 0.25
				end
			end
		end
	end
	return tabs.specs.runtime.durabilityStat.Value * tabs.specs.runtime.totalMultiplier_1635
end

tabs.specs.calculatePlayerDamage = function(targetPlayer)
	if not targetPlayer then return 0 end
	if not targetPlayer:FindFirstChild("leaderstats") or not targetPlayer.leaderstats:FindFirstChild("Strength") then return 0 end
	tabs.specs.runtime.baseDamage = targetPlayer.leaderstats.Strength.Value * 0.066666666666666666666666666666666666666666666667
	tabs.specs.runtime.totalMultiplier_1658 = 1
	if targetPlayer:FindFirstChild("ultimatesFolder") and targetPlayer.ultimatesFolder:FindFirstChild("Demon Damage") then
		tabs.specs.runtime.totalMultiplier_1658 = tabs.specs.runtime.totalMultiplier_1658 + 0.1 * (targetPlayer.ultimatesFolder["Demon Damage"].Value or 0)
	end
	if targetPlayer:FindFirstChild("equippedPets") then
		for _, petValue in ipairs(targetPlayer.equippedPets:GetChildren()) do
			if petValue:IsA("ObjectValue") and petValue.Value then
				if string.lower(petValue.Value.Name):match("wild") and string.lower(petValue.Value.Name):match("wizard") then
					tabs.specs.runtime.totalMultiplier_1658 = tabs.specs.runtime.totalMultiplier_1658 + 0.5
				end
				if string.lower(petValue.Value.Name):match("chaos") and string.lower(petValue.Value.Name):match("sorcerer") then
					tabs.specs.runtime.totalMultiplier_1658 = tabs.specs.runtime.totalMultiplier_1658 + 0.25
				end
			end
		end
	end
	return tabs.specs.runtime.baseDamage * tabs.specs.runtime.totalMultiplier_1658
end

tabs.specs.updateAdvancedStats = function(targetPlayer)
	if not targetPlayer then
		tabs.specs.AdvancedStats.HealthLabel.Text = "🛡️ Enemy Health: N/A"
		tabs.specs.AdvancedStats.EnemyDamageLabel.Text = "💥 Enemy Damage: N/A"
		tabs.specs.AdvancedStats.PlayerHealthLabel.Text = "🛡️ Your Health: N/A"
		tabs.specs.AdvancedStats.PlayerDamageLabel.Text = "💥 Your Damage: N/A"
		tabs.specs.AdvancedStats.HitsToKillLabel.Text = "👊 Hits to Kill: N/A"
		return
	end

	tabs.specs.StatsCache.health = tabs.specs.calculatePlayerHealth(targetPlayer)
	tabs.specs.StatsCache.enemyDamage = tabs.specs.calculatePlayerDamage(targetPlayer)
	tabs.specs.StatsCache.playerHealth = tabs.specs.calculatePlayerHealth(utils.playerData.Player)
	tabs.specs.StatsCache.playerDamage = tabs.specs.calculatePlayerDamage(utils.playerData.Player)
	tabs.specs.StatsCache.hitsToKill = tabs.specs.StatsCache.playerDamage <= 0 and "∞" or (math.ceil(tabs.specs.StatsCache.health / tabs.specs.StatsCache.playerDamage) > 200 and "∞" or
		(math.ceil(tabs.specs.StatsCache.health / tabs.specs.StatsCache.playerDamage) < 1 and "instant" or math.ceil(tabs.specs.StatsCache.health / tabs.specs.StatsCache.playerDamage)))

	tabs.specs.AdvancedStats.HealthLabel.Text = string.format("🛡️ Enemy Health: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.health), utils.formatWithCommas(tabs.specs.StatsCache.health))
	tabs.specs.AdvancedStats.EnemyDamageLabel.Text = string.format("💥 Enemy Damage: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.enemyDamage), utils.formatWithCommas(tabs.specs.StatsCache.enemyDamage))
	tabs.specs.AdvancedStats.PlayerHealthLabel.Text = string.format("🛡️ Your Health: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.playerHealth), utils.formatWithCommas(tabs.specs.StatsCache.playerHealth))
	tabs.specs.AdvancedStats.PlayerDamageLabel.Text = string.format("💥 Your Damage: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.playerDamage), utils.formatWithCommas(tabs.specs.StatsCache.playerDamage))
	tabs.specs.AdvancedStats.HitsToKillLabel.Text = string.format("👊 Hits to Kill: %s", tostring(tabs.specs.StatsCache.hitsToKill))
end

task.spawn(function()
	while true do
		tabs.specs.updateAdvancedStats(tabs.specs.Data.PlayerToInspect)
		task.wait(0.1)
	end
end)


tabs.farming:AddLabel("Rebirths:")

tabs.farming.RebirthData = {
	Label = tabs.farming:AddLabel("Rebirths: 0"),
	TargetLabel = tabs.farming:AddLabel("Target: None"),
	Rebirths = utils.playerData.Player.leaderstats:WaitForChild("Rebirths"),
	TargetRebirths = 0,
	IsAutoRebirthing = false,
	Generation = 0
}


tabs.farming:AddTextBox("Set Rebirth Target (Required):", function(text)
	if tonumber(text) and tonumber(text) >= 0 then tabs.farming.RebirthData.TargetRebirths = tonumber(text) end
end)

tabs.farming.RebirthData.Switch = tabs.farming:AddSwitch("Auto Rebirth", function(enabled)
	tabs.farming.RebirthData.Generation += 1
	if enabled and tabs.farming.RebirthData.TargetRebirths > 0 and tabs.farming.RebirthData.Rebirths.Value < tabs.farming.RebirthData.TargetRebirths then
		tabs.farming.RebirthData.IsAutoRebirthing = true
		task.spawn(function(generation)
			while tabs.farming.RebirthData.IsAutoRebirthing
				and tabs.farming.RebirthData.Generation == generation
				and tabs.farming.RebirthData.Rebirths.Value < tabs.farming.RebirthData.TargetRebirths do
				services.ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
				task.wait(0.05)
			end
			if tabs.farming.RebirthData.Generation ~= generation then return end
			tabs.farming.RebirthData.Switch:Set(false)
		end, tabs.farming.RebirthData.Generation)
	else
		tabs.farming.RebirthData.IsAutoRebirthing = false
	end
end)

task.spawn(function()
	while true do
		tabs.farming.RebirthData.Label.Text = "Rebirths: " .. utils.formatWithCommas(tabs.farming.RebirthData.Rebirths.Value)
		tabs.farming.RebirthData.TargetLabel.Text = "Target Rebirths: " .. utils.formatWithCommas(tabs.farming.RebirthData.TargetRebirths)
		task.wait(0.01)
	end
end)

tabs.farming.SizeData = {Active = false}

tabs.farming.SizeSwitch = tabs.farming:AddSwitch("Auto Size 1", function(bool) tabs.farming.SizeData.Active = bool end)
tabs.farming.SizeSwitch:Set(false)

task.spawn(function()
	while true do
		if tabs.farming.SizeData.Active and utils.playerData.Character and utils.playerData.Humanoid then
			utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", 1)
		end
		task.wait(0.01)
	end
end)

tabs.farming.KingData = {TargetPosition = CFrame.new(-8665.4, 17.21, -5792.9), TeleportActive = false}

tabs.farming.KingSwitch = tabs.farming:AddSwitch("Auto King", function(enabled)
	tabs.farming.KingData.TeleportActive = enabled
end)

task.spawn(function()
	while true do
		if tabs.farming.KingData.TeleportActive then
			if not utils.playerData.Character or not utils.playerData.Character:FindFirstChildOfClass("Humanoid") then
				utils.playerData.Player.CharacterAdded:Wait()
				utils.playerData.Character = utils.playerData.Player.Character
				task.wait(2)
			end

			if not utils.playerData.Humanoid or utils.playerData.Humanoid.Health <= 0 then
				repeat
					task.wait(0.5)
					utils.playerData.Character = utils.playerData.Player.Character
					utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")
				until utils.playerData.Character and utils.playerData.Humanoid and utils.playerData.Humanoid.Health > 0
				task.wait(1)
			end

			if tabs.farming.KingData.TeleportActive and utils.playerData.Character and utils.playerData.Character:FindFirstChild("HumanoidRootPart") then
				if (utils.playerData.Character.HumanoidRootPart.Position - tabs.farming.KingData.TargetPosition.Position).magnitude > 5 then
					pcall(function()
						utils.playerData.Character.HumanoidRootPart.CFrame = tabs.farming.KingData.TargetPosition
					end)
				end
			end
		end
		task.wait(0.05)
	end
end)

tabs.farming:AddLabel("Auto Exercises (recommended for rebirthing):")

tabs.farming.ExerciseData = {
	SelectedTool = nil,
	AutoFarm = false,
	Generation = 0
}

tabs.farming.ToolDropdown = tabs.farming:AddDropdown("Select Exercise", function(selection)
	tabs.farming.ExerciseData.SelectedTool = selection
end)
for _, tool in ipairs({"Weight", "Pushups", "Situps", "Handstands"}) do
	tabs.farming.ToolDropdown:Add(tool)
end

tabs.farming.MachinesFolder = services.Workspace:WaitForChild("machinesFolder")
tabs.farming.SquatsByName = {}
tabs.farming.SquatMachineNames = {}
tabs.farming.LiftMachineNames = {}
tabs.farming.MachineCooldownUntil = 0
tabs.farming.MachineExerciseData = {
	Squat = {SelectedMachine = nil, ActiveMachine = nil, Running = false, Generation = 0, ReenterAt = 0, SeatPart = nil, Choices = {}},
	Lift = {SelectedMachine = nil, ActiveMachine = nil, Running = false, Generation = 0, ReenterAt = 0, SeatPart = nil, Choices = {}}
}

for _, machine in ipairs(tabs.farming.MachinesFolder:GetChildren()) do
	tabs.farming.runtime.lowerName = string.lower(machine.Name)
	if string.find(tabs.farming.runtime.lowerName, "squat", 1, true) and tabs.farming.runtime.lowerName ~= "squat rack" then
		tabs.farming.SquatsByName[machine.Name] = tabs.farming.SquatsByName[machine.Name] or {}
		table.insert(tabs.farming.SquatsByName[machine.Name], machine)
	elseif string.find(tabs.farming.runtime.lowerName, "lift", 1, true) and tabs.farming.runtime.lowerName ~= "deadlift" then
		tabs.farming.MachineExerciseData.Lift.Choices[machine.Name] = machine
		table.insert(tabs.farming.LiftMachineNames, machine.Name)
	end
end

for machineName, matchingSquats in pairs(tabs.farming.SquatsByName) do
	tabs.farming.MachineExerciseData.Squat.Choices[machineName] = matchingSquats[1]
	table.insert(tabs.farming.SquatMachineNames, machineName)
end

table.sort(tabs.farming.SquatMachineNames)
table.sort(tabs.farming.LiftMachineNames)

tabs.farming.getMachineInteractPart = function(machine)
	for _, descendant in ipairs(machine:GetDescendants()) do
		if descendant:IsA("BasePart") and string.lower(descendant.Name) == "interactseat" then
			return descendant
		end
	end
end

tabs.farming.enterExerciseMachine = function(machine, machineData, generation, character, root, humanoid, interactPart)
	if not machine or not machine.Parent or not machineData.Running or machineData.Generation ~= generation
		or os.clock() < math.max(machineData.ReenterAt, tabs.farming.MachineCooldownUntil) then return false end
	character = utils.playerData.Player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	interactPart = tabs.farming.getMachineInteractPart(machine)
	if not root or not humanoid or humanoid.Health <= 0 or not interactPart then return false end

	root.CFrame = interactPart.CFrame * CFrame.new(0, 3, 0)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	task.wait(0.4)
	if not machineData.Running or machineData.Generation ~= generation
		or machineData.SelectedMachine ~= machine or utils.playerData.Player.Character ~= character or humanoid.Health <= 0
		or os.clock() < tabs.farming.MachineCooldownUntil then return false end
	machineData.EnteringMachine = machine
	services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	task.wait(0.1)
	services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	task.wait(0.4)
	return machineData.Running and machineData.Generation == generation
		and machineData.SelectedMachine == machine and machineData.SelectedMachine == machine and os.clock() >= tabs.farming.MachineCooldownUntil
		and utils.playerData.Player.Character == character and humanoid.Health > 0
end

tabs.farming.ToolExerciseSwitch = nil
tabs.farming.SquatExerciseSwitch = nil
tabs.farming.LiftExerciseSwitch = nil

tabs.farming.ToolExerciseSwitch = tabs.farming:AddSwitch("Start exercising", function(enabled)
	tabs.farming.ExerciseData.AutoFarm = enabled
	tabs.farming.ExerciseData.Generation += 1
	if enabled then
		if tabs.farming.SquatExerciseSwitch and tabs.farming.MachineExerciseData.Squat.Running then tabs.farming.SquatExerciseSwitch:Set(false) end
		if tabs.farming.LiftExerciseSwitch and tabs.farming.MachineExerciseData.Lift.Running then tabs.farming.LiftExerciseSwitch:Set(false) end
		task.spawn(function(generation, character, humanoid, tool)
			while tabs.farming.ExerciseData.AutoFarm and tabs.farming.ExerciseData.Generation == generation do
				character = utils.playerData.Player.Character
				humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 and tabs.farming.ExerciseData.SelectedTool then
					tool = character:FindFirstChild(tabs.farming.ExerciseData.SelectedTool)
						or utils.playerData.Player.Backpack:FindFirstChild(tabs.farming.ExerciseData.SelectedTool)
					if tool and tool.Parent ~= character then
						humanoid:EquipTool(tool)
						task.wait(0.2)
					end
					if not tabs.farming.ExerciseData.AutoFarm or tabs.farming.ExerciseData.Generation ~= generation then return end
					if tool and tool.Parent == character and utils.playerData.Player.Character == character and humanoid.Health > 0 then
						pcall(function() utils.playerData.Player.muscleEvent:FireServer("rep") end)
						if tabs.farming.ExerciseData.SelectedTool == "Handstands" and tick() % 6 < 0.1 then
							pcall(function()
								services.VirtualUser:CaptureController()
								services.VirtualUser:ClickButton1(Vector2.new(500, 500))
							end)
						end
					end
				end
				task.wait(0.05)
			end
		end, tabs.farming.ExerciseData.Generation)
	elseif tabs.farming.ExerciseData.SelectedTool and utils.playerData.Player.Character then
		tabs.farming.runtime.equippedTool = utils.playerData.Player.Character:FindFirstChild(tabs.farming.ExerciseData.SelectedTool)
		if tabs.farming.runtime.equippedTool then tabs.farming.runtime.equippedTool.Parent = utils.playerData.Player.Backpack end
	end
end)

tabs.farming.addMachineDropdown = function(label, machineData, machineNames)
	tabs.farming.runtime.dropdown = tabs.farming:AddDropdown(label, function(selection)
		if machineData.ActiveMachine or machineData.SeatPart or machineData.EnteringMachine then
			tabs.farming.MachineCooldownUntil = math.max(tabs.farming.MachineCooldownUntil, os.clock() + 4)
			if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid") then
				utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid").Jump = true
			end
		end
		machineData.SelectedMachine = machineData.Choices[selection]
		machineData.ActiveMachine = nil
		machineData.SeatPart = nil
		machineData.ReenterAt = math.max(machineData.ReenterAt, tabs.farming.MachineCooldownUntil)
	end)

	for _, machineName in ipairs(machineNames) do
		tabs.farming.runtime.dropdown:Add(machineName)
	end
end

tabs.farming.startMachineExercise = function(machineData)
	machineData.Generation += 1
	task.spawn(function(generation, lastCharacter, character, humanoid, humanoidState, jumpedOff)
		lastCharacter = utils.playerData.Player.Character
		while machineData.Running and machineData.Generation == generation do
			character = utils.playerData.Player.Character
			humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character ~= lastCharacter then
				lastCharacter = character
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = math.max(machineData.ReenterAt, os.clock() + 4)
				tabs.farming.MachineCooldownUntil = math.max(tabs.farming.MachineCooldownUntil, machineData.ReenterAt)
			end
			if humanoid and humanoid.Health > 0 then
				humanoidState = humanoid:GetState()
				jumpedOff = machineData.ActiveMachine and (
					humanoidState == Enum.HumanoidStateType.Jumping
					or humanoidState == Enum.HumanoidStateType.Freefall
					or (machineData.SeatPart and humanoid.SeatPart ~= machineData.SeatPart)
				)
				if jumpedOff then
					machineData.ActiveMachine = nil
					machineData.SeatPart = nil
					machineData.ReenterAt = math.max(machineData.ReenterAt, os.clock() + 4)
					tabs.farming.MachineCooldownUntil = math.max(tabs.farming.MachineCooldownUntil, machineData.ReenterAt)
				end
				if machineData.SelectedMachine and not machineData.ActiveMachine
					and os.clock() >= math.max(machineData.ReenterAt, tabs.farming.MachineCooldownUntil) then
					if tabs.farming.enterExerciseMachine(machineData.SelectedMachine, machineData, generation) then
						machineData.ActiveMachine = machineData.SelectedMachine
						machineData.SeatPart = humanoid.SeatPart
					end
					if machineData.Generation == generation then machineData.EnteringMachine = nil end
				end
			elseif machineData.ActiveMachine then
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = math.max(machineData.ReenterAt, os.clock() + 4)
				tabs.farming.MachineCooldownUntil = math.max(tabs.farming.MachineCooldownUntil, machineData.ReenterAt)
			end
			task.wait(0.1)
		end
	end, machineData.Generation)
end

tabs.farming.setMachineExerciseState = function(machineData, otherMachineData, state)
	if not state and (machineData.ActiveMachine or machineData.SeatPart or machineData.EnteringMachine) then
		machineData.ReenterAt = math.max(machineData.ReenterAt, os.clock() + 4)
		tabs.farming.MachineCooldownUntil = math.max(tabs.farming.MachineCooldownUntil, machineData.ReenterAt)
	end
	machineData.Running = state
	machineData.EnteringMachine = nil
	machineData.Generation += 1
	machineData.ActiveMachine = nil
	machineData.SeatPart = nil
	machineData.ReenterAt = math.max(machineData.ReenterAt, tabs.farming.MachineCooldownUntil)

	if not state then return end
	if tabs.farming.ToolExerciseSwitch and tabs.farming.ExerciseData.AutoFarm then tabs.farming.ToolExerciseSwitch:Set(false) end
	if otherMachineData.Running then
		if machineData == tabs.farming.MachineExerciseData.Squat and tabs.farming.LiftExerciseSwitch then
			tabs.farming.LiftExerciseSwitch:Set(false)
		elseif machineData == tabs.farming.MachineExerciseData.Lift and tabs.farming.SquatExerciseSwitch then
			tabs.farming.SquatExerciseSwitch:Set(false)
		end
	end
	tabs.farming.startMachineExercise(machineData)
	task.spawn(function(generation)
		while machineData.Running and machineData.Generation == generation do
			if machineData.ActiveMachine then utils.playerData.Player.muscleEvent:FireServer("rep") end
			task.wait(0.1)
		end
	end, machineData.Generation)
end

tabs.farming.addMachineDropdown("Select Squat", tabs.farming.MachineExerciseData.Squat, tabs.farming.SquatMachineNames)
tabs.farming.SquatExerciseSwitch = tabs.farming:AddSwitch("Auto Squat", function(state)
	tabs.farming.setMachineExerciseState(tabs.farming.MachineExerciseData.Squat, tabs.farming.MachineExerciseData.Lift, state)
end)

tabs.farming.addMachineDropdown("Select Lift", tabs.farming.MachineExerciseData.Lift, tabs.farming.LiftMachineNames)
tabs.farming.LiftExerciseSwitch = tabs.farming:AddSwitch("Auto Lift", function(state)
	tabs.farming.setMachineExerciseState(tabs.farming.MachineExerciseData.Lift, tabs.farming.MachineExerciseData.Squat, state)
end)

tabs.farming.AutoRepRunning = false
tabs.farming.AutoRepSwitch = tabs.farming:AddSwitch("Auto Rep", function(state)
	tabs.farming.AutoRepRunning = state
	if not state then return end
	task.spawn(function()
		while tabs.farming.AutoRepRunning do
			utils.playerData.Player.muscleEvent:FireServer("rep")
			task.wait(0.1)
		end
	end)
end)

tabs.farming:AddLabel("Auto Rock:")

tabs.farming.RockData = {
	Data = {["Tiny Rock - 0 Dura"] = 0, ["Large Rock - 100 Dura"] = 100, ["Punching Rock - 10 Dura"] = 10,
		["Golden Rock - 5k Dura"] = 5000, ["Frost Rock - 150k Dura"] = 150000, ["Mythical Rock - 400k Dura"] = 400000,
		["Eternal Rock - 750k Dura"] = 750000, ["Legend Rock - 1m Dura"] = 1000000, ["Muscle King Rock - 5m Dura"] = 5000000,
		["Jungle Rock - 10m Dura"] = 10000000, ["Industrial Rock - 25m Dura"] = 25000000,},
	SelectedRock = nil
}

tabs.farming.RockDropdown = tabs.farming:AddDropdown("Select Rock", function(selection) tabs.farming.RockData.SelectedRock = selection end)
for rockName in pairs(tabs.farming.RockData.Data) do tabs.farming.RockDropdown:Add(rockName) end

tabs.farming.RockSwitch = tabs.farming:AddSwitch("Auto Rock", function(enabled)
	tabs.farming.RockFarmRunning = enabled
	if enabled and tabs.farming.RockData.SelectedRock then
		task.spawn(function()
			while tabs.farming.RockFarmRunning do
				task.wait(0.12)
				if tabs.farming.RockFarmRunning and utils.playerData.Player.Character
					and utils.playerData.Player.Character:FindFirstChild("LeftHand")
					and utils.playerData.Player.Character:FindFirstChild("RightHand")
					and utils.playerData.Player.Durability.Value >= tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] then
					for _, v in pairs(tabs.farming.MachinesFolder:GetDescendants()) do
						if v.Name == "neededDurability" and v.Value == tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] and
						   utils.playerData.Player.Character:FindFirstChild("LeftHand") and v.Parent:FindFirstChild("Rock") then
							utils.touchParts(v.Parent.Rock, utils.playerData.Player.Character.RightHand, 0)
							utils.touchParts(v.Parent.Rock, utils.playerData.Player.Character.RightHand, 1)
							utils.touchParts(v.Parent.Rock, utils.playerData.Player.Character.LeftHand, 0)
							utils.touchParts(v.Parent.Rock, utils.playerData.Player.Character.LeftHand, 1)
							tabs.killing.getTool()
						end
					end
				end
			end
		end)
	end
end)

tabs.farming:AddLabel("Better Strength Farming:")

tabs.farming.Configs = {
	{name = "Pushup + Industrial Rock", tool = "Pushups", rock = "Industrial Rock"},
	{name = "Pushup + Jungle Rock", tool = "Pushups", rock = "Ancient Jungle Rock"},
	{name = "Pushup + Muscle King Rock", tool = "Pushups", rock = "Muscle King Mountain"},
	{name = "Pushup + Legends Rock", tool = "Pushups", rock = "Rock Of Legends"}
}
tabs.farming.ActiveConfigs = {}

for _, config in ipairs(tabs.farming.Configs) do
	tabs.farming.ActiveConfigs[config.name] = false
	config.Switch = tabs.farming:AddSwitch(config.name, function(state)
		tabs.farming.ActiveConfigs[config.name] = state
		if tabs.farming.ActiveConfigs[config.name] then
			if utils.playerData.Player.Backpack:FindFirstChild(config.tool) and not utils.playerData.Player.Character:FindFirstChild(config.tool) then
				utils.playerData.Player.Character.Humanoid:EquipTool(utils.playerData.Player.Backpack[config.tool])
			end
			task.spawn(function()
				while tabs.farming.ActiveConfigs[config.name] do
					utils.playerData.Player.muscleEvent:FireServer("rep")
					if tabs.farming.MachinesFolder:FindFirstChild(config.rock) and utils.playerData.Player.Character:FindFirstChild("LeftHand") then
						utils.touchParts(tabs.farming.MachinesFolder[config.rock].Rock, utils.playerData.Player.Character.LeftHand, 0)
						utils.touchParts(tabs.farming.MachinesFolder[config.rock].Rock, utils.playerData.Player.Character.LeftHand, 1)
					end
					if utils.playerData.Player.Backpack:FindFirstChild("Punch") then
						utils.playerData.Humanoid:EquipTool(utils.playerData.Player.Backpack.Punch)
						utils.playerData.Player.muscleEvent:FireServer("punch", "rightHand")
						utils.playerData.Player.muscleEvent:FireServer("punch", "leftHand")
					end
					services.RunService.RenderStepped:Wait()
					if utils.playerData.Player.Backpack:FindFirstChild(config.tool) then
						utils.playerData.Player.Character.Humanoid:EquipTool(utils.playerData.Player.Backpack[config.tool])
					end
				end
			end)
		else
			if utils.playerData.Player.Character:FindFirstChild(config.tool) then
				utils.playerData.Player.Character[config.tool].Parent = utils.playerData.Player.Backpack
			end
		end
	end)
end

tabs.boss:AddLabel("Boss Farming:")
tabs.boss.StatusLabel = tabs.boss:AddLabel("Status: Waiting for Boss")
tabs.boss.BossLabel = tabs.boss:AddLabel("Boss: None")
tabs.boss.HealthLabel = tabs.boss:AddLabel("Health: 0 / 0")
tabs.boss.NextBossLabel = tabs.boss:AddLabel("Next Boss: N/A")

tabs.boss.Data = {
	Running = false,
	Generation = 0,
	ContinueTraining = true,
	Phase = "Waiting",
	TrainingSnapshot = nil,
	TrainingRestore = nil,
	TrainingResumeGeneration = 0,
	PreparationSeconds = 4,
	PunchInterval = 0.3,
	LastPunch = 0,
	AttackSequence = nil,
	EvadeUntil = 0,
	EvadeDistance = 230,
	PunchBehindDistance = 45,
	StompHealthThreshold = 0.35,
	DodgeStomps = false,
	BossConfig = nil,
	Bosses = {},
	BossOrder = {},
	BossByDisplayName = {},
	SelectedBosses = {}
}

tabs.boss:AddTextBox("Seconds Training before Boss (when Rebirthing):", function(text)
	if tonumber(text) and tonumber(text) >= 0 then tabs.boss.Data.PreparationSeconds = tonumber(text) end
end, {clear = false})

tabs.boss.SelectedBossesLabel = tabs.boss:AddLabel("Targeted Bosses: Detecting...")
tabs.boss.BossDropdown = tabs.boss:AddDropdown("Target specific Bosses", function(displayName)
	tabs.boss.runtime.bossModelName = tabs.boss.Data.BossByDisplayName[displayName]
	if tabs.boss.runtime.bossModelName then
		tabs.boss.Data.SelectedBosses[tabs.boss.runtime.bossModelName] = not tabs.boss.Data.SelectedBosses[tabs.boss.runtime.bossModelName]
		tabs.boss.updateSelectedBossesLabel()
	end
end)

tabs.boss.updateSelectedBossesLabel = function(selectedNames)
	selectedNames = {}
	for _, modelName in ipairs(tabs.boss.Data.BossOrder) do
		if tabs.boss.Data.SelectedBosses[modelName] then
			table.insert(selectedNames, (string.gsub(tabs.boss.Data.Bosses[modelName], "%s+[Bb][Oo][Ss][Ss]$", "")))
		end
	end
	tabs.boss.SelectedBossesLabel.Text = "Targeted Bosses: " .. (#selectedNames > 0 and table.concat(selectedNames, ", ") or "None")
end

tabs.boss.addBossChoice = function(modelName, displayName)
	modelName = tostring(modelName or "")
	displayName = tostring(displayName or modelName)
	if modelName == "" or tabs.boss.Data.Bosses[modelName] then return end
	tabs.boss.Data.Bosses[modelName] = displayName
	tabs.boss.Data.BossByDisplayName[displayName] = modelName
	tabs.boss.Data.SelectedBosses[modelName] = true
	table.insert(tabs.boss.Data.BossOrder, modelName)
	tabs.boss.BossDropdown:Add(displayName)
	tabs.boss.updateSelectedBossesLabel()
end

tabs.boss.runtime.configSuccess, tabs.boss.Data.BossConfig = pcall(function()
	return require(services.ReplicatedStorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("BossEventConfig"))
end)
if tabs.boss.runtime.configSuccess and tabs.boss.Data.BossConfig and tabs.boss.Data.BossConfig.RARITIES then
	for _, rarity in ipairs(tabs.boss.Data.BossConfig.RARITIES) do
		tabs.boss.addBossChoice(rarity.BossModel, rarity.DisplayName or rarity.Name or rarity.BossModel)
	end
else
	tabs.boss.SelectedBossesLabel.Text = "Farmed Bosses: Waiting for detection"
end

tabs.boss.shouldFarmBoss = function(model)
	if not tabs.boss.Data.Bosses[model.Name] then
		tabs.boss.addBossChoice(model.Name, services.Workspace:GetAttribute("BossDisplayName") or model.Name)
	end
	return tabs.boss.Data.SelectedBosses[model.Name] == true
end

tabs.boss.findActiveBoss = function(model, stats, health, maxHealth, hitbox)
	for _, candidate in ipairs(services.CollectionService:GetTagged("BossEventBoss")) do
		if candidate:IsA("Model") and candidate:IsDescendantOf(services.Workspace) then
			model = candidate
			break
		end
	end

	if not model then
		tabs.boss.runtime.events = services.Workspace:FindFirstChild("Events")
		tabs.boss.runtime.bossFolder = tabs.boss.runtime.events and (tabs.boss.runtime.events:FindFirstChild("BossEvent") or tabs.boss.runtime.events:FindFirstChild("BossArena"))
		if tabs.boss.runtime.bossFolder then
			for _, candidate in ipairs(tabs.boss.runtime.bossFolder:GetDescendants()) do
				if candidate:IsA("Model") and (candidate:FindFirstChild("BossDamageHitbox") or candidate:HasTag("BossEventBoss")) then
					model = candidate
					break
				end
			end
		end
	end

	if not model then return end
	stats = model:FindFirstChild("stats")
	health = stats and stats:FindFirstChild("Health")
	maxHealth = stats and stats:FindFirstChild("MaxHealth")
	hitbox = model:FindFirstChild("BossDamageHitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then return end
	tabs.boss.runtime.currentHealth = health and health.Value or services.Workspace:GetAttribute("BossHealth")
	if typeof(tabs.boss.runtime.currentHealth) == "number" and tabs.boss.runtime.currentHealth <= 0 then return end
	return model, health, maxHealth, hitbox
end

tabs.boss.getBossDisplayName = function(model)
	return services.Workspace:GetAttribute("BossDisplayName") or model.Name
end

tabs.boss.getBossHealth = function(health)
	return health and health.Value or services.Workspace:GetAttribute("BossHealth") or 0
end

tabs.boss.getBossMaxHealth = function(maxHealth)
	return maxHealth and maxHealth.Value or services.Workspace:GetAttribute("BossMaxHealth") or 0
end

tabs.boss.formatCountdown = function(seconds, hours, minutes)
	seconds = math.max(0, math.floor(seconds or 0))
	hours = math.floor(seconds / 3600)
	minutes = math.floor(seconds % 3600 / 60)
	seconds = seconds % 60
	return string.format("%dh %dmin %ds", hours, minutes, seconds)
end

tabs.boss.leaveExerciseMachine = function(character, humanoid, root)
	character = utils.playerData.Player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 then return end

	pcall(function()
		services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		humanoid.Sit = false
		humanoid.Jump = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		if root then root.AssemblyLinearVelocity = Vector3.new(0, math.max(root.AssemblyLinearVelocity.Y, 50), 0) end
	end)
	pcall(function() services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
	tabs.farming.MachineCooldownUntil = math.max(tabs.farming.MachineCooldownUntil, os.clock() + 4)
	for _, machineData in pairs(tabs.farming.MachineExerciseData) do
		machineData.ReenterAt = math.max(machineData.ReenterAt, tabs.farming.MachineCooldownUntil)
	end
	task.wait(0.2)
end

tabs.boss.captureTraining = function()
	tabs.boss.Data.TrainingResumeGeneration += 1
	if tabs.boss.Data.TrainingSnapshot then return end
	if tabs.boss.Data.TrainingRestore then
		tabs.boss.Data.TrainingSnapshot = tabs.boss.Data.TrainingRestore
		tabs.boss.Data.TrainingRestore = nil
		return
	end
	tabs.boss.Data.TrainingSnapshot = {
		Rebirth = tabs.farming.RebirthData.IsAutoRebirthing,
		Size = tabs.farming.SizeData.Active,
		King = tabs.farming.KingData.TeleportActive,
		Tool = tabs.farming.ExerciseData.AutoFarm,
		SelectedTool = tabs.farming.ExerciseData.SelectedTool,
		Squat = tabs.farming.MachineExerciseData.Squat.Running,
		Lift = tabs.farming.MachineExerciseData.Lift.Running,
		SquatMachine = tabs.farming.MachineExerciseData.Squat.ActiveMachine or tabs.farming.MachineExerciseData.Squat.SelectedMachine,
		LiftMachine = tabs.farming.MachineExerciseData.Lift.ActiveMachine or tabs.farming.MachineExerciseData.Lift.SelectedMachine,
		AutoRep = tabs.farming.AutoRepRunning,
		Rock = tabs.farming.RockFarmRunning == true,
		Configs = {}
	}
	for _, config in ipairs(tabs.farming.Configs) do
		tabs.boss.Data.TrainingSnapshot.Configs[config.name] = tabs.farming.ActiveConfigs[config.name] == true
	end
end

tabs.boss.startSavedExercise = function(snapshot, preparing)
	if snapshot.Squat then
		tabs.farming.MachineExerciseData.Squat.SelectedMachine = snapshot.SquatMachine
		if not tabs.farming.MachineExerciseData.Squat.Running then tabs.farming.SquatExerciseSwitch:Set(true) end
	elseif snapshot.Lift then
		tabs.farming.MachineExerciseData.Lift.SelectedMachine = snapshot.LiftMachine
		if not tabs.farming.MachineExerciseData.Lift.Running then tabs.farming.LiftExerciseSwitch:Set(true) end
	elseif snapshot.Tool or preparing then
		tabs.farming.ExerciseData.SelectedTool = snapshot.Tool and snapshot.SelectedTool or "Pushups"
		if not tabs.farming.ExerciseData.AutoFarm then tabs.farming.ToolExerciseSwitch:Set(true) end
	end
end

tabs.boss.isTrainingReady = function(snapshot, preparing, character, humanoid, machine)
	character = utils.playerData.Player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or not character:FindFirstChild("HumanoidRootPart") then return false end
	if snapshot.Squat or snapshot.Lift then
		machine = snapshot.Squat and tabs.farming.MachineExerciseData.Squat or tabs.farming.MachineExerciseData.Lift
		return machine.Running and machine.ActiveMachine ~= nil and machine.ActiveMachine == machine.SelectedMachine
			and (not machine.SeatPart or humanoid.SeatPart == machine.SeatPart)
	end
	if snapshot.Tool or preparing then
		return tabs.farming.ExerciseData.AutoFarm
			and character:FindFirstChild(snapshot.Tool and snapshot.SelectedTool or "Pushups") ~= nil
	end
	return true
end

tabs.boss.pauseTraining = function(onMachine)
	tabs.boss.captureTraining()
	onMachine = tabs.farming.MachineExerciseData.Squat.ActiveMachine or tabs.farming.MachineExerciseData.Squat.EnteringMachine
		or tabs.farming.MachineExerciseData.Lift.ActiveMachine or tabs.farming.MachineExerciseData.Lift.EnteringMachine
	if tabs.farming.RebirthData.IsAutoRebirthing then tabs.farming.RebirthData.Switch:Set(false) end
	if tabs.farming.SizeData.Active then tabs.farming.SizeSwitch:Set(false) end
	if tabs.farming.KingData.TeleportActive then tabs.farming.KingSwitch:Set(false) end
	if tabs.farming.ExerciseData.AutoFarm then tabs.farming.ToolExerciseSwitch:Set(false) end
	if tabs.farming.MachineExerciseData.Squat.Running then tabs.farming.SquatExerciseSwitch:Set(false) end
	if tabs.farming.MachineExerciseData.Lift.Running then tabs.farming.LiftExerciseSwitch:Set(false) end
	if tabs.farming.AutoRepRunning then tabs.farming.AutoRepSwitch:Set(false) end
	if tabs.farming.RockFarmRunning then tabs.farming.RockSwitch:Set(false) end
	for _, config in ipairs(tabs.farming.Configs) do
		if tabs.farming.ActiveConfigs[config.name] and config.Switch then config.Switch:Set(false) end
	end
	if onMachine then tabs.boss.leaveExerciseMachine() end
end

tabs.boss.hasTrainingStats = function(strength, durability)
	strength = utils.playerData.Player.leaderstats:FindFirstChild("Strength")
	durability = utils.playerData.Player:FindFirstChild("Durability")
	return strength and durability and strength.Value > 0 and durability.Value > 0
end

tabs.boss.prepareForBoss = function(boss, preparation, character, humanoid, tool, backpack, toolName, strength)
	if not boss.Data.Preparation then
		tabs.boss.pauseTraining()
		boss.Data.Preparation = {LastRep = 0}
		boss.Data.Phase = "Training"
	end
	preparation = boss.Data.Preparation
	character = utils.playerData.Player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if preparation.Character ~= character or preparation.Rebirths ~= tabs.farming.RebirthData.Rebirths.Value then
		preparation.Character = character
		preparation.Rebirths = tabs.farming.RebirthData.Rebirths.Value
		preparation.StartedAt = nil
		preparation.PetsReady = nil
		preparation.LastRep = 0
		preparation.Required = not tabs.boss.hasTrainingStats()
	end
	if not humanoid or humanoid.Health <= 0 then
		preparation.StartedAt = nil
		boss.StatusLabel.Text = "Status: Waiting for Respawn"
		return false
	end
	if not preparation.Required then
		boss.Data.FightCharacter = character
		boss.Data.FightRebirths = tabs.farming.RebirthData.Rebirths.Value
		boss.Data.Preparation = nil
		return true
	end
	if utils.playerData.Player.Character ~= character or humanoid.Health <= 0 then return false end
	backpack = utils.playerData.Player:FindFirstChild("Backpack")
	strength = utils.playerData.Player.leaderstats:FindFirstChild("Strength")
	if not strength then return false end
	toolName = strength.Value < 2000 and "Weight" or "Pushups"
	if toolName == "Weight" then preparation.StartedAt = nil end
	tool = character:FindFirstChild(toolName) or backpack and backpack:FindFirstChild(toolName)
	if not tool then
		preparation.StartedAt = nil
		boss.StatusLabel.Text = "Status: Waiting for " .. toolName
		return false
	end
	if tool.Parent ~= character then humanoid:EquipTool(tool) end
	if tool.Parent ~= character then preparation.StartedAt = nil return false end
	if toolName == "Pushups" then preparation.StartedAt = preparation.StartedAt or os.clock() end
	if os.clock() - preparation.LastRep >= 0.1 then
		utils.playerData.Player.muscleEvent:FireServer("rep")
		preparation.LastRep = os.clock()
	end
	if toolName == "Weight" then
		boss.StatusLabel.Text = "Status: Weight Training | " .. utils.formatNumber(strength.Value) .. " / 2K Strength"
		return false
	end
	boss.StatusLabel.Text = "Status: Training before Boss (" .. string.format("%.1f", math.max(0, tabs.boss.Data.PreparationSeconds - (os.clock() - preparation.StartedAt))) .. "s)"
	if os.clock() - preparation.StartedAt < tabs.boss.Data.PreparationSeconds then return false end
	boss.Data.FightCharacter = character
	boss.Data.FightRebirths = tabs.farming.RebirthData.Rebirths.Value
	boss.Data.Preparation = nil
	return true
end

tabs.boss.needsRetraining = function(boss, character, humanoid)
	character = utils.playerData.Player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return not humanoid or humanoid.Health <= 0 or boss.Data.FightCharacter ~= utils.playerData.Player.Character
		or boss.Data.FightRebirths ~= tabs.farming.RebirthData.Rebirths.Value
end

tabs.boss.resumeTraining = function(snapshot)
	snapshot = tabs.boss.Data.TrainingSnapshot
	if not snapshot then return end
	tabs.boss.Data.TrainingSnapshot = nil
	tabs.boss.Data.TrainingRestore = snapshot
	tabs.boss.Data.TrainingResumeGeneration += 1
	if not snapshot.Tool and tabs.farming.ExerciseData.AutoFarm then tabs.farming.ToolExerciseSwitch:Set(false) end
	tabs.farming.ExerciseData.SelectedTool = snapshot.SelectedTool
	tabs.boss.startSavedExercise(snapshot, false)
	if snapshot.Size then tabs.farming.SizeSwitch:Set(true) end
	if snapshot.King then tabs.farming.KingSwitch:Set(true) end
	if snapshot.AutoRep then tabs.farming.AutoRepSwitch:Set(true) end
	if snapshot.Rock then tabs.farming.RockSwitch:Set(true) end
	for _, config in ipairs(tabs.farming.Configs) do
		if snapshot.Configs[config.name] and config.Switch then config.Switch:Set(true) end
	end
	task.spawn(function(generation)
		while tabs.boss.Data.TrainingResumeGeneration == generation do
			if tabs.boss.isTrainingReady(snapshot, false) then
				tabs.boss.Data.TrainingRestore = nil
				if snapshot.Rebirth then tabs.farming.RebirthData.Switch:Set(true) end
				return
			end
			task.wait(0.1)
		end
	end, tabs.boss.Data.TrainingResumeGeneration)
end

tabs.boss.getBossHeadPosition = function(model, hitbox, head)
	head = model:FindFirstChild("Head", true) or model:FindFirstChild("head", true)
	if head and head:IsA("BasePart") then return head.Position end
	if head and head:IsA("Bone") then return head.WorldPosition end
	return hitbox.Position + Vector3.new(0, hitbox.Size.Y * 0.35, 0)
end

tabs.boss.getAliveCharacter = function(generation, timeout, startedAt, character, root, humanoid)
	if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
	startedAt = os.clock()
	repeat
		character = utils.playerData.Player.Character
		root = character and character:FindFirstChild("HumanoidRootPart")
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			utils.playerData.Character = character
			utils.playerData.Humanoid = humanoid
			return character, root, humanoid
		end
		tabs.boss.StatusLabel.Text = "Status: Waiting for Respawn"
		task.wait(0.1)
	until not tabs.boss.Data.Running
		or tabs.boss.Data.Generation ~= generation
		or (timeout and os.clock() - startedAt >= timeout)
end

tabs.boss.evadeAttack = function(boss, model, hitbox, root, humanoid, sequence, attackKind, attackCFrame, impactTime, direction, safePosition, center)
	sequence = model:GetAttribute("BossAttackSequence")
	attackKind = model:GetAttribute("BossAttackKind")
	attackCFrame = model:GetAttribute("BossAttackCFrame")
	impactTime = model:GetAttribute("BossAttackImpactTime")

	if typeof(sequence) == "number" and sequence ~= boss.Data.AttackSequence then
		boss.Data.AttackSequence = sequence
		if typeof(attackKind) == "string" and typeof(attackCFrame) == "CFrame" and typeof(impactTime) == "number" then
			boss.Data.EvadeUntil = impactTime + 0.6
		end
	end

	if typeof(attackCFrame) ~= "CFrame" or services.Workspace:GetServerTimeNow() > boss.Data.EvadeUntil then
		return
	end

	attackKind = string.lower(tostring(attackKind or ""))
	if string.find(attackKind, "punch", 1, true) then
		center = tabs.boss.getBossHeadPosition(model, hitbox)
		direction = Vector3.new(attackCFrame.LookVector.X, 0, attackCFrame.LookVector.Z)
		if direction.Magnitude < 1 then direction = Vector3.new(hitbox.CFrame.LookVector.X, 0, hitbox.CFrame.LookVector.Z) end
		if direction.Magnitude < 1 then direction = Vector3.new(0, 0, 1) end
		safePosition = center - direction.Unit * boss.Data.PunchBehindDistance
		root.CFrame = CFrame.lookAt(safePosition, center)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		boss.StatusLabel.Text = "Status: Dodging Punch"
		return "Punch"
	end

	if not string.find(attackKind, "stomp", 1, true) then return end
	if humanoid.Health / math.max(humanoid.MaxHealth, 1) <= boss.Data.StompHealthThreshold then
		boss.Data.DodgeStomps = true
	end
	if not boss.Data.DodgeStomps then return end

	direction = Vector3.new(root.Position.X - attackCFrame.Position.X, 0, root.Position.Z - attackCFrame.Position.Z)
	if direction.Magnitude < 1 then
		direction = Vector3.new(-attackCFrame.LookVector.X, 0, -attackCFrame.LookVector.Z)
	end
	if direction.Magnitude < 1 then direction = Vector3.new(1, 0, 0) end
	direction = direction.Unit
	safePosition = attackCFrame.Position + direction * boss.Data.EvadeDistance + Vector3.new(0, 18, 0)
	root.CFrame = CFrame.lookAt(safePosition, attackCFrame.Position)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	boss.StatusLabel.Text = "Status: Dodging Stomp"
	return "Stomp"
end

tabs.boss.attack = function(boss, model, health, maxHealth, hitbox, character, root, humanoid, punch, leftHand, rightHand, center, position, evadeMode)
	character = utils.playerData.Player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return end
	evadeMode = tabs.boss.evadeAttack(boss, model, hitbox, root, humanoid)
	if evadeMode == "Stomp" then return end
	punch = character:FindFirstChild("Punch") or utils.playerData.Backpack:FindFirstChild("Punch")
	if punch and punch.Parent ~= character then humanoid:EquipTool(punch) end
	leftHand = character:FindFirstChild("LeftHand")
	rightHand = character:FindFirstChild("RightHand")
	center = tabs.boss.getBossHeadPosition(model, hitbox)
	if evadeMode ~= "Punch" then
		position = center
		root.CFrame = CFrame.lookAt(position, position + hitbox.CFrame.LookVector)
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	pcall(function()
		if leftHand then
			utils.touchParts(hitbox, leftHand, 0)
			utils.touchParts(hitbox, leftHand, 1)
		end
		if rightHand then
			utils.touchParts(hitbox, rightHand, 0)
			utils.touchParts(hitbox, rightHand, 1)
		end
	end)

	if os.clock() - boss.Data.LastPunch >= boss.Data.PunchInterval then
		boss.Data.LastPunch = os.clock()
		pcall(function()
			utils.remotes.MuscleEvent:FireServer("punch", "leftHand")
			utils.remotes.MuscleEvent:FireServer("punch", "rightHand")
			if punch then punch:Activate() end
		end)
	end

	boss.BossLabel.Text = (boss.BossLabelPrefix or "Boss: ") .. boss.getBossDisplayName(model)
	boss.runtime.health = boss.getBossHealth(health, model)
	boss.runtime.maxHealth = boss.getBossMaxHealth(maxHealth, model)
	boss.HealthLabel.Text = "Health: " .. utils.formatNumber(boss.runtime.health) .. " / " .. utils.formatNumber(boss.runtime.maxHealth)
end

tabs.boss.findChest = function(chest, prompt, part)
	for _, candidate in ipairs(services.CollectionService:GetTagged("BossEventChest")) do
		if candidate:IsDescendantOf(services.Workspace) then chest = candidate break end
	end
	if not chest then chest = services.Workspace:FindFirstChild("BossChest", true) end
	if not chest then
		for _, candidate in ipairs(services.Workspace:GetDescendants()) do
			if candidate:IsA("ProximityPrompt") and candidate.Name == "bossChestPrompt" then
				chest = candidate.Parent
				break
			end
		end
	end
	if not chest then return end
	prompt = chest:FindFirstChild("bossChestPrompt", true)
	part = prompt and prompt.Parent or (chest:IsA("Model") and (chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart", true))) or chest
	if part and part:IsA("BasePart") then return chest, prompt, part end
end

tabs.boss.collectChest = function(generation, startedAt, chest, prompt, part, character, root)
	tabs.boss.StatusLabel.Text = "Status: Waiting for Chest"
	startedAt = os.clock()
	repeat
		chest, prompt, part = tabs.boss.findChest()
		if chest and chest:GetAttribute("BossChestEmerging") ~= true then break end
		task.wait(0.1)
	until not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation or os.clock() - startedAt >= 12
	if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation or not chest or not part then return end

	tabs.boss.StatusLabel.Text = "Status: Collecting Chest"
	startedAt = os.clock()
	repeat
		character, root = tabs.boss.getAliveCharacter(generation, 2)
		if character and root and chest.Parent and part.Parent then
			tabs.boss.StatusLabel.Text = "Status: Collecting Chest"
			pcall(function()
				root.CFrame = CFrame.lookAt(part.Position + Vector3.new(0, 3, 4), part.Position)
				root.AssemblyLinearVelocity = Vector3.zero
			end)
			task.wait(0.15)
			if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
			if not (prompt and prompt.Parent and type(fireproximityprompt) == "function"
				and pcall(fireproximityprompt, prompt)) then
				pcall(function()
					services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(0.1)
					services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end)
			end
		end
		task.wait(0.25)
	until not tabs.boss.Data.Running
		or tabs.boss.Data.Generation ~= generation
		or utils.playerData.Player:GetAttribute("BossChestPending") == false
		or not chest.Parent
		or os.clock() - startedAt >= 12
end

tabs.boss.ContinueSwitch = tabs.boss:AddSwitch("Continue Farming after Boss Kill", function(state)
	tabs.boss.Data.ContinueTraining = state
	if state and tabs.boss.Data.Phase == "Waiting"
		and (not tabs.boss.Halloween or not tabs.boss.Halloween.Data.Running) then tabs.boss.resumeTraining() end
end)
tabs.boss.ContinueSwitch:Set(true)

task.spawn(function(model, health, maxHealth, hitbox, currentHealth, currentMaxHealth, nextTime)
	while true do
		model, health, maxHealth, hitbox = tabs.boss.findActiveBoss()
		if model then
			currentHealth = tabs.boss.getBossHealth(health)
			currentMaxHealth = tabs.boss.getBossMaxHealth(maxHealth)
			tabs.boss.BossLabel.Text = "Boss: " .. (services.Workspace:GetAttribute("BossDisplayName") or model.Name)
			tabs.boss.HealthLabel.Text = "Health: " .. utils.formatNumber(currentHealth) .. " / " .. utils.formatNumber(currentMaxHealth)
			tabs.boss.NextBossLabel.Text = "Next Boss: Current boss active"
		else
			tabs.boss.BossLabel.Text = "Boss: None"
			tabs.boss.HealthLabel.Text = "Health: 0 / 0"
			nextTime = services.Workspace:GetAttribute("BossSpawnNextTime")
			tabs.boss.NextBossLabel.Text = typeof(nextTime) == "number"
				and "Next Boss: " .. tabs.boss.formatCountdown(nextTime - services.Workspace:GetServerTimeNow())
				or "Next Boss: N/A"
		end
		task.wait(0.25)
	end
end)

tabs.boss.AutoFarmSwitch = tabs.boss:AddSwitch("Auto Farm Boss", function(state)
	if state and tabs.boss.Halloween and tabs.boss.Halloween.Data.Running then
		tabs.boss.Halloween.AutoFarmSwitch:Set(false)
	end
	tabs.boss.Data.Running = state
	tabs.boss.Data.Generation += 1
	tabs.boss.runtime.generation = tabs.boss.Data.Generation
	if not state then
		tabs.boss.Data.Preparation = nil
		tabs.boss.Data.Phase = "Waiting"
		tabs.boss.StatusLabel.Text = "Status: Disabled"
		tabs.boss.resumeTraining()
		return
	end

	task.spawn(function(generation, wasFighting, model, health, maxHealth, hitbox, selected)
		while tabs.boss.Data.Running and tabs.boss.Data.Generation == generation do
			pcall(function()
				model, health, maxHealth, hitbox = tabs.boss.findActiveBoss()
				selected = model and tabs.boss.shouldFarmBoss(model)
				if model and not selected then
					if wasFighting or tabs.boss.Data.Preparation then
						tabs.boss.Data.Preparation = nil
						wasFighting = false
						tabs.boss.resumeTraining()
					end
					tabs.boss.Data.Phase = "Waiting"
					tabs.boss.StatusLabel.Text = "Status: Skipping " .. (services.Workspace:GetAttribute("BossDisplayName") or model.Name)
				elseif model then
					if wasFighting and tabs.boss.needsRetraining(tabs.boss) then wasFighting = false end
					if not wasFighting then
						if not tabs.boss.prepareForBoss(tabs.boss) then return end
						wasFighting = true
						tabs.boss.Data.Phase = "Fighting"
						tabs.boss.Data.AttackSequence = nil
						tabs.boss.Data.EvadeUntil = 0
						tabs.boss.Data.DodgeStomps = false
						tabs.boss.pauseTraining()
					end
					if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
					if tabs.boss.needsRetraining(tabs.boss) then return end
					if utils.playerData.Player.Character
						and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid")
						and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
						tabs.boss.StatusLabel.Text = "Status: Fighting"
						tabs.boss.attack(tabs.boss, model, health, maxHealth, hitbox)
					else
						tabs.boss.StatusLabel.Text = "Status: Waiting for Respawn"
					end
				elseif wasFighting then
					wasFighting = false
					tabs.boss.Data.Phase = "Collecting"
					pcall(tabs.boss.collectChest, generation)
					if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
					tabs.boss.BossLabel.Text = "Boss: None"
					tabs.boss.HealthLabel.Text = "Health: 0 / 0"
					if tabs.boss.Data.ContinueTraining then tabs.boss.resumeTraining() end
					tabs.boss.Data.Phase = "Waiting"
					tabs.boss.StatusLabel.Text = "Status: Waiting for Boss"
				else
					if tabs.boss.Data.Preparation then
						tabs.boss.Data.Preparation = nil
						tabs.boss.resumeTraining()
					end
					tabs.boss.StatusLabel.Text = "Status: Waiting for Boss"
				end
			end)
			task.wait(model and selected and 0.03 or 0.25)
		end
	end, tabs.boss.runtime.generation)
end)

tabs.boss:AddLabel("")

tabs.boss:AddLabel("Halloween Boss Farming:")
tabs.boss.Halloween = {
	runtime = {},
	BossLabelPrefix = "Halloween Boss: ",
	StatusLabel = tabs.boss:AddLabel("Status: Waiting for Halloween Boss"),
	BossLabel = tabs.boss:AddLabel("Halloween Boss: None"),
	HealthLabel = tabs.boss:AddLabel("Health: 0 / 0"),
	NextBossLabel = tabs.boss:AddLabel("Next Halloween Boss: Waiting for spawn"),
	Data = {
		Running = false,
		Generation = 0,
		Phase = "Waiting",
		PunchInterval = 0.3,
		LastPunch = 0,
		AttackSequence = nil,
		EvadeUntil = 0,
		EvadeDistance = 230,
		PunchBehindDistance = 45,
		StompHealthThreshold = 0.35,
		DodgeStomps = false,
		Bosses = {
			GrimReaper = "Grim Reaper",
			FrankenBrute = "Frankenbrute",
			PumpkinTitan = "Pumpkin Titan",
			ScarecrowColossus = "Scarecrow Colossus"
		},
		BossOrder = {"GrimReaper", "FrankenBrute", "PumpkinTitan", "ScarecrowColossus"},
		BossByDisplayName = {},
		SelectedBosses = {},
		Target = nil
	}
}

tabs.boss.Halloween.getBossDisplayName = function(model)
	return tabs.boss.Halloween.Data.Bosses[model:GetAttribute("BossId") or model.Name] or model.Name
end

tabs.boss.Halloween.getBossHealth = function(health, model)
	return tonumber(model:GetAttribute("Health")) or 0
end

tabs.boss.Halloween.getBossMaxHealth = function(maxHealth, model)
	return tonumber(model:GetAttribute("MaxHealth")) or 0
end

tabs.boss.Halloween.SelectedBossesLabel = tabs.boss:AddLabel("Targeted Halloween Bosses: All")
tabs.boss.Halloween.updateSelectedBossesLabel = function(selectedNames)
	selectedNames = {}
	for _, bossId in ipairs(tabs.boss.Halloween.Data.BossOrder) do
		if tabs.boss.Halloween.Data.SelectedBosses[bossId] then
			table.insert(selectedNames, tabs.boss.Halloween.Data.Bosses[bossId])
		end
	end
	tabs.boss.Halloween.SelectedBossesLabel.Text = "Targeted Halloween Bosses: "
		.. (#selectedNames > 0 and table.concat(selectedNames, ", ") or "None")
end

tabs.boss.Halloween.BossDropdown = tabs.boss:AddDropdown("Target specific Halloween Bosses", function(displayName, bossId)
	bossId = tabs.boss.Halloween.Data.BossByDisplayName[displayName]
	if not bossId then return end
	tabs.boss.Halloween.Data.SelectedBosses[bossId] = not tabs.boss.Halloween.Data.SelectedBosses[bossId]
	tabs.boss.Halloween.updateSelectedBossesLabel()
end)
for _, bossId in ipairs(tabs.boss.Halloween.Data.BossOrder) do
	tabs.boss.Halloween.Data.BossByDisplayName[tabs.boss.Halloween.Data.Bosses[bossId]] = bossId
	tabs.boss.Halloween.Data.SelectedBosses[bossId] = true
	tabs.boss.Halloween.BossDropdown:Add(tabs.boss.Halloween.Data.Bosses[bossId])
end
tabs.boss.Halloween.updateSelectedBossesLabel()

tabs.boss.Halloween.shouldFarmBoss = function(model)
	return tabs.boss.Halloween.Data.SelectedBosses[model:GetAttribute("BossId") or model.Name] == true
end

tabs.boss.Halloween.findActiveBoss = function(selectedOnly, model, hitbox, candidateHitbox, character, root, distance, closestDistance)
	character = utils.playerData.Player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	closestDistance = math.huge
	for _, candidate in ipairs(services.CollectionService:GetTagged("HalloweenBoss")) do
		if candidate:IsA("Model") and candidate:IsDescendantOf(services.Workspace)
			and tabs.boss.Halloween.getBossHealth(nil, candidate) > 0
			and (not selectedOnly or tabs.boss.Halloween.shouldFarmBoss(candidate)) then
			candidateHitbox = candidate:FindFirstChild("BossDamageHitbox", true)
				or candidate.PrimaryPart or candidate:FindFirstChild("HumanoidRootPart")
			if candidateHitbox and candidateHitbox:IsA("BasePart") then
				if selectedOnly and candidate == tabs.boss.Halloween.Data.Target then
					return candidate, nil, nil, candidateHitbox
				end
				distance = root and (root.Position - candidateHitbox.Position).Magnitude or 0
				if not model or distance < closestDistance then
					model, hitbox, closestDistance = candidate, candidateHitbox, distance
				end
			end
		end
	end
	return model, nil, nil, hitbox
end

task.spawn(function(model)
	while true do
		model = tabs.boss.Halloween.Data.Target
		if not model or not model.Parent or tabs.boss.Halloween.getBossHealth(nil, model) <= 0 then
			model = tabs.boss.Halloween.findActiveBoss()
		end
		if model then
			tabs.boss.Halloween.BossLabel.Text = "Halloween Boss: " .. tabs.boss.Halloween.getBossDisplayName(model)
			tabs.boss.Halloween.HealthLabel.Text = "Health: " .. utils.formatNumber(tabs.boss.Halloween.getBossHealth(nil, model))
				.. " / " .. utils.formatNumber(tabs.boss.Halloween.getBossMaxHealth(nil, model))
			tabs.boss.Halloween.NextBossLabel.Text = "Next Halloween Boss: Current boss active"
		else
			tabs.boss.Halloween.BossLabel.Text = "Halloween Boss: None"
			tabs.boss.Halloween.HealthLabel.Text = "Health: 0 / 0"
			tabs.boss.Halloween.NextBossLabel.Text = "Next Halloween Boss: Waiting for spawn"
		end
		task.wait(0.25)
	end
end)

tabs.boss.Halloween.AutoFarmSwitch = tabs.boss:AddSwitch("Auto Farm Halloween Boss", function(state)
	if state and tabs.boss.Data.Running then tabs.boss.AutoFarmSwitch:Set(false) end
	tabs.boss.Halloween.Data.Running = state
	tabs.boss.Halloween.Data.Generation += 1
	if not state then
		tabs.boss.Halloween.Data.Preparation = nil
		tabs.boss.Halloween.Data.Target = nil
		tabs.boss.Halloween.Data.Phase = "Waiting"
		tabs.boss.Halloween.StatusLabel.Text = "Status: Disabled"
		tabs.boss.resumeTraining()
		return
	end

	task.spawn(function(generation, wasFighting, model, health, maxHealth, hitbox)
		while tabs.boss.Halloween.Data.Running and tabs.boss.Halloween.Data.Generation == generation do
			pcall(function()
				model, health, maxHealth, hitbox = tabs.boss.Halloween.findActiveBoss(true)
				if model then
					if wasFighting and tabs.boss.needsRetraining(tabs.boss.Halloween) then wasFighting = false end
					if not wasFighting then
						if not tabs.boss.prepareForBoss(tabs.boss.Halloween) then return end
						wasFighting = true
						tabs.boss.pauseTraining()
					end
					if not tabs.boss.Halloween.Data.Running or tabs.boss.Halloween.Data.Generation ~= generation then return end
					if tabs.boss.needsRetraining(tabs.boss.Halloween) then return end
					if tabs.boss.Halloween.Data.Target ~= model then
						tabs.boss.Halloween.Data.Target = model
						tabs.boss.Halloween.Data.AttackSequence = nil
						tabs.boss.Halloween.Data.EvadeUntil = 0
						tabs.boss.Halloween.Data.DodgeStomps = false
					end
					tabs.boss.Halloween.Data.Phase = "Fighting"
					if utils.playerData.Player.Character
						and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid")
						and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
						tabs.boss.Halloween.StatusLabel.Text = "Status: Fighting"
						tabs.boss.attack(tabs.boss.Halloween, model, health, maxHealth, hitbox)
					else
						tabs.boss.Halloween.StatusLabel.Text = "Status: Waiting for Respawn"
					end
				else
					tabs.boss.Halloween.Data.Target = nil
					tabs.boss.Halloween.Data.Phase = "Waiting"
					if tabs.boss.Halloween.Data.Preparation then
						tabs.boss.Halloween.Data.Preparation = nil
						tabs.boss.resumeTraining()
					elseif wasFighting then
						tabs.boss.resumeTraining()
					end
					wasFighting = false
					tabs.boss.Halloween.StatusLabel.Text = "Status: Waiting for Halloween Boss"
				end
			end)
			task.wait(model and 0.03 or 0.25)
		end
	end, tabs.boss.Halloween.Data.Generation)
end)

tabs.inventory:AddLabel("Pet Shop:")

tabs.inventory.PetShopRuntime = services.ReplicatedStorage:WaitForChild("shared"):WaitForChild("runtime")
tabs.inventory.PetShopFolder = tabs.inventory.PetShopRuntime:WaitForChild("cPetShopFolder")
tabs.inventory.PetShopRemote = services.ReplicatedStorage.rEvents:WaitForChild("cPetShopRemote")

tabs.inventory.PetShopData = {
	PetList = {},
	Selected = {},
	SelectedList = {},
	BuyAmount = 1
}

tabs.inventory.AuraData = {
	AuraList = {},
	Selected = {},
	SelectedList = {},
	BuyAmount = 1
}

tabs.inventory.EvolveData = {Selected = {}, SelectedList = {}, Amount = 1}

for _, item in ipairs(tabs.inventory.PetShopFolder:GetChildren()) do
	if item:GetAttribute("IsPowerUp") == true then
		table.insert(tabs.inventory.AuraData.AuraList, item.Name)
	else
		table.insert(tabs.inventory.PetShopData.PetList, item.Name)
	end
end
table.sort(tabs.inventory.PetShopData.PetList)
table.sort(tabs.inventory.AuraData.AuraList)

tabs.inventory.BuyPetLabel = tabs.inventory:AddLabel("Selected Pets: None")
tabs.inventory.BuyPetDropdown = tabs.inventory:AddDropdown("Choose Pets", function(text)
	utils.toggleSelection(tabs.inventory.PetShopData.Selected, tabs.inventory.PetShopData.SelectedList, text, tabs.inventory.BuyPetLabel, "Selected Pets: ")
end)
for _, petName in ipairs(tabs.inventory.PetShopData.PetList) do tabs.inventory.BuyPetDropdown:Add(petName) end

tabs.inventory:AddTextBox("Buy Amount:", function(text)
	tabs.inventory.PetShopData.BuyAmount = math.max(1, math.floor(tonumber(text) or 1))
end, {clear = false})

tabs.inventory:AddSwitch("Buy Pet", function(bool)
	_G.AutoHatchPet = bool
	if bool then
		task.spawn(function()
			while _G.AutoHatchPet do
				for _, petName in ipairs(tabs.inventory.PetShopData.SelectedList) do
					tabs.inventory.runtime.selectedPet = tabs.inventory.PetShopFolder:FindFirstChild(petName)
					if tabs.inventory.runtime.selectedPet then
						for _ = 1, tabs.inventory.PetShopData.BuyAmount do
							task.spawn(function(selectedPet)
								pcall(function() tabs.inventory.PetShopRemote:InvokeServer(selectedPet) end)
							end, tabs.inventory.runtime.selectedPet)
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
end)

tabs.inventory:AddLabel("Auras:")

tabs.inventory.AuraLabel = tabs.inventory:AddLabel("Selected Auras: None")
tabs.inventory.AuraDropdown = tabs.inventory:AddDropdown("Select Auras", function(text)
	utils.toggleSelection(tabs.inventory.AuraData.Selected, tabs.inventory.AuraData.SelectedList, text, tabs.inventory.AuraLabel, "Selected Auras: ")
end)
for _, auraName in ipairs(tabs.inventory.AuraData.AuraList) do tabs.inventory.AuraDropdown:Add(auraName) end

tabs.inventory:AddTextBox("Buy Amount:", function(text)
	tabs.inventory.AuraData.BuyAmount = math.max(1, math.floor(tonumber(text) or 1))
end, {clear = false})

tabs.inventory:AddSwitch("Buy Aura", function(bool)
	_G.AutoHatchAura = bool
	if bool then
		task.spawn(function()
			while _G.AutoHatchAura do
				for _, auraName in ipairs(tabs.inventory.AuraData.SelectedList) do
					tabs.inventory.runtime.selectedAura = tabs.inventory.PetShopFolder:FindFirstChild(auraName)
					if tabs.inventory.runtime.selectedAura then
						for _ = 1, tabs.inventory.AuraData.BuyAmount do
							task.spawn(function(selectedAura)
								pcall(function() tabs.inventory.PetShopRemote:InvokeServer(selectedAura) end)
							end, tabs.inventory.runtime.selectedAura)
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
end)

tabs.inventory:AddLabel("You need Gems and Inventory Space!")

tabs.inventory:AddLabel("Auto Evolving:")

tabs.inventory.EvolveLabel = tabs.inventory:AddLabel("Selected Pets: None")
tabs.inventory.EvolvePetDropdown = tabs.inventory:AddDropdown("Choose Pets", function(text)
	utils.toggleSelection(tabs.inventory.EvolveData.Selected, tabs.inventory.EvolveData.SelectedList, text, tabs.inventory.EvolveLabel, "Selected Pets: ")
end)
for _, petName in ipairs(tabs.inventory.PetShopData.PetList) do tabs.inventory.EvolvePetDropdown:Add(petName) end

tabs.inventory:AddTextBox("Evolve Amount:", function(text)
	tabs.inventory.EvolveData.Amount = math.max(1, math.floor(tonumber(text) or 1))
end, {clear = false})

tabs.inventory.AutoEvolveRunning = false

tabs.inventory:AddSwitch("Auto Evolve", function(state)
    tabs.inventory.AutoEvolveRunning = state
    if not state then return end

    task.spawn(function()
        while tabs.inventory.AutoEvolveRunning do
			for _, petName in ipairs(tabs.inventory.EvolveData.SelectedList) do
				for _ = 1, tabs.inventory.EvolveData.Amount do
					services.ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", petName)
				end
			end
            task.wait(0.5)
        end
    end)
end)



tabs.inventory:AddLabel("Auto Trading:")

tabs.inventory.TradeData = {SelectedPlayers = {}, SelectedPlayerList = {}, SelectedPets = {}, SelectedPetList = {}, Generation = 0}

tabs.inventory.TradePlayerLabel = tabs.inventory:AddLabel("Selected Players: None")
tabs.inventory.TradePlayerDropdown = tabs.inventory:AddDropdown("Choose Player", function(name)
    tabs.inventory.runtime.username_2258 = name:match(" | (.+)") or name
    utils.toggleSelection(tabs.inventory.TradeData.SelectedPlayers, tabs.inventory.TradeData.SelectedPlayerList, tabs.inventory.runtime.username_2258, tabs.inventory.TradePlayerLabel, "Selected Players: ")
end)

tabs.inventory:AddButton("Add All Players", function()
	for _, player in ipairs(services.Players:GetPlayers()) do
		if player ~= services.Players.LocalPlayer and not tabs.inventory.TradeData.SelectedPlayers[player.Name] then
			tabs.inventory.TradeData.SelectedPlayers[player.Name] = true
			table.insert(tabs.inventory.TradeData.SelectedPlayerList, player.Name)
		end
	end
	tabs.inventory.TradePlayerLabel.Text = "Selected Players: " .. (#tabs.inventory.TradeData.SelectedPlayerList > 0 and table.concat(tabs.inventory.TradeData.SelectedPlayerList, ", ") or "None")
end)

for _, player in ipairs(services.Players:GetPlayers()) do
    if player ~= services.Players.LocalPlayer then
        tabs.inventory.TradePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

services.Players.PlayerAdded:Connect(function(player)
    if player ~= services.Players.LocalPlayer then
        tabs.inventory.TradePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

services.Players.PlayerRemoving:Connect(function(player)
    tabs.inventory.TradePlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
    if tabs.inventory.TradeData.SelectedPlayers[player.Name] then
		utils.toggleSelection(tabs.inventory.TradeData.SelectedPlayers, tabs.inventory.TradeData.SelectedPlayerList, player.Name, tabs.inventory.TradePlayerLabel, "Selected Players: ")
	end
end)

tabs.inventory.TradePetLabel = tabs.inventory:AddLabel("Selected Pets: None")
tabs.inventory.TradePetDropdown = tabs.inventory:AddDropdown("Choose Pets", function(text)
	utils.toggleSelection(tabs.inventory.TradeData.SelectedPets, tabs.inventory.TradeData.SelectedPetList, text, tabs.inventory.TradePetLabel, "Selected Pets: ")
end)
for _, petName in ipairs(tabs.inventory.PetShopData.PetList) do tabs.inventory.TradePetDropdown:Add(petName) end



tabs.inventory.AutoTradeRunning = false

tabs.inventory:AddSwitch("Auto Trade", function(state)
    tabs.inventory.AutoTradeRunning = state
	tabs.inventory.TradeData.Generation += 1
    if not state then return end

    task.spawn(function(generation)
        while tabs.inventory.AutoTradeRunning and tabs.inventory.TradeData.Generation == generation do
            if #tabs.inventory.TradeData.SelectedPlayerList > 0 and #tabs.inventory.TradeData.SelectedPetList > 0 then
				for _, username in ipairs(tabs.inventory.TradeData.SelectedPlayerList) do
					tabs.inventory.runtime.tradePlayer = services.Players:FindFirstChild(username)
					if not tabs.inventory.AutoTradeRunning or tabs.inventory.TradeData.Generation ~= generation then break end
					if tabs.inventory.runtime.tradePlayer then
						tabs.inventory.runtime.tradingEvent = services.ReplicatedStorage.rEvents.tradingEvent
						tabs.inventory.runtime.unique = game.Players.LocalPlayer.petsFolder.Unique

						tabs.inventory.runtime.tradingEvent:FireServer(
							"sendTradeRequest",
							tabs.inventory.runtime.tradePlayer
						)

						task.wait(0.5)

						tabs.inventory.runtime.offered = 0
						tabs.inventory.runtime.offeredPets = {}
						repeat
							tabs.inventory.runtime.addedPet = false
							for _, selectedName in ipairs(tabs.inventory.TradeData.SelectedPetList) do
								for _, pet in ipairs(tabs.inventory.runtime.unique:GetChildren()) do
									if pet.Name == selectedName and not tabs.inventory.runtime.offeredPets[pet] then
										tabs.inventory.runtime.tradingEvent:FireServer("offerItem", pet)
										tabs.inventory.runtime.offeredPets[pet] = true
										tabs.inventory.runtime.offered += 1
										tabs.inventory.runtime.addedPet = true
										task.wait(0.01)
										break
									end
								end
								if not tabs.inventory.AutoTradeRunning or tabs.inventory.TradeData.Generation ~= generation or tabs.inventory.runtime.offered >= 6 then break end
							end
						until not tabs.inventory.AutoTradeRunning or tabs.inventory.TradeData.Generation ~= generation or tabs.inventory.runtime.offered >= 6 or not tabs.inventory.runtime.addedPet

						task.wait(0.05)

						if tabs.inventory.AutoTradeRunning and tabs.inventory.TradeData.Generation == generation then
							tabs.inventory.runtime.tradingEvent:FireServer("acceptTrade")
							task.wait(2)
						end
					end
				end
            end

            task.wait(2)
        end
    end, tabs.inventory.TradeData.Generation)
end)





tabs.boosts:AddLabel("Boost Eater:")

tabs.boosts.EggEaterData = {Running = false}

task.spawn(function()
	while true do
		if tabs.boosts.EggEaterData.Running then
			tabs.boosts.runtime.tool_2122 = (utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("Protein Egg")) or utils.playerData.Player.Backpack:FindFirstChild("Protein Egg")
			if tabs.boosts.runtime.tool_2122 then utils.playerData.Player.muscleEvent:FireServer("proteinEgg", tabs.boosts.runtime.tool_2122) end
			task.wait(0.25)
		else
			task.wait(1)
		end
	end
end)

tabs.boosts:AddSwitch("Eat All Eggs", function(state) tabs.boosts.EggEaterData.Running = state end):Set(false)

tabs.boosts.BoostData = {
	ItemList = {"Tropical Shake", "Energy Shake", "Protein Bar", "TOUGH Bar", "Protein Shake", "ULTRA Shake", "Energy Bar"},
	Running = false
}

task.spawn(function()
	while true do
		if tabs.boosts.BoostData.Running then
			for _, itemName in ipairs(tabs.boosts.BoostData.ItemList) do
				tabs.boosts.runtime.tool_2142 = (utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild(itemName)) or utils.playerData.Player.Backpack:FindFirstChild(itemName)
				if tabs.boosts.runtime.tool_2142 then
					tabs.boosts.runtime.parts = {}
					for word in itemName:gmatch("%S+") do table.insert(tabs.boosts.runtime.parts, word:lower()) end
					for i = 2, #tabs.boosts.runtime.parts do tabs.boosts.runtime.parts[i] = tabs.boosts.runtime.parts[i]:sub(1, 1):upper() .. tabs.boosts.runtime.parts[i]:sub(2) end
					for i = 1, 10 do utils.playerData.Player.muscleEvent:FireServer(table.concat(tabs.boosts.runtime.parts), tabs.boosts.runtime.tool_2142) end
				end
			end
		end
		task.wait(0.1)
	end
end)

tabs.boosts:AddSwitch("Eat all Boosts (expect lag)", function(state) tabs.boosts.BoostData.Running = state end)

tabs.boosts:AddLabel("Egg Gifter:")

tabs.boosts.EggGifterData = {ProteinEggLabel = tabs.boosts:AddLabel("Protein Eggs: 0"), SelectedPlayer = nil, EggCount = 0}

tabs.boosts.EggPlayerDropdown = tabs.boosts:AddDropdown("Choose Player", function(name)
    tabs.boosts.runtime.username_2340 = name:match(" | (.+)") or name
    tabs.boosts.EggGifterData.SelectedPlayer = services.Players:FindFirstChild(tabs.boosts.runtime.username_2340)
end)

for _, player in ipairs(services.Players:GetPlayers()) do
    if player ~= services.Players.LocalPlayer then
        tabs.boosts.EggPlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

services.Players.PlayerAdded:Connect(function(player)
    if player ~= services.Players.LocalPlayer then
        tabs.boosts.EggPlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

services.Players.PlayerRemoving:Connect(function(player)
    tabs.boosts.EggPlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
    if tabs.boosts.EggGifterData.SelectedPlayer == player then tabs.boosts.EggGifterData.SelectedPlayer = nil end
end)

tabs.boosts.EggAmountTextBox = tabs.boosts:AddTextBox("Amount:", function(text)
	tabs.boosts.runtime.amount_2362 = tonumber(text)
	if tabs.boosts.runtime.amount_2362 then
		tabs.boosts.EggGifterData.EggCount = math.max(0, math.floor(tabs.boosts.runtime.amount_2362))
	end
end, {clear = false})

tabs.boosts:AddButton("Start Gifting", function()
	tabs.boosts.runtime.amount_2369 = tonumber(tabs.boosts.EggAmountTextBox.Text) or tabs.boosts.EggGifterData.EggCount
	tabs.boosts.runtime.amount_2369 = tabs.boosts.runtime.amount_2369 and math.max(0, math.floor(tabs.boosts.runtime.amount_2369)) or 0
	tabs.boosts.EggGifterData.EggCount = tabs.boosts.runtime.amount_2369

	if not tabs.boosts.EggGifterData.SelectedPlayer or tabs.boosts.runtime.amount_2369 == 0 then return end

	task.spawn(function()
		for _ = 1, tabs.boosts.runtime.amount_2369 do
			tabs.boosts.runtime.egg = services.Players.LocalPlayer.consumablesFolder:FindFirstChild("Protein Egg")
			if not tabs.boosts.runtime.egg then break end

			pcall(function()
				services.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", tabs.boosts.EggGifterData.SelectedPlayer, tabs.boosts.runtime.egg)
			end)
			task.wait(0.1)
		end
	end)
end)

tabs.boosts:AddLabel("Shake Gifter:")

tabs.boosts.ShakeGifterData = {TropicalShakeLabel = tabs.boosts:AddLabel("Tropical Shakes: 0"), SelectedPlayer = nil, ShakeCount = 0}

tabs.boosts.ShakePlayerDropdown = tabs.boosts:AddDropdown("Choose Player", function(name)
	tabs.boosts.runtime.usernameone = name:match(" | (.+)") or name
	tabs.boosts.ShakeGifterData.SelectedPlayer = services.Players:FindFirstChild(tabs.boosts.runtime.usernameone)
end)

for _, player in ipairs(services.Players:GetPlayers()) do
	if player ~= services.Players.LocalPlayer then
		tabs.boosts.ShakePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end

services.Players.PlayerAdded:Connect(function(player)
	if player ~= services.Players.LocalPlayer then
		tabs.boosts.ShakePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end)

services.Players.PlayerRemoving:Connect(function(player)
	tabs.boosts.ShakePlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	if tabs.boosts.ShakeGifterData.SelectedPlayer == player then tabs.boosts.ShakeGifterData.SelectedPlayer = nil end
end)

tabs.boosts.ShakeAmountTextBox = tabs.boosts:AddTextBox("Amount:", function(text)
	tabs.boosts.runtime.amount_2415 = tonumber(text)
	if tabs.boosts.runtime.amount_2415 then
		tabs.boosts.ShakeGifterData.ShakeCount = math.max(0, math.floor(tabs.boosts.runtime.amount_2415))
	end
end, {clear = false})

tabs.boosts:AddButton("Start Gifting", function()
	tabs.boosts.runtime.amount_2422 = tonumber(tabs.boosts.ShakeAmountTextBox.Text) or tabs.boosts.ShakeGifterData.ShakeCount
	tabs.boosts.runtime.amount_2422 = tabs.boosts.runtime.amount_2422 and math.max(0, math.floor(tabs.boosts.runtime.amount_2422)) or 0
	tabs.boosts.ShakeGifterData.ShakeCount = tabs.boosts.runtime.amount_2422

	if not tabs.boosts.ShakeGifterData.SelectedPlayer or tabs.boosts.runtime.amount_2422 == 0 then return end

	task.spawn(function()
		for _ = 1, tabs.boosts.runtime.amount_2422 do
			tabs.boosts.runtime.shake = services.Players.LocalPlayer.consumablesFolder:FindFirstChild("Tropical Shake")
			if not tabs.boosts.runtime.shake then break end

			pcall(function()
				services.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", tabs.boosts.ShakeGifterData.SelectedPlayer, tabs.boosts.runtime.shake)
			end)
			task.wait(0.1)
		end
	end)
end)

task.spawn(function()
	while true do
		tabs.boosts.runtime.proteinEggCount = 0
		tabs.boosts.runtime.tropicalShakeCount = 0
		if utils.playerData.Backpack then
			for _, item in ipairs(utils.playerData.Backpack:GetChildren()) do
				if item.Name == "Protein Egg" then tabs.boosts.runtime.proteinEggCount = tabs.boosts.runtime.proteinEggCount + 1
				elseif item.Name == "Tropical Shake" then tabs.boosts.runtime.tropicalShakeCount = tabs.boosts.runtime.tropicalShakeCount + 1 end
			end
		end
		tabs.boosts.EggGifterData.ProteinEggLabel.Text = "Protein Eggs: " .. tabs.boosts.runtime.proteinEggCount
		tabs.boosts.ShakeGifterData.TropicalShakeLabel.Text = "Tropical Shakes: " .. tabs.boosts.runtime.tropicalShakeCount
		task.wait(7.5)
	end
end)

tabs.boosts:AddLabel("Interferes with Boosts you got gifted. Get on a machine for less Lag!")

tabs.teleport:AddLabel("Main:")

tabs.teleport.Locations = {
	{name = "Tiny Island", pos = CFrame.new(-37.1, 9.2, 1919)},
	{name = "Main Island", pos = CFrame.new(16.07, 9.08, 133.8)},
	{name = "Beach", pos = CFrame.new(-8, 9, -169.2)}
}

for _, loc in ipairs(tabs.teleport.Locations) do
	tabs.teleport:AddButton(loc.name, function()
		if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			utils.playerData.Player.Character.HumanoidRootPart.CFrame = loc.pos
		end
	end)
end

tabs.teleport:AddLabel("Gyms:")

tabs.teleport.GymLocations = {
	{name = "Overcharged Gym", pos = CFrame.new(-2941.766, 151.797, 4994.552)},
	{name = "Industrial gym", pos = CFrame.new(-5254.681641, 58.342850, 4931.850586)},
	{name = "Jungle Gym", pos = CFrame.new(-8543, 6.8, 2400)},
	{name = "Muscle King Gym", pos = CFrame.new(-8665.4, 17.21, -5792.9)},
	{name = "Legends Gym", pos = CFrame.new(4516, 991.5, -3856)},
	{name = "Infernal Gym", pos = CFrame.new(-6759, 7.36, -1284)},
	{name = "Mythical Gym", pos = CFrame.new(2250, 7.37, 1073.2)},
	{name = "Frost Gym", pos = CFrame.new(-2623, 7.36, -409)}
}

for _, gym in ipairs(tabs.teleport.GymLocations) do
	tabs.teleport:AddButton(gym.name, function()
		if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			utils.playerData.Player.Character.HumanoidRootPart.CFrame = gym.pos
		end
	end)
end

tabs.stats:AddLabel("Elapsed Time:")

tabs.stats.Data = {
	StopwatchLabel = tabs.stats:AddLabel("0d 0h 0m 0s"),
	StartTime = tick(),
	Leaderstats = utils.playerData.Player:WaitForChild("leaderstats"),
	Stats = {},
	InitialValues = {},
	StatLabels = {}
}

tabs.stats:AddLabel("Stats:")

task.spawn(function()
	while true do
		tabs.stats.runtime.elapsedTime = tick() - tabs.stats.Data.StartTime
		tabs.stats.runtime.days = math.floor(tabs.stats.runtime.elapsedTime / (24 * 3600))
		tabs.stats.runtime.hours = math.floor((tabs.stats.runtime.elapsedTime % (24 * 3600)) / 3600)
		tabs.stats.runtime.minutes = math.floor((tabs.stats.runtime.elapsedTime % 3600) / 60)
		tabs.stats.runtime.seconds = math.floor(tabs.stats.runtime.elapsedTime % 60)
		tabs.stats.Data.StopwatchLabel.Text = string.format("%dd %dh %dm %ds", tabs.stats.runtime.days, tabs.stats.runtime.hours, tabs.stats.runtime.minutes, tabs.stats.runtime.seconds)
		task.wait(0.1)
	end
end)

tabs.stats.Data.Stats = {
	{name = tabs.specs.Data.EmojiMap["Strength"] .. " Strength", stat = tabs.stats.Data.Leaderstats:WaitForChild("Strength")},
	{name = tabs.specs.Data.EmojiMap["Rebirths"] .. " Rebirths", stat = tabs.stats.Data.Leaderstats:WaitForChild("Rebirths")},
	{name = tabs.specs.Data.EmojiMap["Durability"] .. " Durability", stat = utils.playerData.Player:WaitForChild("Durability")},
	{name = tabs.specs.Data.EmojiMap["Kills"] .. " Kills", stat = tabs.stats.Data.Leaderstats:WaitForChild("Kills")},
	{name = tabs.specs.Data.EmojiMap["Agility"] .. " Agility", stat = utils.playerData.Player:WaitForChild("Agility")},
	{name = tabs.specs.Data.EmojiMap["Evil Karma"] .. " Evil Karma", stat = utils.playerData.Player:WaitForChild("evilKarma")},
	{name = tabs.specs.Data.EmojiMap["Good Karma"] .. " Good Karma", stat = utils.playerData.Player:WaitForChild("goodKarma")},
	{name = tabs.specs.Data.EmojiMap["Brawls"] .. " Brawls", stat = tabs.stats.Data.Leaderstats:WaitForChild("Brawls")}
}

for _, info in ipairs(tabs.stats.Data.Stats) do
	tabs.stats.Data.InitialValues[info.name] = info.stat.Value
	tabs.stats.Data.StatLabels[info.name] = tabs.stats:AddLabel("")
end

task.spawn(function()
	while true do
		for _, info in ipairs(tabs.stats.Data.Stats) do
			tabs.stats.runtime.currentValue = info.stat.Value
			tabs.stats.runtime.gained = tabs.stats.runtime.currentValue - tabs.stats.Data.InitialValues[info.name]
			tabs.stats.Data.StatLabels[info.name].Text = string.format("%s: %s (%s) | Gained: %s (%s)", info.name,
				utils.formatNumber(tabs.stats.runtime.currentValue), utils.formatWithCommas(tabs.stats.runtime.currentValue),
				utils.formatNumber(tabs.stats.runtime.gained), utils.formatWithCommas(tabs.stats.runtime.gained))
		end
		task.wait(0.1)
	end
end)
tabs.info:Show()
tabs.info:AddLabel("Made by xyzhenrik")
tabs.info:AddLabel("Any issues? Create a Ticket on Discord")
tabs.info:AddLabel("Official Discord: discord.gg/9eFf93Kg8D")
tabs.info:AddButton("Copy Invite", function()
	if type(setclipboard) == "function" and pcall(setclipboard, "https://discord.gg/9eFf93Kg8D") then
		pcall(function() game.StarterGui:SetCore("SendNotification", {Title = "Link Copied!", Text = "You can continue to Discord now.", Duration = 3}) end)
	else
		pcall(function() game.StarterGui:SetCore("SendNotification", {Title = "Error!", Text = "Clipboard not Supported.", Duration = 3}) end)
	end
end)
tabs.info:AddLabel("")
tabs.info:AddLabel("Contributors:").TextSize = 17
tabs.info:AddLabel("- Henrik @xyzhenrik")
tabs.info:AddLabel("- Muki @mukimagdich")
tabs.info:AddLabel("- HalisAnteo @xyzhalis")
tabs.info:AddLabel("")
tabs.info:AddLabel("Silence is Open-Source!")
tabs.info:AddLabel("")
tabs.info.VersionLabel = tabs.info:AddLabel("Muscle Legends [V4.2.0]")
tabs.info.VersionLabel.TextSize = 20
tabs.info.VersionLabel.Font = Enum.Font.Arcade
]====],Controls={
{Kind=[====[
Paragraph]====],Title=[====[
User Settings:]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/User Settings:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/User Settings:]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Size:]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/Size:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Size:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Set Size]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/Set Size]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Set Size]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Speed:]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/Speed:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Speed:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Set Speed]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/Set Speed]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Set Speed]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
FOV:]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/FOV:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/FOV:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Set FOV]====],Desc=[====[
Finalidade: User Settings:
Origem: Mystery/Silence | Main - Good Noon!/Main/Set FOV]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Set FOV]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Protection and Visuals:]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Protection and Visuals:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Protection and Visuals:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Anti Fling]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Anti Fling]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Anti Fling]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Lock Position]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Lock Position]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Lock Position]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show Pets]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Show Pets]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Show Pets]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show Other Pets]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Show Other Pets]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Show Other Pets]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show PopUps]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Show PopUps]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Show PopUps]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Hide Name]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Hide Name]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Hide Name]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Hide Stats]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Hide Stats]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Hide Stats]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Walk on Water]====],Desc=[====[
Finalidade: Protection and Visuals:
Origem: Mystery/Silence | Main - Good Noon!/Main/Walk on Water]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Walk on Water]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Other:]====],Desc=[====[
Finalidade: Other:
Origem: Mystery/Silence | Main - Good Noon!/Main/Other:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Other:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Infinite Jump]====],Desc=[====[
Finalidade: Other:
Origem: Mystery/Silence | Main - Good Noon!/Main/Infinite Jump]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Infinite Jump]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Spin Fortune Wheel]====],Desc=[====[
Finalidade: Other:
Origem: Mystery/Silence | Main - Good Noon!/Main/Spin Fortune Wheel]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Spin Fortune Wheel]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Change Time]====],Desc=[====[
Finalidade: Other:
Origem: Mystery/Silence | Main - Good Noon!/Main/Change Time]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Main/Change Time]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Misc:]====],Desc=[====[
Finalidade: Misc:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Misc:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Misc:]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Equip Best Damage]====],Desc=[====[
Finalidade: Misc:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Equip Best Damage]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Equip Best Damage]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Equip Best Health]====],Desc=[====[
Finalidade: Misc:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Equip Best Health]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Equip Best Health]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Remove Attack Animations]====],Desc=[====[
Finalidade: Misc:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Remove Attack Animations]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Remove Attack Animations]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Auto Kill:]====],Desc=[====[
Finalidade: Auto Kill:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Auto Kill:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Auto Kill:]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Add to Whitelist]====],Desc=[====[
Finalidade: Auto Kill:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Add to Whitelist]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Add to Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Kill Everyone]====],Desc=[====[
Finalidade: Auto Kill:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Kill Everyone]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Kill Everyone]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Whitelist Friends]====],Desc=[====[
Finalidade: Auto Kill:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Whitelist Friends]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Whitelist Friends]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Karma Killing:]====],Desc=[====[
Finalidade: Karma Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Karma Killing:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Karma Killing:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Farm Evil Karma]====],Desc=[====[
Finalidade: Karma Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Farm Evil Karma]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Farm Evil Karma]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Farm Good Karma]====],Desc=[====[
Finalidade: Karma Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Farm Good Karma]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Farm Good Karma]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Target Killing:]====],Desc=[====[
Finalidade: Target Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Target Killing:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Target Killing:]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Add to Killlist]====],Desc=[====[
Finalidade: Target Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Add to Killlist]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Add to Killlist]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Kill List]====],Desc=[====[
Finalidade: Target Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Kill List]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Kill List]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Player]====],Desc=[====[
Finalidade: Target Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Choose Player]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Choose Player]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Spectate]====],Desc=[====[
Finalidade: Target Killing:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Spectate]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Spectate]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Kill Aura:]====],Desc=[====[
Finalidade: Kill Aura:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Kill Aura:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Kill Aura:]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Range (1-140):]====],Desc=[====[
Finalidade: Kill Aura:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Range (1-140):]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Range (1-140):]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Ring Color]====],Desc=[====[
Finalidade: Kill Aura:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Ring Color]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Ring Color]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show Ring]====],Desc=[====[
Finalidade: Kill Aura:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Show Ring]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Show Ring]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Toggle Ring]====],Desc=[====[
Finalidade: Kill Aura:
Origem: Mystery/Silence | Main - Good Noon!/Killing/Toggle Ring]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Toggle Ring]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Whitelist: None]====],Desc=[====[
Finalidade: Whitelist: None
Origem: Mystery/Silence | Main - Good Noon!/Killing/Whitelist: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Whitelist: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Remove from Whitelist]====],Desc=[====[
Finalidade: Whitelist: None
Origem: Mystery/Silence | Main - Good Noon!/Killing/Remove from Whitelist]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Remove from Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Clear Whitelist]====],Desc=[====[
Finalidade: Whitelist: None
Origem: Mystery/Silence | Main - Good Noon!/Killing/Clear Whitelist]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Clear Whitelist]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Killlist: None]====],Desc=[====[
Finalidade: Killlist: None
Origem: Mystery/Silence | Main - Good Noon!/Killing/Killlist: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Killlist: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Remove from Killlist]====],Desc=[====[
Finalidade: Killlist: None
Origem: Mystery/Silence | Main - Good Noon!/Killing/Remove from Killlist]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Remove from Killlist]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Clear Killlist]====],Desc=[====[
Finalidade: Killlist: None
Origem: Mystery/Silence | Main - Good Noon!/Killing/Clear Killlist]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Killing/Clear Killlist]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Player Stats:]====],Desc=[====[
Finalidade: Player Stats:
Origem: Mystery/Silence | Main - Good Noon!/Specs/Player Stats:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/Player Stats:]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Player]====],Desc=[====[
Finalidade: Player Stats:
Origem: Mystery/Silence | Main - Good Noon!/Specs/Choose Player]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/Choose Player]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
👤 Name: N/A]====],Desc=[====[
Finalidade: 👤 Name: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/👤 Name: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/👤 Name: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
🎫 Username: N/A]====],Desc=[====[
Finalidade: 🎫 Username: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/🎫 Username: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/🎫 Username: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
💪 Strength: N/A]====],Desc=[====[
Finalidade: 💪 Strength: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/💪 Strength: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/💪 Strength: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
🔄 Rebirths: N/A]====],Desc=[====[
Finalidade: 🔄 Rebirths: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/🔄 Rebirths: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/🔄 Rebirths: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
🛡 Durability: N/A]====],Desc=[====[
Finalidade: 🛡 Durability: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/🛡 Durability: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/🛡 Durability: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
⚡ Agility: N/A]====],Desc=[====[
Finalidade: ⚡ Agility: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/⚡ Agility: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/⚡ Agility: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
💀 Kills: N/A]====],Desc=[====[
Finalidade: 💀 Kills: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/💀 Kills: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/💀 Kills: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
😈 Evil Karma: N/A]====],Desc=[====[
Finalidade: 😈 Evil Karma: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/😈 Evil Karma: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/😈 Evil Karma: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
😇 Good Karma: N/A]====],Desc=[====[
Finalidade: 😇 Good Karma: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/😇 Good Karma: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/😇 Good Karma: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
🥊 Brawls: N/A]====],Desc=[====[
Finalidade: 🥊 Brawls: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/🥊 Brawls: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/🥊 Brawls: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
———————————————————————————————————]====],Desc=[====[
Finalidade: ———————————————————————————————————
Origem: Mystery/Silence | Main - Good Noon!/Specs/———————————————————————————————————]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/———————————————————————————————————]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Advanced Stats:]====],Desc=[====[
Finalidade: Advanced Stats:
Origem: Mystery/Silence | Main - Good Noon!/Specs/Advanced Stats:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/Advanced Stats:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
🛡️ Enemy Health: N/A]====],Desc=[====[
Finalidade: 🛡️ Enemy Health: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/🛡️ Enemy Health: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/🛡️ Enemy Health: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
💥 Enemy Damage: N/A]====],Desc=[====[
Finalidade: 💥 Enemy Damage: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/💥 Enemy Damage: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/💥 Enemy Damage: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
🛡️ Your Health: N/A]====],Desc=[====[
Finalidade: 🛡️ Your Health: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/🛡️ Your Health: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/🛡️ Your Health: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
💥 Your Damage: N/A]====],Desc=[====[
Finalidade: 💥 Your Damage: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/💥 Your Damage: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/💥 Your Damage: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
👊 Hits to Kill: N/A]====],Desc=[====[
Finalidade: 👊 Hits to Kill: N/A
Origem: Mystery/Silence | Main - Good Noon!/Specs/👊 Hits to Kill: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Specs/👊 Hits to Kill: N/A]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Rebirths:]====],Desc=[====[
Finalidade: Rebirths:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Rebirths:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Rebirths:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Rebirths: 0]====],Desc=[====[
Finalidade: Rebirths: 0
Origem: Mystery/Silence | Main - Good Noon!/Farming/Rebirths: 0]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Rebirths: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Target: None]====],Desc=[====[
Finalidade: Target: None
Origem: Mystery/Silence | Main - Good Noon!/Farming/Target: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Target: None]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Set Rebirth Target (Required):]====],Desc=[====[
Finalidade: Target: None
Origem: Mystery/Silence | Main - Good Noon!/Farming/Set Rebirth Target (Required):]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Set Rebirth Target (Required):]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Rebirth]====],Desc=[====[
Finalidade: Target: None
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Rebirth]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Rebirth]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Size 1]====],Desc=[====[
Finalidade: Target: None
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Size 1]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Size 1]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto King]====],Desc=[====[
Finalidade: Target: None
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto King]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto King]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Auto Exercises (recommended for rebirthing):]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Exercises (recommended for rebirthing):]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Exercises (recommended for rebirthing):]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Exercise]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Select Exercise]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Select Exercise]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Start exercising]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Start exercising]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Start exercising]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Squat]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Select Squat]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Select Squat]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Squat]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Squat]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Squat]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Lift]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Select Lift]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Select Lift]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Lift]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Lift]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Lift]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Rep]====],Desc=[====[
Finalidade: Auto Exercises (recommended for rebirthing):
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Rep]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Rep]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Auto Rock:]====],Desc=[====[
Finalidade: Auto Rock:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Rock:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Rock:]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Rock]====],Desc=[====[
Finalidade: Auto Rock:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Select Rock]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Select Rock]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Rock]====],Desc=[====[
Finalidade: Auto Rock:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Auto Rock]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Auto Rock]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Better Strength Farming:]====],Desc=[====[
Finalidade: Better Strength Farming:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Better Strength Farming:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Better Strength Farming:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Pushup + Industrial Rock]====],Desc=[====[
Finalidade: Better Strength Farming:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Pushup + Industrial Rock]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Pushup + Industrial Rock]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Pushup + Jungle Rock]====],Desc=[====[
Finalidade: Better Strength Farming:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Pushup + Jungle Rock]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Pushup + Jungle Rock]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Pushup + Muscle King Rock]====],Desc=[====[
Finalidade: Better Strength Farming:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Pushup + Muscle King Rock]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Pushup + Muscle King Rock]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Pushup + Legends Rock]====],Desc=[====[
Finalidade: Better Strength Farming:
Origem: Mystery/Silence | Main - Good Noon!/Farming/Pushup + Legends Rock]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Farming/Pushup + Legends Rock]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Boss Farming:]====],Desc=[====[
Finalidade: Boss Farming:
Origem: Mystery/Silence | Main - Good Noon!/Boss/Boss Farming:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Boss Farming:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Status: Waiting for Boss]====],Desc=[====[
Finalidade: Status: Waiting for Boss
Origem: Mystery/Silence | Main - Good Noon!/Boss/Status: Waiting for Boss]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Status: Waiting for Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Boss: None]====],Desc=[====[
Finalidade: Boss: None
Origem: Mystery/Silence | Main - Good Noon!/Boss/Boss: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Boss: None]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Health: 0 / 0]====],Desc=[====[
Finalidade: Health: 0 / 0
Origem: Mystery/Silence | Main - Good Noon!/Boss/Health: 0 / 0]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Health: 0 / 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Next Boss: N/A]====],Desc=[====[
Finalidade: Next Boss: N/A
Origem: Mystery/Silence | Main - Good Noon!/Boss/Next Boss: N/A]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Next Boss: N/A]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Seconds Training before Boss (when Rebirthing):]====],Desc=[====[
Finalidade: Next Boss: N/A
Origem: Mystery/Silence | Main - Good Noon!/Boss/Seconds Training before Boss (when Rebirthing):]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Seconds Training before Boss (when Rebirthing):]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Targeted Bosses: Detecting...]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Main - Good Noon!/Boss/Targeted Bosses: Detecting...]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Targeted Bosses: Detecting...]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Target specific Bosses]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Main - Good Noon!/Boss/Target specific Bosses]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Target specific Bosses]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Continue Farming after Boss Kill]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Main - Good Noon!/Boss/Continue Farming after Boss Kill]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Continue Farming after Boss Kill]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Farm Boss]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Main - Good Noon!/Boss/Auto Farm Boss]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Auto Farm Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Main - Good Noon!/Boss/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Halloween Boss Farming:]====],Desc=[====[
Finalidade: Halloween Boss Farming:
Origem: Mystery/Silence | Main - Good Noon!/Boss/Halloween Boss Farming:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Halloween Boss Farming:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Status: Waiting for Halloween Boss]====],Desc=[====[
Finalidade: Status: Waiting for Halloween Boss
Origem: Mystery/Silence | Main - Good Noon!/Boss/Status: Waiting for Halloween Boss]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Status: Waiting for Halloween Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Halloween Boss: None]====],Desc=[====[
Finalidade: Halloween Boss: None
Origem: Mystery/Silence | Main - Good Noon!/Boss/Halloween Boss: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Halloween Boss: None]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Health: 0 / 0]====],Desc=[====[
Finalidade: Health: 0 / 0
Origem: Mystery/Silence | Main - Good Noon!/Boss/Health: 0 / 0]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Health: 0 / 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Next Halloween Boss: Waiting for spawn]====],Desc=[====[
Finalidade: Next Halloween Boss: Waiting for spawn
Origem: Mystery/Silence | Main - Good Noon!/Boss/Next Halloween Boss: Waiting for spawn]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Next Halloween Boss: Waiting for spawn]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Targeted Halloween Bosses: All]====],Desc=[====[
Finalidade: Targeted Halloween Bosses: All
Origem: Mystery/Silence | Main - Good Noon!/Boss/Targeted Halloween Bosses: All]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Targeted Halloween Bosses: All]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Target specific Halloween Bosses]====],Desc=[====[
Finalidade: Targeted Halloween Bosses: All
Origem: Mystery/Silence | Main - Good Noon!/Boss/Target specific Halloween Bosses]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Target specific Halloween Bosses]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Farm Halloween Boss]====],Desc=[====[
Finalidade: Targeted Halloween Bosses: All
Origem: Mystery/Silence | Main - Good Noon!/Boss/Auto Farm Halloween Boss]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boss/Auto Farm Halloween Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Pet Shop:]====],Desc=[====[
Finalidade: Pet Shop:
Origem: Mystery/Silence | Main - Good Noon!/Pets/Pet Shop:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Pet Shop:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Selected Pets: None]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Selected Pets: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Selected Pets: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Pets]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Choose Pets]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Choose Pets]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Buy Amount:]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Buy Amount:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Buy Amount:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Buy Pet]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Buy Pet]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Buy Pet]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Auras:]====],Desc=[====[
Finalidade: Auras:
Origem: Mystery/Silence | Main - Good Noon!/Pets/Auras:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Auras:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Selected Auras: None]====],Desc=[====[
Finalidade: Selected Auras: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Selected Auras: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Selected Auras: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Select Auras]====],Desc=[====[
Finalidade: Selected Auras: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Select Auras]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Select Auras]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Buy Amount:]====],Desc=[====[
Finalidade: Selected Auras: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Buy Amount:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Buy Amount:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Buy Aura]====],Desc=[====[
Finalidade: Selected Auras: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Buy Aura]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Buy Aura]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
You need Gems and Inventory Space!]====],Desc=[====[
Finalidade: You need Gems and Inventory Space!
Origem: Mystery/Silence | Main - Good Noon!/Pets/You need Gems and Inventory Space!]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/You need Gems and Inventory Space!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Auto Evolving:]====],Desc=[====[
Finalidade: Auto Evolving:
Origem: Mystery/Silence | Main - Good Noon!/Pets/Auto Evolving:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Auto Evolving:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Selected Pets: None]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Selected Pets: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Selected Pets: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Pets]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Choose Pets]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Choose Pets]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Evolve Amount:]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Evolve Amount:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Evolve Amount:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Evolve]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Auto Evolve]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Auto Evolve]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Auto Trading:]====],Desc=[====[
Finalidade: Auto Trading:
Origem: Mystery/Silence | Main - Good Noon!/Pets/Auto Trading:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Auto Trading:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Selected Players: None]====],Desc=[====[
Finalidade: Selected Players: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Selected Players: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Selected Players: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Player]====],Desc=[====[
Finalidade: Selected Players: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Choose Player]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Choose Player]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Add All Players]====],Desc=[====[
Finalidade: Selected Players: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Add All Players]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Add All Players]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Selected Pets: None]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Selected Pets: None]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Selected Pets: None]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Pets]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Choose Pets]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Choose Pets]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Trade]====],Desc=[====[
Finalidade: Selected Pets: None
Origem: Mystery/Silence | Main - Good Noon!/Pets/Auto Trade]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Pets/Auto Trade]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Boost Eater:]====],Desc=[====[
Finalidade: Boost Eater:
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Boost Eater:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Boost Eater:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Eat All Eggs]====],Desc=[====[
Finalidade: Boost Eater:
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Eat All Eggs]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Eat All Eggs]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Eat all Boosts (expect lag)]====],Desc=[====[
Finalidade: Boost Eater:
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Eat all Boosts (expect lag)]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Eat all Boosts (expect lag)]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Egg Gifter:]====],Desc=[====[
Finalidade: Egg Gifter:
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Egg Gifter:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Egg Gifter:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Protein Eggs: 0]====],Desc=[====[
Finalidade: Protein Eggs: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Protein Eggs: 0]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Protein Eggs: 0]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Player]====],Desc=[====[
Finalidade: Protein Eggs: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Choose Player]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Choose Player]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Amount:]====],Desc=[====[
Finalidade: Protein Eggs: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Amount:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Amount:]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Start Gifting]====],Desc=[====[
Finalidade: Protein Eggs: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Start Gifting]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Start Gifting]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Shake Gifter:]====],Desc=[====[
Finalidade: Shake Gifter:
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Shake Gifter:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Shake Gifter:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Tropical Shakes: 0]====],Desc=[====[
Finalidade: Tropical Shakes: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Tropical Shakes: 0]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Tropical Shakes: 0]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Choose Player]====],Desc=[====[
Finalidade: Tropical Shakes: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Choose Player]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Choose Player]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Amount:]====],Desc=[====[
Finalidade: Tropical Shakes: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Amount:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Amount:]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Start Gifting]====],Desc=[====[
Finalidade: Tropical Shakes: 0
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Start Gifting]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Start Gifting]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Interferes with Boosts you got gifted. Get on a machine for less Lag!]====],Desc=[====[
Finalidade: Interferes with Boosts you got gifted. Get on a machine for less Lag!
Origem: Mystery/Silence | Main - Good Noon!/Boosts/Interferes with Boosts you got gifted. Get on a machine for less Lag!]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Boosts/Interferes with Boosts you got gifted. Get on a machine for less Lag!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Main:]====],Desc=[====[
Finalidade: Main:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Main:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Main:]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Tiny Island]====],Desc=[====[
Finalidade: Main:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Tiny Island]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Tiny Island]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Main Island]====],Desc=[====[
Finalidade: Main:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Main Island]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Main Island]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Beach]====],Desc=[====[
Finalidade: Main:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Beach]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Beach]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Gyms:]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Gyms:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Gyms:]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Overcharged Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Overcharged Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Overcharged Gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Industrial gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Industrial gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Industrial gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Jungle Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Jungle Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Jungle Gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Muscle King Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Muscle King Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Muscle King Gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Legends Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Legends Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Legends Gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Infernal Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Infernal Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Infernal Gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Mythical Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Mythical Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Mythical Gym]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Frost Gym]====],Desc=[====[
Finalidade: Gyms:
Origem: Mystery/Silence | Main - Good Noon!/Teleports/Frost Gym]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Teleports/Frost Gym]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Elapsed Time:]====],Desc=[====[
Finalidade: Elapsed Time:
Origem: Mystery/Silence | Main - Good Noon!/Stats/Elapsed Time:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/Elapsed Time:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
0d 0h 0m 0s]====],Desc=[====[
Finalidade: 0d 0h 0m 0s
Origem: Mystery/Silence | Main - Good Noon!/Stats/0d 0h 0m 0s]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/0d 0h 0m 0s]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Stats:]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/Stats:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/Stats:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Stats:
Origem: Mystery/Silence | Main - Good Noon!/Stats/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Stats/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Made by xyzhenrik]====],Desc=[====[
Finalidade: Made by xyzhenrik
Origem: Mystery/Silence | Main - Good Noon!/Info/Made by xyzhenrik]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Made by xyzhenrik]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Any issues? Create a Ticket on Discord]====],Desc=[====[
Finalidade: Any issues? Create a Ticket on Discord
Origem: Mystery/Silence | Main - Good Noon!/Info/Any issues? Create a Ticket on Discord]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Any issues? Create a Ticket on Discord]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Official Discord: discord.gg/9eFf93Kg8D]====],Desc=[====[
Finalidade: Official Discord: discord.gg/9eFf93Kg8D
Origem: Mystery/Silence | Main - Good Noon!/Info/Official Discord: discord.gg/9eFf93Kg8D]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Official Discord: discord.gg/9eFf93Kg8D]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Copy Invite]====],Desc=[====[
Finalidade: Official Discord: discord.gg/9eFf93Kg8D
Origem: Mystery/Silence | Main - Good Noon!/Info/Copy Invite]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Copy Invite]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Official Discord: discord.gg/9eFf93Kg8D
Origem: Mystery/Silence | Main - Good Noon!/Info/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Contributors:]====],Desc=[====[
Finalidade: Contributors:
Origem: Mystery/Silence | Main - Good Noon!/Info/Contributors:]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Contributors:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
- Henrik @xyzhenrik]====],Desc=[====[
Finalidade: - Henrik @xyzhenrik
Origem: Mystery/Silence | Main - Good Noon!/Info/- Henrik @xyzhenrik]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/- Henrik @xyzhenrik]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
- Muki @mukimagdich]====],Desc=[====[
Finalidade: - Muki @mukimagdich
Origem: Mystery/Silence | Main - Good Noon!/Info/- Muki @mukimagdich]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/- Muki @mukimagdich]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
- HalisAnteo @xyzhalis]====],Desc=[====[
Finalidade: - HalisAnteo @xyzhalis
Origem: Mystery/Silence | Main - Good Noon!/Info/- HalisAnteo @xyzhalis]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/- HalisAnteo @xyzhalis]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: - HalisAnteo @xyzhalis
Origem: Mystery/Silence | Main - Good Noon!/Info/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Silence is Open-Source!]====],Desc=[====[
Finalidade: Silence is Open-Source!
Origem: Mystery/Silence | Main - Good Noon!/Info/Silence is Open-Source!]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Silence is Open-Source!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Silence is Open-Source!
Origem: Mystery/Silence | Main - Good Noon!/Info/]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Muscle Legends [V4.2.0]]====],Desc=[====[
Finalidade: Muscle Legends [V4.2.0]
Origem: Mystery/Silence | Main - Good Noon!/Info/Muscle Legends [V4.2.0]]====],Path=[====[
Mystery/Silence | Main - Good Noon!/Info/Muscle Legends [V4.2.0]]====],Default=[====[
]====]}
},Saved=setmetatable({}, {__mode="k"}),Created={},Connections={},Widgets={},Status="Carrega ao usar"}
B.Engines[#B.Engines+1]={Name=[====[
Silence Farming]====],Id=[====[
silence_farming]====],Source=[====[
--[[
    Silence - Ml Farming
    by Henrik @xyzhenrik
       Muki @mukimagdich
]]

local services = {
    players = game:GetService("Players"),
    replicatedstorage = game:GetService("ReplicatedStorage"),
    runservice = game:GetService("RunService"),
    tws = game:GetService("TweenService"),
    userinputservice = game:GetService("UserInputService"),
    httpservice = game:GetService("HttpService"),
    virtualuser = game:GetService("VirtualUser"),
    virtualinputmanager = game:GetService("VirtualInputManager"),
    lighting = game:GetService("Lighting"),
    startergui = game:GetService("StarterGui"),
    collectionservice = game:GetService("CollectionService")
}

local lp = {
    player = services.players.LocalPlayer,
    userid = services.players.LocalPlayer.UserId,
    username = services.players.LocalPlayer.Name,
    displayname = services.players.LocalPlayer.DisplayName
}

lp.player.Idled:Connect(function()
    pcall(function()
        services.virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
        task.wait(0.05)
        services.virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
    end)
end)

function deleteAds()
	for _, portal in pairs(game:GetDescendants()) do
		if portal.Name == "RobloxForwardPortals" then
			portal:Destroy()
		end
	end
	if _G.ads then
		_G.ads:Disconnect()
	end

	_G.ads = game.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "RobloxForwardPortals" then
			descendant:Destroy()
		end
	end)
end
deleteAds()

function deleteBodyMovementScript()
    if lp.player.Character and lp.player.Character:FindFirstChild("bodyMovementScript") then
        lp.player.Character.bodyMovementScript:Destroy()
    end
end
deleteBodyMovementScript()


services.muscleEvent = lp.player:WaitForChild("muscleEvent")
services.touchParts = function(part, hand, state)
    if type(firetouchinterest) ~= "function" or not part or not hand then return false end
    return pcall(firetouchinterest, part, hand, state)
end

local function greeting(hour)
    hour = hour or os.date("*t").hour
    if hour >= 6 and hour < 12 then return "Good Morning!"
    elseif hour >= 12 and hour < 13 then return "Good Noon!"
    elseif hour >= 13 and hour < 19 then return "Good Afternoon!"
    elseif hour >= 19 and hour < 22 then return "Good Evening!"
    else return "Good Night!" end
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/silencedevs/SilenceScripts/refs/heads/main/libraries/eleriumv2.luau?cache=" .. tostring(os.time()), true))()
local silence = library:AddWindow("Silence | Fast Farming - " .. greeting(), {
    main_color = Color3.fromRGB(138, 0, 0),
    min_size = Vector2.new(500, 560),
    can_resize = false
})

task.spawn(function()
    while true do
        task.wait(60)
        silence:SetTitle("Silence | Fast Farming - " .. greeting())
    end
end)

local tabs = {
    rebirths = silence:AddTab("Rebirths"),
    strength = silence:AddTab("Strength"),
    strength2 = silence:AddTab("Strength (Slower)"),
    boss = silence:AddTab("Boss"),
    other = silence:AddTab("Other"),
    info = silence:AddTab("Info")
}

tabs.other:Show()

tabs.other.RedactConfigPath = "Silence/MuscleLegendsFarmingConfig.json"
tabs.other.RedactConfig = {
    RedactName = true,
    RedactStats = true,
}

tabs.other.loadRedactConfig = function()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
    pcall(function()
        if not isfile(tabs.other.RedactConfigPath) then return end
        local savedConfig = services.httpservice:JSONDecode(readfile(tabs.other.RedactConfigPath))
        if typeof(savedConfig) == "table" then
            tabs.other.RedactConfig.RedactName = savedConfig.RedactName == true
            tabs.other.RedactConfig.RedactStats = savedConfig.RedactStats == true
        end
    end)
end

tabs.other.saveRedactConfig = function()
    if type(writefile) ~= "function" then return end
    pcall(function()
        if type(makefolder) == "function"
            and (type(isfolder) ~= "function" or not isfolder("Silence")) then
            pcall(makefolder, "Silence")
        end
        writefile(tabs.other.RedactConfigPath, services.httpservice:JSONEncode(tabs.other.RedactConfig))
    end)
end

tabs.other.applyNameVisibility = function()
    pcall(function()
        workspace.HenneZocktTV.Head.nameGui.Enabled = not tabs.other.RedactConfig.RedactName
    end)
end

tabs.other.applyStatsVisibility = function()
    pcall(function()
        lp.player.PlayerGui.gameGui.hudNewMenu.Top.InfoSlots.Visible = not tabs.other.RedactConfig.RedactStats
    end)
    pcall(function() services.startergui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not tabs.other.RedactConfig.RedactStats) end)
end

tabs.other.loadRedactConfig()

function formatNumber(num)
    if num >= 1e18 then return string.format("%.2fQi", num/1e18) end
    if num >= 1e15 then return string.format("%.2fQa", num/1e15) end
    if num >= 1e12 then return string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return string.format("%.2fK", num/1e3) end
    return string.format("%.0f", num)
end

tabs.other.redactStats = tabs.other.RedactConfig.RedactStats

local function formatCurrentStat(value)
    return tabs.other.redactStats and "####" or formatNumber(value)
end

function formatPace(ratePerSecond)
    return formatNumber(ratePerSecond) .. "/s | "
        .. formatNumber(ratePerSecond * 60) .. "/min | "
        .. formatNumber(ratePerSecond * 3600) .. "/h | "
        .. formatNumber(ratePerSecond * 86400) .. "/d"
end

-- Right here comes my beautiful pet dictionary and its equip funcs

local PETS = {
    ["Omega Overlord"] = {
        repSpeed = 20,
        strength = 0,
        durability = 0,
        rebirth = 0,
    },

    ["Swift Samurai"] = {
        repSpeed = 15,
        strength = 0,
        durability = 0,
        rebirth = 0,
    },

    ["Powercore Hound"] = {
        repSpeed = 0,
        strength = 25,
        durability = 15,
        rebirth = 0,
    },

    ["Titanium Hydra"] = {
        repSpeed = 0,
        strength = 0,
        durability = 0,
        rebirth = 2,
    },

    ["Tribal Overlord"] = {
        repSpeed = 0,
        strength = 0,
        durability = 0,
        rebirth = 2,
    },
	["Inferno Unicorn"] = {
		repSpeed = 0,
		strength = 25,
		durability = 25,
		rebirth = 0,
	},
	["Common Boss Pet"] = {
		repSpeed = 5,
		strength = 0,
		durability = 0,
		rebirth = 0,
	},
	["Rare Boss Pet"] = {
		repSpeed = 7,
		strength = 0,
		durability = 0,
		rebirth = 0,
	},
	["Epic Boss Pet"] = {
		repSpeed = 10,
		strength = 0,
		durability = 0,
		rebirth = 0,
	},
	["Rainbow Boss Pet"] = {
		repSpeed = 10,
		strength = 7,
		durability = 0,
		rebirth = 0,
	},
	["Legendary Boss Pet"] = {
		repSpeed = 10,
		strength = 10,
		durability = 0,
		rebirth = 0,
	},
	["Mythic Boss Pet"] = {
		repSpeed = 10,
		strength = 20,
		durability = 0,
		rebirth = 0,
	},
    ["Inferno Drake"] = {
        repSpeed = 40,
        strength = 0,
        durability = 0,
        rebirth = 0,
    },
}

local MAX_PET_SLOTS = 12
local TARGET_REP_SPEED = 100

local function unequipConfiguredPets()
    for _, folder in ipairs(lp.player.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                services.replicatedstorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

local function equipConfiguredPet(pet)
    services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
end

local function getOwnedConfiguredPets()
    local ownedPets = {}

    for _, folder in ipairs(lp.player.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                local config = PETS[pet.Name]
                if config then
                    table.insert(ownedPets, {
                        instance = pet,
                        name = pet.Name,
                        repSpeed = config.repSpeed or 0,
                        strength = config.strength or 0,
                        durability = config.durability or 0,
                        rebirth = config.rebirth or 0,
                    })
                end
            end
        end
    end

    return ownedPets
end

local function equipBestFarmingPets(isCurrent)
    unequipConfiguredPets()
    if isCurrent and not isCurrent() then return end

    local pets = getOwnedConfiguredPets()
    local equipped = {}
    local equippedCount = 0
    local currentRepSpeed = 0

    table.sort(pets, function(a, b)
        return a.repSpeed > b.repSpeed
    end)

    for _, pet in ipairs(pets) do
        if equippedCount >= MAX_PET_SLOTS or currentRepSpeed >= TARGET_REP_SPEED then
            break
        end

        if pet.repSpeed > 0 then
            equipConfiguredPet(pet.instance)
            equipped[pet.instance] = true
            equippedCount = equippedCount + 1
            currentRepSpeed = currentRepSpeed + pet.repSpeed
        end
    end

    local remainingPets = {}

    for _, pet in ipairs(pets) do
        if not equipped[pet.instance] then
            table.insert(remainingPets, pet)
        end
    end

    table.sort(remainingPets, function(a, b)
        local scoreA = a.strength + a.durability
        local scoreB = b.strength + b.durability
        return scoreA > scoreB
    end)

    for _, pet in ipairs(remainingPets) do
        if equippedCount >= MAX_PET_SLOTS then
            break
        end

        if pet.strength > 0 or pet.durability > 0 then
            equipConfiguredPet(pet.instance)
            equipped[pet.instance] = true
            equippedCount = equippedCount + 1
        end
    end

    return currentRepSpeed, equippedCount
end

local function equipBestRebirthPets(isCurrent)
    unequipConfiguredPets()
    if isCurrent and not isCurrent() then return end

    local pets = getOwnedConfiguredPets()

    table.sort(pets, function(a, b)
        return a.rebirth > b.rebirth
    end)

    local equippedCount = 0
    local totalRebirthMultiplier = 0

    for _, pet in ipairs(pets) do
        if equippedCount >= MAX_PET_SLOTS then
            break
        end

        if pet.rebirth > 0 then
            equipConfiguredPet(pet.instance)
            equippedCount = equippedCount + 1
            totalRebirthMultiplier = totalRebirthMultiplier + pet.rebirth
        end
    end

    return totalRebirthMultiplier, equippedCount
end


-- Rebirth Tab

tabs.rebirths.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.rebirths.rebirths = tabs.rebirths.leaderstats:WaitForChild("Rebirths")
tabs.rebirths.strength = tabs.rebirths.leaderstats:WaitForChild("Strength")
tabs.rebirths.running = false
tabs.rebirths.workerActive = false
tabs.rebirths.startedAt = 0
tabs.rebirths.timerStarted = false
tabs.rebirths.hasStarted = false
tabs.rebirths.totalElapsed = 0
tabs.rebirths.startRebirths = tabs.rebirths.rebirths.Value
tabs.rebirths.gainedBaselineSet = false
tabs.rebirths.lastRebirthAt = tick()
tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
tabs.rebirths.paceBaselineReady = false
tabs.rebirths.petFolders = {}
tabs.rebirths.pets = {}
tabs.rebirths.uniquePets = {}
tabs.rebirths.omegas = {}
tabs.rebirths.swifts = {}
tabs.rebirths.hounds = {}
tabs.rebirths.hydras = {}
tabs.rebirths.tribals = {}
tabs.rebirths.folderIndex = 1
tabs.rebirths.petIndex = 1
tabs.rebirths.repIndex = 1
tabs.rebirths.equippedCount = 0
tabs.rebirths.currentPercent = 0
tabs.rebirths.maxSlots = 12
tabs.rebirths.strengthTarget = 0
tabs.rebirths.generation = 0
tabs.rebirths.adaptive = {
    TargetSeconds = 3,
    MinSeconds = 3,
    RepsPerAward = 5,
    MaxRate = 3295,
    SendRate = lp.player.MembershipType == Enum.MembershipType.Premium and 750 or 1500,
    StrengthPerAward = nil,
    LastTrainingSeconds = nil
}
tabs.rebirths.rebirthValueBefore = tabs.rebirths.rebirths.Value
tabs.rebirths.Status = tabs.rebirths:AddLabel("Status: Inactive")
tabs.rebirths.Runtime = tabs.rebirths:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.rebirths.RebirthStats = tabs.rebirths:AddLabel("Rebirths: " .. formatCurrentStat(tabs.rebirths.rebirths.Value) .. " | Gained: 0")
tabs.rebirths.Pace = tabs.rebirths:AddLabel("Pace: -- / Hour | -- / Day | -- / Week")
tabs.rebirths.AveragePace = tabs.rebirths:AddLabel("Average: -- / Hour | -- / Day | -- / Week")
tabs.rebirths.Status.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.rebirths.updateStats = function()
    tabs.rebirths.RebirthStats.Text = "Rebirths: " .. formatCurrentStat(tabs.rebirths.rebirths.Value)
        .. " | Gained: " .. formatNumber(tabs.rebirths.rebirths.Value - tabs.rebirths.startRebirths)
end

tabs.rebirths.updateRuntime = function()
    tabs.rebirths.elapsed = tabs.rebirths.totalElapsed
    if tabs.rebirths.running and tabs.rebirths.timerStarted then
        tabs.rebirths.elapsed = tabs.rebirths.elapsed + tick() - tabs.rebirths.startedAt
    end

    tabs.rebirths.Runtime.Text = string.format(
        "Runtime: %dd %dh %dm %ds",
        math.floor(tabs.rebirths.elapsed / 86400),
        math.floor((tabs.rebirths.elapsed % 86400) / 3600),
        math.floor((tabs.rebirths.elapsed % 3600) / 60),
        math.floor(tabs.rebirths.elapsed % 60)
    )
end

tabs.rebirths.updatePace = function()
    if not tabs.rebirths.running then
        return
    end

    if not tabs.rebirths.paceBaselineReady then
        tabs.rebirths.paceBaselineReady = true
        tabs.rebirths.timerStarted = true
        tabs.rebirths.startedAt = tick()
        tabs.rebirths.lastRebirthAt = tick()
        tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
        tabs.rebirths.averageStartedAt = tick()
        tabs.rebirths.averageStartRebirths = tabs.rebirths.rebirths.Value
        return
    end

    if tabs.rebirths.rebirths.Value <= tabs.rebirths.lastRebirthValue then
        return
    end

    tabs.rebirths.rebirthGain = tabs.rebirths.rebirths.Value - tabs.rebirths.lastRebirthValue
    tabs.rebirths.secondsPerRebirth = (tick() - tabs.rebirths.lastRebirthAt) / tabs.rebirths.rebirthGain
    tabs.rebirths.hourlyPace = 3600 / tabs.rebirths.secondsPerRebirth
    tabs.rebirths.dailyPace = 86400 / tabs.rebirths.secondsPerRebirth
    tabs.rebirths.weeklyPace = 604800 / tabs.rebirths.secondsPerRebirth

    tabs.rebirths.Pace.Text = string.format(
        "Pace: %s / Hour | %s / Day | %s / Week",
        formatNumber(tabs.rebirths.hourlyPace),
        formatNumber(tabs.rebirths.dailyPace),
        formatNumber(tabs.rebirths.weeklyPace)
    )

    tabs.rebirths.averageElapsed = tick() - tabs.rebirths.averageStartedAt
    tabs.rebirths.averageHourlyPace = (tabs.rebirths.rebirths.Value - tabs.rebirths.averageStartRebirths)
        / tabs.rebirths.averageElapsed * 3600

    tabs.rebirths.AveragePace.Text = string.format(
        "Average: %s / Hour | %s / Day | %s / Week",
        formatNumber(tabs.rebirths.averageHourlyPace),
        formatNumber(tabs.rebirths.averageHourlyPace * 24),
        formatNumber(tabs.rebirths.averageHourlyPace * 168)
    )

    tabs.rebirths.lastRebirthAt = tick()
    tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
end


tabs.rebirths.unequipAllPets = function()
    unequipConfiguredPets()
end

tabs.rebirths.isCurrent = function(generation)
    return tabs.rebirths.running and tabs.rebirths.generation == generation
end

tabs.rebirths.equipFarmingPets = function(generation)
    equipBestFarmingPets(function() return tabs.rebirths.isCurrent(generation) end)
end

tabs.rebirths.equipRebirthPets = function(generation)
    equipBestRebirthPets(function() return tabs.rebirths.isCurrent(generation) end)
end

tabs.rebirths.updateAdaptiveSpeed = function(cycle, now, elapsed, gain, sent, estimate, remainingSeconds, desiredRate)
    now = os.clock()
    elapsed = now - cycle.SampleAt
    if elapsed < 0.25 then return end
    gain = tabs.rebirths.strength.Value - cycle.SampleStrength
    sent = cycle.Sent - cycle.SampleSent
    if gain > 0 and sent >= tabs.rebirths.adaptive.RepsPerAward then
        estimate = gain * tabs.rebirths.adaptive.RepsPerAward / sent
        tabs.rebirths.adaptive.StrengthPerAward = tabs.rebirths.adaptive.StrengthPerAward
            and tabs.rebirths.adaptive.StrengthPerAward * 0.65 + estimate * 0.35 or estimate
        remainingSeconds = math.max(0.25, tabs.rebirths.adaptive.TargetSeconds - cycle.TrainingSeconds)
        desiredRate = math.max(0, cycle.Target - tabs.rebirths.strength.Value)
            / tabs.rebirths.adaptive.StrengthPerAward * tabs.rebirths.adaptive.RepsPerAward / remainingSeconds
        tabs.rebirths.adaptive.SendRate = math.clamp(desiredRate,
            math.max(1, tabs.rebirths.adaptive.SendRate * 0.5),
            math.min(tabs.rebirths.adaptive.MaxRate, tabs.rebirths.adaptive.SendRate * 2))
    elseif gain == 0 then
        return
    end
    cycle.SampleAt = now
    cycle.SampleStrength = tabs.rebirths.strength.Value
    cycle.SampleSent = cycle.Sent
end

tabs.rebirths.performRebirth = function(generation, cycle, now, character, humanoid, elapsed, estimate)
    cycle = {
        Target = 5000 + tabs.rebirths.rebirths.Value * 2550,
        Rebirths = tabs.rebirths.rebirths.Value,
        SampleAt = os.clock(),
        SampleStrength = tabs.rebirths.strength.Value,
        StartStrength = tabs.rebirths.strength.Value,
        SampleSent = 0,
        Sent = 0,
        Tokens = 0,
        LastAt = os.clock(),
        TrainingSeconds = 0
    }
    if tabs.rebirths.adaptive.StrengthPerAward then
        tabs.rebirths.adaptive.SendRate = math.clamp(
            math.max(0, cycle.Target - tabs.rebirths.strength.Value)
                / tabs.rebirths.adaptive.StrengthPerAward * tabs.rebirths.adaptive.RepsPerAward
                / tabs.rebirths.adaptive.TargetSeconds,
            1, tabs.rebirths.adaptive.MaxRate)
    end
    while tabs.rebirths.isCurrent(generation) and tabs.rebirths.rebirths.Value == cycle.Rebirths do
        now = os.clock()
        elapsed = math.max(0, now - cycle.LastAt)
        cycle.LastAt = now
        character = lp.player.Character
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            cycle.TrainingSeconds = cycle.TrainingSeconds + elapsed
            if tabs.rebirths.strength.Value >= cycle.Target then
                if not cycle.ReachedAt then cycle.ReachedAt = cycle.TrainingSeconds end
                if cycle.TrainingSeconds >= tabs.rebirths.adaptive.MinSeconds then break end
                cycle.Tokens = 0
            else
                tabs.rebirths.updateAdaptiveSpeed(cycle)
                cycle.Tokens = math.min(math.ceil(tabs.rebirths.adaptive.MaxRate * 0.1),
                    cycle.Tokens + tabs.rebirths.adaptive.SendRate * math.min(0.1, elapsed))
                while cycle.Tokens >= 1 and tabs.rebirths.isCurrent(generation)
                    and tabs.rebirths.strength.Value < cycle.Target do
                    services.muscleEvent:FireServer("rep")
                    cycle.Sent = cycle.Sent + 1
                    cycle.Tokens = cycle.Tokens - 1
                end
            end
            tabs.rebirths.Status.Text = "Status: Strength Training | " .. string.format("%.1fs", cycle.TrainingSeconds)
                .. " | " .. formatNumber(tabs.rebirths.adaptive.SendRate) .. " reps/s"
        else
            cycle.Tokens = 0
            cycle.SampleAt = now
            cycle.SampleStrength = tabs.rebirths.strength.Value
            cycle.SampleSent = cycle.Sent
            tabs.rebirths.Status.Text = "Status: Waiting for Respawn"
        end
        services.runservice.Heartbeat:Wait()
    end
    if not tabs.rebirths.isCurrent(generation) or tabs.rebirths.rebirths.Value ~= cycle.Rebirths then return end
    if tabs.rebirths.strength.Value < cycle.Target then return end
    if cycle.Sent > 0 and tabs.rebirths.strength.Value > cycle.StartStrength then
        estimate = (tabs.rebirths.strength.Value - cycle.StartStrength)
            * tabs.rebirths.adaptive.RepsPerAward / cycle.Sent
        tabs.rebirths.adaptive.StrengthPerAward = tabs.rebirths.adaptive.StrengthPerAward
            and tabs.rebirths.adaptive.StrengthPerAward * 0.5 + estimate * 0.5 or estimate
    end
    tabs.rebirths.adaptive.LastTrainingSeconds = cycle.ReachedAt or cycle.TrainingSeconds
    tabs.rebirths.adaptive.SendRate = math.clamp(tabs.rebirths.adaptive.SendRate
        * math.clamp(tabs.rebirths.adaptive.LastTrainingSeconds / tabs.rebirths.adaptive.TargetSeconds, 0.65, 1.35),
        1, tabs.rebirths.adaptive.MaxRate)
    tabs.rebirths.Status.Text = "Status: Switching to Rebirth Pets"
    tabs.rebirths.equipRebirthPets(generation)
    task.wait(0.25)
    while tabs.rebirths.isCurrent(generation) and tabs.rebirths.rebirths.Value == cycle.Rebirths do
        services.replicatedstorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
        task.wait(0.05)
    end
end

tabs.rebirths.startWorker = function()
    if tabs.rebirths.workerActive then return end
    tabs.rebirths.workerActive = true
    task.spawn(function(generation, success)
        success = pcall(function()
            while tabs.rebirths.isCurrent(generation) do
                tabs.rebirths.equipFarmingPets(generation)
                if not tabs.rebirths.isCurrent(generation) then break end
                tabs.rebirths.performRebirth(generation)
                task.wait(0.5)
            end
        end)
        tabs.rebirths.workerActive = false
        if not success then task.wait(0.5) end
        if tabs.rebirths.running then tabs.rebirths.startWorker() end
    end, tabs.rebirths.generation)
end

tabs.rebirths.rebirths:GetPropertyChangedSignal("Value"):Connect(function()
    tabs.rebirths.updatePace()
    tabs.rebirths.updateStats()
end)

tabs.rebirths.Switch = tabs.rebirths:AddSwitch("Pack Rebirth (Yes, Robux Packs)", function(state)
    tabs.rebirths.generation = tabs.rebirths.generation + 1
    tabs.rebirths.running = state
    if state then
        tabs.rebirths.hasStarted = true
        tabs.rebirths.startedAt = 0
        tabs.rebirths.timerStarted = false
        if not tabs.rebirths.gainedBaselineSet then
            tabs.rebirths.startRebirths = tabs.rebirths.rebirths.Value
            tabs.rebirths.gainedBaselineSet = true
        end
        tabs.rebirths.lastRebirthAt = tick()
        tabs.rebirths.lastRebirthValue = tabs.rebirths.rebirths.Value
        tabs.rebirths.paceBaselineReady = false
        tabs.rebirths.Status.Text = "Status: Rebirthing"
        tabs.rebirths.Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        tabs.rebirths.updateStats()
        tabs.rebirths.startWorker()
    else
        if tabs.rebirths.timerStarted and tabs.rebirths.startedAt > 0 then
            tabs.rebirths.totalElapsed = tabs.rebirths.totalElapsed + tick() - tabs.rebirths.startedAt
            tabs.rebirths.startedAt = 0
            tabs.rebirths.timerStarted = false
        end
        tabs.rebirths.Status.Text = tabs.rebirths.hasStarted and "Status: Paused" or "Status: Inactive"
        tabs.rebirths.Status.TextColor3 = tabs.rebirths.hasStarted and Color3.fromRGB(255, 180, 70) or Color3.fromRGB(255, 80, 80)
        tabs.rebirths.updateRuntime()
    end
end)
tabs.rebirths.Switch:Set(false)

task.spawn(function()
    while true do
        tabs.rebirths.updateRuntime()
        task.wait(1)
    end
end)

-- Strength Tab

tabs.strength.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.strength.strength = tabs.strength.leaderstats:WaitForChild("Strength")
tabs.strength.durability = lp.player:WaitForChild("Durability")
tabs.strength.running = false
tabs.strength.workerActive = false
tabs.strength.startedAt = 0
tabs.strength.totalElapsed = 0
tabs.strength.timerStarted = false
tabs.strength.gainedBaselineSet = false
tabs.strength.startStrength = tabs.strength.strength.Value
tabs.strength.startDurability = tabs.strength.durability.Value
tabs.strength.lastSampleAt = tick()
tabs.strength.lastStrength = tabs.strength.strength.Value
tabs.strength.lastDurability = tabs.strength.durability.Value
tabs.strength.paceBaselineReady = false
tabs.strength.calculationInterval = 10
tabs.strength.lastCalculationAt = tick()
tabs.strength.lastCalculatedStrength = tabs.strength.strength.Value
tabs.strength.lastCalculatedDurability = tabs.strength.durability.Value
tabs.strength.initialSendRate = 200
tabs.strength.maxSendRate = 659
tabs.strength.sendRate = tabs.strength.initialSendRate
tabs.strength.sendTokens = 0
tabs.strength.maxBurst = 24
tabs.strength.controlInterval = 0.5
tabs.strength.lastControlAt = tick()
tabs.strength.lastProgressAt = tick()
tabs.strength.lastControlStrength = tabs.strength.strength.Value
tabs.strength.lastControlDurability = tabs.strength.durability.Value
tabs.strength.stalledIntervals = 0
tabs.strength.lastLoopAt = os.clock()
tabs.strength.repIndex = 1
tabs.strength.Status = tabs.strength:AddLabel("Status: Inactive")
tabs.strength.Runtime = tabs.strength:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.strength.StrengthStats = tabs.strength:AddLabel("Strength: " .. formatCurrentStat(tabs.strength.strength.Value) .. " | Gained: 0")
tabs.strength.DurabilityStats = tabs.strength:AddLabel("Durability: " .. formatCurrentStat(tabs.strength.durability.Value) .. " | Gained: 0")
tabs.strength.StrengthPace = tabs.strength:AddLabel("Str Pace: --/s | --/min | --/h | --/d")
tabs.strength.DurabilityPace = tabs.strength:AddLabel("Dura Pace: --/s | --/min | --/h | --/d")
tabs.strength.StrengthAverage = tabs.strength:AddLabel("Str Ø: --/s | --/min | --/h | --/d")
tabs.strength.DurabilityAverage = tabs.strength:AddLabel("Dura Ø: --/s | --/min | --/h | --/d")
tabs.strength.Status.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.strength.updateRuntime = function()
    tabs.strength.elapsed = tabs.strength.totalElapsed
    if tabs.strength.running and tabs.strength.timerStarted then
        tabs.strength.elapsed = tabs.strength.elapsed + tick() - tabs.strength.startedAt
    end

    tabs.strength.Runtime.Text = string.format(
        "Runtime: %dd %dh %dm %ds",
        math.floor(tabs.strength.elapsed / 86400),
        math.floor((tabs.strength.elapsed % 86400) / 3600),
        math.floor((tabs.strength.elapsed % 3600) / 60),
        math.floor(tabs.strength.elapsed % 60)
    )
end

tabs.strength.updateStats = function()
    tabs.strength.StrengthStats.Text = "Strength: " .. formatCurrentStat(tabs.strength.strength.Value)
        .. " | Gained: " .. formatNumber(tabs.strength.strength.Value - tabs.strength.startStrength)
    tabs.strength.DurabilityStats.Text = "Durability: " .. formatCurrentStat(tabs.strength.durability.Value)
        .. " | Gained: " .. formatNumber(tabs.strength.durability.Value - tabs.strength.startDurability)
end

tabs.strength.updatePace = function()
    if not tabs.strength.running then
        return
    end

    if not tabs.strength.timerStarted then
        if tabs.strength.strength.Value == tabs.strength.startStrength and tabs.strength.durability.Value == tabs.strength.startDurability then
            return
        end

        tabs.strength.timerStarted = true
        tabs.strength.startedAt = tick()
        tabs.strength.lastSampleAt = tick()
        tabs.strength.lastStrength = tabs.strength.strength.Value
        tabs.strength.lastDurability = tabs.strength.durability.Value
        tabs.strength.lastCalculationAt = tick()
        tabs.strength.lastCalculatedStrength = tabs.strength.strength.Value
        tabs.strength.lastCalculatedDurability = tabs.strength.durability.Value
        return
    end

end

tabs.strength.calculatePace = function()
    if not tabs.strength.running or not tabs.strength.timerStarted then
        return
    end

    if tick() - tabs.strength.lastCalculationAt < tabs.strength.calculationInterval then
        return
    end

    tabs.strength.calculationElapsed = tick() - tabs.strength.lastCalculationAt
    tabs.strength.strengthDelta = tabs.strength.strength.Value - tabs.strength.lastCalculatedStrength
    tabs.strength.durabilityDelta = tabs.strength.durability.Value - tabs.strength.lastCalculatedDurability
    tabs.strength.strengthPacePerSecond = tabs.strength.strengthDelta / tabs.strength.calculationElapsed
    tabs.strength.durabilityPacePerSecond = tabs.strength.durabilityDelta / tabs.strength.calculationElapsed

    if tabs.strength.strengthDelta > 0 then
        tabs.strength.StrengthPace.Text = "Str Pace: " .. formatPace(tabs.strength.strengthPacePerSecond)
    end
    if tabs.strength.durabilityDelta > 0 then
        tabs.strength.DurabilityPace.Text = "Dura Pace: " .. formatPace(tabs.strength.durabilityPacePerSecond)
    end

    tabs.strength.averageElapsed = tabs.strength.totalElapsed + tick() - tabs.strength.startedAt
    tabs.strength.averageStrengthPerSecond = (tabs.strength.strength.Value - tabs.strength.startStrength)
        / tabs.strength.averageElapsed
    tabs.strength.averageDurabilityPerSecond = (tabs.strength.durability.Value - tabs.strength.startDurability)
        / tabs.strength.averageElapsed
    tabs.strength.StrengthAverage.Text = "Str Ø: " .. formatPace(tabs.strength.averageStrengthPerSecond)
    tabs.strength.DurabilityAverage.Text = "Dura Ø: " .. formatPace(tabs.strength.averageDurabilityPerSecond)

    tabs.strength.lastCalculationAt = tick()
    tabs.strength.lastCalculatedStrength = tabs.strength.strength.Value
    tabs.strength.lastCalculatedDurability = tabs.strength.durability.Value
end

tabs.strength.updateAdaptiveRate = function()
    tabs.strength.controlNow = tick()
    tabs.strength.controlElapsed = tabs.strength.controlNow - tabs.strength.lastControlAt
    if tabs.strength.controlElapsed < tabs.strength.controlInterval then
        return
    end

    tabs.strength.serverProgress = tabs.strength.strength.Value > tabs.strength.lastControlStrength
        or tabs.strength.durability.Value > tabs.strength.lastControlDurability

    if tabs.strength.serverProgress then
        tabs.strength.stalledIntervals = 0
        tabs.strength.lastProgressAt = tabs.strength.controlNow
        tabs.strength.sendRate = math.min(tabs.strength.maxSendRate, tabs.strength.sendRate * 1.12)
        tabs.strength.Status.Text = "Status: Farming | "
            .. formatNumber(tabs.strength.sendRate) .. " reps/s"
        tabs.strength.Status.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        tabs.strength.stalledIntervals = tabs.strength.stalledIntervals + 1
    end

    if tabs.strength.stalledIntervals >= 2 then
        tabs.strength.sendRate = math.max(tabs.strength.initialSendRate, tabs.strength.sendRate * 0.65)
        tabs.strength.sendTokens = 0
        tabs.strength.Status.Text = "Status: Slowing for server | "
            .. formatNumber(tabs.strength.sendRate) .. " reps/s"
        tabs.strength.Status.TextColor3 = Color3.fromRGB(255, 180, 70)
    end

    tabs.strength.lastControlAt = tabs.strength.controlNow
    tabs.strength.lastControlStrength = tabs.strength.strength.Value
    tabs.strength.lastControlDurability = tabs.strength.durability.Value
end

tabs.strength.workerLoop = function()
    tabs.strength.lastLoopAt = os.clock()
    while tabs.strength.running do
        tabs.strength.loopNow = os.clock()
        tabs.strength.loopElapsed = math.min(0.1, tabs.strength.loopNow - tabs.strength.lastLoopAt)
        tabs.strength.lastLoopAt = tabs.strength.loopNow

        tabs.strength.updateAdaptiveRate()
        tabs.strength.sendTokens = math.min(
            tabs.strength.maxBurst,
            tabs.strength.sendTokens + tabs.strength.sendRate * tabs.strength.loopElapsed
        )
        tabs.strength.burstLimit = math.max(
            1,
            math.min(tabs.strength.maxBurst, math.ceil(tabs.strength.sendRate * 0.05))
        )
        tabs.strength.sendCount = math.min(
            math.floor(tabs.strength.sendTokens),
            tabs.strength.burstLimit
        )
        tabs.strength.repIndex = 1
        while tabs.strength.repIndex <= tabs.strength.sendCount do
            services.muscleEvent:FireServer("rep")
            tabs.strength.repIndex = tabs.strength.repIndex + 1
        end
        tabs.strength.sendTokens = tabs.strength.sendTokens - tabs.strength.sendCount

        services.runservice.Heartbeat:Wait()
    end

    tabs.strength.workerActive = false
    if tabs.strength.running then
        tabs.strength.startWorker()
    end
end

tabs.strength.startWorker = function()
    if tabs.strength.workerActive then
        return
    end

    tabs.strength.workerActive = true
    task.spawn(tabs.strength.workerLoop)
end

tabs.strength.strength:GetPropertyChangedSignal("Value"):Connect(function()
    tabs.strength.updateStats()
    tabs.strength.updatePace()
end)

tabs.strength.durability:GetPropertyChangedSignal("Value"):Connect(function()
    tabs.strength.updateStats()
    tabs.strength.updatePace()
end)

tabs.strength:AddTextBox("Max reps/s: " .. tabs.strength.maxSendRate, function(inputText, value)
    value = tonumber(inputText)
    if not value or value ~= value or value == math.huge or value == -math.huge then return end
    tabs.strength.maxSendRate = math.max(1, value)
    tabs.strength.sendRate = math.min(tabs.strength.sendRate, tabs.strength.maxSendRate)
end, {clear = false})

tabs.strength:AddLabel("Recommended Speed: 659, more = lag")

tabs.strength.FastRepToggle = tabs.strength:AddSwitch("Fast Rep", function(state)
    tabs.strength.running = state
    if state then
        if not tabs.strength.gainedBaselineSet then
            tabs.strength.startStrength = tabs.strength.strength.Value
            tabs.strength.startDurability = tabs.strength.durability.Value
            tabs.strength.gainedBaselineSet = true
        end
        tabs.strength.timerStarted = false
        tabs.strength.startedAt = 0
        tabs.strength.lastSampleAt = tick()
        tabs.strength.lastStrength = tabs.strength.strength.Value
        tabs.strength.lastDurability = tabs.strength.durability.Value
        tabs.strength.paceBaselineReady = false
        tabs.strength.sendRate = tabs.strength.initialSendRate
        tabs.strength.sendTokens = 0
        tabs.strength.lastLoopAt = os.clock()
        tabs.strength.lastControlAt = tick()
        tabs.strength.lastProgressAt = tick()
        tabs.strength.lastControlStrength = tabs.strength.strength.Value
        tabs.strength.lastControlDurability = tabs.strength.durability.Value
        tabs.strength.stalledIntervals = 0
        tabs.strength.Status.Text = "Status: Farming | 200 reps/s"
        tabs.strength.Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        tabs.strength.startWorker()
    else
        if tabs.strength.timerStarted and tabs.strength.startedAt > 0 then
            tabs.strength.totalElapsed = tabs.strength.totalElapsed + tick() - tabs.strength.startedAt
            tabs.strength.startedAt = 0
            tabs.strength.timerStarted = false
        end
        tabs.strength.sendTokens = 0
        tabs.strength.Status.Text = tabs.strength.gainedBaselineSet and "Status: Paused" or "Status: Inactive"
        tabs.strength.Status.TextColor3 = tabs.strength.gainedBaselineSet and Color3.fromRGB(255, 180, 70) or Color3.fromRGB(255, 80, 80)
        tabs.strength.updateRuntime()
    end
end)

tabs.strength.FastRepToggle:Set(false)

task.spawn(function()
    while true do
        tabs.strength.updateRuntime()
        tabs.strength.calculatePace()
        task.wait(1)
    end
end)

tabs.strength:AddLabel("Reaching Average Speed takes some time!")

-- Strength Tab (For bad devices)

tabs.strength2.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.strength2.strength = tabs.strength2.leaderstats:WaitForChild("Strength")
tabs.strength2.durability = lp.player:WaitForChild("Durability")
tabs.strength2.running = false
tabs.strength2.workerActive = false
tabs.strength2.startedAt = 0
tabs.strength2.totalElapsed = 0
tabs.strength2.timerStarted = false
tabs.strength2.gainedBaselineSet = false
tabs.strength2.startStrength = tabs.strength2.strength.Value
tabs.strength2.startDurability = tabs.strength2.durability.Value
tabs.strength2.calculationInterval = 10
tabs.strength2.lastCalculationAt = tick()
tabs.strength2.lastCalculatedStrength = tabs.strength2.strength.Value
tabs.strength2.lastCalculatedDurability = tabs.strength2.durability.Value
tabs.strength2.repSpeed = 350
tabs.strength2.pingControl = true
tabs.strength2.currentPing = 0
tabs.strength2.Status = tabs.strength2:AddLabel("Status: Inactive")
tabs.strength2.Runtime = tabs.strength2:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.strength2.StrengthStats = tabs.strength2:AddLabel("Strength: " .. formatCurrentStat(tabs.strength2.strength.Value) .. " | Gained: 0")
tabs.strength2.DurabilityStats = tabs.strength2:AddLabel("Durability: " .. formatCurrentStat(tabs.strength2.durability.Value) .. " | Gained: 0")
tabs.strength2.StrengthPace = tabs.strength2:AddLabel("Str Pace: --/s | --/min | --/h | --/d")
tabs.strength2.DurabilityPace = tabs.strength2:AddLabel("Dura Pace: --/s | --/min | --/h | --/d")
tabs.strength2.StrengthAverage = tabs.strength2:AddLabel("Str Ø: --/s | --/min | --/h | --/d")
tabs.strength2.DurabilityAverage = tabs.strength2:AddLabel("Dura Ø: --/s | --/min | --/h | --/d")
tabs.strength2.Status.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.strength2.updateRuntime = function()
    tabs.strength2.elapsed = tabs.strength2.totalElapsed
    if tabs.strength2.running and tabs.strength2.timerStarted then
        tabs.strength2.elapsed = tabs.strength2.elapsed + tick() - tabs.strength2.startedAt
    end

    tabs.strength2.Runtime.Text = string.format(
        "Runtime: %dd %dh %dm %ds",
        math.floor(tabs.strength2.elapsed / 86400),
        math.floor((tabs.strength2.elapsed % 86400) / 3600),
        math.floor((tabs.strength2.elapsed % 3600) / 60),
        math.floor(tabs.strength2.elapsed % 60)
    )
end

tabs.strength2.updateStats = function()
    tabs.strength2.StrengthStats.Text = "Strength: " .. formatCurrentStat(tabs.strength2.strength.Value)
        .. " | Gained: " .. formatNumber(tabs.strength2.strength.Value - tabs.strength2.startStrength)
    tabs.strength2.DurabilityStats.Text = "Durability: " .. formatCurrentStat(tabs.strength2.durability.Value)
        .. " | Gained: " .. formatNumber(tabs.strength2.durability.Value - tabs.strength2.startDurability)
end

tabs.strength2.updatePace = function()
    if not tabs.strength2.running or tabs.strength2.timerStarted then
        return
    end
    if tabs.strength2.strength.Value == tabs.strength2.startStrength
        and tabs.strength2.durability.Value == tabs.strength2.startDurability then
        return
    end

    tabs.strength2.timerStarted = true
    tabs.strength2.startedAt = tick()
    tabs.strength2.lastCalculationAt = tick()
    tabs.strength2.lastCalculatedStrength = tabs.strength2.strength.Value
    tabs.strength2.lastCalculatedDurability = tabs.strength2.durability.Value
end

tabs.strength2.calculatePace = function()
    if not tabs.strength2.running or not tabs.strength2.timerStarted then
        return
    end

    tabs.strength2.calculationElapsed = tick() - tabs.strength2.lastCalculationAt
    if tabs.strength2.calculationElapsed < tabs.strength2.calculationInterval then
        return
    end

    tabs.strength2.strengthDelta = tabs.strength2.strength.Value - tabs.strength2.lastCalculatedStrength
    tabs.strength2.durabilityDelta = tabs.strength2.durability.Value - tabs.strength2.lastCalculatedDurability
    tabs.strength2.strengthPacePerSecond = tabs.strength2.strengthDelta / tabs.strength2.calculationElapsed
    tabs.strength2.durabilityPacePerSecond = tabs.strength2.durabilityDelta / tabs.strength2.calculationElapsed

    if tabs.strength2.strengthDelta > 0 then
        tabs.strength2.StrengthPace.Text = "Str Pace: " .. formatPace(tabs.strength2.strengthPacePerSecond)
    end
    if tabs.strength2.durabilityDelta > 0 then
        tabs.strength2.DurabilityPace.Text = "Dura Pace: " .. formatPace(tabs.strength2.durabilityPacePerSecond)
    end

    tabs.strength2.averageElapsed = tabs.strength2.totalElapsed + tick() - tabs.strength2.startedAt
    if tabs.strength2.averageElapsed > 0 then
        tabs.strength2.averageStrengthPerSecond = (tabs.strength2.strength.Value - tabs.strength2.startStrength)
            / tabs.strength2.averageElapsed
        tabs.strength2.averageDurabilityPerSecond = (tabs.strength2.durability.Value - tabs.strength2.startDurability)
            / tabs.strength2.averageElapsed
        tabs.strength2.StrengthAverage.Text = "Str Ø: " .. formatPace(tabs.strength2.averageStrengthPerSecond)
        tabs.strength2.DurabilityAverage.Text = "Dura Ø: " .. formatPace(tabs.strength2.averageDurabilityPerSecond)
    end

    tabs.strength2.lastCalculationAt = tick()
    tabs.strength2.lastCalculatedStrength = tabs.strength2.strength.Value
    tabs.strength2.lastCalculatedDurability = tabs.strength2.durability.Value
end

tabs.strength2.networkStats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]

tabs.strength2.getCurrentPing = function()
    return tabs.strength2.networkStats:GetValue()
end

tabs.strength2.getAdaptiveSpeed = function(ping)
    if ping < 80 then
        return 500
    elseif ping < 150 then
        return 300
    elseif ping < 250 then
        return 100
    end
    return 50
end

tabs.strength2.workerLoop = function()
    tabs.strength2.lastPingUpdate = time()
    tabs.strength2.currentPing = tabs.strength2.getCurrentPing()

    while tabs.strength2.running do
        if time() - tabs.strength2.lastPingUpdate > 0.5 then
            tabs.strength2.currentPing = tabs.strength2.getCurrentPing()
            tabs.strength2.lastPingUpdate = time()
        end

        tabs.strength2.repsToFire = tabs.strength2.pingControl
            and tabs.strength2.getAdaptiveSpeed(tabs.strength2.currentPing)
            or tabs.strength2.repSpeed
        tabs.strength2.repsToFire = math.min(tabs.strength2.repsToFire, tabs.strength2.repSpeed)
        tabs.strength2.delayBetweenBatches = math.clamp(tabs.strength2.currentPing / 2500, 0.001, 0.1)

        tabs.strength2.Status.Text = "Status: Farming | " .. formatNumber(tabs.strength2.repsToFire)
            .. " reps/batch | " .. formatNumber(tabs.strength2.currentPing) .. " ms"
        tabs.strength2.Status.TextColor3 = Color3.fromRGB(80, 255, 120)

        for repCount = 1, tabs.strength2.repsToFire do
            if not tabs.strength2.running then
                break
            end
            services.muscleEvent:FireServer("rep")
            if repCount % 500 == 0 then
                task.wait()
            end
        end
        task.wait(tabs.strength2.delayBetweenBatches)
    end

    tabs.strength2.workerActive = false
    if tabs.strength2.running then
        tabs.strength2.startWorker()
    end
end

tabs.strength2.startWorker = function()
    if tabs.strength2.workerActive then
        return
    end
    tabs.strength2.workerActive = true
    task.spawn(tabs.strength2.workerLoop)
end

tabs.strength2.strength:GetPropertyChangedSignal("Value"):Connect(function()
    tabs.strength2.updateStats()
    tabs.strength2.updatePace()
end)

tabs.strength2.durability:GetPropertyChangedSignal("Value"):Connect(function()
    tabs.strength2.updateStats()
    tabs.strength2.updatePace()
end)

tabs.strength2:AddTextBox("Rep Speed:", function(inputText)
    tabs.strength2.speedValue = tonumber(inputText)
    if tabs.strength2.speedValue then
        tabs.strength2.repSpeed = math.clamp(math.floor(tabs.strength2.speedValue), 1, 1000)
    end
end)

tabs.strength2:AddSwitch("Controlled Speed", function(state)
    tabs.strength2.pingControl = state
end):Set(true)

tabs.strength2.FastRepToggle = tabs.strength2:AddSwitch("Fast Rep", function(state)
    tabs.strength2.running = state
    if state then
        if not tabs.strength2.gainedBaselineSet then
            tabs.strength2.startStrength = tabs.strength2.strength.Value
            tabs.strength2.startDurability = tabs.strength2.durability.Value
            tabs.strength2.gainedBaselineSet = true
        end
        tabs.strength2.timerStarted = false
        tabs.strength2.startedAt = 0
        tabs.strength2.lastCalculationAt = tick()
        tabs.strength2.lastCalculatedStrength = tabs.strength2.strength.Value
        tabs.strength2.lastCalculatedDurability = tabs.strength2.durability.Value
        tabs.strength2.Status.Text = "Status: Starting..."
        tabs.strength2.Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        tabs.strength2.startWorker()
    else
        if tabs.strength2.timerStarted and tabs.strength2.startedAt > 0 then
            tabs.strength2.totalElapsed = tabs.strength2.totalElapsed + tick() - tabs.strength2.startedAt
            tabs.strength2.startedAt = 0
            tabs.strength2.timerStarted = false
        end
        tabs.strength2.Status.Text = tabs.strength2.gainedBaselineSet and "Status: Paused" or "Status: Inactive"
        tabs.strength2.Status.TextColor3 = tabs.strength2.gainedBaselineSet
            and Color3.fromRGB(255, 180, 70)
            or Color3.fromRGB(255, 80, 80)
        tabs.strength2.updateRuntime()
    end
end)

tabs.strength2.FastRepToggle:Set(false)

task.spawn(function()
    while true do
        tabs.strength2.updateRuntime()
        tabs.strength2.calculatePace()
        task.wait(1)
    end
end)
tabs.strength2:AddLabel("This Farm is for low end devices, It will be slower then the other one")
tabs.strength2:AddLabel("For me, 20-40 works the best. Try around!")

tabs.boss.runtime = {}

tabs.boss:AddLabel("Boss Farming:")
tabs.boss.StatusLabel = tabs.boss:AddLabel("Status: Waiting for Boss")
tabs.boss.BossLabel = tabs.boss:AddLabel("Boss: None")
tabs.boss.HealthLabel = tabs.boss:AddLabel("Health: 0 / 0")
tabs.boss.NextBossLabel = tabs.boss:AddLabel("Next Boss: N/A")

tabs.boss.Data = {
	Running = false,
	Generation = 0,
	ContinueTraining = true,
	Phase = "Waiting",
	MachineCooldownUntil = 0,
	TrainingSnapshot = nil,
	TrainingRestore = nil,
	TrainingResumeGeneration = 0,
	PreparationSeconds = 4,
	PunchInterval = 0.3,
	LastPunch = 0,
	AttackSequence = nil,
	EvadeUntil = 0,
	EvadeDistance = 230,
	PunchBehindDistance = 45,
	StompHealthThreshold = 0.35,
	DodgeStomps = false,
	BossConfig = nil,
	Bosses = {},
	BossOrder = {},
	BossByDisplayName = {},
	SelectedBosses = {}
}

tabs.boss:AddTextBox("Seconds Training before Boss (when Rebirthing):", function(text)
	if tonumber(text) and tonumber(text) >= 0 then tabs.boss.Data.PreparationSeconds = tonumber(text) end
end, {clear = false})

tabs.boss.SelectedBossesLabel = tabs.boss:AddLabel("Targeted Bosses: Detecting...")
tabs.boss.BossDropdown = tabs.boss:AddDropdown("Target specific Bosses", function(displayName)
	tabs.boss.runtime.bossModelName = tabs.boss.Data.BossByDisplayName[displayName]
	if tabs.boss.runtime.bossModelName then
		tabs.boss.Data.SelectedBosses[tabs.boss.runtime.bossModelName] = not tabs.boss.Data.SelectedBosses[tabs.boss.runtime.bossModelName]
		tabs.boss.updateSelectedBossesLabel()
	end
end)

tabs.boss.updateSelectedBossesLabel = function(selectedNames)
	selectedNames = {}
	for _, modelName in ipairs(tabs.boss.Data.BossOrder) do
		if tabs.boss.Data.SelectedBosses[modelName] then
			table.insert(selectedNames, (string.gsub(tabs.boss.Data.Bosses[modelName], "%s+[Bb][Oo][Ss][Ss]$", "")))
		end
	end
	tabs.boss.SelectedBossesLabel.Text = "Targeted Bosses: " .. (#selectedNames > 0 and table.concat(selectedNames, ", ") or "None")
end

tabs.boss.addBossChoice = function(modelName, displayName)
	modelName = tostring(modelName or "")
	displayName = tostring(displayName or modelName)
	if modelName == "" or tabs.boss.Data.Bosses[modelName] then return end
	tabs.boss.Data.Bosses[modelName] = displayName
	tabs.boss.Data.BossByDisplayName[displayName] = modelName
	tabs.boss.Data.SelectedBosses[modelName] = true
	table.insert(tabs.boss.Data.BossOrder, modelName)
	tabs.boss.BossDropdown:Add(displayName)
	tabs.boss.updateSelectedBossesLabel()
end

tabs.boss.runtime.configSuccess, tabs.boss.Data.BossConfig = pcall(function()
	return require(services.replicatedstorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("BossEventConfig"))
end)
if tabs.boss.runtime.configSuccess and tabs.boss.Data.BossConfig and tabs.boss.Data.BossConfig.RARITIES then
	for _, rarity in ipairs(tabs.boss.Data.BossConfig.RARITIES) do
		tabs.boss.addBossChoice(rarity.BossModel, rarity.DisplayName or rarity.Name or rarity.BossModel)
	end
else
	tabs.boss.SelectedBossesLabel.Text = "Farmed Bosses: Waiting for detection"
end

tabs.boss.shouldFarmBoss = function(model)
	if not tabs.boss.Data.Bosses[model.Name] then
		tabs.boss.addBossChoice(model.Name, workspace:GetAttribute("BossDisplayName") or model.Name)
	end
	return tabs.boss.Data.SelectedBosses[model.Name] == true
end

tabs.boss.findActiveBoss = function(model, stats, health, maxHealth, hitbox)
	for _, candidate in ipairs(services.collectionservice:GetTagged("BossEventBoss")) do
		if candidate:IsA("Model") and candidate:IsDescendantOf(workspace) then
			model = candidate
			break
		end
	end

	if not model then
		tabs.boss.runtime.events = workspace:FindFirstChild("Events")
		tabs.boss.runtime.bossFolder = tabs.boss.runtime.events and (tabs.boss.runtime.events:FindFirstChild("BossEvent") or tabs.boss.runtime.events:FindFirstChild("BossArena"))
		if tabs.boss.runtime.bossFolder then
			for _, candidate in ipairs(tabs.boss.runtime.bossFolder:GetDescendants()) do
				if candidate:IsA("Model") and (candidate:FindFirstChild("BossDamageHitbox") or candidate:HasTag("BossEventBoss")) then
					model = candidate
					break
				end
			end
		end
	end

	if not model then return end
	stats = model:FindFirstChild("stats")
	health = stats and stats:FindFirstChild("Health")
	maxHealth = stats and stats:FindFirstChild("MaxHealth")
	hitbox = model:FindFirstChild("BossDamageHitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then return end
	tabs.boss.runtime.currentHealth = health and health.Value or workspace:GetAttribute("BossHealth")
	if typeof(tabs.boss.runtime.currentHealth) == "number" and tabs.boss.runtime.currentHealth <= 0 then return end
	return model, health, maxHealth, hitbox
end

tabs.boss.getBossDisplayName = function(model)
	return workspace:GetAttribute("BossDisplayName") or model.Name
end

tabs.boss.getBossHealth = function(health)
	return health and health.Value or workspace:GetAttribute("BossHealth") or 0
end

tabs.boss.getBossMaxHealth = function(maxHealth)
	return maxHealth and maxHealth.Value or workspace:GetAttribute("BossMaxHealth") or 0
end

tabs.boss.formatCountdown = function(seconds, hours, minutes)
	seconds = math.max(0, math.floor(seconds or 0))
	hours = math.floor(seconds / 3600)
	minutes = math.floor(seconds % 3600 / 60)
	seconds = seconds % 60
	return string.format("%dh %dmin %ds", hours, minutes, seconds)
end

tabs.boss.getTrainingMachine = function(character, root, seat, machines, best, bestDistance, distance, part)
	character = lp.player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	seat = character and character:FindFirstChildOfClass("Humanoid")
	seat = seat and seat.SeatPart
	machines = workspace:FindFirstChild("machinesFolder")
	if not root or not machines then return end
	bestDistance = 35
	for _, machine in ipairs(machines:GetChildren()) do
		if seat and seat:IsDescendantOf(machine) then return machine, seat end
		part = tabs.boss.getMachineInteractPart(machine)
		if part then
			distance = (part.Position - root.Position).Magnitude
			if distance < bestDistance then best, bestDistance = machine, distance end
		end
	end
	return best, nil
end

tabs.boss.getMachineInteractPart = function(machine)
	for _, descendant in ipairs(machine:GetDescendants()) do
		if descendant:IsA("BasePart") and string.lower(descendant.Name) == "interactseat" then return descendant end
	end
end

tabs.boss.leaveExerciseMachine = function(character, humanoid, root)
	character = lp.player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 then return end
	pcall(function()
		services.virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		humanoid.Sit = false
		humanoid.Jump = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		if root then root.AssemblyLinearVelocity = Vector3.new(0, math.max(root.AssemblyLinearVelocity.Y, 50), 0) end
	end)
	pcall(function() services.virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
	tabs.boss.Data.MachineCooldownUntil = math.max(tabs.boss.Data.MachineCooldownUntil, os.clock() + 4)
	task.wait(0.2)
end

tabs.boss.captureTraining = function(character, root)
	tabs.boss.Data.TrainingResumeGeneration = tabs.boss.Data.TrainingResumeGeneration + 1
	if tabs.boss.Data.TrainingSnapshot then return end
	if tabs.boss.Data.TrainingRestore then
		tabs.boss.Data.TrainingSnapshot = tabs.boss.Data.TrainingRestore
		tabs.boss.Data.TrainingRestore = nil
		return
	end
	character = lp.player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	tabs.boss.Data.TrainingSnapshot = {
		Rebirth = tabs.rebirths.running,
		Strength = tabs.strength.running,
		Strength2 = tabs.strength2.running,
		Position = root and root.CFrame,
		Tool = character and character:FindFirstChildOfClass("Tool"),
		Character = character
	}
	tabs.boss.Data.TrainingSnapshot.Machine, tabs.boss.Data.TrainingSnapshot.SeatPart = tabs.boss.getTrainingMachine()
end

tabs.boss.pauseTraining = function()
	tabs.boss.captureTraining()
	if tabs.rebirths.running then tabs.rebirths.Switch:Set(false) end
	if tabs.strength.running then tabs.strength.FastRepToggle:Set(false) end
	if tabs.strength2.running then tabs.strength2.FastRepToggle:Set(false) end
end

tabs.boss.hasTrainingStats = function(strength, durability)
	strength = tabs.rebirths.strength
	durability = lp.player:FindFirstChild("Durability")
	return strength and durability and strength.Value > 0 and durability.Value > 0
end

tabs.boss.prepareForBoss = function(boss, preparation, character, humanoid, tool, backpack, toolName)
	if not boss.Data.Preparation then
		tabs.boss.pauseTraining()
		boss.Data.Preparation = {LastRep = 0}
		boss.Data.Phase = "Training"
	end
	preparation = boss.Data.Preparation
	if tabs.rebirths.workerActive or tabs.strength.workerActive or tabs.strength2.workerActive then
		boss.StatusLabel.Text = "Status: Waiting for Farming to Pause"
		return false
	end
	character = lp.player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if preparation.Character ~= character or preparation.Rebirths ~= tabs.rebirths.rebirths.Value then
		preparation.Character = character
		preparation.Rebirths = tabs.rebirths.rebirths.Value
		preparation.StartedAt = nil
		preparation.Detached = false
		preparation.PetsReady = nil
		preparation.LastRep = 0
		preparation.Required = not tabs.boss.hasTrainingStats()
	end
	if not humanoid or humanoid.Health <= 0 then
		preparation.StartedAt = nil
		boss.StatusLabel.Text = "Status: Waiting for Respawn"
		return false
	end
	if not preparation.Detached then
		preparation.Detached = true
		if tabs.boss.Data.TrainingSnapshot.Machine or humanoid.SeatPart then tabs.boss.leaveExerciseMachine() end
		if not boss.Data.Running then return false end
	end
	if not preparation.Required then
		boss.Data.FightCharacter = character
		boss.Data.FightRebirths = tabs.rebirths.rebirths.Value
		boss.Data.Preparation = nil
		return true
	end
	if not preparation.PetsReady then
		equipBestFarmingPets(function() return boss.Data.Running and boss.Data.Preparation == preparation end)
		if not boss.Data.Running or boss.Data.Preparation ~= preparation then return false end
		preparation.PetsReady = true
	end
	if lp.player.Character ~= character or humanoid.Health <= 0 then return false end
	backpack = lp.player:FindFirstChild("Backpack")
	toolName = tabs.rebirths.strength.Value < 2000 and "Weight" or "Pushups"
	if toolName == "Weight" then preparation.StartedAt = nil end
	tool = character:FindFirstChild(toolName) or backpack and backpack:FindFirstChild(toolName)
	if not tool then
		preparation.StartedAt = nil
		boss.StatusLabel.Text = "Status: Waiting for " .. toolName
		return false
	end
	if tool.Parent ~= character then humanoid:EquipTool(tool) end
	if tool.Parent ~= character then preparation.StartedAt = nil return false end
	if toolName == "Pushups" then preparation.StartedAt = preparation.StartedAt or os.clock() end
	if os.clock() - preparation.LastRep >= 0.1 then
		services.muscleEvent:FireServer("rep")
		preparation.LastRep = os.clock()
	end
	if toolName == "Weight" then
		boss.StatusLabel.Text = "Status: Weight Training | " .. formatCurrentStat(tabs.rebirths.strength.Value) .. " / 2K Strength"
		return false
	end
	boss.StatusLabel.Text = "Status: Training before Boss (" .. string.format("%.1f", math.max(0, tabs.boss.Data.PreparationSeconds - (os.clock() - preparation.StartedAt))) .. "s)"
	if os.clock() - preparation.StartedAt < tabs.boss.Data.PreparationSeconds then return false end
	boss.Data.FightCharacter = character
	boss.Data.FightRebirths = tabs.rebirths.rebirths.Value
	boss.Data.Preparation = nil
	return true
end

tabs.boss.needsRetraining = function(boss, character, humanoid)
	character = lp.player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return not humanoid or humanoid.Health <= 0 or boss.Data.FightCharacter ~= character
		or boss.Data.FightRebirths ~= tabs.rebirths.rebirths.Value
end

tabs.boss.restoreMachine = function(snapshot, generation, character, humanoid, root, part, tool, backpack)
	if tabs.boss.Data.TrainingResumeGeneration ~= generation then return false end
	character = lp.player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid or humanoid.Health <= 0 then return false end
	humanoid:UnequipTools()
	if snapshot.Machine then
		if not snapshot.Machine.Parent then return false end
		part = tabs.boss.getMachineInteractPart(snapshot.Machine)
		if not part or os.clock() < tabs.boss.Data.MachineCooldownUntil then return false end
		root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait(0.4)
		if tabs.boss.Data.TrainingResumeGeneration ~= generation or lp.player.Character ~= character or humanoid.Health <= 0 then return false end
		services.virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait(0.1)
		services.virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		task.wait(0.4)
		if tabs.boss.Data.TrainingResumeGeneration ~= generation or lp.player.Character ~= character or humanoid.Health <= 0 then return false end
		if snapshot.SeatPart and (not humanoid.SeatPart or not humanoid.SeatPart:IsDescendantOf(snapshot.Machine)) then return false end
	elseif snapshot.Position then
		root.CFrame = snapshot.Position
		root.AssemblyLinearVelocity = Vector3.zero
	end
	backpack = lp.player:FindFirstChild("Backpack")
	tool = snapshot.Tool and (snapshot.Tool.Parent and snapshot.Tool or backpack and backpack:FindFirstChild(snapshot.Tool.Name))
	if tool then humanoid:EquipTool(tool) end
	return true
end

tabs.boss.resumeTraining = function(snapshot)
	snapshot = tabs.boss.Data.TrainingSnapshot
	if not snapshot then return end
	tabs.boss.Data.TrainingSnapshot = nil
	tabs.boss.Data.TrainingRestore = snapshot
	tabs.boss.Data.TrainingResumeGeneration = tabs.boss.Data.TrainingResumeGeneration + 1
	task.spawn(function(generation)
		while tabs.boss.Data.TrainingResumeGeneration == generation do
			if tabs.boss.restoreMachine(snapshot, generation) then
				if tabs.boss.Data.TrainingResumeGeneration ~= generation then return end
				tabs.boss.Data.TrainingRestore = nil
				if snapshot.Strength then tabs.strength.FastRepToggle:Set(true) end
				if snapshot.Strength2 then tabs.strength2.FastRepToggle:Set(true) end
				if snapshot.Rebirth then tabs.rebirths.Switch:Set(true) end
				return
			end
			task.wait(0.1)
		end
	end, tabs.boss.Data.TrainingResumeGeneration)
end

tabs.boss.getBossHeadPosition = function(model, hitbox, head)
	head = model:FindFirstChild("Head", true) or model:FindFirstChild("head", true)
	if head and head:IsA("BasePart") then return head.Position end
	if head and head:IsA("Bone") then return head.WorldPosition end
	return hitbox.Position + Vector3.new(0, hitbox.Size.Y * 0.35, 0)
end

tabs.boss.getAliveCharacter = function(generation, timeout, startedAt, character, root, humanoid)
	if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
	startedAt = os.clock()
	repeat
		character = lp.player.Character
		root = character and character:FindFirstChild("HumanoidRootPart")
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			return character, root, humanoid
		end
		tabs.boss.StatusLabel.Text = "Status: Waiting for Respawn"
		task.wait(0.1)
	until not tabs.boss.Data.Running
		or tabs.boss.Data.Generation ~= generation
		or (timeout and os.clock() - startedAt >= timeout)
end

tabs.boss.evadeAttack = function(boss, model, hitbox, root, humanoid, sequence, attackKind, attackCFrame, impactTime, direction, safePosition, center)
	sequence = model:GetAttribute("BossAttackSequence")
	attackKind = model:GetAttribute("BossAttackKind")
	attackCFrame = model:GetAttribute("BossAttackCFrame")
	impactTime = model:GetAttribute("BossAttackImpactTime")

	if typeof(sequence) == "number" and sequence ~= boss.Data.AttackSequence then
		boss.Data.AttackSequence = sequence
		if typeof(attackKind) == "string" and typeof(attackCFrame) == "CFrame" and typeof(impactTime) == "number" then
			boss.Data.EvadeUntil = impactTime + 0.6
		end
	end

	if typeof(attackCFrame) ~= "CFrame" or workspace:GetServerTimeNow() > boss.Data.EvadeUntil then
		return
	end

	attackKind = string.lower(tostring(attackKind or ""))
	if string.find(attackKind, "punch", 1, true) then
		center = tabs.boss.getBossHeadPosition(model, hitbox)
		direction = Vector3.new(attackCFrame.LookVector.X, 0, attackCFrame.LookVector.Z)
		if direction.Magnitude < 1 then direction = Vector3.new(hitbox.CFrame.LookVector.X, 0, hitbox.CFrame.LookVector.Z) end
		if direction.Magnitude < 1 then direction = Vector3.new(0, 0, 1) end
		safePosition = center - direction.Unit * boss.Data.PunchBehindDistance
		root.CFrame = CFrame.lookAt(safePosition, center)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		boss.StatusLabel.Text = "Status: Dodging Punch"
		return "Punch"
	end

	if not string.find(attackKind, "stomp", 1, true) then return end
	if humanoid.Health / math.max(humanoid.MaxHealth, 1) <= boss.Data.StompHealthThreshold then
		boss.Data.DodgeStomps = true
	end
	if not boss.Data.DodgeStomps then return end

	direction = Vector3.new(root.Position.X - attackCFrame.Position.X, 0, root.Position.Z - attackCFrame.Position.Z)
	if direction.Magnitude < 1 then
		direction = Vector3.new(-attackCFrame.LookVector.X, 0, -attackCFrame.LookVector.Z)
	end
	if direction.Magnitude < 1 then direction = Vector3.new(1, 0, 0) end
	direction = direction.Unit
	safePosition = attackCFrame.Position + direction * boss.Data.EvadeDistance + Vector3.new(0, 18, 0)
	root.CFrame = CFrame.lookAt(safePosition, attackCFrame.Position)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	boss.StatusLabel.Text = "Status: Dodging Stomp"
	return "Stomp"
end

tabs.boss.attack = function(boss, model, health, maxHealth, hitbox, character, root, humanoid, punch, leftHand, rightHand, center, position, evadeMode)
	character = lp.player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return end
	evadeMode = tabs.boss.evadeAttack(boss, model, hitbox, root, humanoid)
	if evadeMode == "Stomp" then return end
	punch = character:FindFirstChild("Punch") or lp.player.Backpack:FindFirstChild("Punch")
	if punch and punch.Parent ~= character then humanoid:EquipTool(punch) end
	leftHand = character:FindFirstChild("LeftHand")
	rightHand = character:FindFirstChild("RightHand")
	center = tabs.boss.getBossHeadPosition(model, hitbox)
	if evadeMode ~= "Punch" then
		position = center
		root.CFrame = CFrame.lookAt(position, position + hitbox.CFrame.LookVector)
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	pcall(function()
		if leftHand then
			services.touchParts(hitbox, leftHand, 0)
			services.touchParts(hitbox, leftHand, 1)
		end
		if rightHand then
			services.touchParts(hitbox, rightHand, 0)
			services.touchParts(hitbox, rightHand, 1)
		end
	end)

	if os.clock() - boss.Data.LastPunch >= boss.Data.PunchInterval then
		boss.Data.LastPunch = os.clock()
		pcall(function()
			services.muscleEvent:FireServer("punch", "leftHand")
			services.muscleEvent:FireServer("punch", "rightHand")
			if punch then punch:Activate() end
		end)
	end

	boss.BossLabel.Text = (boss.BossLabelPrefix or "Boss: ") .. boss.getBossDisplayName(model)
	boss.runtime.health = boss.getBossHealth(health, model)
	boss.runtime.maxHealth = boss.getBossMaxHealth(maxHealth, model)
	boss.HealthLabel.Text = "Health: " .. formatCurrentStat(boss.runtime.health) .. " / " .. formatCurrentStat(boss.runtime.maxHealth)
end

tabs.boss.findChest = function(chest, prompt, part)
	for _, candidate in ipairs(services.collectionservice:GetTagged("BossEventChest")) do
		if candidate:IsDescendantOf(workspace) then chest = candidate break end
	end
	if not chest then chest = workspace:FindFirstChild("BossChest", true) end
	if not chest then
		for _, candidate in ipairs(workspace:GetDescendants()) do
			if candidate:IsA("ProximityPrompt") and candidate.Name == "bossChestPrompt" then
				chest = candidate.Parent
				break
			end
		end
	end
	if not chest then return end
	prompt = chest:FindFirstChild("bossChestPrompt", true)
	part = prompt and prompt.Parent or (chest:IsA("Model") and (chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart", true))) or chest
	if part and part:IsA("BasePart") then return chest, prompt, part end
end

tabs.boss.collectChest = function(generation, startedAt, chest, prompt, part, character, root)
	tabs.boss.StatusLabel.Text = "Status: Waiting for Chest"
	startedAt = os.clock()
	repeat
		chest, prompt, part = tabs.boss.findChest()
		if chest and chest:GetAttribute("BossChestEmerging") ~= true then break end
		task.wait(0.1)
	until not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation or os.clock() - startedAt >= 12
	if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation or not chest or not part then return end

	tabs.boss.StatusLabel.Text = "Status: Collecting Chest"
	startedAt = os.clock()
	repeat
		character, root = tabs.boss.getAliveCharacter(generation, 2)
		if character and root and chest.Parent and part.Parent then
			tabs.boss.StatusLabel.Text = "Status: Collecting Chest"
			pcall(function()
				root.CFrame = CFrame.lookAt(part.Position + Vector3.new(0, 3, 4), part.Position)
				root.AssemblyLinearVelocity = Vector3.zero
			end)
			task.wait(0.15)
			if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
			if not (prompt and prompt.Parent and type(fireproximityprompt) == "function"
				and pcall(fireproximityprompt, prompt)) then
				pcall(function()
					services.virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(0.1)
					services.virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end)
			end
		end
		task.wait(0.25)
	until not tabs.boss.Data.Running
		or tabs.boss.Data.Generation ~= generation
		or lp.player:GetAttribute("BossChestPending") == false
		or not chest.Parent
		or os.clock() - startedAt >= 12
end

tabs.boss.ContinueSwitch = tabs.boss:AddSwitch("Continue Farming after Boss Kill", function(state)
	tabs.boss.Data.ContinueTraining = state
	if state and tabs.boss.Data.Phase == "Waiting"
		and (not tabs.boss.Halloween or not tabs.boss.Halloween.Data.Running) then tabs.boss.resumeTraining() end
end)
tabs.boss.ContinueSwitch:Set(true)

task.spawn(function(model, health, maxHealth, hitbox, currentHealth, currentMaxHealth, nextTime)
	while true do
		model, health, maxHealth, hitbox = tabs.boss.findActiveBoss()
		if model then
			currentHealth = tabs.boss.getBossHealth(health)
			currentMaxHealth = tabs.boss.getBossMaxHealth(maxHealth)
			tabs.boss.BossLabel.Text = "Boss: " .. (workspace:GetAttribute("BossDisplayName") or model.Name)
			tabs.boss.HealthLabel.Text = "Health: " .. formatCurrentStat(currentHealth) .. " / " .. formatCurrentStat(currentMaxHealth)
			tabs.boss.NextBossLabel.Text = "Next Boss: Current boss active"
		else
			tabs.boss.BossLabel.Text = "Boss: None"
			tabs.boss.HealthLabel.Text = "Health: 0 / 0"
			nextTime = workspace:GetAttribute("BossSpawnNextTime")
			tabs.boss.NextBossLabel.Text = typeof(nextTime) == "number"
				and "Next Boss: " .. tabs.boss.formatCountdown(nextTime - workspace:GetServerTimeNow())
				or "Next Boss: N/A"
		end
		task.wait(0.25)
	end
end)

tabs.boss.AutoFarmSwitch = tabs.boss:AddSwitch("Auto Farm Boss", function(state)
	if state and tabs.boss.Halloween and tabs.boss.Halloween.Data.Running then
		tabs.boss.Halloween.AutoFarmSwitch:Set(false)
	end
	tabs.boss.Data.Running = state
	tabs.boss.Data.Generation += 1
	tabs.boss.runtime.generation = tabs.boss.Data.Generation
	if not state then
		tabs.boss.Data.Preparation = nil
		tabs.boss.Data.Phase = "Waiting"
		tabs.boss.StatusLabel.Text = "Status: Disabled"
		tabs.boss.resumeTraining()
		return
	end

	task.spawn(function(generation, wasFighting, model, health, maxHealth, hitbox, selected)
		while tabs.boss.Data.Running and tabs.boss.Data.Generation == generation do
			pcall(function()
				model, health, maxHealth, hitbox = tabs.boss.findActiveBoss()
				selected = model and tabs.boss.shouldFarmBoss(model)
				if model and not selected then
					if wasFighting or tabs.boss.Data.Preparation then
						tabs.boss.Data.Preparation = nil
						wasFighting = false
						tabs.boss.resumeTraining()
					end
					tabs.boss.Data.Phase = "Waiting"
					tabs.boss.StatusLabel.Text = "Status: Skipping " .. (workspace:GetAttribute("BossDisplayName") or model.Name)
				elseif model then
					if wasFighting and tabs.boss.needsRetraining(tabs.boss) then wasFighting = false end
					if not wasFighting then
						if not tabs.boss.prepareForBoss(tabs.boss) then return end
						wasFighting = true
						tabs.boss.Data.Phase = "Fighting"
						tabs.boss.Data.AttackSequence = nil
						tabs.boss.Data.EvadeUntil = 0
						tabs.boss.Data.DodgeStomps = false
						tabs.boss.pauseTraining()
					end
					if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
					if tabs.boss.needsRetraining(tabs.boss) then return end
					if lp.player.Character
						and lp.player.Character:FindFirstChildOfClass("Humanoid")
						and lp.player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
						tabs.boss.StatusLabel.Text = "Status: Fighting"
						tabs.boss.attack(tabs.boss, model, health, maxHealth, hitbox)
					else
						tabs.boss.StatusLabel.Text = "Status: Waiting for Respawn"
					end
				elseif wasFighting then
					wasFighting = false
					tabs.boss.Data.Phase = "Collecting"
					pcall(tabs.boss.collectChest, generation)
					if not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation then return end
					tabs.boss.BossLabel.Text = "Boss: None"
					tabs.boss.HealthLabel.Text = "Health: 0 / 0"
					if tabs.boss.Data.ContinueTraining then tabs.boss.resumeTraining() end
					tabs.boss.Data.Phase = "Waiting"
					tabs.boss.StatusLabel.Text = "Status: Waiting for Boss"
				else
					if tabs.boss.Data.Preparation then
						tabs.boss.Data.Preparation = nil
						tabs.boss.resumeTraining()
					end
					tabs.boss.StatusLabel.Text = "Status: Waiting for Boss"
				end
			end)
			task.wait(model and selected and 0.03 or 0.25)
		end
	end, tabs.boss.runtime.generation)
end)

tabs.boss:AddLabel("")

tabs.boss:AddLabel("Halloween Boss Farming:")
tabs.boss.Halloween = {
	runtime = {},
	BossLabelPrefix = "Halloween Boss: ",
	StatusLabel = tabs.boss:AddLabel("Status: Waiting for Halloween Boss"),
	BossLabel = tabs.boss:AddLabel("Halloween Boss: None"),
	HealthLabel = tabs.boss:AddLabel("Health: 0 / 0"),
	NextBossLabel = tabs.boss:AddLabel("Next Halloween Boss: Waiting for spawn"),
	Data = {
		Running = false,
		Generation = 0,
		Phase = "Waiting",
		PunchInterval = 0.3,
		LastPunch = 0,
		AttackSequence = nil,
		EvadeUntil = 0,
		EvadeDistance = 230,
		PunchBehindDistance = 45,
		StompHealthThreshold = 0.35,
		DodgeStomps = false,
		Bosses = {
			GrimReaper = "Grim Reaper",
			FrankenBrute = "Frankenbrute",
			PumpkinTitan = "Pumpkin Titan",
			ScarecrowColossus = "Scarecrow Colossus"
		},
		BossOrder = {"GrimReaper", "FrankenBrute", "PumpkinTitan", "ScarecrowColossus"},
		BossByDisplayName = {},
		SelectedBosses = {},
		Target = nil
	}
}

tabs.boss.Halloween.getBossDisplayName = function(model)
	return tabs.boss.Halloween.Data.Bosses[model:GetAttribute("BossId") or model.Name] or model.Name
end

tabs.boss.Halloween.getBossHealth = function(health, model)
	return tonumber(model:GetAttribute("Health")) or 0
end

tabs.boss.Halloween.getBossMaxHealth = function(maxHealth, model)
	return tonumber(model:GetAttribute("MaxHealth")) or 0
end

tabs.boss.Halloween.SelectedBossesLabel = tabs.boss:AddLabel("Targeted Halloween Bosses: All")
tabs.boss.Halloween.updateSelectedBossesLabel = function(selectedNames)
	selectedNames = {}
	for _, bossId in ipairs(tabs.boss.Halloween.Data.BossOrder) do
		if tabs.boss.Halloween.Data.SelectedBosses[bossId] then
			table.insert(selectedNames, tabs.boss.Halloween.Data.Bosses[bossId])
		end
	end
	tabs.boss.Halloween.SelectedBossesLabel.Text = "Targeted Halloween Bosses: "
		.. (#selectedNames > 0 and table.concat(selectedNames, ", ") or "None")
end

tabs.boss.Halloween.BossDropdown = tabs.boss:AddDropdown("Target specific Halloween Bosses", function(displayName, bossId)
	bossId = tabs.boss.Halloween.Data.BossByDisplayName[displayName]
	if not bossId then return end
	tabs.boss.Halloween.Data.SelectedBosses[bossId] = not tabs.boss.Halloween.Data.SelectedBosses[bossId]
	tabs.boss.Halloween.updateSelectedBossesLabel()
end)
for _, bossId in ipairs(tabs.boss.Halloween.Data.BossOrder) do
	tabs.boss.Halloween.Data.BossByDisplayName[tabs.boss.Halloween.Data.Bosses[bossId]] = bossId
	tabs.boss.Halloween.Data.SelectedBosses[bossId] = true
	tabs.boss.Halloween.BossDropdown:Add(tabs.boss.Halloween.Data.Bosses[bossId])
end
tabs.boss.Halloween.updateSelectedBossesLabel()

tabs.boss.Halloween.shouldFarmBoss = function(model)
	return tabs.boss.Halloween.Data.SelectedBosses[model:GetAttribute("BossId") or model.Name] == true
end

tabs.boss.Halloween.findActiveBoss = function(selectedOnly, model, hitbox, candidateHitbox, character, root, distance, closestDistance)
	character = lp.player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	closestDistance = math.huge
	for _, candidate in ipairs(services.collectionservice:GetTagged("HalloweenBoss")) do
		if candidate:IsA("Model") and candidate:IsDescendantOf(workspace)
			and tabs.boss.Halloween.getBossHealth(nil, candidate) > 0
			and (not selectedOnly or tabs.boss.Halloween.shouldFarmBoss(candidate)) then
			candidateHitbox = candidate:FindFirstChild("BossDamageHitbox", true)
				or candidate.PrimaryPart or candidate:FindFirstChild("HumanoidRootPart")
			if candidateHitbox and candidateHitbox:IsA("BasePart") then
				if selectedOnly and candidate == tabs.boss.Halloween.Data.Target then
					return candidate, nil, nil, candidateHitbox
				end
				distance = root and (root.Position - candidateHitbox.Position).Magnitude or 0
				if not model or distance < closestDistance then
					model, hitbox, closestDistance = candidate, candidateHitbox, distance
				end
			end
		end
	end
	return model, nil, nil, hitbox
end

task.spawn(function(model)
	while true do
		model = tabs.boss.Halloween.Data.Target
		if not model or not model.Parent or tabs.boss.Halloween.getBossHealth(nil, model) <= 0 then
			model = tabs.boss.Halloween.findActiveBoss()
		end
		if model then
			tabs.boss.Halloween.BossLabel.Text = "Halloween Boss: " .. tabs.boss.Halloween.getBossDisplayName(model)
			tabs.boss.Halloween.HealthLabel.Text = "Health: " .. formatCurrentStat(tabs.boss.Halloween.getBossHealth(nil, model))
				.. " / " .. formatCurrentStat(tabs.boss.Halloween.getBossMaxHealth(nil, model))
			tabs.boss.Halloween.NextBossLabel.Text = "Next Halloween Boss: Current boss active"
		else
			tabs.boss.Halloween.BossLabel.Text = "Halloween Boss: None"
			tabs.boss.Halloween.HealthLabel.Text = "Health: 0 / 0"
			tabs.boss.Halloween.NextBossLabel.Text = "Next Halloween Boss: Waiting for spawn"
		end
		task.wait(0.25)
	end
end)

tabs.boss.Halloween.AutoFarmSwitch = tabs.boss:AddSwitch("Auto Farm Halloween Boss", function(state)
	if state and tabs.boss.Data.Running then tabs.boss.AutoFarmSwitch:Set(false) end
	tabs.boss.Halloween.Data.Running = state
	tabs.boss.Halloween.Data.Generation += 1
	if not state then
		tabs.boss.Halloween.Data.Preparation = nil
		tabs.boss.Halloween.Data.Target = nil
		tabs.boss.Halloween.Data.Phase = "Waiting"
		tabs.boss.Halloween.StatusLabel.Text = "Status: Disabled"
		tabs.boss.resumeTraining()
		return
	end

	task.spawn(function(generation, wasFighting, model, health, maxHealth, hitbox)
		while tabs.boss.Halloween.Data.Running and tabs.boss.Halloween.Data.Generation == generation do
			pcall(function()
				model, health, maxHealth, hitbox = tabs.boss.Halloween.findActiveBoss(true)
				if model then
					if wasFighting and tabs.boss.needsRetraining(tabs.boss.Halloween) then wasFighting = false end
					if not wasFighting then
						if not tabs.boss.prepareForBoss(tabs.boss.Halloween) then return end
						wasFighting = true
						tabs.boss.pauseTraining()
					end
					if not tabs.boss.Halloween.Data.Running or tabs.boss.Halloween.Data.Generation ~= generation then return end
					if tabs.boss.needsRetraining(tabs.boss.Halloween) then return end
					if tabs.boss.Halloween.Data.Target ~= model then
						tabs.boss.Halloween.Data.Target = model
						tabs.boss.Halloween.Data.AttackSequence = nil
						tabs.boss.Halloween.Data.EvadeUntil = 0
						tabs.boss.Halloween.Data.DodgeStomps = false
					end
					tabs.boss.Halloween.Data.Phase = "Fighting"
					if lp.player.Character
						and lp.player.Character:FindFirstChildOfClass("Humanoid")
						and lp.player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
						tabs.boss.Halloween.StatusLabel.Text = "Status: Fighting"
						tabs.boss.attack(tabs.boss.Halloween, model, health, maxHealth, hitbox)
					else
						tabs.boss.Halloween.StatusLabel.Text = "Status: Waiting for Respawn"
					end
				else
					tabs.boss.Halloween.Data.Target = nil
					tabs.boss.Halloween.Data.Phase = "Waiting"
					if tabs.boss.Halloween.Data.Preparation then
						tabs.boss.Halloween.Data.Preparation = nil
						tabs.boss.resumeTraining()
					elseif wasFighting then
						tabs.boss.resumeTraining()
					end
					wasFighting = false
					tabs.boss.Halloween.StatusLabel.Text = "Status: Waiting for Halloween Boss"
				end
			end)
			task.wait(model and 0.03 or 0.25)
		end
	end, tabs.boss.Halloween.Data.Generation)
end)


-- Other Tab

function unequipPets()
    for _, folder in pairs(lp.player.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                services.replicatedstorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

function equipPetsByName(name)
    unequipPets()
    task.wait(0.01)
    for _, pet in pairs(lp.player.petsFolder.Unique:GetChildren()) do
        if pet.Name == name then
            services.replicatedstorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
        end
    end
end

tabs.other.eggsowned = tabs.other:AddLabel("Protein Eggs: 0")
tabs.other.eggsowned.TextSize = 14

tabs.other.autoEgg = false
tabs.other.autoShake = false
tabs.other.autoSpinWheel = false
tabs.other.eggUsedThisCycle = false


task.spawn(function()
    while true do
        tabs.other.proteinEggCount = 0
        tabs.other.backpack = lp.player:FindFirstChild("Backpack")
        if tabs.other.backpack then
            for _, item in ipairs(tabs.other.backpack:GetChildren()) do
                if item.Name == "Protein Egg" then
                    tabs.other.proteinEggCount = tabs.other.proteinEggCount + 1
                end
            end
        end
        tabs.other.eggsowned.Text = "Protein Eggs: " .. tabs.other.proteinEggCount
        task.wait(1)
    end
end)

tabs.other.x2str = tabs.other:AddLabel("x2 Strength: 00:00")
tabs.other.x2str.TextSize = 14

function formatTime(seconds)
    return string.format("%dd %dh %dm %ds", math.floor(seconds / 86400), math.floor((seconds % 86400) / 3600), math.floor((seconds % 3600) / 60), seconds % 60)
end

task.spawn(function()
    while true do
        tabs.other.boostTimersFolder = lp.player:FindFirstChild("boostTimersFolder")
        tabs.other.boost = tabs.other.boostTimersFolder and tabs.other.boostTimersFolder:FindFirstChild("Protein Egg")
        tabs.other.seconds = (tabs.other.boost and tabs.other.boost:IsA("IntValue")) and tabs.other.boost.Value or 0
        tabs.other.x2str.Text = "x2 Strength: " .. formatTime(tabs.other.seconds)
        task.wait(0.5)
    end
end)

function eatEgg()
    tabs.other.character = lp.player.Character
    tabs.other.backpack = lp.player:FindFirstChild("Backpack")
    tabs.other.tool = (tabs.other.character and tabs.other.character:FindFirstChild("Protein Egg")) or (tabs.other.backpack and tabs.other.backpack:FindFirstChild("Protein Egg"))
    if tabs.other.tool then
        for _ = 1, 10 do
            services.muscleEvent:FireServer("proteinEgg", tabs.other.tool)
        end
    end
end

task.spawn(function()
    while true do
        if tabs.other.autoEgg then
            eatEgg()
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

tabs.other:AddSwitch("Eat Eggs", function(state)
    tabs.other.autoEgg = state
    if state then
        eatEgg()
    end
end)

function eatShake()
    tabs.other.character = lp.player.Character
    tabs.other.backpack = lp.player:FindFirstChild("Backpack")
    tabs.other.tool = (tabs.other.character and tabs.other.character:FindFirstChild("Tropical Shake")) or (tabs.other.backpack and tabs.other.backpack:FindFirstChild("Tropical Shake"))
    if tabs.other.tool then
        services.muscleEvent:FireServer("tropicalShake", tabs.other.tool)
    end
end

task.spawn(function()
    while true do
        if tabs.other.autoShake then
            eatShake()
            task.wait(150)
        else
            task.wait(1)
        end
    end
end)

tabs.other:AddSwitch("Auto Shake (just to eat them)", function(state)
    tabs.other.autoShake = state
    if state then
        eatShake()
    end
end)

tabs.other.spinFortuneWheel = function()
    tabs.other.spinResult = table.pack(pcall(function()
        return game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote:InvokeServer(
            "openFortuneWheel",
            "Fortune Wheel"
        )
    end))
end

tabs.other:AddSwitch("Spin Fortune Wheel", function(bool)
    _G.AutoSpinWheel = bool
    
    if bool then
        task.spawn(function()
            tabs.other.rspin = game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote
            tabs.other.chances = game:GetService("ReplicatedStorage").shared.catalogs.fortuneWheelChances["Fortune Wheel"]
            
            while _G.AutoSpinWheel do
                tabs.other.rspin:InvokeServer("openFortuneWheel", tabs.other.chances)
                task.wait(1)
            end
        end)
    end
end)


tabs.other.boostItemList = {
    "Tropical Shake",
    "Energy Shake",
    "Protein Bar",
    "TOUGH Bar",
    "Protein Shake",
    "ULTRA Shake",
    "Energy Bar",
}

tabs.other.boostActions = {
    ["Tropical Shake"] = "tropicalShake",
    ["Energy Shake"] = "energyShake",
    ["Protein Bar"] = "proteinBar",
    ["TOUGH Bar"] = "toughBar",
    ["Protein Shake"] = "proteinShake",
    ["ULTRA Shake"] = "ultraShake",
    ["Energy Bar"] = "energyBar",
}

tabs.other.eatAllBoostsRunning = false

task.spawn(function()
    while true do
        if tabs.other.eatAllBoostsRunning then
            tabs.other.boostItemIndex = 1
            while tabs.other.boostItemIndex <= #tabs.other.boostItemList do
                tabs.other.boostItemName = tabs.other.boostItemList[tabs.other.boostItemIndex]
                tabs.other.character = lp.player.Character
                tabs.other.backpack = lp.player:FindFirstChild("Backpack")
                tabs.other.boostTool = (tabs.other.character and tabs.other.character:FindFirstChild(tabs.other.boostItemName))
                    or (tabs.other.backpack and tabs.other.backpack:FindFirstChild(tabs.other.boostItemName))

                if tabs.other.boostTool then
                    tabs.other.boostUseIndex = 1
                    while tabs.other.boostUseIndex <= 10 do
                        services.muscleEvent:FireServer(tabs.other.boostActions[tabs.other.boostItemName], tabs.other.boostTool)
                        tabs.other.boostUseIndex = tabs.other.boostUseIndex + 1
                    end
                end

                tabs.other.boostItemIndex = tabs.other.boostItemIndex + 1
            end

            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

tabs.other:AddSwitch("Eat All Boosts (Expect Lag)", function(state)
    tabs.other.eatAllBoostsRunning = state
end):Set(false)

tabs.other.VisibilitySettings = {
    {Name = "Show Pets", GuiName = "MyPetsBase", Enabled = false},
    {Name = "Show Other Pets", GuiName = "OtherPets", Enabled = false},
    {Name = "Show PopUps", GuiName = "PopUps", Enabled = false}
}

tabs.other.syncVisibilitySetting = function(setting, success, connections)
    if not setting.OnText or not setting.OnText.Parent or not setting.Button or not setting.Button.Parent
        or setting.Pending or setting.OnText.Visible == setting.Enabled then return end
    if type(firesignal) ~= "function" or type(getconnections) ~= "function" then return end
    for _, button in ipairs({setting.Button, setting.Button:FindFirstChild(setting.OnText.Visible and "OnButton" or "OffButton")}) do
        for _, eventName in ipairs({"MouseButton1Click", "Activated"}) do
            success, connections = pcall(getconnections, button[eventName])
            if success and type(connections) == "table" then
                for _, connection in ipairs(connections) do
                    if connection.Enabled ~= false then
                        setting.Pending = true
                        if pcall(firesignal, button[eventName]) then return end
                        setting.Pending = false
                    end
                end
            end
        end
    end
end

tabs.other.bindVisibilitySetting = function(setting, node, onText, button)
    node = lp.player
    for _, childName in ipairs({"PlayerGui", "gameGui", "settingsNewMenu", "Content", "ListLayout", "ScrollingFrame", setting.GuiName}) do
        node = node:WaitForChild(childName, 10)
        if not node then return end
    end
    onText = node:WaitForChild("OnText", 10)
    button = node:WaitForChild("Switch", 10)
    if not onText or not button then return end
    if setting.OnText ~= onText or setting.Button ~= button then
        if setting.Connection then setting.Connection:Disconnect() end
        setting.OnText = onText
        setting.Button = button
        setting.Pending = false
        setting.Connection = onText:GetPropertyChangedSignal("Visible"):Connect(function()
            setting.Pending = false
            task.defer(tabs.other.syncVisibilitySetting, setting)
        end)
    end
    tabs.other.syncVisibilitySetting(setting)
end

for _, setting in ipairs(tabs.other.VisibilitySettings) do
    setting.Switch = tabs.other:AddSwitch(setting.Name, function(state)
        setting.Enabled = state
        tabs.other.syncVisibilitySetting(setting)
    end)
    setting.Switch:Set(false)
    task.spawn(tabs.other.bindVisibilitySetting, setting)
end
lp.player.CharacterAdded:Connect(function()
    for _, setting in ipairs(tabs.other.VisibilitySettings) do
        task.spawn(tabs.other.bindVisibilitySetting, setting)
    end
end)

tabs.other.HideNameSwitch = tabs.other:AddSwitch("Hide Name", function(state)
    tabs.other.RedactConfig.RedactName = state
    tabs.other.applyNameVisibility()
    tabs.other.saveRedactConfig()
end)
tabs.other.HideNameSwitch:Set(tabs.other.RedactConfig.RedactName)

tabs.other.RedactStatsSwitch = tabs.other:AddSwitch("Hide Stats", function(state)
    tabs.other.redactStats = state
    tabs.other.RedactConfig.RedactStats = state
    tabs.other.applyStatsVisibility()
    tabs.other.saveRedactConfig()
    tabs.rebirths.updateStats()
    tabs.strength.updateStats()
    tabs.strength2.updateStats()
end)
tabs.other.RedactStatsSwitch:Set(tabs.other.RedactConfig.RedactStats)

lp.player.CharacterAdded:Connect(function(character, head)
    task.defer(tabs.other.applyStatsVisibility)
    if character.Name ~= "HenneZocktTV" then return end
    head = character:WaitForChild("Head", 10)
    if head and head:WaitForChild("nameGui", 10) and lp.player.Character == character then
        tabs.other.applyNameVisibility()
    end
end)



tabs.other.tpE = function(position)
    tabs.other.character = lp.player.Character or lp.player.CharacterAdded:Wait()
    tabs.other.hrp = tabs.other.character:WaitForChild("HumanoidRootPart")
    tabs.other.hrp.CFrame = CFrame.new(position)
    tabs.other.hrp.AssemblyLinearVelocity = Vector3.zero
    tabs.other.hrp.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.4)
    services.virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    services.virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

tabs.other:AddButton("Industrial Lift",function()
    tabs.other.tpE(Vector3.new(-5491.68945, 81.2379913, 4643.85791))
end)

tabs.other:AddButton("Industrial Squat",function()
    tabs.other.tpE(Vector3.new(-5217.25049, 89.8445511, 5416.01025))
end)

tabs.other:AddButton("Halloween Lift",function()
    tabs.other.tpE(Vector3.new(5760.389, 83.206, 6117.898))
end)

tabs.other:AddButton("Halloween Squat",function()
    tabs.other.tpE(Vector3.new(4803.357, 83.791, 5827.032))
end)


tabs.other:AddButton("Anti Lag (for bad devices)", function()
    tabs.other.playerGui = lp.player:WaitForChild("PlayerGui")

    for _, gui in pairs(tabs.other.playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "imgui" then
            gui:Destroy()
        end
    end

    tabs.other.darkenSky = function()
        for _, v in pairs(services.lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end

        tabs.other.darkSky = Instance.new("Sky")
        tabs.other.darkSky.Name = "DarkSky"
        tabs.other.darkSky.SkyboxBk = "rbxassetid://0"
        tabs.other.darkSky.SkyboxDn = "rbxassetid://0"
        tabs.other.darkSky.SkyboxFt = "rbxassetid://0"
        tabs.other.darkSky.SkyboxLf = "rbxassetid://0"
        tabs.other.darkSky.SkyboxRt = "rbxassetid://0"
        tabs.other.darkSky.SkyboxUp = "rbxassetid://0"
        tabs.other.darkSky.Parent = services.lighting

        services.lighting.Brightness = 0
        services.lighting.ClockTime = 0
        services.lighting.TimeOfDay = "00:00:00"
        services.lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        services.lighting.Ambient = Color3.new(0, 0, 0)
        services.lighting.FogColor = Color3.new(0, 0, 0)
        services.lighting.FogEnd = 100

        task.spawn(function()
            while true do
                wait(5)
                if not services.lighting:FindFirstChild("DarkSky") then
                    tabs.other.darkSky:Clone().Parent = services.lighting
                end
                services.lighting.Brightness = 0
                services.lighting.ClockTime = 0
                services.lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                services.lighting.Ambient = Color3.new(0, 0, 0)
                services.lighting.FogColor = Color3.new(0, 0, 0)
                services.lighting.FogEnd = 100
            end
        end)
    end

    tabs.other.removeParticleEffects = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj:Destroy()
            end
        end
    end

    tabs.other.removeLightSources = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end
    end

for _, v in pairs(services.lighting:GetChildren()) do
    if v:IsA("Atmosphere") then
        v:Destroy()
    end
end

    workspace.Terrain.WaterColor = Color3.new(0, 0, 0)
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 1

    services.lighting.GlobalShadows = false
    services.lighting.EnvironmentDiffuseScale = 0
    services.lighting.EnvironmentSpecularScale = 0
    services.lighting.ExposureCompensation = -10

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Color = Color3.new(0, 0, 0)
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        end
    end

    tabs.other.removeParticleEffects()
    tabs.other.removeLightSources()
    tabs.other.darkenSky()
    services.replicatedstorage.shared.assets.ui.strengthFrame:Destroy()
    services.replicatedstorage.shared.assets.ui.durabilityFrame:Destroy()
end)

tabs.other:AddButton("Equip Rep Pets", function()
    equipBestFarmingPets()
end)

tabs.info:Show()
tabs.info:AddLabel("Made by xyzhenrik")
tabs.info:AddLabel("Any issues? Create a Ticket on Discord")
tabs.info:AddLabel("Official Discord: discord.gg/9eFf93Kg8D")
tabs.info:AddButton("Copy Invite", function()
	if type(setclipboard) == "function" and pcall(setclipboard, "https://discord.gg/9eFf93Kg8D") then
		pcall(function() game.StarterGui:SetCore("SendNotification", {Title = "Link Copied!", Text = "You can continue to Discord now.", Duration = 3}) end)
	else
		pcall(function() game.StarterGui:SetCore("SendNotification", {Title = "Error!", Text = "Clipboard not Supported.", Duration = 3}) end)
	end
end)
tabs.info:AddLabel("")
tabs.info:AddLabel("Contributors:").TextSize = 17
tabs.info:AddLabel("- Henrik @xyzhenrik")
tabs.info:AddLabel("- Muki @mukimagdich")
tabs.info:AddLabel("")
tabs.info:AddLabel("Silence is Open-Source!")
tabs.info:AddLabel("")
tabs.info.VersionLabel = tabs.info:AddLabel("Muscle Legends [V4.2.0]")
tabs.info.VersionLabel.TextSize = 20
tabs.info.VersionLabel.Font = Enum.Font.Arcade
]====],Controls={
{Kind=[====[
Paragraph]====],Title=[====[
Status: Inactive]====],Desc=[====[
Finalidade: Status: Inactive
Origem: Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Status: Inactive]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Status: Inactive]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Runtime: 0d 0h 0m 0s]====],Desc=[====[
Finalidade: Runtime: 0d 0h 0m 0s
Origem: Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Runtime: 0d 0h 0m 0s]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Runtime: 0d 0h 0m 0s]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Rebirths: #### | Gained: 0]====],Desc=[====[
Finalidade: Rebirths: #### | Gained: 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Rebirths: #### | Gained: 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Rebirths: #### | Gained: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Pace: -- / Hour | -- / Day | -- / Week]====],Desc=[====[
Finalidade: Pace: -- / Hour | -- / Day | -- / Week
Origem: Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Pace: -- / Hour | -- / Day | -- / Week]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Pace: -- / Hour | -- / Day | -- / Week]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Average: -- / Hour | -- / Day | -- / Week]====],Desc=[====[
Finalidade: Average: -- / Hour | -- / Day | -- / Week
Origem: Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Average: -- / Hour | -- / Day | -- / Week]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Average: -- / Hour | -- / Day | -- / Week]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Pack Rebirth (Yes, Robux Packs)]====],Desc=[====[
Finalidade: Average: -- / Hour | -- / Day | -- / Week
Origem: Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Pack Rebirth (Yes, Robux Packs)]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Rebirths/Pack Rebirth (Yes, Robux Packs)]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Status: Inactive]====],Desc=[====[
Finalidade: Status: Inactive
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Status: Inactive]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Status: Inactive]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Runtime: 0d 0h 0m 0s]====],Desc=[====[
Finalidade: Runtime: 0d 0h 0m 0s
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Runtime: 0d 0h 0m 0s]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Runtime: 0d 0h 0m 0s]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Strength: #### | Gained: 0]====],Desc=[====[
Finalidade: Strength: #### | Gained: 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Strength: #### | Gained: 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Strength: #### | Gained: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Durability: #### | Gained: 0]====],Desc=[====[
Finalidade: Durability: #### | Gained: 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Durability: #### | Gained: 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Durability: #### | Gained: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Str Pace: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Str Pace: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Str Pace: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Str Pace: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Dura Pace: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Dura Pace: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Dura Pace: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Dura Pace: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Str Ø: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Str Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Str Ø: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Str Ø: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Dura Ø: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Dura Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Dura Ø: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Dura Ø: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Max reps/s: 659]====],Desc=[====[
Finalidade: Dura Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Max reps/s: 659]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Max reps/s: 659]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Recommended Speed: 659, more = lag]====],Desc=[====[
Finalidade: Recommended Speed: 659, more = lag
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Recommended Speed: 659, more = lag]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Recommended Speed: 659, more = lag]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Fast Rep]====],Desc=[====[
Finalidade: Recommended Speed: 659, more = lag
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Fast Rep]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Fast Rep]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Reaching Average Speed takes some time!]====],Desc=[====[
Finalidade: Reaching Average Speed takes some time!
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength/Reaching Average Speed takes some time!]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength/Reaching Average Speed takes some time!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Status: Inactive]====],Desc=[====[
Finalidade: Status: Inactive
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Status: Inactive]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Status: Inactive]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Runtime: 0d 0h 0m 0s]====],Desc=[====[
Finalidade: Runtime: 0d 0h 0m 0s
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Runtime: 0d 0h 0m 0s]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Runtime: 0d 0h 0m 0s]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Strength: #### | Gained: 0]====],Desc=[====[
Finalidade: Strength: #### | Gained: 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Strength: #### | Gained: 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Strength: #### | Gained: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Durability: #### | Gained: 0]====],Desc=[====[
Finalidade: Durability: #### | Gained: 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Durability: #### | Gained: 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Durability: #### | Gained: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Str Pace: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Str Pace: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Str Pace: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Str Pace: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Dura Pace: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Dura Pace: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Dura Pace: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Dura Pace: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Str Ø: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Str Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Str Ø: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Str Ø: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Dura Ø: --/s | --/min | --/h | --/d]====],Desc=[====[
Finalidade: Dura Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Dura Ø: --/s | --/min | --/h | --/d]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Dura Ø: --/s | --/min | --/h | --/d]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Rep Speed:]====],Desc=[====[
Finalidade: Dura Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Rep Speed:]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Rep Speed:]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Controlled Speed]====],Desc=[====[
Finalidade: Dura Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Controlled Speed]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Controlled Speed]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Fast Rep]====],Desc=[====[
Finalidade: Dura Ø: --/s | --/min | --/h | --/d
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Fast Rep]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/Fast Rep]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
This Farm is for low end devices, It will be slower then the other one]====],Desc=[====[
Finalidade: This Farm is for low end devices, It will be slower then the other one
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/This Farm is for low end devices, It will be slower then the other one]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/This Farm is for low end devices, It will be slower then the other one]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
For me, 20-40 works the best. Try around!]====],Desc=[====[
Finalidade: For me, 20-40 works the best. Try around!
Origem: Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/For me, 20-40 works the best. Try around!]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Strength (Slower)/For me, 20-40 works the best. Try around!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Boss Farming:]====],Desc=[====[
Finalidade: Boss Farming:
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Boss Farming:]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Boss Farming:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Status: Waiting for Boss]====],Desc=[====[
Finalidade: Status: Waiting for Boss
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Status: Waiting for Boss]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Status: Waiting for Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Boss: None]====],Desc=[====[
Finalidade: Boss: None
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Boss: None]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Boss: None]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Health: 0 / 0]====],Desc=[====[
Finalidade: Health: 0 / 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Health: 0 / 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Health: 0 / 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Next Boss: N/A]====],Desc=[====[
Finalidade: Next Boss: N/A
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Next Boss: N/A]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Next Boss: N/A]====],Default=[====[
]====]},
{Kind=[====[
Input]====],Title=[====[
Seconds Training before Boss (when Rebirthing):]====],Desc=[====[
Finalidade: Next Boss: N/A
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Seconds Training before Boss (when Rebirthing):]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Seconds Training before Boss (when Rebirthing):]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Targeted Bosses: Detecting...]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Targeted Bosses: Detecting...]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Targeted Bosses: Detecting...]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Target specific Bosses]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Target specific Bosses]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Target specific Bosses]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Continue Farming after Boss Kill]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Continue Farming after Boss Kill]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Continue Farming after Boss Kill]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Farm Boss]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Auto Farm Boss]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Auto Farm Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Targeted Bosses: Detecting...
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Halloween Boss Farming:]====],Desc=[====[
Finalidade: Halloween Boss Farming:
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Halloween Boss Farming:]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Halloween Boss Farming:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Status: Waiting for Halloween Boss]====],Desc=[====[
Finalidade: Status: Waiting for Halloween Boss
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Status: Waiting for Halloween Boss]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Status: Waiting for Halloween Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Halloween Boss: None]====],Desc=[====[
Finalidade: Halloween Boss: None
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Halloween Boss: None]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Halloween Boss: None]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Health: 0 / 0]====],Desc=[====[
Finalidade: Health: 0 / 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Health: 0 / 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Health: 0 / 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Next Halloween Boss: Waiting for spawn]====],Desc=[====[
Finalidade: Next Halloween Boss: Waiting for spawn
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Next Halloween Boss: Waiting for spawn]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Next Halloween Boss: Waiting for spawn]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Targeted Halloween Bosses: All]====],Desc=[====[
Finalidade: Targeted Halloween Bosses: All
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Targeted Halloween Bosses: All]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Targeted Halloween Bosses: All]====],Default=[====[
]====]},
{Kind=[====[
Dropdown]====],Title=[====[
Target specific Halloween Bosses]====],Desc=[====[
Finalidade: Targeted Halloween Bosses: All
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Target specific Halloween Bosses]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Target specific Halloween Bosses]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Farm Halloween Boss]====],Desc=[====[
Finalidade: Targeted Halloween Bosses: All
Origem: Mystery/Silence | Fast Farming - Good Noon!/Boss/Auto Farm Halloween Boss]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Boss/Auto Farm Halloween Boss]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Protein Eggs: 0]====],Desc=[====[
Finalidade: Protein Eggs: 0
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Protein Eggs: 0]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Protein Eggs: 0]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
x2 Strength: 00:00]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/x2 Strength: 00:00]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/x2 Strength: 00:00]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Eat Eggs]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Eat Eggs]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Eat Eggs]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Auto Shake (just to eat them)]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Auto Shake (just to eat them)]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Auto Shake (just to eat them)]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Spin Fortune Wheel]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Spin Fortune Wheel]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Spin Fortune Wheel]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Eat All Boosts (Expect Lag)]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Eat All Boosts (Expect Lag)]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Eat All Boosts (Expect Lag)]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show Pets]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Show Pets]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Show Pets]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show Other Pets]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Show Other Pets]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Show Other Pets]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Show PopUps]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Show PopUps]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Show PopUps]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Hide Name]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Hide Name]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Hide Name]====],Default=[====[
]====]},
{Kind=[====[
Toggle]====],Title=[====[
Hide Stats]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Hide Stats]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Hide Stats]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Industrial Lift]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Industrial Lift]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Industrial Lift]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Industrial Squat]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Industrial Squat]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Industrial Squat]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Halloween Lift]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Halloween Lift]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Halloween Lift]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Halloween Squat]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Halloween Squat]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Halloween Squat]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Anti Lag (for bad devices)]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Anti Lag (for bad devices)]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Anti Lag (for bad devices)]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Equip Rep Pets]====],Desc=[====[
Finalidade: x2 Strength: 00:00
Origem: Mystery/Silence | Fast Farming - Good Noon!/Other/Equip Rep Pets]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Other/Equip Rep Pets]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Made by xyzhenrik]====],Desc=[====[
Finalidade: Made by xyzhenrik
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Made by xyzhenrik]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Made by xyzhenrik]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Any issues? Create a Ticket on Discord]====],Desc=[====[
Finalidade: Any issues? Create a Ticket on Discord
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Any issues? Create a Ticket on Discord]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Any issues? Create a Ticket on Discord]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Official Discord: discord.gg/9eFf93Kg8D]====],Desc=[====[
Finalidade: Official Discord: discord.gg/9eFf93Kg8D
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Official Discord: discord.gg/9eFf93Kg8D]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Official Discord: discord.gg/9eFf93Kg8D]====],Default=[====[
]====]},
{Kind=[====[
Button]====],Title=[====[
Copy Invite]====],Desc=[====[
Finalidade: Official Discord: discord.gg/9eFf93Kg8D
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Copy Invite]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Copy Invite]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Official Discord: discord.gg/9eFf93Kg8D
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Contributors:]====],Desc=[====[
Finalidade: Contributors:
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Contributors:]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Contributors:]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
- Henrik @xyzhenrik]====],Desc=[====[
Finalidade: - Henrik @xyzhenrik
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/- Henrik @xyzhenrik]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/- Henrik @xyzhenrik]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
- Muki @mukimagdich]====],Desc=[====[
Finalidade: - Muki @mukimagdich
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/- Muki @mukimagdich]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/- Muki @mukimagdich]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: - Muki @mukimagdich
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Silence is Open-Source!]====],Desc=[====[
Finalidade: Silence is Open-Source!
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Silence is Open-Source!]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Silence is Open-Source!]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
]====],Desc=[====[
Finalidade: Silence is Open-Source!
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/]====],Default=[====[
]====]},
{Kind=[====[
Paragraph]====],Title=[====[
Muscle Legends [V4.2.0]]====],Desc=[====[
Finalidade: Muscle Legends [V4.2.0]
Origem: Mystery/Silence | Fast Farming - Good Noon!/Info/Muscle Legends [V4.2.0]]====],Path=[====[
Mystery/Silence | Fast Farming - Good Noon!/Info/Muscle Legends [V4.2.0]]====],Default=[====[
]====]}
},Saved=setmetatable({}, {__mode="k"}),Created={},Connections={},Widgets={},Status="Carrega ao usar"}
    -- SOURCE_CATALOG is inserted here by build_sources.py.
    local categoryKeywords={
        Farm={"Farm","Strength","Farming","Rebirths","Boosts"},Bosses={"Boss","Bosses"},
        PvP={"Killing","Killer"},Pets={"Pets","Inventory","Trade","Gift"},
        ["Sessão"]={"Dashboard","Home","Specs","Stats","Info"},Ajustes={"Main","Other","Teleports","Misc"},
    }
    for _,engine in ipairs(B.Engines) do
        local sections={}
        for index,control in ipairs(engine.Controls) do
            control.Engine=engine; control.Index=index
            control.Key="Source_"..engine.Id.."_"..index
            S[control.Key]=false
            if B:owner(control) then
                M.Conflicts[control.Key]=M.Conflicts[control.Key] or {}
                for _,nativeKey in ipairs({"Train","TrainWeight","TrainPushups","TrainSitups","TrainHandstands",
                    "TurboStrength","MaxStrengthF2P","AutoMachine","AutoAgility","SmartRock","SmartFarm",
                    "AutoBoss","PvpAny","PvpGood","PvpEvil","StrengthRebirth","LockPosition"}) do
                    M.Conflicts[control.Key][nativeKey]=true
                    M.Conflicts[nativeKey]=M.Conflicts[nativeKey] or {}
                    M.Conflicts[nativeKey][control.Key]=true
                end
            end
            local category="Ajustes"
            for name,words in pairs(categoryKeywords) do
                for _,word in ipairs(words) do if control.Path:find("/"..word,1,true) then category=name end end
            end
            local group=engine.Name.." / "..category
            UI.Groups[group]=category
            if not sections[group] then section(group,"Funções do módulo recuperado; cada botão informa sua origem e finalidade."); sections[group]=true end
            UI.CurrentCategory=category; currentSection=group
            local title=engine.Name..": "..(control.Title~="" and control.Title or "Informações")
            local desc=control.Desc~="" and control.Desc or ("Origem: "..control.Path)
            if control.Kind=="Toggle" then
                local button=toggle(title,desc,control.Key)
                button.Activated:Connect(function() B:invoke(control,S[control.Key]); renderAllToggles() end)
            elseif control.Kind=="Input" or control.Kind=="Slider" then
                local input=field(title,control.Default or "",function(value)
                    return B:invoke(control,value),"Valor enviado à rotina de origem"
                end)
                control.Input=input
            elseif control.Kind=="Dropdown" then
                card(title,desc,function()
                    if not B:boot(engine) then return end
                    local values=engine.Widgets[index].Values
                    local options={}
                    for _,value in ipairs(values) do options[#options+1]={Label=tostring(value),Value=value} end
                    UI.Choose(title,options,function(value) B:invoke(control,value) end)
                end)
            else
                local _,label,detail=card(title,desc,control.Kind=="Button" and function() B:invoke(control) end or nil)
                control.TitleLabel=label; control.DescLabel=detail
            end
            B.Catalog[#B.Catalog+1]=control
        end
    end
    section("CONTROLE DAS FONTES","Estado das funções recuperadas e bloqueios reversíveis.")
    toggle("Bloquear rebirth nas rotinas integradas","Desliga os pedidos de rebirth pelo 710Hub e pelos módulos importados; desligue para liberar.","BlockAllRebirths")
    card("Diagnóstico Mystery / Silence","Mostra o catálogo, a inicialização e as últimas falhas detectadas.",function()
        local lines={"Elementos de interface integrados: "..#B.Catalog}
        for _,engine in ipairs(B.Engines) do lines[#lines+1]=engine.Name..": "..(engine.Status or "Carrega ao usar a primeira função") end
        for _,line in ipairs(B.Reports) do lines[#lines+1]=line end
        local report=table.concat(lines,"\n")
        if type(setclipboard)=="function" then pcall(setclipboard,report) end
        setHubStatus(report)
    end)
end
initializeSourceBridge()
-- END SOURCE BRIDGE

-- Busca global: ignora acentos e procura em todas as categorias.
do
    local search = Instance.new("TextBox")
    search.Name = "Pesquisar"; search.Size = UDim2.new(1, -91, 0, 40)
    search.Position = UDim2.fromOffset(16, 75); search.BackgroundColor3 = COLORS.Panel2
    search.BorderSizePixel = 0; search.TextColor3 = COLORS.White; search.PlaceholderColor3 = COLORS.Muted
    search.PlaceholderText = "Buscar função em todas as categorias..."
    search.Text = ""; search.ClearTextOnFocus = false; search.TextSize = 15; search.Font = Enum.Font.Gotham
    search.TextXAlignment = Enum.TextXAlignment.Left; search.Parent = main; addCorner(search, 10)
    local padding = Instance.new("UIPadding"); padding.PaddingLeft = UDim.new(0, 12); padding.PaddingRight = UDim.new(0, 12); padding.Parent = search
    UI.Search = search
    addStroke(search,COLORS.Border,1,.5)
    trackConnection(search:GetPropertyChangedSignal("Text"):Connect(function()
        searchQuery = UI:normalize(search.Text):match("^%s*(.-)%s*$")
        UI:refresh(true, false)
    end))
    local larger = Instance.new("TextButton")
    larger.Size = UDim2.fromOffset(51, 40); larger.Position = UDim2.new(1, -67, 0, 75)
    larger.BackgroundColor3 = COLORS.Panel2; larger.TextColor3 = COLORS.Cyan
    larger.Text = "A+"; larger.TextSize = 18; larger.Font = Enum.Font.GothamBold
    larger.BorderSizePixel = 0; larger.Parent = main; addCorner(larger, 10)
    larger.Size = UDim2.fromOffset(40,44)
    larger.TextSize = 13
    UI.Larger = larger
    larger.Activated:Connect(function()
        UI.LargeText = not UI.LargeText
        larger.Text = UI.LargeText and "A−" or "A+"
        UI:resize()
    end)
end
UI.CurrentCategory = "Ajustes"
currentSection = "Encerrar"

card("Encerrar 710Hub", "Desliga as automacoes, restaura os efeitos e remove o painel.", function()
    stopAllAutomations()
    SESSION.Cleanup()
end, COLORS.Red)
UI:resize()
UI:refresh(true, false)
end
initializeUI()

end, function(message)
    return debug.traceback(tostring(message), 2)
end)
if startupOK then
    if startupGui then startupGui:Destroy() end
else
    local env = (getgenv and getgenv()) or _G
    local session = env.__710HubSession
    if session then
        session.Alive = false
        if session.Cleanup then pcall(session.Cleanup) end
    end
    startupStatus("Falha ao abrir. Envie esta mensagem:\n" .. tostring(startupError))
end

