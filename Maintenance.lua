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
        "TrainWeight", "TrainPushups", "TrainSitups", "TrainHandstands", "PvpGood", "PvpEvil",
        "SmartRock", "LockPosition", "AutoMachine", "AutoBestMachine", "StrengthRebirth",
        "TurboStrength", "MaxStrengthF2P", "AutoBoss", "AutoAgility", "SmartFarm",
        "AutoEquipAfterHatch", "AutoEvolveAfterHatch", "GoalEnabled"}
    local booleans = {"BossReturn", "BossDefense", "ResumeAfterDeath", "HealthGuard", "StallAlerts", "PerformanceMode", "StabilityMode", "RebirthGuard", "BreakEnabled"}
    local numbers = {
        NovaMaxOpens = {1, 1000}, PvpRadius = {10, 150}, RepDelay = {.05, 5}, HatchDelay = {.1, 30}, BossDistance = {2, 12},
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
    for _, mode in ipairs({"PvpGood", "PvpEvil"}) do
        for _, key in ipairs(trainers) do conflict(mode, key) end
        for _, key in ipairs({"AutoBoss", "Brawl", "SmartRock", "AutoPunch", "LockPosition", "SmartFarm", "Rebirth", "StrengthRebirth"}) do conflict(mode, key) end
    end
    conflict("Hatch", "AutoNovaPhoenix")
    conflict("PvpGood", "PvpEvil")
    function M:pvpEligible(good, evil)
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
        settings.PvpGood, settings.PvpEvil = false, false
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
