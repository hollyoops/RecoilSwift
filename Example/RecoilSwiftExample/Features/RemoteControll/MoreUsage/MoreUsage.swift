import SwiftUI

struct MoreUsageView: View {
  var body: some View {
    List {
      NavigationLink(
        "Loadable Usage",
        destination: LoadableExampleView()
      )
    }
    .navigationTitle("Examples")
  }
}

