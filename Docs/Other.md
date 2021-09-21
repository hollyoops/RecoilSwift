## Reactish

```swift
// Created a async atom
let allBooksState = atom { 
    fetchRemoteBooks()
}
let selectedCategoryState = atom<Category?> { nil }

// Create readonly Selector
let currentBooksSelector = selector { get -> [Book] in
    let books = get(allBooksState)
    if let category = get(selectedCategoryState) {
        return books.filter { $0.category == category }
    }
    return books
}

// Get data from states
struct YourView1: RecoilView { 
    var hookBody: some View { 
        let currentBooks = useRecoilValue(currentBooksSelector)

        return VStack {
            if let books = currentBooks {
                dataView(allBook: books)
            }
        }
    }
}

// Modify state in another view
struct YourView2: RecoilView {
    var hookBody: some View { 
        let selectedCategory = useRecoilState(selectedCategoryState)

        return Button("Change Category") {
            selectedCategory.wrapperValue = .educate
            // View 1 will be rerender
        }
    }
}
```