//
//  Parsely.swift
//  Parsely
//
//  Created by 서준일 on 9/24/25.
//

import Foundation

public final class Parsely: Sendable {
    /// 싱글턴 인스턴스
    public static let shared = Parsely()
    
    /// 외부에서 인스턴스 생성을 막기 위한 private 초기화
    private init() {}
    
    /// XML 문자열을 파싱하여 지정된 타입의 객체로 변환합니다.
    /// - Parameters:
    ///   - xmlString: 파싱할 XML 문자열
    ///   - type: 변환할 타입 (ParselyType을 채택한 구조체)
    /// - Returns: 파싱 성공시 해당 타입의 인스턴스, 실패시 nil
    public func parse<T: ParselyType>(_ xmlString: String, as type: T.Type) -> T? {
        // XML Parsing
        guard let xmlData = parseXML(xmlString) else {
            return nil
        }
        
        // Decoder 생성하고 디코딩
        let decoder = ParselyDecoder(xmlData: xmlData)
        
        do {
            return try T(from: decoder)
        } catch {
            return nil
        }
    }
    
    /// XML을 Dictionary로 파싱하는 내부 메서드
    private func parseXML(_ xmlString: String) -> [String: Any]? {
        guard let data = xmlString.data(using: .utf8) else {
            return nil
        }
        
        let parser = XMLParser(data: data)
        let parserDelegate = ParselyXMLParserDelegate()
        parser.delegate = parserDelegate
        
        guard parser.parse() else {
            return nil
        }
        
        return parserDelegate.parsedData
    }
}

/// XMLParser용 Delegate
private final class ParselyXMLParserDelegate: NSObject, XMLParserDelegate {
    var parsedData: [String: Any] = [:]
    private var elementStack: [String] = []
    private var currentValue = ""
    private var dataStack: [[String: Any]] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementStack.append(elementName)
        currentValue = ""
        dataStack.append([:])
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        elementStack.removeLast()
        let currentData = dataStack.removeLast()
        
        // 추가할 값 결정
        let valueToAdd: Any?
        if !currentValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            valueToAdd = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if !currentData.isEmpty {
            valueToAdd = currentData
        } else {
            valueToAdd = nil
        }
        
        guard let value = valueToAdd else {
            currentValue = ""
            return
        }
        
        if dataStack.count > 0 {
            // 부모 스택에 추가
            var parentData = dataStack[dataStack.count - 1]
            
            if let existingValue = parentData[elementName] {
                // 같은 키가 이미 존재 - 배열로 변환
                if var existingArray = existingValue as? [Any] {
                    existingArray.append(value)
                    parentData[elementName] = existingArray
                } else {
                    parentData[elementName] = [existingValue, value]
                }
            } else {
                // 새로운 키
                parentData[elementName] = value
            }
            
            dataStack[dataStack.count - 1] = parentData
        } else {
            // 루트 레벨
            parsedData[elementName] = value
        }
        
        currentValue = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
}
