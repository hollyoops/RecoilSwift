import SwiftUI
import RecoilSwift

struct LoadableExampleView: HookView {
    @MainActor
    var hookBody: some View {
        bookNameViews
    }
    
    @ViewBuilder
    @MainActor var bookNameViews: some View {
        let selectedCategory = useRecoilValue(BookList.selectedCategoryState)
        let categoryName = selectedCategory??.rawValue ?? "ALL"
        let loadable = useRecoilValueLoadable(MoreUsage.fetchRemoteBookNamesByCategory(categoryName))
        
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
