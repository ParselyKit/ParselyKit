# Parsely

A simple XML parsing library for Swift

## Overview

Parsely is a Swift library that makes it easy to convert XML data into Swift structs. No complex configuration needed - just adopt one protocol and you're ready to parse XML.

## Requirements

[![Swift](https://img.shields.io/badge/Swift-5.9_5.10_6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.9_5.10_6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-orange?style=flat-square)](https://img.shields.io/badge/Platforms-iOS-orange?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Parsely.git", from: "1.0.0")
]
```

## Usage

### 1. Basic Usage

```swift
import Parsely

// Define your XML structure
struct Product: ParselyType {
    let id: Int
    let name: String
    let price: Double
    let inStock: Bool
    let description: String
}

// Wrapper for the root XML element
struct ProductDTO: ParselyType {
    let product: Product
}

// Parse XML
let xmlString = """
<product>
    <id>12345</id>
    <name>iPhone 17 PRO</name>
    <price>1200000.99</price>
    <inStock>true</inStock>
    <description>Latest iPhone</description>
</product>
"""

let result = ProductDTO.parse(from: xmlString)
print(result?.product.name) // "iPhone 17 PRO"
```

### 2. Nested Structures

```swift
struct Address: ParselyType {
    let street: String
    let city: String
    let zipCode: String
}

struct Customer: ParselyType {
    let name: String
    let email: String
    let address: Address
}

// Root wrapper
struct CustomerDTO: ParselyType {
    let customer: Customer
}

let xmlString = """
<customer>
    <name>John Doe</name>
    <email>john@example.com</email>
    <address>
        <street>123 Main St</street>
        <city>New York</city>
        <zipCode>10001</zipCode>
    </address>
</customer>
"""

let result = CustomerDTO.parse(from: xmlString)
print(result?.customer.name) // "John Doe"
```

### 3. Array Handling

```swift
struct BookItem: ParselyType {
    let title: String
    let author: String
    let isbn: String
}

struct BookList: ParselyType {
    let books: [BookItem]
}

struct Library: ParselyType {
    let name: String
    let bookList: BookList
}

// Root wrapper
struct LibraryDTO: ParselyType {
    let library: Library
}

let xmlString = """
<library>
    <name>Central Library</name>
    <bookList>
        <books>
            <title>Swift Programming</title>
            <author>Apple Inc.</author>
            <isbn>978-123456789</isbn>
        </books>
        <books>
            <title>iOS App Development</title>
            <author>Developer Team</author>
            <isbn>978-987654321</isbn>
        </books>
    </bookList>
</library>
"""

let result = LibraryDTO.parse(from: xmlString)
print(result?.library.bookList.books.count) // 2
```

## Supported Data Types

### Basic Types (Single Values)

- String: Text data
- Int, Int8, Int16, Int32, Int64: Integer types
- UInt, UInt8, UInt16, UInt32, UInt64: Unsigned integer types
- Bool: Boolean values (true/false, 1/0, yes/no)
- Double, Float: Floating-point numbers
- CGFloat: Core Graphics floating-point numbers

### Complex Types

- Custom Structs: Any struct that adopts ParselyType
- Nested Structures: Structs containing other structs
- Arrays of Custom Structs: [YourStruct] where YourStruct: ParselyType

### Currently NOT Supported

- ❌ Arrays of basic types: [Int], [String], [Bool], etc.
- ❌ XML attributes
- ❌ Mixed content (text + elements)

### Features

- ✅ Simple protocol adoption
- ✅ Automatic type conversion for basic types
- ✅ Nested structure support
- ✅ Arrays of custom structs
- ✅ Multiple boolean format support
- ✅ Automatic whitespace trimming
- ⚠️ Arrays of basic types coming in v1.1

### Key Points

- Root Element: Always create a wrapper struct for the root XML element
- Property Names: Swift property names must match XML tag names exactly
- Type Safety: Automatic conversion with Swift's type system
- Custom Structs Only: Arrays currently support only custom structs, not basic types
- Error Handling: Returns nil if parsing fails

## Examples

For more examples, please refer to the test files in the repository.

## Testing

```bash
swift test
```

## License

MIT License. See [LICENSE](https://github.com/ParselyKit/ParselyKit/blob/main/LICENSE) file for details.

## Contributing

Issues and pull requests are welcome!
