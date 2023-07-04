Large Language Models (LLMs) have a constraint on the input size, prompting the need for partitioning the input text into smaller segments before processing them through the model. Nevertheless, haphazardly splitting the input text can result in the loss of semantically significant information. For instance, if the text is divided in the mid<br/>
dle, as shown here, the original meaning will no<br/>
longer remain coherent.

[LangChain](https://docs.langchain.com/) is a robust open-source framework designed to streamline the usage of language models by offering a wide array of classes and utility functions. Among the utilities provided by LangChain, there exist several class libraries specifically developed to facilitate the division of input text into smaller segments, all while ensuring the preservation of semantic integrity. This blog post introduces a method of leveraging the comprehensive utility set provided by LangChain for effective spliting long text into smaller segements.

```bs-alert info

LangChain offers two versions: Python and JavaScript. This blog post focuses on utilizing the Python version of LangChain.
```

## Install LangChain

To install LangChain, we can use the following command:

```shell
$ pip install -U langchain
```

The `-U` parameter is used to upgrade to the most recent version of LangChain in case it has been previously installed. Given that LangChain is currently undergoing active development, it is highly recommended to frequently update the framework to access and utilize its latest features.

In additional to LangChain, we also need to install the `tiktoken` library for token counting purposes in the input text. This library can be installed using the following command:

```shell
$ pip install -U tiktoken
```

## Token counting function

As a first step, it is essential to construct a function that can accurately count the number of tokens for an input text. This function will subsequently be employed by LangChain to validate whether the token count exceeds the limit of the language model. To accomplish this, we will utilize the `tiktoken` library from OpenAI for the token counting task.

Below is an example of how the token counting function can be defined:

```python
import tiktoken

def count_tokens_func_for_model(model_name):
    def count_tokens(text):
        enc = tiktoken.encoding_for_model(model_name)
        return len(enc.encode(text))
    return count_tokens
```

## Split a plaintext

We can split a plaintext into smaller segments by using the `RecursiveCharacterTextSplitter` class provided by LangChain:

```python
def split_text(model_name, text, chunk_size, chunk_overlap):
    from langchain.text_splitter import RecursiveCharacterTextSplitter
    length_function = count_tokens_func_for_model(model_name)
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size = chunk_size,
        chunk_overlap  = chunk_overlap,
        length_function = length_function,
    )
    return text_splitter.split_text(text)

text = """Large Language Models (LLMs) have a constraint on the input size, prompting the need for partitioning the input text into smaller segments before processing them through the model. Nevertheless, haphazardly splitting the input text can result in the loss of semantically significant information. For instance, if the text is divided in the middle, as shown here, the original meaning will no longer remain coherent.

LangChain is a robust open-source framework designed to streamline the usage of language models by offering a wide array of classes and utility functions. Among the utilities provided by LangChain, there exist several class libraries specifically developed to facilitate the division of input text into smaller segments, all while ensuring the preservation of semantic integrity. This blog post introduces a method of leveraging the comprehensive utility set provided by LangChain for effective spliting long text into smaller segements."""

chunks = split_text("text-embedding-ada-002", text, 70, 15)

# print the split segments together with token counts
length_function = count_tokens_func_for_model("text-embedding-ada-002")
chunks_and_tokens = [{'chunk':x, 'tokens':length_function(x)} for x in chunks]
print(chunks_and_tokens)
```

With settings `chunk_size = 70` and `chunk_overlap = 15`, the input text will undergo segmentation into smaller segments, resulting in the following breakdown:
```python
[
    {
        'chunk': 'Large Language Models (LLMs) have a constraint on the input size, prompting the need for partitioning the input text into smaller segments before processing them through the model. Nevertheless, haphazardly splitting the input text can result in the loss of semantically significant information. For instance, if the text is divided in the middle, as shown',
        'tokens': 69
    }, 
    {
        'chunk': 'For instance, if the text is divided in the middle, as shown here, the original meaning will no longer remain coherent.', 
        'tokens': 25
    }, 
    {
        'chunk': 'LangChain is a robust open-source framework designed to streamline the usage of language models by offering a wide array of classes and utility functions. Among the utilities provided by LangChain, there exist several class libraries specifically developed to facilitate the division of input text into smaller segments, all while ensuring the preservation of semantic integrity. This blog post introduces a method of', 
        'tokens': 69
    }, 
    {
        'chunk': 'while ensuring the preservation of semantic integrity. This blog post introduces a method of leveraging the comprehensive utility set provided by LangChain for effective spliting long text into smaller segements.', 
        'tokens': 35
    }
]
```

Increasing `chunk_size = 128` and setting `chunk_overlap = 0`, the segmentation process yields the following outcome:
```python
[
    {
        'chunk': 'Large Language Models (LLMs) have a constraint on the input size, prompting the need for partitioning the input text into smaller segments before processing them through the model. Nevertheless, haphazardly splitting the input text can result in the loss of semantically significant information. For instance, if the text is divided in the middle, as shown here, the original meaning will no longer remain coherent.', 
        'tokens': 80
    }, 
    {
        'chunk': 'LangChain is a robust open-source framework designed to streamline the usage of language models by offering a wide array of classes and utility functions. Among the utilities provided by LangChain, there exist several class libraries specifically developed to facilitate the division of input text into smaller segments, all while ensuring the preservation of semantic integrity. This blog post introduces a method of leveraging the comprehensive utility set provided by LangChain for effective spliting long text into smaller segements.', 
        'tokens': 89
    }
]
```

So, with an reasonable `chunk_size` setting (`text-embedding-ada-002` supports up to `8192` tokens<sup>[*]</sup>), it becomes feasible to partition the input text into smaller segments without compromising the preservation of semantic coherence.

```bs-alert info

[*] model `text-embedding-ada-002` supports `2048` tokens with version 1 and `8192` tokens with version 2. Source: https://openai.com/blog/new-and-improved-embedding-model
```

## Split a Markdown text

Markdown is a widely used markup language in technical documents. In Markdown, text paragraphs sharing similar meanings are frequently organized into sections. To facilitate the segmentation of Markdown text into smaller segments while maintaining the semantic structure of the content, LangChain offers the `MarkdownHeaderTextSplitter` class. This class effectively partitions Markdown text, preserving the intended semantic hierarchy within the segmented output.

```python
def split_markdown(text):
    headers_to_split_on = [
        ("#", "H1"),
        ("##", "H2"),
        ("###", "H3"),
        ("####", "H4"),
        ("#####", "H5"),
        ("######", "H6"),
    ]
    from langchain.text_splitter import MarkdownHeaderTextSplitter
    markdown_splitter = MarkdownHeaderTextSplitter(headers_to_split_on=headers_to_split_on)
    return markdown_splitter.split_text(text)

md_text = """Large Language Models (LLMs) have a constraint on the input size, prompting the need for partitioning the input text into smaller segments before processing them through the model. Nevertheless, haphazardly splitting the input text can result in the loss of semantically significant information.

## Install LangChain

To install LangChain, we can use the following command: $ pip install -U langchain

The `-U` parameter is used to upgrade to the most recent version of LangChain in case it has been previously installed. Given that LangChain is currently undergoing active development, it is highly recommended to frequently update the framework to access and utilize its latest features.

## Token counting function

As a first step, it is essential to construct a function that can accurately count the number of tokens for an input text. This function will subsequently be employed by LangChain to validate whether the token count exceeds the limit of the language model. To accomplish this, we will utilize the `tiktoken` library from OpenAI for the token counting task."""

md_chunks = split_markdown(md_text)
print(md_chunks)
```

The segmentation process yields the following outcome:

```python
[
    Document(
        page_content='Large Language Models (LLMs) have a constraint on the input size, prompting the need for partitioning the input text into smaller segments before processing them through the model. Nevertheless, haphazardly splitting the input text can result in the loss of semantically significant information.', 
        metadata={}
    ), 
    Document(
        page_content='To install LangChain, we can use the following command: $ pip install -U langchain  \nThe `-U` parameter is used to upgrade to the most recent version of LangChain in case it has been previously installed. Given that LangChain is currently undergoing active development, it is highly recommended to frequently update the framework to access and utilize its latest features.', 
        metadata={'H2': 'Install LangChain'}
    ), 
    Document(
        page_content='As a first step, it is essential to construct a function that can accurately count the number of tokens for an input text. This function will subsequently be employed by LangChain to validate whether the token count exceeds the limit of the language model. To accomplish this, we will utilize the `tiktoken` library from OpenAI for the token counting task.', 
        metadata={'H2': 'Token counting function'}
    )
]
```

```bs-alert primary

While the Markdown text has been segmented into smaller units based on its semantic structure, it is possible that some of these segments still exceed the token limit imposed by the language model. To address this issue, we can employ the _"Split a plaintext"_ approach to further divide these segments into manageable sizes.
```

## Before we wrap up

In this blog post, we have introduced two essential classes, namely `RecursiveCharacterTextSplitter` and `MarkdownHeaderTextSplitter`, which are available in LangChain. These classes serve the purpose of effectively segmenting lengthy texts into smaller, manageable segments while ensuring the preservation of semantic integrity. Beyond these classes, LangChain provides a range of additional utility functions and classes that can be utilized to partition HTML documents or source code written in various popular programming languages. For a comprehensive understanding and further details, please consult the [LangChain documentation](https://python.langchain.com/docs/modules/data_connection/document_transformers/).

<hr/>

```bs-alert warning

Disclaimer: I utilized ChatGPT to proofread and rephrase certain sections of this post.
```

_[[do-tag ghissue_comment.en]]_
