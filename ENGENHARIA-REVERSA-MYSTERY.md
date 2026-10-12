# Mystery / Silence no 710Hub — 2026.10-boss-hover.35

O arquivo principal `710Hub.lua` incorpora os três módulos consultados: Mystery Muscle Legends WindUI, Silence Main e Silence Farming. O catálogo tem **427 elementos de interface**, dos quais **249 são interativos**. Esses números incluem seletores, campos e controles repetidos entre os módulos; não significam 427 poderes ou ganhos diferentes.

## O que foi recuperado

Foi identificada a permutação das funções de suporte do Mystery e foram isolados seus decodificadores Base85, XOR e descompressão. O conteúdo decodificado tem 163.070 bytes. A leitura do formato da máquina virtual recuperou 1.803 textos/identificadores únicos e 317 protótipos principais. O ponto de entrada foi interceptado para extrair a estrutura sem executar instruções de jogo. Depois, a inicialização foi auditada em um simulador local, com HTTP substituído por respostas registradas e tarefas de fundo sem execução.

Essa auditoria identificou 166 elementos no Mystery, 182 no Silence Main e 79 no Silence Farming. A integração preserva os callbacks de origem em ambientes separados e substitui WindUI/Elerium pelos controles do 710Hub. As bibliotecas de interface e os sistemas de chave dos outros hubs não são carregados.

As fontes incorporadas são cópias locais fixadas por SHA-256, registradas em `references/source-manifest.json`. Portanto, atualizar um dos repositórios externos não altera silenciosamente as rotinas incorporadas.

## Propósitos e uso

Os controles aparecem nas categorias do 710Hub com os prefixos **Mystery**, **Silence Main** e **Silence Farming**. A descrição inclui o contexto e a origem. Use a pesquisa global para localizar nomes como `Noclip`, `Walk On Water`, `Auto Win Brawl`, `Auto Tool + Rock`, `Fast Rebirths`, `Trade`, `Send Eggs`, `Buy Aura` e `Server Hop`.

As opções de treino, rocks, combos, máquinas, bosses, Halloween, rebirth, Brawl, pets, auras, evolução, trocas, presentes, consumíveis, combate, karma, listas de proteção/alvos, câmera, movimento, otimização, estatísticas e teleportes ficam vinculadas aos callbacks dos respectivos módulos. Os seletores usam a lista que o módulo encontra na sessão atual. Campos e seleções do módulo permanecem durante essa sessão; os perfis do núcleo continuam separados.

Cada módulo é inicializado quando você usa seu primeiro controle. O executor precisa oferecer `loadstring`, `setfenv` e as APIs utilizadas pela função escolhida. Objetos ausentes no jogo ou métodos ausentes no executor são relatados em **Diagnóstico Mystery / Silence**. A inicialização do módulo não inicia compras, treino ou rebirth automaticamente.

O controlador central aplica pausa, limite de chamadas e encerramento às rotinas incorporadas. “Parar tudo” cancela tarefas dos controles e restaura alterações de propriedades rastreadas. Treinos e combates importados interrompem os concorrentes do núcleo e o contrário também ocorre. Compras, evolução, trocas e presentes já enviados ao servidor não podem ser desfeitos pelo cancelamento.

O botão **Anti Rebirth** foi adaptado para bloquear pedidos de rebirth feitos pelas rotinas integradas. O bloqueio é reversível em **Bloquear rebirth nas rotinas integradas**; não instala um hook permanente e não bloqueia scripts independentes.

**No Comer Eggs** bloqueia o protocolo de consumo de Protein Eggs das rotinas integradas, com desligamento reversível, sem baixar o auxiliar `Crack`. **Permanent Shiftlock** usa MouseBehavior, CameraOffset e orientação do personagem; clique novamente para restaurar. Essa adaptação dispensa o loader externo do botão original e também oferece o deslocamento de câmera no celular.

Os campos **Fake Stats** mudam somente os textos locais da interface do jogo. Não concedem atributos, moeda, kills ou rebirths. As operações de compra, troca e presente usam os itens/moedas possuídos e os protocolos de origem; o servidor decide a aceitação.

**Infinite Yield** e **All Emotes** são atalhos externos, conforme o propósito dos botões do Mystery. Eles baixam as fontes correspondentes quando você clica e abrem interfaces próprias. O cancelamento central impede executar um download pendente; depois de abertos, os controles dessas ferramentas pertencem às próprias interfaces, incluindo seu encerramento. Não fazem parte das rotinas isoladas de Muscle Legends.

As configurações em arquivo dos módulos usam a pasta `710hub_sources`, com nomes separados por módulo, quando o executor oferece leitura e gravação.

## Auto Kill Boss acima do alvo

O **Auto Kill Boss / farm de boss** do núcleo agora começa com **Atacar acima do boss de cabeça para baixo** ligado. A posição usa o topo da cabeça do boss, com afastamento inicial de 2 studs e inversão de 180 graus em X. O acompanhamento ocorre a cada frame e continua ativando Punch. AutoRotate e a orientação normal são restaurados ao pausar, recuar, parar, morrer ou encerrar.

O controle **Altura / distância do boss** alterna 2, 3, 5 e 7 studs. No modo superior ele ajusta a altura; sem esse modo, ajusta a distância da rota no chão. A proteção de vida baixa continua podendo suspender o ataque e recuar. Essa posição não garante imunidade; a aceitação do soco e o dano continuam sendo definidos pelo jogo. Se não houver queda de vida observada, o painel sugere reduzir a altura.

## Testes e limites da verificação

Foram verificados o catálogo completo, a vinculação dos 249 callbacks interativos, a execução de desligamento dos 115 toggles e os comportamentos de roleta, tamanho, gravidade, bloqueio de rebirth, concorrência de treino, pausa, retomada, cancelamento e atalhos externos. Os testes executam o arquivo principal inteiro em um ambiente Roblox simulado. **Não comprovam funcionamento de cada recurso no servidor real, ganho de atributos, kills, vitórias ou compras.** Isso exige testes dentro do Roblox com o executor e a conta que serão usados.

```powershell
py -3 tests/check_sources.py
py -3 tests/check_enhancements.py
py -3 tests/check_published.py
py -3 tests/check_design.py
py -3 tests/check_boss_hover.py
```

Os resultados ficam em `tests/source-results.txt` e nos relatórios das outras suítes. Para reconstruir após editar a camada de compatibilidade:

```powershell
py -3 build_sources.py
py -3 tests/check_sources.py
py -3 proteger_scripts.py 710Hub.lua
```

Para repetir a recuperação, os scripts estão em `references/reverse_mystery.py`, `references/index_mystery.py` e `references/audit_mystery.py`. Eles usam o Luau CLI em `%TEMP%/710hub-luau-check` e os arquivos de referência presentes nesta pasta.

## Loadstring

O comando para a versão do ramo `main` do seu repositório é:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/main/710Hub.lua", true))()
```

Esse comando sempre baixa o arquivo publicado naquele ramo. A alteração local só passa a ser carregada depois que o arquivo correspondente é atualizado no GitHub. O script não assume que a publicação foi realizada.

A versão de teste desta integração foi publicada no ramo `codex/mystery-silence-710hub`, com [PR em rascunho](https://github.com/Kamoviich/710hub/pull/1):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/refs/heads/codex/mystery-silence-710hub/710Hub.lua", true))()
```
