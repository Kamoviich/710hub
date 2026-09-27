# 710Hub — Muscle Legends

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/main/710Hub.lua", true))()
```

Abra Muscle Legends, execute o comando e informe sua key para liberar o painel. RightShift abre/fecha o menu; End para as automacoes.

## Acesso por key

Painel do proprietario: https://710hub-keys.710hub-key-server.workers.dev

A credencial administrativa esta apenas no computador do proprietario, em `710hub/key-server/private/admin-token.txt`. Use-a no painel para gerar keys, definir validade e revogar acessos. Entregue aos jogadores somente as keys geradas, nunca a credencial administrativa.

O arquivo publico `710Hub.lua` agora e um carregador: valida a key e baixa o menu pelo servidor autenticado. Requer suporte a `request` ou `http_request` com cabecalhos. Revogacao encerra a sessao na proxima verificacao, em ate aproximadamente 60 segundos; uma falha de rede tambem bloqueia a sessao. Uma key permite uma sessao atual de ate 8 horas.

As versoes antigas ja publicadas continuam no historico e nao sao bloqueadas retroativamente. As keys controlam o carregamento atual, sem impedir copias feitas pelo cliente.

**Manutencao:** a copia local completa do menu permanece em `710hub/710Hub.lua`; atualize o Worker usando `key-server/prepare.mjs` e Wrangler. Nao sobrescreva o carregador publico com essa copia completa. O modelo publico fica em `key-server/KeyLoader.template.lua` localmente.

## Versao 2026.09-neon.19

Atualizacao exclusivamente visual: icones de linha nas categorias e secoes (halteres, coroa, pet, meta, perfil, grafico e ajustes), haltere decorativo no cabecalho, indicador da aba ativa, bordas mais finas, gradientes discretos e maior espaco entre cartoes. Desenhos nativos da interface, sem downloads adicionais. Preserva os botoes, recursos e tema preto/amarelo. O enfeite do cabecalho e ocultado em telas estreitas para preservar a leitura.


### Bosses: deteccao e chances

- Reconhece marcadores Boss/Chefe, tags, atributos, DisplayName e rigs aninhados. Tambem le vida numerica Health/HP e partes principais ou corpos simples. Exclui jogadores, seus descendentes e modelos que envolvam personagens de jogadores.
- **Monitorar todos os bosses** remove a preferencia por nome. **Diagnosticar boss proximo** mostra NPCs reconheciveis ate 150 studs. Um nome exato no campo Boss preferido autoriza aquele NPC como alvo; confirme pelo diagnostico antes de usar.
- **Chances e historico dos bosses** mostra as taxas do print fornecido pelo proprietario: Comum 50%, Raro 30%, Epico 15%, Lendario 4%, Mitico 1%; Arco-iris somente administradores. Essas taxas nao foram inferidas do historico e podem mudar com atualizacoes do jogo.
- Monitora aparicoes a cada 5 segundos e avisa ao detectar Lendario, Mitico ou Arco-iris, mesmo com Auto Boss desligado. Historico limitado aos 30 encontros mais recentes, apenas nesta sessao. Um mesmo objeto e contado uma vez; objetos reutilizados, streaming e bosses fora do alcance tornam os dados incompletos.
- Nao ha previsao deterministica de raridade nem horario de spawn. A chance de ao menos um Lendario/Mitico em 20 sorteios e aproximadamente 64,2%, **somente se** forem independentes com taxa constante de 5%. Sequencias anteriores nao provam que um raro esteja devido.

Validacao: 22 testes de deteccao e probabilidades, mais 76 testes existentes; compilacao Luau. A estrutura real dos bosses precisa ser confirmada no cliente usando o diagnostico.


A logo original preta e amarela e usada no cabecalho e no botao de reabrir. A versao 17 remove a transparencia durante carregamento, recorta as margens pela interface, renova o cache e inclui Diagnostico da logo na categoria Sessao. O PNG pode ser baixado do Worker ou do GitHub. O script baixa o PNG do repositorio e guarda em `710hub_logo_neon_v2.png`. Requer `writefile` e `getcustomasset` ou `getsynasset`; sem suporte, ou se a imagem nao carregar, permanece o texto 710. O carregamento da logo nao bloqueia a abertura do menu. A imagem nao foi enviada ao catalogo Roblox.


### Rendimento, rebirth e planejamento

- **Rendimento recente:** forca/minuto medida em uma janela de ate 60 segundos, com pelo menos 10 segundos de amostras. Descarta a janela depois de rebirth, queda de forca, pausa, treino desligado ou lacuna de amostragem. Ganhos de outras fontes podem influenciar a taxa.
- **Previsao de meta:** digite a forca desejada para estimar minutos restantes ao ritmo recente. A previsao e informativa, nao interrompe o treino e nao garante o resultado. Sem ganho ou amostras suficientes, nao mostra tempo inventado.
- **Forca minima antes do rebirth:** protecao opcional com limite definido pelo jogador. Nao descobre nem altera os requisitos oficiais do jogo, e o rebirth pode consumir a forca acumulada.
- **Intervalo de rebirth:** de 0,5 a 30 segundos, padrao de 1 segundo. As duas rotinas compartilham a mesma trava; enquanto um pedido aguarda resposta, outro nao e enviado. Meta, pausa e comparacao sao respeitadas.
- **Aplicar melhor treino:** depois de uma comparacao valida, inicia o metodo com melhor taxa observada. Para as demais rotinas e verifica se o metodo continua disponivel. Repita a comparacao depois de mudar pets ou bonus.
- **Pausas programadas:** configure 1 a 240 minutos ativos e 1 a 60 minutos de descanso. Pausas manuais, por vida baixa e por respawn continuam independentes. Parar tudo ou carregar perfil reinicia o contador. O botao de encerrar descanso nao remove outras pausas.
- **Codigos oficiais:** botoes para copiar megalift50, speedy50, spacegems50 e ultimate250, com alternativa para selecionar o texto quando o clipboard nao esta disponivel. Resgate na interface do jogo; validade e recompensa dependem do servidor.
- **Guia de bonus:** explica os beneficios de Premium e grupo descritos na [pagina oficial do Muscle Legends](https://www.roblox.com/games/3623096087/Muscle-Legends), consultada em 27/09/2026. Nao compra beneficios nem concede multiplicadores.

As configuracoes de intervalo, limite de forca e descanso entram nos perfis salvos. A meta da previsao vale apenas na sessao atual. As novas rotinas opcionais comecam desligadas.

Validacao desta versao: compilacao Luau e 76 verificacoes automatizadas (45 de manutencao e 31 de progresso). A execucao no Roblox/Xeno ainda precisa ser confirmada no jogo.


### Menu neon e leitura

- Tema preto com amarelo neon e dourado, linha animada no cabecalho, destaque ao passar o mouse e transicoes suaves entre categorias. Textos claros e alertas em ambar mantem o contraste.
- Navegacao por **Farm, Bosses, Pets, Metas, Perfis, Sessao e Ajustes**. Em telas estreitas, deslize a barra de categorias horizontalmente.
- Titulos de funcoes em 16px e descricoes em 14px, com quebra de linha e altura automatica. O botao **A+** aumenta para 18px/16px; **A−** restaura o tamanho padrao.
- Busca global que ignora acentos. Clicar numa categoria limpa a busca.
- Painel ajustado ao tamanho da tela, arrastavel pelo cabecalho com mouse ou toque.
- **Pausar/Retomar** e **Parar tudo** sempre acessiveis na barra inferior. O botao **−** minimiza; **710** reabre.

O layout compila, mas a aparencia final ainda deve ser conferida no Roblox na resolucao usada pelo jogador.

### Manutencao e automacoes

Novas categorias: CONTROLE E PERFIS, PROTECAO E BOSSES, METAS E COMPARACAO, HISTORICO E COMPATIBILIDADE.

1. **Perfis:** tres slots, com configuracao de rotinas, metas, boss e protecoes. Salvar grava `710hub_profiles_v1.json` no workspace do executor, quando `writefile` existe. Sem acesso a arquivos, o perfil dura apenas a sessao do executor. O ultimo perfil salvo e restaurado em pausa: use **Pausar / Retomar** para iniciar. Timers absolutos nao sao restaurados.
2. **Pausa e retomada:** preservam as opcoes e suspendem novas acoes automaticas. Chamadas ja enviadas ao servidor nao podem ser desfeitas. Pausas por personagem incompleto ou vida baixa nao sao removidas pelo botao manual.
3. **Recuperacao apos morrer:** aguarda Humanoid, raiz e vida positiva, atualiza referencias e retoma a configuracao. Desligar essa opcao exige retomada manual apos morrer.
4. **Boss preferido:** use a lista de bosses detectados para digitar o nome exato. O nome e priorizado na proxima selecao; se estiver ausente, outro boss detectado pode ser escolhido.
5. **Vida baixa:** com Auto Boss ligado, pausa por padrao em 25% e retoma em 75%. Os limites sao configuraveis. O retorno ao ponto anterior depende da opcao de retorno; nao concede cura ou invulnerabilidade.
6. **Farm parado:** alerta depois de 60s sem aumento de forca ou rebirth, com intervalo configuravel de 30 a 600s. Ignora pausas e combate de boss; nao mede farm de agilidade ou durabilidade.
7. **Comparador de treinos:** suspende temporariamente outras rotinas e mede ferramenta, rajada e maquina disponiveis por ate 20s cada. Restaura a rotina anterior no fim. Recomenda apenas com pelo menos duas amostras validas; rebirth, perda de forca e interrupcoes invalidam a medicao. Pets e bonus externos podem alterar resultados.
8. **Metas personalizadas:** digite o valor absoluto da estatistica escolhida em METAS e ative a parada por meta. Para o ciclo, digite uma quantidade adicional de rebirths e use **Iniciar ciclo personalizado**.
9. **Historico:** tempo, ganhos observados, mortes e ultimos 150 eventos. Pode ser lido/copiado no painel e exportado para `710hub_historico.txt` quando ha acesso a arquivos. A soma dos ganhos de forca observados pode perder ganhos entre amostras e nao representa o saldo depois de rebirths.
10. **Compatibilidade:** verifica recursos a cada 15s e registra perdas e recuperacoes. A verificacao inspeciona objetos visiveis; nao prova que o servidor aceitara as chamadas. A linha de base e persistida junto do perfil quando ele e salvo.

O comparador e o botao de parada cancelam tarefas de comparacao antigas. Alterar um toggle durante a comparacao cancela a medicao e aplica a nova escolha. O temporizador fica suspenso durante pausas e comparacoes.

### Correcoes preservadas

- Corrige o erro de compilacao `exceeded limit 200`, separando a construcao da interface.
- Exibe falhas de inicializacao e limita esperas por objetos do jogo.
- Usa PlayerGui, sem exigir acesso ao CoreGui.
- Busca por nome de funcao ou categoria e botao para encerrar a sessao.
- Auto Kill Boss permanece aguardando novos spawns enquanto estiver ligado. Busca a cada dois segundos quando esta sem alvo, ataca com Punch, permite configurar distancia e retorno ao ponto inicial. O contador registra mortes observadas, nao recompensas confirmadas ou autoria da eliminacao.
- Ciclo de +10, +25, +50 ou +100 rebirths, seguido por treino de forca.
- Equipar pets de forca possuidos, temporizador de 15/30/60/120 minutos e medias de forca/minuto e rebirths/hora.
- Corrige o respeito a meta de rebirth no modo Forca + Rebirth.

Para bosses: ligue **Auto Kill Boss / farm de boss** na categoria BOSSES. A deteccao depende de NPCs com Humanoid e marcadores de boss visiveis ao cliente. Bosses fora do alcance de streaming ou com outra estrutura podem nao ser detectados. Recompensas, dano e requisitos de rebirth sao controlados pelo jogo. Nao ha multiplicadores artificiais.

Para progressao: escolha a quantidade em PROGRESSAO e clique em Iniciar ciclo. Configure o temporizador depois de iniciar o perfil. Parar todas as automacoes cancela tambem o ciclo e o temporizador. Nenhuma automacao comeca ligada.

## Validacao

Compilado com Luau 0.740. `Maintenance.test.luau` cobre pausas independentes, perfis invalidos, metas, alertas, cancelamento de comparacao, historico e mudancas de compatibilidade. O funcionamento da interface no cliente Roblox/Xeno, os remotes do jogo e o recebimento de recompensas ainda exigem teste no jogo. Esta versao evolui o codigo do 710Hub; nao e uma copia integral do Speed Hub.

### Desenvolvimento

A implementacao local completa e autocontida: o comando de carregamento nao faz novos downloads de modulos Lua; a logo PNG e baixada separadamente quando nao esta no cache. `Maintenance.lua` e os arquivos `.fragment.lua` sao fontes incorporadas por `build.ps1`; `MenuShell.fragment.lua` contem o tema, a navegacao e os componentes visuais. Depois de editar essas fontes, reconstrua o arquivo principal e execute:

```text
luau Maintenance.test.luau
luau Progress.test.luau
luau-compile --null 710Hub.lua
```

`Maintenance.lua` contem o controlador testavel sem Roblox; os fragmentos fazem a integracao com jogo e interface. Execute `build.ps1` em um ambiente PowerShell que permita os seus scripts locais.
