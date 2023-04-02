import XCTest
@testable import RecoilSwift

class NodeKeyTests: XCTestCase {
    func test_should_returnCorrectHash_when_hashIsCalled_given_NodeKey() {
        let key1 = NodeKey("test")
        let key2 = NodeKey("test")
        XCTAssertEqual(key1.hashValue, key2.hashValue)
        XCTAssertEqual(key1.fullKeyName, "test")
    }

    func test_should_returnCorrectFullKeyName_when_fullKeyNameIsCalled_given_NodeKey() {
        let pos = SourcePosition(funcName: "test", fileName: "test.swift", line: 10)
        let key = NodeKey(position: pos)
        XCTAssertEqual(key.fullKeyName, "test_test.swift_10")
    }
    
    func test_should_returnCorrectFullKeyNamesOrName_when_given_NodeKey() {
        XCTAssertEqual(TempCelsiusSelector().key.name, "TempCelsiusSelector")
        XCTAssertEqual(TempCelsiusSelector().key.fullKeyName, "TempCelsiusSelector")
        XCTAssertEqual(RemoteNames.names.key.name, "names")
        XCTAssertEqual(RemoteNames.names.key.fullKeyName, "names_RecoilSwiftTests/ScopedStates.swift_12")
    }

    func test_should_returnCorrectEquality_when_equalityIsChecked_given_NodeKey() {
        let key1 = NodeKey("test")
        let key2 = NodeKey("test")
        let key3 = NodeKey("test2")
        
        XCTAssertTrue(key1 == key2)
        XCTAssertFalse(key1 == key3)
    }
    
    func test_should_returnCorrectHash_when_hashIsCalled_given_NodeKeyWithHashRule() {
        let hashRule: NodeKey.HashRuleBlock = { hasher in
            hasher.combine(10)
        }
        
        let key1 = NodeKey("test", hashRule: hashRule)
        let key2 = NodeKey("test", hashRule: hashRule)
        
        XCTAssertEqual(key1, key2)
        XCTAssertEqual(key1.hashValue,
                       key2.hashValue,
                       "Expected NodeKeys with same name and hash rule to have same hash value")
    }
    
    func test_should_saveToMapCorrect_when_hashIsCalled_given_NodeKeyWithHashRule() {
        let hashRule: NodeKey.HashRuleBlock = { hasher in
            hasher.combine(10)
        }
        
        let key1 = NodeKey("test", hashRule: hashRule)
        let key2 = NodeKey("test", hashRule: hashRule)
        let key3 = NodeKey("test")
        
        var states: [NodeKey: String] = [:]
        states[key1] = "Value1"
        states[key2] = "Value2"
        states[key3] = "Value3"

        XCTAssertEqual(states.keys.count, 2)
        XCTAssertEqual(states[key1], "Value2")
    }
    
    func test_should_notEqual_when_hashIsCalled_given_NodeKeyWithHashRule() {
        let hashRule: NodeKey.HashRuleBlock = { hasher in
            hasher.combine("param")
        }
        
        let key1 = NodeKey("test")
        let key2 = NodeKey("test", hashRule: hashRule)
        
        XCTAssertNotEqual(key1, key2)
        XCTAssertNotEqual(key1.hashValue,
                          key2.hashValue,
                          "Expected Not equal same name and hash rule to have same hash value")
    }
}

class SourcePositionTests: XCTestCase {
    func test_should_returnCorrectValues_when_sourcePositionIsInitialized_given_correctInput() {
        let pos = SourcePosition(funcName: "test", fileName: "test.swift", line: 10)
        XCTAssertEqual(pos.tokenName, "test")
        XCTAssertEqual(pos.fileName, "test.swift")
        XCTAssertEqual(pos.line, 10)
    }
}
