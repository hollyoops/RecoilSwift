import RecoilSwift

typealias HomeTab = Home.Tab

struct SelectedTabState: SyncAtomNode {
    typealias T = Home.Tab
    func getValue() throws -> Home.Tab {
        .list
    }
}

// MARK: - Atoms
struct Home {
    enum Tab {
        case list
        case remote
        case cart
    }
    
    static var selectedTabState: Atom<Tab> {
        atom(.list)
    }
    
    static var filterVisisbleState: AsyncSelector<Bool> {
        selector { ctx in
            let books = try await ctx.get(AllBooks.allBookState)
            return !books.isEmpty
        }
    }
}

// MARK: - Actions
extension Home {
    static func selectTab(_ context: RecoilCallbackContext, tab: Tab) {
        context.accessor.set(selectedTabState, tab)
    }
}
