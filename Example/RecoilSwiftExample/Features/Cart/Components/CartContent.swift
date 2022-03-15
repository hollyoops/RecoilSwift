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
      ActionView(item)
    }
    .padding()
  }
}

struct ActionView: HookView {
  
  private var cartItem: CartItem
  
  init(_ item: CartItem) {
    self.cartItem = item
  }
  
  var hookBody: some View {
    let increaseCount = useRecoilCallback(Cart.increasItemCount(context:item:))
    let decreaseCount = useRecoilCallback(Cart.decreasItemCount(context:item:))
    HStack(spacing: 10) {
      Button("-") {
        decreaseCount(cartItem)
      }
      TextField("", text: .constant(String(cartItem.count)))
        .multilineTextAlignment(.center)
        .frame(width: 20)
        .background(Color.white)
        .border(Color.black)
      Button("+") {
        increaseCount(cartItem)
      }
    }
  }
}

struct CartContent_Previews: PreviewProvider {
  static var previews: some View {
    CartContent()
  }
}
