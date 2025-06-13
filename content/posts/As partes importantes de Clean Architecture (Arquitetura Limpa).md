---
title: "As partes importantes de Clean Architecture (Arquitetura Limpa)"
date: 2025-06-10
draft: false
---

Tenho flertado com a arquitetura de software recentemente e esse livro caiu como uma luva. Como sempre, esse artigo é mais para mim do que para qualquer outra pessoa.

## Detalhes

Fazer um programa funcionar não é difícil, estudantes de ensino médio ou fundamental fazem isso sem dificuldades. Mas fazer direito? Ah, isso sim é difícil - é como a diferença entre fazer um sanduíche e ser chef de um restaurante estrelado.

O objetivo da arquitetura de software é deixar o máximo possível de opções abertas, pelo máximo de tempo possível. Quais opções precisamos deixar em aberto? Detalhes que não importam. É como manter as portas abertas numa festa: você nunca sabe quando vai precisar de uma rota de fuga.

Todo sistema de software pode ser decomposto em dois elementos principais: política e detalhes. O elemento político engloba todas as regras e procedimentos de negócios. A política é onde está o verdadeiro valor do sistema - é o coração que bombeia vida através das artérias do código.

Os detalhes são itens necessários para que os seres humanos, outros sistemas e programadores se comuniquem com a política, mas que não causam impacto algum sobre o comportamento da política (ou pelo menos não deveriam). Eles incluem dispositivos de IO, banco de dados, sistemas web, servidores, frameworks, protocolos de comunicação e assim por diante. São como as roupas que vestimos: importantes para a interação social, mas não definem quem somos por dentro.

Os detalhes devem ser irrelevantes para a política. Isso permite que as decisões para esses detalhes sejam adiadas e deferidas - uma procrastinação arquitetural produtiva, se você preferir.

Deve haver um limite entre os detalhes e a política, sendo os detalhes algo como um plugin. Por exemplo, ao instalar um plugin no VS Code, nada que a equipe de desenvolvimento do plugin faça vai afetar o desenvolvimento do VSCode, mas a equipe de desenvolvimento do VSCode pode atrapalhar o desenvolvimento do plugin se quisesse. Queremos ter um relacionamento desse tipo nos nossos sistemas. Alguns módulos devem ser imunes a outros. Não queremos que uma mudança no schema do banco de dados interfira na regra de negócio, mas o contrário pode acontecer. É uma relação unilateral, como aquela amizade onde só uma pessoa pode cancelar os planos de última hora.

## Arquitetura Gritante

Imagine olhando para a planta de um prédio. Esse documento, preparado por um arquiteto, estabelece os planos para a construção de um prédio. O que dizem esses planos?

Se esses planos forem para uma residência familiar, você provavelmente verá uma entrada frontal, uma sala e talvez uma sala de jantar. Provavelmente haverá uma cozinha a uma curta distância, perto da sala de jantar. Talvez haja uma pequena área para fazer refeições próxima à cozinha e, provavelmente, um quarto perto dela. Quando você observa esses planos, sem dúvida está vendo uma residência familiar. A arquitetura grita: "CASA".

Agora suponha que você esteja olhando a arquitetura de uma biblioteca. Você provavelmente verá uma grande entrada, uma área para empréstimo/devolução de livros, áreas de leitura, pequenas salas de conferência e uma sequência de galerias, com capacidade para reunir estantes com todos os livros da biblioteca. Essa arquitetura grita: "BIBLIOTECA".

Então, o que grita a arquitetura da sua aplicação? Quando você olha a estrutura de diretórios de nível mais alto e os arquivos-fonte no pacote de nível mais alto, eles gritam "Sistema de Saúde", "Sistema de Contabilidade" ou "Sistema de Gestão de Inventário"? Ou gritam "Rails", "Laravel" ou "ASP"? Se sua aplicação grita o nome de um framework, talvez seja hora de repensar suas prioridades arquiteturais - é como ter uma casa que grita "IKEA" em vez de "LAR".

Arquiteturas não se resumem a frameworks. Arquiteturas não devem ser estabelecidas por frameworks. Os frameworks são ferramentas à nossa disposição e não arquiteturas a que devemos nos resignar. Se a sua arquitetura é baseada em frameworks, ela não pode ser baseada em casos de uso.

Boas arquiteturas devem ser centradas em casos de uso para que os arquitetos possam descrever com segurança as estruturas que suportam esses casos de uso, sem se comprometerem com frameworks, ferramentas e ambientes. Novamente, considere os planos de uma casa. A primeira preocupação de um arquiteto é garantir que a casa seja usável e não garantir que a casa seja feita de tijolos. Afinal, ninguém quer morar numa "casa de tijolos" quando o que realmente importa é ter um lar funcional.

## Arquitetura Limpa

Independente da arquitetura escolhida, uma boa arquitetura deve produzir um sistema com as seguintes características:

- **Independente de framework** - Frameworks vêm e vão como modas; sua arquitetura deve ser mais atemporal que uma peça clássica do guarda-roupa
- **Testável** - As regras de negócio podem ser testadas sem UI, banco de dados, servidor web ou qualquer outro elemento externo
- **Independente de UI** - Uma UI web pode ser substituída por uma UI de console, por exemplo, sem alterar as regras de negócio
- **Independente de banco de dados** - MySQL hoje, PostgreSQL amanhã, quem sabe NoSQL depois de amanhã
- **Independente de qualquer fator externo** - Suas regras de negócio não sabem nada sobre as interfaces do mundo externo

Com isso em mente, Uncle Bob chegou no seguinte diagrama:
![image](/images/clean-architecture.png)

A regra primordial dessa arquitetura é a regra da dependência:

> As dependências de código-fonte devem apontar apenas para dentro, na direção das políticas de mais alto nível

Os elementos de um círculo interno não podem saber nada sobre os elementos de um círculo externo. É como uma hierarquia social bem definida, mas no mundo do código.

### Entidades

Reúnem as Regras Cruciais de Negócios (regras que geram receita ou diminuem custos, independente de sistema). Uma entidade pode ser um objeto com métodos ou um conjunto de estrutura de dados e funções. São as joias da coroa do seu sistema - protegidas no cofre mais interno da arquitetura.

### Casos de Uso

Contém as regras de negócio específicas da aplicação. Ele reúne e implementa todos os casos de uso do sistema. Esses casos de uso orquestram o fluxo de dados para e a partir das entidades e orientam essas entidades na aplicação das Regras Cruciais de Negócios a fim de atingir os objetivos do caso de uso. São como maestros de uma orquestra, coordenando as entidades para criar uma sinfonia de funcionalidades.

### Adaptadores de Interface

Essa camada consiste em um conjunto de adaptadores que convertem dados no formato que é mais conveniente para os casos de uso e entidades, para o formato mais conveniente para algum agente externo como a base de dados ou a web. É nessa camada que contém o MVC. Os presenters, views e controllers pertencem à camada de adaptadores de interface. As models provavelmente são apenas estruturas de dados transmitidas dos controllers para os casos de uso, e então, dos casos de uso para os presenters e views.

Da mesma forma, os dados dessa camada são convertidos da forma mais conveniente para entidades e casos de uso para a forma mais conveniente para o framework de persistência em uso (por exemplo, o banco de dados). Nenhum código interno desse círculo deve saber nada sobre o banco de dados. Se o banco for SQL, todo o SQL deve ser escrito nessa camada.

Também deve ter outro adaptador nessa camada para converter dados de forma externa, como uma API, para a forma interna usada pelos casos de uso e entidades. É a camada de tradução simultânea do seu sistema.

### Frameworks e Drivers

Em geral, você não programa muita coisa nessa camada além do código de associação que estabelece uma comunicação com o círculo interno seguinte. É como a recepção de um prédio: importante para fazer as conexões, mas não é onde acontece o trabalho real.

## Conclusão

A Arquitetura Limpa não é apenas mais um padrão arquitetural da moda - é uma filosofia de design que prioriza a longevidade e manutenibilidade do código sobre a conveniência imediata. Ao separar claramente as responsabilidades e manter as dependências apontando sempre para dentro, criamos sistemas que são resilientes a mudanças e adaptáveis às necessidades futuras.

Lembre-se: frameworks são como relacionamentos - alguns podem durar para sempre, mas é melhor estar preparado para mudanças. Construa seu sistema pensando no longo prazo, mantenha suas regras de negócio protegidas no núcleo da arquitetura e trate os detalhes técnicos como o que eles realmente são: detalhes substituíveis.

No final das contas, uma boa arquitetura é como uma boa piada: se você precisar explicar demais, provavelmente não está funcionando. Sua arquitetura deve ser tão clara que qualquer desenvolvedor possa olhar para ela e imediatamente entender do que se trata o sistema. Porque se após seis meses você mesmo não conseguir entender o que estava pensando quando escreveu aquele código, imagine um colega de equipe tentando decifrar seus hieróglifos arquiteturais.

Arquitetura de software é, no fim, sobre tomar decisões pensando no futuro. E como diria qualquer arquiteto que se preze: é melhor planejar duas vezes e construir uma vez, do que construir três vezes e chorar eternamente.
