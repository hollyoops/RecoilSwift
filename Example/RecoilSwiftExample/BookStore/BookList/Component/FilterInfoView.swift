import SwiftUI
import RecoilSwift

struct FilterInfoView: View {
    @RecoilScope var recoil
    
    var body: some View {
        let selectedCategoryState = recoil.useValue(BookList.selectedCategoryState)
        let value = selectedCategoryState??.rawValue ??  "None"
        
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
