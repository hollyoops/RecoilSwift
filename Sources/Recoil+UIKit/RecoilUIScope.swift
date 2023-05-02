#if canImport(UIKit)

import UIKit

internal let globalStore = RecoilStore()

public protocol RecoilUIScope: ViewRefreshable {
    var recoil: ScopedRecoilContext { get }
}

private struct RecoilUIScopeKeys {
    static var cache = "recoilswift.stateCache"
}

private func stateCache<T: RecoilUIScope & NSObjectProtocol>(for object: T) -> ScopedStateCache {
    if let cache = objc_getAssociatedObject(object, &RecoilUIScopeKeys.cache) as? ScopedStateCache {
        return cache
    } else {
        let cache = ScopedStateCache()
        objc_setAssociatedObject(object, &RecoilUIScopeKeys.cache, cache, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return cache
    }
}

extension RecoilUIScope where Self: UIViewController {
    public var recoil: ScopedRecoilContext {
        ScopedRecoilContext(store: globalStore,
                            cache: stateCache(for: self),
                            refresher: self)
    }
}

extension RecoilUIScope where Self: UIView {
    public var recoil: ScopedRecoilContext {
        ScopedRecoilContext(store: globalStore,
                            cache: stateCache(for: self),
                            refresher: self)
    }
}

#endif
