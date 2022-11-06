import SwiftUI

public struct RecoilRoot<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The content and behavior of the view.
    public var body: some View {
        content.environment(
            \.store,
             RecoilStore.shared
        )
    }
}
