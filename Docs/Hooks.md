# RecoilHooks

## useRecoilValue(state)

Returns the value of the given Recoil state. This hook will implicitly subscribe the component to the given state. 

This is the recommended hook to use when a component intends to read state without writing to it, as this hook works with both `read-only` state and `writeable` state. Atoms are `writeable` state while selectors may be either `read-only` or `writeable`. 

`useRecoilValue` return a readonly state from atom or selector, even it's writeable.

`useRecoilState` return a `'Binding<State>'` that writeable from atom or selector.


```swift
let namesState = atom { ["", "Ella", "Chris", "", "Paul"] }
let filteredNamesState = selector { get -> [String] in
   get(namesState).filter { $0 != ""}
}

func nameDisplay() -> some View {
  let names = useRecoilValue(namesState);
  let filteredNames = useRecoilValue(filteredNamesState);

  return VStack {
    Text("Original names: \(names.join(","))")
    Text("Filtered names: \(filteredNames.wrappedValue.join(","))")

    Button("Reset to original") {
        filteredNames.wrappedValue = names
    }
  }
}
```

## useRecoilValueLoadable

See more [Loadable](Loadable.md) for detail

```swift
// In some function
func someView() -> some View {
    HookScope { // when your view is not implement with RecoilView, you have to use `HookScope`
        let id = useRecoilValue(selectedCategoryState)
        let loadable = useRecoilValueLoadable(fetchRemoteDataById(id))
        
        // This body will be render after task completed
        return VStack {
            // while loading
            if loadable.isLoading {
                ProgressView()
            }

            // when error
            if let err = loadable.errors.first {
                errorView(err)
            }

            // when data fulfill
            if let names = loadable.data {
                dataView(allBook: names, onRetry: loadable.retry)
            }
        }
    }
}
```

## useRecoilCallback

This hook can be used to construct a callback that has access to a Recoil state and the ability to asynchronously update current Recoil state.

You can use `useRecoilCallback()` to lazily read state without subscribing a component to re-render when the state changes.

```swift
 var hookBody: some View {
        let callback = useRecoilCallback { context in
            let someValue = context.get(someAtom)
            
            BookShop.getALLBooks()
                .sink(receiveCompletion: { _ in }, receiveValue: { context.set(BookShop.allBookStore, $0) })
                .store(in: context)
        }
        
        return VStack {
            Button("Get All Books") {
                callback()
            }
            ...
        }
 }
```
