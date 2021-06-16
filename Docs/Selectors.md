# Selector

## Core Concept

A selector represents a piece of derived state. You can think of derived state as the output of passing state to a pure function that modifies the given state in some way.

Derived state is a powerful concept because it lets us build dynamic data that depends on other data. In the context of our todo list application, the following are considered derived state

## Basic Usage

```swift
let currentBooksSel = selector { get -> [Book] in
    let books = get(allBookStore)
      if let category = get(selectedCategoryState) {
          return books.filter { $0.category == category }
      }
    return books
}
```

## Writeable Selector

TBD

## Async Selector

TBD
