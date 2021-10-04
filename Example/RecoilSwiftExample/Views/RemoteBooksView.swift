import SwiftUI
import RecoilSwift

struct RemoteBooksView: HookView {
    var hookBody: some View {
        let selectedCategory = useRecoilValue(BookShop.selectedCategoryState)
        let categoryName = selectedCategory?.rawValue ?? "ALL"
        let loadable = useRecoilValueLoadable(BookShop.fetchRemoteBookNamesByCategory(categoryName))
        
        return VStack {
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
