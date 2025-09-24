//
//  ParselyType.swift
//  Parsely
//
//  Created by 서준일 on 9/24/25.
//

import Foundation

public protocol ParselyType: Decodable { }

public extension ParselyType {
    static func parse(from xmlString: String) -> Self? {
        return Parsely.shared.parse(xmlString, as: Self.self)
    }
}
