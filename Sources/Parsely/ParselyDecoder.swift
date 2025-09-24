//
//  ParselyDecoder.swift
//  Parsely
//
//  Created by 서준일 on 9/24/25.
//

import Foundation

// MARK: - ParselyDecoder (내부 디코더)

/// Parsely에서 내부적으로 사용하는 디코더
internal class ParselyDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    private let xmlData: [String: Any]
    
    init(xmlData: [String: Any]) {
        self.xmlData = xmlData
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = ParselyKeyedDecodingContainer<Key>(xmlData: xmlData, codingPath: codingPath)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed containers not supported at root"))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ParselySingleValueDecodingContainer(xmlData: xmlData, codingPath: codingPath)
    }
}

// MARK: - 배열 디코딩 전용 디코더

/// 배열 데이터를 처리하는 전용 디코더
private class ParselyArrayDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    private let container: ParselyUnkeyedDecodingContainer
    
    init(container: ParselyUnkeyedDecodingContainer) {
        self.container = container
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Array decoder does not support keyed containers"))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return container
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.typeMismatch(Any.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Array decoder does not support single value containers"))
    }
}

// MARK: - KeyedDecodingContainer

private struct ParselyKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey]
    private let xmlData: [String: Any]
    
    init(xmlData: [String: Any], codingPath: [CodingKey]) {
        self.xmlData = xmlData
        self.codingPath = codingPath
    }
    
    var allKeys: [Key] {
        return xmlData.keys.compactMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: Key) -> Bool {
        return xmlData[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        return xmlData[key.stringValue] == nil
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let value = xmlData[key.stringValue] as? String else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key '\(key.stringValue)' not found"))
        }
        return value
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let stringValue = xmlData[key.stringValue] as? String,
              let intValue = Int(stringValue) else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot convert '\(key.stringValue)' to Int"))
        }
        return intValue
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let stringValue = xmlData[key.stringValue] as? String else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot convert '\(key.stringValue)' to Bool"))
        }
        
        switch stringValue.lowercased() {
        case "true", "1", "yes", "y":
            return true
        case "false", "0", "no", "n":
            return false
        default:
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot convert '\(stringValue)' to Bool"))
        }
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let stringValue = xmlData[key.stringValue] as? String,
              let doubleValue = Double(stringValue) else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot convert '\(key.stringValue)' to Double"))
        }
        return doubleValue
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let stringValue = xmlData[key.stringValue] as? String,
              let floatValue = Float(stringValue) else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot convert '\(key.stringValue)' to Float"))
        }
        return floatValue
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        // 중첩된 구조체 처리
        if let nestedData = xmlData[key.stringValue] as? [String: Any] {
            let nestedDecoder = ParselyDecoder(xmlData: nestedData)
            return try T(from: nestedDecoder)
        }
        
        // 배열 자동 처리
        let typeName = String(describing: type)
        if typeName.hasPrefix("Array<") || typeName.contains("[") {
            if let arrayData = xmlData[key.stringValue] as? [Any] {
                let arrayContainer = ParselyUnkeyedDecodingContainer(arrayData: arrayData, codingPath: codingPath + [key])
                let arrayDecoder = ParselyArrayDecoder(container: arrayContainer)
                return try T(from: arrayDecoder)
            }
        }
        
        throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key '\(key.stringValue)' not found"))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard let nestedData = xmlData[key.stringValue] as? [String: Any] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key '\(key.stringValue)' not found"))
        }
        
        let container = ParselyKeyedDecodingContainer<NestedKey>(xmlData: nestedData, codingPath: codingPath + [key])
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        print("배열 컨테이너 요청: \(key.stringValue)")
        print("사용 가능한 키들: \(xmlData.keys)")
        
        guard let arrayData = xmlData[key.stringValue] as? [Any] else {
            print("❌ 배열 데이터를 찾을 수 없음: \(key.stringValue)")
            print("실제 데이터: \(xmlData[key.stringValue] ?? "nil")")
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key '\(key.stringValue)' not found or not an array"))
        }
        
        print("✅ 배열 데이터 발견: \(arrayData.count)개 항목")
        return ParselyUnkeyedDecodingContainer(arrayData: arrayData, codingPath: codingPath + [key])
    }
    
    func superDecoder() throws -> Decoder {
        return ParselyDecoder(xmlData: xmlData)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return ParselyDecoder(xmlData: xmlData)
    }
}

// MARK: - UnkeyedDecodingContainer

private struct ParselyUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey]
    private let arrayData: [Any]
    private(set) var currentIndex: Int = 0
    
    init(arrayData: [Any], codingPath: [CodingKey]) {
        self.arrayData = arrayData
        self.codingPath = codingPath
    }
    
    var count: Int? {
        return arrayData.count
    }
    
    var isAtEnd: Bool {
        return currentIndex >= arrayData.count
    }
    
    mutating func decodeNil() throws -> Bool {
        return false
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        guard !isAtEnd, let value = arrayData[currentIndex] as? String else {
            throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected String"))
        }
        currentIndex += 1
        return value
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed container is at end"))
        }
        
        let currentData = arrayData[currentIndex]
        currentIndex += 1
        
        if let dictData = currentData as? [String: Any] {
            let decoder = ParselyDecoder(xmlData: dictData)
            return try T(from: decoder)
        }
        
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected dictionary for \(type)"))
    }
    
    // 다른 필수 메서드들 (간단하게 에러 처리)
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Bool not supported"))
    }
    mutating func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Int not supported"))
    }
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Int8 not supported"))
    }
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Int16 not supported"))
    }
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Int32 not supported"))
    }
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Int64 not supported"))
    }
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "UInt not supported"))
    }
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "UInt8 not supported"))
    }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "UInt16 not supported"))
    }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "UInt32 not supported"))
    }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "UInt64 not supported"))
    }
    mutating func decode(_ type: Float.Type) throws -> Float {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Float not supported"))
    }
    mutating func decode(_ type: Double.Type) throws -> Double {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Double not supported"))
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Nested containers not supported"))
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch([Any].self, DecodingError.Context(codingPath: codingPath, debugDescription: "Nested unkeyed containers not supported"))
    }
    
    mutating func superDecoder() throws -> Decoder {
        throw DecodingError.typeMismatch(Decoder.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Super decoder not supported"))
    }
}

// MARK: - SingleValueDecodingContainer

private struct ParselySingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    private let xmlData: [String: Any]
    
    init(xmlData: [String: Any], codingPath: [CodingKey]) {
        self.xmlData = xmlData
        self.codingPath = codingPath
    }
    
    func decodeNil() -> Bool {
        return false
    }
    
    func decode(_ type: String.Type) throws -> String {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Single value decoding not supported"))
    }
}
