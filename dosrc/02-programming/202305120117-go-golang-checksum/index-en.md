A checksum is a small-sized block of data derived from another block of digital data for the purpose of detecting errors that may have been introduced during its transmission or storage. By themselves, checksums are often used to verify data integrity. ([Wikipedia](https://en.wikipedia.org/wiki/Checksum))

Calculating the checksum value of scalar data types such as `string` or `int` in Go is quite straightforward. However, for more intricate data types, like `map`, the operation is nontrivial, and for nested data types, it is even more complex. This post introduces an implementation for computing the checksum value for various data types in Go, which includes complex data types like `slice/array`, `map`, `struct`, as well as nested data types.

Before we start, let's establish some criteria for the checksum calculation implementation:

1️⃣ Two identical data have the same checksum value, and two different data have different checksums (*).

2️⃣ Two data with the same value but different data types have different checksum values (*).

3️⃣ a) The order of fields/keys in `map` and `struct` does not affect the checksum value. This means that `{"key1": 1, "key2": "value2"}` and `{"key2": "value2", "key1": 1}` have the same checksum value. b) Two `map/struct` with the same values but different `fields/keys` have different checksums. This means that `{"key1": 1, "key2": "value2"}` and `{"k1": 1, "k2": "value2"}` will have different checksum values (*).

4️⃣ For simplicity, we agree on:

a) All integer data types (`int`, `intN`, `uint`, and `uintN`) have the same checksum value. This means that `int(12)`, `uint(12)`, `int32(12)`, and `uint64(12)` have the same checksum.
b) `float32` and `float64` have the same checksum value.
c) `slice` and `array` with the same length and identical elements have the same checksum. This means that `[]int{1,2,3}` and `[3]int{1,2,3}` have the same checksum value.
d) Similarly, `map` and `struct` with the same fields/keys and values have the same checksum value.

```bs-alert warning

(*) Checksum cannot provide a 100% guarantee that two distinct data blocks will always have different checksum values. There exists a possibility (infinitesimally small) that two different data blocks may still result in the same checksum value!
```

## Hash function

First of all, a hash function is required. Go already has a number of hash functions for us to use, including `CRC`, `MD5`, `SHA`, etc. For the sake of simplicity, this article adopts `MD5` as the hash function. The implementation is as follows:

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

For ease of changing the hash function in real-world projects, we define a general hash function type `HashFunc` to compute the hash value from the input.
```

## Scalar data types

To compute the checksum value of scalar data types such as `string`, `bool`, `int`, `uint`, and `float`, we first transform the value into a `[]byte` and then calculate the hash value.

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

The structure of the function presented above would be challenging to implement for complex data types like `map` or nested data types. To overcome this, let's enhance the function using _reflection_.

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

Our new `Checksum` function can serve as a replacement for the `ChecksumBool`, `ChecksumInt`, `ChecksumUint`, `ChecksumFloat`, and `ChecksumString` functions while satisfying criteria (1), (2), (4a), and (4b).

## Slices and Arrays

For `slice` and `array`, we iterate through each element:
- Calculate the checksum value of the current element.
- `append` the calculated checksum value to the checksum value calculated in the previous step.
- Calculate the checksum of the slice after appending.

Sample code:

```go
func Checksum(hf HashFunc, v interface{}) []byte {
	rv := reflect.ValueOf(v)
	switch rv.Kind() {
    // other cases removed for readability
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

The `Checksum` function we have developed now satisfies criterion (4c) as well.

## Maps and Structs

With `map` and `struct`, we can follow a similar approach as we did with `slice/array`: iterate through the elements, compute the checksum of each element and _aggregate the results to obtain the final value_. However, it's important to note that the elements of a `map` or `struct` and struct are _unordered_. Hence, we need to ensure that the checksum of `{"key1":"value1","key2":"value2"}` is equal to the checksum of `{"key2":"value2","key1":"value1"}`. One way to achieve this is combining the results using the `xor` operation after calculating the checksum of each element.

Sample code:

```go
func Checksum(hf HashFunc, v interface{}) []byte {
	rv := reflect.ValueOf(v)
	switch rv.Kind() {
    // other cases removed for readability
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

Our `Checksum` function has satisfied both criterion (3) and (4d). Thus, all the criteria have been fulfilled.

## Nested data types

Our `Checksum` function is also capable of computing the checksum value of nested data types with multiple levels:

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

## Before we wrap up

We have developed a function to calculate checksum values for data types of varying complexity in Go. While there are a few cases that we have not yet addressed, such as _pointer_ data types or _non-exported fields_ of a struct, these are not difficult to implement.

Alternatively, you can use the [checksum library](https://github.com/btnguyen2k/consu/tree/master/checksum) that I have developed.

<hr/>

```bs-alert warning

Disclaimer: I utilized ChatGPT to proofread and rephrase certain sections of this post.
```

_[[do-tag ghissue_comment.en]]_
