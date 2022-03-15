import SwiftUI
import RecoilSwift

struct CartView: HookView {
  var hookBody: some View {
    VStack(alignment: .leading, spacing: 6) {
      NavigationView {
        CartContent()
          .navigationTitle("Cart")
      }
    }
  }
}
