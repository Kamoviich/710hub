# 710Hub — controlador de farm e rotas

**Atualização 2026.10-pvp.46:** [PvP com distância, bring, aura, listas persistentes, Player Hunter limitado e redução de carga](PVP-E-DESEMPENHO.md).

**Versão atual selecionada:** execute `710Hub.lua` (`2026.10-pvp.46`). Os novos controles estão em [PVP-E-DESEMPENHO.md](PVP-E-DESEMPENHO.md). Força e fast rebirth estão em [FAST-REP-E-REBIRTH.md](FAST-REP-E-REBIRTH.md); a seleção anterior está em [MENU-SELECIONADO.md](MENU-SELECIONADO.md). `710Hub.protegido.lua` acompanha a versão atual. As instruções abaixo descrevem a versão anterior preservada em `710Hub.original.lua`.

Execute o arquivo inteiro `710Hub.original.lua` em Muscle Legends. A versão exibida no console é `2026.10-personal.15`.

1. Em **FARM**, escolha a **Velocidade de farm** entre 1 e 20. O valor altera as solicitações de treino e o intervalo de tentativas de rebirth. Aplica imediatamente ao farm ligado, inclusive no modo estável. Quedas persistentes de FPS ainda reduzem a carga; o alvo efetivo aparece no painel.
2. Para perseguir a meta, use **Otimizar rota para 10M de rebirths**. O sistema equipa seus pets de força possuídos, compara as ferramentas de treino carregadas e até três máquinas elegíveis. Mede cinco segundos de força por rota e depois quinze segundos de ciclos de rebirth para cada uma das duas melhores. Usa os rebirths observados como critério principal e o ganho de força como desempate.
3. A rota escolhida passa ao farm contínuo. **Iniciar rumo a 10M de rebirths** permite começar diretamente usando a última rota medida ou o método disponível. O perfil retoma após respawn e para ao alcançar 10.000.000.
4. **Adaptar rotas às mudanças do jogo** atualiza o catálogo de recursos carregados e permite nova comparação quando ferramentas, máquinas ou canais conhecidos mudam. O farm também tenta outras rotas medidas se ficar sem progresso. Um rebirth bem-sucedido conta como progresso mesmo quando zera a força.
5. **Testar farm atual por 10 segundos** mede solicitações enviadas e ganho observado. A medição é cancelada se houver respawn, combate, parada, rebirth ou mudança de velocidade. O painel da meta estima o prazo usando os rebirths observados nos últimos sessenta segundos; precisa de pelo menos dez segundos e três rebirths para mostrar um ritmo.

O painel **Sua conta** lê a força, rebirths, pets possuídos e ritmo observado automaticamente. Mostra o requisito do próximo rebirth quando encontra um valor explícito no cliente; quando não encontra, informa que a validação pertence ao jogo. As rotas medidas ficam na memória do executor, separadas por conta e servidor, para reexecutar o hub na mesma sessão. Fechar o cliente elimina essa memória.

**END** e **Parar todas as automações** interrompem farm, combate e comparação de rotas. As opções anteriores, flexões, loja de pets, cristais, teleportes e gerenciamento de pets continuam no menu.

Overcharged tem prioridade para entrar na comparação, sem ser declarada vencedora pelo nome. A escolha depende do ganho efetivamente observado na conta entre as rotas testadas. A comparação cobre recursos carregados no cliente e protocolos conhecidos; uma mudança nos argumentos exigidos pelo jogo ainda pode precisar de uma atualização do código. Essa adaptação não confirma automaticamente bugs do jogo.

A [descrição oficial do jogo](https://games.roblox.com/v1/games?universeIds=1268927906) confirma benefícios Premium de força de treino em dobro e um slot extra de pet, além de giros e recompensas de baús. O painel identifica Premium quando presente e mede o resultado dos benefícios que já estiverem ativos na conta. A fonte oficial consultada não publica uma classificação de rendimento das máquinas Overcharged; o controlador usa medição da sessão para essa escolha.

## Verificação

Os testes executam o script completo, as coroutines, os botões e as chamadas de rede em um ambiente Roblox simulado. Validam ritmo, cancelamento, recuperação, rejeições e seleção de rotas. O resultado está em `tests/resultados.txt`.

Para repetir com Python e os executáveis oficiais do Luau CLI:

```powershell
python tests/run_checks.py --luau-dir "C:\caminho\para\luau"
```

O ambiente simulado usa ganhos e requisitos de treino definidos na fixture. Os resultados não comprovam ganhos, compras ou um ranking de máquinas no Roblox real. A frequência de solicitações não garante que todas sejam aprovadas pelo servidor; o teste de dez segundos e as medidas de rebirth no painel permitem conferir o resultado na conta.
