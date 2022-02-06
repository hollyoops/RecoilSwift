import SwiftUI
import RecoilSwift
import ReactiveForm

class NewBookForm: ObservableForm {
  @FormField(validators: [.required])
  var bookName: String = ""
  
  @FormField(validators: [])
  var category: BookCategory = .other
  
  @FormField(validators: [])
  var publishDate: Quarter = .q1
}

extension NewBookForm {
  func toBook() -> Book {
    Book(name: bookName, category: category, publishDate: publishDate)
  }
}

struct AddBookView: HookView {
  @StateObject var form = NewBookForm()
  
  var hookBody: some View {
    let addBook = useRecoilCallback(AllBooks.addNew(context:newBook:))
    let navigateTo = useRecoilCallback(Home.selectTab(_:tab:))
    
    Form {
      VStack(alignment: .leading) {
        TextField("Name", text: $form.bookName)
        if form.$bookName.isDirty && form.$bookName.isInvalid {
          Text("Please input the name of the book.")
            .foregroundColor(.red)
        }
      }
      
      VStack(alignment: .leading) {
        Text("Select a category:")
        Picker("Book category?", selection: $form.category) {
          ForEach(Book.Category.allCases, id: \.self) {
            Text($0.rawValue)
          }
        }
        .pickerStyle(.segmented)
      }
      
      VStack(alignment: .leading) {
        Text("Select a quarter:")
        Picker("Publish quarter?", selection: $form.publishDate) {
          ForEach(Quarter.allCases, id: \.self) {
            Text($0.rawValue)
          }
        }
        .pickerStyle(.segmented)
      }
      
      VStack(alignment: .center) {
        Button("Add Book") {
          if (addBook(form.toBook())) {
            navigateTo(HomeTab.list)
          }
        }.disabled(form.isInvalid)
      }
    }
  } 
}
