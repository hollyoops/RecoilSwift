import SwiftUI
import RecoilSwift

struct QuickDemoView: View {
    @RecoilScope var ctx: ScopedRecoilContext
    
    @ViewBuilder
    var body: some View {
        let _ = print("veiw Update")

        var category = ctx.useRecoilState(BookList.selectedCategoryState)
        
        VStack {
//            Text(text)
            Text("Category: \(category.wrappedValue?.rawValue ?? "No Value")")
            Button("make Upper") {
//                text = .emotion
            }
            Button("Set category") {
//                category.wrappedValue = .education
                category.wrappedValue = .emotion
            }
        }
    }
}

struct QuickDemoView_Previews: PreviewProvider {
    static var previews: some View {
        QuickDemoView()
    }
}
