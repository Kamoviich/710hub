local newProbe=require("../FarmProbeCore")
local passed=0
local function check(value,message) assert(value,message); passed+=1; print("PASS: "..message) end
local pet={}
local function snapshot(t,multiplier)
    return {Strength=1000+t*100*(multiplier or 1),Durability=100+t*20*(multiplier or 1),Rebirths=100,
        Pets={[pet]=true},PetsKnown=true,Character="char",Server="server",Alive=true,Ping=40}
end
local function trial(p,kind,label)
    check(p:start(label or "710Hub",0,snapshot(0)),"Inicia rodada "..kind)
    for frame=1,3600 do
        local t=frame/60
        if (kind~="pause" and kind~="pauseBonus") or t<=20 or t>=25 then
            p:frame(t)
            if frame%15==0 then
                local visible=kind=="delayed" and math.floor(t/5)*5 or t
                p:sample(t,snapshot(visible,(kind=="bonus" or kind=="pauseBonus") and 2 or 1))
            end
        end
    end
    return p.History[#p.History]
end
local p=newProbe()
local normal=trial(p,"normal")
check(normal.Valid and normal.Duration==60,"Rodada normal usa 60 segundos completos")
check(normal.Rate.Strength==100 and normal.Rate.Durability==20,"Mede ganho conhecido de força e durabilidade")
check(normal.Gaps==0,"Sessenta FPS sem bloqueio não é classificado como pausa")
local pause=trial(p,"pause")
check(pause.Valid and pause.Gaps==1 and pause.MaxGap>=5,"Detecta intervalo sem Heartbeat na fixture de travada")
check(pause.Rate.Strength==normal.Rate.Strength and pause.Rate.Durability==normal.Rate.Durability,"Travada com ganho constante não inventa bônus de força/durabilidade")
check(pause.Delayed.Strength>0 and pause.Delayed.Durability>0,"Registra salto após intervalo sem mudança visível")
local delayed=trial(p,"delayed")
check(delayed.Gaps==0 and delayed.Delayed.Strength>=10,"Estatísticas em blocos são distinguidas de pausa do Heartbeat")
check(delayed.Rate.Strength==100 and delayed.Rate.Durability==20,"Entrega visível em blocos conserva média integral")
local bonus=trial(newProbe(),"bonus")
check(bonus.Rate.Strength==200 and bonus.Rate.Durability==40,"Bônus definido explicitamente na fixture aparece como ganho maior, sem ser deduzido da travada")
local late=newProbe(); late:start("710Hub",0,snapshot(0)); late:frame(58); late:sample(58,snapshot(58))
late:frame(65); local r=late:sample(65,snapshot(65))
check(r.Duration==65 and r.Rate.Strength==100,"Fim atrasado por travada usa 65 segundos, sem truncar janela a 60")
local changed=newProbe(); changed:start("710Hub",0,snapshot(0))
local s=snapshot(30); s.Rebirths+=1; s.Strength=0; changed:sample(30,s); changed:sample(60,snapshot(60))
check(not changed.History[1].Valid and changed.History[1].Reasons["Rebirths mudaram durante a rodada"],"Rebirth e queda de estatística invalidam comparação")
changed=newProbe(); changed:start("710Hub",0,snapshot(0)); s=snapshot(30); s.Pets={other=true}; changed:sample(30,s); changed:sample(60,snapshot(60))
check(not changed.History[1].Valid,"Mudança observada de pet é excluída da comparação")
changed=newProbe(); changed:start("710Hub",0,snapshot(0)); s=snapshot(30); s.Character="respawn"; changed:sample(30,s); changed:sample(60,snapshot(60))
check(not changed.History[1].Valid,"Respawn invalida rodada")
changed=newProbe(); changed:start("710Hub",0,snapshot(0)); changed:sample(60,{Strength=0/0,Durability=1})
check(not changed.History[1].Valid,"Estatística NaN não vira ganho válido")
changed=newProbe(); s=snapshot(0); s.PetsKnown=false; changed:start("710Hub",0,s); s=snapshot(60); s.PetsKnown=false; changed:sample(60,s)
check(not changed.History[1].Valid,"Pets não observáveis não produzem comparação confiável")
changed=newProbe(); changed:start("710Hub",0,snapshot(0)); changed:sample(10,snapshot(10)); changed:finish(10,false)
check(not changed.History[1].Valid and changed.History[1].Duration==10,"Interrupção preserva relatório parcial e exclui resultado")
check(not changed:start("desconhecido",0,snapshot(0)),"Recusa rótulo que não identifica o farm")
changed=newProbe(); changed:start("710Hub",0,snapshot(0))
check(not changed:start("Silence",0,snapshot(0)),"Não cria duas medições concorrentes")
local compare=newProbe()
for _=1,3 do trial(compare,"normal"); trial(compare,"pause") end
check(compare:compare("710Hub",true):find("(+0.0%)",1,true)~=nil,"Três rodadas por grupo detectam ausência de bônus apesar das travadas")
check(newProbe({normal}):compare("710Hub",true):find("faltam rodadas",1,true)~=nil,"Uma rodada não produz conclusão prematura")
local positive=newProbe()
for _=1,3 do trial(positive,"normal"); trial(positive,"pauseBonus") end
check(positive:compare("710Hub",true):find("(+100.0%)",1,true)~=nil,"Comparador reconhece bônus explícito da fixture em rodadas com pausa")
local incompatible=newProbe({normal,normal,normal,pause,pause,pause})
local other=trial(newProbe(),"normal"); other.First.Rebirths=200; incompatible.History[#incompatible.History+1]=other
check(incompatible:compare("710Hub",true):find("Condições",1,true)~=nil,"Mudança de condições entre rodadas torna comparação inconclusiva")
check(p:report(60):find("não prova causa",1,true)==nil and compare:report(60):find("não prova causa",1,true)~=nil,"Relatório qualifica associação e exige amostra mínima")
local retained=newProbe()
for _=1,15 do retained:start("710Hub",0,snapshot(0)); retained:sample(60,snapshot(60)) end
check(#retained.History==12,"Histórico fica limitado a doze rodadas")
print(string.format("FIXTURE_RATES: normal=%.1f/%.1f pause=%.1f/%.1f delayed=%.1f/%.1f bonus=%.1f/%.1f (strength/durability por segundo)",normal.Rate.Strength,normal.Rate.Durability,pause.Rate.Strength,pause.Rate.Durability,delayed.Rate.Strength,delayed.Rate.Durability,bonus.Rate.Strength,bonus.Rate.Durability))
print("PROBE_CORE_TOTAL: "..passed.." verificações")
