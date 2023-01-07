/// Adds timeout that races with `run`.
///
public func withTimeout<B>(
    seconds: UInt,
    run: @escaping () async throws -> B
) -> () async throws -> B {
    {
        try await withTimeout(nanoseconds: UInt64(seconds) * 1_000_000_000) { () in
            try await run()
        }()
    }
}

public func withTimeout<B>(
    nanoseconds: UInt64,
    run: @escaping () async throws -> B
) -> () async throws -> B {
    {
        try await withTimeout(nanoseconds: nanoseconds, run: { () in
            try await run()
        })(())
    }
}

public func withTimeout<A, B>(
    nanoseconds: UInt64,
    run: @escaping (A) async throws -> B
) -> (A) async throws -> B {
    { a in
        let timeout: (A) async throws -> B? = { _ in
            try await Task.sleep(nanoseconds: nanoseconds)
            return .none
        }

        let race = asyncFirst([run, timeout])

        if let value = try await race(a) {
            return value
        }
        else {
            throw TimeoutCancellationError()
        }
    }
}

// MARK: - TimeoutCancellationError
public struct TimeoutCancellationError : Error {}

/// Runs multiple `fs` concurrently and returns the first arrival, which can be either success or error.
/// This method is equivalent to `Promise.race` in JavaScript.
public func asyncFirst<A, B>(_ fs: [(A) async throws -> B]) -> (A) async throws -> B {
    precondition(!fs.isEmpty, "asyncFirst error: async array is empty.")

    return { a in
        try await withThrowingTaskGroup(of: B.self) { group -> B in
            for f in fs {
                group.addTask {
                    try await f(a)
                }
            }

            let first = try await group.next()!
            group.cancelAll()
            return first
        }
    }
}
