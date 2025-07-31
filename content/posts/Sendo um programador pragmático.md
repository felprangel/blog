---
title: "Sendo um programador pragmático"
date: 2025-07-30
draft: false
---

## O gato comeu meu código fonte

Seja responsável pelo código que você escreve, reconheça quando cometer erros e lide com isso profissionalmente. Se acontecer uma falha e você não tiver um plano de contingência, dizer ao seu chefe "o gato comeu meu código" não vai resolver.

Antes de abordar alguém para dizer que algo não pode ser feito, pare e escute a si mesmo. Como sua resposta vai soar para seu chefe?

**Em vez de desculpas, forneça opções.** Não diga que não pode ser feito; explique o que pode ser feito para salvar a situação.

Pense consigo mesmo, como você reage quando alguém como um caixa de banco, um mecânico, ou um balconista, lhe dá uma desculpa esfarrapada? O que você acha deles e de sua empresa em decorrência disso? Por exemplo, quando você pede um prato do cardápio, e a cozinha está em falta de um ingrediente essencial, você prefere que o garçom venha apenas te dar a notícia ou te dê alternativas para contornar o problema?

## Entropia de Software

Em algumas cidades, alguns prédios são belos e limpos, enquanto outros são estruturas deterioradas. Por quê? Pesquisadores descobriram um fascinante mecanismo acionador, um mecanismo que torna muito rapidamente um prédio limpo, intacto e habitado em uma construção quebrada e abandonada: **uma janela quebrada.**

Uma janela quebrada, deixada sem reparos por um certo período de tempo, faz brotar nos moradores uma sensação de abandono - uma sensação que os responsáveis não se preocupam com o prédio. Portanto, outra janela é quebrada. As pessoas começam a acumular lixo na área externa. Em um curto período de tempo, o prédio fica danificado demais para o proprietário querer consertá-lo e a sensação de abandono se torna realidade.

**Não deixe uma "janela quebrada" no seu código.** Ao ver uma pequena "bagunça", conserte-o, nem que seja com tábuas de madeira. Se pensar "não temos tempo para arrumar todas as janelas quebradas", é melhor planejar a compra de uma caçamba ou mudar para outra vizinhança.

## Software Satisfatório

Não existe software perfeito, ponto. Ficar polindo demais um software faz você nunca lançar um produto. Os usuários preferem ter algo limitado para usar agora, do que o produto completo da que um ano.

## Sua carteira de conhecimentos

Trate seu conhecimento como um investidor trata uma carteira de investimentos:

- Invista regularmente, como um hábito
- Diversificação é a chave para o sucesso a longo prazo
- Tenha uma carteira equilibrada com investimentos conservadores e investimento de alto risco e remuneração
- Compre barato e venda caro para obter o máximo em retorno
- A carteira deve ser reexaminada e reestruturada periodicamente

## Protótipos

Criar protótipos é um ato de aprendizado. Um protótipo pode ser completamente descartável, já que o valor não está no código produzido, mas nas lições aprendidas. Essa é a razão real para a criação de protótipos.

### Coisas que devem ter um protótipo

- Arquitetura
- Nova funcionalidade em um sistema existente
- Estrutura ou conteúdo de dados externos
- Ferramentas ou componentes de terceiros
- Questões de desempenho
- Projeto de interface de usuário

**Lembre-se:** um protótipo não é um MVP, são duas coisas diferentes.

Um MVP é o que o livro chama de _projétil luminoso_ em que você constrói algo mínimo que funcione e que o código pode e muito provavelmente vai ser reutilizado na versão final. Um protótipo tem de ser algo rápido, que pode ser construído até mesmo com outras linguagens de mais alto nível da que seu projeto utiliza, ou pode até não usar linguagem nenhuma!

**Exemplo prático:** O marketing quer discutir páginas web com mapas clicáveis — talvez um carro, telefone ou casa. Você tem 15 minutos para mostrar protótipos. O que faz mais sentido: tentar montar algo "real" na stack do projeto ou fazer wireframes no Figma, esboços no Paint, ou até desenhos em um guardanapo?

## Estimando

### Que nível de exatidão é suficientemente exato?

Até certo ponto, todas as respostas são estimativas. Só que algumas são mais precisas do que outras. O que precisa ser levado em consideração é se é necessário um nível alto de precisão ou o que estão querendo é um número aproximado.

Por exemplo, quando sua vó pergunta quando você vai chegar, ela provavelmente está pensando se deve se preparar pra te receber com almoço ou com jantar. Por outro lado, um mergulhador preso debaixo d'água ficando sem oxigênio vai querer uma resposta expressa em segundos.

Uma coisa interessante das estimativas é que a unidade usada faz diferença na percepção dos resultados. Por exemplo, se disse que algo levará cerca de 130 dias úteis, as pessoas terão expectativas de algo mais exato. No entanto, se disse "em cerca de 6 meses", elas saberão que a margem de erro pode ser maior.

O livro recomenda a seguinte tabela:

| Duração            | Calcule a estimativa em               |
| ------------------ | ------------------------------------- |
| 1-15 dias          | dias                                  |
| 3-8 semanas        | semanas                               |
| 8-30 semanas       | meses                                 |
| mais de 30 semanas | pense bem antes de dar uma estimativa |

## Programação assertiva

Nunca, NUNCA, você deve pensar:

> Isso nunca vai acontecer...

"`count` não pode ser negativo". "Esse comando `printf` nunca vai falhar"

Sempre que se pegar pensando "isso nunca vai acontecer", adicione código para verificar. A maneira mais fácil é com asserções. Lembre-se: se algo pode dar errado, eventualmente dará.

## Orgulho e preconceito

Os artesãos da antiguidade tinham orgulho em assinar seu trabalho. Você também deveria ter.

Isso não significa tratar seu código como propriedade intocável. Devemos respeitar o código dos outros. "Trate os outros como gostaria de ser tratado." Queremos ver orgulho na autoria: "Escrevi isso e sou responsável pelo meu trabalho."

Sua assinatura deve ser reconhecida como indicador de qualidade. As pessoas devem ver seu nome em um código e esperar consistência, boa escrita, testes e documentação. Trabalho profissional de verdade. Com certeza, escrito por um programador pragmático.

## Dicas que o livro dá

1. Preocupe-se com seu trabalho
2. Reflita sobre seu trabalho
3. Forneça opções, não dê desculpas esfarrapadas
4. Não tolere janelas quebradas
5. Seja um catalisador da mudança
6. Lembre-se do cenário em larga escala
7. Torne a qualidade parte dos requisitos
8. Invista regularmente em sua carteira de conhecimentos
9. Analise criticamente o que você lê e ouve
10. É o que você diz e a maneira como diz
11. DRY - Don't Repeat Yourself
12. Facilite a reutilização
13. Elimine efeitos entre elementos não relacionados
14. Não há decisões definitivas
15. Use projéteis luminosos para encontrar o alvo
16. Crie protótipos para aprender
17. Programe em um nível próximo ao domínio do problema
18. Estime para evitar surpresas
19. Reexamine o cronograma junto ao código
20. Mantenha as informações em texto simples
21. Use o poder dos shells de comando
22. Use um único editor bem
23. Use sempre o controle de código fonte
24. Corrija o problema, esqueça o culpado
25. Não entre em pânico
26. "select" não está com defeito
27. Não suponha, teste.
28. Aprenda uma linguagem de manipulação de texto
29. Escreva um código que crie códigos
30. Você não conseguirá criar um software perfeito
31. Projete com contratos
32. Encerre antecipadamente
33. Se não pode acontecer, use asserções para assegurar que não aconteça
34. Use exceções para problemas excepcionais
35. Acabe o que começou
36. Reduza a vinculação entre módulos
37. Configure, não integre
38. Coloque as abstrações no código e os detalhes em metadados
39. Analise o fluxo de trabalho para melhorar a concorrência
40. Projete usando serviços
41. Projete sempre pensando na concorrência
42. Separe as visualizações dos modelos
43. Use quadros-negros para coordenar o fluxo de trabalho
44. Não programe por coincidência
45. Estime a ordem de seus algoritmos
46. Testes suas estimativas
47. Refatore cedo, refatore sempre
48. Projete para testar
49. Teste seu software ou seus usuários testarão
50. Não use um código de assistente que você não entender
51. Não colete requisitos - cave-os
52. Trabalhe com um usuário para pensar como um usuário
53. Abstrações têm vida mais longa do que detalhes
54. Use um glossário do projeto
55. Não pense fora da caixa - _encontre_ a caixa
56. Só comece quando estiver pronto
57. Algumas coisas são fáceis de fazer, mas não de descrever
58. Não seja escravo dos métodos formais
59. Ferramentas caras não produzem projetos melhores
60. Organize as equipes com base na funcionalidade
61. Não use procedimentos manuais
62. Teste cedo. Teste sempre. Teste automaticamente
63. A codificação só estará concluída após todos os testes serem executados
64. Use sabotadores para testar seus testes
65. Teste a cobertura de estados e não a cobertura de código
66. Encontre os erros apenas uma vez
67. Trate o português simplesmente como outra linguagem de programação
68. Construa a documentação no código, não a acrescente como complemento
69. Exceda gentilmente as expectativas de seus usuários
70. Assine seu trabalho
