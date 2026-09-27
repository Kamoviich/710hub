# 710Hub — Muscle Legends

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/main/710Hub.lua", true))()
```

Abra Muscle Legends, execute o comando e aguarde o painel. RightShift abre/fecha o menu; End para as automacoes.

## Versao 2026.09-stable.11

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

Compilado com Luau 0.740. O arquivo anterior falhava por excesso de variaveis locais; esta versao compila. O funcionamento no cliente Roblox/Xeno, os remotes do jogo e o recebimento de recompensas ainda exigem teste no jogo. Esta versao evolui o codigo do 710Hub; nao e uma copia integral do Speed Hub.

