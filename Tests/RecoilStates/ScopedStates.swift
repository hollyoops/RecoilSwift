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

struct CircleDeps {
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

struct MockAtoms {
    static var intState: Atom<Int> {
        atom { 0 }
    }
}

struct MockSelector {
    static var remoteBooks: AsyncSelectorFamily<[String], [String]> {
        selectorFamily { books, context in
            try? await Task.sleep(nanoseconds: TestConfig.mock_async_wait_nanoseconds)
            return books
        }
    }
    
    static var remoteBooksCombine: AsyncSelectorFamily<[String], [String]> {
        selectorFamily { books, context in
            MockAPI.makeCombine(result: .success(books), delay: TestConfig.mock_async_wait_seconds)
        }
    }
}
