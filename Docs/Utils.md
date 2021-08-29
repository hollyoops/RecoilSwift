# Utils

## Selector Family

A selectorFamily is a powerful pattern that is similar to a selector, but allows you to pass parameters to the get and set callbacks of a selector. The selectorFamily() utility returns a function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.

[View More](https://recoiljs.org/docs/api-reference/utils/selectorFamily)

```swift
let myNumberState = atom { 2 }

let myMultipliedState = selectorFamily(
  get: (multiplier, get) => {
     get(myNumberState) * multiplier;
  },
  set: (multiplier, set, newValue) => {
    set(myNumberState, newValue / multiplier);
  },
})

func multipliedView() -> some View {
  // defaults to 2
  const number = useRecoilValue(myNumberState)

  // defaults to 200
  const multipliedNumber = useRecoilValue(myMultipliedState(100))

  return  VStack { ... }
}
```