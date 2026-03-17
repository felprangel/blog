---
title: Como computadores representam números negativos
date: 2026-03-16
draft: false
math: true
---

Tem um conceito que eu ouvi falar várias vezes antes de realmente entender — só caiu a ficha quando li o manual do Intel 8080 enquanto desenvolvia um emulador.

Se você já estudou os fundamentos da computação, provavelmente conhece números binários. E em algum momento, talvez tenha surgido a dúvida: _como representar números negativos em binário?_ Se você pesquisou sobre isso, ou leu a documentação de inteiros em bancos de dados, provavelmente se deparou com algo como "um bit é reservado para o sinal" — o que explica os tipos `SIGNED` e `UNSIGNED`.

Mas será que é só isso? Coloca um bit pro sinal e tá resolvido?

Spoiler: não é bem assim. Vamos ver por quê — e como chegamos na solução que os computadores realmente usam.

---

## Abordagem 1: reservar um bit para o sinal

A ideia mais intuitiva é simples: o bit mais significativo (o mais à esquerda) indica o sinal. `0` para positivo, `1` para negativo. Considerando números de 4 bits:

| Binário | Decimal |
| :-----: | :-----: |
|  1111   |   -7    |
|  1110   |   -6    |
|   ...   |   ...   |
|  1000   |   -0    |
|  0000   |    0    |
|  0001   |    1    |
|   ...   |   ...   |
|  0111   |    7    |

Dois problemas saltam aos olhos.

O primeiro é estético: existe um **zero negativo** (`1000` = -0). Estranho, mas tolerável.

O segundo é fatal: a **aritmética não funciona**. Tente somar -2 + 3:

$$
\begin{array}{r}
  1010 \\
\mathbin{+}\ 0011 \\
\hline
  1101
\end{array}
$$

O resultado `1101` representa -5, mas o correto seria +1. O hardware precisaria de lógica especial para lidar com isso — o que é caro e lento. Precisamos de algo melhor.

---

## Abordagem 2: complemento de um (_One's Complement_)

E se "inverter" um número positivo para obter seu negativo? Isso é o complemento de um: **flipa todos os bits**.

`0010` (+2) → `1101` (-2)

| Binário | Decimal |
| :-----: | :-----: |
|  1000   |   -7    |
|   ...   |   ...   |
|  1111   |   -0    |
|  0000   |    0    |
|   ...   |   ...   |
|  0111   |    7    |

O zero negativo ainda aparece, mas pelo menos a aritmética melhorou. Veja -2 + 4:

$$
\begin{array}{r}
  0100 \\
\mathbin{+}\ 1101 \\
\hline
  0001
\end{array}
$$

O resultado bruto seria `10001`, mas truncando para 4 bits fica `0001` — que é 1, não 2. **Sempre 1 a menos do que deveria.**

Estamos mais perto, mas ainda não chegamos lá.

---

## Abordagem 3: complemento de dois (_Two's Complement_)

A solução é elegante: pega o complemento de um e **soma 1**. Esse é o complemento de dois — e é o que todos os processadores modernos usam.

Para obter -2: inverte `0010` → `1101`, depois soma 1 → `1110`.

| Binário | Decimal |
| :-----: | :-----: |
|  1001   |   -7    |
|  1010   |   -6    |
|  1011   |   -5    |
|  1100   |   -4    |
|  1101   |   -3    |
|  1110   |   -2    |
|  1111   |   -1    |
|  0000   |    0    |
|  0001   |    1    |
|  0010   |    2    |
|  0011   |    3    |
|  0100   |    4    |
|  0101   |    5    |
|  0110   |    6    |
|  0111   |    7    |

Dois problemas resolvidos de uma vez: **sem zero negativo**, e a aritmética funciona naturalmente:

$$
\begin{array}{r}
  0100 \\
\mathbin{+}\ 1110 \\
\hline
  0010
\end{array}
$$

4 + (-2) = 2. O resultado bruto seria `10010`, mas truncado para 4 bits: `0010`. ✓

$$
\begin{array}{r}
  1110 \\
\mathbin{+}\ 0010 \\
\hline
  0000
\end{array}
$$

-2 + 2 = 0. Resultado bruto `10000`, truncado: `0000`. ✓

### Uma forma diferente de enxergar

Há uma maneira interessante de interpretar o complemento de dois: o bit mais significativo não é um "bit de sinal" — ele vale **-8** (em 4 bits).

- `1001` → -8 + 1 = **-7**
- `1010` → -8 + 2 = **-6**
- `1111` → -8 + 7 = **-1**

Essa perspectiva explica por que a soma funciona sem nenhuma lógica especial: é só aritmética binária normal, onde o bit mais à esquerda tem peso negativo.

---

Da próxima vez que você ver `int8` indo de -128 a 127 (e não de -127 a 127), já sabe o porquê.
