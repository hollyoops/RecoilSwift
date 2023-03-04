import SwiftUI
import RecoilSwift

struct FilterInfoView: HookView {
    
    @MainActor
    var hookBody: some View {
        let selectedCategoryState = useRecoilState(BookList.selectedCategoryState)
        let value = selectedCategoryState.wrappedValue?.rawValue ??  "None"
        
        HStack {
            Text(verbatim: "Selected Category: ")
                .font(.headline)
                .fontWeight(.regular)
                .foregroundColor(.primary)
            
            Text("\(value.capitalized)")
                .foregroundColor(.cyan)
        
            Spacer()
        }
    }
}
