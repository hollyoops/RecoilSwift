import RecoilSwift

struct RemoteNames {
    static var filteredNames: AsyncSelector<[String]> {
        selector { context in
            let states = try await context.get(names)
            return states.filter { !$0.isEmpty }
        }
    }
    
    static var names: AsyncSelector<[String]> {
        selector { _ in
            await MockAPI.makeAsync(value: ["", "Ella", "Chris", "", "Paul"])
        }
    }
}

struct CircleRef {
    typealias Selector = RecoilSwift.Selector
    
    static var stateA: Selector<String> {
        selector { context in try context.get(self.stateB) }
    }
    
    static var stateB: Selector<String> {
        selector { context in try context.get(self.stateA) }
    }
    
    static var selfReferenceState: Selector<String> {
        selector { context in try context.get(self.selfReferenceState) }
    }
}

struct MultipleTen {
    static var state: Selector<Int> {
        selector { context in
            try context.get(upstreamState) * 10
        }
    }
    
    static var upstreamState: Atom<Int> {
        atom { 0 }
    }
}

struct AsyncMultipleTen  {
    static var state: AsyncSelector<Int> {
        selector { context in
            try await context.get(upstreamState) * 10
        }
    }
    
    static var upstreamState: AsyncAtom<Int> {
        atom { 0 }
    }
}
