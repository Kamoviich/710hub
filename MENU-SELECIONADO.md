# 710Hub — seleção limpa

**Atualização 2026.10-ultra.42:** Ultra em lotes inspirado no Silence anexado, adaptação por ping, preparação local reversível e pets preservados. O menu mantém 69 elementos e passou em 561 verificações locais. Consulte [FAST-REP-E-REBIRTH.md](FAST-REP-E-REBIRTH.md) para uso e resultados. A descrição abaixo registra a revisão anterior 2026.10-clean.36.

O menu tem **65 elementos**: 26 toggles, 14 campos e 25 cards de ação, seleção ou estado. Há um único controle para cada propósito; as opções de um seletor não são cópias da mesma rotina.

## Seleção mantida

| Grupo | O que ficou e por quê |
| --- | --- |
| Treino | Um seletor com automático, peso, flexões, abdominais, parada de mãos, máquina, pedras e esteira. Um botão inicia/para o método. O modo automático usa máquinas elegíveis ou ferramenta, e os modos específicos permitem escolher o exercício. |
| Rebirth e recompensas | Uma rotina de rebirth com intervalo e meta, coleta de baús e roleta com intervalo. Usa os protocolos existentes, sem multiplicadores inventados. |
| Consumíveis | Uma rotina para Protein Eggs e outra para shakes/barras possuídos. Cada item tem intervalo de uso. |
| Boss | Um Auto Kill Boss, com prioridade de raridade, pose invertida acima da cabeça, altura, recuo, recuperação de vida, drops e retorno. |
| PvP | Um controlador com seletor de filtro: todos, karma bom, karma ruim ou conta selecionada. Mantém proteção por UserId, amizade e spawn, observação e estatísticas replicadas. |
| Pets | Um gerenciador por atributos legíveis: força, durabilidade ou agilidade. Evolução preserva pets equipados, bloqueados e favoritos. |
| Cristais e loja | Uma abertura com limite e pet alvo opcional; para em recusa ou falta de progresso. Uma compra manual por lote, com catálogo atual de pets/auras e cancelamento. |
| Metas e perfis | Uma meta de parada, um temporizador e três perfis. Carregar um perfil começa em pausa e atualiza os campos visíveis. |
| Sessão e ajustes | Um relatório de estado, histórico e verificação de dependências; uma lista de teleportes; salvar posição; estabilidade e gráficos reversíveis; velocidade/tamanho, FOV, shiftlock, salto, proteção de arremesso, reentrada e encerramento. |

Os recursos escolhidos do Silence e Mystery foram adaptados às rotinas nativas do 710Hub. Exemplos: roleta, consumíveis, seleção de pets por atributo, proteção de amigos, seleção de jogadores, shiftlock e referências de navegação. A decisão foi baseada em protocolo identificável, finalidade clara, controle de cancelamento e resultado observável; não em promessas de ganho do hub de origem.

## Duplicações removidas

- A importação completa de Mystery, Silence Main e Silence Farming, que acrescentava 427 elementos e exigia interpretar módulos externos.
- Os menus paralelos com prefixo do hub de origem, seus ambientes, bibliotecas UI e carregamento de código.
- Vários botões separados para treinos equivalentes, ciclos/presets repetidos de força e rebirth, gerenciadores concorrentes de pets e atualizações redundantes de máquinas.
- A abertura específica de Nova Phoenix: use o nome do pet no alvo opcional da abertura única.
- Seletores diferentes para destinos carregados, academias e posição salva. Pontos com o mesmo nome são consolidados; o carregado no jogo tem prioridade.
- Atalhos de hubs independentes, fake stats, trocas/presentes automáticos, presets de nomes de pets, dano sem atributo legível, spam e rotinas antigas fora da seleção.

O arquivo de execução passou de **1.001.537 para 213.445 bytes** nesta revisão, uma redução de aproximadamente **78,7%**. As referências anteriores permanecem para consulta; não são carregadas pelo script. `build_sources.py` bloqueia a reintrodução acidental da importação ampla.

## Verificação

```powershell
py -3 build_clean.py
py -3 tests/check_clean.py
py -3 tests/check_published.py
py -3 tests/check_boss_hover.py
py -3 tests/check_design.py
```

As suítes da revisão somam **363 verificações locais**: 301 do menu selecionado, 22 do fluxo de bosses, 20 do ataque superior e 20 da interface. Cada um dos 65 elementos está identificado em `tests/clean-catalog.json` e foi exercitado pelos testes da revisão.

Os testes acionam botões, campos e seletores reais do menu, executam as coroutines do arquivo completo e verificam chamadas, mudanças na fixture do jogo, restauração e cancelamento. Incluem os oito métodos de treino, filtros de PvP, proteção de spawn, conjuntos de pets por atributo, evolução de grupos válidos, limite/recusa/ausência de confirmação de cristais, compras canceladas, perfis antigos, metas, temporizador, câmera, movimento e telas com/sem toque.

**A garantia verificável aqui é sobre o código e seu comportamento no simulador.** A aceitação de pedidos, dano, vitórias, moeda, itens e ganhos no Roblox real depende do servidor, da conta e do executor. Não houve conexão a um cliente Roblox real durante esses testes. O menu não promete imunidade nem ganhos garantidos.

Resultados atuais: `tests/clean-results.txt`, `tests/published-results.txt`, `tests/boss-hover-results.txt` e `tests/design-results.txt`. Os relatórios antigos de importação/integração ampla descrevem a versão arquivada, não esta seleção.

## Manutenção

Edite `CleanUI.fragment.lua` para os controles, `CleanRuntime.fragment.lua` para o controlador, `EnhancementsRuntime.fragment.lua` para os recursos escolhidos e `BossHover.fragment.lua` para a pose de ataque. `build_clean.py` sincroniza os fragmentos com `710Hub.lua` sem recuperar os menus descartados.

```powershell
py -3 build_clean.py
py -3 tests/check_clean.py
py -3 proteger_scripts.py 710Hub.lua
```

O loadstring de teste será fixado no commit publicado desta revisão; o ramo principal é atualizado após a revisão do PR.
