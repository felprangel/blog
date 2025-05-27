---
title: SOLID Single Responsability Principle
date: 2025-05-26
draft: false
---

De todos os princípios SOLID, o SRP provavelmente é o mais conhecido e o menos compreendido. Isso se deve principalmente ao seu nome inadequado. Ao escutar esse nome, logo pensamos que os módulos devem fazer apenas uma coisa.

## O Que É Esse Tal de SRP?

O SRP diz basicamente: "Um módulo deve ter uma, e apenas uma, razão para mudar".

Em termos mais técnicos e menos zen, o princípio diz que uma classe deve ter apenas uma responsabilidade, ou seja, apenas um motivo para mudar. Parece simples, né? Spoiler alert: não é.

## O Problema: A Classe Canivete Suíço

Imagine que você está no escritório e encontra esta belezinha no código:

```php
<?php
class Funcionario {
    private $nome;
    private $salario;

    public function calcularSalario() {
        // 50 linhas de lógica complexa aqui
    }

    public function salvarNoBanco() {
        // Conexão com banco, SQL, transactions...
    }

    public function enviarEmail() {
        // SMTP, templates, validações...
    }

    public function gerarRelatorio() {
        // PDF, formatação, headers...
    }

    public function validarCPF() {
        // Algoritmo de validação de CPF
    }
}
?>
```

Esta classe `Funcionario` está fazendo mais coisas que um estagiário no primeiro dia: calculando salário, salvando no banco, enviando email, gerando relatório E validando CPF. É o Batman do código, mas sem a parte legal de ser herói.

## Por Que Isso É Um Problema?

### 1. O Pesadelo dos Múltiplos Motivos Para Mudar

Nossa classe `Funcionario` tem pelo menos 5 motivos diferentes para ser alterada:

- **Mudança nas regras de cálculo salarial** → mexe na classe
- **Troca do banco de dados** → mexe na classe
- **Novo template de email** → mexe na classe
- **Mudança no formato do relatório** → mexe na classe
- **Nova validação de CPF** → mexe na classe

Quando a regra de negócio exige mudança no cálculo do vale-refeição, você acaba mexendo em código que envia email, e de repente os relatórios param de funcionar.

### 2. Teste Vira Pesadelo

Tentar testar essa classe é como tentar usar óculos de grau emprestado: tecnicamente funciona, mas você sai com dor de cabeça. Você quer testar apenas o cálculo de salário, mas precisa mockar banco de dados, servidor de email e impressora PDF. É mais setup que o Arch Linux.

### 3. Reutilização? Esquece!

Quer usar só a validação de CPF em outro lugar? Paciência, meu amigo, você vai ter que carregar toda a bagagem da classe `Funcionario` nas costas, como quem viaja de ônibus com mala de rodinha quebrada.

## A Solução: Separar Para Conquistar

Vamos aplicar o SRP e transformar nossa classe Frankenstein em algo mais civilizado:

```php
<?php
// Apenas dados do funcionário
class Funcionario {
    public function __construct(
        private readonly string $nome,
        private readonly int $salario,
    ) {}
}

// Especialista em cálculos
class CalculadoraSalario {
    public function calcular(Funcionario $funcionario) {
        // Lógica de cálculo aqui
    }
}

// Especialista em persistência
class RepositorioFuncionario {
    public function salvar(Funcionario $funcionario) {
        // Lógica de banco aqui
        // PDO, Eloquent, ou o que preferir
    }
}

// Especialista em comunicação
class ServicoEmail {
    public function enviar($destinatario, $assunto, $corpo) {
        // Lógica de email aqui
        // PHPMailer, SwiftMailer, etc.
    }
}

// Especialista em relatórios
class GeradorRelatorio {
    public function gerar(array $funcionarios) {
        // Lógica de relatório aqui
        // TCPDF, DomPDF, etc.
    }
}

// Especialista em validação
class ValidadorCPF {
    public function validar($cpf) {
        // Lógica de validação aqui
    }
}
?>
```

Agora sim! Cada classe tem sua especialidade, como um time de super-heróis onde cada um tem seu poder específico, ao invés de um Homem-Aranha que também é médico, advogado e professor de culinária.

## Os Benefícios de Seguir o SRP

### 1. Manutenção Mais Fácil

Precisa alterar como o salário é calculado? Vai direto na `CalculadoraSalario`. Precisa mudar o template do email? `ServicoEmail` te espera. É como ter uma caixa de ferramentas organizada, ao invés de uma gaveta bagunçada.

### 2. Testes Mais Simples

Testar a `CalculadoraSalario` agora é moleza: passa um `Funcionario`, chama o método, verifica o resultado. Sem mock de banco, sem configuração de SMTP, sem dor de cabeça.

### 3. Reutilização Real

O `ValidadorCPF` pode ser usado em qualquer lugar que precise validar CPF: cadastro de clientes, fornecedores, ou até no seu projeto paralelo da loja de açaí.

### 4. Entendimento Mais Rápido

Quando alguém novo chega no time e precisa entender o código, é muito mais fácil explicar: "Essa classe calcula salário, essa salva no banco, essa envia email..." do que "Essa classe faz... bem... tudo."

## Cuidado Com os Exageros

Como tudo na vida, o SRP pode ser levado ao extremo. Não é para criar uma classe para cada linha de código:

```php
<?php
// Isso aqui é exagero, galera
class SomadorDeUm {
    public function somar($numero) {
        return $numero + 1;
    }
}
?>
```

O segredo é encontrar o equilíbrio. Pense no SRP como uma dieta: o objetivo é ser saudável, não passar fome.

## Sinais de Que Você Está Violando o SRP

- Sua classe tem mais métodos públicos que um canivete suíço tem ferramentas
- Você usa "E" frequentemente ao explicar o que a classe faz: "Ela calcula salário E envia email E gera relatório E..."
- Suas classes têm nomes genéricos demais: `Manager`, `Handler`, `Utils`, `Helper` (especialmente se elas fazem mais que gerenciar, manusear, ou ajudar)
- Quando você precisa alterar um requisito simples, acaba mexendo em 15 métodos diferentes da mesma classe

## Conclusão

O Princípio da Responsabilidade Única não é sobre criar milhões de classes minúsculas, mas sobre criar código que faça sentido, seja fácil de manter e não dê vontade de chorar toda vez que você precisa fazer uma alteração.

Lembre-se: código bom é como uma boa piada - se você precisa explicar muito, provavelmente não está tão bom assim. E se sua classe precisa de um manual de instruções para ser entendida, talvez seja hora de aplicar um pouco de SRP na sua vida.
