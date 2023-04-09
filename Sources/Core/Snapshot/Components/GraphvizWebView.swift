import SwiftUI

#if os(iOS)
import WebKit

struct GraphvizWebView: UIViewRepresentable {
    let html: String
    var dotGraph: String
    @Binding var isGraphReady: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.isLoading {
            uiView.stopLoading()
        }

        if context.coordinator.initialLoadDone {
            let js = "graphvizRender(`\(dotGraph)`);"
            uiView.evaluateJavaScript(js, completionHandler: nil)
        } else {
            let content = html.replacingOccurrences(of: "{DOT_GRAPH_STRING}", with: dotGraph)
            uiView.loadHTMLString(content, baseURL: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: GraphvizWebView
        var initialLoadDone: Bool = false

        init(_ parent: GraphvizWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            initialLoadDone = true
            let js = "graphvizRender(`\(parent.dotGraph)`);"
            webView.evaluateJavaScript(js, completionHandler: nil)
            DispatchQueue.main.async { [weak self] in
                self?.parent.isGraphReady = true
            }
        }
    }
}
#else
struct GraphvizWebView: View {
    let html: String
    var dotGraph: String
    @Binding var isGraphReady: Bool
    
    var body: some View {
        // Return a placeholder view for macOS
        Text("GraphvizWebView is not available on macOS")
    }
}
#endif
