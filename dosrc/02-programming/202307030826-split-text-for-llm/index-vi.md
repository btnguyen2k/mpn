Các mô hình ngôn ngữ lớn (Large Language Model - LLM) hiện nay đều có giới hạn kích thước đầu vào. Để giải quyết vấn đề này, chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn trước khi đưa vào mô hình. Tuy nhiên, chia nhỏ văn bản đầu vào mà không có chiến lược hợp lý có thể làm mất đi một số thông tin quan trọng. Chẳng hạn như đoạn văn bản bị chi<br/>
a cắt ngay giữa như thế này thì ngữ<br/>
nghĩa sẽ không còn nguyên vẹn nữa.

[LangChain](https://docs.langchain.com/) là một framework mã nguồn mở cung cấp nhiều class và hàm tiện ích để ứng dụng làm việc với các mô hình ngôn ngữ dễ dàng hơn. Trong số các tiện ích được cung cấp bởi LangChain, có một số class thư viện giúp chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn mà vẫn bảo toàn ngữ nghĩa. Bài viết này giới thiệu một phương pháp sử dụng các tiện ích cung cấp bởi LangChain để chia nhỏ văn bản đầu vào.

```bs-alert info

LangChain hỗ trợ 2 phiên bản: Python và Javascript. Bài viết này sử dụng phiên bản Python của LangChain.
```

## Cài đặt LangChain

Để cài đặt LangChain, chúng ta có thể sử dụng lệnh sau:

```shell
$ pip install -U langchain
```

Tham số `-U` được sử dụng để cập nhật phiên bản mới nhất của LangChain nếu LangChain đã được cài đặt trước đó. LangChain hiện vẫn còn đang trong giai đoạn phát triển, do vậy khuyến nghị bạn nên cập nhật LangChain định kỳ để có thể sử dụng được các tính năng mới nhất.

Ngoài ra, chúng ta cũng cần cài thêm thư viện `tiktoken` để đếm số token từ văn bản đầu vào. Thư viện này có thể được cài đặt bằng lệnh sau:

```shell
$ pip install -U tiktoken
```

## Hàm tính số token của 1 đoạn văn bản

Đầu tiên, chúng ta cần 1 hàm tính số token của 1 đoạn văn bản. Hàm này sẽ được sử dụng bởi LangChain để kiểm tra xem số token của 1 đoạn văn bản có vượt quá giới hạn của mô hình ngôn ngữ hay không. Trong bài viết này, chúng ta sẽ sử dụng thư viện `tiktoken` của OpenAI để tính số token của 1 đoạn văn bản.

Hàm tính số token của chúng ta có thể được viết như sau:

```python
import tiktoken

def count_tokens_func_for_model(model_name):
    def count_tokens(text):
        enc = tiktoken.encoding_for_model(model_name)
        return len(enc.encode(text))
    return count_tokens
```

## Chia nhỏ văn bản thô

Chúng ta chia nhỏ văn bản thô thành các đoạn văn bản nhỏ hơn bằng cách sử dụng class `RecursiveCharacterTextSplitter` cung cấp bởi LangChain:

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

text = """Các mô hình ngôn ngữ lớn (Large Language Model - LLM) hiện nay đều có giới hạn kích thước đầu vào. Để giải quyết vấn đề này, chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn và đưa vào mô hình. Tuy nhiên, chia nhỏ văn bản đầu vào mà không có chiến lược hợp lý có thể làm mất đi một số thông tin quan trọng. Chẳng hạn như đoạn văn bản bị chia cắt ngay giữa như thế này thì ngữ nghĩa sẽ không còn nguyên vẹn nữa.

LangChain là một framework mã nguồn mở cung cấp nhiều thư viện và hàm tiện ích để ứng dụng làm việc với các mô hình ngôn ngữ dễ dàng hơn. Trong số các tiện ích được cung cấp bởi LangChain, có một số hàm và thư viện giúp chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn mà vẫn bảo toàn ngữ nghĩa. Bài viết này giới thiệu một phương pháp sử dụng các hàm và thư viện được cung cấp bởi LangChain để chia nhỏ văn bản đầu vào."""

chunks = split_text("text-embedding-ada-002", text, 100, 20)

# in ra các đoạn văn bản sau khi chia nhỏ cùng với số token
length_function = count_tokens_func_for_model("text-embedding-ada-002")
chunks_and_tokens = [{'chunk':x, 'tokens':length_function(x)} for x in chunks]
print(chunks_and_tokens)
```

Với các `chunk_size = 100` và `chunk_overlap = 20` như trên, đoạn văn bản đầu vào sẽ được chia thành các đoạn nhỏ hơn như sau:
```python
[
    {
        'chunk': 'Các mô hình ngôn ngữ lớn (Large Language Model - LLM) hiện nay đều có giới hạn kích thước đầu vào. Để giải quyết vấn đề này, chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn và đưa vào mô hình. Tuy nhiên,', 
        'tokens': 100
    }, 
    {
        'chunk': 'nhỏ hơn và đưa vào mô hình. Tuy nhiên, chia nhỏ văn bản đầu vào mà không có chiến lược hợp lý có thể làm mất đi một số thông tin quan trọng. Chẳng hạn như đoạn văn bản bị chia cắt ngay giữa như thế này thì ngữ', 
        'tokens': 100
    }, 
    {
        'chunk': 'chia cắt ngay giữa như thế này thì ngữ nghĩa sẽ không còn nguyên vẹn nữa.', 
        'tokens': 41
    }, 
    {
        'chunk': 'LangChain là một framework mã nguồn mở cung cấp nhiều thư viện và hàm tiện ích để ứng dụng làm việc với các mô hình ngôn ngữ dễ dàng hơn. Trong số các tiện ích được cung cấp bởi LangChain, có một số hàm và thư viện', 
        'tokens': 97
    }, 
    {
        'chunk': 'bởi LangChain, có một số hàm và thư viện giúp chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn mà vẫn bảo toàn ngữ nghĩa. Bài viết này giới thiệu một phương pháp sử dụng các hàm và thư viện được cung cấp bởi', 
        'tokens': 100
    }, 
    {
        'chunk': 'các hàm và thư viện được cung cấp bởi LangChain để chia nhỏ văn bản đầu vào.', 
        'tokens': 35
    }
]
```

Tăng giới hạn `chunk_size = 256` và đặt `chunk_overlap = 0`, chúng ta thu được kết quả như sau:
```python
[
    {
        'chunk': 'Các mô hình ngôn ngữ lớn (Large Language Model - LLM) hiện nay đều có giới hạn kích thước đầu vào. Để giải quyết vấn đề này, chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn và đưa vào mô hình. Tuy nhiên, chia nhỏ văn bản đầu vào mà không có chiến lược hợp lý có thể làm mất đi một số thông tin quan trọng. Chẳng hạn như đoạn văn bản bị chia cắt ngay giữa như thế này thì ngữ nghĩa sẽ không còn nguyên vẹn nữa.',
        'tokens': 204
    },
    {
        'chunk': 'LangChain là một framework mã nguồn mở cung cấp nhiều thư viện và hàm tiện ích để ứng dụng làm việc với các mô hình ngôn ngữ dễ dàng hơn. Trong số các tiện ích được cung cấp bởi LangChain, có một số hàm và thư viện giúp chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn mà vẫn bảo toàn ngữ nghĩa. Bài viết này giới thiệu một phương pháp sử dụng các hàm và thư viện được cung cấp bởi LangChain để chia nhỏ văn bản đầu vào.',
        'tokens': 195
    }
]
```

Như vậy, với `chunk_size` đủ lớn (model `text-embedding-ada-002` hỗ trợ đến `8192` token<sup>[*]</sup>), chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn mà vẫn bảo toàn ngữ nghĩa.

```bs-alert info

[*] model `text-embedding-ada-002` hỗ trợ `2048` token với version 1 và `8192` token với version 2. Nguồn: https://openai.com/blog/new-and-improved-embedding-model
```

## Chia nhỏ văn bản Markdown

Markdown là một ngôn ngữ đánh dấu văn bản được sử dụng phổ biến trong các tài liệu kỹ thuật. Với Markdown, các đoạn văn bản có ngữ nghĩa gần nhau thường được nhóm với nhau theo các đề mục. LangChain cung cấp class `MarkdownHeaderTextSplitter` giúp chúng ta chia nhỏ văn bản Markdown thành các đoạn nhỏ hơn, đồng thời đính kèm các đề mục để bảo toàn ngữ nghĩa theo cấu trúc của văn bản.

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

md_text = """Các mô hình ngôn ngữ lớn (Large Language Model - LLM) hiện nay đều có giới hạn kích thước đầu vào. Để giải quyết vấn đề này, chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn và đưa vào mô hình. Tuy nhiên, chia nhỏ văn bản đầu vào mà không có chiến lược hợp lý có thể làm mất đi một số thông tin quan trọng. Chẳng hạn như đoạn văn bản bị chia cắt ngay giữa như thế này thì ngữ nghĩa sẽ không còn nguyên vẹn nữa.

# Cài đặt LangChain

Để cài đặt LangChain, chúng ta có thể sử dụng lệnh sau: pip install -U langchain

Tham số -U được sử dụng để cập nhật phiên bản mới nhất của LangChain nếu LangChain đã được cài đặt trước đó. LangChain hiện vẫn còn đang trong giai đoạn phát triển, do vậy khuyến nghị bạn nên cập nhật LangChain định kỳ để có thể sử dụng được các tính năng mới nhất.

# Hàm tính số token của 1 đoạn văn bản

Đầu tiên, chúng ta cần 1 hàm tính số token của 1 đoạn văn bản. Hàm này sẽ được sử dụng bởi LangChain để kiểm tra xem số token của 1 đoạn văn bản có vượt quá giới hạn của mô hình ngôn ngữ hay không. Trong bài viết này, chúng ta sẽ sử dụng thư viện tiktoken của OpenAI để tính số token của 1 đoạn văn bản."""

md_chunks = split_markdown(md_text)
print(md_chunks)
```

Chúng ta thu được kết quả như sau:

```python
[
    Document(
        page_content='Các mô hình ngôn ngữ lớn (Large Language Model - LLM) hiện nay đều có giới hạn kích thước đầu vào. Để giải quyết vấn đề này, chúng ta có thể chia nhỏ văn bản đầu vào thành các đoạn nhỏ hơn và đưa vào mô hình. Tuy nhiên, chia nhỏ văn bản đầu vào mà không có chiến lược hợp lý có thể làm mất đi một số thông tin quan trọng. Chẳng hạn như đoạn văn bản bị chia cắt ngay giữa như thế này thì ngữ nghĩa sẽ không còn nguyên vẹn nữa.', 
        metadata={}
    ),
    Document(
        page_content='Để cài đặt LangChain, chúng ta có thể sử dụng lệnh sau: pip install -U langchain  \nTham số -U được sử dụng để cập nhật phiên bản mới nhất của LangChain nếu LangChain đã được cài đặt trước đó. LangChain hiện vẫn còn đang trong giai đoạn phát triển, do vậy khuyến nghị bạn nên cập nhật LangChain định kỳ để có thể sử dụng được các tính năng mới nhất.', 
        metadata={'H1': 'Cài đặt LangChain'}
    ),
    Document(
        page_content='Đầu tiên, chúng ta cần 1 hàm tính số token của 1 đoạn văn bản. Hàm này sẽ được sử dụng bởi LangChain để kiểm tra xem số token của 1 đoạn văn bản có vượt quá giới hạn của mô hình ngôn ngữ hay không. Trong bài viết này, chúng ta sẽ sử dụng thư viện tiktoken của OpenAI để tính số token của 1 đoạn văn bản.', 
        metadata={'H1': 'Hàm tính số token của 1 đoạn văn bản'}
    )
]
```

```bs-alert primary

Mặc dù văn bản Markdown đã được chia thành các đoạn nhỏ theo ngữ nghĩa, nhưng trong các đoạn nhỏ này có thể có những đoạn có số token vượt quá giới hạn của mô hình ngôn ngữ. Chúng ta có thể áp dụng cách _"Chia nhỏ văn bản thô"_ để tiếp tục chia nhỏ các đoạn này.
```

## Trước khi kết thúc

Bài viết đã giới thiệu 2 class `RecursiveCharacterTextSplitter` và `MarkdownHeaderTextSplitter` của LangChain giúp chúng ta chia nhỏ 1 đoạn văn bản dài thành các đoạn nhỏ hơn mà ngữ nghĩa vẫn được bảo toàn.

Ngoài 2 class kể trên, LangChain còn cung cấp các hàm và class tiện ích khác bạn có thể sử dụng để chia nhỏ các văn bản HTML hoặc mã nguồn các ngôn ngữ lập trình thông dụng. Bạn có thể tham khảo thêm ở trang [tài liệu của LangChain](https://python.langchain.com/docs/modules/data_connection/document_transformers/).

<hr >

_[[do-tag ghissue_comment.vi]]_
