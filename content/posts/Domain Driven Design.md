---
title: Domain Driven Design
date: 2026-03-10
draft: false
---

Recentemente mergulhei na leitura sobre **Domain-Driven Design (DDD)**. Vou ser sincero: não é um livro fácil de se escrever sobre. Grande parte do conteúdo foca em detalhes minuciosos de implementação, mas o verdadeiro "pulo do gato" está nos conceitos estratégicos.

Para facilitar a jornada, reuni aqui os temas centrais que considero o coração do DDD.

## Linguagem Ubíqua: Falando a mesma língua

Imagine o caos se o desenvolvedor fala "UserStatus" e o dono do negócio fala "Situação do Cliente". No DDD, isso é proibido. O projeto deve ter uma **linguagem única**. Se uma regra de negócio usa um termo, o código deve usar o exato mesmo termo. Isso elimina a "tradução" mental e aproxima quem entende do problema de quem constrói a solução.

## Entidades vs. Objetos de Valor

Essa distinção é fundamental para modelar bem o seu domínio:

- **Entidades:** Têm uma **identidade única**. Pense em nós, seres humanos: mudamos de corte de cabelo, de peso ou de endereço (mudamos nossos valores), mas continuamos sendo a mesma "entidade". O que nos define é quem somos, não apenas os nossos dados atuais.
- **Objetos de Valor (Value Objects):** Aqui, o que importa é apenas o **valor**. Se você tem duas notas de 10 reais, não importa qual é qual; o que importa é o valor "10". Se o valor mudar, o objeto é outro.

## Serviços

Às vezes, uma operação ou transformação não se encaixa naturalmente dentro de uma Entidade ou de um Objeto de Valor. Quando isso acontece, criamos um **Serviço**.

> O nome dessa operação deve obrigatoriamente fazer parte daquela _Linguagem Ubíqua_ que combinamos lá no início.

## Factories

Direto do mundo dos Design Patterns: se a criação de um objeto (Entidade ou VO) for muito complexa, use uma **Factory**. Ela encapsula a lógica de "como montar o objeto" para que o restante do sistema não precise conhecer os detalhes da fabricação.

## Repositories

O **Repository** é o guardião entre o seu domínio e o banco de dados.

- Ele gerencia a persistência e a consulta.
- Sua missão é impedir que o domínio saiba se você usa MySQL, MongoDB ou uma planilha de Excel.
- **Atenção:** Repositórios não devem controlar transações (isso é papel do cliente) e, embora possam usar Factories para instanciar objetos, sua função principal é o acesso aos dados.

## Contextos Delimitados (Bounded Contexts)

É a camada que separa diferentes partes do sistema. É importante notar: **Contextos Delimitados não são módulos**. Eles podem ser implementados como módulos, mas sua função principal é definir a fronteira de onde um modelo de domínio se aplica e onde outro começa.

## Subdomínios Genéricos

Nem tudo no seu software é o "coração" do negócio. Existem partes de apoio que são genéricas (como um sistema de envio de e-mail ou log). Esses subdomínios devem ter **menor prioridade de desenvolvimento** do que o seu domínio principal. Foque energia onde o valor realmente está!

## Declaração da Visão do Domínio

Por fim, nada disso funciona sem um norte. Tenha um documento (breve e claro) que mostre a **proposição de valor**. O que esse domínio resolve? Qual o objetivo principal? Sem essa visão, o código é apenas código.

## Domínio Principal (Core Domain): Onde o dinheiro está

Se os _Subdomínios Genéricos_ têm menos prioridade, o **Core Domain** é o rei.

- É aqui que está o diferencial da sua empresa.
- **O erro clássico:** Gastar meses refinando um sistema de login (Genérico) e deixar a regra de cálculo de lucro (Core) para a última hora. No DDD, o foco total de design deve estar no que faz o negócio ser único.
