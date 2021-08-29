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
            if let err = loadable.error {
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

