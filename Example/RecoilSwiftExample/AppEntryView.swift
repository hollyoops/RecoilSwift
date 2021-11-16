import SwiftUI
import RecoilSwift
import Combine

struct AppEntryView: View {
    var body: some View {
        MainTabBar()
    }
}

struct AppEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AppEntryView()
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
