# PvP e desempenho — 2026.10-pvp.46

Execute `710Hub.lua` inteiro em Muscle Legends. `710Hub.protegido.lua` contém a mesma versão. A revisão está disponível no ramo `codex/pvp-46` do repositório `Kamoviich/710hub`; o loader de teste aponta para a publicação desta versão.

Na categoria **PvP**, selecione um jogador e o **Modo de ataque PvP**. Use **Iniciar / parar PvP** para ligar ou desligar o controlador.

| Opção | Comportamento |
| --- | --- |
| Aproximar | Caminha até um alvo e ativa Punch, com verificação de obstáculos. |
| Distancia | Ativa Punch e solicita contatos com o alvo sem mover seu personagem. Exige `firetouchinterest`. |
| Bring | Tenta trazer os alvos para perto antes de solicitar contato. A mudança pode ficar somente no seu cliente ou ser corrigida pelo servidor. |
| Aura | Solicita contatos apenas com jogadores dentro da esfera fixa que você marcou. Seu personagem pode se afastar do centro. |
| Range de Kill Universal | Remove o limite de busca para Aproximar, Distancia e Bring. Abrange personagens carregados no cliente. A área da aura mantém o próprio limite. |
| Selecionado | Filtra pela conta escolhida no seletor. |
| Multiplos | Usa as contas adicionadas em **Adicionar / remover alvo multiplo**. Atende no máximo oito por rodada, alternando os lotes. |
| Blacklist | Filtra tags salvas nos nomes, nomes de exibição ou atributos/valores replicados de clã. A comparação ignora maiúsculas e usa texto literal. |

**Whitelist:** selecione uma conta e use **Proteger / liberar jogador**, ou digite `+12345` no campo de whitelist para proteger um UserId e `-12345` para remover a proteção. A whitelist tem prioridade em todos os modos, inclusive blacklist. A proteção de amigos e a proteção de spawn continuam sendo respeitadas.

**Blacklist:** digite `+[CLA]` para adicionar uma tag e `-[CLA]` para removê-la. Use **Ativar PvP automatico da blacklist** para iniciar o controlador com esse filtro. Enquanto ativo, ele reconhece novos jogadores e mudanças nas tags. Remover uma tag interrompe a seleção correspondente. Salvar uma tag não liga combate sozinho; o carregamento do hub e dos perfis também não inicia PvP.

**Aura:** escolha Aura, configure o raio de 5 a 500 studs e use **Marcar area da Kill aura** na posição desejada. Inicie o PvP. A esfera é uma marcação local e respeita o filtro escolhido e a whitelist. **Parar tudo**, END e encerramento do hub cancelam o combate e removem a marcação.

Whitelist, alvos e tags são salvos por conta em `710hub_pvp_<UserId>_v1.json` quando o executor oferece `writefile` e `readfile`. Sem essas funções, permanecem no ambiente da sessão. O relatório **Ver whitelist, alvos e blacklist** informa o estado da gravação. Os limites de leitura são 200 contas por lista, 30 tags e 64 KB de arquivo.

**Player Hunter:** informe um UserId ou @usuário exato, clique em **Buscar servidor do jogador** e consulte o estado. O hub reconhece jogadores no servidor atual e consulta até 200 amigos com localização disponível pelo Roblox. Quando encontra um destino, **Entrar no servidor encontrado** interrompe suas automações e solicita o teleporte. Não localiza qualquer conta, não força acesso a servidores privados e não ignora permissões ou lotação. A API geral de localização de servidor só pode ser chamada pelo servidor; a consulta local de amigos fornece apenas os dados expostos pelo Roblox. [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService#GetPlayerPlaceInstanceAsync), [Player.GetFriendsOnlineAsync](https://create.roblox.com/docs/reference/engine/classes/Player#GetFriendsOnlineAsync).

**Lag zero / modo estavel**, em Ajustes, ativa limites de carga e redução gráfica. A redução oculta efeitos e texturas locais e desativa sombras, restaurando as propriedades ao desligar. Não elimina latência da conexão nem travamentos do servidor.

Contatos solicitados não equivalem a dano aprovado ou morte. O painel distingue solicitações de contato e queda de vida observada. Alcance, proteção, dano e replicação são controlados pelo jogo; com streaming, personagens de regiões distantes podem não existir no cliente. [Execução entre cliente e servidor](https://create.roblox.com/docs/projects/client-server), [Validação no servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary).

Para reconstruir e verificar:

```powershell
py -3 build_clean.py
py -3 tests/check_clean.py
py -3 tests/check_fast_rep.py --rebirth
py -3 tests/check_fast_rep.py --combined
py -3 proteger_scripts.py 710Hub.lua
```

Os testes executam o script completo e os controles em um simulador Roblox offline. Cobrem filtros, persistência, contatos em pares, lotes, cancelamento, aura fixa, bring local e consulta/entrada no servidor. Não confirmam dano, kills, bring replicado, teleporte real ou ganho de FPS dentro do Roblox.
