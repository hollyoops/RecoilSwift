import SwiftUI
import RecoilSwift

struct CartContent: HookView {
  
  var hookBody: some View {
    let items = useRecoilValue(Cart.allCartItemState)
    List(items) { item in
      rowContent(item)
    }
  }
  
  private func rowContent(_ item: CartItem) -> some View {
    HStack {
      Text(item.book.name)
      Spacer()
      actionView(item)
    }
    .padding()
  }
  
  private func actionView(_ item: CartItem) -> some View {
    HStack(spacing: 10) {
      Button("-") {
        
      }
      TextField("", text: .constant(String(item.count)))
        .multilineTextAlignment(.center)
        .frame(width: 20)
        .background(Color.white)
        .border(Color.black)
      Button("+") {
        
      }
    }
  }
}

struct CartContent_Previews: PreviewProvider {
  static var previews: some View {
    CartContent()
  }
}
