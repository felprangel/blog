---
title: "SOLID Open Close Principle"
date: 2025-06-01
draft: false
---

Se você já trabalhou com código por mais de cinco minutos, provavelmente já passou pela seguinte situação: você precisa adicionar uma nova funcionalidade e, de repente, percebe que vai ter que mexer em 47 arquivos diferentes, quebrar 23 testes e rezar para três santos diferentes para que tudo continue funcionando.

Bem-vindo ao mundo maravilhoso do código que não segue o **Princípio Aberto/Fechado** (Open/Closed Principle), a segunda letra do acrônimo SOLID!

## O Que É Esse Tal de Princípio Aberto/Fechado?

O princípio é bem simples de entender:

> **"As entidades de software devem estar abertas para extensão, mas fechadas para modificação"**

Traduzindo para o português brasileiro: seu código deve ser como um jogo bem feito: você pode instalar novas expansões para adicionar mundos e personagens, sem precisar reescrever o jogo base. Você pode adicionar novas funcionalidades (extensão) sem precisar mexer no código existente (modificação).

É como construir uma casa modular: você pode adicionar novos cômodos sem derrubar as paredes que já existem.

## O Exemplo Clássico: O Pesadelo do Calculador de Áreas

Vamos começar com um exemplo que vai fazer você se identificar

### O Código Que Quebra Tudo

```php
<?php
class Rectangle {
    public $width;
    public $height;

    public function __construct(public int $width, public int $height) {
        $this->width = $width;
        $this->height = $height;
    }
}

class Circle {
    public $radius;

    public function __construct($radius) {
        $this->radius = $radius;
    }
}

class AreaCalculator {
    public function calculateArea($shape) {
        if ($shape instanceof Rectangle) {
            return $shape->width * $shape->height;
        } elseif ($shape instanceof Circle) {
            return pi() * $shape->radius * $shape->radius;
        }

        throw new InvalidArgumentException("Forma não suportada!");
    }
}

// Uso
$calculator = new AreaCalculator();
$rectangle = new Rectangle(5, 10);
$circle = new Circle(3);

echo $calculator->calculateArea($rectangle); // 50
echo $calculator->calculateArea($circle);    // ~28.27
```

Parece inofensivo, né? Mas agora imagine que seu chefe chega na segunda-feira e fala: _"Precisamos calcular a área de triângulos também!"_

Você vai ter que:

1. Criar a classe `Triangle`
2. **MODIFICAR** a classe `AreaCalculator` (violação do princípio!)
3. Adicionar mais um `elseif`
4. Torcer para não quebrar nada

E quando ele pedir hexágonos? E dodecágonos? E polígonos de 47 lados que ele viu em um sonho? Seu método vai virar uma cadeia de `if/elseif` maior que a constituição brasileira!

### O Código Que Segue o Princípio

```php
<?php
interface ShapeInterface {
    public function calculateArea(): float;
}

class Rectangle implements ShapeInterface {
    private $width;
    private $height;

    public function __construct(float $width, float $height) {
        $this->width = $width;
        $this->height = $height;
    }

    public function calculateArea(): float {
        return $this->width * $this->height;
    }
}

class Circle implements ShapeInterface {
    private $radius;

    public function __construct(float $radius) {
        $this->radius = $radius;
    }

    public function calculateArea(): float {
        return pi() * $this->radius * $this->radius;
    }
}

class Triangle implements ShapeInterface {
    private $base;
    private $height;

    public function __construct(float $base, float $height) {
        $this->base = $base;
        $this->height = $height;
    }

    public function calculateArea(): float {
        return ($this->base * $this->height) / 2;
    }
}

class AreaCalculator {
    public function calculateArea(ShapeInterface $shape): float {
        return $shape->calculateArea();
    }
}

// Uso
$calculator = new AreaCalculator();
$shapes = [
    new Rectangle(5, 10),
    new Circle(3),
    new Triangle(4, 6)
];

foreach ($shapes as $shape) {
    echo "Área: " . $calculator->calculateArea($shape) . "\n";
}

```

Viu a diferença? Agora quando seu chefe pedir para calcular a área de um dodecágono, você só precisa criar a classe `Dodecagon` implementando `ShapeInterface`. A classe `AreaCalculator` continua intacta, feliz e funcionando perfeitamente!

## Exemplo Real: Sistema de Notificações

Vamos para um exemplo mais próximo da vida real. Imagine um sistema de notificações.

### A Abordagem "Vou Quebrar Tudo" ❌

```php
<?php
class NotificationService {
    public function send($message, $type, $recipient) {
        switch ($type) {
            case 'email':
                $this->sendEmail($message, $recipient);
                break;
            case 'sms':
                $this->sendSMS($message, $recipient);
                break;
            case 'push':
                $this->sendPushNotification($message, $recipient);
                break;
            default:
                throw new InvalidArgumentException("Tipo de notificação inválido!");
        }
    }

    private function sendEmail($message, $recipient) {
        // Lógica para enviar email
        echo "Email enviado para: $recipient - $message\n";
    }

    private function sendSMS($message, $recipient) {
        // Lógica para enviar SMS
        echo "SMS enviado para: $recipient - $message\n";
    }

    private function sendPushNotification($message, $recipient) {
        // Lógica para enviar push notification
        echo "Push notification enviado para: $recipient - $message\n";
    }
}
```

Agora seu produto manager aparece e diz: _"Precisamos integrar com WhatsApp, Telegram, Slack e Discord!"_

### A Abordagem "Minha Sanidade Mental Agradece" ✅

```php
<?php
interface NotificationInterface {
    public function send(string $message, string $recipient): bool;
}

class EmailNotification implements NotificationInterface {
    public function send(string $message, string $recipient): bool {
        // Lógica específica para email
        echo "📧 Email enviado para: $recipient - $message\n";
        return true;
    }
}

class SMSNotification implements NotificationInterface {
    public function send(string $message, string $recipient): bool {
        // Lógica específica para SMS
        echo "📱 SMS enviado para: $recipient - $message\n";
        return true;
    }
}

class WhatsAppNotification implements NotificationInterface {
    public function send(string $message, string $recipient): bool {
        // Lógica específica para WhatsApp
        echo "💬 WhatsApp enviado para: $recipient - $message\n";
        return true;
    }
}

class SlackNotification implements NotificationInterface {
    public function send(string $message, string $recipient): bool {
        // Lógica específica para Slack
        echo "💼 Slack enviado para: $recipient - $message\n";
        return true;
    }
}

class NotificationService {
    private $notifications = [];

    public function addNotificationMethod(NotificationInterface $notification) {
        $this->notifications[] = $notification;
    }

    public function sendToAll(string $message, string $recipient) {
        foreach ($this->notifications as $notification) {
            $notification->send($message, $recipient);
        }
    }

    public function send(NotificationInterface $notification, string $message, string $recipient) {
        return $notification->send($message, $recipient);
    }
}

// Uso
$notificationService = new NotificationService();

// Configurando os métodos de notificação
$notificationService->addNotificationMethod(new EmailNotification());
$notificationService->addNotificationMethod(new SMSNotification());
$notificationService->addNotificationMethod(new WhatsAppNotification());

// Enviando notificação
$notificationService->sendToAll("Seu pedido foi confirmado!", "usuario@exemplo.com");

// Ou enviando por um canal específico
$notificationService->send(new SlackNotification(), "Deploy realizado com sucesso!", "#dev-team");
```

Agora quando precisar adicionar Discord, Telegram, pombo-correio ou sinais de fumaça, você só cria uma nova classe. O `NotificationService` nem pisca!

## Por Que Isso É Tão Importante?

### 1. **Manutenibilidade**:

Você não quebra código existente quando adiciona funcionalidades novas. É como adicionar um novo sabor de pizza no cardápio sem precisar reformar a cozinha inteira.

### 2. **Testabilidade**:

Cada classe tem sua responsabilidade específica. Testar fica muito mais fácil.

### 3. **Reutilização**:

Suas classes ficam modulares. Pode usar `EmailNotification` em qualquer lugar sem carregar toda a bagagem do sistema.

### 4. **Escalabilidade**:

Adicionar novas funcionalidades vira uma operação segura. Seu coração não vai mais acelerar a cada deploy.

## Dicas Práticas Para Não Pirar

### 1. **Use Interfaces e Classes Abstratas**

Elas são seus melhores amigos para definir contratos que suas classes devem seguir.

### 2. **Pense em Strategies (O design pattern)**

Quando você vê um `switch/case` ou uma cadeia de `if/elseif` gigante, geralmente é sinal de que está violando o princípio.

### 3. **Dependency Injection é amigo**

Injete dependências ao invés de criar instâncias dentro das classes. Isso facilita a extensão.

### 4. **Não Exagere na Abstração**

Não tente prever todos os cenários futuros. Refatore quando a necessidade real aparecer. YAGNI (You Ain't Gonna Need It) é real!

## Conclusão: Seu Futuro Eu Vai Te Agradecer

O Princípio Aberto/Fechado pode parecer trabalhoso no início, mas é um investimento na sua sanidade mental futura. É a diferença entre ser aquele desenvolvedor que adiciona funcionalidades com confiança e aquele que precisa de três cafés e uma reza antes de cada commit.

Lembre-se: código bem estruturado é como um bom relacionamento - você pode crescer juntos sem precisar mudar completamente quem vocês são.

E quando seu chefe vier com mais uma "pequena mudança", você vai poder sorrir e dizer: _"Sem problemas, só vou criar uma nova classe!"_

Agora pare de ler e vá refatorar aquele `switch` gigante que você sabe que está lá te julgando! 😄
