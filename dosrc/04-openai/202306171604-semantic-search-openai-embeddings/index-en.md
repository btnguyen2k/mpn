Semantic search is a advanced search methodology that transcends the limitations of keyword-based approaches. By comprehending the underlying intent and contextual nuances of a search query, semantic search is able to deliver more relevant and meaningful results compared to the traditional keyword-based search.

For instance, in the context of researching the economic effects of the COVID-19 pandemic, the two articles titled "Tourism numbers are collapsing sharply due to the pandemic" and "Covid-19 has made traveling more difficult than ever" convey similar meanings<sup>[*]</sup>, albeit with different word choices.

A modern approach to implementing semantic search is to use vector search. The algorithm can be summarized as follows:
- Indexing: meaning of the input documents are vectorized where each vector is an array of real numners. The result is then stored in a database.
- Searcning:
  - Firstly, the intent of the search query is also transformed into a vector.
  - Secondly, the vectorized search query is compared to the document vectors stored in the database in order to retrieve the most relevant documents.

One crucial aspect of the aforementioned approach is the process of converting the meaning of the input text into a vector representation. This post highlights the utilization of [OpenAI's embeddings API](https://platform.openai.com/docs/guides/embeddings) to accomplish this task effectively.

```bs-alert info

[*] Using the `text-embedding-ada-002` model to acquire the embedding vectors and compute the cosine similarity value between the two text strings "Tourism numbers are collapsing sharply due to the pandemic" and "Covid-19 has made traveling more difficult than ever", we obtain a result of approximately `87.9%`.
```

## How to use OpenAI's embeddings API

Firsly, you need to register for an account on the website https://platform.openai.com/. Then, you should proceed to update your billing information by visiting https://platform.openai.com/account/billing/overview. Finally, you need to generate an API key by accessing https://platform.openai.com/account/api-keys. This API key will be essential for making calls to OpenAI's APIs.

After successfully acquiring the API key, you can commence invoking OpenAI's embeddings API:

- Send `POST` request to https://api.openai.com/v1/embeddings.
- The request body must be formatted as a JSON string containing at least 2 parameters:
  - `model`: (string), the ID of the OpenAI model utilized for vectorizing the input text. As of the time of this post's publication, OpenAI [recommends](https://platform.openai.com/docs/guides/embeddings/what-are-embeddings) employing the `text-embedding-ada-002` model for all embedings tasks.
  - `input`: (string), the input text to be vectorized.
- The API key is passed via the `Authorization` header for authenciation.

Sample API call:
```sh
curl https://api.openai.com/v1/embeddings \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "The food was delicious and the waiter...",
    "model": "text-embedding-ada-002"
  }'
```

and the returned result:
```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [
        0.0023064255,
        -0.009327292,
        .... (1536 floats total for ada-002)
        -0.0028842222,
      ],
      "index": 0
    }
  ],
  "model": "text-embedding-ada-002",
  "usage": {
    "prompt_tokens": 8,
    "total_tokens": 8
  }
}
```

```bs-alert primary

For detailed information on OpenAI's embeddings API, please consult the documentation available at https://platform.openai.com/docs/api-reference/embeddings
```

## Notes and practices

**Choose an appropriate model**: the selection of different models will have either a direct or indirect influence on the quality and performance of the semantic search result. As of the time of this post's publication, OpenAI [recommends](https://platform.openai.com/docs/guides/embeddings/what-are-embeddings) employing the `text-embedding-ada-002` model for all embedings tasks.

**Normalize the input text** prior to sending it to the embeddings API. For further information, please refer to [this post](../../openai/normalization-embeddings/).

**Segment the large input document into smaller fragments**: if the input document surpasses the maximum length permitted by the model, it becomes necessary to divide the document into smaller segments. Each segment should be vectorized separately.  Additionally, chunking the input text can be employed when the segments convey distinct narratives or meanings.

<hr/>

```bs-alert warning

Disclaimer: I utilized ChatGPT to proofread and rephrase certain sections of this post.
```

_[[do-tag ghissue_comment.en]]_
