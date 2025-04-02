---
title: Guia básico de NGINX
date: 2025-03-31
draft: false
---

Hoje vou fazer um dump de tudo que sei de NGINX, mostrando que não é difícil dar manutenção nos arquivos de configuração do seu servidor.

Depois de ler esse post você vai poder:

- Entender os arquivos de configuração do NGINX
- Configurar o NGINX como um servidor web
- Configurar o NGINX como um proxy reverso
- Configurar o NGINX como um load balancer

# Índice

- [Introdução ao NGINX](#introdução-ao-nginx)
- [Como instalar o NGINX](#como-instalar-o-nginx)
- [Introdução às configurações do NGINX](#introdução-às-configurações-do-nginx)
- [Como configurar um servidor web básico](#como-configurar-um-servidor-web-básico)
  - [Escrevendo seu primeiro arquivo de configuração](#escrevendo-seu-primeiro-arquivo-de-configuração)
  - [Como validar e recarregar os arquivos de configuração](#como-validar-e-recarregar-os-arquivos-de-configuração)
  - [Como entender as diretivas e contextos no NGINX](#como-entender-as-diretivas-e-contextos-no-nginx)
  - [Como servir conteúdo estático usando NGINX](#como-servir-conteúdo-estático-usando-nginx)
  - [Lidando com tipos de arquivo estático no NGINX](#lidando-com-tipos-de-arquivo-estático-no-nginx)
  - [Como incluir arquivos de configuração parciais](#como-incluir-arquivos-de-configuração-parciais)
- [Roteamento dinâmico no NGINX](#roteamento-dinâmico-no-nginx)
  - [Correspondência de localização](#correspondência-de-localização)
  - [Variáveis no NGINX](#variáveis-no-nginx)
  - [Redirecionamentos e reescritas](#redirecionamentos-e-reescritas)
  - [Como tentar múltiplos arquivos](#como-tentar-múltiplos-arquivos)
- [Logs no NGINX](#logs-no-nginx)
- [Como usar o NGINX como um proxy reverso](#como-usar-o-nginx-como-um-proxy-reverso)
  - [Node com NGINX](#node-com-nginx)
- [Como usar o NGINX como um load balancer](#como-usar-o-nginx-como-um-load-balancer)
- [Como configurar processos worker e conexões worker](#como-configurar-processos-worker-e-conexões-worker)

## Introdução ao NGINX

Apesar de ser mais conhecido como um servidor web, o NGINX é basicamente um servidor de [proxy reverso](https://pt.wikipedia.org/wiki/Proxy_reverso).

Quando uma request buscando conteúdo estático chega, o NGINX simplesmente responde com o arquivo, sem rodar nenhum processo adicional.
Isso não significa que o NGINX não consegue lidar com requests que precisam de um processamento por uma linguagem de programação dinâmica. Nesses casos, o NGINX simplesmente delega a tarefa para processos separados como o [PHP-FPM](https://www.php.net/manual/en/install.fpm.php), [Node.js](https://nodejs.org/pt) ou [Python](https://www.python.org/). Então, quando o processo termina, o NGINX faz a proxy de resposta de volta pra o cliente.

## Como instalar o NGINX

Em sistemas baseados em Debian/Ubuntu normalmente é apenas rodar:

```sh
sudo apt install nginx
```

Em caso de problemas você pode consultar a [documentação oficial](https://nginx.org/en/linux_packages.html)

Após a instalação, o NGINX deve estar registrado como um serviço do `systemd`. Para checar, execute o seguinte comando:

```sh
sudo systemctl status nginx
```

Se o serviço estiver rodando, você está pronto para começar. Caso contrário você pode iniciar o serviço com o seguinte comando:

```sh
sudo systemctl start nginx
```

Por último, para um verificação visual de que tudo está rodando e funcionando como deveria, abra o `localhost` no seu navegador e você deve conseguir ver a tela inicial do NGINX

![image](/images/Pasted%20image%2020250214230141.png)

NGINX normalmente é instalado no diretório `/etc/nginx` e a maioria do nosso trabalho nas seções que estão por vir vão ser feitas aqui.

Parabéns! Agora você tem um NGINX rodando na sua máquina. Agora é hora de pular de cabeça no NGINX.

## Introdução as configurações do NGINX

Como um servidor web, o trabalho do NGINX é servir conteúdo estático aos clientes. Mas como esse conteúdo vai ser servido é normalmente controlado por arquivos de configuração.

Os arquivos de configuração do NGINX acabam com a extensão `.conf` e normalmente estão dentro da pasta `/etc/nginx`. Vamos começar entrando nesse diretório e listando todos os arquivos:

```sh
cd /etc/nginx

ls -lh

# drwxr-xr-x 1 root root 4.0K Feb 24 23:48 conf.d
# -rw-r--r-- 1 root root 1007 Feb  5 11:06 fastcgi_params
# -rw-r--r-- 1 root root 5.3K Feb  5 11:06 mime.types
# lrwxrwxrwx 1 root root   22 Feb  5 14:26 modules -> /usr/lib/nginx/modules
# -rw-r--r-- 1 root root  648 Feb  5 14:26 nginx.conf
# -rw-r--r-- 1 root root  636 Feb  5 11:06 scgi_params
# -rw-r--r-- 1 root root  664 Feb  5 11:06 uwsgi_params
```

Entre esses arquivos, deve ter um chamado _nginx.conf_. Esse é o arquivo de configuração principal do NGINX. Você pode dar uma olhada no conteúdo do arquivo com o `cat`:

```sh
cat nginx.conf

# user  nginx;
# worker_processes  auto;

# error_log  /var/log/nginx/error.log notice;
# pid        /var/run/nginx.pid;


# events {
#     worker_connections  1024;
# }


# http {
#     include       /etc/nginx/mime.types;
#     default_type  application/octet-stream;

#     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                       '$status $body_bytes_sent "$http_referer" '
#                       '"$http_user_agent" "$http_x_forwarded_for"';

#     access_log  /var/log/nginx/access.log  main;

#     sendfile        on;
#     #tcp_nopush     on;

#     keepalive_timeout  65;

#     #gzip  on;

#     include /etc/nginx/conf.d/*.conf;
# }
```

Tentar entender esse arquivo nesse estado é um pesadelo. Vamos renomeá-lo e criar um novo arquivo vazio:

```sh
# renomeia o arquivo
sudo mv nginx.conf nginx.conf.backup

# cria um novo arquivo
sudo touch nginx.conf
```

_Não é recomendado_ editar o arquivo `nginx.conf` original a não ser que você saiba exatamente o que você está fazendo. Para fins educativos, estamos renomeando, mas depois, você vai ver como deveria configurar um servidor em um caso real.

## Como configurar um servidor web básico

Nessa seção, vamos colocar a mão na masse e configurar um simples servidor web estático. O intuito dessa seção é introduzir você para a sintaxe fundamental dos conceitos dos arquivos de configuração do NGINX.

### Escrevendo seu primeiro arquivo de configuração

Comece abrindo seu recém criado `nginx.conf` usando seu editor de texto favorito, pra esse exemplo, vou usar o nano:

```sh
sudo nano /etc/nginx/nginx.conf
```

Depois de abrir o arquivo, atualize seu conteúdo para que fique dessa forma:

```conf
events {
}

http {
    server {
        listen 80;
        server_name nginx.test;

        return 200 "Hello World!\n";
    }
}
```

Se você tem experiência na construção de API REST você deve ter deduzido da linha com `return 200 ""Hello World!\n";` que o servidor foi configurado para responder com status code de 200 e a mensagem "Hello World!"

Não se preocupe se você não entendeu nada além disso nesse momento. Eu vou explicar esse arquivo linha a linha, mas primeiro, vamos ver essa configuração em ação.

### Como validar e recarregar os arquivos de configuração

Depois de escrever um novo arquivo de configuração ou atualizar um antigo, a primeira coisa a se fazer é checar se existe algum erro de sintaxe no arquivo. O binário do `nginx` inclui a opção `-t` que faz exatamente isso

```sh
sudo nginx -t

# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Se exite algum erro de sintaxe, o comando vai te alertar sobre ele, incluindo o número da linha.

Apesar do arquivo de configuração estar certo, o NGINX não vai usá-lo. Do jeito que o NGINX funciona ele lê o arquivo de configuração uma vez e continua rodando baseado nessa primeira leitura.

Se você atualizar o arquivo de configuração, então você precisa instruir o NGINX explicitamente para recarregar o arquivo de configuração.
Existem duas formas de fazer isso:

- Você pode reiniciar o serviço do NGINX executando o comando `sudo systemctl restart nginx`
- Você pode mandar um sinal de `reload` para o NGINX executando o comando `sudo nginx -s reload`

O `-s` é usado para enviar vários sinais para o NGINX. O sinais disponíveis são `stop`, `quit`, `reload`, e `reopen`. Entre os dois jeitos de atualizar o arquivo, eu prefiro o segundo, simplesmente por que é menos coisas para digitar.

uma ver que você tenha recarregado o arquivo de configuração rodando o comando `nginx -s reload`, você pode ver isso em ação fazendo uma request get para o servidor:

```sh
curl -i http://nginx.test

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Mon, 24 Feb 2025 23:56:44 GMT
# Content-Type: text/plain
# Content-Length: 13
# Connection: keep-alive

# Hello World!
```

O servidor está respondendo com um status code de 200 e a mensagem esperada. Parabéns por chegar tão longe! Agora é hora de algumas explicações.

### Como entender as diretivas e contextos no NGINX

As poucas linhas de código que você escreveu até agora, apesar de parecerem simples, introduzem duas das mais importantes terminologias dos arquivos de configuração do NGINX. Elas são _diretivas_ e _contextos_.

Tecnicamente, tudo dentro de um arquivo de configuração do NGINX é uma _diretiva_. Diretivas são de dois tipos:

- Diretivas simples
- Diretivas de bloco

Uma diretiva simples consiste do nome da diretiva e os parâmetros delimitados por espaços, como `listen`, `return` e outros.
Diretivas simples são terminadas por ponto e vírgula.

Diretivas de bloco são similares das diretivas simples, mas ao invés de terminar com ponto e vírgula, eles terminam com um par de chaves `{}` fechando instruções adicionais.

Uma diretiva de bloco capaz de conter outras diretivas dentro é chamada de contexto, que são os `events`, `http` e por aí vai.
Existem quatro contextos principais no NGINX:

- `events {}` - O contexto de `events` é usado para definir a configuração global de como o NGINX vai lidar com as requests de um modo geral. Só pode existir um contexto de `events` em um arquivo de configuração válido.
- `http {}` - Evidente pelo nome, o contexto de `http` é usado para definir a configuração de como o servidor vai lidar com requests HTTP e HTTPS, especificamente. Só pode existir um contexto `http` em um arquivo de configuração válido.
- `server {}` - O contexto de `server` é aninhado dentro do contexto de `http` e usado para configurar servidores virtuais específicos em apenas um host. Podem existir vários contexto de `server` dentro de um contexto de `http`. Cada contexto de `server` é considerado um host virtual.
- `main` - O contexto `main` é o próprio arquivo de configuração. Qualquer coisa escrita fora dos três contextos mencionados anteriormente está no contexto `main`.

Você pode considerar contextos do NGINX como escopos em outras linguagens de programação. Existe também uma certa forma de herança entre eles. Você pode encontrar um [índice de diretivas em ordem alfabética](https://nginx.org/en/docs/dirindex.html) na documentação oficial.

Eu mencionei que podem existir múltiplos contextos de `server` no arquivo de configuração. Mas quando a request chega no servidor, como o NGINX sabe qual dos contextos deve lidar com a request?

A diretiva de `listen` é um dos jeitos de identificar o contexto `server` correto na configuração. Considere o seguinte cenário:

```conf
events {
}

http {
    server {
        listen 80;
        server_name nginx.test;

        return 200 "resposta da porta 80!\n";
    }


    server {
        listen 8080;
        server_name nginx.test;

        return 200 "resposta da porta 8080!\n";
    }
}
```

Agora se você mandar uma request para `http://nginx.test:80` você vai receber "resposta da porta 80!" como resposta. E se você mandar uma request para `http://nginx.test:8080` você vai receber "resposta da porta 8080!" como uma resposta:

```sh
curl nginx.test:80

# resposta da porta 80!

curl nginx.test:8080

# resposta da porta 8080!
```

Esses dois blocos de `server` são como duas pessoas com um telefone fixo, esperando para responder quando uma requisição chega nos seu número. Seus números são indicados pelas diretivas `listen`.

Fora a diretiva `listen`, existe também a diretiva `server_name`. Considere o seguinte cenário de uma aplicação imaginária de administração de uma biblioteca:

```conf
events {
}

http {
    server {
        listen 80;
        server_name biblioteca.test;

        return 200 "sua biblioteca local!\n";
    }


    server {
        listen 80;
        server_name bibliotecario.biblioteca.test;

        return 200 "bem vindo bibliotecário!\n";
    }
}
```

Esse é um exemplo básico de um host virtual. Você está rodando duas aplicações separadas em diferentes `server_name` no mesmo servidor.

Se você mandar a request para `http://biblioteca.test` você vai receber a resposta "sua biblioteca local!". Se você mandar uma request para `http://bibliotecario.biblioteca.test` você vai receber "bem vindo bibliotecário!" como resposta.

```sh
curl http://biblioteca.test

# sua biblioteca local!

curl http://bibliotecario.biblioteca.test

# bem vindo bibliotecário!
```

Para fazer isso funcionar, você deve atualizar seu arquivo `hosts` para incluir esses dois domínios:

```
192.168.0.100 biblioteca.test
192.168.0.100 bibliotecario.biblioteca.test
```

Finalmente, a diretiva `return` é responsável por retornar uma resposta válida para o usuário. Essa diretiva recebe dois parâmetros: o status code e a string da mensagem para ser retornada.

### Como servir conteúdo estático usando NGINX

Agora que você tem um bom entendimento de como escrever um arquivo de configuração básico para o NGINX, vamos melhorar a configuração para servir arquivos estáticos ao invés de respostas de texto

Para servir conteúdo estático, primeiro você deve armazená-lo em algum lugar no seu servidor. Se você listar os arquivos e diretórios na raiz do seu servidor usando `ls`, você vai achar um diretório chamado `/srv`:

```sh
ls -lh /

# lrwxrwxrwx   1 root root    7 Feb  3 00:00 bin -> usr/bin
# drwxr-xr-x   2 root root 4.0K Dec 31 10:25 boot
# drwxr-xr-x   5 root root  340 Feb 24 23:48 dev
# drwxr-xr-x   1 root root 4.0K Feb  6 00:26 docker-entrypoint.d
# -rwxr-xr-x   1 root root 1.6K Feb  6 00:26 docker-entrypoint.sh
# drwxr-xr-x   1 root root 4.0K Feb 24 23:55 etc
# drwxr-xr-x   2 root root 4.0K Dec 31 10:25 home
# lrwxrwxrwx   1 root root    7 Feb  3 00:00 lib -> usr/lib
# lrwxrwxrwx   1 root root    9 Feb  3 00:00 lib64 -> usr/lib64
# drwxr-xr-x   2 root root 4.0K Feb  3 00:00 media
# drwxr-xr-x   2 root root 4.0K Feb  3 00:00 mnt
# drwxr-xr-x   2 root root 4.0K Feb  3 00:00 opt
# dr-xr-xr-x 297 root root    0 Feb 24 23:48 proc
# drwx------   1 root root 4.0K Feb 25 00:00 root
# drwxr-xr-x   1 root root 4.0K Feb 24 23:48 run
# lrwxrwxrwx   1 root root    8 Feb  3 00:00 sbin -> usr/sbin
# drwxr-xr-x   2 root root 4.0K Feb  3 00:00 srv
# dr-xr-xr-x  13 root root    0 Feb 24 23:48 sys
# drwxrwxrwt   1 root root 4.0K Feb 24 23:55 tmp
# drwxr-xr-x   1 root root 4.0K Feb  3 00:00 usr
# drwxr-xr-x   1 root root 4.0K Feb  3 00:00 var
```

Esse diretório `/srv` serve para armazenar conteúdo que deve ser servido pelo sistema. Agora vamos entrar nesse diretório e clonar o código do repositório desse tutorial:

```sh
cd /srv

git clone https://github.com/felprangel/exemplos-nginx.git
```

Dentro do diretório `exemplos-nginx` deve ter um diretório chamado `static-demo` contendo quatro arquivos no total:

```sh
ls -lh /srv/exemplos-nginx/static-demo

# -rw-r--r-- 1 root root 878 Feb 25 00:44 index.html
# -rw-r--r-- 1 root root 46K Feb 25 00:44 mini.min.css
# -rw-r--r-- 1 root root 50K Feb 25 00:44 nginx.jpg
# -rw-r--r-- 1 root root 884 Feb 25 00:44 sobre.html
```

Agora que você tem o conteúdo estático para ser servido, atualize sua configuração como a seguinte:

```conf
events {
}

http {
    server {
        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;
    }
}
```

O código é quase o mesmo, mas a diretiva `return` foi substituída pela diretiva `root`. Essa diretiva é usada para declarar o diretório raiz de um site.

Escrevendo `root /srv/exemplos-nginx/static-demo;` você está dizendo para o NGINX para procurar por arquivos para servir dentro do diretório `/srv/exemplos-nginx/static-demo` se qualquer request chegar no servidor. Como o NGINX é um servidor web, ele é inteligente o suficiente para servir o arquivo `index.html` por padrão.

Vamos ver se isso funciona. Teste e recarregue o arquivo de configuração atualizado e visite o servidor. Você deve ser recebido por um arquivo HTML quebrado:

![image](/images/Pasted%20image%2020250216172339.png)

Apesar do NGINX servir o arquivo `index.html` corretamente, julgando pela aparência dos 3 links de navegação, parece que o código CSS não está funcionando.

Você pode pensar que deve ter algo errado com o arquivo CSS. Mas na verdade, o problema está no arquivo de configuração.

### Lidando com tipo de arquivo estático no NGINX

Para debugar esse problema, envie uma request para o arquivo CSS no servidor:

```sh
curl -I http://nginx.test/mini.min.css

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Tue, 25 Feb 2025 00:47:08 GMT
# Content-Type: text/plain
# Content-Length: 46887
# Last-Modified: Tue, 25 Feb 2025 00:44:34 GMT
# Connection: keep-alive
# ETag: "67bd1272-b727"
# Accept-Ranges: bytes
```

Preste atenção no `Content-Type` e veja como ele diz `text/plain` e não `text/css`. Isso significa que o NGINX está servindo esse arquivo como um texto plano ao invés de uma folha de estilos.

Apesar do NGINX ser esperto o suficiente para encontrar o arquivo `index.html` por padrão, ele pode ser bem bobinho quando o assunto é interpretar tipos de arquivos. Para resolver esse problema, atualize seu arquivo de configuração mais uma vez:

```conf
events {
}

http {
    types {
        text/html html;
        text/css css;
    }

    server {
        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;
    }
}
```

A única mudança que fizemos no código é adicionar um novo contexto de `types` dentro do contexto de `http`. Como você deve ter adivinhado pelo nome, o contexto é usado para configurar os tipos.

Escrevendo `text/html html` nesse contexto você está dizendo ao NGINX interpretar como `text/html` qualquer arquivo que termina com a extensão `html`

Você pode pensar que só configurar o tipo de arquivo CSS deve ser o suficiente, já que o HTML está sendo interpretado normalmente, mas não.

Se você adicionar um contexto `types` na configuração, o NGINX fica ainda mais bobo e só interpreta os arquivos configurados por você. Então se você só definir o `text/css css` nesse contexto, o NGINX vai interpretar o arquivo html apenas como texto plano.

Valide e recarregue a nova configuração e visite o servidor novamente. Envie uma request para o arquivo CSS mais uma vez, e dessa vez o arquivo deve ser interpretado como um arquivo _text/css_

```sh
curl -I http://nginx.test/mini.min.css

# Server: nginx/1.27.4
# Date: Tue, 25 Feb 2025 00:48:15 GMT
# Content-Type: text/css
# Content-Length: 46887
# Last-Modified: Tue, 25 Feb 2025 00:44:34 GMT
# Connection: keep-alive
# ETag: "67bd1272-b727"
# Accept-Ranges: bytes
```

Visite o servidor para uma verificação visual, e o site deve estar mais agradável aos olhos dessa vez:

![image](/images/Pasted%20image%2020250216175258.png)

### Como incluir arquivos de configuração parciais

Mapear os tipos de arquivo com o contexto `types` pode funcionar para projetos pequenos, mas para projetos grandes vira um pesadelo.

O NGINX provê uma solução para esse problema. Se você listar os arquivos dentro do diretório `/etc/nginx` novamente, você vai ver um arquivo chamado `mime.types`.

Vamos ver o conteúdo desse arquivo:

```shell
cat /etc/mime.types

# types {
#     text/html                             html htm shtml;
#     text/css                              css;
#     text/xml                              xml;
#     image/gif                             gif;
#     image/jpeg                            jpeg jpg;
#     application/javascript                js;
#     application/atom+xml                  atom;
#     application/rss+xml                   rss;

#     text/mathml                           mml;
#     text/plain                            txt;
#     text/vnd.sun.j2me.app-descriptor      jad;
#     text/vnd.wap.wml                      wml;
#     text/x-component                      htc;

#     image/png                             png;
#     image/tiff                            tif tiff;
#     image/vnd.wap.wbmp                    wbmp;
#     image/x-icon                          ico;
#     image/x-jng                           jng;
#     image/x-ms-bmp                        bmp;
#     image/svg+xml                         svg svgz;
#     image/webp                            webp;

#     application/font-woff                 woff;
#     application/java-archive              jar war ear;
#     application/json                      json;
#     application/mac-binhex40              hqx;
#     application/msword                    doc;
#     application/pdf                       pdf;
#     application/postscript                ps eps ai;
#     application/rtf                       rtf;
#     application/vnd.apple.mpegurl         m3u8;
#     application/vnd.ms-excel              xls;
#     application/vnd.ms-fontobject         eot;
#     application/vnd.ms-powerpoint         ppt;
#     application/vnd.wap.wmlc              wmlc;
#     application/vnd.google-earth.kml+xml  kml;
#     application/vnd.google-earth.kmz      kmz;
#     application/x-7z-compressed           7z;
#     application/x-cocoa                   cco;
#     application/x-java-archive-diff       jardiff;
#     application/x-java-jnlp-file          jnlp;
#     application/x-makeself                run;
#     application/x-perl                    pl pm;
#     application/x-pilot                   prc pdb;
#     application/x-rar-compressed          rar;
#     application/x-redhat-package-manager  rpm;
#     application/x-sea                     sea;
#     application/x-shockwave-flash         swf;
#     application/x-stuffit                 sit;
#     application/x-tcl                     tcl tk;
#     application/x-x509-ca-cert            der pem crt;
#     application/x-xpinstall               xpi;
#     application/xhtml+xml                 xhtml;
#     application/xspf+xml                  xspf;
#     application/zip                       zip;

#     application/octet-stream              bin exe dll;
#     application/octet-stream              deb;
#     application/octet-stream              dmg;
#     application/octet-stream              iso img;
#     application/octet-stream              msi msp msm;

#     application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
#     application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
#     application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

#     audio/midi                            mid midi kar;
#     audio/mpeg                            mp3;
#     audio/ogg                             ogg;
#     audio/x-m4a                           m4a;
#     audio/x-realaudio                     ra;

#     video/3gpp                            3gpp 3gp;
#     video/mp2t                            ts;
#     video/mp4                             mp4;
#     video/mpeg                            mpeg mpg;
#     video/quicktime                       mov;
#     video/webm                            webm;
#     video/x-flv                           flv;
#     video/x-m4v                           m4v;
#     video/x-mng                           mng;
#     video/x-ms-asf                        asx asf;
#     video/x-ms-wmv                        wmv;
#     video/x-msvideo                       avi;
# }
```

O arquivo contém uma longa lista de tipos de arquivo e suas extensões. Para usar esse arquivo dentro do seu arquivo de configuração, atualize sua configuração como a seguinte:

```conf
events {
}

http {

    include /etc/nginx/mime.types;

    server {
        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;
    }
}
```

O antigo contexto `types` agora foi substituído pela nova diretiva `include`. Como o nome sugere, essa diretiva permite que o conteúdo de um arquivo seja incluso em outro.

Valide e recarregue o arquivo de configuração e mande uma request para o arquivo `mini.min.css` novamente:

```sh
curl -I http://nginx.test/mini.min.css

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Tue, 25 Feb 2025 00:56:40 GMT
# Content-Type: text/css
# Content-Length: 46887
# Last-Modified: Tue, 25 Feb 2025 00:44:34 GMT
# Connection: keep-alive
# ETag: "67bd1272-b727"
# Accept-Ranges: bytes
```

## Roteamento dinâmico no NGINX

O arquivo de configuração que você escreveu na seção passada foi uma configuração muito simples de um servidor de conteúdo estático. Tudo que ele fazia era buscar o arquivo correspondente a URL que o cliente visita e retornar uma resposta.

Então se o usuário buscar por arquivos na raiz como `index.html`, `sobre.html` ou `mini.min.css` NGINX vai retornar o arquivo. Mas se você buscar uma rota como http://nginx.test/nada, ele vai responder com a página de 404 padrão:

![image](/images/Pasted%20image%2020250219225145.png)

Nessa seção do post, você vai aprender sobre o contexto `location`, variáveis, redirecionamentos, reescritas e a diretiva `try_files`. Vão ter novos projetos nessa seção, mas os conceitos que você vai aprender aqui vão ser necessários nas seções seguintes

O arquivo de configuração vai mudar bastante nessa seção, então não esqueça de validar e recarregar o arquivo de configuração a cada atualização.

### Correspondência de localização

O primeiro conceito que vamos discutir nessa seção é o contexto `location`. Atualize sua configuração como a seguinte:

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        location /machado {
            return 200 "Bentinho.\nCapitolina.\n";
        }
    }
}
```

Nós substituímos a diretiva `root` com o novo contexto `location`. Esse contexto normalmente fica dentro de blocos de `server`. Podem existir múltiplos contextos `location` dentro de um contexto `server`.

Se você enviar uma request para http://nginx.test/machado, você vai receber uma resposta 200 e uma lista de personagens do Machado de Assis.

```sh
curl -i http://nginx.test/machado

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Tue, 25 Feb 2025 02:07:58 GMT
# Content-Type: text/plain
# Content-Length: 22
# Connection: keep-alive

# Bentinho.
# Capitolina.
```

Se você mandar uma request para http://nginx.test/machado-assis, você vai receber a mesma resposta:

```sh
curl -i http://nginx.test/machado-assis

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Tue, 25 Feb 2025 02:08:38 GMT
# Content-Type: text/plain
# Content-Length: 22
# Connection: keep-alive

# Bentinho.
# Capitolina.
```

Isso acontece porque, escrevendo `location /machado`, você está dizendo para o NGINX para corresponder qualquer URI que comece com "machado". Esse tipo de correspondência é chamado de _correspondência por prefixo_ ou _prefix match_

Para performar uma _correspondência exata_, você pode atualizar o código pelo seguinte:

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        location = /machado {
            return 200 "Bentinho.\nCapitolina.\n";
        }
    }
}
```

Adicionando uma sinal de igual `=` antes da URI vai instruir o NGINX para responder apenas a URL que tenha a correspondência exata. Agora se você mandar uma request para qualquer coisa que não seja `/machado`, você vai ter uma resposta 404.

Outro tipo de correspondência no NGINX é a _correspondência por regex_. Usando esse tipo de correspondência você pode checar a URL com expressões regulares.

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        location ~ /machado[0-9] {
            return 200 "Bentinho.\nCapitolina.\n";
        }
    }
}
```

Substituindo o antigo `=` por um `~`, você está dizendo ao NGINX para fazer uma correspondência por expressão regular. Fazendo essa config significar que o NGINX só vai responder se tiver um número depois da palavra "machado"

Uma correspondência por regex é case sensitive por padrão, o que significa que se você tornar uma letra maiúscula, o `location` não vai funcionar

Para tornar isso em case insensitive, você precisa adicionar um `*` depois do `~`.

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        location ~* /machado[0-9] {
            return 200 "Bentinho.\nCapitolina.\n";
        }
    }
}
```

O NGINX coloca prioridades nessas correspondências, e uma correspondência por regex tem mais prioridade do que uma correspondência por prefixo.

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        location /Machado8 {
            return 200 "correspondencia por prefixo.\n";
        }

        location ~* /machado[0-9] {
            return 200 "correspondencia por regex.\n";
        }
    }

}
```

Ao enviar uma request para http://nginx.test/Machado8, você vai receber a seguinte resposta:

```sh
curl -i http://nginx.test/Machado8

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Tue, 25 Feb 2025 02:09:45 GMT
# Content-Type: text/plain
# Content-Length: 27
# Connection: keep-alive

# correspondencia por regex.
```

Mas essa prioridade pode ser alterada. A maior prioridade de correspondência no NGINX é uma _correspondência por prefixo preferencial_. Para tornar uma correspondência por prefixo em um preferencial, você precisa adicionar o modificador `^~` antes da URI de localização:

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        location ^~ /Machado8 {
            return 200 "correspondencia por prefixo.\n";
        }

        location ~* /machado[0-9] {
            return 200 "correspondencia por regex.\n";
        }
    }

}
```

Agora se você mandar uma request para http://nginx.test/Machado8, você vai ter a seguinte resposta:

```sh
curl -i http://nginx.test/Machado8

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Wed, 26 Feb 2025 01:09:12 GMT
# Content-Type: text/plain
# Content-Length: 29
# Connection: keep-alive

# correspondencia por prefixo.
```

Dessa vez, a correspondência por prefixo ganhou. Então a lista de correspondências tem a seguinte ordem de prioridade:

| Correspondência      | Modificador |
| -------------------- | ----------- |
| Exata                | `=`         |
| Prefixo preferencial | `^~`        |
| REGEX                | `~` ou `~*` |
| Prefixo              | `Nenhum`    |

### Variáveis no NGINX

Variáveis no NGINX são semelhantes a variáveis em outras linguagens de programação. A diretiva `set` pode ser usada para declarar novas variáveis em qualquer lugar no arquivo de configuração:

```conf
set $<nome_da_variavel> <valor_da_variavel>;

# set nome "Felipe"
# set idade 20
# set esta_trabalhando true
```

Variáveis podem ser de três tipos:

- String
- Inteiro
- Booleano

Fora as variáveis que você declara, existem variáveis embutidas nos módulos do NGINX. Um [índice em ordem alfabética dessas variáveis](https://nginx.org/en/docs/varindex.html) está disponível na documentação oficial.

Para ver as variáveis em ação, atualize a configuração como a seguinte:

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        return 200 "Host - $host\nURI - $uri\nArgs - $args\n";
    }

}
```

Fazendo uma request para o servidor, você deve receber uma resposta como a seguinte:

```sh
curl -i 'http://nginx.test/teste?parametro=valor'
# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Wed, 26 Feb 2025 01:19:20 GMT
# Content-Type: text/plain
# Content-Length: 54
# Connection: keep-alive

# Host - nginx.test
# URI - /teste
# Args - parametro=valor
```

Como você pode ver, as variáveis `$host` e `$uri` tem o valor do endereço base acessado e a URI relativa ao endereço base, respectivamente. A variável `$args`, como pode ver, contém todos os query params.

Ao invés de printar a string literal dos query params, você pode acessar os valores individuais usando a variável `$arg`.

```conf
events {

}

http {

    server {

        listen 80;
        server_name nginx.test;

        set $nome $arg_nome; # $arg_<query param nome>

        return 200 "Nome - $nome\n";
    }

}
```

Agora a resposta do servidor vai ser como o seguinte:

```sh
curl -i 'http://nginx.test?nome=felipe'

Nome - felipe
```

### Redirecionamentos e Reescritas

Um redirecionamento no NGINX é o mesmo de redirecionar em qualquer outra plataforma. Para demonstrar como os redirecionamentos funcionam, atualize sua configuração para ser algo como o seguinte:

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;

        location = /pagina_index {
                return 307 /index.html;
        }

        location = /pagina_sobre {
                return 307 /sobre.html;
        }
    }
}
```

Agora se você mandar uma request para http://nginx.test/pagina_sobre, você vai ser redirecionado para http://nginx.test/sobre.html:

```sh
curl -I http://nginx.test/pagina_sobre

# HTTP/1.1 307 Temporary Redirect
# Server: nginx/1.27.4
# Date: Sun, 02 Mar 2025 00:22:15 GMT
# Content-Type: text/html
# Content-Length: 171
# Location: http://nginx.test/sobre.html
# Connection: keep-alive
```

Como pode ver, o servidor respondeu com um status code de 307 e o `location` indica a url http://nginx.test/sobre.html. Se você visitar http://nginx.test/pagina_sobre, você vai ver que a URL vai automaticamente mudar para http://nginx.test/sobre.html.

Uma diretiva `rewrite`, no entanto, funciona um pouco diferente. Ela muda a URI internamente, sem deixar o usuário saber. Para vê-lo em ação, atualize sua configuração como o seguinte:

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;

        rewrite /pagina_index /index.html;

        rewrite /pagina_sobre /sobre.html;
    }
}
```

Agora se você mandar uma request para http://nginx.test/pagina_sobre, você vai ter uma resposta 200 e o código HTML para a página sobre.html na resposta:

```sh
curl -i http://nginx.test/pagina_sobre

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Sun, 02 Mar 2025 00:41:29 GMT
# Content-Type: text/html
# Content-Length: 884
# Last-Modified: Tue, 25 Feb 2025 00:44:34 GMT
# Connection: keep-alive
# ETag: "67bd1272-374"
# Accept-Ranges: bytes

# <!DOCTYPE html>
# <html lang="pt-br">
# <head>
    # <meta charset="UTF-8">
    # <meta http-equiv="X-UA-Compatible" content="IE=edge">
    # <meta name="viewport" content="width=device-width, initial-scale=1.0">
    # <title>Exemplo site estático</title>
    # <link rel="stylesheet" href="mini.min.css">
    # <style>
        # .container {
            # max-width: 1024px;
            # margin-left: auto;
            # margin-right: auto;
        # }
#
        # h1 {
            # text-align: center;
        # }
    # </style>
# </head>
# <body class="container">
    # <header>
        # <a class="button" href="index.html">Index</a>
        # <a class="button" href="sobre.html">Sobre</a>
        # <a class="button" href="nada">Nada</a>
    # </header>
    # <img src="./nginx.jpg" alt="Logo do NGINX">
    # <div class="card fluid">
        # <h1>esse é o arquivo de <strong>sobre.html</strong></h1>
    # </div>
# </body>
# </html>
```

Agora se você visitar essa URI no browser, você vai ver a página sobre.html enquanto a URI não é alterada

Fora a parte de como se lida com a mudança de URI, tem outra diferença entre o redirecionamento e a reescrita. Quando uma reescrita acontece, o contexto `server` é recalculada pelo NGINX. Então uma reescrita é mais pesada do que um redirecionamento.

### Como tentar por múltiplos arquivos

O conceito final que vou mostrar nessa seção é a diretiva `try_files`. Ao invés de responder com um único arquivo, a diretiva `try_files` permite você checar a existência de múltiplos arquivos.

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;

        try_files /nginx.jpg /nao_encontrado;

        location /nao_encontrado {
                return 404 "Infelizmente não encontramos o que você pediu!\n";
        }
    }
}
```

Como pode ver, uma nova diretiva `try_files` foi adicionada. Adicionando `try_files /nginx.jpg /nao_encontrado;` você está instruindo o NGINX para procurar por um arquivo chamado nginx.jpg na raiz sempre que uma request chegar. Se não existir, vá para a URI `/not_found`.

O problema em escrever uma diretiva `try_files` dessa forma é que não importa qual URL você visite, contanto que a request seja recebida pelo servidor e a imagem nginx.jpg for encontrada no disco, NGINX vai retornarná-la.

E é por isso que `try_files` é comumente utilizada com a variável `$uri`

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;

        try_files $uri /nao_encontrado;

        location /nao_encontrado {
                return 404 "Infelizmente não encontramos o que você pediu!\n";
        }
    }
}
```

Escrevendo `try_files $uri /nao_encontrado;` você está instruindo o NGINX para tentar pela URI requisitada pelo cliente primeiro. Se ele não encontrar o primeiro, ele vai tentar o próximo.

Agora se você visitar http://nginx.test/index.html você deve receber a página index.html normalmente. O mesmo valo para a página sobre.html mas se você requisitar um arquivo que não existe, você via receber a resposta da rota `/not_found`

Uma coisa que talvez você já tenha percebido é que se você visitar a raiz do servidot http://nginx.test você vai receber a resposta 404.

Isso acontece porque quando você está requisitando pela raiz do servidor, a variável `$uri` não corresponde a nenhum arquivo existente então o NGINX serve a URI de fallback. Se você quer consertar esse problema, atualize sua configuração como o seguinte:

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        root /srv/exemplos-nginx/static-demo;

        try_files $uri $uri/ /nao_encontrado;

        location /nao_encontrado {
                return 404 "Infelizmente não encontramos o que você pediu!\n";
        }
    }
}
```

Ao escrever `try_files $uri $uri/ /nao_encontrado;` você está instruindo o NGINX para tentar pela URI requisitada primeiro. Se isso não funcionar então tentar a URI requisitada como um diretório, e quando o NGINX procurar por um diretório ele automaticamente começa a procurar por um arquivo index.html.

O `try_files` é o tipo de diretiva que pode ser usada em um número de variações. Nas próximas seções você vai encontrar outras variações mas eu sugiro que você faça alguma pesquisa na internet sobre os diferentes usos da diretiva.

## Logs no NGINX

Por padrão, os arquivos de log do NGINX são localizados dentro da pasta `/var/log/nginx`. Se você listar o conteúdo deste diretório, você via ver algo como o seguinte:

```sh
ls -lh /var/log/nginx/

# lrwxrwxrwx 1 root root 11 Feb  6 00:26 access.log -> /dev/stdout
# lrwxrwxrwx 1 root root 11 Feb  6 00:26 error.log -> /dev/stderr
```

Vamos começar limpando os dois arquivos

```sh
# deleta os arquivos antigos
sudo rm /var/log/nginx/access.log /var/log/nginx/error.log

# criar os novos arquivos
sudo touch /var/log/nginx/access.log /var/log/nginx/error.log

# reabrir os arquivos de log
sudo nginx -s reopen
```

Se você não disparar um sinal de `reopen` pro NGINX, ele vai continuar escrevendo logs para as stream de logs antigas e os novos arquivos vão continuar vazios.

Agora para fazer uma entrada no access log, mande uma request para o servidor.

```sh
curl -I http://nginx.test

# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Mon, 03 Mar 2025 21:29:35 GMT
# Content-Type: text/html
# Content-Length: 878
# Last-Modified: Tue, 25 Feb 2025 00:44:34 GMT
# Connection: keep-alive
# ETag: "67bd1272-36e"
# Accept-Ranges: bytes

sudo cat /var/log/nginx/access.log

# 192.168.100.86 - - [03/Mar/2025:21:29:35 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.12.1"
```

Como pode ver, uma nova entrada foi adicionada no arquivo `access.log`. Qualquer request para o servidor vai ser logado nesse arquivo por padrão. Mas podemos mudar isso usando a diretiva `access_log`.

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        location / {
            return 200 "Isso vai ser logado no arquivo padrão.\n";
        }

        location = /admin {
            access_log /var/logs/nginx/admin.log;

            return 200 "Isso vai ser logado em um arquivo separado.\n";
        }

        location = /sem_log {
            access_log off;

            return 200 "Isso não vai ser logado.\n";
        }
    }
}
```

O primeiro `access_log` dentro do bloco `location` /admin instrui o NGINX para escrever qualquer access log dessa URI para o arquivo `/var/logs/nginx/admin.log`. O segundo dentro do `location` /sem_log desliga o access_log para essa `location` completamente.

Valide e recarregue a configuração. Agora se você enviar requests para essas URIs e inspecionar os arquivos de log, eles vão estar de acordo com o que foi configurado.

O arquivo `error.log`, por outro lado, armazena os logs de falha. Para fazer uma entrada no `error.log`, você terá que fazer o NGINX crashar. Para fazê-lo, atualize sua configuração como a seguinte:

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        return 200 "..." "...";
    }

}
```

Como você sabe, a diretiva `return` só recebe dois parâmetros, mas aqui nós passamos três. Tente recarregar a configuração e você deve ser apresentado com uma mensagem de erro:

```sh
sudo nginx -s reload

# nginx: [emerg] invalid number of arguments in "return" directive in /etc/nginx/nginx.conf:14
```

Cheque o conteúdo do log de erro e a mensagem deve estar presente lá também:

```sh
sudo cat /var/log/nginx/error.log

# 2025/03/03 21:49:10 [emerg] 106#106: invalid number of arguments in "return" directive in /etc/nginx/nginx.conf:14
```

Mensagens de erro tem níveis. Uma entrada `notice` no log de erro é inofensivo, mas um `emerg` ou entrada de emergência deve ser resolvida logo.

Existem oito níveis de mensagem de erro:

- `debug` - Informações úteis de debug para determinar onde está o problema
- `info` - Mensagens informativas que não são necessárias de ler, mas são boas de se saber
- `notice` - Algor normal aconteceu e não vale basicamente nada
- `warn` - Algo inesperado aconteceu, mas não deve ser algo preocupante
- `error` - Alguma coisa não foi bem sucedida
- `crit` - Existem problemas críticos no funcionamento do servidor
- `alert` - Alguma ação é necessária
- `emerg` - O sistema está inutilizável e requer atenção imediata

Por padrão, o NGINX grava todos os níveis de mensagem. Você pode sobrescrever esse comportamento usando a diretiva `error_log`. Se você quer determinar que o nível mínimo de erro deve ser `warn`, atualize sua configuração como a seguinte:

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {

        listen 80;
        server_name nginx.test;

        error_log /var/log/error.log warn;

        return 200 "..." "...";
    }

}
```

Para a maioria dos projetos, deixar a configuração de erro como está deve ser o suficiente. A única sugestão é setar o log mínimo de erro para o `warn`. Dessa forma você não tem de ver entradas desnecessárias no log de erro.

De toda forma, se quiser aprender mais sobre customizar os logs no NGINX, consulte a [documentação oficial](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/)

## Como usar o NGINX como uma proxy reversa

Quando configurado como uma proxy reversa, o NGINX fica entre o client e o servidor backend. O client manda requests para o NGINX, e então o NGINX passa a request para o backend.

Uma vez que o servidor backend terminar de processar a request, ele manda de volta para o NGINX. Então, o NGINX retorna a response para o client.

Durante todo o processo, o client não tem ideia de quem está realmente processando a request. Parece complicado na hora de explicar, mas uma vez que você fizer, verá o quão fácil é fazer isso com o NGINX.

Vamos ver uma configuração básica e não muito prática de uma proxy reversa:

```conf
events {

}

http {

    include /etc/nginx/mime.types;

    server {
        listen 80;
        server_name nginx.test;

        location / {
                proxy_pass "http://nginx.org/";
        }
    }
}
```

Agora se você visitar http://nginx.test, você vai ser recebido pelo nginx.org original, mesmo a URL estando inalterada.

Você também deve conseguir navegar pelo site, acessando cada página da documentação.

Como pode ver, em um nível básico, a diretiva `proxy_pass` simplesmente passa a request do client para um servidor de terceiros e faz a proxy reversa da resposta pro client.

### Node com NGINX

Agora você sabe como configurar um servidor básico de proxy reverso, você pode servir uma aplicação node usando o NGINX. Eu adicionei uma aplicação demo dentro do repositório que vem com esse artigo.

> Estou pressupondo que você tem experiência com Node.js e sabe como iniciar uma aplicação usando o PM2.

Se você já clonou o repositório dentro do `/srv/exemplos-nginx` então o projeto `node-js-demo` deve estar disponível no diretório

Para essa demo funcionar você vai precisar instalar o Node.js no seu servidor. Você pode fazer isso seguindo as instruções da [documentação oficial](https://nodejs.org/en/download)

Essa aplicação de demonstração é um servidor HTTP simples que responde com um status 200 e um payload JSON. Você pode iniciar a aplicação simplesmente executando `node app.js` mas uma maneira melhor de fazer isso é usando [PM2](https://pm2.keymetrics.io/).

Para quem não sabe, PM2 é um gerenciador de projetos usado amplamente em projetos node em produção. Se quiser saber mais, esse [link](https://pm2.keymetrics.io/docs/usage/quick-start/) pode ajudar.

Instale PM2 globalmente executando `sudo npm install -g pm2`. Depois da instalação, execute o seguinte comando dentro do diretório `/srv/exemplos-nginx/node-js-demo:

```sh
pm2 start app.js

# [PM2] Spawning PM2 daemon with pm2_home=/root/.pm2
# [PM2] PM2 Successfully daemonized
# [PM2] Starting /srv/exemplos-nginx/node-js-demo/app.js in fork_mode (1 instance)
# [PM2] Done.
# ┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
# │ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
# ├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
# │ 0  │ app                │ fork     │ 0    │ online    │ 0%       │ 37.4mb   │
# └────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

Você pode parar a aplicação rodando o comando `pm2 stop app`

A aplicação deve estar rodando agora, mas não deve ser acessível do lado de fora do servidor. Para verificar se a aplicação está rodando, envie uma request para o http://localhost:3000 de dentro do seu servidor:

```sh
curl -i localhost:3000

# HTTP/1.1 200 OK
# Content-Type: application/json
# Date: Sun, 30 Mar 2025 12:57:28 GMT
# Connection: keep-alive
# Keep-Alive: timeout=5
# Transfer-Encoding: chunked

# { "status": "success", "message": "Você está aprendendo NGINX!" }
```

Se você recebeu uma resposta 200, então o servidor está funcionando normalmente. Para configurar o NGINX como uma proxy reversa, abra seu arquivo de configuração e atualize o conteúdo como o seguinte:

```conf
events {

}

http {
	server {
	    listen 80;
	    server_name nginx.test;

	    location / {
	        proxy_pass http://localhost:3000;
	    }
	}
}
```

Nada novo para explicar aqui. Você só está passando a requisição recebido para o aplicação Node.js rodando na porta 3000. Agora se você enviar uma request para o servidor do lado de fora você vai receber uma resposta da seguinte forma:

```sh
curl -i http://nginx.test
# HTTP/1.1 200 OK
# Server: nginx/1.27.4
# Date: Sun, 30 Mar 2025 13:35:37 GMT
# Content-Type: application/json
# Transfer-Encoding: chunked
# Connection: keep-alive

# { "status": "success", "message": "Você está aprendendo NGIN" }
```

Apesar disso funcionar para um servidor básico como esse, você pode ter que adicionar mais algumas diretivas para fazer isso funcionar em um cenário do mundo real dependendo dos requisitos da sua aplicação.

Por exemplo, se sua aplicação lida com conexões de websocket, então você deve atualizar sua configuração como a seguinte:

```sh
events {

}

http {
	server {
	    listen 80;
	    server_name nginx.test;

	    location / {
	        proxy_pass http://localhost:3000;
			proxy_http_version 1.1;
	        proxy_set_header Upgrade $http_upgrade;
	        proxy_set_header Connection 'upgrade';
	    }
	}
}
```

A diretiva `proxy_http_version` define a versão do HTTP do servidor. Por padrão é 1.0, mas para usar websocket é necessário que seja pelo menos 1.1. A diretiva `proxy_set_header` é usada por definir um header no servidor. A sintaxe para essa diretiva é algo como:

```conf
proxy_set_header <nome do header> <valor do header>
```

Escrevendo `proxy_set_header Upgrade $http_upgrade;` você está instruindo NGINX para passar o valor da variável `$http_upgrade` como header chamado `Upgrade`, o mesmo pelo header `Connection`

Se quiser saber mais sobre proxy de websocket, esse [link](https://nginx.org/en/docs/http/websocket.html) da documentação oficial pode ajudar.

Dependendo dos headers que sua aplicação precisa, você pode ter que definir mais deles. Mas a configuração acima é comumente utilizada para servir aplicações Node.js

## Como usar o NGINX como um load balancer

Graças ao design de proxy reversa do NGINX, você pode facilmente configurar ele como um load balancer.

No diretório `/srv/exemplos-nginx/load-balancer-demo` você deve encontrar uma demonstração que vamos utilizar nessa parte. Caso não tenha clonado o repositório nessa pasta ainda, agora é um bom momento para fazê-lo.

Num cenário real, fazer um balanceamento de cargo é necessário em projetos de larga escala distribuídos em múltiplos servidores. Mas para essa simples demonstração, eu criei 3 servidores node simples que respondem como o número do servidor e o status code 200.

Para essa demo funcionar você vai precisar instalar o Node.js no seu servidor. Você pode fazer isso seguindo as instruções da [documentação oficial](https://nodejs.org/en/download)

Além disso, você também vai precisar do [PM2](https://pm2.keymetrics.io/) para rodar os servidores dessa demo.

Se você não fez isso ainda, instale o PM2 com o comando `npm install -g pm2`. Depois da instalação acabar, execute o seguinte comando para executar os 3 servidores:

```sh
pm2 start /srv/exemplos-nginx/load-balancer-demo/server-1.js

pm2 start /srv/exemplos-nginx/load-balancer-demo/server-2.js

pm2 start /srv/exemplos-nginx/load-balancer-demo/server-3.js

pm2 list

# ┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
# │ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
# ├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
# │ 0  │ server-1           │ fork     │ 0    │ online    │ 0%       │ 37.4mb   │
# │ 1  │ server-2           │ fork     │ 0    │ online    │ 0%       │ 37.2mb   │
# │ 2  │ server-3           │ fork     │ 0    │ online    │ 0%       │ 37.1mb   │
# └────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

Três servidores Node.js devem estar rodando em localhost:3001, localhost:3002, localhost:3003 respectivamente.

Agora atualize sua configuração como a seguinte:

```conf
events {

}

http {
    upstream backend_servers {
        server localhost:3001;
        server localhost:3002;
        server localhost:3003;
    }

    server {
        listen 80;
        server_name nginx.test;

        location / {
            proxy_pass http://backend_servers;
        }
    }
}
```

A configuração dentro do contexto de `server` é o mesmo que já vimos antes. Mas o contexto `upstream` é novo. Um upstream no NGINX é uma coleção de servidores que pode ser tratado como apenas um backend.

Então os três servidores que inciamos usando PM2 pode ser colocado dentro de apenas um upstream e você deixar que o NGINX faça o balanceamento de carga entre eles.

Para testar a configuração, você vai ter que mandar mais de uma request para o servidor. Você pode automatizar o processo usando um loop `while` em bash:

```sh
while sleep 0.5; do curl http://nginx.test; done

# resposta do servidor - 2.
# resposta do servidor - 3.
# resposta do servidor - 1.
# resposta do servidor - 3.
# resposta do servidor - 1.
# resposta do servidor - 2.
# resposta do servidor - 2.
# resposta do servidor - 3.
# resposta do servidor - 1.
```

Você pode cancelar o loop pressionando `Ctrl + C` no seu teclado. Como pode ver das respostas do servidor, o NGINX faz o balanceamento de carga automaticamente.

Claro, dependendo da escala do projeto, balancear a carga pode ser muito mais complicado que isso. Mas o objetivo desse artigo é te dar uma base. Você pode parar os servidores node executando `pm2 stop all`

## Como configurar processos worker e conexões worker

Como mencionei em seções anteriores, o NGINX pode iniciar múltiplos processos worker, capazes de lidar com milhares de requests cada um.

```sh
sudo systemctl status nginx

# ● nginx.service - A high performance web server and a reverse proxy server
#      Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
#      Active: active (running) since Sun 2025-03-23 08:33:11 UTC; 5h 45min ago
#        Docs: man:nginx(8)
#    Main PID: 3904 (nginx)
#       Tasks: 2 (limit: 1136)
#      Memory: 3.2M
#      CGroup: /system.slice/nginx.service
#              ├─ 3904 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
#              └─16443 nginx: worker process
```

Como pode ver, agora tem apenas um processo worker do NGINX no sistema. Entretanto, esse número pode ser alterado fazendo uma pequena mudança no arquivo de configuração.

```conf
worker_processes 2;

events {

}

http {

    server {
        listen 80;
        server_name nginx.test;

        return 200 "Hello World :)";
    }
}
```

A diretiva `worker_process` escrita no contexto `main` é responsável por definir o número de processos worker para iniciar. Agora cheque o serviço do NGINX novamente e você deve ver dois processos worker:

```shell
sudo systemctl status nginx

# ● nginx.service - A high performance web server and a reverse proxy server
#      Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
#      Active: active (running) since Sun 2025-03-23 08:33:11 UTC; 5h 54min ago
#        Docs: man:nginx(8)
#     Process: 22610 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
#    Main PID: 3904 (nginx)
#       Tasks: 3 (limit: 1136)
#      Memory: 3.7M
#      CGroup: /system.slice/nginx.service
#              ├─ 3904 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
#              ├─22611 nginx: worker process
#              └─22612 nginx: worker process
```

Definindo o número de processos worker é fácil, mas determinar o número ideal de processos worker dá um pouco mais de trabalho.

Os processos worker tem natureza assíncrona. Isso significa que eles vão processar as requests que chegam o mais rápido que o hardware pode.

Agora considere que seu servidor rode em um processador com um core de processamento. Se você definir o número de processos worker para 1, aquele único processo vai utilizar 100% da capacidade do processador. Mas se você definir como 2, os 2 processos vão ser capazes de utilizar 50% do processador cada um. Então aumentar o número de processos worker não significa uma performance melhor.

Uma boa regra a se seguir é determinar o número de processos worker como o número de cores do seu processador.

Determinar o número de cores do processador no seu servidor é muito fácil no Linux.

```sh
nproc

# 1
```

Eu estou em uma máquina virtual de apenas um core, então o `nproc` identifica que tem apenas um core. Agora que você sabe o número de cores, tudo que resta fazer é definir o número na configuração.

Até aí tudo bem, mas toda vez que você fizer upgrade no processador do servidor, vai ter de alterar a configuração manualmente.

O NGINX provê uma forma melhor de lidar com esse problema. Você pode simplesmente definir o número de processos como `auto` e o NGINX vai definir o número de processos baseado no número de cores do processador automaticamente.

```conf
worker_processes auto;

events {

}

http {

    server {
        listen 80;
        server_name nginx.test;

        return 200 "Hello World :)";
    }
}
```

Inspecione o processo do NGINX novamente:

```shell
sudo systemctl status nginx

# ● nginx.service - A high performance web server and a reverse proxy server
#      Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
#      Active: active (running) since Sun 2025-03-23 08:33:11 UTC; 6h ago
#        Docs: man:nginx(8)
#     Process: 22610 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
#    Main PID: 3904 (nginx)
#       Tasks: 2 (limit: 1136)
#      Memory: 3.2M
#      CGroup: /system.slice/nginx.service
#              ├─ 3904 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
#              └─23659 nginx: worker process
```

O número de processos worker está de volta em 1, isso porque esse é o mais otimizado nesse servidor.

Além dos processos worker também existem as conexões worker, indicando o número máximo de conexões que um único worker pode processar.

Assim como o número de processos worker, esse número também está relacionado ao processador e ao número de arquivos que seu sistema operacional pode abrir por core.

Encontrar esse número é bem fácil no Linux:

```shell
ulimit -n

# 1024
```

Agora que temos esse número, tudo que nos resta é definir isso na configuração:

```conf
worker_processes auto;

events {
	worker_connections 1024;
}

http {

    server {
        listen 80;
        server_name nginx.test;

        return 200 "Hello World :)";
    }
}
```

A diretiva `worker_connections` é responsável por definir o número de conexões worker em uma configuração. Essa também é a primeira vez que você está alterando o contexto `events`.

Em uma seção anterior, eu mencionei que esse contexto é utilizado para definir valores usados pelo NGINX é um nível geral. A configuração de conexões worker é um exemplo desse tipo de configuração.
