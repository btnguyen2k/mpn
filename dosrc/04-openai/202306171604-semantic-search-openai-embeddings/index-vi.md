Khác với cách tìm kiếm truyền thống dựa trên từ khoá, tìm kiếm theo ngữ nghĩa (hay còn gọi là tìm kiếm ngữ nghĩa) dựa vào ý định và bối cảnh của câu truy vấn để tìm các tài liệu phù hợp về mặt ý nghĩa. Trong nhiều trường hợp, tìm kiếm ngữ nghĩa trả về các kết quả liên quan và có ý nghĩa hơn so với cách tìm kiếm dựa trên từ khoá.

Ví dụ, khi tìm kiếm về ảnh hưởng của đại dịch COVID-19 lên nền kinh tế, 2 bài báo với tiêu đề _"Lượng khách du lịch giảm mạnh vì đại dịch"_ và _"Covid-19 đã làm cho việc đi lại khó khăn hơn bao giờ hết"_ sẽ có liên quan tới nhau<sup>[*]</sup>. Nhưng rõ ràng 2 tiêu đề bài báo dùng các từ khác nhau hoàn toàn.

Một phương pháp hay dùng hiện nay để xây dựng tính năng tìm kiếm ngữ nghĩa là sử dụng tìm kiếm vec-tơ. Thuật toán có thể tóm tắt như sau:
- Quá trình đánh chỉ mục (index): ngữ nghĩa của tài liệu được chuyển hoá thành 1 vec-tơ gồm N số thực, và lưu vào một cơ sở dữ liệu (CSDL).
- Quá trình tìm kiếm:
  - Đầu tiên câu truy vấn cũng được chuyển hoá thành 1 vec-tơ.
  - Sau đó, vec-tơ câu truy vấn được so sánh với các vec-tơ tài liệu đã được lưu trong CSDL trước đó để lọc ra các tài liệu có liên quan nhất đến câu truy vấn về mặt ý nghĩa.

Một trong các quá trình quan trọng nhất của phương pháp trên là làm thế nào bóc tách được ngữ nghĩa từ 1 đoạn văn bản thành 1 vec-tơ. Bài viết này hướng dẫn sử dụng [embeddings API của OpenAI](https://platform.openai.com/docs/guides/embeddings) để chuyển ngữ nghĩa từ 1 đoạn văn bản thành 1 vec-tơ.

```bs-alert info

[*] Khi sử dụng model `text-embedding-ada-002` để tạo embeddings vector và tính giá trị cosine similarity giữa 2 chuỗi _"Lượng khách du lịch giảm mạnh vì đại dịch"_ và _"Covid-19 đã làm cho việc đi lại khó khăn hơn bao giờ hết"_ ta được kết quả xấp xỉ `82.72%`.
```

## Sử dụng embeddings API của OpenAI

Đầu tiên, bạn cần đăng ký 1 tài khoản ở trang web https://platform.openai.com/, cập nhật thông tin thanh toán ở địa chỉ https://platform.openai.com/account/billing/overview, và tạo 1 API key ở đường dẫn https://platform.openai.com/account/api-keys. Bạn sẽ cần API key để gọi các API của OpenAI.

Sau khi đã có API key, bạn có thể bắt đầu gọi API embeddings của OpenAI để chuyển 1 đoạn văn bản thành vec-tơ:

- Gởi `POST` request đến địa chỉ https://api.openai.com/v1/embeddings.
- Phần body của request là 1 chuỗi JSON gồm tối thiểu 2 tham số:
  - `model`: (string), ID của OpenAI model dùng để tính vec-tơ từ văn bản đầu vào. Vào thời điểm đăng bài viết, OpenAI [khuyến nghị](https://platform.openai.com/docs/guides/embeddings/what-are-embeddings) sử dụng model `text-embedding-ada-002` cho tác vụ này.
  - `input`: (string), đoạn văn bản đầu vào cần chuyển thành vec-tơ.
- API key được truyền theo header `Authorization` để xác thực.

Ví dụ request gọi API
```sh
curl https://api.openai.com/v1/embeddings \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "The food was delicious and the waiter...",
    "model": "text-embedding-ada-002"
  }'
```

Kết quả trả về:
```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [
        0.0023064255,
        -0.009327292,
        .... (1536 số thực nếu sử dụng model ada-002)
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

Tham khảo tài liệu API embeddings của OpenAI tại địa chỉ https://platform.openai.com/docs/api-reference/embeddings
```

## Một số lưu ý và thực hành

**Chọn model thích hợp**: các model khác nhau sẽ có ảnh hưởng trực tiếp hoặc gián tiếp đến chất lượng và hiệu suất của truy vấn tìm kiếm. Vào thời điểm đăng bài viết, OpenAI khuyến nghị sử dụng model `text-embedding-ada-002` với API embeddings, xem chi tiết tại địa chỉ https://platform.openai.com/docs/guides/embeddings/what-are-embeddings

**Chuẩn hoá văn bản** đầu vào trước khi gọi API embeddings có thể giúp tăng chất lượng kết quả tìm kiếm. Tham khảo thêm [tại đây](../../openai/normalization-embeddings/).

**Chia tài liệu dài thành các đoạn văn bản ngắn**: trong trường hợp tài liệu đầu vào vượt quá độ dài cho phép của model, bạn cần phải chia nhỏ tài liệu thành các đoạn văn bản ngắn hơn, và bóc tách vec-tơ ý nghĩa của riêng từng đoạn. Bạn cũng có thể chia tài liệu đầu vào thành các phần nhỏ nếu mỗi phần nhỏ này truyển tải một nội dung khác nhau.

<hr >

_[[do-tag ghissue_comment.vi]]_
