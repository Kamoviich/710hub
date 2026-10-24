-- One bounded PvP controller; actual damage and movement remain server validated.
local function initializePvpRuntime()
    local X,C=HubRuntime.Extras,HubRuntime.Clean
    local P={Targets={},Tags={},Brought={},Observed={},Cursor=0,Token=0,HunterToken=0,HunterStatus="Pronto",Persistence="Sessao"}
    HubRuntime.Pvp=P
    S.PvpMode=S.PvpMode or "Aproximar"
    S.PvpAuraRadius=S.PvpAuraRadius or 30
    S.PvpUniversal=S.PvpUniversal==true
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
        return baseStart(self)
    end
    function P:setMode(mode)
        if not table.find({"Aproximar","Distancia","Bring","Aura"},mode) then return false end
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
    local baseTick=M.pvpTick
    function M:pvpTick()
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
        table.sort(candidates,function(a,b) return a.Player.UserId<b.Player.UserId end)
        if #candidates==0 then self:stopPvp(); self.PvpStatus="Sem alvo elegivel no alcance; personagens distantes podem nao estar carregados"; return end
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
        local hand=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
        if not hand then self.PvpStatus="Mao do personagem indisponivel"; return end
        local attempts,damage=0,0
        for offset=1,math.min(8,#candidates) do
            local entry=candidates[(P.Cursor+offset-1)%#candidates+1]
            if valid(entry) then
                self.PvpTarget=entry.Player
                local last=P.Observed[entry.Player.UserId]
                if last and last.Model==entry.Model then damage+=math.max(0,last.Health-entry.Hum.Health) end
                P.Observed[entry.Player.UserId]={Model=entry.Model,Health=entry.Hum.Health}
                if mode=="Bring" then
                    local original=entry.Root.CFrame
                    local applied=root.CFrame*CFrame.new((offset-1)%3*3-3,0,-4-math.floor((offset-1)/3)*3)
                    entry.Root.CFrame=applied; P.Brought[entry.Root]={Original=original,Applied=applied}
                end
                if valid(entry) then
                    -- Always close a contact pair, including when the server rejects damage.
                    local ok,err=pcall(function() firetouchinterest(hand,entry.Root,0) end)
                    pcall(function() firetouchinterest(hand,entry.Root,1) end)
                    if ok then attempts+=1 else self.PvpDiagnostic=tostring(err) end
                end
            end
        end
        P.Cursor=(P.Cursor+math.min(8,#candidates))%#candidates
        self.PvpStatus=string.format("%s: %d contatos solicitados / %d alvos | queda de vida observada: %.0f",mode,attempts,#candidates,damage)
        self.PvpDiagnostic="Dano depende do servidor. Range universal cobre personagens carregados. Bring pode ser apenas local."
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
