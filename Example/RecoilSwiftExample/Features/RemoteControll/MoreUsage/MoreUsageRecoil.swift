import RecoilSwift

struct MoreUsage {
 
}

// MARK:- Selectors
extension MoreUsage {
  static let fetchRemoteBookNamesByCategory = selectorFamily { (category: String, accessor: StateGetter) async -> [String] in
      // let value = accessor.get(someAtom)
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      return ["\(category):Book1", "\(category):Book2"]
  }

  static let getLocalBookNames = selectorFamily { (category: String, accessor: StateGetter) -> [String] in
        ["local:\(category):Book1", "local:\(category):Book2"]
    }
}
