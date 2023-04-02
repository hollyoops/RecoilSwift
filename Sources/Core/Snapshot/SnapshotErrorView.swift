import SwiftUI

enum SnapshotError: LocalizedError {
    case notFound
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Resoruce file not found"
        case .loadFailed:
            return "Failed to load resoruce file"
        }
    }
}

struct SnapshotErrorView: View {
    let error: Error
    let retryAction: () async -> Void
    
    var body: some View {
        VStack {
            Text("Error: \(error.localizedDescription)")
            Button("Retry") {
                Task {
                    await retryAction()
                }
            }
        }
    }
}
