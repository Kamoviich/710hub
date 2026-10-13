# 710Hub 2026.10-tested.39 — força e fast rebirth

O modo **Fast Rep (packs)** envia reps por frame e ajusta o ritmo pelo progresso observado de força/durabilidade. Começa em 200 pedidos/s, aumenta até o limite configurado de 40–659 e reduz se o progresso parar. O teto antigo de 160 chamadas/s continua nas outras operações; esse treino tem um controle próprio, com até 24 pedidos por frame e sem acumular rajadas durante pausas.

**Seus pets equipados são preservados durante força e fast rebirth.** O controlador apenas lê os pets atuais, os slots e os bônus conhecidos/replicados. Não troca pets para velocidade, força ou rebirth. O autoequip por atributo e a evolução automática aguardam enquanto o Fast Rep estiver ativo. As ferramentas anteriores de pets continuam disponíveis quando o treino rápido estiver desligado, caso você as ative explicitamente.

## Como usar

1. Equipe no jogo o conjunto de pets que deseja manter.
2. Em Treino, selecione **Fast Rep (packs)** e clique em **Iniciar / parar treino**.
3. Para renascer junto ao treino, ative **Fast rebirth / rebirth automático**. Deixe desligado para acumular força.
4. Abra **Rendimento do Fast Rep**: o relatório atualiza a cada segundo com ganho de força/durabilidade/rebirth, ritmo recente e média ativa. Aguarde pelo menos dez segundos antes de comparar ganhos.

O ciclo de fast rebirth solicita assim que há força suficiente e o intervalo configurado permite, sem a antiga espera fixa de três segundos. Dá preferência a um requisito replicado; se ele não existir, usa a fórmula encontrada no Silence (`5000 + rebirths * 2550`). Solicita pelo canal `rebirthRequest` e confirma a mudança na estatística, mantendo o treino de força ativo durante a resposta e a confirmação. Respeita a meta absoluta de rebirths; atingir essa meta para os rebirths e mantém o treino de força. Recusas usam espera adaptativa de 0,5, 1 e até 2 segundos, respeitando intervalos maiores que você configurar. O padrão é 0,5 segundo; a contagem parte do pedido, evitando uma segunda espera inteira depois da resposta. Uma única solicitação fica pendente por vez.

O painel informa se aguarda força, confirmação ou o intervalo, além da força atual/necessária e da última recusa. Um pedido recusado não é contado como rebirth. A redução dessas esperas corrige atrasos do cliente; não remove requisitos ou cooldowns impostos pelo servidor.

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

Foram executadas **464 verificações offline**: 312 do menu, 67 de força/fast rebirth, 23 de cenários prolongados/concorrentes, 22 do fluxo de bosses, 20 da pose acima do boss e 20 da interface. O menu tem 67 elementos, com títulos/IDs únicos. A suite de Fast Rep executa o script completo com doze pets equipados e verifica suas referências exatas após sucesso, recusa, timeout, pausa, boss, respawn e queda de FPS; registra zero chamadas de equip/unequip nesse fluxo. Os casos prolongados verificam um minuto de ciclos, parada sem ganhos apesar de recusas frequentes, requisitos inválidos, pausa longa, confirmação pendente e cancelamento de alterações de pets ao entrar no Fast Rep. Nesses últimos casos, a fixture inicia explicitamente uma tarefa de pets antes do treino e verifica que nenhuma alteração restante acontece após ativar o modo.

Os testes também verificam pedido em menos de 300ms quando a força já basta, força ativa durante resposta/replicação atrasada, ausência de pedidos concorrentes, recuperação após duas recusas temporárias e espera limitada após recusas persistentes. Esses tempos são resultados da fixture, não medições no Roblox.

```powershell
py -3 build_clean.py
py -3 tests/check_clean.py
py -3 tests/check_fast_rep.py
py -3 tests/check_fast_rep.py --stress
py -3 tests/check_published.py
py -3 tests/check_boss_hover.py
py -3 tests/check_design.py
```

As fixtures definem seus próprios ganhos e requisitos. Os testes não comprovam rendimento no servidor Roblox real. Pedidos enviados não são reps aceitas e 659 pedidos/s não garantem ganhos iguais aos screenshots. Compare o ganho observado por minuto na mesma conta, conjunto de pets, boosts e servidor.

## Versão de teste fixada

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kamoviich/710hub/2825144cbaba3a2bf501f9bf130704ce27590515/710Hub.lua", true))()
```
