---
title: Fundamentos da Arquitetura de Software
date: 2026-08-11
draft: false
---

Continuando meu flerte com arquitetura de software, dessa vez foi a vez de _Fundamentos da Arquitetura de Software: uma abordagem de engenharia_, do Mark Richards e Neal Ford. E, como sempre, esse artigo é mais para mim do que para qualquer outra pessoa.

Antes de entrar nos tópicos, vale guardar a ideia que atravessa o livro inteiro: arquitetura é sobre analisar `trade-offs`. Tudo depende, não existe bala de prata. E se você olhou para uma ferramenta e não enxergou nenhuma desvantagem nela, provavelmente ainda não a conhece bem o suficiente.

## O que se espera de um arquiteto

O livro começa listando as expectativas do papel. Isoladas, várias parecem óbvias; juntas, elas desenham um trabalho bem diferente do que normalmente se imagina.

### Tomar decisões de arquitetura

> Um arquiteto deve estabelecer as decisões da arquitetura e os princípios do design usados para orientar as decisões de tecnologia dentro da equipe, do departamento ou em toda a empresa.

A palavra-chave aqui é **orientar**. Um arquiteto não diz "vamos usar React no frontend". Ele diz "vamos usar um framework reativo no frontend" — e aí os engenheiros escolhem entre React, Vue, Angular, o que fizer mais sentido para o contexto e para o time.

Mas às vezes o arquiteto precisa sim cravar uma tecnologia específica, porque aquela escolha é o que preserva alguma característica da arquitetura (escalabilidade, desempenho, disponibilidade). Nesse caso, continua sendo uma decisão arquitetural. O critério não é o nível de detalhe da escolha, é o motivo dela.

### Analisar continuamente a arquitetura

> Um arquiteto deve analisar continuamente a arquitetura e o ambiente de tecnologia atual, para então recomendar soluções de melhorias.

O "continuamente" é a parte importante. Arquitetura não é uma entrega do começo do projeto: aquele diagrama desenhado no kickoff e nunca mais revisitado já não descreve o sistema alguns meses depois.

### Manter-se atualizado com as últimas tendências

> Um arquiteto deve ficar atualizado com as últimas tendências da tecnologia e do setor.

Atualizado no sentido de saber que as coisas existem e entender qual problema cada uma resolve. Isso é diferente de adotar tudo o que aparece.

### Assegurar a conformidade com as decisões

> Um arquiteto deve assegurar a conformidade com as decisões de arquitetura e princípios de design.

Ou seja, o arquiteto verifica continuamente se as equipes de desenvolvimento estão seguindo as decisões e os princípios definidos. Uma decisão que ninguém acompanha acaba virando só uma sugestão.

### Exposição e experiência diversificadas

> Um arquiteto deve se expor a tecnologias, estruturas, plataformas e ambientes múltiplos e diversificados.

Aqui entra o conceito de **profissional em T**: profundidade em alguma coisa, mas conhecimento em vários assuntos. Não é preciso ser o maior especialista do mundo em cinco tecnologias — é preciso conhecer cinco caminhos possíveis para o mesmo problema e saber por que escolheria cada um.

### Ter conhecimento sobre o domínio do negócio

> Um arquiteto deve ter certo nível de especialização no domínio do negócio.

Isso conversa direto com [Domain-Driven Design](https://blog.felpo.dev/posts/domain-driven-design/). O arquiteto precisa usar a **linguagem ubíqua** e conhecer bem o domínio para conversar com os stakeholders do projeto e conseguir arquitetar em cima do problema real.

### Ter habilidades interpessoais

> Um arquiteto deve ter habilidades interpessoais excepcionais, inclusive trabalho em equipe, facilitação e liderança.

E aqui a ponte é com [Como fazer amigos e influenciar pessoas](https://blog.felpo.dev/posts/como-fazer-amigos-e-influenciar-pessoas/). Mais uma vez a mesma conclusão: `soft skill` é, por vezes, mais importante que uma boa `hard skill`. Uma decisão tecnicamente correta que ninguém no time comprou dificilmente sai do papel.

### Entender e lidar bem com questões políticas

> Um arquiteto deve entender o clima político da empresa e conseguir lidar bem com ele.

As decisões de arquitetura afetam o trabalho, o escopo e as prioridades de outras pessoas, e cada uma delas tem algum poder de veto informal. Entender esse ambiente faz parte do trabalho.

## Pensamento arquitetônico

Esse foi o ponto que mais me pegou no livro: um arquiteto de software não é um engenheiro de software.

Um engenheiro normalmente se preocupa em se aprofundar nas tecnologias que já conhece, se tornando um especialista. Um arquiteto faz o movimento oposto: precisa de amplitude. Para um arquiteto, é melhor conhecer cinco ferramentas que resolvem um problema do que ser especialista em uma só — porque quando você só domina uma, a decisão já está tomada antes mesmo de o problema ser descrito.

## Características da arquitetura

O livro dá um nome diferente para os nossos velhos conhecidos "requisitos não funcionais": **características de arquitetura**. Acho um nome melhor, porque "não funcional" dá a impressão de ser a parte opcional, quando normalmente é justamente o que derruba o sistema em produção.

Uma característica de arquitetura atende a três critérios:

- Especifica uma consideração de design **fora do domínio**;
- Influencia algum **aspecto estrutural** do design;
- É **essencial ou importante** para o sucesso da aplicação.

O terceiro critério é o que mais filtra. Todo sistema poderia ser mais escalável, mais resiliente, mais observável. A pergunta não é se aquilo seria bom, e sim se é essencial para o sucesso _daquela_ aplicação.

## Decisões da arquitetura e três antipadrões

### Antipadrão da Cobertura dos Ativos

Ocorre quando o arquiteto evita ou adia tomar a decisão com medo de fazer a escolha errada.

Para mitigar, a ideia é decidir no **último momento responsável**: tarde o suficiente para ter o máximo de informação, cedo o suficiente para não atrasar ninguém.

### Antipadrão do Feitiço do Tempo

Ocorre quando as pessoas não sabem por que uma decisão foi tomada e, por isso, continuam discutindo o assunto sem parar.

A causa é simples: o arquiteto tomou a decisão e não deu a justificativa. E, ao justificar, é importante dar tanto a **justificativa técnica** quanto a **comercial**. "Fica mais desacoplado" resolve para o time técnico, mas não para quem olha o custo — enquanto "reduz o tempo de integrar um novo parceiro" fala com os dois.

### Antipadrão da Arquitetura baseada em E-mail

É quando as pessoas se perdem, esquecem ou nem sabem que uma decisão foi tomada — a decisão importante que ficou num e-mail de março, no meio de uma thread longa, na caixa de entrada de alguém que talvez nem esteja mais na empresa.

O antídoto é comunicar com eficiência: um **lugar unificado** para as ADRs (Architecture Decision Records) e um aviso rápido para quem foi afetado, com o link para a ADR. O conteúdo mora em um lugar só.

### A estrutura de uma ADR

- **Título** — descrição curta especificando a decisão;
- **Status** — proposto, aceito, substituído;
- **Contexto** — o que me faz tomar essa decisão;
- **Decisão** — a decisão e a justificativa correspondente. Aqui o mais importante é o **"o quê"** e o **"por quê"**, não o "como";
- **Consequências** — qual o impacto dessa decisão, incluindo o que se está abrindo mão;
- **Conformidade** — como assegurar a conformidade com essa decisão;
- **Notas** — metadados da decisão (autor, data, etc).

Gosto especialmente do campo de consequências, porque ele obriga quem escreve a registrar também a desvantagem da própria escolha — que é exatamente a informação que costuma se perder com o tempo.

## Tornando as equipes eficientes

Existem dois extremos aqui, e os dois atrapalham.

De um lado, o arquiteto que desenha apenas os diagramas de alto nível e espera que os desenvolvedores façam o resto. Do outro, o arquiteto controlador demais, que quer ditar como cada linha de código vai ser escrita.

Existe um _sweet spot_ no meio, e onde exatamente ele fica depende de alguns fatores:

- **Familiaridade da equipe** — mais familiaridade, menos controle;
- **Tamanho da equipe** — equipe menor, menos controle;
- **Experiência geral** — mais experiência, menos controle;
- **Complexidade do projeto** — menos complexo, menos controle;
- **Duração do projeto** — projeto menor, menos controle.

O que isso quer dizer, na prática, é que o nível de controle não é um traço de personalidade do arquiteto: é uma variável que se ajusta ao contexto. O mesmo nível de controle aplicado a um time pequeno e experiente e a um time grande recém-formado vai estar errado em pelo menos um dos casos.

## Fechando

O que ficou mais forte para mim depois da leitura é que boa parte do trabalho de arquitetura não é técnica. É decidir com informação incompleta, justificar a decisão de um jeito que o negócio também entenda, registrar isso em um lugar onde as pessoas encontrem, e calibrar o quanto é preciso acompanhar cada time.

A parte de desenhar os diagramas é só o começo.
