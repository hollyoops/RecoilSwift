import SwiftUI
import RecoilSwift

@resultBuilder
struct TabBarBuilder {
    static func buildBlock(_ children: TabBarItem...) -> some View {
        Group {
            ForEach(children, id: \.self.label) { item in
                item
                Spacer()
            }
        }
    }
}

struct TabBar<T: View>: View {
    var content: () -> T
    
    init(@TabBarBuilder content: @escaping () -> T) {
        UITabBar.appearance().isHidden = true
        self.content = content
    }
    
    var body: some View {
        HStack {
            Spacer()
            content()
        }.background(Color.white)
    }
}

struct TabBarItem: View {
    var selectedTab: Binding<Home.Tab>
    var label: String
    var systemImage: String
    
    private var configuration = _Configuration()
    
    struct _Configuration {
        var tag: Home.Tab? = nil
    }
    
    init(selectedTab: Binding<Home.Tab>, label: String, systemImage: String) {
        self.label = label
        self.systemImage = systemImage
        self.selectedTab = selectedTab
    }
    
    var body: some View {
        Label(label, systemImage: systemImage)
            .labelStyle(VerticalLabelStyle())
            .foregroundColor(selectedTab.wrappedValue == configuration.tag ? Color.blue : Color.black)
            .onTapGesture {
                if let tag = configuration.tag {
                    selectedTab.wrappedValue = tag
                }
            }
    }
}

extension TabBarItem {
    func tag(_ tag: HomeTab) -> Self {
        then { $0.configuration.tag = tag }
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.icon
            configuration.title.font(Font.system(size: 12))
        }
    }
}
