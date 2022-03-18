# Utils

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