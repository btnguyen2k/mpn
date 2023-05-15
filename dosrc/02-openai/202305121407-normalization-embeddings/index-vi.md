## Embeddings là gì?

Embeddings là 1 vector các số thực, còn được gọi là _véc tơ nhúng_. Khoảng cách giữa 2 véc tơ xác định độ liên quan giữa chúng: khoảng cách càng nhỏ có nghĩa là 2 véc tơ có độ liên quan với nhau càng nhiều, và ngược lại<sup>[1]</sup>.

OpenAI cung cấp [API](https://platform.openai.com/docs/api-reference/embeddings) để trích xuất giá trị embeddings từ một đoạn văn bản đầu vào. Một câu hỏi phát sinh là liệu có nên chuẩn hoá đoạn văn bản đầu vào trước khi trích xuất véc tơ nhúng hay không? Bài viết này cung cấp kết quả của một vài thực nghiệm tôi đã tiến hành để giải đáp cho câu hỏi này.

```bs-alert primary

[1] Tham khảo https://platform.openai.com/docs/guides/embeddings/what-are-embeddings
```

## Dữ liệu text

Tôi chuẩn bị _1 đoạn căn bản_ và _1 câu hỏi_, sử dụng 1 model OpenAI để trích xuất véc tơ nhúng từ cả 2. Sau đó giá trị `cosine similarity` được tính từ 2 véc tơ để xác định độ tương đồng giữa chúng. Thực nghiệm được tiến hành trên nhiều phiên bản chuẩn hoá khác nhau của đoạn văn bản đầu vào.

Đoạn văn bản được trích từ [trang web Markdown Guide](https://www.markdownguide.org/getting-started/#why-use-markdown):
```markdown
# Why Use Markdown?
You might be wondering why people use Markdown instead of a WYSIWYG editor. Why write with Markdown when you can press buttons in an interface to format your text? As it turns out, there are several reasons why people use Markdown instead of WYSIWYG editors.

- Markdown can be used for everything. People use it to create websites, documents, notes, books, presentations, email messages, and technical documentation.
- Markdown is portable. Files containing Markdown-formatted text can be opened using virtually any application. If you decide you don’t like the Markdown application you’re currently using, you can import your Markdown files into another Markdown application. That’s in stark contrast to word processing applications like Microsoft Word that lock your content into a proprietary file format.
- Markdown is platform independent. You can create Markdown-formatted text on any device running any operating system.
- Markdown is future proof. Even if the application you’re using stops working at some point in the future, you’ll still be able to read your Markdown-formatted text using a text editing application. This is an important consideration when it comes to books, university theses, and other milestone documents that need to be preserved indefinitely.
- Markdown is everywhere. Websites like Reddit and GitHub support Markdown, and lots of desktop and web-based applications support it.
```

Câu hỏi: `what are use cases of Markdown?`

Các phiên bản chuẩn hoá của đầu vào được sử dụng:
- **Origin**: giữ nguyên văn bản đầu vào.
- **Lower**: văn bản đầu vào được chuyển hết sang chữ thường.
- **NoNL**: loại bỏ các ký tự xuống hàng, giữ nguyên chữ HOA/thường.
- **NoNLNW**: loại bỏ các ký tự xuống hàng, và một số ký tự phân cách khác (các ký tự dấu câu sau được giữ lại <code>'"-_,;:.?!/</code>), giữ nguyên chữ HOA/thường.
- **NormFull**: văn bản đầu vào được chuyết hết sang chữ thường, loại bỏ các ký tự xuống hàng, và một số ký tự phân cách khác (các ký tự dấu câu sau được giữ lại <code>'"-_,;:.?!/</code>).

_Lưu ý: các ký tự trắng ở đầu và cuối văn bản đầu vào đều được loại bỏ trong tất cả các trường hợp._

Các model OpenAI được sử dụng trong thực nghiệm:
- `text-embedding-ada-002`,
- `text-similarity-ada-001`, `text-similarity-babbage-001`, `text-similarity-curie-001`, `text-similarity-davinci-001`,
- `text-search-ada-doc-001`, `text-search-ada-query-001`,
- `text-search-babbage-doc-001`, `text-search-babbage-query-001`,
- `text-search-curie-doc-001`, `text-search-curie-query-001`,
- `text-search-davinci-doc-001`, `text-search-davinci-query-001`.

## Kết quả

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

Giá trị `cosine similarity` càng lớn thể hiện độ tương đồng giữa đoạn văn bản và câu hỏi càng nhiều.
```

Vì số lượng mẫu thử không đủ nhiều để chúng ta có thể rút ra một kết luận chính xác từ kết quả thực nghiệm, tuy nhiên nó cung cấp một số ý tưởng ban đầu để triển khai thêm. Nếu bạn quan tâm, có thể tham khảo mã nguồn được sử dụng trong thực nghiệm [ở đây](https://gist.github.com/btnguyen2k/2d418b899a3673cd7b10c68ab39075db) và tiến hành thực nghiệm trên tập dữ liệu của riêng bạn.

<hr/>

_[[do-tag ghissue_comment.vi]]_
