import SwiftUI
import Foundation

enum LoadingState {
    case loading
    case success(html: String)
    case failure(Error)
}

@available(iOS 14.0, *)
public struct SnapshotView: View {
    @State private var loadingState: LoadingState = .loading
    @State private var dotGraph = Snapshot.emptyDotGraph
    @State private var isGraphReady = false
    
    @RecoilSnapshot private var latestSnapshot: Snapshot
    
    public init() { }
    
    public var body: some View {
        Group {
            switch loadingState {
            case .loading:
                ProgressView("Init...")
            case .success(let html):
                GraphvizWebView(html: html, dotGraph: dotGraph, isGraphReady: $isGraphReady)
            case .failure(let error):
                SnapshotErrorView(error: error, retryAction: loadHTML)
            }
        }.onChange(of: latestSnapshot) {
            guard isGraphReady else { return }
            dotGraph = $0.generateDotGraph()
        }
        .onChange(of: isGraphReady) { isReady in
            guard isReady else { return }
            dotGraph = latestSnapshot.generateDotGraph()
        }
        .onAppear {
            Task {
                await loadHTML()
            }
        }
    }
    
    @MainActor
    private func loadHTML() async {
        loadingState = .loading
        
        do {
            let html = try await fetchHTML()
            loadingState = .success(html: html)
        } catch {
            loadingState = .failure(error)
        }
    }
    
    private func fetchHTML() async throws -> String {
        guard let vizJsPath = Bundle.module.path(forResource: "viz-lite@1.8.2",
                                                 ofType: "js",
                                                 inDirectory: "graph-web"),
              let vizJsCode = try? String(contentsOfFile: vizJsPath, encoding: .utf8),
              let htmlPath = Bundle.module.path(forResource: "render",
                                                ofType: "html",
                                                inDirectory: "graph-web"),
              let htmlCode = try? String(contentsOfFile: htmlPath, encoding: .utf8) else {
            throw SnapshotError.notFound
        }
        
        return htmlCode
            .replacingOccurrences(of: "{VIZ_JS_CODE}", with: vizJsCode)
    }
}
