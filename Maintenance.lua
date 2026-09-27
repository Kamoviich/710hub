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
