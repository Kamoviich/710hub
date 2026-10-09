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
    Version = "2026.10-daily.31",
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
    BossAutoLoot=true, BossDefense=true, BossDistance=3, BossReturn=true, BossPreference="Qualquer",
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
        "AutoEquipAfterHatch", "AutoEvolveAfterHatch", "GoalEnabled"}
    local booleans = {"PreserveFarmPets", "FarmCustom", "BossAutoLoot", "BossReturn", "BossDefense", "ResumeAfterDeath", "HealthGuard", "StallAlerts", "PerformanceMode", "StabilityMode", "RebirthGuard", "BreakEnabled"}
    local numbers = {
        FarmIntervalMs = {1, 5000}, FarmReps = {1, 160}, FarmSpeed = {1, 3}, NovaMaxOpens = {1, 1000}, PvpRadius = {10, 500}, PvpAttackRange = {1.5, 5}, RepDelay = {.05, 5}, HatchDelay = {.1, 30}, BossDistance = {2, 12},
        HealthLow = {5, 60}, HealthResume = {65, 100}, StallSeconds = {30, 600},
        GoalValue = {1, 1e15}, RebirthTarget = {1, 1e15}, ProgressionTarget = {1, 1e15},
        RebirthFloor = {0, 1e15}, RebirthInterval = {.5, 30}, BreakEvery = {1, 240}, BreakMinutes = {1, 60},
    }
    local choices = {SmartObjective = {"Força", "Durabilidade", "Agilidade", "Rebirths"},
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
                if type(value) ~= "number" or value ~= value or value < bounds[1] or value > bounds[2] then return nil, key end
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
        for _, group in ipairs({
            {"Arco-iris", "rainbow", "arco"}, {"Mitico", "mythic", "mitico"},
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

return {root = bossRoot, health = bossHumanoid, matches = modelHasBossMarker}
end
end)()(workspace, Players, S)
-- END MAINTENANCE DETECTOR
local bossRoot, bossHumanoid, modelHasBossMarker = BossDetector.root, BossDetector.health, BossDetector.matches

function M:scanBosses(force)
    if not force and self.BossScanAt and os.clock() - self.BossScanAt < 2 then return self.BossScanCache end
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

local function findAliveBoss()
    local candidates = {}
    for _, candidate in ipairs(M:scanBosses()) do
        if candidate.Parent and modelHasBossMarker(candidate) then candidates[#candidates + 1] = candidate end
    end

    if S.BossPreference ~= "Qualquer" then
        local preferred = {}
        for _, candidate in ipairs(candidates) do
            if string.lower(candidate.Name) == string.lower(S.BossPreference) then preferred[#preferred + 1] = candidate end
        end
        if #preferred > 0 then candidates = preferred end
    end
    if #candidates == 0 then return nil end

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return candidates[1] end

    table.sort(candidates, function(a,b)
        local ar, br = bossRoot(a), bossRoot(b)
        if not ar then return false end
        if not br then return true end
        return (ar.Position-root.Position).Magnitude < (br.Position-root.Position).Magnitude
    end)

    return candidates[1]
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
        M:resetBossDefense()
        HubRuntime.BossReturnCFrame = root.CFrame
    end

    M.BossLootBaseline = BossLoot:snapshot()
    M.BossRewardWasVisible = BossLoot:rewardText(LP:FindFirstChildOfClass("PlayerGui")) ~= nil
    M.BossLootResult = "Aguardando fim do combate"
    M.BossLastPosition = bossRoot(target) and bossRoot(target).Position
    HubRuntime.BossActive = true
    HubRuntime.BossModel = target
    HubRuntime.BossTarget = target.Name
    return true
end

local function finishBossFight(returnToStart)
    M.BossLootUntil, M.BossLootAttempted = nil, nil
    M:resetBossDefense()
    HubRuntime.BossModel = nil
    local wasActive = HubRuntime.BossActive
    HubRuntime.BossActive = false
    HubRuntime.BossTarget = "Aguardando spawn"

    if wasActive and returnToStart and S.BossReturn and HubRuntime.BossReturnCFrame then
        local character = LP.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                root.CFrame = HubRuntime.BossReturnCFrame
                root.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end

    HubRuntime.BossReturnCFrame = nil
end
HubRuntime.StopBoss = function() finishBossFight(false) end


function M:setBossState(value)
    self.BossState = value
end
function M:bossPosition(root, humanoid, target, character, distance, lateral)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, target}
    params.RespectCanCollide = true
    local targetRoot = bossRoot(target)
    if not targetRoot then return nil end
    local desired = targetRoot.Position - targetRoot.CFrame.LookVector * distance + targetRoot.CFrame.RightVector * lateral
    local hit = workspace:Raycast(desired + Vector3.new(0, 10, 0), Vector3.new(0, -35, 0), params)
    if not hit or hit.Normal.Y < .65 or hit.Material == Enum.Material.Water then return nil end
    if math.abs(hit.Position.Y - root.Position.Y) > 14 then return nil end
    local position = hit.Position + Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
    return CFrame.lookAt(position, Vector3.new(targetRoot.Position.X, position.Y, targetRoot.Position.Z))
end

task.spawn(function()
    local currentBoss, nextScan, blockedSince = nil, 0, nil
    while SESSION.Alive and task.wait(.2) do
        local ok, failure = pcall(function()
            -- Always process stop, even during manual pause or recovery.
            if not S.AutoBoss then
                if HubRuntime.BossActive then finishBossFight(false) else M:resetBossDefense() end
                currentBoss, blockedSince = nil, nil
                M:setBossState("Desligado")
                return
            end
            if not M:bossMayMove() then M:setBossState("Pausado: " .. M:reasonText()); return end
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
            end
            if not currentBoss and os.clock() >= nextScan then
                nextScan = os.clock() + 2
                currentBoss = findAliveBoss()
                if currentBoss then beginBossFight(currentBoss) end
            end
            if not currentBoss then M:setBossState("Aguardando boss reconhecido"); return end
            local character = LP.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid or humanoid.Health <= 0 then
                finishBossFight(false); currentBoss = nil; M:setBossState("Aguardando personagem"); return
            end
            M.BossLastPosition = bossRoot(currentBoss).Position
            local retreat = M:bossRetreat(humanoid.Health, humanoid.MaxHealth)
            if retreat then
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
                        S.AutoBoss = false; finishBossFight(false)
                        setHubError("Auto Boss parado: sem local seguro. Reposicione e ligue novamente.")
                    end
                else
                    blockedSince = nil
                    M:setBossState(M.BossRecovering and ("Recuperando vida ate " .. S.HealthResume .. "%") or "Recuo apos dano")
                end
                return -- no punches while recovering; hold the chosen retreat location.
            end
            local position = M:bossPosition(root, humanoid, currentBoss, character, S.BossDistance, 0)
            if not position then
                blockedSince = blockedSince or os.clock()
                M:setBossState("Sem piso seguro para atacar")
                if os.clock() - blockedSince >= 5 then
                    S.AutoBoss = false; finishBossFight(false)
                    setHubError("Auto Boss parado: posicao de ataque indisponivel.")
                end
                return
            end
            blockedSince = nil
            root.CFrame = position
            root.AssemblyLinearVelocity = Vector3.zero
            if not findPunchTool() then
                S.AutoBoss = false; finishBossFight(false)
                setHubError("Auto Boss parado: ferramenta Punch indisponivel.")
                return
            end
            if M:canAct() and S.AutoBoss then
                if M.BossDamageModel ~= currentBoss then
                    M.BossDamageModel, M.BossObservedHealth, M.BossLastDamageAt = currentBoss, health.Health, os.clock()
                elseif health.Health < (M.BossObservedHealth or health.Health) then M.BossLastDamageAt = os.clock() end
                M.BossObservedHealth = health.Health
                local target = currentBoss
                local punched, reason = doAnimatedPunch(function()
                    local hp = bossHumanoid(target)
                    return S.AutoBoss and M:canAct() and LP.Character == character and target.Parent ~= nil
                        and HubRuntime.BossModel == target and hp and hp.Health > 0
                end)
                if not punched then M:setBossState(reason or "Soco indisponivel")
                elseif os.clock() - M.BossLastDamageAt >= 8 then M:setBossState("Sem queda de vida ha 8s; ajuste a distancia")
                else M:setBossState("Punch ativo: " .. currentBoss.Name) end
            end
        end)
        if not ok then
            S.AutoBoss = false; finishBossFight(false); currentBoss = nil
            M:setBossState("Erro: abra o diagnostico")
            M:log("Erro no boss", tostring(failure)); setHubError("Auto Boss interrompido: " .. tostring(failure))
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
    if not SESSION.Alive or not M:canAct() then return false end
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
    return hasCharacter() and canPunch()
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
        local texts = {boss.Name}
        local hum = boss:FindFirstChildWhichIsA("Humanoid", true)
        if hum then texts[#texts + 1] = hum.DisplayName end
        for _, key in ipairs({"Rarity", "BossType", "Tier"}) do
            local value = boss:GetAttribute(key)
            if type(value) == "string" then texts[#texts + 1] = value end
        end
        for _, obj in ipairs(boss:GetDescendants()) do
            if obj:IsA("TextLabel") then texts[#texts + 1] = obj.Text end
        end
        local rarity = self:bossRarity(table.concat(texts, " "))
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
                    if not otherRoot or not otherHum or otherHum.Health <= 0 then reason = "missing"
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
    ContentWidth = 730, LargeText = false, Stats = {}, TabBadges = {}, TabLabels = {}}
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
    self.Width = math.max(280, math.min(980, viewport.X - 28))
    local height = math.max(300, math.min(760, viewport.Y - 40))
    self.Compact = self.Width < 680
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
        self.Nav.Size = self.Compact and UDim2.new(1,-40,0,39) or UDim2.new(0,168,1,-349)
        self.Nav.ScrollingDirection = self.Compact and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
        self.Nav.AutomaticCanvasSize = self.Compact and Enum.AutomaticSize.X or Enum.AutomaticSize.Y
        self.NavLayout.FillDirection = self.Compact and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        for category,tab in pairs(self.Tabs) do
            tab.Size = UDim2.fromOffset(self.Compact and 108 or 168,self.Compact and 36 or 42)
            if self.TabBadges[category] then self.TabBadges[category].Visible = not self.Compact end
            if self.TabLabels[category] then self.TabLabels[category].Size = UDim2.new(1,self.Compact and -42 or -72,0,16) end
        end
    end
    if self.Search then
        self.Search.Position = UDim2.fromOffset(left,self.Compact and 236 or 249)
        self.Search.Size = UDim2.new(0,self.ContentWidth-50,0,38)
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
        scroll.Position = UDim2.fromOffset(left,self.Compact and 184 or 202)
        scroll.Size = UDim2.new(0,self.ContentWidth,1,self.Compact and -252 or -270)
        if self.Nav then
            self.Nav.Position = UDim2.fromOffset(self.Compact and 20 or 28,self.Compact and 92 or 136)
            self.Nav.Size = self.Compact and UDim2.new(1,-40,0,36) or UDim2.new(0,168,1,-253)
        end
        if self.Search then self.Search.Position = UDim2.fromOffset(left,self.Compact and 136 or 154) end
        if self.Larger then self.Larger.Position = UDim2.new(1,-60,0,self.Compact and 136 or 154) end
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
    bottom.Size = UDim2.new(1, -40, 0, 44); bottom.Position = UDim2.new(0, 20, 1, -60)
    bottom.BackgroundColor3 = COLORS.Panel; bottom.BorderSizePixel = 0; bottom.Parent = main; addCorner(bottom, 10)
    local pause = Instance.new("TextButton")
    pause.Size = UDim2.fromOffset(90, 32); pause.Position = UDim2.new(1, -198, 0, 5)
    pause.TextSize = 13; pause.Font = Enum.Font.GothamBold; pause.BackgroundColor3 = COLORS.GreenDark
    pause.TextColor3 = COLORS.Green; pause.BorderSizePixel = 0; pause.Parent = bottom; addCorner(pause, 8)
    pause.Activated:Connect(function() M:pause("Manual", not M.Reasons.Manual) end)
    local stop = Instance.new("TextButton")
    stop.Size = UDim2.fromOffset(96, 32); stop.Position = UDim2.new(1, -102, 0, 5)
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
        local width = math.max(80, UI.ContentWidth - 43 - reserve)
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
local menuOpen = true
local function hideMenu()
    menuOpen = false; main.Visible = false; shadow.Visible = false; mini.Visible = true
end
local function showMenu()
    menuOpen = true; mini.Visible = false; main.Visible = true; shadow.Visible = true
    UI:refresh(false, true)
end
minimize.Activated:Connect(hideMenu)
mini.Activated:Connect(showMenu)

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
    "Fica aguardando qualquer boss detectado no mapa; quando ele aparece, equipa Punch e ataca até o Humanoid acabar.",
    "AutoBoss",
    canAutoBoss
)

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
    card("Distancia do boss: " .. S.BossDistance, "Alterna a distancia de ataque entre 3, 5 e 7 studs.", function(_, titleLabel)
        S.BossDistance = S.BossDistance == 3 and 5 or (S.BossDistance == 5 and 7 or 3)
        titleLabel.Text = "Distancia do boss: " .. S.BossDistance
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
    entry.Daily = UI.DailyTitles[title] == true
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
        input.Size = UDim2.new(1, -24, 0, 38)
        frame.Size = UDim2.new(1, -9, 0, height + 65)
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
    "Clique para alternar entre os cristais disponíveis.",
    function(_,titleLabel)
        crystalIndex = crystalIndex % #crystals + 1
        S.HatchCrystal = crystals[crystalIndex]
        titleLabel.Text = "Cristal selecionado: "..S.HatchCrystal
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
    "Clique para trocar o destino do teleporte.",
    function(_,titleLabel)
        if #tpNames == 0 then return end
        tpIndex = tpIndex % #tpNames + 1
        titleLabel.Text = "Destino: "..tpNames[tpIndex]
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
    field("Boss preferido (Qualquer ou nome exato)", S.BossPreference, function(value)
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
    larger.Size = UDim2.fromOffset(40,38)
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

