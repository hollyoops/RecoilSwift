@testable import RecoilSwift

extension GraphNode {
    init(_ key: String) {
        self.init(NodeKey(key))
    }
    
    init(_ key: String, @GraphNodeBuilder _ builder: () -> Set<NodeKey>) {
        self.init(NodeKey(key), builder)
    }
    
    func downstreamContains(_ key: String) -> Bool {
        downstream.contains(NodeKey(key))
    }
    
    func upstreamContains(_ key: String) -> Bool {
        upstream.contains(NodeKey(key))
    }
}

extension Graph {
    func isContainEdge(key: String, downstream downKey: String) -> Bool {
        isContainEdge(key: NodeKey(key), downstream: NodeKey(downKey))
    }
    
    func getNode(for key: String) -> Node? {
        getNode(for: NodeKey(key))
    }
    
    func addEdge(key: String, downstream downKey: String) {
        addEdge(key: NodeKey(key), downstream: NodeKey(downKey))
    }
}

extension GraphNodeBuilder {
    static func buildBlock(_ children: String...) -> Set<NodeKey> {
        Set<NodeKey>(children.map { NodeKey($0) })
    }
}

extension DFSCircularChecker {
    func canAddEdge(graph: Graph,
                    forKey key: String,
                    downstream upKey: String) -> Bool {
        canAddEdge(graph: graph, forKey: NodeKey(key), downstream: NodeKey(upKey))
    }
}
