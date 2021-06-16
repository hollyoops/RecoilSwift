public typealias BookCategory = Book.Category

public struct Book {
    public enum Category: String, CaseIterable {
        case emotion
        case education
        case language
    }

    var name: String
    var category: Category
    var publishDate: Quarter
}

extension Book: Hashable {
    
}
