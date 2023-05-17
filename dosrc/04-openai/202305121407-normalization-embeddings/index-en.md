## What are embeddings?

An embedding is a vector (list) of floating point numbers. The distance between two vectors measures their relatedness. Small distances suggest high relatedness and large distances suggest low relatedness<sup>[1]</sup>.

OpenAI provides an [API endpoint for embeddings](https://platform.openai.com/docs/api-reference/embeddings) to obtain embeddings from an input text. A pertinent question is whether normalization of the input text is necessary before obtaining the embeddings. This post outlines the results of experiments I have conducted to address this question.

```bs-alert primary

[1] https://platform.openai.com/docs/guides/embeddings/what-are-embeddings
```

## Test data

_A text string in Markdown_ format along with _a question_ was prepared and embeddings for both were extracted using an OpenAI model. The `cosine similarity` value was then used to gauge the degree of similarity between the text string and the question. This experiment was conducted across different normalized versions of the text string, with `cosine similarity` values being recorded. 

The text string was taken from [Markdown Guide website](https://www.markdownguide.org/getting-started/#why-use-markdown):
```markdown
# Why Use Markdown?
You might be wondering why people use Markdown instead of a WYSIWYG editor. Why write with Markdown when you can press buttons in an interface to format your text? As it turns out, there are several reasons why people use Markdown instead of WYSIWYG editors.

- Markdown can be used for everything. People use it to create websites, documents, notes, books, presentations, email messages, and technical documentation.
- Markdown is portable. Files containing Markdown-formatted text can be opened using virtually any application. If you decide you don’t like the Markdown application you’re currently using, you can import your Markdown files into another Markdown application. That’s in stark contrast to word processing applications like Microsoft Word that lock your content into a proprietary file format.
- Markdown is platform independent. You can create Markdown-formatted text on any device running any operating system.
- Markdown is future proof. Even if the application you’re using stops working at some point in the future, you’ll still be able to read your Markdown-formatted text using a text editing application. This is an important consideration when it comes to books, university theses, and other milestone documents that need to be preserved indefinitely.
- Markdown is everywhere. Websites like Reddit and GitHub support Markdown, and lots of desktop and web-based applications support it.
```

The question: `what are use cases of Markdown?`

The following normalized versions of the text string were used:
- **Origin**: the text string is kept intact.
- **Lower**: the text string is lower-cased.
- **NoNL**: all newlines are removed, text case is intact.
- **NoNLNW**: newlines are removed, some non-word characters are also removed (these punctuations are kept <code>'"-_,;:.?!/</code>), text case is intact.
- **NormFull**: the text string is lower-cased, newlines are removed, some non-word characters are also removed (these punctuations are kept <code>'"-_,;:.?!/</code>).

_Note that leading and trailing spaces are removed in all cases._

The following OpenAI models were used in the experiment:
- `text-embedding-ada-002`,
- `text-similarity-ada-001`, `text-similarity-babbage-001`, `text-similarity-curie-001`, `text-similarity-davinci-001`,
- `text-search-ada-doc-001`, `text-search-ada-query-001`,
- `text-search-babbage-doc-001`, `text-search-babbage-query-001`,
- `text-search-curie-doc-001`, `text-search-curie-query-001`,
- `text-search-davinci-doc-001`, `text-search-davinci-query-001`.

## Results

|Model|Dimensions|Origin|Lower|NoNL|NoNLNW|NormFull|
|-----|---------:|-----:|----:|---:|-----:|-------:|
|<span class="text-nowrap text-info">        text-embedding-ada-002</span>|<span class="text-info"> 1536</span>|<span class="text-info">0.856743</span>|<span class="text-info">0.856882</span>|<span class="text-info">0.858511</span>|<span class="text-info">**0.863255**</span>|<span class="text-info"><u>0.862929</u></span>|
|<span class="text-nowrap">       text-similarity-ada-001</span>| 1024|0.795281|0.791943|0.794294|**0.799370**|<u>0.796414</u>|
|<span class="text-nowrap">   text-similarity-babbage-001</span>| 2048|0.713270|0.713255|0.720984|<u>0.725879</u>|**0.728990**|
|<span class="text-nowrap">     text-similarity-curie-001</span>| 4096|0.743008|0.742636|0.740478|<u>0.744563</u>|**0.746377**|
|<span class="text-nowrap">   text-similarity-davinci-001</span>|12288|0.618809|0.620695|0.620212|<u>0.622371</u>|**0.627889**|
|<span class="text-nowrap">       text-search-ada-doc-001</span>| 1024|0.724214|0.715687|0.725533|**0.732543**|<u>0.726148</u>|
|<span class="text-nowrap">     text-search-ada-query-001</span>| 1024|0.693340|0.681509|<u>0.698028</u>|**0.703483**|0.690489|
|<span class="text-nowrap">   text-search-babbage-doc-001</span>| 2048|<u>0.685309</u>|0.678838|0.684186|**0.686690**|**0.686815**|
|<span class="text-nowrap"> text-search-babbage-query-001</span>| 2048|**0.700823**|<u>0.698532</u>|<u>0.698911</u>|0.697156|<u>0.698270</u>|
|<span class="text-nowrap">     text-search-curie-doc-001</span>| 4096|0.659821|0.654378|0.653947|<u>0.661894</u>|**0.662608**|
|<span class="text-nowrap">   text-search-curie-query-001</span>| 4096|**0.648664**|<u>0.646623</u>|0.631803|0.628487|0.636617|
|<span class="text-nowrap">   text-search-davinci-doc-001</span>|12288|<u>0.559743</u>|**0.565005**|0.544085|0.546072|0.557400|
|<span class="text-nowrap"> text-search-davinci-query-001</span>|12288|**0.626891**|0.621365|0.618291|0.613500|<u>0.622472</u>|

```bs-alert info

A higher `cosine similarity` value indicates a greater similarity between the text string and the question.
```

The experiment results are insufficient to draw a definitive conclusion due to the limited number of test cases, but it provides an initial idea. For those interested, the full source code used in the experiment can be found [here](https://gist.github.com/btnguyen2k/2d418b899a3673cd7b10c68ab39075db), enabling one to conduct the experiment on their own data.

<hr/>

```bs-alert warning

Disclaimer: I utilized ChatGPT to proofread and rephrase certain sections of this post.
```

_[[do-tag ghissue_comment.en]]_
