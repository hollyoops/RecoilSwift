# Loadable

## Core Concept

A `Loadable` object represents the current state of a Recoil atom or selector. This state may either have a value available, may be in an error state, or may still be pending asynchronous resolution. A Loadable has the following interface:

- `status`: The current state of the atom or selector. Possible values are 'solved', 'error', or 'loading'.

- `data`: The value represented by this Loadable. 

- `error`: the error represented by this Loadable. 

Loadables also contain helper methods for accessing the current state.

`isLoading()` - return true or false

`retry()` - recompute atom or selector 

## useRecoilValueLoadable

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
