# Atoms & Selector

## Core Concept for Atom

Atoms are units of state. They're updatable and subscribable: when an atom is updated, each subscribed component is re-rendered with the new value. 

They can be created at runtime, too. Atoms can be used in place of local component state. If the same atom is used  from multiple components, all those components share their state.

## Create Atom

```swift
var fontSizeState: SyncAtom<Int> {
  atom(14)
}  
```

or

```swift
struct FontSizeState: SyncAtomNode {
    ...
}
```

## Core Concept for Selector

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

### read only selector family

A selectorFamily is a powerful pattern that is similar to a atom, but allows you to pass parameters to the get and set callbacks of a atom. The `atomFamily()` utility returns a function which can be called with user-defined parameters and returns an atom. Each unique parameter value will return the same memoized atom instance.

[View More](https://recoiljs.org/docs/api-reference/utils/atomFamily)

```swift
let doubleValue = atomFamily { (multiplier: Int, get: Getter) -> Int in
    2 * multiplier;
  }
}

func multipliedView() -> some View {
  // defaults to 200
  let multipliedNumber = useRecoilValue(doubleValue(100))

  return  VStack { ... }
}
```

## Selector Family

### read only selector family

A selectorFamily is a powerful pattern that is similar to a selector, but allows you to pass parameters to the get and set callbacks of a selector. The selectorFamily() utility returns a function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.

[View More](https://recoiljs.org/docs/api-reference/utils/selectorFamily)

```swift
var myNumberState = atom { 2 }
    
myMultipliedState = selectorFamily { (multiplier: Int, get: Getter) -> Int in
    get(myNumberState) * multiplier;
  }
}

func multipliedView() -> some View {
  // defaults to 2
  let number = useRecoilValue(myNumberState)

  // defaults to 200
  let multipliedNumber = useRecoilValue(myMultipliedState(100))

  return  VStack { ... }
}
```

### writeable selector family

TBD
