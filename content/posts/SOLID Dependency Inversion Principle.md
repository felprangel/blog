---
title: "SOLID Dependency Inversion Principle"
date: 2025-06-09
draft: false
---

Você já assistiu aquelas novelas onde todo mundo depende de todo mundo e no final vira aquela bagunça épica? Pois é, seu código também pode virar isso se você não entender o **Princípio da Inversão de Dependência** (Dependency Inversion Principle - DIP), a última letra do famoso SOLID.

## O Drama Antes da Inversão

Imagine que você está desenvolvendo um sistema de notificações. Seu primeiro instinto pode ser algo assim:

```php
class EmailService
{
    public function send(string $message): void
    {
        echo "Enviando email: " . $message . "\n";
    }
}

class NotificationManager
{
    private EmailService $emailService;

    public function __construct()
    {
        $this->emailService = new EmailService(); // 🚨 Bandeira vermelha!
    }

    public function notify(string $message): void
    {
        $this->emailService->send($message);
    }
}
```

Parece inofensivo, né? Mas na verdade você acabou de criar o equivalente tecnológico de um relacionamento tóxico. Sua `NotificationManager` está **completamente** dependente da `EmailService`. Quer trocar por SMS? Vai ter de refatorar a classe.

## O Princípio que Salva Vidas (e Códigos)

O DIP nos diz duas coisas fundamentais:

1. **Módulos de alto nível não devem depender de módulos de baixo nível.** Ambos devem depender de abstrações.
2. **Abstrações não devem depender de detalhes.** Detalhes devem depender de abstrações.

Traduzindo para português humano: "Pare de casar com implementações específicas. Prefira contratos (interfaces) que podem ser cumpridos por diferentes fornecedores."

## A Redenção Através da Abstração

Vamos refatorar nosso drama mexicano:

```php
interface NotificationServiceInterface
{
    public function send(string $message): void;
}

class EmailService implements NotificationServiceInterface
{
    public function send(string $message): void
    {
        echo "📧 Enviando email: " . $message . "\n";
    }
}

class SmsService implements NotificationServiceInterface
{
    public function send(string $message): void
    {
        echo "📱 Enviando SMS: " . $message . "\n";
    }
}

class SlackService implements NotificationServiceInterface
{
    public function send(string $message): void
    {
        echo "💬 Postando no Slack: " . $message . "\n";
    }
}

class NotificationManager
{
    private NotificationServiceInterface $notificationService;

    public function __construct(NotificationServiceInterface $notificationService)
    {
        $this->notificationService = $notificationService; // ✅ Agora sim!
    }

    public function notify(string $message): void
    {
        $this->notificationService->send($message);
    }
}
```

Agora sim! Sua `NotificationManager` não sabe (nem quer saber) se está lidando com email, SMS ou pombo correio. Ela só sabe que precisa de algo que implemente `NotificationServiceInterface`.

## Usando o Código Libertado

```php
// Criando diferentes tipos de notificação
$emailNotifier = new NotificationManager(new EmailService());
$smsNotifier = new NotificationManager(new SmsService());
$slackNotifier = new NotificationManager(new SlackService());

$message = "Seu pedido foi processado!";

$emailNotifier->notify($message);  // 📧 Enviando email: Seu pedido foi processado!
$smsNotifier->notify($message);    // 📱 Enviando SMS: Seu pedido foi processado!
$slackNotifier->notify($message);  // 💬 Postando no Slack: Seu pedido foi processado!
```

## Um Exemplo Mais Realista: Sistema de Pagamento

Vamos complicar um pouquinho com um cenário mais próximo da vida real:

```php
interface PaymentGatewayInterface
{
    public function processPayment(float $amount, array $paymentData): bool;
    public function getTransactionId(): string;
}

class PayPalGateway implements PaymentGatewayInterface
{
    private string $transactionId;

    public function processPayment(float $amount, array $paymentData): bool
    {
        $this->transactionId = 'PAYPAL_' . uniqid();
        echo "💳 Processando R$ {$amount} via PayPal\n";
        return true; // Simula sucesso
    }

    public function getTransactionId(): string
    {
        return $this->transactionId;
    }
}

class StripeGateway implements PaymentGatewayInterface
{
    private string $transactionId;

    public function processPayment(float $amount, array $paymentData): bool
    {
        $this->transactionId = 'STRIPE_' . uniqid();
        echo "💰 Processando R$ {$amount} via Stripe\n";
        return true; // Simula sucesso
    }

    public function getTransactionId(): string
    {
        return $this->transactionId;
    }
}

class PaymentProcessor
{
    private PaymentGatewayInterface $gateway;

    public function __construct(PaymentGatewayInterface $gateway)
    {
        $this->gateway = $gateway;
    }

    public function processOrder(float $amount, array $customerData): array
    {
        echo "🛒 Processando pedido...\n";

        $success = $this->gateway->processPayment($amount, $customerData);

        if ($success) {
            return [
                'status' => 'approved',
                'transaction_id' => $this->gateway->getTransactionId(),
                'amount' => $amount
            ];
        }

        return ['status' => 'failed'];
    }
}

// Uso flexível
$paypalProcessor = new PaymentProcessor(new PayPalGateway());
$stripeProcessor = new PaymentProcessor(new StripeGateway());

$customerData = ['email' => 'cliente@exemplo.com'];

$result1 = $paypalProcessor->processOrder(99.90, $customerData);
$result2 = $stripeProcessor->processOrder(149.90, $customerData);

print_r($result1);
print_r($result2);
```

## Por Que Isso é Genial?

1. **Flexibilidade**: Quer trocar de PayPal para Stripe? Só mudar na injeção de dependência.
2. **Testabilidade**: Pode criar mocks das interfaces para testes unitários.
3. **Manutenibilidade**: Mudanças em uma implementação não afetam o resto do sistema.
4. **Extensibilidade**: Novo gateway? Só implementar a interface.

## A Moral da História

O Princípio da Inversão de Dependência é como ter um relacionamento maduro: você não precisa controlar cada detalhe do outro, apenas estabelecer expectativas claras (interfaces) e confiar que serão cumpridas.

Seu código fica mais flexível, seus testes ficam mais fáceis, e você dorme melhor sabendo que não vai precisar reescrever meio sistema só porque o cliente decidiu trocar de fornecedor de pagamento.

Lembre-se: **dependa de abstrações, não de implementações**. Seu futuro eu (e seus colegas de equipe) vão agradecer!
