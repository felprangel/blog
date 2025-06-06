---
title: "SOLID Liskov Substitution Principle"
date: 2025-06-05
draft: false
---

Se você já se perguntou por que às vezes sua hierarquia de classes parece mais bagunçada que uma gaveta de cabos, talvez seja hora de conhecer Barbara Liskov e seu famoso princípio.

## A Definição Formal (Ou: Como Falar Difícil Para Impressionar)

Barbara Liskov, em 1987, definiu formalmente seu princípio da seguinte maneira:

> **Se φ(x) é uma propriedade demonstrável dos objetos x de tipo T, então φ(y) deve ser verdadeiro para objetos y de tipo S, onde S é um subtipo de T.**

Traduzindo para o português humano: se você pode trocar um objeto pai por um objeto filho sem quebrar o programa, então você está seguindo o princípio corretamente. É como dizer que todo filho deve conseguir fazer pelo menos o que o pai faz, sem birras ou surpresas desagradáveis.

## O Problema Clássico: Quadrado vs. Retângulo

Vamos ao exemplo que dá arrepios em todo programador que já tentou modelar geometria: a relação entre quadrado e retângulo.

À primeira vista, parece lógico: matematicamente, um quadrado **é** um retângulo especial (onde largura = altura). Então, por que não fazer herança?

```php
<?php

class Retangulo
{
    protected $largura;
    protected $altura;

    public function setLargura($largura)
    {
        $this->largura = $largura;
    }

    public function setAltura($altura)
    {
        $this->altura = $altura;
    }

    public function getLargura()
    {
        return $this->largura;
    }

    public function getAltura()
    {
        return $this->altura;
    }

    public function getArea()
    {
        return $this->largura * $this->altura;
    }
}

class Quadrado extends Retangulo
{
    public function setLargura($largura)
    {
        $this->largura = $largura;
        $this->altura = $largura; // Opa! Alterando os dois
    }

    public function setAltura($altura)
    {
        $this->altura = $altura;
        $this->largura = $altura; // Opa! Alterando os dois
    }
}
```

Agora vem o problema. Considere este código que funciona perfeitamente com um retângulo:

```php
function testeRetangulo(Retangulo $retangulo)
{
    $retangulo->setLargura(5);
    $retangulo->setAltura(4);

    // Esperamos área = 20
    echo "Área esperada: 20, Área real: " . $retangulo->getArea() . "\n";

    // Esperamos largura = 5
    echo "Largura esperada: 5, Largura real: " . $retangulo->getLargura() . "\n";
}

// Com retângulo funciona perfeitamente
$retangulo = new Retangulo();
testeRetangulo($retangulo); // Área: 20, Largura: 5

// Com quadrado... ops!
$quadrado = new Quadrado();
testeRetangulo($quadrado); // Área: 16, Largura: 4 😱
```

**Boom!** O princípio foi violado. O quadrado não pode ser substituído transparentemente pelo retângulo porque altera o comportamento esperado.

## Um Exemplo Mais Divertido: Patos e Suas Peculiaridades

Vamos a um exemplo mais leve. Imagine que estamos modelando patos para um sistema de fazenda virtual:

```php
<?php

abstract class Pato
{
    abstract public function nadar();
    abstract public function voar();
    abstract public function grasnar();
}

class PatoComum extends Pato
{
    public function nadar()
    {
        return "Nadando graciosamente na lagoa";
    }

    public function voar()
    {
        return "Voando baixo sobre a água";
    }

    public function grasnar()
    {
        return "Quack quack!";
    }
}

class PatoDeBorracha extends Pato
{
    public function nadar()
    {
        return "Flutuando na banheira";
    }

    public function voar()
    {
        // Problema! Pato de borracha não voa
        throw new Exception("Patos de borracha não voam, apenas em sonhos!");
    }

    public function grasnar()
    {
        return "Squeak squeak!";
    }
}
```

Agora temos um problema similar:

```php
function simularVidaDoPato(Pato $pato)
{
    echo $pato->nadar() . "\n";
    echo $pato->voar() . "\n"; // Vai quebrar com PatoDeBorracha!
    echo $pato->grasnar() . "\n";
}

$patoComum = new PatoComum();
simularVidaDoPato($patoComum); // Funciona perfeitamente

$patoBorracha = new PatoDeBorracha();
simularVidaDoPato($patoBorracha); // Exception! 💥
```

## A Solução: Repensando a Hierarquia

Para resolver esses problemas, precisamos repensar nossa hierarquia. Uma abordagem seria usar composição ou interfaces mais específicas:

```php
<?php

interface Nadador
{
    public function nadar();
}

interface Voador
{
    public function voar();
}

interface Grasnador
{
    public function grasnar();
}

class PatoComum implements Nadador, Voador, Grasnador
{
    public function nadar()
    {
        return "Nadando graciosamente na lagoa";
    }

    public function voar()
    {
        return "Voando baixo sobre a água";
    }

    public function grasnar()
    {
        return "Quack quack!";
    }
}

class PatoDeBorracha implements Nadador, Grasnador {
    public function nadar()
    {
        return "Flutuando na banheira";
    }

    public function grasnar()
    {
        return "Squeak squeak!";
    }
}

// Agora podemos ser mais específicos sobre o que esperamos
function fazerNadar(Nadador $nadador)
{
    echo $nadador->nadar() . "\n";
}

function fazerVoar(Voador $voador)
{
    echo $voador->voar() . "\n";
}
```

## Para o Problema do Quadrado e Retângulo

```php
<?php

interface Forma
{
    public function getArea();
}

class Retangulo implements Forma
{
    public function __construct(private int $largura, private int $altura)
    {}

    public function setDimensoes($largura, $altura)
    {
        $this->largura = $largura;
        $this->altura = $altura;
    }

    public function getArea()
    {
        return $this->largura * $this->altura;
    }

    public function getLargura()
    {
        return $this->largura;
    }

    public function getAltura()
    {
        return $this->altura;
    }
}

class Quadrado implements Forma
{
    public function __construct(private int $lado)
    {}

    public function setLado($lado)
    {
        $this->lado = $lado;
    }

    public function getArea()
    {
        return $this->lado * $this->lado;
    }

    public function getLado()
    {
        return $this->lado;
    }
}
```

## Conclusão: O Princípio em Ação

O Princípio de Substituição de Liskov nos ensina que herança não é apenas sobre "é um tipo de", mas sobre comportamento consistente. Antes de criar uma hierarquia, pergunte-se:

1. O objeto filho pode fazer **tudo** que o pai faz?
2. O comportamento permanece **consistente** e **previsível**?
3. Não há **surpresas** ou **exceções** inesperadas?

Se a resposta for não para qualquer uma dessas perguntas, talvez seja hora de repensar sua abordagem. Lembre-se: nem todo relacionamento do mundo real deve ser modelado com herança no código.
