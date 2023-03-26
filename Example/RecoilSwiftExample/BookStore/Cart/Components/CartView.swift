import SwiftUI
import RecoilSwift

struct CartView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
        CartContent()
          .navigationTitle("Cart")
    }
  }
}
