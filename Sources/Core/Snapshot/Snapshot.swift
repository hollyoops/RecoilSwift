import Foundation

public class Snapshot {
    private let graph: Graph

    init(graph: Graph) {
        self.graph = graph
    }

    public func generateDotGraph(isSortNodeByName: Bool = false) -> String {
        let nodes = isSortNodeByName ?
            graph.allNodes().values.sorted(by: { $0.key.name < $1.key.name }) :
            Array(graph.allNodes().values)
        
        if nodes.isEmpty {
            return Self.emptyDotGraph
        }
        
        let atomColor = "[fillcolor=\"gold\" color=\"darkgoldenrod\"]"
        let selectorColor = "[fillcolor=\"peru\" color=\"sienna\"]"
        let nodesStrings = nodes.flatMap { node in
            let nodeName = node.key.name
            let color = node.key.nodeType == .atom ? atomColor : selectorColor
            let nodeString = """
                \(nodeName) \(color);
                """

            let edgesStrings = node.downstream.map { downstreamNodeKey in
                let downstreamNodeName = downstreamNodeKey.name
                return """
                \(nodeName) -> \(downstreamNodeName) [color="saddlebrown"];
                """
            }

            return [nodeString] + edgesStrings
        }

        let allLines = """
            digraph Store {
            node [style="filled"];
            \(nodesStrings.joined(separator: "\n"))
            }
            """
        return allLines
    }
}

extension Snapshot: Equatable {
    public static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        lhs.generateDotGraph(isSortNodeByName: true) == rhs.generateDotGraph(isSortNodeByName: true)
    }
}

extension Graph: CustomStringConvertible {
    var description: String {
        Snapshot(graph: self)
            .generateDotGraph(isSortNodeByName: true)
    }
}

public extension Snapshot {
    static var emptyDotGraph: String {
        "digraph Empty { label=\"Empty Store\"; }"
    }
}
