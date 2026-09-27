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
    local lines = {"710Hub " .. SESSION.Version .. " | NPCs com vida legivel ate 150 studs", "Se o boss aparecer como nao detectado, copie seu Nome para Boss preferido. Isso autoriza esse nome como alvo; confira antes de ligar Auto Boss."}
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
