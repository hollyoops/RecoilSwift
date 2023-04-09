import SwiftUI
import RecoilSwift

struct CartContent: View {
    @RecoilScope var ctx
    
    var body: some View {
        let itemsState = try? ctx.useRecoilValue(Cart.allCartItemState)
        
        Group {
            if let items = itemsState, !items.isEmpty {
                cartList(items)
            } else {
                emptyView()
            }
        }
    }
    
    private func emptyView() -> some View {
        Text("No book in cart \n Choose some in bookshop")
            .multilineTextAlignment(.center)
            .font(.headline)
            .foregroundColor(.gray)
    }
    
    private func cartList(_ items: [CartItem]) -> some View {
        let increaseCount = ctx.useRecoilCallback(Cart.increasItemCount(context:item:))
        let decreaseCount = ctx.useRecoilCallback(Cart.decreasItemCount(context:item:))
        let deleteItem = ctx.useRecoilCallback(Cart.deleteItem(context:atIndex:))
        
        return List {
            ForEach(items) { item in
                HStack {
                    Text(item.book.name)
                    Spacer()
                    
                    HStack(spacing: 10) {
                        Button {
                            decreaseCount(item)
                        } label: {
                            Image(systemName: "minus.square")
                        }
                        TextField("", text: .constant(String(item.count)))
                            .multilineTextAlignment(.center)
                            .frame(width: 20)
                            .background(Color.white)
                            .border(Color.black)
                        Button {
                            increaseCount(item)
                        } label: {
                            Image(systemName: "plus.square")
                        }
                    }
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: deleteItem)
        }
        
    }
}

struct CartContent_Previews: PreviewProvider {
    static var previews: some View {
        CartContent()
    }
}
