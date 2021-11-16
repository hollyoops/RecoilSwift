func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

func curry<A, B, C>(_ f: @escaping (A, B) throws -> C) -> (A) -> (B) throws -> C {
  return { a in { b in try f(a, b) } }
}

func curry<A, B, C>(_ f: @escaping (A, B) async throws -> C) -> (A) -> (B) async throws -> C {
  return { a in { b in try await f(a, b) } }
}

func curryFirst<A, B>(_ f: @escaping (A) -> B) -> (A) -> () -> B {
   { a in { () in f(a) } }
}

func curryFirst<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
   { a in { b in f(a, b) } }
}

func curryFirst<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B, C) -> D {
   { a in { b, c in f(a, b, c) } }
}
