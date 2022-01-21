import SwiftUI
import RecoilSwift

struct LoadableExampleView: HookView {
  var hookBody: some View {
    if #available(iOS 15, *)  {
      bookNameViews
    } else {
      EmptyView()
    }
  }
  
  @available(iOS 15.0, *)
  @ViewBuilder var bookNameViews: some View {
    let selectedCategory = useRecoilValue(BookList.selectedCategoryState)
    let categoryName = selectedCategory?.rawValue ?? "ALL"
    let loadable = useRecoilValueLoadable(BookShop.fetchRemoteBookNamesByCategory(categoryName))
    
    VStack {
      if loadable.isLoading {
        Text("Automatic fetching names...")
        ProgressView()
          .padding(.vertical, 10)
      }
      
      if let names = loadable.data {
        ForEach(names, id: \.self) {
          Text($0)
        }
      }
    }
  }
}
