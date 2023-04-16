public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}
public func curry<A, B, C>(_ f: @escaping (A, B) throws -> C) -> (A) -> (B) throws -> C {
  return { a in { b in try f(a, b) } }
}

public func curry<A, B, C>(_ f: @escaping (A, B) async throws -> C) -> (A) -> (B) async throws -> C {
  return { a in { b in try await f(a, b) } }
}

public func curryFirst<A, B>(_ f: @escaping (A) -> B) -> (A) -> () -> B {
   { a in { () in f(a) } }
}

public func curryFirst<A, B>(_ f: @escaping (A) async throws -> B) -> (A) -> () async throws -> B {
   { a in { () in try await f(a) } }
}

public func curryFirst<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
   { a in { b in f(a, b) } }
}

public func curryFirst<A, B, C>(_ f: @escaping (A, B) async throws -> C) -> (A) -> (B) async throws ->  C  {
    { a in { b in try await f(a, b) } }
}

public func curryFirst<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B, C) -> D {
   { a in { b, c in f(a, b, c) } }
}

public func curryFirst<A, B, C, D>(_ f: @escaping (A, B, C) async throws -> D) -> (A) -> (B, C) async throws -> D {
   { a in { b, c in try await f(a, b, c) } }
}
