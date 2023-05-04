As a developer using OpenAI's API, you'll quickly learn that providing detailed instructions and relevant context to the prompt will result in better outcomes. However, it's important to note that there are limits to the amount of text you can add to the prompt, and this limit is measured as the number of _tokens_.

## Use case

It's important to count the number of tokens in your prompt to optimize its performance. However, there's a caveat: token count isn't directly correlated to the number of _characters_, _bytes_, or _words_ in the prompt. This means that similar strings can result in different token counts in different natural languages (such as English and Vietnamese). As a result, accurately counting tokens is not a trivial task.

OpenAI uses [Byte Pair Encoding](https://en.wikipedia.org/wiki/Byte_pair_encoding) (BPE) for prompt input tokenization. Luckily, several programming language [libraries](https://github.com/topics/bpe) can tokenize and count the number of tokens from a string. However, if a suitable library is unavailable in your preferred programming language, you can still _estimate_ the number of tokens. This article proposes an approach to approximating the token count from an input string.

## The approach

While there's no direct relationship between the number of tokens and the number of _characters_, _bytes_, or _words_ in the input string, OpenAI [recommends](https://platform.openai.com/tokenizer) a general guideline for English: 1 token corresponds to approximately 4 characters or $\frac 3 4$ words. As such, 4 characters in the prompt equate to 1 token, and 75 words equate to 100 tokens. We'll apply this formula to approximate the token count from an input string:
- let $s$ be the input string.
- compute $t1=\frac{b(s)}{4}$, where $b(s)$ denotes the byte count of $s$. <br>While a character in English typically corresponds to a byte, this isn't necessarily the case for other natural languages encoded in Unicode. Therefore, we'll utilize byte count rather than character count.
- compute $t2=\frac{4}{3}w(s)+nw(s)$, where:
  - $w(s)$: tokenize $s$ into individual "words". For each "word", determine the upper bound of the byte count divided by 4, then sum all of the resulting values.
  - $nw(s)$ is the sum of byte counts for all "non-word" components (such as parentheses, punctuation marks, etc.) present in $s$.
- the _estimated_ token count $t=\frac{t1+t2} 2$

A reference implementation in Go is available [here](https://gist.github.com/btnguyen2k/2cadc210558714d1646f42a07a4bff5f):
```gh-gist btnguyen2k/2cadc210558714d1646f42a07a4bff5f
```

The output of this implementation is as follows:
|Input | Token count (*) | Estimated token count (**) | Difference |
|---|:---:|:---:|:---:|
|Chinese: `第一个是一，第二个是二，第三个是三。`|33|33|0|
|English: `Number 1 is one, number 2 is two and number 3 is three.`|15|24|9|
|French: `Le numéro 1 est un, le numéro 2 est deux et le numéro 3 est trois.`|26|33|7|
|German: `Nummer 1 ist eins, Nummer 2 ist zwei und Nummer 3 ist drei.`|25|24|-1|
|Japanese: `番号1は1で、番号2は2で、番号3は3です。`|28|34|6|
|Korean: `번호 1은 1이고, 번호 2는 2이고, 번호 3은 3입니다.`|51|41|-10|
|Lao: `ໝາຍເລກ 1 ແມ່ນຫນຶ່ງ, ໝາຍເລກ 2 ແມ່ນສອງ, ແລະ ໝາຍເລກ 3 ແມ່ນສາມ.`|144|92|-52|
|Thai: `หมายเลข 1 คือหนึ่ง หมายเลข 2 คือสอง และหมายเลข 3 คือสาม`|96|89|-7|
|Japanese: `El número 1 es uno, el número 2 es dos y el número 3 es tres.`|29|32|3|
|Vietnamese: `Số 1 là một, số 2 là hai và số 3 là ba`|33|32|-1|

```bs-alert info

(*) Token count is computed by OpenAI's [tokenizer](https://platform.openai.com/tokenizer) tool.

(**) Estimated token count is computed using the formula presented earlier.
```

## See also
- OpenAI's models and their token limits: https://platform.openai.com/docs/models
- Token limits of OpenAI's embedding models: https://platform.openai.com/docs/guides/embeddings/embedding-models
- BPE libraries on GitHub: https://github.com/topics/bpe
