[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) là một dịch vụ cơ sở dữ liệu NoSQL được cung cấp bởi Amazon, là một phần trong danh mục các dịch vụ của Amazon Web Services (AWS).

- AWS cung cấp bộ [SDK cho Go](https://github.com/aws/aws-sdk-go-v2) giúp các ứng dụng Go giao tiếp với các dịch vụ của AWS, bao gồm DynamoDB.
- AWS cũng cho phép người dùng sử dụng [PartiQL](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.html#ql-reference.what-is) để thao tác với các table của DynamoDB thông qua các câu lệnh SQL quen thuộc như `INSERT`, `SELECT`, `UPDATE` hay `DELETE`.
- Go thiết kế [package `database/sql`](https://pkg.go.dev/database/sql), cung cấp một API chung để ứng dụng giao tiếp với các hệ cơ sở dữ liệu hỗ trợ SQL.

Chúng ta còn thiếu 1 nhân tố nữa để kết nối 3 thành phần trên với nhau: một driver để ứng dụng Go có thể giao tiếp với DynamoDB thông qua package `database/sql`. Bài viết này giới thiệu [godynamo](https://github.com/btnguyen2k/godynamo), một `database/sql` driver cho AWS DynamoDB.

## Cách sử dụng

Sử dụng [godynamo](https://github.com/btnguyen2k/godynamo) để giao tiếp với AWS DynamoDB cũng tương tự như sử dụng 1 driver `database/sql` giao tiếp với CSDL như MySQL: đầu tiên, bạn cần import driver; kế tiếp, khởi tạo `sql.DB` với `sql.Open(...)`; và cuối cùng là sử dụng các câu lệnh SQL để thao tác với dữ liệu.

Ví dụ:

```go
package main

import (
	"database/sql"
	"fmt"

	_ "github.com/btnguyen2k/gocosmos" // import driver
)

func main() {
    // khởi tạo connection string
	driver := "godynamo"
	dsn := "Region=us-east-1;AkId=aws-access-key-id;SecretKey=aws-secret-key"
    // tạo connection đến AWS DynamoDB
	db, err := sql.Open(driver, dsn)
	if err != nil {
		panic(err)
	}
	defer db.Close()

    // bắt đầu sử dụng SQL để thao tác với dữ liệu
	dbrows, err := db.Query(`LIST TABLES`)
	if err != nil {
		panic(err)
	}
	for dbRows.Next() {
		var val interface{}
		err := dbRows.Scan(&val)
		if err != nil {
			panic(err)
		}
		fmt.Println(val)
	}
}
```

## Các lệnh SQL được hỗ trợ

[godynamo](https://github.com/btnguyen2k/godynamo) hỗ trợ 3 nhóm lệnh về _table_, _index_ và _document_.

#### Các lệnh về table:

**<i class="bi bi-filetype-sql"></i> `CREATE TABLE`: tạo một table mới.**

Cú pháp:
```sql
CREATE TABLE [IF NOT EXIST] <table-name>
WITH PK=<partition-key-name>:<data-type>
[[,] WITH SK=<sort-key-name>:<data-type>]
[[,] WITH wcu=<number>[,] WITH rcu=<number>]
[[,] WITH LSI=index-name1:attr-name1:data-type]
[[,] WITH LSI=index-name2:attr-name2:data-type:*]
[[,] WITH LSI=index-name2:attr-name2:data-type:nonKeyAttr1,nonKeyAttr2,nonKeyAttr3,...]
[[,] WITH LSI...]
[[,] WITH CLASS=<table-class>]
```

Ví dụ:
```go
result, err := db.Exec(`CREATE TABLE demo WITH PK=id:string WITH rcu=3 WITH wcu=5`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `LIST TABLES`: liệt kê danh sách các table đang có trong database.**

Cú pháp:
```sql
LIST TABLES
```

Ví dụ:
```go
dbrows, err := db.Query(`LIST TABLES`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|$1      |
|--------|
|tbltest0|
|tbltest1|
|tbltest2|
|tbltest3|

**<i class="bi bi-filetype-sql"></i> `DESCRIBE TABLE`: trả về thông tin của 1 table.**

Cú pháp:
```sql
DESCRIBE TABLE <table-name>
```

Ví dụ:
```go
dbrows, err := db.Query(`DESCRIBE TABLE demo`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|ArchivalSummary|AttributeDefinitions|BillingModeSummary|CreationDateTime|DeletionProtectionEnabled|GlobalSecondaryIndexes|GlobalTableVersion|ItemCount|KeySchema|LatestStreamArn|LatestStreamLabel|LocalSecondaryIndexes|ProvisionedThroughput|Replicas|RestoreSummary|SSEDescription|StreamSpecification|TableArn|TableClassSummary|TableId|TableName|TableSizeBytes|TableStatus|
|---------------|--------------------|------------------|----------------|-------------------------|----------------------|------------------|---------|---------|---------------|-----------------|---------------------|---------------------|--------|--------------|--------------|-------------------|--------|-----------------|-------|---------|--------------|-----------|
|null|[{"AttributeName":"app","AttributeType":"S"},{"AttributeName":"user","AttributeType":"S"},{"AttributeName":"timestamp","AttributeType":"N"},{"AttributeName":"browser","AttributeType":"S"},{"AttributeName":"os","AttributeType":"S"}]|{"BillingMode":"PAY_PER_REQUEST","LastUpdateToPayPerRequestDateTime":"2023-05-23T01:58:27.352Z"}|"2023-05-23T01:58:27.352Z"|null|null|null|0|[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"user","KeyType":"RANGE"}]|null|null|[{"IndexArn":"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp/index/idxos","IndexName":"idxos","IndexSizeBytes":0,"ItemCount":0,"KeySchema":[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"os","KeyType":"RANGE"}],"Projection":{"NonKeyAttributes":["os_name","os_version"],"ProjectionType":"INCLUDE"}},{"IndexArn":"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp/index/idxbrowser","IndexName":"idxbrowser","IndexSizeBytes":0,"ItemCount":0,"KeySchema":[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"browser","KeyType":"RANGE"}],"Projection":{"NonKeyAttributes":null,"ProjectionType":"ALL"}},{"IndexArn":"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp/index/idxtime","IndexName":"idxtime","IndexSizeBytes":0,"ItemCount":0,"KeySchema":[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"timestamp","KeyType":"RANGE"}],"Projection":{"NonKeyAttributes":null,"ProjectionType":"KEYS_ONLY"}}]|{"LastDecreaseDateTime":"1970-01-01T00:00:00Z","LastIncreaseDateTime":"1970-01-01T00:00:00Z","NumberOfDecreasesToday":0,"ReadCapacityUnits":0,"WriteCapacityUnits":0}|null|null|null|null|"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp"|null|null|"tbltemp"|0|"ACTIVE"|

**<i class="bi bi-filetype-sql"></i> `ALTER TABLE`: cập nhật thông số RCU/WCU hoặc table-class của 1 table.**

Cú pháp:
```sql
ALTER TABLE <table-name>
[WITH wcu=<number>[,] WITH rcu=<number>]
[[,] WITH CLASS=<table-class>]
```

Ví dụ:
```go
result, err := db.Exec(`ALTER TABLE demo WITH rcu=5 WITH wcu=7`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `DROP TABLE`: xoá 1 table.**

Cú pháp:
```sql
DROP TABLE [IF EXIST] <table-name>
```

Ví dụ:
```go
result, err := db.Exec(`DROP TABLE IF EXISTS demo`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

```bs-alert info

Xem thêm tài liệu của godynamo tại địa chỉ https://github.com/btnguyen2k/godynamo
```

#### Các lệnh về index:

**<i class="bi bi-filetype-sql"></i> `DESCRIBE LSI`: trả về thông tin của 1 `Local Secondary Index`.**

Cú pháp:
```sql
DESCRIBE LSI <index-name> ON <table-name>
```

Ví dụ:
```go
dbrows, err := db.Query(`DESCRIBE LSI idxos ON session`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|IndexArn|IndexName|IndexSizeBytes|ItemCount|KeySchema|Projection|
|--------|---------|--------------|---------|---------|----------|
|"arn:aws:dynamodb:ddblocal:000000000000:table/session/index/idxos"|"idxos"|0|0|[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"os","KeyType":"RANGE"}]|{"NonKeyAttributes":["os_name","os_version"],"ProjectionType":"INCLUDE"}|

**<i class="bi bi-filetype-sql"></i> `CREATE GSI`: tạo 1 `Global Secondary Index` trên 1 table.**

Cú pháp:
```sql
CREATE GSI [IF NOT EXISTS] <index-name> ON <table-name>
<WITH PK=pk-attr-name:data-type>
[[,] WITH SK=sk-attr-name:data-type]
[[,] WITH wcu=<number>[,] WITH rcu=<number>]
[[,] WITH projection=*|attr1,attr2,attr3,...]
```

Ví dụ:
```go
result, err := db.Exec(`CREATE GSI idxname ON tablename WITH pk=grade:number, WITH rcu=1 WITH wru=2`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `DESCRIBE GSI`: trả về thông tin của 1 `Global Secondary Index`.**

Cú pháp:
```sql
DESCRIBE GSI <index-name> ON <table-name>
```

Ví dụ:
```go
dbrows, err := db.Query(`DESCRIBE GSI idxos ON session`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|Backfilling|IndexArn|IndexName|IndexSizeBytes|IndexStatus|ItemCount|KeySchema|Projection|ProvisionedThroughput|
|-----------|--------|---------|--------------|-----------|---------|---------|----------|---------------------|
|null|"arn:aws:dynamodb:ddblocal:000000000000:table/session/index/idxbrowser"|"idxbrowser"|0|"ACTIVE"|0|[{"AttributeName":"browser","KeyType":"HASH"}]|{"NonKeyAttributes":null,"ProjectionType":"ALL"}|{"LastDecreaseDateTime":null,"LastIncreaseDateTime":null,"NumberOfDecreasesToday":null,"ReadCapacityUnits":1,"WriteCapacityUnits":1}|

**<i class="bi bi-filetype-sql"></i> `ALTER GSI`: cập nhật thông số RCU/WCU 1 `Global Secondary Index`.**

Cú pháp:
```sql
ALTER GSI <index-name> ON <table-name>
WITH wcu=<number>[,] WITH rcu=<number>
```

Ví dụ:
```go
result, err := db.Exec(`ALTER GSI idxname ON tablename WITH rcu=1 WITH wru=2`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `DROP GSI`: xoá 1 `Global Secondary Index`.**

Cú pháp:
```sql
DROP GSI [IF EXIST] <index-name> ON <table-name>
```

Ví dụ:
```go
result, err := db.Exec(`DROP GSI IF EXISTS index ON table`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

```bs-alert info

Xem thêm tài liệu của godynamo tại địa chỉ https://github.com/btnguyen2k/godynamo
```

#### Các lệnh về document:

**<i class="bi bi-filetype-sql"></i> `INSERT`: thêm 1 tài liệu vào table.**

Cú pháp: xem https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.insert.html

Ví dụ:
```go
result, err := db.Exec(`INSERT INTO "session" VALUE {'app': ?, 'user': ?, 'active': ?}`, "frontend", "user1", true)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `SELECT`: lấy các tài liệu từ table theo điều kiện lọc.**

Cú pháp: xem https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.select.html

Ví dụ:
```go
dbrows, err := db.Query(`SELECT * FROM "session" WHERE app='frontend'`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|active|app|user|
|------|---|----|
|true|"frontend"|"user1"|

**<i class="bi bi-filetype-sql"></i> `UPDATE`: thay đổi dữ liệu các trường thông tin của 1 tài liệu trong table.**

Cú pháp: xem https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.update.html

Ví dụ:
```go
result, err := db.Exec(`UPDATE "tbltest" SET location=? SET os=? WHERE "app"=? AND "user"=?`, "VN", "Ubuntu", "app0", "user1")
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

Có thể sử dụng `db.Query(...)` để lấy thông tin trả về sau khi thực thi câu lệnh `UPDATE`:
```go
dbrows, err := db.Query(`UPDATE "tbltest" SET location=? SET os=? WHERE "app"=? AND "user"=? RETURNING MODIFIED OLD *`, "VN", "Ubuntu", "app0", "user0")
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|location|
|--------|
|"AU"    |

**<i class="bi bi-filetype-sql"></i> `DELETE`: xoá 1 tài liệu trong table theo điều kiện lọc.**

Cú pháp: xem https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.delete.html

Ví dụ:
```go
result, err := db.Exec(`DELETE FROM "tbltest" WHERE "app"=? AND "user"=?`, "app0", "user1")
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

Có thể sử dụng `db.Query(...)` để lấy thông tin trả về sau khi thực thi câu lệnh `DELETE`:
```go
dbrows, err := db.Query(`DELETE FROM "tbltest" WHERE "app"=? AND "user"=? RETURNING ALL OLD *`, "app0", "user1")
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Kết quả:
|app|location|platform|user|
|---|--------|--------|----|
|"app0"|"AU"|"Windows"|"user1"|

```bs-alert info

Xem thêm tài liệu của godynamo tại địa chỉ https://github.com/btnguyen2k/godynamo
```

<hr>

_[[do-tag ghissue_comment.vi]]_
