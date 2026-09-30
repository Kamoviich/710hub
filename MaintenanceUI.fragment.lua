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
    toggle("PvP: karma bom", "Busca jogadores com mais karma ruim que bom. Desliga apenas rotinas incompativeis; ignora karma desconhecido e neutros.", "PvpGood")
    toggle("PvP: karma ruim", "Busca jogadores com mais karma bom que ruim. Desliga apenas rotinas incompativeis; ignora karma desconhecido e neutros.", "PvpEvil")
    field("Raio de busca PvP (studs)", S.PvpRadius, function(value)
        local number = tonumber(value)
        if not number or number ~= number or number < 10 or number > 150 then return false, "Use de 10 a 150 studs" end
        S.PvpRadius = number; return true
    end)
    local _, _, pvpStatus = card("Estado do PvP", "Desligado", function()
        showReport("PvP e karma", (M.PvpStatus or "Desligado") .. "\n\n" .. (M.PvpDiagnostic or "Ligue um modo para analisar os jogadores.") .. "\n\nNao garante kills ou karma. Use Parar tudo para encerrar. Perfis carregados nao iniciam PvP automaticamente.")
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
    section("RENDIMENTO E PLANEJAMENTO", "Acompanhe ganhos reais e organize os ciclos de treino.")
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
