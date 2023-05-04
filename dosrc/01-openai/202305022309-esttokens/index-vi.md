Sử dụng các API của OpenAI bạn sẽ nhận ra là nếu bạn cung cấp càng nhiều chỉ dẫn cụ thể và ngữ cảnh liên quan trong prompt thì kết quả càng chất lượng. Tuy nhiên, bạn không thể cung cấp vô hạn chỉ dẫn và ngữ cảnh được (dĩ nhiên rồi!). Các API của OpenAI giới hạn độ dài prompt, và độ dài này có đơn vị tính là _token_.

## Tình huống

Tính số lượng token là nhu cầu cần thiết để tối ưu hoá lượng dữ liệu đưa vào prompt. Nhưng ở đây có một rắc rối tí tẹo là token không tương ứng tuyến tính với số _ký tự_, số _byte_ hay số _từ_ trong dữ liệu đầu vào. Và bạn có thể sẽ rất ngạc nhiên khi phát hiện rằng với cùng 1 chuỗi có độ dài tương đương và ý nghĩa tương đồng thì với mỗi ngôn ngữ tự nhiên (tiếng Anh, tiếng Việt, v.v...) sẽ sinh ra lượng token rất khác xa nhau! Do vậy để tính toán chính xác số lượng token không phải đơn giản cộng, trừ, nhân, chia vài con số là ra kết quả.

OpenAI sử dụng phương pháp _mã hoá cặp đôi_ ([Byte pair encoding](https://en.wikipedia.org/wiki/Byte_pair_encoding), viết tắt BPE) để phân tách token từ chuỗi đầu vào. May mắn là có kha khá [thư viện](https://github.com/topics/bpe) bạn có thể sử dụng để thực hiện tách và đếm số lượng token. Nhưng nếu bạn kém may mắn - không có sẵn thư viện trong ngôn ngữ lập trình của bạn để thực hiện việc này thì bạn vẫn có cách để _ước tính_ số lượng token. Bài viết này sẽ trình bày 1 cách tiếp cận cho công thức ước tính số lượng token từ 1 chuỗi đầu vào.

## Cách tiếp cận

Mặc dù không có sự tương đồng tuyến tính giữa lượng token và số _ký tự_, số _byte_ hay số _từ_ trong chuỗi đầu vào, nhưng theo [thông tin từ OpenAI](https://platform.openai.com/tokenizer) thì với tiếng Anh thông dụng: 1 token tương ứng 4 ký tự, hoặc $\frac 3 4$ từ. Như vậy 4 ký tự đầu vào có thể tương ứng với 1 token và 75 từ tương ứng với 100 token. Ta sẽ sử dụng công thức này để ước tính số lượng token từ chuỗi đầu vào:
- $s$ là chuỗi đầu vào.
- tính $t1=\frac{b(s)}{4}$, với $b(s)$ là số lượng byte của chuỗi $s$. <br>Với tiếng Anh thông thường 1 ký tự sẽ tương ứng với 1 byte. Nhưng với nhiều ngôn ngữ khác, khi dùng bảng mã Unicode, 1 ký tự có thể được mã hoá bằng nhiều byte. Do vậy ta sử dụng số byte thay vì số ký tự.
- tính $t2=\frac{4}{3}w(s)+nw(s)$, với:
  - $w(s)$: phân tách $s$ thành các "từ" riêng lẽ. Với mỗi "từ", lấy số byte chia cho 4 và làm tròn lên, cuối cùng cộng dồn kết quả lại với nhau.
  - $nw(s)$ là tổng số byte của các thành phần phi từ (ví dụ như dấu câu, dấu ngoặc, v.v...) trong chuỗi $s$.
- số lượng _token ước tính_ $t=\frac{t1+t2} 2$

Một [phiên bản tham chiếu]((https://gist.github.com/btnguyen2k/2cadc210558714d1646f42a07a4bff5f)) viết bằng Go:
```gh-gist btnguyen2k/2cadc210558714d1646f42a07a4bff5f
```

Kết quả thử nghiệm:
|Đầu vào|Token thực tế (*)|Token ước lượng (**)|Sai số|
|---|:---:|:---:|:---:|
|Tiếng Trung: `第一个是一，第二个是二，第三个是三。`|33|33|0|
|Tiếng Anh: `Number 1 is one, number 2 is two and number 3 is three.`|15|24|9|
|Tiếng Pháp: `Le numéro 1 est un, le numéro 2 est deux et le numéro 3 est trois.`|26|33|7|
|Tiếng Đức: `Nummer 1 ist eins, Nummer 2 ist zwei und Nummer 3 ist drei.`|25|24|-1|
|Tiếng Nhật: `番号1は1で、番号2は2で、番号3は3です。`|28|34|6|
|Tiếng Hàn: `번호 1은 1이고, 번호 2는 2이고, 번호 3은 3입니다.`|51|41|-10|
|Tiếng Lào: `ໝາຍເລກ 1 ແມ່ນຫນຶ່ງ, ໝາຍເລກ 2 ແມ່ນສອງ, ແລະ ໝາຍເລກ 3 ແມ່ນສາມ.`|144|92|-52|
|Tiếng Thái: `หมายเลข 1 คือหนึ่ง หมายเลข 2 คือสอง และหมายเลข 3 คือสาม`|96|89|-7|
|Tiếng Tây Ban Nha: `El número 1 es uno, el número 2 es dos y el número 3 es tres.`|29|32|3|
|Tiếng Việt: `Số 1 là một, số 2 là hai và số 3 là ba`|33|32|-1|

```bs-alert info

(*) Số token thực tế được tính bằng công cụ [tokenizer](https://platform.openai.com/tokenizer) của OpenAI.

(**) Số token ước lượng theo công thức ở trên.
```

## Xem thêm
- Các model của OpenAI và giới hạn token: https://platform.openai.com/docs/models
- Giới hạn token của các model embedding: https://platform.openai.com/docs/guides/embeddings/embedding-models
- Một số thư viện về BPE trên GitHub: https://github.com/topics/bpe
