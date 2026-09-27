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
local previousSession = ENV.__710HubSession
if previousSession then
    previousSession.Alive = false
    if previousSession.Cleanup then
        pcall(previousSession.Cleanup)
    end
end

local SESSION = {
    Alive = true,
    Version = "2026.09-neon.14",
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
    Train=false, Rebirth=false, Chests=false, Hatch=false, Brawl=false,
    AutoPunch=false, SmartRock=false, LockPosition=false,
    AutoMachine=false, AutoBestMachine=false, StrengthRebirth=false,
    TurboStrength=false, MaxStrengthF2P=false, AutoBoss=false,
    AutoAgility=false, SmartFarm=false,
    AutoEquipAfterHatch=false, AutoEvolveAfterHatch=false,
    PerformanceMode=false, StabilityMode=false, GoalEnabled=false,
    SmartObjective="Força", GoalStat="Strength", GoalValue=nil,
    HatchCrystal="Blue Crystal", RepDelay=.065, HatchDelay=.45,
    RebirthTarget=nil, SelectedMachine=nil,
    LastRebirthAttempt=0,
    BossDistance=5, BossReturn=true, BossPreference="Qualquer",
    ResumeAfterDeath=true, HealthGuard=true, HealthLow=25, HealthResume=75,
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
        Stalled = false, WasTraining = false,
    }
    M.AutoKeys = {"Train", "Rebirth", "Chests", "Hatch", "Brawl", "AutoPunch",
        "SmartRock", "LockPosition", "AutoMachine", "AutoBestMachine", "StrengthRebirth",
        "TurboStrength", "MaxStrengthF2P", "AutoBoss", "AutoAgility", "SmartFarm",
        "AutoEquipAfterHatch", "AutoEvolveAfterHatch", "GoalEnabled"}
    local booleans = {"BossReturn", "ResumeAfterDeath", "HealthGuard", "StallAlerts", "PerformanceMode", "StabilityMode"}
    local numbers = {
        RepDelay = {.05, 5}, HatchDelay = {.1, 30}, BossDistance = {2, 12},
        HealthLow = {5, 60}, HealthResume = {65, 100}, StallSeconds = {30, 600},
        GoalValue = {1, 1e15}, RebirthTarget = {1, 1e15}, ProgressionTarget = {1, 1e15},
    }
    local choices = {SmartObjective = {"Força", "Durabilidade", "Agilidade", "Rebirths"},
        GoalStat = {"Strength", "Agility", "Durability", "Rebirths"}}
    local strings = {"HatchCrystal", "SelectedMachine", "BossPreference"}

    function M:log(kind, message)
        self.History[#self.History + 1] = {Time = math.floor(clock() - self.Started), Kind = kind, Message = tostring(message)}
        if #self.History > 150 then table.remove(self.History, 1) end
    end
    function M:canAct()
        return next(self.Reasons) == nil
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
        self:pause("Manual", true)
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
    M:pause("Manual", false)
    M:log("Controle", "Todas as automacoes paradas")
    S.StopAt = nil
    S.ProgressionTarget = nil
    S.Train = false
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

local function doAnimatedPunch()
    if not SESSION.Alive or not M:canAct() then return false end
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

local function bossRoot(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function bossHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

local function modelHasBossMarker(model)
    if not model or not model:IsA("Model") then return false end
    if model == LP.Character or Players:GetPlayerFromCharacter(model) then return false end

    local humanoid = bossHumanoid(model)
    local root = bossRoot(model)
    if not humanoid or humanoid.Health <= 0 or not root then return false end

    local lowerName = string.lower(model.Name)
    if string.find(lowerName, "boss", 1, true) then return true end

    if model:GetAttribute("Boss") == true
        or model:GetAttribute("IsBoss") == true
        or model:GetAttribute("isBoss") == true then
        return true
    end

    local parent = model.Parent
    while parent and parent ~= workspace do
        if string.find(string.lower(parent.Name), "boss", 1, true) then
            return true
        end
        parent = parent.Parent
    end

    -- Alguns NPCs novos exibem "Boss" apenas no BillboardGui, sem colocar
    -- a palavra no nome do Model.
    for _, obj in ipairs(model:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and type(obj.Text) == "string" then
            if string.find(string.lower(obj.Text), "boss", 1, true) then
                return true
            end
        end
    end

    return false
end

local function findAliveBoss()
    local candidates = {}

    -- Primeiro prioriza pastas explicitamente ligadas a bosses.
    for _, container in ipairs(workspace:GetChildren()) do
        if (container:IsA("Folder") or container:IsA("Model"))
            and string.find(string.lower(container.Name), "boss", 1, true) then
            for _, item in ipairs(container:GetDescendants()) do
                if item:IsA("Model") and modelHasBossMarker(item) then
                    candidates[#candidates+1] = item
                end
            end
            if container:IsA("Model") and modelHasBossMarker(container) then
                candidates[#candidates+1] = container
            end
        end
    end

    -- Fallback para updates novos em que o boss fica dentro de Battle Island
    -- ou outra pasta sem "boss" no nome.
    if #candidates == 0 then
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Model") and modelHasBossMarker(item) then
                candidates[#candidates+1] = item
            end
        end
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

local function beginBossFight(target)
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not target then return false end

    if not HubRuntime.BossActive then
        HubRuntime.BossReturnCFrame = root.CFrame
    end

    HubRuntime.BossActive = true
    HubRuntime.BossModel = target
    HubRuntime.BossTarget = target.Name
    return true
end

local function finishBossFight(returnToStart)
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

task.spawn(function()
    local currentBoss = nil
    local nextScan = 0

    while SESSION.Alive and task.wait(S.StabilityMode and .20 or .12) do
        if not M:canAct() then continue end
        if currentBoss and not HubRuntime.BossActive then currentBoss = nil end
        if not S.AutoBoss then
            if HubRuntime.BossActive then
                finishBossFight(true)
            end
            currentBoss = nil
        else
            local humanoid = bossHumanoid(currentBoss)
            local root = bossRoot(currentBoss)

            if not currentBoss or not currentBoss.Parent or not humanoid or humanoid.Health <= 0 or not root then
                if HubRuntime.BossActive and currentBoss then
                    finishBossFight(true)
                    if humanoid and humanoid.Health <= 0 then
                        HubRuntime.BossDeathsObserved += 1
                        M:log("Boss", "Morte observada: " .. currentBoss.Name)
                        setHubStatus("Boss morreu • aguardando proximo spawn")
                    else
                        setHubStatus("Boss saiu do alcance • aguardando proximo spawn")
                    end
                end

                currentBoss = nil
                if os.clock() >= nextScan then
                    nextScan = os.clock() + 2
                    currentBoss = findAliveBoss()
                end
                if currentBoss then
                    beginBossFight(currentBoss)
                    setHubStatus("Auto Boss • "..currentBoss.Name)
                else
                    HubRuntime.BossTarget = "Aguardando spawn"
                end
            end

            if currentBoss and currentBoss.Parent then
                local bossHum = bossHumanoid(currentBoss)
                local bossPart = bossRoot(currentBoss)
                local character = LP.Character
                local myRoot = character and character:FindFirstChild("HumanoidRootPart")
                local myHum = character and character:FindFirstChildOfClass("Humanoid")

                if bossHum and bossHum.Health > 0 and bossPart and myRoot and myHum and myHum.Health > 0 then
                    beginBossFight(currentBoss)

                    pcall(function()
                        local attackPosition = bossPart.Position
                            - bossPart.CFrame.LookVector * S.BossDistance
                            + Vector3.new(0, 2.5, 0)
                        myRoot.CFrame = CFrame.lookAt(attackPosition, bossPart.Position)
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                    end)

                    doAnimatedPunch()
                end
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

local function findTrainingTool()
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

local function activateTrainingTool()
    if not SESSION.Alive or not M:canAct() then return false end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local tool = findTrainingTool()
    if not tool then return false end

    local backpack = getBackpack()
    if backpack and tool.Parent == backpack then
        pcall(function()
            humanoid:EquipTool(tool)
        end)
        task.wait(.05)
    end

    if not SESSION.Alive or not M:canAct() then return false end
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
    if not SESSION.Alive or not M:canAct() then return false end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local event = getMuscleEvent()
    if not event then return false end

    local tool = equipStrengthTool()
    if tool and tool.Parent == character then
        pcall(function()
            tool:Activate()
        end)
    end

    -- Muscle Legends aceita "rep" como a ação de treino. Em vez de depender
    -- de uma máquina específica, enviamos uma rajada curta e limitada.
    local burst = S.StabilityMode and 3 or 8
    for _ = 1, burst do
        if not SESSION.Alive or not M:canAct() or not (S.TurboStrength or S.MaxStrengthF2P) then break end
        safeFire(event, "rep")
    end

    return true
end

task.spawn(function()
    local failures = 0
    local windowStart = os.clock()
    local windowStrength = numberStat("Strength")
    local noGainWindows = 0

    while SESSION.Alive and task.wait(S.StabilityMode and .14 or .08) do
        if M:canAct() and S.TurboStrength and not HubRuntime.BossActive then
            if fastStrengthBurst() then
                failures = 0
            else
                failures += 1
            end

            if os.clock() - windowStart >= 2.5 then
                local now = numberStat("Strength")
                local gained = math.max(0, now - windowStrength)

                if gained > 0 then
                    noGainWindows = 0
                    setHubStatus("Força Rápida • +"..math.floor(gained).." em 2.5s")
                else
                    noGainWindows += 1
                    setHubStatus("Força Rápida • aguardando ganho...")
                end

                windowStrength = now
                windowStart = os.clock()

                if noGainWindows >= 2 or failures >= 10 then
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
    if not SESSION.Alive or not M:canAct() then return false end
    refreshRemotes()
    if not R.EquipPet then return false end

    local pets = allOwnedPets()
    if #pets == 0 then return false end

    table.sort(pets, function(a,b)
        return petStrengthScore(a) > petStrengthScore(b)
    end)

    local equipped, slots = equippedPets()
    if slots <= 0 then slots = 3 end

    for pet in pairs(equipped) do
        safeFire(R.EquipPet, "unequipPet", pet)
        task.wait(S.StabilityMode and .18 or .10)
    end

    for i = 1, math.min(slots, #pets) do
        safeFire(R.EquipPet, "equipPet", pets[i].pet)
        task.wait(S.StabilityMode and .22 or .12)
    end

    return true
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
        if M:canAct() and S.Train and not HubRuntime.BossActive then
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
    while SESSION.Alive and task.wait(S.StabilityMode and .14 or .06) do
        if M:canAct() and S.Rebirth and not HubRuntime.BossActive then
            if S.RebirthTarget and currentRebirths() >= S.RebirthTarget then
                S.Rebirth = false
            else
                -- Sem cooldown artificial do 710Hub. O servidor continua
                -- decidindo quando um rebirth é realmente permitido.
                local now = os.clock()
                local minGap = S.StabilityMode and .12 or .045
                if now - (S.LastRebirthAttempt or 0) >= minGap then
                    S.LastRebirthAttempt = now
                    safeInvoke(R.Rebirth, "rebirthRequest")
                end
            end
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(S.StabilityMode and .24 or .16) do
        if M:canAct() and S.AutoPunch then
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
        if M:canAct() and S.AutoBestMachine then
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
            if not S.AutoMachine then
                local animated = activateTrainingTool()
                if not animated then
                    safeFire(getMuscleEvent(), "rep")
                end
            end
            local now = os.clock()
            local minGap = S.StabilityMode and .14 or .05
            if now - (S.LastRebirthAttempt or 0) >= minGap then
                S.LastRebirthAttempt = now
                safeInvoke(R.Rebirth, "rebirthRequest")
            end
        end
    end
end)

task.spawn(function()
    while SESSION.Alive and task.wait(2) do
        if M:canAct() and S.Chests then
            for _,name in ipairs(CHESTS) do
                if not SESSION.Alive or not M:canAct() or not S.Chests then break end
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
        if M:canAct() and S.Brawl then safeFire(R.Brawl, "joinBrawl") end
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

    while SESSION.Alive and task.wait(S.StabilityMode and .18 or .10) do
        if M:canAct() and S.MaxStrengthF2P then
            if os.clock() - lastPetRefresh >= 10 then
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
        if M:canAct() and S.SmartFarm then
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
    local lastTick, lastScan, lastSample = os.clock(), 0, 0
    while SESSION.Alive do
        task.wait(.25)
        if not SESSION.Alive then break end
        local now = os.clock()
        local elapsed = now - lastTick
        lastTick = now
        if (not M:canAct() or M.Comparing) and S.StopAt then S.StopAt += elapsed end
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if S.HealthGuard and S.AutoBoss and humanoid and humanoid.MaxHealth > 0 and humanoid.Health > 0 then
            local percent = humanoid.Health * 100 / humanoid.MaxHealth
            if percent <= S.HealthLow and not M.Reasons["Vida baixa"] then
                M:pause("Vida baixa", true)
                finishBossFight(true)
                M:log("Boss", "Combate suspenso por vida baixa")
            elseif percent >= S.HealthResume then
                M:pause("Vida baixa", false)
            end
        else
            M:pause("Vida baixa", false)
        end
        if now - lastSample >= 1 then
            lastSample = now
            local training = not HubRuntime.BossActive and (S.Train or S.Rebirth or S.StrengthRebirth
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
-- END MAINTENANCE RUNTIME
end
initializeMaintenance()

local function initializeUI()
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- BEGIN MAINTENANCE MENU
-- Black/yellow neon theme. Legacy color keys keep existing widgets compatible.
local COLORS = {
    Black = Color3.fromRGB(5, 5, 5), Black2 = Color3.fromRGB(12, 12, 12),
    Panel = Color3.fromRGB(17, 17, 15), Panel2 = Color3.fromRGB(23, 23, 20),
    Panel3 = Color3.fromRGB(37, 36, 21), Green = Color3.fromRGB(255, 238, 0),
    GreenBright = Color3.fromRGB(255, 250, 115), GreenDark = Color3.fromRGB(61, 54, 5),
    Yellow = Color3.fromRGB(255, 238, 0), YellowSoft = Color3.fromRGB(255, 248, 155),
    White = Color3.fromRGB(250, 249, 239), Muted = Color3.fromRGB(205, 204, 190),
    Off = Color3.fromRGB(125, 124, 112), Red = Color3.fromRGB(255, 184, 42),
    NeonDim = Color3.fromRGB(116, 103, 10), Cyan = Color3.fromRGB(255, 211, 0),
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
shadow.BackgroundColor3 = Color3.new(0, 0, 0); shadow.BackgroundTransparency = .35
shadow.BorderSizePixel = 0; shadow.Parent = gui; addCorner(shadow, 22)
local main = Instance.new("Frame")
main.Name = "Main"; main.BackgroundColor3 = COLORS.Black; main.BorderSizePixel = 0
main.Active = true; main.Parent = gui; addCorner(main, 18)
addStroke(main, COLORS.Cyan, 1.5, .3)
addGradient(main, COLORS.Black, Color3.fromRGB(17, 16, 7), 70)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -32, 0, 58); header.Position = UDim2.fromOffset(16, 8)
header.BackgroundTransparency = 1; header.Active = true; header.Parent = main
local minimize = Instance.new("TextButton")
minimize.Name = "Minimizar"; minimize.Size = UDim2.fromOffset(42, 40)
minimize.Position = UDim2.new(1, 0, 0, 7); minimize.AnchorPoint = Vector2.new(1, 0)
minimize.Text = "−"; minimize.TextSize = 26; minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = COLORS.Cyan; minimize.BackgroundColor3 = COLORS.Panel2
minimize.BorderSizePixel = 0; minimize.Parent = header; addCorner(minimize, 10)
do
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(48, 44); logo.Position = UDim2.fromOffset(0, 6)
    logo.Text = "710"; logo.Font = Enum.Font.GothamBlack; logo.TextSize = 18
    logo.TextColor3 = COLORS.Green; logo.BackgroundColor3 = COLORS.GreenDark
    logo.BorderSizePixel = 0; logo.Parent = header; addCorner(logo, 12)
    addStroke(logo, COLORS.Green, 1, .3)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(60, 4); title.Size = UDim2.new(1, -114, 0, 29)
    title.BackgroundTransparency = 1; title.Text = "710Hub"; title.TextSize = 25
    title.Font = Enum.Font.GothamBlack; title.TextColor3 = COLORS.White
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header
    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(61, 34); subtitle.Size = UDim2.new(1, -115, 0, 19)
    subtitle.BackgroundTransparency = 1; subtitle.Text = "MUSCLE LEGENDS"; subtitle.TextSize = 12
    subtitle.Font = Enum.Font.GothamMedium; subtitle.TextColor3 = COLORS.Cyan
    subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = header
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -32, 0, 2); line.Position = UDim2.fromOffset(16, 65)
    line.BackgroundColor3 = Color3.new(1, 1, 1); line.BorderSizePixel = 0; line.Parent = main
    local gradient = addGradient(line, COLORS.Green, COLORS.Cyan, 0)
    local animation = TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(.6, 0)})
    animation:Play()
    gui.Destroying:Connect(function() animation:Cancel() end)
end
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Conteudo"; scroll.Position = UDim2.fromOffset(16, 169)
scroll.Size = UDim2.new(1, -32, 1, -229); scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = COLORS.Green; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(); scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ClipsDescendants = true; scroll.Parent = main
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = scroll
local searchQuery, currentSection = "", ""
local searchEntries = {}
local UI = {Category = "Farm", CurrentCategory = "Farm", Order = 0, Tabs = {}, Width = 650, LargeText = false}
UI.Groups = {
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
    local count, sections = 0, {}
    for _, entry in ipairs(searchEntries) do
        if not entry.Heading then
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
        tween(tab, .14, {BackgroundColor3 = selected and COLORS.GreenDark or COLORS.Panel2,
            TextColor3 = selected and COLORS.GreenBright or COLORS.Muted})
    end
    if self.Empty then self.Empty.Visible = count == 0 end
    if resetScroll then scroll.CanvasPosition = Vector2.new() end
end
function UI:resize()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 700)
    self.Width = math.max(280, math.min(740, viewport.X - 28))
    local height = math.max(280, math.min(690, viewport.Y - 60))
    main.Size = UDim2.fromOffset(self.Width, height)
    main.Position = UDim2.new(.5, -self.Width / 2, .5, -height / 2)
    shadow.Size = UDim2.fromOffset(self.Width + 10, height + 10)
    shadow.Position = UDim2.new(.5, -self.Width / 2 - 5, .5, -height / 2 + 1)
    for _, entry in ipairs(searchEntries) do if entry.Resize then entry.Resize() end end
end
do
    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Categorias"; nav.Position = UDim2.fromOffset(16, 122)
    nav.Size = UDim2.new(1, -32, 0, 39); nav.BackgroundTransparency = 1; nav.BorderSizePixel = 0
    nav.ScrollBarThickness = 2; nav.ScrollBarImageColor3 = COLORS.Cyan
    nav.ScrollingDirection = Enum.ScrollingDirection.X; nav.AutomaticCanvasSize = Enum.AutomaticSize.X
    nav.CanvasSize = UDim2.new(); nav.Parent = main
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = nav
    for index, category in ipairs({"Farm", "Bosses", "Pets", "Metas", "Perfis", "Sessão", "Ajustes"}) do
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.fromOffset(87, 34); tab.Text = category; tab.Font = Enum.Font.GothamBold
        tab.TextSize = 14; tab.TextColor3 = COLORS.Muted; tab.BackgroundColor3 = COLORS.Panel2
        tab.BorderSizePixel = 0; tab.LayoutOrder = index; tab.Parent = nav; addCorner(tab, 9)
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
    bottom.Size = UDim2.new(1, -32, 0, 42); bottom.Position = UDim2.new(0, 16, 1, -50)
    bottom.BackgroundColor3 = COLORS.Panel; bottom.BorderSizePixel = 0; bottom.Parent = main; addCorner(bottom, 10)
    local pause = Instance.new("TextButton")
    pause.Size = UDim2.fromOffset(90, 32); pause.Position = UDim2.new(1, -198, 0, 5)
    pause.TextSize = 13; pause.Font = Enum.Font.GothamBold; pause.BackgroundColor3 = COLORS.GreenDark
    pause.TextColor3 = COLORS.Green; pause.BorderSizePixel = 0; pause.Parent = bottom; addCorner(pause, 8)
    pause.Activated:Connect(function() M:pause("Manual", not M.Reasons.Manual) end)
    local stop = Instance.new("TextButton")
    stop.Size = UDim2.fromOffset(96, 32); stop.Position = UDim2.new(1, -102, 0, 5)
    stop.Text = "Parar tudo"; stop.TextSize = 13; stop.Font = Enum.Font.GothamBold
    stop.TextColor3 = COLORS.Red; stop.BackgroundColor3 = Color3.fromRGB(49, 35, 8)
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
            status.Text = M:canAct() and "● Pronto" or "● Em pausa"
            status.TextColor3 = M:canAct() and COLORS.Green or COLORS.Yellow
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
    holder.Size = UDim2.new(1, -9, 0, 70); holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0; holder.Parent = scroll
    local entry = UI:addEntry(holder, currentSection, true)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(2, 8); title.Size = UDim2.new(1, -4, 0, 24)
    title.BackgroundTransparency = 1; title.Text = name; title.TextSize = 17
    title.TextColor3 = COLORS.Green; title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left; title.TextWrapped = true; title.Parent = holder
    local detail = Instance.new("TextLabel")
    detail.Position = UDim2.fromOffset(2, 36); detail.Size = UDim2.new(1, -4, 0, 32)
    detail.Text = desc or ""; detail.TextSize = 14; detail.TextColor3 = COLORS.Muted
    detail.Font = Enum.Font.Gotham; detail.BackgroundTransparency = 1; detail.TextWrapped = true
    detail.TextXAlignment = Enum.TextXAlignment.Left; detail.TextYAlignment = Enum.TextYAlignment.Top; detail.Parent = holder
    entry.Resize = function()
        local width = math.max(100, UI.Width - 48)
        title.TextSize = UI.LargeText and 19 or 17; detail.TextSize = UI.LargeText and 16 or 14
        local service = game:GetService("TextService")
        local th = service:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(detail.Text, detail.TextSize, detail.Font, Vector2.new(width, 10000)).Y + 4
        title.Size = UDim2.new(1, -4, 0, th); detail.Position = UDim2.fromOffset(2, th + 12)
        detail.Size = UDim2.new(1, -4, 0, dh); holder.Size = UDim2.new(1, -9, 0, th + dh + 20)
    end
    entry.Resize()
end
local availabilityRefs = {}
local function card(titleText, description, callback, accentColor, availableFn)
    local accentColorFinal = accentColor or COLORS.Green
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = COLORS.Panel2; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Text = ""; b.Parent = scroll; addCorner(b, 12)
    local entry = UI:addEntry(b, currentSection .. " " .. titleText .. " " .. (description or ""))
    local stroke = addStroke(b, accentColorFinal, 1, .7)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(3, 24); accent.Position = UDim2.fromOffset(0, 16)
    accent.BackgroundColor3 = accentColorFinal; accent.BorderSizePixel = 0; accent.Parent = b; addCorner(accent, 2)
    local t = Instance.new("TextLabel")
    t.Name = "Titre"; t.Position = UDim2.fromOffset(16, 13); t.BackgroundTransparency = 1
    t.Text = titleText; t.TextColor3 = COLORS.White; t.Font = Enum.Font.GothamBold; t.TextSize = 16
    t.TextWrapped = true; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top; t.Parent = b
    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1; d.Text = description or ""; d.TextColor3 = COLORS.Muted
    d.Font = Enum.Font.Gotham; d.TextSize = 14; d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left; d.TextYAlignment = Enum.TextYAlignment.Top; d.Parent = b
    entry.Resize = function()
        local reserve = b:GetAttribute("IsToggle") and 108 or 0
        local width = math.max(100, UI.Width - 75 - reserve)
        t.TextSize = UI.LargeText and 18 or 16; d.TextSize = UI.LargeText and 16 or 14
        local service = game:GetService("TextService")
        local th = service:GetTextSize(t.Text, t.TextSize, t.Font, Vector2.new(width, 10000)).Y + 4
        local dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(width, 10000)).Y + 4
        t.Size = UDim2.new(1, -32 - reserve, 0, th)
        d.Position = UDim2.fromOffset(16, 18 + th); d.Size = UDim2.new(1, -32, 0, dh)
        -- Descriptions use the full width below the toggle for easier reading.
        if reserve > 0 then
            dh = service:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(math.max(100, UI.Width - 75), 10000)).Y + 4
            d.Size = UDim2.new(1, -32, 0, dh)
        end
        b.Size = UDim2.new(1, -9, 0, math.max(78, 32 + th + dh))
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
    b.MouseLeave:Connect(function() tween(b, .2, {BackgroundColor3 = COLORS.Panel2}); tween(stroke, .2, {Transparency = .7}) end)
    b.Activated:Connect(function()
        if not isAvailable() then setHubStatus(titleText .. " indisponível nesta sessão"); return end
        tween(stroke, .1, {Transparency = 0})
        task.delay(.2, function() if b.Parent then tween(stroke, .2, {Transparency = .7}) end end)
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

local function resolveToggleConflicts(key)
    if not S[key] then return end

    if key == "MaxStrengthF2P" then
        S.Train = false
        S.TurboStrength = false
        S.AutoMachine = false
        S.AutoBestMachine = false
        S.StrengthRebirth = false
        S.AutoAgility = false
        S.SmartRock = false
        S.LockPosition = false
        lockedCFrame = nil
    elseif key == "TurboStrength" then
        S.MaxStrengthF2P = false
        S.Train = false
        S.AutoMachine = false
        S.AutoBestMachine = false
        S.StrengthRebirth = false
        S.AutoAgility = false
        S.SmartRock = false
        S.LockPosition = false
        lockedCFrame = nil
    elseif key == "AutoAgility" then
        S.MaxStrengthF2P = false
        S.TurboStrength = false
        S.LockPosition = false
        S.SmartRock = false
        S.AutoMachine = false
        S.StrengthRebirth = false
        lockedCFrame = nil
    elseif key == "SmartRock" then
        S.MaxStrengthF2P = false
        S.TurboStrength = false
        S.AutoAgility = false
        S.AutoMachine = false
        S.LockPosition = false
        lockedCFrame = nil
    elseif key == "AutoMachine" then
        S.MaxStrengthF2P = false
        S.TurboStrength = false
        S.AutoAgility = false
        S.SmartRock = false
        S.LockPosition = false
        lockedCFrame = nil
    elseif key == "LockPosition" then
        S.TurboStrength = false
        S.AutoAgility = false
        S.SmartRock = false
    end
end

local function toggle(titleText, description, key, availableFn)
    local b, t, d = card(titleText, description, nil, COLORS.Green)
    b:SetAttribute("IsToggle", true)
    local pill = Instance.new("TextLabel")
    pill.Size = UDim2.fromOffset(96, 30); pill.Position = UDim2.new(1, -110, 0, 11)
    pill.BorderSizePixel = 0; pill.Font = Enum.Font.GothamBold; pill.TextSize = 13
    pill.Parent = b; addCorner(pill, 9)
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
        pill.Text = enabled and "Ligado" or "Desligado"
        tween(pill, .18, {
            BackgroundColor3 = enabled and COLORS.GreenDark or COLORS.Black2,
            TextColor3 = enabled and COLORS.GreenBright or COLORS.Muted,
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

toggle(
    "Treino automático",
    "Equipa uma ferramenta de treino e ativa repetidamente para ganhar força.",
    "Train",
    canTrain
)

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
            bossStatusDesc.Text = hum
                and ("Vida atual: "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth))
                or "Atacando boss detectado..."
        elseif S.AutoBoss then
            bossStatusTitle.Text = "Boss: aguardando spawn"
            bossStatusDesc.Text = "Aguardando spawn. Mortes observadas: " .. HubRuntime.BossDeathsObserved
        else
            bossStatusTitle.Text = "Boss: Auto Boss desligado"
            bossStatusDesc.Text = "Ative a opção acima para começar a monitorar os spawns."
        end
    end
end)

card(
    "Procurar boss agora",
    "Faz uma varredura imediata e mostra o boss vivo encontrado no mapa.",
    function(_, titleLabel, descLabel)
        local boss = findAliveBoss()
        if boss then
            local hum = bossHumanoid(boss)
            titleLabel.Text = "Encontrado: "..boss.Name
            descLabel.Text = hum
                and ("Vida: "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth))
                or "Boss detectado."
        else
            titleLabel.Text = "Nenhum boss vivo agora"
            descLabel.Text = "O Auto Boss continuará esperando o próximo spawn."
        end
    end,
    COLORS.Yellow,
    canAutoBoss
)

do
    card("Distancia do boss: 5", "Alterna a distancia de ataque entre 3, 5 e 7 studs.", function(_, titleLabel)
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
        text.Text = body
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
    local function field(title, value, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 68)
        frame.BackgroundColor3 = COLORS.Panel2
        frame.Parent = scroll
        addCorner(frame, 10)
        local entry = UI:addEntry(frame, currentSection .. " " .. title)
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
            local height = game:GetService("TextService"):GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(math.max(100, UI.Width - 66), 10000)).Y + 8
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
    field("Boss preferido (Qualquer ou nome exato)", S.BossPreference, function(value)
        value = value:match("^%s*(.-)%s*$")
        if #value < 1 or #value > 150 then return false, "Nome precisa ter entre 1 e 150 caracteres" end
        S.BossPreference = value
        M:log("Boss", "Preferencia: " .. value)
        return true, "Preferencia aplicada na proxima escolha de alvo"
    end)
    card("Listar bosses detectados", "Mostra nomes dos bosses vivos visiveis ao cliente para copiar no campo acima.", function()
        showReport("Bosses detectados", table.concat(M:bossNames(), "\n"))
    end, COLORS.Green)
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
    section("HISTORICO E COMPATIBILIDADE", "Eventos recentes e recursos disponiveis nesta sessao.")
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
    trackConnection(search:GetPropertyChangedSignal("Text"):Connect(function()
        searchQuery = UI:normalize(search.Text):match("^%s*(.-)%s*$")
        UI:refresh(true, false)
    end))
    local larger = Instance.new("TextButton")
    larger.Size = UDim2.fromOffset(51, 40); larger.Position = UDim2.new(1, -67, 0, 75)
    larger.BackgroundColor3 = COLORS.Panel2; larger.TextColor3 = COLORS.Cyan
    larger.Text = "A+"; larger.TextSize = 18; larger.Font = Enum.Font.GothamBold
    larger.BorderSizePixel = 0; larger.Parent = main; addCorner(larger, 10)
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

