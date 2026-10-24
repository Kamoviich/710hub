# Comparação de sistemas de PvP — 24/10/2026

O critério desta comparação foi código legível, ligação entre contato e golpe, cancelamento, seleção de alvos e custo de execução. Não houve acesso ao servidor original nem benchmark de kills no Roblox. Portanto, não há base para declarar um hub o mais rápido ou o mais forte em todos os servidores.

| Fonte examinada | Evidência no código | Decisão para o 710Hub |
| --- | --- | --- |
| [Silence Main](https://github.com/silencedevs/SilenceScripts/blob/main/Scripts/MuscleLegends/Main.luau) | Usa contato nas mãos e comandos de golpe, acompanhamento perto do alvo, cancelamento por geração, proteção de spawn e observação da vida. A rotina coletiva pode dedicar quatro segundos a cada jogador. | Adotar a sequência explícita das duas mãos e perseguição em modo próprio; manter lotes com rotação e permitir foco opcional. |
| [NTS](https://github.com/ntsdzctii/nts/blob/main/ntsdz.lua) | Possui varredura de jogadores para contatos nas duas mãos e rotinas separadas para golpes rápidos; alguns loops usam espera de 0,01 segundo. | Unificar contatos e comandos na mesma execução cancelável, com intervalo configurável e orçamento central de chamadas. |
| [SyncX](https://github.com/Sidhsksjsjsh/MuscleLegends/blob/main/SyncX/Script.lua) | O arquivo consultado não contém rotina de kill nem `firetouchinterest`. | Sem mecanismo de PvP aproveitável nessa fonte. |
| [King](https://github.com/hazardzzk/king/blob/main/king.lua) | O arquivo consultado está ofuscado e não expõe um mecanismo de ataque legível nessa inspeção. | Não usar como evidência de desempenho ou incorporar seu carregador. |
| [Mystery Renewed](https://github.com/Mystery-Center/Mystery-Loader/blob/main/Renewed.lua) | Na consulta atual, contém apenas uma impressão no console. A auditoria histórica local descreve opções antigas, sem benchmark atual. | Não atribuir capacidades atuais ao loader. Preservar as listas e filtros nativos já existentes. |

Entre as fontes legíveis examinadas, Silence fornece a base mais completa para os aspectos de ataque e cancelamento usados nesta adaptação. Isso é uma avaliação do código, não uma classificação de eficácia no jogo.

O motor .47 envia o contato e o comando correspondente para cada mão, suporta nomes de membros R6 e R15, limita a concorrência a uma execução e permite prioridades por vida, proximidade, rotação ou foco. O modo Perseguir desloca o personagem local e troca de alvo após quatro segundos sem dano quando há alternativas; Manter alvo preserva o foco escolhido. Distancia e Aura preservam sua posição. Whitelist, proteção de spawn, pausa, morte e encerramento são reavaliados antes de cada golpe.

O estado separa solicitações de dano observado, incluindo morte entre duas rodadas, erros de contato e de envio. Os testes usam uma fixture que só reduz vida após um par de contato completo seguido do comando de mão correspondente. Essa fixture verifica o protocolo do cliente, sem reproduzir as regras reais do servidor.

Hashes de blob Git das fontes consultadas:

| Fonte | SHA |
| --- | --- |
| Silence Main | `3129697df84b5846360aab6b5033b4f9075625b4` |
| NTS | `1be9fa30227aad2bcf2faf3e9a4c303e0f153ae7` |
| SyncX | `dc39efcabd609297078e59db7360ab191c58c864` |
| King | `35fa6ca555425540eb4e26111619790884249ee5` |
| Mystery Renewed | `c0091e0da7160911adfb0851bf4684f297250271` |

Nenhum código externo é baixado ou executado pelo motor novo. Bring continua sujeito à replicação e pode ser apenas visual no cliente; Range Universal abrange personagens carregados; localização de servidor continua limitada aos dados disponíveis ao Roblox. Não foram encontradas ou confirmadas brechas no servidor original nesta análise.
