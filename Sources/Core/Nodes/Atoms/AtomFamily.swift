import Combine

public struct ParametricRecoilValue<P, Node: RecoilNode> {
    let recoilValue: Node
    let param: P
}

public typealias FamilyFunc<P, T: RecoilNode> = (P) -> ParametricRecoilValue<P, T>

public typealias AtomFamilyGet<P, T> = (P) throws -> T

public typealias AtomFamilyCombineGet<P, T, E: Error> = (P) -> AnyPublisher<T, E>

public typealias AtomFamilyAsyncGet<P, T> = (P) async throws -> T


//MARK: - Families

/// A ``atomFamily`` is a powerful pattern that is similar to a atom, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that is passed an object of named callbacks that returns the value of the atom
/// - Returns: A function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.
public func atomFamily<P: Hashable, T: Equatable>(
    _ getBody: @escaping AtomFamilyGet<P, T>,
    fileID: String = #fileID,
    line: Int = #line
) -> FamilyFunc<P, Atom<T>> {
    return { (param: P) -> ParametricRecoilValue<P, Atom<T>> in
        
        let keyName = sourceLocationKey(Atom<T>.self, fileName: fileID, line: line)
        let key = NodeKey(name: keyName) { hasher in
            hasher.combine(param)
        }
        return ParametricRecoilValue(
            recoilValue: Atom(key: key){ try getBody(param) },
            param: param
        )
    }
}

/// A ``atomFamily`` is a powerful pattern that is similar to a atom, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous atom with combine. Each unique parameter value will return the same memoized atom instance.
public func atomFamily<P: Hashable, T: Equatable, E: Error>(
    _ getBody: @escaping AtomFamilyCombineGet<P, T, E>,
    fileID: String = #fileID,
    line: Int = #line
) -> FamilyFunc<P, AsyncAtom<T>> {
    return { (param: P) -> ParametricRecoilValue<P, AsyncAtom<T>> in
        let keyName = sourceLocationKey(AsyncAtom<T>.self, fileName: fileID, line: line)
        let key = NodeKey(name: keyName) { hasher in
            hasher.combine(param)
        }
        
        return ParametricRecoilValue(
            recoilValue: AsyncAtom(key: key) { try await getBody(param).async() },
            param: param
        )
    }
}

/// A ``atomFamily`` is a powerful pattern that is similar to a atom, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous atom with ``async/await``. Each unique parameter value will return the same memoized atom instance.
public func atomFamily<P: Hashable, T: Equatable>(
  _ getBody: @escaping AtomFamilyAsyncGet<P, T>,
  fileID: String = #fileID,
  line: Int = #line
) -> FamilyFunc<P, AsyncAtom<T>> {
    return { (param: P) -> ParametricRecoilValue<P, AsyncAtom<T>> in
        
        let keyName = sourceLocationKey(AsyncAtom<T>.self, fileName: fileID, line: line)
        let key = NodeKey(name: keyName) { hasher in
            hasher.combine(param)
        }
        return ParametricRecoilValue(
            recoilValue: AsyncAtom(key: key) { try await getBody(param) },
            param: param
        )
    }
}
