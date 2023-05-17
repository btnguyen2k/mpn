Checksum (_giá trị tổng kiểm_, hay _giá trị kiểm tra_) là một khối dữ liệu có kích thước nhỏ được tạo ra từ khối dữ liệu số khác để _phát hiện ra các lỗi_ có thể đã xảy ra trong quá trình truyền tải hoặc lưu trữ. Checksum thường được sử dụng để _xác minh tính toàn vẹn_ dữ liệu. ([theo Wikipedia](https://en.wikipedia.org/wiki/Checksum))

Tính giá trị checksum của các loại dữ liệu vô hướng như `string` hay `int` trong Go khá đơn giản. Nhưng với các kiểu dữ liệu phức hợp như `map` thì không đơn giản, và với các loại dữ liệu lồng nhau thì còn phức tạp hơn nữa. Bài viết này giới thiệu một phương pháp tính checksum của các loại dữ liệu khác nhau trong Go, bao gồm các loại dữ liệu phức hợp như `slice/array`, `map`, `struct` và các loại dữ liệu lồng nhau.

Trước khi bắt đầu, chúng ta hãy thiết lập một số tiêu chí cho phương pháp tính checksum:

1️⃣ 2 dữ liệu giống nhau có cùng giá trị checksum, 2 dữ liệu khác nhau có giá trị checksum khác nhau (*).

2️⃣ 2 dữ liệu có giá trị giống nhau, nhưng _khác kiểu dữ liệu_ có giá trị checksum khác nhau (*).

3️⃣ a) Thứ tự của field/key trong `map` và `struct` _không ảnh hưởng đến giá trị checksum_. Điều đó có nghĩa là `{"key1": 1, "key2": "value2"}` và `{"key2": "value2", "key1": 1}` có cùng giá trị checksum. b) 2 `map/struct` có cùng value, nhưng khác field/key sẽ có checksum khác nhau. Điều đó có nghĩa là `{"key1": 1, "key2": "value2"}` và `{"k1": 1, "k2": "value2"}` sẽ có giá trị checksum khác nhau (*).

4️⃣ Để đơn giản, ta qui ước:
- a) Các kiểu dữ liệu kiểu số nguyên (`int`, `intN`, `unit` và `unitN`) cùng checksum. Có nghĩa là `int(12)`, `uint(12)`, `int32(12)` và `uint64(12)` có cùng giá trị checksum.
- b) `float32` và `float64` có cùng checksum.
- c) `slice` và `array` có cùng độ dài, và các phần tử hoàn toàn giống nhau sẽ có cùng checksum. Có nghĩa là `[]int{1,2,3}` và `[3]int{1,2,3}` sẽ có cùng giá trị checksum.
- d) Tương tự, `map` và `struct` có field/key và value giống nhau sẽ có cùng giá trị checksum.

```bs-alert warning

(*) Checksum không thể đảm bảo 100% hai khối dữ liệu khác nhau sẽ có giá trị checksum khác nhau. Sẽ có một tỉ lệ (vô cùng nhỏ) hai khối dữ liệu khác nhau vẫn có giá trị checksum giống nhau!
```

## Hàm băm (hash function)

Đầu tiên, chúng ta cần 1 hàm băm. Go đã có sẵn khá nhiều hàm băm để chúng ta sử dụng như `CRC`, `MD5`, `SHA`...Để đơn giản, bài viết này sử dụng `MD5` làm hàm băm. Hàm `MD5` được thiết kế tương tự như sau:

```go
import (
	"crypto/md5"
)

// HashFunc is a function signature that calculates hash value of a byte slice.
type HashFunc func(input []byte) []byte

// Md5 calculates MD5 hash value of a byte slice.
func Md5(input []byte) []byte {
	hf := md5.New()
	hf.Write(input)
	return hf.Sum(nil)
}
```

```bs-alert primary

Để tiện cho việc thay đổi hàm băm trong các dự án thực tế, ta định nghĩa 1 kiểu hàm tổng quát `HashFunc` để tính giá trị băm từ đầu vào.
```

## Các kiểu dữ liệu vô hướng

Để tính giá trị checksum của các kiểu dữ liệu vô hướng như `string`, `bool`, `int`, `uint` và `float`, đầu tiên ta chuyển giá trị cần tính checksum về `[]byte` và tính giá trị băm.

```go
import (
	"bytes"
	"encoding/binary"
	"hash/crc32"
)

func boolToBytes(v bool) []byte {
	if v {
		return []byte{1}
	}
	return []byte{0}
}

func ChecksumBool(hf HashFunc, input bool) []byte {
    return hf(boolToBytes(input))
}

func intToBytes(v int64) []byte {
	buf := new(bytes.Buffer)
	binary.Write(buf, binary.BigEndian, v)
	return buf.Bytes()
}

func ChecksumInt(hf HashFunc, input int64) []byte {
    return hf(intToBytes(input))
}

func uintToBytes(v uint64) []byte {
	buf := new(bytes.Buffer)
	binary.Write(buf, binary.BigEndian, v)
	return buf.Bytes()
}

func ChecksumUint(hf HashFunc, input uint64) []byte {
    return hf(uintToBytes(input))
}

func floatToBytes(v float64) []byte {
	buf := new(bytes.Buffer)
	binary.Write(buf, binary.BigEndian, v)
	return buf.Bytes()
}

func ChecksumFloat(hf HashFunc, input float64) []byte {
    return hf(floatToBytes(input))
}

func ChecksumString(hf HashFunc, input string) []byte {
    return hf([]byte(input))
}

func main() {
	fmt.Printf("Bool  : %x\n", ChecksumBool(Md5, true))  // Bool  : 55a54008ad1ba589aa210d2629c1df41
	fmt.Printf("Int   : %x\n", ChecksumInt(Md5, 1))      // Int   : fa5ad9a8557e5a84cf23e52d3d3adf77
	fmt.Printf("UInt  : %x\n", ChecksumUint(Md5, 1))     // UInt  : fa5ad9a8557e5a84cf23e52d3d3adf77
	fmt.Printf("Float : %x\n", ChecksumFloat(Md5, 1))    // Float : 63e62776bae53524619a3e8dc5c06337
	fmt.Printf("String: %x\n", ChecksumString(Md5, "1")) // String: c4ca4238a0b923820dcc509a6f75849b
}
```

Cách thiết kế hàm như trên sẽ khó triển khai với các kiểu dữ liệu phức hợp như `map` hay kiểu dữ liệu lồng nhau. Ta hãy cải tiến một chút _sử dụng reflection_:

```go
import (
    "reflect"
)

func Checksum(hf HashFunc, v interface{}) []byte {
    rv := reflect.ValueOf(v)
    switch rv.Kind() {
	case reflect.Bool:
		return hf(boolToBytes(rv.Bool()))
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return hf(intToBytes(rv.Int()))
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		return hf(uintToBytes(rv.Uint()))
	case reflect.Float32, reflect.Float64:
		return hf(floatToBytes(rv.Float()))
	case reflect.String:
		return hf([]byte(rv.String()))
    }
    return nil
}

func main() {
	fmt.Printf("Bool   : %x\n", Checksum(Md5, true))       // Bool   : 55a54008ad1ba589aa210d2629c1df41
	fmt.Printf("Int    : %x\n", Checksum(Md5, int16(1)))   // Int    : fa5ad9a8557e5a84cf23e52d3d3adf77
	fmt.Printf("UInt   : %x\n", Checksum(Md5, uint32(1)))  // UInt   : fa5ad9a8557e5a84cf23e52d3d3adf77
	fmt.Printf("Float32: %x\n", Checksum(Md5, float32(1))) // Float32: 63e62776bae53524619a3e8dc5c06337
	fmt.Printf("Float64: %x\n", Checksum(Md5, float64(1))) // Float64: 63e62776bae53524619a3e8dc5c06337
	fmt.Printf("String : %x\n", Checksum(Md5, "1"))        // String : c4ca4238a0b923820dcc509a6f75849b
}
```

Hàm `Checksum` mới của chúng ta có thể thay thế 5 hàm `ChecksumBool`, `ChecksumInt`, `ChecksumUint`, `ChecksumFloat` và `ChecksumString` và đồng thời đáp ứng được các tiêu chí (1), (2), (4a) và (4b).

## Slice và Array

Với `slice` và `array`, ta duyệt qua từng phần tử:
- Tính checksum của phần tử đang duyệt.
- `append` giá trị checksum vừa tính được vào checksum tính ở bước trước đó.
- Tính checksum của slice sau khi append.

Code minh hoạ:

```go
func Checksum(hf HashFunc, v interface{}) []byte {
	rv := reflect.ValueOf(v)
	switch rv.Kind() {
    // xoá bớt các trường hợp khác cho dễ đọc
	case reflect.Array, reflect.Slice:
		buf := make([]byte, 0)
		for i, n := 0, rv.Len(); i < n; i++ {
			buf = hf(append(buf, Checksum(hf, rv.Index(i).Interface())...))
		}
		return buf
	}
	return nil
}

func main() {
	fmt.Printf("Slice  : %x\n", Checksum(Md5, []interface{}{int(1), int8(2), int16(3), int32(4), int64(5)})) // Slice  : 549afaa8b4f3b0b81578efd7e940db3f
	fmt.Printf("Array  : %x\n", Checksum(Md5, [5]uint{1, 2, 3, 4, 5}))                                       // Array  : 549afaa8b4f3b0b81578efd7e940db3f
	fmt.Printf("Strings: %x\n", Checksum(Md5, [5]string{"1", "2", "3", "4", "5"}))                           // Strings: ce5410943f08a401f4d3cc0e42584c82
}
```

Như vậy hàm `Checksum` của chúng ta cũng đã đáp ứng được tiêu chí (4c)

## Map và Struct

Với kiểu dữ liệu `map` và `struct`, ta cũng có thể dùng cách tiếp cận tương tự với `slide/array`: duyệt qua các phần tử, _tính checksum và kết hợp kết quả_ lại để cho ra kết quả cuối cùng. Nhưng lưu ý rằng, các phần tử của `map` và `struct` là _không thứ tự_. Do vậy phải đảm bảo rằng checksum của `{"key1":"value1","key2":"value2"}` phải bằng checksum của `{"key2":"value2","key1":"value1"}`. Một cách để thực hiện là sau khi tính checksum của từng phần tử, ta kết hợp kết quả bằng phép toán `xor`.

Code minh hoạ:

```go
func Checksum(hf HashFunc, v interface{}) []byte {
	rv := reflect.ValueOf(v)
	switch rv.Kind() {
    // xoá bớt các trường hợp khác cho dễ đọc
	case reflect.Map:
		buf := hf([]byte{})
		for iter := rv.MapRange(); iter.Next(); {
			temp := Checksum(hf, []interface{}{iter.Key().Interface(), iter.Value().Interface()})
			for i, n := 0, len(buf); i < n; i++ {
				buf[i] ^= temp[i]
			}
		}
		return buf
	case reflect.Struct:
		buf := hf([]byte{})
		for i, n := 0, rv.NumField(); i < n; i++ {
			fieldName := rv.Type().Field(i).Name
			fieldValue := rv.Field(i)
			temp := Checksum(hf, []interface{}{fieldName, fieldValue.Interface()})
			for i, n := 0, len(buf); i < n; i++ {
				buf[i] ^= temp[i]
			}
		}
		return buf
	}
	return nil
}

func main() {
	type MyStruct struct {
		FieldString string
		FieldInt    int32
		FieldUint   uint64
		FieldFloat  float64
		FieldBool   bool
	}
	myStruct := MyStruct{
		FieldString: "a string",
		FieldInt:    1,
		FieldUint:   2,
		FieldFloat:  3.0,
		FieldBool:   true,
	}
	map1 := map[string]interface{}{
		"FieldString": "a string",
		"FieldInt":    int16(1),
		"FieldUint":   uint32(2),
		"FieldFloat":  float32(3.0),
		"FieldBool":   true,
	}
	map2 := map[string]interface{}{
		"FieldBool":   true,
		"FieldString": "a string",
		"FieldFloat":  float32(3.0),
		"FieldUint":   uint32(2),
		"FieldInt":    int16(1),
	}
	fmt.Printf("Struct: %x\n", Checksum(Md5, myStruct)) // Struct: 930ef85f8ebcdb2e3afc479bd5cd21c0
	fmt.Printf("Map1  : %x\n", Checksum(Md5, map1))     // Map1  : 930ef85f8ebcdb2e3afc479bd5cd21c0
	fmt.Printf("Map2  : %x\n", Checksum(Md5, map2))     // Map2  : 930ef85f8ebcdb2e3afc479bd5cd21c0

	fmt.Printf("Map3  : %x\n", Checksum(Md5, map[string]int{"k1": 1, "k2": 2})) // Map3  : dcd84e7f23760f8b12dff0c0e61c8083
	fmt.Printf("Map4  : %x\n", Checksum(Md5, map[string]int{"K1": 1, "K2": 2})) // Map4  : 2a09f830cceacb0ae1241d0ae3fb30ba
}
```

Hàm `Checksum` của chúng ta cũng đã đáp ứng được tiêu chí (3) và (4d). Như vậy tất cả các tiêu chí đã được đáp ứng.

## Kiểu dữ liệu lồng nhau

Hàm `Checksum` của chúng ta cũng tính được giá trị checksum của các kiểu dữ liệu lồng nhau nhiều cấp:

```go
func main() {
	nested := map[string]interface{}{
		"a": []interface{}{"1", 2, true, map[string]int{"one": 1, "two": 2, "three": 3}},
		"m": map[string]interface{}{
			"s":  "a string",
			"i":  1,
			"b":  true,
			"a2": []int{1, 2, 3},
		},
	}
	fmt.Printf("Nested: %x\n", Checksum(Md5, nested)) // b00b52e0392588c034ee103d01c8cb39
}
```

## Trước khi kết thúc

Chúng ta đã có được một phương pháp tính giá trị checksum các kiểu dữ liệu từ đơn giản để phức tạp trong Go. Tuy còn một vài trường hợp chúng ta chưa xử lý như kiểu dữ liệu _pointer_ hoặc các _field không export_ của `struct`, nhưng các phần này không quá khó để bạn tự thực hiện.

Hoặc bạn có thể sử dụng [thư viện checksum](https://github.com/btnguyen2k/consu/tree/master/checksum) tôi đã viết sẵn.

<hr>

_[[do-tag ghissue_comment.vi]]_
