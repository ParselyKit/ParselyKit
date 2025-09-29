import XCTest
@testable import Parsely

final class ParselyTests: XCTestCase {
    
    // MARK: - Test Models
    
    struct RelatedLink: ParselyType {
        let relatenm: String
        let relateurl: String
    }
    
    struct RelatedLinks: ParselyType {
        let relate: [RelatedLink]
    }
    
    struct PerformanceDetail: ParselyType {
        let mt20id: String
        let prfnm: String
        let area: String
        let genrenm: String
        let relates: RelatedLinks?
    }
    
    struct PerformanceDatabaseRoot: ParselyType {
        let dbs: PerformanceDatabase
    }
    
    struct PerformanceDatabase: ParselyType {
        let db: PerformanceDetail
    }
    
    // MARK: - String 배열 테스트용 모델
    
    struct TagsDTO: ParselyType {
        let tags: Tags
    }
    
    struct Tags: ParselyType {
        let tag: [String]
    }
    
    struct MovieDTO: ParselyType {
        let movie: Movie
    }
    
    struct Movie: ParselyType {
        let title: String
        let director: String
        let tags: Tags
    }
    
    // MARK: - 테스트
    
    func testFullyAutomaticDecoding() throws {
        let xml = """
        <dbs>
            <db>
                <mt20id>PF266928</mt20id>
                <prfnm>맘마미아! [서울]</prfnm>
                <area>서울특별시</area>
                <genrenm>뮤지컬</genrenm>
                <relates>
                    <relate>
                        <relatenm>LG아트센터</relatenm>
                        <relateurl>https://www.lgart.com/product/performance/252923</relateurl>
                    </relate>
                    <relate>
                        <relatenm>NHN티켓링크</relatenm>
                        <relateurl>http://www.ticketlink.co.kr/product/56744</relateurl>
                    </relate>
                </relates>
            </db>
        </dbs>
        """
        
//        let result = Parsely.shared.parse(xml, as: PerformanceDatabaseRoot.self)
        let result = PerformanceDatabaseRoot.parse(from: xml)
        
        XCTAssertNotNil(result)
        guard let root = result else { return }
        
        let performance = root.dbs.db
        XCTAssertEqual(performance.mt20id, "PF266928")
        
        // 완전 자동 배열 처리!
        XCTAssertNotNil(performance.relates)
        if let relates = performance.relates {
            XCTAssertEqual(relates.relate.count, 2, "자동으로 2개 항목이 파싱되어야 합니다")
            
            XCTAssertEqual(relates.relate[0].relatenm, "LG아트센터")
            XCTAssertEqual(relates.relate[0].relateurl, "https://www.lgart.com/product/performance/252923")
            
            XCTAssertEqual(relates.relate[1].relatenm, "NHN티켓링크")
            XCTAssertEqual(relates.relate[1].relateurl, "http://www.ticketlink.co.kr/product/56744")
        }
    }
    
    // MARK: - String 배열 테스트
    
    func testStringArrayParsing() {
        let xml = """
        <tags>
            <tag>액션</tag>
            <tag>스릴러</tag>
            <tag>범죄</tag>
            <tag>한국영화</tag>
        </tags>
        """
        
        print("🔍 테스트 시작: String 배열 파싱")
        let result = TagsDTO.parse(from: xml)
        print("🔍 파싱 결과: \(result != nil ? "성공" : "실패")")
        
        XCTAssertNotNil(result, "String 배열 파싱이 성공해야 합니다")
        guard let tagsDTO = result else { return }
        
        XCTAssertEqual(tagsDTO.tags.tag.count, 4, "4개의 태그가 파싱되어야 합니다")
        XCTAssertEqual(tagsDTO.tags.tag[0], "액션")
        XCTAssertEqual(tagsDTO.tags.tag[1], "스릴러")
        XCTAssertEqual(tagsDTO.tags.tag[2], "범죄")
        XCTAssertEqual(tagsDTO.tags.tag[3], "한국영화")
    }
}
