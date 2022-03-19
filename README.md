# RecoilSwift

[![Version](https://img.shields.io/cocoapods/v/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![License](https://img.shields.io/cocoapods/l/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![Main workflow](https://github.com/hollyoops/RecoilSwift/actions/workflows/main.yml/badge.svg)](https://github.com/hollyoops/RecoilSwift/actions/workflows/main.yml)

RecoilSwift is a lightweight & reactive swift state management library. RecoilSwift is a SwiftUI implementation of [recoil.js](https://recoiljs.org/) which powered by Facebook.

Recoil is an alternate option to replace of the `Redux(reswift)` or `MVVM`.

## What is recoil

[![Watch the video](./Docs/Images/Recoil.png)](https://www.youtube.com/watch?v=_ISAA_Jt9kI)

## State Management Data Flow

```
       ← ← ← ← ← ← ← ← ← ← ← atoms ← ← ← ← ← ← ← ← ← ← ← ← ← ←
       ↓                                                     ↑ 
       ↓                                                     ↑
selectors/callback                              mutable selectors/callback    
       ↓                                                     ↑ 
       ↓                                                     ↑
       → → → → → → → → → → → view(hooks) → → → → → → → → → → →
```

![<img src="image.png" width="700" height="378"/>](./Docs/Images/Flow.png)

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
let someSelector = selectorFamily { (id: String, get: Getter) -> AnyPublisher<[String], Error> in
    // Do some logic in here with id
}
```

**Use Atom / Selector in SwiftUI**

Because the `useRecoilXXX` series API is based on Hooks. so it should follow all the [rule of hooks](https://github.com/ra1028/SwiftUI-Hooks#rules-of-hooks)

```swift
struct YourView: RecoilView { // You have to implement the RecoilView protocol
    var hookBody: some View { 
     let currentBooks = useRecoilValue(currentBooksSelector)

     let allBooks = useRecoilState(allBooksStates)

     let loadable = useRecoilValueLoadable(fetchRemoteDataByID(someID))
      // Your UI Code
    }
}
```

## Advance Usage

**Async task above iOS 15**
```Swift
let fetchRemoteDataById = selectorFamily { (id: String, get: ReadonlyContext) async -> [String] in
   let posts = await fetchAllData()
   return posts[id]
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
                dataView(allBook: names, onRetry: loadable.load)
            }
        }
    }
}
```

**Below iOS 15 you can use Combine to run async tasks...**

```Swift
let fetchRemoteDataById = selectorFamily { (id: String, get: ReadonlyContext) -> AnyPublisher<[String], Error> in
      Deferred {
        Future { promise in
              // Do some logic in here with id
        }
    }.eraseToAnyPublisher()
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
    * [Readonly selector](Docs/Selectors.md#Readonly-Selector)
    * [Writeable selectors](Docs/Selectors.md#Writeable-Selector)
    * [Async selectors](Docs/Selectors.md#Async-Selector)
  
    
* Utils & Hooks
  * [useRecoilValue()][1]
  * [useRecoilState()][2] 
  * [useRecoilCallback()](Docs/Hooks.md#useRecoilCallback)
  * [useRecoilValueLoadable()](Docs/Hooks.md#useRecoilValueLoadable)
  * [selectorFamily()](Docs/Utils.md#Selector-Family)

[1]:Docs/Hooks.md#useRecoilValue(state)
[2]:Docs/Hooks.md#useRecoilValue(state)

## TODOs

- [ ] [performance]avoid duplicated compute when rerender hook
- [ ] [Bug]Use callback not work when you click refetch button while updating view
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
