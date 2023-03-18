import Combine

public struct RecoilParamNode<P, Node: RecoilNode> {
    let node: Node
    let param: P
}

public typealias AtomFamily<P: Hashable, T: Equatable> = (P) -> RecoilParamNode<P, Atom<T>>

public typealias AsyncAtomFamily<P: Hashable, T: Equatable> = (P) -> RecoilParamNode<P, AsyncAtom<T>>

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
    funcName: String = #function,
    fileID: String = #fileID,
    line: Int = #line
) -> AtomFamily<P, T> {
    return { (param: P) -> RecoilParamNode<P, Atom<T>> in
        let pos = SourcePosition(funcName: funcName, fileName: fileID, line: line)
        let key = NodeKey(position: pos) { hasher in
            hasher.combine(param)
        }
        return RecoilParamNode(
            node: Atom(key: key){ try getBody(param) },
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
    funcName: String = #function,
    fileID: String = #fileID,
    line: Int = #line
) -> AsyncAtomFamily<P, T> {
    return { (param: P) -> RecoilParamNode<P, AsyncAtom<T>> in
        let pos = SourcePosition(funcName: funcName, fileName: fileID, line: line)
        let key = NodeKey(position: pos) { hasher in
            hasher.combine(param)
        }
        
        return RecoilParamNode(
            node: AsyncAtom(key: key) { try await getBody(param).async() },
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
  funcName: String = #function,
  fileID: String = #fileID,
  line: Int = #line
) -> AsyncAtomFamily<P, T> {
    return { (param: P) -> RecoilParamNode<P, AsyncAtom<T>> in
        
        let pos = SourcePosition(funcName: funcName, fileName: fileID, line: line)
        let key = NodeKey(position: pos) { hasher in
            hasher.combine(param)
        }
        return RecoilParamNode(
            node: AsyncAtom(key: key) { try await getBody(param) },
            param: param
        )
    }
}
