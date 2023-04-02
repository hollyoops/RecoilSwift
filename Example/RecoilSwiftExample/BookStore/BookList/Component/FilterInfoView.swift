import SwiftUI
import RecoilSwift

struct FilterInfoView: View {
    @RecoilScope var ctx
    
    var body: some View {
        let selectedCategoryState = ctx.useRecoilState(BookList.selectedCategoryState)
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
