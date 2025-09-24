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
}
