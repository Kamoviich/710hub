-- Passive measurements only. Snapshot values and frame times are supplied by the client.
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function samePets(a,b)
    if not a or not b then return false end
    for pet in pairs(a) do if not b[pet] then return false end end
    for pet in pairs(b) do if not a[pet] then return false end end
    return true
end
local function validValues(s)
    return s and finite(s.Strength) and finite(s.Durability) and s.Strength>=0 and s.Durability>=0
end
local function reason(r,text) r.Reasons[text]=true end
local function compatible(a,b)
    return a.PetsKnown and b.PetsKnown and samePets(a.Pets,b.Pets)
        and finite(a.Rebirths) and a.Rebirths==b.Rebirths and a.Server==b.Server
end
local function median(values)
    table.sort(values); local n=#values
    return n%2==1 and values[(n+1)/2] or (values[n/2]+values[n/2+1])/2
end
local function compact(n)
    for _,unit in ipairs({{1e18,"Qi"},{1e15,"Qa"},{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
        if math.abs(n)>=unit[1] then return string.format("%.3f%s",n/unit[1],unit[2]) end
    end
    return string.format("%.2f",n)
end
return function(history)
    local P={History=history or {},Duration=60,GapThreshold=.25}
    function P:start(label,now,snapshot)
        if self.Active then return false,"Encerre a medição atual primeiro" end
        if label~="710Hub" and label~="Silence" then return false,"Modo desconhecido" end
        if not finite(now) or not validValues(snapshot) then return false,"Força/durabilidade não observáveis" end
        if not snapshot.Alive then return false,"Aguarde o personagem vivo" end
        local pets={}; for pet in pairs(snapshot.Pets or {}) do pets[pet]=true end
        local first={Strength=snapshot.Strength,Durability=snapshot.Durability,Rebirths=snapshot.Rebirths,
            Pets=pets,PetsKnown=snapshot.PetsKnown,Server=snapshot.Server,Character=snapshot.Character}
        self.Active={Label=label,Started=now,LastFrameAt=now,LastSampleAt=now,First=first,Last=snapshot,
            Frames=0,Gaps=0,MaxGap=0,GapSeconds=0,Reasons={},PingSum=0,PingCount=0,
            QuietSince={Strength=now,Durability=now},Delayed={Strength=0,Durability=0},MaxQuiet=0}
        return true,"Medição iniciada"
    end
    function P:frame(now)
        local r=self.Active
        if not r or not finite(now) or now<=r.LastFrameAt then return end
        local gap=now-r.LastFrameAt
        r.LastFrameAt=now; r.Frames+=1; r.MaxGap=math.max(r.MaxGap,gap)
        if gap>=self.GapThreshold then r.Gaps+=1; r.GapSeconds+=gap end
    end
    function P:finish(now,complete)
        local r=self.Active
        if not r then return end
        r.Duration=math.max(0,now-r.Started)
        if not complete or r.Duration<self.Duration then reason(r,"Rodada interrompida") end
        if not r.First.PetsKnown then reason(r,"Pets equipados não observáveis") end
        if not finite(r.First.Rebirths) then reason(r,"Rebirths não observáveis") end
        r.Valid=next(r.Reasons)==nil
        r.Gain={}; r.Rate={}
        for _,key in ipairs({"Strength","Durability"}) do
            r.Gain[key]=r.Last[key]-r.First[key]
            r.Rate[key]=r.Duration>0 and r.Gain[key]/r.Duration or 0
        end
        self.History[#self.History+1]=r
        while #self.History>12 do table.remove(self.History,1) end
        self.Active=nil
        return r
    end
    function P:sample(now,s)
        local r=self.Active
        if not r or not finite(now) or now<r.LastSampleAt then return end
        if not validValues(s) then
            reason(r,"Estatística indisponível durante a rodada")
        else
            if not s.Alive or s.Character~=r.First.Character then reason(r,"Morte ou troca de personagem") end
            if s.Rebirths~=r.First.Rebirths then reason(r,"Rebirths mudaram durante a rodada") end
            if s.PetsKnown~=r.First.PetsKnown or not samePets(s.Pets,r.First.Pets) then reason(r,"Pets equipados mudaram") end
            if s.Server~=r.First.Server then reason(r,"Servidor mudou") end
            for _,key in ipairs({"Strength","Durability"}) do
                if s[key]<r.Last[key] then reason(r,"Queda de "..key.."; possível reset") end
                if s[key]~=r.Last[key] then
                    local quiet=now-r.QuietSince[key]
                    if s[key]>r.Last[key] and quiet>=1 then r.Delayed[key]+=1; r.MaxQuiet=math.max(r.MaxQuiet,quiet) end
                    r.QuietSince[key]=now
                end
            end
            r.Last=s
            if finite(s.Ping) and s.Ping>=0 then r.PingSum+=s.Ping; r.PingCount+=1 end
        end
        r.LastSampleAt=now
        if now-r.Started>=self.Duration then return self:finish(now,true) end
    end
    function P:compare(label,byGaps)
        local groups={A={},B={}}; local baseline
        for _,r in ipairs(self.History) do
            if r.Valid and (not byGaps or r.Label==label) then
                if baseline and not compatible(baseline,r.First) then return "Condições entre rodadas mudaram (pets/rebirths/servidor); comparação inconclusiva." end
                baseline=baseline or r.First
                local group=byGaps and (r.Gaps>0 and "B" or "A") or (r.Label=="710Hub" and "A" or "B")
                table.insert(groups[group],r)
            end
        end
        local title=byGaps and label..": com pausas / sem pausas" or "Silence / 710Hub"
        if #groups.A<3 or #groups.B<3 then return string.format("%s: faltam rodadas válidas (mínimo 3 por grupo; atual %d/%d).",title,#groups.B,#groups.A) end
        local lines={title.." — associação observada; não prova causa:"}
        for _,key in ipairs({"Strength","Durability"}) do
            local a,b={},{}
            for _,r in ipairs(groups.A) do a[#a+1]=r.Rate[key] end
            for _,r in ipairs(groups.B) do b[#b+1]=r.Rate[key] end
            local x,y=median(a),median(b)
            lines[#lines+1]=string.format("%s: mediana %s/s / %s/s%s",key,compact(y),compact(x),x>0 and string.format(" (%+.1f%%)",(y/x-1)*100) or " (base zero)")
        end
        return table.concat(lines,"\n")
    end
    function P:report(now)
        local lines={"710Hub — medidor passivo de força/durabilidade",
            "Ative um único farm antes de medir. Mantenha pets, boosts, modo e servidor iguais; rebirth desligado."}
        if self.Active then
            local r=self.Active
            lines[#lines+1]=string.format("MEDINDO %s: %.1f/60s | pausas ≥250ms: %d | maior intervalo: %.2fs",r.Label,now-r.Started,r.Gaps,r.MaxGap)
        else lines[#lines+1]="Aguardando medição. Cada rodada conta 60s completos, incluindo travadas." end
        for index,r in ipairs(self.History) do
            local reasons={}; for text in pairs(r.Reasons) do reasons[#reasons+1]=text end; table.sort(reasons)
            lines[#lines+1]=string.format("#%d %s | %.2fs | %s\nForça: +%s (%s/s) | Durabilidade: +%s (%s/s)\nPausas: %d | maior: %.2fs | ping médio amostrado: %s\nSaltos após ≥1s sem mudança: força %d / dura %d%s",index,r.Label,r.Duration,
                r.Valid and "válida" or table.concat(reasons,"; "),compact(r.Gain.Strength),compact(r.Rate.Strength),compact(r.Gain.Durability),compact(r.Rate.Durability),r.Gaps,r.MaxGap,
                r.PingCount>0 and string.format("%.0fms",r.PingSum/r.PingCount) or "indisponível",r.Delayed.Strength,r.Delayed.Durability,
                r.MaxQuiet>0 and string.format(" | intervalo maior %.2fs",r.MaxQuiet) or "")
        end
        lines[#lines+1]=self:compare("710Hub",true)
        lines[#lines+1]=self:compare("Silence",true)
        lines[#lines+1]=self:compare(nil,false)
        lines[#lines+1]="Pausas do Heartbeat não identificam a causa. Mudanças de boosts, evolução de pets e filas remanescentes podem afetar o resultado. Ganhos são valores visíveis ao cliente, não confirmação independente do servidor."
        return table.concat(lines,"\n\n")
    end
    return P
end
