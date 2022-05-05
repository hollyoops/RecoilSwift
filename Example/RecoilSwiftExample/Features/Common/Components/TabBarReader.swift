import SwiftUI

struct TabBarExtractor: UIViewControllerRepresentable {
    @Binding var tabBar: UITabBar?

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = ViewController()
        controller.onTabBarAppearance = {
            tabBar = $0
        }
        return controller
    }
}

private extension TabBarExtractor {
    class ViewController: UIViewController {
        var onTabBarAppearance: ((UITabBar) -> Void)?

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if let tabBar = self.tabBarController?.tabBar {
                onTabBarAppearance?(tabBar)
            } else {
                print("Could not locate TabBar! Try change extractor place in views hierarchy.")
            }
        }
    }
}

struct TabBarReader<C: View>: View {
    @State private var tabBar: UITabBar?
    
    @ViewBuilder var content: (UITabBar?) -> C
    
    var body: some View {
        content(self.tabBar)
            .background(
                TabBarExtractor(tabBar: $tabBar)
            )
    }
}
