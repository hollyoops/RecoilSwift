import SwiftUI

struct MoreUsageView: View {
  var body: some View {
    List {
      NavigationLink(
        "Use Loadable with Hooks",
        destination: LoadableExampleView()
      )
    }
    .navigationTitle("Others")
  }
}

