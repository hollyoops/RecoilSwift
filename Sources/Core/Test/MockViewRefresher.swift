public final class MockViewRefresher: ViewRefreshable {
    private(set) var refreshCount: Int = 0
    private let render: (() -> Void)?
    
    init(render: (() -> Void)? = nil) {
        self.render = render
    }
    
    func refresh() {
        self.refreshCount += 1
        render?()
    }
    
    public func reset() {
        refreshCount = 0
    }
}
