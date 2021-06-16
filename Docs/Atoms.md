# Atoms

## Core Concept

Atoms are units of state. They're updateable and subscribable: when an atom is updated,
each subscribed component is re-rendered with the new value. They can be created at runtime, 
too. Atoms can be used in place of React local component state. If the same atom is used from multiple components, 
all those components share their state.

## Basic Usage

```swift
let fontSizeState = atom(14);
```

### Retrieving Values

TBD

### Updating Values
TBD

