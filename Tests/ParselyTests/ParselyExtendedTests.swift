//
//  File.swift
//  Parsely
//
//  Created by 서준일 on 9/24/25.
//

import XCTest
@testable import Parsely

final class ParselyExtendedTests: XCTestCase {
    
    // MARK: - 기본 데이터 타입 테스트용 모델
    
    struct ProductDTO: ParselyType {
        let product: Product
    }
    
    struct Product: ParselyType {
        let id: Int
        let name: String
        let price: Double
        let inStock: Bool
        let description: String
    }
    
    struct UserDTO: ParselyType {
        let user: User
    }
    
    struct User: ParselyType {
        let userId: String
        let age: Int
        let isActive: Bool
    }
    
    // MARK: - 중첩 구조 테스트용 모델
    
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
    
    struct CustomerDTO: ParselyType {
        let customer: Customer
    }
    
    // MARK: - 배열 테스트용 모델
    
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
    
    struct LibraryDTO: ParselyType {
        let library: Library
    }
    
    // MARK: - 기본 타입 테스트
    
    func testBasicStringParsing() {
        let xml = """
        <user>
            <userId>user123</userId>
            <age>25</age>
            <isActive>true</isActive>
        </user>
        """
        
        let result = UserDTO.parse(from: xml)
        
        XCTAssertNotNil(result, "XML 파싱이 성공해야 합니다")
        guard let user = result?.user else { return }
        
        XCTAssertEqual(user.userId, "user123", "문자열 파싱이 정확해야 합니다")
        XCTAssertEqual(user.age, 25, "정수 파싱이 정확해야 합니다")
        XCTAssertTrue(user.isActive, "불린 파싱이 정확해야 합니다")
    }
    
    func testProductParsing() {
        let xml = """
        <product>
            <id>12345</id>
            <name>iPhone 17 PRO</name>
            <price>1200000.99</price>
            <inStock>true</inStock>
            <description>최신 아이폰</description>
        </product>
        """
        
        let result = ProductDTO.parse(from: xml)
        
        XCTAssertNotNil(result, "제품 정보 파싱이 성공해야 합니다")
        guard let product = result?.product else { return }
        
        XCTAssertEqual(product.id, 12345)
        XCTAssertEqual(product.name, "iPhone 17 PRO")
        XCTAssertEqual(product.price, 1200000.99, accuracy: 0.01)
        XCTAssertTrue(product.inStock)
        XCTAssertEqual(product.description, "최신 아이폰")
    }
    
    // MARK: - 불린 값 다양한 형태 테스트
    
    func testBooleanVariations() {
        // "false" 테스트
        let xmlFalse = """
        <user>
            <userId>user456</userId>
            <age>30</age>
            <isActive>false</isActive>
        </user>
        """
        
        let resultFalse = UserDTO.parse(from: xmlFalse)
        XCTAssertNotNil(resultFalse, "false 값 XML 파싱이 성공해야 합니다")
        
        guard let user = resultFalse?.user else { return }
        XCTAssertFalse(user.isActive, "false 값이 정확히 파싱되어야 합니다")
        
        // "1" / "0" 테스트
        let xmlOne = """
        <user>
            <userId>user789</userId>
            <age>20</age>
            <isActive>1</isActive>
        </user>
        """
        
        let resultOne = UserDTO.parse(from: xmlOne)
        XCTAssertNotNil(resultOne, "숫자 1 값 XML 파싱이 성공해야 합니다")
        
        guard let user = resultOne?.user else { return }
        XCTAssertTrue(user.isActive, "숫자 1이 true로 파싱되어야 합니다")
    }
    
    // MARK: - 중첩 구조 테스트
    
    func testNestedStructureParsing() {
        let xml = """
        <customer>
            <name>김철수</name>
            <email>kim@example.com</email>
            <address>
                <street>강남대로 123</street>
                <city>서울</city>
                <zipCode>06234</zipCode>
            </address>
        </customer>
        """
        
        let result = CustomerDTO.parse(from: xml)
        
        XCTAssertNotNil(result, "중첩 구조 파싱이 성공해야 합니다")
        guard let customer = result?.customer else { return }
        
        XCTAssertEqual(customer.name, "김철수")
        XCTAssertEqual(customer.email, "kim@example.com")
        XCTAssertEqual(customer.address.street, "강남대로 123")
        XCTAssertEqual(customer.address.city, "서울")
        XCTAssertEqual(customer.address.zipCode, "06234")
    }
    
    // MARK: - 배열 파싱 테스트
    
    func testArrayParsing() {
        let xml = """
        <library>
            <name>중앙도서관</name>
            <bookList>
                <books>
                    <title>Swift 프로그래밍</title>
                    <author>김개발</author>
                    <isbn>978-123456789</isbn>
                </books>
                <books>
                    <title>iOS 앱 개발</title>
                    <author>박코딩</author>
                    <isbn>978-987654321</isbn>
                </books>
                <books>
                    <title>앱스토어 출시 가이드</title>
                    <author>이앱스토어</author>
                    <isbn>978-555666777</isbn>
                </books>
            </bookList>
        </library>
        """
        
        let result = LibraryDTO.parse(from: xml)
        
        XCTAssertNotNil(result, "도서관 정보 파싱이 성공해야 합니다")
        guard let library = result?.library else { return }
        
        XCTAssertEqual(library.name, "중앙도서관")
        XCTAssertEqual(library.bookList.books.count, 3, "3권의 책이 파싱되어야 합니다")
        
        // 첫 번째 책 확인
        let firstBook = library.bookList.books[0]
        XCTAssertEqual(firstBook.title, "Swift 프로그래밍")
        XCTAssertEqual(firstBook.author, "김개발")
        XCTAssertEqual(firstBook.isbn, "978-123456789")
        
        // 마지막 책 확인
        let lastBook = library.bookList.books[2]
        XCTAssertEqual(lastBook.title, "앱스토어 출시 가이드")
        XCTAssertEqual(lastBook.author, "이앱스토어")
        XCTAssertEqual(lastBook.isbn, "978-555666777")
    }
    
    // MARK: - 에러 상황 테스트
    
    func testInvalidXMLHandling() {
        let invalidXML = """
        <product>
            <id>invalid_number</id>
            <name>테스트 제품</name>
        </product>
        """
        
        let result = ProductDTO.parse(from: invalidXML)
        XCTAssertNil(result, "잘못된 숫자 형태는 파싱 실패해야 합니다")
    }
    
    func testEmptyXMLHandling() {
        let emptyXML = ""
        let result = ProductDTO.parse(from: emptyXML)
        XCTAssertNil(result, "빈 XML은 파싱 실패해야 합니다")
    }
    
    func testMissingFieldHandling() {
        let incompleteXML = """
        <product>
            <id>123</id>
            <name>테스트</name>
            <!-- price, inStock, description 누락 -->
        </product>
        """
        
        let result = ProductDTO.parse(from: incompleteXML)
        XCTAssertNil(result, "필수 필드가 누락된 경우 파싱 실패해야 합니다")
    }
    
    // MARK: - 공백 및 특수문자 테스트
    
    func testWhitespaceHandling() {
        let xmlWithSpaces = """
        <user>
            <userId>  user_with_spaces  </userId>
            <age>  25  </age>
            <isActive>  true  </isActive>
        </user>
        """
        
        let result = UserDTO.parse(from: xmlWithSpaces)
        XCTAssertNotNil(result, "공백이 포함된 XML도 파싱되어야 합니다")
        guard let user = result?.user else { return }
        
        XCTAssertEqual(user.userId, "user_with_spaces", "앞뒤 공백이 제거되어야 합니다")
        XCTAssertEqual(user.age, 25, "숫자도 공백 제거 후 파싱되어야 합니다")
        XCTAssertTrue(user.isActive, "불린값도 공백 제거 후 파싱되어야 합니다")
    }
    
    // MARK: - 실제 API 응답 형태 테스트
    
    struct APIResponseDTO: ParselyType {
        let response: APIResponse
    }
    
    struct APIResponse: ParselyType {
        let status: String
        let message: String
        let data: APIData
    }
    
    struct APIData: ParselyType {
        let count: Int
        let results: APIResults
    }
    
    struct APIResults: ParselyType {
        let items: [APIItem]
    }
    
    struct APIItem: ParselyType {
        let id: String
        let title: String
        let createdAt: String
    }
    
    func testRealAPIResponseParsing() {
        let apiXML = """
        <response>
            <status>success</status>
            <message>데이터 조회 성공</message>
            <data>
                <count>2</count>
                <results>
                    <items>
                        <id>item001</id>
                        <title>첫 번째 아이템</title>
                        <createdAt>2025-01-01T10:00:00Z</createdAt>
                    </items>
                    <items>
                        <id>item002</id>
                        <title>두 번째 아이템</title>
                        <createdAt>2025-01-02T11:00:00Z</createdAt>
                    </items>
                </results>
            </data>
        </response>
        """
        
        let result = APIResponseDTO.parse(from: apiXML)
        
        XCTAssertNotNil(result, "실제 API 응답 형태의 XML이 파싱되어야 합니다")
        guard let response = result?.response else { return }
        
        XCTAssertEqual(response.status, "success")
        XCTAssertEqual(response.message, "데이터 조회 성공")
        XCTAssertEqual(response.data.count, 2)
        XCTAssertEqual(response.data.results.items.count, 2)
        
        // 첫 번째 아이템 확인
        let firstItem = response.data.results.items[0]
        XCTAssertEqual(firstItem.id, "item001")
        XCTAssertEqual(firstItem.title, "첫 번째 아이템")
        XCTAssertEqual(firstItem.createdAt, "2025-01-01T10:00:00Z")
    }
    
    // MARK: - 성능 테스트 (간단한 수준)
    
    func testSimplePerformance() {
        let xml = """
        <product>
            <id>12345</id>
            <name>성능 테스트 제품</name>
            <price>99000.0</price>
            <inStock>true</inStock>
            <description>성능 측정용</description>
        </product>
        """
        
        // 간단한 성능 측정
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            let _ = Product.parse(from: xml)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(timeElapsed, 1.0, "100번 파싱이 1초 이내에 완료되어야 합니다")
        print("100번 파싱 소요 시간: \(timeElapsed)초")
    }
}
