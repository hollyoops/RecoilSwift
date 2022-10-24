extension Optional {
    var isNone: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
    
    var isSome: Bool {
        return !isNone
    }
    
    func on(some: () throws -> Void) rethrows {
      if self != nil { try some() }
    }


    func on(none: () throws -> Void) rethrows {
      if self == nil { try none() }
    }
}

extension Optional {
    func or(_ default: Wrapped) -> Wrapped {
        return self ?? `default`
    }

    func or(else: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? `else`()
    }

    func or(else: () -> Wrapped) -> Wrapped {
        return self ?? `else`()
    }

    func or(throw exception: Error) throws -> Wrapped {
        guard let unwrapped = self else { throw exception }
        return unwrapped
    }
}

extension Optional where Wrapped == Error {
    func or(_ else: (Error) -> Void) {
    guard let error = self else { return }
    `else`(error)
    }
}

extension Optional {
    func and<B>(_ optional: B?) -> B? {
        guard self != nil else { return nil }
        return optional
    }

    func and<T>(then: (Wrapped) throws -> T?) rethrows -> T? {
        guard let unwrapped = self else { return nil }
        return try then(unwrapped)
    }

    
    func zip2<A>(with other: Optional<A>) -> (Wrapped, A)? {
        guard let first = self, let second = other else { return nil }
        return (first, second)
    }

    func zip3<A, B>(with other: Optional<A>, another: Optional<B>) -> (Wrapped, A, B)? {
        guard let first = self,
              let second = other,
              let third = another else { return nil }
        return (first, second, third)
    }
}
