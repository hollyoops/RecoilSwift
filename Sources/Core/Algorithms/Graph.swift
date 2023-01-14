@resultBuilder
struct GraphNodeBuilder {
    static func buildBlock(_ children: String...) -> Set<String> {
        Set<String>(children)
    }
}

@resultBuilder
struct GraphBuilder {
    static func buildBlock(_ children: Graph.Node...) -> [String: Graph.Node] {
        children.reduce(into: [:]) { map, node in
            map[node.key] = node
        }
    }
}

typealias GraphNode = Graph.Node

internal class Graph {
    private var nodes: [String: Node]
    
    struct Node {
        let key: String
        private(set) var downstream: Set<String>
        private(set) var upstream: Set<String> = []
        
        init(_ key: String, downstream: Set<String> = []) {
            self.key = key
            self.downstream = downstream
        }
        
        init(_ key: String, @GraphNodeBuilder _ builder: () -> Set<String>) {
            self.key = key
            self.downstream = builder()
        }
        
        mutating func add(downstream key: String) {
            downstream.insert(key)
        }
        
        mutating func add(upstream key: String) {
            upstream.insert(key)
        }
        
        mutating func remove(downstream key: String) {
            downstream.remove(key)
        }
        
        mutating func remove(upstream key: String) {
            upstream.insert(key)
        }
    }
    
    init() {
        nodes = [:]
    }
    
    init(@GraphBuilder _ builder: () -> [String: Node]) {
        nodes = builder()
        fixUpstreams()
    }
    
    func addEdge(key: String, downstream downKey: String) {
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
    
    func removeNode(key: String) {
        guard let node = nodes[key] else { return  }
        nodes.removeValue(forKey: key)
        
        node.downstream.forEach { key in
            removeEdge(key: key, upstream: node.key)
        }
        
        node.upstream.forEach { key in
            removeEdge(key: key, downstream: node.key)
        }
    }
    
    func dependencies(key: String) -> Set<String> {
        guard let n = nodes[key] else { return [] }
        
        return  Set<String>(n.upstream)
    }
    
    private func removeEdge(key: String, upstream upKey: String) {
        guard var node = nodes[key] else { return }
        node.remove(upstream: upKey)
        nodes[key] = node
    }
    
    private func removeEdge(key: String, downstream downKey: String) {
        guard var node = nodes[key] else { return }
        node.remove(downstream: downKey)
        nodes[key] = node
    }
    
    func isContainEdge(key: String, downstream downKey: String) -> Bool {
        guard let node = nodes[key] else {
            return false
        }
        
        if !nodes.has(downKey) {
            nodes[downKey] = Node(downKey)
        }
        
        return node.downstream.contains(downKey)
    }
    
    func getNode(for key: String) -> Node? {
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
