# Loadable

## Core Concept

A `Loadable` object represents the current state of a Recoil atom or selector. This state may either have a value available, may be in an error state, or may still be pending asynchronous resolution. A Loadable has the following interface:

- `data(of: type)`: The value represented by this Loadable, return optional value. 

- `errors`: get all errors in this recoil value & it's upstream 

- `hasError`: get all errors in this recoil value & it's upstream 

Loadables also contain helper methods for accessing the current state.

`isLoading` - return true or false

`isAsynchronous` - tell it's asynchronous task or not, return true or false

`retry()` - recompute atom or selector 

## useRecoilValueLoadable

```swift
@RecoilScope var recoil

struct YourView: View {
// In some function 
    var body: some View {
        let id = recoil.useValue(selectedCategoryState)
        let loadable = recoil.useLoadable(fetchRemoteDataById(id))
        
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
