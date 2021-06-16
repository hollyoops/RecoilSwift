import SwiftUI
import RecoilSwift

struct ContentView: View {
    @RecoilValue(BookShop.currentBooksSel) var currentBooks: [Book]
    @RecoilValue(BookShop.fetchRemoteBookNames) var bookNames: [String]?
    @RecoilState(BookShop.allBookStore) var allBooks: [Book]
    @RecoilState(BookShop.selectedCategoryState) var selectedCategoryState: BookCategory?

    var body: some View {
        VStack {
            HStack {
                ForEach(BookCategory.allCases, id: \.self) { category in
                    Button(category.rawValue) {
                        print(category.rawValue)
                        selectedCategoryState = category
                    }.padding()
                }
            }

            ForEach(currentBooks, id: \.self) { itemView($0) }
        }.padding()
         .onAppear {
             allBooks = Mocks.ALL_BOOKS
         }
    }

    func itemView(_ book: Book) -> some View {
        HStack {
            Text(book.name)
            Spacer()
            Text(book.category.rawValue)
        }
        .padding()
        .background(Color.yellow)
    }
}

