//
//  File.swift
//  Parsely
//
//  Created by 서준일 on 9/29/25.
//

import Foundation

public enum ParselyError: Error {
    case xmlParsingFailed
    case decodingFailed(reason: String)
    case keyNotFound(key: String, context: String)
    case typeMismatch(expectedType: String, context: String)
    case valueNotFound(type: String, context: String)
    
    public var localizedDescription: String {
        switch self {
        case .xmlParsingFailed:
            return "XML 파싱에 실패했습니다. XML 형식이 올바른지 확인해주세요."
        case .decodingFailed(let reason):
            return "디코딩에 실패했습니다: \(reason)"
        case .keyNotFound(let key, let context):
            return "키 '\(key)'를 찾을 수 없습니다. \(context)"
        case .typeMismatch(let expectedType, let context):
            return "타입이 일치하지 않습니다. 예상 타입: \(expectedType). \(context)"
        case .valueNotFound(let type, let context):
            return "'\(type)' 타입의 값을 찾을 수 없습니다. \(context)"
        }
    }
}
