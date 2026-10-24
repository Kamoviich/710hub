Mock.Run(3)
local P,U=Mock.Published,Mock.FullUI
check(P and U,"Menu limpo inicializa inteiro")
local S,M,R=P.S,P.M,P.Runtime
local C,X,controls=R.Clean,R.Extras,U.UI.Catalog
local covered={}
local function mark(id) covered[id]=true end
local function click(id)
    assert(controls[id],"Controle ausente: "..id)
    Mock.Click(controls[id].Object); mark(id)
end
local function value(id,text)
    local box=controls[id].Object; box.Text=text; box.FocusLost:Fire(true); Mock.Run(.05); mark(id)
end
local function select(id,label)
    click(id)
    local popup=U.Main:FindFirstChild("710Hub_Choice"); assert(popup,"Seletor não abriu: "..id)
    for _,object in ipairs(popup:GetDescendants()) do
        if object:IsA("TextButton") and object.Text==label then Mock.Click(object); return end
    end
    error("Opção ausente: "..id.."/"..label)
end
local function stop() P.Stop(); Mock.Run(.2); M:pause("Manual",false) end
local initialCalls=#Mock.Calls
local count=0; local titles={}
for id,item in pairs(controls) do
    count+=1
    check(not titles[item.Title],"Título único: "..item.Title); titles[item.Title]=id
    check(not id:find("Source_") and not item.Title:find("Silence") and not item.Title:find("Mystery"),"Controle pertence ao 710Hub")
end
check(count<100 and not R.SourceBridge,"Catalogo com PvP ampliado, sem modulos importados ou controles duplicados")
check(#Mock.Calls==initialCalls,"Abrir o menu não treina nem gasta recursos")
select("farm_preset","Ultra combinado")
check(S.FastRep and not S.Rebirth and S.FastRepProfile=="Combinado","Preset combinado ativa as duas rotas sem alterar pets")
stop()
select("farm_preset","Ultra rápido")
check(S.FastRep and not S.Rebirth and S.FastRepProfile=="Ultra (lotes)","Preset Ultra ativa lotes sem renascer ou alterar pets")
stop()
select("farm_preset","Força acumulada")
check(S.FastRep and not S.Rebirth and S.FastRepLimit==659 and S.FastRepProfile=="Intensivo","Preset de força usa alvo 659/s do Silence sem zerar por rebirth")
stop(); select("farm_preset","Rebirth rápido")
check(S.FastRep and S.Rebirth and S.FastRepLimit==450 and S.RebirthInterval==0,"Preset de rebirth inicia treino moderado e confirmação sem espera local")
stop()
for _,touch in ipairs({false,true}) do
    services.UserInputService.TouchEnabled=touch
    for _,size in ipairs({{1200,900},{390,844},{844,390},{320,320},{640,260}}) do
        workspace.CurrentCamera.ViewportSize=Vector2.new(size[1],size[2]); U.UI:resize()
        local height=U.Main.Size.Y.Offset+U.Scroll.Size.Y.Offset
        check(height>0 and U.Scroll.Position.Y.Offset+height<=U.Main.Size.Y.Offset-60,"Rolagem cabe com toque="..tostring(touch).." em "..size[1].."x"..size[2])
    end
end
U.UI.LargeText=true; U.UI:resize(); U.UI.LargeText=false; U.UI:resize()
value("farm_interval","100"); value("farm_reps","4")
check(S.FarmCustom and S.FarmIntervalMs==100 and S.FarmReps==4,"Ritmo digitado é aplicado")
value("farm_interval","inválido"); value("farm_reps","0")
check(S.FarmIntervalMs==100 and S.FarmReps==4,"Ritmo inválido não altera configuração")
value("fast_rep_limit","10000"); value("fast_rep_limit","10001")
check(S.FastRepLimit==10000,"Limite do Fast Rep rejeita valor fora de 40–10000")
select("rep_profile","Explorar limite"); check(S.FastRepProfile=="Explorar limite","Seletor aplica exploração progressiva")
select("rep_profile","Intensivo"); check(S.FastRepProfile=="Intensivo","Seletor aplica envio intensivo")
select("rep_profile","Adaptativo"); value("fast_rep_limit","659")
click("farm_pace")
check(U.Main:FindFirstChild("710Hub_Choice")~=nil,"Rendimento observado abre relatório")
for _,mode in ipairs(C.Modes) do
    stop(); select("farm_method",mode)
    if mode=="Máquina" then select("machine_select","Overcharged Bench") end
    local strength,agility=Mock.Stats.Strength.Value,Mock.Stats.Agility.Value
    local touches=Mock.Touches or 0
    click("farm_start"); Mock.Run(1.3)
    local key=C.ModeKeys[mode]
    check(S[key] and C:farming(),"Controlador ativa somente o método: "..mode)
    if mode=="Esteira" then check(Mock.Stats.Agility.Value>agility,"Esteira executa movimento e ganho simulado")
    elseif mode=="Pedras" then check((Mock.Touches or 0)>touches and S.AutoPunch,"Pedras usam contato e Punch")
    else check(Mock.Stats.Strength.Value>strength,"Treino executa ganho observado na fixture: "..mode) end
    click("farm_start"); local calls=#Mock.Calls; Mock.Run(.8)
    check(not C:farming() and #Mock.Calls==calls,"Desligar treino interrompe o método: "..mode)
end
stop(); value("rebirth_interval","0,5"); value("rebirth_target",tostring(Mock.Stats.Rebirths.Value+1))
Mock.Stats.Strength.Value=5000+Mock.Stats.Rebirths.Value*2550; local births=Mock.Stats.Rebirths.Value
click("rebirth_auto"); Mock.Run(1)
check(Mock.Stats.Rebirths.Value==births+1 and not S.Rebirth,"Rebirth faz o ciclo e para na meta")
value("rebirth_target","0"); check(S.RebirthTarget==nil,"Meta zero remove limite de rebirth")
local gems=Mock.Stats.Gems.Value; click("chests_auto"); Mock.Run(3)
check(Mock.Stats.Gems.Value>gems and Mock.Count("checkChestRemote")>0,"Baús usam o canal conhecido e registram resposta")
stop(); local spins=Mock.Count("openFortuneWheelRemote"); click("wheel_auto"); Mock.Run(6)
check(Mock.Count("openFortuneWheelRemote")-spins==2,"Roleta respeita pedidos a cada cinco segundos")
stop(); Mock.Rejections.openFortuneWheelRemote=false; click("wheel_auto"); Mock.Run(5)
check(not S.AutoWheel,"Roleta desliga ao receber recusa")
Mock.Rejections.openFortuneWheelRemote=nil
click("eggs_auto"); click("boosts_auto"); Mock.Run(3.5)
check(Mock.Count("muscleEvent","proteinEgg")>0 and Mock.Count("muscleEvent","tropicalShake")>0,"Consumíveis enviam os itens e comandos corretos")
stop(); click("pets_auto"); Mock.Run(1)
local equipped={}; for _,slot in ipairs(Mock.Slots:GetChildren()) do equipped[slot.petReference.Value or false]=true end
check(equipped[Mock.BestPet],"Autoequip aplica força aos pets possuídos")
for _,pair in ipairs({{"Durabilidade","durability"},{"Agilidade","agility"},{"Força","strength"}}) do
    select("pet_attribute",pair[1]); Mock.Run(1)
    check(S.PetObjective==pair[2],"Prioridade de pet aplicada: "..pair[1])
    local worn={}; for _,slot in ipairs(Mock.Slots:GetChildren()) do if slot.petReference.Value then worn[slot.petReference.Value.Name]=true end end
    if pair[2]=="strength" then check(worn["Strong Pet"] and worn["Balanced Pet"] and worn["Durable Pet"] and not worn["Agile Pet"],"Seleção de força equipa o conjunto com melhores valores")
    else check(worn["Durable Pet"] and worn["Balanced Pet"] and worn["Agile Pet"] and not worn["Strong Pet"],"Seleção de atributo troca pets com valor menor") end
end
stop()
local protected=Mock.Owned:FindFirstChild("Evolve Pet"); protected:SetAttribute("Locked",true)
local evolved=Mock.Count("petEvolveEvent"); click("evolve_auto"); Mock.Run(5.5)
check(Mock.Count("petEvolveEvent")==evolved and protected.Parent~=nil,"Evolução preserva pet bloqueado e não inventa grupos")
protected:SetAttribute("Locked",nil); Mock.Run(6)
check(Mock.Count("petEvolveEvent")>evolved,"Evolução usa grupo válido de cinco pets")
stop(); select("crystal_select","Blue Crystal"); value("hatch_limit","2"); value("hatch_target","")
local opened=Mock.Count("openCrystalRemote"); click("hatch_auto"); Mock.Run(3)
check(Mock.Count("openCrystalRemote")==opened+2 and not S.Hatch,"Cristais encerram exatamente no limite de solicitações")
mark("hatch_status")
value("hatch_target","Hatched Pet"); opened=Mock.Count("openCrystalRemote"); click("hatch_auto"); Mock.Run(.5)
check(Mock.Count("openCrystalRemote")==opened and not S.Hatch,"Pet alvo já possuído impede gasto")
value("hatch_target",""); Mock.Rejections.openCrystalRemote=false; click("hatch_auto"); Mock.Run(.5)
check(not S.Hatch and C.HatchStatus:find("recusada"),"Cristal recusado é interrompido")
Mock.Rejections.openCrystalRemote=nil
local priorInvoke=methods.InvokeServer
methods.InvokeServer=function(self,...)
    if self.Name=="openCrystalRemote" then task.wait(1); return priorInvoke(self,...) end
    return priorInvoke(self,...)
end
opened=Mock.Count("openCrystalRemote"); click("hatch_auto"); Mock.Run(.2); stop(); Mock.Run(1.5)
check(not S.Hatch and C.HatchSent==0 and Mock.Count("openCrystalRemote")<=opened+1,"Resposta atrasada não retoma nem contabiliza lote cancelado")
methods.InvokeServer=priorInvoke
methods.InvokeServer=function(self,...)
    if self.Name=="openCrystalRemote" then
        Mock.Calls[#Mock.Calls+1]={Time=Mock.Now,Name=self.Name,Args=table.pack(...)}
        return true
    end
    return priorInvoke(self,...)
end
value("hatch_limit","20"); click("hatch_auto"); Mock.Run(7)
check(not S.Hatch and C.HatchUnconfirmed==6,"Seis respostas sem ganho observado encerram abertura")
methods.InvokeServer=priorInvoke
select("shop_select","Pet: Blue Pet"); value("shop_count","3")
local bought=Mock.Count("cPetShopRemote"); click("shop_buy"); Mock.Run(3)
check(Mock.Count("cPetShopRemote")==bought+3 and not X.Buying,"Compra envia o lote selecionado sequencialmente")
value("shop_count","10"); click("shop_buy"); Mock.Run(.8); bought=Mock.Count("cPetShopRemote"); stop(); Mock.Run(2)
check(Mock.Count("cPetShopRemote")==bought and not X.Buying,"Parar cancela compras restantes do lote")
value("shop_count","3")
value("shop_count","0"); check(S.ShopCount==3,"Quantidade inválida não causa compra")
stop(); select("goal_stat","Strength"); value("goal_value",tostring(Mock.Stats.Strength.Value+1)); click("goal_enabled")
select("farm_method","Peso"); click("farm_start"); Mock.Run(1.2)
check(not C:farming() and not S.GoalEnabled,"Meta observada para todas as rotinas")
value("stop_minutes","0,02"); click("farm_start"); Mock.Run(2)
check(not C:farming() and S.StopAt==nil,"Temporizador encerra a sessão ativa")
value("stop_minutes","0"); check(S.StopAt==nil,"Temporizador zero fica desligado")
value("boss_height","2,5"); check(S.BossDistance==2.5,"Altura do boss aceita decimal")
value("health_limits","40 / 80"); check(S.HealthLow==40 and S.HealthResume==80,"Limites de vida são aplicados juntos")
value("health_limits","90 / 20"); check(S.HealthLow==40 and S.HealthResume==80,"Limites invertidos são rejeitados")
for _,id in ipairs({"boss_above","boss_loot","boss_return","boss_defense","health_guard"}) do click(id); click(id) end
local boss=spawnBoss("Clean Rainbow Boss","Rainbow"); click("boss_auto"); Mock.Run(.7)
check(R.BossActive and M.BossHoverSaved,"Auto Boss seleciona alvo e aplica ataque superior")
click("boss_status"); stop(); boss.Humanoid.Health=0
select("player_select","Enemy (@Enemy)"); select("pvp_filter","Selecionado")
local ray=methods.Raycast; methods.Raycast=function() return nil end
click("pvp_start"); Mock.Run(.6)
check(M.PvpTarget==Mock.EnemyPlayer,"PvP selecionado usa a conta correta")
local protection=node("Highlight","spawnProtectionHighlight",Mock.EnemyPlayer.Character); Mock.Run(.4)
check(not M.PvpTarget,"PvP respeita indicador de proteção de spawn")
protection:Destroy(); Mock.EnemyPlayer.Character:SetAttribute("SpawnProtectedUntil",1010); Mock.Run(.4)
check(not M.PvpTarget,"PvP respeita prazo de proteção replicado")
Mock.EnemyPlayer.Character:SetAttribute("SpawnProtectedUntil",999); Mock.Run(.4)
check(M.PvpTarget==Mock.EnemyPlayer,"Proteção expirada permite retomar alvo")
click("player_protect"); Mock.Run(.4)
check(not M.PvpTarget,"Conta protegida deixa de ser atacada")
click("player_protect"); click("pvp_friends"); X.FriendCache[Mock.EnemyPlayer.UserId]=true; X.FriendChecked[Mock.EnemyPlayer.UserId]=Mock.Now; Mock.Run(.5)
check(not M.PvpTarget,"Amigo confirmado fica protegido")
click("pvp_friends"); select("pvp_filter","Todos"); Mock.Run(.5)
check(S.PvpAny and not S.PvpOnlySelected,"Filtro todos remove restrição à conta selecionada")
select("pvp_filter","Karma bom"); check(S.PvpGood and not S.PvpAny,"Filtro bom ativa somente o modo de karma correspondente")
select("pvp_filter","Karma ruim"); check(S.PvpEvil and not S.PvpGood,"Filtro ruim substitui o filtro anterior")
click("pvp_start"); methods.Raycast=ray
click("spectate"); Mock.Run(.6)
check(workspace.CurrentCamera.CameraSubject==Mock.EnemyPlayer.Character.Humanoid,"Observar usa câmera do jogador escolhido")
click("spectate"); Mock.Run(.6)
check(workspace.CurrentCamera.CameraSubject==Mock.Player.Character.Humanoid,"Desligar observação restaura câmera")
click("player_stats"); check(U.Main:FindFirstChild("710Hub_Choice")~=nil,"Estatísticas replicadas aparecem no relatório")
select("profile_slot","2"); S.PetObjective="agility"; S.FarmMode="Flexões"; S.CameraFOV=88; click("profile_save")
S.PetObjective="strength"; S.FarmMode="Peso"; S.CameraFOV=99; click("profile_load")
check(S.PetObjective=="agility" and S.FarmMode=="Flexões" and M.Reasons.Manual,"Perfil restaura escolhas em pausa")
check(controls.camera_fov.Object.Text=="88","Campos visíveis refletem o perfil carregado")
M:pause("Manual",false); click("resume_death"); check(not S.ResumeAfterDeath,"Retomada automática pode ser desativada"); click("resume_death")
click("history"); check(U.Main:FindFirstChild("710Hub_Choice")~=nil,"Histórico abre relatório")
local calls=#Mock.Calls; click("self_test"); check(#Mock.Calls==calls,"Autoteste não envia compras ou treino")
mark("session_status")
value("character_speed","60"); value("character_size","3"); click("speed_enabled"); click("size_enabled"); Mock.Run(2.5)
check(Mock.Count("changeSpeedSizeRemote","changeSpeed")>0 and Mock.Count("changeSpeedSizeRemote","changeSize")>0,"Ajustes do personagem usam protocolos conhecidos")
value("camera_fov","96"); click("fov_enabled"); Mock.Run(.6)
check(workspace.CurrentCamera.FieldOfView==96,"FOV solicitado é aplicado")
click("fov_enabled"); Mock.Run(.6); check(workspace.CurrentCamera.FieldOfView==73,"FOV anterior é restaurado")
click("shiftlock"); Mock.Run(.6)
check(services.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter,"Shiftlock prende cursor")
click("shiftlock"); Mock.Run(.6); check(services.UserInputService.MouseBehavior==Enum.MouseBehavior.Default,"Shiftlock restaura cursor")
click("jump"); local beforeJump=jumps; services.UserInputService.JumpRequest:Fire(); Mock.Run(.1)
check(jumps==beforeJump+1,"Pulo usa evento do botão de salto")
M:pause("Manual",true); services.UserInputService.JumpRequest:Fire(); Mock.Run(.1)
check(jumps==beforeJump+1,"Pausa central impede salto"); M:pause("Manual",false)
local rootPart=Mock.Player.Character.HumanoidRootPart
rootPart.AssemblyLinearVelocity=Vector3.zero; rootPart.AssemblyAngularVelocity=Vector3.zero
click("antifling"); Mock.Run(.6); local safe=rootPart.CFrame
rootPart.CFrame=CFrame.new(999,999,999); rootPart.AssemblyLinearVelocity=Vector3.new(200,0,0); Mock.Run(.6)
check(rootPart.CFrame==safe and rootPart.AssemblyLinearVelocity.Magnitude==0,"Proteção contra arremesso recupera posição recente")
click("performance"); Mock.Run(.1); check(not services.Lighting.GlobalShadows,"Otimização reduz sombras")
click("performance"); Mock.Run(.1); check(services.Lighting.GlobalShadows,"Otimização restaura sombras")
click("stability"); check(S.StabilityMode and S.PerformanceMode,"Modo estável aplica limites e otimização")
click("stability"); check(not S.StabilityMode,"Modo estável pode ser desligado")
click("save_position"); local point=X.ReturnPoint; select("teleport","Beach"); Mock.Run(.2)
check(M.Reasons.Manual and rootPart.Position.X==20,"Teleporte usa ponto carregado em vez de duplicar coordenada de Beach")
local destinations=C:destinations(); local beaches=0
for _,d in ipairs(destinations) do if d.Label=="Beach" then beaches+=1 end end
check(beaches==1,"Destinos de mesmo nome são consolidados")
local beforePosition=rootPart.CFrame; Mock.MissingFloor=true; select("teleport","Beach"); Mock.Run(.2)
check(rootPart.CFrame==beforePosition,"Destino sem piso é rejeitado")
Mock.MissingFloor=false
select("teleport","Posição salva nesta sessão"); Mock.Run(.2); check(rootPart.CFrame==point,"Posição salva aparece no mesmo seletor")
click("rejoin"); check(Mock.Rejoined and Mock.Rejoined.Job==game.JobId,"Reentrar solicita o mesmo servidor")
local oldProfile=M:profile(); oldProfile.Settings.AutoNovaPhoenix=true; oldProfile.Settings.HideStats=true
oldProfile.Settings.BreakEnabled=true; oldProfile.Settings.RebirthGuard=true
check(M:applyProfile(oldProfile) and not S.AutoNovaPhoenix and not S.HideStats and not S.BreakEnabled and not S.RebirthGuard,"Perfil antigo não reativa rotinas removidas")
stop(); click("close"); local afterClose=#Mock.Calls; Mock.Run(2)
check(not P.Session.Alive and #Mock.Calls==afterClose,"Encerrar impede todas as novas chamadas")
for id in pairs(controls) do check(covered[id],"Opção exercitada: "..id) end
if #Mock.Errors>0 then for _,err in ipairs(Mock.Errors) do nativePrint("ERROR",err) end end
check(#Mock.Errors==0,"Todas as opções mantidas executam sem coroutines com erro no simulador")
nativePrint("CLEAN_TOTAL: "..Mock.Passed.." verificações; "..count.." elementos de menu")
local parts={}
for id,item in pairs(controls) do parts[#parts+1]='{"id":"'..id..'","kind":"'..item.Kind..'","tested":true}' end
nativePrint("CLEAN_CATALOG:["..table.concat(parts,",").."]")
