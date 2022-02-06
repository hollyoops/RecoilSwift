import SwiftUI

struct RemoteControllView: View {
  var body: some View {
    NavigationView {
      AddBookView()
        .navigationBarTitle("New Book")
        .navigationBarItems(
          trailing:
            NavigationLink(destination: MoreUsageView()) {
              Label("", systemImage: "ellipsis")
            }
        )
    }
  }
}
