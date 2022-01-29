import Foundation

public typealias BookCategory = Book.Category

public struct Book: Identifiable {
    public var id = UUID()
    public enum Category: String, CaseIterable {
        case emotion
        case education
        case language
        case other
    }

    var name: String
    var category: Category
    var publishDate: Quarter
}

extension Book: Hashable {
    
}



enum BookError: Error { }
