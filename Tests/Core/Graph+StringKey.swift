@testable import RecoilSwift

extension GraphNode {
    init(_ key: String) {
        self.init(NodeKey(name: key))
    }
    
    init(_ key: String, @GraphNodeBuilder _ builder: () -> Set<NodeKey>) {
        self.init(NodeKey(name: key), builder)
    }
    
    func downstreamContains(_ key: String) -> Bool {
        downstream.contains(NodeKey(name: key))
    }
    
    func upstreamContains(_ key: String) -> Bool {
        upstream.contains(NodeKey(name: key))
    }
}

extension Graph {
    func isContainEdge(key: String, downstream downKey: String) -> Bool {
        isContainEdge(key: NodeKey(name: key), downstream: NodeKey(name: downKey))
    }
    
    func getNode(for key: String) -> Node? {
        getNode(for: NodeKey(name: key))
    }
    
    func addEdge(key: String, downstream downKey: String) {
        addEdge(key: NodeKey(name: key), downstream: NodeKey(name: downKey))
    }
}

extension GraphNodeBuilder {
    static func buildBlock(_ children: String...) -> Set<NodeKey> {
        Set<NodeKey>(children.map { NodeKey(name: $0) })
    }
}

extension DFSCircularChecker {
    func canAddEdge(graph: Graph,
                    forKey key: String,
                    downstream upKey: String) -> Bool {
        canAddEdge(graph: graph, forKey: NodeKey(name: key), downstream: NodeKey(name: upKey))
    }
}
