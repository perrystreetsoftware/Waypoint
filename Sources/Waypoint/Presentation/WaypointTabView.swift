import SwiftUI

public struct WaypointTabView: View {
    private let navigator = WaypointNavigator.shared
    private let tabs: [RootTab]

    public init(tabs: [RootTab]) {
        precondition(!tabs.isEmpty, "WaypointTabView needs at least one tab")
        self.tabs = tabs
    }

    public var body: some View {
        @Bindable var navigator = navigator

        TabView(selection: $navigator.selectedTab) {
            ForEach(tabs, id: \.id) { tab in
                RoutedStackView(router: navigator.router(for: tab.id)) {
                    tab.view
                }
                .tag(tab.id)
            }
        }
        .onChange(of: tabs.map(\.id), initial: true) { _, tabIDs in
            navigator.update(tabs: tabIDs)
        }
        .environment(navigator)
    }
}
