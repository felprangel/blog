---
title: As partes importantes de Clean Code (O Codificador Limpo)
date: 2025-03-01
draft: false
---

Para ser sincero, estou escrevendo este post mais para minhas consultas futuras do que por qualquer outro motivo, mas sei que pode ser útil para outras pessoas. Dito isso, tentei explicar com minhas palavras os pontos mais importantes do livro em cada capítulo.

Lembre-se: nada aqui é regra absoluta. Tudo pode e deve ser questionado. Agora, sem mais delongas, vamos aos capítulos!

## Profissionalismo

### Profissionalismo = Responsabilidade

#### Não cause danos ao funcionamento

> [...] Software é muito complexo para ser criado sem bugs. Mas infelizmente, isso não o exime de sua responsabilidade. O corpo humano é muito complexo para ser entendido plenamente, mas os médicos ainda fazem um juramento para não danificá-lo. Se eles não se eximem da responsabilidade, por que nós deveríamos?

Se você faz um estrago no sistema, não pode simplesmente dar de ombros e dizer: "Ah, tecnologia é assim mesmo". Responsabilidade é chave.

#### O QA não deve encontrar nada

Se você envia um código para QA esperando que eles encontrem bugs, parabéns, você está sendo _preguiçoso_ e _anti-profissional_.

Sempre que um QA (ou pior, um usuário) encontra um bug, você deve ficar surpreso, desapontado e disposto a evitar que isso aconteça novamente. A ideia é que QA seja a última linha de defesa, não a primeira.

### Todo código deve ser testado

Você precisa ter certeza que o código funciona, e como você sabe isso? Testando ele!

> Estou sugerindo 100% de cobertura de testes? Não estou _sugerindo_ isso. Estou _exigindo_. Toda linha de código que você escreve precisa ser testada. Ponto final.

Se não está testado, está quebrado. Simples assim.

### Não cause danos a estrutura

Todo código deve ser fácil de ser alterado e dar manutenção. Se a facilidade da manutenção for sacrificada em troca de rapidez no curto prazo, vai ser criado um lamaçal no código, que atrasa todo mundo que entra nele.

A única maneira de provar que o software é fácil de alterar é alterando ele.

> Cada vez que olha para um módulo você faz pequenas e leves mudanças para melhorar a estrutura. Sempre que ler o código, ajuste a estrutura. [...] Faça algumas ações aleatórias sutis em um código, sempre que o ver

#### A polêmica das 60 horas semanais

Robert diz que um programador profissional deve se dedicar 60 horas semanais: 40 para o empregador e 20 para si mesmo. E se você não pode se comprometer com isso? Bom, segundo ele, _você não é um profissional_.

Concordo que estudar 20 horas semanais pode te tornar um profissional melhor, mas achar que quem não consegue fazer isso não é profissional é absurdo. Pessoas têm famílias, deslocamentos longos, vida fora do trabalho. Não é tão simples assim.

### Conhecer o seu campo

Se você quer ser um profissional de verdade, precisa conhecer seu território. Isso inclui design patterns, princípios como SOLID, metodologias como Agile e Scrum, disciplinas como TDD e orientação a objetos, além de artefatos como diagramas UML. Sim, parece muita coisa, mas acredite: entender essas bases vai te poupar muitas dores de cabeça no futuro.

Como diz o ditado: _"Aquele que não conhece o passado está fadado a repeti-lo"_. E, no mundo da programação, isso significa reinventar a roda quadrada.

Aprender sobre a área e os princípios de código é essencial. Afinal, esses conhecimentos atemporais vêm sendo refinados desde os anos 70, e se ainda estão por aí, é porque fazem sentido. Então, antes de sair digitando como um maníaco, vale a pena dar uma olhada no que os mestres do passado já descobriram.

---

## Dizendo não

Aprender a dizer "não" pode salvar sua sanidade. Como dizia um ex-chefe meu:

> "É melhor amarelar agora do que envermelhar depois."

Se seu gerente pergunta se a tela de login fica pronta até amanhã e você sabe que é impossível, diga _não_. Não existe "eu vou tentar". Ou você sabe que consegue ou sabe que não consegue.

---

## Dizendo sim

Comprometimento significa:

1. Você diz que vai fazer.
2. Você é honesto.
3. Você faz.

Nada de "eu _possivelmente_ termino na terça". Se você se compromete, você **vai** terminar na terça.

Caso ocorra um imprevisto, avise cedo. Ninguém gosta de surpresas de última hora.

---

## Codificando

Se você está cansado ou distraído, não codifique. Sério, só vai piorar as coisas.

Muitas soluções surgem no banho ou no caminho de volta pra casa.

E lembre-se: fazer horas extras para cumprir prazos pode ser contraproducente. Código ruim escrito às 2 da manhã vai precisar ser refeito de qualquer forma.

O livro também alerta sobre a "falsa entrega"—aquele truque de marcar algo como concluído sem realmente terminar, apenas para cumprir o prazo. Spoiler: o tempo para arrumar isso depois _nunca_ aparece, e o código fica para sempre incompleto.

Outro ponto crucial: ajudar e ser ajudado. Quando alguém pedir sua ajuda, dê atenção. Quando precisar de ajuda, peça. Não faz sentido passar o dia inteiro travado em um problema quando alguém poderia resolver em minutos.

---

## Test Driven Development (TDD)

### As três leis do TDD

1. Não escreva código de produção sem antes ter um teste que falha.
2. Não escreva mais de um teste do que o necessário.
3. Não escreva mais código do que o necessário para passar no teste.

### Coragem

> Por que você não corrige o código ruim quando o vê? Sua primeira reação ao ver uma função bagunçada é "Isso está uma zona, precisa ser limpo". Sua segunda reação é "Não vou colocar a mão nisso aqui!". Por quê? Porque sabe que se tocar corre o risco de quebrar, e se quebrar, a responsabilidade passa a ser sua.

Novamente, o livro ressalta a importância dos testes automatizados e como eles fazem maravilhas pelo seu código. Afinal, não há nada melhor do que mexer no código, rodar os testes e ter a certeza de que nada quebrou—desde que os testes sejam bem escritos, claro! Como bem coloca o livro, testes automatizados transformam seu código em argila, pronta para ser moldada em estruturas simples e elegantes, sem medo de desmoronar.

Além disso, o TDD traz outras vantagens, como documentação e design. Um bom teste automatizado serve como uma documentação viva: ele mostra exatamente como cada classe e função devem ser usadas, sendo muitas vezes mais útil do que longos documentos escritos que ninguém lê.

Já no quesito design, o TDD "obriga" você a escrever um código fácil de testar e, como efeito colateral positivo, esse código se torna mais legível, compreensível e fácil de manter. Escrever o teste antes do código é uma abordagem ofensiva—o teste molda o código. Escrever o teste depois é defensivo—você protege o código com testes. Ambos os estilos têm seus méritos, e saber quando usar cada um é o que separa um profissional experiente de um programador teimoso.

Por fim, vale lembrar que TDD não é uma religião nem uma fórmula mágica. Existem situações em que ele pode mais atrapalhar do que ajudar, e um desenvolvedor profissional sabe reconhecer quando é hora de abrir mão da ferramenta em prol da produtividade.

---

## Estratégias de Teste

Pulando alguns capítulos menos relevantes, aqui o livro fala sobre a famosa Pirâmide de Testes:

- **100%** do código deve ser coberto por **testes de unidade**
- **50%** do código deve ser coberto por **testes de componentes**
- **25%** do código deve ser coberto por **testes de integração**
- **10%** do código deve ser coberto por **testes de sistema**
- **5%** do código deve ser coberto por **testes exploratórios manuais**

Agora, vamos entender o que isso significa na prática.

### Testes de Unidade

Testes de unidade são os mais básicos e devem cobrir 100% do código. Eles testam pequenas partes isoladas do sistema, como funções e métodos, garantindo que cada peça individual funciona como esperado.

### Testes de Componentes

Na minha interpretação, testes de componentes verificam pequenos conjuntos do sistema funcionando juntos. Um teste de unidade pode validar uma função isolada de um _repository_, enquanto um teste de componente verificaria a integração entre o _controller_, a _model_ e o _repository_. Esses testes focam no "caminho feliz", garantindo que tudo funcione quando não há falhas. Já os cenários problemáticos devem ser cobertos pelos testes de unidade.

### Testes de Integração

Os testes de integração aumentam a escala, verificando se vários componentes conseguem trabalhar juntos. Eles são **coreografados** e não testam a lógica de negócio, mas sim se os diferentes módulos do sistema conseguem se comunicar corretamente. Um exemplo prático seria testar se um _controller_ consegue chamar corretamente um _repository_, interagir com os _models_ e ainda enviar um e-mail via uma fila de mensagens.

### Testes de Sistema

Segundo o livro, esses são os testes **end-to-end (E2E)**, que validam o funcionamento do sistema como um todo. Eles são mais demorados e custosos, pois envolvem interações reais entre os diversos serviços, bancos de dados e APIs externas.

### Testes Exploratórios Manuais

Aqui entra a parte "humana" da pirâmide. Testadores (ou desenvolvedores destemidos) exploram o sistema buscando falhas, testando _edge cases_ e tentando encontrar exceções que possam ter passado despercebidas pelos testes automatizados. Afinal, sempre existe aquele cenário bizarro que só um usuário real conseguiria descobrir.

---

## Gerenciamento de Tempo

### Discussões & Discordâncias

> "Qualquer discussão que não puder ser resolvida em cinco minutos não pode ser resolvida pela discussão."

Se uma discussão se arrasta por mais de cinco minutos, é um sinal claro de que não existem evidências concretas sustentando nenhum dos lados. Nesse caso, o debate deixou de ser técnico e virou algo quase "religioso", baseado apenas em opiniões e crenças.

Sem dados, discussões longas raramente levam a um consenso. O que fazer, então? Simples: pare de argumentar e vá atrás de mais informações. Teste, simule, faça experimentos! Em alguns casos, quando os dois lados parecem igualmente viáveis, talvez seja mais produtivo jogar uma moeda do que continuar debatendo eternamente.

Mas atenção! Se você aceitou uma decisão, entre no barco de verdade. Nada de "concordar" só para encerrar a conversa e depois ficar no modo passivo-agressivo, esperando algo dar errado para soltar um "eu já sabia que isso não ia dar certo". Se você concordou, os acertos são seus, e os erros também.

### Atoleiros, Lamaçais e Pântanos

Sabe o que é pior do que um beco sem saída? Um lamaçal. Pelo menos no beco sem saída você logo percebe que precisa dar meia-volta. No lamaçal, você vê a luz no fim do túnel e acredita que seguir em frente será mais rápido do que voltar—mas, surpresa! Não é.

Esse tipo de armadilha começa quando você percebe que tomou uma decisão errada (seja de design, estrutura, arquitetura...) e, ao invés de refazer o caminho, escolhe seguir em frente na esperança de que "vai dar tudo certo". Spoiler: não vai.

O pensamento que prende as pessoas no lamaçal é o clássico "Já investi muito tempo nisso, então é melhor continuar do que refazer do zero." Mas essa é uma ilusão perigosa. O momento certo para parar e mudar de rumo é exatamente quando você percebe que tomou a decisão errada. Insistir no erro só te afunda mais.

Pior ainda, continuar seguindo em frente não é só mentir para si mesmo—é enganar sua equipe, sua empresa e seus clientes. Você pode até dizer "Vai ficar tudo bem!", mas, no fundo, sabe que está acelerando em direção ao desastre.

O segredo para evitar lamaçais? Saber a hora de dizer: **"Chega, vamos voltar e fazer direito."**

---

## Estimativa

Empresas tratam estimativas como comprometimentos. Desenvolvedores as tratam como palpites.

Uma estimativa é uma _distribuição_, não um número mágico. Para melhorar suas previsões, o método PERT sugere calcular três estimativas:

- **Otimista (O)**: Se tudo der certo.
- **Nominal (N)**: A estimativa mais provável.
- **Pessimista (P)**: Se tudo der errado.

Fórmula da previsão:

- $\frac{O + 4N + P}{6}$

O resultado vai ser a duração da tarefa. Tendo as seguintes estimativas: O: 1, N: 3, P: 12. Teríamos (1 + 12 + 12) / 6 ou em trono de 4,2 dias.

Para sabermos a divergência padrão, podemos usar o seguinte cálculo:

- $\frac{P - O}{6}$

Quando o resultado da divergência é grande, a incerteza também é. No exemplo de antes, a divergência é de (12 -1)/6 ou por volta de 1,8 dias

---

## Pressão

Não sucumba à tentação de "codar sujo" para ser rápido. Rápido e sujo são paradoxos.

> "Você descobre no que realmente acredita quando a pressão bate. Se você abandona TDD ou código limpo na crise, nunca acreditou neles de verdade."

Se você acredita que boas práticas funcionam, siga-as especialmente quando as coisas apertam.

---

E assim encerramos. Espero que esse resumo seja útil para você (e para o eu do futuro que vai reler isso).
