@resultBuilder
struct GraphNodeBuilder {
    static func buildBlock(_ children: NodeKey...) -> Set<NodeKey> {
        Set<NodeKey>(children)
    }
}

@resultBuilder
struct GraphBuilder {
    static func buildBlock(_ children: Graph.Node...) -> [NodeKey: Graph.Node] {
        children.reduce(into: [:]) { map, node in
            map[node.key] = node
        }
    }
}

typealias GraphNode = Graph.Node

internal class Graph {
    private var nodes: [NodeKey: Node]
    
    struct Node {
        let key: NodeKey
        private(set) var downstream: Set<NodeKey>
        private(set) var upstream: Set<NodeKey> = []
        
        init(_ key: NodeKey, downstream: Set<NodeKey> = []) {
            self.key = key
            self.downstream = downstream
        }
        
        init(_ key: NodeKey, @GraphNodeBuilder _ builder: () -> Set<NodeKey>) {
            self.key = key
            self.downstream = builder()
        }
        
        mutating func add(downstream key: NodeKey) {
            downstream.insert(key)
        }
        
        mutating func add(upstream key: NodeKey) {
            upstream.insert(key)
        }
        
        mutating func remove(downstream key: NodeKey) {
            downstream.remove(key)
        }
        
        mutating func remove(upstream key: NodeKey) {
            upstream.insert(key)
        }
    }
    
    init() {
        nodes = [:]
    }
    
    init(@GraphBuilder _ builder: () -> [NodeKey: Node]) {
        nodes = builder()
        fixUpstreams()
    }
    
    func allNodes() -> [NodeKey: Node] { nodes }
    
    func add(key: NodeKey) {
        if nodes.has(key) {
           return
        }
        nodes[key] = Node(key)
    }
    
    func addEdge(key: NodeKey, downstream downKey: NodeKey) {
        if !nodes.has(downKey) {
            nodes[downKey] = Node(downKey)
        }
        
        if !nodes.has(key) {
            nodes[key] = Node(key)
        }
        
        var upNode = nodes[key]!
        var downNode = nodes[downKey]!
        
        upNode.add(downstream: downKey)
        downNode.add(upstream: key)
        
        nodes[key] = upNode
        nodes[downKey] = downNode
    }
    
    func removeNode(key: NodeKey) {
        guard let node = nodes[key] else { return  }
        nodes.removeValue(forKey: key)
        
        node.downstream.forEach { key in
            removeEdge(key: key, upstream: node.key)
        }
        
        node.upstream.forEach { key in
            removeEdge(key: key, downstream: node.key)
        }
    }
    
    func dependencies(key: NodeKey) -> Set<NodeKey> {
        guard let n = nodes[key] else { return [] }
        
        return Set<NodeKey>(n.upstream)
    }
    
    private func removeEdge(key: NodeKey, upstream upKey: NodeKey) {
        guard var node = nodes[key] else { return }
        node.remove(upstream: upKey)
        nodes[key] = node
    }
    
    private func removeEdge(key: NodeKey, downstream downKey: NodeKey) {
        guard var node = nodes[key] else { return }
        node.remove(downstream: downKey)
        nodes[key] = node
    }
    
    func isContainEdge(key: NodeKey, downstream downKey: NodeKey) -> Bool {
        guard let node = nodes[key] else {
            return false
        }
        
        if !nodes.has(downKey) {
            nodes[downKey] = Node(downKey)
        }
        
        return node.downstream.contains(downKey)
    }
    
    func getNode(for key: NodeKey) -> Node? {
        nodes[key]
    }
    
    func reset() {
        nodes = [:]
    }
    
    private func fixUpstreams() {
        nodes.forEach { element in
            element.value.downstream.forEach { downKey in
                if !nodes.has(downKey) {
                    nodes[downKey] = Node(downKey)
                }
                
                var downNode = nodes[downKey]!
                downNode.add(upstream: element.key)
                nodes[downKey] = downNode
            }
        }
    }
}
