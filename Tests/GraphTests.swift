
import SwiftUI
import XCTest

@testable import RecoilSwift

final class GraphTests: XCTestCase {
  override func setUp() { }
}

// MARK: - AddEdge
extension GraphTests {
  func testAddEdgeWhenGraphIsEmpty() {
    let graph = Graph()
    graph.addEdge(key: "A", downstream: "B")
    
    XCTAssertNotNil(graph.getNode(for: "A"))
    XCTAssertNotNil(graph.getNode(for: "B"))
    XCTAssertEqual(graph.getNode(for: "A")?.downstream.contains("B"), true)
  }
  
  func testAddEdgeWhenTargetNodeExist() {
    let graph = Graph() {
      GraphNode("A") { "C" }
    }
    graph.addEdge(key: "A", downstream: "B")
    
    XCTAssertNotNil(graph.getNode(for: "A"))
    XCTAssertNotNil(graph.getNode(for: "B"))
    XCTAssertEqual(graph.getNode(for: "A")?.downstream.contains("B"), true)
  }
}

// MARK: - isContainEdge
extension GraphTests {
  func testContainEdgeWhenTargetNodeExists() {
    let graph = Graph() {
      GraphNode("A") { "C" }
      GraphNode("C")
    }
    
    XCTAssertTrue(graph.isContainEdge(key: "A", downstream: "C"))
  }
  
  func testContainEdgeWhenDownstreamIsMissing() {
    let graph = Graph() {
      GraphNode("A") { "C" }
    }
    
    XCTAssertTrue(graph.isContainEdge(key: "A", downstream: "C"))
    XCTAssertNotNil(graph.getNode(for: "C"))
  }
  
  func testContainEdgeWhenKeyIsMissing() {
    let graph = Graph() {
      GraphNode("C")
    }
    
    XCTAssertFalse(graph.isContainEdge(key: "A", downstream: "C"))
  }
}
