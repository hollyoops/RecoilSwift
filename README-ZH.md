# RecoilSwift

[![Version](https://img.shields.io/cocoapods/v/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![License](https://img.shields.io/cocoapods/l/RecoilSwift.svg?style=flat)](https://cocoapods.org/pods/RecoilSwift)
[![Main workflow](https://github.com/hollyoops/RecoilSwift/actions/workflows/main.yml/badge.svg)](https://github.com/hollyoops/RecoilSwift/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/hollyoops/RecoilSwift/branch/master/graph/badge.svg?token=AZ9YSL9H0H)](https://codecov.io/gh/hollyoops/RecoilSwift)


RecoilSwift 是一个针对SwiftUI轻量的状态管理框架。你可以他来代替传统的`MVVM` 或者 `Redux-like` (例如: `reswift`、`TCA`)的状态方案。

## 什么是Recoil

`recoil` 是 `Facebook` 提出的一种状态管理方案。他简化了 `Redux`，是其的一种替代方案。

您可以观看下面的视频，或者访问[官网](https://recoiljs.org/)进行快速的了解。

[![Watch the video](./Docs/Images/Recoil.png)](https://www.youtube.com/watch?v=_ISAA_Jt9kI)

## 动机

为什么要有 Recoil、RecoilSwift? 

现有主流的iOS架构模式（如：`MVVM`）使用太多痛点，且不能很好的配合声明式编程。 所以在声明式的UI框架中，很多人选择了 `Redux-like` 的方案 (如：`ReSwift`、`TCA`）。 然而 `Redux` 这种方案比较复杂有一定的学习成本，且模板代码太多。我们就基于 `recoil`，实现了 `RecoilSwift`。recoil能做的，redux都可以做。但是recoil主要有几个特点： 

- 概念简单, 上手成本低  
- 非单一store  
- 响应式  
- 无模板代码  
  
使用recoil后，代码会非常的简洁，且不同的组件可以非常方便的共享状态。


## 状态管理流程

Recoil中主要有两个基本的概念，`atom` 和 `selector`。 `atom` 是原始（同步或异步）的数据, `selector`是指衍生的（同步或异步）数据。

一般情况，我们会在我们的 `selector` 中放业务逻辑。这些业务单元是可以被组合的。如下图：

> 1. Recoil 状态是原子的，状态和状态之间可以常方便的组合重用。  
> 2. Recoil 状态是响应式的，当任何上游的值变了，下游的selector自动重新执行计算逻辑，获得最新的值。  
> 3. Recoil 状态是全局的，跨组件共享状态十分的容易。

这三个特性非常有用，让你代码更加简洁，重用性更高的基石。

![<img src="image.png" width="700" height="378"/>](./Docs/Images/Flow.png)

- 在定义`Selector`的时候,调用 `get` 获取其他的状态的值，并且建立上下游关系 
- `atom` 不能和其他 `atom` 建立关系   
- `selector`可以和 `atom` 和 `Selector` 建立关系
  

## 前置条件

- iOS 13+
- Xcode 13.2+

*注意: 当前只支持swiftUI, 暂时不支持UIKit*

> 最新的版本，我们基于react hooks进行重构。所以提供的API接口，更加接近官方提供的接口。对于前端同学基本可以零成本使用该库。Native的同学，需要了解点 hooks的知识。

## 安装

- [**Swift Package Manager**](https://swift.org/package-manager/)

```
.Pagckage(url: "https://github.com/hollyoops/RecoilSwift.git", from: "master")
```

- [**CocoaPods**](https://cocoapods.org) 

你也可以用CocoaPods安装

```ruby
pod 'RecoilSwift'
```

## 基本用法

**创建 Atom / Selector:**

```swift
// 创建了一个数据源，他存了一个Book列表
let allBooksState = atom { [Book]() }

// 创建了一个只读的Selector，它实现了一定的业务逻辑。这里的逻辑是对书籍进行按照分类过滤
let currentBooksSelector = selector { get -> [Book] in
 // 注意： 下面这个简单的 `get` 方法，是从其他的`atom/selector`中获取数据
 // 其实它还和`allBooksState`建立了上下游关系。当allBooksState数据发生变化,
 // 当前selector会自动重新计算。这让不同状态可以组合，重用，非常强大!
    let books = get(allBooksState)
    if let category = get(selectedCategoryState) {
        return books.filter { $0.category == category }
    }
    return books
}

// 创建一个自定义参数的 Selector。第一个参数是 一个Book的ID
let someSelector = selectorFamily { (id: String, get: Getter) -> AnyPublisher<[String], Error> in
    // 用id做一些操作，例如通过id，拉去API之类的
}
```

**使用 Atom / Selector**

在最新的版本中，我们使用 `hooks` 的思路（基于`SwiftUIHooks`）。所以你只能用 `useRecoilXXX` API来使用`Atom & Selector`。 并且你需要准守[hooks的规则](https://github.com/ra1028/SwiftUI-Hooks#rules-of-hooks)

```swift
// 为了使用Hooks, 你必须实现 RecoilView 协议， 并且实现 hookbody方法
struct YourView: RecoilView { 
    var hookBody: some View { 
     let currentBooks = useRecoilValue(currentBooksSelector)

     let allBooks = useRecoilState(allBooksStates)

     let loadable = useRecoilValueLoadable(fetchRemoteDataByID(someID))
      // Your UI Code
    }
}
```

## 更多用法

- `atomFamily/selectorFamily` 主要是用于动态参数的状态。下面这个用法，我们实现了一个异步的atom，他的数据源来源于服务器

**您可以用Async 来异步任务**
```Swift
let fetchRemoteDataById = atomFamily { (id: String, get: Getter) async -> [String] in
   let posts = await fetchAllData()
   return posts[id]
}

// 
func someView() -> some View {
    HookScope { // 如果你的View 没有实现RecoilView 协议, 你可以用`HookScope` 包裹住你的recoil代码
        let id = useRecoilValue(selectedCategoryState)
        let loadable = useRecoilValueLoadable(fetchRemoteDataById(id))
        
        //当 id的值发生改变 或 api 调用成功。该view会自动重新渲染。
        return VStack {
            // 当正在loading ，显示spinner
            if loadable.isLoading {
                ProgressView()
            }

            // 当发生错误，渲染错误界面
            if let err = loadable.errors.first {
                errorView(err)
            }

            // 当拿到数据，渲染正常内容界面
            if let names = loadable.data {
                dataView(allBook: names, onRetry: loadable.load)
            }
        }
    }
}
```

**你可以用Combine来执行异步任务...**

```Swift
let fetchRemoteDataById = selectorFamily { (id: String, get: Getter) -> AnyPublisher<[String], Error> in
      Deferred {
        Future { promise in
              // Do some logic in here with id
        }
    }.eraseToAnyPublisher()
}
```

## Demo

下面这个demo, 虽然功能很简单。但是强烈建议你去看看对应[代码](./Example/RecoilSwiftExample/Features/Cart/CartRecoil.swift)。recoil和redux一样面向状态编程。不同的页面状态共享, 重用变的十分容易。且状态的逻辑都是纯函数，测试也十分简单容易。

![demo](./Docs/Images/Example.gif)


## 文档

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
  * [atomFamily()](Docs/Utils.md#Selector-Family)
  * [selectorFamily()](Docs/Utils.md#Atom-Family)

[1]:Docs/Hooks.md#useRecoilValue(state)
[2]:Docs/Hooks.md#useRecoilValue(state)

## 资料:

* Facebook Recoil (Recoil.js) 
  * [Recoil website](https://recoiljs.org/)
  * [Official facebook recoil repo](https://github.com/facebookexperimental/Recoil)
  
* Recoil for Android
  * [Rekoil](https://github.com/musotec/rekoil)

* Hooks
  * [React Hooks](https://reactjs.org/docs/hooks-intro.html)
  * [SwiftUI Hooks](https://github.com/ra1028/SwiftUI-Hooks)
