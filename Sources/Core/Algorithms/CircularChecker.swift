protocol CircularChecker {
  func canAddEdge(graph: Graph,
                  forKey key: String,
                  downstream upKey: String) -> Bool
}

struct DFSCircularChecker : CircularChecker {
  func canAddEdge(graph: Graph,
                  forKey key: String,
                  downstream downKey: String) -> Bool {
    guard key != downKey else { return false }
    var stack = [key, downKey]
    return doCheck(graph: graph, stack: &stack, target: downKey)
  }
  
  private func doCheck(graph: Graph, stack: inout [String], target: String) -> Bool {
    guard let node = graph.getNode(for: target) else {
      return true
    }
    
    for itemKey in node.downstream  {
      if stack.contains(itemKey) {
        return false
      }
      
      stack.append(itemKey)
      if !doCheck(graph: graph, stack: &stack, target: itemKey) {
        return false
      }
      _ = stack.popLast()
    }
    
    return true
  }
}
