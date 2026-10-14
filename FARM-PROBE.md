# Medição passiva de gargalos: força e durabilidade

`710Hub-farm-probe.lua` abre um medidor independente. Pode acompanhar o 710Hub ou o Silence. Os botões identificam qual farm você está medindo; **não iniciam nem trocam o farm**. O script lê valores da conta e eventos locais; não envia reps, não equipa pets, não provoca travadas e não altera a rede.

## Como medir na conta real

1. Mantenha o mesmo servidor, pets, boosts, treino e configurações. Desligue o rebirth para que a força não seja consumida durante a rodada. Evite coletar recompensas, consumir boosts ou combater bosses durante a comparação.
2. Execute o medidor. Ative **um único hub/farm**, aguarde o ganho estabilizar e toque em **Medir 710Hub** ou **Medir Silence**, conforme o que está ativo.
3. Aguarde a conclusão automática. A duração é de pelo menos 60 segundos reais. Se o cliente travar aos 58s e só retornar aos 65s, o denominador será 65s e incluirá o ganho visível até a retomada.
4. Repita o mesmo modo para obter rodadas com e sem pausas naturais. O relatório compara as medianas somente após três rodadas válidas em cada grupo. Essa quantidade é um mínimo para não concluir a partir de uma única rodada; não fornece significância estatística.
5. Para comparar os hubs, desligue o farm anterior e aguarde os ganhos remanescentes estabilizarem antes de ativar o outro. Alterne a ordem entre as rodadas para reduzir o efeito de tempo/boosts. Após três rodadas válidas por hub, aparece a comparação adicional Silence/710Hub.
6. Use **Copiar relatório** e envie o texto. **Parar medição** ou fechar o medidor não para seu farm. O histórico de até doze rodadas permanece disponível ao reexecutar o medidor na mesma sessão.

“Pausas” são intervalos de pelo menos 250ms entre callbacks do Heartbeat. “Saltos” são mudanças visíveis após pelo menos um segundo sem mudança da estatística. O segundo caso pode acontecer com Heartbeat regular, e nenhum dos dois identifica sozinho a causa do gargalo. O medidor amostra os valores quatro vezes por segundo, registra cada intervalo do Heartbeat e atualiza a interface uma vez por segundo. O ping é lido no máximo uma vez por segundo, quando disponível.

São excluídas da comparação rodadas interrompidas ou com reset observado de força/durabilidade, rebirth, morte/respawn, troca observada de pets, servidor diferente ou estatísticas indisponíveis. O comparador também exige os mesmos pets, rebirths iniciais e servidor entre rodadas. Ele não detecta mudanças que ocorram inteiramente entre amostras, nem controla evolução/perks de pets, multiplicadores temporários ou boosts do jogo. Esses fatores precisam ser mantidos constantes pelo usuário.

## O que já foi testado offline

| Modelo sintético | Força/s | Durabilidade/s | Interpretação do medidor |
| --- | ---: | ---: | --- |
| Ganho constante, cliente regular | 100 | 20 | Referência |
| Mesmo ganho, pausa de cinco segundos no cliente | 100 | 20 | Pausa registrada, sem bônus inventado |
| Mesmo ganho, estatísticas entregues em blocos de cinco segundos | 100 | 20 | Saltos de estatística, sem pausa de frame |
| Bônus de 2× explicitamente definido pela fixture | 200 | 40 | Aumento real do ganho definido pelo modelo |

Esses valores foram escolhidos na fixture para verificar a medição. **Não representam taxas do Muscle Legends e não demonstram se o servidor real tem um bug.** O caso sem bônus e o caso com bônus apresentam resultados diferentes no comparador, mesmo com travadas. A medição real mostrará associação entre pausas e ganhos, não prova causal nem confirmação independente do servidor.

Foram executadas 53 verificações locais: 41 do cálculo/comparação e 12 do adaptador/interface. Incluem janela estendida por travada, ausência de conclusão com pouca amostra, reset/rebirth, pets alterados, condições diferentes entre rodadas, reexecução/limpeza, zero remotes e painel de 320×320. O script independente compilou em Luau. Os testes não executaram Roblox, Silence nem um servidor real.

```powershell
py -3 build_farm_probe.py
py -3 tests/check_farm_probe.py
```

O comportamento do Heartbeat e os limites da interpretação seguem a [referência oficial de RunService](https://create.roblox.com/docs/reference/engine/classes/RunService) e o [guia de desempenho do Roblox](https://create.roblox.com/docs/performance-optimization/improve). O instrumento utiliza apenas informações observáveis no cliente.
