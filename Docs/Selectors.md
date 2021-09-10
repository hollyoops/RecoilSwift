# Selector

## Core Concept

A selector is a pure function that accepts atoms or other selectors as input. When these upstream atoms or selectors are updated, the selector function will be re-evaluated. Components can subscribe to selectors just like atoms, and will then be re-rendered when the selectors change.

**Selectors** are used to calculate derived data that is based on state. This lets us avoid redundant state because a minimal set of state is stored in atoms, while everything else is efficiently computed as a function of that minimal state.

[Check more about selector](https://recoiljs.org/docs/introduction/core-concepts#selectors)

## Readonly Selector
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

A bi-directional selector receives the incoming value as a parameter and can use that to propagate the changes back upstream along the data-flow graph. 

```swift
let tempFahrenheitState = atom(32)
let tempCelsiusSelector = selector(
    get: { get -> String
        let fahrenheit = get(tempFahrenheitState)
        return (fahrenheit - 32) * 5 / 9
    },
    set: { set, newValue in
        let newFahrenheit = (newValue * 9) / 5 + 32
        set(tempFahrenheitState, newFahrenheit)
    }
)

struct YourView: View {
    // Writable Selector have to wrapped as Recoil state
    @RecoilState(tempCelsiusSelector) var tempCelsius : Int
    
    var body: some View {
        Text("Current \(tempCelsius)")

        Button("Change temp") {
            tempCelsius = 40
            // or tempCelsius(40) 
            // now the value of tempFahrenheitState is 104
        }
    }
}
```

[More about writeable selector](https://recoiljs.org/docs/api-reference/core/selector/#writeable-selectors)
## Async Selector

```swift
let remoteCategoriesSelector = selector { (get: Getter) -> AnyPublisher<[String], Error> in
    Deferred {
        Future { promise in
           ...
        }
    }.eraseToAnyPublisher()
}

func someView() -> some View {
  HookScope {
    var hookBody: some View {
      let remoteCategories = useRecoilValue(remoteCategoriesSelector)

       if let categories = remoteCategories else {
           categoriesView()
       }
    }
  }
}
```
 
## Customized Parameter Selector

Check the [selectorFamily](Utils.md#Selector-Family)
