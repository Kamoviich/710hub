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
-- Menu selecionado, com rotinas nativas únicas para Muscle Legends.
-- Features: treino por método, rebirth, boss invertido, PvP filtrado, pets,
-- cristais limitados, roleta, consumíveis, perfis, navegação e Stop All.

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
    Version = "2026.10-rebirth.38",
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
    FastRep=false, FastRepLimit=659, FarmMode="Fast Rep (packs)", PvpFilter="Todos", PetObjective="strength",
    HatchMaxOpens=20, HatchTargetPet="",
    AutoWheel=false, AutoEggs=false, AutoBoosts=false, AutoBestPetObjective=false, AutoEvolveOwned=false,
    SetSpeed=false, SetSize=false, SetFOV=false, InfiniteJump=false, AntiFling=false,
    Spectate=false, ShiftLock=false,
    PvpProtectFriends=false, PvpOnlySelected=false,
    CharacterSpeed=120, CharacterSize=1, CameraFOV=70, ShopCount=1,
    PvpAny=false, PvpGood=false, PvpEvil=false, PvpRadius=150, PvpAttackRange=2.5,
    TrainWeight=false, TrainPushups=false, TrainSitups=false, TrainHandstands=false,
    Train=false, Rebirth=false, Chests=false, Hatch=false, Brawl=false,
    AutoPunch=false, SmartRock=false, LockPosition=false,
    AutoMachine=false, AutoBestMachine=false, StrengthRebirth=false,
    TurboStrength=false, MaxStrengthF2P=false, AutoBoss=false,
    AutoAgility=false, SmartFarm=false,
        PerformanceMode=false, StabilityMode=false, GoalEnabled=false,
    SmartObjective="Força", GoalStat="Strength", GoalValue=nil,
    HatchCrystal="Blue Crystal", FarmSpeed=2, PreserveFarmPets=false, FarmCustom=false, FarmIntervalMs=100, FarmReps=4, RepDelay=.065, HatchDelay=.45,
    RebirthTarget=nil, SelectedMachine=nil,
    LastRebirthAttempt=0,
    RebirthGuard=false, RebirthFloor=0, RebirthInterval=.5,
    BreakEnabled=false, BreakEvery=30, BreakMinutes=5,
    BossAutoLoot=true, BossDefense=true, BossAbove=true, BossDistance=2, BossReturn=true, BossPreference="Qualquer",
    ResumeAfterDeath=true, HealthGuard=true, HealthLow=55, HealthResume=85,
    StallAlerts=true, StallSeconds=60,
    StopAt=nil, ProgressionTarget=nil,
}

local HubRuntime = {
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
    M.AutoKeys = {"FastRep", "Rebirth", "Chests", "Hatch", "AutoPunch",
        "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "PvpAny", "PvpGood", "PvpEvil",
        "SmartRock", "AutoMachine",
        "MaxStrengthF2P", "AutoBoss", "AutoAgility",
        "GoalEnabled",
        "AutoWheel", "AutoEggs", "AutoBoosts", "AutoBestPetObjective", "AutoEvolveOwned",
        "SetSpeed", "SetSize", "SetFOV", "InfiniteJump", "AntiFling", "Spectate", "ShiftLock"}
    local booleans = { "PreserveFarmPets", "FarmCustom", "BossAutoLoot", "BossReturn", "BossDefense", "BossAbove", "ResumeAfterDeath", "HealthGuard", "StallAlerts", "PerformanceMode", "StabilityMode", "RebirthGuard", "BreakEnabled", "PvpProtectFriends", "PvpOnlySelected"}
    local numbers = {
        FastRepLimit = {40, 659},
        CharacterSpeed = {1, 500}, CharacterSize = {1, 100}, CameraFOV = {30, 120}, ShopCount = {1, 20},
        FarmIntervalMs = {1, 5000}, FarmReps = {1, 160}, FarmSpeed = {1, 3}, HatchMaxOpens = {1, 100}, PvpRadius = {10, 500}, PvpAttackRange = {1.5, 5}, RepDelay = {.05, 5}, HatchDelay = {.1, 30}, BossDistance = {2, 12},
        HealthLow = {5, 60}, HealthResume = {65, 100}, StallSeconds = {30, 600},
        GoalValue = {1, 1e15}, RebirthTarget = {1, 1e15}, ProgressionTarget = {1, 1e15},
        RebirthFloor = {0, 1e15}, RebirthInterval = {.5, 30}, BreakEvery = {1, 240}, BreakMinutes = {1, 60},
    }
    local choices = {
        FarmMode={"Fast Rep (packs)","Automático","Peso","Flexões","Abdominais","Parada de mãos","Máquina","Pedras","Esteira"},
        PvpFilter={"Todos","Karma bom","Karma ruim","Selecionado"}, PetObjective={"strength","durability","agility"}, SmartObjective = {"Força", "Durabilidade", "Agilidade", "Rebirths"},
        GoalStat = {"Strength", "Agility", "Durability", "Rebirths"}}
    local strings = {"HatchCrystal", "HatchTargetPet", "SelectedMachine", "BossPreference"}

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
    local trainers = {"FastRep", "Train", "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "TurboStrength", "MaxStrengthF2P", "AutoMachine", "AutoAgility"}
    for i, a in ipairs(trainers) do
        for j = i + 1, #trainers do conflict(a, trainers[j]) end
        conflict(a, "AutoPunch"); conflict(a, "SmartRock")
    end
    for _, key in ipairs({"AutoMachine", "AutoAgility", "SmartRock"}) do conflict(key, "LockPosition") end
    for _, key in ipairs({"TurboStrength", "MaxStrengthF2P", "AutoAgility", "SmartRock", "AutoPunch"}) do conflict(key, "StrengthRebirth") end
    for _, key in ipairs({"Train", "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "TurboStrength", "MaxStrengthF2P", "AutoMachine", "AutoBestMachine", "AutoAgility", "SmartRock", "AutoPunch", "StrengthRebirth", "Rebirth", "LockPosition"}) do conflict("SmartFarm", key) end
    for _, mode in ipairs({"PvpAny", "PvpGood", "PvpEvil"}) do
        for _, key in ipairs(trainers) do conflict(mode, key) end
        for _, key in ipairs({"FastRep", "AutoBoss", "Brawl", "SmartRock", "AutoPunch", "LockPosition", "SmartFarm", "Rebirth", "StrengthRebirth"}) do conflict(mode, key) end
    end
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
                    or ((key == "ShopCount" or key == "HatchMaxOpens") and value % 1 ~= 0) then return nil, key end
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
        for _, key in ipairs({"AutoNovaPhoenix","AutoEquipAfterHatch","AutoEvolveAfterHatch","Train","TurboStrength","SmartFarm","StrengthRebirth","AutoBestMachine","Brawl","HideName","HideStats","PlayerESP","LockPosition","BreakEnabled","RebirthGuard"}) do settings[key]=false end
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
    if ok then return a, b, true end
    setHubError(a)
    return nil, nil, false
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






local function stopAllAutomations()
    S.FastRep=false
    if HubRuntime.FastRep then HubRuntime.FastRep:cancel() end
    if HubRuntime.Clean then HubRuntime.Clean:stopHatch() end
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
    humanoid.AutoRotate=false
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



local function getPetShopFolder()
    local shared = RS:FindFirstChild("shared")
    local runtime = shared and shared:FindFirstChild("runtime")
    return runtime and runtime:FindFirstChild("cPetShopFolder")
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





local function evolveReadyOwned(allowed)
    local token = HubRuntime.Extras and HubRuntime.Extras.Token
    if not SESSION.Alive or not M:canAct() then return false end
    if not R.EvolvePet then return end
    local counts = {}
    local worn = equippedPets()
    for _, entry in ipairs(allOwnedPets()) do
        if not worn[entry.pet] and not entry.pet:GetAttribute("Locked") and not entry.pet:GetAttribute("Favorite") then
        counts[entry.pet.Name] = (counts[entry.pet.Name] or 0) + 1
        end
    end
    for name,count in pairs(counts) do
        local tries = math.floor(count/5)
        for _=1,tries do
            if not SESSION.Alive or not M:canAct() or (allowed and not allowed()) or (HubRuntime.Extras and HubRuntime.Extras.Token ~= token) then return false end
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
    local lastStrength = numberStat("Strength")
    local lastMeasure = os.clock()
    local failures = 0

    while SESSION.Alive and task.wait((M:farmPace())) do
        if M:canAct() and S.MaxStrengthF2P then

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
    check("Cristais disponíveis", canHatch)
    check("Gerenciador de pets", canPetManager)
    check("Pet Shop disponível", canPetShop)
    check("Teleportes disponíveis", function()
        local folder = workspace:FindFirstChild("areaTeleportParts")
        return folder ~= nil and #folder:GetDescendants() > 0
    end)
    check("Modo desempenho disponível", function() return Lighting ~= nil end)
    check("Esteira recomendada encontrada", function() return bestTreadmill() ~= nil end)
    check("Máquina recomendada encontrada", function() return selectBestMachine() ~= nil end)
    check("Catálogo da loja carregado", function() local folder=getPetShopFolder(); return folder~=nil and #folder:GetChildren()>0 end)

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
    lines[#lines+1] = "Remotes encontrados: "..remoteCount.."/7"

    HubRuntime.SelfTestPassed = passed
    HubRuntime.SelfTestFailed = failed
    HubRuntime.SelfTestReport = table.concat(lines, "\n")
    setHubStatus("Autoteste: "..passed.." OK / "..failed.." indisponíveis")

    print("========== 710Hub AUTOTESTE ==========")
    print(HubRuntime.SelfTestReport)
    print("======================================")

    return passed, failed, HubRuntime.SelfTestReport
end





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
    local X = {Token = 0, Saved = setmetatable({}, {__mode = "k"}),
        Whitelist = {}, FriendCache = {}, FriendChecked = {}, Next = {}, Status = "Pronto", SelectedUserId = 0,
        ShopName = "", ReturnPoint = nil}
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
        local model=player.Character
        if model and (model:FindFirstChildOfClass("ForceField") or model:FindFirstChild("spawnProtectionHighlight")) then return false end
        local expires=model and model:GetAttribute("SpawnProtectedUntil")
        if type(expires)=="number" then
            local ok,now=pcall(function() return workspace:GetServerTimeNow() end)
            if not ok or now<expires then return false end
        end
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
                local response,_,sentOK = safeInvoke(remote, item)
                if not sentOK then break end
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
        if S.FastRep then return false end
        if not SESSION.Alive or not M:canAct() or M.PetEquipBusy then return false end
        refreshRemotes()
        local candidates, equipped, slots = {}, equippedPets()
        if not R.EquipPet or slots <= 0 then return false end
        for _, entry in ipairs(allOwnedPets()) do
            local score = self:petScore(entry, S.PetObjective)
            if score then candidates[#candidates+1] = {Pet = entry.pet, Score = score} end
        end
        table.sort(candidates, function(a,b)
            if a.Score ~= b.Score then return a.Score > b.Score end
            if equipped[a.Pet] ~= equipped[b.Pet] then return equipped[a.Pet] == true end
            return tostring(a.Pet) < tostring(b.Pet)
        end)
        if #candidates == 0 then self.Status = "Atributo dos pets indisponível: " .. S.PetObjective; return false end
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
        self:shiftLock()
    end
    function X:stop()
        self.Token += 1
        for _, key in ipairs({"AutoWheel","AutoEggs","AutoBoosts","AutoBestPetObjective","AutoEvolveOwned", "SetSpeed","SetSize","SetFOV","InfiniteJump","AntiFling","Spectate","ShiftLock"}) do S[key] = false end
        self.LastSafe = nil
        for object, saved in pairs(self.Saved) do
            local keys = {}; for key in pairs(saved) do keys[#keys+1] = key end
            for _,key in ipairs(keys) do self:restore(object,key) end
        end
        local camera = workspace.CurrentCamera
        if camera and camera.CameraSubject and not camera.CameraSubject.Parent then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then camera.CameraSubject = hum end
        end
    end
    function X:shiftLock()
        local character=LP.Character
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local camera=workspace.CurrentCamera
        if S.ShiftLock then
            self:remember(UIS,"MouseBehavior",Enum.MouseBehavior.LockCenter)
            if humanoid then self:remember(humanoid,"CameraOffset",Vector3.new(1.75,.5,0)) end
            if root and humanoid and humanoid.Health>0 and camera and M:canAct()
                and not HubRuntime.BossActive and not M.PvpTarget and not S.AutoMachine and not S.AutoAgility then
                self:remember(humanoid,"AutoRotate",false)
                local look=camera.CFrame.LookVector
                local flat=Vector3.new(look.X,0,look.Z)
                if flat.Magnitude>.01 then root.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit) end
            end
        else
            self:restore(UIS,"MouseBehavior")
            if humanoid then self:restore(humanoid,"CameraOffset"); self:restore(humanoid,"AutoRotate") end
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
        if S.AutoEvolveOwned and not S.FastRep and now >= (self.Next.Evolve or 0) then
            self.Next.Evolve = now+5; evolveReadyOwned(function() return S.AutoEvolveOwned end)
        end
    end
    if UIS.JumpRequest then
        trackConnection(UIS.JumpRequest:Connect(function()
            if not SESSION.Alive or not S.InfiniteJump or not M:canAct() then return end
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end))
    end
    if RunService.RenderStepped then trackConnection(RunService.RenderStepped:Connect(function()
        if SESSION.Alive and S.ShiftLock then X:shiftLock() end
    end)) end
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

-- BEGIN CLEAN RUNTIME
local function initializeCleanRuntime()
    local C={HatchToken=0,HatchSent=0,HatchUnconfirmed=0,HatchStatus="Desligado"}
    HubRuntime.Clean=C
    C.Modes={"Fast Rep (packs)","Automático","Peso","Flexões","Abdominais","Parada de mãos","Máquina","Pedras","Esteira"}
    C.ModeKeys={
        ["Fast Rep (packs)"]="FastRep",
        ["Automático"]="MaxStrengthF2P",["Peso"]="TrainWeight",["Flexões"]="TrainPushups",
        ["Abdominais"]="TrainSitups",["Parada de mãos"]="TrainHandstands",
        ["Máquina"]="AutoMachine",["Pedras"]="SmartRock",["Esteira"]="AutoAgility",
    }
    C.FarmKeys={"FastRep","Train","TrainWeight","TrainPushups","TrainSitups","TrainHandstands","TurboStrength",
        "MaxStrengthF2P","AutoMachine","AutoBestMachine","SmartRock","AutoPunch","AutoAgility","SmartFarm","StrengthRebirth"}
    function C:farming()
        for _,key in ipairs(self.FarmKeys) do if S[key] then return true end end
        return false
    end
    function C:clearFarm()
        for _,key in ipairs(self.FarmKeys) do S[key]=false end
        if HubRuntime.FastRep then HubRuntime.FastRep:cancel() end
    end
    function C:available(mode)
        if mode=="Fast Rep (packs)" then return hasCharacter() and getMuscleEvent()~=nil end
        if mode=="Máquina" then return canMachineFarm() end
        if mode=="Pedras" then return canRockFarm() and canPunch() end
        if mode=="Esteira" then return canAgilityFarm() and bestTreadmill()~=nil end
        if mode=="Automático" then return canTrain() or canMachineFarm() end
        local movement=({Peso="Weight",["Flexões"]="Pushups",Abdominais="Situps",["Parada de mãos"]="Handstands"})[mode]
        return movement~=nil and findTrainingTool(movement)~=nil
    end
    function C:startFarm()
        if not self:available(S.FarmMode) then setHubStatus("Método indisponível: "..S.FarmMode); return false end
        M:cancelComparison(); self:clearFarm()
        local key=self.ModeKeys[S.FarmMode]
        S[key]=true; M:resolveConflicts(key)
        if key=="SmartRock" then S.AutoPunch=true end
        setHubStatus("Treino selecionado: "..S.FarmMode)
        return true
    end
    function C:setMode(mode)
        if not table.find(self.Modes,mode) then return false end
        local running=self:farming()
        self:clearFarm(); S.FarmMode=mode
        if running then return self:startFarm() end
        return true
    end
    function C:pvpActive() return S.PvpAny or S.PvpGood or S.PvpEvil end
    function C:startPvp()
        if not findPunchTool() then setHubStatus("Punch indisponível"); return false end
        S.PvpAny,S.PvpGood,S.PvpEvil=false,false,false
        local key=S.PvpFilter=="Karma bom" and "PvpGood" or S.PvpFilter=="Karma ruim" and "PvpEvil" or "PvpAny"
        S.PvpOnlySelected=S.PvpFilter=="Selecionado"
        if S.PvpOnlySelected and not HubRuntime.Extras:selectedPlayer() then setHubStatus("Selecione um jogador presente"); return false end
        S[key]=true; M:resolveConflicts(key)
        if not S.AutoBoss and HubRuntime.BossActive and HubRuntime.StopBoss then HubRuntime.StopBoss() end
        return true
    end
    function C:setFilter(value)
        local running=self:pvpActive()
        S.PvpAny,S.PvpGood,S.PvpEvil=false,false,false; M:stopPvp()
        S.PvpFilter=value; S.PvpOnlySelected=value=="Selecionado"
        if running then return self:startPvp() end
        return true
    end
    function C:stopHatch()
        self.HatchToken+=1; S.Hatch=false
    end
    function C:startHatch()
        self.HatchToken+=1; self.HatchSent=0; self.HatchUnconfirmed=0
        self.HatchStatus="Aguardando abertura"; S.Hatch=true
    end
    function C:targetOwned()
        local wanted=string.lower(S.HatchTargetPet or "")
        if wanted=="" then return false end
        for _,entry in ipairs(allOwnedPets()) do if string.lower(entry.pet.Name)==wanted then return true end end
        return false
    end
    function C:hatchTick()
        if not S.Hatch or not SESSION.Alive or not M:canAct() or M.Comparing or HubRuntime.BossActive then return end
        if self:targetOwned() then self:stopHatch(); self.HatchStatus="Pet alvo encontrado; abertura parada"; return end
        if self.HatchSent>=S.HatchMaxOpens then self:stopHatch(); self.HatchStatus="Limite de aberturas atingido"; return end
        refreshRemotes()
        if not R.Crystal or not R.Crystal:IsA("RemoteFunction") then self:stopHatch(); self.HatchStatus="Canal de cristal indisponível"; return end
        local token=self.HatchToken
        local beforePets,beforeGems=#allOwnedPets(),numberStat("Gems")
        local beforeCalls=HubRuntime.RemoteCalls
        local result,_,sent=safeInvoke(R.Crystal,"openCrystal",S.HatchCrystal)
        if token~=self.HatchToken or not S.Hatch or not SESSION.Alive then return end
        if result==false then self:stopHatch(); self.HatchStatus="Abertura recusada pelo jogo"; return end
        if not sent or HubRuntime.RemoteCalls==beforeCalls then
            if HubRuntime.RemoteCalls>beforeCalls then self:stopHatch(); self.HatchStatus="Erro na abertura: "..HubRuntime.LastError end
            return
        end
        self.HatchSent+=1
        task.wait(math.max(.5,S.HatchDelay))
        if token~=self.HatchToken or not S.Hatch or not SESSION.Alive then return end
        if #allOwnedPets()>beforePets or numberStat("Gems")<beforeGems then self.HatchUnconfirmed=0
        else self.HatchUnconfirmed+=1 end
        self.HatchStatus=string.format("%d/%d solicitações; confirmação no inventário: %s",self.HatchSent,S.HatchMaxOpens,
            self.HatchUnconfirmed==0 and "observada" or "aguardando")
        if self.HatchUnconfirmed>=6 then self:stopHatch(); self.HatchStatus="Parado: seis aberturas sem mudança observada" end
        if self.HatchSent>=S.HatchMaxOpens then self:stopHatch(); self.HatchStatus="Limite atingido; confira o inventário" end
    end
    function C:destinations()
        local result,seen={},{}
        local function add(label,frame)
            local key=string.lower(label)
            if not seen[key] then seen[key]=true; result[#result+1]={Label=label,Value=frame} end
        end
        local loaded=workspace:FindFirstChild("areaTeleportParts")
        if loaded then for _,part in ipairs(loaded:GetDescendants()) do if part:IsA("BasePart") then add(part.Name,part.CFrame+Vector3.new(0,4,0)) end end end
        for _,point in ipairs({
            {"Tiny Island",-37.1,9.2,1919},{"Main Island",16.07,9.08,133.8},{"Beach",-8,9,-169.2},
            {"Overcharged Gym",-2941.766,151.797,4994.552},{"Industrial Gym",-5254.681641,58.342850,4931.850586},
            {"Jungle Gym",-8543,6.8,2400},{"Muscle King Gym",-8665.4,17.21,-5792.9},
            {"Legends Gym",4516,991.5,-3856},{"Infernal Gym",-6759,7.36,-1284},
            {"Mythical Gym",2250,7.37,1073.2},{"Frost Gym",-2623,7.36,-409},
        }) do add(point[1],CFrame.new(point[2],point[3],point[4])) end
        table.sort(result,function(a,b) return a.Label<b.Label end)
        if HubRuntime.Extras.ReturnPoint then table.insert(result,1,{Label="Posição salva nesta sessão",Value=HubRuntime.Extras.ReturnPoint}) end
        return result
    end
    task.spawn(function()
        while SESSION.Alive do
            local ok,err=pcall(function() C:hatchTick() end)
            if not ok then C:stopHatch(); C.HatchStatus="Erro: "..tostring(err); setHubError(C.HatchStatus) end
            task.wait(.1)
        end
    end)
    task.spawn(function()
        while SESSION.Alive and task.wait(.5) do
            if S.StopAt and M:canAct() and not M.Comparing and os.clock()>=S.StopAt then stopAllAutomations(); setHubStatus("Tempo de sessão encerrado") end
        end
    end)
end
initializeCleanRuntime()
-- END CLEAN RUNTIME

-- BEGIN FAST REP RUNTIME
local function initializeFastRep()
    local F={Token=0,Tokens=0,Rate=200,Sent=0,ActiveSeconds=0,BirthFailures=0,
        Gains={Strength=0,Durability=0,Rebirths=0},Recent={},Status="Parado"}
    HubRuntime.FastRep=F
    -- Bonus definitions observed in the readable Silence farming source and Mystery catalog.
    -- Replicated perks take precedence. Reading this table never equips or unequips a pet.
    F.Bonuses={
        ["Omega Overlord"]={20,0,0,0},["Swift Samurai"]={15,0,0,0},
        ["Powercore Hound"]={0,25,15,0},["Titanium Hydra"]={0,0,0,2},
        ["Tribal Overlord"]={0,0,0,2},["Inferno Unicorn"]={0,25,25,0},
        ["Inferno Drake"]={40,0,0,0},["Common Boss Pet"]={5,0,0,0},
        ["Rare Boss Pet"]={7,0,0,0},["Epic Boss Pet"]={10,0,0,0},
        ["Rainbow Boss Pet"]={10,7,0,0},["Legendary Boss Pet"]={10,10,0,0},
        ["Mythic Boss Pet"]={10,20,0,0},
    }
    function F:active()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        return SESSION.Alive and S.FastRep and M:canAct() and not HubRuntime.BossActive
            and not M.PvpTarget and hum and hum.Health>0
    end
    function F:cancel()
        self.Token+=1; self.Tokens=0; self.NextPets=0
        self.LastControl=nil; self.Rate=200; self.NextBirth=nil; self.BirthFailures=0
        self.BirthResult=nil; self.Status="Parado"
    end
    function F:bonus(pet,index)
        local aliases=({{"repSpeed","repSpeedBonus","repSpeedPercent"},{"strengthMultiplier","strengthBonus"},
            {"durabilityMultiplier","durabilityBonus"},{"rebirth","rebirths","rebirthBonus"}})[index]
        local perks=pet:FindFirstChild("perksFolder")
        for _,container in ipairs({perks or pet,pet}) do
            for _,name in ipairs(aliases) do
                local value=container:FindFirstChild(name)
                local n=value and (value:IsA("NumberValue") or value:IsA("IntValue")) and tonumber(value.Value) or container:GetAttribute(name)
                if type(n)=="number" and n==n and n>=0 then return n end
            end
        end
        return (self.Bonuses[pet.Name] or {})[index] or 0
    end
    function F:equippedBonuses()
        local pets,slots=equippedPets()
        local speed,birth=0,0
        for pet in pairs(pets) do
            if typeof(pet)=="Instance" then
                speed+=self:bonus(pet,1); birth+=self:bonus(pet,4)
            end
        end
        self.PetSpeed=speed; self.PetSlots=slots; self.PetBirth=birth
        return speed,birth,slots
    end
    function F:rebirthRequirement()
        for _,name in ipairs({"rebirthStrengthRequirement","RebirthRequirement"}) do
            local value=LP:FindFirstChild(name)
            if value and tonumber(value.Value) then return math.max(0,tonumber(value.Value)) end
        end
        -- Muscle Legends formula used by Silence; a refused request backs off.
        return 5000+currentRebirths()*2550
    end
    function F:rebirth()
        if not self:active() or not S.Rebirth or self.Busy or M.RebirthInFlight or M.PetEquipBusy
            or not M:canRequestRebirth(numberStat("Strength"),currentRebirths())
            or os.clock()<(self.NextBirth or 0)
            or numberStat("Strength")<self:rebirthRequirement() then return end
        local token,before=self.Token,currentRebirths()
        self.Busy=true; M.RebirthInFlight=true
        local ok,err=pcall(function()
            self.Status="Fast rebirth; mantendo seus pets equipados"
            if token~=self.Token or not self:active() or not S.Rebirth then return end
            refreshRemotes(); M.LastRebirthRequest=os.clock()
            local response,_,sent=safeInvoke(R.Rebirth,"rebirthRequest")
            if token~=self.Token or not self:active() then return end
            local deadline=os.clock()+1.5
            while sent and response~=false and currentRebirths()==before and os.clock()<deadline
                and token==self.Token and self:active() do task.wait(.05) end
            if token~=self.Token or not self:active() then return end
            if currentRebirths()>before then
                self.BirthFailures=0; self.NextBirth=M.LastRebirthRequest+S.RebirthInterval
                self.BirthResult="Rebirth confirmado"
                if S.RebirthTarget and currentRebirths()>=S.RebirthTarget then S.Rebirth=false end
                self.Status="Rebirth confirmado; retomando treino"
            else
                self:retryBirth(response==false and "Recusado pelo jogo" or "Sem confirmação na estatística")
            end
        end)
        M.RebirthInFlight=false; self.Busy=false
        if token==self.Token then
            self.LastControl=nil
            if not ok then self:retryBirth("Erro na solicitação"); setHubError(err) end
        end
    end
    function F:retryBirth(message)
        self.BirthFailures=math.min(3,(self.BirthFailures or 0)+1)
        local delay=math.max(S.RebirthInterval,math.min(2,.5*2^(self.BirthFailures-1)))
        self.NextBirth=os.clock()+delay; self.BirthResult=message
    end
    function F:rebirthStatus()
        if not S.Rebirth then return "Rebirth desligado / meta encerrada" end
        if self.Busy then return "Aguardando confirmação; força continua ativa" end
        if numberStat("Strength")<self:rebirthRequirement() then return "Treinando até a força necessária para rebirth" end
        local nextRequest=math.max(self.NextBirth or 0,(M.LastRebirthRequest or -math.huge)+S.RebirthInterval)
        return string.format("%s | espera restante: %.2fs",self.BirthResult or "Pronto para pedir rebirth",math.max(0,nextRequest-os.clock()))
    end
    function F:sample(dt,active)
        local values={Strength=numberStat("Strength"),Durability=numberStat("Durability"),Rebirths=currentRebirths()}
        if active then self.ActiveSeconds+=dt end
        if active and self.Previous and self.WasActive then
            for key,value in pairs(values) do self.Gains[key]+=math.max(0,value-self.Previous[key]) end
        end
        self.Previous=values; self.WasActive=active
        self.Recent[#self.Recent+1]={At=os.clock(),Seconds=self.ActiveSeconds,Sent=self.Sent,
            Strength=self.Gains.Strength,Durability=self.Gains.Durability,Rebirths=self.Gains.Rebirths}
        while #self.Recent>1 and self.Recent[2].At<os.clock()-10 do table.remove(self.Recent,1) end
    end
    function F:frame(dt)
        dt=math.clamp(tonumber(dt) or 1/60,0,.1)
        local active=self:active()==true
        self:sample(dt,active)
        if not active or M.PetEquipBusy then
            self.Tokens=0; self.LastControl=nil; return
        end
        local now=os.clock()
        if now>=(self.NextPets or 0) then self:equippedBonuses(); self.NextPets=now+5 end
        local strength,durability=numberStat("Strength"),numberStat("Durability")
        local limit=math.min(S.FastRepLimit,S.StabilityMode and 200 or 659)
        if not self.LastControl then
            self.LastControl=now; self.ControlStrength=strength; self.ControlDurability=durability; self.ControlBirths=currentRebirths(); self.NoProgress=0
        elseif now-self.LastControl>=.5 then
            if strength>self.ControlStrength or durability>self.ControlDurability or currentRebirths()>self.ControlBirths then
                self.NoProgress=0; self.Rate=math.min(limit,self.Rate*1.12)
            else
                self.NoProgress+=now-self.LastControl
                if self.NoProgress>=2 then self.Rate=math.max(40,self.Rate*.65); self.Tokens=0 end
                if self.NoProgress>=10 then S.FastRep=false; S.Rebirth=false; self:cancel(); self.Status="Parado: 10s sem ganho observado"; return end
            end
            self.LastControl=now; self.ControlStrength=strength; self.ControlDurability=durability; self.ControlBirths=currentRebirths()
        end
        self.Rate=math.min(self.Rate,limit)
        local burst=S.StabilityMode and 8 or 24
        self.Tokens=math.min(burst,self.Tokens+self.Rate*dt)
        local event=getMuscleEvent()
        if not event then S.FastRep=false; self:cancel(); self.Status="Canal de reps indisponível"; return end
        for _=1,math.floor(self.Tokens) do
            if not self:active() then break end
            local ok,err=pcall(function() event:FireServer("rep") end)
            if not ok then S.FastRep=false; self:cancel(); setHubError(err); break end
            self.Tokens-=1; self.Sent+=1; HubRuntime.RemoteCalls+=1
        end
        if S.FastRep then self.Status=string.format("Fast Rep: %.0f reps/s alvo | bônus de velocidade: %s%%",self.Rate,tostring(self.PetSpeed or 0)) end
    end
    function F:report()
        local function compact(value)
            for _,unit in ipairs({{1e18,"Qi"},{1e15,"Qa"},{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
                if math.abs(value)>=unit[1] then return string.format("%.2f%s",value/unit[1],unit[2]) end
            end
            return string.format("%.2f",value)
        end
        local first=self.Recent[1]; local seconds=first and self.ActiveSeconds-first.Seconds or 0
        local rate=seconds>0 and (self.Sent-first.Sent)/seconds or 0
        local lines={self.Status,self:rebirthStatus(),
            "Força para rebirth: "..compact(numberStat("Strength")).." / "..compact(self:rebirthRequirement()),
            "Seus pets equipados são preservados durante força e fast rebirth.",
            string.format("Pets atuais: %d slots | velocidade estimada: %s%% | bônus de rebirth estimado: %s%%",self.PetSlots or 0,tostring(self.PetSpeed or 0),tostring(self.PetBirth or 0)),
            string.format("Pedidos enviados: %.1f/s | total: %d | tempo ativo: %.1fs",rate,self.Sent,self.ActiveSeconds),
            "Ganhos medidos nos valores da conta; pedidos enviados não equivalem a reps aceitas."}
        for _,key in ipairs({"Strength","Durability","Rebirths"}) do
            local pace=seconds>0 and (self.Gains[key]-first[key])/seconds or 0
            local average=self.ActiveSeconds>0 and self.Gains[key]/self.ActiveSeconds or 0
            lines[#lines+1]=string.format("%s: %s | ganho: %s\nÚltimos 10s: %s/s | %s/min | %s/h | %s/d\nMédia ativa: %s/s",key,compact(numberStat(key)),compact(self.Gains[key]),compact(pace),compact(pace*60),compact(pace*3600),compact(pace*86400),compact(average))
        end
        return table.concat(lines,"\n\n")
    end
    local ordinary=M.attemptRebirth
    function M:attemptRebirth() if S.FastRep then return F:rebirth() end; return ordinary(self) end
    trackConnection(RunService.Heartbeat:Connect(function(dt)
        if not SESSION.Alive then return end
        local ok,err=pcall(function() F:frame(dt) end)
        if not ok then S.FastRep=false; F:cancel(); setHubError("Fast Rep: "..tostring(err)) end
    end))

end
initializeFastRep()
-- END FAST REP RUNTIME

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
    for _, render in pairs(toggleRefs) do
        pcall(render)
    end
end
HubRuntime.RenderToggles = renderAllToggles

local toggleTitles = {}
local function resolveToggleConflicts(key)
    if key == "AutoBestPetObjective" and S.AutoBestPetObjective then S.PreserveFarmPets = true end
    local disabled = M:resolveConflicts(key)
    local names = {}
    for _, other in ipairs(disabled) do
        if other == "AutoBoss" and HubRuntime.StopBoss then HubRuntime.StopBoss() end
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

-- BEGIN CLEAN UI
local function cleanUI()
    local C,X=HubRuntime.Clean,HubRuntime.Extras
    local registry={}; UI.Catalog=registry
    local function register(id,kind,title,object,key)
        assert(not registry[id],"Opção duplicada: "..id)
        local item={Id=id,Kind=kind,Title=title,Object=object,Key=key}
        registry[id]=item; object.Name=id
        return item
    end
    local function action(id,title,desc,fn,available)
        local object,label,detail=card(title,desc,fn,COLORS.Green,available)
        local item=register(id,"action",title,object); item.TitleLabel=label; item.Detail=detail
        return item
    end
    local function switch(id,title,desc,key,available,after)
        local object=toggle(title,desc,key,available)
        local item=register(id,"toggle",title,object,key)
        if after then object.Activated:Connect(function() after(S[key]); renderAllToggles() end) end
        return item
    end
    local function input(id,title,value,callback)
        local object=field(title,value,callback); register(id,"input",title,object)
        return object
    end
    local function numeric(id,title,key,low,high,integer)
        return input(id,title,S[key],function(text)
            local value=tonumber((text:gsub(",",".")))
            if not value or value~=value or value<low or value>high or integer and value%1~=0 then
                return false,"Use "..low.." a "..high..(integer and " (inteiro)" or "")
            end
            S[key]=value; return true
        end)
    end
    local function modal(title)
        local old=main:FindFirstChild("710Hub_Choice"); if old then old:Destroy() end
        local overlay=Instance.new("Frame")
        overlay.Name="710Hub_Choice"; overlay.Size=UDim2.fromScale(1,1); overlay.ZIndex=20
        overlay.BackgroundColor3=COLORS.Black; overlay.BackgroundTransparency=.08
        overlay.BorderSizePixel=0; overlay.Active=true; overlay.Parent=main; addCorner(overlay,14)
        local label=UI:label(overlay,title,16,COLORS.White)
        label.Position=UDim2.fromOffset(16,12); label.Size=UDim2.new(1,-86,0,44); label.TextWrapped=true; label.ZIndex=21
        local close=Instance.new("TextButton")
        close.Size=UDim2.fromOffset(48,44); close.Position=UDim2.new(1,-62,0,12)
        close.Text="×"; close.TextSize=24; close.BackgroundColor3=COLORS.Panel2; close.TextColor3=COLORS.White
        close.ZIndex=22; close.Parent=overlay; addCorner(close,8)
        close.Activated:Connect(function() overlay:Destroy() end)
        return overlay
    end
    local function report(title,body)
        local overlay=modal(title)
        local list=Instance.new("ScrollingFrame")
        list.Position=UDim2.fromOffset(16,70); list.Size=UDim2.new(1,-32,1,-86)
        list.CanvasSize=UDim2.new(); list.AutomaticCanvasSize=Enum.AutomaticSize.Y
        list.ScrollBarThickness=5; list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ZIndex=21; list.Parent=overlay
        local text=Instance.new("TextBox")
        text.Text=type(body)=="function" and body() or body; text.TextEditable=false; text.ClearTextOnFocus=false; text.MultiLine=true; text.TextWrapped=true
        text.Size=UDim2.new(1,-12,0,0); text.AutomaticSize=Enum.AutomaticSize.Y; text.TextSize=14
        text.TextXAlignment=Enum.TextXAlignment.Left; text.TextYAlignment=Enum.TextYAlignment.Top
        text.Font=Enum.Font.Gotham; text.TextColor3=COLORS.White; text.BackgroundTransparency=1; text.ZIndex=22; text.Parent=list
        if type(body)=="function" then task.spawn(function()
            while SESSION.Alive and overlay.Parent do text.Text=body(); task.wait(1) end
        end) end
    end
    local function choose(title,options,callback)
        local overlay=modal(title)
        local search=Instance.new("TextBox")
        search.Name="OptionSearch"; search.Text=""; search.PlaceholderText="Pesquisar opção..."; search.ClearTextOnFocus=false
        search.Position=UDim2.fromOffset(16,64); search.Size=UDim2.new(1,-32,0,44)
        search.TextSize=16; search.TextColor3=COLORS.White; search.BackgroundColor3=COLORS.Panel2
        search.ZIndex=22; search.Parent=overlay; addCorner(search,8)
        local list=Instance.new("ScrollingFrame")
        list.Position=UDim2.fromOffset(16,116); list.Size=UDim2.new(1,-32,1,-132)
        list.CanvasSize=UDim2.new(); list.AutomaticCanvasSize=Enum.AutomaticSize.Y
        list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=5; list.ZIndex=21; list.Parent=overlay
        local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,6); layout.Parent=list
        local rows={}
        for index,option in ipairs(options) do
            local button=Instance.new("TextButton")
            button.Name="Option_"..index; button.Text=option.Label; button.TextWrapped=true
            button.Size=UDim2.new(1,-10,0,52); button.TextSize=14; button.TextColor3=COLORS.White
            button.BackgroundColor3=COLORS.Panel2; button.LayoutOrder=index; button.ZIndex=22; button.Parent=list; addCorner(button,8)
            rows[#rows+1]={Object=button,Text=UI:normalize(option.Label)}
            button.Activated:Connect(function() overlay:Destroy(); callback(option.Value) end)
        end
        local empty=UI:label(list,"Nenhuma opção disponível",14,COLORS.Muted)
        empty.Size=UDim2.new(1,-10,0,52); empty.ZIndex=22
        local function filter()
            local count,query=0,UI:normalize(search.Text)
            for _,row in ipairs(rows) do row.Object.Visible=row.Text:find(query,1,true)~=nil; if row.Object.Visible then count+=1 end end
            empty.Visible=count==0; list.CanvasPosition=Vector2.new()
        end
        search:GetPropertyChangedSignal("Text"):Connect(filter); filter()
    end
    UI.Choose=choose; UI.Report=report
    local function choices(id,title,desc,values,callback,available)
        return action(id,title,desc,function()
            local items=type(values)=="function" and values() or values
            choose(title,items,callback)
        end,available)
    end
    local function strings(values)
        local out={}; for _,value in ipairs(values) do out[#out+1]={Label=value,Value=value} end; return out
    end
    local function group(name,category,desc) UI.Groups[name]=category; section(name,desc) end

    group("TREINO","Farm","Um controlador de treino, com método escolhido e limites de carga.")
    choices("farm_method","Método de treino","Fast Rep ajusta o ritmo pelos ganhos reais; Automático escolhe máquina ou ferramenta.",strings(C.Modes),function(mode) C:setMode(mode); renderAllToggles() end)
    local farm=action("farm_start","Iniciar / parar treino","Inicia o método selecionado; aguarda durante combate com boss.",function()
        if C:farming() then C:clearFarm() else C:startFarm() end
        renderAllToggles()
    end)
    choices("machine_select","Máquina do treino","Lista atual do mapa; aparece ao escolher o método Máquina.",function()
        local out={}; for _,machine in ipairs(scanMachines()) do out[#out+1]={Label=machine.name,Value=machine.name} end; return out
    end,function(name) S.SelectedMachine=name end,function() return S.FarmMode=="Máquina" and canMachineFarm() end)
    numeric("fast_rep_limit","Fast Rep: limite de reps/s (40–659)","FastRepLimit",40,659,true)
    local pace=action("farm_pace","Rendimento do Fast Rep","Força, durabilidade, rebirths e pedidos enviados; atualiza a cada segundo sem alterar seus pets.",function() report("Rendimento observado",function() return HubRuntime.FastRep:report() end) end)
    input("farm_interval","Outros métodos: intervalo em rajada (ms)",S.FarmIntervalMs,function(value) return M:setFarmTiming("FarmIntervalMs",value) end)
    input("farm_reps","Outros métodos: reps por ciclo em rajada",S.FarmReps,function(value) return M:setFarmTiming("FarmReps",value) end)
    switch("rebirth_auto","Fast rebirth / rebirth automático","Junto ao Fast Rep, treina até o requisito, solicita rebirth e retoma força com seus pets atuais; confirma a meta na conta.","Rebirth",canRebirth)
    numeric("rebirth_interval","Intervalo entre rebirths (segundos)","RebirthInterval",.5,30)
    input("rebirth_target","Meta absoluta de rebirths (0 = sem limite)",S.RebirthTarget or 0,function(value)
        local n=tonumber(value); if not n or n~=n or n%1~=0 or n<0 or n>1e15 then return false,"Use um inteiro de 0 a 1e15" end
        S.RebirthTarget=n>0 and n or nil; return true
    end)
    switch("chests_auto","Coletar baús","Solicita somente os baús conhecidos; o jogo valida elegibilidade e intervalo.","Chests",canChestFarm)
    switch("wheel_auto","Roleta automática","No máximo um pedido a cada 5 segundos; usa os giros da conta.","AutoWheel",function() return X:fortuneCatalog()~=nil and rEvents:FindFirstChild("openFortuneWheelRemote")~=nil end)
    switch("eggs_auto","Consumir Protein Eggs","Consome ovos possuídos, um item por vez.","AutoEggs")
    switch("boosts_auto","Consumir shakes e barras","Consome itens possuídos, com intervalo por item.","AutoBoosts")

    group("BOSS","Bosses","Uma rotina de ataque com prioridade de raridade e recuperação de vida.")
    switch("boss_auto","Auto Kill Boss / farm de boss","Reconhece bosses carregados, acompanha o alvo e usa Punch.","AutoBoss",canAutoBoss)
    switch("boss_above","Atacar acima do boss de cabeça para baixo","Mantém a pose invertida acima da cabeça; a altura precisa permitir alcance do soco.","BossAbove")
    numeric("boss_height","Altura / distância do boss (studs)","BossDistance",2,12)
    switch("boss_loot","Coletar drops do boss","Tenta interagir com recompensas novas próximas do boss.","BossAutoLoot")
    switch("boss_return","Retornar depois do boss","Retorna ao ponto salvo no início do combate.","BossReturn")
    switch("boss_defense","Recuar após dano","Libera a pose invertida e aguarda após perder vida.","BossDefense")
    switch("health_guard","Proteção de vida baixa","Suspende ataque para recuperação antes de continuar.","HealthGuard")
    input("health_limits","Vida: recuar / retomar (%)",S.HealthLow.." / "..S.HealthResume,function(text)
        local low,high=text:match("^%s*(%d+)%s*/%s*(%d+)%s*$"); low,high=tonumber(low),tonumber(high)
        if not low or not high or low<5 or low>60 or high<65 or high>100 then return false,"Exemplo: 55 / 85; recuo 5–60, retomada 65–100" end
        S.HealthLow,S.HealthResume=low,high; return true
    end)
    local boss=action("boss_status","Estado do boss","Aguardando",function() report("Boss",M:bossDiagnostic()) end)

    group("JOGADORES","PvP","Um controlador de PvP, com proteção de contas e filtro de karma.")
    choices("player_select","Selecionar jogador","Usa UserId; nome de exibição e @usuário ajudam a identificar a conta.",function() return X:playerOptions() end,function(id) X.SelectedUserId=id end)
    choices("pvp_filter","Filtro do PvP","Todos, karma bom, karma ruim ou apenas a conta selecionada.",strings({"Todos","Karma bom","Karma ruim","Selecionado"}),function(value) C:setFilter(value); renderAllToggles() end)
    local pvp=action("pvp_start","Iniciar / parar PvP","Aproxima e usa Punch; ignora spawn protegido e contas da lista de proteção.",function()
        if C:pvpActive() then S.PvpAny,S.PvpGood,S.PvpEvil=false,false,false; M:stopPvp() else C:startPvp() end
        renderAllToggles()
    end)
    switch("pvp_friends","Proteger amigos no PvP","Consultas de amizade ocorrem fora do combate; pendentes ficam protegidas.","PvpProtectFriends")
    action("player_protect","Proteger / liberar jogador","Alterna a proteção da conta selecionada nesta sessão.",function()
        local player=X:selectedPlayer(); if not player then setHubStatus("Selecione um jogador presente"); return end
        X.Whitelist[player.UserId]=not X.Whitelist[player.UserId] and true or nil
        setHubStatus(X.Whitelist[player.UserId] and "Conta protegida" or "Proteção removida")
    end)
    switch("spectate","Observar jogador","Acompanha a câmera do alvo; restaura ao desligar ou se ele sair.","Spectate")
    action("player_stats","Ver estatísticas do jogador","Exibe apenas os valores replicados e a vida atual.",function()
        local player=X:selectedPlayer(); if not player then setHubStatus("Selecione um jogador presente"); return end
        local lines={"@"..player.Name.." | UserId: "..player.UserId}
        for _,key in ipairs({"Strength","Durability","Agility","Rebirths","goodKarma","evilKarma"}) do lines[#lines+1]=key..": "..tostring(M:playerKarma(player,{key}) or "indisponível") end
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        lines[#lines+1]=hum and string.format("Vida: %.0f / %.0f",hum.Health,hum.MaxHealth) or "Personagem ausente"
        report("Jogador",table.concat(lines,"\n"))
    end)

    group("COLEÇÃO E CRISTAIS","Pets","Um gerenciador de pets, abertura com limite e compra manual por lote.")
    choices("pet_attribute","Prioridade dos pets","Usa atributos legíveis dos pets possuídos; preserva a coleção se faltarem dados.",{
        {Label="Força",Value="strength"},{Label="Durabilidade",Value="durability"},{Label="Agilidade",Value="agility"},
    },function(value) S.PetObjective=value; if S.AutoBestPetObjective then X:equipObjective() end end)
    switch("pets_auto","Equipar melhores pets automaticamente","Aplica a prioridade agora e reavalia a cada 10 segundos.","AutoBestPetObjective",canPetManager,function(enabled)
        if enabled then S.PreserveFarmPets=true; X:equipObjective() end
    end)
    switch("evolve_auto","Evoluir pets repetidos","Usa grupos de cinco; preserva pets equipados, bloqueados e favoritos.","AutoEvolveOwned",function() return R.EvolvePet~=nil end)
    choices("crystal_select","Cristal para abrir","Lista de cristais conhecidos; confirme preço e elegibilidade no jogo.",strings({
        "Blue Crystal","Green Crystal","Mythical Crystal","Frost Crystal","Inferno Crystal","Legends Crystal",
        "Muscle Elite Crystal","Galaxy Oracle Crystal","Jungle Crystal","Charged Crystal",
    }),function(name) if S.Hatch then C:stopHatch() end; S.HatchCrystal=name end,canHatch)
    numeric("hatch_limit","Máximo de aberturas (1 a 100)","HatchMaxOpens",1,100,true)
    input("hatch_target","Pet alvo opcional (nome exato)",S.HatchTargetPet,function(value)
        local name=value:match("^%s*(.-)%s*$"); if #name>80 then return false,"Use até 80 caracteres" end
        if S.Hatch then return false,"Pare a abertura antes de mudar o alvo" end
        S.HatchTargetPet=name; return true
    end)
    switch("hatch_auto","Abrir cristal com limite","Para no limite, ao encontrar o alvo ou após recusas/falta de progresso.","Hatch",canHatch,function(enabled) if enabled then C:startHatch() else C:stopHatch() end end)
    local hatch=action("hatch_status","Estado das aberturas","Desligado",nil)
    choices("shop_select","Selecionar pet ou aura da loja","Catálogo atual, sem inventar itens nem usar nomes aproximados.",function() return X:shopOptions() end,function(name) X.Token+=1; X.ShopName=name end,canPetShop)
    numeric("shop_count","Quantidade de compras (1 a 20)","ShopCount",1,20,true)
    action("shop_buy","Comprar lote selecionado","Gasta a moeda do jogo; uma compra por vez, com cancelamento das restantes.",function() X:buyBatch() end,canPetShop)

    group("OBJETIVOS","Metas","Uma meta de parada e um temporizador da sessão.")
    choices("goal_stat","Estatística da meta","Escolha qual valor encerra as automações.",strings({"Strength","Durability","Agility","Rebirths"}),function(value) S.GoalStat=value end)
    input("goal_value","Valor absoluto da meta",S.GoalValue or "",function(value) return M:setGoal(value) end)
    switch("goal_enabled","Parar ao atingir a meta","Encerra as rotinas quando o valor configurado for observado.","GoalEnabled",function() return S.GoalValue~=nil end)
    input("stop_minutes","Encerrar após minutos ativos (0 = desligado)",0,function(value)
        local minutes=tonumber((value:gsub(",",".")))
        if not minutes or minutes~=minutes or minutes<0 or minutes>240 then return false,"Use 0 a 240 minutos" end
        S.StopAt=minutes>0 and os.clock()+minutes*60 or nil; return true
    end)

    group("PERFIS SALVOS","Perfis","Três configurações; o carregamento começa em pausa.")
    choices("profile_slot","Slot do perfil","Escolha um dos três slots.",strings({"1","2","3"}),function(value) M.ProfileSlot=tonumber(value) end)
    action("profile_save","Salvar perfil","Salva a configuração na sessão ou em disco quando disponível.",function() local _,message=M:saveProfile(); report("Perfil",message) end)
    action("profile_load","Carregar perfil","Restaura configurações em pausa; PvP não inicia automaticamente.",function()
        X.Token+=1; C:stopHatch(); local _,message=M:loadProfile(); report("Perfil",message)
        if UI.SyncFields then UI.SyncFields() end
        renderAllToggles()
    end)
    switch("resume_death","Retomar depois de morrer","Aguarda personagem e ferramentas; desligado requer Retomar manualmente.","ResumeAfterDeath")

    group("SESSÃO E DIAGNÓSTICO","Sessão","Estado real das rotinas, histórico e verificação de dependências.")
    local status=action("session_status","Estado da sessão","Inicializando",nil)
    action("history","Histórico da sessão","Mostra eventos, pausas e ganhos observados em um único relatório.",function() report("Histórico",M:report()) end)
    action("self_test","Verificar dependências","Confere objetos e APIs; não compra itens nem concede atributos.",function()
        local _,_,body=runSelfTest(); report("Dependências",body)
    end)

    group("PREFERÊNCIAS E NAVEGAÇÃO","Ajustes","Controles reversíveis para celular e PC.")
    choices("teleport","Teleportar","Lista única: pontos carregados, academias conhecidas e posição salva.",function() return C:destinations() end,function(frame) task.spawn(function() X:travel(frame) end) end)
    action("save_position","Salvar posição atual","Adiciona seu ponto atual à lista de teleportes desta sessão.",function()
        local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if root then X.ReturnPoint=root.CFrame; setHubStatus("Posição salva") end
    end)
    local stable=switch("stability","Modo estável","Limita chamadas e reduz carga quando os FPS caem.","StabilityMode",nil,function(desired)
        S.StabilityMode=not desired; setStabilityMode(desired)
    end)
    switch("performance","Reduzir efeitos gráficos","Reduz efeitos locais e restaura as propriedades ao desligar.","PerformanceMode",nil,function(desired)
        S.PerformanceMode=not desired; setPerformanceMode(desired)
    end)
    numeric("character_speed","Velocidade do personagem", "CharacterSpeed",1,500)
    switch("speed_enabled","Aplicar velocidade","Solicita o valor a cada 2 segundos; o jogo valida o limite.","SetSpeed",function() return rEvents:FindFirstChild("changeSpeedSizeRemote")~=nil end)
    numeric("character_size","Tamanho do personagem", "CharacterSize",1,100)
    switch("size_enabled","Aplicar tamanho","Usa o canal conhecido de alteração de tamanho.","SetSize",function() return rEvents:FindFirstChild("changeSpeedSizeRemote")~=nil end)
    numeric("camera_fov","Campo de visão", "CameraFOV",30,120)
    switch("fov_enabled","Aplicar campo de visão","Restaura o FOV anterior ao desligar ou encerrar.","SetFOV")
    switch("shiftlock","Shiftlock","Trava o cursor e desloca a câmera; clique novamente para liberar.","ShiftLock")
    switch("jump","Pulo contínuo","Usa o comando de salto do Roblox, incluindo o botão de celular.","InfiniteJump")
    switch("antifling","Proteção contra arremesso","Reage a velocidades anormais sem disputar posicionamento de combate.","AntiFling")
    action("rejoin","Reentrar na sessão","Para as rotinas e solicita retorno ao servidor atual.",function()
        stopAllAutomations(); TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LP)
    end)
    action("close","Encerrar 710Hub","Para as rotinas, restaura efeitos e remove o painel.",function() stopAllAutomations(); SESSION.Cleanup() end)

    function UI:syncFields()
        for id,key in pairs({fast_rep_limit="FastRepLimit",farm_interval="FarmIntervalMs",farm_reps="FarmReps",rebirth_interval="RebirthInterval",
            boss_height="BossDistance",hatch_limit="HatchMaxOpens",hatch_target="HatchTargetPet",shop_count="ShopCount",
            character_speed="CharacterSpeed",character_size="CharacterSize",camera_fov="CameraFOV"}) do
            registry[id].Object.Text=tostring(S[key]); registry[id].Object.TextColor3=COLORS.White
        end
        registry.rebirth_target.Object.Text=tostring(S.RebirthTarget or 0)
        registry.goal_value.Object.Text=tostring(S.GoalValue or "")
        registry.health_limits.Object.Text=S.HealthLow.." / "..S.HealthResume
    end
    UI.SyncFields=function() UI:syncFields() end

    task.spawn(function()
        while SESSION.Alive do
            pace.Detail.Text=HubRuntime.FastRep.Status.." | "..HubRuntime.FastRep:rebirthStatus()
            farm.Detail.Text="Método: "..S.FarmMode.." | "..(C:farming() and "Ativo" or "Desligado")
            pvp.Detail.Text="Filtro: "..S.PvpFilter.." | "..(M.PvpStatus or "Desligado")
            boss.Detail.Text=(M.BossState or "Aguardando").." | "..HubRuntime.BossTarget
            hatch.Detail.Text=C.HatchStatus
            status.Detail.Text=M:reasonText().." | FPS: "..math.floor(HubRuntime.AvgFPS).." | "..HubRuntime.Status
                .."\nÚltimo erro: "..HubRuntime.LastError
            registry.pet_attribute.Detail.Text="Prioridade: "..S.PetObjective.." | usa valores legíveis dos pets possuídos"
            registry.crystal_select.Detail.Text="Cristal: "..S.HatchCrystal.." | confira preço e elegibilidade no jogo"
            registry.shop_select.Detail.Text="Selecionado: "..(X.ShopName~="" and X.ShopName or "nenhum item")
            local player=X:selectedPlayer()
            registry.player_select.Detail.Text=player and ("@"..player.Name.." | UserId: "..player.UserId) or "Nenhum jogador presente selecionado"
            registry.goal_stat.Detail.Text="Estatística: "..S.GoalStat
            registry.profile_slot.Detail.Text="Slot ativo: "..M.ProfileSlot
            task.wait(1)
        end
    end)
    setHubStatus("Pronto • "..SESSION.Version)
end
cleanUI()
-- END CLEAN UI

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

