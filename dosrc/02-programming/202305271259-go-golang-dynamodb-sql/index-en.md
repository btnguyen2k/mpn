[Amazon DynamoDB](https://aws.amazon.com/dynamodb/) is a fully managed NoSQL database service provided by Amazon as part of the Amazon Web Services (AWS) portfolio.

- AWS offers the [SDK for Go](https://github.com/aws/aws-sdk-go-v2), which facilitates seamless integration between Go applications and various AWS services, including DynamoDB.
- AWS provides users with the flexibility to utilize [PartiQL](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.html#ql-reference.what-is), a SQL-like query language, for efficient manipulation of DynamoDB items via operations such as `INSERT`, `SELECT`, `UPDATE`, and `DELETE`.
- The Go programming language includes the [`database/sql` package](https://pkg.go.dev/database/sql), which offers a versatile and standardized interface for interacting with SQL databases or databases that support SQL-like functionality. 

To establish a seamless integration between the three components mentioned earlier, an essential component is required: a database driver that enables Go applications to interface with DynamoDB using the standard `database/sql` package. This blog post introduces [godynamo](https://github.com/btnguyen2k/godynamo) - a `database/sql` driver for AWS DynamoDB.

```bs-alert primary

Disclaimer: I am the author of [godynamo](https://github.com/btnguyen2k/godynamo).
```

## Usage

Utilizing [godynamo](https://github.com/btnguyen2k/godynamo) to interact with AWS DynamoDB follows a familiar pattern akin to employing any `database/sql` driver for a database system, for example MySQL. The process involves a sequence of steps: first, importing the [godynamo](https://github.com/btnguyen2k/godynamo) driver into the project; next, initializing a `sql.DB` instance through using the `sql.Open(...)` function; and lastly, leveraging SQL statements to operate on the items within the DynamoDB table via the `sql.DB` instance.

Example:

```go
package main

import (
	"database/sql"
	"fmt"

	_ "github.com/btnguyen2k/gocosmos" // import driver
)

func main() {
    // build connection string
	driver := "godynamo"
	dsn := "Region=us-east-1;AkId=aws-access-key-id;SecretKey=aws-secret-key"
    // create the sql.DB instance
	db, err := sql.Open(driver, dsn)
	if err != nil {
		panic(err)
	}
	defer db.Close()

    // use SQL statement via the sql.DB instance
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

## Supported SQL statements

[godynamo](https://github.com/btnguyen2k/godynamo) supports 3 groups of SQL statements: _table_, _index_ and _document_.

#### Table-related statement:

**<i class="bi bi-filetype-sql"></i> `CREATE TABLE`: create a new DynamoDB table.**

Syntax:
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

Example:
```go
result, err := db.Exec(`CREATE TABLE demo WITH PK=id:string WITH rcu=3 WITH wcu=5`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `LIST TABLES`: list all available tables.**

Syntax:
```sql
LIST TABLES
```

Example:
```go
dbrows, err := db.Query(`LIST TABLES`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|$1      |
|--------|
|tbltest0|
|tbltest1|
|tbltest2|
|tbltest3|

**<i class="bi bi-filetype-sql"></i> `DESCRIBE TABLE`: return info of a table.**

Syntax:
```sql
DESCRIBE TABLE <table-name>
```

Example:
```go
dbrows, err := db.Query(`DESCRIBE TABLE demo`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|ArchivalSummary|AttributeDefinitions|BillingModeSummary|CreationDateTime|DeletionProtectionEnabled|GlobalSecondaryIndexes|GlobalTableVersion|ItemCount|KeySchema|LatestStreamArn|LatestStreamLabel|LocalSecondaryIndexes|ProvisionedThroughput|Replicas|RestoreSummary|SSEDescription|StreamSpecification|TableArn|TableClassSummary|TableId|TableName|TableSizeBytes|TableStatus|
|---------------|--------------------|------------------|----------------|-------------------------|----------------------|------------------|---------|---------|---------------|-----------------|---------------------|---------------------|--------|--------------|--------------|-------------------|--------|-----------------|-------|---------|--------------|-----------|
|null|[{"AttributeName":"app","AttributeType":"S"},{"AttributeName":"user","AttributeType":"S"},{"AttributeName":"timestamp","AttributeType":"N"},{"AttributeName":"browser","AttributeType":"S"},{"AttributeName":"os","AttributeType":"S"}]|{"BillingMode":"PAY_PER_REQUEST","LastUpdateToPayPerRequestDateTime":"2023-05-23T01:58:27.352Z"}|"2023-05-23T01:58:27.352Z"|null|null|null|0|[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"user","KeyType":"RANGE"}]|null|null|[{"IndexArn":"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp/index/idxos","IndexName":"idxos","IndexSizeBytes":0,"ItemCount":0,"KeySchema":[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"os","KeyType":"RANGE"}],"Projection":{"NonKeyAttributes":["os_name","os_version"],"ProjectionType":"INCLUDE"}},{"IndexArn":"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp/index/idxbrowser","IndexName":"idxbrowser","IndexSizeBytes":0,"ItemCount":0,"KeySchema":[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"browser","KeyType":"RANGE"}],"Projection":{"NonKeyAttributes":null,"ProjectionType":"ALL"}},{"IndexArn":"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp/index/idxtime","IndexName":"idxtime","IndexSizeBytes":0,"ItemCount":0,"KeySchema":[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"timestamp","KeyType":"RANGE"}],"Projection":{"NonKeyAttributes":null,"ProjectionType":"KEYS_ONLY"}}]|{"LastDecreaseDateTime":"1970-01-01T00:00:00Z","LastIncreaseDateTime":"1970-01-01T00:00:00Z","NumberOfDecreasesToday":0,"ReadCapacityUnits":0,"WriteCapacityUnits":0}|null|null|null|null|"arn:aws:dynamodb:ddblocal:000000000000:table/tbltemp"|null|null|"tbltemp"|0|"ACTIVE"|

**<i class="bi bi-filetype-sql"></i> `ALTER TABLE`: change a table's RCU/WCU or table-class.**

Syntax:
```sql
ALTER TABLE <table-name>
[WITH wcu=<number>[,] WITH rcu=<number>]
[[,] WITH CLASS=<table-class>]
```

Example:
```go
result, err := db.Exec(`ALTER TABLE demo WITH rcu=5 WITH wcu=7`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `DROP TABLE`: remove an existing table.**

Syntax:
```sql
DROP TABLE [IF EXIST] <table-name>
```

Example:
```go
result, err := db.Exec(`DROP TABLE IF EXISTS demo`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

```bs-alert info

Find more details on godynamo repository: https://github.com/btnguyen2k/godynamo.
```

#### Index-related statements:

**<i class="bi bi-filetype-sql"></i> `DESCRIBE LSI`: return info of a `Local Secondary Index`.**

Syntax:
```sql
DESCRIBE LSI <index-name> ON <table-name>
```

Example:
```go
dbrows, err := db.Query(`DESCRIBE LSI idxos ON session`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|IndexArn|IndexName|IndexSizeBytes|ItemCount|KeySchema|Projection|
|--------|---------|--------------|---------|---------|----------|
|"arn:aws:dynamodb:ddblocal:000000000000:table/session/index/idxos"|"idxos"|0|0|[{"AttributeName":"app","KeyType":"HASH"},{"AttributeName":"os","KeyType":"RANGE"}]|{"NonKeyAttributes":["os_name","os_version"],"ProjectionType":"INCLUDE"}|

**<i class="bi bi-filetype-sql"></i> `CREATE GSI`: create a new `Global Secondary Index` on a table.**

Syntax:
```sql
CREATE GSI [IF NOT EXISTS] <index-name> ON <table-name>
<WITH PK=pk-attr-name:data-type>
[[,] WITH SK=sk-attr-name:data-type]
[[,] WITH wcu=<number>[,] WITH rcu=<number>]
[[,] WITH projection=*|attr1,attr2,attr3,...]
```

Example:
```go
result, err := db.Exec(`CREATE GSI idxname ON tablename WITH pk=grade:number, WITH rcu=1 WITH wru=2`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `DESCRIBE GSI`: return info of a `Global Secondary Index`.**

Syntax:
```sql
DESCRIBE GSI <index-name> ON <table-name>
```

Example:
```go
dbrows, err := db.Query(`DESCRIBE GSI idxos ON session`)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|Backfilling|IndexArn|IndexName|IndexSizeBytes|IndexStatus|ItemCount|KeySchema|Projection|ProvisionedThroughput|
|-----------|--------|---------|--------------|-----------|---------|---------|----------|---------------------|
|null|"arn:aws:dynamodb:ddblocal:000000000000:table/session/index/idxbrowser"|"idxbrowser"|0|"ACTIVE"|0|[{"AttributeName":"browser","KeyType":"HASH"}]|{"NonKeyAttributes":null,"ProjectionType":"ALL"}|{"LastDecreaseDateTime":null,"LastIncreaseDateTime":null,"NumberOfDecreasesToday":null,"ReadCapacityUnits":1,"WriteCapacityUnits":1}|

**<i class="bi bi-filetype-sql"></i> `ALTER GSI`: change RCU/WCU settings of a `Global Secondary Index`.**

Syntax:
```sql
ALTER GSI <index-name> ON <table-name>
WITH wcu=<number>[,] WITH rcu=<number>
```

Exampe:
```go
result, err := db.Exec(`ALTER GSI idxname ON tablename WITH rcu=1 WITH wru=2`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `DROP GSI`: remove an existing `Global Secondary Index`.**

Syntax:
```sql
DROP GSI [IF EXIST] <index-name> ON <table-name>
```

Example:
```go
result, err := db.Exec(`DROP GSI IF EXISTS index ON table`)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

```bs-alert info

Find more details on godynamo repository: https://github.com/btnguyen2k/godynamo.
```

#### Document-related statements:

**<i class="bi bi-filetype-sql"></i> `INSERT`: add an item to a table.**

Syntax: see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.insert.html

Example:
```go
result, err := db.Exec(`INSERT INTO "session" VALUE {'app': ?, 'user': ?, 'active': ?}`, "frontend", "user1", true)
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

**<i class="bi bi-filetype-sql"></i> `SELECT`: retrieve data from a table.**

Syntax: see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.select.html

Example:
```go
dbrows, err := db.Query(`SELECT * FROM "session" WHERE app='frontend' `)
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|active|app|user|
|------|---|----|
|true|"frontend"|"user1"|

**<i class="bi bi-filetype-sql"></i> `UPDATE`: modify the value of one or more attributes within an item in a table.**

Syntax: see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.update.html

Example:
```go
result, err := db.Exec(`UPDATE "tbltest" SET location=? SET os=? WHERE "app"=? AND "user"=?`, "VN", "Ubuntu", "app0", "user1")
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

`db.Query(...)` can also be used to obtain the returned values:
```go
dbrows, err := db.Query(`UPDATE "tbltest" SET location=? SET os=? WHERE "app"=? AND "user"=? RETURNING MODIFIED OLD *`, "VN", "Ubuntu", "app0", "user0")
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|location|
|--------|
|"AU"    |

**<i class="bi bi-filetype-sql"></i> `DELETE`: delete an existing item from a table.**

Syntax: see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.delete.html

Example:
```go
result, err := db.Exec(`DELETE FROM "tbltest" WHERE "app"=? AND "user"=?`, "app0", "user1")
if err == nil {
	numAffectedRow, err := result.RowsAffected()
	...
}
```

`db.Query(...)` can also be used to obtain the returned values:
```go
dbrows, err := db.Query(`DELETE FROM "tbltest" WHERE "app"=? AND "user"=? RETURNING ALL OLD *`, "app0", "user1")
if err == nil {
	fetchAndPrintAllRows(dbrows)
}
```

Result:
|app|location|platform|user|
|---|--------|--------|----|
|"app0"|"AU"|"Windows"|"user1"|

```bs-alert info

Find more details on godynamo repository: https://github.com/btnguyen2k/godynamo.
```

<hr/>

```bs-alert warning

Disclaimer: I utilized ChatGPT to proofread and rephrase certain sections of this post.
```

_[[do-tag ghissue_comment.en]]_
