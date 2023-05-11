Các mô hình trí tuệ nhân tạo của OpenAI hiểu và xử lý văn bản bằng cách phân tách nó thành các token<sup>[1]</sup>. Bộ phân tích cú pháp của OpenAI dựa vào 1 bảng mã hoá (encoding) để tách chuỗi văn bản thành các token; và theo một [tài liệu của OpenAI](https://github.com/openai/openai-cookbook/blob/7d418b9bf2b5546b2e8e2e3e2a1813ec5d939540/examples/How_to_count_tokens_with_tiktoken.ipynb) các mô hình sử dụng các bảng mã hoá khác nhau cho việc này, cụ thể như sau:

| Bảng mã hoá | Mô hình OpenAI |
|---|---|
| `cl100k_base` | `gpt-4`, `gpt-3.5-turbo`, `text-embedding-ada-002` |
| `p50k_base` | Các mô hình Codex, `text-davinci-002`, `text-davinci-003` |
| `r50k_base` (hoặc `gpt2`) | Các mô hình của GPT-3 như `davinci` |

```bs-alert info

[1] https://platform.openai.com/docs/introduction/tokens
```

Như vậy, liệu các mô hình khác nhau của OpenAI, chính xác hơn là với các bảng mã hoá khác nhau, số lượng token phân tách từ cùng 1 chuỗi nhập vào có khác nhau hay không? Tôi cũng rất tò mò muốn biết, và một cách để biết được điều đó là hãy thử nghiệm thực tế.

## Thử nghiệm

Tôi viết 1 đoạn chương trình dùng các bảng mã hoã khác nhau (`cl100k_base`, `p50k_base` và `r50k_base`) để đếm số token<sup>[2][3]</sup> của cùng một đoạn văn bản, ở các ngôn ngữ tự nhiên khác nhau<sup>[4]</sup>.
```bs-tabs
    [[bs-tab Tiếng Anh
    OpenAI is an American artificial intelligence (AI) research laboratory consisting of the non-profit OpenAI Incorporated and its for-profit subsidiary corporation OpenAI Limited Partnership. OpenAI conducts AI research with the declared intention of promoting and developing a friendly AI. OpenAI systems run on an Azure-based supercomputing platform from Microsoft.

    OpenAI was founded in 2015 by Ilya Sutskever, Greg Brockman, Trevor Blackwell, Vicki Cheung, Andrej Karpathy, Durk Kingma, John Schulman, Pamela Vagata, and Wojciech Zaremba, with Sam Altman and Elon Musk serving as the initial board members. Microsoft provided OpenAI LP with a \$1 billion investment in 2019 and a \$10 billion investment in 2023.
    ]]

    [[bs-tab Tiếng Việt
    OpenAI là một phòng thí nghiệm nghiên cứu trí tuệ nhân tạo (AI) của Mỹ bao gồm tổ chức phi lợi nhuận OpenAI Incorporated (OpenAI Inc.) và công ty con hoạt động vì lợi nhuận OpenAI Limited Partnership (OpenAI LP). OpenAI tiến hành nghiên cứu AI với mục đích đã tuyên bố là thúc đẩy và phát triển một AI thân thiện. Các hệ thống OpenAI chạy trên siêu máy tính mạnh thứ năm trên thế giới. Tổ chức được thành lập tại San Francisco vào năm 2015 bởi Sam Altman, Reid Hoffman, Jessica Livingston, Elon Musk, Ilya Sutskever, Peter Thiel và những người khác. Musk đã từ chức khỏi hội đồng quản trị vào năm 2018 nhưng vẫn là một nhà tài trợ. Microsoft đã cung cấp cho OpenAI LP khoản đầu tư 1 tỷ USD vào năm 2019 và khoản đầu tư thứ hai trong nhiều năm vào tháng 1 năm 2023, được báo cáo là 10 tỷ USD.
    ]]

    [[bs-tab Tiếng Pháp
    OpenAI (« AI » pour artificial intelligence, ou intelligence artificielle) est une entreprise spécialisée dans le raisonnement artificiel, à « but lucratif plafonné », dont le siège social est à San Francisco. Avant mars 2019, elle est reconnue association à but non lucratif. L'objectif de cette société est de promouvoir et de développer un raisonnement artificiel à visage humain qui profitera à toute l'humanité. Grâce à un fonds initial de 100 millions de dollars, OpenAI cherche à s'associer à quelques startups utilisant le raisonnement artificiel pour avoir un effet transformateur, par exemple dans les domaines des soins de santé, du changement climatique et de l'éducation et « où les outils d'IA peuvent autonomiser les gens en les aidant à être plus productifs ».

    En 2023, la société OpenAI est valorisée à 29 milliards de dollars américains.
    ]]

    [[bs-tab Tiếng Trung
    OpenAI（开放人工智能）是美國一個人工智能研究實驗室，由非營利組織OpenAI Inc，和其營利組織子公司OpenAI LP所組成。OpenAI 進行 AI 研究的目的是促進和发展友好的人工智能，使人类整体受益。 OpenAI 系統運行在微軟基於 Azure 的超級計算平台上。該組織於2015年由萨姆·阿尔特曼、里德·霍夫曼、Jessica Livingston、伊隆·马斯克、伊爾亞·蘇茨克維、沃伊切赫·扎伦巴 (Wojciech Zaremba)、彼得·泰爾 等人在旧金山成立，他們共同認捐了$10億美元。 微軟在2019年向 OpenAI LP 提供了$10億美元的投資，並在2023年1月向其提供了第二筆多年投資，據報導為$100億美元， 用於獨家訪問GPT-4，這將為微軟自己的Bing Prometheus 模型提供支持。
    ]]

    [[bs-tab Tiếng Nhật
    OpenAI（オープンエーアイ、オープンAI）とは、営利法人OpenAI LPとその親会社である非営利法人OpenAI Inc. からなるアメリカの人工知能（AI）の開発を行っている企業である。人類全体に利益をもたらす汎用人工知能（AGI）を普及・発展させることを目標に掲げ、AI分野の研究を行っている。

    OpenAIは、サンフランシスコのミッション地区（英語版）にあるパイオニア・ビル（英語版）に本社を構えている。
    ]]

    [[bs-tab Tiếng Hàn
    오픈AI(OpenAI)는 프렌들리 AI를 제고하고 개발함으로써 전적으로 인류에게 이익을 주는 것을 목표로 하는 미국의 인공지능 연구소이다. 이윤을 목적으로 하는 기업 OpenAI LP와 그 모체 조직인 비영리 단체 OpenAI Inc로 구성되어 있다. 이 단체의 목적은 특허와 연구를 대중에 공개함으로써 다른 기관들 및 연구원들과 자유로이 협업하는 것이다. 설립자들(특히 일론 머스크, 샘 올트먼)은 인공 지능의 존재 문제의 염려에 부분적으로 동기를 받았다.
    ]]
```

```bs-alert info

[2] Thư viện [tiktoken-go/tokenizer](https://github.com/tiktoken-go/tokenizer) được dùng để phân tách token.

[3] Source code của chương trình được upload lên Gist [btnguyen2k/6da01c72bd86b2de8c9a30b5ad35fd71](https://gist.github.com/btnguyen2k/6da01c72bd86b2de8c9a30b5ad35fd71).

[4] Đoạn văn bản trong thử nghiệm này được lấy từ [trang wikipedia](https://en.wikipedia.org/wiki/OpenAI).
```

## Kết quả

| Ngôn ngữ  |Bảng mã hoá | Token  |
|-----------|------------|:------:|
| Tiếng Anh | cl100k_base| **161**|
| Tiếng Anh |   p50k_base|     163|
| Tiếng Anh |   r50k_base|     163|
|Tiếng Việt | cl100k_base| **328**|
|Tiếng Việt |   p50k_base|     558|
|Tiếng Việt |   r50k_base|     558|
|Tiếng Pháp | cl100k_base| **222**|
|Tiếng Pháp |   p50k_base|     267|
|Tiếng Pháp |   r50k_base|     267|
|Tiếng Trung| cl100k_base| **384**|
|Tiếng Trung|   p50k_base|     555|
|Tiếng Trung|   r50k_base|     555|
|Tiếng Nhật | cl100k_base| **200**|
|Tiếng Nhật |   p50k_base|     277|
|Tiếng Nhật |   r50k_base|     277|
|Tiếng Hàn  | cl100k_base| **226**|
|Tiếng Hàn  |   p50k_base|     500|
|Tiếng Hàn  |   r50k_base|     500|

Kết quả thử nghiệm cho thấy bảng mã hoá `p50k_base` và `r50k_base` cho _kết quả tương đồng_ nhau. Trong khi đó, bảng mã `cl100k_base` (được dùng bởi các mô hình `gpt-4`, `gpt-3.5-turbo` và `text-embedding-ada-002`) trả về số lượng token _thấp hơn_. Lượng token _giảm đi đáng kể_ với các ngôn ngữ tiếng Nhật (_28%_), tiếng Trung (_31%_), tiếng Việt (_41%_) và tiếng Hàn (_55%_).

<hr>

_[[do-tag ghissue_comment.vi]]_
