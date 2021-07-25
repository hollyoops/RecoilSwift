# Atoms

## Core Concept

Atoms are units of state. They're updateable and subscribable: when an atom is updated, each subscribed component is re-rendered with the new value. 

They can be created at runtime, too. Atoms can be used in place of local component state. If the same atom is used  from multiple components, all those components share their state.

## Basic Usage

### Create Atom

```swift
let fontSizeState = atom(14)
```

or

```swift
let allBookStore = atom { [Book]() }
```

or

```swift
let allBookStore = Atom<[Book]>([])
```

### Retrieving Values

TBD

### Updating Values
TBD

