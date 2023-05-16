## Embeddings là gì?

Embeddings là 1 vector các số thực, còn được gọi là _véc tơ nhúng_. Khoảng cách giữa 2 véc tơ xác định độ liên quan giữa chúng: khoảng cách càng nhỏ có nghĩa là 2 véc tơ có độ liên quan với nhau càng nhiều, và ngược lại<sup>[1]</sup>.

OpenAI cung cấp [API](https://platform.openai.com/docs/api-reference/embeddings) để trích xuất giá trị embeddings từ một đoạn văn bản đầu vào. Một câu hỏi phát sinh là liệu có nên chuẩn hoá đoạn văn bản đầu vào trước khi trích xuất véc tơ nhúng hay không? Bài viết này cung cấp kết quả của một vài thực nghiệm tôi đã tiến hành để giải đáp cho câu hỏi này.

```bs-alert primary

[1] Tham khảo https://platform.openai.com/docs/guides/embeddings/what-are-embeddings
```

## Dữ liệu test

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

**Thực nghiệm với tiếng Việt**

Bên dưới là kết quả thực nghiệm với đoạn văn bản tiếng Việt:
```markdown
# Tập tin metadata

Mỗi một thư mục bài viết có một _tập tin metadata_ riêng. Tập tin này chứa các _trường thông tin_ sau:

- **icon**: (string) icon của bài viết, hỗ trợ icon FontAwesome, ví dụ: <code>icon: fas fa-file</code>.
- **title**: (string) tiêu đề của bài viết, ví dụ: <code>title: "DO CMS là gì"</code>.
- **summary**: (string) tóm tắt ngắn gọn nội dung bài viết, ví dụ: <code>summary: "DO CMS là Hệ thống quản lý nội dung..."</code>.
- **tc**: (int) thời gian bài viết được tạo, ở định sạng UNIX timestamp, ví dụ <code>tc: 1684128579</code>.
```

Câu hỏi: `tập tin metadata có bao nhiêu trường thông tin?`

Kết quả:

|Model|Dimensions|Origin|Lower|NoNL|NoNLNW|NormFull|
|-----|---------:|-----:|----:|---:|-----:|-------:|
|<span class="text-nowrap text-info">        text-embedding-ada-002</span>|<span class="text-info"> 1536</span>|<span class="text-info">0.868167</span>|<span class="text-info">0.866878</span>|<span class="text-info">0.867377</span>|<span class="text-info">**0.887203**</span>|<span class="text-info"><u>0.885630</u></span>|
|<span class="text-nowrap">       text-similarity-ada-001</span>| 1024|0.828773|0.832341|0.833609|<u>0.848432</u>|**0.853005**|
|<span class="text-nowrap">   text-similarity-babbage-001</span>| 2048|0.782900|<u>0.789732</u>|0.779908|0.787809|**0.795255**|
|<span class="text-nowrap">     text-similarity-curie-001</span>| 4096|0.753109|0.756025|0.762263|<u>0.778867</u>|**0.779026**|
|<span class="text-nowrap">   text-similarity-davinci-001</span>|12288|0.647523|<u>0.660092</u>|0.639507|0.645955|**0.661849**|
|<span class="text-nowrap">       text-search-ada-doc-001</span>| 1024|0.773727|0.776633|0.766685|<u>0.790963</u>|**0.793348**|
|<span class="text-nowrap">     text-search-ada-query-001</span>| 1024|0.761278|0.769295|0.767522|<u>0.786152</u>|**0.791242**|
|<span class="text-nowrap">   text-search-babbage-doc-001</span>| 2048|0.734902|<u>0.747060</u>|0.729072|0.737354|**0.750097**|
|<span class="text-nowrap"> text-search-babbage-query-001</span>| 2048|0.749683|<u>0.765511</u>|0.756029|0.758389|**0.770678**|
|<span class="text-nowrap">     text-search-curie-doc-001</span>| 4096|0.725577|**0.729580**|0.721478|0.727762|<u>0.728584</u>|
|<span class="text-nowrap">   text-search-curie-query-001</span>| 4096|<u>0.751477</u>|**0.756445**|<u>0.751380</u>|0.729285|0.736985|
|<span class="text-nowrap">   text-search-davinci-doc-001</span>|12288|0.628781|**0.640672**|0.620964|0.623006|<u>0.635047</u>|
|<span class="text-nowrap"> text-search-davinci-query-001</span>|12288|0.677347|0.673591|0.668126|<u>0.680186</u>|**0.692823**|

<hr/>

_[[do-tag ghissue_comment.vi]]_
