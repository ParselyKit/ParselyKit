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
    
    /// XML 디코더 인스턴스
    private let xmlDecoder = XMLDecoder()
    
    /// 외부에서 인스턴스 생성을 막기 위한 private 초기화
    private init() {}
    
    /// XML 문자열을 파싱하여 지정된 타입의 객체로 변환합니다.
    /// - Parameters:
    ///   - xmlString: 파싱할 XML 문자열
    ///   - type: 변환할 타입 (ParselyType을 채택한 구조체)
    /// - Returns: 파싱 성공시 해당 타입의 인스턴스, 실패시 nil
    public func parse<T: ParselyType>(_ xmlString: String, as type: T.Type) -> T? {
        return xmlDecoder.decode(type, from: xmlString)
    }
}
