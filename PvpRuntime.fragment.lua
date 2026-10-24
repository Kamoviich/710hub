-- One bounded PvP controller; actual damage and movement remain server validated.
local function initializePvpRuntime()
    local X,C=HubRuntime.Extras,HubRuntime.Clean
    local P={Targets={},Tags={},Brought={},Observed={},Cursor=0,Token=0,HunterToken=0,HunterStatus="Pronto",Persistence="Sessao"}
    HubRuntime.Pvp=P
    S.PvpMode=S.PvpMode or "Aproximar"
    S.PvpAuraRadius=S.PvpAuraRadius or 30
    S.PvpUniversal=S.PvpUniversal==true
    S.PvpInterval=S.PvpInterval or .12
    S.PvpPriority=S.PvpPriority or "Rotacao"
    P.PunchRequests,P.ContactPairs,P.DamageTotal,P.DeathsObserved=0,0,0,0
    P.LastAttackError="Nenhum"
    P.Path="710hub_pvp_"..tostring(LP.UserId).."_v1.json"
    local function trim(value) return value:match("^%s*(.-)%s*$") end
    local function validId(value)
        local id=tonumber(value)
        return id and id==id and id>0 and id<1e15 and id%1==0 and id or nil
    end
    function P:loadLists(data)
        if type(data)~="table" or data.Schema~=1 then return false end
        local whitelist,targets,tags={},{},{}
        for _,entry in ipairs({{data.Whitelist,whitelist},{data.Targets,targets}}) do
            if type(entry[1])=="table" then
                local count=0
                for key,enabled in pairs(entry[1]) do
                    local id=validId(key)
                    if id and enabled==true and count<200 then entry[2][id]=true; count+=1 end
                end
            end
        end
        if type(data.Tags)=="table" then
            for _,tag in ipairs(data.Tags) do
                if type(tag)=="string" then
                    tag=string.lower(trim(tag))
                    if #tag>=2 and #tag<=32 and #tags<30 and not table.find(tags,tag) then tags[#tags+1]=tag end
                end
            end
        end
        X.Whitelist,self.Targets,self.Tags=whitelist,targets,tags
        return true
    end
    function P:saveLists()
        local data={Schema=1,Whitelist={},Targets={},Tags=table.clone(self.Tags)}
        for id in pairs(X.Whitelist) do data.Whitelist[tostring(id)]=true end
        for id in pairs(self.Targets) do data.Targets[tostring(id)]=true end
        ENV.__710HubPvpLists=ENV.__710HubPvpLists or {}
        ENV.__710HubPvpLists[tostring(LP.UserId)]=data
        self.Persistence="Salvo na sessao; disco indisponivel"
        if type(writefile)=="function" then
            local ok=pcall(function() writefile(self.Path,game:GetService("HttpService"):JSONEncode(data)) end)
            self.Persistence=ok and "Salvo em disco" or "Salvo na sessao; falha ao gravar disco"
        end
        return self.Persistence
    end
    local cached=ENV.__710HubPvpLists
    if type(cached)=="table" then P:loadLists(cached[tostring(LP.UserId)]) end
    if type(readfile)=="function" then
        local ok,data=pcall(function()
            local raw=readfile(P.Path); assert(#raw<=64000,"Lista grande demais")
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if ok and P:loadLists(data) then P.Persistence="Listas carregadas do disco" end
    end
    function P:editTag(text,remove)
        local tag=string.lower(trim(text))
        if #tag<2 or #tag>32 then return false,"Use uma tag de 2 a 32 caracteres" end
        local index=table.find(self.Tags,tag)
        if remove then if index then table.remove(self.Tags,index) end
        elseif not index then
            if #self.Tags>=30 then return false,"Limite de 30 tags" end
            self.Tags[#self.Tags+1]=tag
        end
        self:saveLists(); return true
    end
    function P:matchesClan(player)
        local values={string.lower(player.Name),string.lower(player.DisplayName or "")}
        local containers={player}
        for _,key in ipairs({"leaderstats","stats"}) do
            local folder=player:FindFirstChild(key); if folder then containers[#containers+1]=folder end
        end
        if player.Character then containers[#containers+1]=player.Character end
        for _,container in ipairs(containers) do
            for _,key in ipairs({"Clan","ClanTag","clan","clanTag","Tag","Guild","GuildTag"}) do
                local value=container:GetAttribute(key)
                local item=container:FindFirstChild(key)
                if item and item:IsA("StringValue") then value=item.Value end
                if type(value)=="string" then values[#values+1]=string.lower(value) end
            end
        end
        for _,tag in ipairs(self.Tags) do
            for _,value in ipairs(values) do if string.find(value,tag,1,true) then return true end end
        end
        return false
    end
    local baseAllowed=X.pvpAllowed
    function X:pvpAllowed(player)
        if player==LP or player.Parent~=Players then return false end
        if not baseAllowed(self,player) then return false end
        if S.PvpFilter=="Multiplos" and not P.Targets[player.UserId] then return false end
        if S.PvpFilter=="Blacklist" and not P:matchesClan(player) then return false end
        return true
    end
    function P:restoreBring()
        for root,saved in pairs(self.Brought) do
            pcall(function() if root.Parent and root.CFrame==saved.Applied then root.CFrame=saved.Original end end)
        end
        table.clear(self.Brought)
    end
    function P:hideArea()
        if self.Marker then self.Marker:Destroy(); self.Marker=nil end
    end
    function P:showArea()
        if not self.Center then return end
        if not self.Marker then
            local part=Instance.new("Part")
            part.Name="710Hub_PvpArea"; part.Shape=Enum.PartType.Ball
            part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
            part.Material=Enum.Material.Neon; part.Color=Color3.fromRGB(90,220,100); part.Transparency=.88
            part.Parent=workspace; self.Marker=part
        end
        local diameter=S.PvpAuraRadius*2
        self.Marker.Size=Vector3.new(diameter,diameter,diameter)
        self.Marker.CFrame=CFrame.new(self.Center)
    end
    function P:markArea()
        local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false,"Aguarde seu personagem" end
        self.Center=root.Position; self:showArea(); return true,"Area marcada na posicao atual"
    end
    function P:stop()
        self.Token+=1; self.HunterToken+=1; self:restoreBring(); self:hideArea()
        self.Destination=nil
        if self.HunterBusy then self.HunterStatus="Busca cancelada" end
    end
    local baseStop=M.stopPvp
    function M:stopPvp() P:restoreBring(); baseStop(self) end
    local baseExtrasStop=X.stop
    function X:stop() P:stop(); baseExtrasStop(self) end
    local baseApply=M.applyProfile
    function M:applyProfile(profile) P:stop(); return baseApply(self,profile) end
    local baseFilter=C.setFilter
    function C:setFilter(value) P.Token+=1; return baseFilter(self,value) end
    local baseStart=C.startPvp
    function C:startPvp()
        if S.PvpMode~="Aproximar" and type(firetouchinterest)~="function" then
            setHubStatus("Este modo precisa de firetouchinterest no executor"); return false
        end
        if S.PvpMode=="Aura" and not P.Center then setHubStatus("Marque a area da aura primeiro"); return false end
        if S.PvpFilter=="Multiplos" and not next(P.Targets) then setHubStatus("Adicione jogadores a lista de alvos"); return false end
        local remote=getMuscleEvent()
        if not remote or not remote:IsA("RemoteEvent") then setHubStatus("Canal muscleEvent indisponivel; aguarde o personagem"); return false end
        local started=baseStart(self)
        if started then
            P.PunchRequests,P.ContactPairs,P.DamageTotal,P.DeathsObserved=0,0,0,0
            P.FirstAttemptAt,P.LastDamageAt,P.LockedUserId=nil,nil,nil
            P.LastAttackError="Nenhum"; table.clear(P.Observed)
        end
        return started
    end
    function P:setMode(mode)
        if not table.find({"Aproximar","Perseguir","Distancia","Bring","Aura"},mode) then return false end
        local running=C:pvpActive()
        S.PvpAny,S.PvpGood,S.PvpEvil=false,false,false; self:stop(); M:stopPvp()
        S.PvpMode=mode
        if running then return C:startPvp() end
        return true
    end
    function P:inRange(root,otherRoot)
        if S.PvpMode=="Aura" then return self.Center and (otherRoot.Position-self.Center).Magnitude<=S.PvpAuraRadius end
        return S.PvpUniversal or (root.Position-otherRoot.Position).Magnitude<=S.PvpRadius
    end
    function P:interval()
        return math.max(S.StabilityMode and .35 or .08,math.clamp(S.PvpInterval,.08,1))
    end
    function P:observeDamage()
        for _,entry in pairs(self.Observed) do
            if entry.Player.Character==entry.Model and entry.Hum.Parent and entry.Hum.Health<entry.Health then
                self.DamageTotal+=entry.Health-entry.Hum.Health; self.LastDamageAt=os.clock()
                entry.LastDamageAt=os.clock()
                if entry.Health>0 and entry.Hum.Health<=0 then self.DeathsObserved+=1 end
            end
            if entry.Hum.Parent then entry.Health=entry.Hum.Health end
        end
    end
    function P:attackTarget(character,entry,allowed)
        local remote=getMuscleEvent()
        if not remote or not remote:IsA("RemoteEvent") then self.LastAttackError="muscleEvent indisponivel"; return 0 end
        local sent,hasHand=0,false
        -- Match the inspected game protocol: target/hand contact, then punch + hand name.
        for _,side in ipairs({{"LeftHand","Left Arm","leftHand"},{"RightHand","Right Arm","rightHand"}}) do
            local hand=character:FindFirstChild(side[1]) or character:FindFirstChild(side[2])
            if hand and hand:IsA("BasePart") and allowed() then
                hasHand=true
                local touched=true
                if type(firetouchinterest)=="function" then
                    local began,beginError=pcall(function() firetouchinterest(entry.Root,hand,0) end)
                    local ended,endError=pcall(function() firetouchinterest(entry.Root,hand,1) end)
                    touched=began and ended
                    if touched then self.ContactPairs+=1
                    else self.LastAttackError="Contato recusado: "..tostring(beginError or endError) end
                elseif S.PvpMode~="Aproximar" then touched=false; self.LastAttackError="firetouchinterest indisponivel" end
                if touched and allowed() then
                    if safeFire(remote,"punch",side[3]) then
                        sent+=1; self.PunchRequests+=1; self.FirstAttemptAt=self.FirstAttemptAt or os.clock()
                    else self.LastAttackError="Golpe nao enviado: canal ou limite de chamadas" end
                end
            end
        end
        if not hasHand then self.LastAttackError="Maos ausentes ou alvo cancelado" end
        return sent
    end
    function P:punchNearby(player,targetRoot,targetHum,allowed)
        local punched,reason=doAnimatedPunch(allowed)
        if not punched then return false,reason end
        self:observeDamage()
        local previous=self.Observed[player.UserId]
        if not previous or previous.Model~=player.Character then
            self.Observed[player.UserId]={Player=player,Model=player.Character,Hum=targetHum,Health=targetHum.Health}
        end
        local sent=self:attackTarget(LP.Character,{Root=targetRoot},allowed)
        return sent>0,sent>0 and "Golpe solicitado" or self.LastAttackError
    end
    function P:orderTargets(candidates,root)
        local priority=S.PvpPriority
        table.sort(candidates,function(a,b)
            if priority=="Menor vida" and a.Hum.Health~=b.Hum.Health then return a.Hum.Health<b.Hum.Health end
            if priority=="Mais proximo" then
                local da,db=(a.Root.Position-root.Position).Magnitude,(b.Root.Position-root.Position).Magnitude
                if da~=db then return da<db end
            end
            return a.Player.UserId<b.Player.UserId
        end)
        if (priority=="Manter alvo" or S.PvpMode=="Perseguir") and self.LockedUserId then
            for i,entry in ipairs(candidates) do
                if entry.Player.UserId==self.LockedUserId then
                    local observed=self.Observed[entry.Player.UserId]
                    local lastProgress=math.max(self.LockedAt or os.clock(),observed and observed.LastDamageAt or 0)
                    local nextIndex=i
                    if priority~="Manter alvo" and #candidates>1 and os.clock()-lastProgress>=4 then
                        nextIndex=i%#candidates+1; self.LockedUserId=nil
                    end
                    local chosen=table.remove(candidates,nextIndex); table.insert(candidates,1,chosen); break
                end
            end
        end
    end
    function P:report()
        local remote=getMuscleEvent()
        local lines={"710Hub "..SESSION.Version,"Modo: "..S.PvpMode.." | filtro: "..S.PvpFilter.." | prioridade: "..S.PvpPriority,
            "Estado: "..(M.PvpStatus or "Desligado"),
            "muscleEvent: "..(remote and remote:IsA("RemoteEvent") and "disponivel" or "ausente"),
            "firetouchinterest: "..(type(firetouchinterest)=="function" and "disponivel" or "ausente"),
            string.format("Pares de contato: %d | golpes enviados: %d | queda de vida observada: %.0f | mortes observadas: %d",self.ContactPairs,self.PunchRequests,self.DamageTotal,self.DeathsObserved),
            "Ultimo erro de ataque: "..self.LastAttackError,
            "Mortes observadas nao comprovam autoria. Bring pode ser apenas local; o jogo valida alcance e dano."}
        for _,player in ipairs(Players:GetPlayers()) do
            if player~=LP then
                local model=player.Character; local hum=model and model:FindFirstChildOfClass("Humanoid")
                lines[#lines+1]=string.format("@%s: vida=%s | filtro=%s",player.Name,hum and tostring(hum.Health) or "ausente",X:pvpAllowed(player) and "aceito" or "protegido/excluido")
            end
        end
        return table.concat(lines,"\n")
    end
    local baseTick=M.pvpTick
    local function pvpTick(self)
        if S.PvpMode=="Aproximar" then P:hideArea(); return baseTick(self) end
        if not C:pvpActive() or not SESSION.Alive then P:restoreBring(); return baseTick(self) end
        if not self:canAct() or self.Comparing or HubRuntime.BossActive then
            self:stopPvp(); P:hideArea(); self.PvpStatus="PvP pausado"; return
        end
        local character=LP.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local hum=character and character:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then self:stopPvp(); self.PvpStatus="Aguardando personagem"; return end
        if S.HealthGuard and hum.MaxHealth>0 and hum.Health/hum.MaxHealth<=(S.HealthLow or 55)/100 then
            S.PvpAny,S.PvpGood,S.PvpEvil=false,false,false; P:stop(); self:stopPvp()
            self.PvpStatus="Parado por vida baixa"; return
        end
        if type(firetouchinterest)~="function" then self.PvpStatus="firetouchinterest indisponivel"; return end
        P:observeDamage()
        if S.PvpMode=="Aura" then P:showArea() else P:hideArea() end
        P:restoreBring()
        local candidates={}
        for _,player in ipairs(Players:GetPlayers()) do
            local model=player.Character
            local otherRoot=model and model:FindFirstChild("HumanoidRootPart")
            local otherHum=model and model:FindFirstChildOfClass("Humanoid")
            if X:pvpAllowed(player) and otherRoot and otherHum and otherHum.Health>0 and P:inRange(root,otherRoot)
                and self:pvpEligible(self:playerKarma(player,{"goodKarma","LightKarma"}),self:playerKarma(player,{"evilKarma","DarkKarma"})) then
                candidates[#candidates+1]={Player=player,Model=model,Root=otherRoot,Hum=otherHum}
            end
        end
        P:orderTargets(candidates,root)
        if #candidates==0 then self:stopPvp(); P.LockedUserId=nil; self.PvpStatus="Sem alvo elegivel | dano observado: "..math.ceil(P.DamageTotal); return end
        local token,mode,filter=P.Token,S.PvpMode,S.PvpFilter
        local function valid(entry)
            return SESSION.Alive and self:canAct() and not self.Comparing and not HubRuntime.BossActive and C:pvpActive()
                and token==P.Token and mode==S.PvpMode and filter==S.PvpFilter and LP.Character==character
                and hum.Health>0 and X:pvpAllowed(entry.Player) and entry.Player.Character==entry.Model
                and entry.Root.Parent==entry.Model and entry.Hum.Health>0 and P:inRange(root,entry.Root)
                and self:pvpEligible(self:playerKarma(entry.Player,{"goodKarma","LightKarma"}),self:playerKarma(entry.Player,{"evilKarma","DarkKarma"}))
        end
        local punched,reason=doAnimatedPunch(function()
            for _,entry in ipairs(candidates) do if valid(entry) then return true end end
            return false
        end)
        if not punched then self.PvpStatus=reason; return end
        local attempts=0
        local focus=mode=="Perseguir" or S.PvpPriority=="Manter alvo"
        local batch=focus and 1 or math.min(S.StabilityMode and 4 or 8,#candidates)
        for offset=1,batch do
            local index=S.PvpPriority=="Rotacao" and not focus and (P.Cursor+offset-1)%#candidates+1 or offset
            local entry=candidates[index]
            if valid(entry) then
                self.PvpTarget=entry.Player
                local last=P.Observed[entry.Player.UserId]
                if not last or last.Model~=entry.Model then
                    P.Observed[entry.Player.UserId]={Player=entry.Player,Model=entry.Model,Hum=entry.Hum,Health=entry.Hum.Health}
                end
                if focus and P.LockedUserId~=entry.Player.UserId then
                    P.LockedUserId=entry.Player.UserId; P.LockedAt=os.clock()
                end
                if mode=="Perseguir" then
                    root.CFrame=entry.Root.CFrame*CFrame.new(0,3.5,0)
                    root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
                end
                if mode=="Bring" then
                    local original=entry.Root.CFrame
                    local applied=root.CFrame*CFrame.new((offset-1)%3*3-3,0,-4-math.floor((offset-1)/3)*3)
                    entry.Root.CFrame=applied; P.Brought[entry.Root]={Original=original,Applied=applied}
                end
                if valid(entry) then
                    local sent=P:attackTarget(character,entry,function() return valid(entry) end)
                    if sent>0 then attempts+=1 end
                end
            end
        end
        P.Cursor=(P.Cursor+batch)%#candidates
        local stalled=P.FirstAttemptAt and os.clock()-(P.LastDamageAt or P.FirstAttemptAt)>=4
        self.PvpStatus=string.format("%s: %d alvos solicitados / %d elegiveis | dano observado: %.0f%s",mode,attempts,#candidates,P.DamageTotal,stalled and " | SEM DANO OBSERVADO" or "")
        if attempts==0 then self.PvpStatus..=" | "..P.LastAttackError end
        self.PvpDiagnostic=string.format("Contatos: %d | golpes enviados: %d | dano observado: %.0f | erro: %s",P.ContactPairs,P.PunchRequests,P.DamageTotal,P.LastAttackError)
    end
    function M:pvpTick()
        if P.InFlight then return end
        P.InFlight=true
        local ok,err=pcall(pvpTick,self)
        P.InFlight=false
        if not ok then error(err) end
    end
    function P:listsReport()
        local lines={self.Persistence,"Whitelist (prioridade sobre todos os filtros):"}
        for id in pairs(X.Whitelist) do lines[#lines+1]=tostring(id) end
        lines[#lines+1]="Alvos multiplos:"
        for id in pairs(self.Targets) do lines[#lines+1]=tostring(id) end
        lines[#lines+1]="Blacklist de tags: "..table.concat(self.Tags,", ")
        return table.concat(lines,"\n")
    end
    function P:findPlayer(text)
        if self.HunterBusy then return false end
        self.HunterBusy=true; self.HunterToken+=1
        local token=self.HunterToken; self.Destination=nil; self.HunterStatus="Buscando jogador..."
        local ok,err=pcall(function()
            local query=trim(text):gsub("^@","")
            local id=validId(query)
            if not id then
                assert(#query>=3 and #query<=20 and query:match("^[%w_]+$"),"Use UserId ou @usuario exato")
                id=Players:GetUserIdFromNameAsync(query)
            end
            if not SESSION.Alive or token~=self.HunterToken then return end
            for _,player in ipairs(Players:GetPlayers()) do
                if player.UserId==id then X.SelectedUserId=id; self.HunterStatus="Jogador presente neste servidor: @"..player.Name; return end
            end
            local online=LP:GetFriendsOnlineAsync(200)
            if not SESSION.Alive or token~=self.HunterToken then return end
            for _,friend in ipairs(online) do
                if friend.VisitorId==id and tonumber(friend.PlaceId) and friend.PlaceId>0 and type(friend.GameId)=="string" and friend.GameId~="" then
                    self.Destination={Place=friend.PlaceId,Job=friend.GameId,UserId=id}
                    self.HunterStatus="Servidor informado pelo Roblox. Use Entrar no servidor encontrado."; return
                end
            end
            self.HunterStatus="Servidor indisponivel. A consulta abrange amigos com localizacao visivel; nao localiza qualquer conta."
        end)
        if not ok and SESSION.Alive and token==self.HunterToken then self.HunterStatus="Busca indisponivel: "..tostring(err) end
        self.HunterBusy=false
        return ok
    end
    function P:joinFound()
        local destination=self.Destination
        if not destination then return false,"Busque um servidor disponivel primeiro" end
        stopAllAutomations()
        local ok,err=pcall(function() TeleportService:TeleportToPlaceInstance(destination.Place,destination.Job,LP) end)
        self.HunterStatus=ok and "Entrada solicitada ao Roblox; aguarde o teleporte" or "Falha na entrada: "..tostring(err)
        return ok,self.HunterStatus
    end
    if TeleportService.TeleportInitFailed then
        trackConnection(TeleportService.TeleportInitFailed:Connect(function(player,_,message)
            if player==LP then P.HunterStatus="Entrada recusada pelo Roblox: "..tostring(message) end
        end))
    end
    trackConnection(Players.PlayerRemoving:Connect(function(player) P.Observed[player.UserId]=nil end))
end
initializePvpRuntime()
