# 710Hub 2026.10-rebirth.45 — força contínua e rebirth sem espera local

O Fast Rep continua treinando força enquanto o auto rebirth aguarda resposta ou confirmação. O campo **Espera local do rebirth (0 = sem cooldown)** aceita de 0 a 30 segundos. O padrão de uma nova sessão e do preset **Rebirth rápido** é zero. Perfis antigos mantêm o intervalo salvo; selecione zero ou reaplique o preset para removê-lo.

## Usar força e rebirth juntos

1. Mantenha os pets que deseja usar equipados.
2. Em **Configuração rápida**, selecione **Rebirth rápido**. Isso inicia Fast Rep Intensivo, liga rebirth e define espera local zero.
3. Alternativamente, inicie o modo **Fast Rep (packs)**, ligue **Fast rebirth / rebirth automático** e defina a espera local como zero.
4. Abra **Rendimento do Fast Rep** para acompanhar força/durabilidade, rebirths observados e fase/duração da solicitação pendente.

Não há pausa do treino ao atingir a força necessária, durante a resposta ou enquanto aguarda a estatística. O limite do treino com rebirth ligado permanece em 450 pedidos locais/s (200 em modo estável). O controlador reduz o ritmo se não observar ganho, mas mantém os envios durante a espera de rebirth. Pausa manual, morte, combate com boss, falha de transporte e Parar Todas continuam funcionando.

Uma única solicitação de rebirth fica pendente por vez. Zero remove a espera entre sucessos imposta pelo cliente; não remove requisitos, filas, tempo de resposta ou cooldown validado pelo servidor. Pedidos recusados ou sem confirmação mantêm recuo de 0,5, 1 e até 2 segundos, respeitando um intervalo manual maior. O modo comum de rebirth também aguarda força e confirmação e limita novas tentativas após recusas.

O requisito replicado numérico tem prioridade. Na ausência dele, usa-se a referência conservadora encontrada no Silence (`5000 + rebirths * 2550`), que não comprova a regra atual do servidor. A meta absoluta de rebirth encerra apenas o rebirth; o Fast Rep continua treinando. Uma resposta tardia não retoma uma sessão cancelada.

**Nenhuma dessas rotinas equipa ou desequipa pets.** Autoequip por atributo e evolução automática aguardam enquanto Fast Rep estiver ativo. O código apenas lê os pets já equipados para diagnóstico. Boosts e compras não são ativados pelos presets.

## Perfis de envio

O teto configurável de 40–10.000 é de pedidos locais, não de reps aceitas pelo servidor.

| Perfil | Comportamento |
| --- | --- |
| Combinado | Clássico por Heartbeat até 659/s, com lotes usando o restante do teto agregado |
| Ultra (lotes) | Trabalhador único, até 350 por lote; tamanho/intervalo consideram o ping medido |
| Explorar limite | Testa taxas por etapas e compara ganhos observados; duas etapas sem melhora retomam a melhor taxa |
| Intensivo | Começa no teto escolhido e reduz o ritmo sem progresso |
| Adaptativo | Começa em 200 e sobe até 659 conforme progresso |

Combinado e Ultra preparam o personagem suspendendo somente `bodyMovementScript` local, de forma reversível. O estado original é restaurado ao parar, pausar, morrer, trocar para outro perfil ou encerrar. O ping é apenas medido. As rotinas compartilham orçamento de quatro milissegundos por frame; não acumulam compensação ilimitada após travadas.

**Ultra combinado** seleciona Combinado com teto total 10.000 e rebirth desligado; **Ultra rápido** seleciona lotes com esse teto; **Força acumulada** seleciona Intensivo 659/s sem rebirth. **Rebirth rápido** usa Intensivo 450/s, rebirth ligado e espera local zero. Todos respeitam pausas, modo estável e metas existentes.

A [definição oficial de RemoteEvent](https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/RemoteEvent.yaml) descreve throttling aproximado de 500 eventos/s por cliente, compartilhado entre eventos do mesmo tipo, e possíveis problemas de latência. Aumentar pedidos não garante mais ganho. A [retomada de task.wait por Heartbeat](https://create.roblox.com/docs/scripting/scheduler) pode alongar intervalos. Os créditos já limitam a taxa, por isso não há uma segunda espera para preencher lotes.

## Métricas e limites

Os ganhos vêm dos valores observados da conta. Pedidos enviados não equivalem a reps aceitas. As médias incluem o tempo das travadas, enquanto o crédito de envio limita a compensação a 0,1s. O histórico recente guarda aproximadamente 45 pontos, amostrados quatro vezes por segundo, e o painel atualiza a cada segundo.

A estimativa até 1T/1Qa usa o ganho recente de força, condicionado a esse ritmo continuar. Rebirth consome força. Não há garantia demonstrada de quadrilhões em segundos, multiplicadores inventados nem uma brecha comprovada de ganho durante travadas. O [medidor passivo](FARM-PROBE.md) permite comparar sessões de 710Hub e Silence sem alterar o farm.

## Validação local

**638 verificações offline**: 324 do menu, 74 de força/fast rebirth, 23 prolongadas/concorrentes, 41 de taxas/exploração, 38 do Ultra, 27 do Combinado, 20 de agendamento/travadas, 29 de intervalo zero/treino contínuo, 22 de bosses, 20 da pose superior e 20 da interface. O menu mantém 69 controles.

Os novos casos verificam o campo zero, compatibilidade de perfis, alteração do intervalo durante espera, confirmação atrasada, treino por onze segundos sem ganho durante resposta pendente de 13s, pausa manual, recusas limitadas, meta e preservação exata dos pets. Uma fixture de 2,2s confirmou 5 rebirths com intervalo local 0,5 e 26 com zero. Esses resultados são do modelo sintético, não uma medição ou promessa da frequência real no Roblox.

As fixtures de fila permitem processamento suficiente para concluir uma solicitação enquanto novas reps chegam. Elas verificam fluxo contínuo e exclusão de pedidos concorrentes; não reproduzem a fila real do jogo. As suites preservam as referências dos pets e registram zero equip/unequip no Fast Rep. Os casos de menu cobrem os 69 controles, sem duplicatas.

```powershell
py -3 build_clean.py
py -3 tests/check_clean.py
py -3 tests/check_fast_rep.py
py -3 tests/check_fast_rep.py --stress
py -3 tests/check_fast_rep.py --rates
py -3 tests/check_fast_rep.py --ultra
py -3 tests/check_fast_rep.py --combined
py -3 tests/check_fast_rep.py --timing
py -3 tests/check_fast_rep.py --rebirth
py -3 tests/check_published.py
py -3 tests/check_boss_hover.py
py -3 tests/check_design.py
```

Origem da adaptação: [Silence Farming](https://raw.githubusercontent.com/silencedevs/SilenceScripts/main/Scripts/MuscleLegends/Farming.luau) e catálogo recuperado do [Mystery](https://github.com/Mystery-Center/Mystery-Loader). O 710Hub mantém controladores nativos; a troca automática de pets não integra o farm.

## Versão de teste fixada

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/b229a5b5c25c23269880b4628e7d2a595526e5ac/710Hub.lua", true))()
```
