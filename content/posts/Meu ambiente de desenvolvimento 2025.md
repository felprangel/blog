---
title: Meu ambiente de desenvolvimento 2025
date: 2025-01-29
draft: false
---

Se tem uma coisa que a gente aprende com o tempo, é que passar horas no terminal pode ser uma experiência dolorosa ou uma jornada digna de um mestre Jedi. Em 2025, um bom ambiente de desenvolvimento não é só um capricho, é um passaporte para a produtividade! Vamos configurar um terminal que é rápido, bonito e cheio de recursos. Aqui estão os passos para transformar seu Ubuntu em uma verdadeira nave espacial da codificação.

---

## Antes de tudo

Tenho um repositório com meus arquivos de configuração que foram ~~copiados~~ criados com muito suor. É recomendado que tenha esses arquivos baixados para facilitar as coisas

[Link do repo](https://github.com/felprangel/dotfiles)

---

## Instalando o Zsh (E se livrando do Bash monocromático)

Vamos instalar o Zsh, porque um terminal sem Zsh é igual a um anjo sem asas:

```bash
sudo apt update && sudo apt install zsh -y
```

Agora que temos o Zsh instalado, vamos torná-lo o padrão:

```bash
chsh -s $(which zsh)
```

Faça logout e entre novamente para ver a mágica acontecer.

### Opcional

Adicionar o script baixado do meu repositório de arquivos de configuração no final do arquivo `~/.zshrc`

---

## Ativando o Autocomplete do Zsh (E economizando digitações)

Agora que temos o Zsh, queremos que ele complete nossos comandos como um verdadeiro assistente de inteligência artificial. Vamos instalar o **zsh-autosuggestions** e o **zsh-syntax-highlighting**:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

# Para ter cores no terminal:
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
echo 'source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
```

Reinicie seu terminal ou rode:

```bash
source ~/.zshrc
```

Agora seu terminal prevê comandos como um mágico!

---

## Instalando Starship (Deixando o terminal nutella)

Para "aviadar" ainda mais o terminal, siga as instruções de instalação e configurção do [Starship](https://starship.rs/)

---

## Instalando o Alacritty (O terminal que voa baixo)

O **Alacritty** é um dos terminais mais rápidos e bonitos que você pode ter. Para instalar, siga os passos da [documentação oficial](https://alacritty.org/)

E pronto, temos um terminal de respeito!

### Opcional

Copiar os arquivos de configuração do meu repositório e colar na pasta `~/.config/alacritty`, que já vai prover um tema bonito para o terminal

---

## Mudando o Terminal Padrão do Ubuntu

Agora que temos o Alacritty, queremos que ele seja o terminal padrão. Para isso rode o seguinte comando para saber onde o Alacritty está instalado:

```bash
which alacritty
```

Agora rode o comando:

```bash
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /caminho/para/alacritty 50
```

Alterando `/caminho/para/alacritty` pelo caminho retornado no comando `which alacritty`

Por último, rode o seguinte comando para escolher o terminal padrão:

```bash
sudo update-alternatives --config x-terminal-emulator
```

Escolha o número correspondente ao Alacritty e pronto!

---

## Mudando o Terminal Padrão do Nautilus

O Nautilus (o gerenciador de arquivos do Ubuntu) ainda pode estar abrindo o terminal antigo. Para corrigir isso instalaremos o seguinte pacote:

[Nautilus Open Any Terminal](https://github.com/Stunkymonkey/nautilus-open-any-terminal)

Agora, ao abrir o terminal pelo Nautilus, você estará dentro do Alacritty!

---

## Instalando o [tmux](https://github.com/tmux/tmux) (Para multitarefa de verdade)

O **tmux** permite dividir sua tela e gerenciar múltiplas sessões sem perder nada. Para instalar:

```bash
sudo apt install tmux -y
```

Depois de instalado, basta rodar:

```bash
tmux
```

Agora você tem um terminal turbo com divisão de janelas!

### Opcional

Baixar o arquivo de configuração do tmux e colar na pasta home, tendo atalhos melhores e um tema bonito para o tmux também

---

## Instalando o [bat](https://github.com/sharkdp/bat) e o [eza](https://github.com/eza-community/eza) (Porque `cat` e `ls` são do século passado)

Substituir o `cat` pelo `bat` e o `ls` pelo `eza` faz seu terminal parecer um painel de controle da NASA. Para instalá-los siga a documentação oficial de cada um

---

## Conclusão

Agora você tem um terminal bonito, funcional e rápido. Seu ambiente de desenvolvimento está preparado para 2025 e além! Agora só falta escrever código de qualidade... mas isso já é outra história.
