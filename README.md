# RecoilSwift

RecoilSwift is a lightweight & reactive swift state management library. RecoilSwift is a SwiftUI/UIKit implementation of [recoil.js](https://recoiljs.org/) which power by facebook.

[![Version](https://img.shields.io/cocoapods/v/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![License](https://img.shields.io/cocoapods/l/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![Platform](https://img.shields.io/cocoapods/p/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)

## What is recoil

[![Recoil](https://yt-embed.herokuapp.com/embed?v=_ISAA_Jt9kI)](https://www.youtube.com/watch?v=_ISAA_Jt9kI "Recoil")

## Requirements

- iOS 10+
- Xcode 12.4+

> Note: Very important!!!
>* This repo haven't completely ready yet. The fist release should come out in end of Oct 
>* Currently this lib is not support for UIKit, But it's planned and will come soon

## Installation

- [**Swift Package Manager**](https://swift.org/package-manager/)

> Xcode 11 integrates with libSwiftPM to provide support for iOS, watchOS, macOS and tvOS platforms.

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

**Create Atom:**

```swift
import  SwiftRecoil

let allBooksStore = atom { [Book]() }
```

**Create Readonly Selector:**

```Swift
import  SwiftRecoil

let currentBooksSelector = selector { get -> [Book] in
    let books = get(allBookStore)
    if let category = get(selectedCategoryState) {
        return books.filter { $0.category == category }
    }
    return books
}
```

**Use in SwiftUI**

```swift
import  SwiftRecoil

struct YourView: View {
    @RecoilValue(currentBooksSelector) var currentBooks: [Book]
    @RecoilState(allBooksStore) var allBooks: [Book]
    
    var body: some View {
        VStack {
            ...
            // Retrieve value from selector 
            ForEach(currentBooks, id: \.self) { itemView($0) }
        }.padding()
         .onAppear {
            // Update the value in store manually
            allBooks = Mocks.ALL_BOOKS
         }
    }
}
```

## Advance Usage

**Writeable selector** 

```swift
let tempFahrenheitStore = atom(32)
let tempCelsiusSelector = selector(
    get: { get -> String
        let fahrenheit = get(tempFahrenheitStore)
        return (fahrenheit - 32) * 5 / 9
    },
    set: { set, newValue in
        let newFahrenheit = (newValue * 9) / 5 + 32
        set(tempFahrenheitStore, newFahrenheit)
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
            // now the value of tempFahrenheitStore is 104
        }
    }
}
```

**Async selector with combine**

```swift
func fetchRemoteBookCategories() -> AnyPublisher<[String], Error> {
        Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    promise(.success(["Category 1", "Category 2"]))
                }
            }
        }.eraseToAnyPublisher()
    }

let remoteCategoriesSelector = selector { _ -> AnyPublisher<[String], Error> in
    fetchRemoteBookCategories()
}

struct YourView: View {
    // Async selector have to mark as optional
    @RecoilValue(remoteCategoriesSelector) var remoteCategories: [Book]?
    
    var body: some View {
       if let categories = remoteCategories else {
           return LoadingView()
                    .eraseToAnyView()
       }

        // Retrieve value from selector 
        ForEach(categories, id: \.self) { categoryView($0) }
    }
}
```

## Documentation

* [Basic concept](Docs/Atoms.md)
* [Atoms](Docs/Atoms.md)
* [Selectors](Docs/Selectors.md)
  * [Writeable selectors](Docs/Selectors.md)
  * [Async selectors](Docs/Selectors.md)
* [Use in SwiftUI](Docs/RecoilValues.md)

## TODOs

- [ ] Fix circular reference for selector
- [ ] Caches value for selector
- [ ] Make UIKit compatible

## Reference:

* Facebook Recoil (Recoil.js) 
  * [Recoil website](https://recoiljs.org/)
  * Official facebook experimental repo
  * [Recoil: State Management - Dave McCabe](https://youtu.be/_ISAA_Jt9kI) (ReactEurope 2020 talk)
  
* Recoil for Android
  * [Rekoil](https://github.com/musotec/rekoil)
