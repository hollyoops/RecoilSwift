import RecoilSwift

extension BookShop {    
    static let getLocalBookNames = selectorFamily { (category: String, get: Getter) -> [String] in
        ["local:\(category):Book1", "local:\(category):Book2"]
    }
}
