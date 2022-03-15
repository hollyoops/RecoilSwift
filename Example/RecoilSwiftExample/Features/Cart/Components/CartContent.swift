import SwiftUI
import RecoilSwift

struct CartContent: HookView {
  var hookBody: some View {
    let items = useRecoilValue(Cart.allCartItemState)
    let increaseCount = useRecoilCallback(Cart.increasItemCount(context:item:))
    let decreaseCount = useRecoilCallback(Cart.decreasItemCount(context:item:))
    
    List(items) { item in
      HStack {
        Text(item.book.name)
        Spacer()
        
        HStack(spacing: 10) {
          Button("-") {
            decreaseCount(item)
          }
          TextField("", text: .constant(String(item.count)))
            .multilineTextAlignment(.center)
            .frame(width: 20)
            .background(Color.white)
            .border(Color.black)
          Button("+") {
            increaseCount(item)
          }
        }
      }
      .padding()
      .buttonStyle(PlainButtonStyle())
    }
  }
}

struct CartContent_Previews: PreviewProvider {
  static var previews: some View {
    CartContent()
  }
}
