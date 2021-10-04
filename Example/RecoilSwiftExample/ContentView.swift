import SwiftUI
import RecoilSwift
import Combine

struct ContentView: View {
    var body: some View {
        MainTabBar()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
