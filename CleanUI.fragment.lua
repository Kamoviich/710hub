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
    choices("farm_preset","Configuração rápida","Ultra combinado: clássico + lotes juntos. Ultra rápido: lotes/ping. Força acumulada: 659/s. Rebirth rápido: prioridade à confirmação. Seus pets são mantidos.",strings({"Ultra combinado","Ultra rápido","Força acumulada","Rebirth rápido"}),function(value) C:applyPreset(value); UI:syncFields(); renderAllToggles() end)
    choices("farm_method","Método de treino","Fast Rep ajusta o ritmo pelos ganhos reais; Automático escolhe máquina ou ferramenta.",strings(C.Modes),function(mode) C:setMode(mode); renderAllToggles() end)
    local farm=action("farm_start","Iniciar / parar treino","Inicia o método selecionado; aguarda durante combate com boss.",function()
        if C:farming() then C:clearFarm() else C:startFarm() end
        renderAllToggles()
    end)
    choices("machine_select","Máquina do treino","Lista atual do mapa; aparece ao escolher o método Máquina.",function()
        local out={}; for _,machine in ipairs(scanMachines()) do out[#out+1]={Label=machine.name,Value=machine.name} end; return out
    end,function(name) S.SelectedMachine=name end,function() return S.FarmMode=="Máquina" and canMachineFarm() end)
    choices("rep_profile","Envio de reps","Combinado soma clássico e lotes dentro do teto total; Ultra usa lotes/ping; Explorar mede ganhos. Seus pets são preservados.",strings({"Combinado","Ultra (lotes)","Explorar limite","Intensivo","Adaptativo"}),function(value) S.FastRepProfile=value; HubRuntime.FastRep:cancel() end)
    numeric("fast_rep_limit","Fast Rep: teto local de pedidos/s (40–10000)","FastRepLimit",40,10000,true)
    local pace=action("farm_pace","Rendimento do Fast Rep","Força, durabilidade, rebirths e pedidos enviados; atualiza a cada segundo sem alterar seus pets.",function() report("Rendimento observado",function() return HubRuntime.FastRep:report() end) end)
    input("farm_interval","Outros métodos: intervalo em rajada (ms)",S.FarmIntervalMs,function(value) return M:setFarmTiming("FarmIntervalMs",value) end)
    input("farm_reps","Outros métodos: reps por ciclo em rajada",S.FarmReps,function(value) return M:setFarmTiming("FarmReps",value) end)
    switch("rebirth_auto","Fast rebirth / rebirth automático","Mantém o treino de força durante resposta e confirmação, com um pedido de rebirth por vez. Zero remove a espera local. Seus pets são mantidos.","Rebirth",canRebirth)
    numeric("rebirth_interval","Espera local do rebirth (0 = sem cooldown)","RebirthInterval",0,30)
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
    choices("pvp_filter","Filtro do PvP","Todos, karma, alvo unico, lista de alvos ou tags da blacklist.",strings({"Todos","Karma bom","Karma ruim","Selecionado","Multiplos","Blacklist"}),function(value) C:setFilter(value); renderAllToggles() end)
    local pvp=action("pvp_start","Iniciar / parar PvP","Usa o modo e filtro escolhidos; respeita spawn protegido e whitelist.",function()
        if C:pvpActive() then S.PvpAny,S.PvpGood,S.PvpEvil=false,false,false; M:stopPvp(); HubRuntime.Pvp:stop() else C:startPvp() end
        renderAllToggles()
    end)
    switch("pvp_friends","Proteger amigos no PvP","Consultas de amizade ocorrem fora do combate; pendentes ficam protegidas.","PvpProtectFriends")
    action("player_protect","Proteger / liberar jogador","Whitelist persistente por UserId, aplicada a todos os modos de PvP.",function()
        local player=X:selectedPlayer(); if not player then setHubStatus("Selecione um jogador presente"); return end
        X.Whitelist[player.UserId]=not X.Whitelist[player.UserId] and true or nil
        HubRuntime.Pvp:saveLists()
        setHubStatus(X.Whitelist[player.UserId] and "Conta protegida" or "Proteção removida")
    end)
    local P=HubRuntime.Pvp
    choices("pvp_mode","Modo de ataque PvP","Distancia e aura tentam contato sem mover voce. Bring depende da replicacao do jogo.",strings({"Aproximar","Distancia","Bring","Aura"}),function(value) P:setMode(value); renderAllToggles() end)
    numeric("pvp_radius","Raio de busca PvP (10 a 500)","PvpRadius",10,500)
    switch("pvp_universal","Range de Kill Universal","Remove o limite de busca; alcanca personagens carregados. O servidor valida o dano.","PvpUniversal")
    action("pvp_target","Adicionar / remover alvo multiplo","Alterna a conta selecionada na lista persistente de alvos.",function()
        local player=X:selectedPlayer(); if not player then setHubStatus("Selecione um jogador presente"); return end
        P.Targets[player.UserId]=not P.Targets[player.UserId] and true or nil
        P:saveLists(); setHubStatus(P.Targets[player.UserId] and "Alvo adicionado" or "Alvo removido")
    end)
    input("pvp_whitelist_id","Whitelist: +UserId ou -UserId","",function(text)
        local sign,id=text:match("^%s*([+-])(%d+)%s*$"); id=tonumber(id)
        if not id or id<=0 or id>=1e15 or id%1~=0 then return false,"Exemplo: +12345 protege; -12345 remove" end
        X.Whitelist[id]=sign=="+" and true or nil; P:saveLists(); return true
    end)
    input("pvp_tag","Blacklist: +tag para salvar, -tag para remover","",function(text)
        local sign,tag=text:match("^%s*([+-])(.+)$")
        if not sign then return false,"Exemplo: +[CLA] ou -[CLA]" end
        return P:editTag(tag,sign=="-")
    end)
    action("pvp_blacklist_start","Ativar PvP automatico da blacklist","Ataca tags salvas e reconhece novos jogadores enquanto este controlador estiver ativo.",function()
        if #P.Tags==0 then setHubStatus("Adicione uma tag a blacklist primeiro"); return end
        C:setFilter("Blacklist")
        if not C:pvpActive() then C:startPvp() end
        renderAllToggles()
    end)
    action("pvp_lists","Ver whitelist, alvos e blacklist","Exibe as listas salvas e o estado da persistencia.",function() report("Listas PvP",P:listsReport()) end)
    numeric("pvp_aura_radius","Raio da Kill aura (5 a 500)","PvpAuraRadius",5,500)
    action("pvp_aura_mark","Marcar area da Kill aura","Marca uma esfera fixa na sua posicao atual. Escolha Aura e inicie o PvP.",function()
        local _,message=P:markArea(); setHubStatus(message)
    end)
    local hunterQuery=""
    input("hunter_query","Player Hunter: UserId ou @usuario","",function(text)
        local value=text:match("^%s*(.-)%s*$")
        if #value<1 or #value>32 then return false,"Use UserId ou @usuario exato" end
        P.HunterToken+=1; P.Destination=nil; hunterQuery=value; return true
    end)
    action("hunter_find","Buscar servidor do jogador","Localiza neste servidor ou entre amigos com localizacao visivel ao Roblox.",function()
        task.spawn(function() P:findPlayer(hunterQuery); setHubStatus(P.HunterStatus) end)
    end)
    action("hunter_join","Entrar no servidor encontrado","Solicita sua entrada. Servidores privados, lotados ou sem permissao podem recusar.",function()
        local _,message=P:joinFound(); setHubStatus(message)
    end)
    action("hunter_status","Estado do Player Hunter","Veja o resultado da consulta e eventuais erros de entrada.",function() report("Player Hunter",function() return P.HunterStatus end) end)
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
    local stable=switch("stability","Lag zero / modo estavel","Limita chamadas e reduz efeitos e carga quando os FPS caem; nao garante lag zero.","StabilityMode",nil,function(desired)
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
            character_speed="CharacterSpeed",character_size="CharacterSize",camera_fov="CameraFOV",
            pvp_radius="PvpRadius",pvp_aura_radius="PvpAuraRadius"}) do
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
            pvp.Detail.Text="Modo: "..S.PvpMode.." | Filtro: "..S.PvpFilter.." | "..(M.PvpStatus or "Desligado")
            registry.pvp_mode.Detail.Text="Selecionado: "..S.PvpMode.." | dano e bring dependem do servidor"
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
