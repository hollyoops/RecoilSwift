# RecoilSwift

RecoilSwift is a lightweight & reactive swift state management library. RecoilSwift is a SwiftUI implementation of [recoil.js](https://recoiljs.org/) which powered by Facebook.

Recoil is an alternate option to replace of the `Redux(reswift)` or `MVVM`.

[![Version](https://img.shields.io/cocoapods/v/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![License](https://img.shields.io/cocoapods/l/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![Platform](https://img.shields.io/cocoapods/p/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)

## What is recoil

[![Recoil](https://yt-embed.herokuapp.com/embed?v=_ISAA_Jt9kI)](https://www.youtube.com/watch?v=_ISAA_Jt9kI "Recoil")

## Requirements

- iOS 13+
- Xcode 12.4+

*NOTE: Currently this library only support for SwiftUI, UIKit is not available. But it planned.*

> In recent release, we re-implement this library with react hooks pattern which making the usage of this lib is more similar with official way. 

## Installation

- [**Swift Package Manager**](https://swift.org/package-manager/)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/hollyoops/RecoilSwift.git`) and click **Next**.
3. For **Rules**, select **Branch** (with branch set to `master`).
4. Click **Finish**.

- [**CocoaPods**](https://cocoapods.org) 

RecoilSwift is available through CocoaPods. To install it, simply add the following line to your Podfile:

```ruby
pod 'RecoilSwift'
```

## State Management Data Flow

```
    ← ← ← ← ← ← ← ← ← atoms ← ← ← ← ← ← ← ←
    ↓                                     ↑ 
    ↓                                     ↑
selectors                       set / writeable selectors 
    ↓                                     ↑ 
    ↓                                     ↑                                               
    → → → → → → → view(hooks) → → → → → → →
```

![<img src="image.png" width="700" height="378"/>](./Docs/Images/Flow.png)

## Basic Usage

**Create Atom / Selector:**

```swift
// Create a Atom
let allBooksState = atom { [Book]() }

// Create readonly Selector
let currentBooksSelector = selector { get -> [Book] in
    let books = get(allBooksState)
    if let category = get(selectedCategoryState) {
        return books.filter { $0.category == category }
    }
    return books
}

// Create parameterized selector 
let someSelector = selectorFamily { (id: String, get: ReadonlyContext) -> AnyPublisher<[String], Error> in
    // Do some logic in here with id
}
```

**Use Atom / Selector in SwiftUI**

Because the `useRecoilXXX` series API is based on Hooks. so it should follow all the [rule of hooks](https://github.com/ra1028/SwiftUI-Hooks#rules-of-hooks)

```swift
struct YourView: RecoilView { // You have to implement the RecoilView protocol
    var hookBody: some View { 
     let currentBooks = useRecoilValue(currentBooksSelector)

     let allBooks = useRecoilState(allBooksStore)

     let loadable = useRecoilValueLoadable(fetchRemoteDataByID(someID))
      // Your UI Code
    }
}
```

## Advance Usage

**Async task**
```Swift
let fetchRemoteDataById = selectorFamily { (id: String, get: ReadonlyContext) -> AnyPublisher<[String], Error> in
      Deferred {
        Future { promise in
              // Do some logic in here with id
        }
    }.eraseToAnyPublisher()
}

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

## Documentation

* [Core concepts](https://recoiljs.org/docs/introduction/core-concepts)
* [Atoms](Docs/Atoms.md)
* [Selectors](Docs/Selectors.md)
* [Loadable](Docs/Loadable.md)
* [Hooks](Docs/Hooks.md)

## API Reference

* State
  * [atom()](Docs/Atoms.md)
  * [selector()](Docs/Selectors.md)
    * [ReadOnly selector](Docs/Selectors.md#Readonly-Selector)
    * [Writeable selectors](Docs/Selectors.md#Writeable-Selector)
    * [Async selectors](Docs/Selectors.md#Async-Selector)
  
    
* Utils & Hooks
  * [useRecoilValue()][1]
  * [useRecoilState()][2] 
  * [Writeable selectors](Docs/Selectors.md)
  * [Async selectors](Docs/Selectors.md)
* [Use in SwiftUI](Docs/RecoilValues.md)
  * [useRecoilValueLoadable()](Docs/Hooks.md#useRecoilValueLoadable)
  * [selectorFamily()](Docs/Utils.md#Selector-Family)

[1]:Docs/Hooks.md#useRecoilValue(state)
[2]:Docs/Hooks.md#useRecoilValue(state)

## TODOs

- [ ] [feature]Add `refresh` for loadable
- [ ] [performance]Fix circular reference for selector
- [ ] [performance]Caches value for selector
- [ ] [feature]Make UIKit compatible

## Reference:

* Facebook Recoil (Recoil.js) 
  * [Recoil website](https://recoiljs.org/)
  * [Official facebook recoil repo](https://github.com/facebookexperimental/Recoil)
  
* Recoil for Android
  * [Rekoil](https://github.com/musotec/rekoil)

* Hooks
  * [React Hooks](https://reactjs.org/docs/hooks-intro.html)
  * [SwiftUI Hooks](https://github.com/ra1028/SwiftUI-Hooks)