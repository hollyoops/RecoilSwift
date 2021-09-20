struct Queue<T: Hashable>: CustomStringConvertible {
    class Node<T>: CustomStringConvertible {
        
        var value: T
        var next: Node?
        
        var description: String {
            guard let next = next else { return "\(value)" }
            return "\(value) -> " + String(describing: next)
        }
        
        init(value: T, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }
    
    var front: Node<T>?
    
    var rear: Node<T>?
    
    private var allValues: Set<T> = []
    
    init() { }
    
    var isEmpty: Bool {
        return front == nil
    }
    
    var description: String {
        guard let front = front else { return "Empty Queue" }
        return String(describing: front)
    }
    
    var peek: T? {
        return front?.value
    }
}

extension Queue {
    mutating private func push(_ value: T) {
        front = Node(value: value, next: front)
        if rear == nil {
            rear = front
        }
    }
    
    func contains(_ value: T) -> Bool {
        allValues.contains(value)
    }
    
    mutating func enqueue(_ value: T) {
        if isEmpty {
            self.push(value)
            return
        }
        
        rear?.next = Node(value: value)
        rear = rear?.next
        allValues.insert(value)
    }
    
    mutating func dequeue() -> T? {
        let val = front?.value
        defer {
            if let v = val {
                allValues.remove(v)
            }

            front = front?.next
            if isEmpty {
                rear = nil
            }
        }
        return val
    }
}
