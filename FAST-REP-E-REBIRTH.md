# 710Hub 2026.10-combined.43 — força e fast rebirth

O modo **Fast Rep (packs)** envia reps sem acumular rajadas durante pausas. O seletor **Envio de reps** oferece cinco perfis, com teto local configurável de 40–10.000 pedidos/s:

- **Combinado:** ativa as duas rotas juntas: clássico pelo Heartbeat, até 659 pedidos/s, e Ultra em lotes pelo trabalhador. Divide o teto total entre elas; os lotes usam o restante depois da reserva clássica. Não duplica medição de ganhos ou tempo ativo. Ambas compartilham orçamento de quatro milissegundos por frame e param juntas em pausa, erro, cancelamento e prioridade de rebirth. O relatório separa os contadores clássico/lotes. Esse perfil responde ao relato do usuário de ligar os dois treinos do Silence simultaneamente; não prova qual foi o ganho aceito no servidor.

- **Ultra (lotes):** adapta o treino `Strength (Slower)` do Silence anexado: até 350 reps/lote, tamanho reduzido com ping alto e intervalo mínimo baseado no ping e no teto escolhido. Usa um único trabalhador; o Heartbeat não envia reps simultaneamente. A preparação local suspende apenas o `LocalScript` chamado `bodyMovementScript` do próprio personagem, preservando sua referência e estado. Restaura ao parar, pausar, morrer, trocar de perfil ou encerrar. O Silence original destrói esse script; nossa adaptação mantém a mudança reversível. Essa diferença é verificável no código, mas não prova que era a causa do ganho em trilhões relatado pelo usuário.

- **Explorar limite** (padrão): testa 250, 400, 500, 659, 1.000, 1.500, 2.500, 3.295, 5.000, 7.500 e 10.000, respeitando o teto configurado. Cada etapa espera dois segundos ativos e mede pelo menos dez segundos de ganhos. Sobe enquanto o ganho melhora; após duas etapas sem melhora superior a 5%, volta à melhor taxa medida nesta rodada.
- **Intensivo**: começa diretamente no limite escolhido. Reduz o envio se o progresso parar.
- **Adaptativo**: mantém o comportamento anterior, começando em 200 e subindo até 659 conforme os ganhos.

A exploração compara força quando o rebirth está desligado e rebirths quando está ligado. Nesse segundo caso, aguarda um rebirth observado para comparar a etapa, sem substituir essa medida por pedidos enviados. Alterar o teto ou ligar/desligar o rebirth reinicia a comparação. O painel mostra cada alvo, pedidos enviados e ganho observado; os resultados podem mudar com boosts, FPS e servidor.

Intensivo/exploração têm até 256 pedidos por frame, com orçamento local de quatro milissegundos para o loop de envio. Em modo estável, continuam limitados a 200 pedidos/s e oito por frame. Quando o rebirth está ligado, o teto de treino é 450 pedidos/s para reduzir concorrência com a confirmação. O teto de 160 chamadas/s das outras operações continua separado.

**10.000 é um teto experimental do cliente, não uma taxa aceita pelo servidor.** A [documentação oficial do Roblox](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) descreve throttling aproximado de 500 eventos/s por cliente, compartilhado pelos eventos do mesmo tipo. Taxas solicitadas maiores podem aumentar a fila e a latência sem aumentar o ganho. O explorador usa ganhos observados para evitar continuar subindo quando não há benefício. Ele não altera o limite do servidor nem garante posição no ranking global.

**Seus pets equipados são preservados durante força e fast rebirth.** O controlador apenas lê os pets atuais, os slots e os bônus conhecidos/replicados. Não troca pets para velocidade, força ou rebirth. O autoequip por atributo e a evolução automática aguardam enquanto o Fast Rep estiver ativo. As ferramentas anteriores de pets continuam disponíveis quando o treino rápido estiver desligado, caso você as ative explicitamente.

## Como usar

1. Equipe no jogo o conjunto de pets que deseja manter.
2. Em Treino, selecione **Fast Rep (packs)** e clique em **Iniciar / parar treino**.
3. Para renascer junto ao treino, ative **Fast rebirth / rebirth automático**. Deixe desligado para acumular força.
4. Em **Envio de reps**, use **Explorar limite** para medir a melhor taxa, ou **Intensivo** para começar no limite escolhido.
5. Abra **Rendimento do Fast Rep**: o relatório atualiza a cada segundo com ganho de força/durabilidade/rebirth, ritmo recente, média ativa e resultados das etapas. Aguarde pelo menos dez segundos antes de comparar ganhos.

### Configuração rápida

O seletor **Configuração rápida** aplica os campos e inicia o método Fast Rep, respeitando modo estável, pausas e metas já configuradas:

- **Ultra combinado:** perfil Combinado, teto total de 10.000 pedidos/s e rebirth desligado. Executa clássico e lotes juntos, preservando os pets e usando a preparação local reversível. O teto é para a soma das rotas; não são 10.000 para cada uma. Modo estável ou teto baixo podem reservar todo o orçamento ao clássico, deixando lotes sem orçamento adicional.

- **Ultra rápido:** perfil Ultra (lotes), teto local de 10.000 pedidos/s e rebirth desligado. Adapta a preparação local reversível e os lotes ao ping, mantendo todos os pets equipados. Se o serviço de ping não estiver disponível, usa referência de 80ms, sem assumir que esse é o ping real.

- **Força acumulada:** perfil Intensivo, alvo de 659 pedidos/s (o alvo do trecho de força do Silence anexado), rebirth desligado. Preserva a força acumulada e os pets; não compra ou consome boosts automaticamente.
- **Rebirth rápido:** perfil Intensivo, teto de 450 pedidos/s, rebirth ligado e intervalo de 0,5 segundo. Ao ter força suficiente, suspende reps excedentes e prioriza a solicitação/confirmacão. Se a meta absoluta de rebirth já foi atingida, avisa e mantém rebirth desligado até você aumentar ou remover essa meta.

O painel também estima o tempo até 1T e 1Qa usando ganho recente de força. A estimativa depende de esse ritmo se manter; não usa pedidos enviados como ganho. Com rebirth ligado, informa que ele consome a força. O código não garante trilhões ou Qa em segundos: esse resultado depende dos multiplicadores, pets equipados, boosts e regras do servidor.

O ciclo de fast rebirth solicita assim que há força suficiente e o intervalo configurado permite, sem a antiga espera fixa de três segundos. Dá preferência a um requisito replicado; se ele não existir, usa a fórmula conservadora encontrada no Silence (`5000 + rebirths * 2550`). Solicita pelo canal `rebirthRequest` e confirma a mudança na estatística. Enquanto a força basta ou a solicitação ainda não foi confirmada, suspende reps excedentes para não continuar enchendo a fila. Se o rebirth já foi observado e a força precisa ser reconstruída, o treino pode retomar mesmo antes do retorno da chamada. Respeita a meta absoluta de rebirths; atingir essa meta para os rebirths e mantém o treino de força. Recusas usam espera adaptativa de 0,5, 1 e até 2 segundos, respeitando intervalos maiores que você configurar. O padrão é 0,5 segundo; a contagem parte do pedido, evitando uma segunda espera inteira depois da resposta. Uma única solicitação fica pendente por vez.

O painel informa se aguarda força, resposta do servidor, replicação da estatística ou o intervalo, incluindo a duração da solicitação pendente. A chamada roda em uma coroutine própria, deixando o controlador livre para processar pausa, metas e diagnósticos. Um pedido recusado não é contado como rebirth. A redução dessas esperas corrige atrasos do cliente; não remove requisitos, filas ou cooldowns impostos pelo servidor. Uma chamada pendente não é reenviada automaticamente só porque demorou.

Morte, pausa, boss e Parar Todas interrompem o envio. Uma resposta tardia de rebirth não retoma a automação cancelada. Dez segundos sem ganho encerram Fast Rep/rebirth e mostram a causa. Em modo estável, o teto é 200 pedidos/s e oito por frame; aparelhos com FPS baixo também ficam limitados pela quantidade por frame.

### Correções da revisão .39

- Pedidos recusados de rebirth não reiniciam mais a janela de progresso. Isso evita manter o treino ativo indefinidamente quando nenhum ganho chega.
- Ao entrar no Fast Rep, autoequip e evolução que já estavam em andamento interrompem suas próximas alterações. A proteção também cobre trabalhos iniciados antes da ativação do modo.
- Requisitos de rebirth inválidos (NaN, infinito, negativos ou uma pasta no lugar de valor numérico) são ignorados. Um requisito alternativo válido tem prioridade sobre a fórmula de referência.
- O painel mostra o motivo da pausa, inclusive durante uma confirmação pendente, e calcula o ritmo recente pelo tempo transcorrido. A média ativa continua separada.
- O histórico recente guarda até aproximadamente 45 pontos, com quatro registros por segundo. Os ganhos continuam medidos por frame; essa redução diminui alocações e deslocamentos de tabelas no celular.

## Origem da seleção

A análise do [Silence Farming](https://raw.githubusercontent.com/silencedevs/SilenceScripts/refs/heads/main/Scripts/MuscleLegends/Farming.luau) identificou envio por frame, ritmo adaptativo, referência de 659 reps/s, cálculo do requisito de rebirth e bônus de pets. O catálogo recuperado do [Mystery](https://github.com/Mystery-Center/Mystery-Loader) confirma as opções de Fast Rep, Fast Rebirth, monitoramento de ganhos e os pets usados nesses propósitos. O 710Hub implementa um controlador nativo e usa o mesmo seletor/botão de treino e a mesma opção de rebirth, evitando menus e rotinas duplicados. A troca automática de pets foi retirada conforme seu pedido.

Gamepasses e boosts pertencem à conta e são aplicados pelo jogo. O hub não inventa multiplicadores, não compra packs e não ativa passes ausentes. Valores de bônus conhecidos servem para diagnóstico; os ganhos mostrados vêm das estatísticas da conta.

## Verificação

Foram executadas **589 verificações offline**: 324 do menu, 74 de força/fast rebirth, 23 de cenários prolongados/concorrentes, 41 de taxas/exploração, 38 do Ultra, 27 do Combinado, 22 do fluxo de bosses, 20 da pose acima do boss e 20 da interface. O menu mantém 69 elementos, com títulos/IDs únicos; Ultra e Combinado reutilizam seletores existentes. A suite de Fast Rep executa o script completo com doze pets equipados e verifica suas referências exatas após sucesso, recusa, timeout, pausa, boss, respawn e queda de FPS; registra zero chamadas de equip/unequip nesse fluxo. Os casos prolongados verificam um minuto de ciclos, prioridade intencional durante recusas quando a força já basta, requisitos inválidos, pausa longa, confirmação pendente e cancelamento de alterações de pets ao entrar no Fast Rep. Nesses últimos casos, a fixture inicia explicitamente uma tarefa de pets antes do treino e verifica que nenhuma alteração restante acontece após ativar o modo.

Os 27 casos Combinado verificam soma dos contadores, tempo ativo contado uma única vez, teto agregado, orçamento de CPU compartilhado, interrupção de ambas as rotas e preservação exata dos pets. Em ping simulado de 300ms, foram medidos 659 pedidos/s clássicos + 500 em lotes = 1.159/s locais. Uma fixture com aceitação limitada demonstra que mais pedidos não são convertidos automaticamente em mais ganhos. Não foi medido o servidor real do usuário.

Os casos Ultra verificam adaptação a ping de 40/100/200/300ms, fallback sem serviço de ping, ausência de trabalhador duplicado, limites manuais/estáveis, respawn, substituição do script local, transporte com falha, parada sem ganho, rebirth pendente e restauração do estado original do movimento. O loop local simulado mediu aproximadamente 10.033,3/s, 7.500,0/s, 1.233,3/s e 500,0/s nesses quatro pings; essas medidas descrevem pedidos locais em lotes, não taxa aceita no Roblox. A fixture não reproduz o custo real de rede, o throttling nem a quantização de `task.wait` no cliente. O ganho de força por pedido é definido pela fixture, e esses testes não comprovam trilhões em segundos na conta real.

Uma fixture reproduz 41,1B de força e requisito de 485,4M: a solicitação pendente não recebe novas reps concorrentes e uma fila simulada termina de processar. Outro caso mantém uma resposta atrasada por seis segundos, verifica fase/duração no painel e a ausência de duplicatas. Os presets e a estimativa por ganhos também são exercitados. Isso valida os controles locais; não mede a fila real do usuário nem prova qual foi a causa da demora mostrada nas imagens.

O benchmark local mediu aproximadamente 500,0, 658,7, 1.500,0, 3.294,7, 4.999,7 e 9.999,7 pedidos/s para os respectivos alvos 500, 659, 1.500, 3.295, 5.000 e 10.000. Essa fixture não impõe o throttling do Roblox: são medidas do loop local simulado. Uma fixture separada limita os pedidos aceitos a 500/s e o explorador seleciona 500 após testar etapas superiores sem melhora. Outra fixture sem limite permite alcançar as onze etapas até 10.000. Também foram testados pausa da exploração, mudança do objetivo, teto manual, orçamento de quatro milissegundos por frame e FPS baixo. Os resultados completos estão em `tests/fast-rep-rate-results.txt`.

Os testes também verificam pedido em menos de 300ms quando a força já basta, suspensão de reps durante confirmação sem estatística observada, retomada após rebirth observado, ausência de pedidos concorrentes, recuperação após duas recusas temporárias e espera limitada após recusas persistentes. Esses tempos são resultados da fixture, não medições no Roblox.

```powershell
py -3 build_clean.py
py -3 tests/check_clean.py
py -3 tests/check_fast_rep.py
py -3 tests/check_fast_rep.py --stress
py -3 tests/check_fast_rep.py --rates
py -3 tests/check_fast_rep.py --ultra
py -3 tests/check_fast_rep.py --combined
py -3 tests/check_published.py
py -3 tests/check_boss_hover.py
py -3 tests/check_design.py
```

As fixtures definem seus próprios ganhos e requisitos. Os testes não comprovam rendimento no servidor Roblox real. Pedidos enviados não são reps aceitas e taxas maiores não garantem ganhos iguais aos screenshots. Compare o ganho observado por minuto na mesma conta, conjunto de pets, boosts e servidor.

## Versão de teste fixada

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/196c89e643f8cb7b60523f0003e11617a92b3ab7/710Hub.lua", true))()
```
