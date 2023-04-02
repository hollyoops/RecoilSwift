import XCTest

@testable import RecoilSwift

class SnapshotTests: XCTestCase {
    func test_should_return_dot_graph_when_have_a_node() {
        let graph = Graph() {
            GraphNode(NodeKey("StateA", type: .atom))
        }
        
        let snapshot = Snapshot(graph: graph)
        
        let expected = """
        digraph Store {
        node [style="filled"];
        StateA [fillcolor="gold" color="darkgoldenrod"];
        }
        """
        
        XCTAssertEqual(snapshot.generateDotGraph(), expected)
    }
    
    func test_should_return_dot_graph_when_have_multiple_nodes() {
        let graph = Graph() {
            GraphNode("StateA") { "StateB" }
            GraphNode("StateB") { "StateC" }
            GraphNode("StateC")
        }
        
        let snapshot = Snapshot(graph: graph)
        
        let expected = """
        digraph Store {
        node [style="filled"];
        StateA [fillcolor="peru" color="sienna"];
        StateA -> StateB [color="saddlebrown"];
        StateB [fillcolor="peru" color="sienna"];
        StateB -> StateC [color="saddlebrown"];
        StateC [fillcolor="peru" color="sienna"];
        }
        """
        
        XCTAssertEqual(snapshot.generateDotGraph(isSortNodeByName: true), expected)
    }
    
    func test_should_return_emtpy_dot_graph_when_no_node() {
        let graph = Graph() { }
        
        let snapshot = Snapshot(graph: graph)
        
        let expected = "digraph Empty { label=\"Empty Store\"; }"
        
        XCTAssertEqual(snapshot.generateDotGraph(isSortNodeByName: true), expected)
    }
}
