import SwiftUI

public struct WaypointTabView: View {
    private let navigator = WaypointNavigator.shared
    private let tabs: [RootTab]

    public init(tabs: [RootTab]) {
        precondition(!tabs.isEmpty, "WaypointTabView needs at least one tab")
        self.tabs = tabs
        self.navigator.update(tabs: tabs.map(\.id))
    }

    public var body: some View {
        @Bindable var navigator = navigator

        TabView(selection: $navigator.selectedTab) {
            // Identity includes position: TabView leaves a moved tab black, so a moved tab is recreated instead.
            ForEach(positionedTabs, id: \.identity) { positioned in
                let tab = positioned.tab
                RoutedStackView(router: navigator.router(for: tab.id)) {
                    tab.view
                }
                .tag(tab.id)
                .tabItem { tab.label }
            }
        }
        .environment(navigator)
    }

    private var positionedTabs: [PositionedTab] {
        tabs.positioned()
    }
}
