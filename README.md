# 710Hub — Muscle Legends

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/main/710Hub.lua", true))()
```

Abra Muscle Legends, execute o comando e aguarde o painel. RightShift abre/fecha o menu; End para as automacoes.

## Versao 2026.09-stable.12

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

O arquivo `710Hub.lua` e autocontido: o comando de carregamento nao faz novos downloads de modulos. `Maintenance.lua` e os dois arquivos `.fragment.lua` sao fontes de manutencao incorporadas por `build.ps1`. Depois de editar essas fontes, reconstrua o arquivo principal e execute:

```text
luau Maintenance.test.luau
luau-compile --null 710Hub.lua
```

`Maintenance.lua` contem o controlador testavel sem Roblox; os fragmentos fazem a integracao com jogo e interface. Execute `build.ps1` em um ambiente PowerShell que permita os seus scripts locais.
