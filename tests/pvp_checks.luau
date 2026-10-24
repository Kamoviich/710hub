-- Run through the real menu, scheduler and contact adapter in check_clean.py.
stop()
local Pv=R.Pvp
local enemy=Mock.EnemyPlayer
local ownRoot=Mock.Player.Character.HumanoidRootPart
local enemyRoot=enemy.Character.HumanoidRootPart
local ownFrame,enemyFrame=ownRoot.CFrame,enemyRoot.CFrame
local enemyHum=enemy.Character.Humanoid
enemyHum.Health=100; enemyHum.MaxHealth=100
Mock.Player.Character.Humanoid.Health=100; Mock.Player.Character.Humanoid.MaxHealth=100
S.HealthGuard=false; S.PvpProtectFriends=false; S.PvpOnlySelected=false
S.PvpFilter="Todos"; X.Whitelist={}
local originalTouch=firetouchinterest
local contacts={}
firetouchinterest=function(hand,root,state)
    contacts[#contacts+1]={Hand=hand,Root=root,State=state}
end
ownRoot.CFrame=CFrame.new(0,5,0); enemyRoot.CFrame=CFrame.new(1000,5,0)
select("pvp_mode","Distancia"); value("pvp_radius","30")
click("pvp_start"); Mock.Run(.6)
check(#contacts==0,"Distancia respeita raio de busca")
local startFrame=ownRoot.CFrame
click("pvp_universal"); Mock.Run(.8)
check(#contacts>0 and #contacts%2==0 and ownRoot.CFrame==startFrame,"Universal tenta contato distante em pares sem teleportar usuario")
check(enemyHum.Health==100,"Contato solicitado nao inventa morte quando servidor nao aplica dano")
local shield=node("ForceField","SpawnShield",enemy.Character)
local shieldBefore=#contacts; Mock.Run(.5)
check(#contacts==shieldBefore,"Contato distante respeita protecao de spawn")
shield:Destroy()
value("pvp_whitelist_id","+2"); local before=#contacts; Mock.Run(.6)
check(#contacts==before,"Whitelist por UserId bloqueia ataque a distancia")
value("pvp_whitelist_id","-2"); value("pvp_whitelist_id","invalido")
X.SelectedUserId=enemy.UserId; click("pvp_target")
select("pvp_filter","Multiplos"); Mock.Run(.6)
check(Pv.Targets[enemy.UserId] and #contacts>before,"Lista multipla inclui apenas contas selecionadas")
click("pvp_target"); before=#contacts; Mock.Run(.6)
check(#contacts==before,"Remover ultimo alvo interrompe contatos")
click("pvp_target")
select("pvp_mode","Bring"); enemyRoot.CFrame=CFrame.new(1000,5,0); Mock.Run(.7)
check((enemyRoot.Position-ownRoot.Position).Magnitude<15,"Bring solicita deslocamento local dos alvos")
value("pvp_whitelist_id","+2"); Mock.Run(.5)
check(enemyRoot.Position.X==1000,"Whitelist restaura bring antes do proximo ataque")
value("pvp_whitelist_id","-2"); click("pvp_start")
value("pvp_tag","+[CL.A]"); value("pvp_tag","+[")
check(#Pv.Tags==1 and Pv.Tags[1]=="[cl.a]","Blacklist valida tamanho e preserva tag literal")
enemy.DisplayName="[CLxA] Enemy"
check(not Pv:matchesClan(enemy),"Tag usa busca literal e nao padrao Lua")
enemy.DisplayName="[CL.A] Enemy"
click("pvp_blacklist_start"); Mock.Run(.5)
check(S.PvpFilter=="Blacklist" and C:pvpActive() and M.PvpTarget==enemy,"Blacklist ativa controlador e reconhece tag")
enemy.DisplayName="Enemy"; enemy:SetAttribute("ClanTag","[CL.A]")
check(Pv:matchesClan(enemy),"Blacklist reconhece atributo replicado do cla")
value("pvp_whitelist_id","+2"); Mock.Run(.5)
check(not M.PvpTarget,"Whitelist vence blacklist")
value("pvp_whitelist_id","-2"); value("pvp_tag","-[CL.A]"); Mock.Run(.5)
check(not M.PvpTarget and #Pv.Tags==0,"Remover tag interrompe ataque automatico")
click("pvp_lists")
check(U.Main:FindFirstChild("710Hub_Choice")~=nil,"Listas mostram relatorio de persistencia")
Pv:editTag("[QA]",false); X.Whitelist[77]=true; Pv:saveLists()
local stored=ENV.__710HubPvpLists[tostring(Mock.Player.UserId)]
X.Whitelist={}; Pv.Targets={}; Pv.Tags={}; Pv:loadLists(stored)
check(X.Whitelist[77] and Pv.Targets[2] and Pv.Tags[1]=="[qa]","Listas persistem por conta e sao restauradas")
check(not Pv:loadLists({Schema=99}) and X.Whitelist[77],"Arquivo invalido preserva listas atuais")
stop(); select("pvp_filter","Todos"); select("pvp_mode","Aura")
Pv.Center=nil; click("pvp_start")
check(not C:pvpActive(),"Aura exige area marcada")
value("pvp_aura_radius","20"); value("pvp_aura_radius","501")
click("pvp_aura_mark"); click("pvp_start")
enemyRoot.CFrame=CFrame.new(10,5,0); ownRoot.CFrame=CFrame.new(200,5,0)
before=#contacts; Mock.Run(.6)
check(#contacts>before and Pv.Center.X==0 and Pv.Marker and S.PvpAuraRadius==20,"Aura usa centro fixo marcado mesmo quando usuario se afasta")
enemyRoot.CFrame=CFrame.new(60,5,0); before=#contacts; Mock.Run(.5)
check(#contacts==before,"Aura exclui jogador fora da area mesmo com range universal")
M:pause("Manual",true); enemyRoot.CFrame=CFrame.new(10,5,0); Mock.Run(.5)
check(#contacts==before and not Pv.Marker,"Pausa central interrompe aura e remove marcador")
M:pause("Manual",false)
stop(); check(not Pv.Marker and not C:pvpActive(),"Parar tudo cancela PvP e remove area visual")
-- Multiple actual players, bounded batches and round-robin fairness.
local originalPlayers=methods.GetPlayers
local playerSet={Mock.Player,enemy}
for id=3,13 do
    local player=node("Player","Target"..id,services.Players)
    player.UserId=id; player.DisplayName=player.Name; player.Character=Mock.Character(player.Name,workspace)
    player.Character.HumanoidRootPart.CFrame=CFrame.new(id*10,5,0)
    playerSet[#playerSet+1]=player; Pv.Targets[id]=true
end
methods.GetPlayers=function() return playerSet end
select("pvp_mode","Distancia"); select("pvp_filter","Multiplos"); click("pvp_start")
before=#contacts; Mock.Run(.36)
check(#contacts-before<=16,"Lote PvP limita trabalho a oito alvos por tick")
Mock.Run(1.2)
local reached={}; for index=before+1,#contacts do reached[contacts[index].Root]=true end
check(reached[playerSet[#playerSet].Character.HumanoidRootPart],"Rotacao de lotes atende tambem os ultimos jogadores")
methods.GetPlayers=originalPlayers; stop()
-- Cancellation while equipping Punch must invalidate the pending contacts.
local punch=Mock.Player.Character:FindFirstChild("Punch") or Mock.Backpack:FindFirstChild("Punch")
punch.Parent=Mock.Backpack
S.PvpAny=true; S.PvpFilter="Todos"; S.PvpOnlySelected=false
before=#contacts
task.spawn(function() M:pvpTick() end)
task.delay(.01,function() P.Stop() end); Mock.Run(.1)
check(#contacts==before,"Parada durante equipar Punch cancela contatos pendentes")
-- Hunter uses only location data exposed by Roblox, and explicit join.
function methods:GetUserIdFromNameAsync(name) if name=="VisibleFriend" then return 99 end; error("Usuario desconhecido") end
function methods:GetFriendsOnlineAsync()
    if Mock.SlowHunter then task.wait(.5) end
    return {{VisitorId=99,PlaceId=46001,GameId="public-test-job"}}
end
value("hunter_query","@VisibleFriend"); click("hunter_find"); Mock.Run(.2)
check(Pv.Destination and Pv.Destination.UserId==99,"Hunter resolve usuario e localizacao visivel de amigo")
click("hunter_status"); click("hunter_join")
check(Mock.Rejoined.Place==46001 and Mock.Rejoined.Job=="public-test-job" and Mock.Rejoined.Player==Mock.Player,"Entrada usa servidor encontrado apenas para usuario local")
value("hunter_query","1234567"); click("hunter_find"); Mock.Run(.1)
check(not Pv.Destination and Pv.HunterStatus:find("indisponivel"),"Hunter nao promete localizacao de qualquer conta")
value("hunter_query","2"); click("hunter_find"); Mock.Run(.1)
check(Pv.HunterStatus:find("presente") and X.SelectedUserId==2,"Hunter reconhece jogador no servidor atual")
Mock.SlowHunter=true; value("hunter_query","99"); click("hunter_find"); Mock.Run(.1); P.Stop(); Mock.Run(.6)
check(not Pv.Destination,"Parada cancela resposta atrasada do Hunter")
Mock.SlowHunter=false
local savedTouch=firetouchinterest; firetouchinterest=nil
check(not C:startPvp(),"Modo de contato indisponivel nao inicia sem API do executor")
firetouchinterest=savedTouch
select("pvp_mode","Aproximar"); S.PvpUniversal=false; S.HealthGuard=true
enemy:SetAttribute("ClanTag",nil); enemy.DisplayName="Enemy"; X.Whitelist={}; Pv.Tags={}; Pv.Targets={}
ownRoot.CFrame=ownFrame; enemyRoot.CFrame=enemyFrame
firetouchinterest=originalTouch; stop()
-- Verify the newly reduced visual properties are reversible on the real toggle.
local decal=node("Decal","PerformanceTest",ownRoot); decal.Transparency=.4
ownRoot.CastShadow=true
if S.PerformanceMode then click("performance") end
click("performance"); Mock.Run(.1)
check(not ownRoot.CastShadow and decal.Transparency==1,"Reducao de carga oculta texturas e sombras locais")
click("performance"); Mock.Run(.1)
check(ownRoot.CastShadow and decal.Transparency==.4,"Desligar reducao restaura texturas e sombras anteriores")
decal:Destroy()
