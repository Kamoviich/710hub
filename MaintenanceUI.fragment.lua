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
