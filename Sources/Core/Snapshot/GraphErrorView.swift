import SwiftUI

enum GraphViewError: LocalizedError {
    case notFound
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "File not found"
        case .loadFailed:
            return "Failed to load file"
        }
    }
}

struct GraphErrorView: View {
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
