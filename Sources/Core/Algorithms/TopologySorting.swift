internal struct MetricNode {
    private(set) var upstreamCount: Int = 0
    private(set) var downstream: Set<String> = []
    
    mutating func increaseUpstream() {
        upstreamCount += 1
    }
    
    mutating func decreaseUpstream() {
        upstreamCount -= 1
    }
    
    mutating func appendDownstream(forKey key: String) {
        downstream.insert(key)
    }
}

internal class TopologySorting {
    var table: [String: MetricNode] = [:]
    
    var queue = Queue<String>()
    
    func checkCircleRef(in states: [String: Store.Node],
                        forKey key: String,
                        upstream upKey: String) -> Bool {
        if states[key].isNone {
            return true
        }
        
        prepareTable(with: states, key: key, upKey: upKey)
        
        while !queue.isEmpty {
            if let value = queue.dequeue() {
                removeNodeFromTable(forKey: value)
            }
        }
        
        return table.count > 0
    }
    
    private func prepareTable(with states: [String: Store.Node],
                      key: String,
                      upKey: String) {
        table = states.mapValues { node -> MetricNode in
            let upstreamCount = node.upstream.count
            return MetricNode(upstreamCount: upstreamCount, downstream: node.downstream)
        }
        
        addNode(forKey: key, upstream: upKey)
        table.forEach { key, node in
            if node.upstreamCount == 0 {
                queue.enqueue(key)
            }
        }
    }
    
    private func increaseUpstream(forKey key: String) {
        guard var node = table[key] else {
            return
        }
      
        node.increaseUpstream()
        table[key] = node
    }
    
    private func decreaseUpstream(forKey key: String) {
        guard var node = table[key] else {
            return
        }
        
        node.decreaseUpstream()
        table[key] = node
    }
    
    private func appendDownstream(forKey key: String, downstreamKey: String) {
        guard var node = table[key] else {
            return
        }

        node.appendDownstream(forKey: downstreamKey)
        table[key] = node
    }
    
    private func addNode(forKey key: String, upstream upKey: String) {
        increaseUpstream(forKey: key)
        appendDownstream(forKey: upKey, downstreamKey: key)
    }
    
    private func removeNodeFromTable(forKey key: String) {
        guard let node = table[key] else {
            return
        }
    
        node.downstream.forEach { item in
            decreaseUpstream(forKey: item)
            if let itemNode = table[item],
               !queue.contains(item) && itemNode.upstreamCount <= 0 {
                queue.enqueue(item)
            }
        }
        
        table.removeValue(forKey: key)
    }
}
