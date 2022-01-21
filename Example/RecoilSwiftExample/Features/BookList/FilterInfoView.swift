import SwiftUI
import RecoilSwift

struct FilterInfoView: HookView {
    var hookBody: some View {
        let selectedCategoryState = useRecoilState(BookList.selectedCategoryState)
        let value = selectedCategoryState.wrappedValue?.rawValue ??  "None"
        
        Text(verbatim:  "Current Category: \(value.capitalized)")
            .font(.headline)
            .fontWeight(.regular)
            .foregroundColor(.primary)
    }
}
