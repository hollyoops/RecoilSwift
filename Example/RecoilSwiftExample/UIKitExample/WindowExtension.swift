import UIKit

extension UIApplication {
    static func getWindow() -> UIWindow? {
        if let windowScene = shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first
        }
        return nil
    }
    
    static func present(_ viewControllerToPresent: UIViewController,
                        animated: Bool,
                        completion: (() -> Void)? = nil) {
        if let window = getWindow() {
            window.rootViewController?.present(viewControllerToPresent,
                                               animated: animated,
                                               completion: completion)
        }
    }
}
