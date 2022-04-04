import Foundation

internal final class Store {
  private var states: [String: Loadable] = [:]
  private var subscriberMap: [String: [Subscriber]] = [:]
  private let graph = Graph()
  private let checker = DFSCircularChecker()
  static let shared = Store()
  
  func getLoadable<T: RecoilValue>(for value: T) -> Loadable {
    states[value.key] ?? register(value: value)
  }
  
  func makeConnect(key: String, upstream upKey: String) {
    guard states.has(key), states.has(upKey) else {
      dePrint("Cannot make connect! \(key)")
#if DEBUG
      if !states.has(key) {
        dePrint("Node not exist: \(key)")
      }
      
      if !states.has(upKey) {
        dePrint("Node not exist: \(upKey)")
      }
#endif
      return
    }
    
    if graph.isContainEdge(key: upKey, downstream: key) {
      return
    }
    
    if checker.canAddEdge(graph: graph, forKey: upKey, downstream: key) {
      graph.addEdge(key: upKey, downstream: key)
    }
  }
  
  func update<T: RecoilValue>(value: T)  {
    let loadable = register(value: value)
    loadable.load()
  }
  
  func addObserver(forKey key: String, onChange: @escaping () -> Void) -> Subscriber {
    var subscribers = getSubscribers(forKey: key) ?? []
    
    let subscriber = Subscriber(onChange) { [weak self] sub in
      self?.removeObserver(forKey: key, subscriberID: sub.id)
    }
    
    subscribers.append(subscriber)
    subscriberMap[key] = subscribers
    
    return subscriber
  }
  
  private func removeObserver(forKey key: String, subscriberID: UUID) {
    guard var subscribers = getSubscribers(forKey: key) else {
      return
    }
    
    subscribers.removeAll { $0.id == subscriberID }
    if subscribers.isEmpty {
      subscriberMap.removeValue(forKey: key)
    } else {
      subscriberMap[key] = subscribers
    }
  }
  
  @discardableResult
  private func register<T: RecoilValue>(value: T) -> Loadable {
    //        check(value: value)
    let key = value.key
    let box = makeLoadBox(from: value)
    states[key] = box
    return box
  }
  
  private func makeLoadBox<T: RecoilValue>(from value: T) -> LoadBox<T.LoadableType.Data, T.LoadableType.Failure> {
    let loadable = value.makeLoadable()
    guard let loadBox = value.castToLoadBox(from: loadable) else {
      fatalError("Make loadbox failed, only loadbox supported.")
    }
    
    _ = loadBox.observe { [weak self] in
      self?.nodeValueChanged(key: value.key)
    }
    
    return loadBox
  }
  
  private func getSubscribers(forKey key: String) -> [Subscriber]? {
    subscriberMap[key]
  }
  
  private func notifyChanged(forKey key: String) {
    guard let subscribers = getSubscribers(forKey: key) else {
      return
    }
    subscribers.forEach { $0() }
  }
  
  private func nodeValueChanged(key: String) {
    let downstreams = graph.getNode(for: key)?.downstream ?? []
    
    for item in downstreams {
      states[item]?.load()
    }
    
    notifyChanged(forKey: key)
  }
}

extension Dictionary {
  func has(_ key: Self.Key) -> Bool {
    self[key] != nil
  }
}

private extension RecoilValue {
  func castToLoadBox(from loadable: Loadable) -> LoadBox<LoadableType.Data, LoadableType.Failure>? {
    loadable as? LoadBox<LoadableType.Data, LoadableType.Failure>
  }
}
