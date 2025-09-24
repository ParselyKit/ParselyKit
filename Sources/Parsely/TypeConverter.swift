//
//  TypeConverter.swift
//  Parsely
//
//  Created by 서준일 on 9/24/25.
//

import Foundation

/// 문자열을 다양한 타입으로 변환하는 유틸리티 클래스
internal struct TypeConverter {
    
    /// 문자열을 지정된 타입으로 변환합니다.
    /// - Parameters:
    ///   - stringValue: 변환할 문자열
    ///   - targetType: 목표 타입
    /// - Returns: 변환된 값, 실패시 nil
    static func convert(_ stringValue: String, to targetType: Any.Type) -> Any? {
        let trimmedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch targetType {
        case is String.Type:
            return trimmedValue
            
        case is Int.Type:
            return Int(trimmedValue)
            
        case is Int8.Type:
            return Int8(trimmedValue)
            
        case is Int16.Type:
            return Int16(trimmedValue)
            
        case is Int32.Type:
            return Int32(trimmedValue)
            
        case is Int64.Type:
            return Int64(trimmedValue)
            
        case is UInt.Type:
            return UInt(trimmedValue)
            
        case is UInt8.Type:
            return UInt8(trimmedValue)
            
        case is UInt16.Type:
            return UInt16(trimmedValue)
            
        case is UInt32.Type:
            return UInt32(trimmedValue)
            
        case is UInt64.Type:
            return UInt64(trimmedValue)
            
        case is Bool.Type:
            return convertToBool(trimmedValue)
            
        case is Double.Type:
            return Double(trimmedValue)
            
        case is Float.Type:
            return Float(trimmedValue)
            
        case is CGFloat.Type:
            if let doubleValue = Double(trimmedValue) {
                return CGFloat(doubleValue)
            }
            return nil
            
        default:
            return nil
        }
    }
    
    /// 문자열을 Bool 타입으로 변환하는 헬퍼 메서드
    /// "true", "false", "1", "0", "yes", "no" 등 다양한 형태를 지원합니다.
    /// - Parameter stringValue: 변환할 문자열
    /// - Returns: 변환된 Bool 값, 실패시 nil
    private static func convertToBool(_ stringValue: String) -> Bool? {
        let lowercasedValue = stringValue.lowercased()
        
        switch lowercasedValue {
        case "true", "1", "yes", "y":
            return true
        case "false", "0", "no", "n":
            return false
        default:
            return nil
        }
    }
}
