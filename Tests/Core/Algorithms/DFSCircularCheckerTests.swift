import SwiftUI
import XCTest

@testable import RecoilSwift

final class DFSCircularCheckerTests: XCTestCase {
  let checker = DFSCircularChecker()
  
  override func setUp() {
    Store.shared.reset()
  }
}

// MARK: - No circular
extension DFSCircularCheckerTests {
  func testCanAddWhenGraphIsEmpty() {
    let graph = Graph()
    
    let canAdd = checker.canAddEdge(graph: graph, forKey: "A", downstream: "B")
    
    XCTAssertEqual(canAdd, true)
  }
  
  func testCanAddWhenBNotExist() {
    let graph = Graph {
      GraphNode("A")
    }
    
    let canAddA2B = checker.canAddEdge(graph: graph, forKey: "A", downstream: "B")
    let canAddB2A = checker.canAddEdge(graph: graph, forKey: "B", downstream: "A")
    
    XCTAssertEqual(canAddA2B, true)
    XCTAssertEqual(canAddB2A, true)
  }
  
  func testCanAddWhenABIsSingleNode() {
    let graph = Graph {
      GraphNode("A")
      GraphNode("B")
    }
    
    let canAddA2B = checker.canAddEdge(graph: graph, forKey: "A", downstream: "B")
    let canAddB2A = checker.canAddEdge(graph: graph, forKey: "B", downstream: "A")
    
    XCTAssertEqual(canAddA2B, true)
    XCTAssertEqual(canAddB2A, true)
  }
  
  func testCanAddWhenBridge() {
    let graph = Graph {
      GraphNode("A") { "B" }
      GraphNode("B")
      GraphNode("C") { "D" }
      GraphNode("D")
    }
    
    let canAddBridgeEdge = checker.canAddEdge(graph: graph, forKey: "B", downstream: "C")
    
    XCTAssertEqual(canAddBridgeEdge, true)
  }
  
  func testCanAddWhenGraphIsClosedButNotCicular() {
    let graph = Graph {
      GraphNode("A") { "B" }
      GraphNode("B") { "C" }
    }
    
    let canAddBridgeEdge = checker.canAddEdge(graph: graph, forKey: "A", downstream: "C")
    
    XCTAssertEqual(canAddBridgeEdge, true)
  }
}

// MARK: - have circular
extension DFSCircularCheckerTests {
  func testCanAddWhenSelfCircular() {
    let graph = Graph {
      GraphNode("A")
    }
    
    let canAddEdge = checker.canAddEdge(graph: graph, forKey: "A", downstream: "A")
    XCTAssertEqual(canAddEdge, false)
  }
  
  func testCanAddWhenDirectCircular() {
    let graph = Graph {
      GraphNode("A") { "B" }
      GraphNode("B")
    }
    
    let canAddEdge = checker.canAddEdge(graph: graph, forKey: "B", downstream: "A")
    
    XCTAssertEqual(canAddEdge, false)
  }
  
  func testCanAddWhenGraphHasSimpleClosedCicular() {
    let graph = Graph {
      GraphNode("A") { "B" }
      GraphNode("B") { "C" }
    }
    
    let canAddEdge = checker.canAddEdge(graph: graph, forKey: "C", downstream: "A")
    
    XCTAssertEqual(canAddEdge, false)
  }
  
  
  func testCanAddWhenGraphHasComplexClosedCicular() {
    let graph = Graph {
      GraphNode("A") {
        "B"
        "C"
      }
      GraphNode("B")
      GraphNode("C") {
        "D"
        "E"
      }
    }
    
    let canAddEdge = checker.canAddEdge(graph: graph, forKey: "E", downstream: "A")
    
    XCTAssertEqual(canAddEdge, false)
  }
}
