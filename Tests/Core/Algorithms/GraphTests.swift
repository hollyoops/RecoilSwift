
import SwiftUI
import XCTest

@testable import RecoilSwift

final class GraphTests: XCTestCase { }

 // MARK: - AddEdge
extension GraphTests {
  func testAddEdgeWhenGraphIsEmpty() {
    let graph = Graph()
    graph.addEdge(key: "A", downstream: "B")
    
    XCTAssertNotNil(graph.getNode(for: "A"))
    XCTAssertNotNil(graph.getNode(for: "B"))
    XCTAssertEqual(graph.getNode(for: "A")?.downstreamContains("B"), true)
    XCTAssertEqual(graph.getNode(for: "B")?.upstreamContains("A"), true)
  }
  
  func testAddEdgeWhenTargetNodeExist() {
    let graph = Graph() {
      GraphNode("A") { "C" }
    }
    graph.addEdge(key: "A", downstream: "B")
    
    XCTAssertNotNil(graph.getNode(for: "A"))
    XCTAssertNotNil(graph.getNode(for: "B"))
    XCTAssertEqual(graph.getNode(for: "A")?.downstreamContains("B"), true)
    XCTAssertEqual(graph.getNode(for: "B")?.upstreamContains("A"), true)
  }
  
  func testShouldMakeCorrectEdgeWhen_C_NotExsit() {
    let graph = Graph() {
      GraphNode("A") { "C" }
    }
    
    XCTAssertNotNil(graph.getNode(for: "A"))
    XCTAssertNotNil(graph.getNode(for: "C"))
    XCTAssertEqual(graph.getNode(for: "A")?.downstreamContains("C"), true)
    XCTAssertEqual(graph.getNode(for: "C")?.upstreamContains("A"), true)
  }
  
  func testShouldMakeCorrectEdgeWhen_C_Exsit() {
    let graph = Graph() {
      GraphNode("A") { "C" }
      GraphNode("C")
    }
    
    XCTAssertNotNil(graph.getNode(for: "A"))
    XCTAssertNotNil(graph.getNode(for: "C"))
    XCTAssertEqual(graph.getNode(for: "A")?.downstreamContains("C"), true)
    XCTAssertEqual(graph.getNode(for: "C")?.upstreamContains("A"), true)
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
