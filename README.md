# Parsely

A lightweight XML parsing library for Swift that automatically converts XML to Swift structs.

## Features

- 🚀 **Automatic Parsing**: Just define a struct and adopt `ParselyType` protocol
- 📦 **Array Support**: Supports both struct arrays and primitive type arrays
- 🔄 **Nested Structures**: Handles deeply nested XML structures
- 🎯 **Type Safe**: Leverages Swift's type system
- 💡 **Simple API**: Clean and intuitive interface

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Parsely.git", from: "1.1.0")
]
```

Or add it through Xcode:
1. File > Add Package Dependencies...
2. Enter the repository URL
3. Select version 1.1.0 or later

## Requirements

[![Swift](https://img.shields.io/badge/Swift-5.9_5.10_6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.9_5.10_6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-orange?style=flat-square)](https://img.shields.io/badge/Platforms-iOS-orange?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## Usage

### Basic Usage

```swift
import Parsely

// 1. Define your struct and adopt ParselyType
struct Product: ParselyType {
    let id: Int
    let name: String
    let price: Double
    let inStock: Bool
}

// 2. Parse XML string
let xml = """
<product>
    <id>12345</id>
    <name>iPhone 15 Pro</name>
    <price>999.99</price>
    <inStock>true</inStock>
</product>
"""

let product = Product.parse(from: xml)
print(product?.name) // "iPhone 15 Pro"
```

### Nested Structures

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

let xml = """
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

let customer = Customer.parse(from: xml)
```

### Array Support

#### Struct Arrays

```swift
struct Book: ParselyType {
    let title: String
    let author: String
}

struct Library: ParselyType {
    let name: String
    let books: [Book]
}

let xml = """
<library>
    <name>City Library</name>
    <books>
        <book>
            <title>Swift Programming</title>
            <author>Apple Inc.</author>
        </book>
        <book>
            <title>iOS Development</title>
            <author>Developer</author>
        </book>
    </books>
</library>
"""

let library = Library.parse(from: xml)
print(library?.books.count) // 2
```

#### Primitive Type Arrays (New in v1.1.0!)

```swift
struct Movie: ParselyType {
    let title: String
    let director: String
    let tags: [String]  // ✨ String array support
}

let xml = """
<movie>
    <title>Inception</title>
    <director>Christopher Nolan</director>
    <tags>
        <tag>Sci-Fi</tag>
        <tag>Thriller</tag>
        <tag>Action</tag>
    </tags>
</movie>
"""

let movie = Movie.parse(from: xml)
print(movie?.tags) // ["Sci-Fi", "Thriller", "Action"]
```

Supported primitive array types:
- `[String]`, `[Int]`, `[Bool]`, `[Double]`, `[Float]`
- `[Int8]`, `[Int16]`, `[Int32]`, `[Int64]`
- `[UInt]`, `[UInt8]`, `[UInt16]`, `[UInt32]`, `[UInt64]`

### Error Handling

```swift
// Simple usage (returns nil on failure)
let result = Product.parse(from: xml)

// With error handling
do {
    let result = try Product.parseOrThrow(from: xml)
    print("Success: \(result)")
} catch let error as ParselyError {
    print("Error: \(error.localizedDescription)")
}
```

## Supported Types

### Primitive Types
- `String`
- `Int`, `Int8`, `Int16`, `Int32`, `Int64`
- `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`
- `Bool` (supports: "true"/"false", "1"/"0", "yes"/"no", "y"/"n")
- `Double`, `Float`

### Complex Types
- Nested structs
- Arrays of structs
- Arrays of primitive types (v1.1.0+)
- Optional values

## How It Works

1. **XML Parsing**: Uses Foundation's `XMLParser` to convert XML into a dictionary structure
2. **Type Mapping**: Automatically maps XML element names to struct property names
3. **Type Conversion**: Converts string values to appropriate Swift types
4. **Array Detection**: Automatically detects and converts repeated elements into arrays

## Important Notes

- XML element names must **exactly match** struct property names (case-sensitive)
- All struct properties must be present in the XML (or marked as optional)
- XML attributes are not currently supported (coming soon!)

## Roadmap

- [ ] XML attribute support
- [ ] Custom key mapping (CodingKeys)
- [ ] Date parsing support
- [ ] Performance optimizations

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
