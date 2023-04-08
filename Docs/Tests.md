# Selector

## Core Concept

A selector is a pure function that accepts atoms or other selectors as input. When these upstream atoms or selectors are updated, the selector function will be re-evaluated. Components can subscribe to selectors just like atoms, and will then be re-rendered when the selectors change.

**Selectors** are used to calculate derived data that is based on state. This lets us avoid redundant state because a minimal set of state is stored in atoms, while everything else is efficiently computed as a function of that minimal state.

[Check more about selector](https://recoiljs.org/docs/introduction/core-concepts#selectors)

## Readonly Selector
```swift
struct BookList {
    static var currentValue: AsyncSelector<[Book]> {
        selector { accessor -> [Book] in
            let books = try accessor.get(AllBooks.list)
            return books
        }
    }
}

```

## Writeable Selector

A bi-directional selector receives the incoming value as a parameter and can use that to propagate the changes back upstream along the data-flow graph. 

```swift
struct TempFahrenheitState: SyncAtomNode {
    typealias T = Int
    func getValue() throws -> Int {
        32
    }
}

struct TempCelsiusSelector: SyncSelectorNode, Writeable {
    typealias T = Int

    func getValue(_ accessor: StateGetter) throws -> Int {
        let fahrenheit = accessor.getUnsafe(TempFahrenheitState())
        return (fahrenheit - 32) * 5 / 9
    }

    func setValue(context: MutableContext, newValue: Int) {
        let newFahrenheit = (newValue * 9) / 5 + 32
        context.accessor.set(TempFahrenheitState(), newFahrenheit)
    }
}

func celsiusView() -> some View {
    // Writable Selector have to wrapped as Recoil state
    let tempCelsius = ctx.useRecoilState(TempCelsiusSelector())
    
    Text("Current \(tempCelsius)")

    Button("Change temp") {
        tempCelsius.wrapperValue = 40
        // now the value of tempFahrenheitState is 104
    }
}
```

[More about writeable selector](https://recoiljs.org/docs/api-reference/core/selector/#writeable-selectors)
## Async Selector

You can use use `async/await` or `Combine` to execute async task in iOS. For instance: 

```swift
struct BookList {
    static var currentBooks: AsyncSelector<[Book]> {
        selector { accessor -> [Book] in
            let books = try await accessor.get(AllBooks.allBookState)
            if let category = try accessor.get(selectedCategoryState) {
                return books.filter { $0.category == category }
            }
            return books
        }
    }
}

```

Use combine

```swift
static var remoteCategoriesSelector: AsyncSelector<[Book]> {
  selector { (get: Getter) -> AnyPublisher<[String], Error> in
    Deferred {
        Future { promise in
           ...
        }
    }.eraseToAnyPublisher()
  }
}
```

run the async tasks
```swift
struct SomeView: View {
    @RecoilScope var ctx
    var body: some View {
      let remoteCategories = ctx.useRecoilValue(remoteCategoriesSelector)

       if let categories = remoteCategories else {
           categoriesView()
       }
    }
}
```
 
## Customized Parameter Selector

Check the [selectorFamily](Utils.md#Selector-Family)
## How to test with RecoilSwift