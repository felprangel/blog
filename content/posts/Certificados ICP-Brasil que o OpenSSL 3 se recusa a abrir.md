---
title: "Certificados ICP-Brasil que o OpenSSL 3 se recusa a abrir"
date: 2026-08-12
---

Faz um tempo que mantenho um projeto pessoal chamado cert-manager: um gerenciador de certificados digitais ICP-Brasil, escrito em PHP com Laravel. A ideia é simples — o usuário faz upload do `.p12` (ou `.pfx`, que é o mesmo formato com outro nome), o sistema abre o arquivo, extrai os dados do certificado, valida se o documento no CN bate com o do dono e guarda tudo com controle de acesso por agência.

A parte de "abrir o arquivo" deveria ser a mais chata e a mais previsível. Não foi.

## O sintoma

O código inicial era o mais direto possível:

```php
$certificates = [];

if (! openssl_pkcs12_read(file_get_contents($path), $certificates, $password)) {
    throw new InvalidCertificateException('Não foi possível ler o certificado.');
}
```

Funcionava perfeitamente com os certificados que eu mesmo tinha gerado para teste. E falhava com os certificados reais que eu usei depois como fixture. Todos eles.

O pior é que `openssl_pkcs12_read()` só retorna `false`. Sem exceção, sem mensagem, sem pista. A senha estava certa, o arquivo não estava corrompido, e o mesmo `.p12` abria normalmente no gerenciador de certificados do Windows.

## Achando a mensagem de erro real

O PHP não joga o erro do OpenSSL fora — ele empilha numa fila que você precisa consumir explicitamente:

```php
while (($message = openssl_error_string()) !== false) {
    logger()->debug($message);
}
```

E aí apareceu o que eu precisava:

```
error:0308010C:digital envelope routines::unsupported
```

Rodando pelo terminal, a mensagem é mais generosa e entrega o nome do algoritmo:

```
$ openssl pkcs12 -info -in certificado.p12
Error outputting keys and certificates
40770ADF7F000000:error:0308010C:digital envelope routines:inner_evp_generic_fetch:
unsupported:crypto/evp/evp_fetch.c:349:Global default library context,
Algorithm (RC2-40-CBC : 0), Properties ()
```

`RC2-40-CBC`. Esse é o ponto.

## Por que isso acontece

O OpenSSL 3.0 reorganizou a biblioteca em _providers_: módulos que fornecem implementações de algoritmos. O provider `default` traz o que é considerado seguro hoje. Os algoritmos antigos — RC2, RC4, DES simples, MD2, entre outros — foram movidos para o provider `legacy`, que **não é carregado por padrão**.

Não é que o OpenSSL tenha perdido o código. É que ele decidiu, deliberadamente, não expor esses algoritmos a menos que você peça.

O problema é que o formato PKCS#12 é antigo, e por muito tempo a combinação padrão para gerar esses arquivos foi:

- **certificado**: `pbeWithSHA1And40BitRC2-CBC`
- **chave privada**: `pbeWithSHA1And3-KeyTripleDES-CBC`
- **MAC**: SHA-1

Repare que só um dos três é problema. O 3DES da chave privada continua no provider default, e o SHA-1 do MAC também. Quem trava tudo é o RC2 de 40 bits que protege o _bag_ do certificado. O OpenSSL 3 abre o arquivo, chega nesse bag, tenta buscar `RC2-40-CBC`, não encontra em nenhum provider ativo e desiste — antes mesmo de chegar na chave, que ele saberia ler.

Aqui é onde eu errei no diagnóstico inicial, e vale registrar. O OpenSSL 3, quando **gera** um `.p12`, usa AES-256-CBC com PBKDF2 — nada de RC2. Então eu assumi que o problema era de arquivos velhos e que ia se resolver sozinho: certificado A1 vale um ano, a base se renova, o assunto morre.

Não é o que acontece. Quem gera o arquivo não é você nem o OpenSSL da sua máquina — é a Autoridade Certificadora, com a ferramenta dela. E as ACs da ICP-Brasil continuam emitindo com a combinação antiga. Um certificado emitido esta semana chega com o mesmo `pbeWithSHA1And40BitRC2-CBC` de um emitido em 2019.

Ou seja: isso não é dívida técnica esperando expirar. É o formato corrente. Enquanto as ACs não mudarem a geração, qualquer aplicação que leia certificado ICP-Brasil em OpenSSL 3 vai esbarrar nisso — hoje e no próximo ano.

Se quiser conferir qual algoritmo um arquivo específico usa:

```bash
openssl pkcs12 -info -in certificado.p12 -noout
```

As linhas com `pbe` na saída entregam o jogo.

## Por que o PHP não resolve isso sozinho

No terminal, a solução é uma flag:

```bash
openssl pkcs12 -legacy -in certificado.p12 -info
```

O `-legacy` carrega o provider legacy junto com o default, e o arquivo abre normalmente.

A extensão OpenSSL do PHP, porém, não tem equivalente. Ela opera sempre no contexto global padrão da biblioteca e não expõe nenhuma forma de ativar um provider por chamada. Não existe flag em `openssl_pkcs12_read()`, e não existe função para carregar provider em runtime.

Sobraram três caminhos.

### Opção 1: recusar arquivos nesse formato

Se fosse um resíduo de certificados antigos, seria defensável — pedir ao usuário que reemitisse resolveria. Mas como o formato antigo é o que as ACs emitem hoje, recusar significa recusar essencialmente todos os certificados ICP-Brasil. Para um gerenciador de certificados ICP-Brasil, isso é o mesmo que não ter o projeto.

### Opção 2: cair para o binário do `openssl` quando o nativo falhar

Tentar a função nativa e, se ela falhar, chamar o CLI com `-legacy` e fazer o parse do PEM de saída. Funciona. Eu cheguei a implementar. E é a opção que eu mais recomendo evitar, por três motivos que não são óbvios de cara:

O primeiro é a senha. A versão natural é esta:

```php
$command = sprintf(
    'openssl pkcs12 -legacy -in %s -passin pass:%s -nodes',
    escapeshellarg($path),
    escapeshellarg($password),
);
```

`escapeshellarg()` protege contra injeção de comando, e isso é necessário. Mas ele não resolve o outro problema: **argumentos de linha de comando são visíveis para qualquer processo na máquina**. Um `ps aux` no momento certo mostra a senha do certificado em texto puro. Escapar argumento resolve injeção, não confidencialidade — são problemas diferentes, e é fácil confundir os dois quando a função tem "escape" no nome. Dá para contornar com `proc_open()` e a senha pelo stdin, mas repare que você já está escrevendo bem mais código do que imaginava.

O segundo é o arquivo temporário. `openssl_pkcs12_read()` recebe o conteúdo em memória; o CLI precisa de um caminho. Então você grava o `.p12` em disco, e agora tem que garantir que ele suma mesmo quando algo explodir no meio.

O terceiro só aparece depois: com o provider ativo globalmente, esse caminho vira código morto no fluxo normal, e o único momento em que ele roda é quando a leitura nativa falha de verdade — senha errada, arquivo corrompido. Ou seja, ele deixa de ser o atalho para os casos difíceis e passa a ser um processo externo criado só para falhar de novo, mais devagar e com uma mensagem pior.

### Opção 3: ativar o provider legacy globalmente

Foi a que eu escolhi. Um arquivo de configuração do OpenSSL que ativa os dois providers:

```ini
openssl_conf = openssl_init

[openssl_init]
providers = provider_sect

[provider_sect]
default = default_sect
legacy = legacy_sect

[default_sect]
activate = 1

[legacy_sect]
activate = 1
```

E, no Dockerfile, o arquivo copiado para dentro da imagem e apontado pela variável de ambiente que o OpenSSL lê na inicialização:

```dockerfile
COPY docker/openssl.cnf /etc/ssl/openssl-legacy.cnf
ENV OPENSSL_CONF=/etc/ssl/openssl-legacy.cnf
```

Só isso. `openssl_pkcs12_read()` volta a abrir os arquivos das ACs e você não escreve uma linha a mais de PHP.

O custo real é de escopo: essa decisão vale para o processo inteiro. Todo o resto da aplicação passa a ter RC2, RC4 e DES disponíveis. Você trocou uma decisão local — _este upload específico precisa de um algoritmo velho_ — por uma global: _esta aplicação inteira aceita algoritmos velhos_.

No meu caso isso é aceitável, e vale explicar por quê em vez de só afirmar. O container roda uma aplicação só, que não negocia TLS com terceiros e não escolhe cifra em lugar nenhum: a única coisa que toca o OpenSSL é a leitura do `.p12`. Ter RC2 disponível ali não abre superfície nova — não existe caminho no código em que um atacante consiga _escolher_ usar RC2 para alguma coisa. Se a aplicação fosse um proxy, ou tivesse configuração de TLS exposta, a conta seria outra.

O custo que eu subestimei é outro, e é o assunto da próxima seção.

## A configuração falha em silêncio

O `OPENSSL_CONF` aponta para um arquivo. Se esse arquivo não existir, ou não for legível, ou tiver a seção errada, o OpenSSL **não reclama**. Ele volta para a configuração padrão e segue a vida. Sua aplicação sobe normalmente, responde normalmente, e só quebra quando alguém tenta subir um certificado — que pode ser uma semana depois do deploy.

Comparado com a Opção 2, é uma inversão desconfortável: o fallback pro CLI é feio, mas é explícito e mora no código, ao lado da chamada que ele resolve. A ativação global é limpa e some. Quem lê a action não vê nada explicando por que aquilo funciona, e um `git blame` no arquivo errado não ajuda.

Tem ainda uma variante mais sutil. A primeira versão do meu `openssl.cnf` era esta:

```ini
.include = /etc/ssl/openssl.cnf

[provider_sect]
default = default_sect
legacy = legacy_sect
...
```

Ela funciona — desde que o `openssl.cnf` do sistema já traga `openssl_conf = openssl_init` e a seção `[openssl_init]` com `providers = provider_sect`. Se a imagem base mudar, ou se você trocar de distro, essas duas linhas podem simplesmente não estar lá. Aí as suas seções viram texto morto: sintaticamente válidas, nunca referenciadas, nenhum aviso. Por isso a versão que está no post acima é autocontida e não depende de nada do arquivo do sistema.

## Distinguir "senha errada" de "algoritmo antigo"

Esse detalhe é fácil de deixar passar. `openssl_pkcs12_read()` retorna `false` nos dois casos, mas a fila de erros diferencia:

- algoritmo indisponível: `error:0308010C:digital envelope routines::unsupported`
- senha errada: `error:11800071:PKCS12 routines::mac verify failure`

Com o provider ativo, o primeiro erro nunca deveria aparecer. Se ele aparecer, o diagnóstico não é sobre o arquivo que o usuário mandou — é sobre o ambiente estar mal configurado. São duas mensagens diferentes, para duas pessoas diferentes: uma para o usuário, outra para você.

```php
$messages = [];

while (($message = openssl_error_string()) !== false) {
    $messages[] = $message;
}
```

Note que o `while` precisa consumir a fila inteira, mesmo depois de encontrar o que procura. Erro que fica na fila do OpenSSL aparece na próxima chamada, em outro lugar, e vira um bug muito chato de rastrear. Pelo mesmo motivo, resista à tentação de silenciar a chamada com `@`: você está jogando fora exatamente o diagnóstico que vai precisar.

## Como testar que o provider está mesmo ativo

Aqui está a parte que eu levei mais tempo para acertar, e é a que eu mais recomendo copiar.

O teste óbvio — subir uma fixture `.p12` legacy pela rota de upload e verificar que deu certo — não serve como garantia. Se o seu código tiver qualquer fallback pro CLI, ele passa mesmo com o provider desativado. Pior: a flag `-legacy` do binário carrega o provider por conta própria, então um teste que shell-a para o `openssl` passa **sempre**, independente da configuração da imagem. Ele testa o binário, não a sua aplicação.

O teste que vale é o que verifica o estado da biblioteca, direto do processo PHP:

```php
it('carrega o provider legacy do OpenSSL', function () {
    $ciphers = array_map('strtolower', openssl_get_cipher_methods());

    expect($ciphers)->toContain('rc2-40-cbc');
});
```

Se essa asserção falhar, o `OPENSSL_CONF` não está valendo — e você descobre no CI, não no suporte. Para o container de teste enxergar a mesma configuração da produção, a variável precisa estar lá também:

```yaml
services:
  test:
    environment:
      OPENSSL_CONF: /etc/ssl/openssl-legacy.cnf
```

E, para gerar uma fixture com a mesma combinação de PBE que as ACs usam, sem precisar de um certificado real no repositório:

```bash
openssl pkcs12 -export -legacy \
    -inkey key.pem -in cert.pem -out legacy.p12 \
    -passout pass:senha123 \
    -certpbe pbeWithSHA1And40BitRC2-CBC \
    -keypbe pbeWithSHA1And3-KeyTripleDES-CBC \
    -macalg sha1
```

## O que eu tiraria disso

Três coisas ficaram comigo.

A primeira é que `false` é um péssimo valor de retorno para uma operação com dez motivos distintos de falha, e a fila de erros do OpenSSL existe justamente por isso. Consumir `openssl_error_string()` deveria ser reflexo, não último recurso.

A segunda é que "o OpenSSL removeu o algoritmo" quase nunca é verdade — ele foi movido, e a decisão de reativá-lo é sua. O que muda é o escopo: no arquivo de configuração a decisão vale para a aplicação inteira; via CLI com `-legacy`, vale só para aquela chamada. Nenhuma das duas é errada. Errado é escolher sem perceber que escolheu.

A terceira é a que eu não esperava: configuração que falha em silêncio é pior que configuração que falha. Uma solução de duas linhas no Dockerfile parece barata até você perceber que não existe nada, em lugar nenhum do código, que quebre se essas duas linhas sumirem. A única defesa é um teste que verifique o _estado_ — o provider está carregado? — em vez do resultado. Resultado, o fallback disfarça.
