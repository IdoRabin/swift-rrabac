import XCTest
@testable import Rabac

fileprivate let dlog : DSLogger? = DLog.forClass("RabacTests")

struct DebugUserId : RabacRouteParamable {
    let uid : UUID
    
    // MARK: RabacRouteParamable : LosslessStringConvertible
    init?(_ description: String) {
        if let uid = UUID(uuidString: description) {
            self.uid = uid
        } else {
            return nil
        }
    }
    
    var description: String {
        return uid.description
    }
}

final class RabacTests: XCTestCase {
    
    override class func setUp() {
        DSLogger.IS_LOGS_ENABLED = true
        RabacDebug.IS_DEBUG = true
        
        let mgr = RabacMgr.shared
        mgr.registerPathParam(keyName: "user_id", type: DebugUserId.self, possibleRegexes: [UUID.REGEX])
    }
    
    override class func tearDown() {
        RabacMgr.shared.shutdown()
    }
    
    func testResources() {
        do {
            // "user/01234567898/one/more", "user/zs01234s567898sz/two/more",
            let resources = try [
                "my/path1/one?myvar=my_val&myvar2=my_val2",
                "my/path1/one#hashatag?myvar=my_val1", "my/path1/one",
                "my/path1/one/more", "my/path1/two", "my/path1/", "my/path2",
                "my/ex", "my/different/one", "ma/diff/one",
                "user/f32628f0-f6af-4fdc-8bea-132d10f0691e/two/more",
            ].map { str in
                try RabacResource(title: str)
            }.uniqueElements()
            
            let matchers = try [
                "my/path1/*", "my/ex", "my/path1/**",
                "my/**/one", "**/**/one",
                "user/:user_id/*/more"
            ].map{ str in
                try RabacResource(title: str)
            }.uniqueElements()
            
            // Testing with cases of RabacRouteComponent.Simplified in mind:
            let expectedMatches = [
                "my/ex" : ["my/ex"],
                
                // Test ".catchall":
                "my/path1/**" : ["my/path1/one", "my/path1/two", "my/path1", "my/path1/one/more"],
                "my/**/one" : ["my/path1/one", "my/different/one"],
                "**/**/one" : ["my/path1/one", "my/different/one", "on/diff/one", "ma/diff/one", "user/01234567898/one"],
                
                // Test ".anything":
                "my/path1/*" : ["my/path1/one", "my/path1/two"],
                "my/*/one" : ["my/path1/one", "my/different/one"],
                "*/*/one" : ["my/path1/one", "my/different/one", "on/diff/one", "ma/diff/one"],
                
                // Test ".parameter": (PARAMPREFIX)
                "user/:user_id/*/more" : ["user/f32628f0-f6af-4fdc-8bea-132d10f0691e/two/more"]
            ]
            
            func isExpectedToMatch(match:String, resc:String)->Bool {
                guard let arr = expectedMatches[match] else {
                    return false
                }
                
                return arr.contains(resc, isCaseSensitive: false)
            }
            
            // Enumerate
            matchers.forEachIndex({ index, matcher in
                if let route1 = matcher.rabacId.title.rabacRoute {
                    dlog?.info(".testResources() for path: \(route1)")
                    for res in resources {
                        if let route2 = res.rabacRoute {
                            
                            // TODO: Remove this .. Debugging:
                            let matPath = matcher.rabacId.title.trimming(string: "/")
                            let resPath = res.rabacId.title.trimming(string: "/")
                            let isExpectedToMatch = isExpectedToMatch(match: matPath, resc: resPath)
                            let matchResult = route1.matchesRoute(route2)
                            
                            if matchResult.isSuccess == isExpectedToMatch {
                                if matchResult.isSuccess {
                                    dlog?.verbose(log: .success, ".testResources()      success. matching route2: \(matcher.rabacId.title) with: \(res.rabacId.title)")
                                } else {
                                    dlog?.verbose(log: .success, ".testResources()      success. was not expecting a match between route2: \(matcher.rabacId.title) with: \(res.rabacId.title). error: \(matchResult.errorValue.descOrNil)")
                                }
                            } else {
                                if matchResult.isSuccess {
                                    dlog?.verbose(log: .fail, ".testResources()      success matching route2: \(matcher.rabacId.title) with: \(res.rabacId.title). But was not expecting a match.")
                                } else {
                                    dlog?.verbose(log: .fail, ".testResources()      failed matching - was  expecting a match between route2: \(matcher.rabacId.title) with: \(res.rabacId.title). error: \(matchResult.errorValue.descOrNil)")
                                }
                                XCTFail(".testResources()      match was expected to \(isExpectedToMatch ? "succeed" : "fail") but instead \(matchResult.isSuccess ? "matched" : "failed") error: \(matchResult.errorValue.descOrNil)")
                            }
                        } else {
                            XCTFail(".testResources()      matches failed creating route2: \(res.rabacId.title) as .rabacRoute")
                        }
                    }
                } else {
                    XCTFail(".testResources() matches failed creating route1: \(matcher.rabacId.title) as .rabacRoute")
                }
            })
        } catch let error {
            XCTFail(".testResources() threw: \(error)")
        }
    }
    
    func testRabacRun() {
        let exp1 = XCTestExpectation(description: "Run")
        
        RabacMgr.shared.whenLoaded.append  { (error) in
            dlog?.info("RabacMgr.shared.whenLoaded(error:\(error.descOrNil)")
            if error == nil {
                exp1.fulfill()
            }
        }
        
        wait(for: [exp1], timeout: 20.0, enforceOrder: true)
        
        XCTAssert(RabacMgr.shared.elements.count > 0, "Expected init for multiple elements")
    }
    
    func testVersion() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssert(SemVer("0.0.1")! < SemVer(RabacMgr.shared.version)! &&
                  SemVer("2.0.0")! > SemVer(RabacMgr.shared.version)!,
                  ".testVersion() failed: version is expected to be between 0.0.1 and 2.0.0 for the forseeable future (2023)!")
        XCTAssertEqual(RabacMgr.shared.version, "1.0.0")
    }
}
