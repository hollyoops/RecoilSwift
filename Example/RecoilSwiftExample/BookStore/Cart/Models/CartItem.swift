import Foundation

public struct CartItem: Identifiable {
    public var id: UUID {
        book.id
    }
    
    var book: Book
    var count: Int
}

extension CartItem: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.book.id == rhs.book.id &&
        lhs.count == rhs.count
    }
}
