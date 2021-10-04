import SwiftUI
import RecoilSwift

struct CategoryView: HookView {
    var hookBody: some View {
        let selectedCategoryState = useRecoilState(BookShop.selectedCategoryState)
        
        VStack {
            HStack {
                ForEach(BookCategory.allCases, id: \.self) { category in
                    Button(category.rawValue) {
                        print(category.rawValue)
                        selectedCategoryState.wrappedValue = category
                    }.padding()
                }
            }
            
            let value = selectedCategoryState.wrappedValue?.rawValue ??  "None"
            Text(verbatim:  "Current Category: \(value)")
                .font(.headline)
                .fontWeight(.regular)
                .foregroundColor(.primary)
        }
    }
}
