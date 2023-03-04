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
    
    VStack {
      Form {
        VStack(alignment: .leading) {
          TextField("Book name", text: $form.bookName)
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
      }
      .background(Color(white: 0.95))
      .frame(height: 280)
      
      Button("Add to local") {
          Task {
              if (try await addBook(form.toBook())) {
                navigateTo(HomeTab.list)
              }
          }
     
      }
      .frame(width: 200, height: 60)
      .foregroundColor(Color.white)
      .background(form.isInvalid ? Color.gray : Color.blue)
      .cornerRadius(12)
      .disabled(form.isInvalid)
      Spacer()
    }.background(Color(white: 0.95))
  }
}
